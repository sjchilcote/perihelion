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
import time
from dataclasses import asdict, dataclass, field, fields
from typing import Any, Mapping

_perf = time.perf_counter


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
    # where the transition happened (run 51: freeze certification could
    # only be proxied for ~90% of the population without positions)
    x: float = 0.0
    y: float = 0.0


@dataclass(frozen=True, slots=True)
class EnemyPositions:
    KIND = "enemy_positions"
    # one bulk snapshot per cadence: eid -> [kind, polygon, x, y]. Replaces
    # the warden-only rows that squatted the player's 'sample' schema
    # (run 51: 77% of sample rows were wardens shadowing the player).
    tick: int
    positions: dict


@dataclass(frozen=True, slots=True)
class PlayerDeath:
    KIND = "player_death"
    # first-class death record (run 51: judges reconstructed deaths from
    # hp staircases in DamageApplied rows)
    tick: int
    polygon: int
    x: float
    y: float
    source: str          # what landed the killing blow
    chassis_left: int
    deaths: int          # cumulative, this session


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
class PickupTaken:
    KIND = "pickup_taken"
    tick: int
    item: str    # NOT 'kind': a field named kind would shadow the
    #              record's own kind in to_json_line's merge and the
    #              event would serialize as kind='medkit' — invisible
    #              to every kind-based scan (found live: judges kept
    #              seeing 'unexplained heals' after tracing was added)
    amount: float


@dataclass(frozen=True, slots=True)
class ShelfReplaced:
    KIND = "shelf_replaced"
    tick: int
    unit_kind: str
    entity_id: int
    hub_chamber: int


@dataclass(frozen=True, slots=True)
class EnemyDeath:
    KIND = "enemy_death"
    tick: int
    entity_id: int
    enemy_kind: str
    polygon: int


@dataclass(frozen=True, slots=True)
class CoordEvent:
    # coordination-layer decisions (holds, prowls, watchdogs) — the
    # judged behaviors run 42b called unjudgeable: danger_hold, prowl,
    # and both chase watchdogs emitted no telemetry, so their filmed
    # absence was indistinguishable from their filmed failure
    KIND = "coord_event"
    tick: int
    entity_id: int
    agent_kind: str
    event: str                # hold_engage / hold_end / prowl_start /
    #                           prowl_end / flank_switch / pursuit_stuck
    detail: str


@dataclass(frozen=True, slots=True)
class FrameTiming:
    """What the loop actually spent, per phase, over a window of frames.

    The sim has no concept of a frame, so this is the one record the APP
    emits into the session bus. It exists because "unplayably slow" was
    for a long time a report we could not answer with evidence — the fps
    meter showed one number with no breakdown, and a recording, a draw,
    and a heavy tick all look identical from the outside.

    `sim_ticks / frames` is the tell that matters most: 1.0 is healthy,
    and the loop's 4-tick catch-up cap means anything approaching 4.0 is
    a frame that can no longer keep the sim on the wall clock — the game
    is running in slow motion, not just drawing less often.
    """
    KIND = "frame_timing"
    tick: int
    frames: int          # frames in this window
    fps: float           # observed, wall clock — what the player feels
    ms_frame: float      # mean work per frame (total minus voluntary wait)
    ms_worst: float      # worst single frame of work in the window
    ms_sim: float        # per-frame means below
    ms_draw: float
    ms_present: float
    ms_record: float
    ms_wait: float       # idle headroom; large is GOOD
    sim_ticks: int       # sim ticks executed across the window


class FrameMeter:
    """Wall-clock accumulator for FrameTiming. Stdlib-only, no I/O.

    Usage per frame: begin(), then mark(phase) at the end of each phase,
    then end(tick, sim_ticks) -> FrameTiming | None (one record per
    window). Time between marks that no phase claims stays visible: the
    phase means are reported alongside ms_frame, so unattributed cost
    shows up as the gap rather than being silently folded into a phase.
    """

    PHASES = ("sim", "draw", "present", "record", "wait")

    __slots__ = ("window", "_acc", "_frames", "_worst", "_ticks",
                 "_t_phase", "_t_frame", "_wall0", "_frame_work")

    def __init__(self, window: int = 60) -> None:
        if window < 1:
            raise ValueError(f"frame window must be >= 1, got {window}")
        self.window = int(window)
        self._acc = dict.fromkeys(self.PHASES, 0.0)
        self._frames = 0
        self._worst = 0.0
        self._ticks = 0
        self._frame_work = 0.0
        self._t_phase = 0.0
        self._t_frame = 0.0
        self._wall0 = _perf()

    def begin(self) -> None:
        now = _perf()
        self._t_phase = self._t_frame = now
        self._frame_work = 0.0

    def mark(self, phase: str) -> None:
        if phase not in self._acc:
            raise KeyError(f"unknown frame phase {phase!r}; "
                           f"expected one of {self.PHASES}")
        now = _perf()
        dt = now - self._t_phase
        self._t_phase = now
        self._acc[phase] += dt
        if phase != "wait":
            self._frame_work += dt

    def end(self, tick: int, sim_ticks: int) -> FrameTiming | None:
        self._frames += 1
        self._ticks += int(sim_ticks)
        if self._frame_work > self._worst:
            self._worst = self._frame_work
        if self._frames < self.window:
            return None
        now = _perf()
        wall = now - self._wall0
        n = self._frames
        rec = FrameTiming(
            tick=int(tick), frames=n,
            fps=round(n / wall, 1) if wall > 0 else 0.0,
            ms_frame=round(1000.0 * (wall - self._acc["wait"]) / n, 2),
            ms_worst=round(1000.0 * self._worst, 2),
            ms_sim=round(1000.0 * self._acc["sim"] / n, 2),
            ms_draw=round(1000.0 * self._acc["draw"] / n, 2),
            ms_present=round(1000.0 * self._acc["present"] / n, 2),
            ms_record=round(1000.0 * self._acc["record"] / n, 2),
            ms_wait=round(1000.0 * self._acc["wait"] / n, 2),
            sim_ticks=self._ticks)
        self._acc = dict.fromkeys(self.PHASES, 0.0)
        self._frames = 0
        self._worst = 0.0
        self._ticks = 0
        self._wall0 = now
        return rec


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
              | DispatchDecision | ShelfReplaced | CorePartEvent
              | PickupTaken | EnemyDeath | CoordEvent | FrameTiming)


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
        if "kind" in d:
            raise ValueError(
                f"{type(event).__name__} has a 'kind' field — it would "
                "shadow the record kind in serialization; rename it")
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
