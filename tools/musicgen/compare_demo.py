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

Clip A is a MONTAGE of short excerpts from several different tracks of ONE \
album -- a hybrid album that ranges from aggressive industrial metal \
(distorted guitars, pounding drums) to darker synth-driven electronic \
pieces. The album's family is defined by that whole range, not by any \
single excerpt. (Prompt calibration note, validated on controls: an \
earlier single-excerpt version of this judge rejected a REAL track from \
the same album at p=0.2 because it wasn't guitar-forward like the one \
anchor excerpt.)

Clip B is an unlabelled candidate. It might be another piece belonging on \
that same album / the same dark-machine game soundtrack (possibly a much \
simpler or rougher production -- judge family, not production budget); it \
might be music from an unrelated genre (upbeat pop, folk, cheerful \
chiptune); or it might not be music at all. Do not assume; listen.

First describe factually what you hear in EACH clip, independently. Then \
judge: could clip B plausibly be a track (or a rough placeholder sketch of \
a track) belonging to clip A's album family -- same dark, machine-driven \
character, compatible pulse and harmonic darkness? Penalize wrong \
CHARACTER (cheerful, pastoral, acoustic-folk, comedic, rhythmically \
incompatible), not low production polish.

Clip B must also actually BE music to qualify: a piece with musical \
structure -- multiple coordinated layers, rhythmic organization AND some \
tonal/harmonic content (riff, bassline, melody, or drone). A bare sound \
effect, a single repeated hit, or an unpitched percussion loop with no \
tonal layer is NOT a track and must be verdict "different_family" no \
matter how dark it sounds.

Return STRICT JSON only, no markdown fences:
{"heard_a": "1-2 sentences, only what you actually hear in A",
 "heard_b": "1-2 sentences, only what you actually hear in B",
 "same_family": true|false, "p_same_family": 0.x,
 "reasoning": "specific, citing audible features from your own heard_a/heard_b",
 "verdict": "same_family | adjacent_but_off | different_family"}"""


def compare(album_clip: Path, demo_clip: Path) -> dict:
    with tempfile.TemporaryDirectory() as td:
        combined = Path(td) / "combined.wav"
        # 12s: room for a 3-excerpt montage anchor (4s each); the 8s
        # attention limit found in judge_instruments applied to a single
        # dense block, and 12s of varied montage tested fine on controls
        ji._concat_with_gap(album_clip, demo_clip, combined,
                             album_anchor_max_s=12.0)
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
