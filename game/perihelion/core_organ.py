"""The CORE — an organ, not a boss (U11, DESIGN_7_25 §1b).

An entire system of parts with deliberately OPPOSITE time constants:
Collars change the current fight (dispatch slows the instant one dies),
Anchors and Sources change the economy later, Caretakers decide whether
anything you did persists. No mandatory order, no invulnerable phase,
no master health bar — and no blackout timer anywhere: killing all
three Sources sets the reserve to -32 and the outage IS that debt being
repaid.

This module owns the bookkeeping (what exists, what regenerates, what
production the depot gets); the parts' BODIES are ordinary shootable
entities the sim owns — damage arrives through the sim's one damage
door and is reported here.
"""
from __future__ import annotations

from dataclasses import dataclass, field

# part kind -> (count, hp) — HP quantized to the player's own weapon
# arithmetic: 42 = one rail, 84 = one charged Tau, 168 = two charged Tau
PART_SPEC = {
    "core_collar": (2, 126.0),
    "core_scriptorium": (1, 84.0),
    "core_caretaker": (4, 42.0),
    "core_anchor": (4, 84.0),
    "core_bud": (12, 42.0),
    "core_source": (3, 168.0),
}
CORE_KINDS = frozenset(PART_SPEC)

# dispatch stretches the moment collars die: 2.20s -> 3.14s -> 4.89s
COLLAR_DISPATCH_FACTOR = {2: 1.0, 1: 3.14 / 2.20, 0: 4.89 / 2.20}

SOURCE_HEAL_DELAY_TICKS = 10 * 60   # undamaged this long, then...
SOURCE_HEAL_PER_TICK = 2.0 / 60.0   # ...2 hp/s knits back
CARETAKER_HEAL_PER_TICK = 6.0 / 60.0  # while physically in contact
MUSTER_RESPONSE_DELAY = 6 * 60      # damage answers ~6s later, ordinarily

# what reforms when the reserve climbs back above zero after a blackout
REFORM_SET = (("core_source", 1), ("core_anchor", 1),
              ("core_bud", 3), ("core_caretaker", 1))


@dataclass
class CorePart:
    part_id: int          # the entity id of its body
    kind: str
    hp: float
    max_hp: float
    chamber: int
    last_damaged_tick: int = -10 ** 9


@dataclass
class CoreOrgan:
    parts: dict = field(default_factory=dict)     # part_id -> CorePart
    blackout_fired: bool = False
    pending_muster: list = field(default_factory=list)  # (tick, chamber)

    # -- membership --------------------------------------------------------

    def add_part(self, part_id: int, kind: str, chamber: int,
                 hp: float | None = None) -> CorePart:
        _, max_hp = PART_SPEC[kind][0], PART_SPEC[kind][1]
        p = CorePart(part_id=part_id, kind=kind,
                     hp=hp if hp is not None else max_hp,
                     max_hp=max_hp, chamber=chamber)
        self.parts[part_id] = p
        return p

    def live(self, kind: str) -> list:
        return [p for p in self.parts.values() if p.kind == kind]

    # -- the sim reports; the organ decides ---------------------------------

    def on_damage(self, part_id: int, tick: int) -> None:
        p = self.parts.get(part_id)
        if p is None:
            return
        p.last_damaged_tick = tick
        self.pending_muster.append((tick + MUSTER_RESPONSE_DELAY, p.chamber))

    def on_destroyed(self, part_id: int, tick: int) -> str | None:
        """Returns 'blackout' exactly once, when the LAST Source dies."""
        p = self.parts.pop(part_id, None)
        if p is None:
            return None
        if p.kind == "core_source" and not self.live("core_source") \
                and not self.blackout_fired:
            self.blackout_fired = True
            return "blackout"
        return None

    # -- couplings the marrow reads -----------------------------------------

    def dispatch_factor(self) -> float:
        return COLLAR_DISPATCH_FACTOR[min(2, len(self.live("core_collar")))]

    def production_capacity(self) -> float:
        """Scales the depot's regeneration: Sources carry thirds, Buds
        carry the finer grain. All twelve buds + three sources = 1.0;
        everything dead = 0 (only home resupply — the debt rate — is
        outside this, which is why the blackout still ends)."""
        sources = len(self.live("core_source")) / 3.0
        buds = len(self.live("core_bud")) / 12.0
        return sources * (0.25 + 0.75 * buds)

    # -- regeneration (the organ heals; the sim mirrors to the bodies) ------

    def step_heal(self, tick: int, caretaker_contacts) -> list:
        """Advance regeneration one tick. `caretaker_contacts` is an
        iterable of part_ids currently in physical contact with a LIVE
        caretaker (the sim computes contact; the organ decides effect).
        Returns [(part_id, new_hp), ...] for bodies the sim must update."""
        out = []
        contacts = set(caretaker_contacts)
        for p in self.parts.values():
            healed = None
            if p.kind == "core_source" and p.hp < p.max_hp \
                    and tick - p.last_damaged_tick >= SOURCE_HEAL_DELAY_TICKS:
                healed = min(p.max_hp, p.hp + SOURCE_HEAL_PER_TICK)
            if p.part_id in contacts and p.hp < p.max_hp:
                healed = min(p.max_hp, (healed if healed is not None
                                        else p.hp) + CARETAKER_HEAL_PER_TICK)
            if healed is not None and healed != p.hp:
                p.hp = healed
                out.append((p.part_id, p.hp))
        return out

    def due_musters(self, tick: int) -> list:
        due = [c for t, c in self.pending_muster if t <= tick]
        self.pending_muster = [(t, c) for t, c in self.pending_muster
                               if t > tick]
        return due

    def reform_due(self, reserve: float) -> bool:
        """After a blackout, the organ reforms minimal the moment the
        debt is repaid — the recovery is tied to the reserve crossing
        zero, never to a clock."""
        return self.blackout_fired and reserve > 0.0

    def reform(self) -> list:
        """Consume the blackout state; returns the minimal part set to
        re-embody: [(kind, count), ...]."""
        self.blackout_fired = False
        return list(REFORM_SET)
