"""Vital goldmine — slot assignments + Vitalium render helpers.

Director's ruling 2026-07-15: ALL synth voices come from the Vital
banks ("if we use Vital patches that add their own detailed character,
the rudimentary nature of our sources becomes an asset rather than a
problem"). Delay Lama (the album's voice), the TR-909 kit, and the chug
wall stay — they're samples/the vocal, not synths.

SLOTS maps slot -> (bank, preset stem). Filled from preset_scout
results + name-flavor fit; every choice's runners-up live in the scout
scores JSON (the decision log's alternates).
"""
from __future__ import annotations

import sys
from functools import lru_cache
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

S = Path("/tmp/claude-1000/-home-login-PycharmProjects-"
         "noneuclideantopdownshooter/6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b"
         "/scratchpad/musicgen")
BANKS = {
    "tngkaos": S / "tngkaos/TngKaos/Presets",
    "5years": S / "fiveyears/5 Years of Vital/Presets",
}
SO = S / "vitalium/usr/lib/vst/vitalium.so"

# slot -> (bank, preset). PROVISIONAL until the scout finishes; the
# lab bake-off is the director's gate. None = keep pending.
SLOTS: dict[str, tuple[str, str] | None] = {}


def preset_path(bank: str, stem: str) -> Path:
    p = BANKS[bank] / f"{stem}.vital"
    if not p.exists():
        raise FileNotFoundError(p)
    return p


@lru_cache(maxsize=1)
def _synth():
    from vst2_host import Vst2Synth
    return Vst2Synth(SO)


_loaded: list[str] = [""]


def render_seq(bank: str, stem: str, seq, total_s: float,
               tail_s: float = 1.0) -> np.ndarray:
    """One continuous pass of a note sequence through the preset.
    seq: [(midi, t_on_s, dur_s, vel)]."""
    syn = _synth()
    key = f"{bank}/{stem}"
    if _loaded[0] != key:
        syn.set_chunk(preset_path(bank, stem).read_bytes() + b"\0")
        _loaded[0] = key
    return syn.render(seq, total_s, tail_s)


def render_notes(bank: str, stem: str, notes, dur_s: float,
                 velocity: int = 100, tail_s: float = 0.8) -> np.ndarray:
    seq = [(int(n), 0.0, dur_s, velocity) for n in notes]
    return render_seq(bank, stem, seq, dur_s, tail_s)
