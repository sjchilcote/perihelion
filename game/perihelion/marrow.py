"""The marrow — reserve economy, cost-fair dispatch, breach lifecycle
(U9, DESIGN_7_25 §1b).

The economy is CLOSED-LOOP AND BLIND: regeneration is driven by how
empty the depot is, never by how the fight is going — this module has
no way to read Distress, kills, player health, or difficulty, because
nothing of the sort is in reach of its inputs. When the next unit is
unaffordable the marrow WAITS for that unit — it never substitutes
something cheaper, which is what makes the stutter at the gate an
honest reserve gauge.

Breaches never read the reserve and never see each other; the marrow —
the only thing that owns dispatch — is the only thing comparing them.
"""
from __future__ import annotations

from dataclasses import dataclass, field

RESERVE_CAP = 120.0
REGEN_BASE = 0.10          # per second when full
REGEN_EMPTY_BOOST = 2.5    # -> 0.35/s when empty (and during debt)
CORE_KILL_DEBT = -32.0     # ~90s at the 0.35/s home-resupply rate

DISPATCH_COST = {"mite": 1, "husk": 2, "spitter": 2, "shrieker": 3,
                 "flicker": 3, "brute": 4, "warden": 8}
DISPATCH_INTERVAL_TICKS = 132          # ~2.2 s of sustained pour
FORMATION_TICKS = 180                  # the 3 s formation tell
IDLE_CLOSE_TICKS = 45 * 60             # nothing crossed for 45 s
EXHAUST_GRACE_TICKS = 10 * 60          # reserve gone: 10 s invasion grace
NO_ROUTE_CLOSE_TICKS = 12 * 60         # nobody hub-side wants it
# 'the reserve has run out' means: not even the cheapest body can be
# paid for (regen is always positive, so exact zero is a phantom — only
# debt goes below it)
EXHAUSTED_FLOOR = 1.0

# the standing guardian shelf: real, dispatchable bodies — when they
# leave, the entrance genuinely weakens (replacements are U11 work)
GUARDIAN_SHELF = ("mite", "mite", "mite", "husk", "husk",
                  "spitter", "shrieker", "flicker", "brute", "warden")


class ReserveDepot:
    __slots__ = ("reserve",)

    def __init__(self, reserve: float = RESERVE_CAP):
        self.reserve = float(reserve)

    def advance(self, elapsed_seconds: float) -> None:
        empty = max(0.0, min(1.0, 1.0 - self.reserve / RESERVE_CAP))
        regen = REGEN_BASE * (1.0 + REGEN_EMPTY_BOOST * empty)
        self.reserve = min(RESERVE_CAP, self.reserve + regen * elapsed_seconds)

    def can_pay(self, cost: float) -> bool:
        return self.reserve >= cost

    def pay(self, cost: float) -> None:
        if not self.can_pay(cost):
            raise ValueError(f"cannot pay {cost} from {self.reserve}")
        self.reserve -= cost

    def set_debt(self, amount: float) -> None:
        """The core-kill status effect: the outage IS the debt being
        repaid — there is no blackout timer anywhere."""
        self.reserve = float(amount)


class CostFairScheduler:
    """Multiple breaches split combat EXPENDITURE, not headcount: each
    live breach accrues equal credit; the readiest unit goes to the
    breach with the most credit and its cost is subtracted. A new breach
    starts at the mean so it neither starves nor floods."""

    __slots__ = ("_credit",)

    def __init__(self) -> None:
        self._credit: dict[int, float] = {}

    def add_breach(self, breach_id: int) -> None:
        mean = (sum(self._credit.values()) / len(self._credit)
                if self._credit else 0.0)
        self._credit[breach_id] = mean

    def remove_breach(self, breach_id: int) -> None:
        self._credit.pop(breach_id, None)

    def accrue(self, amount: float = 1.0) -> None:
        for k in self._credit:
            self._credit[k] += amount

    def assign(self, unit_cost: float) -> int | None:
        if not self._credit:
            return None
        bid = max(sorted(self._credit), key=lambda k: self._credit[k])
        self._credit[bid] -= unit_cost
        return bid


@dataclass
class Breach:
    """A hole — an absence of material. It cannot be killed, it knows
    nothing of reserves or of other breaches; it counts crossings and
    honors close REQUESTS."""
    breach_id: int
    world_chamber: int
    hub_chamber: int
    opened_tick: int
    link: object                       # topology PortalLink
    last_cross_tick: int = 0
    last_interest_tick: int = 0
    closing_reason: str | None = None
    close_at_tick: int = 0
    pour_started: bool = False

    def note_crossing(self, tick: int) -> None:
        self.last_cross_tick = tick
        if self.closing_reason == "idle":
            self.closing_reason = None    # a crossing re-arms the idle clock

    def note_interest(self, tick: int) -> None:
        self.last_interest_tick = tick

    def request_close(self, reason: str, tick: int, grace: int) -> None:
        if self.closing_reason is None:
            self.closing_reason = reason
            self.close_at_tick = tick + grace

    def should_seal(self, tick: int) -> str | None:
        if tick - max(self.last_cross_tick, self.opened_tick) \
                >= IDLE_CLOSE_TICKS:
            return "idle"
        if self.closing_reason is not None and tick >= self.close_at_tick:
            return self.closing_reason
        if tick - max(self.last_interest_tick, self.opened_tick) \
                >= NO_ROUTE_CLOSE_TICKS:
            return "no_route"
        return None


@dataclass
class MarrowCommand:
    kind: str                          # "open" | "dispatch" | "seal"
    imprint: object = None
    breach_id: int = -1
    unit_kind: str = ""
    reason: str = ""


class MarrowController:
    """Owns the depot, the scheduler, and the pending-unit stall. Input
    per step: the tick, the imprints the medium yields, and breach
    statuses. NOTHING about the player or the fight is in the
    signature — the blindness is structural."""

    __slots__ = ("depot", "sched", "_next_dispatch", "_pending_kind",
                 "_shelf_queue")

    def __init__(self) -> None:
        self.depot = ReserveDepot()
        self.sched = CostFairScheduler()
        self._next_dispatch = 0
        self._pending_kind: str | None = None
        # the initial pour leads with the standing shelf — ONE physical
        # set of pre-produced bodies for the whole hub, not one per
        # breach: a fresh call leads with guardians only while guardians
        # remain, which is exactly the second-ranked tell (later calls
        # lose the guardian burst)
        self._shelf_queue: list[str] = list(GUARDIAN_SHELF)

    def on_breach_opened(self, breach_id: int, tick: int) -> None:
        self.sched.add_breach(breach_id)
        self._next_dispatch = max(self._next_dispatch,
                                  tick + FORMATION_TICKS)

    def on_breach_sealed(self, breach_id: int) -> None:
        self.sched.remove_breach(breach_id)

    def step(self, tick: int, imprint, live_breaches) -> list[MarrowCommand]:
        out: list[MarrowCommand] = []
        self.depot.advance(1.0 / 60.0)
        if imprint is not None and self.depot.reserve >= EXHAUSTED_FLOOR:
            # ratified: when the reserve is exhausted the marrow STOPS
            # OPENING portals — the consumed call stays dry
            out.append(MarrowCommand(kind="open", imprint=imprint))
        if self.depot.reserve < EXHAUSTED_FLOOR:
            for b in live_breaches:
                b.request_close("exhausted", tick, EXHAUST_GRACE_TICKS)
        if live_breaches and tick >= self._next_dispatch \
                and self.depot.reserve > 0.0:
            kind = self._pending_kind or (
                self._shelf_queue[0] if self._shelf_queue
                else self._rotation(tick))
            if self._shelf_queue and kind == self._shelf_queue[0]:
                cost = 0.0                     # shelf: pre-produced
            else:
                cost = float(DISPATCH_COST[kind])
            if cost > 0.0 and not self.depot.can_pay(cost):
                # THE STALL: wait for THIS unit; the gap at the gate is
                # the reserve gauge and it cannot lie
                self._pending_kind = kind
            else:
                self.sched.accrue(1.0)
                bid = self.sched.assign(cost if cost > 0.0 else
                                        float(DISPATCH_COST[kind]))
                if bid is not None:
                    if cost > 0.0:
                        self.depot.pay(cost)
                    else:
                        self._shelf_queue.pop(0)
                    self._pending_kind = None
                    self._next_dispatch = tick + DISPATCH_INTERVAL_TICKS
                    out.append(MarrowCommand(kind="dispatch",
                                             breach_id=bid, unit_kind=kind))
        for b in live_breaches:
            reason = b.should_seal(tick)
            if reason is not None:
                out.append(MarrowCommand(kind="seal",
                                         breach_id=b.breach_id,
                                         reason=reason))
        return out

    @staticmethod
    def _rotation(tick: int) -> str:
        """The sustained-pour mix once the shelf is spent — deterministic
        rotation weighted toward the delivered strike package (first
        pass; the ratified composition tables land with the CORE organ)."""
        cycle = ("husk", "mite", "spitter", "husk", "flicker",
                 "mite", "brute", "shrieker")
        return cycle[(tick // DISPATCH_INTERVAL_TICKS) % len(cycle)]
