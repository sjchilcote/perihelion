"""U11 gate — the CORE as an organ, not a boss.

Construction: exact part counts and rooms at every world build; no
master health bar, no invulnerability state, no mandatory order, and NO
BLACKOUT TIMER FIELD anywhere — the outage is the reserve debt being
repaid.

Vectors (Sol's numbers): part HP quantized to the weapon arithmetic
(one rail kills a Caretaker/Bud, two rails an Anchor, four a Source);
collar deaths stretch dispatch 2.20 -> 3.14 -> 4.89s IMMEDIATELY;
Sources knit 2 hp/s only after 10 undamaged seconds; a Caretaker in
contact heals 6 hp/s and its death makes damage STICK; killing all
three Sources sets the reserve to exactly -32, calls stay consumed
(dry) during the blackout, and the minimal organ (1 Source, 1 Anchor,
3 Buds, 1 Caretaker) reforms only as the reserve crosses zero.
"""
from __future__ import annotations

import inspect
from collections import Counter

from perihelion.core_organ import (COLLAR_DISPATCH_FACTOR, PART_SPEC,
                                   CoreOrgan)
from perihelion.levels import LevelBuilder
from perihelion.marrow import CORE_KILL_DEBT
from perihelion.sim import WEAPONS, GameSession, InputFrame


def _world():
    b = LevelBuilder("CORE11", 1)
    r0 = b.rect(0, 0, 300, 200)
    b.player(r0, (60, 100))
    return GameSession(b.build(), seed=7)


def _rail_hit(s, eid, n=1):
    for _ in range(n):
        if eid in s.enemies:
            s._damage_enemy(eid, WEAPONS["rail"]["dmg"], s.sim.get(eid).pos.offset(1.0, 0.0), 0.0,
                            source="rail")


# ---------------------------------------------------------------------------
# construction
# ---------------------------------------------------------------------------

def test_every_world_embodies_the_exact_organ():
    s = _world()
    counts = Counter(p.kind for p in s.core.parts.values())
    for kind, (count, hp) in PART_SPEC.items():
        assert counts[kind] == count, (kind, counts)
        for p in s.core.live(kind):
            assert p.hp == hp
            assert p.part_id in s.enemies
            assert p.chamber in s.hub.chambers.values()
    # sources sit in the three separate Source Cells
    src_rooms = {p.chamber for p in s.core.live("core_source")}
    cells = {s.hub.chambers[n] for n in ("S1", "S2", "S3")}
    assert src_rooms == cells


def test_no_blackout_timer_and_no_master_bar():
    # scan CODE identifiers (not prose) for boss machinery
    import io
    import tokenize

    import perihelion.core_organ as mod
    names = {tok.string
             for tok in tokenize.generate_tokens(
                 io.StringIO(inspect.getsource(mod)).readline)
             if tok.type == tokenize.NAME}
    for forbidden in ("blackout_ticks", "blackout_timer", "master_hp",
                      "total_hp", "phase"):
        assert forbidden not in names, f"boss machinery: {forbidden}"
    # and the dataclasses carry no timer/aggregate fields
    from perihelion.core_organ import CorePart
    fields = set(CoreOrgan.__dataclass_fields__) | \
        set(CorePart.__dataclass_fields__)
    assert not any("timer" in f or "phase" in f for f in fields), fields


# ---------------------------------------------------------------------------
# weapon arithmetic against the parts
# ---------------------------------------------------------------------------

def test_part_hp_is_weapon_quantized():
    s = _world()
    bud = s.core.live("core_bud")[0].part_id
    _rail_hit(s, bud, 1)
    assert bud not in s.enemies, "one rail kills a 42hp Bud"
    anchor = s.core.live("core_anchor")[0].part_id
    _rail_hit(s, anchor, 1)
    assert anchor in s.enemies and s.enemies[anchor]["hp"] == 42.0
    _rail_hit(s, anchor, 1)
    assert anchor not in s.enemies, "two rails kill an 84hp Anchor"
    srcp = s.core.live("core_source")[0].part_id
    _rail_hit(s, srcp, 3)
    assert srcp in s.enemies and s.enemies[srcp]["hp"] == 42.0
    _rail_hit(s, srcp, 1)
    assert srcp not in s.enemies, "four rails kill a 168hp Source"


def test_collar_deaths_stretch_dispatch_immediately():
    s = _world()
    assert s.core.dispatch_factor() == 1.0
    c1, c2 = [p.part_id for p in s.core.live("core_collar")]
    _rail_hit(s, c1, 3)
    assert c1 not in s.enemies
    assert abs(s.core.dispatch_factor()
               - COLLAR_DISPATCH_FACTOR[1]) < 1e-9, "first collar: 3.14s"
    _rail_hit(s, c2, 3)
    assert abs(s.core.dispatch_factor()
               - COLLAR_DISPATCH_FACTOR[0]) < 1e-9, "second collar: 4.89s"


# ---------------------------------------------------------------------------
# regeneration and the caretaker
# ---------------------------------------------------------------------------

def test_source_knits_only_after_ten_quiet_seconds():
    o = CoreOrgan()
    o.add_part(1, "core_source", 0)
    o.parts[1].hp = 100.0
    o.parts[1].last_damaged_tick = 0
    healed = o.step_heal(599, [])
    assert not healed, "599 ticks after damage: no knitting yet"
    healed = o.step_heal(600, [])
    assert healed and healed[0][1] > 100.0, "at 600 ticks it knits"
    # rate: ~2 hp over a simulated second
    hp0 = o.parts[1].hp
    for t in range(601, 661):
        o.step_heal(t, [])
    assert abs((o.parts[1].hp - hp0) - 2.0 * (59 / 60)) < 0.1


def test_caretaker_contact_heals_and_its_death_makes_damage_stick():
    o = CoreOrgan()
    o.add_part(1, "core_anchor", 5)
    o.add_part(2, "core_caretaker", 5)
    o.parts[1].hp = 40.0
    o.parts[1].last_damaged_tick = 0
    hp0 = o.parts[1].hp
    for t in range(1, 61):
        o.step_heal(t, [1])          # in contact with the live caretaker
    assert abs((o.parts[1].hp - hp0) - 6.0) < 0.2, "6 hp/s in contact"
    o.on_destroyed(2, 100)
    hp1 = o.parts[1].hp
    for t in range(100, 700):
        o.step_heal(t, [])           # nobody left to repair it
    assert o.parts[1].hp == hp1, "with the caretaker dead, damage sticks"


# ---------------------------------------------------------------------------
# the blackout, end to end in the sim
# ---------------------------------------------------------------------------

def test_three_source_deaths_are_the_blackout_and_reform_follows():
    s = _world()
    sources = [p.part_id for p in s.core.live("core_source")]
    for i, sid in enumerate(sources):
        _rail_hit(s, sid, 4)
        assert sid not in s.enemies
        if i < 2:
            assert s.marrow.depot.reserve > 0.0, "no blackout before the last"
    assert s.marrow.depot.reserve == CORE_KILL_DEBT, (
        f"the last Source sets the reserve to exactly {CORE_KILL_DEBT}")
    # calls during the blackout are consumed dry — nothing opens
    s.medium.try_lease(999, s.tick_count)
    s.medium.complete(999, s.player_polygon(), (0.0, 0.0), s.tick_count,
                      "lacuna")
    for _ in range(120):
        s.tick(InputFrame())
    assert not s.breaches, "a blackout marrow must not open portals"
    assert s.medium.pending(s.tick_count) == 0, "the dry call was consumed"
    # the outage IS the debt: ~91s of home resupply crosses zero and the
    # minimal organ reforms — 1 Source, 1 Anchor, 3 Buds, 1 Caretaker
    for _ in range(95 * 60):
        s.tick(InputFrame())
        if s.marrow.depot.reserve > 0.0 and not s.core.blackout_fired:
            break
    assert s.marrow.depot.reserve > 0.0
    counts = Counter(p.kind for p in s.core.parts.values())
    assert counts["core_source"] == 1
    assert counts["core_anchor"] >= 1
    assert counts["core_bud"] >= 3
    assert counts["core_caretaker"] >= 1
    # production capacity reflects the gutted organ, not a reset
    assert s.core.production_capacity() < 0.5


def test_no_caller_can_animate_an_organ():
    """A shrieker rally scream (or any future _set_enemy_state caller)
    must not flip a part to 'hunt' — the freeze is enforced at the one
    state door, not as per-caller courtesy. (Caught live: the first
    everything-session crashed the music census on DANGER_CO['core_collar']
    after a scream within 2 hops of the collar chapels.)"""
    s = _world()
    part = s.core.live("core_collar")[0].part_id
    e = s.enemies[part]
    s._set_enemy_state(part, e, "hunt")
    assert e["state"] == "idle", "the one door let an organ hunt"
