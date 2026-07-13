"""Export the dynamic-music state stems from hymn01's voices.

Three EMOTIONAL states (DIRECTOR_FEEDBACK.md, the emotional spec — these
are the Commando's states, not threat meters):

  prayer.wav   — contemplation over a pulse that never stops (urgency
                 inside stillness): hum bed, plain chant, bell, quiet tick.
  contempt.wav — weak enemies aren't worth pausing the liturgy: confident
                 dismissive groove, chant UNINTERRUPTED above it.
  stalwart.wav — the prayer for vengeance: full congregation, harmonic
                 floor holds, cantus firmus through the peak.
  riser.wav    — the endless (Shepard) riser: tension that releases on
                 gameplay's schedule (dormant flicker nearby, lockdown).
  sting.wav    — one-bar release impact (ring-mod sub + riff downbeat).

All loops are EXACTLY 8 bars = 604800 samples at 140 BPM/44100 Hz (the
math lands on an integer — no drift by construction); sting is 1 bar.
Written to game/perihelion/assets/music/hymn01/ as the game's first
(placeholder-grade, pending the director's ear and the commissioned
artist) music bank.

    uv run python tools/musicgen/export_stems.py
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
import soundfile as sf

sys.path.insert(0, str(Path(__file__).resolve().parent))
import hymn01 as H                                   # noqa: E402
from hymn01 import (BAR, SR, STEP, RNG, DIES_IRAE_STROPHE,  # noqa: E402
                    chant_line, organum_lines, render_riff, power_chords,
                    kick_track, machine_hats, bell_hit, shepard_riser,
                    chug_amp, place, KICK_HYMN, KICK_PEAK, envelope,
                    lead_phrase, LEAD_ANTECEDENT, LEAD_CONSEQUENT, D2, gc, sy)

OUT = Path(__file__).resolve().parents[2] / "game/perihelion/assets/music/hymn01"
LOOP_BARS = 8
N = int(round(LOOP_BARS * BAR * SR))
assert N == 604800, N          # exact-integer loop length at 140 BPM


def _fit(x: np.ndarray) -> np.ndarray:
    if len(x) < N:
        x = np.pad(x, (0, N - len(x)))
    x = x[:N].copy()
    # seam: 12 ms equal-power crossfade folded from the tail
    f = int(0.012 * SR)
    ramp = np.linspace(0, 1, f)
    x[:f] = x[:f] * ramp
    return x


def _norm(x: np.ndarray, peak_db: float = -3.0) -> np.ndarray:
    return sy.normalize_peak(x, peak_db)


def prayer() -> np.ndarray:
    out = np.zeros(N)
    bed_src = H.machine_note(0, LOOP_BARS * BAR + 1, breath=1.5, vel=0.4)
    bed = gc.feedback_loop(bed_src * 0.5, delay_s=1.0 / D2,
                           feedback_gain=1.05, drive=1.0, input_gain=1.2,
                           howl_hz=H.D3, howl_q=3.0)
    out += _fit(bed) * 0.14
    # chant line 1 (+ its breath) spans the loop's front; cadence rests
    line1 = DIES_IRAE_STROPHE[:9]
    out += _fit(chant_line(line1, 0)) * 0.85
    out += _fit(np.concatenate([np.zeros(int(6.4 * BAR * SR)),
                                bell_hit(0, 0.5)])[:N])
    # the pulse that never stops: soft tick on quarters (mission clock)
    tick = np.zeros(N)
    for b in range(LOOP_BARS * 4):
        h = H._KICK if H._KICK is not None else H._load("kick_metal_trim.wav")
        H._KICK = h
        place(tick, sy.lowpass(h * 0.16, 300), b * BAR / 4 * (4 / 4) * 1.0)
    for b in range(LOOP_BARS * 4):
        pass
    out += tick
    return _norm(out, -6.0)


def contempt() -> np.ndarray:
    out = np.zeros(N)
    # dismissive groove: kick pattern, hats, PARTED riff (accents only,
    # half density — a swagger, not a strain)
    out += _fit(kick_track(LOOP_BARS, KICK_HYMN)) * 0.7
    out += _fit(machine_hats(LOOP_BARS, 0.5)) * 0.8
    accents = [h for h in H.RIFF_BAR if h[3] >= 0.85]
    accents_b = [h for h in H.RIFF_BAR_B if h[3] >= 0.85]
    riff = render_riff(LOOP_BARS, palette=(accents, accents_b))
    out += _fit(chug_amp(riff)) * 0.55
    # the liturgy does not pause for trash: chant continues, clear
    cf = [(s, d * 2) for s, d in DIES_IRAE_STROPHE][:14]
    out += _fit(chant_line(cf, 12, breath=0.25)) * 0.8
    return _norm(out, -4.0)


def stalwart() -> np.ndarray:
    out = np.zeros(N)
    riff = render_riff(LOOP_BARS, vel_scale=1.05)
    out += _fit(chug_amp(riff)) * 0.8
    wall = chug_amp(power_chords(LOOP_BARS, 1.0))
    out += _fit(sy.highpass(wall, 120)) * 0.5
    out += _fit(kick_track(LOOP_BARS, KICK_PEAK)) * 0.68
    out += _fit(machine_hats(LOOP_BARS, 0.68)) * 0.9
    cf = [(s, d * 2) for s, d in DIES_IRAE_STROPHE]
    out += _fit(organum_lines(cf, 12)) * 0.8
    out += _fit(lead_phrase(LEAD_ANTECEDENT + LEAD_CONSEQUENT, 24, vel=0.7)
                ) * 0.6
    return _norm(out, -3.0)


def riser() -> np.ndarray:
    # cycle = 2 bars -> exactly 4 cycles per loop: seamless by construction
    r = shepard_riser(LOOP_BARS * BAR + 0.1, cycle_s=2 * BAR)
    return _norm(_fit(r), -8.0)


def sting() -> np.ndarray:
    n1 = int(round(BAR * SR))
    out = np.zeros(n1)
    sub_t = np.arange(n1) / SR
    subcar = np.sin(2 * np.pi * D2 / 2 * sub_t)
    subnz = gc.ring_mod_noise(subcar, D2 / 2)
    out += gc._tube((subcar * 0.8 + subnz * 0.3), drive=2.2) \
        * envelope(n1, 0.004, BAR * 0.7)
    hit = H.chug_hit(0, BAR * 0.9, mute=0.0, vel=1.0)
    out[:len(hit)] += chug_amp(hit)[:n1] * 0.9
    out += bell_hit(0, 0.6)[:n1] * 0.5 if len(bell_hit(0, 0.6)) >= n1 else \
        np.pad(bell_hit(0, 0.6) * 0.5, (0, n1 - len(bell_hit(0, 0.6))))
    return _norm(out, -2.5)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, fn in [("prayer", prayer), ("contempt", contempt),
                     ("stalwart", stalwart), ("riser", riser),
                     ("sting", sting)]:
        x = fn()
        sf.write(str(OUT / f"{name}.wav"), x.astype(np.float32), SR)
        print(f"{name:9s} {len(x)} samples  {len(x)/SR:.3f}s")
    print(f"-> {OUT}")


if __name__ == "__main__":
    main()
