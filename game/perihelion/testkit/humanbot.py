"""HumanBot: the marketing-playthrough bot (BOT_REALISM_DESIGN.md).

Perception layer (`PerceptionModel`) -> reactive executor (this module) ->
humanized input synthesis (`MouseModel` for aim; movement/fire stay in
`InputFrame`, the same struct every bot in `bots.py` and the real player's
`_input_frame` produce -- see that module's docstring for why that is the
honest boundary here: the sim never sees anything but `InputFrame`, exactly
like it does for real keyboard/mouse input).

What makes this bot different from `AggroBot` is entirely upstream of that
struct: it never looks at `snapshot["enemies"]` directly, only at what
`PerceptionModel.perceive` releases after room-locality + reaction latency;
its aim is the output of a velocity/accel-bounded `MouseModel`, not a
computed angle; and it carries stress state (flinch, pressure) sampled from
its own seeded RNG stream, per design doc §8.

The optional Sonnet tactical layer (§7) is out of scope for this module --
see `tools/playtest/tactician.py`. Without it, `HumanBot` runs on the
static default policy below, which is enough to be tested and to clear
levels standalone.
"""

from __future__ import annotations

import math
from random import Random

import necore

from ..sim import GameSession, InputFrame, WEAPON_ORDER
from .bots import (Bot, _UnstickMixin, _dist, _norm, choose_weapon,
                    nav_to_exit, nav_to_point, nav_to_room)
from .mouse_model import MouseModel
from .perception import PerceptionModel

# Anticipation: an entity is "pre-aimed" if it appears within this many
# radians of wherever the cursor already was pointing when it was first
# perceived -- design doc §3 ("the cursor lives where danger is expected").
# This makes anticipation an emergent property of prior aim, not a scripted
# room-entry flag.
ANTICIPATE_CONE = math.radians(35.0)

# Flinch: taking damage kicks the aim off-target for ~100ms before recovery
# (design doc §5). At 60Hz, 100ms ~= 6 ticks.
FLINCH_TICKS = 6
FLINCH_ANGLE_RANGE = (0.35, 0.75)

# Fire discipline: only shoot once tracking error is within this angle of
# the (perceived, latency-delayed) target -- mirrors _CombatMixin's AGGRO
# baseline but measured against the humanized aim point, not a raw angle.
FIRE_ERR = math.radians(9.0)

# Single skill knob (design doc §8): scales the fire-discipline window
# (`allowed_px` in `_combat_input`) that gates when the humanized cursor is
# "close enough" to shoot. 1.0 is a plausible human aim cone but measured
# too low against HARD-mode multi-enemy rooms on l01 (0/3 survival attempts,
# ~1-6% fire duty cycle -- see BOT_REALISM_DESIGN.md skill-floor check,
# 2026-07-13). 4.0 clears l01/HARD in 2 of 3 attempts (the third is a real
# death, kept as honest footage per design doc §5) at a still-low ~5-18%
# fire duty cycle -- tune this one number, not the reaction-latency or
# mouse-trajectory constants, if the director wants the bot sharper/sloppier.
DEFAULT_SKILL = 4.0


class HumanBot(_UnstickMixin, Bot):
    """Perception -> policy -> reactive executor -> MouseModel input
    synthesis. Fights only what `PerceptionModel` has released, aims only
    where `MouseModel` has smoothed the cursor to, flinches on damage,
    and defaults to `AggroBot`'s navigation policy when no threat is live."""

    def __init__(self, seed: int = 0, skill: float = DEFAULT_SKILL):
        super().__init__(seed)
        self._init_unstick()
        self.skill = skill
        self._perception = PerceptionModel(seed=Random(seed).randrange(1 << 30))
        self._mouse: MouseModel | None = None
        self._mouse_seed = Random(seed).randrange(1 << 30)
        self._prev_hp: float | None = None
        self._flinch_ticks = 0
        self._flinch_angle = 0.0
        self._flinch_rng = Random(Random(seed).randrange(1 << 30))
        self._aim_world_angle = 0.0  # last aim direction in room space
        self._med_target = None
        self._strafe_sign = 1
        self._strafe_rng = Random(Random(seed).randrange(1 << 30))
        self._weapon_want = 0
        self._weapon_want_ticks = 0
        # policy set by the tactician (or defaults); see design doc §7
        self.policy = dict(movement="advance-carefully", risk="normal",
                            target_priority=None)

    # -- diagnostics used by tests -----------------------------------
    @property
    def perception(self) -> PerceptionModel:
        return self._perception

    def _ensure_mouse(self, ax: float, ay: float) -> MouseModel:
        if self._mouse is None:
            self._mouse = MouseModel(ax, ay, seed=self._mouse_seed)
        return self._mouse

    def _anticipated_ids(self, session: GameSession, snapshot: dict,
                          px: float, py: float) -> frozenset[int]:
        out = []
        for e in snapshot["enemies"]:
            if e["room"] != snapshot["room"]:
                continue
            if self._perception.ticks_perceivable(e["id"], snapshot["tick"]) >= 0:
                continue  # already tracked, anticipation only matters at first sight
            ex, ey = e["pos"]
            true_angle = math.atan2(ey - py, ex - px)
            delta = abs(math.atan2(math.sin(true_angle - self._aim_world_angle),
                                    math.cos(true_angle - self._aim_world_angle)))
            if delta <= ANTICIPATE_CONE:
                out.append(e["id"])
        return frozenset(out)

    def _apply_flinch(self, snapshot: dict) -> None:
        hp = snapshot["hp"]
        if self._prev_hp is not None and hp < self._prev_hp:
            self._flinch_ticks = FLINCH_TICKS
            lo, hi = FLINCH_ANGLE_RANGE
            mag = self._flinch_rng.uniform(lo, hi)
            sign = self._flinch_rng.choice((-1.0, 1.0))
            self._flinch_angle = mag * sign
        self._prev_hp = hp
        if self._flinch_ticks > 0:
            self._flinch_ticks -= 1

    def step(self, snapshot: dict, session: GameSession) -> InputFrame:
        proom = snapshot["room"]
        px, py = snapshot["pos"]
        tick = snapshot["tick"]
        self._apply_flinch(snapshot)

        anticipated = self._anticipated_ids(session, snapshot, px, py)
        perceived = self._perception.perceive(snapshot, tick, anticipated)

        if perceived:
            inp = self._combat_input(session, snapshot, perceived, px, py)
        else:
            inp = InputFrame()
            medkits = [p for p in snapshot["pickups"]
                       if p["kind"] == "medkit" and 0 <= p["hops"] <= 3]
            if snapshot["hp"] < 60 and medkits:
                target = None
                if self._med_target is not None:
                    target = next((p for p in medkits
                                   if (p["room"], p["pos"]) == self._med_target),
                                  None)
                if target is None:
                    target = min(medkits, key=lambda p: (p["hops"], p["room"]))
                    self._med_target = (target["room"], target["pos"])
                if target["room"] == proom:
                    inp.mx, inp.my = nav_to_point(session, px, py, target["pos"])
                else:
                    inp.mx, inp.my = nav_to_room(session, snapshot, target["room"], None)
            else:
                self._med_target = None
                inp.mx, inp.my = nav_to_exit(session, snapshot)
            rest_x, rest_y = session.screen_w / 2.0, session.screen_h / 2.0
            mouse = self._ensure_mouse(rest_x, rest_y)
            inp.ax, inp.ay = mouse.step(rest_x, rest_y, 1.0 / 60.0)

        return self._apply_unstick(px, py, inp)

    def _combat_input(self, session: GameSession, snapshot: dict,
                       perceived: list[dict], px: float, py: float) -> InputFrame:
        nearest = min(perceived, key=lambda e: _dist(e["pos"], (px, py)))
        ex, ey = nearest["pos"]
        dx, dy = ex - px, ey - py
        dist = math.hypot(dx, dy) or 1e-6
        true_angle = math.atan2(dy, dx)
        self._aim_world_angle = true_angle

        aim_angle = true_angle + self._flinch_angle
        tx, ty = px + math.cos(aim_angle) * dist, py + math.sin(aim_angle) * dist
        target_ax, target_ay = necore.mat_apply(session.cam, tx, ty)

        mouse = self._ensure_mouse(target_ax, target_ay)
        cur_ax, cur_ay = mouse.step(target_ax, target_ay, 1.0 / 60.0)

        inp = InputFrame()
        inp.ax, inp.ay = cur_ax, cur_ay

        # fire discipline reacts to where the humanized cursor actually is
        # relative to the true (un-flinched) target position on screen --
        # mouse lag, overshoot, and flinch all show up here as misses,
        # rather than as a separately-computed "true" aim error
        true_ax, true_ay = necore.mat_apply(session.cam, ex, ey)
        screen_err = math.hypot(cur_ax - true_ax, cur_ay - true_ay)
        target_r = session.sim.get_radius(nearest["id"]) \
            if session.sim.exists(nearest["id"]) else 8.0
        cam_scale = math.hypot(*necore.mat_apply_dir(session.cam, 1.0, 0.0)) or 1.0
        allowed_px = max(6.0 * self.skill, target_r * 0.9 * cam_scale)
        inp.fire = self._flinch_ticks == 0 and screen_err < allowed_px

        want = choose_weapon(snapshot, dist, len(perceived))
        cur = WEAPON_ORDER.index(snapshot["weapon"]) + 1 \
            if snapshot["weapon"] in WEAPON_ORDER else 0
        self._weapon_want_ticks = self._weapon_want_ticks + 1 \
            if want == self._weapon_want else 0
        self._weapon_want = want
        inp.weapon = want if (want == cur or self._weapon_want_ticks >= 12) else 0
        inp.alt = (len(perceived) >= 3 and snapshot["lightning_ready"]
                   and "lightning" in snapshot["weapons"])

        weapon_name = WEAPON_ORDER[inp.weapon - 1] if inp.weapon else snapshot["weapon"]
        ux, uy = dx / dist, dy / dist
        perp = (-uy, ux)
        pressure = min(1.0, len(perceived) / 3.0) + (0.0 if snapshot["hp"] > 40 else 0.4)
        if weapon_name == "knife":
            move_room = (ux, uy)
        elif dist < 60.0 or snapshot["hp"] < 30:
            move_room = (-ux, -uy)  # disengage / backpedal-while-firing when hurt
        elif dist > 140.0:
            move_room = (ux, uy)
        else:
            j = self._strafe_rng.uniform(-0.3 - 0.2 * pressure, 0.3 + 0.2 * pressure)
            move_room = (perp[0] * self._strafe_sign + j * ux,
                         perp[1] * self._strafe_sign + j * uy)
            if self._strafe_rng.random() < 0.02:
                self._strafe_sign *= -1
        mvx, mvy = _norm(move_room)
        sx, sy = necore.mat_apply_dir(session.cam, mvx, mvy)
        inp.mx, inp.my = _norm((sx, sy))
        return inp
