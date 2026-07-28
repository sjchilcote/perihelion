"""Pure-numpy 2D drawing onto (W, H, 3) uint8 framebuffers (pygame
surfarray axis order: buf[x, y] = pixel) -- the scene layer's replacement
for pygame.draw / pygame.Surface.

Two buffer kinds, mirroring the pygame idioms the scenes were built on:

  * (W, H, 3) -- an opaque frame. Primitives write solid color; an RGBA
    color's alpha channel is ignored (pygame.draw on a non-SRCALPHA
    surface does the same).
  * (W, H, 4) -- an overlay (`overlay()`), the SRCALPHA stand-in.
    Primitives write RAW RGBA (no blending -- exactly pygame.draw on an
    SRCALPHA surface), and `blit(fb, ov)` alpha-composites the finished
    overlay onto a frame.

Primitive semantics (rect/line/circle/ellipse/arc/polygon, width=0 fill /
width>0 outline) follow pygame.draw at the call sites the scenes use.
"""

from __future__ import annotations

import math

import numpy as np


class Rect:
    """Minimal pygame.Rect stand-in for the few geometry call sites the
    scenes kept (left/right/center accessors). Iterates as (x, y, w, h),
    so every fb2d primitive accepts one where it accepts a rect tuple."""

    __slots__ = ("x", "y", "w", "h")

    def __init__(self, x, y, w, h):
        self.x, self.y, self.w, self.h = int(x), int(y), int(w), int(h)

    def __iter__(self):
        return iter((self.x, self.y, self.w, self.h))

    left = property(lambda self: self.x)
    top = property(lambda self: self.y)
    right = property(lambda self: self.x + self.w)
    bottom = property(lambda self: self.y + self.h)
    centerx = property(lambda self: self.x + self.w // 2)
    centery = property(lambda self: self.y + self.h // 2)

    def inflate(self, dx, dy) -> "Rect":
        return Rect(self.x - dx // 2, self.y - dy // 2,
                    self.w + dx, self.h + dy)


def _color(buf: np.ndarray, color) -> np.ndarray:
    c = np.asarray(color, dtype=np.uint8)
    ch = buf.shape[2]
    if c.shape[0] == ch:
        return c
    if ch == 3:
        return c[:3]                     # RGBA color on opaque frame: solid
    return np.concatenate([c, [255]]).astype(np.uint8)  # RGB on overlay


def overlay(w: int, h: int) -> np.ndarray:
    """A transparent (W, H, 4) scratch layer (SRCALPHA stand-in)."""
    return np.zeros((int(w), int(h), 4), dtype=np.uint8)


def fill(buf: np.ndarray, color, rect=None) -> None:
    """Solid fill of `rect` (x, y, w, h) or the whole buffer."""
    c = _color(buf, color)
    if rect is None:
        buf[...] = c
        return
    W, H = buf.shape[:2]
    x, y, w, h = (int(v) for v in rect)
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(W, x + w), min(H, y + h)
    if x1 > x0 and y1 > y0:
        buf[x0:x1, y0:y1] = c


def alpha_fill(buf: np.ndarray, color, alpha: int, rect=None) -> None:
    """Blend a translucent solid `color` at `alpha` into an opaque frame
    (the pygame idiom: fill an SRCALPHA overlay, blit it over the frame)."""
    W, H = buf.shape[:2]
    if rect is None:
        x0, y0, x1, y1 = 0, 0, W, H
    else:
        x, y, w, h = (int(v) for v in rect)
        x0, y0 = max(0, x), max(0, y)
        x1, y1 = min(W, x + w), min(H, y + h)
    if x1 <= x0 or y1 <= y0:
        return
    a = max(0, min(255, int(alpha)))
    if a >= 255:
        buf[x0:x1, y0:y1] = np.asarray(color, dtype=np.uint8)[:3]
        return
    region = buf[x0:x1, y0:y1].astype(np.uint16)
    c = np.asarray(color, dtype=np.uint16)[:3]
    buf[x0:x1, y0:y1] = _div255(c * a + region * (255 - a) + 127).astype(np.uint8)


def blit(fb: np.ndarray, src: np.ndarray, x: int = 0, y: int = 0,
         alpha: int = 255) -> None:
    """Alpha-composite `src` onto `fb` with its top-left at (x, y).
    `src` is (w, h, 4) RGBA (per-pixel alpha, times the global `alpha`)
    or (w, h, 3) RGB (opaque copy, or `alpha`-blended if alpha < 255)."""
    W, H = fb.shape[:2]
    sw, sh = src.shape[:2]
    x, y = int(x), int(y)
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(W, x + sw), min(H, y + sh)
    if x1 <= x0 or y1 <= y0:
        return
    sub = src[x0 - x:x1 - x, y0 - y:y1 - y]
    dst = fb[x0:x1, y0:y1]
    ga = max(0, min(255, int(alpha)))
    if src.shape[2] == 3:
        if ga >= 255:
            dst[...] = sub[..., :3]
        else:
            d = dst.astype(np.uint16)
            s = sub[..., :3].astype(np.uint16)
            dst[...] = _div255(s * ga + d * (255 - ga) + 127).astype(np.uint8)
        return
    if not sub[..., 3].any():
        return  # fully transparent overlay: nothing to composite
    a = sub[..., 3:4].astype(np.uint16)
    if ga < 255:
        a = _div255(a * ga + 127)
    s = sub[..., :3].astype(np.uint16)
    d = dst.astype(np.uint16)
    dst[...] = _div255(s * a + d * (255 - a) + 127).astype(np.uint8)


def _div255(t: np.ndarray) -> np.ndarray:
    """Exact x//255 for uint16 x <= 65279 (verified exhaustively) without
    integer division -- the hot path of every full-frame composite."""
    return (t + 1 + (t >> 8)) >> 8


# ---------------------------------------------------------------------------
# primitives
# ---------------------------------------------------------------------------

def rect(buf: np.ndarray, color, r, width: int = 0) -> None:
    x, y, w, h = (int(v) for v in r)
    if w <= 0 or h <= 0:
        return
    if width <= 0:
        fill(buf, color, (x, y, w, h))
        return
    width = min(width, (w + 1) // 2, (h + 1) // 2)
    fill(buf, color, (x, y, w, width))                    # top
    fill(buf, color, (x, y + h - width, w, width))        # bottom
    fill(buf, color, (x, y, width, h))                    # left
    fill(buf, color, (x + w - width, y, width, h))        # right


def hline(buf: np.ndarray, color, x0: int, x1: int, y: int, width: int = 1) -> None:
    if x1 < x0:
        x0, x1 = x1, x0
    fill(buf, color, (x0, y - (width - 1) // 2, x1 - x0 + 1, width))


def vline(buf: np.ndarray, color, x: int, y0: int, y1: int, width: int = 1) -> None:
    if y1 < y0:
        y0, y1 = y1, y0
    fill(buf, color, (x - (width - 1) // 2, y0, width, y1 - y0 + 1))


def line(buf: np.ndarray, color, p1, p2, width: int = 1) -> None:
    """Bresenham; width>1 replicates pygame's thick line (parallel 1px
    lines offset along the minor axis, centered)."""
    x1, y1 = int(p1[0]), int(p1[1])
    x2, y2 = int(p2[0]), int(p2[1])
    if y1 == y2:
        hline(buf, color, x1, x2, y1, max(1, width))
        return
    if x1 == x2:
        vline(buf, color, x1, y1, y2, max(1, width))
        return
    c = _color(buf, color)
    W, H = buf.shape[:2]
    dx, dy = abs(x2 - x1), abs(y2 - y1)
    width = max(1, int(width))
    if dx >= dy:
        offs = [(0, k) for k in range(-((width - 1) // 2), width - (width - 1) // 2)]
    else:
        offs = [(k, 0) for k in range(-((width - 1) // 2), width - (width - 1) // 2)]
    sx = 1 if x2 > x1 else -1
    sy = 1 if y2 > y1 else -1
    err = dx - dy
    x, y = x1, y1
    while True:
        for ox, oy in offs:
            px, py = x + ox, y + oy
            if 0 <= px < W and 0 <= py < H:
                buf[px, py] = c
        if x == x2 and y == y2:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x += sx
        if e2 < dx:
            err += dx
            y += sy


def lines(buf: np.ndarray, color, closed: bool, pts, width: int = 1) -> None:
    pts = list(pts)
    if len(pts) < 2:
        return
    for a, b in zip(pts, pts[1:]):
        line(buf, color, a, b, width)
    if closed:
        line(buf, color, pts[-1], pts[0], width)


def _disc_mask(buf, cx, cy, r_out, r_in=None):
    """(window, mask) for an annulus/disc, or None if fully off-buffer."""
    W, H = buf.shape[:2]
    cx, cy, r_out = int(cx), int(cy), int(r_out)
    x0, y0 = max(0, cx - r_out), max(0, cy - r_out)
    x1, y1 = min(W, cx + r_out + 1), min(H, cy + r_out + 1)
    if x1 <= x0 or y1 <= y0:
        return None
    xs = np.arange(x0, x1)[:, None] - cx
    ys = np.arange(y0, y1)[None, :] - cy
    d2 = xs * xs + ys * ys
    m = d2 <= r_out * r_out
    if r_in is not None and r_in > 0:
        m &= d2 > r_in * r_in
    return (x0, y0, x1, y1), m


def circle(buf: np.ndarray, color, center, radius, width: int = 0) -> None:
    radius = int(radius)
    if radius < 1:
        radius = 1 if width == 0 else radius
        if radius < 1:
            return
    r_in = None if width <= 0 else max(0, radius - int(width))
    got = _disc_mask(buf, center[0], center[1], radius, r_in)
    if got is None:
        return
    (x0, y0, x1, y1), m = got
    buf[x0:x1, y0:y1][m] = _color(buf, color)


def _ellipse_mask(buf, r, shrink=0):
    W, H = buf.shape[:2]
    x, y, w, h = (int(v) for v in r)
    rx, ry = (w - 1) / 2.0 - shrink, (h - 1) / 2.0 - shrink
    if rx <= 0 or ry <= 0:
        return None
    cx, cy = x + (w - 1) / 2.0, y + (h - 1) / 2.0
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(W, x + w), min(H, y + h)
    if x1 <= x0 or y1 <= y0:
        return None
    # squared 1D axes broadcast into one fused 2D compare (hot path: the
    # mind map redraws several near-fullscreen band ellipses per frame)
    xs = (np.arange(x0, x1, dtype=np.float32) - cx) * np.float32(1.0 / rx)
    ys = (np.arange(y0, y1, dtype=np.float32) - cy) * np.float32(1.0 / ry)
    return (x0, y0, x1, y1), (xs * xs)[:, None] + (ys * ys)[None, :] <= 1.0


def ellipse(buf: np.ndarray, color, r, width: int = 0) -> None:
    got = _ellipse_mask(buf, r)
    if got is None:
        return
    (x0, y0, x1, y1), m = got
    if width > 0:
        inner = _ellipse_mask(buf, r, shrink=int(width))
        if inner is not None:
            m = m & ~inner[1]
    buf[x0:x1, y0:y1][m] = _color(buf, color)


def arc(buf: np.ndarray, color, r, a0: float, a1: float, width: int = 1) -> None:
    """Elliptical arc inside rect `r`, angles in radians CCW from +x
    (pygame convention: y grows downward, so the arc sweeps visually
    counterclockwise)."""
    x, y, w, h = (int(v) for v in r)
    rx, ry = (w - 1) / 2.0, (h - 1) / 2.0
    if rx <= 0 or ry <= 0:
        return
    cx, cy = x + rx, y + ry
    c = _color(buf, color)
    W, H = buf.shape[:2]
    width = max(1, int(width))
    if a1 < a0:
        a1 += 2 * math.pi
    steps = max(8, int(max(rx, ry) * (a1 - a0)) * 2)
    a = np.linspace(a0, a1, steps + 1)
    ca, sa = np.cos(a), np.sin(a)
    for wi in range(width):
        prx, pry = max(0.5, rx - wi), max(0.5, ry - wi)
        px = np.rint(cx + ca * prx).astype(np.int64)
        py = np.rint(cy - sa * pry).astype(np.int64)
        m = (px >= 0) & (px < W) & (py >= 0) & (py < H)
        buf[px[m], py[m]] = c


def polygon(buf: np.ndarray, color, pts, width: int = 0) -> None:
    pts = [(float(p[0]), float(p[1])) for p in pts]
    if len(pts) < 3:
        return
    if width > 0:
        lines(buf, color, True, pts, width)
        return
    c = _color(buf, color)
    W, H = buf.shape[:2]
    ys = [p[1] for p in pts]
    y0 = max(0, int(math.ceil(min(ys))))
    y1 = min(H - 1, int(math.floor(max(ys))))
    n = len(pts)
    for y in range(y0, y1 + 1):
        xs: list[float] = []
        for i in range(n):
            ax, ay = pts[i]
            bx, by = pts[(i + 1) % n]
            if ay == by:
                continue
            if (ay <= y < by) or (by <= y < ay):
                xs.append(ax + (y - ay) * (bx - ax) / (by - ay))
        xs.sort()
        for i in range(0, len(xs) - 1, 2):
            xa = max(0, int(math.ceil(xs[i])))
            xb = min(W - 1, int(math.floor(xs[i + 1])))
            if xb >= xa:
                buf[xa:xb + 1, y] = c
