"""hymn01 — the first piece composed against the positive spec:
"Church music made by posthuman industrial machines that genuinely believe,
meaningful musical symbolism."

Code is the DAW (johnny method §2). Scored to a locked form map (§2): every
section is a named constant below; the grid is the album census grid
(140 BPM 4/4, 16th steps — fleshgrinder anchor tempo, corpus mode 135-140).

Liturgical forms in the bones, not dressing:
- The Dies Irae first strophe (melodies.DIES_IRAE_STROPHE, GABC-verified) is
  stated PLAIN by the machine congregation in the introit, then held as a
  CANTUS FIRMUS above the riff (chorale-prelude technique) in the hymn.
- ORGANUM: the second statement harmonizes in parallel perfect intervals
  (5th + octave below) — the oldest sacred polyphony is rule-driven and
  parallel, i.e. the most machine-like; that coincidence is the thesis.
- ANTIPHONY: verse = 2-bar lead call (hand-composed counter-motif, timbre =
  chug morphed toward the machine choir) answered by 2-bar chant fragment.
- The counter-motif is COMPOSED, not generated: antecedent/consequent, one
  apex (B natural — Dorian's raised 6th, belief-color against the gloom),
  half cadence answered by full cadence on D. Development is by register
  and rhythm only.
- The breakdown is the array BREATHING (feedback bus choke-and-swell) under
  a bell: when the congregation falls silent, the building keeps believing.
- Symbolism ledger (referents, per the spec): Dies Irae = the literal plot
  (solvet saeclum in favilla — the world dissolved in embers, sung at a
  station falling into the sun); machine choir = the congregation; bell in
  D = the station's own voice calling to worship; organum = machines
  harmonizing like 9th-century monks. Spectrogram neumes + mono-reveal
  chant are planned for v2 (GORDON_METHOD §6), after the audible core
  passes the director's ear.

Renders stems (bed/chant/organum/chug/kick/lead/riser/bell) so the dynamic
system reuses them as intensity layers. Census lanes checked at render.

    uv run python tools/musicgen/hymn01.py            # render all + census
"""
from __future__ import annotations

import json
import sys
from fractions import Fraction
from pathlib import Path

import numpy as np
import soundfile as sf
from scipy.signal import resample_poly, stft, istft

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))
import synth as sy                              # noqa: E402
import gordon_chain as gc                       # noqa: E402
from melodies import DIES_IRAE_STROPHE          # noqa: E402

SR = sy.SR
SCRATCH = Path("/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter"
               "/6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/musicgen")
SRC = SCRATCH / "freesound"
OUT = SCRATCH / "hymn01"
RNG = np.random.default_rng(0x1DAE)             # seeded: renders deterministic

# --- the locked form map (bars, 140 BPM 4/4) -------------------------------
BPM = 140.0
BEAT = 60.0 / BPM
BAR = 4 * BEAT
STEP = BEAT / 4                                  # 16th
S_INTROIT = (0, 9)      # machine hum + plain chant strophe line 1-3 + bell
S_ORGANUM = (9, 18)     # strophe again, organum 5th+8ve, cluster creeps in
S_RISER = (16, 18)      # shepard riser overlaps last organum bars
S_DROP = (18, 19)       # THE DROP: one bar of impact + ring-mod sub
S_HYMN = (18, 34)       # riff + kick; cantus firmus above; antiphony calls
S_CHOKE = (34, 38)      # array breathes, bell, near-silence (contrast law)
S_CLIMAX = (38, 50)     # full congregation: riff + organum + descant
S_END = (50, 53)        # mid-scream chop -> plain final phrase + bell decay
N_BARS = 53
TOTAL_S = N_BARS * BAR

# D roots. Machine congregation sings low (round-2 register finding: D3 is
# the machine's true voice; D4 reads chiptune).
D2, D3, D4 = 73.42, 146.83, 293.66

# SOURCE TUNING (FFT-measured, 2026-07-13). The original render assumed
# every sample already sat on a D root — measured false: the chug is a real
# F#2 (~92.0 Hz), the bell strikes near E3. The whole piece was polytonal
# by accident, which is why every listen-probe reported "dissonant static
# noise, no melody." Offsets bring each source TO its D root:
TUNE_CHUG = -3.90    # 92.0 Hz -> D2 73.42
TUNE_ORGAN = +2.00   # C3-dominant (fifth-rich pipe) -> D3; cluster detunes anyway
TUNE_BELL = -1.70    # ~162 Hz strike partial -> D3 (bells stay inharmonic)


def _sec(bars: tuple[int, int]) -> tuple[int, int]:
    return int(bars[0] * BAR * SR), int(bars[1] * BAR * SR)


def _load(name: str) -> np.ndarray:
    x, sr = sf.read(str(SRC / name), always_2d=True, dtype="float64")
    x = x.mean(axis=1)
    if sr != SR:
        fr = Fraction(SR, sr).limit_denominator(1000)
        x = resample_poly(x, fr.numerator, fr.denominator)
    return x


def repitch(x: np.ndarray, semitones: float) -> np.ndarray:
    """Resample repitch (speed+pitch together — correct for one-shots and
    for the machine voice, where the artifact IS the instrument)."""
    ratio = 2.0 ** (-semitones / 12.0)
    fr = Fraction(ratio).limit_denominator(200)
    return resample_poly(x, fr.numerator, fr.denominator)


def loop_to(x: np.ndarray, n: int, fade_s: float = 0.05) -> np.ndarray:
    """Loop with equal-gain crossfades to exactly n samples."""
    if len(x) >= n:
        return x[:n].copy()
    f = int(fade_s * SR)
    out = np.zeros(n)
    pos = 0
    while pos < n:
        seg = x if pos == 0 else x[f:]
        take = min(len(seg), n - pos)
        if pos > 0 and f > 0:
            ramp = np.linspace(0, 1, f)
            head = min(f, take, len(x) - f)
            if head > 0:
                out[pos - head:pos] *= (1 - ramp[:head])
                out[pos - head:pos] += x[f - head:f] * ramp[:head]
        out[pos:pos + take] += seg[:take]
        pos += take - (f if take == len(seg) and pos + take < n else 0)
        if take <= 0:
            break
    return out


def envelope(n: int, a_s: float, r_s: float, shape: float = 1.0) -> np.ndarray:
    a, r = max(1, int(a_s * SR)), max(1, int(r_s * SR))
    a, r = min(a, n // 2), min(r, n // 2)
    e = np.ones(n)
    e[:a] = np.linspace(0, 1, a) ** shape
    e[n - r:] = np.linspace(1, 0, r) ** shape
    return e


# --- voices ----------------------------------------------------------------

_MACHINE = None
def _factory(n: int) -> np.ndarray:
    global _MACHINE
    if _MACHINE is None:
        _MACHINE = _load("machine_factory.wav")
    return loop_to(_MACHINE, n, fade_s=0.08)


def _env_transplant(carrier: np.ndarray, modulator: np.ndarray,
                    smooth_bins: int = 31) -> np.ndarray:
    """Spectral-envelope transplant: the carrier keeps its harmonic comb
    (= exact pitch), the modulator lends its broad spectral shape and
    motion. |C| * smooth|M| / smooth|C|, carrier phase."""
    n = min(len(carrier), len(modulator))
    _, _, C = stft(carrier[:n], fs=SR, nperseg=2048, noverlap=1536)
    _, _, M = stft(modulator[:n], fs=SR, nperseg=2048, noverlap=1536)
    m = min(C.shape[1], M.shape[1])
    C, M = C[:, :m], M[:, :m]
    k = np.ones(smooth_bins) / smooth_bins
    sC = np.apply_along_axis(lambda v: np.convolve(v, k, "same"), 0, np.abs(C))
    sM = np.apply_along_axis(lambda v: np.convolve(v, k, "same"), 0, np.abs(M))
    Y = np.abs(C) * (sM / (sC + 1e-9)) * np.exp(1j * np.angle(C))
    _, y = istft(Y, fs=SR, nperseg=2048, noverlap=1536)
    return y


def machine_note(semi_from_d3: float, dur_s: float, breath: float = 0.20,
                 vel: float = 1.0) -> np.ndarray:
    """One note of the machine congregation. Measured fact: the factory
    recording is only weakly pitched (spectral comb 0.38) — repitching it
    can never sing a melody (three listen-probes in a row heard none). So
    the pitch is IMPOSED: a detuned-saw harmonic carrier at the exact note
    frequency wearing the factory's spectral envelope — the machines given
    a voice, which is the thesis performed by the DSP itself."""
    n = int(dur_s * SR)
    f0 = D3 * 2.0 ** ((semi_from_d3 + RNG.normal(0.0, 0.06)) / 12.0)
    t = np.arange(n + 4096) / SR
    car = np.zeros(len(t))
    for det, g in ((1.0, 1.0), (1.007, 0.7), (0.5, 0.3)):
        ph = 2 * np.pi * f0 * det * t
        car += g * (2 * ((ph / (2 * np.pi)) % 1.0) - 1.0)   # saw
    mod = _factory(len(car))
    y = _env_transplant(car / 2.0, mod)[:n]
    y *= envelope(n, breath, min(0.25, dur_s * 0.3), shape=1.4)
    return y * vel


def chant_line(events, register_semi: float, phrase_gain: bool = True,
               breath: float = 0.20) -> np.ndarray:
    """Place chant events (semitones-from-D, 16th-steps) on the grid.
    Phrase dynamics: hairpin toward each phrase's highest note (the chant
    breathes as a phrase, not as disconnected notes)."""
    total = sum(d for _, d in events)
    out = np.zeros(int(total * STEP * SR) + SR)
    # phrase-shape: gain follows contour toward apex
    semis = [s for s, _ in events if s is not None]
    apex = max(semis)
    lo = min(semis)
    t = 0
    for s, d in events:
        if s is not None:
            dur = d * STEP
            g = 1.0
            if phrase_gain and apex > lo:
                g = 0.72 + 0.28 * ((s - lo) / (apex - lo))
            g *= 1.0 + RNG.normal(0.0, 0.04)     # articulation, never flat
            note = machine_note(register_semi + s, dur * 1.04,
                                breath=breath, vel=g)
            i = int(t * STEP * SR)
            out[i:i + len(note)] += note[:len(out) - i]
        t += d
    return out


def organum_lines(events, register_semi: float) -> np.ndarray:
    """Parallel organum: principal + 5th below + OCTAVE ABOVE (vox
    organalis both sides), lower voice recessed. Rule-driven parallel
    motion — the machine's native polyphony. The doubling goes UP, not
    down: stacking octaves below the D3 factory voice was measured as
    pure rumble (94% energy < 250 Hz in render 1)."""
    a = chant_line(events, register_semi)
    b = chant_line(events, register_semi - 7) * 0.58
    c = chant_line(events, register_semi + 12) * 0.42
    n = max(len(a), len(b), len(c))
    out = np.zeros(n)
    for v in (a, b, c):
        out[:len(v)] += v
    return sy.highpass(out, 80)


_CHUG_KIT = None
def _slice_chug_kit(n_hits: int = 5) -> list[np.ndarray]:
    """chug1.wav is a 20.7 s RIFF PERFORMANCE (667 onsets, starts quiet) —
    the original code triggered its first ~200 ms of near-silence, which is
    why three probes called the 'guitar' a synth. Slice real hits at the
    strongest well-separated onsets, then AUTO-TUNE each slice to D2 by
    measured f0 (a riff moves pitch — a fixed offset would re-introduce
    the accidental polytonality)."""
    raw = _load("chug1.wav")
    env = np.abs(raw)
    k = int(0.01 * SR)
    sm = np.convolve(env, np.ones(k) / k, "same")
    flux = np.maximum(np.diff(sm), 0)
    idx = np.argsort(flux)[::-1]
    picks, kit = [], []
    for i in idx:
        if len(picks) >= n_hits:
            break
        if all(abs(i - j) > int(0.35 * SR) for j in picks) and i > int(0.5 * SR):
            picks.append(int(i))
    for i in sorted(picks):
        seg = raw[max(0, i - int(0.006 * SR)): i + int(0.30 * SR)].copy()
        seg *= envelope(len(seg), 0.001, 0.06)
        # measured per-slice f0 -> tune to the nearest D/A grid tone, then
        # down to D2 exactly (fifths are chord tones; anything else is drift)
        n2 = len(seg)
        f = np.fft.rfft(seg * np.hanning(n2), 2 * n2)
        ac = np.fft.irfft(f * np.conj(f))[:n2]
        lmin, lmax = int(SR / 400), int(SR / 55)
        j = int(np.argmax(ac[lmin:lmax])) + lmin
        f0 = SR / j
        off = 12 * np.log2(D2 / f0)
        off = off - 12 * round(off / 12)          # nearest octave of D
        kit.append(sy.normalize_peak(repitch(seg, off), -3.0))
    return kit


def chug_hit(semi_from_d2: float, dur_s: float, mute: float, vel: float) -> np.ndarray:
    """One palm-mute chug: a real sliced hit (round-robin kit), repitched;
    mute depth shortens and darkens (that's what a palm does)."""
    global _CHUG_KIT
    if _CHUG_KIT is None:
        _CHUG_KIT = _slice_chug_kit()
    x = _CHUG_KIT[int(RNG.integers(len(_CHUG_KIT)))]
    x = repitch(x, semi_from_d2 + RNG.normal(0, 0.02))
    n = int(dur_s * SR)
    if len(x) < n:
        x = np.pad(x, (0, n - len(x)))
    x = x[:n].copy()
    x *= envelope(n, 0.002, max(0.008, dur_s * (0.25 + 0.55 * mute)))
    if mute > 0:
        x = sy.lowpass(x, 2600 - 1500 * mute)
    return x * vel


# Riff cell: the chant incipit contour (F E F D = +3 +2 +3 0) as accent
# pitches over a D pedal chug train. 16th grid per bar:
#   position: 0    1    2    3    4    5    6    7    8 ...
# accents (chant tones) land on beats; pedal D palm-mutes fill between.
RIFF_BAR = [  # (16th pos, semi_from_D2, mute 0..1, vel) — air between hits
    (0, 3, 0.0, 1.00), (2, 0, 0.9, 0.55),
    (4, 2, 0.15, 0.92), (6, 0, 0.9, 0.5), (7, 0, 0.9, 0.42),
    (8, 3, 0.0, 0.97), (10, 0, 0.9, 0.52),
    (12, 0, 0.1, 0.9), (14, 0, 0.9, 0.5), (15, 2, 0.7, 0.62),
]
RIFF_BAR_B = [  # answer bar: descends to the final (E C D D tail of line 1)
    (0, 2, 0.0, 1.0), (2, 0, 0.9, 0.5),
    (4, -2, 0.12, 0.9), (6, -2, 0.9, 0.5),
    (8, 0, 0.0, 0.95), (10, 0, 0.9, 0.5), (12, 0, 0.15, 0.88),
    (14, 0, 0.9, 0.5), (15, 0, 0.8, 0.55),
]


def chug_amp(x: np.ndarray, bpm: float = BPM) -> np.ndarray:
    """Mid-forward guitar-amp chain for the riff bus. NOT the doom_array:
    the array's smiley EQ (Gordon's, for his sine-texture instrument)
    scoops exactly the 250-2000 Hz the album's rhythm guitar lives in —
    measured: routing the riff through the array left band_mid at 0.017 vs
    the album lane 0.16-0.21. Amp instead: tight highpass, two asymmetric
    stages, presence lift, cab rolloff, light tempo punch."""
    dry = sy.highpass(x, 65)
    # identity law (GORDON_METHOD §1, dry_mix note): the recorded guitar IS
    # the guitar; the drive is the voice AROUND it. Probe-measured failure
    # of the saturation-forward version: "guitar_reads_as: no guitar
    # present / synthesized bass" — pick attack and string noise died in
    # two tube stages. Dry-forward blend brings them back.
    drv = gc._tube(gc._fuzz(dry, gain=2.0, bias=0.06), drive=1.7)
    body = sy.lowpass(sy.highpass(drv, 350), 2600)
    fizz = sy.highpass(drv, 3200)
    y = 0.85 * dry + 0.5 * drv + 0.7 * body + 0.35 * fizz
    y = sy.lowpass(y, 9800)                            # cab, open top
    y = gc.tempo_punch(y, bpm, gain_reduction_db=7.0, attack_s=0.02)
    return sy.normalize_peak(y, -1.5)


_HAT = None
def machine_hats(n_bars: int, vel: float, every: int = 2) -> np.ndarray:
    """Machine percussion on 8ths with accent hierarchy. Voice: ring-mod
    square cluster (the round-2 hat synthesis Gemini accepted at 0.8) —
    the factory-transient slice measured dead above 8k (band_air stuck at
    0.0012); metallic inharmonic cluster is the album's actual hat energy."""
    global _HAT
    if _HAT is None:
        n_h = int(0.06 * SR)
        t = np.arange(n_h) / SR
        cl = np.zeros(n_h)
        for f in (5173.0, 6841.0, 8929.0, 11003.0):   # inharmonic cluster
            cl += np.sign(np.sin(2 * np.pi * f * t))
        cl *= np.sign(np.sin(2 * np.pi * 3271.0 * t))  # ring mod
        _HAT = sy.highpass(cl / 4.0, 5500) * envelope(n_h, 0.0008, 0.045,
                                                      shape=0.7)
    out = np.zeros(int(n_bars * BAR * SR) + SR)
    for bar in range(n_bars):
        for pos in range(0, 16, every):
            acc = 1.0 if pos % 8 == 4 else (0.55 if pos % 4 == 0 else 0.4)
            v = vel * acc * (1 + RNG.normal(0, 0.08))
            place(out, _HAT * v, bar * BAR + pos * STEP)
    return out


def power_chords(n_bars: int, vel: float = 1.0) -> np.ndarray:
    """The sustained rhythm-guitar WALL under the riff — the album's
    mid-band lives here (measured: without it band_mid sat at 0.07 vs the
    0.16-0.21 lane). Open fifths (D + A + octave), half-note harmonic
    rhythm following the riff's two-bar question/answer (D | C->D)."""
    out = np.zeros(int(n_bars * BAR * SR) + SR)
    for bar in range(n_bars):
        roots = [(0, 0.0), (8, 0.0)] if bar % 2 == 0 else [(0, -2.0), (8, 0.0)]
        for pos, root in roots:
            for iv, g in ((0, 1.0), (7, 0.8), (12, 0.55)):
                h = chug_hit(root + iv, 8 * STEP * 1.05, mute=0.0,
                             vel=vel * g * (1 + RNG.normal(0, 0.04)))
                place(out, h, bar * BAR + pos * STEP)
    return out


def beavan(x: np.ndarray) -> np.ndarray:
    """Sean Beavan tape round-trip (GORDON_METHOD §3): the part is rendered
    an octave up at double speed by the caller; here it goes to 'tape' hot
    and comes back at half speed — transients and artifacts land an octave
    down, thicker than any direct rendering."""
    hot = gc._reel_overdrive(x, drive=9.0)
    return resample_poly(hot, 2, 1)              # half speed = -1 octave


def render_riff(n_bars: int, palette=(RIFF_BAR, RIFF_BAR_B),
                vel_scale: float = 1.0) -> np.ndarray:
    """The riff, Beavan-processed: composed on the grid at +12st/2x speed,
    then tape-tripped back down. Every hit has its own velocity and mute."""
    up = np.zeros(int(n_bars * BAR / 2 * SR) + SR)
    for bar in range(n_bars):
        pat = palette[bar % len(palette)]
        for pos, semi, mute, vel in pat:
            t = (bar * 16 + pos) * (STEP / 2)
            v = vel * vel_scale * (1 + RNG.normal(0, 0.05))
            h = chug_hit(semi + 12, STEP * 1.9 / 2 * (1.6 - mute), mute, v)
            i = int(t * SR)
            up[i:i + len(h)] += h[:len(up) - i]
    down = beavan(up)
    return down[:int(n_bars * BAR * SR) + SR]


_KICK = None
def kick_track(n_bars: int, pattern, vel_jitter: float = 0.06) -> np.ndarray:
    global _KICK
    if _KICK is None:
        _KICK = _load("kick_metal_trim.wav")
    out = np.zeros(int(n_bars * BAR * SR) + SR)
    for bar in range(n_bars):
        for pos, vel in pattern:
            t = bar * BAR + pos * STEP
            v = vel * (1 + RNG.normal(0, vel_jitter))
            i = int(t * SR)
            k = _KICK * v
            out[i:i + len(k)] += k[:len(out) - i]
    return out


# census: high tier 2.33 low-hits/beat, peak 2.84. Kick + riff accents
# together carry that; kick itself: driving pattern with accent hierarchy.
KICK_HYMN = [(0, 1.0), (3, 0.55), (4, 0.9), (8, 1.0), (11, 0.5), (12, 0.9)]
KICK_PEAK = [(0, 1.0), (2, 0.5), (4, 0.9), (6, 0.55), (8, 1.0),
             (10, 0.5), (12, 0.92), (14, 0.6)]

_BELL = None
def bell_hit(semi: float, vel: float = 1.0) -> np.ndarray:
    global _BELL
    if _BELL is None:
        _BELL = _load("bell.wav")
    return repitch(_BELL, TUNE_BELL + semi) * vel


def place(out: np.ndarray, x: np.ndarray, t_s: float, gain: float = 1.0):
    i = int(t_s * SR)
    if i >= len(out):
        return
    seg = x[:len(out) - i]
    out[i:i + len(seg)] += seg * gain


# --- the hand-composed counter-motif (lead) --------------------------------
# Antecedent asks (half-close on E), consequent answers (apex B natural —
# Dorian's raised 6th, the belief-color — then closes on D). One apex.
LEAD_ANTECEDENT = [(0, 4), (3, 2), (5, 2), (7, 8), (5, 4), (3, 4), (2, 8)]
LEAD_CONSEQUENT = [(0, 4), (3, 2), (5, 2), (9, 8), (7, 4), (5, 2), (2, 2), (0, 8)]


def morph(a: np.ndarray, b: np.ndarray, alpha: float = 0.55) -> np.ndarray:
    """STFT cross-synthesis (GORDON_METHOD §4): |A|^a * |B|^(1-a) with A's
    phase — the chug's articulation wearing the machine-choir's body."""
    n = min(len(a), len(b))
    fa, ta, Za = stft(a[:n], fs=SR, nperseg=2048, noverlap=1536)
    fb, tb, Zb = stft(b[:n], fs=SR, nperseg=2048, noverlap=1536)
    m = min(Za.shape[1], Zb.shape[1])
    mag = (np.abs(Za[:, :m]) ** alpha) * (np.abs(Zb[:, :m]) ** (1 - alpha))
    Z = mag * np.exp(1j * np.angle(Za[:, :m]))
    _, y = istft(Z, fs=SR, nperseg=2048, noverlap=1536)
    return y


def lead_note(semi_from_d3: float, dur_s: float, vel: float) -> np.ndarray:
    """Lead voice: a sustained chug tone morphed toward the machine choir —
    the signature-tone move aimed at our own congregation."""
    n = int(dur_s * SR)
    g = chug_hit(semi_from_d3 - 12 + 12, dur_s * 1.1, mute=0.0, vel=1.0)
    g = loop_to(g, n + 2048, fade_s=0.03)
    c = machine_note(semi_from_d3, dur_s * 1.1, breath=0.02, vel=1.0)
    c = loop_to(c, n + 2048, fade_s=0.05)
    y = morph(g, c, alpha=0.55)[:n]
    y *= envelope(n, 0.012, min(0.2, dur_s * 0.35))
    return sy.highpass(y, 160) * vel


def lead_phrase(events, register_semi: float, vel: float = 1.0) -> np.ndarray:
    total = sum(d for _, d in events)
    out = np.zeros(int(total * STEP * SR) + SR)
    semis = [s for s, _ in events if s is not None]
    apex, lo = max(semis), min(semis)
    t = 0
    for s, d in events:
        if s is not None:
            g = (0.78 + 0.22 * ((s - lo) / (apex - lo))) if apex > lo else 1.0
            note = lead_note(register_semi + s, d * STEP * 0.96,
                             vel=vel * g * (1 + RNG.normal(0, 0.04)))
            place(out, note, t * STEP)
        t += d
    return out


def shepard_riser(dur_s: float, layers: int = 6, base_hz: float = 55.0,
                  cycle_s: float = 4.0) -> np.ndarray:
    """The endless riser (GORDON_METHOD §7): octave-spaced glissandi under a
    raised-cosine spectral window — rises forever, releases on OUR schedule."""
    n = int(dur_s * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    span = layers  # octaves covered by the window
    for k in range(layers):
        # each layer climbs one octave per cycle, wrapping
        pos = (t / cycle_s + k) % layers          # 0..layers
        f = base_hz * 2.0 ** pos
        phase = np.cumsum(2 * np.pi * f / SR)
        w = 0.5 - 0.5 * np.cos(2 * np.pi * pos / span)
        out += np.sin(phase) * w
    out /= layers
    # gentle grit so it belongs to this world
    return sy.lowpass(gc._tube(out, drive=1.4), 5200)


def bowed_cluster(dur_s: float) -> np.ndarray:
    """GORDON_METHOD §5: the C#/D adjacent-semitone dread cluster across
    four octaves, built from the sustained organ pipe (a real pipe, but
    functioning as texture in the array's world, not 'an organ playing')."""
    organ = _load("organ_cathedral.wav")
    n = int(dur_s * SR)
    out = np.zeros(n)
    for octv in (-12, 0, 12, 24):
        for semi, g in ((0, 0.5), (-1, 0.42)):    # D and C# below it
            x = loop_to(repitch(organ, TUNE_ORGAN + octv + semi + RNG.normal(0, 0.07)),
                        n, fade_s=0.4)
            # slow independent swell per layer (bowing takes)
            lfo = 0.55 + 0.45 * np.sin(
                2 * np.pi * RNG.uniform(0.05, 0.11) * np.arange(n) / SR
                + RNG.uniform(0, 6.28))
            out += x * lfo * g
    return sy.highpass(sy.lowpass(out / 8.0, 5200), 70)


# --- assembly ---------------------------------------------------------------

def render() -> dict:
    OUT.mkdir(parents=True, exist_ok=True)
    n = int(TOTAL_S * SR)
    stems = {k: np.zeros(n) for k in
             ("bed", "chant", "organum", "riff", "wall", "kick", "lead",
              "riser", "bell", "sub", "hats", "steam")}

    # BED: the hum — feedback bus idling at D + low cluster from ORGANUM on
    bed_src = machine_note(0, TOTAL_S, breath=1.5, vel=0.4)
    bed = gc.feedback_loop(bed_src * 0.5, delay_s=1.0 / D2,
                           feedback_gain=1.06, drive=1.0, input_gain=1.2,
                           howl_hz=D3, howl_q=3.0)
    stems["bed"][:len(bed)] += bed[:n] * 0.10
    clu = bowed_cluster((S_CHOKE[0] - S_ORGANUM[0]) * BAR)
    place(stems["bed"], clu * 0.55, S_ORGANUM[0] * BAR)

    # INTROIT: plain chant, one voice, D3. Bell tolls D at the strophe's
    # three line-ends (it knows the grammar).
    chant = chant_line(DIES_IRAE_STROPHE, 0)     # 8 bars from bar 0.5
    place(stems["chant"], chant, 0.5 * BAR, 0.9)
    for t_bar in (3.1, 5.9, 8.6):
        place(stems["bell"], bell_hit(0, 0.5), t_bar * BAR)

    # ORGANUM: strophe again, parallel voices, louder congregation.
    org = organum_lines(DIES_IRAE_STROPHE, 0)
    place(stems["organum"], org, (S_ORGANUM[0] + 0.5) * BAR, 0.95)

    # RISER into the drop
    ris = shepard_riser((S_DROP[0] - S_RISER[0]) * BAR + 0.2)
    ris *= np.linspace(0.15, 1.0, len(ris)) ** 1.5
    place(stems["riser"], ris, S_RISER[0] * BAR, 0.5)

    # THE DROP + HYMN: riff (Beavan), kick, cantus firmus above, antiphony.
    hymn_bars = S_HYMN[1] - S_HYMN[0]
    riff = render_riff(hymn_bars)
    # verse grammar (album's own): when the congregation sings, the band
    # PARTS — alternating 4-bar blocks, full band vs parted texture where
    # the cantus firmus owns the space. Arrangement, not sidechain tricks.
    part_mask = np.ones(len(riff))
    for blk in (1, 3):
        i0 = int(blk * 4 * BAR * SR); i1 = int((blk + 1) * 4 * BAR * SR)
        part_mask[i0:i1] = 0.5
    riff = riff * part_mask[:len(riff)]
    place(stems["riff"], riff, S_HYMN[0] * BAR, 0.95)
    kick = kick_track(hymn_bars, KICK_HYMN)
    place(stems["kick"], kick, S_HYMN[0] * BAR, 0.85)
    place(stems["hats"], machine_hats(hymn_bars, 0.5), S_HYMN[0] * BAR)
    wall_hymn = power_chords(hymn_bars, 0.9)
    wmask = np.ones(len(wall_hymn))
    for blk in (1, 3):
        i0 = int(blk * 4 * BAR * SR); i1 = int((blk + 1) * 4 * BAR * SR)
        wmask[i0:i1] = 0.0
    place(stems["wall"], wall_hymn * wmask, S_HYMN[0] * BAR)
    # steam: the machinery's own air band, a quiet 6k+ hiss bed in motion
    steam_n = int(hymn_bars * BAR * SR)
    steam = sy.highpass(RNG.normal(0, 1.0, steam_n), 6000)
    steam *= 0.5 + 0.5 * np.sin(2 * np.pi * 0.31 * np.arange(steam_n) / SR)
    place(stems["steam"], steam * 0.012, S_HYMN[0] * BAR)
    # ring-mod sub on the drop bar (GORDON_METHOD §2)
    subdur = 2 * BAR
    subcar = np.sin(2 * np.pi * D2 / 2 * np.arange(int(subdur * SR)) / SR)
    subnz = gc.ring_mod_noise(subcar, D2 / 2)
    drop_sub = gc._tube((subcar * 0.8 + subnz * 0.3), drive=2.2) \
        * envelope(int(subdur * SR), 0.004, subdur * 0.7)
    place(stems["sub"], drop_sub, S_DROP[0] * BAR, 0.85)
    # cantus firmus: the strophe in long notes over the riff (2x duration,
    # octave up from the introit voice = D4 register, congregation above).
    # Probe-measured failure at 0.55 single-voice: "liturgical_elements:
    # []" — the congregation was inaudible in its own hymn. Octave-doubled
    # and lifted; the wall is sidechain-parted under it below.
    cf = [(s, d * 2) for s, d in DIES_IRAE_STROPHE]
    cfx = chant_line(cf, 12, breath=0.25)
    cfx = cfx + 0.6 * chant_line(cf, 5, breath=0.25)   # A3: organum 5th below
    cfx = cfx + 0.45 * chant_line(cf, 24, breath=0.25)  # octave crown
    place(stems["chant"], cfx * 1.25, (S_HYMN[0] + 0.5) * BAR)
    # antiphony: lead calls in bars 4-6 and 10-12 of the hymn (answered by
    # the cantus firmus itself arriving at its next line)
    place(stems["lead"], lead_phrase(LEAD_ANTECEDENT, 12, vel=0.8),
          (S_HYMN[0] + 4) * BAR)
    place(stems["lead"], lead_phrase(LEAD_CONSEQUENT, 12, vel=0.85),
          (S_HYMN[0] + 10) * BAR)

    # CHOKE: everything stops; the array breathes; bell; distant plain chant.
    choke_in = np.zeros(int((S_CHOKE[1] - S_CHOKE[0]) * BAR * SR))
    tail = riff[int((hymn_bars - 0.5) * BAR * SR):
                int(hymn_bars * BAR * SR)]
    choke_in[:len(tail)] = tail * 0.7
    breath = gc.feedback_loop(choke_in, delay_s=1.0 / D2,
                              feedback_gain=1.11, drive=1.1,
                              input_gain=2.2, howl_hz=D3, howl_q=3.0)
    place(stems["bed"], breath, (S_CHOKE[0] + 0.06) * BAR, 0.34)
    place(stems["bell"], bell_hit(0, 0.55), (S_CHOKE[0] + 1.2) * BAR)
    line3 = DIES_IRAE_STROPHE[-10:]              # the consequent line only
    place(stems["chant"], chant_line(line3, 0) * 0.4,
          (S_CHOKE[0] + 1.6) * BAR)

    # CLIMAX: riff + kick(peak) + organum cantus firmus + descant lead.
    cl_bars = S_CLIMAX[1] - S_CLIMAX[0]
    place(stems["riff"], render_riff(cl_bars, vel_scale=1.05),
          S_CLIMAX[0] * BAR, 1.0)
    place(stems["kick"], kick_track(cl_bars, KICK_PEAK), S_CLIMAX[0] * BAR, 0.9)
    place(stems["hats"], machine_hats(cl_bars, 0.68), S_CLIMAX[0] * BAR)
    place(stems["wall"], power_chords(cl_bars, 1.0), S_CLIMAX[0] * BAR)
    cn = int(cl_bars * BAR * SR)
    csteam = sy.highpass(RNG.normal(0, 1.0, cn), 6000)
    csteam *= 0.5 + 0.5 * np.sin(2 * np.pi * 0.31 * np.arange(cn) / SR)
    place(stems["steam"], csteam * 0.016, S_CLIMAX[0] * BAR)
    cf2 = [(s, d * 2) for s, d in DIES_IRAE_STROPHE]
    place(stems["organum"], organum_lines(cf2, 12) * 0.5,
          (S_CLIMAX[0] + 0.5) * BAR)
    place(stems["lead"],
          lead_phrase(LEAD_ANTECEDENT + LEAD_CONSEQUENT, 24, vel=0.75),
          (S_CLIMAX[0] + 4) * BAR)
    place(stems["sub"], drop_sub, S_CLIMAX[0] * BAR, 0.8)

    # END: hard chop mid-bar (johnny craft law: cold mixouts chop
    # mid-scream), then the chant's final cadence alone with the bell.
    chop_at = int((S_END[0] + 0.02) * BAR * SR)
    for k in ("riff", "kick", "lead", "organum", "riser", "sub"):
        stems[k][chop_at:] = 0.0
    stems["bed"][chop_at:] *= 0.4
    final = [( -5, 4), (-2, 2), (0, 2), (0, 4), (0, 2), (-2, 2),
             (2, 4), (3, 4), (2, 4), (0, 16)]     # Teste David... la.
    place(stems["chant"], chant_line(final, 0) * 0.8,
          (S_END[0] + 0.15) * BAR)
    place(stems["bell"], bell_hit(0, 0.7), (S_END[0] + 2.0) * BAR)

    # THE DEAD GAP (johnny §8: the 150-250 ms vacuum before an impact does
    # more than any layer): true silence at the choke's front edge.
    gap0 = int(S_CHOKE[0] * BAR * SR)
    for k in stems:
        stems[k][gap0:gap0 + int(0.22 * SR)] = 0.0

    # AMP/BUS PROCESSING per stem class, then the mix bus.
    stems["riff"] = chug_amp(stems["riff"])
    stems["riff"] = stems["riff"] + 0.15 * sy.highpass(stems["riff"], 2800)
    stems["wall"] = chug_amp(stems["wall"])
    # the wall sits BEHIND the riff: recess lows, keep the harmonic body
    stems["wall"] = sy.highpass(stems["wall"], 120)
    # ...and PARTS under the congregation (gentle sidechain from the chant:
    # when the cantus firmus sings, the wall makes room — the mix enacts
    # the deference)
    stems["wall"] = gc.sidechain_duck(stems["wall"], stems["chant"],
                                      amount=0.6, release_s=0.25)
    stems["kick"] = sy.highpass(gc.tempo_punch(stems["kick"], BPM,
                                gain_reduction_db=8.0)[:n], 34)
    stems["kick"] = stems["kick"] + 0.4 * sy.highpass(stems["kick"], 3200)
    # congregation presence: breath overtones, rumble controlled
    for k in ("chant", "organum"):
        v = sy.highpass(stems[k], 85)
        stems[k] = v + 0.6 * sy.highpass(gc._tube(v, drive=2.0), 1400)
    for k in stems:
        stems[k] = stems[k][:n]

    # bed hum is masked once the band plays — gate it down there (its low
    # end was stacking under everything: sub band measured over-lane)
    for a, b in (S_HYMN, S_CLIMAX):
        i0, i1 = int(a * BAR * SR), int(b * BAR * SR)
        stems["bed"][i0:i1] *= 0.28

    GAINS = {"bed": 0.9, "chant": 1.3, "organum": 1.25, "riff": 0.68,
             "wall": 1.0, "kick": 0.62, "lead": 0.9, "riser": 0.7,
             "bell": 0.9, "sub": 0.35, "hats": 1.2, "steam": 2.4}
    mix = np.zeros(n)
    for k, g in GAINS.items():
        mix += stems[k] * g
    # headroom discipline (johnny §8): light glue only — dynamics live in
    # the arrangement. No pinned bus on the MIX (that's for the array).
    mix = sy.soft_clip(mix * 0.9, drive=0.35)
    mix = sy.normalize_peak(mix, -1.5)

    sf.write(str(OUT / "hymn01.wav"), mix.astype(np.float32), SR)
    for k in stems:
        sf.write(str(OUT / f"stem_{k}.wav"),
                 (stems[k] * GAINS[k]).astype(np.float32), SR)
    meta = {"bpm": BPM, "bars": N_BARS, "dur_s": TOTAL_S,
            "form": {"introit": S_INTROIT, "organum": S_ORGANUM,
                     "drop": S_DROP, "hymn": S_HYMN, "choke": S_CHOKE,
                     "climax": S_CLIMAX, "end": S_END}}
    (OUT / "hymn01.json").write_text(json.dumps(meta, indent=1))
    print(f"rendered {OUT/'hymn01.wav'}  {TOTAL_S:.1f}s")
    return meta


if __name__ == "__main__":
    render()
