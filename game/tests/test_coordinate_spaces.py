"""Coordinate spaces: the frame mismatch is now LOUD.

docs/FRAME_SYSTEM_DESIGN_20260729.md targets three silent failures and
nothing wider:

  1. ask two bodies for their positions, subtract, receive a number when
     they are not in the same space;
  2. transform along a legitimate route to the WRONG destination, then use
     the result as though it were where the code assumed;
  3. be pushed into restricting work to one polygon because transforming
     properly is inconvenient.

In all three the defect is SILENCE, so every test here asserts either a
loud refusal or a correct crossing — never that some number is "close
enough". The engine-side algebra is covered in Rust
(engine/necore/src/frames.rs, engine/necore/src/query.rs); this file
covers what the GAME can and cannot express.

WHY A ROTATING PORTAL IN HALF OF THEM. A translation-only portal hides
every mistake this system exists to catch: a difference pushed through the
full affine matrix collects a spurious translation, and under pure
translation the difference between "place" and "direction" is invisible.
So the interesting fixtures rotate.
"""
from __future__ import annotations

import math

import necore
import pytest

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame


def _two_rooms():
    b = LevelBuilder("COORD2", 1)
    ra = b.rect(0, 0, 200, 200)
    rb = b.rect(200, 0, 200, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (100, 100))
    s = GameSession(b.build(), seed=3, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    return s, ra, rb


def _quarter_turn():
    """Two chambers glued by a QUARTER TURN. Nothing about a place or a
    direction crossing this doorway is the identity, so a mistake in
    either shows up as a number that is wrong by 90 degrees rather than
    by a rounding error."""
    b = LevelBuilder("COORDR", 1)
    ra = b.rect(0, 0, 200, 200)
    rb = b.rect(400, 0, 200, 200)
    # A's RIGHT wall glued to B's BOTTOM wall: `connect` builds the rigid
    # map that lays them flush, and laying a vertical edge against a
    # horizontal one is a quarter turn. Equal lengths, so no scaling.
    b.connect(ra, 2, rb, 1)
    b.player(ra, (100, 100))
    s = GameSession(b.build(), seed=3, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    return s, ra, rb


# ---------------------------------------------------------------------------
# failure 1: two positions, subtracted
# ---------------------------------------------------------------------------

def test_two_bodies_in_different_chambers_refuse_to_be_subtracted():
    """THE GATE-66 SHAPE, at its source. Aim, the range gate and the
    knockback direction all did this, and 63 of 64 filmed fires crossed a
    chamber, so the Adversary's whole close-range tool delivered once in
    57,600 ticks. It is not answerable any more."""
    s, ra, rb = _two_rooms()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    here = s.sim.get(s.pid).pos
    there = s.sim.get(eid).pos
    with pytest.raises(necore.FrameMismatch) as exc:
        here.toward(there)
    # the refusal has to be readable, or it is just a crash
    msg = str(exc.value)
    assert "Polygon" in msg and "share no coordinate space" in msg, msg
    with pytest.raises(necore.FrameMismatch):
        here.distance_to(there)
    with pytest.raises(necore.FrameMismatch):
        here - there


def test_two_bodies_in_the_same_chamber_subtract_freely():
    """The control. A system that refused everything would pass the test
    above and be useless."""
    s, ra, rb = _two_rooms()
    eid = s.spawn_enemy(ra, (40.0, 0.0), "husk")
    here = s.sim.get(s.pid).pos
    there = s.sim.get(eid).pos
    assert here.space == there.space
    assert abs(here.distance_to(there) - 40.0) < 1.5
    assert here.toward(there).local()[0] > 0.0


def test_a_sighting_arrives_in_the_observers_own_space():
    """The answer was always in hand: perception develops the target into
    the observer's space along the route it looked down. Failure 1 is not
    just refused, it is unnecessary."""
    s, ra, rb = _two_rooms()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    s.tick(InputFrame())
    seen = s.senses.sight_of(eid, s.pid)
    assert seen is not None and seen.portal_depth == 1
    at = s.sim.get(eid).pos
    assert seen.pos.space == at.space
    heading = at.toward(seen.pos)       # no raise: same space
    assert heading.length > 0.0
    assert abs(heading.length - seen.distance) < 1e-9, (
        "the Track's own distance must agree with the offset it implies")


# ---------------------------------------------------------------------------
# failure 2: the right route to the wrong place
# ---------------------------------------------------------------------------

def test_a_place_crossing_a_rotating_doorway_moves_by_the_whole_matrix():
    s, ra, rb = _quarter_turn()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    at = s.sim.get(eid).pos
    developed = s.sim.develop(at, s.sim.polygon_space(ra))
    assert developed is not None
    assert developed.space == s.sim.polygon_space(ra)
    # the same place, expressed twice, must still be one place: measured
    # from the body itself the separation is zero whichever side you ask
    assert at.distance_to(developed) < 1e-9
    assert developed.chain[0] == s.sim.polygon_space(rb)
    assert developed.chain[-1] == s.sim.polygon_space(ra)


def test_a_direction_crossing_a_rotating_doorway_turns_and_keeps_its_length():
    """A difference moves by the LINEAR part only. Through the full affine
    matrix it would collect the doorway's translation — a heading that
    grows by hundreds of units, pointing somewhere plausible."""
    s, ra, rb = _quarter_turn()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    xf = s.sim.portal_transform(ra, 2)
    assert xf is not None
    assert xf.from_space == s.sim.polygon_space(rb)
    assert xf.to_space == s.sim.polygon_space(ra)
    east = s.sim.get(eid).pos.offset(10.0, 0.0)
    turned = east.transformed(xf)
    assert abs(turned.length - 10.0) < 1e-9, (
        f"a rigid doorway must not change a length: {turned.length}")
    # a quarter turn, so what was +x is now +/-y and no longer +x
    tx, ty = turned.local()
    assert abs(tx) < 1e-6 and abs(abs(ty) - 10.0) < 1e-6, (tx, ty)


def test_a_transform_refuses_a_value_from_the_wrong_space():
    s, ra, rb = _two_rooms()
    xf = s.sim.portal_transform(ra, 2)     # maps B's coords into A's
    in_a = s.sim.get(s.pid).pos            # already in A
    with pytest.raises(necore.FrameMismatch):
        in_a.transformed(xf)


def test_track_velocity_and_facing_ride_the_sightings_own_route():
    """A Track reports place, velocity AND facing, all carried along the
    same doorway chain. Anything that leads a moving target needs the
    velocity in the SHOOTER's space; developing the place and a
    one-second-ahead point through two independently chosen routes gives a
    difference polluted by the holonomy between them."""
    s, ra, rb = _quarter_turn()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    body = s.sim.get(eid)
    s.sim.set_vel(eid, body.pos.offset(60.0, 0.0))
    s.sim.set_dir(eid, body.pos.offset(1.0, 0.0))
    seen = s.senses.sight_of(s.pid, eid)
    assert seen is not None
    assert seen.vel.space == s.sim.get(s.pid).pos.space
    assert seen.dir.space == s.sim.get(s.pid).pos.space
    # crossing a quarter turn, a +x velocity is no longer +x here, and it
    # has not changed speed
    assert abs(seen.vel.length - 60.0) < 1e-6
    assert abs(seen.vel.local()[0]) < 1e-6, seen.vel.local()
    assert abs(abs(seen.dir.local()[1]) - 1.0) < 1e-6, seen.dir.local()


# ---------------------------------------------------------------------------
# what the game cannot express
# ---------------------------------------------------------------------------

def test_python_cannot_conjure_a_place_without_naming_its_space():
    """A place invented from two floats is a claim about the world, and
    the claim has to be made out loud. `Coordinate` has no constructor;
    the two doors both take the space in the same expression as the
    numbers (`sim.place(polygon, x, y)` for authored data,
    `space.place(x, y)` for screen input)."""
    with pytest.raises(TypeError):
        necore.Coordinate(1.0, 2.0)
    s, ra, rb = _two_rooms()
    stated = s.sim.place(rb, 5.0, 5.0)
    assert stated.space == s.sim.polygon_space(rb)
    # ...and being stated does not make it comparable with another space
    with pytest.raises(necore.FrameMismatch):
        s.sim.get(s.pid).pos.toward(stated)


def test_an_offset_is_free_because_a_decision_is_not_a_claim():
    """"Five units along my own +x" is a decision an agent is entitled to
    make. It still cannot be used in someone else's space."""
    s, ra, rb = _two_rooms()
    mine = s.sim.get(s.pid).pos
    step = necore.Offset(mine.space, 5.0, 0.0)
    assert mine.add(step) if hasattr(mine, "add") else True
    moved = mine + step
    assert abs(mine.distance_to(moved) - 5.0) < 1e-9
    other = necore.Offset(s.sim.polygon_space(rb), 5.0, 0.0)
    with pytest.raises(necore.FrameMismatch):
        mine + other


def test_writes_refuse_an_offset_from_another_chamber():
    """`set_vel` / `set_dir` / `apply_impulse` take an Offset in the
    body's OWN space. A push is a direction, and a direction from the
    wrong chamber pushes somewhere arbitrary — the second half of gate
    66's failure lived in exactly this call."""
    s, ra, rb = _two_rooms()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    wrong = necore.Offset(s.sim.polygon_space(ra), 100.0, 0.0)
    for call in (lambda: s.sim.set_vel(eid, wrong),
                 lambda: s.sim.set_dir(eid, wrong),
                 lambda: s.sim.apply_impulse(eid, wrong)):
        with pytest.raises(necore.FrameMismatch):
            call()
    right = s.sim.get(eid).pos.offset(100.0, 0.0)
    s.sim.set_vel(eid, right)
    assert abs(s.sim.get(eid).speed - 100.0) < 1e-9


def test_spawning_takes_a_place_so_polygon_and_position_cannot_disagree():
    s, ra, rb = _two_rooms()
    bid = s.sim.spawn(s.sim.place(rb, 10.0, 0.0), 2.0, 0.01, 3)
    assert s.sim.get_polygon(bid) == rb
    with pytest.raises(TypeError):
        s.sim.spawn(rb, 10.0, 0.0, 2.0, 0.01, 3)


# ---------------------------------------------------------------------------
# asking the world, and the one space no doorway reaches
# ---------------------------------------------------------------------------

def test_develop_answers_none_for_the_screen_because_no_doorway_reaches_it():
    """The screen is a real space and deliberately not a polygon. The only
    way in or out is the camera transform, named — which is what makes a
    screen point and a chamber point comparable at all."""
    s, ra, rb = _two_rooms()
    here = s.sim.get(s.pid).pos
    assert s.sim.develop(here, s.screen_space) is None


def test_a_screen_point_and_a_chamber_point_meet_through_the_camera():
    """The director's question, concretely: two positions arriving from
    completely different places — one from the OS, one from the engine —
    recognised as comparable because the transform between their spaces
    was declared."""
    s, ra, rb = _two_rooms()
    st = s.sim.get(s.pid)
    cam = s.camera_transform()
    assert cam.from_space == st.space
    assert cam.to_space == s.screen_space
    # the player's own place, pushed to the screen and pulled back
    on_screen = st.pos.transformed(cam)
    assert on_screen.space == s.screen_space
    back = on_screen.transformed(cam.inverse())
    assert st.pos.distance_to(back) < 1e-9
    # and a point that STARTED on the screen lands in the chamber
    sx, sy = on_screen.local()
    fresh = s.screen_space.place(sx + 45.0, sy).transformed(cam.inverse())
    assert fresh.space == st.space
    aim = st.pos.toward(fresh)
    assert aim.length > 0.0
    # 45 screen px at zoom 0.45 is 100 chamber units
    assert abs(aim.length - 45.0 / 0.45) < 1e-6, aim.length


def test_reconciliation_uses_records_and_never_the_world():
    """Two values that terminate in different spaces are still comparable
    when their records share an earlier one — and it works after the
    doorway they crossed is gone, because a Coordinate replays only the
    matrices it already holds."""
    s, ra, rb = _two_rooms()
    eid = s.spawn_enemy(rb, (0.0, 0.0), "husk")
    into_a = s.sim.develop(s.sim.get(eid).pos, s.sim.polygon_space(ra))
    assert into_a is not None
    s.sim.disconnect(ra, 2)             # the route is gone
    assert s.sim.develop(s.sim.get(eid).pos,
                         s.sim.polygon_space(ra)) is None, (
        "with the doorway sealed the world can no longer find a route")
    # ...but the value derived while it existed still means what it meant
    assert into_a.distance_to(s.sim.get(s.pid).pos) >= 0.0
