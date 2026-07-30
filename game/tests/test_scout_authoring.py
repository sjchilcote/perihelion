"""U15 (authoring half) gate — scouts are authored into the world.

Ratified §1b: 'authored into the world at initialization and never
produced by the CORE. Some begin dormant in quiet chambers with high
thresholds.' The shipped gauntlet4 carries 2 vagrants + 7 lacunas (5
active + 2 dormant, deep) — the count the U15 geometry migration made
room for, every home measured seam-viable; the marrow's production
cycle contains no Adversary kind, so the census only ever shrinks.
"""
from __future__ import annotations

from collections import Counter

from perihelion.levels import LevelBuilder, load_level
from perihelion.marrow import STRIKE_CYCLE, GUARDIAN_SHELF
from perihelion.sim import ADVERSARY
from perihelion.signals import SignalKind
from perihelion.sim import GameSession, InputFrame


def test_gauntlet4_authors_the_scout_census():
    level = load_level("../levels/gauntlet4.json")
    s = GameSession(level, seed=5)
    c = Counter(e["kind"] for e in s.enemies.values()
                if e["kind"] in ADVERSARY)
    assert c["vagrant"] == 2
    assert c["lacuna"] == 7
    assert s.adversary_census == {"vagrant": 2, "lacuna": 7}
    dormant = [e for e in s.enemies.values() if e.get("dormant")]
    assert len(dormant) == 2, "two deep reserve spotters sleep"
    assert all(e["kind"] == "lacuna" for e in dormant)


def test_every_scout_home_can_hold_a_breach():
    """U15 geometry migration: a call from home must be able to LAND.
    Chambers 8, 9, 20 and the 14/16 connectors were authored with walls
    consumed by doors — a 96u seam had nowhere to go and the farm read
    it as dry_no_site."""
    level = load_level("../levels/gauntlet4.json")
    s = GameSession(level, seed=5)
    homes = {s.sim.get_polygon(eid) for eid, e in s.enemies.items()
             if e["kind"] in ADVERSARY}
    assert len(homes) == 9, "one scout per chamber"
    for chamber in sorted(homes):
        assert s.topology.carve(chamber, (0.0, 0.0), 96.0) is not None, (
            f"chamber {chamber} holds a scout but no 96u seam")


def test_the_core_never_produces_scouts():
    for kind in STRIKE_CYCLE + GUARDIAN_SHELF:
        assert kind not in ADVERSARY, (
            f"{kind}: the census must only ever shrink — scouts are "
            "authored, never produced")


def test_dormant_scout_sleeps_until_the_fight_arrives():
    b = LevelBuilder("DORM", 1)
    ra = b.rect(0, 0, 300, 200)
    rb = b.rect(300, 0, 300, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (60, 100))
    level = b.build()
    s = GameSession(level, seed=9)
    eid = s.spawn_enemy(rb, (0.0, 0.0), "lacuna")
    s.enemies[eid]["dormant"] = 0.5
    x0 = s.sim.get(eid).pos.local()
    for _ in range(8 * 60):
        s.tick(InputFrame())
    e = s.enemies[eid]
    x1 = s.sim.get(eid).pos.local()
    assert e.get("dormant"), "woke with nothing happening"
    assert e.get("scout") is None, "tasked itself while dormant"
    assert abs(x1[0] - x0[0]) + abs(x1[1] - x0[1]) < 1.0, (
        "a dormant spotter must be stone-still")
    # the fight arrives: sustained noise in its chamber over threshold
    for _ in range(90):
        s.signals.emit_at_least(SignalKind.NOISE, rb, 0.7, s.tick_count)
        s.tick(InputFrame())
    e = s.enemies[eid]
    assert not e.get("dormant"), "did not wake at threshold"
    for _ in range(10 * 60):
        s.tick(InputFrame())
        if s.enemies.get(eid, {}).get("scout"):
            break
    assert eid not in s.enemies or s.enemies[eid].get("scout"), (
        "a woken spotter must behave as an ordinary scout")


def test_below_threshold_noise_does_not_wake():
    b = LevelBuilder("DORM2", 1)
    ra = b.rect(0, 0, 300, 200)
    rb = b.rect(300, 0, 300, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (60, 100))
    s = GameSession(b.build(), seed=9)
    eid = s.spawn_enemy(rb, (0.0, 0.0), "lacuna")
    s.enemies[eid]["dormant"] = 0.5
    for _ in range(6 * 60):
        s.signals.emit_at_least(SignalKind.NOISE, rb, 0.3, s.tick_count)
        s.tick(InputFrame())
    assert s.enemies[eid].get("dormant"), (
        "0.3 noise woke a 0.5-threshold spotter")


def test_shooting_a_dormant_scout_wakes_it():
    b = LevelBuilder("DORM3", 1)
    ra = b.rect(0, 0, 300, 200)
    rb = b.rect(300, 0, 300, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (60, 100))
    s = GameSession(b.build(), seed=9)
    eid = s.spawn_enemy(rb, (0.0, 0.0), "lacuna")
    s.enemies[eid]["dormant"] = 0.5
    s._damage_enemy(eid, 5.0, s.sim.get(eid).pos.offset(1.0, 0.0), 0.0, source="test")
    for _ in range(120):
        s.tick(InputFrame())
    assert not s.enemies[eid].get("dormant"), (
        "a shot spotter stayed asleep — scout_hit must wake it")
