"""Perception asks about a NEIGHBOURHOOD, so it searches the polygon graph.

`Sim.find_closest_faction_member_with_los` walks outward from the observer
once, develops each chamber it reaches into the observer's space, and reads
candidates out of those chambers' entity indexes. What it must never do —
and what the code it replaced did — is take every body in the world and run
a route search per body back to the observer: on a full level that was ~270
route searches per gun per tick, thirty-six guns, and it ate the entire
frame budget while the answer only ever concerned one room and its
neighbours.

These guards cover both halves: that the answer is right (nearest, sighted,
in range, within the hop cap, committed to a held target) and that getting
it does not cost more because the far side of the world is crowded.
"""

from __future__ import annotations

import time

import necore

SQUARE = [(0.0, 0.0), (0.0, 100.0), (100.0, 100.0), (100.0, 0.0)]
FOE = 1          # the faction under test
FRIEND = 0       # a different faction, must never be returned
HOPS = 12
FAR = 1e9


def corridor(n: int):
    """`n` chambers in a line; chamber k's centre is 100k from the first."""
    sim = necore.Sim()
    ids = [sim.add_polygon(SQUARE) for _ in range(n)]
    for i in range(n - 1):
        sim.connect(ids[i], 2, ids[i + 1], 0)
    return sim, ids


def spawn(sim, polygon, x, y, faction, radius=5.0):
    return sim.spawn(sim.place(polygon, x, y), radius, 1.0, faction)


def test_it_returns_the_nearest_of_the_faction():
    sim, ids = corridor(4)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    spawn(sim, ids[3], 0.0, 0.0, FOE)          # 300 away
    near = spawn(sim, ids[1], 0.0, 0.0, FOE)   # 100 away
    spawn(sim, ids[2], 0.0, 0.0, FOE)          # 200 away

    got = sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR)
    assert got is not None
    assert got.entity_id == near
    assert abs(got.distance - 100.0) < 1e-6
    assert got.portal_depth == 1


def test_it_never_returns_another_faction():
    sim, ids = corridor(3)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    spawn(sim, ids[1], 0.0, 0.0, FRIEND)       # nearer, wrong faction
    foe = spawn(sim, ids[2], 0.0, 0.0, FOE)

    got = sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR)
    assert got is not None and got.entity_id == foe


def test_range_excludes_a_body_the_graph_can_reach():
    sim, ids = corridor(4)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    spawn(sim, ids[2], 0.0, 0.0, FOE)           # 200 away

    assert sim.find_closest_faction_member_with_los(eye, FOE, HOPS, 150.0) is None
    got = sim.find_closest_faction_member_with_los(eye, FOE, HOPS, 250.0)
    assert got is not None and abs(got.distance - 200.0) < 1e-6


def test_the_hop_cap_bounds_how_deep_it_looks():
    sim, ids = corridor(5)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    spawn(sim, ids[3], 0.0, 0.0, FOE)           # three doorways away

    assert sim.find_closest_faction_member_with_los(eye, FOE, 2, FAR) is None
    assert sim.find_closest_faction_member_with_los(eye, FOE, 3, FAR) is not None


def test_a_body_behind_another_body_is_not_the_nearest_sighted_one():
    """The sightline is a real ray: the front body occludes the back one,
    so the back one is not reported even when it is the only candidate."""
    sim, ids = corridor(2)
    eye = spawn(sim, ids[0], -40.0, 0.0, FRIEND)
    blocker = spawn(sim, ids[0], 0.0, 0.0, FOE, radius=30.0)
    behind = spawn(sim, ids[0], 40.0, 0.0, FOE, radius=2.0)

    got = sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR)
    assert got is not None and got.entity_id == blocker

    sim.remove(blocker)
    got = sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR)
    assert got is not None and got.entity_id == behind


def test_a_held_target_is_kept_over_a_closer_one():
    """Target commitment: a gun already tracking a body does not swing to
    whatever drifts closer, or it never finishes anything it starts."""
    sim, ids = corridor(4)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    held = spawn(sim, ids[2], 0.0, 0.0, FOE)     # 200 away, straight ahead
    # off the sightline to `held` — a body standing IN it occludes it, and
    # then the gun has genuinely lost the target rather than kept it
    closer = spawn(sim, ids[1], 0.0, 40.0, FOE)  # ~108 away

    got = sim.find_closest_faction_member_with_los(
        eye, FOE, HOPS, FAR, 0, held)
    assert got is not None and got.entity_id == held

    # ... but only while it still holds: out of range, the search resumes
    got = sim.find_closest_faction_member_with_los(
        eye, FOE, HOPS, 150.0, 0, held)
    assert got is not None and got.entity_id == closer


def test_a_dead_held_target_does_not_blind_the_search():
    sim, ids = corridor(3)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    gone = spawn(sim, ids[1], 0.0, 0.0, FOE)
    other = spawn(sim, ids[2], 0.0, 0.0, FOE)
    sim.remove(gone)

    got = sim.find_closest_faction_member_with_los(
        eye, FOE, HOPS, FAR, 0, gone)
    assert got is not None and got.entity_id == other


def test_an_empty_neighbourhood_answers_nothing():
    sim, ids = corridor(3)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    spawn(sim, ids[1], 0.0, 0.0, FRIEND)
    assert sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR) is None


def _time_query(sim, eye, calls=300):
    t0 = time.perf_counter()
    for _ in range(calls):
        sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR)
    return time.perf_counter() - t0


def test_the_cost_does_not_follow_the_worlds_population():
    """THE LAW. A crowd on the far side of the level is not the observer's
    problem. Answering must cost what the neighbourhood costs.

    The 4x ceiling is deliberately loose — this is guarding an order of
    magnitude, not a stopwatch. The scan this replaced was ~80x slower on
    the populated world and would fail this by a mile."""
    sim, ids = corridor(20)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    spawn(sim, ids[1], 0.0, 0.0, FOE)
    empty = min(_time_query(sim, eye) for _ in range(3))

    # a thousand bodies packed into the far end of the corridor, every one
    # of them a candidate the old scan would have route-searched
    for i in range(1000):
        spawn(sim, ids[15 + i % 5], (i % 20) * 4.0 - 40.0,
              (i // 20 % 20) * 4.0 - 40.0, FOE, radius=1.0)
    crowded = min(_time_query(sim, eye) for _ in range(3))

    assert crowded < empty * 4.0, (
        f"population leaked into the query: {empty * 1e3:.2f}ms empty vs "
        f"{crowded * 1e3:.2f}ms with 1000 far bodies")


def test_the_crowd_does_not_change_the_answer_either():
    """The speed is worthless if the walk skipped someone it should see."""
    sim, ids = corridor(20)
    eye = spawn(sim, ids[0], 0.0, 0.0, FRIEND)
    near = spawn(sim, ids[1], 0.0, 0.0, FOE)
    for i in range(500):
        spawn(sim, ids[15 + i % 5], (i % 20) * 4.0 - 40.0, 0.0, FOE, radius=1.0)

    got = sim.find_closest_faction_member_with_los(eye, FOE, HOPS, FAR)
    assert got is not None and got.entity_id == near
