"""U10 (settlement half) gate — leader-anchored, leader-oblivious
garrisons.

Sol's vectors: with a Warden physically present in a quiet chamber, two
followers settle at EXACTLY the 720-tick hold boundary (719 -> none);
pulling the Warden at 600 prevents settlement; pulling it after 720
leaves the settlers; a third latecomer cannot settle without it. The
Warden's own record never grows follower/base/command fields. A lone
holder emits Reach; a pair emits Interior. Settled agents ignore the
field quorum but still wake on sight — they fight normally.
"""
from __future__ import annotations

from perihelion.coordination import SETTLE_HOLD_TICKS
from perihelion.levels import LevelBuilder
from perihelion.signals import SignalKind
from perihelion.sim import GameSession, InputFrame


def _quiet_world():
    """The garrison chamber sits FOUR hops from the player, past a bend —
    beyond sightlines, with no noise anywhere."""
    b = LevelBuilder("GARR", 1)
    rooms = [b.rect(i * 300, 0, 300, 200) for i in range(4)]
    bend = b.rect(900, 200, 200, 200)
    for i in range(3):
        b.connect(rooms[i], 2, rooms[i + 1], 0)
    b.connect(rooms[3], 1, bend, 3)
    b.player(rooms[0], (60, 100))
    return b.build(), rooms, bend


def _spawn_garrison(s, chamber, followers=2):
    w = s.spawn_enemy(chamber, (0.0, 0.0), "warden")
    # authored wardens in the shipped levels are posted guardians; a
    # free-roaming leader drifts rooms in minutes and no base can emerge
    # around it (the settle rule only cares that the leader IS present)
    s.enemies[w]["tether"] = True
    fs = [s.spawn_enemy(chamber, (60.0 - 40.0 * i, 40.0), "husk")
          for i in range(followers)]
    return w, fs


def _run(s, ticks):
    for _ in range(ticks):
        s.tick(InputFrame())


def test_settlement_lands_at_the_hold_boundary():
    level, rooms, bend = _quiet_world()
    s = GameSession(level, seed=4)
    w, (f1, f2) = _spawn_garrison(s, bend)
    _run(s, SETTLE_HOLD_TICKS - 20)
    assert s.enemies[f1].get("garrison") is None
    assert s.enemies[f2].get("garrison") is None
    _run(s, 60)
    assert s.enemies[f1].get("garrison") == bend, "follower one settled"
    assert s.enemies[f2].get("garrison") == bend, "follower two settled"


def test_no_warden_no_settlement_and_persistence_after_departure():
    level, rooms, bend = _quiet_world()
    s = GameSession(level, seed=4)
    w, (f1, f2) = _spawn_garrison(s, bend)
    _run(s, 600)
    s._damage_enemy(w, 9999.0, s.sim.get(w).pos.offset(1.0, 0.0), 0.0, source="test")
    _run(s, SETTLE_HOLD_TICKS)
    assert s.enemies[f1].get("garrison") is None, (
        "settlement without a present Warden")
    # now the persistence side: settle fully, THEN remove the Warden
    s2 = GameSession(level, seed=4)
    w2, (g1, g2) = _spawn_garrison(s2, bend)
    _run(s2, SETTLE_HOLD_TICKS + 60)
    assert s2.enemies[g1].get("garrison") == bend
    s2._damage_enemy(w2, 9999.0, s2.sim.get(w2).pos.offset(1.0, 0.0), 0.0, source="test")
    late = s2.spawn_enemy(bend, (-70.0, -40.0), "husk")
    _run(s2, SETTLE_HOLD_TICKS + 120)
    assert s2.enemies[g1].get("garrison") == bend, "settlers persist"
    assert s2.enemies[late].get("garrison") is None, (
        "a latecomer cannot settle without the Warden")


def test_warden_record_never_grows_command_fields():
    level, rooms, bend = _quiet_world()
    s = GameSession(level, seed=4)
    w, fs = _spawn_garrison(s, bend)
    _run(s, SETTLE_HOLD_TICKS + 120)
    for key in s.enemies[w]:
        for forbidden in ("follower", "base", "command", "garrison"):
            assert forbidden not in key, (
                f"the Warden's record grew '{key}' — the leader must stay "
                f"completely oblivious")


def test_lone_holder_marks_reach_pair_holds_interior():
    level, rooms, bend = _quiet_world()
    s = GameSession(level, seed=4)
    w, (f1,) = _spawn_garrison(s, bend, followers=1)
    _run(s, SETTLE_HOLD_TICKS + 180)
    t = s.tick_count
    assert s.signals.sample(SignalKind.GARRISON_REACH, bend, t) > 0.0, (
        "a lone holder must mark the way")
    assert s.signals.sample(SignalKind.GARRISON_INTERIOR, bend, t) == 0.0, (
        "one body is not a wire")
    s.spawn_enemy(bend, (-70.0, -40.0), "husk")
    _run(s, SETTLE_HOLD_TICKS + 180)
    t = s.tick_count
    assert s.signals.sample(SignalKind.GARRISON_INTERIOR, bend, t) > 0.0, (
        "a settled pair must hold the wire")


def test_settled_agents_ignore_the_field_quorum_but_wake_on_sight():
    level, rooms, bend = _quiet_world()
    s = GameSession(level, seed=4)
    w, (f1, f2) = _spawn_garrison(s, bend)
    _run(s, SETTLE_HOLD_TICKS + 60)
    assert s.enemies[f1].get("garrison") == bend
    # scream the fields at them from the neighbor chamber: unsettled
    # agents would cascade; settlers must not answer
    for _ in range(300):
        s.signals.emit(SignalKind.NOISE, rooms[3], 0.9, s.tick_count)
        s.signals.emit(SignalKind.DISTRESS, rooms[3], 0.5, s.tick_count)
        s.tick(InputFrame())
    assert s.enemies[f1]["state"] == "idle", (
        "a settled agent answered an outside call")
    # but the intruder WALKING IN is fought normally
    s.reseat_player(bend, (-80.0, -60.0))
    woke = False
    for _ in range(120):
        s.tick(InputFrame())
        if s.enemies.get(f1, {}).get("state") in ("waking", "hunt") \
                or f1 not in s.enemies:
            woke = True
            break
    assert woke, "a settled agent must still fight what it sees"
