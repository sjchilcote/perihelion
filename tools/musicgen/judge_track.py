"""Complete-track judge — the director's 2026-07-15 iteration loop.

    uv run python tools/musicgen/judge_track.py out/tutti_x.wav [n]

Pro-tier Gemini on the COMPLETE track (all voices), STEREO (the mono
solo-probe path is blind to double-tracking), asking his exact
question: "1-10, does this sound like a finished, professional piece
of music that evokes {brief}? What remaining gaps are there?"
Median score + the union of named gaps drive the next iteration.
"""
from __future__ import annotations

import json
import statistics
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "playtest"))

BRIEF = ("church music made by posthuman industrial machines that "
         "genuinely believe — an original sound with meaningful musical "
         "symbolism, for combat in a retro-futuristic cosmic-horror game")

PROMPT = (
    "Listen to the COMPLETE track. Answer as strict JSON with keys: "
    "score (integer 1-10: does this sound like a finished, professional "
    f"piece of music that evokes: {BRIEF}?), "
    "gaps (array of strings: the remaining concrete gaps between this "
    "and that finished professional piece — composition, arrangement, "
    "performance, production, mix; be specific and actionable), "
    "works (one sentence: what already works and must be kept)."
)

MODEL = "google/gemini-3.1-pro-preview"


def to_stereo_mp3(src: Path, out: Path, max_s: float = 110.0):
    import audio_judge
    audio_judge._ensure_ffmpeg()
    cmd = ["ffmpeg", "-y", "-v", "error", "-i", str(src), "-vn",
           "-t", str(max_s), "-ac", "2",
           "-codec:a", "libmp3lame", "-q:a", "2", str(out)]
    subprocess.run(cmd, check=True)


def judge(wav: str | Path, n: int = 3) -> dict:
    import audio_judge
    from gemini_listen import ask
    orig = audio_judge.to_mp3
    audio_judge.to_mp3 = lambda s, o, max_s=110.0: to_stereo_mp3(s, o, 110.0)
    try:
        passes = []
        for _ in range(n):
            r = ask(Path(wav), PROMPT, max_s=110.0, model=MODEL)
            if "error" not in r and "score" in r:
                passes.append(r)
    finally:
        audio_judge.to_mp3 = orig
    if not passes:
        return {"error": "all passes failed"}
    scores = [int(p["score"]) for p in passes]
    gaps = []
    for p in passes:
        for g in p.get("gaps", []):
            gaps.append(g)
    return dict(median=statistics.median(scores), scores=scores,
                gaps=gaps, works=[p.get("works", "") for p in passes])


if __name__ == "__main__":
    wav = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 3
    r = judge(wav, n)
    print(json.dumps(r, indent=1))
