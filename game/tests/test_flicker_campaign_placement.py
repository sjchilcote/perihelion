"""Invariant checks for the Adversary-territory flicker placements made by
tools/flicker_placement.py (director's order, 2026-07-13: "a common
annoyance in sections where live Adversary troops... live", never in the
early-game corrupted-Testator-machine levels).

Ground truth (see the placement tool's own docstring and the session
report for the full citation trail): the campaign's three strata map to
l01-l02 (Research Outpost, corrupted outpost security), l03-l06 (the
Testament -- malfunctioning war machines, still Testator, not the
Adversary), l07-l09 (the Breach -- the invaders themselves, confirmed
independently by tools/levelgen/dense/l0*.py's own "otherworld" cell
dosage: zero in l01-l06, one isolated in l07, a small cluster in l08, and
72/253 cells in l09).
"""
from __future__ import annotations

import json
import os
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pytest

ROOT = Path(__file__).resolve().parents[2]
LEVELS_DIR = ROOT / "levels"
ADVERSARY_LEVELS = {"l07", "l08", "l09"}
ALL_CAMPAIGN_LEVELS = {f"l{i:02d}" for i in range(1, 10)}


def _flickers(level_id: str) -> list[tuple[int, dict]]:
    data = json.loads((LEVELS_DIR / f"{level_id}.json").read_text())
    out = []
    for i, room in enumerate(data["rooms"]):
        for e in room["entities"]:
            if e["type"] == "flicker":
                out.append((i, e))
    return out


@pytest.mark.parametrize("level_id", sorted(ALL_CAMPAIGN_LEVELS - ADVERSARY_LEVELS))
def test_no_flickers_in_corrupted_testator_territory(level_id):
    """l01-l06 are corrupted outpost security (class 1) or malfunctioning
    Testator war machines (class 2) -- NOT the live Adversary. The
    director's order draws that line explicitly; flickers stay out."""
    assert _flickers(level_id) == [], (
        f"{level_id} is pre-Breach territory (Stratum One/Two) -- "
        "flickers belong only in l07-l09"
    )


@pytest.mark.parametrize("level_id", sorted(ADVERSARY_LEVELS))
def test_adversary_levels_carry_flicker_seasoning(level_id):
    """Every Breach-territory level has at least a few flickers (a
    'common annoyance', per the director) and not so many it reads as
    wallpaper or a single boss-stack."""
    flickers = _flickers(level_id)
    assert 3 <= len(flickers) <= 30, (
        f"{level_id}: {len(flickers)} flickers -- expected light seasoning, "
        "not zero and not saturation"
    )


@pytest.mark.parametrize("level_id", sorted(ADVERSARY_LEVELS))
def test_flickers_never_stacked_on_another_entity(level_id):
    """No flicker spawns on top of another entity (enemy, pickup, key...)
    -- see tools/flicker_placement.py's _find_clear_spot. A flicker sharing
    a room with something else is fine (and common -- that's seasoning);
    sharing the exact spawn point is a placement bug."""
    data = json.loads((LEVELS_DIR / f"{level_id}.json").read_text())
    for i, room in enumerate(data["rooms"]):
        ents = room["entities"]
        flickers = [e for e in ents if e["type"] == "flicker"]
        for f in flickers:
            for other in ents:
                if other is f:
                    continue
                dx = f["pos"][0] - other["pos"][0]
                dy = f["pos"][1] - other["pos"][1]
                dist = (dx * dx + dy * dy) ** 0.5
                assert dist >= 20.0, (
                    f"{level_id} room {i}: flicker spawns {dist:.1f}u from "
                    f"{other['type']} -- stacked spawn"
                )


@pytest.mark.parametrize("level_id", sorted(ADVERSARY_LEVELS))
def test_at_most_two_flickers_per_room(level_id):
    """'Avoid stacking multiple flickers in one small room unless it's a
    deliberate nasty spot' -- the placement tool never deliberately
    doubles up, so more than two in one room would be a bug, not a
    choice."""
    data = json.loads((LEVELS_DIR / f"{level_id}.json").read_text())
    for i, room in enumerate(data["rooms"]):
        n = sum(1 for e in room["entities"] if e["type"] == "flicker")
        assert n <= 2, f"{level_id} room {i}: {n} flickers stacked in one room"


def test_placement_audit_log_matches_shipped_levels():
    """tools/flicker_placement_log.json is the director-auditable
    justification trail; every flicker actually shipped in l07-l09 must
    have a matching logged justification, and vice versa (no drift
    between what was reasoned about and what was written)."""
    log_path = ROOT / "tools" / "flicker_placement_log.json"
    assert log_path.exists(), "run tools/flicker_placement.py --apply"
    log = json.loads(log_path.read_text())
    logged = {(e["level"], e["room"]) for e in log}
    shipped = set()
    for level_id in ADVERSARY_LEVELS:
        for room, _e in _flickers(level_id):
            shipped.add((level_id, room))
    assert logged == shipped, (
        f"audit log / shipped-level drift: logged-only={logged - shipped}, "
        f"shipped-only={shipped - logged}"
    )
    for entry in log:
        assert entry.get("justification"), f"{entry['level']} room {entry['room']}: no justification logged"
