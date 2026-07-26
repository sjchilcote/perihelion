"""Generic captor/captive service (U6, DESIGN_7_25 §3 Warden engulf).

The Warden's engulf is the first user, but nothing here knows what a
Warden is or what a player is — a capture is two entity ids, a pull, a
burn rate, and a release condition ("captor no longer exists"). The
ratified decoupling ("ensure there is no strong coupling between the
player and the Warden") is a module boundary: this file imports nothing
from the game, damage flows through a callback the session provides
(its ONE damage door), and the captor's AI merely begins a spec.

One captor per captive, enforced; the captive's forced fire target is a
query, not a hook into anyone's weapon code.
"""
from __future__ import annotations

import math
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CaptureSpec:
    captor_id: int
    captive_id: int
    pull_speed: float          # u/s drawn toward the captor's core
    damage_per_second: float
    redirect_fire: bool = True


class CaptureSystem:
    __slots__ = ("_by_captive",)

    def __init__(self) -> None:
        self._by_captive: dict[int, CaptureSpec] = {}

    def begin(self, spec: CaptureSpec) -> bool:
        """One captor per captive: a second grab while held is refused."""
        if spec.captive_id in self._by_captive:
            return False
        self._by_captive[spec.captive_id] = spec
        return True

    def held_by(self, captive_id: int) -> int | None:
        spec = self._by_captive.get(captive_id)
        return spec.captor_id if spec is not None else None

    def forced_target(self, entity_id: int) -> int | None:
        spec = self._by_captive.get(entity_id)
        if spec is not None and spec.redirect_fire:
            return spec.captor_id
        return None

    def release_for_entity(self, entity_id: int) -> None:
        """Drop every capture the entity participates in, either side."""
        for cid in [c for c, s in self._by_captive.items()
                    if c == entity_id or s.captor_id == entity_id]:
            del self._by_captive[cid]

    def step(self, world, burn) -> None:
        """Advance every grip one tick. `world` answers exists/get/set_vel
        (the engine sim); `burn(captive_id, captor_id, dps)` is the
        session's damage door — this module never touches HP. A capture
        whose captor stopped existing releases THIS tick."""
        for captive, spec in list(self._by_captive.items()):
            if not world.exists(spec.captor_id) or not world.exists(captive):
                del self._by_captive[captive]
                continue
            _, cx, cy, *_ = world.get(spec.captor_id)
            _, px, py, *_ = world.get(captive)
            dx, dy = cx - px, cy - py
            d = math.hypot(dx, dy)
            if d > 1e-6:
                world.set_vel(captive, dx / d * spec.pull_speed,
                              dy / d * spec.pull_speed)
            burn(captive, spec.captor_id, spec.damage_per_second)
