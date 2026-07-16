#!/usr/bin/env python
"""tools/playtest/mkvideo.py — assemble a recorded run into an mp4.

Input is a `--record` capture directory from the app (frame_%06d.png at
60/`--record-every` fps plus events.jsonl audio taps on the 60Hz frame
clock). The soundtrack is rebuilt offline from the taps against the same
wav bank the game plays, so the video carries the real game audio without
needing a live mixer during headless capture.

    uv run python tools/playtest/mkvideo.py --rec DIR --out run.mp4 --fps 30

`--segments "12-40,95-120"` (seconds, on the capture clock) cuts and
concatenates just those spans instead of encoding the whole run.
"""

from __future__ import annotations

import argparse
import bisect
import json
import shutil
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np

SFX_DIR = Path(__file__).resolve().parents[2] / "game" / "assets" / "sfx"
RATE = 44100


def _load_wav(name: str, cache: dict) -> np.ndarray | None:
    if name in cache:
        return cache[name]
    path = SFX_DIR / f"{name}.wav"
    data = None
    if path.exists():
        with wave.open(str(path)) as w:
            assert w.getframerate() == RATE and w.getsampwidth() == 2, name
            raw = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
            if w.getnchannels() == 2:
                raw = raw.reshape(-1, 2).mean(axis=1)
            data = raw.astype(np.float32) / 32768.0
    else:
        print(f"[mkvideo] missing sfx: {name}.wav", file=sys.stderr)
    cache[name] = data
    return data


def _place(mix: np.ndarray, snd: np.ndarray, t: float, lvol: float, rvol: float,
           loop_until: float | None = None) -> None:
    start = int(t * RATE)
    if loop_until is None:
        end = min(len(mix), start + len(snd))
        if end > start:
            seg = snd[: end - start]
            mix[start:end, 0] += seg * lvol
            mix[start:end, 1] += seg * rvol
        return
    end = min(len(mix), int(loop_until * RATE))
    pos = start
    while pos < end:
        n = min(len(snd), end - pos)
        mix[pos:pos + n, 0] += snd[:n] * lvol
        mix[pos:pos + n, 1] += snd[:n] * rvol
        pos += n


MUSIC_BANK = Path(__file__).resolve().parents[2] / \
    "game/perihelion/assets/music/hymn01"


def _load_stem(p: Path) -> np.ndarray:
    if p.suffix == ".ogg":
        import soundfile as sf
        data, sr = sf.read(str(p), dtype="float32")
        assert sr == RATE, f"{p}: {sr}Hz"
        return data if data.ndim == 2 else np.stack([data, data], axis=1)
    with wave.open(str(p)) as w:
        data = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
        ch = w.getnchannels()
    data = data.astype(np.float32) / 32767.0
    return data.reshape(-1, ch) if ch == 2 else \
        np.stack([data, data], axis=1)


MUSIC_ROOTS = [
    Path(__file__).resolve().parents[2] / "game/assets/music",
    Path(__file__).resolve().parents[2] / "out/banks",
]


def _resolve_bank(name: str) -> Path | None:
    for root in MUSIC_ROOTS:
        d = root / name
        if (d / "bank.json").exists():
            return d
    return None


def _mix_music_rich(out_mix, events, duration_s) -> bool:
    """Offline twin of the CHUNK-QUEUE mixer: music_bar taps carry the
    full per-bar decision (form-local bar index + every lane's content
    and gain), and music_bank taps carry the ENGINE's own bank rotation
    (director 2026-07-16: the engine mixes and matches; no env var).
    Riser/sting from their own taps, from the bank active at the time.
    music_halt taps (death) cut ALL music dead until the engine
    restarts. Seamless loop steers tap music_jump with a '~s' suffix
    and get NO arrival ramp; true jumps ramp every lane EXCEPT
    holy/bed -- PRAYER never stops (director 2026-07-17)."""
    bank_evs = [e for e in events if e["kind"] == "music_bank"]
    bar_evs = [e for e in events if e["kind"] == "music_bar"]
    jump_ts = [e["t"] for e in events if e["kind"] == "music_jump"
               and not str(e["name"]).endswith("~s")]
    halt_ts = [e["t"] for e in events if e["kind"] == "music_halt"]
    if not bar_evs or not bank_evs:
        return False
    # music renders into its own buffer so a death halt can cut it
    # sample-exactly without touching SFX
    mix = np.zeros_like(out_mix)

    banks: dict[str, dict] = {}

    def bank_at(t):
        name = bank_evs[0]["name"]
        for e in bank_evs:
            if e["t"] <= t:
                name = e["name"]
        if name not in banks:
            d = _resolve_bank(name)
            if d is None:
                print(f"[mkvideo] unknown bank {name!r}", file=sys.stderr)
                banks[name] = None
            else:
                meta = json.loads((d / "bank.json").read_text())
                banks[name] = dict(dir=d, bars=int(meta["bars"]),
                                   bar_s=240.0 / float(meta["bpm"]),
                                   stems={})
        return banks[name]

    def stem(bk, key):
        if key in ("silence", "None", None) or bk is None:
            return None
        stems = bk["stems"]
        if key not in stems:
            f = None
            for ext in ("wav", "ogg"):
                q = bk["dir"] / f"{key}.{ext}"
                if q.exists():
                    f = q
                    break
            stems[key] = _load_stem(f) if f is not None else None
        return stems[key]

    n_total = len(mix)
    # bar 0 plays from t=0 with the first tap's lane set (the engine
    # starts lanes before the first boundary tap fires)
    first = bar_evs[0]
    bk0 = bank_at(first["t"])
    seq = [dict(t=max(0.0, first["t"] - (bk0["bar_s"] if bk0 else 2.0)),
                detail=first["name"], bar0=True)] + \
        [dict(t=e["t"], detail=e["name"], bar0=False) for e in bar_evs]
    prev_idx = None
    prev_bank = None
    for ev in seq:
        bk = bank_at(ev["t"])
        if bk is None:
            continue
        bar_n = int(bk["bar_s"] * RATE)
        parts = ev["detail"].split("|")
        bar_idx = int(parts[0]) % bk["bars"]
        if ev["bar0"]:
            bar_idx = (int(parts[0]) - 1) % bk["bars"]
        # arrival fade-in: only TRUE jumps (music_jump taps) and bank
        # rotations ramp -- composed loop points land clean
        ramp_in = (prev_bank is not None and bk is not prev_bank) or \
            any(abs(ev["t"] - jt) < 0.5 for jt in jump_ts)
        prev_idx, prev_bank = bar_idx, bk
        s0 = int(ev["t"] * RATE)
        if s0 >= n_total:
            break
        for lane in parts[1:]:
            ln, key, gain = lane.rsplit(":", 2)[0], \
                lane.rsplit(":", 2)[1], float(lane.rsplit(":", 2)[2])
            if gain <= 0.001:
                continue
            fade = key.endswith("~f")     # farewell bar: ramp to zero
            if fade:
                key = key[:-2]
            snd = stem(bk, key)
            if snd is None:
                continue
            a = min(bar_idx * bar_n, len(snd) - 1)
            b = min(a + bar_n, len(snd))
            seg = snd[a:b]
            n = min(len(seg), n_total - s0)
            g = min(1.0, gain) * 0.8
            if fade:
                env = np.linspace(1.0, 0.0, n, dtype=np.float32)
            elif ramp_in and ln not in ("holy", "bed"):
                # the through-line lanes never dip for an arrival
                env = np.linspace(0.0, 1.0, n, dtype=np.float32)
            else:
                env = None
            if env is not None:
                mix[s0:s0 + n, 0] += seg[:n, 0] * g * env
                mix[s0:s0 + n, 1] += seg[:n, 1] * g * env
            else:
                mix[s0:s0 + n, 0] += seg[:n, 0] * g
                mix[s0:s0 + n, 1] += seg[:n, 1] * g
    # riser: continuous loop under its tapped gain envelope, from the
    # bank active at each tap
    riser_evs = [e for e in events if e["kind"] == "music_riser"]
    if riser_evs:
        env = np.zeros(n_total, dtype=np.float32)
        tl = [(0.0, 0.0)] + [(e["t"], float(e["name"])) for e in riser_evs]
        for i, (ts, val) in enumerate(tl):
            te = tl[i + 1][0] if i + 1 < len(tl) else duration_s
            env[int(ts * RATE):min(int(te * RATE), n_total)] = val * 0.85
        # the riser ROTATES with the bank (was pinned to the first
        # bank's stem for the whole video -- workflow review)
        marks = [0.0] + [e["t"] for e in bank_evs] + [duration_s]
        for a, b in zip(marks[:-1], marks[1:]):
            s0, s1 = int(a * RATE), min(int(b * RATE), n_total)
            if s1 <= s0:
                continue
            bk = bank_at(a + 1e-3)
            rsnd = stem(bk, "riser") if bk else None
            if rsnd is None:
                continue
            span = s1 - s0
            looped = np.tile(rsnd, (int(np.ceil(span / len(rsnd))),
                                    1))[:span]
            mix[s0:s1, 0] += looped[:, 0] * env[s0:s1]
            mix[s0:s1, 1] += looped[:, 1] * env[s0:s1]
    for e in events:
        if e["kind"] == "music_sting":
            bk = bank_at(e["t"])
            ssnd = stem(bk, "sting") if bk else None
            if ssnd is not None:
                _place(mix, ssnd.mean(axis=1), e["t"], 0.8, 0.8)
        elif e["kind"] == "music_stab":
            bk = bank_at(e["t"])
            ssnd = stem(bk, "stab") if bk else None
            if ssnd is not None:
                _place(mix, ssnd.mean(axis=1), e["t"], 0.7, 0.7)
    # death halts (music_halt): the music stops DEAD -- zero everything
    # from the halt until the engine's next restart bar (if any)
    for ht in halt_ts:
        resume = next((e["t"] for e in bar_evs if e["t"] > ht),
                      duration_s + 1.0)
        h0 = max(0, int(ht * RATE))
        h1 = min(n_total, int(resume * RATE))
        if h1 > h0:
            mix[h0:h1] = 0.0
    out_mix += mix
    return True


def _mix_music(mix: np.ndarray, events: list, duration_s: float) -> None:
    """Rebuild the dynamic-music mix from the logged music taps —
    the offline twin of game/perihelion/music.py's live mixer. Stems loop
    continuously from the first music event; logged state changes move
    the stem gains stepwise (binary walls/vacuums, already bar-quantized
    at tap time); the riser follows its logged gain; stings land at their
    logged instants."""
    mevents = [e for e in events if e["kind"].startswith("music")]
    # rich chunk-queue recording? the engine taps its own bank rotation
    # (music_bank events) -- no env vars, no flags (releasable-game law)
    if any(e["kind"] == "music_bank" for e in events):
        if _mix_music_rich(mix, events, duration_s):
            return
    if not MUSIC_BANK.exists():
        return
    # music runs from level start (prayer) even if no state change was
    # ever logged — an all-calm capture still carries the prayer bed
    stems = {}
    for name in ("prayer", "contempt", "stalwart", "riser"):
        p = MUSIC_BANK / f"{name}.wav"
        if p.exists():
            with wave.open(str(p)) as w:
                data = np.frombuffer(w.readframes(w.getnframes()),
                                     dtype=np.int16)
                if w.getnchannels() == 2:
                    data = data.reshape(-1, 2).mean(axis=1)
                stems[name] = data.astype(np.float32) / 32767.0

    t0 = 0.0
    n_total = len(mix)
    # continuous-value timelines, stepwise at logged (bar-quantized) taps
    IDX = {"prayer": 0, "contempt": 1, "stalwart": 2}
    val_evs = [e for e in mevents if e["kind"] == "music_vals"]
    vals_tl = [(t0, (1.0, 0.0, 0.0))] + \
        [(e["t"], tuple(float(v) for v in e["name"].split(",")))
         for e in val_evs]
    riser_evs = [e for e in mevents if e["kind"] == "music_riser"]
    riser_tl = [(t0, 0.0)] + [(e["t"], float(e["name"])) for e in riser_evs]

    BAR = 240.0 / 140.0
    fade_n = int(1.5 * BAR * RATE)       # falls fade ~1.5 bars (director's
    #                                      transition ruling); rises step
    for name, snd in stems.items():
        L = len(snd)
        tl = riser_tl if name == "riser" else vals_tl
        env = np.zeros(n_total, dtype=np.float32)
        for i, (ts, val) in enumerate(tl):
            te = tl[i + 1][0] if i + 1 < len(tl) else duration_s
            g = (val * 0.85) if name == "riser" else val[IDX[name]] ** 0.5
            s0, s1 = int(ts * RATE), min(int(te * RATE), n_total)
            if s1 > s0:
                env[s0:s1] = g
        # derivative-aware smoothing: rises instant, falls ramped
        out_env = env.copy()
        cur = env[0] if len(env) else 0.0
        step = 1.0 / fade_n
        for i in range(1, n_total):
            tgt = env[i]
            cur = tgt if tgt >= cur else max(tgt, cur - step)
            out_env[i] = cur
        if not out_env.any():
            continue
        looped = np.tile(snd, int(np.ceil(n_total / L)))[:n_total]
        seg = looped * out_env * 0.8
        mix[:, 0] += seg
        mix[:, 1] += seg
    # stings
    sting_p = MUSIC_BANK / "sting.wav"
    if sting_p.exists():
        with wave.open(str(sting_p)) as w:
            sdata = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
            if w.getnchannels() == 2:
                sdata = sdata.reshape(-1, 2).mean(axis=1)
            sdata = sdata.astype(np.float32) / 32767.0
        for e in mevents:
            if e["kind"] == "music_sting":
                _place(mix, sdata, e["t"], 0.8, 0.8)


def build_mix(events_path: Path, duration_s: float, out_wav: Path) -> None:
    events = [json.loads(line) for line in events_path.read_text().splitlines()
              if line.strip()]
    mix = np.zeros((int(duration_s * RATE) + RATE, 2), dtype=np.float32)
    cache: dict = {}

    # ambience/heartbeat are looped spans: each runs until the next event of
    # its kind (or capture end)
    amb = [e for e in events if e["kind"] == "ambience"]
    for i, e in enumerate(amb):
        until = amb[i + 1]["t"] if i + 1 < len(amb) else duration_s
        if not e["name"]:
            continue
        snd = _load_wav(e["name"], cache)
        if snd is not None:
            _place(mix, snd, e["t"], e["vol"], e["vol"], loop_until=until)
    hb = [e for e in events if e["kind"].startswith("heartbeat")]
    for i, e in enumerate(hb):
        if e["kind"] != "heartbeat_on":
            continue
        until = hb[i + 1]["t"] if i + 1 < len(hb) else duration_s
        snd = _load_wav(e["name"], cache)
        if snd is not None:
            _place(mix, snd, e["t"], e["vol"], e["vol"], loop_until=until)

    for e in events:
        if e["kind"] != "sfx":
            continue
        snd = _load_wav(e["name"], cache)
        if snd is None:
            continue
        v, pan = e["vol"], e["pan"]
        _place(mix, snd, e["t"], (1.0 - pan) * v, pan * v)

    _mix_music(mix, events, duration_s)

    peak = float(np.abs(mix).max()) or 1.0
    if peak > 0.9:
        mix *= 0.9 / peak
    pcm = (mix * 32767.0).astype(np.int16)
    with wave.open(str(out_wav), "w") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())


def encode(rec: Path, fps: int, scale: int, mix_wav: Path, out: Path,
           frames_dir: Path | None = None, prescaled: bool = False) -> None:
    d = frames_dir or rec
    ext = "jpg" if list(d.glob("frame_000000.jpg")) else "png"
    src = d / f"frame_%06d.{ext}"
    cmd = ["ffmpeg", "-y", "-v", "error",
           "-framerate", str(fps), "-i", str(src),
           "-i", str(mix_wav),
           "-c:v", "libx264", "-preset", "medium", "-crf", "20",
           "-pix_fmt", "yuv420p"]
    if not prescaled:
        cmd += ["-vf", f"scale={640 * scale}:{360 * scale}:flags=neighbor"]
    cmd += ["-c:a", "aac", "-b:a", "160k", "-shortest", str(out)]
    subprocess.run(cmd, check=True)


# --- music-telemetry overlay (director 2026-07-16: "pop up meters for
# the three factors both pre and post filter on the right hand side, as
# well as a visualizer showing the lanes and what tracks are playing in
# them"; overhauled 2026-07-17 per director sign-off: real DAW waveforms
# per lane for EVERY sound the music system makes (not just the 9 chunk
# lanes), NOW/NEXT labelled with the specific stem+form-bar so a silent
# lane reads as "the planner stopped it" vs "playback broke", and death/
# loop/release/riser events legible in the ticker) --------------------

FACTOR_COLORS = {          # match the value battery's identities
    "PRAYER": (110, 190, 255),
    "CONTEMPT": (255, 110, 100),
    "STALWART": (255, 190, 90),
}
CHUNK_LANES = ["bed", "drums", "holy", "groove", "wall", "bass",
               "lead", "lead2", "boss"]
LANE_ORDER = CHUNK_LANES + ["riser", "sting", "stab"]
LANE_COLORS = {
    "bed": (140, 140, 170), "drums": (230, 160, 90),
    "holy": (110, 190, 255), "groove": (255, 110, 100),
    "wall": (255, 190, 90), "bass": (170, 130, 220),
    "lead": (130, 220, 150), "lead2": (100, 190, 120),
    "boss": (255, 80, 160), "riser": (190, 140, 255),
    "sting": (255, 205, 90), "stab": (255, 110, 70),
}

STEM_PEAK_HZ = 210   # 44100 / 210 == 210 exactly -- clean per-stem downsample
LANE_PEAK_HZ = 200   # resolution of the whole-video per-lane peak timelines


def _series(events: list, kind: str) -> list[tuple[float, tuple]]:
    out = []
    for e in events:
        if e["kind"] == kind:
            out.append((e["t"], tuple(float(x)
                                      for x in e["name"].split(","))))
    return out


def _bar_series(events: list) -> list[tuple[float, tuple[int, dict]]]:
    """(t, (formBarIdx, {lane: (key, gain, farewell)})) -- the RAW tapped
    bar index (matches music_dbg's 'form:' field), not modulo'd into the
    bank's fixed bar count (that modulo only matters for audio slicing,
    see _build_lane_timelines)."""
    out = []
    for e in events:
        if e["kind"] != "music_bar":
            continue
        parts = e["name"].split("|")
        bar_idx = int(parts[0])
        lanes = {}
        for part in parts[1:]:
            ln, key, gain = part.rsplit(":", 2)
            fade = key.endswith("~f")
            if fade:
                key = key[:-2]
            lanes[ln] = (key, float(gain), fade)
        out.append((e["t"], (bar_idx, lanes)))
    return out


def _at(series, t, default):
    """Latest sample at or before t (series is time-ordered)."""
    lo, hi = 0, len(series)
    while lo < hi:
        mid = (lo + hi) // 2
        if series[mid][0] <= t:
            lo = mid + 1
        else:
            hi = mid
    return series[lo - 1][1] if lo else default


def _last_at_or_before(ts: list[float], t: float) -> float | None:
    i = bisect.bisect_right(ts, t)
    return ts[i - 1] if i else None


def _bank_dirs(events: list) -> list[tuple[float, dict | None]]:
    """Time-ordered (t, bank-dict) for every music_bank rotation tap;
    bank-dict carries dir/bars/bar_s (director 2026-07-16: the engine
    mixes and matches its own bank rotation, no env vars)."""
    out = []
    cache: dict = {}
    for e in events:
        if e["kind"] != "music_bank":
            continue
        name = e["name"]
        if name not in cache:
            d = _resolve_bank(name)
            if d is None:
                cache[name] = None
            else:
                meta = json.loads((d / "bank.json").read_text())
                cache[name] = dict(dir=d, bars=int(meta["bars"]),
                                   bar_s=240.0 / float(meta["bpm"]))
        out.append((e["t"], cache[name]))
    return out


def _stem_peaks(bank: dict | None, key: str, cache: dict) -> np.ndarray | None:
    """(min, max) peak envelope of one whole stem file, downsampled once
    to STEM_PEAK_HZ bins/sec and cached by (bank dir, key) -- every stem
    gets decoded and downsampled exactly once no matter how many bars or
    frames reference it (the ~8000-frame render has to stay cheap)."""
    if bank is None or key in ("silence", "None", None):
        return None
    ck = (str(bank["dir"]), key)
    if ck in cache:
        return cache[ck]
    f = None
    for ext in ("wav", "ogg"):
        q = bank["dir"] / f"{key}.{ext}"
        if q.exists():
            f = q
            break
    if f is None:
        cache[ck] = None
        return None
    snd = _load_stem(f).mean(axis=1)
    hop = RATE // STEM_PEAK_HZ
    nb = len(snd) // hop
    if nb <= 0:
        cache[ck] = None
        return None
    seg = snd[: nb * hop].reshape(nb, hop)
    peaks = np.stack([seg.min(axis=1), seg.max(axis=1)],
                     axis=1).astype(np.float32)
    cache[ck] = peaks
    return peaks


def _resample_peaks(src: np.ndarray, a_bin: int, b_bin: int,
                    n_dst: int) -> np.ndarray:
    """Nearest-bin resample of src[a_bin:b_bin] (peak bins) to n_dst
    destination columns."""
    src_n = max(1, b_bin - a_bin)
    idx = a_bin + (np.arange(n_dst) * (src_n / n_dst)).astype(np.int64)
    idx = np.clip(idx, 0, len(src) - 1)
    return src[idx]


def _build_lane_timelines(events: list,
                          duration_s: float) -> dict[str, np.ndarray]:
    """One pass over the tap log building a (min, max) peak-amplitude
    timeline per lane at LANE_PEAK_HZ for the WHOLE video, so per-frame
    rendering is just a numpy slice -- decoding/scaling every stem 8000
    times would blow the render budget (director: "minutes, not hours").
    Chunk lanes (the 9 music_bar lanes) are assembled bar-by-bar from
    the schedule, amplitude-scaled by that bar's gain and ramped 1->0
    for a farewell (~f) bar; riser is the riser stem under its tapped
    envelope; sting/stab are the one-shot's own peak envelope dropped in
    at each trigger tap."""
    n_bins = int(duration_s * LANE_PEAK_HZ) + 1
    timelines = {ln: np.zeros((n_bins, 2), dtype=np.float32)
                 for ln in LANE_ORDER}
    banks = _bank_dirs(events)
    if not banks:
        return timelines
    stem_cache: dict = {}
    hop = RATE // STEM_PEAK_HZ

    def bank_at(t):
        return _at(banks, t, banks[0][1])

    bar_evs = [e for e in events if e["kind"] == "music_bar"]
    if bar_evs:
        first = bar_evs[0]
        bk0 = bank_at(first["t"])
        seq = [dict(t=max(0.0, first["t"] - (bk0["bar_s"] if bk0 else 2.0)),
                    detail=first["name"], bar0=True)] + \
            [dict(t=e["t"], detail=e["name"], bar0=False) for e in bar_evs]
        for i, ev in enumerate(seq):
            t0 = ev["t"]
            t1 = seq[i + 1]["t"] if i + 1 < len(seq) else duration_s
            bk = bank_at(t0)
            if bk is None:
                continue
            bar_n = int(bk["bar_s"] * RATE)
            parts = ev["detail"].split("|")
            bar_idx = int(parts[0]) % bk["bars"]
            if ev["bar0"]:
                bar_idx = (int(parts[0]) - 1) % bk["bars"]
            i0 = max(0, int(t0 * LANE_PEAK_HZ))
            i1 = min(int(t1 * LANE_PEAK_HZ), n_bins)
            n = i1 - i0
            if n <= 0:
                continue
            for part in parts[1:]:
                ln, key, gain_s = part.rsplit(":", 2)
                gain = float(gain_s)
                if ln not in timelines or gain <= 0.001:
                    continue
                fade = key.endswith("~f")
                if fade:
                    key = key[:-2]
                peaks = _stem_peaks(bk, key, stem_cache)
                if peaks is None:
                    continue
                a_sample = bar_idx * bar_n
                a_bin = a_sample // hop
                b_bin = min(a_bin + max(1, bar_n // hop), len(peaks))
                seg = _resample_peaks(peaks, a_bin, b_bin, n)
                ramp = np.linspace(1.0, 0.0, n, dtype=np.float32) if fade \
                    else np.ones(n, dtype=np.float32)
                timelines[ln][i0:i1] = seg * (ramp * gain)[:, None]

    riser_evs = sorted((e["t"], float(e["name"])) for e in events
                       if e["kind"] == "music_riser")
    if riser_evs:
        tl = [(0.0, 0.0)] + riser_evs
        for i, (ts, val) in enumerate(tl):
            te = tl[i + 1][0] if i + 1 < len(tl) else duration_s
            i0 = max(0, int(ts * LANE_PEAK_HZ))
            i1 = min(int(te * LANE_PEAK_HZ), n_bins)
            n = i1 - i0
            if n <= 0 or val <= 0.0005:
                continue
            rp = _stem_peaks(bank_at(ts + 1e-3), "riser", stem_cache)
            if rp is None:
                continue
            reps = int(np.ceil(n / len(rp)))
            looped = np.tile(rp, (reps, 1))[:n]
            timelines["riser"][i0:i1] = looped * (val * 0.85)

    for kind, lane, amp in (("music_sting", "sting", 0.8),
                            ("music_stab", "stab", 0.7)):
        for e in events:
            if e["kind"] != kind:
                continue
            sp = _stem_peaks(bank_at(e["t"]), lane, stem_cache)
            if sp is None:
                continue
            real_dur = len(sp) / STEM_PEAK_HZ
            i0 = max(0, int(e["t"] * LANE_PEAK_HZ))
            i1 = min(i0 + max(1, int(real_dur * LANE_PEAK_HZ)), n_bins)
            n = i1 - i0
            if n <= 0:
                continue
            timelines[lane][i0:i1] = _resample_peaks(sp, 0, len(sp), n) * amp

    return timelines


def _lane_wave_rgb(tl: np.ndarray, t0: float, t1: float, width: int,
                   height: int, color: tuple, bg: tuple) -> np.ndarray:
    """Vectorized DAW-style min/max waveform for one lane's time window --
    no per-pixel Python loop, so 12 lanes x thousands of frames stays
    cheap (director: "~8000 frames must complete in minutes, not
    hours")."""
    n_bins = len(tl)
    cols = (t0 + (np.arange(width) + 0.5) / width * (t1 - t0)) * LANE_PEAK_HZ
    idx = cols.astype(np.int64)
    valid = (idx >= 0) & (idx < n_bins)
    seg = tl[np.clip(idx, 0, n_bins - 1)].copy()
    seg[~valid] = 0.0
    half = height / 2.0
    top = np.clip(half - seg[:, 1] * half, 0, height - 1).astype(np.int32)
    bot = np.clip(half - seg[:, 0] * half, 0, height - 1).astype(np.int32)
    lo, hi = np.minimum(top, bot), np.maximum(top, bot)
    rows = np.arange(height)[:, None]
    mask = (rows >= lo[None, :]) & (rows <= hi[None, :])
    arr = np.empty((height, width, 3), dtype=np.uint8)
    arr[:, :, :] = bg
    arr[mask] = color
    return arr


def _ticker_events(events: list) -> list[tuple[float, str, tuple]]:
    """Non-lane event-log lines: interrupts, true jumps, seamless loop
    steers (dim, no red flash -- director 2026-07-17), boss-release
    comedowns, stings/stabs, and riser swells rising from / returning to
    zero. music_halt is deliberately NOT here -- it gets its own big
    banner in overlay_frames instead of competing for ticker space."""
    out = []
    for e in events:
        k = e["kind"]
        if k == "music_int":
            out.append((e["t"], "INT " + e["name"], (255, 120, 120)))
        elif k == "music_jump":
            nm = str(e["name"])
            if nm.endswith("~s"):
                out.append((e["t"], "LOOP " + nm[:-2], (120, 120, 130)))
            else:
                out.append((e["t"], "JUMP " + nm, (255, 150, 150)))
        elif k == "music_rel":
            out.append((e["t"], "REL boss-comedown", (255, 190, 120)))
        elif k in ("music_sting", "music_stab"):
            out.append((e["t"], k[6:].upper(), (255, 200, 120)))
    riser_evs = sorted((e["t"], float(e["name"])) for e in events
                       if e["kind"] == "music_riser")
    prev = 0.0
    for tt, val in riser_evs:
        if prev <= 0.0005 < val:
            out.append((tt, f"RISER {val:.2f}", (200, 150, 255)))
        elif val <= 0.0005 < prev:
            out.append((tt, "RISER END→STING", (200, 150, 255)))
        prev = val
    out.sort()
    return out


def _halt_intervals(events: list,
                    duration_s: float) -> list[tuple[float, float]]:
    """[start, resume) spans where music_halt (death) has cut the music
    dead -- the engine only restarts it on a later music_bar tap, if
    ever."""
    halt_ts = sorted(e["t"] for e in events if e["kind"] == "music_halt")
    bar_ts = sorted(e["t"] for e in events if e["kind"] == "music_bar")
    out = []
    for ht in halt_ts:
        resume = next((bt for bt in bar_ts if bt > ht), duration_s + 1.0)
        out.append((ht, resume))
    return out


def _in_intervals(intervals: list, t: float) -> bool:
    return any(a <= t < b for a, b in intervals)


def overlay_frames(rec: Path, events: list, fps: int, scale: int,
                   out_dir: Path) -> int:
    """DAW-style debug panel (director 2026-07-17 overhaul): frame
    counter, per-factor top-3 subfactor contributions, aggro census,
    crossfade/form transport, and a lane strip for EVERY sound the music
    system makes (the 9 music_bar chunk lanes plus riser/sting/stab)
    with real min/max waveforms scrolling under a playhead. NOW/NEXT are
    labelled with the specific stem+form-bar (e.g. "prayer[17]") so a
    silent lane reads as "the planner stopped it" vs "playback broke",
    and NEXT flashes brighter when the queued clip changes. Event ticker
    covers interrupts, true jumps (red flash, as before), seamless loop
    steers (dim, no flash), boss-release comedowns and riser swells;
    music_halt (death) blacks out every lane strip with a banner."""
    from PIL import Image, ImageDraw, ImageFont
    raw_s = _series(events, "music_valsraw")
    lp_s = _series(events, "music_valslp")
    riser_s = _series(events, "music_riser")
    bars = _bar_series(events)
    dbg_s = [(e["t"], e["name"]) for e in events if e["kind"] == "music_dbg"]
    int_s = [(e["t"], e["name"]) for e in events if e["kind"] == "music_int"]
    jump_true_s = [(e["t"], e["name"]) for e in events
                   if e["kind"] == "music_jump"
                   and not str(e["name"]).endswith("~s")]
    bank_s = [(e["t"], e["name"]) for e in events if e["kind"] == "music_bank"]
    sting_ts = sorted(e["t"] for e in events if e["kind"] == "music_sting")
    stab_ts = sorted(e["t"] for e in events if e["kind"] == "music_stab")

    frames = sorted(rec.glob("frame_*.png"))
    duration_s = len(frames) / fps
    timelines = _build_lane_timelines(events, duration_s)
    ticker = _ticker_events(events)
    halts = _halt_intervals(events, duration_s)

    W, H = 640 * scale, 360 * scale
    panel_w = 200 * scale
    px0 = W - panel_w
    font = ImageFont.truetype(str(FONT), 8 * scale)
    font_b = ImageFont.truetype(str(FONT_BOLD), 8 * scale)
    small = ImageFont.truetype(str(FONT), 7 * scale)
    tiny = ImageFont.truetype(str(FONT), 6 * scale)
    panel_h = H  # debug build: the full DAW column
    panel = Image.new("RGBA", (panel_w, panel_h), (8, 8, 14, 165))

    def at_txt(series, t, default=""):
        best = default
        for tt, v in series:
            if tt <= t:
                best = v
            else:
                break
        return best

    bw = panel_w - 10 * scale
    wf_h = 8 * scale
    ph_frac = 2.0 / 7.0    # playhead position in the now-2s..now+5s window
    last_next: dict[str, str | None] = {ln: None for ln in LANE_ORDER}
    last_change_t: dict[str, float] = {ln: -10.0 for ln in LANE_ORDER}

    for k, fp in enumerate(frames):
        t = k / fps
        im = Image.open(fp).convert("RGB").resize((W, H), Image.NEAREST)
        im.paste(Image.new("RGB", (panel_w, panel_h), (8, 8, 14)),
                 (px0, 0), panel)
        d = ImageDraw.Draw(im)
        x = px0 + 5 * scale
        y = 4 * scale
        # -- transport bar: frame counter / time / bank / form pos --
        dbg = at_txt(dbg_s, t)
        parts = dict(pp.split(":", 1) for pp in dbg.split("|")) \
            if dbg else {}
        bank = at_txt(bank_s, t, "?").replace("album_", "")
        d.text((x, y), f"F{k:06d}  {t:7.2f}s", font=font_b,
               fill=(240, 240, 200))
        y += 11 * scale
        d.text((x, y), f"{bank}  bar {parts.get('form', '?')}  "
                       f"xf {parts.get('xf', '-')}",
               font=small, fill=(170, 170, 190))
        y += 11 * scale
        # -- factors with top-3 subfactor readouts --
        raw = _at(raw_s, t, (0.0, 0.0, 0.0))
        lp = _at(lp_s, t, (0.0, 0.0, 0.0))
        subs = {"PRAYER": "", "CONTEMPT": parts.get("ct", ""),
                "STALWART": parts.get("st", "")}
        for i, name in enumerate(("PRAYER", "CONTEMPT", "STALWART")):
            col = FACTOR_COLORS[name]
            dim = tuple(c // 2 for c in col)
            d.text((x, y), name, font=font_b, fill=col)
            y += 8 * scale
            d.rectangle([x, y, x + bw, y + 2 * scale], fill=(30, 30, 40))
            d.rectangle([x, y, x + int(bw * min(1.0, raw[i])),
                         y + 2 * scale], fill=dim)
            y += 3 * scale
            d.rectangle([x, y, x + bw, y + 4 * scale], fill=(30, 30, 40))
            d.rectangle([x, y, x + int(bw * min(1.0, lp[i])),
                         y + 4 * scale], fill=col)
            y += 5 * scale
            if subs[name]:
                d.text((x + 2 * scale, y), subs[name][:44], font=tiny,
                       fill=(150, 150, 160))
                y += 7 * scale
            y += 1 * scale
        # -- aggro census --
        d.text((x, y), f"AGGRO {parts.get('agg', '-')}", font=small,
               fill=(220, 160, 120))
        y += 10 * scale
        d.text((x, y), "LANES", font=font_b, fill=(200, 200, 210))
        y += 9 * scale

        in_halt = _in_intervals(halts, t)
        if in_halt:
            d.text((x, y), "DEATH — MUSIC HALTED", font=font_b,
                   fill=(255, 60, 60))
            y += 10 * scale

        # -- lanes: real waveforms + NOW/NEXT, flash on interrupts --
        bidx, lanes_now = _at(bars, t, (0, {}))
        nxt_bidx, nxt_lanes = 0, {}
        for tt, (bi, ln_) in bars:
            if tt > t:
                nxt_bidx, nxt_lanes = bi, ln_
                break
        recent_int = {nm.split(":", 1)[0] for tt, nm in int_s
                      if 0 <= t - tt < 0.45}
        jump_flash = any(0 <= t - tt < 0.45 for tt, _ in jump_true_s)
        riser_now = _at(riser_s, t, (0.0,))[0]

        for ln in LANE_ORDER:
            row_top = y
            if in_halt:
                d.rectangle([x, y, x + bw, y + wf_h], fill=(16, 16, 20))
                y += wf_h + 1 * scale
                d.text((x, y), f"{ln[:4]:<4s} -", font=tiny,
                       fill=(70, 70, 76))
                y += 7 * scale + 1 * scale
                continue

            arr = _lane_wave_rgb(timelines[ln], t - 2.0, t + 5.0, bw, wf_h,
                                 LANE_COLORS[ln], (20, 20, 26))
            im.paste(Image.fromarray(arr), (x, y))
            ph_x = x + int(bw * ph_frac)
            d.line([(ph_x, y), (ph_x, y + wf_h)], fill=(255, 255, 255),
                  width=max(1, scale // 2))

            key, gain, fade = lanes_now.get(ln, (None, 0.0, False))
            live_chunk = ln in CHUNK_LANES and \
                key not in (None, "None", "silence") and gain > 0.001
            if ln in recent_int or (jump_flash and live_chunk):
                d.rectangle([x - 2 * scale, row_top - scale,
                            x + bw + 2 * scale,
                            row_top + wf_h + 7 * scale + 2 * scale],
                           outline=(255, 60, 60), width=scale)
            y += wf_h + 1 * scale

            if ln in CHUNK_LANES:
                if key in (None, "None"):
                    now_txt = "-"
                elif key == "silence" or gain <= 0.001:
                    now_txt = "silence"
                else:
                    now_txt = f"{key}[{bidx}]" + ("~F" if fade else "")
                nkey, ngain, _ = nxt_lanes.get(ln, (None, 0.0, False))
                if nkey in (None, "None"):
                    next_txt = "-"
                elif nkey == "silence":
                    next_txt = "silence"
                else:
                    next_txt = f"{nkey}[{nxt_bidx}]"
            elif ln == "riser":
                now_txt = f"{riser_now:.2f}" if riser_now > 0.001 else "-"
                next_txt = "-"
            else:  # sting / stab: one-shots, no schedule to look ahead at
                trig = _last_at_or_before(
                    sting_ts if ln == "sting" else stab_ts, t)
                now_txt = "hit" if trig is not None and t - trig < 0.3 \
                    else "-"
                next_txt = "-"

            if next_txt != "-" and last_next[ln] != next_txt:
                last_change_t[ln] = t
            if next_txt != "-":
                last_next[ln] = next_txt
            flash = (t - last_change_t[ln]) < 0.3

            d.text((x, y), ln[:4], font=tiny, fill=LANE_COLORS[ln])
            d.text((x + 20 * scale, y), f"now:{now_txt}"[:20], font=tiny,
                  fill=(230, 230, 240))
            nx_col = (245, 245, 250) if flash else (125, 125, 135)
            d.text((x + 95 * scale, y), f"nxt:{next_txt}"[:18], font=tiny,
                  fill=nx_col)
            y += 7 * scale + 1 * scale

        # -- event ticker (last ~3 events, 2.5s window) --
        evs = [(tt, txt, col) for tt, txt, col in ticker if 0 <= t - tt < 2.5]
        for tt, txt, col in sorted(evs)[-3:]:
            d.text((x, y), txt[:40], font=tiny, fill=col)
            y += 7 * scale

        im.save(out_dir / f"frame_{k:06d}.jpg", quality=90)
    return len(frames)


FONT = Path(__file__).resolve().parents[2] / \
    "game" / "perihelion" / "assets" / "fonts" / "IBMPlexSans-Regular.ttf"
FONT_BOLD = Path(__file__).resolve().parents[2] / \
    "game" / "perihelion" / "assets" / "fonts" / "IBMPlexSans-SemiBold.ttf"


def cut_segments(full: Path, segments: str, out: Path,
                 labels: list[str] | None = None) -> None:
    """Cut `a-b,c-d` (seconds) from the encoded mp4 and concatenate.
    Optional per-segment labels burn in for the first 3 s of each cut."""
    tmp = Path(tempfile.mkdtemp(prefix="mkvideo_seg_"))
    parts = []
    for i, span in enumerate(segments.split(",")):
        a, b = (float(x) for x in span.split("-"))
        part = tmp / f"part_{i}.mp4"
        cmd = ["ffmpeg", "-y", "-v", "error", "-ss", str(a),
               "-to", str(b), "-i", str(full)]
        if labels and i < len(labels) and labels[i]:
            text = labels[i].replace("'", r"\'").replace(":", r"\:")
            cmd += ["-vf",
                    f"drawtext=fontfile={FONT}:text='{text}':fontsize=32:"
                    f"fontcolor=white:borderw=3:bordercolor=black:"
                    f"x=(w-text_w)/2:y=28:enable='lt(t,3)'"]
        cmd += ["-c:v", "libx264", "-preset", "medium", "-crf", "20",
                "-c:a", "aac", "-b:a", "160k", str(part)]
        subprocess.run(cmd, check=True)
        parts.append(part)
    lst = tmp / "list.txt"
    lst.write_text("".join(f"file '{p}'\n" for p in parts))
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "concat",
                    "-safe", "0", "-i", str(lst), "-c", "copy", str(out)],
                   check=True)
    shutil.rmtree(tmp)


def main(argv=None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--rec", required=True, help="capture dir from --record")
    p.add_argument("--out", required=True)
    p.add_argument("--fps", type=int, default=30,
                   help="must be 60/record-every used at capture time")
    p.add_argument("--scale", type=int, default=2)
    p.add_argument("--overlay", action="store_true",
                   help="burn in the music-telemetry panel (factor "
                        "meters pre/post filter + lane visualizer)")
    p.add_argument("--segments", default=None,
                   help='"a-b,c-d" spans in seconds to cut and join')
    p.add_argument("--labels", default=None,
                   help="comma-separated per-segment labels (burned in 3s)")
    args = p.parse_args(argv)

    rec = Path(args.rec)
    frames = sorted(rec.glob("frame_*.png"))
    if not frames:
        print(f"[mkvideo] no frames in {rec}", file=sys.stderr)
        return 1
    duration = len(frames) / args.fps
    mix_wav = rec / "mix.wav"
    build_mix(rec / "events.jsonl", duration, mix_wav)

    frames_dir = None
    prescaled = False
    if args.overlay:
        events = [json.loads(l)
                  for l in (rec / "events.jsonl").read_text().splitlines()]
        frames_dir = rec / "overlay_frames"
        frames_dir.mkdir(exist_ok=True)
        n = overlay_frames(rec, events, args.fps, args.scale, frames_dir)
        prescaled = True
        print(f"[mkvideo] overlay burned into {n} frames")

    out = Path(args.out)
    if args.segments:
        full = rec / "full.mp4"
        encode(rec, args.fps, args.scale, mix_wav, full,
               frames_dir, prescaled)
        labels = args.labels.split(",") if args.labels else None
        cut_segments(full, args.segments, out, labels)
    else:
        encode(rec, args.fps, args.scale, mix_wav, out,
               frames_dir, prescaled)
    print(f"[mkvideo] wrote {out} ({duration:.0f}s source)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
