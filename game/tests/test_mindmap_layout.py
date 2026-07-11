"""PBT harness (director-directed, SEEDPOD_UI_DESIGN.md follow-up): PROVES
the mind-map layout laws for generated mind-map-shaped graphs AND the
real data/mindmap.json: determinism (no wall-clock, no unseeded
randomness), canvas/band containment, crossing reduction, and -- under
the round-2 LOCAL CAMERA model -- the label laws that replaced the old
global-canvas ones: within the camera's legibility radius, labels never
overlap and always sit adjacent to their own node; beyond it, nodes are
honest unlabeled points; the selection always has a label.

ROUND-2 ADAPTATION NOTE (each documented where it happens): the old
global label_layout() -- one canvas-wide placement with an escalation
ladder that could exile a label to a leader line -- was DELETED with the
director's clarification ("the dislocated titles can and should thus be
eliminated"), so its PBTs (whole-canvas non-occlusion, canvas bounds on
label boxes, header-rect reservation) went with it: their premise (all
labels visible at once on one static canvas) no longer exists. Their
successors below assert the strictly stronger local law on every placed
box instead.

Run from the repo root (pytest needs the cwd for other suites' fixtures).
"""

from __future__ import annotations

import math
import random

from hypothesis import HealthCheck, given, settings
from hypothesis import strategies as st
import pytest

from perihelion import mindmap
from perihelion.testkit.graphs import synthetic_mindmap

EXAMPLES = 200

# a bounded settings profile: generous per the task brief, but capped so
# the whole module stays well inside CI patience. Layout math is pure
# Python (no I/O, no randomness), so 200 examples/property is seconds,
# not minutes, even with the label raster-scan escalation path included.
settings.register_profile(
    "mindmap_pbt",
    max_examples=EXAMPLES,
    deadline=None,
    suppress_health_check=[HealthCheck.too_slow, HealthCheck.data_too_large],
)
settings.load_profile("mindmap_pbt")


# ---------------------------------------------------------------------------
# strategies: DAGs shaped like real mind maps -- regions, prereq edges
# forming a connected rooted forest-per-region, varying label lengths.
# ---------------------------------------------------------------------------

_WORDS = ["the", "watch", "liturgy", "of", "kernel", "constraint", "organ",
          "harvesting", "adversary", "biology", "survey", "comprehension",
          "spatial", "tools", "fold", "cartography", "resonance", "mapping",
          "testator", "engineering", "connection", "space", "hollow",
          "litany", "arithmetic", "futility", "unit", "remembers", "name",
          "count", "doesnt", "stop", "second", "discarded", "protected",
          "revival", "psalm", "loop", "kin", "just", "war", "a"]

_LONG_LABELS = [
    "comprehension-adversary-biology-survey",
    "the-liturgy-of-the-watch-and-the-hollow-litany-of-the-count",
    "x",
]


def _draw_label(draw):
    if draw(st.integers(0, 9)) == 0:  # ~10% long/degenerate labels
        return draw(st.sampled_from(_LONG_LABELS))
    n = draw(st.integers(1, 5))
    words = draw(st.lists(st.sampled_from(_WORDS), min_size=n, max_size=n))
    return " ".join(words)


@st.composite
def mindmap_graph(draw, min_nodes=10, max_nodes=60):
    n_nodes = draw(st.integers(min_nodes, max_nodes))
    n_regions = draw(st.integers(1, 6))
    regions = [f"region{i}" for i in range(n_regions)]
    ids = [f"n{i}" for i in range(n_nodes)]
    labels = [_draw_label(draw) for _ in ids]

    graph: dict[str, dict] = {}
    # process nodes in id order; each non-root node picks 0-2 prereqs
    # among EARLIER ids only, guaranteeing a connected rooted DAG (no
    # cycles by construction) -- roots (region entry points) get none.
    for i, nid in enumerate(ids):
        region = draw(st.sampled_from(regions))
        if i == 0:
            prereqs = []
        else:
            max_pre = min(2, i)
            k = draw(st.integers(0, max_pre))
            # bias toward recent nodes so depth grows (a real tree shape)
            # but allow any earlier id so cross-region edges can occur
            pool = ids[:i]
            prereqs = draw(st.lists(st.sampled_from(pool), min_size=k,
                                    max_size=k, unique=True))
        graph[nid] = {
            "id": nid, "region": region, "label": labels[i],
            "prereqs": prereqs, "cost": {"components": 1, "data": 0},
            "faith": 0, "unlock": None, "blurb": "", "brief": "",
        }
    # every region actually used needs at least one root-reachable node;
    # since region assignment is independent of prereq structure this is
    # already guaranteed (frontier/available logic isn't under test here,
    # only layout, which only needs prereqs to be a subset of earlier ids)
    return graph


# ---------------------------------------------------------------------------
# geometry helpers (mirror mindmap.py's own overlap tests, kept independent
# so the property doesn't just re-check the implementation against itself
# for the raster-scan path -- these are plain AABB/point-circle tests)
# ---------------------------------------------------------------------------

def _rects_overlap(a, b) -> bool:
    l, t, r, bo = a
    l2, t2, r2, bo2 = b
    return l < r2 and r > l2 and t < bo2 and bo > t2


def _rect_circle_overlap(rect, cx, cy, radius) -> bool:
    l, t, r, b = rect
    nx = min(max(cx, l), r)
    ny = min(max(cy, t), b)
    return math.hypot(cx - nx, cy - ny) < radius


def _compute(graph):
    seed = mindmap.seed_layout(graph)
    pos, _ = mindmap.relax(seed, graph)
    return pos


# a camera the way podscene actually produces one: parked on a node, or
# anywhere along a glide between two nodes (camera_glide is a convex
# combination of endpoints, so interpolation covers every real mid-glide
# position exactly)
@st.composite
def _camera(draw, pos):
    ids = sorted(pos)
    a = pos[ids[draw(st.integers(0, len(ids) - 1))]]
    b = pos[ids[draw(st.integers(0, len(ids) - 1))]]
    t = draw(st.floats(0.0, 1.0, allow_nan=False))
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)


@st.composite
def graph_cam_sel(draw):
    graph = draw(mindmap_graph())
    pos = _compute(graph)
    cam = draw(_camera(pos))
    ids = sorted(graph)
    sel = ids[draw(st.integers(0, len(ids) - 1))]
    return graph, pos, cam, sel


# ---------------------------------------------------------------------------
# properties: node geometry (unchanged premises from round 1)
# ---------------------------------------------------------------------------

@given(graph=mindmap_graph())
def test_geometry_within_bounds(graph):
    # ROUND-2 ADAPTATION: this property used to also bound label boxes to
    # the canvas -- labels are now placed in the camera's local frame and
    # legitimately extend past the canonical canvas (the viewport crops
    # them); only the NODE containment premise survives, unchanged.
    pos = _compute(graph)
    for nid, (x, y) in pos.items():
        px, py = mindmap._to_px((x, y))
        r = mindmap.node_radius_px(graph[nid])
        assert -1e-6 <= px - r and px + r <= mindmap.CANVAS_W + 1e-6
        assert -1e-6 <= py - r and py + r <= mindmap.CANVAS_H + 1e-6


@given(graph=mindmap_graph())
def test_layout_deterministic(graph):
    seed = mindmap.seed_layout(graph)
    pos1, _ = mindmap.relax(seed, graph)
    pos2, _ = mindmap.relax(seed, graph)
    assert pos1 == pos2


# ---------------------------------------------------------------------------
# properties: the LOCAL label laws (director's round-2 clarification --
# these are the successors of the old whole-canvas non-occlusion PBTs;
# the law is now scoped to what a local camera can ever show)
# ---------------------------------------------------------------------------

def _point_rect_dist(px, py, rect):
    l, t, r, b = rect
    dx = max(l - px, 0.0, px - r)
    dy = max(t - py, 0.0, py - b)
    return math.hypot(dx, dy)


@given(gcs=graph_cam_sel())
def test_local_labels_never_overlap(gcs):
    """No two boxes the local layout places may intersect -- INCLUDING
    the selection's guaranteed box. This is the round-2 successor of the
    old whole-canvas label/label property, now over every camera position
    a glide can produce, not one static poster."""
    graph, pos, cam, sel = gcs
    zoom = mindmap.local_zoom(graph)
    labels = mindmap.local_label_layout(pos, cam, graph, zoom=zoom, sel=sel)
    boxes = list(labels.items())
    for i, (a, la) in enumerate(boxes):
        for b, lb in boxes[i + 1:]:
            assert not _rects_overlap(la["box"], lb["box"]), (
                f"labels overlap: {a} {la['box']} vs {b} {lb['box']}")


@given(gcs=graph_cam_sel())
def test_local_labels_clear_of_node_discs(gcs):
    """A placed label never covers ANY node disc (its own node's disc is
    cleared by anchor construction; every other node's by the collision
    search). The selection's last-resort fallback is exempt from the disc
    law by design -- podscene backs it with an opaque name-card plate --
    but never from the label/label law (previous test)."""
    graph, pos, cam, sel = gcs
    zoom = mindmap.local_zoom(graph)
    labels = mindmap.local_label_layout(pos, cam, graph, zoom=zoom, sel=sel)
    world = {nid: mindmap._to_world_px(pos[nid], zoom) for nid in pos}
    rad = {nid: mindmap.node_radius_px(graph[nid]) for nid in graph}
    for nid, info in labels.items():
        if nid == sel:
            continue
        for onid, (ox, oy) in world.items():
            if onid == nid:
                continue
            assert not _rect_circle_overlap(info["box"], ox, oy, rad[onid]), (
                f"label for {nid} overlaps node {onid}")


@given(gcs=graph_cam_sel())
def test_local_labels_adjacent_to_their_node(gcs):
    """Every placed box touches its node's vicinity: nearest edge within
    LOCAL_LABEL_MAX_GAP_PX of the node center. The old escalation
    ladder's exile tiers (labels 100-230px away on leader lines) are
    gone; this bound is what "eliminated" means."""
    graph, pos, cam, sel = gcs
    zoom = mindmap.local_zoom(graph)
    labels = mindmap.local_label_layout(pos, cam, graph, zoom=zoom, sel=sel)
    for nid, info in labels.items():
        nx, ny = mindmap._to_world_px(pos[nid], zoom)
        d = _point_rect_dist(nx, ny, info["box"])
        assert d <= mindmap.LOCAL_LABEL_MAX_GAP_PX, (nid, d)


@given(gcs=graph_cam_sel())
def test_local_labels_lod_law(gcs):
    """The LOD contract: a non-selected node appears in the layout IFF
    its view alpha is positive (legibility is owed near the camera and
    only there -- distant nodes are unlabeled points), each entry carries
    exactly its label_view_alpha, and the selection is ALWAYS present
    regardless of distance."""
    graph, pos, cam, sel = gcs
    zoom = mindmap.local_zoom(graph)
    labels = mindmap.local_label_layout(pos, cam, graph, zoom=zoom, sel=sel)
    assert sel in labels, "the selection must always carry a label"
    for nid, info in labels.items():
        assert info["alpha"] == mindmap.label_view_alpha(pos[nid], cam, zoom)
    for nid in pos:
        if nid != sel and mindmap.label_view_alpha(pos[nid], cam, zoom) <= 0.0:
            assert nid not in labels, (nid, "beyond the fade radius")


@given(gcs=graph_cam_sel())
def test_local_labels_deterministic(gcs):
    graph, pos, cam, sel = gcs
    zoom = mindmap.local_zoom(graph)
    a = mindmap.local_label_layout(pos, cam, graph, zoom=zoom, sel=sel)
    b = mindmap.local_label_layout(pos, cam, graph, zoom=zoom, sel=sel)
    assert a == b


def test_local_zoom_reference_and_scaling():
    """local_zoom is LOCAL_ZOOM exactly at the real map's density (the
    tuned baseline must not drift when the scaling law changes) and grows
    like sqrt(n) so the visible neighborhood stays ~constant-size as the
    map grows toward the director's hundreds/thousands."""
    assert mindmap.local_zoom() == mindmap.LOCAL_ZOOM  # real map == baseline
    g33 = {f"n{i}": {"region": "vocation", "label": "x", "prereqs": []}
           for i in range(33)}
    assert mindmap.local_zoom(g33) == mindmap.LOCAL_ZOOM
    g132 = {f"n{i}": {"region": "vocation", "label": "x", "prereqs": []}
            for i in range(132)}
    assert abs(mindmap.local_zoom(g132) - 2 * mindmap.LOCAL_ZOOM) < 1e-9
    g4 = {f"n{i}": {"region": "vocation", "label": "x", "prereqs": []}
          for i in range(4)}
    assert mindmap.local_zoom(g4) == mindmap.LOCAL_ZOOM  # floor, never below


def _region_centroids(pos, by_region):
    out = {}
    for region, ids in by_region.items():
        pts = [pos[nid] for nid in ids]
        out[region] = (sum(p[0] for p in pts) / len(pts),
                       sum(p[1] for p in pts) / len(pts))
    return out


@given(graph=mindmap_graph())
def test_region_cohesion(graph):
    """Non-vacuous cohesion (silhouette-shaped, not the trivial "centroid
    minimizes SSE" tautology): on average, a region's members sit closer
    to their OWN region's centroid than to the NEAREST other region's
    centroid. A layout that ignores region entirely (nodes placed without
    regard to `region`) would fail this on average, since own-centroid
    distance would be statistically indistinguishable from distance to
    the nearest foreign centroid."""
    pos, _ = mindmap.relax(mindmap.seed_layout(graph), graph)
    by_region: dict[str, list[str]] = {}
    for nid, n in graph.items():
        by_region.setdefault(n["region"], []).append(nid)
    if len(by_region) < 2:
        return  # cohesion vs. separation is meaningless with one region
    centroids = _region_centroids(pos, by_region)

    for region, ids in by_region.items():
        if len(ids) < 2:
            continue  # a singleton has no internal spread to test
        pts = [pos[nid] for nid in ids]
        rcx, rcy = centroids[region]
        own_mean_d = sum(math.hypot(x - rcx, y - rcy) for x, y in pts) / len(pts)
        nearest_other = min(
            sum(math.hypot(x - ocx, y - ocy) for x, y in pts) / len(pts)
            for oregion, (ocx, ocy) in centroids.items() if oregion != region)
        # region-sector affinity is DELIBERATELY a weak force (hard
        # constraint: territory should read without hard-ringing nodes)
        # AND real mind maps have real cross-region prereq edges (the
        # actual data/mindmap.json has two) whose springs legitimately
        # pull a member toward a neighboring region's territory. One
        # dragged member skews a SMALL region's mean by roughly 1/n of
        # the gap, so the slack scales with 1/len(ids) -- generous for a
        # 3-node region, ~5% for a realistic 20-node one. A layout that
        # ignores region entirely still fails this outright (30-100%
        # off), so the property stays meaningful.
        slack = 1.0 + 1.0 / len(ids)
        assert own_mean_d <= nearest_other * slack + 1e-6, (
            region, own_mean_d, nearest_other, slack)


# ---------------------------------------------------------------------------
# edge-crossing reduction (director follow-up: relaxation alone left the
# graph "a dense tangle"). relax() closes this with a construction, not a
# hope: an uncrossing-polish closer that always falls back no worse than
# the seed it started from (see mindmap.relax()'s docstring/comment). The
# properties below hold that construction to account from three angles:
# never worse than the seed (the guarantee itself), a strict absolute
# ceiling on graphs small/sparse enough to be drawn near-planar in
# practice, and a substantial (not token) aggregate reduction across a
# reproducible batch spanning the full generator's size range.
# ---------------------------------------------------------------------------

@given(graph=mindmap_graph())
def test_crossings_relaxed_never_worse_than_seed(graph):
    """The core guarantee: relax() never hands back a MORE tangled graph
    than the seed it started from. This holds by construction (an
    uncrossing-polish closer that falls back to the seed if it can't beat
    it -- see relax()), not by luck of the force constants, so it must
    hold for every generated graph, not just on average."""
    seed = mindmap.seed_layout(graph)
    pos, _ = mindmap.relax(seed, graph)
    seed_c = mindmap.count_crossings(seed, graph)
    relaxed_c = mindmap.count_crossings(pos, graph)
    assert relaxed_c <= seed_c, (relaxed_c, seed_c)


# graphs small/sparse enough that the sector-seeded relaxation reliably
# finds a near-planar drawing (measured: 500 examples of this exact
# strategy top out at 16 crossings, mean ~1.2 -- see the task's tuning
# notes). Real DAGs of this shape (small in-degree, few dozen nodes) are
# the common case for a mind map; this is the "planar-embeddable in
# practice" bound the brief asks for.
_SPARSE_ABS_BOUND = 24  # measured max 16 across 500 examples; headroom, not vacuous


@given(graph=mindmap_graph(min_nodes=10, max_nodes=18))
def test_crossings_bounded_for_sparse_graphs(graph):
    """Strict absolute ceiling for graphs in the size range that is
    realistically drawable with few crossings. A layout that didn't try
    to uncross at all would blow well past this (measured mean seed
    crossings ~7, max 46, on this same strategy) -- so this is a real,
    falsifiable claim, not a bound set so high it can never fail."""
    pos, _ = mindmap.relax(mindmap.seed_layout(graph), graph)
    c = mindmap.count_crossings(pos, graph)
    assert c <= _SPARSE_ABS_BOUND, c


def _seeded_batch_graphs(rng_seed: int, n_graphs: int) -> list[dict[str, dict]]:
    """A reproducible batch of mindmap-shaped graphs spanning the real
    generator's full node/region range, built from a plain seeded
    `random.Random` -- NOT hypothesis's `derandomize` (tried first: with
    `max_examples=1` hypothesis's internal byte stream for a derandomized
    run draws the all-minimal example, producing a batch of tiny 10-node
    graphs with zero seed crossings, which made the reduction ratio
    0/0 -- degenerate, not representative). A directly-seeded RNG gives
    the size/density spread the aggregate claim actually needs, while
    staying exactly as deterministic (same seed -> same batch, forever)."""
    rng = random.Random(rng_seed)
    graphs = []
    for _ in range(n_graphs):
        n_nodes = rng.randint(10, 60)
        n_regions = rng.randint(1, 6)
        regions = [f"region{i}" for i in range(n_regions)]
        ids = [f"n{i}" for i in range(n_nodes)]
        graph: dict[str, dict] = {}
        for i, nid in enumerate(ids):
            region = rng.choice(regions)
            label = " ".join(rng.choice(_WORDS) for _ in range(rng.randint(1, 5)))
            prereqs = [] if i == 0 else rng.sample(ids[:i], rng.randint(0, min(2, i)))
            graph[nid] = {"id": nid, "region": region, "label": label,
                          "prereqs": prereqs, "cost": {"components": 1, "data": 0},
                          "faith": 0, "unlock": None, "blurb": "", "brief": ""}
        graphs.append(graph)
    return graphs


# for an AGGREGATE claim: per-example crossing counts are noisy (a single
# unlucky dense/single-region graph can be genuinely hard to draw without
# crossings), but the reduction averaged over a real spread of graph
# shapes must be substantial, not a token few percent -- that is the
# "penalizes crossing" term actually doing its job across the space, not
# just on the one real map. Measured on 3 independent seeded batches of
# 40 (this fixture's seed and two others), BEFORE the depth-annulus
# containment existed: 43%, 53%, 55% reduction. The annulus (director's
# hybridization: nodes hard-confined to their own depth band) genuinely
# costs some of this -- a crossing-uncrossing move that would require
# leaving a node's own ring is no longer available, so the achievable
# reduction on the same batch dropped for real, not from a tuning
# regression: re-measured after the annulus landed at 32.8% on this exact
# batch. 0.30 is the new real, comfortably-clear-of-zero floor for the
# constrained field, not a number picked to exactly clear this one run.
_BATCH_SEED = 20260710
_BATCH_MIN_REDUCTION = 0.30


def test_crossings_batch_substantial_reduction():
    total_seed = total_relaxed = 0
    for graph in _seeded_batch_graphs(_BATCH_SEED, 40):
        seed = mindmap.seed_layout(graph)
        pos, _ = mindmap.relax(seed, graph)
        total_seed += mindmap.count_crossings(seed, graph)
        total_relaxed += mindmap.count_crossings(pos, graph)
    assert total_seed > 0, "batch degenerate: no seed had any crossing to reduce"
    reduction = (total_seed - total_relaxed) / total_seed
    assert reduction >= _BATCH_MIN_REDUCTION, (total_seed, total_relaxed, reduction)


# ---------------------------------------------------------------------------
# the real data/mindmap.json as a regression fixture, same properties
# ---------------------------------------------------------------------------

def test_real_mindmap_local_labels_every_camera():
    """ROUND-2 SUCCESSOR of the old real-map label fixtures (whole-canvas
    non-occlusion + canvas bounds, premises deleted with the global
    layout): with the camera parked on EVERY node of the real map in
    turn (each as the selection, exactly what navigation produces), the
    local label laws hold -- no two boxes overlap, no box covers a
    foreign disc (sel's plate-backed fallback aside), every box adjacent
    to its node, the selection always labeled -- and every node within
    the full-legibility radius actually GETS a label (the real map at
    real density owes full coverage near the camera; measured 100%
    across all 33 cameras at the shipped constants)."""
    graph = mindmap.nodes()
    pos = _compute(graph)
    zoom = mindmap.local_zoom(graph)
    rad = {nid: mindmap.node_radius_px(graph[nid]) for nid in graph}
    for camid in sorted(graph):
        cam = pos[camid]
        labels = mindmap.local_label_layout(pos, cam, graph, zoom=zoom,
                                            sel=camid)
        assert camid in labels
        boxes = list(labels.items())
        for i, (a, la) in enumerate(boxes):
            for b, lb in boxes[i + 1:]:
                assert not _rects_overlap(la["box"], lb["box"]), (camid, a, b)
        world = {nid: mindmap._to_world_px(pos[nid], zoom) for nid in pos}
        for nid, info in labels.items():
            nx, ny = world[nid]
            assert _point_rect_dist(nx, ny, info["box"]) <= \
                mindmap.LOCAL_LABEL_MAX_GAP_PX, (camid, nid)
            if nid != camid:
                for onid, (ox, oy) in world.items():
                    if onid != nid:
                        assert not _rect_circle_overlap(
                            info["box"], ox, oy, rad[onid]), (camid, nid, onid)
        near = [nid for nid in pos
                if mindmap.label_view_alpha(pos[nid], cam, zoom) >= 1.0]
        unlabeled_near = [nid for nid in near if nid not in labels]
        assert not unlabeled_near, (camid, unlabeled_near)


def test_real_mindmap_within_bounds():
    # ROUND-2 ADAPTATION: label boxes are no longer canvas-bounded (the
    # local camera crops); the node containment premise is unchanged.
    graph = mindmap.nodes()
    pos = _compute(graph)
    for nid, (x, y) in pos.items():
        px, py = mindmap._to_px((x, y))
        r = mindmap.node_radius_px(graph[nid])
        assert 0 <= px - r and px + r <= mindmap.CANVAS_W
        assert 0 <= py - r and py + r <= mindmap.CANVAS_H


def test_real_mindmap_deterministic():
    graph = mindmap.nodes()
    seed = mindmap.seed_layout(graph)
    pos1, _ = mindmap.relax(seed, graph)
    pos2, _ = mindmap.relax(seed, graph)
    assert pos1 == pos2
    # and layout()'s memoized path agrees with a fresh relax
    mindmap._LAYOUT = None
    assert mindmap.layout() == pos1
    mindmap._LAYOUT = None
    assert mindmap.layout() == pos1


def test_real_mindmap_region_cohesion():
    graph = mindmap.nodes()
    pos, _ = mindmap.relax(mindmap.seed_layout(graph), graph)
    by_region: dict[str, list[str]] = {}
    for nid, n in graph.items():
        by_region.setdefault(n["region"], []).append(nid)
    centroids = _region_centroids(pos, by_region)
    for region, ids in by_region.items():
        pts = [pos[nid] for nid in ids]
        rcx, rcy = centroids[region]
        own_mean_d = sum(math.hypot(x - rcx, y - rcy) for x, y in pts) / len(pts)
        nearest_other = min(
            sum(math.hypot(x - ocx, y - ocy) for x, y in pts) / len(pts)
            for oregion, (ocx, ocy) in centroids.items() if oregion != region)
        slack = 1.0 + 1.0 / len(ids)
        assert own_mean_d <= nearest_other * slack + 1e-6


def test_real_mindmap_trajectory_reaches_final_frame():
    """layout_steps() ends exactly at layout()'s fixed point -- the API
    the UI animates through must actually terminate where the rest of the
    game thinks the graph lives."""
    steps = mindmap.layout_steps(record_every=10)
    assert len(steps) >= 2
    assert steps[0] != steps[-1]  # it actually moved
    assert steps[-1] == mindmap.layout()


def test_real_mindmap_crossings():
    """Regression bound for the real map (director follow-up: the settle
    was "a dense tangle"). Measured before the crossing-aware terms
    existed: the seed layout has 11 prereq-edge crossings and the OLD
    relaxation (repulsion + springs + region affinity + bounds, no
    crossing-aware term) made it WORSE -- 31 crossings at rest. With the
    node<->edge repulsion + explicit uncrossing pass + polish closer, the
    real map settled at 6 crossings (after making the label<->label
    repulsion term a central force). Re-measured AGAIN after adding the
    depth-annulus hard containment (director's hybridization: nodes can
    never cross their own ring boundary) -- honestly, this genuinely costs
    a little of the uncrossing freedom (a crossing fix that would require
    leaving a node's own ring is no longer reachable): the real map now
    settles at 5 crossings, still a substantial 11 -> 5 reduction, and
    (coincidentally) one better than before the annulus, not worse -- the
    band constraint happened to steer this particular graph's settle into
    a cleaner configuration than the unconstrained one found. The achieved
    number is asserted as a tight regression bound (not just "<= seed") so
    a future change that quietly regresses the tangle gets caught even
    though 5 is still technically <= 11."""
    graph = mindmap.nodes()
    seed = mindmap.seed_layout(graph)
    pos, _ = mindmap.relax(seed, graph)
    seed_c = mindmap.count_crossings(seed, graph)
    relaxed_c = mindmap.count_crossings(pos, graph)
    # re-measured 2026-07-11 (director's band-freedom pass): the seed now
    # scatters radii within each depth band (crc32 fraction, see
    # seed_layout), which changed the seed's own tangle from 11 to 9 --
    # and the strengthened uncrossing terms (24/900/22, see _CROSS_K's
    # comment) hold the settle to 5, a real 9 -> 5 reduction with genuine
    # settle motion (the earlier 5/400/16 constants ended WORSE than the
    # new seed and silently fell back to it: zero settle animation, which
    # test_real_mindmap_trajectory_reaches_final_frame now guards).
    assert seed_c == 9, seed_c
    assert relaxed_c <= 5, relaxed_c
    assert relaxed_c <= seed_c


# ---------------------------------------------------------------------------
# depth-annulus containment (director's hybridization, superseding the
# earlier "yanked to the center...drifted back...when released" pin:
# "let's make it so nodes can't cross the concentric ring boundaries...
# but the details are allowed to be chaotic. A slight hybridization...
# I *love* the way the vertices move now" -- then, superseding the pin
# entirely, "let's instead have the camera move out to the ring that
# hosts the selected concept" -- no node is EVER exempt from its own band,
# selected or not, live physics or baked rest).
# ---------------------------------------------------------------------------

def _within_own_band(pos, graph=None, tol=1e-6):
    bands = mindmap.node_bands(graph)
    for nid, (x, y) in pos.items():
        lo, hi = bands[nid]
        r = math.hypot(x, y)
        assert lo - tol <= r <= hi + tol, (nid, r, lo, hi)


@given(graph=mindmap_graph())
def test_relax_respects_depth_annulus(graph):
    """Property (a) for the baked rest layout: every node's relaxed
    position, over the FULL hypothesis-generated graph space, sits inside
    its own depth's band -- not just the real map."""
    pos, _ = mindmap.relax(mindmap.seed_layout(graph), graph)
    _within_own_band(pos, graph)


def test_real_mindmap_relax_respects_annulus():
    _within_own_band(mindmap.layout())


# ---------------------------------------------------------------------------
# band FREEDOM (director, verbatim: "I envisioned them as bands they're
# contained within but free to move within them" -- not "vertices locked
# to the circles"). Two claims: (a) no rest position ever sits ON a band
# boundary (the hard clamp is inset by BAND_CLAMP_INSET_FRAC of the
# shoulder margin, so this holds by construction, PBT'd over the full
# graph space); (b) the real map's rest layout shows genuine radial
# VARIANCE within bands -- a bead-necklace layout (all nodes at one
# radius per ring) would fail the spread floor outright.
# ---------------------------------------------------------------------------

def _band_interior_bounds(nid_bands):
    lo, hi = nid_bands
    inset = (hi - lo) * mindmap.BAND_MARGIN_FRAC * mindmap.BAND_CLAMP_INSET_FRAC
    return lo + inset, hi - inset


@given(graph=mindmap_graph())
def test_rest_never_rides_band_boundary(graph):
    pos, _ = mindmap.relax(mindmap.seed_layout(graph), graph)
    bands = mindmap.node_bands(graph)
    for nid, (x, y) in pos.items():
        lo_i, hi_i = _band_interior_bounds(bands[nid])
        r = math.hypot(x, y)
        assert lo_i - 1e-6 <= r <= hi_i + 1e-6, (nid, r, lo_i, hi_i)


def test_live_sleep_never_rides_band_boundary():
    st = mindmap.live_rest_state()
    for _ in range(mindmap._LIVE_SETTLE_BOUND_TICKS):
        st = mindmap.live_relax_step(st)
        if st.asleep:
            break
    else:
        raise AssertionError("never reached bitwise rest")
    bands = mindmap.node_bands()
    for nid, (x, y) in st.pos.items():
        lo_i, hi_i = _band_interior_bounds(bands[nid])
        r = math.hypot(x, y)
        assert lo_i - 1e-6 <= r <= hi_i + 1e-6, (nid, r, lo_i, hi_i)


def test_real_mindmap_radial_variance_within_bands():
    """The anti-necklace floor, measured on the real map at the shipped
    constants (2026-07-11): per-node position-within-band fractions span
    0.07..0.93 with population sd ~0.24. A layout that snapped nodes back
    onto ring centerlines (sd ~0) or onto the boundaries (all fracs at
    0/1, sd high but spread degenerate) fails one of these."""
    lay = mindmap.layout()
    bands = mindmap.node_bands()
    fracs = []
    for nid, (x, y) in lay.items():
        lo, hi = bands[nid]
        fracs.append((math.hypot(x, y) - lo) / (hi - lo))
    assert all(0.05 <= f <= 0.95 for f in fracs), (min(fracs), max(fracs))
    mean = sum(fracs) / len(fracs)
    sd = (sum((f - mean) ** 2 for f in fracs) / len(fracs)) ** 0.5
    assert sd >= 0.15, sd


# ROUND-2 ADAPTATION: test_real_mindmap_labels_avoid_region_headers was
# deleted with its premise -- the global layout reserved header rects on
# ONE static canvas; under the local camera, headers are LOD-faded by the
# same label_view_alpha law as labels (podscene._draw_region_headers), so
# a header and a label box no longer share a fixed frame to be reserved
# in. (Headers anchor at unit radius 1.10, outside the node ellipse, so
# at full alpha they sit beyond any node's adjacent label reach anyway.)


def test_live_rest_respects_annulus_at_sleep():
    """Property (b): at live sleep (no selection input -- there is none
    left in the force field), every node is inside its own band, for the
    real map."""
    st = mindmap.live_rest_state()
    for _ in range(mindmap._LIVE_SETTLE_BOUND_TICKS):
        st = mindmap.live_relax_step(st)
        if st.asleep:
            break
    else:
        raise AssertionError("never reached bitwise rest")
    _within_own_band(st.pos)


def test_live_trajectory_never_leaves_annulus():
    """Property (a) restated for the LIVE dynamics: every node stays
    inside its own band on EVERY tick of a real trajectory, not just at
    the end -- from the most displaced starting condition the UI actually
    produces (the raw seed layout, e.g. right after a graph reveal, before
    any settle has run), through to sleep."""
    seed = mindmap.seed_layout()
    st = mindmap.LiveState(pos=dict(seed), vel={nid: (0.0, 0.0) for nid in seed})
    for _ in range(mindmap._LIVE_SETTLE_BOUND_TICKS):
        st = mindmap.live_relax_step(st)
        _within_own_band(st.pos)
        if st.asleep:
            break
    else:
        raise AssertionError("never reached bitwise rest")


# ---------------------------------------------------------------------------
# the quiescence law (director follow-up, "we need to assert that the
# graph nodes come to a rest after a certain point"): from any starting
# state, the system must reach a point where every SUBSEQUENT tick's
# positions are EXACTLY equal (bitwise) -- not "very still", not "within
# a few px", literally the same dict. This is the mind-map's second-order
# integrator (see mindmap.py's live_relax_step comment block) plus its
# sleep latch. Selection no longer touches the force field at all (the
# director's camera-glide hybridization), so there is nothing left to
# sweep as a "pin" -- the measured worst case below is from the most
# displaced state the UI actually produces (the raw seed layout):
#   page-open, no input, worst case:               9 ticks   (~0.15s)
#   from the raw seed layout (post-reveal), worst case: 91 ticks (~1.5s)
# ---------------------------------------------------------------------------

_LIVE_SETTLE_BOUND = mindmap._LIVE_SETTLE_BOUND_TICKS  # 600: generous over
                                                        # the measured
                                                        # ~91-tick worst case


def _run_to_sleep(state, budget=_LIVE_SETTLE_BOUND):
    """Tick `state` until it reports asleep, or `budget` ticks pass.
    Returns (tick_index_or_None, final_state)."""
    for i in range(budget):
        state = mindmap.live_relax_step(state)
        if state.asleep:
            return i, state
    return None, state


def test_live_rest_open_reaches_exact_bitwise_rest():
    """From page-open state with no input, there exists a bounded T after
    which every subsequent tick's positions are EXACTLY equal -- proven
    over a further 600 ticks (10s @ 60Hz), not just the tick T itself."""
    st = mindmap.live_rest_state()
    settle_at, st = _run_to_sleep(st)
    assert settle_at is not None, "never reached bitwise rest"
    assert settle_at <= _LIVE_SETTLE_BOUND, settle_at
    frozen = dict(st.pos)
    for _ in range(600):
        st = mindmap.live_relax_step(st)
        assert st.pos == frozen, "positions moved after the system reported asleep"


def test_live_rest_from_seed_reaches_exact_bitwise_rest():
    """The SAME exact-rest guarantee holds from the most displaced state
    the UI actually produces (the raw seed layout, right after a reveal,
    before any settle)."""
    seed = mindmap.seed_layout()
    st = mindmap.LiveState(pos=dict(seed), vel={nid: (0.0, 0.0) for nid in seed})
    settle_at, st = _run_to_sleep(st)
    assert settle_at is not None, "never reached bitwise rest from seed"
    assert settle_at <= _LIVE_SETTLE_BOUND, settle_at
    frozen = dict(st.pos)
    for _ in range(120):
        st = mindmap.live_relax_step(st)
        assert st.pos == frozen, "positions moved after the system reported asleep"


def test_live_relax_deterministic():
    """Two independent runs from the same start produce IDENTICAL
    LiveState at every tick -- pos, vel, and the quiet/asleep bookkeeping
    all included. No wall-clock, no unseeded randomness."""
    seed = mindmap.seed_layout()
    st1 = mindmap.LiveState(pos=dict(seed), vel={nid: (0.0, 0.0) for nid in seed})
    st2 = mindmap.LiveState(pos=dict(seed), vel={nid: (0.0, 0.0) for nid in seed})
    for _ in range(500):
        st1 = mindmap.live_relax_step(st1)
        st2 = mindmap.live_relax_step(st2)
        assert st1 == st2


# ---------------------------------------------------------------------------
# the camera glide (director's hybridization: selection moves the CAMERA
# to frame the selected node's ring, never the node itself -- see
# podscene.py's usage). Promoted here from mindmap_rings.py (its original
# home for the rings-mode A/B variant) so BOTH layout variants share the
# exact same math; mindmap_rings.camera_glide re-exports this same
# function (see test_mindmap_rings.py for those same properties exercised
# through that name).
# ---------------------------------------------------------------------------

def test_camera_glide_exact_arrival_and_static_after():
    p_from, p_to, t0, dur = (0.0, 0.0), (10.0, -4.0), 2.0, 0.5
    assert mindmap.camera_glide(t0 - 1.0, t0, dur, p_from, p_to) == p_from
    assert mindmap.camera_glide(t0, t0, dur, p_from, p_to) == p_from
    mid = mindmap.camera_glide(t0 + dur / 2.0, t0, dur, p_from, p_to)
    assert 0.0 < mid[0] < 10.0 and -4.0 < mid[1] < 0.0
    arrival = mindmap.camera_glide(t0 + dur, t0, dur, p_from, p_to)
    assert arrival == p_to
    later = mindmap.camera_glide(t0 + dur + 50.0, t0, dur, p_from, p_to)
    assert later == p_to  # bitwise-static after arrival, forever


def test_camera_glide_zero_duration_snaps():
    p_from, p_to = (1.0, 1.0), (5.0, 5.0)
    assert mindmap.camera_glide(0.0, 0.0, 0.0, p_from, p_to) == p_to


def test_camera_glide_deterministic():
    p_from, p_to = (0.0, 0.0), (3.0, 7.0)
    a = [mindmap.camera_glide(t / 10.0, 0.0, 0.5, p_from, p_to) for t in range(20)]
    b = [mindmap.camera_glide(t / 10.0, 0.0, 0.5, p_from, p_to) for t in range(20)]
    assert a == b


# ---------------------------------------------------------------------------
# TARGET SCALE (director's round-2 brief: "hundreds, maybe _thousands_ of
# vertices... I never intended for all rings nor all vertices within a
# ring to be visible at once"). The real map's 33 nodes are a sparse
# early-game state; the local-camera framing must be PROVEN at the scale
# it is designed for. testkit.graphs.synthetic_mindmap is that design
# fixture: 400 nodes, real depth distribution (maxd 20), realistic label
# lengths, per-region rooted DAGs -- relaxed ONCE per test session below.
# ---------------------------------------------------------------------------

_SCALE_N = 400


@pytest.fixture(scope="module")
def scale_fixture():
    graph = synthetic_mindmap(_SCALE_N)
    pos, _ = mindmap.relax(mindmap.seed_layout(graph), graph)
    return graph, pos


def test_target_scale_fixture_shape(scale_fixture):
    """The fixture is actually target-shaped, not a toy: hundreds of
    nodes, a deep prereq structure (double-digit depth), every region
    populated -- otherwise the framing claims below prove nothing."""
    graph, _ = scale_fixture
    assert len(graph) == _SCALE_N
    dep = mindmap._depths_of(graph)
    assert max(dep.values()) >= 10, max(dep.values())
    regions = {n["region"] for n in graph.values()}
    assert len(regions) == 4


def test_target_scale_bands_hold(scale_fixture):
    """The depth-annulus containment law survives 400 nodes: every rest
    position inside its own band (the generic PBT tops out at 60 nodes;
    this pins the dense regime where hard containment does real work)."""
    graph, pos = scale_fixture
    _within_own_band(pos, graph)


def test_target_scale_local_framing(scale_fixture):
    """The round-2 law itself, measured: with the density-scaled zoom
    (local_zoom(400) ~ 10.4 vs the 33-node baseline 3.0), every sampled
    camera position frames a LOCAL neighborhood -- never more than 8% of
    the graph in the viewport (measured max 5%), median a workable
    handful, and the zoom is genuinely scaled up from the baseline."""
    graph, pos = scale_fixture
    zoom = mindmap.local_zoom(graph)
    assert zoom > 2 * mindmap.LOCAL_ZOOM
    hw_u = (mindmap.CANVAS_W / 2) / (mindmap.CANVAS_W * mindmap.SX_FRAC * zoom)
    strip = mindmap.CANVAS_H - mindmap.HEADER_MARGIN_PX - mindmap.FOOTER_MARGIN_PX
    hh_u = (strip / 2) / (mindmap.CANVAS_H * mindmap.SY_FRAC * zoom)
    counts = []
    for camid in sorted(graph)[::20]:
        cx, cy = pos[camid]
        counts.append(sum(1 for x, y in pos.values()
                          if abs(x - cx) <= hw_u and abs(y - cy) <= hh_u))
    assert max(counts) <= 0.08 * len(graph), (max(counts), len(graph))
    assert sorted(counts)[len(counts) // 2] >= 3, counts  # territory, not void


def test_target_scale_local_labels(scale_fixture):
    """The label laws at target density, every 20th node as camera+sel:
    no overlaps, adjacency, selection always labeled, and >= 90% of
    full-legibility-radius nodes actually labeled (measured 100% at the
    shipped constants -- density scaling is what makes this possible; at
    the 33-node baseline zoom this same fixture measured 12-35%)."""
    graph, pos = scale_fixture
    zoom = mindmap.local_zoom(graph)
    for camid in sorted(graph)[::20]:
        cam = pos[camid]
        labels = mindmap.local_label_layout(pos, cam, graph, zoom=zoom,
                                            sel=camid)
        assert camid in labels
        boxes = list(labels.items())
        for i, (a, la) in enumerate(boxes):
            for b, lb in boxes[i + 1:]:
                assert not _rects_overlap(la["box"], lb["box"]), (camid, a, b)
        for nid, info in labels.items():
            nx, ny = mindmap._to_world_px(pos[nid], zoom)
            assert _point_rect_dist(nx, ny, info["box"]) <= \
                mindmap.LOCAL_LABEL_MAX_GAP_PX, (camid, nid)
        near = [nid for nid in pos
                if mindmap.label_view_alpha(pos[nid], cam, zoom) >= 1.0]
        placed = sum(1 for nid in near if nid in labels)
        assert placed >= 0.9 * len(near), (camid, placed, len(near))


def test_target_scale_live_physics_leashed(scale_fixture):
    """The live-jitter field was tuned at 33 nodes; at target density its
    raw equilibrium sits up to 0.64 unit from layout() (measured -- the
    camera, which aims at layout(), would visibly lose its own subject).
    The leash (mindmap.LIVE_LEASH_SCREEN_PX) is the contract that framing
    survives ANY density: on every sampled tick, no node is farther from
    its layout() rest than 1.5x the screen-space cap. The slack over the
    raw leash exists because the band/ellipse containment deliberately
    gets the LAST word after it (the annulus law is strict; at this
    density a band is only ~4 canvas px wide -- comparable to the leash
    itself -- so its projection can carry a leashed node past the leash
    circle by a real fraction: measured worst 49.4 screen px over 300
    ticks vs the 40px cap). Without the leash this measured ~1900 screen
    px (0.64 unit) -- the framing claim would simply be false. (Bitwise
    sleep at this saturated density is NOT claimed -- see the leash's
    comment; bounded forever is the law here.)"""
    graph, _ = scale_fixture
    import perihelion.mindmap as mm
    old_nodes, old_layout = mm._NODES, mm._LAYOUT
    try:
        mm._NODES, mm._LAYOUT = graph, None
        lay = mm.layout()
        zoom = mm.local_zoom(graph)
        leash_canvas = mm.LIVE_LEASH_SCREEN_PX / zoom
        st_ = mm.live_rest_state(graph)
        sx = mm.CANVAS_W * mm.SX_FRAC
        sy = mm.CANVAS_H * mm.SY_FRAC
        for tick in range(120):
            st_ = mm.live_relax_step(st_, graph)
            if tick % 20:
                continue
            for nid, (x, y) in st_.pos.items():
                dx = (x - lay[nid][0]) * sx
                dy = (y - lay[nid][1]) * sy
                d = math.hypot(dx, dy)
                assert d <= leash_canvas * 1.5 + 1e-6, (tick, nid, d * zoom)
    finally:
        mm._NODES, mm._LAYOUT = old_nodes, old_layout
        mm._SYSTEM_CACHE.clear()
        mm._REST_CACHE.clear()
