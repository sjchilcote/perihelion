"""Adversary scout decisions (U7, DESIGN_7_25 §1b) — pure functions.

The vagrant and the lacuna are PERSONNEL: finite, authored at world
build, never produced by any core. Only they can call. This module is
the caller's judgment — where to creep, when to brace, where a call is
worth planting — consuming only the agent's own legal perception
(a one-hop SignalNeighborhood) and returning chamber choices. It knows
nothing of the sim, the marrow, breaches, or what (if anything) answers
a call: "if it calls and nothing is available, nothing comes."

The class order IS the weakness order: lacuna calls before vagrant
(ratified — weakest-in-room by CLASS, not by hit points).
"""
from __future__ import annotations

from .signals import SignalKind, SignalNeighborhood

# weakest first: the tasked caller is the weakest class present
ADVERSARY_ORDER = ("lacuna", "vagrant")

# rooted broadcast lengths (ratified §1b): total exposure adds a 2s brace
VAGRANT_ROOT_TICKS = 6 * 60
LACUNA_ROOT_TICKS = 8 * 60
BRACE_TICKS = 2 * 60
POUR_OBSERVE_TICKS = 3 * 60
FLEE_TICKS = 5 * 60

# "as close to the player as is safe": advance through chambers below
# this hotness, stop AT it, plant there (first-pass numbers)
CALLER_HOT = 0.45
CALL_PLANT_MIN = 0.06          # don't plant a call for a cold nothing
HIGH_DANGER_ENTER = 0.35       # expansion: refuse chambers deadlier than this


def _hot(vals) -> float:
    """How player-y a chamber smells: the thing a caller creeps toward
    but never into."""
    return (vals[SignalKind.NOISE] + vals[SignalKind.TRAIL]
            + 0.6 * vals[SignalKind.DISTRESS])


def _quiet(vals) -> float:
    """How attractive ground is for a garrison seed: thin Kin, unswept,
    off the intruder's scent."""
    return (vals[SignalKind.KIN] + 0.5 * vals[SignalKind.PATROL]
            + vals[SignalKind.TRAIL] + vals[SignalKind.NOISE])


def weakest_class_present(classes) -> str | None:
    """The class that gets the caller duty among those present."""
    for cls in ADVERSARY_ORDER:
        if cls in classes:
            return cls
    return None


def approach_target(nbh: SignalNeighborhood) -> int | None:
    """Contact mode: climb the hotness gradient toward the fight but
    never INTO a chamber at or past the threshold — the call is planted
    at the edge of the hot zone, out of the player's reach."""
    own = _hot(nbh.own)
    best = None
    best_h = own
    for chamber, vals in nbh.adjacent:
        h = _hot(vals)
        if h >= CALLER_HOT:
            continue                       # too hot to stand in
        if h > best_h:
            best, best_h = chamber, h
    return best


def ready_to_plant(nbh: SignalNeighborhood) -> bool:
    """Stopped AT the threshold: something adjacent is hot (or the trail
    here is warm enough to matter) while this chamber is still safe."""
    own_h = _hot(nbh.own)
    if own_h >= CALLER_HOT:
        return False                        # standing in the fire: move
    hottest_next = max((_hot(v) for _, v in nbh.adjacent), default=0.0)
    return hottest_next >= CALLER_HOT or own_h >= CALL_PLANT_MIN


def safe_target(nbh: SignalNeighborhood) -> int | None:
    """Expansion, quiet leg: descend Kin/Patrol/scent toward the
    thinnest ground — where a garrison seed is worth planting."""
    own = _quiet(nbh.own)
    best = None
    best_q = own
    for chamber, vals in nbh.adjacent:
        if vals[SignalKind.DANGER] > HIGH_DANGER_ENTER:
            continue
        q = _quiet(vals)
        if q < best_q:
            best, best_q = chamber, q
    return best


def peak_target(nbh: SignalNeighborhood) -> int | None:
    """Expansion, raid leg: climb the Danger field toward the player's
    killing grounds — but never enter a chamber past the entry line;
    the raid call lands at the last safe chamber."""
    own = nbh.own[SignalKind.DANGER]
    best = None
    best_d = own
    for chamber, vals in nbh.adjacent:
        d = vals[SignalKind.DANGER]
        if d > HIGH_DANGER_ENTER:
            continue
        if d > best_d:
            best, best_d = chamber, d
    return best


def root_ticks(caller_class: str) -> int:
    return LACUNA_ROOT_TICKS if caller_class == "lacuna" \
        else VAGRANT_ROOT_TICKS
