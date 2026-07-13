#!/usr/bin/env python3
"""A/B "which one is the human?" judge for the marketing bot
(BOT_REALISM_DESIGN.md, Verification).

For each trial: record the SAME level/seed/segment twice through the real
`--record` path -- once with the omniscient `--bot aggro` baseline, once
with `--bot human` -- sample frames from each clip, shuffle which clip is
presented as A vs B (seeded), and ask Sonnet (via `claude -p`, reading the
frame files) which clip was played by the human. The human bot's win rate
is reported honestly, wins and losses both.

Judge validation (fail-first control): `--control` runs the same protocol
with BOTH clips from aggro bots (different seeds). A judge with real signal
should be ~50/50 there; a judge that reliably "detects the human" in an
all-bot lineup is reading noise, and the main result would be meaningless.
Run the control first.

Usage:
    uv run python tools/playtest/human_judge.py --seeds 101,102,103
    uv run python tools/playtest/human_judge.py --seeds 101,102,103 --control

Writes per-trial artifacts (frame lists, raw judge JSON) under --out and
prints a summary. Requires the `claude` CLI on PATH and ffmpeg-free (frames
are judged directly; no video assembly needed).
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from random import Random

REPO = Path(__file__).resolve().parents[2]
JUDGE_TIMEOUT_S = 300

PROMPT = """\
Two short clips from the same top-down shooter, same level, same starting
point. One was played by a HUMAN player, the other by a BOT. You will see
{n} frames from each clip, in chronological order (about 1 second apart).

Clip A frames, in order:
{a_frames}

Clip B frames, in order:
{b_frames}

Read ALL frames of both clips before deciding. Judge like a replay analyst:
- cursor/crosshair movement between consecutive frames (humans move the
  cursor smoothly with overshoot and drift; bots snap or park it)
- movement paths and pacing (hesitation at doorways, wobble, speed changes
  vs. ruler-straight beelines at constant speed)
- reactions to threats (delayed and messy vs. instant and exact)

Reply with ONLY a JSON object, no prose, no fences:
{{"human": "A" or "B", "confidence": 0.0-1.0, "reason": "<one sentence>"}}
"""


def record_clip(kind: str, seed: int, level: str, seconds: float,
                out_dir: Path, hard: bool) -> list[Path]:
    """Run the real game headless with `--bot kind --record`, return the
    saved frame paths. Raises on failure -- a missing clip must kill the
    trial loudly, not degrade into judging a stale directory."""
    out_dir.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, SDL_VIDEODRIVER="dummy", SDL_AUDIODRIVER="dummy")
    cmd = ["uv", "run", "python", "-m", "perihelion",
           "--level", level, "--bot", kind, "--seed", str(seed),
           "--autoplay", "--record", str(out_dir),
           "--record-every", "2", "--record-seconds", str(seconds)]
    if hard:
        cmd.append("--hard")
    subprocess.run(cmd, cwd=REPO, env=env, check=True,
                   capture_output=True, timeout=600)
    frames = sorted(out_dir.glob("frame_*.png"))
    if not frames:
        raise RuntimeError(f"no frames recorded in {out_dir}")
    return frames


def sample_frames(frames: list[Path], n: int) -> list[Path]:
    if len(frames) <= n:
        return frames
    step = (len(frames) - 1) / (n - 1)
    return [frames[round(i * step)] for i in range(n)]


def judge(a_frames: list[Path], b_frames: list[Path], model: str) -> dict:
    prompt = PROMPT.format(
        n=len(a_frames),
        a_frames="\n".join(str(p) for p in a_frames),
        b_frames="\n".join(str(p) for p in b_frames))
    result = subprocess.run(
        ["claude", "-p", prompt, "--model", model,
         "--output-format", "json", "--allowedTools", "Read"],
        capture_output=True, text=True, timeout=JUDGE_TIMEOUT_S)
    if result.returncode != 0:
        raise RuntimeError(f"judge call failed: {result.stderr[:500]}")
    payload = json.loads(result.stdout)
    text = payload["result"]
    # tolerate accidental fences, nothing else
    text = text.strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()
    verdict = json.loads(text)
    if verdict.get("human") not in ("A", "B"):
        raise RuntimeError(f"malformed verdict: {verdict!r}")
    return verdict


def main(argv=None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--seeds", required=True,
                   help="comma-separated trial seeds, e.g. 101,102,103")
    p.add_argument("--level", default="levels/l01.json")
    p.add_argument("--seconds", type=float, default=12.0)
    p.add_argument("--frames-per-clip", type=int, default=10)
    p.add_argument("--hard", action="store_true", default=True)
    p.add_argument("--model", default="sonnet")
    p.add_argument("--control", action="store_true",
                   help="judge validation: both clips are aggro bots")
    p.add_argument("--out", default=None)
    args = p.parse_args(argv)

    seeds = [int(s) for s in args.seeds.split(",")]
    label = "control" if args.control else "ab"
    out_root = Path(args.out) if args.out else \
        REPO / "tools" / "playtest" / "judge_out" / label
    out_root.mkdir(parents=True, exist_ok=True)

    results = []
    for seed in seeds:
        trial_dir = out_root / f"seed_{seed}"
        # LABEL HYGIENE: the judge Reads the frame files by path, so the
        # bot kind must never appear anywhere in the path. (Found the hard
        # way, 2026-07-13: with dirs named human/ and aggro/, a trial's
        # verdict reason cited "the source folder labels" -- the whole
        # measurement was leaking.) Clips are recorded directly into
        # neutral a/ and b/ dirs, assigned by the seeded shuffle.
        flip = Random(seed).random() < 0.5
        if args.control:
            # two aggro clips, different seeds: there is no human; a fair
            # judge should split ~50/50 across trials
            pair = [("aggro", seed), ("aggro", seed + 5000)]
            if flip:
                pair.reverse()
            truth_letter = None
        else:
            pair = [("human", seed), ("aggro", seed)]
            if flip:
                pair.reverse()
            truth_letter = "A" if pair[0][0] == "human" else "B"
        a = record_clip(pair[0][0], pair[0][1], args.level, args.seconds,
                        trial_dir / "a", args.hard)
        b = record_clip(pair[1][0], pair[1][1], args.level, args.seconds,
                        trial_dir / "b", args.hard)

        verdict = judge(sample_frames(a, args.frames_per_clip),
                        sample_frames(b, args.frames_per_clip), args.model)
        row = dict(seed=seed, flip=flip, truth=truth_letter, verdict=verdict,
                   correct=None if truth_letter is None
                   else verdict["human"] == truth_letter)
        results.append(row)
        (trial_dir / "verdict.json").write_text(json.dumps(row, indent=2))
        print(f"[trial seed={seed}] picked={verdict['human']} "
              f"truth={truth_letter} conf={verdict.get('confidence')} "
              f"reason={verdict.get('reason')}", flush=True)

    (out_root / "summary.json").write_text(json.dumps(results, indent=2))
    if args.control:
        picks = [r["verdict"]["human"] for r in results]
        print(f"\n[control] picks: {picks} "
              f"(A={picks.count('A')}, B={picks.count('B')}) -- "
              f"both clips were bots; near-even split with low confidence "
              f"is the healthy outcome")
    else:
        wins = sum(1 for r in results if r["correct"])
        print(f"\n[A/B] human bot identified as the human in "
              f"{wins}/{len(results)} trials")
    return 0


if __name__ == "__main__":
    sys.exit(main())
