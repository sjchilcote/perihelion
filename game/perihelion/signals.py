"""The nine-field signal substrate (U4, DESIGN_7_25 appendix).

Scalar fields, ONE value per chamber, spreading hop-by-hop across the
portal graph (never through a wall, never beyond the doorways), fading
over time. This is the shared medium the whole Adversary coordinates
through — systems collaborate by writing and reading it, never by
reaching into each other's internals.

Decay is EXPONENTIAL and analytic: every cell stores the tick it was
last materialized and decay is computed from the delta, so a chamber
that stops receiving updates fades at exactly the same effective rate
as one updated every tick (ratified: separation in time comes from
half-lives, never amplitude). Spread runs on a fixed global cadence
(SPREAD_DT ticks), independent of who samples when — reads never
mutate, so update frequency cannot change what a value is.

Deterministic by construction: no RNG, no wall clock, sorted iteration.
(The sim's replay property survives; this module does not impose any
NEW determinism requirement on its consumers.)
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Mapping

import necore

TICK_RATE = 60
SPREAD_DT = 15                  # spread cadence in ticks (0.25s)
_EPS = 1e-5                     # wet-set floor


class SignalKind(Enum):
    DISTRESS = "distress"
    DANGER = "danger"
    NOISE = "noise"
    TRAIL = "trail"
    PATROL = "patrol"
    MUSTER = "muster"
    GARRISON_INTERIOR = "garrison_interior"
    GARRISON_REACH = "garrison_reach"
    KIN = "kin"


# kind -> (half_life_seconds, spread_per_second, hop_gain)
# hop_gain < 1 is the extra per-crossing attenuation ("very exponential
# dropoff per hop" — Muster). First-pass numbers per DESIGN_7_25 §1b /
# the round-3 plan; Trail/Patrol/Danger half-lives are the ratified ones.
_SPEC: dict[SignalKind, tuple[float, float, float]] = {
    SignalKind.DISTRESS: (45.0, 0.12, 1.0),
    SignalKind.DANGER: (180.0, 0.0, 1.0),
    SignalKind.NOISE: (3.0, 1.20, 1.0),
    SignalKind.TRAIL: (12.0, 0.0, 1.0),
    SignalKind.PATROL: (60.0, 0.0, 1.0),
    SignalKind.MUSTER: (1.0, 1.8, 0.35),
    SignalKind.GARRISON_INTERIOR: (1.5, 0.9, 1.0),   # special two-front rule
    SignalKind.GARRISON_REACH: (2.0, 0.7, 1.0),
    SignalKind.KIN: (8.0, 0.45, 1.0),
}
assert len(_SPEC) == len(SignalKind) == 9

# per-tick decay multiplier per kind: 0.5 ** (1 / (hl * TICK_RATE))
_DECAY_PER_TICK = {k: 0.5 ** (1.0 / (hl * TICK_RATE))
                   for k, (hl, _, _) in _SPEC.items()}


@dataclass(frozen=True, slots=True)
class SignalNeighborhood:
    """One agent's whole legal view of the medium: its own chamber and
    chambers one portal away. There is no deeper query."""
    center: int
    own: Mapping[SignalKind, float]
    adjacent: tuple[tuple[int, Mapping[SignalKind, float]], ...]


class SignalField:
    """Typed facade over the ENGINE's signal substrate (necore.SignalField,
    engine/necore/src/signals.rs — the one implementation of the math).
    This class owns only: the SignalKind enum boundary (kinds cross as
    declaration-order indices), adjacency extraction from the world, and
    the frozen observation dataclasses. The Python cell loops it replaced
    were the sim's steady-state and spread-beat hot path (measured
    2026-07-28: ~1.5-2 ms per spread tick at fight density)."""

    _IDX = {k: i for i, k in enumerate(SignalKind)}

    def __init__(self, world, tick: int = 0):
        self._w = world
        self._f = necore.SignalField(tick)
        self._adj: list[list[int]] = []
        self.on_topology_changed()

    # -- topology ----------------------------------------------------------

    def on_topology_changed(self) -> None:
        """Call after ANY runtime connect/disconnect/add_polygon: adjacency
        is rebuilt and the arrays grow. Signals never cross a sealed
        doorway because a sealed doorway simply is not in the adjacency."""
        w = self._w
        n = w.num_polygons()
        self._adj = [[p[0] for p in w.polygon_portals(r) if p is not None]
                     for r in range(n)]
        self._f.set_adjacency(self._adj)

    # -- write -------------------------------------------------------------

    def emit(self, kind: SignalKind, polygon: int, amount: float,
             tick: int) -> None:
        self._f.emit(self._IDX[kind], polygon, amount, tick)

    def emit_many(self, kind: SignalKind, polygons, amount: float,
                  tick: int) -> None:
        self._f.emit_many(self._IDX[kind], list(polygons), amount, tick)

    def emit_at_least(self, kind: SignalKind, polygon: int, level: float,
                      tick: int) -> None:
        """Raise the cell to at least `level` (the Trail idiom: passage
        re-arms the scent to full, it does not stack unboundedly)."""
        self._f.emit_at_least(self._IDX[kind], polygon, level, tick)

    # -- read (never mutates observable state) ------------------------------

    def sample(self, kind: SignalKind, polygon: int, tick: int) -> float:
        return self._f.sample(self._IDX[kind], polygon, tick)

    def neighborhood(self, polygon: int, tick: int, *,
                     depth: int = 1) -> SignalNeighborhood:
        if depth > 1:
            raise ValueError(
                f"agents sample only one portal away (asked {depth})")
        own = dict(zip(SignalKind, self._f.sample_all(polygon, tick)))
        adj = []
        if depth >= 1:
            for nb in self._adj[polygon]:
                adj.append((nb, dict(zip(SignalKind,
                                         self._f.sample_all(nb, tick)))))
        return SignalNeighborhood(center=polygon, own=own,
                                  adjacent=tuple(adj))

    def total(self, kind: SignalKind, tick: int) -> float:
        return self._f.totals(tick)[self._IDX[kind]]

    def totals(self, tick: int) -> dict:
        vals = self._f.totals(tick)
        return {k: vals[i] for i, k in enumerate(SignalKind)}

    # -- doorway traffic marks ----------------------------------------------

    def deposit_doorway_trail(self, polygon: int, edge: int, amount: float,
                              tick: int) -> None:
        self._f.deposit_doorway_trail(polygon, edge, amount, tick)

    def doorway_trail(self, polygon: int, edge: int, tick: int) -> float:
        return self._f.doorway_trail(polygon, edge, tick)

    # -- spread (fixed cadence, independent of sampling) ---------------------

    def step_to(self, tick: int) -> None:
        """Advance spread to `tick` in whole SPREAD_DT chunks. Decay needs
        no stepping (it is analytic); only transfer between neighbors
        happens here, so behavior cannot depend on call frequency."""
        self._f.step_to(tick)

    # -- the scrubber's sink (U13 consumes this; the capacity is SHARED) ----

    def drain(self, polygon_weights: Mapping[int, float], capacity: float,
              tick: int) -> float:
        """Remove up to `capacity` signal-units TOTAL (all nine fields
        together, weighted per chamber), proportionally to what is
        actually there. Returns what was removed."""
        return self._f.drain(list(polygon_weights.items()), capacity, tick)
