"""Walk-mask terrain: converts a `<texture>_walkmask.png` (white = walkable,
black = terrain) into the polygon-local axis-aligned rects
`necore.Sim.set_polygon_terrain` consumes for movement/projectile blocking.

Naming convention: alongside each polygon's bespoke floor texture
`polygon_<index>.png` (see `texture_geom.py`), an optional
`polygon_<index>_walkmask.png` in the same directory, same size, same
polygon-local coordinate mapping (the texel law: texel (tx, ty) <->
`bbox_min + (tx+0.5, ty+0.5) / DENSITY`) -- painted equipment lines up with
its floor art exactly. Absence of the file means fully walkable: no
terrain is ever fabricated (`load_walk_mask_rects` returns `[]`).

Dependency-free like `texture_geom.py`: `sim.py` states its own contract as
"Pure python + necore. No pygame" (`GameSession` is the deterministic,
headless-runnable core), so this module decodes PNG itself with the
standard-library `zlib`/`struct` rather than pulling pygame's image loader
into that lane. The art pipeline emits ordinary non-interlaced 8-bit
grayscale or RGB(A) PNGs for masks (the same tooling that emits the floor
textures render.py loads with pygame); interlaced/16-bit/palette masks are
rejected loudly rather than silently misread.
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

from . import texture_geom

TEXTURE_DIR = Path(__file__).resolve().parent / "assets" / "textures"

# Coarse-grid downsample factor: this many walk-mask texels (per axis)
# collapse into one terrain grid cell before rect-merging. Painted
# equipment silhouettes don't need per-texel collision precision, and
# merging coarser first keeps the extracted-rect count small (the
# "efficient, polygon-local" representation the director's spec asks for).
DOWNSAMPLE = 4

# A coarse cell is terrain if at least this fraction of its covered texels
# are black (painted-over) -- a majority vote, so a stray anti-aliased
# pixel at a silhouette edge doesn't flip a whole cell.
BLOCK_FRACTION = 0.5

# Below this 0..255 luminance, a texel counts as "black" (terrain, per the
# white=walkable/black=terrain convention).
BLACK_THRESHOLD = 128


class WalkMaskError(ValueError):
    """A walk-mask PNG exists but can't be trusted -- raised loudly rather
    than silently ignored or silently misread (no fallbacks/fake data)."""


def walkmask_path(level_id: str, polygon_index: int) -> Path:
    """`<TEXTURE_DIR>/<level_id>/polygon_<polygon_index>_walkmask.png`."""
    tex = texture_geom.texture_path(TEXTURE_DIR, level_id, polygon_index)
    return tex.with_name(tex.stem + "_walkmask" + tex.suffix)


# --- minimal PNG decoder (stdlib only) -------------------------------

_PNG_SIG = b"\x89PNG\r\n\x1a\n"


def _unfilter(raw: bytes, width: int, height: int, bpp: int) -> bytearray:
    """Reverse the per-scanline PNG filters (spec 9.2), non-interlaced."""
    stride = width * bpp
    out = bytearray(stride * height)
    prev = bytearray(stride)
    pos = 0
    for row in range(height):
        ftype = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        if ftype == 0:
            pass
        elif ftype == 1:  # Sub
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 0xFF
        elif ftype == 2:  # Up
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ftype == 3:  # Average
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                b = prev[i]
                line[i] = (line[i] + ((a + b) // 2)) & 0xFF
        elif ftype == 4:  # Paeth
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                b = prev[i]
                c = prev[i - bpp] if i >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        else:
            raise WalkMaskError(f"walk-mask PNG: unsupported filter type {ftype}")
        out[row * stride:(row + 1) * stride] = line
        prev = line
    return out


def decode_png_luminance(data: bytes) -> tuple[int, int, bytes]:
    """Decode a non-interlaced 8-bit grayscale/RGB/RGBA PNG into
    `(width, height, luma)` where `luma` is one byte per pixel (0..255,
    row-major). Raises `WalkMaskError` for anything outside that (palette,
    16-bit, interlaced, corrupt) -- a walk-mask miscount is a silent
    collision bug, so decode assumptions fail loud, not soft."""
    if data[:8] != _PNG_SIG:
        raise WalkMaskError("not a PNG file (bad signature)")
    pos = 8
    width = height = bit_depth = color_type = interlace = None
    idat = bytearray()
    n = len(data)
    while pos < n:
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        ctype = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        pos += 8 + length + 4  # + CRC
        if ctype == b"IHDR":
            (width, height, bit_depth, color_type, _comp, _filt, interlace) = \
                struct.unpack(">IIBBBBB", chunk)
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"IEND":
            break
    if width is None:
        raise WalkMaskError("walk-mask PNG: missing IHDR")
    if interlace != 0:
        raise WalkMaskError("walk-mask PNG: interlaced PNGs are not supported")
    if bit_depth != 8:
        raise WalkMaskError(f"walk-mask PNG: bit depth {bit_depth} not supported (need 8)")
    channels = {0: 1, 2: 3, 4: 2, 6: 4}.get(color_type)
    if channels is None:
        raise WalkMaskError(f"walk-mask PNG: color type {color_type} not supported "
                             "(need grayscale, RGB, gray+alpha, or RGBA)")
    raw = zlib.decompress(bytes(idat))
    px = _unfilter(raw, width, height, channels)
    luma = bytearray(width * height)
    if channels == 1:
        luma[:] = px
    elif channels == 2:
        luma[:] = px[0::2]
    else:  # 3 (RGB) or 4 (RGBA): ITU-R BT.601 luma, alpha ignored
        for i in range(width * height):
            o = i * channels
            luma[i] = (px[o] * 299 + px[o + 1] * 587 + px[o + 2] * 114) // 1000
    return width, height, bytes(luma)


# --- downsample + rect extraction -------------------------------------

def _coarse_grid(width: int, height: int, luma: bytes) -> tuple[int, int, list[list[bool]]]:
    """`(cols, rows, blocked)` -- `blocked[gy][gx]` True if that DOWNSAMPLE
    x DOWNSAMPLE coarse cell is terrain (majority of covered texels black).
    Partial edge cells (image size not a DOWNSAMPLE multiple) are sized by
    however many texels they actually cover."""
    cols = -(-width // DOWNSAMPLE)
    rows = -(-height // DOWNSAMPLE)
    blocked = [[False] * cols for _ in range(rows)]
    for gy in range(rows):
        y0, y1 = gy * DOWNSAMPLE, min(height, (gy + 1) * DOWNSAMPLE)
        for gx in range(cols):
            x0, x1 = gx * DOWNSAMPLE, min(width, (gx + 1) * DOWNSAMPLE)
            total = (y1 - y0) * (x1 - x0)
            black = 0
            for y in range(y0, y1):
                row_off = y * width
                for x in range(x0, x1):
                    if luma[row_off + x] < BLACK_THRESHOLD:
                        black += 1
            blocked[gy][gx] = (black / total) >= BLOCK_FRACTION
    return cols, rows, blocked


def _merge_rects(cols: int, rows: int, blocked: list[list[bool]]) -> list[tuple[int, int, int, int]]:
    """Greedy rect merge in coarse-cell units: horizontal runs per row,
    then extend vertically while an identical run exists directly below.
    Not maximal-rectangle-optimal, but correct and keeps the rect count
    small for the roughly-rectangular equipment footprints this mask
    represents. Returns (gx0, gy0, gx1, gy1) cell ranges (gx1/gy1
    exclusive)."""
    consumed = [[False] * cols for _ in range(rows)]
    rects: list[tuple[int, int, int, int]] = []
    for gy in range(rows):
        gx = 0
        while gx < cols:
            if not blocked[gy][gx] or consumed[gy][gx]:
                gx += 1
                continue
            gx1 = gx
            while gx1 < cols and blocked[gy][gx1] and not consumed[gy][gx1]:
                gx1 += 1
            gy1 = gy + 1
            while gy1 < rows and all(
                blocked[gy1][x] and not consumed[gy1][x] for x in range(gx, gx1)
            ):
                gy1 += 1
            for y in range(gy, gy1):
                for x in range(gx, gx1):
                    consumed[y][x] = True
            rects.append((gx, gy, gx1, gy1))
            gx = gx1
    return rects


def rects_from_mask(width: int, height: int, luma: bytes,
                     bbox_min: tuple[float, float]) -> list[tuple[float, float, float, float]]:
    """Polygon-local `(lo_x, lo_y, hi_x, hi_y)` terrain rects from a decoded
    walk-mask image, using the same texel law `texture_geom.py` documents."""
    cols, rows, blocked = _coarse_grid(width, height, luma)
    bx, by = bbox_min
    cell = DOWNSAMPLE / texture_geom.DENSITY
    out = []
    for gx0, gy0, gx1, gy1 in _merge_rects(cols, rows, blocked):
        out.append((
            bx + gx0 * cell, by + gy0 * cell,
            bx + gx1 * cell, by + gy1 * cell,
        ))
    return out


def load_walk_mask_rects(level_id: str, polygon_index: int,
                          verts: list[tuple[float, float]]) -> list[tuple[float, float, float, float]]:
    """Polygon-local terrain rects for one polygon, or `[]` if it has no
    `<texture>_walkmask.png` (absence = fully walkable, per spec)."""
    path = walkmask_path(level_id, polygon_index)
    if not path.is_file():
        return []
    width, height, luma = decode_png_luminance(path.read_bytes())
    want_w, want_h = texture_geom.texture_size_for_polygon(verts)
    if (width, height) != (want_w, want_h):
        raise WalkMaskError(
            f"{path}: walk-mask is {width}x{height}, expected {want_w}x{want_h} "
            "(must match the floor texture's size/mapping exactly)"
        )
    bbox_min = texture_geom.polygon_bbox(verts)[:2]
    return rects_from_mask(width, height, luma, bbox_min)


def apply_walk_masks(sim, level, polygon_offset: int = 0) -> None:
    """Load and install walk-mask terrain for every polygon in `level` into
    `sim` (a `necore.Sim`), polygon indices shifted by `polygon_offset` (for
    streamed chunks appended after polygon 0). No-op per polygon when the level
    has no `level_id` or the polygon has no mask file."""
    level_id = getattr(level, "level_id", "") or ""
    if not level_id:
        return
    for local_idx, verts in enumerate(level.polygon_verts):
        rects = load_walk_mask_rects(level_id, local_idx, verts)
        if rects:
            sim.set_polygon_terrain(local_idx + polygon_offset, rects)
