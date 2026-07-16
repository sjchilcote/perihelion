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
# them") -------------------------------------------------------------

FACTOR_COLORS = {          # match the value battery's identities
    "PRAYER": (110, 190, 255),
    "CONTEMPT": (255, 110, 100),
    "STALWART": (255, 190, 90),
}
LANE_ORDER = ["bed", "drums", "holy", "groove", "wall", "bass",
              "lead", "lead2", "boss"]
LANE_COLORS = {
    "bed": (140, 140, 170), "drums": (230, 160, 90),
    "holy": (110, 190, 255), "groove": (255, 110, 100),
    "wall": (255, 190, 90), "bass": (170, 130, 220),
    "lead": (130, 220, 150), "lead2": (100, 190, 120),
    "boss": (255, 80, 160),
}


def _series(events: list, kind: str) -> list[tuple[float, tuple]]:
    out = []
    for e in events:
        if e["kind"] == kind:
            out.append((e["t"], tuple(float(x)
                                      for x in e["name"].split(","))))
    return out


def _bar_series(events: list) -> list[tuple[float, dict]]:
    out = []
    for e in events:
        if e["kind"] != "music_bar":
            continue
        lanes = {}
        for part in e["name"].split("|")[1:]:
            ln, key, gain = part.rsplit(":", 2)
            if key.endswith("~f"):
                key = key[:-2]
            lanes[ln] = (key, float(gain))
        out.append((e["t"], lanes))
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


def overlay_frames(rec: Path, events: list, fps: int, scale: int,
                   out_dir: Path) -> int:
    """DAW-style debug panel (director 2026-07-17): frame counter,
    per-factor top-3 subfactor contributions, aggro census, crossfade,
    form position, and per-lane NOW + NEXT strips that FLASH on
    planner-intentional interrupts -- so a silent lane can be read as
    'the planner stopped it' vs 'playback broke'."""
    from PIL import Image, ImageDraw, ImageFont
    raw_s = _series(events, "music_valsraw")
    lp_s = _series(events, "music_valslp")
    bars = _bar_series(events)
    dbg_s = [(e["t"], e["name"]) for e in events
             if e["kind"] == "music_dbg"]
    int_s = [(e["t"], e["name"]) for e in events
             if e["kind"] == "music_int"]
    jump_s = [(e["t"], e["name"]) for e in events
              if e["kind"] in ("music_jump", "music_rel")]
    bank_s = [(e["t"], e["name"]) for e in events
              if e["kind"] == "music_bank"]
    W, H = 640 * scale, 360 * scale
    panel_w = 152 * scale
    px0 = W - panel_w
    font = ImageFont.truetype(str(FONT), 8 * scale)
    small = ImageFont.truetype(str(FONT), 7 * scale)
    tiny = ImageFont.truetype(str(FONT), 6 * scale)
    frames = sorted(rec.glob("frame_*.png"))
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
        d.text((x, y), f"F{k:06d}  {t:7.2f}s", font=font,
               fill=(240, 240, 200))
        y += 11 * scale
        d.text((x, y), f"{bank}  bar {parts.get('form', '?')}  "
                       f"xf {parts.get('xf', '-')}",
               font=small, fill=(170, 170, 190))
        y += 11 * scale
        # -- factors with top-3 subfactor readouts --
        raw = _at(raw_s, t, (0.0, 0.0, 0.0))
        lp = _at(lp_s, t, (0.0, 0.0, 0.0))
        bw = panel_w - 10 * scale
        subs = {"PRAYER": "", "CONTEMPT": parts.get("ct", ""),
                "STALWART": parts.get("st", "")}
        for i, name in enumerate(("PRAYER", "CONTEMPT", "STALWART")):
            col = FACTOR_COLORS[name]
            dim = tuple(c // 2 for c in col)
            d.text((x, y), name, font=small, fill=col)
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
                d.text((x + 2 * scale, y), subs[name][:34], font=tiny,
                       fill=(150, 150, 160))
                y += 7 * scale
            y += 2 * scale
        # -- aggro census --
        d.text((x, y), f"AGGRO {parts.get('agg', '-')}", font=small,
               fill=(220, 160, 120))
        y += 11 * scale
        # -- lanes: NOW / NEXT, flash on interrupts --
        d.text((x, y), "LANES        now        next", font=small,
               fill=(200, 200, 210))
        y += 10 * scale
        lanes_now = _at(bars, t, {})
        nxt = {}
        for tt, ln in bars:
            if tt > t:
                nxt = ln
                break
        recent_int = {nm.split(":", 1)[0] for tt, nm in int_s
                      if 0 <= t - tt < 0.45}
        jump_flash = any(0 <= t - tt < 0.45 for tt, _ in jump_s)
        for ln in LANE_ORDER:
            key, gain = lanes_now.get(ln, (None, 0.0))
            nkey, ngain = nxt.get(ln, (None, 0.0))
            col = LANE_COLORS[ln]
            live = key not in (None, "None", "silence") and gain > 0.001
            fading = isinstance(key, str) and key.endswith("~f")
            kdisp = (key[:-2] + "*FADE" if fading else (key or "-")) \
                if live or fading else "-"
            ndisp = (nkey or "-") if nkey not in (None, "None",
                                                  "silence") else "-"
            row_y = y
            if ln in recent_int or (jump_flash and live):
                d.rectangle([x - 2 * scale, row_y - scale,
                             x + bw + 2 * scale, row_y + 14 * scale],
                            outline=(255, 60, 60), width=scale)
            d.text((x, y), ln[:5], font=tiny,
                   fill=col if live else (90, 90, 100))
            d.text((x + 26 * scale, y), str(kdisp)[:13], font=tiny,
                   fill=(230, 230, 240) if live else (100, 100, 110))
            d.text((x + 92 * scale, y), str(ndisp)[:11], font=tiny,
                   fill=(140, 140, 150))
            y += 7 * scale
            d.rectangle([x, y, x + bw, y + 3 * scale], fill=(28, 28, 38))
            if live:
                d.rectangle([x, y, x + int(bw * min(1.0, gain)),
                             y + 3 * scale], fill=col)
            if ndisp != "-":
                yy = y + 4 * scale
                d.rectangle([x, yy, x + int(bw * min(1.0, ngain)),
                             yy + scale], fill=tuple(c // 2 for c in col))
                y += 2 * scale
            y += 6 * scale
        # -- event ticker --
        evs = [(tt, "INT " + nm) for tt, nm in int_s if 0 <= t - tt < 2.5]
        evs += [(tt, "JMP/REL " + nm) for tt, nm in jump_s
                if 0 <= t - tt < 2.5]
        evs += [(tt, kind.upper()) for tt, kind in
                [(e["t"], e["kind"][6:]) for e in events
                 if e["kind"] in ("music_sting", "music_stab")]
                if 0 <= t - tt < 2.5]
        for tt, txt in sorted(evs)[-3:]:
            d.text((x, y), txt[:36], font=tiny, fill=(255, 120, 120))
            y += 7 * scale
        im.save(out_dir / f"frame_{k:06d}.jpg", quality=92)
    return len(frames)


FONT = Path(__file__).resolve().parents[2] / "game" / "assets" / "fonts" / "FSEX300.ttf"


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
