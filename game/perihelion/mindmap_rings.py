"""MIND page layout variant A (director A/B, PERIHELION_MINDMAP_LAYOUT=rings):
a fully ALGORITHMIC, STATIC concentric-ring layout -- "leveraging those
concentric circles" (director's brief, verbatim). Contrast with variant B
(mindmap.py's relax()): that is an iterative force-directed settle where
nodes move; this is a closed-form-ish PIPELINE that terminates by
construction and never iterates to convergence. Nodes NEVER move at rest
-- perfect stillness is inherent, not something a cooling schedule
approaches. Selection is expressed by moving the CAMERA to the node
(podscene.py's rings-mode `_to_screen`/`camera_glide`), never the node to
the camera -- the inverse of variant B's "yanked to the center" pin.

THE PIPELINE (five closed-form stages, each pure and deterministic):

  1. depth = prereq depth (shared with mindmap.py: `mindmap._depths_of`)
     -> ring index. A node's ring is EXACTLY its depth, always -- no
     escalation ever moves a node to a different ring, only within its
     own ring's radial band (see stage 3).

  2. region = a fixed compass sector, same territory semantics as
     mindmap.py's REAL map (`mindmap._REGION_ANGLE_DEG`, reused so both
     A/B variants agree on where "vocation" etc. live) when the graph's
     regions are exactly the four known ones; for synthetic graphs (the
     PBT suite's made-up region names) sectors are assigned evenly
     around the compass instead, non-overlapping by construction
     (half-span = 180deg / region count).

  3. within (region, ring), a Sugiyama-style barycenter sweep (fixed
     count, `SWEEP_COUNT`, alternating down/up over the depth layers)
     orders nodes to minimize edge crossings -- not by relaxing to a
     fixed point, but by a FIXED number of passes, ties broken by node
     id. This is an ORDERING pass only; it does not touch radius.

  4. arc allocation: each node's angular width at its ring's radius is
     computed ANALYTICALLY from its label's real rendered pixel size
     (`mindmap.label_size_px`, the same exact metric mindmap.py's own
     label placement uses -- see `_ring_metrics`'s angle-independent
     (w+h)/2 footprint bound, since labels are never rotated to match a
     node's angle around the ring). If a (region, ring) group's total
     angular demand exceeds its sector's span, escalation is a single
     deterministic first-fit bin-packing pass (`_allocate_group`): walk
     the group in barycenter order, dropping each node into the first
     already-open radial LANE its arc still fits in sector-wise, or
     opening a new one -- floored at the ACTUAL realized outer edge of
     every lane opened so far, not a fixed step, so an uncapped single
     wide label can never spill into a lane that assumed less room for
     it. No RNG, no fixed-point search, no recursion -- one pass,
     terminates by construction (at most one lane per node).

  5. ring radii are chosen SEQUENTIALLY, outward: ring d's base radius is
     the previous ring's ACTUAL realized outer radius (after whatever
     escalation stage 4 needed) plus a fixed minimum step. This is what
     makes "ring radius = depth, exactly" a real guarantee rather than a
     hope -- a deeper ring can never be closer to center than a
     shallower one, however much an earlier ring had to escalate.

Positions come back in WORLD px (the same px scale mindmap.py's label/
node metrics are authored in), NOT the -1..1 unit space mindmap.py's
relaxation uses -- rings mode's camera pans/zooms across a world that is
not bounded to one fixed screen (see podscene.py's `_to_screen_rings`),
unlike variant B's fixed elliptical canvas.
"""

from __future__ import annotations

import math

from . import mindmap

# ---------------------------------------------------------------------------
# tunables -- all fixed constants, no RNG, no wall-clock.
# ---------------------------------------------------------------------------

SWEEP_COUNT = 4                 # fixed Sugiyama barycenter sweep count
SECTOR_HALF_DEG = 45.0          # real map: 4 regions, 90deg apart, exactly
                                 # non-overlapping (mindmap.py's own 46deg
                                 # half-span leaves a deliberate 2deg soft
                                 # overlap for the WEAK relaxation affinity;
                                 # rings mode is a HARD partition, so it
                                 # needs the exact non-overlapping value)

RING0_R_PX = 60.0               # innermost ring (depth 0) radius
RING_MIN_STEP_PX = 24.0         # extra safety margin between ring d's
                                 # realized OUTER edge (node + label, see
                                 # `_ring_metrics`) and ring d+1's base --
                                 # small, because the outer-edge accounting
                                 # already reserves the label's real extent
ARC_PAD_PX = 10.0                # minimum tangential gap reserved between
                                 # two adjacent labels' arc allotments
SECTOR_SAFETY_FACTOR = 0.90      # arc allocation fits nodes within this
                                 # FRACTION of a region's true sector
                                 # half-span (region_layout()'s reported
                                 # value, used unshrunk for the sector-
                                 # containment property) -- two adjacent
                                 # regions' outermost nodes are placed via
                                 # INDEPENDENT allocations that each only
                                 # know their own half-span, so without a
                                 # buffer they can each legitimately use
                                 # the label's full conservative footprint
                                 # right up to the shared boundary and
                                 # touch (or, in float arithmetic, overlap
                                 # by a hair) across it. Shrinking the
                                 # half-span actually used for fitting
                                 # carves out a real gap between regions
                                 # while leaving `region_layout()`'s
                                 # reported half-span (and therefore the
                                 # sector-containment property) untouched.
RING_SAFETY_MARGIN_PX = 12.0     # extra clearance folded into a ring's
                                 # lane gap, on top of the exact label
                                 # geometry it's derived from

_NODE_R_WORST_PX = mindmap.NODE_R_PX + mindmap.NODE_R_ROOT_BONUS_PX


def _ring_metrics(tbl: dict[str, dict], ids_this_ring: list[str]) -> tuple[dict[str, float], float, float, float]:
    """Per-ring label geometry, shared by every node placed in this ring
    (allocation AND `ring_labels()` use the SAME numbers, so the angular
    budget stage 4 reserves is exactly what gets drawn -- no per-node
    mismatch). Labels are axis-aligned (never rotated to match a node's
    angle around the ring), so a label's true radial vs. tangential
    footprint depends on that angle -- e.g. a label at the ring's 3
    o'clock position has its WIDTH pointing radially and its HEIGHT
    tangentially, the opposite of a label at 12 o'clock. Rather than a
    per-angle case split, every footprint here uses the safe, angle-
    independent bound: an axis-aligned box of half-extents (w/2, h/2)
    projects onto ANY direction with extent at most (w/2)+(h/2) (each
    term's projection factor is <= 1) -- so reserving (w+h)/2 as BOTH the
    radial and the tangential half-extent is correct for every node in
    the ring regardless of where it ends up angularly.

    Returns (per-node eff_half, this ring's radial_half [the worst-case
    node's, applied uniformly], the node-center -> label-center radial
    offset)."""
    eff_half = {nid: sum(mindmap.label_size_px(tbl[nid]["label"])) / 2.0
                for nid in ids_this_ring}
    radial_half = max(eff_half.values()) if eff_half else 0.0
    offset = _NODE_R_WORST_PX + mindmap.LABEL_GAP_PX + radial_half + mindmap.LABEL_PAD_PX
    return eff_half, radial_half, offset


# ---------------------------------------------------------------------------
# stage 2: region -> compass angle + sector half-span, resolved once per
# graph. The real map's 4 named regions keep mindmap.py's authored compass
# points (so both A/B variants agree on where "vocation" etc. live);
# anything else (the PBT suite's synthetic "region0".."regionN-1" names)
# gets an evenly-spaced, non-overlapping partition instead.
# ---------------------------------------------------------------------------

def region_layout(graph: dict[str, dict] | None = None) -> tuple[dict[str, float], float]:
    """(region -> center angle in degrees, sector half-span in degrees)."""
    tbl = graph if graph is not None else mindmap.nodes()
    regions = sorted({n["region"] for n in tbl.values()})
    if not regions:
        return {}, SECTOR_HALF_DEG
    known = mindmap._REGION_ANGLE_DEG
    if all(r in known for r in regions):
        return dict(known), SECTOR_HALF_DEG
    n = len(regions)
    angles = {r: 360.0 * i / n for i, r in enumerate(regions)}
    return angles, 180.0 / n


# ---------------------------------------------------------------------------
# stage 1 + 3: depth grouping and the fixed-count barycenter sweep.
# ---------------------------------------------------------------------------

def _children_map(tbl: dict[str, dict]) -> dict[str, list[str]]:
    child_of: dict[str, list[str]] = {nid: [] for nid in tbl}
    for nid, n in tbl.items():
        for p in n["prereqs"]:
            if p in tbl:
                child_of[p].append(nid)
    for k in child_of:
        child_of[k].sort()
    return child_of


def _group_by_region_depth(tbl: dict[str, dict],
                            depth: dict[str, int],
                            ) -> dict[tuple[str, int], list[str]]:
    groups: dict[tuple[str, int], list[str]] = {}
    for nid in sorted(tbl):
        groups.setdefault((tbl[nid]["region"], depth[nid]), []).append(nid)
    return groups


def _barycenter_order(tbl: dict[str, dict], depth: dict[str, int],
                       groups: dict[tuple[str, int], list[str]]) -> None:
    """Orders every group's node list in place by a fixed `SWEEP_COUNT`
    alternating down/up barycenter sweep (classic layered-graph-drawing
    crossing reduction, e.g. the default in `dot`'s layered mode) -- a
    FIXED number of passes, not an iterate-to-convergence loop. Ties
    (equal barycenter, or no parents/children to average) break on node
    id, so the result is identical on every machine, every run."""
    maxd = max(depth.values()) if depth else 0
    child_of = _children_map(tbl)
    order_val: dict[str, float] = {}

    for (region, d), ids in groups.items():
        if d == 0:
            for i, nid in enumerate(sorted(ids)):
                order_val[nid] = float(i)
    for nid in tbl:
        order_val.setdefault(nid, 0.0)

    def resort(d_filter: int) -> None:
        for (region, d), ids in groups.items():
            if d == d_filter:
                ids.sort(key=lambda nid: (order_val[nid], nid))

    def down_sweep() -> None:
        for d in range(1, maxd + 1):
            for (region, dd), ids in groups.items():
                if dd != d:
                    continue
                for nid in ids:
                    pre = [p for p in tbl[nid]["prereqs"] if p in tbl]
                    if pre:
                        order_val[nid] = sum(order_val[p] for p in pre) / len(pre)
            resort(d)

    def up_sweep() -> None:
        for d in range(maxd - 1, -1, -1):
            for (region, dd), ids in groups.items():
                if dd != d:
                    continue
                for nid in ids:
                    ch = child_of.get(nid, [])
                    if ch:
                        order_val[nid] = sum(order_val[c] for c in ch) / len(ch)
            resort(d)

    down_sweep()
    for i in range(1, SWEEP_COUNT):
        (up_sweep if i % 2 == 1 else down_sweep)()


# ---------------------------------------------------------------------------
# stage 4: analytic arc allocation with deterministic escalation.
# ---------------------------------------------------------------------------

def _node_arc(eff_half: float, eff_r: float) -> float:
    """The angular window one node needs at radius `eff_r`, given the
    conservative circular footprint of radius `eff_half` around its
    label center (see `_ring_metrics`). This is the EXACT tangent-line
    relation, not the small-angle `width / eff_r` approximation: the two
    rays from the ring's origin tangent to a circle of radius `eff_half`
    at distance `eff_r` subtend a half-angle of `asin(eff_half / eff_r)`,
    and the circle lies entirely within that angular wedge (that is what
    "tangent" means) -- so two nodes on the SAME radius with disjoint
    wedges cannot have overlapping footprints, exactly, for ANY
    separation, not just small ones. `width / eff_r` under-reserves for
    large angular separations (a real bug an earlier version of this
    function had -- verified: two adjacent very wide labels at ~74deg
    apart, entirely plausible on a crowded single-lane ring, is where
    arc-length and chord-length diverge enough to actually collide) since
    chord length = 2*eff_r*sin(angle/2) < eff_r*angle for any angle > 0."""
    half = math.asin(min(1.0, eff_half / eff_r)) if eff_r > 0 else math.pi / 2
    return 2.0 * half + ARC_PAD_PX / max(eff_r, 1.0)


def _place_arcs(ids: list[str], r: float, center_rad: float,
                 eff_half: dict[str, float], offset: float,
                 ) -> dict[str, tuple[float, float]]:
    if not ids:
        return {}
    if len(ids) == 1:
        return {ids[0]: (r, center_rad)}
    eff_r = r + offset
    arcs = [_node_arc(eff_half[nid], eff_r) for nid in ids]
    start = center_rad - sum(arcs) / 2.0
    out: dict[str, tuple[float, float]] = {}
    cursor = start
    for nid, a in zip(ids, arcs):
        out[nid] = (r, cursor + a / 2.0)
        cursor += a
    return out


def _allocate_group(ids: list[str], base_r: float, center_rad: float,
                     half_span_rad: float, eff_half: dict[str, float],
                     offset: float, radial_half: float,
                     ) -> dict[str, tuple[float, float]]:
    """node id -> (radius, angle) for one (region, ring) group, `ids`
    already in final barycenter-swept order. A single deterministic pass,
    first-fit bin packing (a "shelf" packer): walk `ids` in order, and for
    each one, try every LANE opened so far (in creation order) at that
    lane's own fixed radius -- if adding this node's arc keeps that
    lane's running total within the sector span, it joins that lane;
    otherwise a NEW lane opens.

    A new lane's radius floor is `next_floor`, sequentially derived from
    the ACTUAL realized outer edge (offset + this ring's worst-case
    `radial_half`, the same accounting `ring_layout()` uses between
    RINGS) of every lane opened so far -- exactly the technique that
    makes ring-to-ring spacing safe (stage 5), applied one level down to
    LANES within a ring. This is what actually fixes the escalation: a
    fixed lane-to-lane radius step can't accommodate an uncapped single
    huge label without either capping its growth (leaving no way to
    place a label wider than the cap) or blowing the step past whatever
    the next lane assumed (a real bug an earlier fixed-step version of
    this function had) -- deriving each new floor from what the PREVIOUS
    lane actually needed sidesteps both.

    Termination is immediate: one pass over `ids`, at most `len(ids)`
    lanes opened (worst case, one node per lane, each a no-neighbor
    trivial fit)."""
    if not ids:
        return {}
    sector_span = 2.0 * half_span_rad
    # sin(sector_span / 2) is the exact inverse of `_node_arc`'s asin --
    # solving `2*asin(eff_half/eff_r) == sector_span` for eff_r gives the
    # minimum radius a single node's own footprint fits the WHOLE sector
    # at, closed form, the same tangent-line relation `_node_arc` uses
    # (not the small-angle `width/span` approximation this replaced).
    sector_sin = max(1e-6, math.sin(min(sector_span / 2.0, math.pi - 1e-6)))
    lanes: list[dict] = []
    next_floor = base_r
    for nid in ids:
        eh = eff_half[nid]
        for lane in lanes:
            arc = _node_arc(eh, lane["r"] + offset)
            if lane["arc"] + arc <= sector_span:
                lane["arc"] += arc
                lane["ids"].append(nid)
                break
        else:
            r_alone = max(next_floor, eh / sector_sin - offset)
            lanes.append({"r": r_alone, "arc": _node_arc(eh, r_alone + offset), "ids": [nid]})
            next_floor = max(next_floor, r_alone + offset + radial_half + RING_SAFETY_MARGIN_PX)

    out: dict[str, tuple[float, float]] = {}
    for lane in lanes:
        out.update(_place_arcs(lane["ids"], lane["r"], center_rad, eff_half, offset))
    return out


# ---------------------------------------------------------------------------
# stage 5: sequential outward ring placement + public API.
# ---------------------------------------------------------------------------

def ring_layout(graph: dict[str, dict] | None = None) -> dict[str, dict]:
    """node id -> {"pos": (x, y) world px, "radius": float, "angle":
    radians, "depth": int}. Positions are centered on a world origin
    (0, 0); podscene's rings-mode camera pans/zooms this world, it is not
    fit into one fixed canvas the way mindmap.py's relaxation is."""
    tbl = graph if graph is not None else mindmap.nodes()
    depth = mindmap._depths_of(tbl)
    maxd = max(depth.values()) if depth else 0
    groups = _group_by_region_depth(tbl, depth)
    _barycenter_order(tbl, depth, groups)
    angles_deg, half_span_deg = region_layout(tbl)
    half_span_rad = math.radians(half_span_deg) * SECTOR_SAFETY_FACTOR

    out: dict[str, dict] = {}
    prev_outer = RING0_R_PX
    for d in range(maxd + 1):
        ids_this_ring = [nid for nid in tbl if depth[nid] == d]
        eff_half, radial_half, offset = _ring_metrics(tbl, ids_this_ring)
        base_r = RING0_R_PX if d == 0 else prev_outer + RING_MIN_STEP_PX

        placed: dict[str, tuple[float, float]] = {}
        for (region, dd), ids in groups.items():
            if dd != d:
                continue
            center_rad = math.radians(angles_deg.get(region, 0.0))
            placed.update(_allocate_group(ids, base_r, center_rad, half_span_rad,
                                          eff_half, offset, radial_half))
        ring_outer = max((r + offset + radial_half for r, _ in placed.values()),
                        default=base_r)
        for nid, (r, theta) in placed.items():
            out[nid] = {"radius": r, "angle": theta, "depth": d,
                        "pos": (r * math.cos(theta), r * math.sin(theta)),
                        "label_offset": offset}
        prev_outer = ring_outer
    return out


def positions(graph: dict[str, dict] | None = None) -> dict[str, tuple[float, float]]:
    """node id -> (x, y) world px -- the shape podscene.py's `self.layout`
    expects, mirroring `mindmap.layout()`'s contract for the physics
    variant."""
    return {nid: info["pos"] for nid, info in ring_layout(graph).items()}


def ring_labels(graph: dict[str, dict] | None = None,
                 layout: dict[str, dict] | None = None,
                 ) -> dict[str, dict]:
    """node id -> {"box": (l, t, r, b) world px, "font_px": int, "leader":
    bool, "center": (x, y)}. Every label sits at the EXACT radial offset
    (`ring_layout()`'s per-node `"label_offset"`, from `_ring_metrics`)
    stage 4's arc allocation assumed for every node in its ring -- so
    non-occlusion holds by construction, not by a
    search over candidate anchors the way `mindmap.label_layout` (variant
    B's safety net) works. `leader` is always False: a radial spoke from a
    ring is its own leader line, no separate tick is needed."""
    tbl = graph if graph is not None else mindmap.nodes()
    lay = layout if layout is not None else ring_layout(tbl)
    pad = mindmap.LABEL_PAD_PX
    out: dict[str, dict] = {}
    for nid, info in lay.items():
        n = tbl[nid]
        w, h = mindmap.label_size_px(n["label"])
        eff_r = info["radius"] + info["label_offset"]
        theta = info["angle"]
        cx, cy = eff_r * math.cos(theta), eff_r * math.sin(theta)
        box = (cx - w / 2 - pad, cy - h / 2 - pad, cx + w / 2 + pad, cy + h / 2 + pad)
        out[nid] = {"box": box, "font_px": int(mindmap.LABEL_H_PX),
                    "leader": False, "center": (cx, cy)}
    return out


# ---------------------------------------------------------------------------
# crossing count (world-px twin of mindmap.count_crossings, which assumes
# unit-space input via mindmap._to_px -- rings positions are already px,
# so this operates on them directly rather than reusing that conversion).
# ---------------------------------------------------------------------------

def _xprod(o, a, b):
    return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])


def _segs_cross(p1, p2, p3, p4) -> bool:
    d1, d2 = _xprod(p3, p4, p1), _xprod(p3, p4, p2)
    d3, d4 = _xprod(p1, p2, p3), _xprod(p1, p2, p4)
    return d1 * d2 < 0 and d3 * d4 < 0


def count_crossings(layout: dict[str, dict], graph: dict[str, dict] | None = None) -> int:
    """Exact count of prereq-edge pairs that literally cross, for a
    `ring_layout()`-shaped `layout` (world px positions under "pos")."""
    tbl = graph if graph is not None else mindmap.nodes()
    edges = mindmap._edge_list(tbl)
    pts = {nid: layout[nid]["pos"] for nid in layout}
    count = 0
    for i in range(len(edges)):
        a, b = edges[i]
        if a not in pts or b not in pts:
            continue
        for j in range(i + 1, len(edges)):
            c, d = edges[j]
            if len({a, b, c, d}) < 4 or c not in pts or d not in pts:
                continue
            if _segs_cross(pts[a], pts[b], pts[c], pts[d]):
                count += 1
    return count


# ---------------------------------------------------------------------------
# camera glide: selection moves the CAMERA to the node (director's brief,
# verbatim), never the node to the camera. PROMOTED to mindmap.py (director-
# directed follow-up: podscene's physics-mode variant now needs the exact
# same glide for its own selection-changes-move-the-camera hybridization),
# re-exported here under its original name for backward compatibility --
# mindmap_rings.camera_glide and mindmap.camera_glide are the same function.
# ---------------------------------------------------------------------------

camera_glide = mindmap.camera_glide
