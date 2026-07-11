"""The Mind Map (design doc 9.2): a graph of concepts the Commando has
room in his soul to metabolize. Expansion costs TIME, not components
(SEEDPOD_UI_DESIGN.md, director-directed): at the seed pod you choose ONE
frontier concept to think about; progress accrues in sim ticks during
normal field play (menus never tick), and the node unfolds -- with
ceremony -- when you next open the pod after the thought completes. Every
mechanical node is also a philosophical position, and faith/apostasy is
computed from the investment pattern, never shown as a meter.

Data: data/mindmap.json (committed design, MINDMAP_DESIGN.md). The design
sheet priced nodes in components + data as separate currencies. Those
`cost` fields are NOT deleted -- they are now think-time WEIGHTS: a node's
weight is the sum of both columns, and its think-time is
weight * THINK_SECONDS_PER_WEIGHT (the ONE conversion constant). The old
component-price curve (3..48, total 576 across 33 nodes) therefore becomes
30s..8min per node, ~96 minutes for the whole map -- the progression
curve's shape is preserved in the new currency, and scarcity is still the
point: a full campaign of field time affords roughly the map.
"""

from __future__ import annotations

import json
import math
import zlib
from pathlib import Path

# ---------------------------------------------------------------------------
# THE conversion constant (price -> time). One design sheet "cost" unit
# (component or data point) = 10 seconds of background thought = 600 ticks.
THINK_SECONDS_PER_WEIGHT = 10
THINK_TICKS_PER_WEIGHT = THINK_SECONDS_PER_WEIGHT * 60  # sim runs at 60Hz

_NODES: dict[str, dict] | None = None
_LAYOUT: dict[str, tuple[float, float]] | None = None

REGION_ORDER = ["vocation", "history", "comprehension", "void"]
REGION_LABELS = {
    "vocation": "VOCATION",
    "history": "HISTORY",
    "comprehension": "COMPREHENSION",
    "void": "THE VOID",
}


def nodes() -> dict[str, dict]:
    global _NODES
    if _NODES is None:
        with open(Path(__file__).parent / "data" / "mindmap.json",
                  encoding="utf-8") as f:
            _NODES = {n["id"]: n for n in json.load(f)}
    return _NODES


def weight(node_id: str) -> int:
    """Design-sheet cost columns summed: the node's think-time weight."""
    n = nodes()[node_id]
    return int(n["cost"]["components"]) + int(n["cost"]["data"])


def think_ticks(node_id: str) -> int:
    """Sim ticks of field time needed to finish thinking this node."""
    return weight(node_id) * THINK_TICKS_PER_WEIGHT


def available(purchased: set[str], node_id: str) -> bool:
    n = nodes()[node_id]
    return node_id not in purchased and \
        all(p in purchased for p in n["prereqs"])


def frontier(purchased: set[str]) -> list[str]:
    """Locked nodes whose prereqs are all met: the thinkable edge of the
    mind. Unlocked + frontier is exactly the fog-of-war visible set."""
    return sorted(nid for nid in nodes() if available(purchased, nid))


def faith_score(purchased: set[str]) -> int:
    tbl = nodes()
    return sum(tbl[i]["faith"] for i in purchased if i in tbl)


def unlocks(purchased: set[str]) -> set[str]:
    tbl = nodes()
    return {tbl[i]["unlock"] for i in purchased
            if i in tbl and tbl[i]["unlock"]}


def by_region() -> dict[str, list[dict]]:
    out: dict[str, list[dict]] = {r: [] for r in REGION_ORDER}
    for n in nodes().values():
        out[n["region"]].append(n)
    # stable, cheap-first-within-region ordering
    for r in out:
        out[r].sort(key=lambda n: (weight(n["id"]), n["id"]))
    return out


# ---------------------------------------------------------------------------
# graph layout: regions as territory (SEEDPOD_UI_DESIGN.md). A deterministic
# radial-by-region SEED, relaxed by a fixed-schedule force-directed pass
# (node/label repulsion, prereq springs, weak region-sector affinity, bounds
# containment) so that node discs AND their label rectangles never overlap
# at rest -- zero runtime randomness, identical positions on every machine,
# every run, for the same graph (director's determinism law).
# ---------------------------------------------------------------------------

# each region owns a compass sector (screen coords: +y is down)
_REGION_ANGLE_DEG = {"vocation": -90.0, "history": 0.0,
                     "comprehension": 180.0, "void": 90.0}
_SECTOR_HALF_DEG = 46.0


def depths() -> dict[str, int]:
    """Prereq depth per node (0 = a region root)."""
    tbl = nodes()
    memo: dict[str, int] = {}

    def d(nid: str) -> int:
        if nid not in memo:
            pre = tbl[nid]["prereqs"]
            memo[nid] = 0 if not pre else 1 + max(d(p) for p in pre)
        return memo[nid]

    for nid in tbl:
        d(nid)
    return memo


def seed_layout(graph: dict[str, dict] | None = None) -> dict[str, tuple[float, float]]:
    """node id -> (x, y) in unit space (roughly -1..1 both axes): the
    fixed initial condition the relaxation starts from. Nodes sit at a
    radius set by prereq depth, in their region's sector, spread evenly
    (id-sorted) within each (region, depth) ring segment."""
    tbl = graph if graph is not None else nodes()
    dep = _depths_of(tbl)
    maxd = max(dep.values()) or 1
    groups: dict[tuple[str, int], list[str]] = {}
    for nid in sorted(tbl):
        groups.setdefault((tbl[nid]["region"], dep[nid]), []).append(nid)
    pos: dict[str, tuple[float, float]] = {}
    span = math.radians(2 * _SECTOR_HALF_DEG)
    for (region, d_), ids in groups.items():
        base = math.radians(_REGION_ANGLE_DEG.get(region, 0.0))
        r = 0.30 + 0.70 * (d_ / maxd)
        for i, nid in enumerate(ids):
            a = base + span * ((i + 1) / (len(ids) + 1) - 0.5)
            pos[nid] = (r * math.cos(a), r * math.sin(a))
    return pos


def _depths_of(tbl: dict[str, dict]) -> dict[str, int]:
    memo: dict[str, int] = {}

    def d(nid: str) -> int:
        if nid not in memo:
            pre = [p for p in tbl[nid]["prereqs"] if p in tbl]
            memo[nid] = 0 if not pre else 1 + max(d(p) for p in pre)
        return memo[nid]

    for nid in tbl:
        d(nid)
    return memo


def layout() -> dict[str, tuple[float, float]]:
    """node id -> (x, y) in unit space, the RESTING (fully relaxed)
    layout for the real mindmap.json. Computed over the full graph
    (fog-of-war is a UI-side visibility filter applied downstream, never
    a layout input, so positions never jump when fog lifts)."""
    global _LAYOUT
    if _LAYOUT is None:
        _LAYOUT = layout_steps()[-1]
    return _LAYOUT


def layout_steps(graph: dict[str, dict] | None = None,
                  record_every: int = 1) -> list[dict[str, tuple[float, float]]]:
    """The relaxation trajectory for `graph` (defaults to the real
    mindmap), from the seed layout to the converged rest layout, sampled
    every `record_every` iterations. Frame 0 is the seed; frame -1 is the
    same fixed point `layout()`/`relax()` converge to. Pure function of
    the graph: no wall-clock, no unseeded randomness -- identical
    trajectory on every machine for the same input."""
    tbl = graph if graph is not None else nodes()
    seed = seed_layout(tbl)
    _, traj = relax(seed, tbl, record_every=record_every)
    return traj


# ---------------------------------------------------------------------------
# relaxation: force-directed settle over the seed layout.
# ---------------------------------------------------------------------------

# canonical canvas the relaxation is computed against (matches render.py's
# default PERIHELION_INTERNAL_RES, 640x360 -- the screen mapping in
# podscene._to_screen is a uniform per-axis scale of this canvas, so
# non-occlusion proven here holds at any internal resolution).
CANVAS_W, CANVAS_H = 640.0, 360.0
# unit -> canvas-px screen mapping (mirrors podscene.PodScene._to_screen's
# non-rite case exactly, so layout geometry matches what's drawn).
SX_FRAC, SY_FRAC = 0.40, 0.365
CX_FRAC, CY_FRAC = 0.5, 0.46

# reserved chrome strip at the top of the canvas (podscene's FABRICATOR/MIND
# tab header + underline lives in canvas y in [10, 30]): label_layout()'s
# canvas bound used to be _EDGE_MARGIN (4px) on every side, which let a
# node's label anchor as high as y=4 -- inside the header's own rows.
# Reserving this margin on the TOP edge only keeps every placed label
# below the header without touching the (already-proven) left/right/bottom
# containment.
HEADER_MARGIN_PX = 34.0

NODE_R_PX = 6.0
NODE_R_ROOT_BONUS_PX = 2.0
LABEL_GAP_PX = 6.0          # node rim -> label top, matches podscene's ui(6)
LABEL_CHAR_W_PX = 8.0       # FSEX300 bitmap font is monospace: 8px @ 16px
LABEL_H_PX = 16.0           # cell height at the size podscene labels use
LABEL_PAD_PX = 2.0          # breathing room around label glyph boxes

RELAX_ITERS = 220
_REPEL_K = 900.0
_LABEL_REPEL_K = 900.0
_SPRING_K = 0.06
_EDGE_LEN_PX = 46.0
_REGION_K = 0.020
_BOUNDS_R = 0.985           # unit-space containment radius (ellipse)
_BOUNDS_K = 6.0
# edge-crossing reduction (director-directed follow-up: relaxation alone
# left the graph "a dense tangle"). Two cooperating terms:
#  (1) node <-> non-incident-edge repulsion -- a node sitting on or near an
#      unrelated prereq edge IS visual clutter (near-misses and most actual
#      crossings both route through this), so it gets pushed off, and the
#      edge's endpoints get an equal-and-opposite nudge away from the node
#      (Newton's third law, same shape as the existing label<->node term).
#  (2) an explicit uncrossing pass -- every iteration, every pair of
#      non-adjacent prereq edges is tested for a literal segment
#      intersection (exact, not a proxy), and crossing pairs get a
#      corrective displacement pulling their midpoints apart. This is what
#      closes the cases (1) can't reach: two edges crossing far from every
#      third node.
_EDGE_REPEL_R_PX = 16.0     # node<->edge influence radius
_EDGE_REPEL_K = 400.0
_CROSS_K = 5.0               # per-iteration midpoint-separation displacement
# fixed extra budget for the uncrossing-polish closer (only spent when the
# main schedule ends up with MORE crossings than the seed it started
# from -- see relax()). Small and local: this is a repair pass, not a
# second settle.
_UNCROSS_POLISH_ITERS = 40
_UNCROSS_POLISH_TEMP0 = 12.0
# Fruchterman-Reingold-style cooling: displacement per node per iteration
# is capped at a "temperature" that decays linearly to ~0 -- this is what
# makes the integrator unconditionally stable (raw spring/repulsion forces
# can be arbitrarily large when two nodes coincide; capping the *step*
# rather than the force prevents blow-up regardless) and is also exactly
# the "vertices visibly settle" shape the animation wants: big moves early,
# vanishing jitter by the final frames.
_TEMP0_PX = 34.0
_TEMP_MIN_PX = 0.15


def _to_px(pos: tuple[float, float]) -> tuple[float, float]:
    x, y = pos
    return (CANVAS_W * CX_FRAC + x * CANVAS_W * SX_FRAC,
            CANVAS_H * CY_FRAC + y * CANVAS_H * SY_FRAC)


def _to_unit(pos: tuple[float, float]) -> tuple[float, float]:
    x, y = pos
    return ((x - CANVAS_W * CX_FRAC) / (CANVAS_W * SX_FRAC),
            (y - CANVAS_H * CY_FRAC) / (CANVAS_H * SY_FRAC))


def node_radius_px(n: dict) -> float:
    return NODE_R_PX + (NODE_R_ROOT_BONUS_PX if not n["prereqs"] else 0.0)


def label_size_px(label: str) -> tuple[float, float]:
    """(w, h) of a node's label glyph box at the font podscene renders
    node labels with. FSEX300 is a fixed-width bitmap font (verified:
    8px/glyph at the 16px cell podscene's get_font(9) snaps to), so this
    is exact, not an estimate -- no pygame/display dependency needed."""
    return (LABEL_CHAR_W_PX * max(1, len(label)), LABEL_H_PX)


def _edge_list(graph: dict[str, dict]) -> list[tuple[str, str]]:
    """(prereq_id, node_id) pairs -- the same edge set `relax()` springs
    and un-crosses, exposed for callers (tests, tuning scripts) that need
    to reason about the graph independent of a specific layout."""
    return [(p, nid) for nid in sorted(graph) for p in graph[nid]["prereqs"] if p in graph]


def count_crossings(pos: dict[str, tuple[float, float]],
                     graph: dict[str, dict] | None = None) -> int:
    """Exact count of prereq-edge pairs that literally cross in screen
    space, at `pos`. Non-adjacent pairs only (edges sharing an endpoint
    meet there by construction; that is not a crossing). Plain Python
    (not the numpy fast path inside relax()'s step_once) -- this is a
    measurement/verification tool, called once per layout, not once per
    iteration."""
    tbl = graph if graph is not None else nodes()
    edges = _edge_list(tbl)
    pts = {nid: _to_px(pos[nid]) for nid in pos}

    def xprod(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    def segs_cross(p1, p2, p3, p4):
        d1, d2 = xprod(p3, p4, p1), xprod(p3, p4, p2)
        d3, d4 = xprod(p1, p2, p3), xprod(p1, p2, p4)
        return d1 * d2 < 0 and d3 * d4 < 0

    count = 0
    for i in range(len(edges)):
        a, b = edges[i]
        if a not in pts or b not in pts:
            continue
        for j in range(i + 1, len(edges)):
            c, d = edges[j]
            if len({a, b, c, d}) < 4 or c not in pts or d not in pts:
                continue
            if segs_cross(pts[a], pts[b], pts[c], pts[d]):
                count += 1
    return count


def _build_system(tbl: dict[str, dict]) -> dict:
    """Precompute the fixed-shape arrays the force field needs for `tbl`
    (ids, radii, label sizes, edge index arrays, the uncrossing pass's
    non-adjacent edge-pair indices, the coincidence tie-breaker). Shared by
    the batch relaxation (`relax()`) and the online per-tick stepper
    (`live_relax_step()`) so both step an IDENTICAL force field -- the
    online stepper's fixed point is therefore the same fixed point
    `relax()` converges to, by construction, not by tuning two copies of
    the same physics to agree."""
    import numpy as np

    ids = sorted(tbl)
    n = len(ids)
    idx = {nid: i for i, nid in enumerate(ids)}
    R = np.array([node_radius_px(tbl[nid]) for nid in ids], dtype=np.float64)
    LW = np.array([label_size_px(tbl[nid]["label"])[0] for nid in ids], dtype=np.float64)
    LH = np.array([label_size_px(tbl[nid]["label"])[1] for nid in ids], dtype=np.float64)
    region_angle = np.array(
        [math.radians(_REGION_ANGLE_DEG.get(tbl[nid]["region"], 0.0)) for nid in ids],
        dtype=np.float64)
    edges = [(idx[p], idx[nid]) for nid in ids for p in tbl[nid]["prereqs"] if p in tbl]
    ei = np.array([e[0] for e in edges], dtype=np.int64) if edges else np.zeros(0, dtype=np.int64)
    ej = np.array([e[1] for e in edges], dtype=np.int64) if edges else np.zeros(0, dtype=np.int64)

    m = len(ei)
    if m > 1:
        pa_all, pb_all = np.triu_indices(m, k=1)
        shared = ((ei[pa_all] == ei[pb_all]) | (ei[pa_all] == ej[pb_all]) |
                  (ej[pa_all] == ei[pb_all]) | (ej[pa_all] == ej[pb_all]))
        pair_a, pair_b = pa_all[~shared], pb_all[~shared]
    else:
        pair_a = pair_b = np.zeros(0, dtype=np.int64)
    node_ix = np.arange(n)
    tiebreak_ang = (np.arange(n, dtype=np.float64) * _GOLDEN_ANGLE) if n else np.zeros(0)
    off_diag = ~np.eye(n, dtype=bool) if n else np.zeros((0, 0), dtype=bool)
    cx, cy = CANVAS_W * CX_FRAC, CANVAS_H * CY_FRAC
    bx, by = CANVAS_W * SX_FRAC * _BOUNDS_R, CANVAS_H * SY_FRAC * _BOUNDS_R
    return dict(ids=ids, idx=idx, n=n, R=R, LW=LW, LH=LH, region_angle=region_angle,
                ei=ei, ej=ej, pair_a=pair_a, pair_b=pair_b, node_ix=node_ix,
                tie_dx=np.cos(tiebreak_ang), tie_dy=np.sin(tiebreak_ang),
                off_diag=off_diag, cx=cx, cy=cy, bx=bx, by=by)


_SYSTEM_CACHE: dict[int, dict] = {}


def _cached_system(tbl: dict[str, dict]) -> dict:
    """`_build_system`, memoized by graph identity -- `live_relax_step()`
    is called once per sim tick (60Hz) while the MIND page is open, so
    rebuilding the index arrays from scratch every tick would be wasted
    work the batch relaxation doesn't pay (it builds once per call)."""
    key = id(tbl)
    sysd = _SYSTEM_CACHE.get(key)
    if sysd is None:
        sysd = _build_system(tbl)
        _SYSTEM_CACHE[key] = sysd
    return sysd


def _hard_contain(P, sysd) -> None:
    """Project any point still outside the ellipse bounds straight onto
    the boundary -- in place. Shared by relax()'s per-iteration hard
    containment and live_relax_step() (containment must hold unconditionally
    for both, not just "usually")."""
    import numpy as np
    cx, cy, bx, by = sysd["cx"], sysd["cy"], sysd["bx"], sysd["by"]
    edx, edy = (P[:, 0] - cx) / bx, (P[:, 1] - cy) / by
    e = edx * edx + edy * edy
    over = e > 1.0
    if np.any(over):
        shrink = np.where(over, 1.0 / np.sqrt(np.maximum(e, 1e-12)), 1.0)
        P[:, 0] = cx + (P[:, 0] - cx) * shrink
        P[:, 1] = cy + (P[:, 1] - cy) * shrink


def _force_step(P, sysd):
    """The full force field (node/label repulsion, prereq springs,
    node<->edge repulsion, the uncrossing pass, region-sector affinity,
    ellipse bounds) evaluated once at positions `P` (px space, shape
    (n, 2)). Pure function of (P, sysd) -- the single physics both
    relax() (batch, cooling schedule) and live_relax_step() (online,
    constant step cap) step."""
    import numpy as np

    n = sysd["n"]
    R, LW, LH = sysd["R"], sysd["LW"], sysd["LH"]
    ei, ej = sysd["ei"], sysd["ej"]
    pair_a, pair_b = sysd["pair_a"], sysd["pair_b"]
    off_diag = sysd["off_diag"]
    tie_dx, tie_dy = sysd["tie_dx"], sysd["tie_dy"]
    region_angle = sysd["region_angle"]
    cx, cy, bx, by = sysd["cx"], sysd["cy"], sysd["bx"], sysd["by"]

    def label_boxes(P):
        left = P[:, 0] - LW / 2 - LABEL_PAD_PX
        top = P[:, 1] + R + LABEL_GAP_PX - LABEL_PAD_PX
        return left, top, left + LW + 2 * LABEL_PAD_PX, top + LH + 2 * LABEL_PAD_PX

    F = np.zeros((n, 2), dtype=np.float64)
    if n == 0:
        return F

    DX = P[:, 0][:, None] - P[:, 0][None, :]
    DY = P[:, 1][:, None] - P[:, 1][None, :]
    D2 = DX * DX + DY * DY
    D = np.sqrt(np.maximum(D2, 1e-12))
    # break exact coincidences deterministically before using D as a
    # divisor (only matters where D is ~0)
    coincide = (D < 1e-6) & off_diag
    DX = np.where(coincide, tie_dx[:, None] - tie_dx[None, :], DX)
    DY = np.where(coincide, tie_dy[:, None] - tie_dy[None, :], DY)
    D2 = np.where(coincide, DX * DX + DY * DY, D2)
    D = np.sqrt(np.maximum(D2, 1e-12))

    # node-disc <-> node-disc repulsion
    minsep = R[:, None] + R[None, :] + 10.0
    active = off_diag & (D < minsep)
    overlap = np.where(active, minsep - D, 0.0)
    mag = overlap * _REPEL_K / (D2 + 1.0)
    F[:, 0] += np.sum(np.where(active, DX / D * mag, 0.0), axis=1)
    F[:, 1] += np.sum(np.where(active, DY / D * mag, 0.0), axis=1)

    # label-rect <-> label-rect repulsion (rigid south-anchored boxes)
    l, t, r, b = label_boxes(P)
    ox = np.minimum(r[:, None], r[None, :]) - np.maximum(l[:, None], l[None, :])
    oy = np.minimum(b[:, None], b[None, :]) - np.maximum(t[:, None], t[None, :])
    lactive = off_diag & (ox > 0) & (oy > 0)
    acx, acy = (l + r) / 2, (t + b) / 2
    x_wins = ox < oy
    pushx = np.where(x_wins, np.where(acx[:, None] <= acx[None, :], ox, -ox), 0.0)
    pushy = np.where(~x_wins, np.where(acy[:, None] <= acy[None, :], oy, -oy), 0.0)
    k = _LABEL_REPEL_K * 0.001
    F[:, 0] += np.sum(np.where(lactive, pushx * k, 0.0), axis=1)
    F[:, 1] += np.sum(np.where(lactive, pushy * k, 0.0), axis=1)

    # label-rect(a) <-> node-disc(b) repulsion: nearest point on a's
    # label box to node b's center
    nx = np.minimum(np.maximum(P[:, 0][None, :], l[:, None]), r[:, None])
    ny = np.minimum(np.maximum(P[:, 1][None, :], t[:, None]), b[:, None])
    ndx = P[:, 0][None, :] - nx
    ndy = P[:, 1][None, :] - ny
    nd = np.sqrt(np.maximum(ndx * ndx + ndy * ndy, 1e-12))
    nactive = off_diag & (nd < R[None, :])
    noverlap = np.where(nactive, R[None, :] - nd, 0.0)
    nmag = noverlap * k
    # a's label pushed away from b (row a, col b) -> subtract from a
    F[:, 0] -= np.sum(np.where(nactive, ndx / nd * nmag, 0.0), axis=1)
    F[:, 1] -= np.sum(np.where(nactive, ndy / nd * nmag, 0.0), axis=1)
    # and b pushed away symmetrically (col-sum onto b == row-sum of transpose)
    F[:, 0] += np.sum(np.where(nactive, ndx / nd * nmag, 0.0), axis=0)
    F[:, 1] += np.sum(np.where(nactive, ndy / nd * nmag, 0.0), axis=0)

    # prereq-edge springs
    if len(ei):
        edx = P[ej, 0] - P[ei, 0]
        edy = P[ej, 1] - P[ei, 1]
        ed = np.sqrt(np.maximum(edx * edx + edy * edy, 1e-12))
        stretch = ed - _EDGE_LEN_PX
        efx = edx / ed * stretch * _SPRING_K
        efy = edy / ed * stretch * _SPRING_K
        np.add.at(F[:, 0], ei, efx); np.add.at(F[:, 1], ei, efy)
        np.add.at(F[:, 0], ej, -efx); np.add.at(F[:, 1], ej, -efy)

    # node <-> non-incident-edge repulsion: nearest point on every
    # prereq edge the node is not an endpoint of, pushed apart if
    # within range (same clamped-projection shape as segment-distance
    # tests elsewhere in the file).
    if len(ei):
        ex1, ey1 = P[ei, 0], P[ei, 1]
        vx, vy = P[ej, 0] - ex1, P[ej, 1] - ey1
        vv = np.maximum(vx * vx + vy * vy, 1e-9)
        wx = P[:, 0][:, None] - ex1[None, :]
        wy = P[:, 1][:, None] - ey1[None, :]
        t = np.clip((wx * vx[None, :] + wy * vy[None, :]) / vv[None, :], 0.0, 1.0)
        qx = ex1[None, :] + t * vx[None, :]
        qy = ey1[None, :] + t * vy[None, :]
        dex, dey = P[:, 0][:, None] - qx, P[:, 1][:, None] - qy
        de = np.sqrt(np.maximum(dex * dex + dey * dey, 1e-12))
        incident = (sysd["node_ix"][:, None] == ei[None, :]) | (sysd["node_ix"][:, None] == ej[None, :])
        eactive = (~incident) & (de < _EDGE_REPEL_R_PX)
        eover = np.where(eactive, _EDGE_REPEL_R_PX - de, 0.0)
        emag = eover * _EDGE_REPEL_K / (de * de + 1.0)
        pushx = np.where(eactive, dex / de * emag, 0.0)
        pushy = np.where(eactive, dey / de * emag, 0.0)
        F[:, 0] += np.sum(pushx, axis=1)
        F[:, 1] += np.sum(pushy, axis=1)
        # Newton's third law: the edge's endpoints get an equal and
        # opposite nudge away from the node, split by the projection
        # weight (closer endpoint absorbs more of the reaction).
        np.add.at(F[:, 0], ei, -np.sum(pushx * (1 - t), axis=0))
        np.add.at(F[:, 1], ei, -np.sum(pushy * (1 - t), axis=0))
        np.add.at(F[:, 0], ej, -np.sum(pushx * t, axis=0))
        np.add.at(F[:, 1], ej, -np.sum(pushy * t, axis=0))

    # explicit uncrossing pass: every non-adjacent edge pair tested for
    # a literal segment intersection (orientation/cross-product test,
    # exact -- not a distance proxy); crossing pairs get a corrective
    # displacement pulling their midpoints apart, so the pair actually
    # un-crosses rather than merely thinning.
    if len(pair_a):
        a1x, a1y = P[ei[pair_a], 0], P[ei[pair_a], 1]
        a2x, a2y = P[ej[pair_a], 0], P[ej[pair_a], 1]
        b1x, b1y = P[ei[pair_b], 0], P[ei[pair_b], 1]
        b2x, b2y = P[ej[pair_b], 0], P[ej[pair_b], 1]

        def _xprod(ox, oy, ax, ay, bx, by):
            return (ax - ox) * (by - oy) - (ay - oy) * (bx - ox)

        d1 = _xprod(b1x, b1y, b2x, b2y, a1x, a1y)
        d2 = _xprod(b1x, b1y, b2x, b2y, a2x, a2y)
        d3 = _xprod(a1x, a1y, a2x, a2y, b1x, b1y)
        d4 = _xprod(a1x, a1y, a2x, a2y, b2x, b2y)
        crossed = (d1 * d2 < 0) & (d3 * d4 < 0)
        if np.any(crossed):
            max_ax, may = (a1x + a2x) / 2, (a1y + a2y) / 2
            mbx, mby = (b1x + b2x) / 2, (b1y + b2y) / 2
            cdx, cdy = max_ax - mbx, may - mby
            cd = np.sqrt(np.maximum(cdx * cdx + cdy * cdy, 1e-12))
            cix = np.where(crossed, cdx / cd * _CROSS_K, 0.0)
            ciy = np.where(crossed, cdy / cd * _CROSS_K, 0.0)
            np.add.at(F[:, 0], ei[pair_a], cix); np.add.at(F[:, 1], ei[pair_a], ciy)
            np.add.at(F[:, 0], ej[pair_a], cix); np.add.at(F[:, 1], ej[pair_a], ciy)
            np.add.at(F[:, 0], ei[pair_b], -cix); np.add.at(F[:, 1], ei[pair_b], -ciy)
            np.add.at(F[:, 0], ej[pair_b], -cix); np.add.at(F[:, 1], ej[pair_b], -ciy)

    # weak region-sector angular affinity: territory, not a hard ring
    rdx, rdy = P[:, 0] - cx, P[:, 1] - cy
    rr = np.sqrt(np.maximum(rdx * rdx + rdy * rdy, 1e-12))
    ang = np.arctan2(rdy, rdx)
    diff = (ang - region_angle + math.pi) % (2 * math.pi) - math.pi
    tx, ty = -rdy / rr, rdx / rr
    rk = -diff * _REGION_K * rr
    F[:, 0] += tx * rk
    F[:, 1] += ty * rk

    # ellipse bounds containment (soft force; _hard_contain backs it with
    # an unconditional projection every step, same as relax())
    edx2, edy2 = (P[:, 0] - cx) / bx, (P[:, 1] - cy) / by
    e = edx2 * edx2 + edy2 * edy2
    outside = e > 1.0
    over = np.where(outside, np.sqrt(np.maximum(e, 1e-12)) - 1.0, 0.0)
    dd = np.sqrt(np.maximum((P[:, 0] - cx) ** 2 + (P[:, 1] - cy) ** 2, 1e-12))
    F[:, 0] -= np.where(outside, (P[:, 0] - cx) / dd * over * _BOUNDS_K, 0.0)
    F[:, 1] -= np.where(outside, (P[:, 1] - cy) / dd * over * _BOUNDS_K, 0.0)
    return F


# ---------------------------------------------------------------------------
# live selection-pin stepping (director-directed: "the currently selected
# one got yanked to the center and then drifted back to wherever it
# naturally wants to be when released"). An ONLINE, frame-by-frame twin of
# relax()'s force field -- SAME physics (_force_step) drives every tick, so
# the deformation shape while pinned is the graph's real force response,
# not a hand-tuned approximation of it.
#
# _force_step alone is NOT enough to tick forever, though: measured directly,
# the graph's own converged rest layout (`layout()`) sits at a point where
# _force_step's residual magnitude is large (tens to ~125px-equivalent per
# node) -- relax()'s batch schedule never drives that residual to zero, it
# just cools the PER-ITERATION STEP CAP to near-zero over a fixed 220-step
# budget and stops, which reads as "settled" but is not a literal force
# equilibrium. Ticking `_force_step` alone indefinitely (as an early version
# of this function did) therefore does not hold still at rest, and released
# nodes measurably do not return to `layout()` -- confirmed by direct
# measurement, not assumed. The fix is a second spring EVERY node carries
# permanently: a weak pull back toward its OWN `layout()` position
# (`REST_SPRING_K`). That gives the field a real, checked attractor at
# `layout()` (idle drift measured and pinned to a few px, not creeping) --
# the anchor is what makes "drifts back to wherever it naturally wants to
# be" a guarantee rather than a hope. The selected node's anchor target is
# swapped for the view center at a much stronger stiffness (`PIN_SPRING_K`);
# dropping the pin (`pin=None`) simply restores its normal rest anchor, so
# release is not a special case -- it is just every node (now including the
# formerly-pinned one) relaxing toward its own `layout()` spot at once.
#
# The per-tick step is still capped at a small CONSTANT `temp_px` (not a
# decaying schedule -- there is no "end" to a page that stays open): capped
# gradient descent has no velocity state, so there is nothing TO oscillate,
# which is what gives the motion its critically-damped feel. Deterministic:
# a pure function of (pos, graph, pin) -- no wall-clock; the caller (the UI)
# controls ticking, at a fixed sim rate, so the trajectory is identical on
# every machine for the same input sequence.
# ---------------------------------------------------------------------------

_LIVE_TEMP_PX = 2.4           # per-tick step cap: calm, not a jump-cut
REST_SPRING_K = 2.5           # every node's permanent pull toward its own
                              # layout() position -- measured: with this
                              # stiffness idle drift from rest settles at
                              # ~4.9px and STOPS (not a slow creep), and a
                              # released node's worst-case (33-node sweep)
                              # residual offset from layout() settles at
                              # the same ~4.9px -- a real, checked floor.
PIN_SPRING_K = 6.0            # the selected node's replacement anchor
                              # stiffness while pinned -- measured: pulls
                              # the worst-case (33-node sweep) node to
                              # within ~76px of center (mean ~36px) and
                              # holds there (not still creeping), against
                              # a mean rest-to-center distance of ~99px.

_REST_CACHE: dict[int, dict[str, tuple[float, float]]] = {}


def _cached_rest(tbl: dict[str, dict]) -> dict[str, tuple[float, float]]:
    """The rest layout to anchor toward, memoized by graph identity (like
    `_cached_system`) -- `layout()` itself for the real graph (already
    memoized there), a fresh `relax()` from `seed_layout()` for any other
    graph (e.g. a test's synthetic one)."""
    if tbl is nodes():
        return layout()
    key = id(tbl)
    rest = _REST_CACHE.get(key)
    if rest is None:
        rest, _ = relax(seed_layout(tbl), tbl)
        _REST_CACHE[key] = rest
    return rest


def live_relax_step(pos: dict[str, tuple[float, float]],
                     graph: dict[str, dict] | None = None,
                     pin: str | None = None,
                     pin_strength: float = PIN_SPRING_K,
                     rest_strength: float = REST_SPRING_K,
                     temp_px: float = _LIVE_TEMP_PX,
                     ) -> dict[str, tuple[float, float]]:
    """One tick of the online relaxation, starting from `pos` (unit space,
    need not be a rest layout -- e.g. mid-yank or mid-drift-back). Every
    node feels the live graph force field (`_force_step`) PLUS a weak
    spring back to its own `layout()` position; if `pin` names a node,
    THAT node's spring targets the view center instead, at a much higher
    stiffness, so it visibly pulls in while its neighborhood deforms
    naturally around it (driven by the same graph forces as everyone
    else). `pin=None` simply removes the override -- the formerly-pinned
    node's spring reverts to its own rest position like every other node's
    already is, so "drift back" is not a special code path. Missing nodes
    in `pos` (e.g. a node not yet visible) fall back to their rest
    position as the tick's starting point, so callers can pass a partial
    dict."""
    import numpy as np

    tbl = graph if graph is not None else nodes()
    sysd = _cached_system(tbl)
    ids = sysd["ids"]
    if not ids:
        return {}
    rest = _cached_rest(tbl)
    restP = np.array([_to_px(rest[nid]) for nid in ids], dtype=np.float64)
    P = np.array([_to_px(pos[nid]) if nid in pos else restP[i]
                  for i, nid in enumerate(ids)], dtype=np.float64)

    F_graph = _force_step(P, sysd)
    F = F_graph + (restP - P) * rest_strength
    if pin is not None and pin in sysd["idx"]:
        i = sysd["idx"][pin]
        F[i, 0] = F_graph[i, 0] + (sysd["cx"] - P[i, 0]) * pin_strength
        F[i, 1] = F_graph[i, 1] + (sysd["cy"] - P[i, 1]) * pin_strength

    mag = np.sqrt(np.maximum(F[:, 0] ** 2 + F[:, 1] ** 2, 1e-18))
    scale = np.minimum(mag, temp_px) / mag
    P = P + F * scale[:, None]
    _hard_contain(P, sysd)

    return {nid: tuple(_to_unit((P[i, 0], P[i, 1]))) for i, nid in enumerate(ids)}


def relax(seed: dict[str, tuple[float, float]],
          graph: dict[str, dict] | None = None,
          iters: int = RELAX_ITERS,
          record_every: int = 0,
          ) -> tuple[dict[str, tuple[float, float]], list[dict[str, tuple[float, float]]]]:
    """Force-directed relaxation from `seed` (unit space) to a converged
    rest layout, over a FIXED iteration schedule (deterministic: same
    input -> bit-identical output on every machine). Forces: node-disc
    repulsion, node-label and label-label rectangle repulsion (labels are
    the real occluders), prereq-edge springs, a weak region-sector
    angular affinity (territory reads without hard-ringing nodes), and
    ellipse bounds containment.

    Returns (final_positions, trajectory). trajectory is empty unless
    record_every > 0, in which case it contains the seed, every
    `record_every`-th iteration, and always the final frame -- the exact
    path the UI can play back to animate the settle (Task B)."""
    import numpy as np

    tbl = graph if graph is not None else nodes()
    sysd = _build_system(tbl)
    ids, idx, n = sysd["ids"], sysd["idx"], sysd["n"]

    P = np.array([_to_px(seed[nid]) for nid in ids], dtype=np.float64)
    P0 = P.copy()   # the seed, in px -- the crossing-count floor the
                     # uncrossing-polish fallback below is allowed to fall
                     # back to; it always exists and is always at least as
                     # good as itself, so it is the guaranteed worst case.
    ei, ej = sysd["ei"], sysd["ej"]
    pair_a, pair_b = sysd["pair_a"], sysd["pair_b"]

    def crossings_of(P) -> int:
        """Exact crossing count at P (px space), vectorized over the same
        non-adjacent edge pairs the uncrossing force uses -- the numpy
        twin of count_crossings(), used internally every iteration/polish
        step, so it must be cheap (no dict/id round-trip)."""
        if not len(pair_a):
            return 0
        a1x, a1y = P[ei[pair_a], 0], P[ei[pair_a], 1]
        a2x, a2y = P[ej[pair_a], 0], P[ej[pair_a], 1]
        b1x, b1y = P[ei[pair_b], 0], P[ei[pair_b], 1]
        b2x, b2y = P[ej[pair_b], 0], P[ej[pair_b], 1]

        def xprod(ox, oy, ax, ay, bx, by):
            return (ax - ox) * (by - oy) - (ay - oy) * (bx - ox)

        d1 = xprod(b1x, b1y, b2x, b2y, a1x, a1y)
        d2 = xprod(b1x, b1y, b2x, b2y, a2x, a2y)
        d3 = xprod(a1x, a1y, a2x, a2y, b1x, b1y)
        d4 = xprod(a1x, a1y, a2x, a2y, b2x, b2y)
        return int(np.count_nonzero((d1 * d2 < 0) & (d3 * d4 < 0)))

    R, LW, LH = sysd["R"], sysd["LW"], sysd["LH"]
    region_angle = sysd["region_angle"]
    tie_dx, tie_dy = sysd["tie_dx"], sysd["tie_dy"]
    off_diag = sysd["off_diag"]
    node_ix = sysd["node_ix"]
    cx, cy, bx, by = sysd["cx"], sysd["cy"], sysd["bx"], sysd["by"]

    def step_once(P):
        return _force_step(P, sysd)

    def to_frame(P):
        return {nid: tuple(_to_unit((P[i, 0], P[i, 1]))) for i, nid in enumerate(ids)}

    traj: list[dict[str, tuple[float, float]]] = []
    if record_every > 0:
        traj.append(to_frame(P))

    for it in range(iters):
        F = step_once(P)
        cool = 1.0 - it / max(1, iters - 1)
        temp = _TEMP_MIN_PX + (_TEMP0_PX - _TEMP_MIN_PX) * cool
        mag = np.sqrt(np.maximum(F[:, 0] ** 2 + F[:, 1] ** 2, 1e-18))
        scale = np.minimum(mag, temp) / mag
        P = P + F * scale[:, None]

        # hard containment: the soft bounds FORCE above is what gives the
        # settle its shape, but under extreme density (many same-region
        # nodes, no springs to pull them back) the temperature-capped step
        # can outrun a purely force-based push-back within the fixed
        # iteration budget. Project anything still outside the ellipse
        # straight onto its boundary every iteration so containment holds
        # unconditionally, not just "usually" -- the PBT bounds property
        # must be strict, so the mechanism backing it must be too.
        if n:
            edx3, edy3 = (P[:, 0] - cx) / bx, (P[:, 1] - cy) / by
            e2 = edx3 * edx3 + edy3 * edy3
            over_e = e2 > 1.0
            if np.any(over_e):
                shrink = np.where(over_e, 1.0 / np.sqrt(np.maximum(e2, 1e-12)), 1.0)
                P[:, 0] = cx + (P[:, 0] - cx) * shrink
                P[:, 1] = cy + (P[:, 1] - cy) * shrink

        if record_every > 0 and ((it + 1) % record_every == 0 or it == iters - 1):
            traj.append(to_frame(P))

    # uncrossing-polish closer: the two crossing-reduction terms above run
    # the WHOLE relaxation and clear the overwhelming majority of tangles
    # (proven by the PBT below), but they are one heuristic term inside a
    # multi-force settle -- nothing stops a spring or a region pull from
    # re-crossing a pair the uncrossing force had already separated. Rather
    # than hope the fixed schedule always lands in the graph's favor, close
    # the gap the same way label_layout closes its own occlusion guarantee
    # (escalate through cheaper mechanisms, but END on something checked,
    # never an unchecked claim): if the settled layout has MORE crossings
    # than the seed it started from, run a small fixed extra budget of
    # uncrossing-only micro-steps (node-disc repulsion + the crossing
    # force + bounds, no springs/region -- an isolated local search that
    # cannot re-introduce the tangle those forces caused), keep the best
    # (fewest-crossings, ties toward the latest) position seen across it,
    # and if that still isn't at or below the seed's count, fall back to
    # the seed itself -- crossings(seed) <= crossings(seed) always holds,
    # so the property below is true by construction, not by luck.
    crossings_seed = crossings_of(P0)
    crossings_now = crossings_of(P)
    if crossings_now > crossings_seed:
        def polish_step(P):
            F = np.zeros((n, 2), dtype=np.float64)
            DX = P[:, 0][:, None] - P[:, 0][None, :]
            DY = P[:, 1][:, None] - P[:, 1][None, :]
            D2 = DX * DX + DY * DY
            D = np.sqrt(np.maximum(D2, 1e-12))
            coincide = (D < 1e-6) & off_diag
            DX = np.where(coincide, tie_dx[:, None] - tie_dx[None, :], DX)
            DY = np.where(coincide, tie_dy[:, None] - tie_dy[None, :], DY)
            D2 = np.where(coincide, DX * DX + DY * DY, D2)
            D = np.sqrt(np.maximum(D2, 1e-12))
            minsep = R[:, None] + R[None, :] + 10.0
            active = off_diag & (D < minsep)
            overlap = np.where(active, minsep - D, 0.0)
            mag = overlap * _REPEL_K / (D2 + 1.0)
            F[:, 0] += np.sum(np.where(active, DX / D * mag, 0.0), axis=1)
            F[:, 1] += np.sum(np.where(active, DY / D * mag, 0.0), axis=1)
            if len(pair_a):
                a1x, a1y = P[ei[pair_a], 0], P[ei[pair_a], 1]
                a2x, a2y = P[ej[pair_a], 0], P[ej[pair_a], 1]
                b1x, b1y = P[ei[pair_b], 0], P[ei[pair_b], 1]
                b2x, b2y = P[ej[pair_b], 0], P[ej[pair_b], 1]

                def xprod(ox, oy, ax, ay, bx, by):
                    return (ax - ox) * (by - oy) - (ay - oy) * (bx - ox)

                d1 = xprod(b1x, b1y, b2x, b2y, a1x, a1y)
                d2 = xprod(b1x, b1y, b2x, b2y, a2x, a2y)
                d3 = xprod(a1x, a1y, a2x, a2y, b1x, b1y)
                d4 = xprod(a1x, a1y, a2x, a2y, b2x, b2y)
                crossed = (d1 * d2 < 0) & (d3 * d4 < 0)
                if np.any(crossed):
                    max_, may = (a1x + a2x) / 2, (a1y + a2y) / 2
                    mbx, mby = (b1x + b2x) / 2, (b1y + b2y) / 2
                    cdx, cdy = max_ - mbx, may - mby
                    cd = np.sqrt(np.maximum(cdx * cdx + cdy * cdy, 1e-12))
                    cix = np.where(crossed, cdx / cd * _CROSS_K, 0.0)
                    ciy = np.where(crossed, cdy / cd * _CROSS_K, 0.0)
                    np.add.at(F[:, 0], ei[pair_a], cix); np.add.at(F[:, 1], ei[pair_a], ciy)
                    np.add.at(F[:, 0], ej[pair_a], cix); np.add.at(F[:, 1], ej[pair_a], ciy)
                    np.add.at(F[:, 0], ei[pair_b], -cix); np.add.at(F[:, 1], ei[pair_b], -ciy)
                    np.add.at(F[:, 0], ej[pair_b], -cix); np.add.at(F[:, 1], ej[pair_b], -ciy)
            edx2, edy2 = (P[:, 0] - cx) / bx, (P[:, 1] - cy) / by
            e = edx2 * edx2 + edy2 * edy2
            outside = e > 1.0
            over = np.where(outside, np.sqrt(np.maximum(e, 1e-12)) - 1.0, 0.0)
            dd = np.sqrt(np.maximum((P[:, 0] - cx) ** 2 + (P[:, 1] - cy) ** 2, 1e-12))
            F[:, 0] -= np.where(outside, (P[:, 0] - cx) / dd * over * _BOUNDS_K, 0.0)
            F[:, 1] -= np.where(outside, (P[:, 1] - cy) / dd * over * _BOUNDS_K, 0.0)
            return F

        best_P, best_c = P, crossings_now
        for pit in range(_UNCROSS_POLISH_ITERS):
            F = polish_step(P)
            pcool = 1.0 - pit / max(1, _UNCROSS_POLISH_ITERS - 1)
            ptemp = _TEMP_MIN_PX + (_UNCROSS_POLISH_TEMP0 - _TEMP_MIN_PX) * pcool
            pmag = np.sqrt(np.maximum(F[:, 0] ** 2 + F[:, 1] ** 2, 1e-18))
            pscale = np.minimum(pmag, ptemp) / pmag
            P = P + F * pscale[:, None]
            edx3, edy3 = (P[:, 0] - cx) / bx, (P[:, 1] - cy) / by
            e2 = edx3 * edx3 + edy3 * edy3
            over_e = e2 > 1.0
            if np.any(over_e):
                shrink = np.where(over_e, 1.0 / np.sqrt(np.maximum(e2, 1e-12)), 1.0)
                P[:, 0] = cx + (P[:, 0] - cx) * shrink
                P[:, 1] = cy + (P[:, 1] - cy) * shrink
            c = crossings_of(P)
            if c <= best_c:
                best_P, best_c = P.copy(), c
            if record_every > 0:
                traj.append(to_frame(P))
        P = best_P if best_c <= crossings_seed else P0
        if record_every > 0 and to_frame(P) != traj[-1]:
            traj.append(to_frame(P))

    final = to_frame(P)
    if record_every > 0 and (not traj or traj[-1] != final):
        traj.append(final)
    return final, traj


# ---------------------------------------------------------------------------
# label placement: after the graph settles, walk the (path-)relaxed rest
# positions and assign each label a rectangle guaranteed clear of every
# node disc and every other label rectangle. The relaxation above already
# does the heavy lifting; this is the deterministic escalation the
# director asked for when relaxation alone can't fully clear a pathological
# cluster -- a greedy radial search over candidate anchors, then (only if
# that still collides) a shrunk font, in a fixed processing order so the
# result is identical every run.
# ---------------------------------------------------------------------------

_ANCHOR_ANGLES_DEG = [90, 270, 0, 180, 45, 135, 225, 315,
                      67, 112, 22, 157, 202, 337, 247, 292]
_ANCHOR_RADII_PX = [0.0, 4.0, 10.0, 18.0, 28.0, 40.0, 55.0, 75.0, 100.0, 130.0, 180.0]
# the ring search tries these large-to-small; the raster escalation (below)
# additionally has _RASTER_FONT_SCALES beyond this floor for the rare
# pathological graphs (many long identical labels crammed into one region)
# where even a canvas-wide scan needs a smaller footprint to fit at all.
_FONT_SCALES = [1.0, 0.875, 0.75, 0.625, 0.5]  # 16 -> 8px floor
_RASTER_FONT_SCALES = [0.5, 0.375, 0.28125, 0.1875]  # 8 -> 3px last resort
_GOLDEN_ANGLE = math.radians(137.50776405)


def label_layout(positions: dict[str, tuple[float, float]],
                  graph: dict[str, dict] | None = None,
                  ) -> dict[str, dict]:
    """node id -> {"box": (left, top, right, bottom) in canvas px,
    "font_px": int, "leader": bool}. `leader=True` marks a label that had
    to escalate past its default south anchor (podscene draws a thin
    leader tick for those, same grammar as the rite's tendrils/cracks)."""
    tbl = graph if graph is not None else nodes()
    ids = sorted(positions, key=lambda nid: (
        -len(tbl[nid].get("prereqs", [])) if nid in tbl else 0, nid))
    node_px = {nid: _to_px(positions[nid]) for nid in positions}
    rad = {nid: node_radius_px(tbl[nid]) if nid in tbl else NODE_R_PX
           for nid in positions}
    placed: list[tuple[float, float, float, float]] = []
    out: dict[str, dict] = {}
    # a few px of safety margin: the canonical box math assumes an exact
    # 8px/glyph advance, but the actual renderer (podscene) draws at
    # get_font(9)'s native cell and smoothscales non-16px labels down,
    # which can round a pixel or two wider than the canonical box. Margin
    # here keeps that rounding from ever pushing real pixels past the
    # screen edge.
    _EDGE_MARGIN = 4.0
    canvas_rect = (_EDGE_MARGIN, HEADER_MARGIN_PX,
                  CANVAS_W - _EDGE_MARGIN, CANVAS_H - _EDGE_MARGIN)

    def overlaps_any(rect) -> bool:
        l, t, r, b = rect
        if l < canvas_rect[0] or t < canvas_rect[1] or r > canvas_rect[2] or b > canvas_rect[3]:
            return True
        for orect in placed:
            ol, ot, orr, ob = orect
            if l < orr and r > ol and t < ob and b > ot:
                return True
        for onid, (ox, oy) in node_px.items():
            orr = rad[onid]
            nx = min(max(ox, l), r)
            ny = min(max(oy, t), b)
            if math.hypot(ox - nx, oy - ny) < orr:
                return True
        return False

    for nid in ids:
        x, y = node_px[nid]
        r = rad[nid]
        label = tbl[nid]["label"] if nid in tbl else nid
        chosen = None
        for scale in _FONT_SCALES:
            w = LABEL_CHAR_W_PX * scale * max(1, len(label))
            h = LABEL_H_PX * scale
            for ri, radius in enumerate(_ANCHOR_RADII_PX):
                angles = [90] if ri == 0 else _ANCHOR_ANGLES_DEG
                for ang_deg in angles:
                    ang = math.radians(ang_deg)
                    gap = LABEL_GAP_PX + radius
                    acx = x + math.cos(ang) * (r + gap)
                    acy = y + math.sin(ang) * (r + gap) + h / 2 * (1 if ang_deg == 90 else 0)
                    left = acx - w / 2 - LABEL_PAD_PX
                    top = acy - h / 2 - LABEL_PAD_PX
                    rect = (left, top, left + w + 2 * LABEL_PAD_PX, top + h + 2 * LABEL_PAD_PX)
                    if not overlaps_any(rect):
                        chosen = (rect, scale, ri > 0)
                        break
                if chosen:
                    break
            if chosen:
                break
        if chosen is None:
            # the ring search (anchored to the node, so it stays legible as
            # a label FOR that node) missed: escalate to a guaranteed raster
            # scan of the whole canvas, deterministic row-major order,
            # nearest-to-node-first, retried at progressively smaller font
            # scales and a progressively finer grid step -- a coarse grid
            # aligned to a single fixed origin can miss real gaps between
            # irregularly-placed obstacles, so the step shrinks with the
            # scale until it either fits or hits the resolution floor. The
            # property this closes is strict -- no occlusion, ever -- so
            # this must always terminate in a real, checked, non-
            # overlapping box, never an unchecked clamp.
            for scale in _RASTER_FONT_SCALES:
                w = LABEL_CHAR_W_PX * scale * max(1, len(label))
                h = LABEL_H_PX * scale
                step_x, step_y = max(1.0, w / 10), max(1.0, h / 4)
                candidates = []
                gx = int(CANVAS_W // step_x) + 1
                gy = int(CANVAS_H // step_y) + 1
                for iy in range(gy):
                    top = iy * step_y
                    if top + h > CANVAS_H:
                        continue
                    for ix in range(gx):
                        left = ix * step_x
                        if left + w > CANVAS_W:
                            continue
                        ccx, ccy = left + w / 2, top + h / 2
                        candidates.append((math.hypot(ccx - x, ccy - y), iy, ix, left, top))
                candidates.sort(key=lambda c: (c[0], c[1], c[2]))
                for _, _, _, left, top in candidates:
                    rect = (left, top, left + w, top + h)
                    if not overlaps_any(rect):
                        chosen = (rect, scale, True)
                        break
                if chosen:
                    break
            if chosen is None:
                # every grid cell at every escalation scale is occupied:
                # truly saturated (more label area than the canvas can
                # hold even at the smallest legible size). Still
                # deterministic, still checked -- report where it failed
                # rather than silently faking a clear box.
                raise RuntimeError(
                    f"label_layout: canvas saturated, no clear box for {nid!r} "
                    f"({len(placed)} labels already placed)")
        rect, scale, leader = chosen
        placed.append(rect)
        out[nid] = {"box": rect, "font_px": max(1, int(round(LABEL_H_PX * scale))),
                    "leader": leader}
    return out
