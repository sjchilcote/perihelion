"""tools/musicgen/melodies.py

Phase C step 2: sequence the accepted instrument palette (instruments.py)
into a simple pattern grammar, rendered per role (rhythm bed / bass / lead)
at a couple of intensity levels, per the playbook's grid (140 BPM, 4/4,
kick-on-every-quarter industrial techno-metal hybrid, as measured directly
off the album blocks in Phase A).

Deliberately simple: fixed-grid step sequencer (numpy array indexing into
instrument one-shots), no tracker format, no MIDI -- matches the "keep the
runtime mechanism as simple as pyweek-28's" design directive by not
over-building the offline generator either.
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


def _place(track: np.ndarray, x: np.ndarray, step: int, gain: float = 1.0) -> None:
    start = int(round(step * STEP_S * sy.SR))
    end = min(len(track), start + len(x))
    if end <= start:
        return
    track[start:end] += gain * x[: end - start]


def render_rhythm_bed(n_bars: int, intensity: str) -> np.ndarray:
    """Drums: kick every quarter (steps 0,4,8,12), snare on 2 & 4 (steps
    4,12), hats on straight 8ths -- the pattern all 41+ analyzed album
    blocks converge on for high-intensity sections. `low`/`building` thin
    the hats and drop the backbeat snare for a sparser bed."""
    n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
    track = np.zeros(n, dtype=np.float64)
    k, s, h = inst.kick(), inst.snare(), inst.hihat_closed()
    for bar in range(n_bars):
        base = bar * BAR_STEPS
        for step in (0, 4, 8, 12):
            _place(track, k, base + step, 0.9)
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
        # "low": kick only, no hats/snare -- dormant/low blocks in the
        # corpus consistently strip everything but a sparse pulse.
    return sy.normalize_peak(track, -2.0)


BASS_PATTERN = [0, None, None, 0, None, None, 7, None,
                0, None, None, 0, None, None, 5, None]  # semitone offsets, None=rest


def render_bass(n_bars: int, root_note: str, root_octave: int, intensity: str) -> np.ndarray:
    root = note_hz(root_note, root_octave)
    n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
    track = np.zeros(n, dtype=np.float64)
    dur = STEP_S * (3.0 if intensity in ("high", "peak") else 2.0)
    for bar in range(n_bars):
        base = bar * BAR_STEPS
        for step, semi in enumerate(BASS_PATTERN):
            if semi is None:
                continue
            freq = root * (2.0 ** (semi / 12.0))
            gain = 0.85 if intensity in ("high", "peak") else 0.5
            _place(track, inst.fm_bass(freq, dur), base + step, gain)
    return sy.normalize_peak(track, -2.0)


LEAD_PATTERN_HIGH = [(0, 3), (None, 1), (7, 2), (5, 2), (None, 1), (10, 3),
                      (7, 2), (None, 2)]  # (semitone, length_in_steps)


def render_lead(n_bars: int, root_note: str, root_octave: int, intensity: str) -> np.ndarray:
    if intensity not in ("high", "peak"):
        # lead only enters at high intensity+ in this demo grammar --
        # matches the playbook's "lead enters last, at the drop" layering rule
        n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
        return np.zeros(n, dtype=np.float64)
    root = note_hz(root_note, root_octave)
    n = int(n_bars * BAR_STEPS * STEP_S * sy.SR) + sy.samples(0.5)
    track = np.zeros(n, dtype=np.float64)
    for bar in range(n_bars):
        base = bar * BAR_STEPS
        step = 0
        for semi, length in LEAD_PATTERN_HIGH:
            if semi is not None:
                freq = root * 4 * (2.0 ** (semi / 12.0))
                _place(track, inst.lead_saw(freq, length * STEP_S), base + step, 0.8)
            step += length
    return sy.normalize_peak(track, -3.0)


def render_layer(role: str, n_bars: int, intensity: str,
                  root_note: str = "C", root_octave: int = 3) -> np.ndarray:
    if role == "rhythm":
        return render_rhythm_bed(n_bars, intensity)
    if role == "bass":
        return render_bass(n_bars, root_note, root_octave, intensity)
    if role == "lead":
        return render_lead(n_bars, root_note, root_octave, intensity)
    raise ValueError(role)


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", type=Path, required=True)
    ap.add_argument("--bars", type=int, default=4)
    args = ap.parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)
    for intensity in ("low", "building", "high"):
        for role in ("rhythm", "bass", "lead"):
            x = render_layer(role, args.bars, intensity)
            path = args.out_dir / f"{role}_{intensity}.wav"
            sy.write_wav(path, x)
            print(role, intensity, "->", path)
