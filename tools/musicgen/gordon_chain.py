"""tools/musicgen/gordon_chain.py

Round 2, director's order #1 applied: process real sampled sources
(real_sources.py) through parallel Gordon-method signal chains
(GORDON_METHOD.md secs 2, 3, 4, 7) instead of one linear distortion call.
Sine-through-a-single-clip() was round 1's failure mode (called out in
GORDON_METHOD.md sec 1 as the cliche a real chain must replace).

Each function here is a literal instrument-chain: several parallel
processing paths off the same real source, recombined with side-chain-style
ducking, a genuine self-reprocessing feedback loop, and a tempo-tuned
makeup-gain punch stage -- matching Gordon's description of his DOOM
sine-wave array, except our source is a real recorded sample instead of a
bare sine (see SOURCES_LICENSES.md).

## No analog gear / no VSTs -- confirmed, not assumed

Gordon's chain was built from real hardware pedals, a tape echo, a
reel-to-reel, a mic'd practice amp. We're headless Linux + Python with no
audio interface. VST hosting was tried and ruled out (dawdreamer has no
wheel for this box's Python; pacman-installing Surge XT/sfizz needs a
sudo password we don't have) -- see SOURCES_LICENSES.md for the concrete
commands that failed. The digital-equivalent mapping used instead, stage
by stage:

| His hardware | What it does physically | Our numpy equivalent |
|---|---|---|
| Bitcrusher ("Geiger counter" pedal) | sample-rate/bit-depth reduction | `synth.bitcrush()` |
| Tube/fuzz distortion pedals | asymmetric/soft nonlinear clipping | `synth.soft_clip()` (tanh waveshaper) |
| Phaser pedals (Mutron Bi-Phase, DOD) | swept allpass notch, filter *moves* over time | `synth.allpass_filter()` -- currently static, a real phaser needs the delay swept over time, noted as a follow-up gap, not silently claimed as equivalent |
| Tape echo (Watkins Copicat) | delay with a saturating repeat (tape itself distorts each pass) | `synth.delay_fx()` -- also currently missing the saturation-in-the-repeat-path Gordon's real tape had; a closer model would run `soft_clip` inside the feedback tap, noted as a follow-up gap |
| Reel-to-reel driven 40dB hot | real analog tape saturation | `soft_clip` on a pre-emphasized (highpass-boosted) signal -- an approximation, not a physical tape model |
| Spring reverb | a physical spring's resonant modes | `synth.reverb()` -- generic Schroeder comb/allpass reverb, not spring-specific; another honest gap, not a claimed match |
| **Mini-amp feedback loop** (mic signal routed back into the amp) | **true recursive self-reprocessing with a nonlinearity inside the loop** | `feedback_loop()` below -- this one IS built as a literal equivalent (see its docstring), because it's the mechanism Gordon calls out as generating the array's actual character, not an incidental effect |
| Final hard compressor + makeup gain | reveal the chain's own quiet artifacts once the loud input decays | `tempo_punch()` below -- rewritten to include an explicit makeup-gain stage after the corrected reading of the transcript (see GORDON_METHOD.md) |

The phaser/tape-echo/spring-reverb rows are flagged honestly as
approximations rather than claimed equivalents -- they're linear,
static-parameter filters standing in for time-varying or nonlinear analog
behavior. The feedback loop and the compressor+makeup-gain stage are the
two mechanisms actually verified against the transcript as load-bearing
for the array's character, so those got the real (non-approximated)
implementation.
"""
from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))
import synth as sy  # noqa: E402


def envelope_follower(x: np.ndarray, attack_s: float = 0.003,
                       release_s: float = 0.08, sr: int = sy.SR) -> np.ndarray:
    """Peak envelope follower: fast attack, slower release -- the shape a
    hardware compressor's detector uses. Used both for our own punch stage
    and for sidechain ducking one layer off another's amplitude
    (GORDON_METHOD.md sec 3: "based on whatever the input was doing, it
    could dynamically change the mix")."""
    a_coef = np.exp(-1.0 / max(1, attack_s * sr))
    r_coef = np.exp(-1.0 / max(1, release_s * sr))
    env = np.zeros_like(x, dtype=np.float64)
    level = 0.0
    ax = np.abs(x)
    for i in range(len(x)):
        target = ax[i]
        coef = a_coef if target > level else r_coef
        level = coef * level + (1 - coef) * target
        env[i] = level
    return env


def sidechain_duck(carrier: np.ndarray, trigger: np.ndarray,
                    amount: float = 0.6, attack_s: float = 0.003,
                    release_s: float = 0.12) -> np.ndarray:
    """Duck `carrier`'s gain inversely to `trigger`'s envelope -- e.g. let
    a grit/noise layer swell only when the tonal body has decayed away
    (GORDON_METHOD.md sec 3's amp-feedback-loop description: "the feedback
    was small enough that any signal coming through the amp would choke it
    out, and when the signal died the feedback swelled back in")."""
    n = min(len(carrier), len(trigger))
    env = envelope_follower(trigger[:n], attack_s, release_s)
    if env.max() > 1e-9:
        env = env / env.max()
    duck_gain = 1.0 - amount * env
    out = carrier.copy()
    out[:n] = out[:n] * duck_gain
    return out


def sidechain_pump(carrier: np.ndarray, trigger: np.ndarray,
                    amount: float = 0.7, attack_s: float = 0.002,
                    release_s: float = 0.15) -> np.ndarray:
    """Classic sidechain pump: duck `carrier` on `trigger` transients (kick
    ducking the bed) so the transient reads as punchy against a suddenly
    quieter background (GORDON_METHOD.md sec 7: fast attack lets the
    transient through, then the ducked material swells back)."""
    return sidechain_duck(carrier, trigger, amount, attack_s, release_s)


def feedback_loop(x: np.ndarray, delay_s: float, feedback_gain: float = 0.75,
                   drive: float = 2.2, sr: int = sy.SR) -> np.ndarray:
    """A genuine self-reprocessing feedback loop, modeling chain 4 of
    Gordon's DOOM array literally: a small amp fed ~40dB hot, mic'd, with
    a small amount of the mic signal routed back into the amp's own input
    -- "if a sound was actually coming through the amp it would choke out
    the feedback, and when that sound started to disappear the feedback
    would come back up in the mix."

    `comb_filter()` (synth.py) is NOT this -- it's a *linear* feedback
    filter (delayed copies decaying geometrically, same waveform each
    repeat), which only ever produces a metallic ringing, never new
    texture. The amp loop is nonlinear: distortion sits INSIDE the
    feedback path, so each pass around the loop doesn't just repeat the
    signal quieter, it reshapes it -- harmonics generated on pass 1 get
    fed back and redistorted on pass 2, and so on, so the loop accumulates
    genuinely emergent, chaotic character that isn't derivable from a
    single filtering pass over the dry source. That's the "biggest point"
    a purely feed-forward parallel-paths chain (the previous version of
    this module) cannot produce no matter how many static filters are
    stacked -- it has to be an actual recursive process:

        y[n] = drive_nonlinearity(x[n] + feedback_gain * y[n - delay_samples])

    This is the direct on-machine equivalent of "route a little of the
    mic signal back into the amp": a literal digital feedback loop with a
    nonlinearity inside it, computed sample-by-sample (numpy can't
    vectorize this -- it's a true IIR recursion through a nonlinearity,
    not a linear filter with a closed-form transfer function)."""
    x = np.asarray(x, dtype=np.float64)
    n = len(x)
    nd = max(1, sy.samples(delay_s, sr))
    y = np.empty(n, dtype=np.float64)
    buf = np.zeros(nd, dtype=np.float64)
    idx = 0
    for i in range(n):
        fb = buf[idx]
        combined = x[i] + feedback_gain * fb
        out = np.tanh(combined * drive)
        buf[idx] = out
        y[i] = out
        idx += 1
        if idx >= nd:
            idx = 0
    return y.astype(np.float32)


def ring_mod_noise(carrier: np.ndarray, mod_freq: float, sr: int = sy.SR,
                    seed: int = 0) -> np.ndarray:
    """Ring-modulate gated white noise at the carrier's own fundamental
    rate and sum with the carrier before shared distortion (GORDON_METHOD.md
    sec 4's literal 36.7Hz sub-audibility recipe)."""
    n = len(carrier)
    noise = sy.white_noise(n / sr, sr=sr, seed=seed)[:n]
    gate = (sy.square(mod_freq, n / sr, sr=sr)[:n] > 0).astype(np.float64)
    return carrier + 0.35 * noise * gate


def tempo_punch(x: np.ndarray, bpm: float, gain_reduction_db: float = 14.0,
                 attack_s: float = 0.03, makeup_db: Optional[float] = None
                 ) -> np.ndarray:
    """Hard-pinned compressor + makeup gain, release locked to the beat
    (GORDON_METHOD.md sec 7). First pass here only squashed the loud
    transient down (downward compression, no makeup stage) -- that gives
    punch but throws away the actual effect Gordon described: with
    ~20dB of gain reduction on the transient, the makeup gain applied
    afterward to restore level pushes everything that was NOT being
    compressed (the parallel chains' quiet resonant tails -- comb-filter
    ring, feedback-loop decay, reverb) up by that same makeup amount, so
    once the input note dies the chain's own resonances/feedback swell up
    into audibility. Director's correction: that reveal-on-decay is the
    actual mechanism, not just a punchy attack."""
    release_s = (60.0 / bpm) * 0.5  # half a beat
    env = envelope_follower(x, attack_s, release_s)
    thresh = np.percentile(env, 70) + 1e-9
    over = np.maximum(env / thresh, 1.0)
    ratio = 1.0 + gain_reduction_db / 6.0  # rough dB->ratio mapping
    gain = np.where(over > 1.0, over ** (1.0 / ratio - 1.0), 1.0)
    compressed = x * gain
    # makeup gain: restore the level the compressor took off the transient
    # peak, applied to the WHOLE signal -- this is what lets the untouched
    # quiet tail material poke through once the loud part has decayed
    makeup = gain_reduction_db if makeup_db is None else makeup_db
    return compressed * sy.db_to_lin(makeup)


def smiley_eq(x: np.ndarray, sr: int = sy.SR) -> np.ndarray:
    """Gordon's "smiley face" curve: cut low mud, boost the top shelf
    (GORDON_METHOD.md sec 2: "cut 30-60Hz by ~4-5dB, boost ~8-10dB around
    8-10kHz shelf"). synth.py's biquad() only has lowpass/highpass/bandpass
    (no shelf types), so the shelves are built the standard way from those:
    subtract a scaled lowpassed copy (low cut) and add a scaled highpassed
    copy (high boost)."""
    low = sy.lowpass(x, 55.0, sr=sr, q=0.7)
    x = x - 0.4 * low
    high = sy.highpass(x, 8500.0, sr=sr, q=0.7)
    x = x + 1.8 * high
    return x


def guitar_chain(source: np.ndarray, bpm: float = 140.0) -> np.ndarray:
    """Parallel four-path distortion array modeled on Gordon's literal DOOM
    instrument description (GORDON_METHOD.md sec 2): fuzz/bitcrush path,
    phaser+echo path, overdriven-tape path, feedback-loop path -- summed,
    not chained, then smiley-EQ'd and tempo-punched. `source` is a REAL
    recorded guitar sample (real_sources.py's distortion_guitar/
    overdrive_guitar GM patch), not a synth waveform -- Gordon fed his array
    only a sine and the array did all the work; we feed it a real guitar
    and let the array do the same work Gordon's did for HIS sine.

    v1/v2 truncated every parallel path back down to len(source) before
    mixing, which silently cut off the comb-filter/feedback-loop path's
    own resonant decay tail -- exactly the material the tempo_punch()
    makeup-gain stage exists to reveal (director's correction: the point
    of the hard compression + makeup gain is that once the input note
    dies, the chain's own resonances/feedback swell up into audibility).
    Truncating the tail before that stage even ran meant there was nothing
    left to reveal. Fixed by padding the source with trailing silence so
    the feedback/comb/reverb-ish paths have room to ring out."""
    tail_s = 0.5
    source = sy.pad_to(source, len(source) + sy.samples(tail_s))
    n = len(source)

    # v1 fed all four paths through hard bitcrush/heavy drive and lost the
    # source's identity entirely -- a listen-proxy check (gemini_listen.py,
    # "instrument_family"/"sounds_like_real_instrument") came back
    # "synthesizer... buzzy", failing the director's actual bar ("sounds
    # like a GUITAR"). Root cause: over-processing, same failure Gordon
    # describes discarding his OWN first sine+distortion attempt for being
    # a cliche -- except ours was a cliche in the other direction (too much
    # grind erases the real source instead of a bare sine having none to
    # erase). Fix: keep a healthy dry path, drop bitcrush from the guitar
    # chain (bass/kick territory, not "sounds like a guitar" territory),
    # and lower the drive on the remaining wet paths so the real recorded
    # attack/body survives underneath the processing instead of being
    # replaced by it.
    dry = source

    # Path A: moderate amp-style saturation (not bitcrush -- crushing a
    # real guitar sample destroys the thing that reads as "real")
    path_a = sy.soft_clip(source * 2.2, drive=1.1)

    # Path B: phaser-ish (allpass sweep) + slap echo, for movement/width
    path_b = sy.allpass_filter(source, delay_s=0.0021, g=0.6)
    path_b = sy.delay_fx(path_b, delay_s=0.11, feedback=0.25, mix=0.35)

    # Path C: overdriven "tape" path -- pre-emphasis (highpass-boosted
    # drive) then soft saturation, modeling the sped-up-tape-playback trick
    # (GORDON_METHOD.md sec 5) as a nonlinearity applied to a
    # brightness-shifted signal rather than the raw source
    pre = sy.highpass(source, 800.0) * 1.2 + source
    path_c = sy.soft_clip(pre * 1.8, drive=1.3)

    # Path D: the mini-amp feedback loop, literally (feedback_loop() --
    # nonlinearity INSIDE a self-reprocessing recursion, not a linear
    # comb filter). Fed at reduced level (this loop is meant to be a
    # background presence that surfaces once tempo_punch()'s makeup gain
    # lifts it, matching "small enough that a loud signal chokes it out").
    path_d = feedback_loop(source, delay_s=1.0 / 110.0, feedback_gain=0.55,
                            drive=1.8)

    mixed = sy.mix_layers(
        [sy.pad_to(dry, n), sy.pad_to(path_a, n), sy.pad_to(path_b, n),
         sy.pad_to(path_c, n), sy.pad_to(path_d, n)],
        gains=[0.7, 0.3, 0.18, 0.22, 0.14],
    )
    mixed = smiley_eq(mixed)
    mixed = tempo_punch(mixed, bpm, gain_reduction_db=6.0)
    return sy.normalize_peak(mixed, -1.5)


def organ_choir_chain(source: np.ndarray, drone: bool = True) -> np.ndarray:
    """Lighter processing for the liturgical layer (organ/choir/bells):
    real samples stay largely intact (this is the "sacred" register, not
    the "argent metal" register) but get width via a slow chorus-style
    detuned double and a long reverb tail, so the chant material reads as
    a real room, not a dry MIDI render."""
    n = len(source)
    # cheap chorus: short slap-delay double for width
    doubled = sy.delay_fx(source, delay_s=0.018, feedback=0.0, mix=0.5)
    mixed = sy.mix_layers([sy.pad_to(source, n), sy.pad_to(doubled, n)],
                           gains=[0.8, 0.5])
    wet = sy.reverb(mixed, room_size=0.85, damping=0.25, tail_s=2.2)
    out = 0.55 * sy.pad_to(mixed, len(wet)) + 0.45 * wet
    return sy.normalize_peak(out, -3.0)


def argent_bass_chain(source: np.ndarray, bpm: float = 140.0) -> np.ndarray:
    """Sub-heavy bass path: ring-mod the source with gated noise at its own
    approximate fundamental so it reads on small speakers (GORDON_METHOD.md
    ring-mod recipe), pass the ring-modulated signal through the same
    nonlinear feedback_loop() as the guitar chain's amp path (a bass tail
    that keeps regenerating harmonic content as it decays reads far less
    static than a filtered-once sub), then the shared smiley EQ / tempo
    punch for mix cohesion across the "argent" layers."""
    tail_s = 0.4
    source = sy.pad_to(source, len(source) + sy.samples(tail_s))
    n = len(source)
    ringmod = ring_mod_noise(source, mod_freq=55.0)
    driven = sy.soft_clip(ringmod * 3.0, drive=1.1)
    fb = feedback_loop(driven, delay_s=1.0 / 55.0, feedback_gain=0.5, drive=1.5)
    mixed = 0.65 * driven + 0.45 * fb
    mixed = smiley_eq(mixed)
    mixed = tempo_punch(mixed, bpm, gain_reduction_db=10.0)
    return sy.normalize_peak(sy.pad_to(mixed, n), -2.0)
