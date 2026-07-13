"""tools/musicgen/assemble_demo.py

Phase C step 3: assemble one demonstration piece -- rhythm bed + bass + lead
across low -> building -> high intensity, using the pyweek-28-simple
layering rule (layers mute/unmute or crossfade rather than any complex
transition logic; see DYNAMIC_MUSIC_DESIGN.md).
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))
import synth as sy  # noqa: E402
import melodies as mel  # noqa: E402


def assemble(out_path: Path, bars_per_section: int = 4) -> None:
    sections = []
    for intensity in ("low", "building", "high"):
        layers = [mel.render_layer(role, bars_per_section, intensity)
                  for role in ("rhythm", "bass", "lead")]
        n = max(len(x) for x in layers)
        layers = [sy.pad_to(x, n) for x in layers]
        mixed = sy.mix_layers(layers, gains=[1.0, 0.9, 0.8])
        sections.append(sy.normalize_peak(mixed, -2.0))
    full = sy.concat(*sections)
    full = sy.normalize_peak(full, -1.0)
    sy.write_wav(out_path, full)
    print(f"Wrote {out_path} ({len(full) / sy.SR:.1f}s)")


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--bars-per-section", type=int, default=4)
    args = ap.parse_args()
    assemble(args.out, args.bars_per_section)
