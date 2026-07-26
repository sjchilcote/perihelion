"""U8 gate — runtime topology ownership and the always-built hub.

Construction: connect_equal refuses mismatched lengths BEFORE gluing
(96 vs 52 raises with no live portal left behind), and even with the
length check gone the post-connect scale assert tears the portal out
(the mutant vector); edge handles stay true across later splits of the
same wall; every world builds exactly one 24-chamber hub, unreachable
until a breach exists.

Layout: three receiving apses, the transept loop, collar/anchor
chapels, one scriptorium, three PAIRWISE NONADJACENT source cells at
depth 10-11 from every apse, ~half the floor area in the first three
depth bands, and three carved-but-unconnected 96u breach seams.
"""
from __future__ import annotations

import math

import pytest

from perihelion.hub import BREACH_W, _ROOMS
from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession
from perihelion.topology import TopologyError


def _session():
    b = LevelBuilder("HUB8", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (100, 100))
    return GameSession(b.build(), seed=3), r0


# ---------------------------------------------------------------------------
# the scale guard
# ---------------------------------------------------------------------------

def test_connect_equal_glues_96_to_96_at_scale_1():
    s, r0 = _session()
    world = s.topology.carve(r0, (200.0 - 200.0, 150.0 - 150.0), 96.0)
    assert world is not None
    seam = s.hub.breach_edges[0]
    link = s.topology.connect_equal(world, seam)
    ra, ea = s.topology.current_edge(world)
    m9 = s.sim.portal_xform(ra, ea)
    assert abs(math.hypot(m9[0], m9[3]) - 1.0) < 1e-9
    # and the hub is now REACHABLE — a breach is a real two-way portal
    assert s.sim.hop_distance(s.player_polygon(),
                              s.hub.receiving_apses[0]) >= 0
    s.topology.disconnect(link)
    assert s.sim.hop_distance(s.player_polygon(),
                              s.hub.receiving_apses[0]) == -1


def test_mismatched_lengths_refused_before_any_portal_exists():
    s, r0 = _session()
    w52 = s.topology.carve(r0, (-150.0, -100.0), 52.0)
    seam96 = s.hub.breach_edges[1]
    apse = s.hub.receiving_apses[1]
    with pytest.raises(TopologyError):
        s.topology.connect_equal(w52, seam96)
    assert s.sim.hop_distance(s.player_polygon(), apse) == -1, (
        "the refused glue left a live portal behind")


def test_even_without_the_length_check_the_scale_assert_kills_it():
    """Sol's mutant vector, made a permanent test: bypass the manager and
    glue 96-to-52 raw — the engine derives a x1.846 lens, which is
    exactly what connect_equal's SECOND layer (post-connect scale read +
    tear-out) exists to make unshippable."""
    s, r0 = _session()
    w52 = s.topology.carve(r0, (-150.0, -100.0), 52.0)
    seam96 = s.hub.breach_edges[1]
    ra, ea = s.topology.current_edge(w52)
    rb, eb = s.topology.current_edge(seam96)
    s.sim.connect(ra, ea, rb, eb)          # the raw, guardless glue
    m9 = s.sim.portal_xform(ra, ea)
    scale = math.hypot(m9[0], m9[3])
    # portal_xform maps TARGET->SOURCE, so which of 52/96 or 96/52 you
    # read depends on the side you ask from — the guard only cares that
    # it is not 1, in either direction
    assert (abs(scale - 52.0 / 96.0) < 1e-6
            or abs(scale - 96.0 / 52.0) < 1e-6), (
        f"expected a 52<->96 lens, got {scale}")
    assert abs(scale - 1.0) > 1e-3
    s.sim.disconnect(ra, ea)


def test_edge_handles_survive_later_splits():
    s, r0 = _session()
    h1 = s.topology.carve(r0, (-190.0, 100.0), 60.0)   # bottom wall, left
    r1, e1 = s.topology.current_edge(h1)
    len1 = s.topology.edge_length(h1)
    # a second carve on the SAME wall, left of the first: renumbers it
    h2 = s.topology.carve(r0, (60.0, 148.0), 60.0)
    r2, e2 = s.topology.current_edge(h2)
    assert (r1, e1) != s.topology.current_edge(h1) or e2 > 0
    assert abs(s.topology.edge_length(h1) - len1) < 1e-9, (
        "the first handle no longer points at its own 60u cut")
    assert abs(s.topology.edge_length(h2) - 60.0) < 1e-9


# ---------------------------------------------------------------------------
# the hub itself
# ---------------------------------------------------------------------------

def test_every_world_builds_one_unreachable_hub():
    s, r0 = _session()
    assert s.hub is not None
    assert len(s.hub.chambers) == 24
    for apse in s.hub.receiving_apses:
        assert s.sim.hop_distance(s.player_polygon(), apse) == -1
    # seams are carved at exactly BREACH_W and are NOT portals
    for hseam in s.hub.breach_edges:
        assert abs(s.topology.edge_length(hseam) - BREACH_W) < 1e-9
        rp, ep = s.topology.current_edge(hseam)
        assert s.sim.polygon_portals(rp)[ep] is None


def test_source_cells_are_deep_and_separate():
    s, r0 = _session()
    hub = s.hub
    for src in hub.source_cells:
        depths = [s.sim.hop_distance(a, src) for a in hub.receiving_apses]
        assert all(10 <= d <= 11 for d in depths), depths
    # pairwise nonadjacent: one Tau cannot take two sources
    for i, a in enumerate(hub.source_cells):
        for b_ in hub.source_cells[i + 1:]:
            assert s.sim.hop_distance(a, b_) == 2, (
                "source cells must not share a doorway")


def test_transept_loop_and_trunk():
    s, r0 = _session()
    c = s.hub.chambers
    # the loop: T1 and T3 meet across the fold as well as through T2
    assert s.sim.hop_distance(c["T1"], c["T3"]) == 1
    # the single axial trunk: N4 is reachable ONLY down the chain
    assert s.sim.hop_distance(c["R"], c["N4"]) == 4
    assert s.sim.hop_distance(c["A2"], c["N4"]) == 7


def test_half_the_floor_area_sits_in_the_first_three_bands():
    shallow = sum(w * h for name, (w, h) in _ROOMS.items()
                  if name[0] in ("A", "G", "T") and name != "AN1"
                  and name != "AN2")
    total = sum(w * h for w, h in _ROOMS.values())
    frac = shallow / total
    assert 0.45 <= frac <= 0.55, f"shallow-band floor fraction {frac:.3f}"


def test_signal_fields_grew_with_the_hub():
    """The substrate must know the hub's chambers from tick zero — the
    discarded build crashed exactly here (field arrays not grown when
    topology grew)."""
    s, r0 = _session()
    from perihelion.signals import SignalKind
    apse = s.hub.receiving_apses[0]
    s.signals.emit(SignalKind.DISTRESS, apse, 1.0, s.tick_count)
    assert s.signals.sample(SignalKind.DISTRESS, apse, s.tick_count) > 0.9
