"""U5 gate — coordination behaviors on the signal substrate.

Pure-function vectors first (the ratified arithmetic, exactly), then
sim vectors: quorum cascade demographics (a three-agent corridor flips
at least twice as readily as a twelve-agent hall), priority-budget
flocking (opposed demands do not cancel), the raid fan (~1/3 second
routes), deterministic stand-down at 300 quiet ticks, danger-hold at a
deadly doorway, and the structural gate: the omniscient wake/pursuit
paths are GONE (no alert_enemies, no next_edge-to-the-player's-address
in the hunt).
"""
from __future__ import annotations

import inspect
import math
import random

from perihelion import coordination as coord
from perihelion.levels import LevelBuilder
from perihelion.signals import SignalKind
from perihelion.sim import GameSession, InputFrame


# ---------------------------------------------------------------------------
# pure vectors
# ---------------------------------------------------------------------------

def test_quorum_fraction_exact_values():
    e = coord.quorum_excitation(0.60, 0.0)
    assert e == 1.0
    assert abs(coord.quorum_fraction(0, 3, e) - 1 / 4) < 1e-12
    assert abs(coord.quorum_fraction(0, 6, e) - 1 / 7) < 1e-12
    assert abs(coord.quorum_fraction(0, 12, e) - 1 / 13) < 1e-12
    h3 = coord.commit_hazard(1 / 4, 0.35)
    h6 = coord.commit_hazard(1 / 7, 0.35)
    h12 = coord.commit_hazard(1 / 13, 0.35)
    assert h3 > h6 > h12, "hazard must strictly decrease with hall size"


def test_sparse_rooms_flip_at_least_twice_as_often():
    """Over 1000 independent spawn thresholds: same excitation, two
    seconds of decision beats — the three-agent corridor must commit at
    least twice as many agents as the twelve-agent hall."""
    rng = random.Random(7)
    beats = 12          # 2s at one decision per 10 ticks
    commits = {3: 0, 12: 0}
    for n in commits:
        for _ in range(1000):
            thr = rng.uniform(*coord.QUORUM_THRESHOLD_BAND)
            f = coord.quorum_fraction(0, n, 1.0)
            p = coord.commit_probability(f, thr)
            if any(rng.random() < p for _ in range(beats)):
                commits[n] += 1
    assert commits[3] >= 2 * commits[12], commits
    assert commits[3] > 100, f"cascades never start: {commits}"


def test_priority_budget_never_averages_into_the_doorframe():
    ax, ay = coord.allocate_acceleration(
        100.0, [(0, -100.0, 0.0), (1, 100.0, 0.0)])
    assert ax == -100.0 and ay == 0.0, (
        "separation must win outright, not cancel to zero")
    # with budget to spare, the remainder chases
    ax, ay = coord.allocate_acceleration(
        100.0, [(0, -40.0, 0.0), (1, 100.0, 0.0)])
    assert abs(ax - 20.0) < 1e-9      # -40 then +60 of the remainder


def test_choose_route_fans():
    assert coord.choose_route(2, 5, raid_member=False) == 2
    assert coord.choose_route(2, 5, raid_member=True) == 5
    assert coord.choose_route(2, -1, raid_member=True) == 2


def test_stand_down_rule_is_exact():
    assert not coord.wants_stand_down(True, 0.0, 10_000)
    assert not coord.wants_stand_down(False, 0.2, 10_000)
    assert not coord.wants_stand_down(False, 0.0, coord.STAND_DOWN_TICKS - 1)
    assert coord.wants_stand_down(False, 0.0, coord.STAND_DOWN_TICKS)


def test_danger_hold_rule():
    above = coord.DANGER_HOLD_LINE + 0.1
    below = coord.DANGER_HOLD_LINE - 0.1
    assert coord.danger_hold(above, 0, 0.0)
    assert not coord.danger_hold(below, 0, 0.0)        # not deadly enough
    assert not coord.danger_hold(above, 3, 0.0)        # push has gathered
    assert not coord.danger_hold(above, 0, 0.9)        # muster says go
    # the sighted-chase relaxation: a PAIR that can see the killer goes
    assert not coord.danger_hold(above, 1, 0.0, cross_peers=1)
    assert coord.danger_hold(above, 0, 0.0, cross_peers=1)


# ---------------------------------------------------------------------------
# structural: the parallel omniscient paths are gone
# ---------------------------------------------------------------------------

def test_no_parallel_wake_or_omniscient_pursuit():
    import perihelion.sim as sim_mod
    src = inspect.getsource(sim_mod)
    assert "def alert_enemies" not in src, (
        "the hop-wake route must not survive as a parallel system")
    hunt = inspect.getsource(sim_mod.GameSession._enemy_ai)
    assert "next_edge(polygon, ppolygon)" not in hunt, (
        "hunting without a sighting must follow the fields, not the "
        "player's address")


# ---------------------------------------------------------------------------
# sim vectors
# ---------------------------------------------------------------------------

def _chain(n_rooms, w=300, h=200):
    b = LevelBuilder("COORD", 1)
    rooms = [b.rect(i * w, 0, w, h) for i in range(n_rooms)]
    for i in range(n_rooms - 1):
        b.connect(rooms[i], 2, rooms[i + 1], 0)
    b.player(rooms[0], (100, h // 2))
    return b, rooms


def test_raid_flag_demographics():
    b, rooms = _chain(2)
    s = GameSession(b.build(), seed=11)
    n = 300
    for i in range(n):
        s.spawn_enemy(rooms[1], ((i % 10) * 25 - 120, (i // 10) * 6 - 90),
                      "mite")
    raiders = sum(1 for e in s.enemies.values() if e["raid"])
    assert 80 <= raiders <= 120, f"{raiders}/300 raid members"


def test_stand_down_exits_hunt_at_300_quiet_ticks():
    # five rooms: the far hunter is 4 hops out — beyond even a straight
    # sightline (VISION_HOPS = 3), so nothing keeps it committed
    b, rooms = _chain(5)
    s = GameSession(b.build(), seed=11)
    eid = s.spawn_enemy(rooms[4], (0.0, 0.0), "husk")
    s.enemies[eid]["state"] = "hunt"
    exit_tick = None
    for t in range(1, 400):
        s.tick(InputFrame())
        if s.enemies[eid]["state"] != "hunt":
            exit_tick = t
            break
    assert exit_tick is not None, "hunter never stood down in a dead level"
    assert abs(exit_tick - coord.STAND_DOWN_TICKS) <= 2, exit_tick
    # ...while a hunter sharing the intruder's chamber never does
    s2 = GameSession(b.build(), seed=11)
    eid2 = s2.spawn_enemy(rooms[0], (60.0, 0.0), "husk")
    s2.enemies[eid2]["state"] = "hunt"
    for t in range(1, 400):
        s2.tick(InputFrame())
        if eid2 not in s2.enemies or s2.dead:
            break
        assert s2.enemies[eid2]["state"] == "hunt"


def test_danger_hold_at_a_deadly_doorway():
    b, rooms = _chain(2)
    s = GameSession(b.build(), seed=11)
    # the far room reeks of dead kin; the near room has a lone hunter
    # drawn by noise from beyond the deadly chamber
    eid = s.spawn_enemy(rooms[1], (100.0, 0.0), "husk")
    s.enemies[eid]["state"] = "hunt"
    s.enemies[eid]["raid"] = False
    # bait: noise in the player's room; danger ON the player's room
    for t in range(1, 320):
        tk = s.tick_count + 1
        s.signals.emit(SignalKind.NOISE, rooms[0], 0.10, tk - 1)
        s.signals.emit_at_least(SignalKind.DANGER, rooms[0],
                                    coord.DANGER_HOLD_LINE + 0.15, tk - 1)
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
    assert eid in s.enemies
    assert s.sim.get_polygon(eid) == rooms[1], (
        "a lone agent crossed into a chamber that keeps killing its kind")
    assert s.signals.sample(SignalKind.MUSTER, rooms[1],
                            s.tick_count) > 0.0, (
        "the holding agent must call (Muster) at the door")
    # give it a push: four committed kin in its chamber
    for i in range(4):
        oid = s.spawn_enemy(rooms[1], (-40.0 + 30 * i, 60.0), "husk")
        s.enemies[oid]["state"] = "hunt"
    crossed = False
    for t in range(1, 600):
        tk = s.tick_count + 1
        s.signals.emit(SignalKind.NOISE, rooms[0], 0.10, tk - 1)
        s.signals.emit_at_least(SignalKind.DANGER, rooms[0],
                                    coord.DANGER_HOLD_LINE + 0.15, tk - 1)
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
        if s.sim.get_polygon(eid) == rooms[0]:
            crossed = True
            break
    assert crossed, "with a push gathered, the group must cross together"


def test_gunfire_two_hops_away_starts_a_cascade():
    b, rooms = _chain(3)
    s = GameSession(b.build(), seed=9)
    for i in range(6):
        s.spawn_enemy(rooms[2], (-100 + i * 40, 0), "husk")
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    woke = 0
    for t in range(1, 360):
        s.tick(InputFrame(ax=cx - 100, ay=cy, fire=(t % 30 == 5)))
        woke = sum(1 for e in s.enemies.values()
                   if e["state"] in ("waking", "hunt"))
        if woke >= 3:
            break
    assert woke >= 3, (
        f"gunfire two hops away woke only {woke}/6 — the field-quorum "
        f"path is not carrying the alert")


# ---------------------------------------------------------------------------
# Run-51 watch item (d): the hub-resident stalls. A relayed scream must not
# self-amplify, and a one-door hunt that cannot progress must stand down.
# ---------------------------------------------------------------------------

def _two_rooms_session():
    """Open seam: A's scream reaches B; the player shares r1."""
    b = LevelBuilder("STALL", 1)
    r0 = b.rect(0, 0, 200, 160, kind="dock")
    r1 = b.rect(200, 0, 200, 160, kind="dock")
    b.connect(r0, 2, r1, 0)
    b.player(r1, (340.0, 80.0))
    b.exit(r1, (380.0, 80.0))
    return GameSession(b.build(), seed=3)


def _corner_session():
    """r0 has ONE 40u door (a slit, not a full glued wall) and the
    player stands outside the two-slit sight cone: no line of sight,
    verified in-test."""
    b = LevelBuilder("STALLC", 1)
    r0 = b.polygon([(0, 0), (0, 160), (120, 160), (160, 100),
                    (160, 60), (120, 0)], kind="dock")
    r1 = b.rect(160, 60, 150, 40, kind="corridor")
    r2 = b.polygon([(350, 220), (430, 220), (430, -100), (350, -100),
                    (310, 60), (310, 100)], kind="dock")
    b.connect_pts(r0, (160, 80), r1, (160, 80))
    b.connect_pts(r1, (310, 80), r2, (310, 80))
    b.player(r2, (390.0, -60.0))
    b.exit(r2, (410.0, -60.0))
    return GameSession(b.build(), seed=3)


# The mutual-rescream loop is now UNREPRESENTABLE rather than flagged:
# U10's shrieker FSM rouses everything within two hops EXCEPT other
# shriekers, which run their own machine, so a scream can no longer wake
# a caller that screams back. The property is pinned where the machine
# lives, in test_shrieker_mark.py::test_rouse_leaves_other_shriekers_alone.


def test_one_door_hunt_stands_down_instead_of_grinding():
    """Run 49/51: brute 427 pushed AN1's only doorway for 7474 ticks.
    Fifteen seconds at the single door with nothing in sight ends the
    hunt on the record."""
    s = _corner_session()
    # r0 has exactly one portal; the player is outside the sight cone
    eid = s.spawn_enemy(0, (60.0, 80.0), "brute")
    e = s.enemies[eid]
    assert s.senses.sight_of(eid, s.pid) is None, "vector broken: sighted"
    s._set_enemy_state(eid, e, "hunt")
    # something calls from next door — the intruder's trail
    s.signals.emit(SignalKind.TRAIL, 1, 0.9, s.tick_count)
    t0 = s.tick_count
    edge = s._hunt_edge(eid, e, 0)
    assert edge >= 0
    e["route_stuck"] = (0, edge, t0 - 901)      # fifteen seconds ago
    e.pop("route", None)                        # cache expired, re-pick
    got = s._hunt_edge(eid, e, 0)
    assert got == -1, "one-door grind did not stand down"
    assert e["state"] == "idle"
    stood = [r for r in s.trace.drain()
             if r.kind == "coord_event"
             and r.data.get("event") == "hunt_stall_stand_down"]
    assert stood, "stand-down left no trace record"
