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


def kick(dur_s: float = 0.4) -> np.ndarray:
    """Acoustic-hybrid industrial kick, per the playbook's converged album
    description ("deep subby acoustic kick + high-transient click ~3-4kHz").
    v2/v3 (sine sweep + click, heavy clip/bitcrush) judged "808-style,
    lacks acoustic texture and mid-range knock" (p_match 0.2-0.4). Class
    change, not re-tune: add the layer 808s lack -- a MID-RANGE KNOCK
    (damped shell-mode tone + short mid-band noise burst, what makes a kick
    read as a struck drumhead) -- and swap bitcrush for moderate saturation
    plus a touch of room."""
    n = sy.samples(dur_s)
    # sub body
    pitch = sy.pitch_env(dur_s, start_hz=120.0, end_hz=45.0, curve="exp")
    body = sy.sine(pitch, dur_s)
    body = sy.apply_env(body, sy.env_exp_decay(dur_s, tau=0.16))
    # mid knock: damped shell-mode tone + short bandpassed burst
    knock_noise = sy.bandpass(sy.white_noise(0.05, seed=3), 500, q=1.2)
    knock_noise = sy.apply_env(knock_noise, sy.env_exp_decay(0.05, tau=0.012))
    knock_tone = sy.sine(sy.pitch_env(0.06, 350.0, 180.0, curve="exp"), 0.06)
    knock_tone = sy.apply_env(knock_tone, sy.env_exp_decay(0.06, tau=0.02))
    knock = sy.pad_to(knock_noise, n) + sy.pad_to(knock_tone, n)
    # click transient
    click = sy.bandpass(sy.white_noise(0.006, seed=4), 3500, q=1.5)
    click = sy.apply_env(click, sy.env_exp_decay(0.006, tau=0.003))
    click = sy.pad_to(click, n)
    # v4-v6 lesson: tanh on a 45-120Hz sine only creates 150/250Hz-class
    # harmonics, which Gemini keeps hearing as "clean/fat 808", never as
    # "distorted" -- the album kick's grit is BROADBAND. v7 adds an
    # explicit grit layer: the body's own envelope shape applied to
    # overdriven mid-band noise, so the distortion is audible in the
    # 800Hz-4kHz range where ears (and codecs) actually look for it.
    body_env = sy.env_exp_decay(dur_s, tau=0.16)
    grit = sy.bandpass(sy.white_noise(dur_s, seed=9), 1800, q=0.5)
    grit = sy.soft_clip(grit * 8.0, drive=1.0)
    grit = sy.apply_env(grit, body_env)
    x = sy.mix_layers([sy.pad_to(body, n), knock, click,
                        sy.pad_to(grit, n)],
                       gains=[1.3, 0.5, 0.5, 0.55])
    x = sy.soft_clip(x * 6.0, drive=1.0)
    wet = sy.reverb(x, room_size=0.5, damping=0.45, tail_s=0.3)
    x = 0.6 * sy.pad_to(x, len(wet)) + 0.4 * wet
    x = sy.soft_clip(x * 3.5, drive=1.0)
    x = sy.lowpass(x, 5000, q=0.7)
    return sy.normalize_peak(x, -1.0)


def snare(dur_s: float = 0.35) -> np.ndarray:
    """Modal snare: tuned drumhead modes (inharmonic partial stack, per the
    playbook's "high-tension marching/metal snare") + snare-wire rattle
    (noise amplitude-modulated by the head vibration, which is what real
    wires do) + room. v3's tone+ring+noise recipe still judged "sterile
    drum-machine" (p_match=0.3) -- the class change is modal body +
    modulated-wire rattle instead of static filtered noise."""
    n = sy.samples(dur_s)
    # inharmonic head modes of a high-tension snare (ratios from membrane
    # physics, slightly sharpened), each with its own decay
    fundamental = 210.0
    modes = [(1.0, 1.0, 0.045), (1.59, 0.6, 0.035), (2.14, 0.45, 0.028),
             (2.65, 0.3, 0.022), (2.92, 0.25, 0.018)]
    body = np.zeros(n, dtype=np.float64)
    for ratio, amp, tau in modes:
        m = sy.sine(fundamental * ratio, dur_s)
        body += amp * sy.apply_env(m, sy.env_exp_decay(dur_s, tau=tau)).astype(np.float64)
    # wire rattle: bright noise, amplitude-modulated by the (rectified)
    # head fundamental so it "sizzles" with the head instead of hissing flat
    wires = sy.highpass(sy.white_noise(dur_s, seed=5), 2500)
    head_mod = np.abs(sy.sine(fundamental, dur_s).astype(np.float64))
    wires = wires.astype(np.float64) * (0.4 + 0.6 * head_mod)
    wires = sy.apply_env(wires.astype(np.float32),
                          sy.env_exp_decay(dur_s, tau=0.075))
    # attack crack
    crack = sy.bandpass(sy.white_noise(0.01, seed=6), 1800, q=1.0)
    crack = sy.apply_env(crack, sy.env_exp_decay(0.01, tau=0.004))
    x = sy.mix_layers([body.astype(np.float32), wires, sy.pad_to(crack, n)],
                       gains=[0.7, 0.9, 0.8])
    x = sy.soft_clip(x * 2.2, drive=1.0)
    wet = sy.reverb(x, room_size=0.45, damping=0.45, tail_s=0.25)
    x = 0.75 * sy.pad_to(x, len(wet)) + 0.25 * wet
    return sy.normalize_peak(x, -1.5)


def hihat_closed(dur_s: float = 0.09) -> np.ndarray:
    """Metallic hat via square-cluster ring-mod (the classic 808-cymbal
    trick: six detuned square waves at inharmonic ratios multiplied
    pairwise produce clangorous metal partials) instead of plain filtered
    white noise, which v1-v3 judges consistently called "synthetic noise
    burst, no metallic resonance" (p_match=0.3)."""
    ratios = [1.0, 1.34, 1.68, 2.02, 2.47, 2.98]
    base = 400.0
    cluster = np.zeros(sy.samples(dur_s), dtype=np.float64)
    for r in ratios:
        cluster += sy.square(base * r, dur_s).astype(np.float64)
    # ring-mod against a higher cluster member for extra inharmonicity
    ring = cluster * sy.square(base * 5.17, dur_s).astype(np.float64)
    x = (cluster + 0.7 * ring).astype(np.float32)
    # v4's double highpass at 6500 stripped the clangy 3-6kHz partials that
    # make a cymbal read as metal (judge: "no metallic ring") -- keep them:
    # single highpass at 4200 + a presence bandpass blended back in.
    x = sy.highpass(x, 4200)
    pres = sy.bandpass(x, 8500, q=0.7)
    x = (x.astype(np.float64) + 0.6 * pres.astype(np.float64)).astype(np.float32)
    x = sy.apply_env(x, sy.env_exp_decay(dur_s, tau=0.03))
    return sy.normalize_peak(x, -3.0)


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


def _karplus_strong(freq_hz: float, dur_s: float, damping: float = 0.996,
                     brightness: float = 0.5, sr: int = sy.SR,
                     seed: int = 11) -> np.ndarray:
    """Karplus-Strong plucked/struck string. `damping` is the per-sample
    loop feedback (palm-mute = lower); `brightness` blends the loop's
    two-tap averaging lowpass (1.0 = no filtering = bright, 0.0 = heavy)."""
    n = sy.samples(dur_s, sr)
    period = max(2, int(round(sr / freq_hz)))
    rng = np.random.default_rng(seed)
    buf = rng.uniform(-1.0, 1.0, period)
    # band-limit the excitation (moving-average smoothing): a raw white
    # buffer keeps the first ~10 periods hissy, which distortion then
    # amplifies into "white-noise burst" territory (the v4 failure mode).
    # A dark pluck reads as palm-muted string immediately.
    k = max(1, int(sr / 2000))  # ~2kHz excitation bandwidth
    kernel = np.ones(k) / k
    buf = np.convolve(np.tile(buf, 3), kernel, mode="same")[period:2 * period]
    buf /= max(np.max(np.abs(buf)), 1e-9)
    out = np.empty(n, dtype=np.float64)
    idx = 0
    for i in range(n):
        cur = buf[idx]
        nxt = buf[(idx + 1) % period]
        out[i] = cur
        buf[idx] = damping * ((1.0 - 0.5 * (1.0 - brightness)) * cur
                                + 0.5 * (1.0 - brightness) * nxt)
        idx = (idx + 1) % period
    return out.astype(np.float32)


def rhythm_chug(freq_hz: float = 73.4, dur_s: float = 0.25) -> np.ndarray:
    """Palm-muted guitar chug: Karplus-Strong strings (2 detuned courses,
    low damping = palm mute) driven into high-gain amp-style distortion
    with the playbook's converged EQ (mid scoop ~500Hz, presence bite
    2-4kHz, tight highpass ~70Hz). Class change from v1-v3's filtered saw
    (judged "acoustic woodblock, no string character", p_match 0.0-0.1) --
    KS actually behaves like a struck string: inharmonic attack noise that
    settles onto the string period, decaying upper partials."""
    # brightness=0.0 -> full 0.5/0.5 two-tap averaging so the noise
    # excitation settles onto the string tone within a few periods (v4's
    # brightness=0.55 left it hissing for the whole note: judge heard
    # "white-noise burst", no string). Palm-mute is dark anyway.
    s1 = _karplus_strong(freq_hz, dur_s, damping=0.998, brightness=0.0, seed=11)
    s2 = _karplus_strong(freq_hz * 1.008, dur_s, damping=0.998,
                          brightness=0.0, seed=23)
    x = (0.7 * s1 + 0.7 * s2).astype(np.float32)
    # string-noise floor: continuous dark noise modulated by the string
    # envelope (real high-gain rigs amplify fret/pick noise into the
    # distortion; its absence is a synth tell the judge keeps flagging)
    sn = sy.bandpass(sy.white_noise(dur_s, seed=37), 1200, q=0.6)
    string_env = np.abs(x.astype(np.float64))
    k_env = max(1, int(sy.SR * 0.004))
    string_env = np.convolve(string_env, np.ones(k_env) / k_env, mode="same")
    x = (x.astype(np.float64)
         + 0.35 * sn.astype(np.float64) * string_env).astype(np.float32)
    # pick-attack transient: a few ms of bright noise at the very front
    # (v5's fully-darkened excitation lost the "string-pluck transient"
    # the judge flagged as missing)
    pick = sy.bandpass(sy.white_noise(0.006, seed=31), 3200, q=0.8)
    pick = sy.apply_env(pick, sy.env_exp_decay(0.006, tau=0.0025))
    x = (x.astype(np.float64)
         + 0.5 * sy.pad_to(pick, len(x)).astype(np.float64)).astype(np.float32)
    # high-gain amp: pre-emphasis, drive
    x = sy.highpass(x, 70)
    x = sy.soft_clip(x * 9.0, drive=1.0)
    # mid scoop at ~500 Hz: subtract a bandpassed copy
    mid = sy.bandpass(x, 500, q=0.9)
    x = (x.astype(np.float64) - 0.5 * mid.astype(np.float64)).astype(np.float32)
    # cab sim: short comb resonances (4x12-ish box modes) + rolloff --
    # replaces v5's presence bandpass, which the judge heard as a
    # "laser-like resonant filter sweep" (synth tell, not guitar)
    x = sy.comb_filter(x, 0.0021, feedback=0.28)
    x = sy.comb_filter(x, 0.0037, feedback=0.22)
    x = sy.lowpass(x, 5200, q=0.7)
    env = sy.env_adsr(dur_s, attack=0.002, decay=0.04, sustain_level=0.55,
                       release=0.09)
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
