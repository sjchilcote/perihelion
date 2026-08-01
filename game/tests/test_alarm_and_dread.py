"""The coordination mechanics added 2026-08-01, each guarded at its own
mechanism rather than through a whole session.

Gate 76 failed this diff partly for having none of these: five new
behaviours shipped with zero tests, one of them (`_seek_kin`) wired to
nothing at all while comments at two call sites claimed it ran. Every
law below is one an agent can violate silently — a field that stacks
without bound, a timer that re-arms itself, a body that flees forever —
and none of them announce themselves in a play session.
"""

from __future__ import annotations

from perihelion import coordination as coord
from perihelion.levels import LevelBuilder
from perihelion.signals import SignalKind
from perihelion.sim import GameSession, InputFrame


# --------------------------------------------------------------------
# the pure decisions
# --------------------------------------------------------------------

def test_an_alarm_does_not_need_a_vote():
    """Distress commits an agent on its own. The quorum asks what the
    neighbours are doing and is INHIBITED by calm ones; a room that
    reeks of a fight is a fact, and facts do not poll."""
    assert coord.alarmed(coord.ALARM_DISTRESS_LINE)
    assert coord.alarmed(coord.ALARM_DISTRESS_LINE + 0.5)
    assert not coord.alarmed(coord.ALARM_DISTRESS_LINE - 0.01)


def test_a_fresh_scent_beats_the_beacon_that_led_you_to_it():
    """The whole point of staging Trail over Distress: near a big fight
    Distress dwarfs Trail's hard 0.80 cap, so a summed score walks the
    hunter toward the commotion instead of the body that made it."""
    big_distress, fresh_trail = 4.55, 0.55
    blended = coord.hunt_attraction(fresh_trail, 0.0, big_distress,
                                    0.0, 0.0, locked=False)
    beacon_only = coord.hunt_attraction(0.0, 0.0, big_distress,
                                        0.0, 0.0, locked=False)
    assert blended < beacon_only + fresh_trail + 1e-9
    assert beacon_only > fresh_trail, (
        "this fixture is meaningless unless the beacon really does "
        "outweigh the scent when summed")
    # locked: the scent alone decides, and the beacon cannot pull it off
    locked_scent = coord.hunt_attraction(fresh_trail, 0.0, big_distress,
                                         0.0, 0.0, locked=True)
    locked_none = coord.hunt_attraction(0.0, 0.0, big_distress,
                                        0.0, 0.0, locked=True)
    assert locked_scent > locked_none, "a locked hunter follows the trail"
    assert locked_none == 0.0, "and the beacon contributes nothing to it"


def test_scent_lock_needs_a_trail_that_is_actually_fresh():
    assert coord.scent_lock([coord.TRAIL_LOCK])
    assert coord.scent_lock([0.0, 0.0, coord.TRAIL_LOCK + 0.2])
    assert not coord.scent_lock([coord.TRAIL_LOCK - 0.01, 0.0])
    assert not coord.scent_lock([]), "no doorways is not a lock"


def test_numbers_override_dread():
    assert coord.dread_turret(0)
    assert coord.dread_turret(coord.TURRET_DREAD_PEERS - 1)
    assert not coord.dread_turret(coord.TURRET_DREAD_PEERS)
    assert not coord.dread_turret(coord.TURRET_DREAD_PEERS + 5)


# --------------------------------------------------------------------
# the behaviours, in a running session
# --------------------------------------------------------------------

def _gun_room(kind="husk", gap=140.0):
    """One chamber, one player-side gun, one enemy that can see it."""
    b = LevelBuilder("DREAD", 1)
    r0 = b.rect(0, 0, 700, 400)
    b.player(r0, (300.0, 0.0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    s.spawn_sentry(r0, (0.0, 0.0))
    eid = s.spawn_enemy(r0, (-gap, 0.0), kind)
    s.tick(InputFrame())
    return s, eid


def test_a_lone_body_flees_a_gun_it_can_see():
    s, eid = _gun_room()
    fled = False
    for _ in range(240):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
        if s.enemies[eid].get("dread", 0) > 0:
            fled = True
            break
    assert fled, "a lone body never registered the emplacement at all"


def test_the_flight_is_bounded_and_cannot_re_arm_itself():
    """THE GATE-76 BLOCKER. Re-arming on every scan while the gun stayed
    in view turned a 90-tick withdrawal into 746 continuous ticks of
    flight with the body's whole AI suspended behind it."""
    s, eid = _gun_room()
    # THE BODY MUST SURVIVE to measure this at all: the gun kills a husk
    # in a couple hundred ticks, and a test that ends at the funeral
    # reports a short flight no matter how broken the timer is. This
    # fixture passed against the unbounded original until the hp went up.
    s.enemies[eid]["hp"] = 1e9
    longest = run = 0
    for _ in range(1800):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
        if s.enemies[eid].get("dread", 0) > 0:
            run += 1
            longest = max(longest, run)
        else:
            run = 0
    assert longest <= coord.TURRET_DREAD_TICKS + 2, (
        f"fled for {longest} consecutive ticks against a "
        f"{coord.TURRET_DREAD_TICKS}-tick budget — the timer is "
        f"re-arming itself")


def test_the_danger_mark_is_a_level_not_a_running_total():
    """A mark says 'this place kills us'. Summed instead of levelled, a
    crowd of frightened bodies drove the field to 19-23x its normal
    range, and Danger is read by the hold line, scout planting and
    routing — the fear drowned the field it was written into."""
    s, eid = _gun_room()
    poly = s.sim.get_polygon(s.pid)
    ids = [eid] + [s.spawn_enemy(poly, (-200.0, 20.0 * i), "husk")
                   for i in range(6)]
    # NOTHING MAY DIE in this fixture: a death emits 0.40 Danger of its
    # own, and 7 of them would swamp the very thing under test. Deathless
    # bodies leave the dread mark as the only writer of this field.
    for i in ids:
        s.enemies[i]["hp"] = 1e9
    gun_poly = s.sim.get_polygon(next(iter(s.sentries)))
    peak = 0.0
    for _ in range(900):
        s.tick(InputFrame())
        assert all(i in s.enemies for i in ids), "fixture invalid: a body died"
        peak = max(peak, s.signals.sample(SignalKind.DANGER, gun_poly,
                                          s.tick_count))
    assert peak <= coord.TURRET_DREAD + 1e-6, (
        f"seven frightened bodies drove Danger to {peak:.2f} against a "
        f"{coord.TURRET_DREAD} mark — it is summing, not levelling")


def test_dormant_bodies_are_not_frightened_out_of_their_ambush():
    """A dormant spotter is stone-still by design. Fear must not be the
    thing that gets it up and walking."""
    s, eid = _gun_room()
    s.enemies[eid]["dormant"] = 0.5
    for _ in range(300):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
        assert s.enemies[eid].get("dread", 0) <= 0, (
            "a dormant body fled a turret and broke its own ambush")


def test_sighting_the_player_dumps_distress_where_it_happened():
    """The alarm is a smell: without this the swarm only ever learned
    about the player from its own casualties, one at a time."""
    b = LevelBuilder("ALARM", 1)
    r0 = b.rect(0, 0, 600, 400)
    b.player(r0, (0.0, 0.0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    poly = s.sim.get_polygon(s.pid)
    before = s.signals.sample(SignalKind.DISTRESS, poly, s.tick_count)
    s.spawn_enemy(poly, (-120.0, 0.0), "husk")
    for _ in range(40):
        s.tick(InputFrame())
    after = s.signals.sample(SignalKind.DISTRESS, poly, s.tick_count)
    assert after > before + 0.1, (
        f"a body sighted the intruder and called nobody: distress "
        f"{before:.3f} -> {after:.3f}")
