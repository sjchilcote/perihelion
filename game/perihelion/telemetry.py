"""The instrumentation spine (U1, DESIGN_7_25 verification plan).

One always-present, in-memory channel every simulation path emits typed,
tick-stamped evidence through. The sim EMITS; drainers (app, testkit
harness, tools) DRAIN the same bus to JSONL — one schema for human runs
and bot runs by construction, which is the director's "instrument the
human exactly like the bot" made structural.

Boundaries, enforced by game/tests/test_architecture_boundaries.py:
- this module imports nothing but the standard library — no pygame, no
  numpy, no audio, no render, no sim;
- the bus has NO query API: `drain()` destructively hands the buffer to a
  drainer, so simulation code cannot read its own trace and telemetry can
  never become a gameplay input;
- the renderer may not import this module (visual tells must read real
  system state, never the trace).

The bus does not impose determinism: records carry wall-free tick stamps
only, and nothing here is part of replay equality.
"""
from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field, fields
from typing import Any, Mapping


@dataclass(frozen=True, slots=True)
class TraceRecord:
    seq: int
    tick: int
    kind: str
    data: Mapping[str, Any]


def to_json_line(rec: TraceRecord) -> str:
    """The one serialization every drainer uses — schema identity between
    app and harness is by construction, not convention."""
    return json.dumps(
        {"seq": rec.seq, "t": rec.tick, "kind": rec.kind, **rec.data},
        separators=(",", ":"), default=_json_default)


def _json_default(o: Any):
    if isinstance(o, (set, frozenset, tuple)):
        return list(o)
    raise TypeError(f"untraceable value in trace data: {o!r}")


# --------------------------------------------------------------------------
# Typed events. Frozen, slotted, no defaults on load-bearing fields —
# a constructor missing a field is a TypeError at the emit site, not a
# half-record in the log.
# --------------------------------------------------------------------------

@dataclass(frozen=True, slots=True)
class InputRecord:
    KIND = "input"
    tick: int
    mx: float
    my: float
    ax: float
    ay: float
    fire: bool
    alt: bool
    interact: bool
    weapon: int


@dataclass(frozen=True, slots=True)
class AgentTransition:
    KIND = "agent_transition"
    tick: int
    entity_id: int
    agent_kind: str
    from_state: str
    to_state: str


@dataclass(frozen=True, slots=True)
class PortalCrossing:
    KIND = "portal_crossing"
    tick: int
    entity_id: int
    entity_kind: str          # "player" | enemy kind | "bullet:<kind>" | "other"
    from_polygon: int
    to_polygon: int
    edge: int


@dataclass(frozen=True, slots=True)
class DamageApplied:
    KIND = "damage_applied"
    tick: int
    target_id: int
    target_kind: str          # "player" or enemy kind
    amount: float
    source: str               # bullet kind / contact / spit / arc ...


@dataclass(frozen=True, slots=True)
class ImpulseApplied:
    KIND = "impulse_applied"
    tick: int
    entity_id: int
    jx: float                 # impulse (mass-scaled: J = m * dv), world units
    jy: float
    source: str


@dataclass(frozen=True, slots=True)
class FieldSample:
    KIND = "field_sample"
    tick: int
    totals: Mapping[str, float]      # signal kind -> world total
    player_polygon: int
    player_own: Mapping[str, float]  # the player's chamber's values


@dataclass(frozen=True, slots=True)
class BreachLifecycle:
    KIND = "breach_lifecycle"
    tick: int
    breach_id: int
    event: str            # requested | dry_no_site | opened | sealed
    world_chamber: int
    detail: str


@dataclass(frozen=True, slots=True)
class CorePartEvent:
    KIND = "core_part"
    tick: int
    part_id: int          # -1 for organ-wide events (blackout, reform)
    part_kind: str        # "" for organ-wide events
    event: str            # destroyed | blackout | reformed
    detail: str


@dataclass(frozen=True, slots=True)
class ReserveSample:
    KIND = "reserve_sample"
    tick: int
    reserve: float
    live_breaches: int
    pending_kind: str


@dataclass(frozen=True, slots=True)
class DispatchDecision:
    KIND = "dispatch_decision"
    tick: int
    breach_id: int
    unit_kind: str
    entity_id: int
    from_shelf: bool
    knows_position: bool  # the ~10% rule: does this body know the site?
    hub_chamber: int


@dataclass(frozen=True, slots=True)
class ShelfReplaced:
    KIND = "shelf_replaced"
    tick: int
    unit_kind: str
    entity_id: int
    hub_chamber: int


@dataclass(frozen=True, slots=True)
class TopologyChanged:
    KIND = "topology_changed"
    tick: int
    op: str                   # "connect" | "disconnect" | "split_edge"
    a_polygon: int
    a_edge: int
    b_polygon: int            # -1 where not applicable
    b_edge: int
    source: str               # door / hole / cloister / stream ...


# Event kinds reserved for later units (U4-U11) so the vocabulary is fixed
# before the systems land: field_sample, call_lease, call_imprint,
# breach_lifecycle, reserve_sample, dispatch_decision, core_part,
# structure_event.

TraceEvent = (InputRecord | AgentTransition | PortalCrossing
              | DamageApplied | ImpulseApplied | TopologyChanged
              | FieldSample | BreachLifecycle | ReserveSample
              | DispatchDecision | ShelfReplaced | CorePartEvent)


class TraceBus:
    """Append-only in-memory event buffer.

    Emit-side rules (enforced, not documented): sequence numbers strictly
    increase; tick stamps never decrease. There is deliberately no read or
    query surface — the only way data leaves is `drain()`, which empties
    the buffer into the caller.
    """

    __slots__ = ("_buf", "_seq", "_last_tick")

    def __init__(self) -> None:
        self._buf: list[TraceRecord] = []
        self._seq = 0
        self._last_tick = -1

    def _push(self, tick: int, kind: str, data: Mapping[str, Any]) -> None:
        if tick < self._last_tick:
            raise ValueError(
                f"trace tick went backwards: {tick} after {self._last_tick}")
        self._last_tick = tick
        self._seq += 1
        self._buf.append(TraceRecord(self._seq, tick, kind, data))

    def emit(self, event: TraceEvent) -> None:
        d = asdict(event)
        tick = d.pop("tick")
        self._push(tick, type(event).KIND, d)

    def sample(self, tick: int, data: Mapping[str, Any]) -> None:
        """A periodic state snapshot — readable without re-simulating."""
        self._push(tick, "sample", dict(data))

    def drain(self) -> list[TraceRecord]:
        out = self._buf
        self._buf = []
        return out


class TraceWriter:
    """Drains a TraceBus to a JSONL file. Used by the app for human
    sessions and by the testkit harness for bot runs — the same writer, so
    the two artifacts cannot drift apart.

    Failures are loud: an unopenable path raises at construction and a
    failed write raises at the drain site. No silent fallback log."""

    __slots__ = ("_fh", "path")

    def __init__(self, path, header: Mapping[str, Any]):
        import io
        import os
        os.makedirs(os.path.dirname(str(path)) or ".", exist_ok=True)
        self.path = str(path)
        self._fh: io.TextIOBase = open(self.path, "w", encoding="utf-8")
        self._fh.write(json.dumps({"kind": "header", **header},
                                  separators=(",", ":")) + "\n")

    def drain_from(self, bus: TraceBus) -> int:
        recs = bus.drain()
        for rec in recs:
            self._fh.write(to_json_line(rec) + "\n")
        return len(recs)

    def close(self) -> None:
        self._fh.flush()
        self._fh.close()
