"""Non-pygame bitmap text: FSEX300 (the game's UI typeface) rasterized by
PIL to numpy alpha bitmaps and alpha-composited onto a (W, H, 3) uint8 frame
buffer (pygame surfarray axis order: fb[x, y] = pixel).

This is the ONE text path the renderer and HUD share, replacing pygame.font.
FSEX300 is a fixed-pitch pixel font, so glyphs land crisp; the alpha blit
still anti-aliases the few sub-pixel edges PIL produces at the requested
size.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

# The UI typeface the menus already use (menus.get_font loads the same file).
_FONT_PATH = Path(__file__).resolve().parent.parent / "assets" / "fonts" / "FSEX300.ttf"

_font_cache: dict[int, "ImageFont.FreeTypeFont"] = {}
_glyph_cache: dict[tuple, np.ndarray] = {}


def _font(size: int) -> "ImageFont.FreeTypeFont":
    f = _font_cache.get(size)
    if f is None:
        f = _font_cache[size] = ImageFont.truetype(str(_FONT_PATH), size)
    return f


def measure(text: str, size: int) -> tuple[int, int]:
    """(width, height) of `text` rendered at `size`, matching render_alpha's
    bitmap extent."""
    a = render_alpha(text, size)
    h, w = a.shape
    return w, h


def render_alpha(text: str, size: int) -> np.ndarray:
    """Alpha coverage bitmap of `text` at `size`, shape (h, w) uint8, cached
    forever. Top-left origin; the bitmap spans the font's ascent+descent so
    different strings share a common line box (so "10" and "9" line up)."""
    key = (text, size)
    a = _glyph_cache.get(key)
    if a is None:
        font = _font(size)
        ascent, descent = font.getmetrics()
        h = max(1, ascent + descent)
        bbox = font.getbbox(text)
        w = max(1, bbox[2])
        img = Image.new("L", (w, h), 0)
        ImageDraw.Draw(img).text((0, 0), text, fill=255, font=font)
        a = _glyph_cache[key] = np.asarray(img, dtype=np.uint8)
    return a


def blit_text(fb: np.ndarray, text: str, x: int, y: int, color, size: int) -> None:
    """Alpha-composite `text` onto `fb` (a (W, H, 3) uint8 array in pygame
    surfarray order) with its top-left at (x, y)."""
    a = render_alpha(text, size)
    h, w = a.shape
    W, H, _ = fb.shape
    x, y = int(x), int(y)
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(W, x + w), min(H, y + h)
    if x1 <= x0 or y1 <= y0:
        return
    # a is (row=y, col=x); fb is (x, y): take the visible sub-rect and
    # transpose to (dx, dy).
    sub = a[y0 - y:y1 - y, x0 - x:x1 - x].T.astype(np.uint16)  # (dx, dy)
    region = fb[x0:x1, y0:y1].astype(np.uint16)                # (dx, dy, 3)
    al = sub[..., None]
    col = np.asarray(color, dtype=np.uint16)[None, None, :]
    out = (col * al + region * (255 - al) + 127) // 255
    fb[x0:x1, y0:y1] = out.astype(np.uint8)
