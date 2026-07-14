"""Structural gates for levels/gauntlet_cal.json (tools/musiccal's
calibration gauntlet — see tools/musiccal/build_gauntlet.py). Mirrors
test_levels.py's campaign gates: loads, traversable, exit reachable.
Deeper playability (bot completion, clear rate) is measured at scale by
tools/musiccal/run_farm.py + tune_density.py, not here — this file is the
fast, always-on structural regression guard."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "musiccal"))

from perihelion.levels import load_level  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402

LEVEL_PATH = ROOT / "levels" / "gauntlet_cal.json"
META_PATH = ROOT / "tools" / "musiccal" / "gauntlet_meta.json"


@pytest.fixture(scope="module")
def level():
    assert LEVEL_PATH.exists(), \
        "run: uv run python tools/musiccal/build_gauntlet.py --density <tuned>"
    return load_level(LEVEL_PATH)


@pytest.fixture(scope="module")
def meta():
    assert META_PATH.exists(), "run tools/musiccal/build_gauntlet.py to (re)generate it"
    return json.loads(META_PATH.read_text())


def test_structure_loads_and_is_traversable(level):
    s = GameSession(level, seed=1)
    for t in range(120):
        s.tick(InputFrame(mx=(t % 3) - 1, my=((t // 3) % 3) - 1))
    assert not s.dead
    for d in s.doors:
        if not d["open"]:
            s.sim.connect(d["a"], d["ea"], d["b"], d["eb"])
    reach = set(s.sim.rooms_within(level.player_room, 99))
    assert reach == set(range(s.sim.num_rooms())), "unreachable rooms in the gauntlet"
    assert level.exit_room in reach


def test_gauntlet_has_no_keys_or_gates(level):
    # the calibration gauntlet measures combat, not puzzle-solving: every
    # connection must be immediately traversable.
    assert not level.doors
    assert level.exit_key == ""
    assert level.exit_gate_kind == ""


def test_six_segments_present_with_enemy_rosters(meta):
    assert set(meta["per_segment"]) == {"A", "B", "C", "D", "E", "F"}
    assert meta["total_enemies"] == sum(meta["per_segment"].values())
    assert meta["total_enemies"] > 0, "density tuning zeroed out the whole gauntlet"


def test_enemies_only_in_combat_zones(level, meta):
    """Corridors and loot rooms must be enemy-free (they're the director's
    'long, safe corridors' and 'rest and recharge lootrooms') -- every enemy
    entity must land in a room the builder tagged zone=='combat'."""
    from perihelion.sim import ENEMIES

    zones = meta["zones"]
    for room, spec in level.entities:
        if spec.type in ENEMIES:
            assert zones[str(room)]["zone"] == "combat", \
                f"enemy {spec.type} spawned in a non-combat room {room}"


def test_loot_rooms_carry_health_and_ammo(level, meta):
    from perihelion.sim import PICKUPS, SENTRIES

    loot_rooms = {int(r) for r, z in meta["zones"].items() if z["zone"] == "loot"}
    assert len(loot_rooms) == 7, "one loot room per corridor (start + 5 between + end)"
    kinds_by_room: dict[int, set[str]] = {}
    for room, spec in level.entities:
        if room in loot_rooms:
            assert spec.type in PICKUPS or spec.type in SENTRIES, \
                f"unexpected entity type {spec.type!r} in loot room {room}"
            kinds_by_room.setdefault(room, set()).add(spec.type)
    for room in loot_rooms:
        kinds = kinds_by_room.get(room, set())
        assert "medkit" in kinds, f"loot room {room} has no health pickup"
        assert any(k.startswith("ammo_") for k in kinds), \
            f"loot room {room} has no ammo pickup"


def test_loot_rooms_each_have_one_sentry(level, meta):
    """Director's directive, 2026-07-13: "let's put friendly turrets in
    the safe-room corridors" -- FITTING_REPORT.md finding #1 measured loot
    rooms as the deadliest zone (2.2x combat) because pursuers have no
    de-aggro path. One sentry per loot room, none anywhere else -- placing
    them is the director's tuning call for campaign levels, not the
    gauntlet's structural default (see build_gauntlet.py's module note)."""
    from perihelion.sim import SENTRIES

    loot_rooms = {int(r) for r, z in meta["zones"].items() if z["zone"] == "loot"}
    sentries_by_room: dict[int, int] = {}
    for room, spec in level.entities:
        if spec.type in SENTRIES:
            assert room in loot_rooms, \
                f"sentry placed outside a loot room (room {room}) -- gauntlet " \
                "placement is loot-room-doorway only"
            sentries_by_room[room] = sentries_by_room.get(room, 0) + 1
    for room in loot_rooms:
        assert sentries_by_room.get(room, 0) == 1, \
            f"loot room {room} should have exactly one sentry"


def test_corridors_are_long_and_safe(level, meta):
    """'LONG, safe corridors' per the director's brief: every non-combat,
    non-loot room must be enemy-free (already covered), and each corridor's
    total authored span must exceed a single room-scale hop."""
    from build_gauntlet import CORRIDOR_STUB_LEN

    corridor_rooms = [r for r, z in meta["zones"].items() if z["zone"] == "corridor"]
    assert len(corridor_rooms) == 14, "two stub rooms per corridor x 7 corridors"
    assert CORRIDOR_STUB_LEN >= 300.0, "a corridor stub must read as a real hallway"


def test_player_and_exit_at_opposite_ends(level, meta):
    assert level.player_room == meta["player_room"]
    assert level.exit_room == meta["exit_room"]
    assert level.player_room != level.exit_room
