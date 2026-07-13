"""Melody-prominence meter — is the intended melody AUDIBLE in the render?

The director's verdict on v3: "THERE ARE NO MELODIES IN YOUR 'MUSIC' -
JUST RANDOM NOISES." No step ever verified that placed notes come through
as a listener-perceptible line. First meter attempt (pyin salience) taught
two things: the v3 chant's pitches ARE present (0.586 tracked) at ~zero
salience (0.049) — his verdict in numbers — and pyin collapses entirely on
the album's dense wall (0.000 voiced). So the discriminating quantity is
COMB PROMINENCE: the harmonic comb's share of total spectral energy at the
intended pitch — "is the tune among the loudest things right now."
Mixture-safe, tracker-free.

Fixture protocol (his ear = ground truth): the album's lead material must
out-prominence the v3 chant by a wide margin, or the meter can't hear the
difference he hears and is disqualified.

    uv run python tools/musicgen/melody_check.py --fixtures
    uv run python tools/musicgen/melody_check.py --wav X.wav --t0 1.7
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import soundfile as sf

sys.path.insert(0, str(Path(__file__).resolve().parent))

SR = 44100
SCRATCH = Path("/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter"
               "/6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/musicgen")
D3 = 146.83


def comb_prominence(x: np.ndarray, f0: float, sr: int = SR) -> float:
    """Share of spectral energy in the harmonic comb of f0 (k=1..8,
    ±quarter-tone) vs total 80-4200 Hz."""
    n = len(x)
    if n < 1024:
        return 0.0
    F = np.abs(np.fft.rfft(x * np.hanning(n)))
    fr = np.fft.rfftfreq(n, 1 / sr)
    tot = F[(fr >= 80) & (fr <= 4200)].sum() + 1e-12
    comb = 0.0
    for k in range(1, 9):
        fk = f0 * k
        if fk > 4200:
            break
        band = (fr >= fk * 0.9715) & (fr <= fk * 1.0293)
        if band.any():
            comb += F[band].sum()
    return float(comb / tot)


def max_comb_prominence(x: np.ndarray, sr: int = SR,
                        lo: float = 90.0, hi: float = 900.0) -> float:
    """Prominence of the BEST f0 (quarter-tone grid search) — how strongly
    ANY single pitch dominates this frame. Calibrates the audible-melody
    bar on album lead material without knowing its notes."""
    best = 0.0
    f = lo
    while f <= hi:
        best = max(best, comb_prominence(x, f, sr))
        f *= 2 ** (0.5 / 12)
    return best


def score_melody(audio: np.ndarray, events, step_s: float, t0: float,
                 register_semi: float = 0.0, sr: int = SR) -> dict:
    """events: (semi_from_D3|None, dur_steps). t0: melody start (s).
    conformance: the slot's intended comb beats a quarter-tone-detuned
    control (the pitch is really THERE); prominence: the comb's share of
    total energy (it can be HEARD)."""
    hits, slots, proms = 0, 0, []
    cur = t0
    for sv, d in events:
        dur = d * step_s
        if sv is not None and dur >= 0.18:
            target = D3 * 2 ** ((register_semi + sv) / 12)
            a = int((cur + 0.05) * sr)
            b = int((cur + dur - 0.03) * sr)
            if b - a > 1024 and b <= len(audio):
                seg = audio[a:b]
                slots += 1
                p_true = comb_prominence(seg, target, sr)
                p_ctl = comb_prominence(seg, target * 2 ** (0.25 / 12), sr)
                proms.append(p_true)
                if p_true > p_ctl * 1.15:
                    hits += 1
        cur += dur
    return {"note_slots": slots,
            "slots_pitch_present": hits,
            "melody_conformance": round(hits / slots, 3) if slots else 0.0,
            "mean_prominence": round(float(np.mean(proms)), 4) if proms else 0.0}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fixtures", action="store_true")
    ap.add_argument("--wav", type=Path)
    ap.add_argument("--t0", type=float, default=0.0)
    ap.add_argument("--register", type=float, default=0.0)
    a = ap.parse_args()
    from melodies import DIES_IRAE_STROPHE
    STEP = 60.0 / 140.0 / 4

    if a.fixtures:
        print("fixture 1: hymn01 v3 introit chant (director: NO melody)")
        x, sr = sf.read(str(SCRATCH / "hymn01/hymn01.wav"))
        x = x.mean(axis=1) if x.ndim == 2 else x
        BAR = 60 / 140 * 4
        r1 = score_melody(x[:int(10 * BAR * SR)], DIES_IRAE_STROPHE, STEP,
                          t0=0.5 * BAR, register_semi=0.0)
        print(" ", json.dumps(r1))
        print("fixture 2: album peak block (audible soaring lead)")
        y, sr2 = sf.read(str(SCRATCH /
                         "blocks/04_not_a_heart__but_an_engine_blk07.wav"))
        y = y.mean(axis=1) if y.ndim == 2 else y
        if sr2 != SR:
            import librosa
            y = librosa.resample(y, orig_sr=sr2, target_sr=SR)
        frames = [max_comb_prominence(y[i:i + int(0.5 * SR)])
                  for i in range(0, int(15 * SR), int(0.5 * SR))]
        alb = float(np.mean(frames))
        print(f"  album best-comb prominence: {alb:.4f}")
        print(f"  v3 chant prominence:        {r1['mean_prominence']:.4f}")
        ok = alb > r1["mean_prominence"] * 1.8
        print("FIXTURES", "PASS (meter discriminates)" if ok else "FAIL")
        (Path(__file__).parent / "analysis/melody_fixtures.json").write_text(
            json.dumps({"v3_introit": r1, "album_prominence": alb,
                        "pass": ok}, indent=1))
        sys.exit(0 if ok else 1)

    if a.wav:
        x, sr = sf.read(str(a.wav))
        x = x.mean(axis=1) if x.ndim == 2 else x
        print(json.dumps(score_melody(x, DIES_IRAE_STROPHE, STEP, t0=a.t0,
                                      register_semi=a.register)))


if __name__ == "__main__":
    main()
