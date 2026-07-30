"""Gate run 53's confirmed blockers, pinned as tests.

Each fails on the run-53 build:

  * a body pressed into a facet by a peer that never moves held one
    bit-identical coordinate for up to 7680 ticks, because separation
    claims its 0.7 of the acceleration budget forever and the objective
    can never spend the remaining 0.3 against a wall;
  * PlayerDeath.source lied on 2 of 3 deaths -- the grip was the one
    damage door that never recorded itself;
  * the periodic instrument samples rode _marrow_tick, which sits below
    the dead/freeze early-returns, so every hitstop landing on a sample
    tick dropped it (219-236 of an expected 240 per session).
"""
from __future__ import annotations

from perihelion.levels import LevelBuilder
from perihelion.sim import SEP_FUTILE_TICKS, GameSession, InputFrame


def _tick(s, n=1, **kw):
    for _ in range(n):
        s.tick(InputFrame(**kw))


def _pinned_scene():
    """A hunter in the corner with an immovable body between it and the
    room: exactly the run-53 geometry (five hub bodies, each with a
    correct heading at its own doorway, none of them moving)."""
    b = LevelBuilder("PIN", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 200, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (500, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    # the wedged hunter, hard against the west wall of r0
    victim = s.spawn_enemy(r0, (-192.0, 0.0), "husk")
    # the immovable neighbour: a posted guardian, just off its shoulder,
    # pushing it into that wall for as long as it stands there
    wall = s.spawn_enemy(r0, (-160.0, 0.0), "brute")
    s.enemies[wall]["tether"] = True
    s._set_enemy_state(victim, s.enemies[victim], "hunt")
    return s, victim, wall


def test_a_keep_apart_demand_that_keeps_nothing_apart_yields():
    s, victim, wall = _pinned_scene()
    x0, y0 = s.sim.get(victim).pos.local()
    _tick(s, SEP_FUTILE_TICKS + 240)
    x1, y1 = s.sim.get(victim).pos.local()
    moved = abs(x1 - x0) + abs(y1 - y0)
    assert moved > 8.0, (
        f"the wedged hunter travelled {moved:.2f}u in "
        f"{SEP_FUTILE_TICKS + 240} ticks — it is still pinned")


def test_the_yield_does_not_fire_while_a_crowd_is_spreading():
    """Conservation check: the rule must not disable separation for
    bodies that are actually getting clear of each other, or it would
    trade a wall-pin for the doorframe averaging it was built to stop."""
    b = LevelBuilder("CROWD", 1)
    r0 = b.rect(0, 0, 600, 400)
    b.player(r0, (300, 200))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    ids = [s.spawn_enemy(r0, (-40.0 + 8.0 * i, -120.0), "husk")
           for i in range(4)]
    for eid in ids:
        s._set_enemy_state(eid, s.enemies[eid], "hunt")
    _tick(s, 90)
    futile = [s.enemies[eid].get("_sep_futile", 0) for eid in ids]
    assert max(futile) <= SEP_FUTILE_TICKS, (
        f"a spreading crowd was judged futile ({futile})")


def test_the_grip_records_itself_as_the_killer():
    b = LevelBuilder("GRIP2", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (200, 150))
    s = GameSession(b.build(), seed=5, screen=(640, 360), zoom=0.45)
    captor = s.spawn_enemy(r0, (215, 150), "warden")
    s._damage_player(1.0, s.player_polygon(), source="contact:brute")
    s.trace.drain()
    while not s.dead:
        s._capture_burn(s.pid, captor, 400.0)
    rec = [r for r in s.trace.drain() if r.kind == "player_death"]
    assert rec, "the grip killed him and filed no death"
    assert rec[0].data["source"] == "engulfed", (
        f"the grip's kill was filed as {rec[0].data['source']!r}")


def test_the_instrument_samples_survive_a_hitstop():
    b = LevelBuilder("SAMP", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (200, 150))
    s = GameSession(b.build(), seed=6, screen=(640, 360), zoom=0.45)
    s.spawn_enemy(r0, (120, 120), "husk")
    # park the sim in hitstop across a sampling boundary
    while (s.tick_count + 1) % 60 != 0:
        _tick(s)
    s.freeze = 5
    s.trace.drain()
    _tick(s)
    kinds = [r.kind for r in s.trace.drain()]
    assert "enemy_positions" in kinds, (
        "the position sample was skipped because the sim was paused")
    assert "reserve_sample" in kinds, "the reserve sample was skipped"


def test_the_instrument_samples_survive_death():
    b = LevelBuilder("SAMP2", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (200, 150))
    s = GameSession(b.build(), seed=6, screen=(640, 360), zoom=0.45)
    s.spawn_enemy(r0, (120, 120), "husk")
    while (s.tick_count + 1) % 60 != 0:
        _tick(s)
    s.dead = True
    s.trace.drain()
    _tick(s)
    kinds = [r.kind for r in s.trace.drain()]
    assert "reserve_sample" in kinds, "a death linger blinded the instruments"
