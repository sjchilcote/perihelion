"""tools/musicgen/real_sources.py

Round 2, director's order #2 ("real instruments... a guitar/chug that
sounds like a GUITAR, organ/choir/bells that sound REAL"). Route chosen:
fluidsynth (already installed, headless-friendly) + CC0-licensed GM
soundfonts (see SOURCES_LICENSES.md and fetch_soundfonts.sh) rather than
VST hosting -- dawdreamer has no wheel for this box's Python (3.13/3.14,
dawdreamer's newest wheel tops out at cp311) and there's no passwordless
sudo to pacman-install Surge XT/sfizz, so VST hosting was a dead end
verified, not assumed. Soundfont-rendered real samples is the director's
own explicitly endorsed fallback route ("fluidsynth + good soundfonts").

Every note/patch rendered here is a real recorded sample played back by
fluidsynth, not synthesis -- this module is the "real instrument" source
material that gordon_chain.py then processes per GORDON_METHOD.md.
"""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))
import synth as sy  # noqa: E402

SF2_DIR = Path(os.environ.get("SF2_DIR", Path.home() / ".cache/perihelion_musicgen/sf2"))

# GM patch numbers (0-indexed) used from the CC0 soundfonts. Verified present
# via `strings *.sf2 | grep -i <name>` against all four CC0 banks fetched by
# fetch_soundfonts.sh; program numbers are the GM-1 standard assignments
# (these soundfonts are GM-compliant banks, not custom-numbered).
PROGRAM = {
    "church_organ": 19,       # GM: Church Organ
    "distortion_guitar": 30,  # GM: Distortion Guitar
    "overdrive_guitar": 29,   # GM: Overdriven Guitar
    "choir_aahs": 52,         # GM: Choir Aahs
    "tubular_bells": 14,      # GM: Tubular Bells
    "string_ensemble": 48,    # GM: String Ensemble 1 (for pad glue)
}

# Bank preference order per patch: Masterpiece.sf2 first (cleanest samples
# in informal listening pass), fall back to the others if a file is missing
# locally (fetch_soundfonts.sh didn't run yet) or a program sounds broken.
BANK_ORDER = ["Masterpiece.sf2", "ChaosBank.sf2", "Jnsgm2.sf2", "Unison.sf2"]


def _midi_note(name_octave_semi_from_c4: float) -> int:
    """semitones from C4 (MIDI 60) -> MIDI note number."""
    return int(round(60 + name_octave_semi_from_c4))


def _write_midi(path: Path, program: int, note: int, dur_s: float, velocity: int = 100) -> None:
    import mido
    mid = mido.MidiFile(ticks_per_beat=480)
    tr = mido.MidiTrack()
    mid.tracks.append(tr)
    tr.append(mido.Message("program_change", program=program, time=0))
    tr.append(mido.Message("note_on", note=note, velocity=velocity, time=0))
    ticks = int(dur_s * 480 * 2)  # 120bpm-independent: we set tempo below
    tr.append(mido.MetaMessage("set_tempo", tempo=500000, time=0))  # 120bpm
    tr.append(mido.Message("note_off", note=note, velocity=0, time=ticks))
    mid.save(str(path))


def render_note(patch: str, semitones_from_c4: float, dur_s: float,
                 velocity: int = 100, tail_s: float = 1.0) -> np.ndarray:
    """Render one note of a real GM patch via fluidsynth. Returns mono
    float32 at synth.SR. Tries banks in BANK_ORDER until one renders
    non-silent audio (a soundfont can have a broken/missing preset)."""
    program = PROGRAM[patch]
    note = _midi_note(semitones_from_c4)
    last_err = None
    for bank_name in BANK_ORDER:
        sf2 = SF2_DIR / bank_name
        if not sf2.exists():
            continue
        with tempfile.TemporaryDirectory() as td:
            midp = Path(td) / "n.mid"
            wavp = Path(td) / "n.wav"
            _write_midi(midp, program, note, dur_s + tail_s, velocity)
            try:
                subprocess.run(
                    ["fluidsynth", "-ni", "-F", str(wavp), "-r", str(sy.SR),
                     str(sf2), str(midp)],
                    check=True, capture_output=True, timeout=30,
                )
            except Exception as e:  # noqa: BLE001 -- try next bank
                last_err = e
                continue
            x, _sr = sy.read_wav(wavp)
            x = np.asarray(x, dtype=np.float32)
            if x.ndim > 1:  # fluidsynth renders stereo; collapse to mono
                x = x.mean(axis=1)
            if x.size and np.max(np.abs(x)) > 1e-4:
                return x
    raise RuntimeError(
        f"no CC0 soundfont in {SF2_DIR} rendered a non-silent '{patch}' "
        f"note (run fetch_soundfonts.sh first). last error: {last_err}"
    )


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)
    for patch in PROGRAM:
        x = render_note(patch, 0.0, 2.0)
        sy.write_wav(args.out_dir / f"{patch}_raw.wav", x)
        print(patch, "->", args.out_dir / f"{patch}_raw.wav", f"{len(x)/sy.SR:.2f}s")
