"""HumanBot: the marketing-playthrough bot (BOT_REALISM_DESIGN.md).

Perception layer (`PerceptionModel`) -> reactive executor (this module) ->
humanized input synthesis (`MouseModel` for aim; movement/fire stay in
`InputFrame`, the same struct every bot in `bots.py` and the real player's
`_input_frame` produce -- see that module's docstring for why that is the
honest boundary here: the sim never sees anything but `InputFrame`, exactly
like it does for real keyboard/mouse input).

What makes this bot different from `AggroBot` is entirely upstream of that
struct: it never looks at `snapshot["enemies"]` directly, only at what
`PerceptionModel.perceive` releases after visibility (room-local, or on
screen via the renderer's own portal-visibility query -- see
`_visible_enemy_screens`) + reaction latency; its aim is the output of a
velocity/accel-bounded `MouseModel`, not a computed angle; and it carries
stress state (flinch, pressure) sampled from its own seeded RNG stream,
per design doc §8.

Threat neutralization is absolute priority (director's verdict,
2026-07-13): the instant anything is perceived, `step` cancels every
ritual (threshold pause, curiosity sweep) and either fights it (co-room)
or closes the distance with the weapon up (seen through a portal, not yet
co-room) -- never resuming navigation-toward-objective, and never running
past it, until nothing is perceived. The recognized exceptions are the
flanked-choke escape (§5, still fights while leaving) and the low-HP
disengage-while-firing in `_combat_input`; both keep engaging, they just
change the footwork.

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
                    nav_to_point)
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

# Movement-hesitancy tunables (director's verdict, 2026-07-13: "it's way
# too hesitant to move"). Each ran long/deep enough pre-tune to read as
# dithering instead of the "beat of intention" design doc §3/§4 call for.
# Retuned down together with the absolute-priority fix in `step` (rituals
# now also cancel the instant a threat is merely VISIBLE, not just once
# it's shared the player's room -- see `_visible_enemy_screens` -- so in
# enemy-dense areas they fire far less often even though the trigger
# condition below is otherwise unchanged; "rarer" comes from that
# preemption, "shorter" from the numbers themselves).
PAUSE_TICKS = (8, 16)          # was (28, 55): ~0.13-0.27s, was ~0.47-0.92s
ENTRY_BIAS_TICKS = 14          # was 25: matched back down to the shorter pause
LOOKAROUND_TICKS = (12, 22)    # was (30, 60): ~0.2-0.37s, was ~0.5-1.0s
LOOKAROUND_MOVE_SCALE = 0.75   # was 0.5: a glance, not a crawl
TEMPO_INIT = 0.95              # was 0.9
TEMPO_MIN = 0.85               # was 0.7: permanent foot-drag floor raised
HARD_TURN_COS = 0.5            # was 0.75 (~41deg): only >~60deg sheds speed
HARD_TURN_SCALE = 0.75         # was 0.55: gentler shed when it does trigger

# A/B judge finding (2026-07-13 re-run, seed 401): a distant threat's aim
# was converging to pixel precision on its screen position, read by the
# judge as "aimbot-style instant target acquisition." Correct: nothing is
# being fired at a not-yet-room-local target (see `_distant_threat_input`),
# so there is no reason for the tracking to be combat-precise -- a human
# noticing something through a doorway looks roughly toward it, not at a
# firing solution on it. Bounded wander added on top of the true screen
# position keeps the read as "noticed, orienting," not "locked on."
DISTANT_GLANCE_RADIUS = 30.0
DISTANT_GLANCE_STEP = 2.5


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
        # travel-aim wander state (design doc §2/§6): where the resting
        # cursor hovers relative to the direction of travel. A cursor
        # parked dead-center (or pinned exactly on the movement vector at
        # a fixed radius) is a machine tell the A/B judge called out
        # verbatim on 2026-07-13 ("cursor consistently centered/aligned
        # exactly along the movement direction").
        self._gaze_off = (0.0, 0.0)
        self._gaze_radius = 80.0
        # distant-threat glance wander (design doc §2/§6, see
        # DISTANT_GLANCE_RADIUS): the same idea applied to tracking a
        # threat seen through a portal -- roughly toward it, not locked on.
        self._distant_glance_off = (0.0, 0.0)
        # variable tempo (§6): slow multiplicative random walk on move speed
        self._tempo = TEMPO_INIT
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
                self._lookaround_ticks = self._nav_rng.randint(*LOOKAROUND_TICKS)
            self._visited_rooms.add(proom)

        # THREAT NEUTRALIZATION IS ABSOLUTE PRIORITY (director's verdict,
        # 2026-07-13). Perception is "on the screen," not "room-membership"
        # -- `session.visible()` is the exact portal-visibility query the
        # renderer uses, so an enemy plainly in frame through an open
        # doorway counts even before the player has crossed the room-index
        # boundary the sim uses for bookkeeping. Gating on room-membership
        # alone was the confirmed root cause of the bot running right past
        # enemies it hadn't room-crossed into range of yet: it was blind to
        # anything the renderer had already put on screen. See
        # `_visible_enemy_screens`.
        visible_screens = self._visible_enemy_screens(session)
        anticipated = self._anticipated_ids(session, snapshot, px, py)
        perceived = self._perception.perceive(snapshot, tick, anticipated,
                                               frozenset(visible_screens))
        # Co-room entries have valid room-local coordinates for the
        # existing aim/movement math. Anything only glimpsed through a
        # portal does not -- positions from different rooms are different
        # local frames, never diffed against the player's -- and is
        # handled screen-space-only by `_distant_threat_input` until the
        # bot actually reaches it.
        co_room = [e for e in perceived if e["room"] == proom]
        distant = [e for e in perceived if e["room"] != proom]

        if co_room:
            self._pause_ticks = 0  # combat preempts any threshold ritual
            self._lookaround_ticks = 0
            self._combat_streak += 1
            self._last_contact_tick = tick
            inp = self._combat_input(session, snapshot, co_room, px, py)
            # sustained-pressure escape (ported from AggroBot): a fight
            # that has accumulated ~10s of net pressure -- including the
            # portal ping-pong pattern where contact keeps dropping and
            # re-acquiring -- gets walked out toward the exit while firing
            if self._combat_streak > 60 * 10:
                mx_, my_ = self._nav_exit_move(session, snapshot, px, py)
                if mx_ or my_:
                    inp.mx, inp.my = mx_, my_
            return self._apply_unstick(px, py, inp)

        if distant:
            # A threat plainly on screen cancels every ritual just like a
            # co-room one -- never run PAST something the bot can see
            # coming. It just can't be fired on yet: every weapon's hit
            # test is room-scoped (`sim._fire`/`_fire_rail` resolve
            # targets from `room_entities(proom)` / a raycast rooted at
            # `proom`), so "firing" here could never connect and would
            # just be an ammo-waste, spray-at-nothing tell. Orient and
            # close the distance instead; `co_room` above takes over --
            # fire included -- the tick it's actually reached.
            self._pause_ticks = 0
            self._lookaround_ticks = 0
            self._escape_ticks = 0
            self._last_contact_tick = tick
            inp = self._distant_threat_input(session, snapshot, distant,
                                              visible_screens, px, py)
            return self._apply_unstick(px, py, inp)

        self._combat_streak = max(0, self._combat_streak - 2)
        self._escape_ticks = 0
        inp = InputFrame()
        inp.mx, inp.my = self._objective_move(session, snapshot, px, py, proom)

        # room-entry protocol (design doc §3): pause at the threshold of
        # unexplored territory and lamp-sweep it from the doorway. A hurt
        # player, or one fresh out of contact, hurries instead -- the
        # ritual reads human only when the situation is calm. Short and
        # infrequent by construction (director's verdict, 2026-07-13:
        # "way too hesitant to move") -- a beat of intention, not a
        # dither -- and preempted entirely the instant anything is
        # perceived, not just once it shares the room (see above).
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
            # curiosity sweep: slow down (not crawl) and look around
            self._lookaround_ticks -= 1
            inp.mx, inp.my = (inp.mx * LOOKAROUND_MOVE_SCALE,
                               inp.my * LOOKAROUND_MOVE_SCALE)
            ahead = (px + math.cos(self._aim_world_angle) * 120.0,
                     py + math.sin(self._aim_world_angle) * 120.0)
            ax, ay = self._sweep_aim(session, px, py, ahead)
            mouse = self._ensure_mouse(ax, ay)
            inp.ax, inp.ay = mouse.step(ax, ay, 1.0 / 60.0)
        else:
            ax, ay = self._travel_aim(session, inp.mx, inp.my)
            mouse = self._ensure_mouse(ax, ay)
            inp.ax, inp.ay = mouse.step(ax, ay, 1.0 / 60.0)

        # variable tempo (§6): nobody holds the stick at exactly 1.0 --
        # narrow, high floor (director's verdict, 2026-07-13: the old
        # 0.7-1.0 range read as permanent foot-dragging, not the occasional
        # confident-burst/careful-step variation it was meant to be).
        self._tempo += self._nav_rng.uniform(-0.02, 0.02)
        self._tempo = max(TEMPO_MIN, min(1.0, self._tempo))
        inp.mx, inp.my = inp.mx * self._tempo, inp.my * self._tempo

        return self._apply_unstick(px, py, inp)

    def _visible_enemy_screens(self, session: GameSession
                                ) -> dict[int, tuple[float, float]]:
        """Every entity id currently in the renderer's own portal-visibility
        set (`session.visible()` -- the exact query the real renderer calls
        every frame to decide what's on screen, walking `max_depth` portal
        hops out), mapped to its screen position. This is the perception
        channel design doc §1 actually specifies ("entities inside the
        rendered viewport"): wider than room-membership, because the
        seamless-portal renderer shows a neighboring room's contents
        through an open doorway before the player ever crosses into it.
        Cheap: a pure geometry query (no rasterization), measured well
        under the render pass's own per-frame cost."""
        screens: dict[int, tuple[float, float]] = {}
        for _room, _xform, _depth, _clip, _walls, _entry_edge, ents \
                in session.visible():
            for eid, sx, sy, _dirx, _diry, _srad, _fully_inside in ents:
                screens[eid] = (sx, sy)
        return screens

    def _objective_move(self, session: GameSession, snapshot: dict,
                         px: float, py: float, proom: int) -> tuple[float, float]:
        """Movement toward the current objective: a nearby medkit when
        hurt, otherwise the exit. Shared by the no-threat branch and by
        `_distant_threat_input` -- closing on a threat still has to go
        SOMEWHERE, and that somewhere is wherever the bot was already
        headed (usually exactly the room the threat was spotted in)."""
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
                goal = target["pos"]
            else:
                edge = session.sim.next_edge(proom, target["room"])
                goal = session.sim.edge_midpoint(proom, edge) if edge >= 0 else None
            if goal is None:
                return (0.0, 0.0)
            way = self._steer_target(session, proom, (px, py), goal)
            return nav_to_point(session, px, py, way)
        self._med_target = None
        return self._nav_exit_move(session, snapshot, px, py)

    def _distant_threat_input(self, session: GameSession, snapshot: dict,
                               distant: list[dict],
                               visible_screens: dict[int, tuple[float, float]],
                               px: float, py: float) -> InputFrame:
        """Orient toward the nearest threat that's on screen but not yet
        room-local: aim tracks NEAR its actual screen position (valid
        regardless of which room it's physically in -- the renderer
        already did that transform for us) with a loose glance wander, not
        combat-precise tracking -- nothing is fired at a not-yet-room-local
        target (see `step`'s comment: no weapon's hit test can connect
        room-to-room), so there is no firing solution to converge on, only
        "I see that." Movement keeps closing on the objective that put it
        in view in the first place; this is "advance with the weapon up,"
        not combat footwork -- that starts the instant `co_room` does."""
        proom = snapshot["room"]
        inp = InputFrame()
        inp.mx, inp.my = self._objective_move(session, snapshot, px, py, proom)
        inp.mx, inp.my = self._humanize_move(inp.mx, inp.my)

        # cross-room comparisons are invalid (different local frames) --
        # `hops` is the one graph-distance field that IS comparable here
        target = min(distant, key=lambda e: (e["hops"], e["id"]))
        true_ax, true_ay = visible_screens.get(
            target["id"], (session.screen_w / 2.0, session.screen_h / 2.0))
        gx, gy = self._distant_glance_off
        gx = max(-DISTANT_GLANCE_RADIUS, min(DISTANT_GLANCE_RADIUS,
            gx + self._nav_rng.uniform(-DISTANT_GLANCE_STEP, DISTANT_GLANCE_STEP)))
        gy = max(-DISTANT_GLANCE_RADIUS, min(DISTANT_GLANCE_RADIUS,
            gy + self._nav_rng.uniform(-DISTANT_GLANCE_STEP, DISTANT_GLANCE_STEP)))
        self._distant_glance_off = (gx, gy)
        target_ax, target_ay = true_ax + gx, true_ay + gy
        mouse = self._ensure_mouse(target_ax, target_ay)
        inp.ax, inp.ay = mouse.step(target_ax, target_ay, 1.0 / 60.0)
        inp.fire = False
        return inp

    def _travel_aim(self, session: GameSession, mx: float, my: float
                     ) -> tuple[float, float]:
        """Resting cursor target while traveling: hovers AHEAD of the
        movement direction at a wandering radius and offset, so the gaze
        leads into upcoming space instead of parking at screen center or
        riding the exact movement vector."""
        cx, cy = session.screen_w / 2.0, session.screen_h / 2.0
        # slow random walk on the lateral/longitudinal offset and radius
        gx, gy = self._gaze_off
        gx = max(-45.0, min(45.0, gx + self._nav_rng.uniform(-2.2, 2.2)))
        gy = max(-35.0, min(35.0, gy + self._nav_rng.uniform(-2.2, 2.2)))
        self._gaze_off = (gx, gy)
        self._gaze_radius = max(45.0, min(115.0,
            self._gaze_radius + self._nav_rng.uniform(-3.0, 3.0)))
        mag = math.hypot(mx, my)
        if mag < 1e-6:
            return (cx + gx, cy + gy)
        return (cx + mx / mag * self._gaze_radius + gx,
                cy + my / mag * self._gaze_radius + gy)

    # -- terrain-aware in-room steering --------------------------------
    #
    # Walk-mask terrain (rect colliders inside rooms) landed with the art
    # pass; the shared nav helpers steer straight at the target and rely
    # on the random unstick jitter to round obstacles, which grinds for
    # sim-minutes against real cover (l01 room 112: AggroBot seed 101
    # spent the full 12-minute budget there; clearing that one room's
    # terrain in-session flipped it to complete-in-17s -- causal). Humans
    # walk around furniture: greedy corner-hopping, re-evaluated per tick.

    CLEARANCE = 9.0  # player radius + margin, room units

    @staticmethod
    def _seg_hits_rect(p, q, rect, pad: float) -> bool:
        """Liang-Barsky: does segment p->q cross rect inflated by pad?"""
        x0, y0, x1, y1 = rect
        x0, y0, x1, y1 = x0 - pad, y0 - pad, x1 + pad, y1 + pad
        dx, dy = q[0] - p[0], q[1] - p[1]
        t0, t1 = 0.0, 1.0
        for num, den in ((x0 - p[0], dx), (p[0] - x1, -dx),
                          (y0 - p[1], dy), (p[1] - y1, -dy)):
            if abs(den) < 1e-12:
                if num > 0:
                    return False
                continue
            t = num / den
            if den > 0:
                t0 = max(t0, t)
            else:
                t1 = min(t1, t)
            if t0 > t1:
                return False
        return True

    def _steer_target(self, session: GameSession, room: int,
                       p: tuple[float, float],
                       target: tuple[float, float]) -> tuple[float, float]:
        """Next waypoint toward `target` around this room's terrain rects.
        Greedy: if the straight segment is blocked, hop to the reachable
        inflated corner of a blocking rect that best shortens the path.
        Re-run every tick, so multi-rect fields resolve corner by corner."""
        rects = session.sim.room_terrain(room) or []
        if not rects:
            return target

        def blocked(a, b):
            return any(self._seg_hits_rect(a, b, r, self.CLEARANCE * 0.7)
                       for r in rects)

        if not blocked(p, target):
            return target
        pad = self.CLEARANCE
        best, best_cost = None, float("inf")
        for r in rects:
            x0, y0, x1, y1 = r
            for c in ((x0 - pad, y0 - pad), (x1 + pad, y0 - pad),
                       (x0 - pad, y1 + pad), (x1 + pad, y1 + pad)):
                if _dist(p, c) < 1.0 or blocked(p, c):
                    continue
                cost = _dist(p, c) + _dist(c, target)
                if cost < best_cost:
                    best, best_cost = c, cost
        return best if best is not None else target

    def _nav_exit_move(self, session: GameSession, snapshot: dict,
                        px: float, py: float) -> tuple[float, float]:
        """`nav_to_exit` with terrain-aware in-room steering."""
        proom = snapshot["room"]
        if session.exit_room < 0:
            return (0.0, 0.0)
        if proom == session.exit_room:
            goal = session.exit_pos
        else:
            edge = snapshot.get("exit_next_edge", -1)
            if edge < 0:
                return (0.0, 0.0)
            goal = session.sim.edge_midpoint(proom, edge)
        way = self._steer_target(session, proom, (px, py), goal)
        return nav_to_point(session, px, py, way)

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
                self._pause_ticks = self._nav_rng.randint(*PAUSE_TICKS)
                self._pause_mid = (mx_, my_)
                self._sweep_phase = self._nav_rng.uniform(0.0, math.pi)
                self._entry_bias_ticks = ENTRY_BIAS_TICKS
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
        # hard turns shed speed (a hand steering, not a vector snap) --
        # only genuinely sharp reversals, and only a partial shed (director's
        # verdict, 2026-07-13: this used to fire on ~41deg course changes at
        # a 45% cut and made ordinary corridor steering read as hesitant)
        pmx, pmy = self._prev_move
        pmag = math.hypot(pmx, pmy)
        scale = 1.0
        if pmag > 1e-6 and mag > 1e-6:
            cos_turn = (wx * pmx + wy * pmy) / (mag * pmag)
            if cos_turn < HARD_TURN_COS:
                scale = HARD_TURN_SCALE
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
            # committed flank escape, steered around in-room terrain
            gx = px + self._escape_dir[0] * 80.0
            gy = py + self._escape_dir[1] * 80.0
            way = self._steer_target(session, snapshot["room"], (px, py),
                                      (gx, gy))
            move_room = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else self._escape_dir
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
