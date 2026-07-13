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
        spawn = Random(seed)  # one spawner -> independent derived streams
        self._perception = PerceptionModel(seed=spawn.randrange(1 << 30))
        self._mouse: MouseModel | None = None
        self._mouse_seed = spawn.randrange(1 << 30)
        self._prev_hp: float | None = None
        self._flinch_ticks = 0
        self._flinch_angle = 0.0
        self._flinch_rng = Random(spawn.randrange(1 << 30))
        self._aim_world_angle = 0.0  # last aim direction in room space
        self._med_target = None
        self._strafe_sign = 1
        self._strafe_rng = Random(spawn.randrange(1 << 30))
        self._weapon_want = 0
        self._weapon_want_ticks = 0
        # navigation humanization state (design doc §3/§4)
        self._nav_rng = Random(spawn.randrange(1 << 30))
        self._visited_rooms: set[int] = set()
        self._paused_thresholds: set[tuple[int, int]] = set()
        self._pause_ticks = 0
        self._pause_mid: tuple[float, float] | None = None
        self._sweep_phase = 0.0
        self._entry_bias_ticks = 0
        self._entry_bias_side = 1.0
        self._lookaround_ticks = 0
        self._wobble = 0.0
        self._prev_move: tuple[float, float] = (0.0, 0.0)
        # flanked-choke escape state (design doc §5)
        self._escape_ticks = 0
        self._escape_dir: tuple[float, float] = (0.0, 0.0)
        # single-threaded attention (design doc §1): the current focus
        # target, held with hysteresis. Without this, two equidistant
        # enemies flip "nearest" every tick and the cursor oscillates
        # between opposite screen positions, never converging enough to
        # fire -- l01/HARD seed 101 deadlocked 11 sim-minutes this way
        # in the 2026-07-13 skill-floor re-check.
        self._focus_id: int | None = None
        # net combat pressure (AggroBot's doorway ping-pong fix, ported:
        # decays out of combat rather than resetting, so a perceive/lose/
        # re-perceive cycle across a portal still accumulates)
        self._combat_streak = 0
        self._last_contact_tick = -10_000
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

        # room bookkeeping: entering a never-seen room starts a curiosity
        # look-around beat (design doc §6)
        if proom not in self._visited_rooms:
            if self._visited_rooms:  # not the spawn room
                self._lookaround_ticks = self._nav_rng.randint(30, 60)
            self._visited_rooms.add(proom)

        anticipated = self._anticipated_ids(session, snapshot, px, py)
        perceived = self._perception.perceive(snapshot, tick, anticipated)

        if perceived:
            self._pause_ticks = 0  # combat preempts any threshold ritual
            self._lookaround_ticks = 0
            self._combat_streak += 1
            self._last_contact_tick = tick
            inp = self._combat_input(session, snapshot, perceived, px, py)
            # sustained-pressure escape (ported from AggroBot): a fight
            # that has accumulated ~10s of net pressure -- including the
            # portal ping-pong pattern where contact keeps dropping and
            # re-acquiring -- gets walked out toward the exit while firing
            if self._combat_streak > 60 * 10:
                mx_, my_ = nav_to_exit(session, snapshot)
                if mx_ or my_:
                    inp.mx, inp.my = mx_, my_
            return self._apply_unstick(px, py, inp)

        self._combat_streak = max(0, self._combat_streak - 2)
        self._escape_ticks = 0
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

        # room-entry protocol (design doc §3): pause at the threshold of
        # unexplored territory and lamp-sweep it from the doorway. A hurt
        # player, or one fresh out of contact, hurries instead -- the
        # ritual reads human only when the situation is calm.
        calm = snapshot["hp"] >= 50 and tick - self._last_contact_tick > 60 * 3
        if calm:
            self._maybe_start_threshold_pause(session, proom, px, py)
        else:
            self._pause_ticks = 0
            self._lookaround_ticks = 0
        if self._pause_ticks > 0:
            self._pause_ticks -= 1
            inp.mx, inp.my = 0.0, 0.0
            ax, ay = self._sweep_aim(session, px, py, self._pause_mid)
            mouse = self._ensure_mouse(ax, ay)
            inp.ax, inp.ay = mouse.step(ax, ay, 1.0 / 60.0)
            # a stationary ritual must not trip the unstick jitter
            self._pos_hist.clear()
            return inp

        inp.mx, inp.my = self._humanize_move(inp.mx, inp.my)

        if self._lookaround_ticks > 0:
            # curiosity sweep: slow down and look around the new room
            self._lookaround_ticks -= 1
            inp.mx, inp.my = inp.mx * 0.5, inp.my * 0.5
            ahead = (px + math.cos(self._aim_world_angle) * 120.0,
                     py + math.sin(self._aim_world_angle) * 120.0)
            ax, ay = self._sweep_aim(session, px, py, ahead)
            mouse = self._ensure_mouse(ax, ay)
            inp.ax, inp.ay = mouse.step(ax, ay, 1.0 / 60.0)
        else:
            rest_x, rest_y = session.screen_w / 2.0, session.screen_h / 2.0
            mouse = self._ensure_mouse(rest_x, rest_y)
            inp.ax, inp.ay = mouse.step(rest_x, rest_y, 1.0 / 60.0)

        return self._apply_unstick(px, py, inp)

    # -- navigation humanization (design doc §3/§4) --------------------

    THRESHOLD_RADIUS = 42.0

    def _maybe_start_threshold_pause(self, session: GameSession, proom: int,
                                      px: float, py: float) -> None:
        if self._pause_ticks > 0:
            return
        portals = session.sim.room_portals(proom)
        for edge, portal in enumerate(portals):
            if portal is None:
                continue
            neighbor = portal[0]
            if neighbor in self._visited_rooms:
                continue
            if (proom, edge) in self._paused_thresholds:
                continue
            mx_, my_ = session.sim.edge_midpoint(proom, edge)
            if math.hypot(mx_ - px, my_ - py) < self.THRESHOLD_RADIUS:
                self._paused_thresholds.add((proom, edge))
                self._pause_ticks = self._nav_rng.randint(28, 55)
                self._pause_mid = (mx_, my_)
                self._sweep_phase = self._nav_rng.uniform(0.0, math.pi)
                self._entry_bias_ticks = 25
                self._entry_bias_side = self._nav_rng.choice((-1.0, 1.0))
                return

    def _sweep_aim(self, session: GameSession, px: float, py: float,
                    focus: tuple[float, float]) -> tuple[float, float]:
        """Screen-space aim point sweeping an arc around the direction to
        `focus` -- the doorway lamp-sweep / look-around motion."""
        base = math.atan2(focus[1] - py, focus[0] - px)
        self._sweep_phase += 0.11
        ang = base + math.sin(self._sweep_phase) * 0.9
        self._aim_world_angle = ang
        wx, wy = px + math.cos(ang) * 120.0, py + math.sin(ang) * 120.0
        return necore.mat_apply(session.cam, wx, wy)

    def _humanize_move(self, mx: float, my: float) -> tuple[float, float]:
        """Heading wobble, hard-turn slowdown, and post-threshold wall bias
        applied to a commanded screen-space move vector."""
        mag = math.hypot(mx, my)
        if mag < 1e-6:
            self._prev_move = (0.0, 0.0)
            return (mx, my)
        # wall-entry bias: come through the doorway along a wall, not the
        # centerline, for a beat after a threshold pause
        if self._entry_bias_ticks > 0:
            self._entry_bias_ticks -= 1
            perp = (-my / mag, mx / mag)
            mx += perp[0] * 0.45 * self._entry_bias_side * mag
            my += perp[1] * 0.45 * self._entry_bias_side * mag
            mag = math.hypot(mx, my)
        # heading wobble: bounded random walk on the move angle
        self._wobble += self._nav_rng.uniform(-0.028, 0.028)
        self._wobble = max(-0.16, min(0.16, self._wobble))
        cos_w, sin_w = math.cos(self._wobble), math.sin(self._wobble)
        wx = mx * cos_w - my * sin_w
        wy = mx * sin_w + my * cos_w
        # hard turns shed speed (a hand steering, not a vector snap)
        pmx, pmy = self._prev_move
        pmag = math.hypot(pmx, pmy)
        scale = 1.0
        if pmag > 1e-6 and mag > 1e-6:
            cos_turn = (wx * pmx + wy * pmy) / (mag * pmag)
            if cos_turn < 0.75:  # > ~41 degree course change
                scale = 0.55
        out = (wx / mag * min(1.0, mag) * scale,
               wy / mag * min(1.0, mag) * scale)
        self._prev_move = out
        return out

    # -- flanked-choke escape (design doc §5) --------------------------

    FLANK_SPAN = 2.2          # rad: threat span that reads as "flanked"
    FLANK_HP = 70.0           # only escape when the fight is going badly
    FLANK_RANGE = 170.0       # threats beyond this don't pin us

    def _update_flank_escape(self, perceived: list[dict], hp: float,
                              px: float, py: float) -> None:
        """Being flanked in a choke must trigger a committed escape through
        the less-dangerous side (fight-through when boxed), never a
        hold-until-death. Fail-first evidence: pre-fix, seed 16 on the
        flank_choke test level died in the corridor without leaving it."""
        if self._escape_ticks > 0:
            self._escape_ticks -= 1
            return
        threats = [e for e in perceived
                   if _dist(e["pos"], (px, py)) < self.FLANK_RANGE]
        if len(threats) < 2 or hp >= self.FLANK_HP:
            return
        angles = sorted(math.atan2(e["pos"][1] - py, e["pos"][0] - px)
                        for e in threats)
        gaps = [angles[i + 1] - angles[i] for i in range(len(angles) - 1)]
        gaps.append(2.0 * math.pi - (angles[-1] - angles[0]))
        span = 2.0 * math.pi - max(gaps)
        if span < self.FLANK_SPAN:
            return
        # escape away from the weighted threat mass: closer enemies push
        # harder, so the vector points through the weaker/farther side --
        # fight-through, exactly what a boxed-in human does
        vx = vy = 0.0
        for e in threats:
            dx, dy = e["pos"][0] - px, e["pos"][1] - py
            d = math.hypot(dx, dy) or 1e-6
            w = 1.0 / d
            vx -= dx / d * w
            vy -= dy / d * w
        vmag = math.hypot(vx, vy)
        if vmag < 1e-4:  # perfectly balanced: burst away from the nearest
            nearest = min(threats, key=lambda e: _dist(e["pos"], (px, py)))
            dx, dy = nearest["pos"][0] - px, nearest["pos"][1] - py
            d = math.hypot(dx, dy) or 1e-6
            vx, vy = -dx / d, -dy / d
            vmag = 1.0
        self._escape_dir = (vx / vmag, vy / vmag)
        self._escape_ticks = self._nav_rng.randint(50, 80)

    def _combat_input(self, session: GameSession, snapshot: dict,
                       perceived: list[dict], px: float, py: float) -> InputFrame:
        self._update_flank_escape(perceived, snapshot["hp"], px, py)
        if self._escape_ticks > 0:
            # while escaping, shoot whatever blocks the escape path
            edx, edy = self._escape_dir
            in_path = [e for e in perceived
                       if (lambda dx, dy, d: (dx * edx + dy * edy) / d > 0.2)(
                           e["pos"][0] - px, e["pos"][1] - py,
                           _dist(e["pos"], (px, py)) or 1e-6)]
            pool = in_path or perceived
            nearest = min(pool, key=lambda e: _dist(e["pos"], (px, py)))
            self._focus_id = nearest["id"]
        else:
            # single-threaded attention with hysteresis: stay on the
            # current focus unless it's gone or something is decisively
            # closer (1.5x) -- a human doesn't retarget on a per-tick tie
            closest = min(perceived, key=lambda e: _dist(e["pos"], (px, py)))
            focus = next((e for e in perceived if e["id"] == self._focus_id),
                         None)
            if focus is not None and _dist(focus["pos"], (px, py)) <= \
                    1.5 * _dist(closest["pos"], (px, py)):
                nearest = focus
            else:
                nearest = closest
            self._focus_id = nearest["id"]
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
        if self._escape_ticks > 0:
            move_room = self._escape_dir  # committed flank escape
        elif weapon_name == "knife":
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
