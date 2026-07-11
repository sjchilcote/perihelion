"""The Mind Map (design doc 9.2): a graph of concepts the Commando has
room in his soul to metabolize. Expansion costs TIME, not components
(SEEDPOD_UI_DESIGN.md, director-directed): at the seed pod you choose ONE
frontier concept to think about; progress accrues in sim ticks during
normal field play (menus never tick), and the node unfolds -- with
a full reveal animation -- when you next open the pod after the thought completes. Every
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

import dataclasses
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


def _ring_radius(d: int, maxd: int) -> float:
    """Unit-space radius of depth `d`'s seed ring, out of `maxd` total
    depth levels (0..maxd) -- the ONE formula `seed_layout()` places every
    node's radius with, so `depth_bands()`/`ring_boundary_radii()` below
    (the annulus containment bands, and the concentric circles podscene
    draws for them) share exactly these numbers with the seed, not an
    independently-derived approximation of them."""
    dm = maxd or 1
    return 0.30 + 0.70 * (d / dm)


def seed_layout(graph: dict[str, dict] | None = None) -> dict[str, tuple[float, float]]:
    """node id -> (x, y) in unit space (roughly -1..1 both axes): the
    fixed initial condition the relaxation starts from. Nodes sit at a
    radius set by prereq depth, in their region's sector, spread evenly
    (id-sorted) within each (region, depth) ring segment."""
    tbl = graph if graph is not None else nodes()
    dep = _depths_of(tbl)
    maxd = max(dep.values()) or 1
    bands = depth_bands(max(dep.values()))
    groups: dict[tuple[str, int], list[str]] = {}
    for nid in sorted(tbl):
        groups.setdefault((tbl[nid]["region"], dep[nid]), []).append(nid)
    pos: dict[str, tuple[float, float]] = {}
    span = math.radians(2 * _SECTOR_HALF_DEG)
    for (region, d_), ids in groups.items():
        base = math.radians(_REGION_ANGLE_DEG.get(region, 0.0))
        lo, hi = bands[d_]
        # radial scatter WITHIN the band (director: nodes are contained in
        # bands, free within them -- not beads locked onto a circle): a
        # deterministic per-node fraction (crc32, like the reveal ornament
        # -- no process-salted hash()) spreads seed radii across the
        # band's interior, clear of both boundaries by BAND_MARGIN_FRAC so
        # the seed already shows the radial variance the rest layout keeps.
        m = (hi - lo) * BAND_MARGIN_FRAC
        for i, nid in enumerate(ids):
            a = base + span * ((i + 1) / (len(ids) + 1) - 0.5)
            f = (zlib.crc32(nid.encode()) % 4096) / 4095.0
            r = (lo + m) + f * ((hi - m) - (lo + m))
            pos[nid] = (r * math.cos(a), r * math.sin(a))
    return pos


# ---------------------------------------------------------------------------
# depth-annulus bands (director's hybridization: "nodes can't cross the
# concentric ring boundaries, so there's still organization and a global
# structure to the map, but the details are allowed to be chaotic"). Each
# depth d owns a radial band, bounded by the midpoints between adjacent
# seed-ring radii -- the SAME `_ring_radius()` seed_layout() places nodes
# at, so the annulus a node is hard-confined to (both relax()'s baked rest
# and the live dynamics) and the concentric circles podscene draws for the
# player are, by construction, the same boundary.
# ---------------------------------------------------------------------------

def depth_bands(maxd: int) -> dict[int, tuple[float, float]]:
    """depth -> (r_lo, r_hi) in unit space, for depth 0..maxd. Depth 0's
    inner bound is 0 (no hole at the map's center); every other band is
    bounded by the midpoint between its own ring radius and its
    neighbors'; the outermost depth's outer bound extends past its own
    ring by the same half-gap as its inner boundary (a symmetric band) --
    the global ellipse bound (`_BOUNDS_R`) is still the real outer
    backstop for it in practice (see `_hard_contain`), since a wide graph's
    outermost half-gap alone can exceed the canvas. `maxd <= 0` (every
    node at depth 0 -- degenerate/synthetic graphs) collapses to a single
    band spanning the whole bounded disc: there is only one depth level,
    so an annulus constraint would be vacuous."""
    if maxd <= 0:
        return {0: (0.0, _BOUNDS_R)}
    step = _ring_radius(1, maxd) - _ring_radius(0, maxd)
    half = step / 2.0
    out: dict[int, tuple[float, float]] = {}
    for d in range(maxd + 1):
        r = _ring_radius(d, maxd)
        lo = 0.0 if d == 0 else r - half
        hi = r + half
        out[d] = (lo, hi)
    return out


def node_bands(graph: dict[str, dict] | None = None) -> dict[str, tuple[float, float]]:
    """node id -> (r_lo, r_hi) in unit space: this node's own depth-
    annulus band, resolved from `depth_bands()` -- exposed for callers
    (the PBT suite, podscene's boundary-circle draw) that need a node's
    band without touching the numpy system arrays."""
    tbl = graph if graph is not None else nodes()
    dep = _depths_of(tbl)
    maxd = max(dep.values()) if dep else 0
    bands = depth_bands(maxd)
    return {nid: bands[dep[nid]] for nid in tbl}


def ring_boundary_radii(maxd: int) -> list[float]:
    """Unit-space radii of the `maxd` interior boundaries between adjacent
    depth bands (depth d | d+1's shared edge), for d in 0..maxd-1 -- what
    podscene draws as the background concentric depth-ring circles.
    Single source of truth with `depth_bands()`: literally each band's own
    `hi`, for every depth except the last (whose `hi` is not shared with a
    deeper band)."""
    if maxd <= 0:
        return []
    bands = depth_bands(maxd)
    return [bands[d][1] for d in range(maxd)]


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
# unit -> canvas-px screen mapping (podscene.PodScene._to_screen reads
# these directly, so layout geometry matches what's drawn). SY/CY are
# chosen so the whole node ellipse (radius _BOUNDS_R) sits between the
# tab-header strip and the detail panel: no node ever renders under
# either piece of chrome even before podscene's clip rect is applied.
SX_FRAC, SY_FRAC = 0.44, 0.32
CX_FRAC, CY_FRAC = 0.5, 0.42

# reserved chrome strip at the top of the canvas (podscene's FABRICATOR/MIND
# tab header + underline lives in canvas y in [10, 30]): label_layout()'s
# canvas bound used to be _EDGE_MARGIN (4px) on every side, which let a
# node's label anchor as high as y=4 -- inside the header's own rows.
# Reserving this margin on the TOP edge only keeps every placed label
# below the header without touching the (already-proven) left/right/bottom
# containment.
HEADER_MARGIN_PX = 34.0
# ...and the BOTTOM: the detail panel (58px band + 18px inset) plus the
# footer help strip own the bottom of the canvas -- labels may never be
# placed under them (podscene additionally clips the whole map draw to
# the same strip, so even mid-glide nothing bleeds onto chrome).
FOOTER_MARGIN_PX = 78.0

NODE_R_PX = 6.0
NODE_R_ROOT_BONUS_PX = 2.0
LABEL_GAP_PX = 6.0          # node rim -> label top, matches podscene's ui(6)
LABEL_CHAR_W_PX = 8.0       # fallback advance for glyphs missing from the
                            # measured metrics table (below) -- deliberately
                            # the widest plausible advance, never a shortfall
LABEL_H_PX = 16.0           # canonical label cell height in canvas px --
                            # IBM Plex Sans Regular at pt 12 renders exactly
                            # this cell (asserted by the metrics generator)
LABEL_PAD_PX = 2.0          # breathing room around label glyph boxes

# the mind map's own typeface (director-directed: Fixedsys Excelsior is
# the terminal/HUD voice and scales badly; the map -- the Commando's inner
# space -- speaks a minimalistic sans-serif instead). Bundled OFL faces in
# assets/fonts/; per-character advances measured once by
# tools/gen_mindmap_font_metrics.py into data/mindmap_font_metrics.json so
# this module's label geometry stays exact AND pygame-free.
LABEL_FONT_PT = 12           # pt size whose pygame cell height == LABEL_H_PX

_FONT_METRICS: dict | None = None


def _font_metrics() -> dict:
    global _FONT_METRICS
    if _FONT_METRICS is None:
        with open(Path(__file__).parent / "data" / "mindmap_font_metrics.json",
                  encoding="utf-8") as f:
            _FONT_METRICS = json.load(f)
    return _FONT_METRICS


def text_width_px(text: str, face: str = "regular") -> float:
    """Exact canvas-px width of `text` at the canonical label size
    (LABEL_H_PX cell): the sum of the measured per-glyph advances.
    Kerning in the real renderer only ever tightens (Plex's pair kerning
    is negative), so this is width-exact-or-conservative, verified against
    real pygame renders by test_podscene.py."""
    adv = _font_metrics()[face]
    return sum(adv.get(ch, LABEL_CHAR_W_PX) for ch in text)


_LABEL_W_SLACK = 1.04  # canonical boxes are 4% wider than the advance sum:
                       # the renderer floors its pt size (podscene.label_pt)
                       # and hinted advances at the floored size can round
                       # a hair wide of the linear scale -- measured worst
                       # case 2.78% across the real map at 1x/2x/3x.

RELAX_ITERS = 220
_REPEL_K = 900.0
_LABEL_REPEL_K = 900.0
_SPRING_K = 0.06
_EDGE_LEN_PX = 56.0         # longer prereq springs = the hub breathes;
                             # 46px packed the owned cluster so tight the
                             # label search exiled half a dozen labels to
                             # long leader lines (measured, first Plex pass)
_REGION_K = 0.020
_BOUNDS_R = 0.985           # unit-space containment radius (ellipse)
_BOUNDS_K = 6.0
BAND_CLAMP_INSET_FRAC = 0.35  # fraction of the shoulder margin the HARD
                              # clamp itself is inset from the boundary:
                              # the projection target is strictly inside
                              # the band, so no rest position can ever sit
                              # exactly ON a drawn boundary circle (the
                              # bead-necklace read) -- the containment
                              # guarantee (within [lo, hi]) only tightens.
BAND_MARGIN_FRAC = 0.20      # fraction of a band's radial width treated as
                              # a soft shoulder at EACH boundary: the soft
                              # band force below engages inside this margin
                              # (not only past the boundary), so nodes at
                              # rest sit visibly WITHIN their band instead
                              # of riding the drawn boundary circle pinned
                              # by the hard clamp (measured before this
                              # existed: 12 of the real map's 33 nodes
                              # rested at EXACTLY r == lo or r == hi -- the
                              # "bead necklace" the director rejected).
_BAND_K = 12.0               # depth-annulus soft restoring force stiffness
                              # (see _force_step) -- stronger than _BOUNDS_K
                              # since the band boundary is now the map's
                              # real organizing constraint (director's
                              # hybridization); the hard clamp in
                              # _hard_contain_bands backs it unconditionally
                              # regardless of this value.
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
_EDGE_REPEL_R_PX = 22.0     # node<->edge influence radius
_EDGE_REPEL_K = 900.0
_CROSS_K = 24.0              # per-iteration midpoint-separation displacement
                             # (raised with the scattered in-band seed: the
                             # seed now starts near-planar, so the settle
                             # must hold that line against the springs --
                             # measured on the real map: 5/400/16 ended the
                             # main schedule at 13-18 crossings and fell
                             # back to the seed (no settle motion at all);
                             # 24/900/22 settles to 5 with a full real
                             # settle. This balance is knife-edged: the
                             # trajectory test (steps[0] != steps[-1])
                             # exists precisely to catch a silent
                             # fall-back-to-seed regression when anything
                             # in the force field is touched)
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
    node labels with (IBM Plex Sans Regular, canonical LABEL_H_PX cell).
    Proportional widths from the measured advance table -- exact, not an
    estimate, and still pygame-free (the measuring happened once, in
    tools/gen_mindmap_font_metrics.py)."""
    return (max(LABEL_CHAR_W_PX, text_width_px(label) * _LABEL_W_SLACK),
            LABEL_H_PX)


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
    # bx0/by0: the SAME per-axis unit-space -> px scale, WITHOUT the
    # _BOUNDS_R shrink -- depth-band radii (0.30..~1.0, see _ring_radius)
    # are authored in raw unit space, so the annulus containment below
    # measures its own ellipse-normalized radius against these, not the
    # canvas-bounds ellipse's already-shrunk axes.
    bx0, by0 = CANVAS_W * SX_FRAC, CANVAS_H * SY_FRAC
    dep = _depths_of(tbl)
    maxd = max(dep.values()) if dep else 0
    bands = depth_bands(maxd)
    band_lo = np.array([bands[dep[nid]][0] for nid in ids], dtype=np.float64)
    band_hi = np.array([bands[dep[nid]][1] for nid in ids], dtype=np.float64)
    band_m = (band_hi - band_lo) * BAND_MARGIN_FRAC
    return dict(ids=ids, idx=idx, n=n, R=R, LW=LW, LH=LH, region_angle=region_angle,
                ei=ei, ej=ej, pair_a=pair_a, pair_b=pair_b, node_ix=node_ix,
                tie_dx=np.cos(tiebreak_ang), tie_dy=np.sin(tiebreak_ang),
                off_diag=off_diag, cx=cx, cy=cy, bx=bx, by=by,
                bx0=bx0, by0=by0, band_lo=band_lo, band_hi=band_hi,
                band_m=band_m)


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


_CONTAIN_TOL = 1e-9  # floating-point slack on the hard ellipse clamp below:
                     # relax()'s OWN soft bounds force settles boundary
                     # nodes to e == 1.0 +/- a couple ULP, not exactly
                     # 1.0 -- discovered live: a few real-map nodes sit at
                     # e ~= 1.0000000000000002 at rest, which without this
                     # tolerance re-triggers the clamp EVERY tick forever
                     # (a genuine no-op position-wise, but it silently
                     # discards that tick's convergence progress at those
                     # nodes, which pins their whole neighborhood's force a
                     # few px above zero indefinitely -- confirmed by
                     # measurement: removing the hard-contain call let the
                     # same live physics decay to ~1e-12; adding it back
                     # reproduced a permanent ~5.8 force floor). A real
                     # bounds violation is orders of magnitude bigger than
                     # this tolerance, so it changes nothing about the
                     # containment guarantee itself.


_BAND_CONTAIN_TOL = 1e-9   # same role/reason as _CONTAIN_TOL above, for the
                           # per-node depth-annulus clamp: the band's OWN
                           # soft restoring force (see _force_step) settles
                           # a boundary-riding node to r == lo/hi +/- a
                           # couple ULP, not exactly -- zero tolerance here
                           # would re-trigger the clamp forever, the same
                           # never-sleeps bug class _CONTAIN_TOL's comment
                           # documents for the outer ellipse bound.


def _hard_contain_bands(P, sysd) -> None:
    """Project any node whose radial position falls outside its OWN
    depth's annulus band straight onto the nearest band edge, along the
    ellipse-normalized radial direction the band was defined in -- in
    place. The director's hybridization: nodes may never cross their own
    ring boundary, in either the baked rest layout or the live dynamics
    (both call this, via _hard_contain, below)."""
    import numpy as np
    cx, cy = sysd["cx"], sysd["cy"]
    bx0, by0 = sysd["bx0"], sysd["by0"]
    inset = sysd["band_m"] * BAND_CLAMP_INSET_FRAC
    lo = sysd["band_lo"] + inset
    hi = sysd["band_hi"] - inset
    dxn, dyn = (P[:, 0] - cx) / bx0, (P[:, 1] - cy) / by0
    r = np.sqrt(dxn * dxn + dyn * dyn)
    tie = r < 1e-9
    ux = np.where(tie, sysd["tie_dx"], dxn / np.maximum(r, 1e-12))
    uy = np.where(tie, sysd["tie_dy"], dyn / np.maximum(r, 1e-12))
    too_far_in = r < lo - _BAND_CONTAIN_TOL
    too_far_out = r > hi + _BAND_CONTAIN_TOL
    need = too_far_in | too_far_out
    if np.any(need):
        target = np.where(too_far_in, lo, np.where(too_far_out, hi, r))
        P[:, 0] = np.where(need, cx + ux * target * bx0, P[:, 0])
        P[:, 1] = np.where(need, cy + uy * target * by0, P[:, 1])


def _hard_contain(P, sysd) -> None:
    """Project any point still outside its own depth-band annulus AND/OR
    the canvas ellipse bounds straight onto the boundary -- in place.
    Shared by relax()'s per-iteration hard containment and
    live_relax_step() (containment must hold unconditionally for both,
    not just "usually"). Band clamp first, ellipse clamp second: the
    outermost depth's band `hi` deliberately extends past the canvas
    ellipse (see depth_bands()'s docstring), so the ellipse is what
    actually binds there -- applying it after the band clamp never fights
    it, it just tightens the outermost ring the rest of the way."""
    import numpy as np
    _hard_contain_bands(P, sysd)
    cx, cy, bx, by = sysd["cx"], sysd["cy"], sysd["bx"], sysd["by"]
    edx, edy = (P[:, 0] - cx) / bx, (P[:, 1] - cy) / by
    e = edx * edx + edy * edy
    over = e > 1.0 + _CONTAIN_TOL
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
    bx0, by0 = sysd["bx0"], sysd["by0"]
    band_lo, band_hi = sysd["band_lo"], sysd["band_hi"]

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

    # label-rect <-> label-rect repulsion (rigid south-anchored boxes).
    # Pushed along the line connecting box CENTERS (a central force),
    # not along whichever axis currently has less overlap. The axis-pick
    # ("push along x if ox<oy else y") used to be a hard argmin: as two
    # labels drift, ox and oy cross each other's value constantly, and the
    # push direction snaps between "purely x" and "purely y" every time
    # they do -- a discontinuous, non-central pairwise force. A pairwise
    # force that is equal-and-opposite (this one always was) but NOT
    # central is not conservative, and a non-conservative force can sustain
    # a stable limit cycle forever, no matter how much velocity damping is
    # applied to it -- proven by direct simulation while building the
    # live-relax quiescence mechanism (see live_relax_step): with this
    # exact axis-pick term, a critically-damped second-order integrator's
    # speed floor never dropped below ~1.5-3.7px/s even after 20000 ticks,
    # while every OTHER force term in this function (repulsion, springs,
    # node<->edge, crossings, region, bounds) drove speed to ~1e-12 within
    # a couple thousand. Swapping to a central force (same trigger, same
    # penetration-depth magnitude, direction = center-to-center instead of
    # an axis) is a strict subset of the original's job (still separates
    # overlapping label boxes) and is provably conservative -- the fix is
    # at the force's source, not a symptom patch on the integrator.
    l, t, r, b = label_boxes(P)
    ox = np.minimum(r[:, None], r[None, :]) - np.maximum(l[:, None], l[None, :])
    oy = np.minimum(b[:, None], b[None, :]) - np.maximum(t[:, None], t[None, :])
    lactive = off_diag & (ox > 0) & (oy > 0)
    acx, acy = (l + r) / 2, (t + b) / 2
    cdx, cdy = acx[:, None] - acx[None, :], acy[:, None] - acy[None, :]
    cd = np.sqrt(np.maximum(cdx * cdx + cdy * cdy, 1e-9))
    depth = np.minimum(ox, oy)
    k = _LABEL_REPEL_K * 0.001
    lmag = np.where(lactive, depth * k, 0.0)
    F[:, 0] += np.sum(lmag * cdx / cd, axis=1)
    F[:, 1] += np.sum(lmag * cdy / cd, axis=1)

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

    # depth-annulus band: soft radial restoring force with a SHOULDER --
    # it engages a BAND_MARGIN_FRAC-wide margin INSIDE each boundary (zero
    # only in the band's interior core, so the chaotic tangential motion
    # within the band is undamped by this term). The shoulder is what
    # keeps rest positions visibly inside the band instead of pinned on
    # the drawn boundary circle by the hard clamp (the director's "bands
    # they're contained within but free to move within" -- a node pushed
    # outward by repulsion now settles where repulsion balances the
    # shoulder, strictly inside, rather than grinding on the projection).
    band_m = sysd["band_m"]
    bdx, bdy = (P[:, 0] - cx) / bx0, (P[:, 1] - cy) / by0
    br = np.sqrt(np.maximum(bdx * bdx + bdy * bdy, 1e-12))
    under = np.maximum((band_lo + band_m) - br, 0.0)
    over_b = np.maximum(br - (band_hi - band_m), 0.0)
    ddb = np.sqrt(np.maximum((P[:, 0] - cx) ** 2 + (P[:, 1] - cy) ** 2, 1e-12))
    bpush = (under - over_b) * _BAND_K
    F[:, 0] += (P[:, 0] - cx) / ddb * bpush
    F[:, 1] += (P[:, 1] - cy) / ddb * bpush

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
# live idle stepping (director's hybridization, superseding the earlier
# "yank the selection to center" pin: "let's instead have the camera move
# out to the ring that hosts the selected concept" -- selection now drives
# podscene's CAMERA, never a node's position; see podscene.py's
# camera_glide usage. No node is ever exempt from its own depth-annulus
# band -- there is no pin force left in this field at all). An ONLINE,
# frame-by-frame twin of relax()'s force field -- SAME physics
# (`_force_step`, including the annulus containment) drives every tick, so
# the map's continuous, chaotic-within-bands motion is the graph's real
# force response, not a hand-tuned approximation of it.
#
# TRUE VELOCITY (director-directed follow-up: an earlier first-order,
# capped-step version -- "step = min(|F|, temp_px) toward F" every tick,
# forever -- never actually stopped. Direct measurement while building
# this: even with the cap removed and heavy velocity damping added,
# positions kept moving at a near-constant, non-decaying speed indefinitely
# (still ~1.5-3.7px/s after 20000 ticks). The culprit was NOT "not enough
# damping" -- it was that one force term (the label<->label rectangle push
# in _force_step, now fixed to be a central force, see its comment) was
# NON-CONSERVATIVE: paired equal-and-opposite but not directed along the
# line between the two labels, which is exactly the condition under which a
# force can sustain a stable limit cycle forever, immune to any amount of
# linear velocity damping. With that term made conservative, this second-
# order integrator (semi-implicit Euler: acceleration = force, damped,
# dt = sim.DT) drives every node's speed to true float-precision zero
# (~1e-12) given enough ticks -- rest is now a real property of the
# physics, not a hoped-for one.
#
# Even so, "real convergence" is asymptotic, not exact-in-finite-time (an
# exponential decay never hits literal 0.0 by a fixed tick count) -- and the
# PBT law here is EXACT bitwise rest, not "very small". So the physics is
# backed by an explicit sleep latch: once both max speed and max applied
# force stay under a tiny threshold for `_SLEEP_K_CONSEC` consecutive ticks,
# velocities snap to exactly (0, 0) and the tick becomes a no-op -- positions
# are the same dict, unchanged, forever, until something perturbs the force
# field enough to cross the wake threshold again (the caller resetting to a
# fresh `live_rest_state()` on page open / node reveal is the only such
# perturbation left now that selection no longer touches the force field).
#
# Every node carries a permanent spring back to its OWN `layout()` position
# (`REST_SPRING_K`) -- `_force_step`'s residual at `layout()` is not exactly
# zero (real graphs don't settle to a literal force-free point in a fixed-
# schedule cooled relaxation), so without an anchor the true equilibrium of
# the live field would drift away from the position the rest of the game
# thinks the graph lives at.
#
# Anisotropic damping (director-directed: "give the vertices a bias towards
# moving along circular paths -- friction applies more strongly in
# directions other than moving along the perimeter"): velocity is resolved
# into a component RADIAL to the view center and a component TANGENTIAL to
# it (the local "along this node's own ring" direction), and each is damped
# by its own coefficient (`LIVE_DAMPING_RADIAL` > `LIVE_DAMPING_TANGENT`).
# A node fighting its way toward/away from center bleeds speed fast; a node
# drifting along its ring bleeds speed slowly -- exactly the "bank-
# switching within limited main memory" feel, and it composes cleanly with
# the annulus containment (the hard radial clamp is what ultimately stops
# radial motion at the boundary; damping alone never needs to).
#
# Deterministic: `live_relax_step` is a pure function of (state, graph) --
# no wall-clock; the caller (the UI) controls ticking, at a fixed sim rate,
# so the trajectory is identical on every machine for the same input
# sequence.
# ---------------------------------------------------------------------------

_LIVE_DT = 1.0 / 60.0   # matches sim.DT -- the fixed sim rate podscene
                        # ticks this stepper at; kept local (not imported
                        # from sim.py) so mindmap.py stays decoupled from
                        # the sim/necore stack.
REST_SPRING_K = 200.0   # every node's permanent pull toward its own
                        # layout() position (px/s^2 per px of offset).
                        # Tuned (with the damping constants below) so a
                        # perturbed node's settle point stays close to the
                        # ORIGINAL layout() (no permanent deformation)
                        # while the field still visibly, chaotically
                        # jitters within its band before sleeping.
LIVE_DAMPING_RADIAL = 50.0    # velocity damping along the radial
                               # direction (toward/away from the view
                               # center) -- px/s^2 per px/s of radial speed.
LIVE_DAMPING_TANGENT = 20.0   # velocity damping along the tangential
                               # (circular/"along the ring") direction --
                               # deliberately weaker than the radial
                               # coefficient: the director's "bias towards
                               # moving along circular paths".
LIVE_DAMPING = LIVE_DAMPING_RADIAL   # back-compat alias: the isotropic
                                      # damping constant this module used
                                      # before the radial/tangential split.
_LIVE_MAX_SPEED_PX = 600.0     # terminal-velocity safety cap (px/s):
                                # guards against a momentary huge force
                                # (near-coincident nodes) without capping
                                # ordinary motion the way the old per-tick
                                # step cap did.
_SLEEP_DISP_EPS_PX = 0.02       # px -- the ACTUAL per-tick displacement
                                 # after integration + hard containment,
                                 # sub-pixel (imperceptible at the canvas
                                 # this all renders at). Deliberately NOT a
                                 # raw-force OR raw-velocity threshold --
                                 # see live_relax_step's docstring for why
                                 # both are the wrong signal (a node
                                 # resting against the hard ellipse
                                 # containment has a permanently nonzero
                                 # pre-clamp force/internal velocity but a
                                 # position that provably never moves
                                 # again).
_SLEEP_SPEED_EPS_PX = 1.5       # px/s of OBSERVED position change
                                 # (disp/dt, see live_relax_step) -- kept
                                 # as a second, independent-units gate on
                                 # the same underlying signal.
_SLEEP_K_CONSEC = 10            # consecutive ticks under both epsilons
                                 # before the system is declared asleep --
                                 # a single lucky tick near a turning point
                                 # of a not-yet-settled trajectory should
                                 # not freeze it.

# Measured settle time (33-node real map, 60Hz ticks): see
# test_live_rest_open_reaches_exact_bitwise_rest for the current measured
# worst case from a fresh live_rest_state() -- there is no pin/release
# trajectory left to measure now that selection doesn't touch the field.
_LIVE_SETTLE_BOUND_TICKS = 600   # generous over the measured worst case,
                                 # not a vacuous ceiling.


@dataclasses.dataclass(frozen=True)
class LiveState:
    """The live stepper's full state: positions (unit space, like every
    other layout dict in this module), per-node velocities (unit space per
    second -- same convention, so a caller never has to know this is a
    second-order system to read `.pos`), and the sleep latch. Immutable:
    `live_relax_step` returns a new `LiveState`, never mutates one, so a
    frozen `LiveState` IS the frozen positions (equality of two `LiveState`s
    with the same `.pos` is exactly the PBT's "bitwise identical" claim)."""
    pos: dict[str, tuple[float, float]]
    vel: dict[str, tuple[float, float]]
    quiet: int = 0
    asleep: bool = False


def live_rest_state(graph: dict[str, dict] | None = None) -> LiveState:
    """The state a page-open (or a settle/reveal finishing and handing the
    floor back) resets to: every node at its own `layout()` position, at
    rest (zero velocity), not yet proven asleep (`quiet=0`) -- the first few
    ticks re-verify quiescence for real rather than assuming the rest
    layout is already a literal fixed point of the live field (it isn't,
    see REST_SPRING_K's comment above)."""
    tbl = graph if graph is not None else nodes()
    rest = _cached_rest(tbl)
    return LiveState(pos=dict(rest), vel={nid: (0.0, 0.0) for nid in rest})


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


def live_relax_step(state: LiveState,
                     graph: dict[str, dict] | None = None,
                     rest_strength: float = REST_SPRING_K,
                     damping_radial: float = LIVE_DAMPING_RADIAL,
                     damping_tangent: float = LIVE_DAMPING_TANGENT,
                     max_speed: float = _LIVE_MAX_SPEED_PX,
                     sleep_speed_eps: float = _SLEEP_SPEED_EPS_PX,
                     sleep_disp_eps: float = _SLEEP_DISP_EPS_PX,
                     sleep_k_consec: int = _SLEEP_K_CONSEC,
                     ) -> LiveState:
    """One tick (dt = sim.DT, fixed 60Hz) of the online, second-order
    relaxation, starting from `state` (need not be at rest). Every node
    feels the live graph force field (`_force_step`, which includes its
    own depth-annulus band containment) PLUS a weak spring back to its own
    `layout()` position -- there is no selection/pin override left in this
    field; selection is expressed purely by podscene's camera. Missing
    nodes in `state.pos`/`state.vel` (e.g. a node not yet visible) fall
    back to rest position / zero velocity, so callers can pass a partial
    state.

    Semi-implicit (symplectic) Euler: acceleration = force (mass = 1),
    ANISOTROPICALLY damped -- velocity is resolved into a component
    radial to the view center and a component tangential to it, each
    damped by its own coefficient (`damping_radial` > `damping_tangent`,
    the director's "bias towards moving along circular paths": friction
    bites harder radially than along a node's own ring) -- velocity
    updated first, then position from the NEW velocity -- unconditionally
    stable for the stiffnesses here at DT = 1/60, and it is what gives the
    motion real inertia (arrives with weight, eases in, does not snap).

    Sleep latch: quiescence is judged by the ACTUAL applied per-node
    displacement this tick (position AFTER integration and hard
    containment, minus position before) and speed, not by raw force.
    Force alone is the wrong signal: a node resting exactly against the
    ellipse's hard containment can have a large, permanently nonzero
    pre-clamp force (the clamp is what's holding it there, the same way a
    ball at rest against a wall has a nonzero contact force) while its
    POSITION never moves again -- checking force there would refuse to
    sleep forever over a node that is, observably, already still (found
    by direct measurement while tuning this: a few real-map nodes sit
    exactly on the containment boundary at `layout()`, and an
    earlier force-gated version of this latch never slept because of
    them). If max displacement AND max speed both stay under their
    epsilons for `sleep_k_consec` consecutive ticks, the system snaps
    velocities to exactly (0, 0) and goes to sleep: `state` is then
    returned completely unchanged tick after tick (bitwise-identical
    positions, discarding whatever infinitesimal candidate move the
    physics would otherwise have made) until something perturbs the field
    past the threshold -- the caller resetting to `live_rest_state()` on
    page open / node reveal."""
    import numpy as np

    tbl = graph if graph is not None else nodes()
    sysd = _cached_system(tbl)
    ids = sysd["ids"]
    if not ids:
        return state
    rest = _cached_rest(tbl)
    restP = np.array([_to_px(rest[nid]) for nid in ids], dtype=np.float64)
    P0 = np.array([_to_px(state.pos[nid]) if nid in state.pos else restP[i]
                   for i, nid in enumerate(ids)], dtype=np.float64)
    sx = CANVAS_W * SX_FRAC
    sy = CANVAS_H * SY_FRAC
    V = np.array([(state.vel[nid][0] * sx, state.vel[nid][1] * sy)
                  if nid in state.vel else (0.0, 0.0) for nid in ids],
                 dtype=np.float64)

    F = _force_step(P0, sysd) + (restP - P0) * rest_strength

    # anisotropic damping: resolve V into radial (toward/away from the
    # view center) and tangential (along this node's own ring) unit
    # components and damp each independently. A node sitting exactly at
    # the center has no well-defined radial direction -- fall back to the
    # same deterministic per-node tiebreak angle _force_step's coincidence
    # handling uses, so this stays a pure function with no discontinuity
    # at r == 0.
    cx, cy = sysd["cx"], sysd["cy"]
    rx, ry = P0[:, 0] - cx, P0[:, 1] - cy
    rn = np.sqrt(rx * rx + ry * ry)
    tie = rn < 1e-9
    urx = np.where(tie, sysd["tie_dx"], rx / np.maximum(rn, 1e-12))
    ury = np.where(tie, sysd["tie_dy"], ry / np.maximum(rn, 1e-12))
    utx, uty = -ury, urx
    v_rad = V[:, 0] * urx + V[:, 1] * ury
    v_tan = V[:, 0] * utx + V[:, 1] * uty
    damp_x = damping_radial * v_rad * urx + damping_tangent * v_tan * utx
    damp_y = damping_radial * v_rad * ury + damping_tangent * v_tan * uty

    A = np.empty_like(F)
    A[:, 0] = F[:, 0] - damp_x
    A[:, 1] = F[:, 1] - damp_y
    V = V + A * _LIVE_DT
    raw_speed = np.sqrt(np.maximum(V[:, 0] ** 2 + V[:, 1] ** 2, 1e-24))
    scale = np.minimum(raw_speed, max_speed) / raw_speed
    V = V * scale[:, None]
    P = P0 + V * _LIVE_DT
    _hard_contain(P, sysd)
    disp = np.sqrt(np.sum((P - P0) ** 2, axis=1))
    # "speed" for the sleep decision is the OBSERVED rate of position
    # change (disp / dt), not the raw internal velocity state. The two
    # differ exactly at hard containment: a node resting against the
    # ellipse boundary keeps a permanent nonzero internal V (like a ball's
    # velocity pressed into a wall -- the spring/graph force keeps
    # accelerating it into the constraint every tick), but the constraint
    # eats that velocity before it becomes a real position change. Gating
    # on raw |V| there would refuse to sleep forever over motion nobody
    # can see (measured on the real map: internal speed floors up to
    # ~38px/s at nodes pinned against the boundary, while their actual
    # displacement was already below 1e-9px) -- gating on the OUTPUT speed
    # is what "tiny epsilon" is supposed to mean.
    speed = disp / _LIVE_DT

    quiescent = bool(speed.max() < sleep_speed_eps and disp.max() < sleep_disp_eps)
    if state.asleep and quiescent:
        return state  # still still -- discard this tick's candidate move

    quiet = state.quiet + 1 if quiescent else 0
    asleep = quiet >= sleep_k_consec
    if asleep:
        V = np.zeros_like(V)

    pos_out = {nid: tuple(_to_unit((P[i, 0], P[i, 1]))) for i, nid in enumerate(ids)}
    vel_out = {nid: (V[i, 0] / sx, V[i, 1] / sy) for i, nid in enumerate(ids)}
    return LiveState(pos=pos_out, vel=vel_out, quiet=quiet, asleep=asleep)


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
    bx0, by0 = sysd["bx0"], sysd["by0"]
    band_lo, band_hi = sysd["band_lo"], sysd["band_hi"]

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

        # hard containment: the soft bounds/band FORCEs above are what give
        # the settle its shape, but under extreme density (many same-
        # region nodes, no springs to pull them back) the temperature-
        # capped step can outrun a purely force-based push-back within the
        # fixed iteration budget. Project anything still outside its own
        # depth band or the canvas ellipse straight onto the boundary
        # every iteration so containment holds unconditionally, not just
        # "usually" -- the PBT bounds/band properties must be strict, so
        # the mechanism backing them must be too.
        if n:
            _hard_contain(P, sysd)

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
            # depth-annulus band soft force (same term as _force_step's --
            # the uncrossing polish is an isolated local search, but it
            # must not visibly grind a boundary-riding node against the
            # hard clamp below either)
            bdx, bdy = (P[:, 0] - cx) / bx0, (P[:, 1] - cy) / by0
            br = np.sqrt(np.maximum(bdx * bdx + bdy * bdy, 1e-12))
            band_m = sysd["band_m"]
            under = np.maximum((band_lo + band_m) - br, 0.0)
            over_b = np.maximum(br - (band_hi - band_m), 0.0)
            bpush = (under - over_b) * _BAND_K
            F[:, 0] += (P[:, 0] - cx) / dd * bpush
            F[:, 1] += (P[:, 1] - cy) / dd * bpush
            return F

        best_P, best_c = P, crossings_now
        for pit in range(_UNCROSS_POLISH_ITERS):
            F = polish_step(P)
            pcool = 1.0 - pit / max(1, _UNCROSS_POLISH_ITERS - 1)
            ptemp = _TEMP_MIN_PX + (_UNCROSS_POLISH_TEMP0 - _TEMP_MIN_PX) * pcool
            pmag = np.sqrt(np.maximum(F[:, 0] ** 2 + F[:, 1] ** 2, 1e-18))
            pscale = np.minimum(pmag, ptemp) / pmag
            P = P + F * pscale[:, None]
            _hard_contain(P, sysd)
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
# camera glide (promoted here from mindmap_rings.py, its original home, so
# BOTH mind-map layout variants can share it: podscene's physics mode now
# also expresses selection by gliding the CAMERA to the selected node --
# director's hybridization, superseding the old "yank node to center" pin
# -- rather than writing a second glide function. A pure function of (t,
# t0, dur, endpoints) -- no wall-clock, no pygame -- so both podscene.py
# and the test suites drive the exact same math. Smoothstep easing gives
# the "critically damped" FEEL (ease in, ease out, no ringing) while
# guaranteeing an EXACT finite-time arrival (u clamps to 1.0 and the
# result becomes bitwise `p_to` from then on) -- a literal damped-spring
# ODE integration only approaches its target asymptotically and would
# never satisfy "then bitwise-static frames". mindmap_rings.py re-exports
# this name for backward compatibility.
# ---------------------------------------------------------------------------

def camera_glide(t: float, t0: float, dur: float,
                  p_from: tuple[float, float], p_to: tuple[float, float],
                  ) -> tuple[float, float]:
    if dur <= 0.0 or t >= t0 + dur:
        return p_to
    if t <= t0:
        return p_from
    u = (t - t0) / dur
    u = u * u * (3.0 - 2.0 * u)
    return (p_from[0] + (p_to[0] - p_from[0]) * u,
            p_from[1] + (p_to[1] - p_from[1]) * u)


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

# ---------------------------------------------------------------------------
# region headers: each region names its own compass sector. Placed HERE
# (not ad hoc in podscene) so label_layout can reserve their rectangles --
# region headers are part of the map and node labels must never sit on
# them. The anchor is a unit-space point (so podscene's camera transform
# moves headers rigidly with the nodes -- no screen-space clamping that
# would slide a header over the graph mid-glide), pre-clamped in CANVAS
# space at rest so every header starts inside the safe strip.
# ---------------------------------------------------------------------------

HEADER_CELL_PX = 13.0        # canvas-px cell height for region headers
HEADER_TRACK_PX = 2.0        # extra letterspacing per glyph, canvas px
_HEADER_RADIUS = 1.10        # unit-space anchor radius (outside the node
                             # ellipse; the per-axis clamp below pulls the
                             # N/S headers back inside the safe strip)


def region_header_size_px(label: str) -> tuple[float, float]:
    """(w, h) canvas px of a region header (Medium face, HEADER_CELL_PX
    cell, HEADER_TRACK_PX letterspacing) -- shared by the reservation
    below and podscene's draw so they can never disagree."""
    scale = HEADER_CELL_PX / LABEL_H_PX
    w = text_width_px(label, "medium") * scale
    w += HEADER_TRACK_PX * max(0, len(label) - 1)
    # +6px: a rendered glyph's ink box can overhang its advance by a
    # couple px (side bearings/antialiasing) -- reserve for it so the
    # drawn header never exceeds the rect labels were laid out against
    return (w + 6.0, HEADER_CELL_PX)


def region_header_layout(graph: dict[str, dict] | None = None) -> dict[str, dict]:
    """region -> {"box": (l, t, r, b) canvas px, "center_unit": (x, y),
    "label": str}. Deterministic, pure geometry."""
    tbl = graph if graph is not None else nodes()
    regions = sorted({n["region"] for n in tbl.values()},
                     key=lambda r: (REGION_ORDER.index(r)
                                    if r in REGION_ORDER else 99, r))
    out: dict[str, dict] = {}
    for i, region in enumerate(regions):
        label = REGION_LABELS.get(region, region.upper())
        if region in _REGION_ANGLE_DEG:
            a = math.radians(_REGION_ANGLE_DEG[region])
        else:  # synthetic graphs: spread evenly, deterministically
            a = 2 * math.pi * i / max(1, len(regions)) - math.pi / 2
        w, h = region_header_size_px(label)
        px, py = _to_px((_HEADER_RADIUS * math.cos(a),
                         _HEADER_RADIUS * math.sin(a)))
        # clamp the whole box into the safe strip, in canvas space
        px = min(max(px, 4.0 + w / 2), CANVAS_W - 4.0 - w / 2)
        py = min(max(py, HEADER_MARGIN_PX + 2.0 + h / 2),
                 CANVAS_H - FOOTER_MARGIN_PX - 2.0 - h / 2)
        box = (px - w / 2, py - h / 2, px + w / 2, py + h / 2)
        out[region] = {"box": box, "center_unit": _to_unit((px, py)),
                       "label": label}
    return out


_ANCHOR_ANGLES_DEG = [90, 270, 0, 180, 45, 135, 225, 315,
                      67, 112, 22, 157, 202, 337, 247, 292]
_ANCHOR_RADII_PX = [0.0, 4.0, 10.0, 18.0, 28.0, 40.0, 55.0, 75.0, 100.0,
                    130.0, 180.0, 230.0]
# the ring search tries these large-to-small; the raster escalation (below)
# additionally has _RASTER_FONT_SCALES beyond this floor for the rare
# pathological graphs (many long identical labels crammed into one region)
# where even a canvas-wide scan needs a smaller footprint to fit at all.
_FONT_SCALES = [0.8125, 0.6875, 0.5625, 0.5]  # 13 -> 8px floor: graph labels
                                          # are annotations, not headlines
                                          # -- 13px cells leave the canvas
                                          # ~35% label-covered instead of
                                          # ~50%, which is what lets the
                                          # placement ladder keep labels
                                          # NEXT TO their nodes
_RASTER_FONT_SCALES = [0.5, 0.375, 0.28125, 0.1875]  # 8 -> 3px last resort
_GOLDEN_ANGLE = math.radians(137.50776405)


def label_layout(positions: dict[str, tuple[float, float]],
                  graph: dict[str, dict] | None = None,
                  ) -> dict[str, dict]:
    """node id -> {"box": (left, top, right, bottom) in canvas px,
    "font_px": int, "leader": bool}. `leader=True` marks a label that had
    to escalate past its default south anchor (podscene draws a thin
    leader tick for those, same grammar as the reveal's tendrils/cracks)."""
    tbl = graph if graph is not None else nodes()
    ids = sorted(positions, key=lambda nid: (
        -len(tbl[nid].get("prereqs", [])) if nid in tbl else 0, nid))
    node_px = {nid: _to_px(positions[nid]) for nid in positions}
    rad = {nid: node_radius_px(tbl[nid]) if nid in tbl else NODE_R_PX
           for nid in positions}
    # region headers are part of the map: reserve their rectangles up
    # front so no node label is ever placed over a sector's name.
    placed: list[tuple[float, float, float, float]] = [
        info["box"] for info in region_header_layout(tbl).values()]
    out: dict[str, dict] = {}
    # a few px of safety margin: the canonical box math assumes an exact
    # 8px/glyph advance, but the actual renderer (podscene) draws at
    # get_font(9)'s native cell and smoothscales non-16px labels down,
    # which can round a pixel or two wider than the canonical box. Margin
    # here keeps that rounding from ever pushing real pixels past the
    # screen edge.
    _EDGE_MARGIN = 4.0
    canvas_rect = (_EDGE_MARGIN, HEADER_MARGIN_PX,
                  CANVAS_W - _EDGE_MARGIN, CANVAS_H - FOOTER_MARGIN_PX)

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
        # escalation ladder ordered by a COST over (distance, shrink):
        # a slightly smaller label NEAR its node beats a full-size label
        # exiled half a canvas away (measured on the first Plex render:
        # the old scale-major order sent half a dozen full-size labels
        # 100-180px from their nodes on invisible leader lines -- orphan
        # text is a worse failure than a 12px label). Deterministic: the
        # ladder is a fixed sort of a fixed list.
        ladder = sorted(
            ((radius + (1.0 - scale) * 120.0, ri, si)
             for si, scale in enumerate(_FONT_SCALES)
             for ri, radius in enumerate(_ANCHOR_RADII_PX)),
            key=lambda c: (c[0], c[1], c[2]))
        for _, ri, si in ladder:
            scale = _FONT_SCALES[si]
            radius = _ANCHOR_RADII_PX[ri]
            w = label_size_px(label)[0] * scale
            h = LABEL_H_PX * scale
            angles = [90, 270] if ri == 0 else _ANCHOR_ANGLES_DEG
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
                w = label_size_px(label)[0] * scale
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
