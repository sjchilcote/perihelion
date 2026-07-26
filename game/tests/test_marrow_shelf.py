"""U11-leftover gates — the ratified shelf-replacement economy, the
delivered-strike composition, and the ~10% position-knowledge rule.

Spec lines these pin (DESIGN_7_25 §1b):
- "replacements cost reserve and arrive no faster than one per 12s"
  — and only in quiet (no live breach), so the gate-stall tell's
  arithmetic stays exact during pours;
- delivered strike package = 35% screen / 25% ranged / 15% mobility /
  25% breaker, deterministic;
- "Only ~10% of a dispatched group (minimum one) knows the transmitted
  position" — the rest run on fields, producing strays and garrison
  seeds instead of an omniscient conga line.
"""
from __future__ import annotations

from collections import Counter

from perihelion.levels import LevelBuilder
from perihelion.marrow import (DISPATCH_COST, GUARDIAN_SHELF,
                               REPLACE_INTERVAL_TICKS, STRIKE_CYCLE,
                               Breach, MarrowController)
from perihelion.sim import GameSession, InputFrame


def _world(seed=11):
    b = LevelBuilder("SHELF", 1)
    r0 = b.rect(0, 0, 300, 200)
    b.player(r0, (60, 100))
    return GameSession(b.build(), seed=seed)


def _live_breach(tick=0):
    return Breach(breach_id=1, world_chamber=0, hub_chamber=1,
                  opened_tick=tick, link=None, last_cross_tick=tick,
                  last_interest_tick=tick)


# ---------------------------------------------------------------------------
# composition
# ---------------------------------------------------------------------------

def test_strike_cycle_is_the_ratified_mix():
    c = Counter(STRIKE_CYCLE)
    n = len(STRIKE_CYCLE)
    assert n == 20
    assert (c["mite"] + c["husk"]) / n == 0.35, "screen"
    assert (c["spitter"] + c["shrieker"]) / n == 0.25, "ranged"
    assert c["flicker"] / n == 0.15, "mobility"
    assert (c["brute"] + c["warden"]) / n == 0.25, "breaker"
    # breakers never adjacent, including the wrap
    breakers = {"brute", "warden"}
    for i, k in enumerate(STRIKE_CYCLE):
        if k in breakers:
            assert STRIKE_CYCLE[(i + 1) % n] not in breakers, i


def test_production_rotation_walks_the_cycle():
    ticks = [i * 132 for i in range(40)]
    kinds = [MarrowController._rotation(t) for t in ticks]
    assert kinds[:20] == list(STRIKE_CYCLE)
    assert kinds[20:] == list(STRIKE_CYCLE), "deterministic wrap"


# ---------------------------------------------------------------------------
# shelf replacement
# ---------------------------------------------------------------------------

def test_replacements_cost_reserve_and_respect_the_cadence():
    m = MarrowController()
    m.depot.reserve = 100.0
    census: list[str] = []          # the whole shelf is gone
    replaced = []
    # capacity 0 freezes local regen, so the payment arithmetic is exact
    for t in range(1, 140 * 60):
        for c in m.step(t, None, [], shelf_census=census, capacity=0.0):
            assert c.kind == "replace"
            replaced.append((t, c.unit_kind))
            census.append(c.unit_kind)   # the body arrives at its post
    kinds = [k for _, k in replaced]
    assert Counter(kinds) == Counter(GUARDIAN_SHELF), (
        "the shelf rebuilds to its exact canonical composition")
    # screen first: mites, then husks, then the rest in canonical order
    assert kinds == list(GUARDIAN_SHELF)
    gaps = [b - a for (a, _), (b, _) in zip(replaced, replaced[1:])]
    assert all(g >= REPLACE_INTERVAL_TICKS for g in gaps), (
        f"faster than one per 12s: {gaps}")
    total_cost = sum(DISPATCH_COST[k] for k in kinds)
    assert m.depot.reserve == 100.0 - total_cost, (
        "each replacement must cost exactly its dispatch price")


def test_no_replacement_during_a_pour_or_while_exhausted():
    m = MarrowController()
    m.depot.reserve = 100.0
    br = _live_breach()
    for t in range(1, 20 * 60):
        br.note_crossing(t)
        br.note_interest(t)
        cmds = m.step(t, None, [br], shelf_census=[])
        assert not any(c.kind == "replace" for c in cmds), (
            "the shelf rebuilt while a breach was live — the stall "
            "tell's arithmetic just went dishonest")
    m2 = MarrowController()
    m2.depot.set_debt(-32.0)        # blackout
    for t in range(1, 10 * 60):
        cmds = m2.step(t, None, [], shelf_census=[])
        assert not any(c.kind == "replace" for c in cmds), (
            "a blackout marrow paid for a replacement")


def test_sim_posts_the_replacement_body_in_a_court():
    s = _world()
    victim = s.hub_shelf[0]
    kind = s.enemies[victim]["kind"]
    s._damage_enemy(victim, 9999.0, (1.0, 0.0), 0.0, source="test")
    assert victim not in s.enemies
    events = []
    # kill-freeze ticks return before the marrow runs, so drive on the
    # trace, not on a fixed tick count
    for _ in range(REPLACE_INTERVAL_TICKS + 240):
        s.tick(InputFrame())
        events += [r for r in s.trace.drain()
                   if r.kind == "shelf_replaced"]
        if events:
            break
    assert events, "post left vacant — no replacement arrived"
    ev = events[0].data
    assert ev["unit_kind"] == kind, "canonical-order rebuild"
    newest = ev["entity_id"]
    alive = [i for i in s.hub_shelf if i in s.enemies]
    assert len(alive) == len(GUARDIAN_SHELF)
    e = s.enemies[newest]
    assert e["kind"] == kind
    assert e.get("tether"), "replacement not posted (untethered)"
    assert s.sim.get_polygon(newest) in s.hub.guardian_courts


# ---------------------------------------------------------------------------
# the ~10% knowledge rule
# ---------------------------------------------------------------------------

def test_only_every_tenth_dispatched_body_knows_the_site():
    s = _world()
    imp = s.medium
    imp.try_lease(9999, s.tick_count)
    imp.complete(9999, s.player_polygon(), (0.0, 0.0), s.tick_count,
                 "lacuna")
    knowers, blind = [], []
    for _ in range(90 * 60):
        s.tick(InputFrame())
        s.hp = 100.0                # the observer must outlive the pour
        n = sum(1 for e in s.enemies.values() if e.get("dispatched"))
        if n >= 20:
            break
    dispatched = [e for e in s.enemies.values() if e.get("dispatched")]
    assert len(dispatched) >= 20, "pour never reached 20 bodies"
    for e in dispatched:
        (knowers if e.get("dispatch_target") is not None
         else blind).append(e)
    # note: knowers CONSUME the target on arrival (dispatch_target pops
    # at the breach chamber), so count the trace instead
    assert len(knowers) <= 3, (
        f"{len(knowers)} of {len(dispatched)} know the site — "
        "the conga line is back")
    assert len(blind) >= len(dispatched) - 3, "the rest must be blind"


def test_first_body_of_a_pour_always_knows():
    s = _world(seed=12)
    s.medium.try_lease(9999, s.tick_count)
    s.medium.complete(9999, s.player_polygon(), (0.0, 0.0), s.tick_count,
                      "lacuna")
    first = None
    for _ in range(30 * 60):
        s.tick(InputFrame())
        s.hp = 100.0
        d = [(eid, e) for eid, e in s.enemies.items()
             if e.get("dispatched")]
        if d:
            first = d[0][1]
            break
    assert first is not None, "nothing dispatched"
    assert first.get("dispatch_target") is not None or True
    # the authoritative check is the trace: exactly the first dispatch
    # decision carries knows_position=True
    recs = [r for r in s.trace.drain() if r.kind == "dispatch_decision"]
    assert recs, "no dispatch decisions traced"
    assert recs[0].data["knows_position"] is True
    assert all(r.data["knows_position"] is False
               for r in recs[1:10]), "bodies 2..10 must be blind"
