"""U3 gate — the shared find/senses API.

Construction: observations are frozen value objects with no HP, reserve,
or object references; asking an ambient frame deeper than one hop raises.

Isolated vectors (Sol's three-room vector, adapted to the ratified
two-tier reach): a visible one-hop enemy appears in the ambient frame at
portal_depth 1; an off-axis enemy the portal does not expose is absent
(no wallhacks); a two-hop enemy is absent from the frame but reachable
by targeted sight down a straight corridor (the cross-room combat law:
one hop was never the law for SIGHT); a sealed door reads as a wall in
active_portals and flips when unlocked.
"""
from __future__ import annotations

import dataclasses

import pytest

from perihelion.levels import LevelBuilder
from perihelion.senses import PortalSense, SenseHit, VISION_HOPS
from perihelion.sim import GameSession, InputFrame


def _corridor3():
    """A -- B -- C in a straight line, full-width portals: a clean
    sightline runs all the way down."""
    b = LevelBuilder("SENSE3", 1)
    ra = b.rect(0, 0, 200, 200)
    rb = b.rect(200, 0, 200, 200)
    rc = b.rect(400, 0, 200, 200)
    b.connect(ra, 2, rb, 0)
    b.connect(rb, 2, rc, 0)
    b.player(ra, (100, 100))
    return b.build(), ra, rb, rc


def _elbow():
    """A short room A whose full right wall is the doorway into a much
    taller room B (the splitter cuts B's long wall to match): the parts of
    B beyond the door span are genuinely behind the wall from A — one hop
    away, but not exposed by the portal."""
    b = LevelBuilder("SENSEL", 1)
    ra = b.rect(0, 0, 200, 100)      # door = A's full wall, y 0..100
    rb = b.rect(200, 0, 300, 200)    # B continues to y 200 behind the wall
    b.player(ra, (40, 50))
    return b.build(), ra, rb


# ---------------------------------------------------------------------------
# construction
# ---------------------------------------------------------------------------

def test_observations_are_frozen_values():
    assert dataclasses.fields(SenseHit)
    h = SenseHit(entity_id=1, kind="husk", faction="testator", role="fighter",
                 polygon=0, position=(1.0, 2.0), distance=3.0, portal_depth=0,
                 state_tags=frozenset())
    with pytest.raises(dataclasses.FrozenInstanceError):
        h.distance = 99.0
    names = {f.name for f in dataclasses.fields(SenseHit)}
    for forbidden in ("hp", "reserve", "hub", "session", "enemy"):
        assert forbidden not in names


def test_frame_deeper_than_one_hop_raises():
    level, ra, rb, rc = _corridor3()
    s = GameSession(level, seed=2)
    with pytest.raises(ValueError):
        s.senses.frame(s.pid, portal_depth=2)


# ---------------------------------------------------------------------------
# the three-room vector
# ---------------------------------------------------------------------------

def test_one_hop_visible_enemy_appears_two_hop_absent_from_frame():
    level, ra, rb, rc = _corridor3()
    s = GameSession(level, seed=2)
    near = s.spawn_enemy(rb, (0.0, 0.0), "husk")      # B, on the axis
    deep = s.spawn_enemy(rc, (0.0, 0.0), "brute")     # C, two hops
    frame = s.senses.frame(s.pid)
    ids = {h.entity_id: h for h in frame.hits}
    assert near in ids, "visible one-hop enemy missing from the frame"
    assert ids[near].portal_depth == 1
    assert ids[near].kind == "husk"
    assert deep not in ids, "two-hop enemy leaked into a one-hop frame"


def test_off_axis_body_one_hop_away_is_not_seen():
    level, ra, rb = _elbow()
    s = GameSession(level, seed=2)
    # B centroid is authored (350, 100): the hidden husk sits at authored
    # (330, 190) — beyond the y 0..100 door span, behind real wall; the
    # visible one sits at B's centroid, square in the doorway's cone
    hidden = s.spawn_enemy(rb, (-20.0, 90.0), "husk")
    visible = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    ids = {h.entity_id for h in s.senses.frame(s.pid).hits}
    assert visible in ids, "the doorway-cone husk should be seen (control)"
    assert hidden not in ids, (
        "a body the portal does not expose was 'seen' — wallhack")


def test_targeted_sight_runs_deeper_than_the_frame():
    level, ra, rb, rc = _corridor3()
    s = GameSession(level, seed=2)
    deep = s.spawn_enemy(rc, (0.0, 0.0), "brute")
    hit = s.senses.sight_of(deep, s.pid)   # the ENEMY sees the PLAYER
    assert hit is not None, "straight two-hop sightline denied"
    assert hit.portal_depth == 2
    assert hit.kind == "player"
    # the position is in the OBSERVER's local frame: aiming at it must
    # point back down the corridor (negative x from C toward A)
    assert hit.position[0] < 0.0


def test_sight_respects_the_vision_cap():
    b = LevelBuilder("SENSE5", 1)
    polys = [b.rect(i * 200, 0, 200, 200) for i in range(VISION_HOPS + 3)]
    for i in range(len(polys) - 1):
        b.connect(polys[i], 2, polys[i + 1], 0)
    b.player(polys[0], (100, 100))
    s = GameSession(b.build(), seed=2)
    far = s.spawn_enemy(polys[VISION_HOPS + 1], (0.0, 0.0), "husk")
    assert s.senses.sight_of(far, s.pid) is None, (
        f"sight beyond {VISION_HOPS} hops must not resolve")


# ---------------------------------------------------------------------------
# portals
# ---------------------------------------------------------------------------

def test_sealed_door_reads_as_wall_until_unlocked():
    b = LevelBuilder("SENSED", 1)
    ra = b.rect(0, 0, 200, 200)
    rb = b.rect(200, 0, 200, 200)
    b.door(ra, 2, rb, 0, "red")
    b.player(ra, (100, 100))
    s = GameSession(b.build(), seed=2)
    before = {p.edge: p for p in s.senses.active_portals(s.pid)}
    assert not any(p.active for p in before.values()), (
        "a sealed door read as a live portal")
    s.keys.add("red")
    s._unlock_doors("red")
    after = s.senses.active_portals(s.pid)
    assert any(p.active and p.target_polygon == rb for p in after), (
        "unlocking did not surface the portal to the senses")


def test_engagement_flows_through_the_senses():
    """The AI's target acquisition consumes sight_of — a husk two rooms
    down a straight corridor closes in on the player (the cross-room
    combat law, now through the shared infrastructure)."""
    level, ra, rb, rc = _corridor3()
    s = GameSession(level, seed=2)
    eid = s.spawn_enemy(rc, (0.0, 0.0), "husk")
    s.enemies[eid]["state"] = "hunt"
    d0 = s.sim.hop_distance(s.sim.get_polygon(eid), s.player_polygon())
    for _ in range(240):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
    d1 = s.sim.hop_distance(s.sim.get_polygon(eid), s.player_polygon())
    assert d1 < d0, "the deep-sighted hunter never closed the distance"
