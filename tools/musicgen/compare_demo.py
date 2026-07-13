"""tools/musicgen/compare_demo.py

Phase C step 3 (judging half): Gemini side-by-side comparison of the
assembled demo piece against real album blocks -- "same musical family?"
Fail-first: verified against a deliberately wrong reference (see
__main__ usage in the Phase A/C report) before trusting any accept.
"""
from __future__ import annotations

import argparse
import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "playtest"))
import gemini_listen as gl  # noqa: E402
import judge_instruments as ji  # noqa: E402

PROMPT = """You are a veteran game-audio composer comparing two audio clips.

You will hear TWO clips concatenated into one file: clip A, then a \
half-second of silence, then clip B. You are NOT told in advance what \
either clip is -- describe ONLY what you actually hear in each, independently.

Clip A is a real excerpt from a metal/industrial album. Clip B is an \
unlabelled candidate that may or may not belong to the same musical family \
as A -- it could be a faithful (if simpler/cruder) sketch of the same style, \
a completely different genre, or not music at all. Do not assume; listen.

First describe factually what instrumentation, tempo, energy, and genre \
character you hear in EACH clip, independently, based only on the audio. \
Then judge: does clip B belong to the SAME MUSICAL FAMILY as clip A -- same \
genre, same aggressive industrial-metal energy, same rough tempo/pulse feel? \
A placeholder that's merely "some electronic sound" is not enough; it needs \
to genuinely read as a rough sketch of THIS music, not just any synth.

Return STRICT JSON only, no markdown fences:
{"heard_a": "1-2 sentences, only what you actually hear in A",
 "heard_b": "1-2 sentences, only what you actually hear in B",
 "same_family": true|false, "p_same_family": 0.x,
 "reasoning": "specific, citing audible features from your own heard_a/heard_b",
 "verdict": "same_family | adjacent_but_off | different_family"}"""


def compare(album_clip: Path, demo_clip: Path) -> dict:
    with tempfile.TemporaryDirectory() as td:
        combined = Path(td) / "combined.wav"
        ji._concat_with_gap(album_clip, demo_clip, combined,
                             album_anchor_max_s=8.0)
        return gl.ask(combined, PROMPT, max_s=40.0)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--album-clip", type=Path, required=True)
    ap.add_argument("--demo-clip", type=Path, required=True)
    args = ap.parse_args()
    if not gl.have_key():
        print("ERROR: no OpenRouter key.", file=sys.stderr)
        return 1
    result = compare(args.album_clip, args.demo_clip)
    print(json.dumps(result, indent=2))
    print(f"\ncumulative cost: ${gl.total_cost():.4f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
