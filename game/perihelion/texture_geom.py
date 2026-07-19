"""Shared geometry/naming convention for bespoke per-polygon floor textures
(ARTSTYLE_DIRECTION.md, lever one). Deliberately dependency-free (no
pygame, no necore) so both the renderer and the offline generation tool
import the exact same numbers with no risk of drift.

Texture space is the polygon's LOCAL frame (the engine's post-recentering
frame, same as `Level.polygon_verts[i]` / `level.polygon_verts[i]` at runtime):
texel (tx, ty) of a polygon's texture corresponds to the polygon-local point
    local = bbox_min + (tx + 0.5, ty + 0.5) / DENSITY
i.e. texel (0, 0) is the top-left of the polygon's local bounding box, texel
rows increase downward with local y (matching an ordinary decoded image
top-to-bottom row order and the engine's y-down convention). Both render
backends invert the instance's polygon-local->screen transform and sample
NEAREST at each screen pixel's center.
"""

from __future__ import annotations

import math

# px per world unit in texture space. Fixed by ARTSTYLE_DIRECTION.md's
# measured projection ("native-res camera territory" is ~3px/world-unit at
# window scale); the renderer (Rust TEX_DENSITY / this module) and the
# generation tool must never disagree on this.
DENSITY = 3.0


def polygon_bbox(verts: list[tuple[float, float]]) -> tuple[float, float, float, float]:
    """(min_x, min_y, max_x, max_y) of polygon-local vertices."""
    xs = [p[0] for p in verts]
    ys = [p[1] for p in verts]
    return min(xs), min(ys), max(xs), max(ys)


def texture_size_for_polygon(verts: list[tuple[float, float]]) -> tuple[int, int]:
    """Expected texture pixel size (w, h) for a polygon's local vertex list --
    the size the generation tool must produce and `polygon_<index>.png` must
    have on disk. `ceil` so the texture always fully covers the bbox."""
    x0, y0, x1, y1 = polygon_bbox(verts)
    w = max(1, math.ceil((x1 - x0) * DENSITY))
    h = max(1, math.ceil((y1 - y0) * DENSITY))
    return w, h


def texture_path(textures_dir, level_id: str, polygon_index: int):
    """`<textures_dir>/<level_id>/polygon_<polygon_index>.png`."""
    return textures_dir / level_id / f"polygon_{polygon_index}.png"
