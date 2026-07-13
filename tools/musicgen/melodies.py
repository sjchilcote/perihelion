"""tools/musicgen/melodies.py

Round 2 rebuild. Round 1's `render_lead` was a single 9-event fixed array
(`LEAD_PATTERN_HIGH`) looped verbatim for an entire intensity level -- the
exact bug the director named ("a synth playing one annoying note over and
over forever"). This module replaces it with a motif/phrase engine built
per `MELODY_CRAFT.md`'s researched rules (antecedent/consequent phrases,
motivic development -- sequence/inversion/augmentation/fragmentation,
contour classes, harmony-aware note choice, cadences) and seeded with a
real Gregorian chant motif per `CATHOLIC_SOURCES.md` (Dies Irae, Dorian
mode) rather than an arbitrary semitone table.

Still deliberately simple in the systems sense (fixed-grid step sequencer,
no tracker format/MIDI -- matches "keep the runtime mechanism as simple as
pyweek-28's") -- the complexity that was missing was compositional
(phrase/motif structure), not architectural, per the director's own
diagnosis of the failure.
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))
import synth as sy  # noqa: E402
import instruments as inst  # noqa: E402

BPM = 140.0
BEAT_S = 60.0 / BPM
STEP_S = BEAT_S / 4.0  # 16th-note grid, 16 steps/bar at 4/4
BAR_STEPS = 16

# note names -> Hz (equal temperament, A4=440)
_NOTE_OFFSETS = {"C": -9, "Cs": -8, "D": -7, "Ds": -6, "E": -5, "F": -4,
                 "Fs": -3, "G": -2, "Gs": -1, "A": 0, "As": 1, "B": 2}


def note_hz(name: str, octave: int) -> float:
    semitone = _NOTE_OFFSETS[name] + (octave - 4) * 12
    return 440.0 * (2.0 ** (semitone / 12.0))


# ---------------------------------------------------------------------------
# Church modes (CATHOLIC_SOURCES.md sec 1) -- semitone offsets from the final
# ---------------------------------------------------------------------------
MODES = {
    "dorian": [0, 2, 3, 5, 7, 9, 10, 12],       # Dies Irae's mode
    "phrygian": [0, 1, 3, 5, 7, 8, 10, 12],
    "mixolydian": [0, 2, 4, 5, 7, 9, 10, 12],   # Victimae Paschali's family
    "lydian": [0, 2, 4, 6, 7, 9, 11, 12],
}

# "Stable" scale degrees (index into MODES[...]) a phrase should land on at
# strong beats / phrase-end cadences: root, 4th (subdominant-ish anchor in a
# modal context), 5th -- per MELODY_CRAFT.md sec 4's chord-tone/cadence rule,
# adapted to modal (non-tonal-harmony) writing: no triadic chords, so
# "stable" = the final and its perfect-interval neighbors.
STABLE_DEGREES = {0, 3, 4, 7}  # indices into the 8-entry mode list (incl. octave)

# ---------------------------------------------------------------------------
# Chant-derived motifs (CATHOLIC_SOURCES.md sec 2) -- semitone offsets from
# the chant's own final, captured from real GABC incipits on GregoBase.
# ---------------------------------------------------------------------------
# Dies Irae, "Dies irae, dies illa": F E F D | E C D D, mode I Dorian, final D.
# Semitones from D: F=+3 E=+2 D=0 | E=+2 C=-2(nat. 7th below D) D=0 D=0.
DIES_IRAE_MOTIF = [3, 2, 3, 0, 2, -2, 0, 0]
# Victimae Paschali Laudes: D C D F G F E D, same Dorian family, final D.
VICTIMAE_MOTIF = [0, -2, 0, 3, 5, 3, 2, 0]

# Each motif entry paired with a 16th-step duration (syllabic default: one
# step per note, giving a compact ~half-bar cell -- the "1-2 bar cell" size
# MELODY_CRAFT.md sec 2 specifies for a developable motif).
MOTIF_DUR_STEPS = 2  # each chant syllable -> an 8th note (2 x 16th steps)


# ---------------------------------------------------------------------------
# Motivic development transforms (MELODY_CRAFT.md sec 2)
# ---------------------------------------------------------------------------

def sequence(motif, shift_semitones):
    """Repeat the motif transposed -- same shape, different pitch level."""
    return [s + shift_semitones for s in motif]


def invert(motif):
    """Flip each interval's direction around the motif's first note."""
    root = motif[0]
    return [root - (s - root) for s in motif]


def fragment(motif, n, from_end=False):
    """Take only the head (or tail) of a motif -- used to build tension via
    rhythmic density near a phrase's climax/cadence."""
    return motif[-n:] if from_end else motif[:n]


def retrograde(motif):
    """Reverse the motif -- a fourth mechanical transform, used sparingly
    for the consequent phrase's divergence point."""
    return list(reversed(motif))


# ---------------------------------------------------------------------------
# Harmony-aware snapping (MELODY_CRAFT.md sec 4/5): bias strong-beat/cadence
# notes onto stable scale degrees of the active mode instead of leaving an
# arbitrary chant interval unresolved against the underlying root.
# ---------------------------------------------------------------------------

def _snap_to_mode(semitone: int, mode: str, prefer_stable: bool) -> int:
    scale = MODES[mode]
    # candidate absolute semitones across a +-1 octave window
    candidates = [d + 12 * o for o in (-1, 0, 1) for d in scale]
    if prefer_stable:
        stable_semis = {MODES[mode][i] + 12 * o for o in (-1, 0, 1)
                         for i in STABLE_DEGREES}
        pool = sorted(stable_semis, key=lambda c: abs(c - semitone))
        return pool[0]
    pool = sorted(set(candidates), key=lambda c: abs(c - semitone))
    return pool[0]


def build_phrase(motif, n_bars: int, mode: str, register_offset: int = 0):
    """Build one antecedent OR consequent phrase (n_bars long) from a seed
    motif, applying development per MELODY_CRAFT.md rule: a motif may
    repeat verbatim at most 2 times consecutively; every repeat after that
    gets a transformation. Strong beats (every 4th step, i.e. beat starts)
    snap to stable scale degrees; weak beats snap to the nearest scale tone
    (passing/neighbor use, still modally coherent instead of arbitrary).
    Returns a list of (semitone_from_root, duration_steps) events, None
    semitone = rest, covering exactly n_bars * BAR_STEPS steps."""
    total_steps = n_bars * BAR_STEPS
    events = []
    step = 0
    repeat_count = 0
    cur_motif = list(motif)
    variant_cycle = ["sequence_up", "sequence_down", "invert", "fragment_head"]
    variant_i = 0
    while step < total_steps:
        remaining = total_steps - step
        # last cell of the phrase: force a cadence landing (stable degree,
        # longer duration) instead of wrapping mid-idea (MELODY_CRAFT.md #5)
        is_final_cell = remaining <= len(cur_motif) * MOTIF_DUR_STEPS + 2
        for i, semi in enumerate(cur_motif):
            if step >= total_steps:
                break
            strong_beat = (step % 4 == 0)
            cadence_note = is_final_cell and (i == len(cur_motif) - 1)
            snapped = _snap_to_mode(semi, mode, prefer_stable=strong_beat or cadence_note)
            dur = MOTIF_DUR_STEPS
            if cadence_note:
                dur = min(4, total_steps - step)
                snapped = 0  # resolve to the root -- authentic cadence
            events.append((snapped + register_offset, dur))
            step += dur
        if is_final_cell:
            break
        repeat_count += 1
        if repeat_count >= 2:
            # apply a transformation so the motif is never bare-repeated a
            # 3rd time running (MELODY_CRAFT.md's concrete anti-monotony rule)
            kind = variant_cycle[variant_i % len(variant_cycle)]
            variant_i += 1
            if kind == "sequence_up":
                cur_motif = sequence(motif, 2)
            elif kind == "sequence_down":
                cur_motif = sequence(motif, -3)
            elif kind == "invert":
                cur_motif = invert(motif)
            elif kind == "fragment_head":
                cur_motif = fragment(motif, max(2, len(motif) // 2))
            repeat_count = 0
        else:
            cur_motif = list(motif)
    return events


def build_period(motif, mode: str, phrase_bars: int = 4,
                  register_offset: int = 0):
    """Antecedent + consequent period (MELODY_CRAFT.md sec 1): the
    consequent restates the motif's opening (parallel period) then diverges
    via retrograde so the ear reads the restart as intentional composition,
    not a raw loop, while still resolving more conclusively than the
    antecedent (which cadences on the stable-but-not-always-root degree the
    snap function nearest to; the consequent's forced final cell always
    resolves to the root)."""
    antecedent = build_phrase(motif, phrase_bars, mode, register_offset)
    consequent_seed = retrograde(motif) if len(motif) > 2 else motif
    # parallel-period restart: reuse the original opening 2 notes, then the
    # retrograde tail -- "same opening idea, diverge to resolve differently"
    consequent_motif = motif[:2] + consequent_seed[2:]
    consequent = build_phrase(consequent_motif, phrase_bars, mode, register_offset)
    return antecedent + consequent


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

def _place(track: np.ndarray, x: np.ndarray, step: int, gain: float = 1.0) -> None:
    start = int(round(step * STEP_S * sy.SR))
    end = min(len(track), start + len(x))
    if end <= start:
        return
    track[start:end] += gain * x[: end - start]


def _load_sample(sample_dir, name: str):
    if sample_dir is None:
        return None
    p = Path(sample_dir) / f"{name}.wav"
    if not p.exists():
        return None
    x, _sr = sy.read_wav(p)
    return np.asarray(x, dtype=np.float32)


def render_rhythm_bed(n_bars: int, intensity: str,
                       sample_dir=None) -> np.ndarray:
    """Drums + guitar chug: kick every quarter (steps 0,4,8,12), snare on
    2 & 4, hats on straight 8ths -- the pattern the analyzed album blocks
    converge on -- plus, at building+ intensity, the 16th palm-mute chug
    train (7 hits + 1 rest per half-bar). Unchanged in grammar from round 1
    (the director's complaint was about the LEAD's monotony, not the
    rhythm bed's -- ostinato drums are genre-idiomatic per
    MELODY_CRAFT.md sec 6) but now also accepts a real-guitar-derived
    "chug_sampled" one-shot from gordon_chain.py's processed freesound
    source (see real_sources.py/gordon_chain.py) via sample_dir."""
    n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
    track = np.zeros(n, dtype=np.float64)
    k = _load_sample(sample_dir, "kick_sampled")
    s = _load_sample(sample_dir, "snare_sampled")
    c = _load_sample(sample_dir, "chug_sampled")
    k = k if k is not None else inst.kick()
    s = s if s is not None else inst.snare()
    c = c if c is not None else inst.rhythm_chug(73.4)
    h = inst.hihat_closed()
    for bar in range(n_bars):
        base = bar * BAR_STEPS
        for step in (0, 4, 8, 12):
            _place(track, k, base + step, 0.9)
        if intensity in ("building", "high", "peak"):
            for step in range(BAR_STEPS):
                if step % 8 != 7:
                    _place(track, c, base + step, 0.75)
        if intensity in ("high", "peak"):
            for step in (4, 12):
                _place(track, s, base + step, 0.8)
            for step in range(0, BAR_STEPS, 2):
                _place(track, h, base + step, 0.4)
        elif intensity == "building":
            for step in (12,):
                _place(track, s, base + step, 0.7)
            for step in range(0, BAR_STEPS, 4):
                _place(track, h, base + step, 0.35)
    return sy.normalize_peak(track, -2.0)


def render_bass(n_bars: int, root_note: str, root_octave: int, intensity: str,
                 mode: str = "dorian") -> np.ndarray:
    """Root-pedal 8th notes locked to the kick, still legitimate per
    MELODY_CRAFT.md sec 6 (bass-as-static-pedal under a moving lead is
    idiomatic -- the bug was the LEAD having nothing to move against).
    Now derives its root-adjacent passing note from the active mode (the
    5th, MODES[mode][4]) every other bar instead of a bare repeated root,
    for a hint of harmonic motion without becoming melodic/bouncy (which
    demo v6 previously judged "chiptune")."""
    root = note_hz(root_note, root_octave)
    fifth_semi = MODES[mode][4]
    n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
    track = np.zeros(n, dtype=np.float64)
    dur = STEP_S * (3.0 if intensity in ("high", "peak") else 2.0)
    for bar in range(n_bars):
        base = bar * BAR_STEPS
        use_fifth = (bar % 4 == 3)  # one bar in four leans on the 5th
        pattern = [fifth_semi if use_fifth else 0, None] * 8
        for step, semi in enumerate(pattern):
            if semi is None:
                continue
            freq = root * (2.0 ** (semi / 12.0))
            gain = 0.85 if intensity in ("high", "peak") else 0.5
            _place(track, inst.fm_bass(freq, dur), base + step, gain)
    return sy.normalize_peak(track, -2.0)


def render_lead(n_bars: int, root_note: str, root_octave: int, intensity: str,
                 mode: str = "dorian", motif=None) -> np.ndarray:
    """Chant-derived motif, developed across antecedent/consequent periods
    (MELODY_CRAFT.md sec 1-5), replacing round 1's single looped
    `LEAD_PATTERN_HIGH` array. `motif` defaults to the Dies Irae incipit
    (DIES_IRAE_MOTIF) -- the director's ordered judgment/apocalypse chant
    source (CATHOLIC_SOURCES.md sec 2a)."""
    n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
    if intensity not in ("high", "peak"):
        # lead only enters at high intensity+ -- playbook's "lead enters
        # last, at the drop" layering rule, unchanged from round 1
        return np.zeros(n, dtype=np.float64)
    root = note_hz(root_note, root_octave)
    track = np.zeros(n, dtype=np.float64)
    seed = motif if motif is not None else DIES_IRAE_MOTIF
    # register: one octave above the bass root (round 1's C6-region lead
    # read as "8-bit chiptino bleeps" per that module's own note -- keep
    # the lower register that fixed it)
    period = build_period(seed, mode, phrase_bars=4, register_offset=0)
    total_steps = n_bars * BAR_STEPS
    period_steps = sum(d for _, d in period)
    step = 0
    idx = 0
    while step < total_steps:
        semi, dur = period[idx % len(period)]
        if step >= total_steps:
            break
        dur = min(dur, total_steps - step)
        freq = root * 2 * (2.0 ** (semi / 12.0))
        note_dur_s = dur * STEP_S
        _place(track, inst.lead_saw(freq, note_dur_s), step, 0.8)
        step += dur
        idx += 1
    return sy.normalize_peak(track, -3.0)


def render_layer(role: str, n_bars: int, intensity: str,
                  root_note: str = "D", root_octave: int = 3,
                  sample_dir=None, mode: str = "dorian") -> np.ndarray:
    if role == "rhythm":
        return render_rhythm_bed(n_bars, intensity, sample_dir=sample_dir)
    if role == "bass":
        return render_bass(n_bars, root_note, root_octave, intensity, mode=mode)
    if role == "lead":
        return render_lead(n_bars, root_note, root_octave, intensity, mode=mode)
    raise ValueError(role)


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", type=Path, required=True)
    ap.add_argument("--bars", type=int, default=8)
    args = ap.parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)
    for intensity in ("low", "building", "high"):
        for role in ("rhythm", "bass", "lead"):
            x = render_layer(role, args.bars, intensity)
            path = args.out_dir / f"{role}_{intensity}.wav"
            sy.write_wav(path, x)
            print(role, intensity, "->", path)
