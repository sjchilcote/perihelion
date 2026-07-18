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

import collections
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
        self._aim_world_angle = 0.0  # last aim direction in room space
        self._med_target = None
        self._med_since = 0
        self._med_blacklist: dict = {}
        self._strafe_sign = 1
        self._strafe_rng = Random(spawn.randrange(1 << 30))
        self._weapon_want = 0
        self._room_long_axis = None
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
        # OH-SHIT retreat (director 2026-07-16: the bot "repeatedly
        # charges in to dark rooms with 50+ enemies... instead of
        # kiting them in to the nearby turrets"): facing a swarm, fall
        # back to the last sentry field passed and fight from there.
        self._pressure_hist = collections.deque()
        self._retreat_cooldown = 0   # suppress re-rise after a stalemate
        # motor-schema arbitration state (BBR/Arkin, director 2026-07-16:
        # behaviors emit vectors, gains weight them, output = the sum --
        # the retreat LEVEL is continuous, not a latched mode)
        self._retreat_gain = 0.0
        self._retreat_room: int | None = None
        self._entry_caution = False
        self._planted = False
        self._warden_hunting = False
        # combat locomotion invariant (Sol consult #1 + incident mining
        # meta-finding "the bot does not MOVE during combat"): if the
        # feet have not actually displaced during a live co-room fight,
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
        proom = snapshot["room"]
        px, py = snapshot["pos"]
        tick = snapshot["tick"]
        self._apply_flinch(snapshot)
        if getattr(self, "_cur_room", None) != proom:
            # breadcrumb trail for the funnel-retreat schema: walking
            # back along the trail POPS it (so a multi-room retreat
            # keeps falling further back, never re-targets the room
            # just abandoned), any other move appends
            prev = getattr(self, "_cur_room", None)
            trail = getattr(self, "_trail", None)
            if trail is None:
                trail = self._trail = []
            if trail and proom == trail[-1]:
                trail.pop()
            elif prev is not None:
                trail.append(prev)
                del trail[:-8]
            self._entry_door = None
            if prev is not None:
                try:
                    for edge, portal in enumerate(
                            session.sim.room_portals(proom)):
                        if portal is not None and portal[0] == prev:
                            self._entry_door = \
                                session.sim.edge_midpoint(proom, edge)
                            break
                except Exception:
                    pass
            if getattr(self, "_funnel_hold", 0) > 0:
                # withdrawal depth is counted in ROOMS — coordinates
                # are room-local in portal space, distances across
                # frames are meaningless
                self._funnel_rooms = getattr(self, "_funnel_rooms",
                                             0) + 1
            self._cur_room = proom

        # room bookkeeping: entering a never-seen room starts a curiosity
        # look-around beat (design doc §6)
        try:
            vs = session.level.room_verts[proom]
            xs = [v[0] for v in vs]
            ys = [v[1] for v in vs]
            w, h = max(xs) - min(xs), max(ys) - min(ys)
            self._room_long_axis = (1.0, 0.0) if w >= h else (0.0, 1.0)
        except Exception:
            self._room_long_axis = None
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

        kills = session.metrics.get("kills", 0)
        if kills != self._last_kills:
            self._last_kills = kills
            self._last_kill_tick = tick
        # pressure = AGGROED enemies only (director 2026-07-16: the bot
        # "spends the VAST majority of its time trying to kite enemies
        # that haven't even aggroed yet" -- an idle enemy on screen is
        # scenery, not pressure; it gets fought where it stands)
        if any(e.get("kind") == "warden" for e in co_room) and \
                not getattr(self, "_warden_room_logged", 0) == proom:
            self._warden_room_logged = proom
            self.diag.setdefault("warden_entry_hp", []).append(
                int(snapshot["hp"]))
        self._threats_total = sum(
            1 for e in co_room + distant
            if e.get("state") in ("hunt", "waking"))
        self._warden_hunting = any(
            e.get("kind") == "warden" and e.get("state") == "hunt"
            for e in co_room + distant)

        # ---- motor-schema arbitration (BBR/Arkin; director's order:
        # "a 'move routine' and a 'fight routine' whose vectors
        # weighted-sum, with the weights determined by the situation").
        # Each behavior emits a room-space vector; gains are continuous
        # functions of the situation; the command = the normalized sum.
        # The only ballistic override left is the flank-escape reflex
        # (a triggered, temporally-extended schema) and unstick.
        self._retreat_gain_update(session, snapshot, tick)
        rg = self._retreat_gain
        n_co_hunt = sum(1 for e in co_room
                        if e.get("state") in ("hunt", "waking"))

        fight_vec = (0.0, 0.0)
        fight_gain = 0.0
        if co_room:
            self._pause_ticks = 0   # combat preempts every ritual
            self._lookaround_ticks = 0
            self._combat_streak += 1
            self._last_contact_tick = tick
            inp, fvx, fvy = self._combat_input(session, snapshot,
                                               co_room, px, py)
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
                # fires on enemies in the same room polygon. That's no
                # good"): bullets are physics bodies and cross portals
                # like everything else -- the old 'room-scoped, would
                # never connect' rationale was wrong for every
                # projectile weapon. Visible on screen = shootable:
                # point at the closest visible enemy, hold the trigger.
                pax, pay = necore.mat_apply(session.cam, px, py)
                cand = [visible_screens[e["id"]] for e in distant
                        if e["id"] in visible_screens]
                if cand:
                    tx_, ty_ = min(cand, key=lambda s: math.hypot(
                        s[0] - pax, s[1] - pay))
                    cam_scale = math.hypot(*necore.mat_apply_dir(
                        session.cam, 1.0, 0.0)) or 1.0
                    dist_est = math.hypot(tx_ - pax, ty_ - pay) / cam_scale
                    mouse = self._ensure_mouse(tx_, ty_)
                    inp.ax, inp.ay = mouse.step(tx_, ty_, 1.0 / 60.0)
                    inp.fire = True
                    want = choose_weapon(snapshot, dist_est, len(distant))
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
            if self._retreat_room is None or tick % 30 == 0:
                self._retreat_room = self._best_field(session, proom)
            if self._retreat_room is not None:
                ret_vec = self._nav_room_move(session, snapshot, px, py,
                                              self._retreat_room)
        # FUNNEL RETREAT (2026-07-18): badly outnumbered co-room, fall
        # back through the door you came in — the doorway strings the
        # pack out single-file, which is the level's whole choke
        # grammar (deaths were 4-8 enemies co-room, engulfed in the
        # open). Feet retreat; the gun keeps firing. LATCHED: the
        # funnel thins the co-room count below its own trigger, and
        # without a hold the bot surged straight back in and
        # re-engulfed (measured). While the hold runs and the room is
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
        duel = any(e.get("kind") == "warden" for e in co_room) and \
            sum(1 for e in co_room if e.get("kind") != "warden"
                and e.get("state") in ("hunt", "waking")) <= 1
        hp_line = 40 if duel else 55
        # live pursuit gates the trigger; tethered wardens are
        # excluded from "pursuit" (a visible boss door kept wounded
        # runs locked backward forever), but a single mobile chaser
        # at low hp still withdraws — that rule carried the first
        # full clear
        live_threat = n_co_hunt >= 1 or any(
            e.get("state") in ("hunt", "waking")
            and e.get("kind") != "warden" for e in distant)
        trig = live_threat and (snapshot["hp"] < hp_line
                                or n_co_hunt >= 5)
        if trig and self._escape_ticks == 0 and trail:
            self._funnel_hold = 240
            self._funnel_rooms = 0
        elif self._funnel_hold > 0:
            self._funnel_hold -= 1
        if self._funnel_hold > 0 and trail and \
                (n_co_hunt >= 1
                 or getattr(self, "_funnel_rooms", 0) < 2):
            # a fighting WITHDRAWAL: keep going ~240u past the door
            # and around the bends — standing at the doorway for four
            # seconds was the stall (Sol: kill the single-file
            # pursuers at the choke, from depth)
            fv = self._nav_room_move(session, snapshot, px, py,
                                     trail[-1])
            if fv != (0.0, 0.0):
                ret_vec = fv
                rg = max(rg, 0.9)
                fight_gain *= 0.55
                self.diag["funnel"] += 1

        # advance schema: the objective (medkit when hurt, else exit) --
        # always some forward intent, damped by pressure and retreat
        # a live co-room fight all but zeroes forward objective pull --
        # the blend must never read as running past enemies (the
        # arbitration's first cut at 0.28/hunter left 0.72 advance with
        # one hunter on screen and the bot toured the gauntlet shooting
        # over its shoulder: 19 kills in 200s)
        n_dist_hunt = sum(1 for e in distant
                          if e.get("state") in ("hunt", "waking"))
        # damping counts EVERY perceived co-room enemy: aggro-only is
        # the retreat rule, not license to stroll past a fight plinking
        # idle targets on the move (that leak re-created run-past)
        adv_gain = max(0.08, 1.0 - rg - 0.5 * len(co_room)
                       - 0.2 * min(3, n_dist_hunt))
        # NEVER walk on with hunters inbound (the absolute-priority law,
        # re-lost in the blend: measured run-past of a waking husk, then
        # a 74-tick stroll with it chasing): no co-room fight + anything
        # hunting on screen = stand your ground and meet it, gun up
        if not co_room and n_dist_hunt > 0 and rg < 0.4:
            adv_gain = min(adv_gain, 0.12)
        # planted (deleting a free target): the advance schema stands
        # down too -- at 0.5 gain it dragged the blend through the
        # doorway at forced full pace while the fight schema strafed
        if self._planted:
            adv_gain = min(adv_gain, 0.05)
        # funnel hold: the room ahead just mobbed us — stand at the
        # door with the gun up until the hold expires; do not stroll
        # back into the arena the moment it looks locally clear
        if self._funnel_hold > 0:
            adv_gain = min(adv_gain, 0.02)
        # doorway discipline: 67% of all damage landed within 1.5s of a
        # room entry (measured, seed 1054) -- the blind stumble. Any
        # portal into a room not yet walked slows the approach to a
        # careful entrance; perception catches up before the body does.
        # THRESHOLD HOLD (2026-07-18, from arena-1 death footage: the
        # bot strolled mid-room into 8 convergers and died in the open
        # every time): a visibly CROWDED unvisited room — or a warden
        # room when hurt — is fought FROM HERE. Anchor in a stand-off
        # band at the portal, fire through it, and let the noise pull
        # them out single-file through the pinch. A healthy bot still
        # walks into a warden room deliberately: the co-room brood
        # brawl is the boss fight (and the boss music), and the funnel
        # retreat stays armed as the escape valve.
        self._threshold_hold = False
        if not co_room:
            portals = session.sim.room_portals(proom)
            hold = None
            for edge, portal in enumerate(portals):
                if portal is None:
                    continue
                mx_, my_ = session.sim.edge_midpoint(proom, edge)
                pd = math.hypot(mx_ - px, my_ - py)
                if pd >= 190.0:
                    continue
                beyond = [e for e in distant
                          if e.get("room") == portal[0]]
                # the warden door is gated no matter how often we've
                # been through it: the arena-1 death pattern was
                # RE-entries at hp 41/32/22/11/2 (visited-room checks
                # only guarded the first walk in). Enter ARMED — near
                # full hp with the lightning burst ready for the brood
                # hatch — or not at all... except: walk away to a
                # reachable medkit rather than besiege at low hp, and
                # after ~25s of siege COMMIT anyway (a door-stall
                # timed out a whole run standing here).
                if any(e.get("kind") == "warden" for e in beyond):
                    armed = (snapshot["hp"] >= 80
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
                if portal[0] in self._visited_rooms:
                    continue
                if len(beyond) >= 3:
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
            if self._hold_ticks > 1500 and snapshot["hp"] >= 55:
                self._hold_break = 900      # commit for 15s
                self._hold_ticks = 0
        else:
            self._hold_ticks = 0
        if self._hold_break > 0:
            self._hold_break -= 1
        adv_vec = self._objective_move(session, snapshot, px, py, proom)

        RG_W = float(__import__('os').environ.get('BOT_RG_W', '1.15'))
        vx = fight_gain * fight_vec[0] + RG_W * rg * ret_vec[0] + \
            adv_gain * adv_vec[0]
        vy = fight_gain * fight_vec[1] + RG_W * rg * ret_vec[1] + \
            adv_gain * adv_vec[1]
        # flank-escape reflex: ballistic, dominates while it runs
        if self._escape_ticks > 0 and co_room:
            gx = px + self._escape_dir[0] * 80.0
            gy = py + self._escape_dir[1] * 80.0
            way = self._steer_target(session, proom, (px, py), (gx, gy))
            ex_, ey_ = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else self._escape_dir
            vx = vx * 0.25 + ex_
            vy = vy * 0.25 + ey_
        # ENTRY-LIP LEASH (Sol §1.2): while the warden's brood is
        # live, fight from the door lip — the add-first targeting
        # walked the bot toward the far-side spawn wave, i.e. into
        # the room center, which was the engulfment
        if any(e.get("kind") == "warden" for e in co_room) \
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

        # SPIT-DODGE REFLEX (2026-07-18): projectiles are dodgeable —
        # sidestep off the flight line of any spit closing within
        # ~0.55s. The enraged warden's radial bursts were literally
        # invisible before (snapshot carried no projectiles at all;
        # snapshot['spits'] added same day). Strong blend, still below
        # contact-evasion: the thing biting you outranks the thing
        # merely flying at you.
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
        for e in co_room:
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
        # co-room contact -> commit to a collision-aware strafe for
        # 24-42 ticks at near-full pace. Aim and fire untouched.
        self._pos_ring.append((px, py))
        if len(self._pos_ring) > 18:
            self._pos_ring.pop(0)
        vis_hunters = [e for e in distant
                       if e.get("state") in ("hunt", "waking")
                       and e["id"] in visible_screens]
        threat_present = bool(co_room) or bool(vis_hunters)
        if threat_present and len(self._pos_ring) >= 18 and \
                _dist(self._pos_ring[0], (px, py)) < 8.0:
            self._freeze_ticks += 1
        else:
            self._freeze_ticks = 0
        if self._loco_ticks > 0 and threat_present:
            self._loco_ticks -= 1
            if co_room:
                gx = px + self._loco_dir[0] * 80.0
                gy = py + self._loco_dir[1] * 80.0
                way = self._steer_target(session, proom, (px, py),
                                         (gx, gy))
                lx, ly = _norm((way[0] - px, way[1] - py)) \
                    if _dist(way, (px, py)) > 1e-6 else self._loco_dir
                # room-space -> screen-space, like the contact-evasion
                # layer (schema vectors are screen-space by contract)
                sxl, syl = necore.mat_apply_dir(session.cam, lx, ly)
                sml = math.hypot(sxl, syl) or 1.0
                vx, vy = vx * 0.2 + sxl / sml, vy * 0.2 + syl / sml
            else:
                # distant threat: _loco_dir is already screen-space
                # (a portal-visible enemy lives in ANOTHER room's
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
            if co_room:
                near = min(co_room,
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

        if co_room or distant:
            if not co_room:
                inp.mx, inp.my = self._humanize_move(inp.mx, inp.my)
            return self._apply_unstick(px, py, inp)

        # calm: rituals may run on top of the blended (advance) command
        self._escape_ticks = 0

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
        # top-up discipline: a medkit in the CURRENT room is a trivial
        # detour -- grab it before the red zone (attrition finding: the
        # bot walked past same-room medkits at hp 62 and died of the
        # drip two rooms later). 70 is the SIM's own consume ceiling
        # (`_pickup_scan`: "leave it for later"); chasing one above that
        # is an infinite orbit. Cross-room detours keep the old bar.
        heal_bar = 70 if any(p["hops"] == 0 for p in medkits) else 60
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
                           (p["room"], p["pos"]), 0) < snapshot["tick"]]
            if self._med_target is not None:
                target = next((p for p in medkits
                               if (p["room"], p["pos"]) == self._med_target),
                              None)
            if target is None:
                if not medkits:
                    self._med_target = None
                    return self._nav_exit_move(session, snapshot, px, py)
                target = min(medkits, key=lambda p: (p["hops"], p["room"]))
                self._med_target = (target["room"], target["pos"])
                self._med_since = snapshot["tick"]
            if target["room"] == proom:
                goal = target["pos"]
            else:
                edge = session.sim.next_edge(proom, target["room"])
                goal = self._portal_goal(session, proom, edge) \
                    if edge >= 0 else None
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
                lose += 0.5
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
            self._retreat_room = None
        # stalemate: a high retreat level that produces no kills for 15s
        # means they are not coming -- drop it and go fight carefully
        if self._retreat_gain > 0.5 and \
                tick - self._last_kill_tick > 60 * 15:
            self._retreat_gain = 0.0
            self._retreat_room = None
            self._retreat_cooldown = tick + 600

    def _best_field(self, session: GameSession, proom: int) -> int | None:
        """Strongest reachable sentry field among rooms already seen:
        gun count dominates, hops discount, long rooms get a bonus (the
        kite lane is where a warden's burst can't corner you)."""
        guns = collections.Counter()
        for tid in session.sentries:
            if session.sim.exists(tid):
                guns[session.sim.get_room(tid)] += 1
        best, best_score = None, -(1 << 20)
        budget = 8 if self._warden_hunting else 6
        for r, n_guns in guns.items():
            if r not in self._visited_rooms:
                continue
            h = session.sim.hop_distance(proom, r)
            if not 0 <= h <= budget:
                continue
            try:
                vs = session.level.room_verts[r]
                xs = [v[0] for v in vs]
                ys = [v[1] for v in vs]
                long_dim = max(max(xs) - min(xs), max(ys) - min(ys))
            except Exception:
                long_dim = 0.0
            score = n_guns * 3 - h + (3 if long_dim >= 300.0 else 0)
            if score > best_score:
                best, best_score = r, score
        return best

    def _portal_goal(self, session: GameSession, proom: int,
                     edge: int) -> tuple[float, float]:
        """A point BEYOND the portal edge, not on it: steering at the
        edge midpoint itself is a knife-edge attractor -- the tick you
        arrive the room flips, the goal flips with it, and the bot
        surfs the seam forever (seed 1002 spent 800s sliding along the
        fold at y=74.x). Overshooting along the outward direction
        carries the crossing through."""
        mx_, my_ = session.sim.edge_midpoint(proom, edge)
        try:
            vs = session.level.room_verts[proom]
            cx = sum(v[0] for v in vs) / len(vs)
            cy = sum(v[1] for v in vs) / len(vs)
            dx, dy = mx_ - cx, my_ - cy
            d = math.hypot(dx, dy) or 1.0
            return (mx_ + dx / d * 40.0, my_ + dy / d * 40.0)
        except Exception:
            return (mx_, my_)

    def _nav_room_move(self, session: GameSession, snapshot: dict,
                       px: float, py: float, target_room: int
                       ) -> tuple[float, float]:
        """Terrain-aware movement toward `target_room`; inside it, anchor
        just off the nearest sentry (fight from behind the guns)."""
        proom = snapshot["room"]
        if proom == target_room:
            # hurt and standing next to a medkit: grab it first, then
            # hold at the guns -- the choke IS the resupply point
            if snapshot["hp"] < 60.0:
                meds = [p["pos"] for p in snapshot.get("pickups", [])
                        if p.get("kind") == "medkit" and
                        p.get("room") == proom]
                if meds:
                    gx, gy = min(meds, key=lambda a: _dist(a, (px, py)))
                    way = self._steer_target(session, proom, (px, py),
                                             (gx, gy))
                    return nav_to_point(session, px, py, way)
            anchors = []
            for tid in session.sentries:
                if session.sim.exists(tid) and \
                        session.sim.get_room(tid) == proom:
                    _, sx, sy, *_ = session.sim.get(tid)
                    anchors.append((sx, sy))
            if not anchors:
                return (0.0, 0.0)
            gx, gy = min(anchors, key=lambda a: _dist(a, (px, py)))
            if _dist((gx, gy), (px, py)) < 34.0:
                return (0.0, 0.0)      # in the field: stand and shoot
            goal = (gx, gy)
        else:
            edge = session.sim.next_edge(proom, target_room)
            if edge is None or edge < 0:
                return (0.0, 0.0)
            goal = self._portal_goal(session, proom, edge)
        way = self._steer_target(session, proom, (px, py), goal)
        return nav_to_point(session, px, py, way)

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
            goal = self._portal_goal(session, proom, edge)
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
            # kite ALONG the room's long axis (a human backpedals down
            # the corridor, through the sentry field / the fold — not
            # into a wall); project the away-vector onto the axis
            ax_dir = self._room_long_axis
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
        # ADD-FIRST targeting (Sol §3): while the warden's brood (or
        # any other hunters) are alive co-room, they are the targets —
        # the 520hp warden soaks a magazine while 4hp mites connect.
        # The warden is fought when its screen is down.
        pool = [e for e in perceived if e.get("kind") != "warden"
                and e.get("state") in ("hunt", "waking")]
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
        self._focus_id = nearest["id"]
        ex, ey = nearest["pos"]
        dx, dy = ex - px, ey - py
        dist = math.hypot(dx, dy) or 1e-6
        true_angle = math.atan2(dy, dx)
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
        # running.)
        inp.fire = True

        want = choose_weapon(snapshot, dist, len(perceived))
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
        # discharge doctrine: the implant recharges in 9s; in a gauntlet
        # a player rides the cooldown. The old >=3 co-room gate meant
        # ZERO discharges in a full 15-minute run (measured, seed 1002)
        # -- the pull-to-the-guns doctrine keeps co-room contact at 1-2
        # while the real wave stacks just behind the portal, which is
        # exactly the moment to dump the blast into the funnel.
        inp.alt = (snapshot["lightning_ready"]
                   and "lightning" in snapshot["weapons"]
                   and snapshot["weapon"] != "tau"
                   and (len(perceived) >= 2 or self._threats_total >= 4))

        weapon_name = WEAPON_ORDER[inp.weapon - 1] if inp.weapon else snapshot["weapon"]
        ux, uy = dx / dist, dy / dist
        perp = (-uy, ux)
        pressure = min(1.0, len(perceived) / 3.0) + (0.0 if snapshot["hp"] > 40 else 0.4)
        # opportunistic mid-fight heal (0/20 attrition finding: 4 heals
        # in a 96s run with 30 medkits on the map -- healing only ever
        # happened in no-threat windows that a dense gauntlet never
        # grants). A hurt player who sees a medkit in the room weaves to
        # it WHILE firing; he does not finish the fight first.
        med_goal = None
        if snapshot["hp"] < 65.0 and dist > 40.0:
            meds = [p["pos"] for p in snapshot.get("pickups", [])
                    if p.get("kind") == "medkit" and
                    p.get("room") == snapshot["room"] and
                    _dist(p["pos"], (px, py)) < 320.0]
            if meds:
                med_goal = min(meds, key=lambda a: _dist(a, (px, py)))
        if med_goal is not None:
            way = self._steer_target(session, snapshot["room"], (px, py),
                                      med_goal)
            move_room = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else (0.0, 0.0)
        elif self._escape_ticks > 0:
            # committed flank escape, steered around in-room terrain
            gx = px + self._escape_dir[0] * 80.0
            gy = py + self._escape_dir[1] * 80.0
            way = self._steer_target(session, snapshot["room"], (px, py),
                                      (gx, gy))
            move_room = _norm((way[0] - px, way[1] - py)) \
                if _dist(way, (px, py)) > 1e-6 else self._escape_dir
        elif weapon_name == "knife":
            move_room = (ux, uy)
        elif nearest.get("kind") in ("warden", "brute"):
            # heavies are a RANGE DUEL, not a footrace: turning tail on
            # a warden means eating spit through three rooms (seed 1000:
            # hp 77 -> dead across a 5s retreat, run down mid-flight).
            # Hold the rail band -- back off inside 170, close outside
            # 260, strafe between -- and keep the trigger down.
            if dist < 170.0:
                move_room = (-ux, -uy)
            elif dist > 260.0:
                move_room = (ux, uy)
            else:
                move_room = (perp[0] * self._strafe_sign + 0.15 * -ux,
                             perp[1] * self._strafe_sign + 0.15 * -uy)
                if self._strafe_rng.random() < 0.02:
                    self._strafe_sign *= -1
        elif nearest.get("state") in ("idle", "waking") and \
                snapshot["hp"] >= 30:
            # an idle OR still-waking target is free damage: plant your
            # feet and delete it -- backpedal/kite footwork here walked
            # the bot off the target (and back through the doorway)
            # before the trigger could settle
            self._planted = True
            move_room = (0.0, 0.0)   # feet planted means planted: the
            #   0.3 strafe drifted the bot over the very doorway seam
            #   it was standing on when it acquired the target
        elif dist < 80.0 or snapshot["hp"] < 30:
            move_room = (-ux, -uy)  # disengage / backpedal-while-firing when hurt
        elif dist > 140.0:
            # approach ONLY what will not come to you (director: "it
            # sees an enemy and walks in to it" -- closing on a charging
            # melee enemy meets it at combined speed, at contact, mid
            # sight-settle). A hunting melee kind gets held at range:
            # stand and shoot, give ground slowly, let it cross the gun.
            charging = (nearest.get("state") in ("hunt", "waking") and
                        nearest.get("kind") in
                        ("husk", "mite", "brute", "flicker", "warden"))
            if charging:
                # STAND and shoot -- pure strafe. A back-drift here
                # walked the bot back through the portal it had just
                # entered, dropping co-room and resetting the whole
                # fight (74-tick fire lag at the doorway, measured);
                # ground-giving belongs to the <80u band, not to a
                # target still 140u out
                move_room = (perp[0] * self._strafe_sign,
                             perp[1] * self._strafe_sign)
            else:
                move_room = (ux, uy)
        else:
            # melee kinds CLOSE through a pure orbit -- 81% of fires
            # ended up point-blank. Kite: strafe with a backward bias,
            # trading ground for range the way the lanes are built for
            j = self._strafe_rng.uniform(-0.3 - 0.2 * pressure, 0.3 + 0.2 * pressure)
            back = 0.55 if nearest.get("kind") in \
                ("husk", "mite", "brute", "flicker") else 0.0
            move_room = (perp[0] * self._strafe_sign + (j - back) * ux,
                         perp[1] * self._strafe_sign + (j - back) * uy)
            if self._strafe_rng.random() < 0.02:
                self._strafe_sign *= -1
        mvx, mvy = _norm(move_room)
        sx, sy = necore.mat_apply_dir(session.cam, mvx, mvy)
        fvx, fvy = _norm((sx, sy))
        return inp, fvx, fvy
