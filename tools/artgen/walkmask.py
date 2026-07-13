"""tools/artgen/walkmask.py

Walk-mask dual output (director's order, 2026-07-13, workstream 2): for
each textured room, a second image the same dimensions as the floor
texture, white=walkable, black=painted-in terrain (the equipment placed
via box_conditioning's labeled boxes). Naming: `<texture stem>_walkmask.png`
next to the texture -- this is the exact convention the engine loader is
being built against; do not change it without coordinating with the
engine agent.

APPROACH CHOSEN: (b) derive the mask from the labeled boxes + texture
analysis, not a second paid generation call. Rationale (the three
approaches the director asked us to evaluate):

  (a) second generation call conditioned on the produced texture ("segment
      the solid equipment") -- doubles per-room generation cost (roughly
      +$0.05-0.12/room going by cost_log.json's per-call average) for a
      segmentation the pipeline can already derive for free from data it
      already has (the boxes), AND introduces a NEW failure mode (the
      segmentation call inventing/omitting equipment independently of what
      the first call actually painted) that then needs its OWN consistency
      gate against the texture -- strictly more paid calls and more retry
      surface for a result the box geometry already pins down.
  (b) derive from boxes + texture analysis -- zero extra generation cost,
      deterministic, and by construction consistent with what was
      REQUESTED; the residual risk is the model painting an item smaller/
      offset from its requested box, which the texture-analysis refinement
      below (threshold the box interior for solid low-variance paint vs.
      bare floor) catches and the mask/texture consistency gate verifies.
  (c) ask for both texture+mask in one structured call -- not supported by
      this pipeline's image-gen API (gen.py's generate_image returns a
      single flat PNG per call; OpenRouter's chat-completions image
      modality has no multi-image-per-response contract we can rely on)
      without a second round-trip, collapsing to (a)'s cost profile anyway.

(b) is therefore the cheap-to-evaluate winner and what full-run generation
will use; kept easy to swap for (a) later (same call site in
gen_pilot_textures_v2.process_room) if in-situ review of (b)'s masks on
the calibration batch shows it under-covers real painted equipment.
"""
from __future__ import annotations

from collections import deque

import numpy as np
from PIL import Image, ImageFilter

from tools.artgen.pilot_texture_lib import room_doorway_edges, _room_xform


def _largest_component(binary: np.ndarray) -> np.ndarray:
    """Boolean (H,W) -> boolean mask of just its largest 4-connected
    component (empty array in, empty out). No scipy dependency: a plain
    BFS flood fill, fine at the box sizes this pipeline works with."""
    h, w = binary.shape
    seen = np.zeros((h, w), dtype=bool)
    best = None
    best_size = 0
    ys, xs = np.nonzero(binary)
    for sy, sx in zip(ys.tolist(), xs.tolist()):
        if seen[sy, sx]:
            continue
        comp = _bfs_reachable(binary, (sy, sx))
        seen |= comp
        size = int(comp.sum())
        if size > best_size:
            best_size = size
            best = comp
    return best if best is not None else np.zeros((h, w), dtype=bool)


def _clean_binary(mask_bool: np.ndarray, radius: int = 2) -> np.ndarray:
    """MORPHOLOGICAL CLEANUP (director's requirement: 'mask must be clean
    binary after thresholding'). Per-pixel deviation thresholding alone
    produces salt-and-pepper speckle wherever the painted equipment has
    fine internal detail (rivets, highlights) -- calibration on l03/room_0
    confirmed this (a solid trough silhouette came out as scattered noise,
    not a clean blob). Open (erode then dilate) removes speckle smaller
    than `radius`; close (dilate then erode) fills small pinholes left
    inside an otherwise-solid shape; then keep only the largest connected
    component, since a real requested item is one coherent shape, not
    several disconnected fragments."""
    if not mask_bool.any():
        return mask_bool
    im = Image.fromarray((mask_bool.astype(np.uint8) * 255), mode="L")
    k = 2 * radius + 1
    opened = im.filter(ImageFilter.MinFilter(k)).filter(ImageFilter.MaxFilter(k))
    closed = opened.filter(ImageFilter.MaxFilter(k)).filter(ImageFilter.MinFilter(k))
    cleaned = np.asarray(closed) > 127
    if not cleaned.any():
        return cleaned
    return _largest_component(cleaned)


def derive_walkmask(room_mask_arr: np.ndarray, boxes: list[dict],
                     texture: Image.Image | None = None,
                     refine_from_texture: bool = True) -> Image.Image:
    """White (255) = walkable, black (0) = painted-in terrain. Starts from
    the boxed item footprints (guaranteed non-walkable -- that is what was
    requested), then optionally REFINES each box's blocked region down to
    just the solid-paint sub-area actually rendered there (texture
    analysis, approach (b)'s texture-analysis half): a requested item that
    only fills 60% of its box shouldn't block the other 40% as if it were
    solid. Pixels outside the room polygon are always black (matches the
    texture's own masking -- undefined outside the hull, never "walkable").
    """
    h, w = room_mask_arr.shape
    walk = np.zeros((h, w), dtype=bool)
    walk[room_mask_arr] = True

    tex_arr = None
    if refine_from_texture and texture is not None:
        tsz = texture.size  # (w, h)
        if tsz != (w, h):
            texture = texture.resize((w, h), Image.LANCZOS)
        tex_arr = np.asarray(texture.convert("L")).astype(np.float32)

    for b in boxes:
        x0, y0, x1, y1 = b["box"]
        x0, x1 = max(0, min(x0, w)), max(0, min(x1, w))
        y0, y1 = max(0, min(y0, h)), max(0, min(y1, h))
        if x1 <= x0 or y1 <= y0:
            continue
        if tex_arr is None:
            walk[y0:y1, x0:x1] = False
            continue
        # texture-analysis refinement: within the requested box, block the
        # region that reads as a coherent solid mass rather than bare
        # floor -- low local variance AND non-trivial extent, found via a
        # local-window std-dev threshold, then take the largest connected
        # component so isolated noisy floor pixels inside the box don't
        # get incorrectly blocked.
        sub = tex_arr[y0:y1, x0:x1]
        if sub.size == 0:
            continue
        # crude edge-density proxy for "this looks like a distinct object"
        # vs "this looks like plain floor": local gradient magnitude.
        gy, gx = np.gradient(sub)
        grad = np.sqrt(gx ** 2 + gy ** 2)
        # equipment reads as either much darker/lighter than the box's own
        # median (a solid shape) or as a locally structured region; either
        # signal alone is noisy, so block on deviation-from-median in
        # brightness (equipment silhouettes are the dominant local
        # departure from ambient floor tone in this style -- see
        # STYLE_LANGUAGE's flat-lighting law, which keeps floor tone flat
        # so an object IS the deviation).
        med = float(np.median(sub))
        dev = np.abs(sub - med)
        thresh = max(18.0, float(np.percentile(dev, 60)))
        solid_raw = dev > thresh
        solid = _clean_binary(solid_raw, radius=max(2, min(sub.shape) // 20))
        # require the block to cover a meaningful fraction of its own box
        # (a couple of stray bright/dark floor pixels must not block a
        # walkway) -- if too sparse, fall back to blocking the WHOLE
        # requested box (conservative: never under-block a requested item,
        # only ever refine a box that clearly IS mostly solid).
        if solid.mean() < 0.25:
            walk[y0:y1, x0:x1] = False
        else:
            block = np.zeros_like(walk[y0:y1, x0:x1])
            block[solid] = True
            walk[y0:y1, x0:x1][block] = False

    return Image.fromarray((walk.astype(np.uint8) * 255), mode="L")


def walkmask_out_path(texture_path):
    """<texture stem>_walkmask.png next to the texture -- the exact naming
    convention the engine loader is being built against."""
    from pathlib import Path
    p = Path(texture_path)
    return p.with_name(p.stem + "_walkmask.png")


# ---------------------------------------------------------------------------
# hard gate: portal connectivity
# ---------------------------------------------------------------------------

def _bfs_reachable(walk: np.ndarray, start: tuple[int, int]) -> np.ndarray:
    """4-connected flood fill from `start` (row, col) over `walk` (bool,
    True=walkable). Returns a bool array of the same shape marking every
    cell reachable from `start`."""
    h, w = walk.shape
    seen = np.zeros((h, w), dtype=bool)
    sy, sx = start
    if not (0 <= sy < h and 0 <= sx < w) or not walk[sy, sx]:
        return seen
    seen[sy, sx] = True
    q = deque([(sy, sx)])
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and walk[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True
                q.append((ny, nx))
    return seen


def portal_points_px(stem: str, room_idx: int, level, px_per_unit: float = 3
                      ) -> list[tuple[int, int, int]]:
    """Pixel-space sample point just INSIDE each doorway edge of this room
    (edge midpoint, nudged toward the room centroid by a few px so it
    lands on real floor, not exactly on the boundary), plus the edge
    index it belongs to. Returns [(edge_idx, row, col), ...] in the same
    (H, W) pixel frame room_mask/_room_xform use."""
    xform, verts = _room_xform(stem, room_idx, px_per_unit)
    door_edges = room_doorway_edges(stem, room_idx)
    n = len(verts)
    cx = sum(v[0] for v in verts) / n
    cy = sum(v[1] for v in verts) / n
    import necore
    ccx, ccy = necore.mat_apply(xform, cx, cy)
    out = []
    for i in door_edges:
        a, b = verts[i], verts[(i + 1) % n]
        ax, ay = necore.mat_apply(xform, *a)
        bx, by = necore.mat_apply(xform, *b)
        mx, my = (ax + bx) / 2.0, (ay + by) / 2.0
        # nudge 6px toward centroid so the sample lands inside the floor,
        # not exactly on the boundary edge (which the polygon mask/rasterizer
        # can render as just-outside due to fill-rule rounding).
        dx, dy = ccx - mx, ccy - my
        dlen = max(1e-6, (dx ** 2 + dy ** 2) ** 0.5)
        px_x = mx + dx / dlen * 6.0
        px_y = my + dy / dlen * 6.0
        out.append((i, int(round(px_y)), int(round(px_x))))
    return out


def check_room_portal_connectivity(walk_arr: np.ndarray, portal_pts: list[tuple[int, int, int]]
                                    ) -> dict:
    """HARD GATE: every portal (doorway) sample point in this room must be
    mutually reachable from every other portal sample point through
    walkable cells -- terrain painted via box conditioning must never wall
    off a doorway or bisect the room so two doors no longer connect. Fails
    loud (returns ok=False with the specific unreachable pair) rather than
    silently passing an under-specified mask."""
    if len(portal_pts) < 2:
        return dict(ok=True, reason="fewer than 2 doorways -- nothing to connect", n_portals=len(portal_pts))
    reach_from_first = _bfs_reachable(walk_arr, portal_pts[0][1:])
    unreachable = []
    for edge_idx, y, x in portal_pts[1:]:
        h, w = walk_arr.shape
        in_bounds = 0 <= y < h and 0 <= x < w
        if not in_bounds or not reach_from_first[y, x]:
            unreachable.append(edge_idx)
    ok = not unreachable
    return dict(ok=ok, n_portals=len(portal_pts), unreachable_edges=unreachable)


def check_level_portal_connectivity(stem: str, walkmasks: dict[int, np.ndarray], level=None) -> dict:
    """Runs check_room_portal_connectivity for every room that has a
    walk-mask, using the room's real doorway edges from level geometry.
    Returns per-room results plus an overall ok flag -- this is the hard
    gate the director specified: 'every portal remains reachable from
    every other portal through walkable cells.' A room whose portals fail
    to connect through its own walkable interior means SOME neighbor pair
    of rooms lost connectivity through it, so failing this locally is
    sufficient (no need to also BFS the whole level graph -- if every
    room's own doors connect to each other internally, and each doorway
    is shared with exactly one neighbor room by construction, the whole
    level graph's connectivity is unaffected by walk-mask terrain)."""
    if level is None:
        from tools.artgen.pilot_texture_lib import get_level
        level = get_level(stem)
    results = {}
    all_ok = True
    for room_idx, walk_arr in walkmasks.items():
        pts = portal_points_px(stem, room_idx, level)
        res = check_room_portal_connectivity(walk_arr, pts)
        results[room_idx] = res
        if not res["ok"]:
            all_ok = False
    return dict(ok=all_ok, rooms=results)
