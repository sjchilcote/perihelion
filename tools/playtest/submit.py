#!/usr/bin/env python3
"""Build the evidence bundle a change is submitted with.

WHY THIS EXISTS. The gate used to film its own evidence, so the capture
command lived in the judge's prompt and drifted: it ended up pointed at
`marrow_demo.py`, a script whose own docstring admits it "seeds a handful
of scouts behind the bot's opening route" for one feature's demo. Every
gate run was therefore judging a doctored world, and nobody noticed
because the instruction was buried in a prompt nobody diffs.

Capture belongs to the agent making the change. It runs the SHIPPED
entry point — no seeding, no fixture, no special case — and hands the
judge a bundle to review. The judge then has one job, judging, and the
capture is a versioned tool that can be read and tested like code.

    uv run python tools/playtest/submit.py -o out/submission

Produces, per seed: the record dir (shutter-blended frames, audio taps,
frame->tick index), an mp4, and contact sheets at the moments that
matter — every time the player was hurt or died, which is where "not to
be killed without warning" is actually adjudicated. Plus a manifest
naming the build, the seeds, and what the run contained.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GAME = ROOT / "game"
SEEDS = (2, 4, 7, 11)
DEFAULT_LEVEL = ROOT / "levels" / "gauntlet4.json"
ZOOM = 0.45          # play, capture and farm share one zoom


def _run(cmd: list[str], cwd: Path) -> None:
    print("  $", " ".join(str(c) for c in cmd[-6:]), flush=True)
    r = subprocess.run(cmd, cwd=cwd)
    if r.returncode != 0:
        raise SystemExit(f"FAILED ({r.returncode}): {' '.join(map(str, cmd))}")


def build_id() -> str:
    try:
        rev = subprocess.run(["git", "rev-parse", "--short", "HEAD"],
                             cwd=ROOT, capture_output=True, text=True)
        dirty = subprocess.run(
            ["git", "status", "--porcelain", "--untracked-files=no"],
            cwd=ROOT, capture_output=True, text=True)
        return rev.stdout.strip() + ("-dirty" if dirty.stdout.strip() else "")
    except OSError:
        return "nogit"


def capture(level: Path, seed: int, ticks: int, out: Path) -> Path:
    """One filmed session, through the shipped entry point."""
    rec = out / f"run_s{seed}"
    _run([sys.executable, "-m", "perihelion",
          "--level", str(level), "--autoplay", "--bot", "aggro",
          "--mute", "--zoom", str(ZOOM), "--seed", str(seed),
          "--record", str(rec), "--record-every", "3",
          "--record-seconds", str(ticks / 60.0)], cwd=GAME)
    return rec


def frame_index(rec: Path) -> dict[int, int]:
    """tick -> saved frame index, from the recorder's own record."""
    idx: dict[int, int] = {}
    ev = rec / "events.jsonl"
    if not ev.exists():
        return idx
    for line in ev.open():
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if d.get("kind") == "frame" and d.get("tick", -1) >= 0:
            idx[int(d["tick"])] = int(d["frame"])
    return idx


def hurt_moments(trace: Path, limit: int = 6) -> list[tuple[int, str]]:
    """Ticks where the player was hurt or killed — the moments a
    reviewer has to be able to adjudicate."""
    out: list[tuple[int, str]] = []
    if not trace.exists():
        return out
    for line in trace.open():
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if d.get("kind") == "player_death":
            out.append((int(d["t"]), f"death:{d.get('source', '?')}"))
        elif d.get("kind") == "damage_applied" \
                and d.get("target_kind") == "player":
            out.append((int(d["t"]), f"hurt:{d.get('source', '?')}"))
    out.sort(key=lambda r: (0 if r[1].startswith("death") else 1, r[0]))
    return out[:limit]


def session_trace(seed: int) -> Path | None:
    """The newest session trace, identified by its own argv header."""
    best = None
    for p in sorted((GAME / "out" / "sessions").glob("*.jsonl"),
                    key=lambda q: q.stat().st_mtime, reverse=True):
        try:
            head = json.loads(p.open().readline())
        except (OSError, ValueError):
            continue
        argv = head.get("argv") or []
        if "--seed" in argv and argv[argv.index("--seed") + 1] == str(seed):
            best = p
            break
    return best


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("-o", "--out", type=Path,
                    default=ROOT / "out" / "submission")
    ap.add_argument("--level", type=Path, default=DEFAULT_LEVEL)
    ap.add_argument("--seeds", default=",".join(str(s) for s in SEEDS))
    ap.add_argument("--ticks", type=int, default=14400)
    ap.add_argument("--span", type=int, default=6,
                    help="frames per contact sheet / ghost blend")
    a = ap.parse_args()

    seeds = [int(s) for s in a.seeds.split(",") if s.strip()]
    a.out = a.out.resolve()
    a.out.mkdir(parents=True, exist_ok=True)
    manifest = dict(build=build_id(), level=str(a.level), ticks=a.ticks,
                    zoom=ZOOM, seeds={})

    for seed in seeds:
        print(f"[submit] seed {seed}: filming {a.ticks} ticks", flush=True)
        rec = capture(a.level, seed, a.ticks, a.out)
        n_png = len(list(rec.glob("frame_*.png")))

        mp4 = a.out / f"run_s{seed}.mp4"
        _run([sys.executable, str(ROOT / "tools/playtest/mkvideo.py"),
              "--rec", str(rec), "--out", str(mp4)], cwd=ROOT)

        trace = session_trace(seed)
        idx = frame_index(rec)
        sheets = []
        for tick, what in hurt_moments(trace) if trace else []:
            # nearest recorded frame at or after the event
            cand = [t for t in idx if t >= tick]
            if not cand:
                continue
            fr = idx[min(cand)]
            stem = a.out / f"s{seed}_{what.replace(':', '_')}_{tick}.png"
            _run([sys.executable, str(ROOT / "tools/playtest/ghost.py"),
                  str(rec), "--at", str(fr), "--span", str(a.span),
                  "-o", str(stem)], cwd=ROOT)
            sheets.append(dict(tick=tick, frame=fr, what=what,
                               sheet=stem.with_name(stem.stem + "_sheet.png").name))

        manifest["seeds"][seed] = dict(
            record=rec.name, frames=n_png, video=mp4.name,
            trace=trace.name if trace else None, moments=sheets)
        print(f"[submit] seed {seed}: {n_png} frames, {len(sheets)} moments",
              flush=True)

    (a.out / "manifest.json").write_text(json.dumps(manifest, indent=1))
    print(f"\n[submit] bundle at {a.out}")
    print(f"[submit] build {manifest['build']}, seeds {seeds}")
    print("[submit] the judge reviews THIS; it does not film its own.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
