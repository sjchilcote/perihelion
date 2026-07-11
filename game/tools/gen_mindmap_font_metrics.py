"""Generate game/perihelion/data/mindmap_font_metrics.json: per-character
horizontal advances (px) for the mind-map's sans-serif faces (IBM Plex
Sans Regular/Medium) at the canonical label point size, measured with
freetype through pygame -- so mindmap.py's pure-Python label geometry
(label_size_px, region_header_boxes) can compute EXACT proportional text
widths without importing pygame at runtime.

The canonical size is PT=12, whose rendered cell height in pygame is
exactly 16px (mindmap.LABEL_H_PX) -- measured, not assumed; asserted
below. Other label sizes scale these advances linearly; the real-render
containment test (test_podscene.py) verifies the canonical boxes still
contain the actual rendered pixels at every ladder size and at 2x
resolution.

Run from the repo root after changing the bundled font:
    uv run --project game python game/tools/gen_mindmap_font_metrics.py
"""
from __future__ import annotations

import json
import os
import sys

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import pygame  # noqa: E402
import pygame.freetype  # noqa: E402

FONT_DIR = os.path.join(os.path.dirname(__file__), "..", "perihelion",
                        "assets", "fonts")
OUT = os.path.join(os.path.dirname(__file__), "..", "perihelion", "data",
                   "mindmap_font_metrics.json")
PT = 12
CELL_H = 16  # pygame.font cell height at PT (asserted below)
CHARS = "".join(chr(c) for c in range(32, 127))


def advances(path: str) -> dict[str, float]:
    ft = pygame.freetype.Font(path, PT)
    out = {}
    for ch in CHARS:
        m = ft.get_metrics(ch)
        if m and m[0] is not None:
            out[ch] = float(m[0][4])
    return out


def main() -> None:
    pygame.init()
    reg = os.path.join(FONT_DIR, "IBMPlexSans-Regular.ttf")
    med = os.path.join(FONT_DIR, "IBMPlexSans-Medium.ttf")
    f = pygame.font.Font(reg, PT)
    assert f.get_height() == CELL_H, (
        f"cell height at pt {PT} is {f.get_height()}, expected {CELL_H} -- "
        "update mindmap.LABEL_H_PX and this generator together")
    data = {
        "font": "IBM Plex Sans",
        "pt": PT,
        "cell_h": CELL_H,
        "regular": advances(reg),
        "medium": advances(med),
    }
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=1, sort_keys=True)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
