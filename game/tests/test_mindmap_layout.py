"""PBT harness (director-directed, SEEDPOD_UI_DESIGN.md follow-up): PROVES
the mind-map relaxation layout never lets a node label collide with
another label or another node, for generated mind-map-shaped graphs AND
for the real data/mindmap.json. Also proves determinism (no wall-clock,
no unseeded randomness) and canvas containment.

Run from the repo root (pytest needs the cwd for other suites' fixtures).
"""

from __future__ import annotations

import math
import random

from hypothesis import HealthCheck, given, settings
from hypothesis import strategies as st

from perihelion import mindmap

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
    labels = mindmap.label_layout(pos, graph)
    return pos, labels


# ---------------------------------------------------------------------------
# properties
# ---------------------------------------------------------------------------

@given(graph=mindmap_graph())
def test_no_label_label_overlap(graph):
    _, labels = _compute(graph)
    boxes = list(labels.items())
    for i, (a, la) in enumerate(boxes):
        for b, lb in boxes[i + 1:]:
            assert not _rects_overlap(la["box"], lb["box"]), (
                f"labels overlap: {a} {la['box']} vs {b} {lb['box']}")


@given(graph=mindmap_graph())
def test_no_label_node_overlap(graph):
    pos, labels = _compute(graph)
    node_px = {nid: mindmap._to_px(pos[nid]) for nid in graph}
    rad = {nid: mindmap.node_radius_px(graph[nid]) for nid in graph}
    for nid, info in labels.items():
        for onid, (ox, oy) in node_px.items():
            if onid == nid:
                continue  # a label may sit against its own node
            assert not _rect_circle_overlap(info["box"], ox, oy, rad[onid]), (
                f"label for {nid} overlaps node {onid}")


@given(graph=mindmap_graph())
def test_geometry_within_bounds(graph):
    pos, labels = _compute(graph)
    for nid, (x, y) in pos.items():
        px, py = mindmap._to_px((x, y))
        r = mindmap.node_radius_px(graph[nid])
        assert -1e-6 <= px - r and px + r <= mindmap.CANVAS_W + 1e-6
        assert -1e-6 <= py - r and py + r <= mindmap.CANVAS_H + 1e-6
    for nid, info in labels.items():
        l, t, r, b = info["box"]
        assert -1e-6 <= l and r <= mindmap.CANVAS_W + 1e-6, (nid, info["box"])
        assert -1e-6 <= t and b <= mindmap.CANVAS_H + 1e-6, (nid, info["box"])


@given(graph=mindmap_graph())
def test_layout_deterministic(graph):
    seed = mindmap.seed_layout(graph)
    pos1, _ = mindmap.relax(seed, graph)
    pos2, _ = mindmap.relax(seed, graph)
    assert pos1 == pos2
    labels1 = mindmap.label_layout(pos1, graph)
    labels2 = mindmap.label_layout(pos2, graph)
    assert labels1 == labels2


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

def test_real_mindmap_no_label_label_overlap():
    graph = mindmap.nodes()
    _, labels = _compute(graph)
    boxes = list(labels.items())
    for i, (a, la) in enumerate(boxes):
        for b, lb in boxes[i + 1:]:
            assert not _rects_overlap(la["box"], lb["box"]), (a, b)


def test_real_mindmap_no_label_node_overlap():
    graph = mindmap.nodes()
    pos, labels = _compute(graph)
    node_px = {nid: mindmap._to_px(pos[nid]) for nid in graph}
    rad = {nid: mindmap.node_radius_px(graph[nid]) for nid in graph}
    for nid, info in labels.items():
        for onid, (ox, oy) in node_px.items():
            if onid == nid:
                continue
            assert not _rect_circle_overlap(info["box"], ox, oy, rad[onid])


def test_real_mindmap_within_bounds():
    graph = mindmap.nodes()
    pos, labels = _compute(graph)
    for nid, (x, y) in pos.items():
        px, py = mindmap._to_px((x, y))
        r = mindmap.node_radius_px(graph[nid])
        assert 0 <= px - r and px + r <= mindmap.CANVAS_W
        assert 0 <= py - r and py + r <= mindmap.CANVAS_H
    for info in labels.values():
        l, t, r, b = info["box"]
        assert 0 <= l and r <= mindmap.CANVAS_W
        assert 0 <= t and b <= mindmap.CANVAS_H


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


def test_real_mindmap_labels_avoid_region_headers():
    """Region headers are part of the map: label_layout reserves their
    rects (the same region_header_layout() podscene draws from), so no
    node label may intersect any header box."""
    graph = mindmap.nodes()
    pos, labels = _compute(graph)
    headers = mindmap.region_header_layout(graph)
    for nid, info in labels.items():
        for region, h in headers.items():
            assert not _rects_overlap(info["box"], h["box"]), (nid, region)


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
