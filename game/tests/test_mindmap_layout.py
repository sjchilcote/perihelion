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
# 40 (this fixture's seed and two others): 43%, 53%, 55% reduction --
# 0.35 is a real, comfortably-clear-of-zero floor, not a number picked to
# exactly clear this one run.
_BATCH_SEED = 20260710
_BATCH_MIN_REDUCTION = 0.35


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
    real map settles at 6 crossings (re-measured after making the
    label<->label repulsion term a central force -- see _force_step's
    comment -- which shifts the settled positions slightly since it is
    the SAME force field relax() uses; still a substantial 11 -> 6
    reduction). The achieved number is asserted as a tight regression
    bound (not just "<= seed") so a future change that quietly regresses
    the tangle gets caught even though 6 is still technically <= 11."""
    graph = mindmap.nodes()
    seed = mindmap.seed_layout(graph)
    pos, _ = mindmap.relax(seed, graph)
    seed_c = mindmap.count_crossings(seed, graph)
    relaxed_c = mindmap.count_crossings(pos, graph)
    assert seed_c == 11, seed_c
    assert relaxed_c <= 6, relaxed_c
    assert relaxed_c <= seed_c


# ---------------------------------------------------------------------------
# the live selection pin (director-directed: "yanked to the center...
# drifted back...when released" -- podscene.py's per-tick UI feature).
# live_relax_step() is the ONLINE twin of relax()'s force field: ticked
# indefinitely at a fixed rate rather than run once over a cooling
# schedule.
#
# THE quiescence law (director follow-up, "we need to assert that the
# graph nodes come to a rest after a certain point"): from any starting
# state, the system must reach a point where every SUBSEQUENT tick's
# positions are EXACTLY equal (bitwise) -- not "very still", not "within
# a few px", literally the same dict. This is the mind-map's second-order
# integrator (see mindmap.py's live_relax_step comment block) plus its
# sleep latch, and every bound below is a real, measured number (not
# picked to make these pass), captured while tuning REST_SPRING_K /
# PIN_SPRING_K / LIVE_DAMPING:
#   page-open, no input, worst case:        9 ticks   (~0.15s)
#   pin engaged, from rest, worst case:   450 ticks   (~7.5s)
#   release, from pinned rest, worst case: 112 ticks  (~1.9s)
#   worst release deviation from layout():        ~11.0px
#   worst pinned distance-to-view-center:        ~152.5px
# ---------------------------------------------------------------------------

_LIVE_SETTLE_BOUND = mindmap._LIVE_SETTLE_BOUND_TICKS  # 600: generous over
                                                        # the measured
                                                        # 450-tick worst case
_PIN_CENTER_BOUND_PX = 160.0   # measured worst case (33-node sweep): 152.5px,
                               # against a mean rest-to-center distance of
                               # ~99px -- a real, non-vacuous "pulled toward
                               # center" bound, not the literal center (the
                               # pin is one spring among several; it wins,
                               # it doesn't obliterate the others).
_RELEASE_EPSILON_PX = 20.0     # measured worst case (33-node sweep, settle
                               # under pin -> release -> re-settle): ~11.0px.


def _pin_center_px():
    return (mindmap.CANVAS_W * mindmap.CX_FRAC, mindmap.CANVAS_H * mindmap.CY_FRAC)


def _run_to_sleep(state, pin, budget=_LIVE_SETTLE_BOUND):
    """Tick `state` (with the given pin) until it reports asleep, or
    `budget` ticks pass. Returns (tick_index_or_None, final_state)."""
    for i in range(budget):
        state = mindmap.live_relax_step(state, pin=pin)
        if state.asleep:
            return i, state
    return None, state


def test_live_rest_open_reaches_exact_bitwise_rest():
    """Property (a): from page-open state with no input, there exists a
    bounded T after which every subsequent tick's positions are EXACTLY
    equal -- proven over a further 600 ticks (10s @ 60Hz), not just
    the tick T itself."""
    st = mindmap.live_rest_state()
    settle_at, st = _run_to_sleep(st, pin=None)
    assert settle_at is not None, "never reached bitwise rest"
    assert settle_at <= _LIVE_SETTLE_BOUND, settle_at
    frozen = dict(st.pos)
    for _ in range(600):
        st = mindmap.live_relax_step(st, pin=None)
        assert st.pos == frozen, "positions moved after the system reported asleep"


def test_live_rest_under_pin_reaches_exact_bitwise_rest():
    """Property (b): the SAME exact-rest guarantee holds at the pinned
    equilibrium, for every node in the real map as the selection (not
    just one hand-picked case)."""
    rest = mindmap.layout()
    for sel in sorted(rest):
        st = mindmap.live_rest_state()
        settle_at, st = _run_to_sleep(st, pin=sel)
        assert settle_at is not None, (sel, "never reached bitwise rest while pinned")
        assert settle_at <= _LIVE_SETTLE_BOUND, (sel, settle_at)
        frozen = dict(st.pos)
        for _ in range(120):
            st = mindmap.live_relax_step(st, pin=sel)
            assert st.pos == frozen, (sel, "positions moved after asleep, still pinned")


def test_live_pin_pulls_selected_node_near_center():
    rest = mindmap.layout()
    cx, cy = _pin_center_px()
    worst = 0.0
    for sel in sorted(rest):
        st = mindmap.live_rest_state()
        _, st = _run_to_sleep(st, pin=sel)
        px, py = mindmap._to_px(st.pos[sel])
        worst = max(worst, math.hypot(px - cx, py - cy))
    assert worst <= _PIN_CENTER_BOUND_PX, worst


def test_live_wake_and_re_rest_within_epsilon():
    """Property (c), the key one: releasing a held selection must WAKE
    the (now sleeping) system -- releasing changes the force field (the
    formerly-pinned node's spring reverts to its own rest anchor), so the
    very next tick must NOT be quiescent, i.e. the sleep latch is not a
    one-way door -- and the system must then re-settle, again to EXACT
    bitwise rest, within the same bounded tick budget, landing within
    epsilon of the ORIGINAL static layout() for every node (not just the
    formerly-pinned one) -- the no-permanent-deformation property must
    hold THROUGH the sleep mechanism, not be broken by it."""
    rest = mindmap.layout()
    worst_release_settle = 0
    worst_dev = 0.0
    for sel in sorted(rest):
        st = mindmap.live_rest_state()
        settle_at, st = _run_to_sleep(st, pin=sel)
        assert settle_at is not None, (sel, "never settled under pin")
        assert st.asleep

        st = mindmap.live_relax_step(st, pin=None)  # release: the perturbation
        assert st.quiet == 0, (sel, "release did not wake the sleeping system")

        settle_at, st = _run_to_sleep(st, pin=None)
        assert settle_at is not None, (sel, "never re-settled after release")
        worst_release_settle = max(worst_release_settle, settle_at)

        devpx = max(
            math.hypot(*(a - b for a, b in zip(mindmap._to_px(st.pos[n]), mindmap._to_px(rest[n]))))
            for n in rest)
        worst_dev = max(worst_dev, devpx)

    assert worst_release_settle <= _LIVE_SETTLE_BOUND, worst_release_settle
    assert worst_dev <= _RELEASE_EPSILON_PX, worst_dev


def test_live_relax_deterministic():
    """Property (d): two independent runs from the same start, ticked
    through the same pin sequence (pin, then release, through sleep and
    wake both times), produce IDENTICAL LiveState at every tick -- pos,
    vel, and the quiet/asleep bookkeeping all included. No wall-clock, no
    unseeded randomness."""
    sel = sorted(mindmap.layout())[7]
    st1 = mindmap.live_rest_state()
    st2 = mindmap.live_rest_state()
    for _ in range(500):
        st1 = mindmap.live_relax_step(st1, pin=sel)
        st2 = mindmap.live_relax_step(st2, pin=sel)
        assert st1 == st2
    for _ in range(300):
        st1 = mindmap.live_relax_step(st1, pin=None)
        st2 = mindmap.live_relax_step(st2, pin=None)
        assert st1 == st2
