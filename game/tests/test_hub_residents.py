"""U11-leftover gate — the resident hub population.

Ratified §1b composition table: residents read 60% screen / 18% ranged
/ 10% mobility / 12% breaker — 'the invaded hub reads visibly lighter
than the force it sends', an identity derived from the combat system.
Residents are ordinary agents (they hunt when hurt, unlike organ
parts), unposted (no tether), off the shelf, and invisible to the
world-side snapshot until a breach lets the worlds touch.
"""
from __future__ import annotations

from collections import Counter

from perihelion.hub import RESIDENT_PLACEMENT
from perihelion.levels import LevelBuilder
from perihelion.marrow import STRIKE_CYCLE
from perihelion.sim import GameSession

SCREEN = {"mite", "husk"}
RANGED = {"spitter", "shrieker"}
MOBILITY = {"flicker"}
BREAKER = {"brute", "warden"}


def _world():
    b = LevelBuilder("RES", 1)
    r0 = b.rect(0, 0, 300, 200)
    b.player(r0, (60, 100))
    return GameSession(b.build(), seed=13)


def test_resident_composition_is_the_ratified_table():
    kinds = [k for _, k in RESIDENT_PLACEMENT]
    n = len(kinds)
    c = Counter(kinds)

    def count(group):
        return sum(c[k] for k in group)

    # the authored canon: 11/3/2/2 of 18 — EXACT (a one-body swap is a
    # composition change, not noise), and no warden (garrisons emerge
    # from dispatched wardens; a resident warden would pre-build one)
    assert n == 18
    assert count(SCREEN) == 11
    assert count(RANGED) == 3
    assert count(MOBILITY) == 2
    assert count(BREAKER) == 2
    assert c["warden"] == 0
    # ...which sits within one body of the ratified 60/18/10/12
    for group, want in ((SCREEN, 0.60), (RANGED, 0.18),
                        (MOBILITY, 0.10), (BREAKER, 0.12)):
        assert abs(count(group) / n - want) <= 1.0 / n


def test_the_hub_reads_lighter_than_what_it_sends():
    res = Counter(k for _, k in RESIDENT_PLACEMENT)
    strike = Counter(STRIKE_CYCLE)
    n_res, n_strike = len(RESIDENT_PLACEMENT), len(STRIKE_CYCLE)
    res_breaker = sum(res[k] for k in BREAKER) / n_res
    strike_breaker = sum(strike[k] for k in BREAKER) / n_strike
    res_screen = sum(res[k] for k in SCREEN) / n_res
    strike_screen = sum(strike[k] for k in SCREEN) / n_strike
    assert res_breaker < strike_breaker, "residents must hit softer"
    assert res_screen > strike_screen, "residents must read as chaff"


def test_every_world_houses_the_residents():
    s = _world()
    placed = Counter()
    hub_chambers = set(s.hub.chambers.values())
    shelf = set(s.hub_shelf)
    for eid, e in s.enemies.items():
        chamber = s.sim.get_polygon(eid)
        if chamber in hub_chambers and eid not in shelf \
                and not e["kind"].startswith("core_"):
            placed[e["kind"]] += 1
            assert not e.get("tether"), "residents are not posted"
    assert placed == Counter(k for _, k in RESIDENT_PLACEMENT)


def test_residents_live_in_their_authored_chambers():
    s = _world()
    want = Counter((s.hub.chambers[name], kind)
                   for name, kind in RESIDENT_PLACEMENT)
    have = Counter()
    shelf = set(s.hub_shelf)
    for eid, e in s.enemies.items():
        chamber = s.sim.get_polygon(eid)
        if chamber in set(s.hub.chambers.values()) and eid not in shelf \
                and not e["kind"].startswith("core_"):
            have[(chamber, e["kind"])] += 1
    assert have == want


def test_residents_are_ordinary_agents_not_organs():
    s = _world()
    hub_chambers = set(s.hub.chambers.values())
    shelf = set(s.hub_shelf)
    victim = next(eid for eid, e in s.enemies.items()
                  if s.sim.get_polygon(eid) in hub_chambers
                  and eid not in shelf
                  and not e["kind"].startswith("core_"))
    s._damage_enemy(victim, 1.0, (1.0, 0.0), 0.0, source="test")
    assert s.enemies[victim]["state"] == "hunt", (
        "a hurt resident must fight — only organ parts stay passive")


def test_residents_stay_out_of_the_worldside_snapshot():
    s = _world()
    snap = s.snapshot()
    ids = {h["id"] for h in snap.get("enemies", [])} \
        if snap.get("enemies") and isinstance(
            next(iter(snap["enemies"])), dict) else set()
    hub_chambers = set(s.hub.chambers.values())
    hub_ids = {eid for eid in s.enemies
               if s.sim.get_polygon(eid) in hub_chambers}
    assert not (ids & hub_ids), "hub residents leaked into the snapshot"


# ---------------------------------------------------------------------------
# the cathedral's light (ratified arrival language)
# ---------------------------------------------------------------------------

def test_hub_lights_itself_at_build():
    from perihelion.hub import HUB_LIGHT_PLAN
    s = _world()
    hub_polys = set(s.hub.chambers.values())
    hub_lights = [lt for lt in s.lighting.lights
                  if lt.polygon in hub_polys and lt.kind == "static"]
    assert len(hub_lights) == len(HUB_LIGHT_PLAN)
    # every chamber is lit — no pitch-dark rooms in a built place
    lit = {lt.polygon for lt in hub_lights}
    assert lit == hub_polys, "every cathedral chamber carries a light"
    # the reliquaries burn hottest; the trunk's reach grows with depth
    by_room = {}
    for name, poly in s.hub.chambers.items():
        by_room[name] = [lt for lt in hub_lights if lt.polygon == poly]
    src_i = min(lt.intensity for n in ("S1", "S2", "S3")
                for lt in by_room[n])
    other_i = max(lt.intensity for n, ls in by_room.items()
                  if n not in ("S1", "S2", "S3") for lt in ls)
    assert src_i >= other_i, "the prize must read hottest"
    trunk = [by_room[n][0].radius for n in ("N1", "N2", "N3", "N4")]
    assert trunk == sorted(trunk) and trunk[0] < trunk[-1], (
        "the conduit ramp must carry light inward — deeper reaches "
        "farther")
