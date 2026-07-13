"""tools/musicgen/judge_instruments.py

Phase C step 1 (judging half): Gemini listens to a synthesized candidate
instrument next to a REAL excerpt of the album that prominently features
that instrument, and judges timbral match. Fail-first: the prompt must
permit (and the harness must be shown to produce) "no match" -- verified by
running a deliberately wrong pairing before trusting any accept.

Reuses gemini_listen.ask() (itself built on audio_judge's key/transcode/cost
machinery) with a comparative two-clip prompt in the same spirit as
audio_judge.ANCHORED_PROMPT_TEMPLATE, but anchored on the ALBUM rather than
our own shipped bank.
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
import audio_judge  # noqa: E402

PROMPT = """You are a veteran game-audio composer doing a calibrated \
timbre-match review.

You will hear TWO short clips concatenated into ONE audio file, in this \
order: first clip A, then a half-second of silence, then clip B.

Clip A is a REAL excerpt from the inspiration album ("With the Machine, \
Against the Machine") which is described as prominently featuring this \
instrument: {instrument_spec}

Clip B is a synthesized CANDIDATE instrument, built from scratch, intended \
to sit in that same sonic family for a placeholder soundtrack. If B is a \
short one-shot it has been repeated several times with gaps so you have \
enough audio to judge -- treat each repetition as the same single hit, not \
a rhythmic pattern.

Judge whether clip B's timbre could plausibly belong in the same sonic \
family as what you hear in clip A -- NOT whether the whole mix sounds \
identical (A is a full mix, B is a solo instrument). Be honest: if B is \
clearly the wrong timbre family (e.g. a bell where A has a growling bass, \
or a clean sine where A is heavily distorted), say so plainly and give a \
low score. A false "close enough" is worse than an honest rejection.

Return STRICT JSON only, no markdown fences:
{{"heard_a": "1-2 factual sentences describing A's relevant instrument texture",
  "heard_b": "1-2 factual sentences describing B",
  "timbre_family_match": true|false,
  "p_match": 0.x,
  "reasoning": "why you scored it this way, citing specific audible features",
  "verdict": "match | close_but_off | no_match"}}"""


ALBUM_ANCHOR_MAX_S = 8.0  # see judge_reliability note below


def _concat_with_gap(a: Path, b: Path, out: Path, gap_s: float = 0.5,
                      album_anchor_max_s: float = ALBUM_ANCHOR_MAX_S) -> None:
    """Concat A then B with a silent gap. B is repeated 4x (with small gaps,
    same heuristic as audio_judge._repeat_wav) if it's a short one-shot --
    otherwise a <0.6s candidate is perceptually negligible at the tail of a
    ~30s clip A and the judge ends up describing near-silence, which we
    observed produces a hallucinated (not actually-heard) verdict rather
    than an honest low-confidence one.

    judge_reliability note (found during fail-first verification): with a
    full 30s album block as clip A, the judge described a repeated hi-hat
    candidate as a "sub-bass" -- confirmed via spectral-centroid analysis
    that the hi-hat audio WAS present and loud in the file (~13.5kHz
    centroid), so this was the model losing attention to a long dense clip
    A rather than a broken concat. Trimming clip A to ALBUM_ANCHOR_MAX_S (8s)
    fixed it in a direct retest (same file, correct "no_match" verdict).
    Album clip A is therefore always trimmed to this length before judging."""
    import subprocess
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        silence = tmp / "silence.wav"
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "lavfi",
                         "-i", f"anullsrc=r=44100:cl=mono:d={gap_s}",
                         str(silence)], check=True)
        list_file = tmp / "list.txt"
        # normalize both inputs to mono 44100 wav first for concat safety
        a_norm, b_norm = tmp / "a.wav", tmp / "b.wav"
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(a),
                         "-t", str(album_anchor_max_s),
                         "-ac", "1", "-ar", "44100", str(a_norm)], check=True)
        b_dur = audio_judge._wav_duration_s(b)
        b_src = b
        if b_dur < audio_judge.REPEAT_UNDER_S:
            b_rep = tmp / "b_rep.wav"
            audio_judge._repeat_wav(b, b_rep)
            b_src = b_rep
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(b_src),
                         "-ac", "1", "-ar", "44100", str(b_norm)], check=True)
        list_file.write_text(
            f"file '{a_norm}'\nfile '{silence}'\nfile '{b_norm}'\n")
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "concat",
                         "-safe", "0", "-i", str(list_file), str(out)],
                        check=True)


def judge_instrument(album_clip: Path, candidate_wav: Path,
                      instrument_spec: str) -> dict:
    with tempfile.TemporaryDirectory() as td:
        combined = Path(td) / "combined.wav"
        _concat_with_gap(album_clip, candidate_wav, combined)
        prompt = PROMPT.format(instrument_spec=instrument_spec)
        return gl.ask(combined, prompt, max_s=40.0)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--album-clip", type=Path, required=True)
    ap.add_argument("--candidate", type=Path, required=True)
    ap.add_argument("--spec", type=str, required=True)
    ap.add_argument("--out", type=Path, default=None)
    args = ap.parse_args()

    if not gl.have_key():
        print("ERROR: no OpenRouter key available.", file=sys.stderr)
        return 1

    result = judge_instrument(args.album_clip, args.candidate, args.spec)
    print(json.dumps(result, indent=2))
    if args.out:
        args.out.write_text(json.dumps(result, indent=2))
    print(f"\ncumulative cost: ${gl.total_cost():.4f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
