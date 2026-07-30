"""Firing point-blank into a captor that stands in the NEXT chamber.

THIS DEFECT WAS FOUND BY 14,400 TICKS OF REAL PLAY, not by the suite.
`_fire`'s point-blank-inside-a-grip branch handed `_damage_enemy` the
shot direction in the PLAYER's space, and a warden's grip straddles a
doorway routinely — portal geometry puts bodies in each other's laps
across a threshold. Every fixture that exercised the grip put both
bodies in one chamber, which is the one case where the bug is invisible;
gate 66 failed the Adversary's shove for exactly the same reason.

The coordinate types turned it into a crash instead of a wrong push:

    necore.FrameMismatch: entity 4459 is in Polygon 12, but the offset
    given is in Polygon 9

The fix is a named carry (`GameSession._carry`) at the damage door and
the push door, asking the world for ONE transform rather than
developing two places and differencing them.
"""
from __future__ import annotations

import necore
import pytest

from perihelion.capture import CaptureSpec
from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame


def _grip_across_a_doorway():
    """A warden gripping the player from the OTHER side of a threshold."""
    b = LevelBuilder("GRIP2", 1)
    r0 = b.rect(0, 0, 300, 300)
    r1 = b.rect(300, 0, 300, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (330, 150))
    s = GameSession(b.build(), seed=5, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    captor = s.spawn_enemy(r0, (140.0, 0.0), "warden")
    s.tick(InputFrame())
    assert s.sim.get_polygon(captor) != s.player_polygon(), (
        "the whole point of this fixture is that the grip spans a doorway")
    s.captures.begin(CaptureSpec(captor_id=captor, captive_id=s.pid,
                                 pull_speed=90.0, damage_per_second=10.0))
    return s, captor


def test_point_blank_fire_into_a_cross_chamber_captor_lands():
    s, captor = _grip_across_a_doorway()
    hp0 = s.enemies[captor]["hp"]
    s.weapon = "pistol"
    for _ in range(90):
        s.tick(InputFrame(fire=True, ax=320.0, ay=180.0))
        if captor not in s.enemies:
            break
    assert captor not in s.enemies or s.enemies[captor]["hp"] < hp0, (
        "firing inside a grip that spans a doorway did nothing")


def test_the_charged_tau_discharges_into_a_cross_chamber_captor():
    """The second site with the same shape: the tau's gripped-discharge
    branch also aimed in the player's space."""
    s, captor = _grip_across_a_doorway()
    s.weapons.append("tau")
    s.weapon = "tau"
    s.ammo["cell"] = 20
    hp0 = s.enemies[captor]["hp"]
    for t in range(200):
        # hold alt to charge, then release
        s.tick(InputFrame(alt=t % 90 < 70, ax=320.0, ay=180.0))
        if captor not in s.enemies:
            break
    assert captor not in s.enemies or s.enemies[captor]["hp"] < hp0, (
        "the charged discharge did nothing to a captor a doorway away")


def test_a_captor_with_no_route_is_released_rather_than_pulled_nowhere():
    """The honest end of the same story: if the world can find no route
    between the two, the grip is over. It does not pull the captive
    toward a number."""
    s, captor = _grip_across_a_doorway()
    assert s.captures.held_by(s.pid) == captor
    s.sim.disconnect(0, 2)          # the only doorway between them
    s.tick(InputFrame())
    assert s.captures.held_by(s.pid) is None, (
        "a grip with no route between captor and captive must release")


def test_the_carry_declines_rather_than_guessing():
    """`_carry` answers None when no route exists — and a hit whose
    direction cannot be expressed still lands, it just does not push."""
    s, captor = _grip_across_a_doorway()
    here = s.player_pos().offset(1.0, 0.0)
    there = s.sim.get(captor).pos.space
    assert s._carry(here, there) is not None
    assert s._carry(here, here.space) is here, "same space is a no-op"
    orphan = necore.Space("Nowhere")
    assert s._carry(here, orphan) is None
    hp0 = s.enemies[captor]["hp"]
    s._damage_enemy(captor, 5.0, necore.Offset(orphan, 1.0, 0.0), 200.0,
                    source="test")
    assert s.enemies[captor]["hp"] < hp0, (
        "a hit with an inexpressible direction must still hurt")
