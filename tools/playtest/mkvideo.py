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


def _mix_music(mix: np.ndarray, events: list, duration_s: float) -> None:
    """Rebuild the dynamic-music mix from the logged music taps —
    the offline twin of game/perihelion/music.py's live mixer. Stems loop
    continuously from the first music event; logged state changes move
    the stem gains stepwise (binary walls/vacuums, already bar-quantized
    at tap time); the riser follows its logged gain; stings land at their
    logged instants."""
    mevents = [e for e in events if e["kind"].startswith("music")]
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


def encode(rec: Path, fps: int, scale: int, mix_wav: Path, out: Path) -> None:
    vf = f"scale={640 * scale}:{360 * scale}:flags=neighbor"
    cmd = ["ffmpeg", "-y", "-v", "error",
           "-framerate", str(fps), "-i", str(rec / "frame_%06d.png"),
           "-i", str(mix_wav),
           "-c:v", "libx264", "-preset", "medium", "-crf", "20",
           "-pix_fmt", "yuv420p", "-vf", vf,
           "-c:a", "aac", "-b:a", "160k", "-shortest", str(out)]
    subprocess.run(cmd, check=True)


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

    out = Path(args.out)
    if args.segments:
        full = rec / "full.mp4"
        encode(rec, args.fps, args.scale, mix_wav, full)
        labels = args.labels.split(",") if args.labels else None
        cut_segments(full, args.segments, out, labels)
    else:
        encode(rec, args.fps, args.scale, mix_wav, out)
    print(f"[mkvideo] wrote {out} ({duration:.0f}s source)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
