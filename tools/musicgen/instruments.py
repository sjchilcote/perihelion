"""tools/musicgen/instruments.py

Phase C step 1: candidate instrument syntheses for the playbook's palette,
built with tools/soundgen/synth.py's numpy DSP toolkit (same house style as
the SFX bank -- pure numpy, offline rendering, no external audio deps).

Each function returns a mono float32 numpy array at synth.SR. This module
only *synthesizes*; judging against the album happens in judge_instruments.py.
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))
import synth as sy  # noqa: E402  (reused: oscillators/filters/envelopes/fx)


def kick(dur_s: float = 0.35) -> np.ndarray:
    """Industrial distorted kick: pitch-swept sine + click, driven into
    saturation. v1 (soft_clip drive=1.3 only) judged "clean/acoustic-style,
    devoid of distortion" (p_match=0.2) vs the album's "heavily distorted,
    saturated" kick -- push much harder into clip + bitcrush."""
    pitch = sy.pitch_env(dur_s, start_hz=140.0, end_hz=45.0, curve="exp")
    body = sy.sine(pitch, dur_s)
    body = sy.apply_env(body, sy.env_exp_decay(dur_s, tau=0.09))
    click = sy.white_noise(0.008)
    click = sy.bandpass(click, 3000, q=1.5)
    click = sy.apply_env(click, sy.env_exp_decay(0.008, tau=0.004))
    click = sy.pad_to(click, len(body))
    x = sy.mix_layers([body, click], gains=[1.0, 0.6])
    x = sy.soft_clip(x * 5.0, drive=1.0)
    x = sy.hard_clip(x * 1.4, ceiling=1.0)
    x = sy.bitcrush(x, bits=8)
    return sy.normalize_peak(x, -1.0)


def snare(dur_s: float = 0.3) -> np.ndarray:
    """Industrial metal snare: metallic ring (resonant bandpassed tone) +
    saturated noise body + short reverb tail. v1 (triangle tone + hp noise,
    light bitcrush) judged "sterile 808-style, no acoustic depth/grit/ring"
    (p_match=0.2) -- add a resonant metallic ring and darker room verb."""
    tone = sy.triangle(190.0, dur_s)
    ring = sy.bandpass(sy.white_noise(dur_s), 2400, q=6.0)
    tone = sy.apply_env(tone, sy.env_exp_decay(dur_s, tau=0.05))
    ring = sy.apply_env(ring, sy.env_exp_decay(dur_s, tau=0.09))
    noise = sy.white_noise(dur_s)
    noise = sy.highpass(noise, 900)
    noise = sy.apply_env(noise, sy.env_exp_decay(dur_s, tau=0.07))
    x = sy.mix_layers([tone, ring, noise], gains=[0.4, 0.35, 0.9])
    x = sy.soft_clip(x * 3.0, drive=1.0)
    x = sy.reverb(x, room_size=0.55, damping=0.4)
    x = sy.bitcrush(x, bits=10)
    return sy.normalize_peak(x, -1.5)


def hihat_closed(dur_s: float = 0.06) -> np.ndarray:
    n = sy.white_noise(dur_s)
    n = sy.highpass(n, 6000)
    n = sy.apply_env(n, sy.env_exp_decay(dur_s, tau=0.018))
    return sy.normalize_peak(n, -3.0)


def fm_bass(freq_hz: float, dur_s: float = 0.5) -> np.ndarray:
    """FM growl bass: sine carrier, feedback-ish square modulator at 1:2,
    driven hard into saturation -- album reference judged v1 (soft_clip
    drive=1.2) as "too clean/polite, lacks grit/bite" (p_match=0.2); this
    version pushes distortion much harder (hard_clip after high pre-gain +
    a second soft_clip stage) to reach the album's aggressive harmonic
    density."""
    mod = sy.square(freq_hz * 2.0, dur_s)
    carrier_freq = freq_hz + mod * freq_hz * 1.4
    x = sy.sine(carrier_freq, dur_s)
    x = sy.lowpass(x, 320, q=1.1)
    env = sy.env_adsr(dur_s, attack=0.005, decay=0.08, sustain_level=0.85,
                       release=0.05)
    x = sy.apply_env(x, env)
    x = sy.soft_clip(x * 6.0, drive=1.0)
    x = sy.hard_clip(x * 1.6, ceiling=1.0)
    x = sy.bitcrush(x, bits=9)
    return sy.normalize_peak(x, -1.0)


def rhythm_chug(freq_hz: float = 73.4, dur_s: float = 0.22) -> np.ndarray:
    """Palm-muted staccato "guitar" chug: detuned saw pair, low fundamental
    kept audible (not bandpassed away), heavy distortion. v1 (bandpass
    @1200Hz stripped the low fundamental, short 0.045s decay) was heard as
    a clean "acoustic woodblock/rimshot" (p_match=0.0) -- keep the low end,
    lengthen the body, and distort much harder for a sustained low chug."""
    x = sy.saw(freq_hz, dur_s) + 0.7 * sy.saw(freq_hz * 2.006, dur_s)
    x = sy.lowpass(x, 900, q=1.0)
    x = sy.soft_clip(x * 8.0, drive=1.0)
    x = sy.hard_clip(x * 1.5, ceiling=1.0)
    env = sy.env_adsr(dur_s, attack=0.003, decay=0.03, sustain_level=0.6,
                       release=0.1)
    x = sy.apply_env(x, env)
    return sy.normalize_peak(x, -1.0)


def lead_saw(freq_hz: float, dur_s: float = 0.4, vibrato_hz: float = 8.0,
             vibrato_depth: float = 0.015) -> np.ndarray:
    """Detuned dual-saw lead with LFO vibrato and a resonant lowpass sweep,
    matching the "screaming, slithering" lead described in the album blocks."""
    t = sy.time_array(dur_s)
    vibrato = 1.0 + vibrato_depth * np.sin(2 * np.pi * vibrato_hz * t)
    f = freq_hz * vibrato
    x = 0.6 * sy.saw(f, dur_s) + 0.6 * sy.saw(f * 1.012, dur_s)
    cutoff = np.linspace(freq_hz * 3, freq_hz * 8, len(x))
    x = sy.lowpass(x, cutoff, q=2.5)
    env = sy.env_adsr(dur_s, attack=0.02, decay=0.05, sustain_level=0.8,
                       release=0.08)
    x = sy.apply_env(x, env)
    # v1 (clean, no drive) judged "too clean/narrow/plastic" vs the album's
    # "aggressive, saturated, hard-sync tearing" lead (p_match=0.2). Drive it.
    x = sy.soft_clip(x * 4.0, drive=1.0)
    return sy.normalize_peak(x, -1.5)


def industrial_drone(dur_s: float = 4.0) -> np.ndarray:
    """Tonal analog-style drone: detuned low saw/sine pair (not noise) with
    a slow sweeping resonant lowpass and warm saturation, dark reverb tail.
    v1 (bandpassed brown noise) was heard as "harsh, bright, wind/jet-engine
    noise, no tonal/resonant core" (p_match=0.1) -- the album anchor has a
    clear musical pitch center, so give the candidate one."""
    t = sy.time_array(dur_s)
    root = 55.0  # A1
    x = 0.6 * sy.saw(root, dur_s) + 0.5 * sy.sine(root * 1.003, dur_s)
    x += 0.3 * sy.sine(root * 2.0, dur_s)
    cutoff = root * 4 + root * 3 * (0.5 + 0.5 * np.sin(2 * np.pi * 0.08 * t))
    x = sy.lowpass(x, cutoff, q=3.0)
    x = sy.soft_clip(x * 1.8, drive=1.0)
    x = sy.reverb(x, room_size=0.8, damping=0.25)
    x = sy.fade_in(x, 0.5)
    x = sy.fade_out(x, 0.5)
    return sy.normalize_peak(x, -2.0)


PALETTE = {
    "kick": kick,
    "snare": snare,
    "hihat_closed": hihat_closed,
    "fm_bass": lambda: fm_bass(65.4),      # C2
    "rhythm_chug": lambda: rhythm_chug(65.4),
    "lead_saw": lambda: lead_saw(523.25),  # C5
    "industrial_drone": industrial_drone,
}


def render_all(out_dir: Path) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest = {}
    for name, fn in PALETTE.items():
        x = fn()
        path = out_dir / f"{name}.wav"
        sy.write_wav(path, x)
        manifest[name] = str(path)
    return manifest


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    m = render_all(args.out_dir)
    for k, v in m.items():
        print(k, "->", v)
