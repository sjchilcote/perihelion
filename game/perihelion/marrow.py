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

from collections import Counter
from dataclasses import dataclass, field

# THE WORLD IS POPULATED, NOT STOCKED (director 2026-08-01: "the hub
# needs to be generating enemies WAY more often... 10x the enemy count.
# This shouldn't be a video game level you clear — it's a world,
# populated by the enemy, who are actively working against you").
#
# Measured on a real 24-minute session: the census fell 277 -> 15,
# monotonically, and never once recovered. Income was 0.35/s against an
# average body cost of 3, so the marrow could field ~7 bodies a minute
# while the player killed 17. The reserve sat at zero for 22 of the 24
# minutes — the hive was broke from minute two onward, and "clearing the
# level" was just outspending it.
#
# Income was the FIRST limit; it was not the only one. The claim that
# once stood here — "a 132-tick interval across 3 breaches carries ~81
# bodies a minute" — was false, and the gate caught it: the dispatch
# counter is a single global, so breach count bought nothing and the
# pipeline stayed pinned near 27/min while the reserve banked 290 of
# 300 unspent. Both ends are fixed now (see the per-breach divisor in
# `step`); this comment is kept as written-down proof that arithmetic
# in a comment is not arithmetic in the code.
RESERVE_CAP = 300.0
REGEN_BASE = 1.00          # per second when full
REGEN_EMPTY_BOOST = 2.5    # -> 3.5/s when empty (and during debt)
# scaled WITH the regen it is denominated in: this is "~90s of outage",
# and at the new resupply rate the old -32.0 would have been nine
# seconds — a core kill has to keep costing the hive what it used to
CORE_KILL_DEBT = -320.0    # ~90s at the 3.5/s home-resupply rate

DISPATCH_COST = {"mite": 1, "husk": 2, "spitter": 2, "shrieker": 3,
                 "flicker": 3, "brute": 4, "warden": 8}
DISPATCH_INTERVAL_TICKS = 132          # ~2.2 s of sustained pour
SHELF_BURST_TICKS = 36                 # the shelf SURGES: pre-produced
#   bodies pour at ~0.6 s so the opening beat reads as a pour on
#   screen, not a trickle (ratified pour shape: formation tell ->
#   BURST from the shelf -> sustained 2.2 s production)
FORMATION_TICKS = 180                  # the 3 s formation tell
IDLE_CLOSE_TICKS = 45 * 60             # nothing crossed for 45 s
EXHAUST_GRACE_TICKS = 10 * 60          # reserve gone: 10 s invasion grace
NO_ROUTE_CLOSE_TICKS = 12 * 60         # nobody hub-side wants it
# 'the reserve has run out' means: not even the cheapest body can be
# paid for (regen is always positive, so exact zero is a phantom — only
# debt goes below it)
EXHAUSTED_FLOOR = 1.0

# the standing guardian shelf: real, dispatchable bodies — when they
# leave, the entrance genuinely weakens. Replacements cost reserve and
# arrive no faster than one per 12 s (ratified §1b), which makes the
# timing the actual skill: the safest moment to invade is while the
# shelf is away fighting somewhere else.
GUARDIAN_SHELF = ("mite", "mite", "mite", "husk", "husk",
                  "spitter", "shrieker", "flicker", "brute", "warden")
REPLACE_INTERVAL_TICKS = 12 * 60

# the delivered strike package (ratified composition): 35% screen /
# 25% ranged / 15% mobility / 25% breaker over a deterministic 20-slot
# cycle — breakers never adjacent, the warden lands deep in the cycle
STRIKE_CYCLE = ("mite", "spitter", "husk", "brute", "mite",
                "shrieker", "flicker", "husk", "spitter", "brute",
                "mite", "flicker", "husk", "brute", "spitter",
                "mite", "shrieker", "brute", "flicker", "warden")


class ReserveDepot:
    __slots__ = ("reserve",)

    def __init__(self, reserve: float = RESERVE_CAP):
        self.reserve = float(reserve)

    def advance(self, elapsed_seconds: float, capacity: float = 1.0) -> None:
        """`capacity` scales LOCAL production (the CORE's sources and
        buds). Debt repayment is home-universe resupply and ignores it —
        which is why a blackout always ends even with the organ gutted."""
        if self.reserve < 0.0:
            regen = REGEN_BASE * (1.0 + REGEN_EMPTY_BOOST)
        else:
            empty = max(0.0, min(1.0, 1.0 - self.reserve / RESERVE_CAP))
            regen = REGEN_BASE * (1.0 + REGEN_EMPTY_BOOST * empty) \
                * max(0.0, capacity)
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

    def cancel_close(self, reason: str) -> None:
        """The latch was a bug: an 'exhausted' close kept its deadline
        after the reserve recovered, so seals fired on a healthy
        economy (run 39 ledger: seals at reserve 3.19 and 4.08). The
        marrow — the only thing that may read the reserve — cancels."""
        if self.closing_reason == reason:
            self.closing_reason = None
            self.close_at_tick = 0

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
                 "_shelf_queue", "_next_replace")

    def __init__(self) -> None:
        self.depot = ReserveDepot()
        self.sched = CostFairScheduler()
        self._next_dispatch = 0
        self._next_replace = 0
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

    def step(self, tick: int, imprint, live_breaches, *,
             shelf_census: list[str],
             dispatch_factor: float = 1.0,
             capacity: float = 1.0) -> list[MarrowCommand]:
        out: list[MarrowCommand] = []
        self.depot.advance(1.0 / 60.0, capacity)
        # the physical hub is authoritative: the pour queue is re-derived
        # from the bodies actually standing at the posts, so a guardian
        # shot AT its post leaves the books the same way one that
        # marched out does — the two can never diverge
        self._reconcile_shelf(shelf_census)
        if not live_breaches:
            # the shelf rebuilds only in quiet: during a pour every
            # body and every point of reserve belongs to the gate, so
            # tell #1's arithmetic — wait = (cost - reserve)/regen —
            # stays exact. The rebuild window after a fight IS the
            # 'safest moment to invade' from the ratified spec.
            out.extend(self._step_replacement(tick, shelf_census))
        if imprint is not None and self.depot.reserve >= EXHAUSTED_FLOOR:
            # ratified: when the reserve is exhausted the marrow STOPS
            # OPENING portals — the consumed call stays dry
            out.append(MarrowCommand(kind="open", imprint=imprint))
        if self.depot.reserve < EXHAUSTED_FLOOR:
            for b in live_breaches:
                b.request_close("exhausted", tick, EXHAUST_GRACE_TICKS)
        else:
            for b in live_breaches:
                b.cancel_close("exhausted")
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
                    # collar damage stretches the cadence IMMEDIATELY —
                    # the dispatch machinery visibly missing beats is the
                    # third-ranked tell. Shelf bodies BURST (they exist
                    # already); production holds the sustained beat.
                    base = (SHELF_BURST_TICKS if cost == 0.0
                            else DISPATCH_INTERVAL_TICKS)
                    # THE CADENCE IS PER WAY IN, NOT PER HIVE. This
                    # counter is global, so three open breaches poured
                    # no faster than one and the whole pipeline was
                    # pinned near 27 bodies a minute however rich the
                    # marrow got — which is exactly why raising income
                    # tenfold left 290 of 300 reserve sitting unspent.
                    # A second doorway is a second throat.
                    self._next_dispatch = tick + max(1, int(
                        base * max(1.0, dispatch_factor)
                        / max(1, len(live_breaches))))
                    out.append(MarrowCommand(kind="dispatch",
                                             breach_id=bid, unit_kind=kind))
        for b in live_breaches:
            reason = b.should_seal(tick)
            if reason is not None:
                out.append(MarrowCommand(kind="seal",
                                         breach_id=b.breach_id,
                                         reason=reason))
        return out

    def _reconcile_shelf(self, shelf_census: list[str]) -> None:
        remaining = Counter(shelf_census)
        queue = []
        for k in GUARDIAN_SHELF:
            if remaining[k] > 0:
                remaining[k] -= 1
                queue.append(k)
        self._shelf_queue = queue

    def _step_replacement(self, tick: int,
                          shelf_census: list[str]) -> list[MarrowCommand]:
        """Rebuild the standing shelf toward its canonical composition:
        each replacement costs reserve and arrives no faster than one
        per 12 s (ratified). Canonical order — the screen rebuilds
        first. Like the gate, this never substitutes: if the next
        needed body is unaffordable, the post stays vacant until the
        reserve covers IT."""
        if tick < self._next_replace \
                or self.depot.reserve < EXHAUSTED_FLOOR:
            return []
        deficit = Counter(GUARDIAN_SHELF) - Counter(shelf_census)
        kind = next((k for k in GUARDIAN_SHELF if deficit[k] > 0), None)
        if kind is None:
            return []
        cost = float(DISPATCH_COST[kind])
        if not self.depot.can_pay(cost):
            return []
        self.depot.pay(cost)
        self._next_replace = tick + REPLACE_INTERVAL_TICKS
        return [MarrowCommand(kind="replace", unit_kind=kind)]

    @staticmethod
    def _rotation(tick: int) -> str:
        """The sustained-pour mix once the shelf is spent: the ratified
        delivered-strike composition — 35% screen, 25% ranged, 15%
        mobility, 25% breaker — as a deterministic 20-slot cycle."""
        return STRIKE_CYCLE[(tick // DISPATCH_INTERVAL_TICKS)
                            % len(STRIKE_CYCLE)]
