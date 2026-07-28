"""HumanBot: the marketing-playthrough bot (BOT_REALISM_DESIGN.md).

Perception layer (`PerceptionModel`) -> reactive executor (this module) ->
humanized input synthesis (`MouseModel` for aim; movement/fire stay in
`InputFrame`, the same struct every bot in `bots.py` and the real player's
`_input_frame` produce -- see that module's docstring for why that is the
honest boundary here: the sim never sees anything but `InputFrame`, exactly
like it does for real keyboard/mouse input).

What makes this bot different from `AggroBot` is entirely upstream of that
struct: it never looks at `snapshot["enemies"]` directly, only at what
`PerceptionModel.perceive` releases after visibility (polygon-local, or on
screen via the renderer's own portal-visibility query -- see
`_visible_enemy_screens`) + reaction latency; its aim is the output of a
velocity/accel-bounded `MouseModel`, not a computed angle; and it carries
stress state (flinch, pressure) sampled from its own seeded RNG stream,
per design doc §8.

Threat neutralization is absolute priority (director's verdict,
2026-07-13): the instant anything is perceived, `step` cancels every
ritual (threshold pause, curiosity sweep) and either fights it (co-polygon)
or closes the distance with the weapon up (seen through a portal, not yet
co-polygon) -- never resuming navigation-toward-objective, and never running
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

import collections
import os
import math
from random import Random

import necore

from ..sim import (ENEMIES, GROUP_ENEMY, GROUP_PLAYER, PLAYER_RADIUS,
                   WEAPONS, GameSession, InputFrame, WEAPON_ORDER)
from .bots import (Bot, _UnstickMixin, _dist, _norm, choose_weapon,
                    nav_to_point)
from .mouse_model import MouseModel
from .perception import PerceptionModel

# Anticipation: an entity is "pre-aimed" if it appears within this many
# radians of wherever the cursor already was pointing when it was first
# perceived -- design doc §3 ("the cursor lives where danger is expected").
# This makes anticipation an emergent property of prior aim, not a scripted
# polygon-entry flag.
ANTICIPATE_CONE = math.radians(35.0)

# Flinch: taking damage kicks the aim off-target for ~100ms before recovery
# (design doc §5). At 60Hz, 100ms ~= 6 ticks. Magnitude is a JITTER,
# not a wild swing: the original 0.35-0.75 rad (20-43 deg) meant a
# melee touch every ~0.7s kept the cursor permanently in the weeds --
# measured 53% of combat ticks blocked on aim error, the director's
# 'refuses to fire' (2026-07-16). A hit shakes your hand ~6-13 deg.
FLINCH_TICKS = 6
FLINCH_ANGLE_RANGE = (0.10, 0.22)

# Fire discipline: only shoot once tracking error is within this angle of
# the (perceived, latency-delayed) target -- mirrors _CombatMixin's AGGRO
# baseline but measured against the humanized aim point, not a raw angle.
FIRE_ERR = math.radians(9.0)

# Single skill knob (design doc §8): scales the fire-discipline window
# (`allowed_px` in `_combat_input`) that gates when the humanized cursor is
# "close enough" to shoot. 1.0 is a plausible human aim cone but measured
# too low against HARD-mode multi-enemy polygons on l01 (0/3 survival attempts,
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
# it's shared the player's polygon -- see `_visible_enemy_screens` -- so in
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
# being fired at a not-yet-polygon-local target (see `_distant_threat_input`),
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
        # skill scales the three HUMAN LIMITS (hand speed, reaction
        # latency, flinch), calibrated so DEFAULT_SKILL reproduces the
        # marketing-realism bot exactly. It had silently decoupled when
        # the fire gate it used to scale was removed (measured: skill
        # 4/7/10 byte-identical runs, 2026-07-18) — rewired here.
        self.skill = skill
        self.diag = {"funnel": 0, "dodge": 0}
        self._funnel_hold = 0
        self._hold_ticks = 0
        self._hold_break = 0
        self._limit = max(0.25, DEFAULT_SKILL / max(0.5, skill))
        spawn = Random(seed)  # one spawner -> independent derived streams
        self._perception = PerceptionModel(seed=spawn.randrange(1 << 30),
                                           latency_scale=self._limit)
        self._mouse: MouseModel | None = None
        self._mouse_seed = spawn.randrange(1 << 30)
        self._prev_hp: float | None = None
        self._flinch_ticks = 0
        self._flinch_angle = 0.0
        self._flinch_rng = Random(spawn.randrange(1 << 30))
        self._aim_world_angle = 0.0  # last aim direction in polygon space
        self._med_target = None
        self._med_since = 0
        self._med_blacklist: dict = {}
        self._strafe_sign = 1
        self._strafe_rng = Random(spawn.randrange(1 << 30))
        self._weapon_want = 0
        self._polygon_long_axis = None
        self._weapon_want_ticks = 0
        # navigation humanization state (design doc §3/§4)
        self._nav_rng = Random(spawn.randrange(1 << 30))
        self._visited_polygons: set[int] = set()
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
        # OH-SHIT retreat (director 2026-07-16: the bot "repeatedly
        # charges in to dark polygons with 50+ enemies... instead of
        # kiting them in to the nearby turrets"): facing a swarm, fall
        # back to the last sentry field passed and fight from there.
        self._pressure_hist = collections.deque()
        self._retreat_cooldown = 0   # suppress re-rise after a stalemate
        # motor-schema arbitration state (BBR/Arkin, director 2026-07-16:
        # behaviors emit vectors, gains weight them, output = the sum --
        # the retreat LEVEL is continuous, not a latched mode)
        self._retreat_gain = 0.0
        self._retreat_polygon: int | None = None
        self._entry_caution = False
        self._planted = False
        self._warden_hunting = False
        self._warden_seen: set[int] = set()
        self._warden_recoils: dict[int, int] = {}
        # combat locomotion invariant (Sol consult #1 + incident mining
        # meta-finding "the bot does not MOVE during combat"): if the
        # feet have not actually displaced during a live co-polygon fight,
        # force a committed, collision-aware strafe. Displacement-based
        # so it catches EVERY freeze mode (planted, cancelled schema
        # vectors, terrain block) without caring which one it is.
        self._pos_ring = []          # last ~18 tick positions
        self._freeze_ticks = 0
        self._loco_ticks = 0
        self._loco_dir = (1.0, 0.0)
        self._last_kills = 0
        self._last_kill_tick = 0
        self._threats_total = 0
        # policy set by the tactician (or defaults); see design doc §7
        self.policy = dict(movement="advance-carefully", risk="normal",
                            target_priority=None)

    # -- diagnostics used by tests -----------------------------------
    @property
    def perception(self) -> PerceptionModel:
        return self._perception

    def _ensure_mouse(self, ax: float, ay: float) -> MouseModel:
        if self._mouse is None:
            self._mouse = MouseModel(ax, ay, seed=self._mouse_seed,
                                     agility=1.0 / self._limit)
        return self._mouse

    def _anticipated_ids(self, session: GameSession, snapshot: dict,
                          px: float, py: float) -> frozenset[int]:
        out = []
        for e in snapshot["enemies"]:
            if e["polygon"] != snapshot["polygon"]:
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
            self._flinch_ticks = max(2, round(FLINCH_TICKS * self._limit))
            lo, hi = FLINCH_ANGLE_RANGE
            mag = self._flinch_rng.uniform(lo, hi) * self._limit
            sign = self._flinch_rng.choice((-1.0, 1.0))
            self._flinch_angle = mag * sign
        self._prev_hp = hp
        if self._flinch_ticks > 0:
            self._flinch_ticks -= 1
        elif self._flinch_angle != 0.0:
            # Flinch must DECAY: the angle was set on every hit but
            # never cleared when the ticks expired, so after the first
            # damage of a run every shot carried a permanent random
            # bias of up to ~12 degrees, re-rolled per hit.
            self._flinch_angle = 0.0

    def step(self, snapshot: dict, session: GameSession) -> InputFrame:
        ppolygon = snapshot["polygon"]
        px, py = snapshot["pos"]
        tick = snapshot["tick"]
        self._apply_flinch(snapshot)
        if getattr(self, "_cur_polygon", None) != ppolygon:
            # breadcrumb trail for the funnel-retreat schema: walking
            # back along the trail POPS it (so a multi-polygon retreat
            # keeps falling further back, never re-targets the polygon
            # just abandoned), any other move appends
            prev = getattr(self, "_cur_polygon", None)
            trail = getattr(self, "_trail", None)
            if trail is None:
                trail = self._trail = []
            if trail and ppolygon == trail[-1]:
                trail.pop()
            elif prev is not None:
                trail.append(prev)
                del trail[:-8]
            self._entry_door = None
            if prev is not None:
                try:
                    for edge, portal in enumerate(
                            session.sim.polygon_portals(ppolygon)):
                        if portal is not None and portal[0] == prev:
                            self._entry_door = \
                                session.sim.edge_midpoint(ppolygon, edge)
                            break
                except Exception:
                    pass
            if getattr(self, "_funnel_hold", 0) > 0:
                # withdrawal depth is counted in POLYGONS — coordinates
                # are polygon-local in portal space, distances across
                # frames are meaningless
                self._funnel_polygons = getattr(self, "_funnel_polygons",
                                             0) + 1
            self._cur_polygon = ppolygon

        # polygon bookkeeping: entering a never-seen polygon starts a curiosity
        # look-around beat (design doc §6)
        try:
            vs = session.level.polygon_verts[ppolygon]
            xs = [v[0] for v in vs]
            ys = [v[1] for v in vs]
            w, h = max(xs) - min(xs), max(ys) - min(ys)
            self._polygon_long_axis = (1.0, 0.0) if w >= h else (0.0, 1.0)
        except Exception:
            self._polygon_long_axis = None
        if ppolygon not in self._visited_polygons:
            if self._visited_polygons:  # not the spawn polygon
                self._lookaround_ticks = self._nav_rng.randint(*LOOKAROUND_TICKS)
            self._visited_polygons.add(ppolygon)

        # THREAT NEUTRALIZATION IS ABSOLUTE PRIORITY (director's verdict,
        # 2026-07-13). Perception is "on the screen," not "polygon-membership"
        # -- `session.visible()` is the exact portal-visibility query the
        # renderer uses, so an enemy plainly in frame through an open
        # doorway counts even before the player has crossed the polygon-index
        # boundary the sim uses for bookkeeping. Gating on polygon-membership
        # alone was the confirmed root cause of the bot running right past
        # enemies it hadn't polygon-crossed into range of yet: it was blind to
        # anything the renderer had already put on screen. See
        # `_visible_enemy_screens`.
        visible_screens = self._visible_enemy_screens(session)
        anticipated = self._anticipated_ids(session, snapshot, px, py)
        perceived = self._perception.perceive(snapshot, tick, anticipated,
                                               frozenset(visible_screens))
        # Co-polygon entries have valid polygon-local coordinates for the
        # existing aim/movement math. Enemies one hop out get the same
        # treatment through the portal transform: polygons are individual
        # polygons and combat is continuous across them (director's law,
        # 2026-07-18) — the fatal micro-trace showed wardens grinding
        # the bot by TOUCH at 25u from the far side of a portal plane
        # while co_polygon read zero and every reflex (contact-evasion,
        # pressure counts, flank escape) was blind. `portal_xform`
        # maps neighbor-local -> ppolygon-local; a transformed hunter is
        # a co-polygon threat in every sense that matters to the body.
        # Polygons further out stay screen-space-only
        # (`_distant_threat_input`).
        co_polygon = [e for e in perceived if e["polygon"] == ppolygon]
        distant = [e for e in perceived if e["polygon"] != ppolygon]
        adj_xf: dict[int, tuple] = {}
        for edge, portal in enumerate(session.sim.polygon_portals(ppolygon)):
            if portal is not None and portal[0] not in adj_xf:
                xf = session.sim.portal_xform(ppolygon, edge)
                if xf is not None:
                    adj_xf[portal[0]] = xf

        def _chain_xf(target_polygon):
            # composed transform target_polygon-local -> ppolygon-local
            # along the shortest portal path, up to 3 hops (director
            # 2026-07-19: one hop was never the law)
            got = adj_xf.get(target_polygon)
            if got is not None:
                return got
            xf_ = None
            r_ = ppolygon
            for _ in range(3):
                if r_ == target_polygon:
                    return xf_
                e_ = session.sim.next_edge(r_, target_polygon)
                if e_ < 0:
                    return None
                step = session.sim.portal_xform(r_, e_)
                if step is None:
                    return None
                xf_ = step if xf_ is None else necore.mat_mul(xf_, step)
                r_ = session.sim.polygon_portals(r_)[e_][0]
            return xf_ if r_ == target_polygon else None

        for e in distant:
            if not e.get("active"):
                continue
            # adjacent enemies merge unconditionally; deeper ones only
            # when the renderer confirms them on screen (honest
            # perception: a wall-hidden third-polygon enemy stays unknown)
            if e["polygon"] not in adj_xf and \
                    e["id"] not in visible_screens:
                continue
            xf = _chain_xf(e["polygon"])
            if xf is None:
                continue
            lx, ly = necore.mat_apply(xf, *e["pos"])
            if math.hypot(lx - px, ly - py) < 340.0:
                t_e = dict(e)
                t_e["pos"] = (lx, ly)
                t_e["thru"] = True
                co_polygon.append(t_e)

        kills = session.metrics.get("kills", 0)
        if kills != self._last_kills:
            self._last_kills = kills
            self._last_kill_tick = tick
        # pressure = AGGROED enemies only (director 2026-07-16: the bot
        # "spends the VAST majority of its time trying to kite enemies
        # that haven't even aggroed yet" -- an idle enemy on screen is
        # scenery, not pressure; it gets fought where it stands)
        if any(e.get("kind") == "warden" for e in co_polygon) and \
                not getattr(self, "_warden_polygon_logged", 0) == ppolygon:
            self._warden_polygon_logged = ppolygon
            self.diag.setdefault("warden_entry_hp", []).append(
                int(snapshot["hp"]))
        self._threats_total = sum(
            1 for e in co_polygon + distant
            if e.get("active"))
        # wind the listening clock: live threats now = no quiet
        # crossing of a blind waist for the next 5s (sound-pull
        # arrivals are en route)
        if self._threats_total > 0:
            self._listen_t = tick + 300
        self._warden_hunting = any(
            e.get("kind") == "warden" and e.get("active")
            for e in co_polygon + distant)

        # ---- motor-schema arbitration (BBR/Arkin; director's order:
        # "a 'move routine' and a 'fight routine' whose vectors
        # weighted-sum, with the weights determined by the situation").
        # Each behavior emits a polygon-space vector; gains are continuous
        # functions of the situation; the command = the normalized sum.
        # The only ballistic override left is the flank-escape reflex
        # (a triggered, temporally-extended schema) and unstick.
        self._retreat_gain_update(session, snapshot, tick)
        rg = self._retreat_gain
        n_co_hunt = sum(1 for e in co_polygon
                        if e.get("active"))

        fight_vec = (0.0, 0.0)
        fight_gain = 0.0
        if co_polygon:
            self._pause_ticks = 0   # combat preempts every ritual
            self._lookaround_ticks = 0
            self._combat_streak += 1
            self._last_contact_tick = tick
            inp, fvx, fvy = self._combat_input(session, snapshot,
                                               co_polygon, px, py)
            fight_vec = (fvx, fvy)
            # footwork weight grows with how crowded the fight is, and
            # yields ground to the retreat schema as the fight sours
            fight_gain = min(1.0, 0.75 + 0.12 * n_co_hunt) * \
                max(0.45, 1.0 - 0.5 * rg)
        else:
            self._combat_streak = max(0, self._combat_streak - 2)
            self._planted = False
            inp = InputFrame()
            if distant:
                self._pause_ticks = 0
                self._lookaround_ticks = 0
                self._last_contact_tick = tick
                # FIRE THROUGH THE PORTAL (director 2026-07-16: "it only
                # fires on enemies in the same polygon polygon. That's no
                # good"): bullets are physics bodies and cross portals
                # like everything else -- the old 'polygon-scoped, would
                # never connect' rationale was wrong for every
                # projectile weapon. Visible on screen = shootable:
                # point at the closest visible enemy, hold the trigger.
                pax, pay = necore.mat_apply(session.cam, px, py)
                # HUNTING TARGETS ONLY (2026-07-18): sniping idle
                # enemies through portals was free kills against the
                # old off-polygon-inert game (they walked to the door and
                # died single-file); on the honest game every such
                # shot wakes a polygon that arrives as a FIGHTING pack —
                # measured 48-77 kills by t~75s, a self-made avalanche
                # that killed every run at the first compound. Sleeping
                # polygons stay asleep.
                # ...except WARDENS: a parked boss astride the route
                # gets the deliberate opening shot — that IS the pull
                # (timeout footage: 4+ minutes recoil-looping at one
                # doorway, unable to provoke or pass). (A 250u
                # minimum poke range was tried 2026-07-18 and
                # measured mildly negative: Z-bends often have no
                # long vantage, so the rule only deferred the pull
                # into a worse co-polygon entry.)
                # RENDERABLE RANGE ONLY (filmed-playtest judge: bot
                # filmed firing at unrendered enemies, s7 x2 s11 x1 —
                # `visible()` walks 14 hops but the film at zoom 0.45
                # only legibly draws ~2-3): a shot at a target beyond
                # 2 hops reads as flailing at an empty corridor.
                # Deeper contacts stay on the glance/orient channel
                # (`_distant_threat_input`); routing is untouched.
                cand = [visible_screens[e["id"]] for e in distant
                        if e["id"] in visible_screens
                        and 0 <= e.get("hops", 9) <= 2
                        and (e.get("active")
                             or e.get("kind") == "warden")]
                if cand:
                    tx_, ty_ = min(cand, key=lambda s: math.hypot(
                        s[0] - pax, s[1] - pay))
                    cam_scale = math.hypot(*necore.mat_apply_dir(
                        session.cam, 1.0, 0.0)) or 1.0
                    dist_est = math.hypot(tx_ - pax, ty_ - pay) / cam_scale
                    mouse = self._ensure_mouse(tx_, ty_)
                    inp.ax, inp.ay = mouse.step(tx_, ty_, 1.0 / 60.0)
                    inp.fire = True
                    want = choose_weapon(dict(snapshot, enemies=distant),
                                         dist_est, len(distant))
                    # tau ricochet veto, same rule as the co-polygon
                    # branch: never in a narrow polygon
                    if WEAPON_ORDER[want - 1] == "tau":
                        try:
                            vs = session.level.polygon_verts[snapshot["polygon"]]
                            xs = [v[0] for v in vs]
                            ys = [v[1] for v in vs]
                            narrow = min(max(xs) - min(xs),
                                         max(ys) - min(ys)) < 220.0
                        except Exception:
                            narrow = False
                        if narrow:
                            want = choose_weapon(
                                dict(snapshot, enemies=distant,
                                     weapons=[w for w in
                                              snapshot["weapons"]
                                              if w != "tau"]),
                                dist_est, len(distant))
                    cur = WEAPON_ORDER.index(snapshot["weapon"]) + 1 \
                        if snapshot["weapon"] in WEAPON_ORDER else 0
                    self._weapon_want_ticks = \
                        self._weapon_want_ticks + 1 \
                        if want == self._weapon_want else 0
                    self._weapon_want = want
                    inp.weapon = want if (want == cur or
                                          self._weapon_want_ticks >= 12) \
                        else 0
                else:
                    ds = self._distant_threat_input(session, snapshot,
                                                    distant,
                                                    visible_screens,
                                                    px, py)
                    inp.ax, inp.ay = ds.ax, ds.ay

        # retreat-to-guns schema
        ret_vec = (0.0, 0.0)
        if rg > 0.05:
            if self._retreat_polygon is None or tick % 30 == 0:
                self._retreat_polygon = self._best_field(session, ppolygon)
            if self._retreat_polygon is not None:
                ret_vec = self._nav_polygon_move(session, snapshot, px, py,
                                              self._retreat_polygon)
        # FUNNEL RETREAT (2026-07-18): badly outnumbered co-polygon, fall
        # back through the door you came in — the doorway strings the
        # pack out single-file, which is the level's whole choke
        # grammar (deaths were 4-8 enemies co-polygon, engulfed in the
        # open). Feet retreat; the gun keeps firing. LATCHED: the
        # funnel thins the co-polygon count below its own trigger, and
        # without a hold the bot surged straight back in and
        # re-engulfed (measured). While the hold runs and the polygon is
        # clear, STAND at the door and shoot what comes through — the
        # doorway dance, not a rout.
        trail = getattr(self, "_trail", None)
        # triggers are PRESSURE, not headcount — three hunters is the
        # intended boss crowd (Sol §1.5): withdraw when hurt, when the
        # warden presses with adds committed, or when it's a true mob
        # DUEL COMMITMENT: once it's the warden and at most one
        # straggler, see it through — withdrawing from a tethered
        # boss kills nothing and loops forever (measured: 9/16 runs
        # timed out in a withdraw/re-enter siege cycle)
        duel = any(e.get("kind") == "warden" for e in co_polygon) and \
            sum(1 for e in co_polygon if e.get("kind") != "warden"
                and e.get("active")) <= 1
        hp_line = 40 if duel else 65
        # live pursuit gates the trigger; tethered wardens are
        # excluded from "pursuit" (a visible boss door kept wounded
        # runs locked backward forever), but a single mobile chaser
        # at low hp still withdraws — that rule carried the first
        # full clear
        # A/B via BOT_FUNNEL_FORM: 'co' = hp trigger needs a co-polygon
        # chaser (kills the distant-visibility lock, 3 timeouts);
        # 'dist' = distant non-warden hunters also arm it (round-3
        # form that measured 34%/2.6-trigger clears). n=64 decides.
        if os.environ.get("BOT_FUNNEL_FORM", "co") == "dist":
            live_threat = n_co_hunt >= 1 or any(
                e.get("active")
                and e.get("kind") != "warden" for e in distant)
            trig = live_threat and (snapshot["hp"] < hp_line
                                    or n_co_hunt >= 5)
        else:
            trig = ((n_co_hunt >= 1 and snapshot["hp"] < hp_line)
                    or n_co_hunt >= 3)
        # (a mites-don't-count variant was tried 2026-07-18 and made
        # the bot brawl mite floods in the OPEN — the funnel is a
        # fighting withdrawal to a choke, gun firing, which is exactly
        # the right answer to a swarm of faster pursuers)
        # WARDEN ERUPTION (honest-game death footage): a co-polygon
        # warden with its brood pouring in is fought from behind the
        # entry pinch, never in the open — here mites DO count (they
        # are the engulfment), because the withdrawal target is a
        # choke that strings them single-file, not open-field flight
        trig = trig or (any(e.get("kind") == "warden"
                            and e.get("active")
                            for e in co_polygon)
                        and n_co_hunt >= 4)
        # FIRST-SIGHT RECOIL (single-pull doctrine): compound wardens
        # are only noise-coupled at 1 hop — a brawl fought 2+ polygons
        # down the Z-hall wakes nobody else. Every multi-warden
        # disaster starts the same way: the bot keeps walking after
        # first warden sight until 2-3 have LOS-engaged at once. The
        # first time each NEW warden is perceived, recoil hard; the
        # one that engaged follows alone into the kite, the rest stay
        # asleep.
        any_ward = any(e.get("kind") == "warden"
                       for e in co_polygon + distant)
        if any_ward:
            self._warden_last_seen = tick
        elif self._warden_seen and \
                tick - getattr(self, "_warden_last_seen", 0) > 600:
            # re-arm after 10 quiet seconds — but CAPPED at two
            # recoils per warden id: uncapped, one parked warden
            # recoil-looped a doorway for 4+ minutes (seed 2219 polygon
            # 105); banned outright, the median collapsed 217->133s
            # (the second recoil after a field kill was load-bearing).
            # Past the cap the approach is a siege: provoke, kite,
            # kill.
            self._warden_seen = {i for i in self._warden_seen
                                 if self._warden_recoils.get(i, 0) >= 2}
        fresh_pull = False
        for e in co_polygon + distant:
            if e.get("kind") == "warden" and \
                    e["id"] not in self._warden_seen:
                self._warden_seen.add(e["id"])
                self._warden_recoils[e["id"]] = \
                    self._warden_recoils.get(e["id"], 0) + 1
                trig = True
                fresh_pull = True
        # LIVE PURSUIT WEIGHT: the wave one hop back counts — episode
        # accounting (2026-07-18, 8 seeds): pack fights of 1-2 cost
        # 4.6hp; EVERY engagement of 5+ cost ~100hp (death). The old
        # hold expired whenever co-polygon momentarily hit zero mid-
        # flight, so the bot turned around with the 8-wave one polygon
        # behind and met it all at once. Withdraw until the PURSUIT
        # thins, not until an arbitrary depth.
        # wardens count: untethered they pursue (137 u/s vs our 133 —
        # they always close), and they were exactly the grinders in
        # the portal-plane deaths
        n_pursuit = n_co_hunt + sum(
            1 for e in distant
            if e.get("active"))
        # a warden PAIR keeps the withdrawal latched the whole way to
        # the guns — two same-speed anchors cannot be killed in a bare
        # corridor kite (double-pull deaths, rounds 16-18); the sentry
        # field can (3x18dmg ~= a warden per 7s of field time)
        n_ward_hunt = sum(1 for e in co_polygon + distant
                          if e.get("kind") == "warden"
                          and e.get("active"))
        if (trig or (self._funnel_hold > 0
                     and (n_pursuit >= 5 or n_ward_hunt >= 2))) \
                and self._escape_ticks == 0 and trail:
            # a FRESH pull runs long: the r25 bank's discriminator
            # between deep runs and 110s deaths was first-encounter
            # size (1-4 hunters vs 9+, same entry hp) — i.e. how far
            # the pull got dragged before the fight stuck. 4s (~2
            # polygons) isn't enough head start to string a hatching
            # brood; 10s is 4-5 polygons and the mites arrive as singles
            self._funnel_hold = 600 if fresh_pull \
                else max(self._funnel_hold, 240)
            if trig:
                self._funnel_polygons = 0
        elif self._funnel_hold > 0:
            self._funnel_hold -= 1
        if self._funnel_hold > 0 and trail and \
                (n_co_hunt >= 1 or n_pursuit >= 5
                 or getattr(self, "_funnel_polygons", 0) < 2):
            # CHECK YOUR SIX (2026-07-18 pincer trace: 487 funnel
            # ticks retreating toward a polygon ALREADY holding >=2
            # hunters — the trail polygon fills with converging pursuit
            # while we fight forward, and rote withdrawal marches
            # into the second pack). If the trail polygon is occupied,
            # fall back toward the least-occupied neighbor instead,
            # preferring walked ground.
            occ: dict[int, int] = {}
            for e in distant:
                if e.get("active"):
                    # a warden is not "one occupant" — it is a wall
                    # (2234 trace: the guns-run pathed THROUGH a
                    # warden pair, body-blocked at the portal for 5s,
                    # ground from 94 to dead while 'running')
                    w = 10 if e.get("kind") == "warden" else 1
                    occ[e["polygon"]] = occ.get(e["polygon"], 0) + w
            def _longdim(r):
                try:
                    vs = session.level.polygon_verts[r]
                    xs = [v[0] for v in vs]; ys = [v[1] for v in vs]
                    return max(max(xs) - min(xs), max(ys) - min(ys))
                except Exception:
                    return 999.0
            fdest = trail[-1]
            # KITE SPACE (2224 footage: mid-kite at hp 98 the bot
            # backed into a ~150u medbay pocket and died against its
            # far wall in 6s — the warden filled the doorway). Under
            # warden pursuit a polygon shorter than the 350u standoff
            # is a death box whatever its door count; retreat along
            # polygons you can keep kiting in.
            if n_ward_hunt >= 1 and _longdim(fdest) < 300.0:
                cands = [p[0] for p in session.sim.polygon_portals(ppolygon)
                         if p is not None]
                polygony = [r for r in cands if _longdim(r) >= 300.0
                         and occ.get(r, 0) < 2]
                if polygony:
                    fdest = min(polygony, key=lambda r: (
                        occ.get(r, 0),
                        0 if r in self._visited_polygons else 1))
            if occ.get(fdest, 0) >= 2:
                cands = [p[0] for p in session.sim.polygon_portals(ppolygon)
                         if p is not None]
                if cands:
                    # coffin guard for the kite: a 1-door polygon ends
                    # the withdrawal (two medbay cornering deaths,
                    # round-12 probe) — never flee INTO a dead end
                    def _doors(r):
                        return sum(1 for p in
                                   session.sim.polygon_portals(r)
                                   if p is not None)
                    fdest = min(cands, key=lambda r: (
                        occ.get(r, 0),
                        0 if _doors(r) >= 2 else 1,
                        0 if r in self._visited_polygons else 1))
            # (COVER ROUTING via lateral retreat vs spitters was tried
            # 2026-07-19 and measured negative, mean 276->225: any
            # interference with withdrawal routing loses more than the
            # broken sightline saves — consistent with every routing
            # override this doctrine has measured. Real cover needs
            # positional fighting [corner-peek], a planner-scale build.)
            # KITE TO THE GUNS (director's designed answer to a heavy
            # train: "kite-to-turrets stays a valid strat" — the
            # sentry alcoves are 3x18dmg emplacements built exactly
            # for this). Under a train we cannot thin ourselves —
            # 5+ pursuers or any hunting warden (faster than us,
            # unkillable mid-flight) — the withdrawal leads INTO the
            # strongest reachable field instead of pacing the trail.
            if n_pursuit >= 5 or self._warden_hunting:
                fr = self._best_field(session, ppolygon)
                if fr is None:
                    self.diag["gr_nofield"] = \
                        self.diag.get("gr_nofield", 0) + 1
                elif fr != ppolygon and \
                        0 < session.sim.hop_distance(ppolygon, fr) <= 8:
                    fedge = session.sim.next_edge(ppolygon, fr)
                    if fedge >= 0:
                        port = session.sim.polygon_portals(ppolygon)[fedge]
                        if port is not None and occ.get(port[0], 0) < 4:
                            fdest = port[0]
                            self.diag["gunrun"] = \
                                self.diag.get("gunrun", 0) + 1
                        else:
                            self.diag["gr_blocked"] = \
                                self.diag.get("gr_blocked", 0) + 1
            # a fighting WITHDRAWAL: keep going ~240u past the door
            # and around the bends — standing at the doorway for four
            # seconds was the stall (Sol: kill the single-file
            # pursuers at the choke, from depth)
            fv = self._nav_polygon_move(session, snapshot, px, py, fdest)
            if fv != (0.0, 0.0):
                ret_vec = fv
                rg = max(rg, 0.9)
                fight_gain *= 0.55
                self.diag["funnel"] += 1

        # advance schema: the objective (medkit when hurt, else exit) --
        # always some forward intent, damped by pressure and retreat
        # a live co-polygon fight all but zeroes forward objective pull --
        # the blend must never read as running past enemies (the
        # arbitration's first cut at 0.28/hunter left 0.72 advance with
        # one hunter on screen and the bot toured the gauntlet shooting
        # over its shoulder: 19 kills in 200s)
        n_dist_hunt = sum(1 for e in distant
                          if e.get("active"))
        # damping counts EVERY perceived co-polygon enemy: aggro-only is
        # the retreat rule, not license to stroll past a fight plinking
        # idle targets on the move (that leak re-created run-past)
        adv_gain = max(0.08, 1.0 - rg - 0.5 * len(co_polygon)
                       - 0.2 * min(3, n_dist_hunt))
        # NEVER walk on with hunters inbound (the absolute-priority law,
        # re-lost in the blend: measured run-past of a waking husk, then
        # a 74-tick stroll with it chasing): no co-polygon fight + anything
        # hunting on screen = stand your ground and meet it, gun up
        if not co_polygon and n_dist_hunt > 0 and rg < 0.4:
            adv_gain = min(adv_gain, 0.12)
        # planted (deleting a free target): the advance schema stands
        # down too -- at 0.5 gain it dragged the blend through the
        # doorway at forced full pace while the fight schema strafed
        if self._planted:
            adv_gain = min(adv_gain, 0.05)
        # funnel hold: the polygon ahead just mobbed us — stand at the
        # door with the gun up until the hold expires; do not stroll
        # back into the arena the moment it looks locally clear
        if self._funnel_hold > 0:
            adv_gain = min(adv_gain, 0.02)
        # FINISH THE PULL (single-pull doctrine, part 2): while a
        # hunting warden is within 3 hops it WILL close (137 vs our
        # 133) — advancing now walks into the next warden's sight
        # line and turns one pull into a train (measured: every
        # multi-warden death). The pulled anchor gets finished first;
        # the objective can wait the ~20s that takes.
        if any(e.get("kind") == "warden"
               and e.get("active")
               and 0 <= e.get("hops", 9) <= 3
               for e in co_polygon + distant):
            adv_gain = min(adv_gain, 0.02)
        # doorway discipline: 67% of all damage landed within 1.5s of a
        # polygon entry (measured, seed 1054) -- the blind stumble. Any
        # portal into a polygon not yet walked slows the approach to a
        # careful entrance; perception catches up before the body does.
        # THRESHOLD HOLD (2026-07-18, from arena-1 death footage: the
        # bot strolled mid-polygon into 8 convergers and died in the open
        # every time): a visibly CROWDED unvisited polygon — or a warden
        # polygon when hurt — is fought FROM HERE. Anchor in a stand-off
        # band at the portal, fire through it, and let the noise pull
        # them out single-file through the pinch. A healthy bot still
        # walks into a warden polygon deliberately: the co-polygon brood
        # brawl is the boss fight (and the boss music), and the funnel
        # retreat stays armed as the escape valve.
        self._threshold_hold = False
        if not co_polygon:
            portals = session.sim.polygon_portals(ppolygon)
            hold = None
            for edge, portal in enumerate(portals):
                if portal is None:
                    continue
                mx_, my_ = session.sim.edge_midpoint(ppolygon, edge)
                pd = math.hypot(mx_ - px, my_ - py)
                if pd >= 190.0:
                    continue
                beyond = [e for e in distant
                          if e.get("polygon") == portal[0]]
                # the warden door is gated no matter how often we've
                # been through it: the arena-1 death pattern was
                # RE-entries at hp 41/32/22/11/2 (visited-polygon checks
                # only guarded the first walk in). Enter ARMED — near
                # full hp with the lightning burst ready for the brood
                # hatch — or not at all... except: walk away to a
                # reachable medkit rather than besiege at low hp, and
                # after ~25s of siege COMMIT anyway (a door-stall
                # timed out a whole run standing here).
                if any(e.get("kind") == "warden" for e in beyond):
                    # hp>=70, not 90: the sim's own pickup ceiling is
                    # 70 ("leave it for later") — an arming bar above
                    # it is UNREACHABLE by healing, and the measured
                    # result was an 11s dead stall at hp 84 (can't
                    # arm, won't heal) ended by the breaker forcing
                    # the same under-armed entry the gate exists to
                    # prevent
                    armed = (snapshot["hp"] >= 70
                             and (snapshot["lightning_ready"]
                                  or "lightning"
                                  not in snapshot["weapons"]))
                    has_med = any(p["kind"] == "medkit"
                                  and 0 <= p.get("hops", 9) <= 3
                                  for p in snapshot["pickups"])
                    go_heal = snapshot["hp"] < 70 and has_med
                    if not armed and not go_heal \
                            and self._hold_break <= 0:
                        hold = (mx_, my_, pd)
                        break
                if portal[0] in self._visited_polygons:
                    continue
                # NARROW-WAIST ARMING (2026-07-18 death footage): the
                # boss halls' Z-bends hide the arena from perception —
                # `beyond` is empty at exactly the doors that matter
                # most, and the bot strolled through a 64u slit at hp
                # 84 into a two-warden double-brood eruption. The slit
                # itself is the tell (chokes/pinches are ~64u; honest
                # polygon portals are 150+): a narrow waist into unwalked
                # territory demands the same arming as a seen warden
                # door.
                x1, y1, x2, y2 = session.sim.edge_endpoints(ppolygon, edge)
                if math.hypot(x2 - x1, y2 - y1) < 80.0 \
                        and self._hold_break <= 0:
                    armed = (snapshot["hp"] >= 70
                             and (snapshot["lightning_ready"]
                                  or "lightning"
                                  not in snapshot["weapons"]))
                    has_med = any(p["kind"] == "medkit"
                                  and 0 <= p.get("hops", 9) <= 3
                                  for p in snapshot["pickups"])
                    # LISTENING HOLD (sound-pull doctrine): our own
                    # approach gunfire alerts 1 hop — whatever it
                    # woke is already walking here. Crossing the
                    # waist NOW meets it in the open on ITS ground
                    # plus whatever else gains LOS at the mouth.
                    # Wait out a quiet window at the choke first:
                    # the pulled arrivals come to our gun single-
                    # file, and only a genuinely quiet compound gets
                    # entered. (The clock is wound in the main flow —
                    # any perceived hunter or shot fired resets it.)
                    listening = tick < getattr(self, "_listen_t", 0)
                    if (not armed and not (snapshot["hp"] < 70
                                           and has_med)) or listening:
                        hold = (mx_, my_, pd)
                        break
                if len(beyond) >= 3 and self._hold_break <= 0:
                    # crowd holds honor the commit breaker too — this
                    # branch never checked it, so break windows never
                    # opened for crowd sieges (timeout trajectories
                    # bit-identical across three breaker changes)
                    hold = (mx_, my_, pd)
                    break
                if pd < 90.0:
                    self._entry_caution = True
                    break
            else:
                self._entry_caution = False
            if hold is not None:
                self._threshold_hold = True
                self._entry_caution = True
                adv_gain = 0.0
                mx_, my_, pd = hold
                if pd < 60.0:
                    hv = _norm((px - mx_, py - my_))
                elif pd > 120.0:
                    hv = _norm((mx_ - px, my_ - py))
                else:
                    hv = (0.0, 0.0)
                if hv != (0.0, 0.0):
                    sxh, syh = necore.mat_apply_dir(session.cam, *hv)
                    smh = math.hypot(sxh, syh) or 1.0
                    ret_vec = (sxh / smh, syh / smh)
                    rg = max(rg, 0.8)
                self.diag["thold"] = self.diag.get("thold", 0) + 1
        else:
            self._entry_caution = False
        if self._threshold_hold:
            self._hold_ticks += 1
            if self._hold_ticks > 1500:
                # break the siege: THROUGH the door when healthy,
                # AWAY to a far medkit when not (Sol 2 §6). After
                # three failed cycles, commit at any hp >= 40: the
                # measured brawl odds at 60-80 entry are 84-88%,
                # and a guaranteed timeout is 0%.
                self._hold_cycles = getattr(self, "_hold_cycles",
                                            0) + 1
                if snapshot["hp"] >= 70 or \
                        (self._hold_cycles >= 3
                         and snapshot["hp"] >= 40):
                    self._hold_break = 900
                else:
                    self._hold_break = 1400
                self._hold_ticks = 0
        else:
            # DECAY, don't reset: the stalled-seed trace showed the
            # bot oscillating polygons at a boss door, zeroing the
            # consecutive counter forever — the breaker never fired
            # once in an 11-minute siege. Cumulative-ish counting
            # lets it fire within ~30s of real siege time.
            self._hold_ticks = max(0, self._hold_ticks - 4)
            if snapshot["hp"] >= 90:
                self._hold_cycles = 0
        if self._hold_break > 0:
            self._hold_break -= 1
        # BOT_SPRINT=1 (experiment flag, A/B only): full-avoidance
        # speedrun — advance dominates, no holds, fight only what's
        # in the way. Measures whether traversal-without-clearing is
        # even alive as a macro-family.
        if os.environ.get("BOT_SPRINT"):
            adv_gain = 1.0
            self._funnel_hold = 0
            self._threshold_hold = False
            rg = min(rg, 0.2)
        adv_vec = self._objective_move(session, snapshot, px, py, ppolygon)

        RG_W = float(__import__('os').environ.get('BOT_RG_W', '1.15'))
        vx = fight_gain * fight_vec[0] + RG_W * rg * ret_vec[0] + \
            adv_gain * adv_vec[0]
        vy = fight_gain * fight_vec[1] + RG_W * rg * ret_vec[1] + \
            adv_gain * adv_vec[1]
        # flank-escape reflex: ballistic, dominates while it runs
        if self._escape_ticks > 0 and co_polygon:
            gx = px + self._escape_dir[0] * 80.0
            gy = py + self._escape_dir[1] * 80.0
            way = self._steer_target(session, ppolygon, (px, py), (gx, gy))
            ex_, ey_ = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else self._escape_dir
            vx = vx * 0.25 + ex_
            vy = vy * 0.25 + ey_
        # BOSS-DOOR BARRIER (frontier lock, minimal form): never
        # DRIFT through a door with a warden behind it while fighting
        # or under-hp — deliberate armed entry goes through the
        # threshold-hold path. (Flight recorder: 69 encounters/64
        # runs entered below hp 60 at 52% survival, all via combat
        # drift AFTER the door gates were already tight.)
        if (co_polygon or snapshot["hp"] < 90) \
                and self._hold_break <= 0:
            # (the barrier stands down during a commit-break window:
            # breaker-says-go vs barrier-says-never deadlocked four
            # runs into 7-11 minute sieges — measured thold 27-41k)
            for edge, portal in enumerate(
                    session.sim.polygon_portals(ppolygon)):
                if portal is None:
                    continue
                if not any(e.get("kind") == "warden"
                           and e.get("polygon") == portal[0]
                           for e in distant):
                    continue
                mxb, myb = session.sim.edge_midpoint(ppolygon, edge)
                dpx, dpy = px - mxb, py - myb
                dp = math.hypot(dpx, dpy)
                if dp < 85.0:
                    wb = 1.5 * (85.0 - dp) / 85.0
                    sxb, syb = necore.mat_apply_dir(
                        session.cam, dpx / max(dp, 1e-6),
                        dpy / max(dp, 1e-6))
                    smb = math.hypot(sxb, syb) or 1.0
                    vx += 1.5 * wb * sxb / smb
                    vy += 1.5 * wb * syb / smb

        # POCKET-DOOR BARRIER (same idiom): while a co-polygon warden
        # hunts, the mouths of SMALL polygons repel — the r33 medbay
        # deaths were the standoff repulsion field-pushing the bot
        # through a pocket door it never chose (10/64; disabling the
        # repulsion instead collapsed the bank). Kill the funnel-into-
        # coffin at the door, keep the push.
        if any(e.get("kind") == "warden" and e.get("active")
               for e in co_polygon):
            for edge, portal in enumerate(
                    session.sim.polygon_portals(ppolygon)):
                if portal is None:
                    continue
                try:
                    vs = session.level.polygon_verts[portal[0]]
                    xs = [v[0] for v in vs]; ys = [v[1] for v in vs]
                    if max(max(xs) - min(xs),
                           max(ys) - min(ys)) >= 300.0:
                        continue
                except Exception:
                    continue
                mxb, myb = session.sim.edge_midpoint(ppolygon, edge)
                dpx, dpy = px - mxb, py - myb
                dp = math.hypot(dpx, dpy)
                if dp < 75.0:
                    wb = (75.0 - dp) / 75.0
                    sxb, syb = necore.mat_apply_dir(
                        session.cam, dpx / max(dp, 1e-6),
                        dpy / max(dp, 1e-6))
                    smb = math.hypot(sxb, syb) or 1.0
                    vx += 1.2 * wb * sxb / smb
                    vy += 1.2 * wb * syb / smb

        # ENTRY-LIP LEASH (Sol §1.2): while the warden's brood is
        # live, fight from the door lip — the add-first targeting
        # walked the bot toward the far-side spawn wave, i.e. into
        # the polygon center, which was the engulfment
        if any(e.get("kind") == "warden" for e in co_polygon) \
                and n_co_hunt >= 2 \
                and getattr(self, "_entry_door", None) is not None:
            dxl = px - self._entry_door[0]
            dyl = py - self._entry_door[1]
            dl = math.hypot(dxl, dyl)
            if dl > 140.0:
                lv = _norm((-dxl, -dyl))
                sxl, syl = necore.mat_apply_dir(session.cam, *lv)
                sml = math.hypot(sxl, syl) or 1.0
                vx = vx * 0.5 + 1.3 * sxl / sml
                vy = vy * 0.5 + 1.3 * syl / sml

        # WARDEN STANDOFF (2026-07-18, the range war): a warden closes
        # at only 4 u/s net (137 vs our 133) — at range it is a free
        # rail target for minutes; at touch range it grinds 10-30hp
        # per second (portal-plane micro-trace). Treat a hunting
        # warden like contact treats melee: a repulsion field, here at
        # 350u — back off at combat pace, gun firing the whole time.
        # The brood arrives speed-sorted (mites first, ALONE) into the
        # close-range machinery; the warden itself never gets to
        # touch.
        # (Direction-to-nav-only was tried 2026-07-18 and collapsed
        # the bank 298->117s mean, 0 clears: the raw away-vector IS
        # what holds the 350u gap mid-withdrawal; nav alone loses the
        # race. The medbay pocket-push is the lesser evil.)
        wrx = wry = 0.0
        for e in co_polygon:
            if e.get("kind") != "warden" or \
                    not e.get("active"):
                continue
            d = _dist(e["pos"], (px, py))
            if d < 350.0:
                w = (350.0 - d) / 350.0
                dvx, dvy = px - e["pos"][0], py - e["pos"][1]
                dm = math.hypot(dvx, dvy) or 1e-6
                wrx += dvx / dm * w
                wry += dvy / dm * w
        if wrx or wry:
            wm = math.hypot(wrx, wry)
            sxw, syw = necore.mat_apply_dir(session.cam,
                                            wrx / wm, wry / wm)
            smw = math.hypot(sxw, syw) or 1.0
            vx = vx * 0.4 + 1.5 * sxw / smw
            vy = vy * 0.4 + 1.5 * syw / smw

        # (CORNER-PEEK COVER was built and measured 2026-07-19: mean
        # 276->143s, the worst single result of the program. Anchoring
        # at a doorway mouth to peek-fire pins the bot exactly where
        # portal-plane touch grind and brood streams live; every
        # cover-family variant — lateral routing, spit-merge dodging,
        # peeking — measures negative because this game's melee-flood
        # dynamics punish ANY stationarity near mouths. Cover suits
        # slower threat mixes; here, flow is armor.)
        # SPIT-DODGE REFLEX (2026-07-18): projectiles are dodgeable —
        # sidestep off the flight line of any spit closing within
        # ~0.55s. The enraged warden's radial bursts were literally
        # invisible before (snapshot carried no projectiles at all;
        # snapshot['spits'] added same day). Strong blend, still below
        # contact-evasion: the thing biting you outranks the thing
        # merely flying at you.
        # (Cross-polygon spit merging into the dodge is a TWICE-measured
        # negative — old game median 207->117s, new deep-sightline game
        # mean 276->223s: the dodge override thrashes navigation
        # whenever portal spits are visible, which post-multi-hop is
        # constantly. The answer to deep sightlines is COVER
        # [director], handled in the withdrawal routing — not reactive
        # dodging of everything on screen.)
        ddx = ddy = 0.0
        for sp in snapshot.get("spits", ()):
            spx, spy = sp["pos"]
            svx, svy = sp["vel"]
            sv = math.hypot(svx, svy)
            if sv < 1.0:
                continue
            ux_, uy_ = svx / sv, svy / sv
            rx, ry = px - spx, py - spy
            along = rx * ux_ + ry * uy_
            if along < -10.0 or along > sv * 0.55:
                continue                # behind us, or >0.55s out
            lat = rx * -uy_ + ry * ux_  # signed miss distance
            if abs(lat) > 30.0:
                continue                # already missing
            side = 1.0 if lat >= 0.0 else -1.0
            w = (30.0 - abs(lat)) / 30.0
            ddx += -uy_ * side * w
            ddy += ux_ * side * w
        if ddx or ddy:
            self.diag["dodge"] += 1
            dm = math.hypot(ddx, ddy)
            sxd, syd = necore.mat_apply_dir(session.cam,
                                            ddx / dm, ddy / dm)
            smd = math.hypot(sxd, syd) or 1.0
            vx = vx * 0.45 + 1.6 * sxd / smd
            vy = vy * 0.45 + 1.6 * syd / smd

        # CONTACT-EVASION REFLEX (director 2026-07-16: "it still loves
        # letting enemies touch it. 'Move away from melee enemy within
        # 30 px' needs to have overriding priority"). Subsumption layer:
        # any enemy inside touch range overrides the whole blend -- move
        # directly away from the local contact mass at full speed, gun
        # still on the closest (aim is unaffected).
        evade_x = evade_y = 0.0
        for e in co_polygon:
            d = _dist(e["pos"], (px, py))
            if d < 45.0:
                w = 1.0 / max(d, 4.0)
                evade_x -= (e["pos"][0] - px) * w / max(d, 4.0)
                evade_y -= (e["pos"][1] - py) * w / max(d, 4.0)
        if evade_x or evade_y:
            em = math.hypot(evade_x, evade_y)
            sxe, sye = necore.mat_apply_dir(session.cam,
                                            evade_x / em, evade_y / em)
            sm = math.hypot(sxe, sye) or 1.0
            inp.mx, inp.my = sxe / sm, sye / sm
            return self._apply_unstick(px, py, inp)

        # COMBAT LOCOMOTION INVARIANT (subsumption, below contact-
        # evasion): standing still in a live fight is the measured #1
        # damage source (~270 HP stationary under visible ranged fire,
        # pixel-identical positions 4-9.5s in 20+ incidents). A short
        # settle is human; a statue is not. Trigger on ACTUAL feet:
        # under ~4u displacement across 18 ticks, for 10+ ticks, with
        # co-polygon contact -> commit to a collision-aware strafe for
        # 24-42 ticks at near-full pace. Aim and fire untouched.
        self._pos_ring.append((px, py))
        if len(self._pos_ring) > 18:
            self._pos_ring.pop(0)
        vis_hunters = [e for e in distant
                       if e.get("active")
                       and e["id"] in visible_screens]
        threat_present = bool(co_polygon) or bool(vis_hunters)
        if threat_present and len(self._pos_ring) >= 18 and \
                _dist(self._pos_ring[0], (px, py)) < 8.0:
            self._freeze_ticks += 1
        else:
            self._freeze_ticks = 0
        if self._loco_ticks > 0 and threat_present:
            self._loco_ticks -= 1
            if co_polygon:
                gx = px + self._loco_dir[0] * 80.0
                gy = py + self._loco_dir[1] * 80.0
                way = self._steer_target(session, ppolygon, (px, py),
                                         (gx, gy))
                lx, ly = _norm((way[0] - px, way[1] - py)) \
                    if _dist(way, (px, py)) > 1e-6 else self._loco_dir
                # polygon-space -> screen-space, like the contact-evasion
                # layer (schema vectors are screen-space by contract)
                sxl, syl = necore.mat_apply_dir(session.cam, lx, ly)
                sml = math.hypot(sxl, syl) or 1.0
                vx, vy = vx * 0.2 + sxl / sml, vy * 0.2 + syl / sml
            else:
                # distant threat: _loco_dir is already screen-space
                # (a portal-visible enemy lives in ANOTHER polygon's
                # frame -- never diff its pos against ours)
                vx = vx * 0.2 + self._loco_dir[0]
                vy = vy * 0.2 + self._loco_dir[1]
            if self._freeze_ticks > 12:
                # committed direction is blocked: flip and recommit
                self._strafe_sign *= -1
                self._loco_dir = (-self._loco_dir[0],
                                  -self._loco_dir[1])
                self._loco_ticks = 24 + int(self._strafe_rng.random()
                                            * 18)
                self._freeze_ticks = 0
        elif self._freeze_ticks > 10 and threat_present and \
                self._escape_ticks == 0:
            if co_polygon:
                near = min(co_polygon,
                           key=lambda e: _dist(e["pos"], (px, py)))
                ux_, uy_ = _norm((near["pos"][0] - px,
                                  near["pos"][1] - py))
                self._loco_dir = (-uy_ * self._strafe_sign,
                                  ux_ * self._strafe_sign)
            else:
                pax_, pay_ = necore.mat_apply(session.cam, px, py)
                sx_, sy_ = min(
                    (visible_screens[e["id"]] for e in vis_hunters),
                    key=lambda s: math.hypot(s[0] - pax_, s[1] - pay_))
                ex_, ey_ = _norm((sx_ - pax_, sy_ - pay_))
                self._loco_dir = (-ey_ * self._strafe_sign,
                                  ex_ * self._strafe_sign)
            self._loco_ticks = 24 + int(self._strafe_rng.random() * 18)
            self._planted = False   # the settle shot is over
            self._freeze_ticks = 0

        # pace policy: fights and committed retreats run at FULL speed
        # (a 0.75-gain backpedal moved ~100 u/s against 153 u/s mites --
        # diluted magnitude was the perma-chew), but a lone advance
        # schema keeps its gain as its pace -- blanket renormalization
        # erased the caution signal and the bot sprinted the whole lane
        # in 3s, waking three segments at once (old/new comparison,
        # seed 1002). All schema vectors are already screen-space.
        mag = math.hypot(vx, vy)
        if mag > 1e-6:
            speed = min(1.0, mag)
            if self._planted:
                speed = min(speed, 0.35)
            elif fight_gain > 0.45 or rg > 0.45:
                speed = max(speed, 0.95)
            elif self._entry_caution:
                speed = min(speed, 0.5)     # careful through the door
            inp.mx, inp.my = vx / mag * speed, vy / mag * speed
        else:
            inp.mx, inp.my = 0.0, 0.0

        if co_polygon or distant:
            if not co_polygon:
                inp.mx, inp.my = self._humanize_move(inp.mx, inp.my)
            return self._apply_unstick(px, py, inp)

        # calm: rituals may run on top of the blended (advance) command
        self._escape_ticks = 0

        # polygon-entry protocol (design doc §3): pause at the threshold of
        # unexplored territory and lamp-sweep it from the doorway. A hurt
        # player, or one fresh out of contact, hurries instead -- the
        # ritual reads human only when the situation is calm. Short and
        # infrequent by construction (director's verdict, 2026-07-13:
        # "way too hesitant to move") -- a beat of intention, not a
        # dither -- and preempted entirely the instant anything is
        # perceived, not just once it shares the polygon (see above).
        calm = snapshot["hp"] >= 50 and tick - self._last_contact_tick > 60 * 3
        if calm:
            self._maybe_start_threshold_pause(session, ppolygon, px, py)
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
        rendered viewport"): wider than polygon-membership, because the
        seamless-portal renderer shows a neighboring polygon's contents
        through an open doorway before the player ever crosses into it.
        Cheap: a pure geometry query (no rasterization), measured well
        under the render pass's own per-frame cost."""
        screens: dict[int, tuple[float, float]] = {}
        for _polygon, _xform, _depth, _clip, _walls, _entry_edge, ents \
                in session.visible():
            for eid, sx, sy, _dirx, _diry, _srad, _fully_inside in ents:
                screens[eid] = (sx, sy)
        return screens

    def _objective_move(self, session: GameSession, snapshot: dict,
                         px: float, py: float, ppolygon: int) -> tuple[float, float]:
        """Movement toward the current objective: a nearby medkit when
        hurt, otherwise the exit. Shared by the no-threat branch and by
        `_distant_threat_input` -- closing on a threat still has to go
        SOMEWHERE, and that somewhere is wherever the bot was already
        headed (usually exactly the polygon the threat was spotted in)."""
        relax = (getattr(self, "_hold_break", 0) > 0
                 and snapshot["hp"] < 75)
        # quiet windows buy restock range: deep runs died hp-starved
        # with 100 shells left while walked-past medkits sat 4-6 hops
        # back (pull-cycle hp hovers 40-70, exactly the consumable
        # band)
        med_hops = 12 if relax else \
            (6 if self._threats_total == 0 else 3)
        medkits = [p for p in snapshot["pickups"]
                   if p["kind"] == "medkit"
                   and 0 <= p["hops"] <= med_hops]
        # top-up discipline: a medkit in the CURRENT polygon is a trivial
        # detour -- grab it before the red zone (attrition finding: the
        # bot walked past same-polygon medkits at hp 62 and died of the
        # drip two polygons later). 70 is the SIM's own consume ceiling
        # (`_pickup_scan`: "leave it for later"); chasing one above that
        # is an infinite orbit. Cross-polygon detours keep the old bar.
        heal_bar = 75 if relax else \
            (70 if any(p["hops"] == 0 for p in medkits) else 60)
        if medkits and getattr(self, "_warden_hunting", False):
            # never heal in a coffin while a warden hunts: two probe
            # deaths were medbay corners, kit in reach, warden in the
            # door (2026-07-18). A 1-door medkit polygon is only shopped
            # in peace.
            def _mdoors(r):
                return sum(1 for p in session.sim.polygon_portals(r)
                           if p is not None)
            medkits = [p for p in medkits
                       if p["polygon"] == ppolygon or _mdoors(p["polygon"]) >= 2]
        if snapshot["hp"] < heal_bar and medkits:
            target = None
            # give-up timer: a medkit the bot has chased for 8s without
            # reaching is unreachable in practice (terrain, fold seams)
            # -- blacklist it briefly instead of orbiting forever
            if self._med_target is not None and \
                    snapshot["tick"] - self._med_since > 480:
                self._med_blacklist[self._med_target] = \
                    snapshot["tick"] + 1800
                self._med_target = None
            medkits = [p for p in medkits
                       if self._med_blacklist.get(
                           (p["polygon"], p["pos"]), 0) < snapshot["tick"]]
            if self._med_target is not None:
                target = next((p for p in medkits
                               if (p["polygon"], p["pos"]) == self._med_target),
                              None)
            if target is None:
                if not medkits:
                    self._med_target = None
                    return self._nav_exit_move(session, snapshot, px, py)
                target = min(medkits, key=lambda p: (p["hops"], p["polygon"]))
                self._med_target = (target["polygon"], target["pos"])
                self._med_since = snapshot["tick"]
            if target["polygon"] == ppolygon:
                goal = target["pos"]
            else:
                edge = session.sim.next_edge(ppolygon, target["polygon"])
                goal = self._portal_goal(session, ppolygon, edge) \
                    if edge >= 0 else None
            if goal is None:
                return (0.0, 0.0)
            way = self._steer_target(session, ppolygon, (px, py), goal)
            return nav_to_point(session, px, py, way)
        self._med_target = None
        # AMMO DISCIPLINE (2026-07-18): half the deep deaths were
        # KNIFE-in-hand with every pool at zero — the bot walked past
        # stocked lanes/alcoves all run. Low pools divert to the
        # nearest matching ammo box exactly like medkits do.
        ammo = snapshot.get("ammo", {})
        want_kinds = []
        if ammo.get("9mm", 0) < 90:
            want_kinds.append("ammo_9mm")
        if ammo.get("shell", 0) < 14:
            want_kinds.append("ammo_shell")
        if ammo.get("cell", 0) < 30:
            want_kinds.append("ammo_cell")
        if want_kinds:
            # quiet windows buy restock range, same as medkits: the
            # 13/14-warden near-clear died dueling the last boss at 8
            # cells while its own warden-spoil cell boxes lay at old
            # kill sites a few hops back
            ammo_hops = 6 if self._threats_total == 0 else 3
            boxes = [p for p in snapshot["pickups"]
                     if p["kind"] in want_kinds
                     and 0 <= p["hops"] <= ammo_hops]
            if boxes:
                target = min(boxes, key=lambda p: (p["hops"],
                                                   p["polygon"]))
                if target["polygon"] == ppolygon:
                    goal = target["pos"]
                else:
                    edge = session.sim.next_edge(ppolygon, target["polygon"])
                    goal = self._portal_goal(session, ppolygon, edge) \
                        if edge >= 0 else None
                if goal is not None:
                    way = self._steer_target(session, ppolygon, (px, py),
                                             goal)
                    return nav_to_point(session, px, py, way)
        return self._nav_exit_move(session, snapshot, px, py)

    def _distant_threat_input(self, session: GameSession, snapshot: dict,
                               distant: list[dict],
                               visible_screens: dict[int, tuple[float, float]],
                               px: float, py: float) -> InputFrame:
        """Orient toward the nearest threat that's on screen but not yet
        polygon-local: aim tracks NEAR its actual screen position (valid
        regardless of which polygon it's physically in -- the renderer
        already did that transform for us) with a loose glance wander, not
        combat-precise tracking -- nothing is fired at a not-yet-polygon-local
        target (see `step`'s comment: no weapon's hit test can connect
        polygon-to-polygon), so there is no firing solution to converge on, only
        "I see that." Movement keeps closing on the objective that put it
        in view in the first place; this is "advance with the weapon up,"
        not combat footwork -- that starts the instant `co_polygon` does."""
        ppolygon = snapshot["polygon"]
        inp = InputFrame()
        inp.mx, inp.my = self._objective_move(session, snapshot, px, py, ppolygon)
        inp.mx, inp.my = self._humanize_move(inp.mx, inp.my)

        # cross-polygon comparisons are invalid (different local frames) --
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

    # -- terrain-aware in-polygon steering --------------------------------
    #
    # Walk-mask terrain (rect colliders inside polygons) landed with the art
    # pass; the shared nav helpers steer straight at the target and rely
    # on the random unstick jitter to round obstacles, which grinds for
    # sim-minutes against real cover (l01 polygon 112: AggroBot seed 101
    # spent the full 12-minute budget there; clearing that one polygon's
    # terrain in-session flipped it to complete-in-17s -- causal). Humans
    # walk around furniture: greedy corner-hopping, re-evaluated per tick.

    CLEARANCE = 9.0  # player radius + margin, polygon units

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

    def _steer_target(self, session: GameSession, polygon: int,
                       p: tuple[float, float],
                       target: tuple[float, float]) -> tuple[float, float]:
        """Next waypoint toward `target` around this polygon's terrain rects.
        Greedy: if the straight segment is blocked, hop to the reachable
        inflated corner of a blocking rect that best shortens the path.
        Re-run every tick, so multi-rect fields resolve corner by corner."""
        rects = session.sim.polygon_terrain(polygon) or []
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

    # -- retreat-to-guns schema (BBR rework of the OH-SHIT latch) ------

    def _retreat_gain_update(self, session, snapshot, tick: int) -> None:
        """Continuous 'the fight is being lost' level in [0,1]. Rises
        fast on losing signals (aggro influx outpacing kills while
        engaged, a hunting warden, hurt under pressure), decays slowly
        -- faster once kills outpace influx. Replaces the latched
        OH-SHIT mode: the retreat VECTOR's weight is this gain, so
        falling back blends with fighting instead of snapping."""
        hp = snapshot["hp"]
        n = self._threats_total
        self._pressure_hist.append((tick, n,
                                    session.metrics.get("kills", 0)))
        while self._pressure_hist and \
                tick - self._pressure_hist[0][0] > 120:
            self._pressure_hist.popleft()
        t0, n0, k0 = self._pressure_hist[0]
        influx = n - n0
        killed = session.metrics.get("kills", 0) - k0

        lose = 0.0
        if tick >= self._retreat_cooldown:
            if n >= 3 and influx > killed and self._combat_streak > 90:
                lose += 0.6
            if self._warden_hunting:
                # honest-game calibration: a hunting warden IS a lost
                # local fight — it closes at 137 vs our 133 and cannot
                # be finished in a bare corridor before its compound
                # converges; the one deep run of the r19 bank (354s,
                # 4 wardens down) was the seed whose retreat drive
                # saturated and carried the fight to the sentry field
                lose += 0.85
            if hp < 45.0 and n >= 2:
                lose += 0.5
        lose = min(1.0, lose)
        if lose > self._retreat_gain:
            a = 0.08                        # rise ~0.25s to level
        elif killed > influx and killed > 0:
            a = 0.035                       # fight turned: let go quicker
        else:
            a = 0.012                       # otherwise ease off slowly
        self._retreat_gain += a * (lose - self._retreat_gain)
        if self._retreat_gain < 0.05:
            self._retreat_polygon = None
        # stalemate: a high retreat level that produces no kills for 15s
        # means they are not coming -- drop it and go fight carefully
        if self._retreat_gain > 0.5 and \
                tick - self._last_kill_tick > 60 * 15:
            self._retreat_gain = 0.0
            self._retreat_polygon = None
            self._retreat_cooldown = tick + 600

    def _best_field(self, session: GameSession, ppolygon: int) -> int | None:
        """Strongest reachable sentry field among polygons already seen:
        gun count dominates, hops discount, long polygons get a bonus (the
        kite lane is where a warden's burst can't corner you)."""
        guns = collections.Counter()
        for tid in session.sentries:
            if session.sim.exists(tid):
                guns[session.sim.get_polygon(tid)] += 1
        best, best_score = None, -(1 << 20)
        budget = 8 if self._warden_hunting else 6
        for r, n_guns in guns.items():
            # a field counts as KNOWN if we walked it or walked past
            # its mouth — the alcoves are side pockets off the lanes,
            # and requiring entry left the bot blind to every gun polygon
            # it strolled by (gr_nofield dominated the guns-run diag,
            # 340-1969 ticks/run of "no field known" while alcoves sat
            # one door off the trail)
            if r not in self._visited_polygons and not any(
                    p is not None and p[0] in self._visited_polygons
                    for p in session.sim.polygon_portals(r)):
                continue
            h = session.sim.hop_distance(ppolygon, r)
            if not 0 <= h <= budget:
                continue
            try:
                vs = session.level.polygon_verts[r]
                xs = [v[0] for v in vs]
                ys = [v[1] for v in vs]
                long_dim = max(max(xs) - min(xs), max(ys) - min(ys))
            except Exception:
                long_dim = 0.0
            score = n_guns * 3 - h + (3 if long_dim >= 300.0 else 0)
            # dead-end coffin guard (2026-07-18): a one-door sentry
            # pocket is a strongpoint against a trickle and a coffin
            # against a fast pack (flicker-swarm deaths measured IN
            # the alcove). Under heavy pursuit, prefer fields you can
            # fight THROUGH.
            try:
                n_doors = sum(1 for p in
                              session.sim.polygon_portals(r)
                              if p is not None)
            except Exception:
                n_doors = 2
            if n_doors <= 1 and self._threats_total >= 3:
                score -= 8
            if score > best_score:
                best, best_score = r, score
        return best

    def _portal_goal(self, session: GameSession, ppolygon: int,
                     edge: int) -> tuple[float, float]:
        """A point BEYOND the portal edge, not on it: steering at the
        edge midpoint itself is a knife-edge attractor -- the tick you
        arrive the polygon flips, the goal flips with it, and the bot
        surfs the seam forever (seed 1002 spent 800s sliding along the
        fold at y=74.x). Overshooting along the outward direction
        carries the crossing through."""
        mx_, my_ = session.sim.edge_midpoint(ppolygon, edge)
        try:
            vs = session.level.polygon_verts[ppolygon]
            cx = sum(v[0] for v in vs) / len(vs)
            cy = sum(v[1] for v in vs) / len(vs)
            dx, dy = mx_ - cx, my_ - cy
            d = math.hypot(dx, dy) or 1.0
            return (mx_ + dx / d * 40.0, my_ + dy / d * 40.0)
        except Exception:
            return (mx_, my_)

    def _nav_polygon_move(self, session: GameSession, snapshot: dict,
                       px: float, py: float, target_polygon: int
                       ) -> tuple[float, float]:
        """Terrain-aware movement toward `target_polygon`; inside it, anchor
        just off the nearest sentry (fight from behind the guns)."""
        ppolygon = snapshot["polygon"]
        if ppolygon == target_polygon:
            # hurt and standing next to a medkit: grab it first, then
            # hold at the guns -- the choke IS the resupply point
            if snapshot["hp"] < 60.0:
                meds = [p["pos"] for p in snapshot.get("pickups", [])
                        if p.get("kind") == "medkit" and
                        p.get("polygon") == ppolygon]
                if meds:
                    gx, gy = min(meds, key=lambda a: _dist(a, (px, py)))
                    way = self._steer_target(session, ppolygon, (px, py),
                                             (gx, gy))
                    return nav_to_point(session, px, py, way)
            anchors = []
            for tid in session.sentries:
                if session.sim.exists(tid) and \
                        session.sim.get_polygon(tid) == ppolygon:
                    _, sx, sy, *_ = session.sim.get(tid)
                    anchors.append((sx, sy))
            if not anchors:
                return (0.0, 0.0)
            gx, gy = min(anchors, key=lambda a: _dist(a, (px, py)))
            if _dist((gx, gy), (px, py)) < 34.0:
                return (0.0, 0.0)      # in the field: stand and shoot
            goal = (gx, gy)
        else:
            edge = session.sim.next_edge(ppolygon, target_polygon)
            if edge is None or edge < 0:
                return (0.0, 0.0)
            goal = self._portal_goal(session, ppolygon, edge)
        way = self._steer_target(session, ppolygon, (px, py), goal)
        return nav_to_point(session, px, py, way)

    def _nav_exit_move(self, session: GameSession, snapshot: dict,
                        px: float, py: float) -> tuple[float, float]:
        """`nav_to_exit` with terrain-aware in-polygon steering."""
        ppolygon = snapshot["polygon"]
        if session.exit_polygon < 0:
            return (0.0, 0.0)
        if ppolygon == session.exit_polygon:
            goal = session.exit_pos
        else:
            edge = snapshot.get("exit_next_edge", -1)
            if edge < 0:
                return (0.0, 0.0)
            goal = self._portal_goal(session, ppolygon, edge)
        way = self._steer_target(session, ppolygon, (px, py), goal)
        return nav_to_point(session, px, py, way)

    # -- navigation humanization (design doc §3/§4) --------------------

    THRESHOLD_RADIUS = 42.0

    def _maybe_start_threshold_pause(self, session: GameSession, ppolygon: int,
                                      px: float, py: float) -> None:
        if self._pause_ticks > 0:
            return
        portals = session.sim.polygon_portals(ppolygon)
        for edge, portal in enumerate(portals):
            if portal is None:
                continue
            neighbor = portal[0]
            if neighbor in self._visited_polygons:
                continue
            if (ppolygon, edge) in self._paused_thresholds:
                continue
            mx_, my_ = session.sim.edge_midpoint(ppolygon, edge)
            if math.hypot(mx_ - px, my_ - py) < self.THRESHOLD_RADIUS:
                self._paused_thresholds.add((ppolygon, edge))
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
        # OUTNUMBERED KITE (2026-07-16, dense-gauntlet recalibration): a
        # competent player facing a swarm backpedals — through the lane,
        # the sentry field, the choke — instead of trading into it. Same
        # committed-escape machinery as the flank case, longer leg.
        if len(threats) >= 6 and hp < 65.0:
            vx = vy = 0.0
            for e in threats:
                dx, dy = e["pos"][0] - px, e["pos"][1] - py
                d = math.hypot(dx, dy) or 1e-6
                vx -= dx / d / d
                vy -= dy / d / d
            vmag = math.hypot(vx, vy) or 1e-6
            vx, vy = vx / vmag, vy / vmag
            # kite ALONG the polygon's long axis (a human backpedals down
            # the corridor, through the sentry field / the fold — not
            # into a wall); project the away-vector onto the axis
            ax_dir = self._polygon_long_axis
            if ax_dir is not None:
                dot = vx * ax_dir[0] + vy * ax_dir[1]
                if abs(dot) > 0.25:
                    s = 1.0 if dot > 0 else -1.0
                    vx, vy = ax_dir[0] * s, ax_dir[1] * s
            self._escape_dir = (vx, vy)
            self._escape_ticks = self._nav_rng.randint(90, 140)
            return
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
                       perceived: list[dict], px: float, py: float):
        self._planted = False
        self._update_flank_escape(perceived, snapshot["hp"], px, py)
        # PAIN OVERRIDES EVERYTHING (director 2026-07-16: the bot "will
        # hold fire on an enemy currently touch-hurting it to shoot at a
        # more distant enemy that can't harm it"). An enemy in contact
        # range is hurting us NOW -- it outranks focus hysteresis, the
        # escape-path pool, everything. A human being bitten shoots the
        # thing biting him.
        # FIRE POLICY (director 2026-07-16): "If enemy in LOS, point at
        # closest enemy, hold down trigger." No urgency tiers, no
        # escape-path pools -- closest wins, with only enough hysteresis
        # to stop per-tick ties from flickering the cursor.
        # ADD-FIRST targeting (Sol §3): while the warden's PRESSING
        # screen is alive, the adds are the targets — the 520hp warden
        # soaks a magazine while 4hp mites connect. But "any hunter
        # anywhere on screen" excluded the warden for entire runs on
        # the honest cross-polygon game (0/14 wardens down over 64 runs,
        # mean 0 warden damage per encounter — a brood never fully
        # empties). The screen is what's CLOSE: with fewer than three
        # non-warden hunters inside 200u, the boss is a live target.
        press = sum(1 for e in perceived
                    if e.get("kind") != "warden"
                    and e.get("active")
                    and _dist(e["pos"], (px, py)) < 200.0)
        # ...and a warden inside 140u is ALWAYS live: that close it is
        # spitting into our face — and when it's wedged in a waist it
        # is plugging its own brood's only path; that is the kill
        # window the choke doctrine exists to create
        pool = [e for e in perceived
                if e.get("active")
                and (e.get("kind") != "warden" or press < 3
                     or _dist(e["pos"], (px, py)) < 140.0)]
        if not pool:
            pool = [e for e in perceived if e.get("kind") != "warden"
                    and e.get("active")]
        if not pool:
            pool = perceived
        closest = min(pool, key=lambda e: _dist(e["pos"], (px, py)))
        focus = next((e for e in pool if e["id"] == self._focus_id),
                     None)
        if focus is not None and _dist(focus["pos"], (px, py)) <= \
                1.15 * _dist(closest["pos"], (px, py)):
            nearest = focus
        else:
            nearest = closest
        # RAIL LINES THROUGH THE ANCHOR (kite-war footage: 27 rail
        # shots, zero wardens down — every line was spent on the mite
        # skirmish screen while the 520hp anchor rode mid-train). The
        # rail pierces 3: a line THROUGH the warden kills the screen
        # on the way. With rail in hand, the warden IS the target.
        if snapshot["weapon"] == "rail" and press < 4:
            rw = [e for e in perceived
                  if e.get("kind") == "warden"
                  and e.get("active")
                  and _dist(e["pos"], (px, py)) < 420.0]
            if rw:
                nearest = min(rw, key=lambda e: _dist(e["pos"], (px, py)))
        self._focus_id = nearest["id"]
        ex, ey = nearest["pos"]
        dx, dy = ex - px, ey - py
        dist = math.hypot(dx, dy) or 1e-6
        true_angle = math.atan2(dy, dx)
        # (STOP-AND-POP was tried twice 2026-07-18 against the 38%
        # backpedal rail hit rate — global-phase plants (mean 296->
        # 257s) AND discharge-phase-locked plants via the bot's own
        # cell counter (mean 308->264s, tail 15->8) both measured
        # NEGATIVE: any deliberate stillness near a closing warden
        # costs more than the accuracy buys. Axis closed; the duel
        # hit rate is a skill/mouse property, not a stance one.)
        self._aim_world_angle = true_angle

        aim_angle = true_angle + self._flinch_angle
        # minimum aim extension (director: "engaging enemies from close
        # enough that the aim direction is indeterminate and it shoots
        # the wall" -- 81% of fires were inside 30u, where the cursor
        # sits pixels from the player and tiny error means any bearing):
        # a human aims THROUGH a point-blank target, holding the cursor
        # out where the direction stays determinate
        aim_dist = max(dist, 50.0)
        tx, ty = px + math.cos(aim_angle) * aim_dist, \
            py + math.sin(aim_angle) * aim_dist
        target_ax, target_ay = necore.mat_apply(session.cam, tx, ty)

        mouse = self._ensure_mouse(target_ax, target_ay)
        cur_ax, cur_ay = mouse.step(target_ax, target_ay, 1.0 / 60.0)

        inp = InputFrame()
        inp.ax, inp.ay = cur_ax, cur_ay

        # fire discipline reacts to where the humanized cursor actually is
        # relative to the true (un-flinched) target position on screen --
        # mouse lag, overshoot, and flinch all show up here as misses,
        # rather than as a separately-computed "true" aim error
        # trigger: HELD. The pointing is the MouseModel's problem; misses
        # while the cursor swings are honest human misses. (Every prior
        # gate -- ray-lateral, per-weapon slop, sight-settle -- measured
        # as some flavor of "ABSURDLY gunshy", director, three rounds
        # running.) The 2026-07-19 self-damage arc ended in the SIM's
        # wounded-round guard (sweep_bullets): rounds that lose their
        # muzzle velocity to silent spawn-overlap wall grazes now
        # despawn instead of drifting into their shooter — the
        # bot-side serpentine and fire-line vetoes that compensated
        # for it measured survival-negative and were deleted.
        # ...held only inside RENDERABLE range (same 2-hop law as the
        # portal-fire gate in `step`; filmed-playtest judge: bot filmed
        # firing at unrendered enemies, s7 x2 s11 x1): a 3-hop
        # chain-merged threat still drives the footwork, but its
        # chamber isn't legibly drawn at zoom 0.45 — the trigger waits
        # until it closes to 2 hops.
        inp.fire = 0 <= nearest.get("hops", 0) <= 2
        # (The enrage-preparation gate died with the NPC-internals
        # purge, director 2026-07-18: it read the warden's hp. The
        # enrage roar is the diegetic cue and the bot has no ears —
        # if it ever grows hearing, that is where the gate returns.)

        # the weapon pick sees only what the BOT sees (no omniscient
        # enemy list — same ruling as state/hp)
        want = choose_weapon(dict(snapshot, enemies=perceived),
                             dist, len(perceived))
        # CELL RESERVE: cells are boss fuel (~13 rail cells per
        # warden; charged tau drinks 5 at once). Deep r27 deaths ran
        # cell-dry in 8/24 while shells sat at 75-111 — no rail left
        # for wardens 6-9. Below 40 cells the tau stays holstered
        # while any other ammo lives.
        # ...and NEVER in a narrow polygon: the tau ricochets (rest_wall
        # 1, up to 3 bounces at 1900u/s) — in a 150u corridor a miss
        # comes straight back down the axis into the shooter's face.
        # Measured 2026-07-18: self-returned rounds were 39-43% of ALL
        # damage taken, ~460 hits per 12 runs, and the fold-lane
        # theory was wrong — it's ricochet physics. Tau is an open-
        # polygon weapon.
        def _shortdim(r):
            try:
                vs = session.level.polygon_verts[r]
                xs = [v[0] for v in vs]; ys = [v[1] for v in vs]
                return min(max(xs) - min(xs), max(ys) - min(ys))
            except Exception:
                return 999.0
        # SCRAP DRIVER (2026-07-18): components are DEAD WEIGHT on
        # gauntlet4 (no pods, no fabricator) and the bot banks 300+
        if WEAPON_ORDER[want - 1] == "tau" \
                and (_shortdim(snapshot["polygon"]) < 220.0
                     or (snapshot["ammo"].get("cell", 0) < 40
                         and (snapshot["ammo"].get("9mm", 0) > 0
                              or snapshot["ammo"].get("shell", 0) > 0))):
            want = choose_weapon(
                dict(snapshot, enemies=perceived,
                     weapons=[w for w in snapshot["weapons"]
                              if w != "tau"]),
                dist, len(perceived))
        # the lightning cannon IS the crowd-control answer (director):
        # when a wave is stacked and the implant is charged, pull it out
        # and dump the blast -- with tau in hand, `inp.alt` charges tau
        # instead, so the implant could never discharge in exactly the
        # swarm moment it exists for
        if (len(perceived) >= 5 and snapshot["lightning_ready"]
                and "lightning" in snapshot["weapons"]):
            want = WEAPON_ORDER.index("lightning") + 1
        cur = WEAPON_ORDER.index(snapshot["weapon"]) + 1 \
            if snapshot["weapon"] in WEAPON_ORDER else 0
        self._weapon_want_ticks = self._weapon_want_ticks + 1 \
            if want == self._weapon_want else 0
        self._weapon_want = want
        inp.weapon = want if (want == cur or self._weapon_want_ticks >= 12) else 0
        # WEAPON COMMIT (2026-07-18 death footage: SMG->RAIL->TAU->
        # SHOTGUN->SMG inside ~4s of the deciding brawl — choose_weapon
        # keys on distance-to-current-target, which jumps between a 30u
        # mite and a 95u husk every retarget; every swap is dead
        # trigger time). A human commits to the gun in hand: once
        # switched, hold it 2s unless it runs DRY. The lightning
        # override bypasses — the crowd moment won't wait.
        if inp.weapon and inp.weapon != cur \
                and WEAPON_ORDER[inp.weapon - 1] != "lightning":
            ammo_t = WEAPONS.get(snapshot["weapon"], {}).get("ammo")
            cur_dry = ammo_t is not None \
                and snapshot["ammo"].get(ammo_t, 0) <= 0
            # CONTACT BYPASS (2216 footage: died with the RAIL in
            # hand, five single shots into a mite swarm chewing at
            # touch range — the anti-thrash lock held the sniper
            # through the emergency). Commitment is for range;
            # anything inside 60u unlocks the swap instantly.
            contact = any(_dist(e["pos"], (px, py)) < 60.0
                          for e in perceived)
            if not cur_dry and not contact and snapshot["tick"] < \
                    getattr(self, "_weapon_lock_until", 0):
                inp.weapon = 0
            else:
                self._weapon_lock_until = snapshot["tick"] + 120
        # discharge doctrine: the implant recharges in 9s; in a gauntlet
        # a player rides the cooldown. The old >=3 co-polygon gate meant
        # ZERO discharges in a full 15-minute run (measured, seed 1002)
        # -- the pull-to-the-guns doctrine keeps co-polygon contact at 1-2
        # while the real wave stacks just behind the portal, which is
        # exactly the moment to dump the blast into the funnel.
        # discharge on GEOMETRY, not on ambient dread: the old
        # `threats_total >= 5` clause was ~always true mid-fight, so
        # the implant fired on cooldown at whatever 2-3 happened to
        # be close instead of waiting ~2s for the bunch (corner
        # catch-ups, waist crossings) where one blast deletes 5+
        inp.alt = (snapshot["lightning_ready"]
                   and "lightning" in snapshot["weapons"]
                   and snapshot["weapon"] != "tau"
                   and (sum(1 for e in perceived
                            if _dist(e["pos"], (px, py)) < 150.0) >= 4
                        or any(_dist(e["pos"], (px, py)) < 45.0
                               for e in perceived)
                        or any(e.get("kind") == "warden"
                               and _dist(e["pos"], (px, py)) < 120.0
                               for e in perceived)))

        weapon_name = WEAPON_ORDER[inp.weapon - 1] if inp.weapon else snapshot["weapon"]
        ux, uy = dx / dist, dy / dist
        perp = (-uy, ux)
        pressure = min(1.0, len(perceived) / 3.0) + (0.0 if snapshot["hp"] > 40 else 0.4)
        # opportunistic mid-fight heal (0/20 attrition finding: 4 heals
        # in a 96s run with 30 medkits on the map -- healing only ever
        # happened in no-threat windows that a dense gauntlet never
        # grants). A hurt player who sees a medkit in the polygon weaves to
        # it WHILE firing; he does not finish the fight first.
        med_goal = None
        if snapshot["hp"] < 65.0 and dist > 40.0:
            meds = [p["pos"] for p in snapshot.get("pickups", [])
                    if p.get("kind") == "medkit" and
                    p.get("polygon") == snapshot["polygon"] and
                    _dist(p["pos"], (px, py)) < 320.0]
            if meds:
                med_goal = min(meds, key=lambda a: _dist(a, (px, py)))
        if med_goal is not None:
            way = self._steer_target(session, snapshot["polygon"], (px, py),
                                      med_goal)
            move_polygon = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else (0.0, 0.0)
        elif self._escape_ticks > 0:
            # committed flank escape, steered around in-polygon terrain
            gx = px + self._escape_dir[0] * 80.0
            gy = py + self._escape_dir[1] * 80.0
            way = self._steer_target(session, snapshot["polygon"], (px, py),
                                      (gx, gy))
            move_polygon = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else self._escape_dir
        elif weapon_name == "knife":
            move_polygon = (ux, uy)
        elif nearest.get("kind") in ("warden", "brute"):
            # heavies are a RANGE DUEL, not a footrace: turning tail on
            # a warden means eating spit through three polygons (seed 1000:
            # hp 77 -> dead across a 5s retreat, run down mid-flight).
            # Hold the rail band -- back off inside 170, close outside
            # 260, strafe between -- and keep the trigger down.
            if dist < 170.0:
                move_polygon = (-ux, -uy)
            elif dist > 260.0:
                move_polygon = (ux, uy)
            else:
                move_polygon = (perp[0] * self._strafe_sign + 0.15 * -ux,
                             perp[1] * self._strafe_sign + 0.15 * -uy)
                # circulation is LATCHED in a boss duel (Sol §1.3):
                # direction flips only when blocked (the freeze
                # detector flips it), never on a coin — reversing
                # into the brood's route was self-encirclement
        elif not nearest.get("active") and \
                snapshot["hp"] >= 30:
            # an idle OR still-waking target is free damage: plant your
            # feet and delete it -- backpedal/kite footwork here walked
            # the bot off the target (and back through the doorway)
            # before the trigger could settle
            self._planted = True
            move_polygon = (0.0, 0.0)   # feet planted means planted: the
            #   0.3 strafe drifted the bot over the very doorway seam
            #   it was standing on when it acquired the target
        elif dist < 80.0 or snapshot["hp"] < 30:
            close = [e for e in perceived
                     if e.get("kind") in ("husk", "mite", "brute",
                                          "flicker", "warden")
                     and _dist(e["pos"], (px, py)) < 110.0]
            if len(close) >= 2:
                # CONTACT-RESOLVE (Sol §1.4): pure backpedal from a
                # faster swarm is how you get cornered — exit through
                # the largest free angular gap, gun stays on target
                bs = sorted(math.atan2(e["pos"][1] - py,
                                       e["pos"][0] - px)
                            for e in close)
                best, mid = -1.0, 0.0
                for i in range(len(bs)):
                    a = bs[i]
                    b = bs[(i + 1) % len(bs)]
                    gap = (b - a) % (2.0 * math.pi)
                    if gap > best:
                        best, mid = gap, a + gap / 2.0
                move_polygon = (math.cos(mid), math.sin(mid))
            else:
                move_polygon = (-ux, -uy)  # 1v1: backpedal-while-firing
        elif dist > 140.0:
            # approach ONLY what will not come to you (director: "it
            # sees an enemy and walks in to it" -- closing on a charging
            # melee enemy meets it at combined speed, at contact, mid
            # sight-settle). A hunting melee kind gets held at range:
            # stand and shoot, give ground slowly, let it cross the gun.
            charging = (nearest.get("active") and
                        nearest.get("kind") in
                        ("husk", "mite", "brute", "flicker", "warden"))
            if charging:
                # STAND and shoot -- pure strafe. A back-drift here
                # walked the bot back through the portal it had just
                # entered, dropping co-polygon and resetting the whole
                # fight (74-tick fire lag at the doorway, measured);
                # ground-giving belongs to the <80u band, not to a
                # target still 140u out
                move_polygon = (perp[0] * self._strafe_sign,
                             perp[1] * self._strafe_sign)
            else:
                move_polygon = (ux, uy)
        else:
            # melee kinds CLOSE through a pure orbit -- 81% of fires
            # ended up point-blank. Kite: strafe with a backward bias,
            # trading ground for range the way the lanes are built for
            j = self._strafe_rng.uniform(-0.3 - 0.2 * pressure, 0.3 + 0.2 * pressure)
            back = 0.55 if nearest.get("kind") in \
                ("husk", "mite", "brute", "flicker") else 0.0
            move_polygon = (perp[0] * self._strafe_sign + (j - back) * ux,
                         perp[1] * self._strafe_sign + (j - back) * uy)
            if self._strafe_rng.random() < 0.02:
                self._strafe_sign *= -1
        mvx, mvy = _norm(move_polygon)
        sx, sy = necore.mat_apply_dir(session.cam, mvx, mvy)
        fvx, fvy = _norm((sx, sy))
        return inp, fvx, fvy
