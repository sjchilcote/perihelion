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
    """The substrate. `world` is the engine sim (portal adjacency); it is
    the only dependency — no game system is visible from here."""

    __slots__ = ("_w", "_v", "_t", "wet", "_adj", "_adj_n",
                 "_last_spread", "_trail", "_trail_t")

    def __init__(self, world, tick: int = 0):
        self._w = world
        n = world.num_polygons()
        self._v = {k: [0.0] * n for k in SignalKind}
        self._t = {k: [tick] * n for k in SignalKind}
        self.wet: set[int] = set()
        self._adj: list[list[int]] = []
        self._adj_n = -1
        self._last_spread = tick
        # doorway traffic marks: directed edge pheromone (polygon, edge),
        # distinct from the chamber TRAIL field (the intruder's scent) —
        # this is which route SEARCHERS have repeatedly chosen
        self._trail: dict[tuple[int, int], float] = {}
        self._trail_t: dict[tuple[int, int], int] = {}
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
        if n > self._adj_n:
            for k in SignalKind:
                self._v[k].extend([0.0] * (n - len(self._v[k])))
                self._t[k].extend([self._last_spread]
                                  * (n - len(self._t[k])))
        self._adj_n = n

    # -- write -------------------------------------------------------------

    def emit(self, kind: SignalKind, polygon: int, amount: float,
             tick: int) -> None:
        if amount <= 0.0 or polygon < 0 or polygon >= self._adj_n:
            return
        self._materialize(kind, polygon, tick)
        self._v[kind][polygon] += amount
        self.wet.add(polygon)

    def emit_at_least(self, kind: SignalKind, polygon: int, level: float,
                      tick: int) -> None:
        """Raise the cell to at least `level` (the Trail idiom: passage
        re-arms the scent to full, it does not stack unboundedly)."""
        if polygon < 0 or polygon >= self._adj_n:
            return
        cur = self.sample(kind, polygon, tick)
        if cur < level:
            self._v[kind][polygon] = level
            self.wet.add(polygon)

    # -- read (never mutates observable state) ------------------------------

    def _materialize(self, kind: SignalKind, polygon: int, tick: int) -> None:
        dt = tick - self._t[kind][polygon]
        if dt < 0:
            raise ValueError(f"time ran backwards for {kind} in {polygon}")
        if dt:
            v = self._v[kind][polygon] * (_DECAY_PER_TICK[kind] ** dt)
            self._v[kind][polygon] = 0.0 if v < _EPS else v
            self._t[kind][polygon] = tick

    def sample(self, kind: SignalKind, polygon: int, tick: int) -> float:
        if polygon < 0 or polygon >= self._adj_n:
            raise ValueError(f"unknown chamber {polygon}")
        dt = tick - self._t[kind][polygon]
        if dt < 0:
            raise ValueError(f"time ran backwards for {kind} in {polygon}")
        v = self._v[kind][polygon] * (_DECAY_PER_TICK[kind] ** dt)
        return 0.0 if v < _EPS else v

    def neighborhood(self, polygon: int, tick: int, *,
                     depth: int = 1) -> SignalNeighborhood:
        if depth > 1:
            raise ValueError(
                f"agents sample only one portal away (asked {depth})")
        own = {k: self.sample(k, polygon, tick) for k in SignalKind}
        adj = []
        if depth >= 1:
            for nb in self._adj[polygon]:
                adj.append((nb, {k: self.sample(k, nb, tick)
                                 for k in SignalKind}))
        return SignalNeighborhood(center=polygon, own=own,
                                  adjacent=tuple(adj))

    def total(self, kind: SignalKind, tick: int) -> float:
        return sum(self.sample(kind, r, tick) for r in sorted(self.wet))

    # -- doorway traffic marks ----------------------------------------------

    _TRAIL_CAP = 8.0
    _TRAIL_HL_TICKS = 660.0          # ~11s: only reused lanes persist

    def deposit_doorway_trail(self, polygon: int, edge: int, amount: float,
                              tick: int) -> None:
        if amount <= 0.0:
            return
        k = (polygon, edge)
        cur = self.doorway_trail(polygon, edge, tick)
        self._trail[k] = min(self._TRAIL_CAP, cur + amount)
        self._trail_t[k] = tick

    def doorway_trail(self, polygon: int, edge: int, tick: int) -> float:
        k = (polygon, edge)
        v = self._trail.get(k)
        if v is None:
            return 0.0
        dt = tick - self._trail_t[k]
        v *= 0.5 ** (dt / self._TRAIL_HL_TICKS)
        return 0.0 if v < _EPS else v

    # -- spread (fixed cadence, independent of sampling) ---------------------

    def step_to(self, tick: int) -> None:
        """Advance spread to `tick` in whole SPREAD_DT chunks. Decay needs
        no stepping (it is analytic); only transfer between neighbors
        happens here, so behavior cannot depend on call frequency."""
        while tick - self._last_spread >= SPREAD_DT:
            self._last_spread += SPREAD_DT
            self._spread_chunk(self._last_spread)

    def _spread_chunk(self, tick: int) -> None:
        if not self.wet:
            return
        live = sorted(self.wet | {nb for r in self.wet if r < self._adj_n
                                  for nb in self._adj[r]})
        dt_s = SPREAD_DT / TICK_RATE
        new_wet: set[int] = set()
        for kind, (hl, rate, hop_gain) in _SPEC.items():
            if rate <= 0.0:
                for r in live:
                    self._materialize(kind, r, tick)
                    if self._v[kind][r] > 0.0:
                        new_wet.add(r)
                continue
            arr = self._v[kind]
            for r in live:
                self._materialize(kind, r, tick)
            frac = min(0.45, rate * dt_s)   # stability: never move >45%/side
            if kind is SignalKind.GARRISON_INTERIOR:
                self._spread_interior(live, frac, hop_gain, tick)
            else:
                # per-door outflow from a SNAPSHOT of the chunk's values
                # (simultaneous update); total outflow capped below 90% so
                # a many-doored room can never go negative in one chunk
                flows = []
                for r in live:
                    cur = arr[r]
                    if cur <= 0.0:
                        continue
                    deg = len(self._adj[r])
                    if deg == 0:
                        continue
                    per = cur * min(0.9, frac * deg) / deg
                    for nb in self._adj[r]:
                        flows.append((r, nb, per))
                for r, nb, per in flows:
                    arr[r] -= per                   # what left the room
                    arr[nb] += per * hop_gain       # what arrived (hop loss)
            for r in live:
                v = arr[r]
                if v < _EPS:
                    arr[r] = 0.0
                else:
                    new_wet.add(r)
        self.wet = new_wet

    def _spread_interior(self, live, frac, hop_gain, tick) -> None:
        """Garrison Interior's two-front rule: a chamber only becomes
        'inside the wire' when emission reaches it from TWO OR MORE
        distinct neighbors; a single-path reach converts to Garrison
        Reach instead (the FOB is this way, not you-are-inside-it)."""
        interior = self._v[SignalKind.GARRISON_INTERIOR]
        reach = self._v[SignalKind.GARRISON_REACH]
        gains: dict[int, list[float]] = {}
        outflow: dict[int, float] = {}
        for r in live:
            cur = interior[r]
            if cur <= 0.0:
                continue
            deg = len(self._adj[r])
            if deg == 0:
                continue
            per = cur * min(0.9, frac * deg) / deg
            outflow[r] = per * deg
            for nb in self._adj[r]:
                gains.setdefault(nb, []).append(per)
        for r, out in sorted(outflow.items()):
            interior[r] -= out
        for nb, parts in sorted(gains.items()):
            total = sum(parts)
            if len(parts) >= 2:
                interior[nb] += total
            else:
                self._materialize(SignalKind.GARRISON_REACH, nb, tick)
                reach[nb] += total

    # -- the scrubber's sink (U13 consumes this; the capacity is SHARED) ----

    def drain(self, polygon_weights: Mapping[int, float], capacity: float,
              tick: int) -> float:
        """Remove up to `capacity` signal-units TOTAL (all nine fields
        together, weighted per chamber), proportionally to what is
        actually there. Returns what was removed."""
        pool = []
        for r, wgt in sorted(polygon_weights.items()):
            if r < 0 or r >= self._adj_n or wgt <= 0.0:
                continue
            for k in SignalKind:
                v = self.sample(k, r, tick)
                if v > 0.0:
                    pool.append((k, r, v, wgt))
        weighted = sum(v * wgt for _, _, v, wgt in pool)
        if weighted <= 0.0 or capacity <= 0.0:
            return 0.0
        removed = 0.0
        scale = min(1.0, capacity / weighted)
        for k, r, v, wgt in pool:
            self._materialize(k, r, tick)
            cut = v * wgt * scale
            self._v[k][r] = max(0.0, self._v[k][r] - cut)
            removed += cut
        return removed
