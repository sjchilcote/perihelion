"""GameSession: the deterministic core of PERIHELION.

Pure python + necore. No pygame, no wall-clock, no I/O. Same level + seed +
input sequence => bit-identical run. The renderer and audio system consume
`session.fx` (per-tick effect intents) and `session.decals`; tests and bots
consume `snapshot()` and `metrics`.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from random import Random

import necore

from .levels import Level
from .lighting import LightingSystem, light_level_at
from .senses import SenseQuery
from .signals import SignalField, SignalKind
from . import coordination as coord
from .telemetry import (AgentTransition, DamageApplied, FieldSample,
                        ImpulseApplied, InputRecord, PortalCrossing,
                        TopologyChanged, TraceBus)
from . import terrain

DT = 1.0 / 60.0
TICK_RATE = 60

GROUP_PLAYER = 0
GROUP_ENEMY = 1
GROUP_PBULLET = 2
GROUP_EBULLET = 3
GROUP_PICKUP = 4

ACTIVE_HOPS = 5

PLAYER_HP = 100
PLAYER_RADIUS = 6.5
PLAYER_ACCEL = 820.0
PLAYER_FRICTION = 5.6  # terminal speed ~133 u/s (discrete 60Hz tick)
PLAYER_MASS = 1.2

# name: (damage, cooldown_ticks, speed, spread_rad, pellets, ammo_type, ammo_per_shot, sound)
# `imp` is the weapon's knockback IMPULSE (J = m*dv, applied through the
# engine's apply_impulse — DESIGN_7_25: ALL weapons push, force through the
# physics, never a velocity write). Per-pellet for pellet weapons. First-pass
# values scaled so a pistol visibly arrests a husk's approach between shots.
WEAPONS: dict[str, dict] = {
    "knife": dict(dmg=9, cd=22, ammo=None, sound="knife_swing", range=27.0,
                  arc=math.radians(55), imp=420.0),
    "pistol": dict(dmg=12, cd=20, speed=1500.0, spread=math.radians(1.6), pellets=1,
                   ammo="9mm", per=1, sound="pistol_fire", kick=2.2, imp=260.0),
    "smg": dict(dmg=7, cd=6, speed=1350.0, spread=math.radians(5.5), pellets=1,
                ammo="9mm", per=1, sound="smg_fire", kick=1.6, imp=110.0),
    "shotgun": dict(dmg=6, cd=54, speed=1150.0, spread=math.radians(11.0), pellets=8,
                    ammo="shell", per=1, sound="shotgun_fire", kick=7.0, imp=90.0),
    "rail": dict(dmg=42, cd=84, ammo="cell", per=1, sound="rail_fire", pierce=3,
                 kick=5.0, imp=700.0),
    "lightning": dict(dmg=26, cd=None, speed=720.0, sound="lightning_fire",
                      radius=220.0, force=1500.0, arc_range=150.0,
                      arc_dmg=16, max_arcs=18, imp=1500.0),
    "tau": dict(dmg=9, cd=7, speed=1900.0, spread=math.radians(2.0), pellets=1,
                ammo="cell", per=1, sound="tau_fire", kick=2.6, bounces=2,
                imp=160.0),
    "hole": dict(cd=18, sound="terminal_open"),
}
WEAPON_ORDER = ["knife", "pistol", "smg", "shotgun", "rail", "lightning",
                "tau", "hole"]

# Every damaging player weapon pushes — validated at import so a new weapon
# without an impulse entry is a startup crash, not a silent exception to the
# canon ("hole" is the one non-damaging tool).
for _wname, _w in WEAPONS.items():
    if _wname != "hole":
        assert _w.get("imp", 0.0) > 0.0, f"weapon {_wname} has no impulse"

# Charged tau: full charge detonates on impact — a small AoE that damages
# and pushes. 84 max direct damage: two full-charge hits kill a 168 Warden.
TAU_AOE_RADIUS = 48.0
TAU_AOE_DMG = 42.0          # at the center of the burst, falls off linearly
TAU_AOE_IMP = 300.0
TAU_CHARGED_IMP = 400.0     # direct-hit impulse at full power, scales down
TAU_CHARGE_FULL = 80        # ticks of held charge for max damage
TAU_OVERCHARGE = 160        # holding past this hurts
HOLE_WIDTH = 15.0           # player diameter 13 + clearance; brutes (27) excluded
HOLE_RANGE = 160.0
HOLE_CORRIDOR_LEN = 36.0
LIGHTNING_RECHARGE_TICKS = 60 * 9

# Speed doctrine (Teleglitch): base walk slightly SLOWER than the player
# (discrete-tick terminal; player ~133 u/s) so spacing is a real skill; the
# husk/brute lunge is the burst that punishes carelessness. Mites nearly
# match player speed and win by numbers.
# Speed doctrine (DESIGN_7_25 combat canon, replacing the old Teleglitch
# spacing rule): EVERY kind is significantly faster than the un-upgraded
# Commando (~133 u/s terminal), heavier (mass > PLAYER_MASS 1.2), and turns
# worse (`turn` = max heading slew, rad/s — the Commando turns instantly).
# Escape is fighting them backward, not outrunning them; what the player
# buys with knockback is spacing, not distance. terminal = accel / fric,
# accel values set from MEASURED terminals (discrete-tick friction eats
# ~6-8%; see test_combat_canon's measurement vectors).
# First-pass ratios (warden 1.15x ... mite 1.55x) — tuning candidates.
ENEMIES: dict[str, dict] = {
    "husk": dict(hp=15, radius=8.0, mass=1.6, accel=567.0, fric=3.2, turn=5.0,
                 touch_dmg=12,
                 touch_cd=38, alert_snd="enemy_alert_husk", die_snd="enemy_die_husk",
                 score=1),
    "mite": dict(hp=4, radius=4.0, mass=1.4, accel=1012.0, fric=4.5, turn=7.0,
                 touch_dmg=4,
                 touch_cd=24, alert_snd="enemy_alert_mite", die_snd="enemy_die_mite",
                 score=1),
    "spitter": dict(hp=18, radius=9.0, mass=1.7, accel=653.0, fric=3.8, turn=4.5,
                    touch_dmg=8,
                    touch_cd=45, alert_snd="enemy_alert_husk", die_snd="enemy_die_husk",
                    spit_cd=95, spit_speed=380.0, spit_dmg=9, keep_min=110.0,
                    keep_max=190.0, score=2),
    "brute": dict(hp=65, radius=13.5, mass=7.0, accel=430.0, fric=2.6, turn=3.2,
                  touch_dmg=24,
                  touch_cd=55, alert_snd="enemy_alert_husk", die_snd="enemy_die_brute",
                  score=4),
    "shrieker": dict(hp=10, radius=7.0, mass=1.5, accel=701.0, fric=3.4, turn=6.0,
                     touch_dmg=0,
                     touch_cd=60, alert_snd="shrieker_scream", die_snd="enemy_die_mite",
                     scream_cd=60 * 5, score=3),
    # Warden = a normal high-tier enemy (DESIGN_7_25): 168 hp — dies to
    # exactly 2 full-charge Tau (84) or 4 rail (42); no brood, no enrage.
    "warden": dict(hp=168, radius=16.0, mass=12.0, accel=386.0, fric=2.4, turn=2.6,
                   touch_dmg=30,
                   touch_cd=48, alert_snd="shrieker_scream", die_snd="enemy_die_brute",
                   spit_cd=70, spit_speed=460.0, spit_dmg=13, keep_min=0.0,
                   keep_max=100.0, score=10),
    # Adversary-lane ambush predator (director's directive, 2026-07-13):
    # "add an enemy that deliberately keeps to the shadows until the
    # player gets close, then ambushes." Named for the sensor-trace
    # dramaturgy its own render channel implements (dim/intermittent
    # return while dormant, solid the instant it commits) rather than any
    # "shadow stalker" flavor label -- clinical/diegetic, matching the
    # existing husk/mite/spitter/brute/shrieker/warden naming register.
    # See `GameSession._flicker_ai` for the LURK/AMBUSH state machine.
    "flicker": dict(hp=22, radius=8.5, mass=1.5, accel=729.0, fric=3.4, turn=6.5,
                    touch_dmg=16, touch_cd=42, alert_snd="enemy_alert_husk",
                    die_snd="enemy_die_husk", score=3,
                    lurk_speed=95.0, ambush_radius=70.0, ambush_burst=560.0,
                    ambush_ticks=18, disengage_light=0.15, disengage_dist=220.0,
                    disengage_beat=90),
}

for _ename, _e in ENEMIES.items():
    assert _e["mass"] > PLAYER_MASS, f"{_ename} lighter than the Commando"
    assert _e["turn"] > 0.0, f"{_ename} has no turn-rate model"
assert ENEMIES["warden"]["hp"] == 168, "warden is a normal enemy: 2 charged tau / 4 rail"

PICKUPS: dict[str, dict] = {
    "ammo_9mm": dict(radius=5.0, amount=30),
    "ammo_shell": dict(radius=5.0, amount=7),
    "ammo_cell": dict(radius=5.0, amount=8),
    "medkit": dict(radius=6.0, amount=35),
    "weapon_smg": dict(radius=7.0),
    "weapon_shotgun": dict(radius=7.0),
    "weapon_rail": dict(radius=7.0),
    "weapon_tau": dict(radius=7.0),
    "portable_hole": dict(radius=6.0),
    "safe_polygon_core": dict(radius=7.0),
    "turret": dict(radius=6.0),
    "implant_lightning": dict(radius=7.0),
    "key_red": dict(radius=5.5), "key_blue": dict(radius=5.5),
    "key_gold": dict(radius=5.5), "key_void": dict(radius=5.5),
    "components": dict(radius=5.0),
    "corpse_frame": dict(radius=8.0),
}

# Friendly, stationary defensive emplacement (director's directive,
# 2026-07-13: "let's put friendly turrets in the safe-polygon corridors" --
# the calibration farm measured loot/rest polygons as the DEADLIEST zone
# class, 2.2x combat, because standard enemies have no de-aggro path and
# simply follow a hurt player to the medkits; see FITTING_REPORT.md
# finding #1). MIRIAD-lane defensive emplacement, clinical naming to match
# the enemy roster's own register (husk/mite/spitter/...). Pistol-class
# rate of fire and damage, finite range, requires LOS (same polygon + no
# walk-mask terrain crossing the shot -- see `_sentry_los_clear`), and a
# short spin-up before its first shot on a freshly acquired target rather
# than instant acquisition. No `hp` field: indestructible, matching the
# only existing "friendly turret" precedent in this codebase (the
# cloister's anti-looter guardians, `self.turrets` / `_turret_tick`
# below, also spawned GROUP_PICKUP with no hp) -- that group never
# collides with enemies or the player under this session's collision
# matrix (see __init__), so real destructibility would need a new
# collision pair PLUS teaching ranged enemies to target something other
# than the player, a much larger AI change this directive doesn't ask
# for. See `spawn_sentry` / `_sentry_tick`.
SENTRIES: dict[str, dict] = {
    # dmg/cd retuned 2026-07-16 (gauntlet III): a 3-gun choke field must
    # GRIND a pulled wave -- at 12dmg/20cd the field lost to one warden+
    # brute pack arriving together (measured -52hp/5s burst deaths at
    # the field in 16/20 calibration runs); the sentry hazard is the
    # director's intended player-buff lever ("environmental hazards ...
    # lure enemies to"), so the guns bite for real now
    "sentry": dict(radius=7.0, dmg=18, cd=14, range=300.0, spin_up=10,
                   bolt_speed=1400.0, alert_snd="pistol_fire"),
}

# DESIGN_7_25 §2: every placed building spends 30 seconds inert and fragile
# ("unpack") before it activates — you can't drop a turret into a swarm and
# have it fight. Consumed by the placement code and by the renderer's
# unpack-progress draw.
BUILDING_UNPACK_TICKS = 30 * 60

# DESIGN_7_25 §1b: an Adversary scout's rooted broadcast (lacuna 8s; the
# per-class split lands with the scout unit). The renderer reads this as the
# transmit-tell denominator when an enemy doesn't carry its own call_t.
CALL_TRANSMIT_TICKS = 8 * 60

# The fabricator's price sheet. Components are salvaged mass — every enemy
# yields its score in components (the same number the metrics already used,
# so salvage income equals fight difficulty by construction).
SHOP: dict[str, dict] = {
    "chassis": dict(cost=8, label="SPARE CHASSIS"),
    "station_kit": dict(cost=12, label="SEED STATION KIT"),
    "hp_up": dict(cost=10, label="HULL PLATING +15", growth=6),
    "recall": dict(cost=6, label="RECALL BEACON"),
    "ammo_9mm": dict(cost=3, label="9MM x30", ammo=("9mm", 30)),
    "ammo_shell": dict(cost=3, label="SHELLS x7", ammo=("shell", 7)),
    "ammo_cell": dict(cost=4, label="CELLS x8", ammo=("cell", 8)),
}

DROP_TABLES = {
    "husk": [(0.35, "ammo_9mm"), (0.08, "medkit")],
    "mite": [(0.04, "ammo_9mm")],
    "spitter": [(0.30, "ammo_shell"), (0.08, "medkit")],
    "brute": [(0.55, "ammo_cell"), (0.25, "medkit")],
    "shrieker": [(0.5, "ammo_9mm")],
    # the boss carries the spoils: a guaranteed cache ON the kill —
    # Sol 2 §6's encounter-clear recovery, attached to the victory
    # itself. Flight recorder: late deaths were wounded bots pinned
    # at boss doors with the map's medkits long consumed.
    "warden": [(1.0, "medkit"), (1.0, "ammo_9mm"), (1.0, "ammo_shell"),
               (0.5, "ammo_cell")],
    "flicker": [(0.4, "ammo_9mm"), (0.1, "medkit")],
}


@dataclass
class InputFrame:
    mx: float = 0.0  # screen-space move -1..1
    my: float = 0.0
    ax: float = 240.0  # aim, internal-screen pixels
    ay: float = 135.0
    fire: bool = False
    alt: bool = False
    interact: bool = False
    weapon: int = 0  # 0 = keep, 1..6 select WEAPON_ORDER[i-1]

    def pack(self) -> list:
        return [round(self.mx, 4), round(self.my, 4), round(self.ax, 2),
                round(self.ay, 2), int(self.fire), int(self.alt),
                int(self.interact), self.weapon]

    @staticmethod
    def unpack(row: list) -> "InputFrame":
        return InputFrame(row[0], row[1], row[2], row[3],
                          bool(row[4]), bool(row[5]), bool(row[6]), row[7])


class GameSession:
    def __init__(self, level: Level, seed: int = 0,
                 screen: tuple[int, int] = (480, 270), zoom: float = 1.35,
                 player_state: dict | None = None, difficulty: str = "normal"):
        self.level = level
        # Soft (otherworld) polygons deform level.polygon_verts in place via the
        # per-tick refresh; copy so a Level object reused across sessions
        # never inherits another session's deformations.
        level.polygon_verts = [list(map(tuple, vs)) for vs in level.polygon_verts]
        self.difficulty = difficulty
        self.player_resist = float((player_state or {}).get(
            "dmg_taken_mul", 1.0))
        self._hp_mul = 1.35 if difficulty == "hard" else 1.0
        self._dmg_mul = 1.25 if difficulty == "hard" else 1.0
        self.rng = Random(seed)
        self.seed = seed
        self.screen_w, self.screen_h = screen
        self.zoom = zoom
        self.tick_count = 0
        self.dead = False
        self.complete = False
        self.freeze = 0  # hitstop ticks

        # --- engine world ---
        s = necore.Sim()
        self.sim = s
        for verts in level.polygon_verts:
            s.add_polygon(verts)
        # Walk-mask terrain: painted-in equipment/machinery that blocks
        # movement and shots exactly like a wall. Loaded alongside the
        # floor texture (same directory, same polygon-local coordinate
        # mapping -- terrain.py), but the collision data itself flows
        # straight into the engine here, never through the renderer.
        # Absence of a mask file means fully walkable (no fabricated
        # terrain) -- see terrain.py's module docstring.
        terrain.apply_walk_masks(s, level)
        for a, ea, b, eb in level.connects:
            s.connect(a, ea, b, eb)
        for a, ea, b, eb, m9 in level.connects_x:
            s.connect_with_xform(a, ea, b, eb, m9)
        # collision matrix
        for g in range(5):
            for h in range(5):
                s.set_collision_pair(g, h, False)
        s.set_collision_pair(GROUP_PLAYER, GROUP_ENEMY, True)
        s.set_collision_pair(GROUP_ENEMY, GROUP_ENEMY, True)
        s.set_collision_pair(GROUP_PBULLET, GROUP_ENEMY, True)
        s.set_collision_pair(GROUP_EBULLET, GROUP_PLAYER, True)
        # your own rounds CAN come back: mirrors and ricochets are honest
        s.set_collision_pair(GROUP_PBULLET, GROUP_PLAYER, True)

        # --- lighting: world lights, cast via the visibility engine itself
        # (portals wired above, so static caches see the real chain).
        # The player's FRAME carries an attached work lamp THROUGH the same
        # system, so their own illumination occludes properly (light
        # stops at walls / spills through doorways) rather than being a
        # screen-space disc. Zero ambient (the director's order): unless a
        # level places a specific fixture, this lamp is the ONLY light
        # that always exists. Intensity/radius tuned as the SOLE source of
        # illumination, not an addition on top of a screen-space ambient
        # field -- the old 0.22/64 pair was calibrated for the latter and
        # left the player's own pool nearly invisible once ambient was
        # removed.
        self.lighting = LightingSystem(s, level)
        from .levels import LightSpec as _LightSpec
        # the flashlight proper: a directional cone along the aim
        # (COMBAT_REDESIGN §10 — directional lights; "the player's
        # flashlight needs to reach further")
        self.player_light = _LightSpec(
            polygon=level.player_polygon, pos=tuple(level.player_pos),
            color=(255, 226, 188), intensity=1.0, radius=230.0,
            kind="attached", dir=(1.0, 0.0), arc=1.15)
        self.lighting.lights.append(self.player_light)
        # ...plus the close work-lamp pool so the frame itself is never
        # standing in its own darkness
        # radius 70 -> 88 (2026-07-21): four independent frame reviews of
        # the gauntlet footage flagged long stretches where nothing but the
        # player was legible. The flashlight covers where you AIM; this
        # pool covers where you ARE, and at 70u it was smaller than the
        # player's own reach. The level's authored darkness is untouched —
        # this only fills the ring you are standing in.
        self.player_lamp = _LightSpec(
            polygon=level.player_polygon, pos=tuple(level.player_pos),
            color=(255, 226, 188), intensity=0.64, radius=88.0,
            kind="attached")
        self.lighting.lights.append(self.player_lamp)
        # muzzle flash as a REAL light: re-lit on every shot, decaying
        # over ~5 ticks (see _fire / tick). OMNIDIRECTIONAL and room-sized
        # (director 2026-07-22: "it should light up the whole room") — the
        # old narrow cone (arc 1.9, radius 150) left the room mostly dark
        # while a fake per-room glow disc did the visible flashing, and
        # that disc was clipped to the firing room, which is exactly the
        # seam at every portal the director kept seeing.
        self.muzzle_light = _LightSpec(
            polygon=level.player_polygon, pos=tuple(level.player_pos),
            color=(255, 214, 150), intensity=0.0, radius=320.0,
            kind="attached")
        self.lighting.lights.append(self.muzzle_light)
        # transient PULSE lights (tau discharge, sentry muzzles, wall
        # breaches, the reprint pad): the same idea as the muzzle light, a
        # small round-robin pool of real attached lights that flare and
        # decay. Real lights propagate through portals along occlusion
        # wedges like every other light; the per-room glow discs they
        # replace ended in a hard bright edge at the first portal.
        self._pulse_lights = [
            _LightSpec(polygon=level.player_polygon,
                       pos=tuple(level.player_pos),
                       color=(255, 214, 150), intensity=0.0, radius=200.0,
                       kind="attached")
            for _ in range(4)]
        self.lighting.lights.extend(self._pulse_lights)
        self._pulse_at = 0

        # --- doors (pending connections) ---
        self.doors: list[dict] = []
        self.door_edges: dict[tuple[int, int], str] = {}
        for d in level.doors:
            meta = level.key_meta.get(d.key)
            rec = dict(a=d.a, ea=d.ea, b=d.b, eb=d.eb, key=d.key, open=False,
                       gate_prompt=meta.gate_prompt if meta else "")
            self.doors.append(rec)
            self.door_edges[(d.a, d.ea)] = d.key
            self.door_edges[(d.b, d.eb)] = d.key
        self._door_prompt_at: dict[str, int] = {}  # key id -> last prompt tick
        # the exit's blocked prompt, from this level's key metadata (the
        # streamer re-points this at the final chunk's metadata)
        exit_meta = level.key_meta.get(level.exit_key) if level.exit_key else None
        self.exit_gate_prompt = exit_meta.gate_prompt if exit_meta else ""

        # --- player ---
        st = player_state or {}
        self.pid = s.spawn(level.player_polygon, *level.player_pos,
                           PLAYER_RADIUS, PLAYER_MASS, GROUP_PLAYER)
        s.set_props(self.pid, rest_wall=0.0, rest_ent=0.05, max_substep=6.0)
        self.max_hp = int(st.get("max_hp", PLAYER_HP))
        self.hp = st.get("hp", self.max_hp)
        self.ammo = dict(st.get("ammo", {"9mm": 48, "shell": 0, "cell": 0}))
        self.weapons = list(st.get("weapons", ["knife", "pistol"]))
        # --- the revival economy (design doc 9.1/9.3) ---
        # components: salvaged mass, the one currency. chassis: hulls
        # fabricated in advance; dying with one racked reprints you at the
        # nearest seed station with the world left as it lies (your wreck
        # included). With none racked, the seed cold-restores the chunk
        # (streamer respawn) -- the pre-economy behavior, so bots and
        # difficulty gates see an unchanged baseline.
        self.components = int(st.get("components", 0))
        self.chassis = int(st.get("chassis", 0))
        self.station_kits = int(st.get("station_kits", 0))
        self.hp_ups = int(st.get("hp_ups", 0))
        # the mind map (9.2): integrated concept-node ids; faith is computed
        # from the investment pattern, never displayed as a meter
        self.mind: set[str] = set(st.get("mind", []))
        # thinking-as-time (SEEDPOD_UI_DESIGN.md): the ONE focus node the
        # Commando ruminates on in the field; per-node accrued ticks
        # (switching focus never loses thought); and the queue of finished
        # thoughts awaiting their unfolding reveal at the pod. All three
        # survive death, chassis reprint, and cold restore -- the mind
        # survives the body by construction. Dying costs loot, never thought.
        self.think_focus: str | None = st.get("think_focus")
        self.think_progress: dict[str, int] = {
            k: int(v) for k, v in dict(st.get("think_progress", {})).items()}
        self.think_done: list[str] = list(st.get("think_done", []))
        self._recompute_mind()
        # recall beacons: emergency teleport home -- a 90-tick channel that
        # any hit severs (an escape you must earn a quiet moment for)
        self.recalls = int(st.get("recalls", 0))
        self.recall_t = 0
        self.stations: list[dict] = []  # {polygon, pos}: planted + chunk seeds
        # the seed you just printed from is a station by definition (the
        # streamer's chunk-entry add_station dedupes against this one)
        self.add_station(level.player_polygon, level.player_pos)
        self.keys: set[str] = set()
        # key id -> KeyMeta of the object actually picked up (for HUD/world
        # glyphs); intersect with self.keys — the streamer clears keys on
        # zone crossings without touching this
        self.held_key_meta: dict = {}
        # Otherworld: polygons whose walls are soft (mass-spring vertices).
        self.soft_polygons: set[int] = set()
        for i, k in enumerate(level.polygon_kinds):
            if k == "otherworld":
                self.sim.soften_polygon(i)
                self.soft_polygons.add(i)
        self.weapon = st.get("weapon", "pistol")
        if self.weapon not in self.weapons:
            self.weapon = self.weapons[-1]
        self.lightning_charge = LIGHTNING_RECHARGE_TICKS  # full
        self.cooldown = 0
        self.hurt_cd = 0
        self.aim = (1.0, 0.0)
        self.holes = int(st.get("holes", 0))
        self.hole_mark: tuple | None = None  # (polygon, edge, t0, t1, x, y)
        self.tau_charge = 0
        self.cloister: dict | None = None  # {sanctum, corridor, links, attached}
        self.turrets: dict[int, dict] = {}
        # Data-driven defensive emplacements (SENTRIES), placed by level
        # JSON (e.g. levels/gauntlet_cal.json's loot polygons) -- distinct
        # container/tick from the cloister's `self.turrets` above; see the
        # comment on `SENTRIES` and `_sentry_tick`.
        self.sentries: dict[int, dict] = {}

        # --- camera: player-polygon local -> internal screen ---
        px, py = level.player_pos
        self._set_cam(necore.mat_mul(
            necore.mat_mul(necore.mat_translate(self.screen_w / 2, self.screen_h / 2),
                           necore.mat_scale(zoom, zoom)),
            necore.mat_translate(-px, -py)))

        # --- scripted/world objects ---
        # per-tick light-map cache for flicker (Adversary-lane lurker) AI
        # queries only -- see `_polygon_light_map`; never populated (and
        # never costs anything) for a session with no flicker enemies.
        self._light_map_tick = -1
        self._light_map_cache: dict = {}
        self.enemies: dict[int, dict] = {}
        self.bullets: dict[int, dict] = {}
        self.pickups: dict[int, dict] = {}
        self.terminals: list[dict] = [
            dict(polygon=t.polygon, pos=t.pos, text=t.text, read=False)
            for t in level.terminals
        ]
        for polygon, spec in level.entities:
            self._spawn_from_spec(polygon, spec)

        self.exit_polygon = level.exit_polygon
        self.exit_pos = level.exit_pos
        if st.get("cloister"):
            self._build_cloister()

        # --- output channels ---
        self.fx: list[tuple] = []  # drained by app each tick
        self._oob_fx: list[tuple] = []  # menu-time events; join next tick
        # the instrumentation spine: always present, emit-only from the
        # sim's side; app/harness drain it to JSONL (see telemetry.py)
        self.trace = TraceBus()
        # the shared find/senses infrastructure (DESIGN_7_25): every
        # "what can I see from here?" goes through this one query object
        self.senses = SenseQuery(self.sim, self._describe_entity)
        # the nine-field signal substrate — the shared medium the whole
        # Adversary coordinates through. Always on; every world has one.
        self.signals = SignalField(self.sim, tick=0)
        self.decals: dict[int, list] = {}  # polygon -> [(kind,x,y,size,angle)]
        self._objective_fired: set[str] = set()  # once-gates for objective fx
        self.metrics = dict(ticks=0, shots=0, hits=0, kills=0, dmg_dealt=0.0,
                            dmg_taken=0.0, pickups=0, transfers=0, deaths=0,
                            polygons_visited={level.player_polygon}, hp_series=[],
                            completed=False)

    # ------------------------------------------------------------------
    # spawning
    # ------------------------------------------------------------------

    def _spawn_from_spec(self, polygon: int, spec, key_meta=None) -> None:
        """`key_meta` is the key-id -> KeyMeta table of the LEVEL this spec
        came from — the streamer passes each chunk's own table because
        `self.level` is chunk 0's and key ids mean different objects on
        different decks. None = use this session's level."""
        t = spec.type
        if t in ENEMIES:
            eid = self.spawn_enemy(polygon, spec.pos, t)
            if "hp" in spec.props:
                self.enemies[eid]["hp"] = float(spec.props["hp"]) * self._hp_mul
            if spec.props.get("tether"):
                self.enemies[eid]["tether"] = True
        elif t in SENTRIES:
            self.spawn_sentry(polygon, spec.pos, t)
        elif t in PICKUPS:
            meta = None
            if t.startswith("key_"):
                table = key_meta if key_meta is not None else self.level.key_meta
                meta = table.get(t[4:])
            self.spawn_pickup(polygon, spec.pos, t, meta)
        elif t == "player":
            pass  # player spawn handled by level.player
        else:
            raise ValueError(f"unknown entity type {t!r} in level")

    def spawn_enemy(self, polygon: int, pos, kind: str) -> int:
        d = ENEMIES[kind]
        eid = self.sim.spawn(polygon, pos[0], pos[1], d["radius"], d["mass"], GROUP_ENEMY)
        self.sim.set_props(eid, rest_wall=0.0, rest_ent=0.2, max_substep=8.0)
        # A flicker's resting behavior IS lurking (not idle-until-noticed
        # like the standard state machine) -- it never uses idle/waking,
        # see `_flicker_ai`.
        state = "lurk" if kind == "flicker" else "idle"
        self.enemies[eid] = dict(kind=kind, hp=d["hp"] * self._hp_mul, state=state,
                                 touch_cd=0, spit_cd=0, scream_cd=0,
                                 wander_cd=0, buff=0, trace_intensity=1.0,
                                 # per-agent quorum threshold, sampled ONCE
                                 # at spawn (killing habitual low-threshold
                                 # initiators thins future cascades), and
                                 # the raid-fan coin (~1/3 take route B)
                                 q_thr=self.rng.uniform(*coord.QUORUM_THRESHOLD_BAND),
                                 raid=self.rng.random() < coord.RAID_FRACTION)
        return eid

    def spawn_pickup(self, polygon: int, pos, kind: str, meta=None,
                     extra: dict | None = None) -> int:
        d = PICKUPS[kind]
        eid = self.sim.spawn(polygon, pos[0], pos[1], d["radius"], 100.0, GROUP_PICKUP)
        self.sim.set_props(eid, transfers=False)
        rec = dict(kind=kind)
        if meta is not None:
            rec["meta"] = meta  # KeyMeta: the object this key id is here
        if extra:
            rec.update(extra)
        self.pickups[eid] = rec
        return eid

    def douse_player_lights(self) -> None:
        """Master off-switch for the player's whole light rig
        (flashlight cone + work lamp + muzzle flash) — the single
        hook tests and dark-scene tooling use; poking one spec is no
        longer enough now the rig is three lights."""
        self.player_light.intensity = 0.0
        self.player_lamp.intensity = 0.0
        self.muzzle_light.intensity = 0.0
        for _pl in self._pulse_lights:
            _pl.intensity = 0.0
        self._lights_doused = True

    def pulse_light(self, polygon: int, pos, radius: float,
                    intensity: float, color=(255, 214, 150)) -> None:
        """Flare one of the transient pulse lights (tau discharge, sentry
        muzzle, wall breach, reprint pad) at `pos`, decaying like the
        muzzle flash (~5 ticks, see tick()). These are REAL lights: their
        burst crosses portals through occlusion wedges like every other
        light, which is the whole point — the per-room glow discs they
        replaced ended in a hard bright edge at the first portal
        (director 2026-07-22: "muzzle flash causes room seams — rework it
        to use the actual lighting system")."""
        if getattr(self, "_lights_doused", False):
            return
        pl = self._pulse_lights[self._pulse_at]
        self._pulse_at = (self._pulse_at + 1) % len(self._pulse_lights)
        pl.polygon = polygon
        pl.pos = (pos[0], pos[1])
        pl.color = color
        pl.radius = radius
        pl.intensity = intensity

    def spawn_sentry(self, polygon: int, pos, kind: str = "sentry") -> int:
        d = SENTRIES[kind]
        eid = self.sim.spawn(polygon, pos[0], pos[1], d["radius"], 100.0, GROUP_PICKUP)
        self.sim.set_props(eid, transfers=False)
        self.sentries[eid] = dict(kind=kind, cd=0, spin=d["spin_up"])
        return eid

    # ------------------------------------------------------------------
    # helpers
    # ------------------------------------------------------------------

    def _snd(self, name: str, polygon: int, pos, vol: float = 1.0):
        self.fx.append(("sound", name, polygon, pos[0], pos[1], vol))

    def _shake(self, mag: float):
        self.fx.append(("shake", mag))

    def _hitstop(self, ticks: int):
        self.freeze = max(self.freeze, ticks)

    def _decal(self, polygon: int, kind: str, x: float, y: float,
               size: float, angle: float = 0.0):
        lst = self.decals.setdefault(polygon, [])
        lst.append((kind, x, y, size, angle))
        if len(lst) > 250:
            del lst[0: len(lst) - 250]

    # Spoken narrative lives ONLY where the player is safe and reading:
    # relay conversations (convscene) and wall terminals. Authored
    # level.radio triggers remain valid data (the authoring/editor API is
    # intact) but the game consumes them as nothing. The one in-combat text
    # channel is the ("objective", text) fx: a one-line ALL-CAPS functional
    # system prompt.

    ACQUIRE_LABELS = {"cloister": "THE CLOISTER", "hole": "PORTABLE HOLE",
                      "lightning": "LIGHTNING IMPLANT", "tau": "TAU CANNON"}

    def _objective(self, text: str):
        self.fx.append(("objective", text))

    def _acquired(self, item: str):
        self._objective(
            f"ACQUIRED: {self.ACQUIRE_LABELS.get(item, item.upper())}")

    def _set_cam(self, m) -> None:
        """HARD camera reset -- spawn, seed-recall, chassis-reprint. Not
        used for the ordinary per-tick follow or the portal re-base; see
        `_cam_step_follow` and `_cam_rebase` for those.

        `_cam_smooth` keeps the exact float matrix (nothing ever
        integrates on the rendered copy). The rendered `cam` snaps its
        translation to whole internal pixels: unsnapped, sub-pixel
        camera dither (the exponential follow oscillating against
        collision push-out) flips every 1-px prop outline between pixel
        rows frame to frame -- world-wide decor flicker, the
        campaign-video finding. Because this is a hard cut (no prior
        rendered frame to stay continuous with), snapping fresh here is
        fine.

        NOTE: this per-call independent re-round is exactly what used to
        also run at every portal transfer, and *that* was the bug --
        re-rounding a re-based translation can disagree with the
        previous frame's rounding by up to 0.5 rendered px, stepping the
        whole frame by a HALF-pixel for one tick (every 1px seam/grate
        line in view re-rasterizes, then snaps back). Transfers now go
        through `_cam_rebase`, which never re-rounds."""
        self._cam_smooth = m
        mm = list(m)
        mm[2] = float(round(mm[2]))
        mm[5] = float(round(mm[5]))
        self.cam = tuple(mm)

    def _cam_step_follow(self, smooth_new) -> None:
        """Ordinary per-tick camera update. Advances the rendered `cam`
        toward `smooth_new` by an INTEGER screen-pixel translation step:
        round of the whole un-stepped screen-space error
        (t_smooth - t_cam) -- a stateful integer-stepping follower, not
        a per-tick re-derivation from absolute position. The sub-pixel
        remainder needs no separate accumulator: `cam` itself carries
        it (the error left after a step is <= 0.5px and is re-measured
        against the live matrices next tick, so it self-corrects). An
        explicit remainder accumulator ADDED to this error would count
        the same lag twice and turn smooth-camera micro-oscillation
        into a visible +/-1px per-tick dither -- verified empirically
        on seed-7 l01 ticks 215-227 during the fix.

        This makes the pixel snap base-independent: every consecutive-
        tick screen delta of `cam` is a whole-pixel translation,
        transfer ticks included (see `_cam_rebase`), so there is no
        tick at which the rendered mapping can step by a fractional
        pixel. `cam`'s linear (rotation/zoom) part always equals
        `_cam_smooth`'s -- only translation is ever stepped
        independently, only in whole pixels, and
        |t_cam - t_smooth| <= 0.5px holds after every follow step."""
        stx = float(round(smooth_new[2] - self.cam[2]))
        sty = float(round(smooth_new[5] - self.cam[5]))
        self.cam = necore.mat_mul(necore.mat_translate(stx, sty), self.cam)
        self._cam_smooth = smooth_new

    def _cam_rebase(self, m9) -> None:
        """Portal re-base: re-express BOTH camera matrices in the new
        polygon's local frame by right-multiplying with inv(m9). This is
        exact on the composed world->screen mapping -- true "zero
        visible change by construction", unlike re-snapping the
        rendered copy independently (the root cause this replaces: a
        zoom-scaled world offset carried a fractional part through the
        old rounding, disagreeing with the previous frame's rounding by
        up to 0.5px for exactly one tick).

        The rendered-vs-smooth sub-pixel lag carries across exactly,
        not approximately: for two matrices sharing a linear part L
        with translations t1, t2, right-multiplying both by the same
        B=(Lb,tb) gives translations L*tb+t1 and L*tb+t2 -- their
        difference t1-t2 is unchanged by the multiplication. `cam` and
        `_cam_smooth` always share a linear part (only
        `_cam_step_follow`'s whole-pixel steps and this rebase ever
        touch either matrix, and both keep the linear parts equal by
        construction), so the lag `_cam_step_follow` measures next tick
        survives the rebase with no correction needed -- even through a
        rotating portal."""
        inv9 = necore.mat_inv(m9)
        self._cam_smooth = necore.mat_mul(self._cam_smooth, inv9)
        self.cam = necore.mat_mul(self.cam, inv9)

    def player_pos(self):
        _, px, py, *_ = self.sim.get(self.pid)
        return px, py

    def player_polygon(self) -> int:
        return self.sim.get_polygon(self.pid)

    WAKE_TICKS = {"husk": 32, "mite": 18, "spitter": 26, "brute": 45,
                  "shrieker": 12, "warden": 20}

    # ------------------------------------------------------------------
    # the tick
    # ------------------------------------------------------------------

    def tick(self, inp: InputFrame) -> None:
        # fx contract: cleared here every tick (headless harnesses never
        # drain); events emitted OUTSIDE the tick (fabricator buys, chassis
        # reprint, kit planting -- all menu-time calls) are parked in
        # _oob_fx and delivered with the next tick instead of being wiped
        self.fx = self._oob_fx
        self._oob_fx = []
        self.tick_count += 1
        self.metrics["ticks"] = self.tick_count
        self.trace.emit(InputRecord(
            tick=self.tick_count, mx=round(inp.mx, 4), my=round(inp.my, 4),
            ax=round(inp.ax, 2), ay=round(inp.ay, 2), fire=bool(inp.fire),
            alt=bool(inp.alt), interact=bool(inp.interact),
            weapon=int(inp.weapon)))
        if self.tick_count % 15 == 0 and self.sim.exists(self.pid):
            px_s, py_s = self.player_pos()
            m = self.metrics
            self.trace.sample(self.tick_count, dict(
                hp=round(self.hp, 1), polygon=self.player_polygon(),
                pos=[round(px_s, 1), round(py_s, 1)], weapon=self.weapon,
                kills=m["kills"], deaths=m["deaths"],
                dmg_taken=round(m["dmg_taken"], 1), ammo=dict(self.ammo)))
        # the signal medium: spread on its fixed cadence; the intruder's
        # passage re-arms the Trail scent in his chamber; every agent
        # thickens Kin where it stands (the underdefended-ground gradient)
        self.signals.step_to(self.tick_count)
        if not self.dead and self.sim.exists(self.pid):
            if self.tick_count % 5 == 0:
                self.signals.emit_at_least(SignalKind.TRAIL,
                                           self.player_polygon(), 0.80,
                                           self.tick_count)
        if self.tick_count % 15 == 0:
            for _eid in self.enemies:
                self.signals.emit(SignalKind.KIN,
                                  self.sim.get_polygon(_eid), 0.011,
                                  self.tick_count)
        if self.tick_count % 60 == 0:
            _t = self.tick_count
            _pp = self.player_polygon() if self.sim.exists(self.pid) else -1
            self.trace.emit(FieldSample(
                tick=_t,
                totals={k.value: round(self.signals.total(k, _t), 4)
                        for k in SignalKind},
                player_polygon=_pp,
                player_own={} if _pp < 0 else
                {k.value: round(self.signals.sample(k, _pp, _t), 4)
                 for k in SignalKind}))
        if self.tick_count % 60 == 0:
            self.metrics["hp_series"].append(self.hp)
        if self.dead or self.complete:
            return
        if self.freeze > 0:
            self.freeze -= 1
            return

        s = self.sim
        ppolygon = self.player_polygon()
        s.set_active_within(ppolygon, ACTIVE_HOPS)

        if self.soft_polygons:
            rv = self.level.polygon_verts
            for r_ in self.soft_polygons:
                if r_ < len(rv):
                    rv[r_] = self.sim.polygon_verts(r_)
        if self.tick_count % 30 == 0:
            self._containment_sweep(ppolygon)
        self._recall_tick(ppolygon)
        if self._regen_rate and self.tick_count % 60 == 0:
            # grafted Adversary organs knit the hull -- up to a fraction of
            # max only; flesh does not respect fabrication tolerances
            cap = self.max_hp * self._regen_cap_frac
            if self.hp < cap:
                self.hp = min(cap, self.hp + self._regen_rate)

        self._think_tick(ppolygon)
        self._player_control(inp, ppolygon)
        self._enemy_ai(ppolygon)

        # friction (artistic, so it lives here not in the engine)
        self._apply_friction(self.pid, PLAYER_FRICTION)
        for eid, e in self.enemies.items():
            self._apply_friction(eid, ENEMIES[e["kind"]]["fric"])

        events = s.step(DT)
        self._consume_events(events)
        self.sweep_bullets()

        self._turret_tick()
        self._sentry_tick()
        if self.muzzle_light.intensity > 0.0:
            self.muzzle_light.intensity = (
                0.0 if self.muzzle_light.intensity < 0.06
                else self.muzzle_light.intensity * 0.68)
        for _pl in self._pulse_lights:
            if _pl.intensity > 0.0:
                _pl.intensity = (0.0 if _pl.intensity < 0.06
                                 else _pl.intensity * 0.68)
        if self.dead:
            # death landed mid-tick (contact/spit during the event sweep):
            # a dead frame reads no terminals, opens no shops, exits no
            # levels, and -- critically -- does not scoop its own corpse
            # in the tick that dropped it
            return
        self._pickup_scan(ppolygon)
        self._terminal_scan(ppolygon, inp)
        self._station_scan(ppolygon, inp)
        self._exit_scan(ppolygon)

        if self.cooldown > 0:
            self.cooldown -= 1
        if self.hurt_cd > 0:
            self.hurt_cd -= 1
        self.lightning_charge = min(LIGHTNING_RECHARGE_TICKS, self.lightning_charge + 1)

        # camera follow (after physics; transfers already re-based the
        # matrix via _cam_rebase). Integrates on the SMOOTH matrix; the
        # rendered cam is stepped toward it by whole pixels only, see
        # _cam_step_follow.
        px2, py2 = self.player_pos()
        spx, spy = necore.mat_apply(self._cam_smooth, px2, py2)
        k = min(1.0, 7.0 * DT)
        smooth_new = necore.mat_mul(
            necore.mat_translate((self.screen_w / 2 - spx) * k,
                                 (self.screen_h / 2 - spy) * k),
            self._cam_smooth)
        self._cam_step_follow(smooth_new)

    # ------------------------------------------------------------------

    def _apply_friction(self, eid: int, fric: float):
        try:
            _, _, _, vx, vy, _, _ = self.sim.get(eid)
        except Exception:
            return
        f = max(0.0, 1.0 - fric * DT)
        self.sim.set_vel(eid, vx * f, vy * f)

    def _player_control(self, inp: InputFrame, ppolygon: int):
        s = self.sim
        # weapon select
        if 1 <= inp.weapon <= len(WEAPON_ORDER):
            w = WEAPON_ORDER[inp.weapon - 1]
            if w in self.weapons:
                self.weapon = w
        # aim: maps through the SMOOTH camera, not the whole-pixel
        # rendered one. Historically this used `self.cam` (the snapped
        # copy), which coupled gameplay to render-side rounding; the
        # 2026-07-12 half-pixel-transfer fix switched it to the exact
        # matrix so the sim's evolution, given the same InputFrame
        # stream, is independent of how `cam` snaps. This is a one-time
        # sub-pixel behavior change: seeded bot recordings made before
        # the fix diverge from re-runs (seed-7 l01 first sfx-event delta
        # at ~t=7.4s) -- accepted, since replays store InputFrames and
        # re-derive everything, and no golden replay fixtures exist
        # in-tree. (Bots also read `session.cam` when composing inputs,
        # so seeded bot runs would have shifted under any camera change
        # regardless of this choice.)
        inv = necore.mat_inv(self._cam_smooth)
        awx, awy = necore.mat_apply(inv, inp.ax, inp.ay)
        _, px, py, vx, vy, _, _ = s.get(self.pid)
        dx, dy = awx - px, awy - py
        dl = math.hypot(dx, dy)
        if dl > 1e-6:
            s.set_dir(self.pid, dx / dl, dy / dl)
            self.aim = (dx / dl, dy / dl)
        else:
            self.aim = s.get(self.pid)[5:7]
        # move (screen-space -> polygon-space through inverse camera rotation)
        mlen = math.hypot(inp.mx, inp.my)
        if mlen > 1e-6:
            mlen = min(1.0, mlen)
            mdx, mdy = necore.mat_apply_dir(inv, inp.mx, inp.my)
            ml = math.hypot(mdx, mdy)
            if ml > 1e-9:
                ax_, ay_ = mdx / ml * mlen, mdy / ml * mlen
                s.set_vel(self.pid, vx + ax_ * PLAYER_ACCEL * self._accel_mul * DT,
                          vy + ay_ * PLAYER_ACCEL * self._accel_mul * DT)
        # fire
        if inp.fire and self.cooldown <= 0:
            self.last_fire_tick = self.tick_count
            self._fire(ppolygon, px, py)
        # alt: tau charge when tau is in hand, lightning implant otherwise
        if self.weapon == "tau" and "tau" in self.weapons:
            if inp.alt and self.ammo.get("cell", 0) > 0:
                self.tau_charge += 1
                if self.tau_charge == 1:
                    self._snd("tau_charge", ppolygon, (px, py), 0.8)
                if self.tau_charge > TAU_OVERCHARGE:
                    self._damage_player(12, ppolygon, source="tau_overcharge")
                    self._snd("tau_overcharge_hurt", ppolygon, (px, py))
                    self.tau_charge = 0
            elif self.tau_charge > 0:
                self._fire_tau_charged(ppolygon, px, py)
                self.tau_charge = 0
        elif inp.alt and self.lightning_charge >= LIGHTNING_RECHARGE_TICKS \
                and "lightning" in self.weapons:
            self._fire_lightning(ppolygon, px, py)

    def _fire(self, ppolygon: int, px: float, py: float):
        w = WEAPONS[self.weapon]
        adx, ady = self.aim
        if self.weapon == "lightning":
            # the implant fires the same whether triggered or selected
            self.cooldown = 18
            if self.lightning_charge >= LIGHTNING_RECHARGE_TICKS:
                self._fire_lightning(ppolygon, px, py)
            else:
                self._snd("dry_click", ppolygon, (px, py))
            return
        if self.weapon == "hole":
            self.cooldown = w["cd"]
            self._hole_shot(ppolygon, px, py, adx, ady)
            return
        if self.weapon == "knife":
            self.cooldown = w["cd"]
            self._snd("knife_swing", ppolygon, (px, py))
            self.metrics["shots"] += 1
            hit_any = False
            for eid in list(self.sim.polygon_entities(ppolygon)):
                e = self.enemies.get(eid)
                if not e:
                    continue
                _, ex, ey, *_ = self.sim.get(eid)
                ddx, ddy = ex - px, ey - py
                dist = math.hypot(ddx, ddy)
                reach = w["range"] + self.sim.get_radius(eid)
                if dist < 1e-6 or dist > reach:
                    continue
                ang = math.atan2(ddy, ddx) - math.atan2(ady, adx)
                ang = (ang + math.pi) % (2 * math.pi) - math.pi
                if abs(ang) <= w["arc"]:
                    self._damage_enemy(eid, w["dmg"], (ddx / dist, ddy / dist),
                                       w["imp"], source="knife")
                    hit_any = True
            if hit_any:
                self._snd("knife_hit", ppolygon, (px, py))
                self._shake(1.5)
            return
        ammo_t = w.get("ammo")
        if ammo_t and self.ammo.get(ammo_t, 0) < w.get("per", 1):
            self.cooldown = 18
            self._snd("dry_click", ppolygon, (px, py))
            return
        elif ammo_t:
            self.ammo[ammo_t] -= w.get("per", 1)
        self.cooldown = w["cd"]
        self.metrics["shots"] += 1
        self._snd(w["sound"], ppolygon, (px, py))
        self._shake(w.get("kick", 2.0))
        # MUZZLE CLAMP (2026-07-19, ground-truth trace): firing within
        # muzzle length of a portal plane (or wall) put the spawn
        # point OUTSIDE the polygon polygon; penetration resolution then
        # shoved the fresh round back inside — into the shooter
        # (spawn-tick self-hits measured at ~40% of all player damage
        # taken, misattributed for a day to fold returns). Clamp the
        # muzzle inside the polygon like the camera apex; the round
        # then crosses the portal by flying, as physics intends.
        mx_, my_ = self._clamp_apex(
            ppolygon, px + adx * (PLAYER_RADIUS + 5),
            py + ady * (PLAYER_RADIUS + 5))
        # the flash IS a light and nothing else (COMBAT_REDESIGN §10),
        # decaying over ~5 ticks (see tick())
        if not getattr(self, "_lights_doused", False):
            self.muzzle_light.polygon = ppolygon
            self.muzzle_light.pos = (mx_, my_)
            self.muzzle_light.intensity = 1.35
        if self.weapon == "rail":
            self._fire_rail(ppolygon, px, py, adx, ady)
        else:
            _, _, _, pvx, pvy, _, _ = self.sim.get(self.pid)
            for _ in range(w.get("pellets", 1)):
                ang = math.atan2(ady, adx) + self.rng.uniform(
                    -w["spread"], w["spread"]) * self._spread_mul
                spd = w["speed"] * self.rng.uniform(0.95, 1.05)
                bid = self.sim.spawn(ppolygon, mx_, my_, 1.6, 0.002, GROUP_PBULLET)
                self.sim.set_props(bid, rest_wall=0.0, rest_ent=0.0, max_substep=3.2)
                self.sim.set_vel(bid, math.cos(ang) * spd + pvx * 0.4,
                                 math.sin(ang) * spd + pvy * 0.4)
                self.sim.set_dir(bid, math.cos(ang), math.sin(ang))
                self.bullets[bid] = dict(kind="bullet", dmg=w["dmg"], ttl=90,
                                         imp=w["imp"], born=self.tick_count)
                if self.weapon == "tau":
                    self.bullets[bid].update(kind="tau", ttl=140,
                                             bounces=w.get("bounces", 0))
                    self.sim.set_props(bid, rest_wall=1.0)
        # gunfire is loud: the Noise field IS the alert — it spreads
        # hop-by-hop and the quorum rule decides who commits
        self.signals.emit(SignalKind.NOISE, ppolygon, 0.8, self.tick_count)

    def _fire_rail(self, ppolygon, px, py, adx, ady):
        ox, oy, polygon = px + adx * (PLAYER_RADIUS + 3), py + ady * (PLAYER_RADIUS + 3), ppolygon
        dx, dy = adx, ady
        ignore = self.pid
        w = WEAPONS["rail"]
        for _ in range(w["pierce"]):
            hit = self.sim.raycast(polygon, ox, oy, dx, dy, 8, 2000.0,
                                   1 << GROUP_ENEMY, ignore)
            kind = hit[0]
            if kind == "ent":
                _, eid, hpolygon, hx, hy, dist, hops, m9 = hit
                self._damage_enemy(eid, w["dmg"], (dx, dy), w["imp"], source="rail")
                r = self.sim.get_radius(eid) if self.sim.exists(eid) else 8.0
                ox, oy, polygon, ignore = hx + dx * (2 * r + 1.0), hy + dy * (2 * r + 1.0), hpolygon, eid
            else:
                if kind == "wall":
                    _, hpolygon, hedge, hx, hy, dist, hops, m9 = hit
                    self._decal(hpolygon, "scorch", hx, hy, 4.0)
                break
        # visual tracer that flies the same path
        bid = self.sim.spawn(ppolygon, px + adx * (PLAYER_RADIUS + 3),
                             py + ady * (PLAYER_RADIUS + 3), 1.2, 0.0005, GROUP_PBULLET)
        self.sim.set_props(bid, rest_wall=0.0, max_substep=4.0)
        self.sim.set_vel(bid, adx * 5200.0, ady * 5200.0)
        self.bullets[bid] = dict(kind="tracer", dmg=0, ttl=14,
                                 born=self.tick_count)
        self._hitstop(2)

    def _fire_lightning(self, ppolygon, px, py):
        self.lightning_charge = 0
        adx, ady = self.aim
        w = WEAPONS["lightning"]
        _, _, _, pvx, pvy, _, _ = self.sim.get(self.pid)
        bid = self.sim.spawn(ppolygon, px + adx * (PLAYER_RADIUS + 6),
                             py + ady * (PLAYER_RADIUS + 6), 3.0, 0.02, GROUP_PBULLET)
        self.sim.set_props(bid, rest_wall=0.0, max_substep=4.0)
        self.sim.set_vel(bid, adx * w["speed"] + pvx * 0.5, ady * w["speed"] + pvy * 0.5)
        self.bullets[bid] = dict(kind="dart", dmg=w["dmg"], ttl=240,
                                 born=self.tick_count)
        self._snd("lightning_fire", ppolygon, (px, py))
        self._shake(4.0)
        self.signals.emit(SignalKind.NOISE, ppolygon, 0.9, self.tick_count)

    def _fire_tau_charged(self, ppolygon, px, py):
        adx, ady = self.aim
        frac = min(1.0, self.tau_charge / TAU_CHARGE_FULL)
        cost = min(self.ammo.get("cell", 0), 5)
        if cost <= 0:
            self._snd("dry_click", ppolygon, (px, py))
            return
        self.ammo["cell"] -= cost
        power = frac * (0.4 + 0.6 * cost / 5.0)
        # 84 at full power: two full-charge hits kill a 168 Warden, the
        # ratified weapon arithmetic (DESIGN_7_25)
        dmg = 18 + 66 * power
        full = power >= 0.999
        _, _, _, pvx, pvy, _, _ = self.sim.get(self.pid)
        bid = self.sim.spawn(ppolygon, px + adx * (PLAYER_RADIUS + 5),
                             py + ady * (PLAYER_RADIUS + 5), 2.2, 0.006,
                             GROUP_PBULLET)
        self.sim.set_props(bid, rest_wall=1.0, max_substep=4.0)
        self.sim.set_vel(bid, adx * 2600.0 + pvx * 0.3, ady * 2600.0 + pvy * 0.3)
        # a FULL charge detonates on impact (small AoE + push) instead of
        # ricocheting: bounces=0 so the first contact — enemy or wall —
        # resolves it (see _detonate_tau)
        self.bullets[bid] = dict(kind="taucharged", dmg=dmg, ttl=160,
                                 bounces=0 if full else 3, aoe=full,
                                 imp=TAU_CHARGED_IMP * power,
                                 born=self.tick_count)
        self.metrics["shots"] += 1
        self._snd("tau_charged_fire", ppolygon, (px, py))
        self._shake(4.0 + 5.0 * power)
        self._hitstop(2)
        self.pulse_light(ppolygon, (px + adx * 12, py + ady * 12), 300.0, 1.2)
        self.signals.emit(SignalKind.NOISE, ppolygon, 1.0, self.tick_count)

    # ------------------------------------------------------------------
    # portable hole
    # ------------------------------------------------------------------

    def _hole_shot(self, ppolygon, px, py, adx, ady):
        if self.holes <= 0:
            self._snd("dry_click", ppolygon, (px, py))
            return
        hit = self.sim.raycast(ppolygon, px, py, adx, ady, 0, HOLE_RANGE, 0, self.pid)
        if hit[0] != "wall":
            self._snd("dry_click", ppolygon, (px, py), 0.5)
            return
        _, polygon, edge, hx, hy, dist, hops, m9 = hit
        x1, y1, x2, y2 = self.sim.edge_endpoints(polygon, edge)
        elen = math.hypot(x2 - x1, y2 - y1)
        along = (hx - x1) * (x2 - x1) / elen + (hy - y1) * (y2 - y1) / elen
        half = HOLE_WIDTH / 2.0
        if along < half + 2.0 or along > elen - half - 2.0:
            self._snd("dry_click", ppolygon, (px, py), 0.5)
            return
        t0, t1 = (along - half) / elen, (along + half) / elen
        if self.cloister is not None:
            if polygon in (self.cloister["sanctum"], self.cloister["corridor"]):
                self._snd("dry_click", ppolygon, (px, py), 0.5)
                return
            mid = self.sim.split_edge(polygon, edge, t0, t1)
            self._shift_edge_maps(polygon, edge)
            self.cloister["links"].append((polygon, mid))
            self._attach_cloister(len(self.cloister["links"]) - 1)
            self.holes -= 1
            self._decal(polygon, "scorch", hx, hy, 8.0)
            self._snd("door_unlock", polygon, (hx, hy))
            self.pulse_light(polygon, (hx, hy), 220.0, 0.9)
            self._shake(2.5)
            return
        if self.hole_mark is None:
            self.hole_mark = (polygon, edge, t0, t1, hx, hy)
            self._decal(polygon, "scorch", hx, hy, 5.0)
            self._snd("terminal_type", polygon, (hx, hy))
            self.pulse_light(polygon, (hx, hy), 140.0, 0.5)
            return
        m_polygon, m_edge, m_t0, m_t1, mx, my = self.hole_mark
        if m_polygon == polygon and m_edge == edge:
            self._snd("dry_click", ppolygon, (px, py), 0.5)
            return
        # split the FIRST mark's wall first; if the second mark shares the
        # polygon with a later edge index, account for the insertion shift
        if m_polygon == polygon and edge > m_edge:
            edge += 2
        mid_a = self.sim.split_edge(m_polygon, m_edge, m_t0, m_t1)
        self._shift_edge_maps(m_polygon, m_edge)
        mid_b = self.sim.split_edge(polygon, edge, t0, t1)
        self._shift_edge_maps(polygon, edge)
        if m_polygon == polygon and mid_a > edge:
            mid_a += 2  # the second split renumbered the first doorway
        w = HOLE_WIDTH
        cor = self.sim.add_polygon([(0.0, 0.0), (0.0, w),
                                 (HOLE_CORRIDOR_LEN, w), (HOLE_CORRIDOR_LEN, 0.0)])
        self.sim.connect(m_polygon, mid_a, cor, 0)
        self.sim.connect(polygon, mid_b, cor, 2)
        self.trace.emit(TopologyChanged(
            tick=self.tick_count, op="connect", a_polygon=m_polygon,
            a_edge=mid_a, b_polygon=cor, b_edge=0, source="hole"))
        self.trace.emit(TopologyChanged(
            tick=self.tick_count, op="connect", a_polygon=polygon,
            a_edge=mid_b, b_polygon=cor, b_edge=2, source="hole"))
        self.signals.on_topology_changed()
        self.level.polygon_seeds.append(cor * 7919 + 13)
        self.holes -= 1
        self.hole_mark = None
        self._snd("door_unlock", polygon, (hx, hy))
        self.pulse_light(polygon, (hx, hy), 220.0, 0.9)
        self._shake(3.0)

    def carve_door(self, polygon: int, near, width: float = 70.0) -> int | None:
        """Split the wall nearest `near` (polygon-local) to make a door-width
        sub-edge; returns its index, or None if no wall has the span."""
        best = None
        for e in range(len(self.sim.polygon_portals(polygon))):
            if self.sim.polygon_portals(polygon)[e] is not None:
                continue
            x1, y1, x2, y2 = self.sim.edge_endpoints(polygon, e)
            elen = math.hypot(x2 - x1, y2 - y1)
            if elen < width + 8.0:
                continue
            ux, uy = (x2 - x1) / elen, (y2 - y1) / elen
            along = (near[0] - x1) * ux + (near[1] - y1) * uy
            along = max(width / 2 + 3.0, min(elen - width / 2 - 3.0, along))
            px_, py_ = x1 + ux * along, y1 + uy * along
            d2 = (px_ - near[0]) ** 2 + (py_ - near[1]) ** 2
            if best is None or d2 < best[0]:
                best = (d2, e, along, elen)
        if best is None:
            return None
        _, e, along, elen = best
        t0 = (along - width / 2) / elen
        t1 = (along + width / 2) / elen
        mid = self.sim.split_edge(polygon, e, t0, t1)
        self._shift_edge_maps(polygon, e)
        return mid

    def append_chunk(self, level) -> int:
        """Stream another level's polygons into this live world. Returns the
        polygon-index offset where the chunk begins. Doors, terminals, and
        entities all arrive re-indexed."""
        offset = self.sim.num_polygons()
        for verts in level.polygon_verts:
            self.sim.add_polygon(verts)
        terrain.apply_walk_masks(self.sim, level, offset)
        for a, ea, b, eb in level.connects:
            self.sim.connect(a + offset, ea, b + offset, eb)
            self.trace.emit(TopologyChanged(
                tick=self.tick_count, op="connect", a_polygon=a + offset,
                a_edge=ea, b_polygon=b + offset, b_edge=eb, source="stream"))
            self.signals.on_topology_changed()
        for a, ea, b, eb, m9 in level.connects_x:
            self.sim.connect_with_xform(a + offset, ea, b + offset, eb, m9)
        for d in level.doors:
            meta = level.key_meta.get(d.key)
            rec = dict(a=d.a + offset, ea=d.ea, b=d.b + offset, eb=d.eb,
                       key=d.key, open=False,
                       gate_prompt=meta.gate_prompt if meta else "")
            self.doors.append(rec)
            self.door_edges[(rec["a"], rec["ea"])] = d.key
            self.door_edges[(rec["b"], rec["eb"])] = d.key
        for t in level.terminals:
            self.terminals.append(dict(polygon=t.polygon + offset, pos=t.pos,
                                       text=t.text, read=False))
        for polygon, spec in level.entities:
            self._spawn_from_spec(polygon + offset, spec, key_meta=level.key_meta)
        if level.lights:
            from dataclasses import replace as _dc_replace
            shifted = [_dc_replace(lt, polygon=lt.polygon + offset) for lt in level.lights]
            self.level.lights.extend(shifted)
            self.lighting.add_lights(self.sim, shifted)
        self.level.polygon_seeds.extend(level.polygon_seeds)
        for i, k in enumerate(level.polygon_kinds):
            if k == "otherworld":
                self.sim.soften_polygon(offset + i)
                self.soft_polygons.add(offset + i)
        self.level.polygon_kinds.extend(level.polygon_kinds)
        self.level.polygon_verts.extend(level.polygon_verts)
        self.level.polygon_centroids.extend(level.polygon_centroids)
        return offset

    def _shift_edge_maps(self, polygon: int, edge: int):
        """A split inserted two edges after `edge` in `polygon`; every python-
        side (polygon, edge) reference beyond it shifts by 2."""
        remapped = {}
        for (r, e), k in self.door_edges.items():
            remapped[(r, e + 2 if r == polygon and e > edge else e)] = k
        self.door_edges = remapped
        for d in self.doors:
            if d["a"] == polygon and d["ea"] > edge:
                d["ea"] += 2
            if d["b"] == polygon and d["eb"] > edge:
                d["eb"] += 2
        if self.cloister:
            self.cloister["links"] = [
                (r, e + 2 if r == polygon and e > edge else e)
                for (r, e) in self.cloister["links"]]

    def _build_cloister(self):
        if self.cloister is not None:
            return
        self.hole_mark = None  # paired-mode marks cannot complete anymore
        s = self.sim
        verts = []
        for i in range(8):
            a = math.radians(22.5) - i * math.pi / 4.0
            verts.append((85.0 * math.cos(a), 85.0 * math.sin(a)))
        sanctum = s.add_polygon(verts)
        elen = 2 * 85.0 * math.sin(math.pi / 8.0)
        t0 = 0.5 - 7.5 / elen
        t1 = 0.5 + 7.5 / elen
        door = s.split_edge(sanctum, 4, t0, t1)
        corridor = s.add_polygon([(0.0, 0.0), (0.0, 15.0), (36.0, 15.0), (36.0, 0.0)])
        s.connect(sanctum, door, corridor, 0)
        self.cloister = dict(sanctum=sanctum, corridor=corridor,
                             links=[], attached=None)
        # the anti-looter guardians, re-sworn: invincible, player-loyal
        for tx, ty in ((-30.0, -34.0), (-30.0, 34.0)):
            tid = s.spawn(sanctum, tx, ty, 6.0, 50.0, GROUP_PICKUP)
            s.set_props(tid, transfers=False)
            self.turrets[tid] = dict(cd=0)
        # the seed keeps the pantry stocked
        self.spawn_pickup(sanctum, (30.0, -20.0), "medkit")
        self.spawn_pickup(sanctum, (30.0, 20.0), "ammo_9mm")
        self.level.polygon_seeds.extend([sanctum * 7919 + 13, corridor * 7919 + 13])

    def _attach_cloister(self, idx: int):
        c = self.cloister
        if c["attached"] is not None:
            self.sim.disconnect(c["corridor"], 2)
            self.trace.emit(TopologyChanged(
                tick=self.tick_count, op="disconnect",
                a_polygon=c["corridor"], a_edge=2, b_polygon=-1, b_edge=-1,
                source="cloister"))
        polygon, edge = c["links"][idx]
        self.sim.connect(polygon, edge, c["corridor"], 2)
        self.trace.emit(TopologyChanged(
            tick=self.tick_count, op="connect", a_polygon=polygon,
            a_edge=edge, b_polygon=c["corridor"], b_edge=2,
            source="cloister"))
        self.signals.on_topology_changed()
        c["attached"] = idx

    def _rotate_cloister(self):
        c = self.cloister
        if c and len(c["links"]) > 1 and c["attached"] is not None:
            self._attach_cloister((c["attached"] + 1) % len(c["links"]))

    def _turret_tick(self):
        if not self.turrets:
            return
        s = self.sim
        for tid, t in self.turrets.items():
            if t["cd"] > 0:
                t["cd"] -= 1
                continue
            polygon = s.get_polygon(tid)
            _, tx, ty, *_ = s.get(tid)
            best, bd = None, 1e18
            for eid in s.polygon_entities(polygon):
                if eid in self.enemies:
                    _, ex, ey, *_ = s.get(eid)
                    d = (ex - tx) ** 2 + (ey - ty) ** 2
                    if d < bd:
                        best, bd = (ex, ey), d
            if best is None:
                continue
            t["cd"] = 16
            dx, dy = best[0] - tx, best[1] - ty
            dl = math.hypot(dx, dy) or 1e-6
            nx, ny = dx / dl, dy / dl
            bid = s.spawn(polygon, tx + nx * 8, ty + ny * 8, 1.6, 0.002, GROUP_PBULLET)
            s.set_props(bid, rest_wall=0.0, max_substep=3.2)
            s.set_vel(bid, nx * 1200.0, ny * 1200.0)
            self.bullets[bid] = dict(kind="turret", dmg=6, ttl=40)
            self._snd("smg_fire", polygon, (tx, ty), 0.35)
            self.pulse_light(polygon, (tx + nx * 8, ty + ny * 8), 190.0, 0.85)

    # ------------------------------------------------------------------
    # gauntlet sentries: data-driven, range/LOS-gated defensive turrets
    # (see SENTRIES above). Deliberately separate from the cloister's
    # `self.turrets` / `_turret_tick` above -- those guardians are
    # shipped, tested (test_cloister.py pins len(s.turrets) == 2), and
    # tuned for a tiny always-safe sanctum with no range/LOS/spin-up of
    # their own; folding sentries into that path would change guardian
    # behavior too. Sentry bullets reuse the guardians' own kind="turret"
    # bullet tag on purpose -- `_contact` already refuses to damage the
    # player with it ("the guardians do not miss that badly") and already
    # damages `self.enemies` with it, so this is the exact "study how
    # player projectiles vs enemy interactions resolve" reuse the
    # directive asks for, not a new special case.
    # ------------------------------------------------------------------

    @staticmethod
    def _segment_crosses_rect(x1, y1, x2, y2, lo_x, lo_y, hi_x, hi_y) -> bool:
        """Liang-Barsky segment-vs-AABB clip test: True if the open segment
        (x1,y1)-(x2,y2) actually crosses the closed rect's interior (a bare
        touch/tangent at a single point does not count -- t0 < t1, not
        <=). Used for sentry LOS against walk-mask terrain rects: the same
        polygon-local `Sim.polygon_terrain` data the lighting system's own
        shadow-casting already reads (see `lighting.terrain_shadow_polys`).
        A polygon's own boundary is convex by construction, so terrain is the
        only thing that can occlude two points already confirmed to share
        a polygon -- `raycast` (used by the rail gun / portable hole) has no
        notion of terrain at all, it only stops at polygon edges/entities."""
        dx, dy = x2 - x1, y2 - y1
        t0, t1 = 0.0, 1.0
        for p, q in ((-dx, x1 - lo_x), (dx, hi_x - x1),
                    (-dy, y1 - lo_y), (dy, hi_y - y1)):
            if abs(p) < 1e-12:
                if q < 0.0:
                    return False  # parallel to this edge and outside it
                continue
            r = q / p
            if p < 0.0:
                if r > t1:
                    return False
                if r > t0:
                    t0 = r
            else:
                if r < t0:
                    return False
                if r < t1:
                    t1 = r
        return t0 < t1

    def _sentry_los_clear(self, polygon: int, x1, y1, x2, y2) -> bool:
        for lo_x, lo_y, hi_x, hi_y in self.sim.polygon_terrain(polygon):
            if self._segment_crosses_rect(x1, y1, x2, y2, lo_x, lo_y, hi_x, hi_y):
                return False
        return True

    def _sentry_tick(self):
        if not self.sentries:
            return
        s = self.sim
        for tid, t in self.sentries.items():
            d = SENTRIES[t["kind"]]
            if t["cd"] > 0:
                t["cd"] -= 1
            polygon = s.get_polygon(tid)
            _, tx, ty, *_ = s.get(tid)
            # nearest enemy in range WITH a clear shot -- an occluded
            # nearer target must not blind the sentry to a farther, clear
            # one (see the fail-first walls/terrain test).
            best, best_d2 = None, d["range"] * d["range"]
            for eid in s.polygon_entities(polygon):
                if eid not in self.enemies:
                    continue
                _, ex, ey, *_ = s.get(eid)
                dist2 = (ex - tx) ** 2 + (ey - ty) ** 2
                if dist2 > best_d2:
                    continue
                if not self._sentry_los_clear(polygon, tx, ty, ex, ey):
                    continue
                best, best_d2 = (ex, ey), dist2
            if best is None:
                t["spin"] = d["spin_up"]  # target lost: re-acquire from cold
                continue
            if t["spin"] > 0:
                t["spin"] -= 1  # instant-ish acquisition, not instant
                continue
            if t["cd"] > 0:
                continue
            t["cd"] = d["cd"]
            dx, dy = best[0] - tx, best[1] - ty
            dl = math.hypot(dx, dy) or 1e-6
            nx, ny = dx / dl, dy / dl
            bid = s.spawn(polygon, tx + nx * (d["radius"] + 2), ty + ny * (d["radius"] + 2),
                         1.6, 0.002, GROUP_PBULLET)
            s.set_props(bid, rest_wall=0.0, max_substep=3.2)
            s.set_vel(bid, nx * d["bolt_speed"], ny * d["bolt_speed"])
            self.bullets[bid] = dict(kind="turret", dmg=d["dmg"], ttl=50)
            self._snd(d["alert_snd"], polygon, (tx, ty), 0.4)
            # muzzle FLARE — a real pulse light at the barrel, brief and
            # bright (director 2026-07-23: "muzzle flash, and muzzle flare
            # at the barrel"); the render adds the sprite flash off fire_tick
            self.pulse_light(polygon, (tx + nx * (d["radius"] + 2),
                                       ty + ny * (d["radius"] + 2)), 150.0, 0.7)

    def _detonate_tau(self, bid: int, polygon: int, x: float, y: float,
                      b: dict, skip: int | None = None):
        """Full-charge tau impact: a SMALL burst (DESIGN_7_25 — 'detonates
        on impact with a small AoE + push'), nothing like the lightning
        blast. Neighbors inside TAU_AOE_RADIUS take falloff damage and a
        falloff push; the directly-struck body (skip) already resolved."""
        self.fx.append(("lightning", polygon, x, y, TAU_AOE_RADIUS))
        self.signals.emit(SignalKind.NOISE, polygon, 0.8, self.tick_count)
        self._snd("tau_charged_fire", polygon, (x, y), 0.7)
        self._shake(4.0)
        self._decal(polygon, "scorch", x, y, 10.0)
        for eid in list(self.sim.polygon_entities(polygon)):
            if eid == skip or eid not in self.enemies:
                continue
            _, ex, ey, *_ = self.sim.get(eid)
            d = math.hypot(ex - x, ey - y)
            if d > TAU_AOE_RADIUS:
                continue
            fall = 1.0 - d / TAU_AOE_RADIUS
            nx, ny = ((ex - x) / d, (ey - y) / d) if d > 1e-6 else (1.0, 0.0)
            self._apply_impulse(eid, nx * TAU_AOE_IMP * fall,
                                ny * TAU_AOE_IMP * fall, source="taucharged_aoe")
            self._damage_enemy(eid, TAU_AOE_DMG * fall, (nx, ny), 0.0,
                               source="taucharged_aoe")

    def _detonate_dart(self, bid: int, polygon: int, x: float, y: float):
        """The lightning cannon IS the crowd-control option (director,
        2026-07-16): the blast kills weak enemies anywhere inside it
        (falloff floor keeps damage above husk hp), then CHAIN ARCS walk
        the bolt down the packed file — one shot into a choke takes out
        15-20 of the weakest."""
        w = WEAPONS["lightning"]
        self.fx.append(("lightning", polygon, x, y, w["radius"]))
        self.signals.emit(SignalKind.NOISE, polygon, 1.0, self.tick_count)
        self._snd("lightning_fire", polygon, (x, y), 1.0)
        self._shake(9.0)
        self._hitstop(5)
        self._decal(polygon, "scorch", x, y, 22.0)
        struck: list[tuple[float, float]] = [(x, y)]
        hit_ids: set[int] = set()
        for eid in list(self.sim.polygon_entities(polygon)):
            e = self.enemies.get(eid)
            if not e:
                continue
            _, ex, ey, evx, evy, _, _ = self.sim.get(eid)
            d = math.hypot(ex - x, ey - y)
            if d > w["radius"]:
                continue
            fall = 1.0 - d / w["radius"]
            nx, ny = ((ex - x) / d, (ey - y) / d) if d > 1e-6 else (1.0, 0.0)
            # the cannon's push, generalized to every weapon by the canon:
            # a mass-scaled impulse — heavy bodies ride it out, light ones fly
            self._apply_impulse(eid, nx * w["imp"] * fall, ny * w["imp"] * fall,
                                source="lightning")
            self._damage_enemy(eid, w["dmg"] * (0.6 + 0.4 * fall),
                               (nx, ny), 0.0, source="lightning")
            struck.append((ex, ey))
            hit_ids.add(eid)
        # chain arcs: hop to the nearest unstruck enemy within arc range
        # of ANY struck point, up to max_arcs — the bolt walks the file
        arcs = 0
        while arcs < w["max_arcs"]:
            best = None
            for eid in list(self.sim.polygon_entities(polygon)):
                if eid in hit_ids or eid not in self.enemies:
                    continue
                if not self.sim.exists(eid):
                    continue
                _, ex, ey, _, _, _, _ = self.sim.get(eid)
                dmin = min(math.hypot(ex - sx, ey - sy)
                           for sx, sy in struck)
                if dmin <= w["arc_range"] and                         (best is None or dmin < best[0]):
                    best = (dmin, eid, ex, ey)
            if best is None:
                break
            _, eid, ex, ey = best
            hit_ids.add(eid)
            struck.append((ex, ey))
            self.fx.append(("lightning", polygon, ex, ey, 40.0))
            self._damage_enemy(eid, w["arc_dmg"], (0.0, 0.0), 0.0,
                               source="lightning_arc")
            arcs += 1

    # ------------------------------------------------------------------

    def _describe_entity(self, eid: int):
        """The senses' identity oracle: who a body is, or None for things
        that are not sensable beings (bullets, pickups, decoration). The
        tuple deliberately carries no HP and no private records."""
        if eid == self.pid:
            tags = frozenset(("dead",)) if self.dead else frozenset()
            return ("player", "commando", "intruder", tags, GROUP_PLAYER)
        e = self.enemies.get(eid)
        if e is not None:
            return (e["kind"], "testator", "fighter",
                    frozenset((e["state"],)), GROUP_ENEMY)
        return None

    def _apply_impulse(self, eid: int, jx: float, jy: float, *, source: str):
        """The one sanctioned push: J through the engine (dv = J/m), traced.
        Knockback is never a velocity write (DESIGN_7_25 combat canon)."""
        self.sim.apply_impulse(eid, jx, jy)
        self.trace.emit(ImpulseApplied(
            tick=self.tick_count, entity_id=eid,
            jx=round(jx, 3), jy=round(jy, 3), source=source))

    def _set_enemy_state(self, eid: int, e: dict, new: str) -> None:
        """The one door every enemy state change walks through, so the
        trace sees each transition exactly once."""
        old = e["state"]
        if old == new:
            return
        e["state"] = new
        self.trace.emit(AgentTransition(
            tick=self.tick_count, entity_id=eid, agent_kind=e["kind"],
            from_state=old, to_state=new))

    def _damage_enemy(self, eid: int, dmg: float, ndir, knock: float,
                      *, source: str):
        e = self.enemies.get(eid)
        if e is None:
            return
        dmg *= self._dmg_out_mul
        if e["state"] != "idle":
            dmg *= self._target_mark_mul
        if self._crit_p > 0.0 and self.rng.random() < self._crit_p:
            dmg *= self._crit_mul
        e["hp"] -= dmg
        self._set_enemy_state(eid, e, "hunt")
        self.metrics["hits"] += 1
        self.metrics["dmg_dealt"] += dmg
        polygon = self.sim.get_polygon(eid)
        _, ex, ey, evx, evy, _, _ = self.sim.get(eid)
        self.trace.emit(DamageApplied(
            tick=self.tick_count, target_id=eid, target_kind=e["kind"],
            amount=round(dmg, 3), source=source))
        # Distress: an agent was harmed here — the inflammation analogue,
        # keyed to agent harm only (there is no structural damage)
        self.signals.emit(SignalKind.DISTRESS, polygon, 0.15, self.tick_count)
        if knock > 0.0:
            self._apply_impulse(eid, ndir[0] * knock, ndir[1] * knock,
                                source=source)
        self._snd("hit_flesh", polygon, (ex, ey), 0.8)
        self._decal(polygon, "blood", ex + self.rng.uniform(-4, 4),
                    ey + self.rng.uniform(-4, 4), self.rng.uniform(3, 7),
                    self.rng.uniform(0, 6.28))
        self.fx.append(("hitflash", eid))
        if e["hp"] <= 0:
            self._kill_enemy(eid, polygon, (ex, ey), ndir)

    def _kill_enemy(self, eid: int, polygon: int, pos, ndir):
        e = self.enemies.pop(eid)
        kind = e["kind"]
        d = ENEMIES[kind]
        self.metrics["kills"] += 1
        self._snd(d["die_snd"], polygon, pos)
        self._decal(polygon, "corpse_" + kind, pos[0], pos[1],
                    d["radius"], math.atan2(ndir[1], ndir[0]))
        for i in range(int(d["radius"])):
            a = self.rng.uniform(0, 6.28)
            r = self.rng.uniform(2, d["radius"] * 1.8)
            self._decal(polygon, "blood", pos[0] + math.cos(a) * r,
                        pos[1] + math.sin(a) * r, self.rng.uniform(2, 5), a)
        self.fx.append(("gib", polygon, pos[0], pos[1], int(d["radius"]),
                        (ndir[0], ndir[1])))
        self._hitstop(4 if kind in ("husk", "mite") else 7)
        self._shake(2.5)
        self.sim.remove(eid)
        # drops
        for p, kind_ in DROP_TABLES[kind]:
            if self.rng.random() < p:
                self.spawn_pickup(polygon, (pos[0] + self.rng.uniform(-6, 6),
                                         pos[1] + self.rng.uniform(-6, 6)), kind_)
                break
        # Void path: with the harvesting protocol integrated, a spitter's
        # salvage: every kill yields its score in components (9.1 -- wrecks
        # are materials; score already priced each enemy's difficulty)
        self.spawn_pickup(polygon, (pos[0] + self.rng.uniform(-5, 5),
                                 pos[1] + self.rng.uniform(-5, 5)),
                          "components",
                          extra=dict(amount=int(math.ceil(
                              d["score"] * self._salvage_mul))))
        # Danger: an agent DIED here — no spread, very slow fade; Distress
        # bumps too (the killing is the strongest disturbance there is)
        self.signals.emit(SignalKind.DANGER, polygon, 0.40, self.tick_count)
        self.signals.emit(SignalKind.DISTRESS, polygon, 0.25, self.tick_count)

    def _damage_player(self, dmg: float, polygon: int, *, source: str):
        if self.hurt_cd > 0 or self.dead:
            return
        self.hurt_cd = 30
        if self.recall_t > 0:
            self.recall_t = 0
            self._objective("RECALL SEVERED")
        dmg *= self._dmg_mul * self._armor_mul
        dmg *= self.player_resist        # armor: player_state buff lever
        self.hp -= dmg
        self.metrics["dmg_taken"] += dmg
        self.trace.emit(DamageApplied(
            tick=self.tick_count, target_id=self.pid, target_kind="player",
            amount=round(dmg, 3), source=source))
        px, py = self.player_pos()
        self._snd("player_hurt", polygon, (px, py))
        self._shake(min(8.0, 2.0 + dmg * 0.25))
        self.fx.append(("playerhurt", dmg))
        self._decal(polygon, "blood", px + self.rng.uniform(-5, 5),
                    py + self.rng.uniform(-5, 5), self.rng.uniform(3, 6))
        if self.hp <= 0:
            self.dead = True
            self.metrics["deaths"] += 1
            self._snd("player_die", polygon, (px, py))
            self.fx.append(("playerdie",))
            self._decal(polygon, "corpse_player", px, py, PLAYER_RADIUS)
            self._drop_corpse(polygon, (px, py))

    def _drop_corpse(self, polygon: int, pos) -> None:
        """The wrecked frame stays where it fell, holding what it carried:
        components and unplanted station kits (weapons and hole charges are
        licensed patterns -- the seed reprints those with the frame, so they
        never ride the corpse; carrying them here would duplicate them
        through the cold-restore path). As many wrecks accumulate as you
        leave unrecovered; nothing is lost until then, and nothing is lost
        after retrieval (9.1)."""
        if self._protected_revival:
            # Vocation capstone: the seed holds your salvage in trust; the
            # wreck carries only what a fabricator can't bank (kits)
            contents = dict(components=0, station_kits=self.station_kits)
        else:
            contents = dict(components=self.components,
                            station_kits=self.station_kits)
            self.components = 0
        self.station_kits = 0
        if any(contents.values()):
            self.spawn_pickup(polygon, pos, "corpse_frame",
                              extra=dict(contents=contents,
                                         line=self.rng.randrange(1 << 30)))

    # ------------------------------------------------------------------

    def _enemy_ai(self, ppolygon: int):
        s = self.sim
        active = set(s.polygons_within(ppolygon, ACTIVE_HOPS))
        px, py = self.player_pos()
        for eid, e in list(self.enemies.items()):
            polygon = s.get_polygon(eid)
            if polygon not in active:
                continue
            kind = e["kind"]
            d = ENEMIES[kind]
            _, ex, ey, evx, evy, edx, edy = s.get(eid)
            for k in ("touch_cd", "spit_cd", "scream_cd", "wander_cd"):
                if e.get(k, 0) > 0:
                    e[k] -= 1
            if e.get("buff", 0) > 0:
                e["buff"] -= 1

            if kind == "flicker":
                # Deliberately bypasses the standard idle/waking/hunt
                # state machine entirely -- a flicker's resting behavior
                # already IS an active state (holding low-light ground),
                # not "wait until the player enters the polygon" like every
                # other kind; see `_flicker_ai`'s own docstring for the
                # LURK/AMBUSH/hunt/disengage state machine.
                self._flicker_ai(eid, e, polygon, ppolygon, ex, ey, evx, evy)
                continue

            # footfalls: the dread channel again — mass on deck plating,
            # audible through walls before anything is visible. Deltas are
            # only meaningful within one polygon's local frame, so a transfer
            # resets the stride.
            if kind not in ("mite", "shrieker"):
                lpolygon, lx, ly = e.get("step_from", (polygon, ex, ey))
                if lpolygon == polygon:
                    e["step_acc"] = e.get("step_acc", 0.0) + \
                        math.hypot(ex - lx, ey - ly)
                else:
                    e["step_acc"] = 0.0
                e["step_from"] = (polygon, ex, ey)
                stride = 44.0 if kind in ("brute", "warden") else 30.0
                if e.get("step_acc", 0.0) >= stride:
                    e["step_acc"] = 0.0
                    self._snd("step_heavy" if kind in ("brute", "warden")
                              else "step_soft", polygon, (ex, ey),
                              0.6 if e["state"] == "hunt" else 0.35)

            if e["state"] == "idle":
                if polygon == ppolygon:
                    # the notice beat: growl first, charge after — the
                    # player always gets the first move
                    self._set_enemy_state(eid, e, "waking")
                    e["wake"] = self.WAKE_TICKS[kind]
                    self._snd(d["alert_snd"], polygon, (ex, ey), 0.9)
                    self.fx.append(("alerted", polygon, ex, ey))
                    ddx, ddy = px - ex, py - ey
                    dl = math.hypot(ddx, ddy) or 1e-6
                    s.set_dir(eid, ddx / dl, ddy / dl)
                    continue
                # staggered awareness beat (every 10 ticks per agent):
                # fire on line of sight — an intruder plainly visible
                # through a doorway wakes the watcher (DESIGN_7_25 §3) —
                # and the FRACTIONAL QUORUM: commit on the fraction of
                # visible chamber-mates already committed, plus one
                # bounded virtual supporter from the fields. Calm packed
                # halls inhibit; sparse pickets flip first.
                if (self.tick_count + eid) % 10 == 0:
                    if self.senses.sight_of(eid, self.pid) is not None:
                        self._set_enemy_state(eid, e, "waking")
                        e["wake"] = self.WAKE_TICKS[kind]
                        self._snd(d["alert_snd"], polygon, (ex, ey), 0.7)
                        self.fx.append(("alerted", polygon, ex, ey))
                        continue
                    peers = [self.enemies[oid]
                             for oid in s.polygon_entities(polygon)
                             if oid != eid and oid in self.enemies]
                    committed = sum(1 for oe in peers
                                    if oe["state"] in ("waking", "hunt"))
                    exc = coord.quorum_excitation(
                        self.signals.sample(SignalKind.NOISE, polygon,
                                            self.tick_count),
                        self.signals.sample(SignalKind.DISTRESS, polygon,
                                            self.tick_count))
                    f = coord.quorum_fraction(committed, len(peers), exc)
                    if self.rng.random() < coord.commit_probability(
                            f, e["q_thr"]):
                        self._set_enemy_state(eid, e, "waking")
                        e["wake"] = self.WAKE_TICKS[kind]
                        self._snd(d["alert_snd"], polygon, (ex, ey), 0.5)
                        continue
                # aimless drift — and the drift is a PATROL: this chamber
                # reads as recently searched to the rest of the swarm
                if self.tick_count % 15 == (eid % 15):
                    self.signals.emit(SignalKind.PATROL, polygon, 0.04,
                                      self.tick_count)
                if e["wander_cd"] <= 0:
                    e["wander_cd"] = self.rng.randrange(90, 240)
                    a = self.rng.uniform(0, 6.28)
                    e["wander"] = (math.cos(a), math.sin(a))
                wx, wy = e.get("wander", (0.0, 0.0))
                s.set_vel(eid, evx + wx * d["accel"] * 0.25 * DT,
                          evy + wy * d["accel"] * 0.25 * DT)
                continue

            if e["state"] == "waking":
                e["wake"] = e.get("wake", 0) - 1
                if e["wake"] <= 0:
                    self._set_enemy_state(eid, e, "hunt")
                continue

            # hunting: audible before visible — the dread channel
            e["groan_cd"] = e.get("groan_cd", self.rng.randrange(60, 200)) - 1
            if e["groan_cd"] <= 0:
                e["groan_cd"] = self.rng.randrange(140, 260)
                self._snd(d["alert_snd"], polygon, (ex, ey), 0.35)
            accel = d["accel"] * (e.get("buff_mul", 1.25)
                                  if e.get("buff", 0) > 0 else 1.0)
            if kind == "shrieker":
                self._shrieker_ai(eid, e, polygon, ppolygon, ex, ey, accel)
                continue
            # --- engagement target: the player's position in THIS polygon's
            # local frame. Polygons are individual polygons, so co-polygon is
            # just the identity case; further out, the portal transforms
            # COMPOSE along the chain (director 2026-07-19: one hop was
            # never the law — sightlines run as deep as the geometry
            # lets them) and combat continues through every doorway the
            # ray clears — aiming, spitting, lunging. An
            # enemy that goes inert when the player steps over a
            # threshold is not a fight.
            tx = ty = None
            sighting = self.senses.sight_of(eid, self.pid)
            if sighting is not None:
                tx, ty = sighting.position
                e["quiet"] = 0
                # relay-recruit: an agent with the target in sight
                # re-broadcasts — contact makes signal makes more contact
                if (self.tick_count + eid) % 5 == 0:
                    self.signals.emit(SignalKind.MUSTER, polygon, 0.02,
                                      self.tick_count)
                    self.signals.emit(SignalKind.DISTRESS, polygon, 0.005,
                                      self.tick_count)
            else:
                # stand-down: a hunter whose neighborhood stays faint ~5s
                # exits the combat state — the response THINS, it doesn't
                # chase ghosts forever
                t_ = self.tick_count
                peak = max(
                    self.signals.sample(SignalKind.NOISE, polygon, t_),
                    self.signals.sample(SignalKind.TRAIL, polygon, t_),
                    self.signals.sample(SignalKind.DISTRESS, polygon, t_),
                    self.signals.sample(SignalKind.MUSTER, polygon, t_))
                if peak < coord.STAND_DOWN_FLOOR:
                    e["quiet"] = e.get("quiet", 0) + 1
                else:
                    e["quiet"] = 0
                if coord.wants_stand_down(False, peak, e["quiet"]):
                    self._set_enemy_state(eid, e, "idle")
                    e["quiet"] = 0
                    e.pop("route", None)
                    continue
            if tx is not None and sighting.portal_depth >= 1:
                # even a SIGHTED chase respects the threshold-holding
                # rule: the chamber that keeps killing our kind is not
                # entered alone just because the killer is visible in it
                # — that is precisely how a killbox works. Hold at the
                # doorway and call until a push gathers.
                pedge = s.next_edge(polygon, sighting.polygon)
                if pedge >= 0:
                    portal1 = s.polygon_portals(polygon)[pedge]
                    t_ = self.tick_count
                    if portal1 is not None and coord.danger_hold(
                            self.signals.sample(SignalKind.DANGER,
                                                portal1[0], t_),
                            sum(1 for oid in s.polygon_entities(polygon)
                                if oid != eid and oid in self.enemies
                                and self.enemies[oid]["state"]
                                in ("waking", "hunt")),
                            self.signals.sample(SignalKind.MUSTER,
                                                polygon, t_)):
                        if (t_ + eid) % 5 == 0:
                            self.signals.emit(SignalKind.MUSTER, polygon,
                                              0.05, t_)
                        mx_, my_ = s.edge_midpoint(polygon, pedge)
                        ddx, ddy = mx_ - ex, my_ - ey
                        dist = math.hypot(ddx, ddy) or 1e-6
                        if dist > 90.0:
                            nx, ny = ddx / dist, ddy / dist
                            s.set_dir(eid, nx, ny)
                            sx, sy = s.terrain_avoid_dir(
                                polygon, ex, ey, d["radius"], nx, ny,
                                max(40.0, min(dist, 120.0)))
                            sx, sy = self._steer_heading(eid, e, d, sx, sy)
                            self._budget_move(eid, e, d, polygon, ex, ey,
                                              evx, evy, sx, sy, accel)
                        continue
            if tx is not None:
                ddx, ddy = tx - ex, ty - ey
                dist = math.hypot(ddx, ddy) or 1e-6
                nx, ny = ddx / dist, ddy / dist
                s.set_dir(eid, nx, ny)  # aim/face the player exactly
                # Movement steers around walk-mask terrain: physics-level
                # wall sliding alone doesn't route a bot around an obstacle
                # it beelines straight into (only a polygon's convex boundary
                # guarantees that) -- a straight seek toward a target
                # directly behind painted equipment can generate zero
                # tangential velocity and grind against it forever
                # (confirmed fail-first in necore's physics tests). `sx,sy`
                # is the movement heading; `nx,ny` stays the true bearing
                # for aim/attacks below.
                sx, sy = s.terrain_avoid_dir(polygon, ex, ey, d["radius"], nx, ny,
                                             max(40.0, min(dist, 120.0)))
                sx, sy = self._steer_heading(eid, e, d, sx, sy)
                # husks lunge: a sudden burst inside close range reads as an
                # attack, not a shove
                if kind in ("husk", "brute") and dist < 95.0 \
                        and e.get("lunge_cd", 0) <= 0:
                    e["lunge_cd"] = 120 if kind == "husk" else 150
                    burst = 300.0 if kind == "husk" else 240.0
                    s.set_vel(eid, evx + sx * burst, evy + sy * burst)
                    self._snd(d["alert_snd"], polygon, (ex, ey), 0.55)
                if e.get("lunge_cd", 0) > 0:
                    e["lunge_cd"] -= 1
                # warden = a normal high-tier enemy (DESIGN_7_25): no
                # enrage phase, no brood — 168 hp and honest kinematics
                keep_min = d.get("keep_min")
                if keep_min is not None and d.get("spit_cd") is not None:
                    # ranged: hold the band, spit on cooldown
                    if dist < d["keep_min"]:
                        s.set_vel(eid, evx - sx * accel * DT, evy - sy * accel * DT)
                    elif dist > d["keep_max"]:
                        s.set_vel(eid, evx + sx * accel * DT, evy + sy * accel * DT)
                    if e["spit_cd"] <= 0:
                        e["spit_cd"] = d["spit_cd"]
                        self._spit(eid, polygon, ex, ey, nx, ny, d)
                    if kind != "warden":
                        continue
                self._budget_move(eid, e, d, polygon, ex, ey, evx, evy,
                                  sx, sy, accel)
            else:
                if e.get("tether"):
                    # holds its ground — but only pursuit is waived; an
                    # engaged tethered guardian fights through the door
                    # via the engagement branch above
                    continue
                # no sighting: hunt the FIELDS, not the player's address —
                # climb Noise/Trail/Distress across the portal graph
                # (chemotaxis; the omniscient next_edge pursuit is gone)
                edge = self._hunt_edge(eid, e, polygon)
                if edge < 0:
                    continue
                portal = s.polygon_portals(polygon)[edge]
                if portal is None:
                    e.pop("route", None)
                    continue
                t_ = self.tick_count
                if coord.danger_hold(
                        self.signals.sample(SignalKind.DANGER, portal[0], t_),
                        sum(1 for oid in s.polygon_entities(polygon)
                            if oid != eid and oid in self.enemies
                            and self.enemies[oid]["state"] in ("waking", "hunt")),
                        self.signals.sample(SignalKind.MUSTER, polygon, t_)):
                    # threshold-holding: that chamber keeps killing us —
                    # stand at the doorway and call until a push gathers
                    if (t_ + eid) % 5 == 0:
                        self.signals.emit(SignalKind.MUSTER, polygon, 0.05, t_)
                    mx_, my_ = s.edge_midpoint(polygon, edge)
                    ddx, ddy = mx_ - ex, my_ - ey
                    dist = math.hypot(ddx, ddy) or 1e-6
                    if dist > 90.0:
                        nx, ny = ddx / dist, ddy / dist
                        s.set_dir(eid, nx, ny)
                        sx, sy = s.terrain_avoid_dir(
                            polygon, ex, ey, d["radius"], nx, ny,
                            max(40.0, min(dist, 120.0)))
                        sx, sy = self._steer_heading(eid, e, d, sx, sy)
                        self._budget_move(eid, e, d, polygon, ex, ey,
                                          evx, evy, sx, sy, accel)
                    continue
                mx_, my_ = s.edge_midpoint(polygon, edge)
                ddx, ddy = mx_ - ex, my_ - ey
                dist = math.hypot(ddx, ddy) or 1e-6
                nx, ny = ddx / dist, ddy / dist
                s.set_dir(eid, nx, ny)
                sx, sy = s.terrain_avoid_dir(polygon, ex, ey, d["radius"], nx, ny,
                                             max(40.0, min(dist, 120.0)))
                sx, sy = self._steer_heading(eid, e, d, sx, sy)
                self._budget_move(eid, e, d, polygon, ex, ey, evx, evy,
                                  sx, sy, accel)

    def _peer_bodies(self, eid: int, polygon: int):
        out = []
        for oid in self.sim.polygon_entities(polygon):
            if oid == eid or oid not in self.enemies:
                continue
            _, ox, oy, *_ = self.sim.get(oid)
            out.append((ox, oy, ENEMIES[self.enemies[oid]["kind"]]["radius"]))
        return out

    def _budget_move(self, eid, e, d, polygon, ex, ey, evx, evy,
                     sx, sy, accel) -> None:
        """Priority-budget locomotion (the ratified flocking correction):
        keep-apart claims acceleration FIRST, only the remainder chases —
        opposed demands never average into the doorframe."""
        sep = coord.separation_request((ex, ey), d["radius"],
                                       self._peer_bodies(eid, polygon))
        ax, ay = coord.allocate_acceleration(
            accel, [(0, sep[0] * accel, sep[1] * accel),
                    (1, sx * accel, sy * accel)])
        self.sim.set_vel(eid, evx + ax * DT, evy + ay * DT)

    def _hunt_edge(self, eid: int, e: dict, polygon: int) -> int:
        """Which doorway calls loudest: Noise + Trail + Distress + Muster
        one hop away, plus the worn doorway-trail lanes. Raid members take
        the second-best route so pushes fan. Returns -1 when nothing
        calls from anywhere — the hunter has nothing to hunt."""
        t_ = self.tick_count
        route = e.get("route")
        if route is not None and route[0] == polygon and t_ - route[2] < 45:
            return route[1]
        best = (-1, 0.0)
        second = (-1, 0.0)
        for edge, portal in enumerate(self.sim.polygon_portals(polygon)):
            if portal is None:
                continue
            nb = portal[0]
            att = (self.signals.sample(SignalKind.NOISE, nb, t_)
                   + self.signals.sample(SignalKind.TRAIL, nb, t_)
                   + 0.6 * self.signals.sample(SignalKind.DISTRESS, nb, t_)
                   + 0.4 * self.signals.sample(SignalKind.MUSTER, nb, t_)
                   + 0.15 * self.signals.doorway_trail(polygon, edge, t_))
            if att > best[1]:
                second = best
                best = (edge, att)
            elif att > second[1]:
                second = (edge, att)
        if best[1] < 0.02:
            e.pop("route", None)
            return -1
        edge = coord.choose_route(best[0],
                                  second[0] if second[1] >= 0.02 else -1,
                                  bool(e.get("raid")))
        e["route"] = (polygon, edge, t_)
        self.signals.deposit_doorway_trail(polygon, edge, 0.5, t_)
        return edge

    def _steer_heading(self, eid: int, e: dict, d: dict,
                       wx: float, wy: float) -> tuple[float, float]:
        """Turn-rate-limited steering (DESIGN_7_25 kinematics: every kind
        turns WORSE than the Commando, who turns instantly). The body's
        stored heading slews toward the wanted direction at most
        d['turn'] rad/s; acceleration is applied along the heading, so a
        fast heavy kind genuinely overshoots and arcs — escape is won by
        turning inside them, not by outrunning them."""
        m = math.hypot(wx, wy)
        if m < 1e-9:
            return e.get("hdg", (1.0, 0.0))
        wx, wy = wx / m, wy / m
        hx, hy = e.get("hdg", (wx, wy))
        cross = hx * wy - hy * wx
        dot = hx * wx + hy * wy
        ang = math.atan2(cross, dot)
        max_step = d["turn"] * DT
        if abs(ang) <= max_step:
            hx, hy = wx, wy
        else:
            st = max_step if ang > 0 else -max_step
            ca, sa = math.cos(st), math.sin(st)
            hx, hy = hx * ca - hy * sa, hx * sa + hy * ca
        e["hdg"] = (hx, hy)
        self.sim.set_dir(eid, hx, hy)   # the body faces where it moves
        return hx, hy

    def _spit(self, eid, polygon, ex, ey, nx, ny, d):
        bid = self.sim.spawn(polygon, ex + nx * (d["radius"] + 4),
                             ey + ny * (d["radius"] + 4), 2.5, 0.01, GROUP_EBULLET)
        self.sim.set_props(bid, rest_wall=0.0, max_substep=3.0)
        ang = math.atan2(ny, nx) + self.rng.uniform(-0.06, 0.06)
        self.sim.set_vel(bid, math.cos(ang) * d["spit_speed"],
                         math.sin(ang) * d["spit_speed"])
        self.bullets[bid] = dict(kind="spit", dmg=d["spit_dmg"], ttl=180)
        self._snd("spitter_shoot", polygon, (ex, ey), 0.9)

    def _shrieker_ai(self, eid, e, polygon, ppolygon, ex, ey, accel):
        """The alarm caller GOES somewhere (director 2026-07-16: "the
        shrieker should be _going_ somewhere -- to the nearest cluster
        of its friends"): it rallies toward the reachable polygon holding
        the most allies (count discounted by hops), screaming on the
        way, steering around terrain like everything else -- the old
        straight-line flee pinned it into walls."""
        s = self.sim
        d = ENEMIES["shrieker"]
        px, py = self.player_pos()
        if e["scream_cd"] <= 0:
            e["scream_cd"] = d["scream_cd"]
            self._snd("shrieker_scream", polygon, (ex, ey), 1.0)
            self.fx.append(("scream", polygon, ex, ey))
            for oid, oe in self.enemies.items():
                if oid == eid:
                    continue
                orr = s.get_polygon(oid)
                hd = s.hop_distance(orr, polygon)
                if 0 <= hd <= 2:
                    self._set_enemy_state(oid, oe, "hunt")
                    oe["buff"] = 60 * 5
        e["rally_cd"] = e.get("rally_cd", 0) - 1
        if e["rally_cd"] <= 0 or "rally_polygon" not in e:
            e["rally_cd"] = 60
            counts: dict[int, int] = {}
            for oid, oe in self.enemies.items():
                if oid == eid or oe.get("kind") == "shrieker":
                    continue
                r = s.get_polygon(oid)
                counts[r] = counts.get(r, 0) + 1
            best, best_score = None, 0.0
            for r, n in counts.items():
                hd = s.hop_distance(polygon, r)
                if not 0 <= hd <= 5 or r == ppolygon:
                    continue
                score = n / (1.0 + hd)
                if score > best_score:
                    best, best_score = r, score
            e["rally_polygon"] = best
        rally = e.get("rally_polygon")
        _, _, _, evx, evy, _, _ = s.get(eid)
        if rally is not None and rally != polygon:
            edge = s.next_edge(polygon, rally)
            if edge >= 0:
                gx, gy = s.edge_midpoint(polygon, edge)
            else:
                gx, gy = ex - (px - ex), ey - (py - ey)
        elif polygon == ppolygon:
            gx, gy = ex + (ex - px), ey + (ey - py)   # nowhere better:
            #                                           back off for now
        else:
            return                                    # with friends: hold
        ddx, ddy = gx - ex, gy - ey
        dist = math.hypot(ddx, ddy) or 1e-6
        nx, ny = ddx / dist, ddy / dist
        s.set_dir(eid, nx, ny)
        sx, sy = s.terrain_avoid_dir(polygon, ex, ey, d["radius"], nx, ny,
                                     max(40.0, min(dist, 120.0)))
        sx, sy = self._steer_heading(eid, e, d, sx, sy)
        s.set_vel(eid, evx + sx * accel * DT, evy + sy * accel * DT)

    # ------------------------------------------------------------------
    # flicker: Adversary-lane ambush predator (LURK/AMBUSH state machine)
    # ------------------------------------------------------------------

    def _polygon_light_map(self):
        """`LightingSystem.frame_lookup()`, computed at most ONCE per sim
        tick and cached -- `light_level_at` queries are cheap per-call, but
        `frame_lookup` itself re-runs the attached (worklight) visibility
        pass, the same cost `render.py` already pays once per frame. Only
        ever called when a flicker enemy actually exists (see
        `_flicker_ai`'s call site in `_enemy_ai`), so a session with no
        lurkers -- every shipped campaign level today -- pays nothing."""
        if self._light_map_tick != self.tick_count:
            self._light_map_cache = self.lighting.frame_lookup(self.sim)
            self._light_map_tick = self.tick_count
        return self._light_map_cache

    #: how lit a spot must read (0..1) before a lurker treats it as a lamp
    #: pool to avoid / a discovery bright enough to abandon stealth.
    LURK_MAX_LIGHT = 0.12

    def _flicker_dormant_trace(self, e) -> float:
        """Sensor-trace intensity while DORMANT (LURK, not currently
        committing): a flickering, unreliable return -- dim, never fully
        invisible, alternating on a randomized cadence so a player who's
        paying attention can catch it. Draws from the sim's own RNG
        stream (determinism law: no wall clock), the same pattern
        `_enemy_ai`'s existing idle "wander" cadence already uses."""
        cd = e.get("flicker_cd", 0) - 1
        if cd <= 0:
            cd = self.rng.randrange(6, 22)
            e["flicker_on"] = not e.get("flicker_on", False)
        e["flicker_cd"] = cd
        return 0.34 if e.get("flicker_on") else 0.12

    def _flicker_ai(self, eid, e, polygon, ppolygon, ex, ey, evx, evy):
        """LURK: seek/hold low-light polygon-local positions, steer away from
        lamp pools, reposition as the worklight sweep approaches (all via
        `light_level_at`, which already folds in Unit 1's terrain shadows
        -- a lurker's best hiding spot is naturally behind terrain).
        AMBUSH: player within `ambush_radius` while in the same polygon ->
        a fast burst commit, full-solid trace, no more hiding. After the
        burst it fights like a normal aggressive (`hunt`) until either it
        disengages back to darkness (dark + far from the player for a
        sustained beat) or the player kills it."""
        s = self.sim
        d = ENEMIES["flicker"]
        px, py = self.player_pos()
        light_map = self._polygon_light_map()
        level = light_level_at(light_map, self.lighting.lights, polygon, ex, ey)

        if e["state"] == "lurk":
            e["trace_intensity"] = self._flicker_dormant_trace(e)
            if polygon == ppolygon:
                dist = math.hypot(px - ex, py - ey)
                if dist < d["ambush_radius"]:
                    self._set_enemy_state(eid, e, "ambush")
                    e["ambush_t"] = d["ambush_ticks"]
                    dx, dy = px - ex, py - ey
                    dl = math.hypot(dx, dy) or 1e-6
                    nx, ny = dx / dl, dy / dl
                    s.set_dir(eid, nx, ny)
                    s.set_vel(eid, nx * d["ambush_burst"], ny * d["ambush_burst"])
                    self._snd(d["alert_snd"], polygon, (ex, ey), 0.9)
                    self.fx.append(("alerted", polygon, ex, ey))
                    e["trace_intensity"] = 1.0
                    return
            # Reposition toward darkness ONLY while the current spot is
            # actually a lamp pool (debounced by `lurk_retarget_cd` so a
            # single bright tick doesn't cause thrashing) -- deliberately
            # NOT on a periodic cadence regardless of light level. Fail-
            # first note: an earlier version also retargeted whenever a
            # cooldown expired even while already dark, and once outside
            # every light's radius (level == 0.0 EXACTLY, not just low)
            # every one of the 8 sampled candidate directions ties at
            # 0.0 -- `min()`'s first-seen tie-break then always picked the
            # same candidate angle (index 0, "east"), so a lurker that had
            # already reached true darkness kept "repositioning" dead east
            # forever, one 44-unit hop per cooldown, with no bound. Caught
            # via tools/playtest/flicker_lurker_demo.py: the lurker walked
            # off its intended shadow spot over ~450 ticks and the player's
            # scripted approach never got within ambush range. The random
            # phase offset below (rather than always starting the angle
            # sweep at 0) is the belt-and-suspenders fix for the same tie-
            # break class in the remaining "actually bright" case.
            e["lurk_retarget_cd"] = e.get("lurk_retarget_cd", 0) - 1
            if level > self.LURK_MAX_LIGHT and e["lurk_retarget_cd"] <= 0:
                e["lurk_retarget_cd"] = self.rng.randrange(45, 90)
                phase = self.rng.uniform(0.0, 2.0 * math.pi)
                best = None
                for k in range(8):
                    a = phase + k * math.pi / 4.0
                    cand = (ex + math.cos(a) * 44.0, ey + math.sin(a) * 44.0)
                    lvl = light_level_at(light_map, self.lighting.lights, polygon, *cand)
                    if best is None or lvl < best[0]:
                        best = (lvl, cand)
                e["lurk_target"] = best[1]
            tx, ty = e.get("lurk_target", (ex, ey))
            dx, dy = tx - ex, ty - ey
            dist = math.hypot(dx, dy)
            if dist > 4.0:
                nx, ny = dx / dist, dy / dist
                sx, sy = s.terrain_avoid_dir(polygon, ex, ey, d["radius"], nx, ny, 44.0)
                s.set_dir(eid, nx, ny)
                s.set_vel(eid, sx * d["lurk_speed"], sy * d["lurk_speed"])
            else:
                s.set_vel(eid, evx * 0.8, evy * 0.8)
            return

        if e["state"] == "ambush":
            e["trace_intensity"] = 1.0
            e["ambush_t"] -= 1
            dx, dy = px - ex, py - ey
            dl = math.hypot(dx, dy) or 1e-6
            nx, ny = dx / dl, dy / dl
            s.set_dir(eid, nx, ny)
            s.set_vel(eid, evx + nx * d["accel"] * DT, evy + ny * d["accel"] * DT)
            if e["ambush_t"] <= 0:
                self._set_enemy_state(eid, e, "hunt")
                e["dark_beat"] = 0
            return

        # hunt: fights like a normal aggressive (husk-pattern seek/lunge)
        # until it can disengage back to darkness.
        e["trace_intensity"] = 1.0
        if polygon == ppolygon:
            dx, dy = px - ex, py - ey
            dist = math.hypot(dx, dy) or 1e-6
            nx, ny = dx / dist, dy / dist
            s.set_dir(eid, nx, ny)
            sx, sy = s.terrain_avoid_dir(polygon, ex, ey, d["radius"], nx, ny,
                                         max(40.0, min(dist, 120.0)))
            s.set_vel(eid, evx + sx * d["accel"] * DT, evy + sy * d["accel"] * DT)
            if level < d["disengage_light"] and dist > d["disengage_dist"]:
                e["dark_beat"] = e.get("dark_beat", 0) + 1
                if e["dark_beat"] > d["disengage_beat"]:
                    self._set_enemy_state(eid, e, "lurk")
                    e["dark_beat"] = 0
            else:
                e["dark_beat"] = 0
        else:
            edge = s.next_edge(polygon, ppolygon)
            if edge >= 0:
                mx_, my_ = s.edge_midpoint(polygon, edge)
                dx, dy = mx_ - ex, my_ - ey
                dist = math.hypot(dx, dy) or 1e-6
                nx, ny = dx / dist, dy / dist
                s.set_dir(eid, nx, ny)
                sx, sy = s.terrain_avoid_dir(polygon, ex, ey, d["radius"], nx, ny,
                                             max(40.0, min(dist, 120.0)))
                s.set_vel(eid, evx + sx * d["accel"] * DT, evy + sy * d["accel"] * DT)

    # ------------------------------------------------------------------

    def _consume_events(self, events):
        for ev in events:
            tag = ev[0]
            if tag == "transfer":
                _, ent, from_polygon, to_polygon, edge, m9 = ev
                if ent == self.pid:
                    ent_kind = "player"
                elif ent in self.enemies:
                    ent_kind = self.enemies[ent]["kind"]
                elif ent in self.bullets:
                    ent_kind = "bullet:" + self.bullets[ent]["kind"]
                else:
                    ent_kind = "other"
                self.trace.emit(PortalCrossing(
                    tick=self.tick_count, entity_id=ent, entity_kind=ent_kind,
                    from_polygon=from_polygon, to_polygon=to_polygon,
                    edge=edge))
                if ent == self.pid:
                    if self.cloister and to_polygon == self.cloister["sanctum"]:
                        self._rotate_cloister()
                    # camera re-base: zero visible change by construction
                    # (exact right-multiply of BOTH matrices -- see
                    # _cam_rebase; no re-rounding, so this can no longer
                    # disagree with the previous frame's pixel snap)
                    self._cam_rebase(m9)
                    self.metrics["transfers"] += 1
                    self.metrics["polygons_visited"].add(to_polygon)
            elif tag == "wall":
                _, ent, polygon, edge, px_, py_, nx, ny, speed = ev
                if ent == self.pid:
                    self._door_bump(polygon, edge)
                if polygon in self.soft_polygons:
                    b_ = self.bullets.get(ent)
                    if b_ is not None:
                        mag = 10.0 + 5.5 * float(b_.get("dmg", 0))
                    else:
                        e_ = self.enemies.get(ent)
                        mass = ENEMIES[e_["kind"]]["mass"] if e_ else 1.2
                        mag = min(90.0, 0.06 * mass * speed)
                    if mag > 1.0:
                        verts = self.sim.polygon_verts(polygon)
                        a_ = verts[edge]
                        b2_ = verts[(edge + 1) % len(verts)]
                        ex_, ey_ = b2_[0] - a_[0], b2_[1] - a_[1]
                        el2 = ex_ * ex_ + ey_ * ey_ or 1.0
                        t_ = ((px_ - a_[0]) * ex_ + (py_ - a_[1]) * ey_) / el2
                        self.sim.soft_wall_impulse(polygon, edge,
                                                   max(0.0, min(1.0, t_)), mag)
                b = self.bullets.get(ent)
                if b is not None and b["kind"] != "spit" \
                        and self.door_edges.get((polygon, edge)) == "shoot":
                    # a cracked wall gives way
                    for d in self.doors:
                        if not d["open"] and d["key"] == "shoot" and (
                                (d["a"], d["ea"]) == (polygon, edge)
                                or (d["b"], d["eb"]) == (polygon, edge)):
                            d["open"] = True
                            self.sim.connect(d["a"], d["ea"], d["b"], d["eb"])
                            self.trace.emit(TopologyChanged(
                                tick=self.tick_count, op="connect",
                                a_polygon=d["a"], a_edge=d["ea"],
                                b_polygon=d["b"], b_edge=d["eb"],
                                source="door_shoot"))
                            self.signals.on_topology_changed()
                            self.door_edges.pop((d["a"], d["ea"]), None)
                            self.door_edges.pop((d["b"], d["eb"]), None)
                            self._snd("door_unlock", polygon, (px_, py_))
                            self._decal(polygon, "scorch", px_, py_, 10.0)
                            self._shake(3.0)
                            self.pulse_light(polygon, (px_, py_), 220.0, 0.9)
                            break
                if b is not None:
                    if b["kind"] in ("tau", "taucharged") and b.get("bounces", 0) > 0:
                        b["bounces"] -= 1
                        self._snd("ricochet", polygon, (px_, py_), 0.5)
                        self.fx.append(("spark", polygon, px_, py_, nx, ny))
                        continue  # engine already reflected it (rest_wall=1)
                    if b["kind"] == "spit":
                        self._decal(polygon, "splat", px_, py_, 4.0)
                    elif b["kind"] == "dart":
                        self._detonate_dart(ent, polygon, px_, py_)
                    elif b["kind"] == "taucharged" and b.get("aoe"):
                        # full charge: the wall stops it, the burst still
                        # happens — anything near the impact point eats it
                        self._detonate_tau(ent, polygon, px_, py_, b)
                    elif b["kind"] == "bullet":
                        self._decal(polygon, "chip", px_, py_, 2.0)
                        self._snd("hit_wall", polygon, (px_, py_), 0.35)
                        self.fx.append(("spark", polygon, px_, py_, nx, ny))
                    self.sim.remove(ent)
                    self.bullets.pop(ent, None)
            elif tag == "contact":
                _, a, b, cx, cy, nx, ny, rel = ev
                self._contact(a, b, cx, cy, nx, ny)

    def _door_bump(self, polygon: int, edge: int):
        """The player pressed against a locked door: name the mechanism
        and the object it wants. Rate-limited per key id — the prompt
        holds ~4s on screen; re-arm after 5s of continued shoving."""
        key = self.door_edges.get((polygon, edge))
        if not key or key == "shoot" or key in self.keys:
            return
        last = self._door_prompt_at.get(key)
        if last is not None and self.tick_count - last < 300:
            return
        self._door_prompt_at[key] = self.tick_count
        prompt = ""
        for d in self.doors:
            if not d["open"] and d["key"] == key and (
                    (d["a"], d["ea"]) == (polygon, edge)
                    or (d["b"], d["eb"]) == (polygon, edge)):
                prompt = d.get("gate_prompt", "")
                break
        self._objective(prompt or f"DOOR SEALED - {key.upper()} SEAL REQUIRED")

    def _contact(self, a: int, b: int, cx: float, cy: float, nx: float, ny: float):
        # normalize order: identify roles
        for x, y in ((a, b), (b, a)):
            bx = self.bullets.get(x)
            if bx is not None and y in self.enemies:
                if bx["kind"] == "dart":
                    polygon = self.sim.get_polygon(x) if self.sim.exists(x) \
                        else self.sim.get_polygon(y)
                    self._detonate_dart(x, polygon, cx, cy)
                elif bx["kind"] in ("bullet", "tau", "taucharged", "turret"):
                    self._damage_enemy(y, bx["dmg"],
                                       (nx if x == b else -nx,
                                        ny if x == b else -ny),
                                       bx.get("imp", 90.0), source=bx["kind"])
                    if bx["kind"] == "taucharged" and bx.get("aoe"):
                        # full charge detonates on the body it struck:
                        # the small AoE catches the neighbors (the direct
                        # target already took full damage + push above)
                        polygon = self.sim.get_polygon(y) if self.sim.exists(y) \
                            else self.sim.get_polygon(x)
                        self._detonate_tau(x, polygon, cx, cy, bx, skip=y)
                self.sim.remove(x)
                self.bullets.pop(x, None)
                return
            if bx is not None and y == self.pid:
                polygon = self.sim.get_polygon(y)
                if bx["kind"] == "spit":
                    self._damage_player(bx["dmg"], polygon, source="spit")
                elif bx["kind"] == "dart":
                    self._detonate_dart(x, polygon, cx, cy)
                    px_, py_ = self.player_pos()
                    self._damage_player(WEAPONS["lightning"]["dmg"] * 0.6,
                                        polygon, source="lightning_self")
                elif bx["kind"] == "turret":
                    pass  # the guardians do not miss that badly
                elif self.tick_count - bx.get("born", -99) <= 2:
                    # spawn-resolution artifact, not a returned round:
                    # a fresh round shoved back into its shooter by
                    # wall/portal overlap resolution (ground-truth
                    # trace 2026-07-19 — the fastest LEGITIMATE
                    # return, a fold wrap, takes 6+ ticks). Dies
                    # silently.
                    pass
                else:
                    # a round you fired found its way back through the fold
                    self._damage_player(bx["dmg"] * 0.75, polygon,
                                        source="returned_round")
                self.sim.remove(x)
                self.bullets.pop(x, None)
                return
        if a == self.pid or b == self.pid:
            eid = b if a == self.pid else a
            e = self.enemies.get(eid)
            if e and e["touch_cd"] <= 0:
                d = ENEMIES[e["kind"]]
                if d["touch_dmg"] > 0:
                    e["touch_cd"] = d["touch_cd"]
                    self._damage_player(
                        d["touch_dmg"],
                        self.sim.get_polygon(self.pid),
                        source="contact:" + e["kind"])

    # ------------------------------------------------------------------

    @staticmethod
    def _outside_by(px: float, py: float, verts) -> float:
        """Signed clearance: <= 0 inside the convex polygon, > 0 = distance
        past the most-violated wall. Winding-independent."""
        n = len(verts)
        area2 = sum(verts[i][0] * verts[(i + 1) % n][1] -
                    verts[(i + 1) % n][0] * verts[i][1] for i in range(n))
        sgn = 1.0 if area2 > 0 else -1.0
        worst = -1e18
        for i in range(n):
            ax, ay = verts[i]
            bx, by = verts[(i + 1) % n]
            el = math.hypot(bx - ax, by - ay) or 1e-9
            cr = ((bx - ax) * (py - ay) - (by - ay) * (px - ax)) / el * sgn
            worst = max(worst, -cr)
        return worst

    def _containment_sweep(self, ppolygon: int) -> None:
        """Entities must never exist outside their polygon's polygon. The
        engine's collision guarantees this in normal play, but a crowded
        shove at a carved door jamb can press an entity through a wall
        (soak seed 1993: a fleeing shrieker escaped the mirror ward and
        drifted 14k units out, untargetable, wedging the run). Recover
        escapees to the polygon centroid and say so loudly -- this is
        damage control for an engine bug, not normal flow."""
        verts_all = self.level.polygon_verts
        streaks = getattr(self, "_outside_streaks", None)
        if streaks is None:
            streaks = self._outside_streaks = {}
        for eid in (self.pid, *list(self.enemies)):
            if not self.sim.exists(eid):
                streaks.pop(eid, None)
                continue
            polygon, x, y, *_ = self.sim.get(eid)
            if polygon >= len(verts_all):
                continue
            off = self._outside_by(x, y, verts_all[polygon])
            if off <= 25.0:
                streaks.pop(eid, None)
                continue
            # persistence gate: a door-crush can press entities 25-50u out
            # and physics reclaims them when the crowd shifts — recovering
            # those mid-fight destabilizes the finale (soak2: 54/985 runs
            # wedged by recovery churn vs 1/1894 baseline). A true escape
            # (bad transfer from an out-of-polygon position) stays outside
            # every sweep forever; only that persistent signature recovers.
            streaks[eid] = streaks.get(eid, 0) + 1
            if streaks[eid] >= 6:  # 6 sweeps = 3 seconds continuously out
                streaks.pop(eid, None)
                # recovery target MUST come from the same frame as the
                # verts: level.polygon_centroids is authored-frame bookkeeping
                # and teleporting there re-corrupts (that bug ate this
                # sweep's first version)
                vs = verts_all[polygon]
                cx = sum(v[0] for v in vs) / len(vs)
                cy = sum(v[1] for v in vs) / len(vs)
                self.sim.set_pos(eid, cx, cy)
                self.sim.set_vel(eid, 0.0, 0.0)
                self.metrics["containment_recoveries"] = \
                    self.metrics.get("containment_recoveries", 0) + 1
                import sys as _sys
                print(f"[sim] CONTAINMENT: entity {eid} "
                      f"({'player' if eid == self.pid else self.enemies.get(eid, {}).get('kind', '?')}) "
                      f"was {off:.1f}u outside polygon {polygon} at ({x:.0f},{y:.0f}); "
                      f"recovered to centroid", file=_sys.stderr)

    def _pickup_scan(self, ppolygon: int):
        px, py = self.player_pos()
        for eid in list(self.sim.polygon_entities(ppolygon)):
            p = self.pickups.get(eid)
            if p is None:
                continue
            _, x, y, *_ = self.sim.get(eid)
            if math.hypot(x - px, y - py) > PLAYER_RADIUS + PICKUPS[p["kind"]]["radius"] + 2.0:
                continue
            kind = p["kind"]
            if kind.startswith("ammo_"):
                t = kind[5:]
                amt = int(PICKUPS[kind]["amount"] * self._ammo_mul)
                self.ammo[t] = self.ammo.get(t, 0) + amt
                self._snd("pickup_ammo", ppolygon, (x, y))
                self.fx.append(("pickup_text", ppolygon, (x, y),
                                f"+{amt} {t.upper()}"))
            elif kind == "medkit":
                if self.hp > 70:
                    continue  # leave it for later — scarcity respects foresight
                self.hp = min(self.max_hp, self.hp + PICKUPS[kind]["amount"])
                self._snd("pickup_medkit", ppolygon, (x, y))
                self.fx.append(("pickup_text", ppolygon, (x, y),
                                f"+{PICKUPS[kind]['amount']} INTEGRITY"))
            elif kind.startswith("weapon_"):
                w = kind[7:]
                if w not in self.weapons:
                    self.weapons.append(w)
                    self.weapon = w
                self.ammo_bonus_for(w)
                self._snd("pickup_ammo", ppolygon, (x, y))
                self._acquired(w)
            elif kind == "safe_polygon_core":
                self._build_cloister()
                if "hole" not in self.weapons:
                    self.weapons.append("hole")
                self.holes += 2
                self._snd("pickup_key", ppolygon, (x, y))
                self._acquired("cloister")
            elif kind == "turret":
                continue  # not a pickup; the guardians are furniture
            elif kind == "portable_hole":
                self.holes += 1 + self._hole_bonus
                if "hole" not in self.weapons:
                    self.weapons.append("hole")
                self._snd("pickup_key", ppolygon, (x, y))
                self._acquired("hole")
            elif kind == "implant_lightning":
                if "lightning" not in self.weapons:
                    self.weapons.append("lightning")
                self._snd("pickup_key", ppolygon, (x, y))
                self._acquired("lightning")
            elif kind == "components":
                n = p.get("amount", 1)
                self.components += n
                self._snd("pickup_ammo", ppolygon, (x, y))
                self.fx.append(("pickup_text", ppolygon, (x, y),
                                f"+{n} COMPONENTS"))
            elif kind == "corpse_frame":
                c = p.get("contents", {})
                self.components += c.get("components", 0)
                self.station_kits += c.get("station_kits", 0)
                self._snd("corpse_recover", ppolygon, (x, y))
                got = []
                if c.get("components"):
                    got.append(f"+{c['components']} COMPONENTS")
                if c.get("station_kits"):
                    got.append(f"+{c['station_kits']} SEED KIT")
                self.fx.append(("pickup_text", ppolygon, (x, y),
                                "FRAME RECOVERED  " + "  ".join(got)))
                self.fx.append(("logvoice", p.get("line", 0)))
            elif kind.startswith("key_"):
                key = kind[4:]
                self.keys.add(key)
                self._snd("pickup_key", ppolygon, (x, y))
                meta = p.get("meta")
                self.fx.append(("pickup_text", ppolygon, (x, y),
                                meta.item_name if meta
                                else f"{key.upper()} SEAL"))
                if meta:
                    self.held_key_meta[key] = meta
                    self._objective(meta.acquire_prompt)
                self._unlock_doors(key)
            self.metrics["pickups"] += 1
            self.sim.remove(eid)
            self.pickups.pop(eid, None)

    def ammo_bonus_for(self, w: str):
        bonus = {"smg": ("9mm", 30), "shotgun": ("shell", 8), "rail": ("cell", 6),
                 "tau": ("cell", 10)}
        if w in bonus:
            t, n = bonus[w]
            self.ammo[t] = self.ammo.get(t, 0) + n

    def _unlock_doors(self, key: str):
        for d in self.doors:
            if d["key"] == key and not d["open"]:
                d["open"] = True
                self.sim.connect(d["a"], d["ea"], d["b"], d["eb"])
                self.trace.emit(TopologyChanged(
                    tick=self.tick_count, op="connect", a_polygon=d["a"],
                    a_edge=d["ea"], b_polygon=d["b"], b_edge=d["eb"],
                    source="door_unlock"))
                self.signals.on_topology_changed()
                self.door_edges.pop((d["a"], d["ea"]), None)
                self.door_edges.pop((d["b"], d["eb"]), None)
                mx, my = self.sim.edge_midpoint(d["a"], d["ea"])
                self._snd("door_unlock", d["a"], (mx, my))

    # ------------------------------------------------------------------
    # the revival economy: seed stations, the fabricator, chassis reprint
    # ------------------------------------------------------------------

    STATION_RADIUS = 30.0

    def add_station(self, polygon: int, pos) -> None:
        """Register a seed station (chunk-entry seeds are planted by the
        streamer; the player plants forward seeds with kits, 9.3)."""
        for st in self.stations:
            if st["polygon"] == polygon and \
                    math.hypot(st["pos"][0] - pos[0], st["pos"][1] - pos[1]) < 24.0:
                return
        self.stations.append(dict(polygon=polygon, pos=(pos[0], pos[1])))

    def station_near(self, ppolygon: int):
        px, py = self.player_pos()
        for st in self.stations:
            if st["polygon"] == ppolygon and \
                    math.hypot(st["pos"][0] - px, st["pos"][1] - py) < self.STATION_RADIUS:
                return st
        return None

    def _park_oob(self, mark: int) -> None:
        """Menu-time calls emit fx between ticks; park those events so the
        next tick delivers them instead of the tick-start clear eating them."""
        self._oob_fx.extend(self.fx[mark:])
        del self.fx[mark:]

    def place_station(self) -> bool:
        if self.station_kits <= 0:
            return False
        mark = len(self.fx)
        ppolygon = self.player_polygon()
        px, py = self.player_pos()
        self.station_kits -= 1
        self.add_station(ppolygon, (px, py))
        self._snd("seed_plant", ppolygon, (px, py))
        self._objective("SEED PLANTED - REVIVAL ANCHORED HERE")
        self._park_oob(mark)
        return True

    def buy(self, item: str) -> bool:
        d = SHOP[item]
        cost = d["cost"] + d.get("growth", 0) * (self.hp_ups if item == "hp_up" else 0)
        if self.components < cost:
            return False
        self.components -= cost
        if item == "chassis":
            self.chassis += 1
        elif item == "station_kit":
            self.station_kits += 1
        elif item == "hp_up":
            self.hp_ups += 1
            self.max_hp += 15
            self.hp = min(self.max_hp, self.hp + 15)
        elif item == "recall":
            self.recalls += 1
        elif "ammo" in d:
            t, n = d["ammo"]
            self.ammo[t] = self.ammo.get(t, 0) + n
        mark = len(self.fx)
        ppolygon = self.player_polygon()
        self._snd("fabricate_buy", ppolygon, self.player_pos())
        self.fx.append(("pickup_text", ppolygon, self.player_pos(),
                        f"-{cost} COMPONENTS"))
        self._park_oob(mark)
        return True

    def shop_price(self, item: str) -> int:
        d = SHOP[item]
        return d["cost"] + d.get("growth", 0) * (self.hp_ups if item == "hp_up" else 0)

    def use_recall(self) -> bool:
        """Open the recall channel (app keybind). 90 ticks of standing
        still enough not to get hit, then the nearest seed takes you."""
        if self.recalls <= 0 or self.recall_t > 0 or self.dead \
                or not self.stations:
            return False
        mark = len(self.fx)
        self.recall_t = 90
        self._objective("RECALL CHANNEL OPEN - ANY HIT SEVERS IT")
        self._snd("terminal_open", self.player_polygon(), self.player_pos())
        self._park_oob(mark)
        return True

    def _recall_tick(self, ppolygon: int) -> None:
        if self.recall_t <= 0:
            return
        self.recall_t -= 1
        if self.recall_t > 0:
            return
        # channel held: the beacon spends itself and the seed takes you
        self.recalls -= 1
        px, py = self.player_pos()
        best = min(self.stations,
                   key=lambda st: (self.sim.hop_distance(st["polygon"], ppolygon)
                                   if self.sim.hop_distance(st["polygon"], ppolygon) >= 0
                                   else 1 << 20))
        polygon, (tx, ty) = best["polygon"], best["pos"]
        self.pulse_light(ppolygon, (px, py), 260.0, 1.0, (180, 235, 255))
        if ppolygon != polygon:
            self.reseat_player(polygon, (tx, ty))
        else:
            self.sim.set_pos(self.pid, tx, ty)
        self.sim.set_vel(self.pid, 0.0, 0.0)
        self._set_cam(necore.mat_mul(
            necore.mat_mul(
                necore.mat_translate(self.screen_w / 2, self.screen_h / 2),
                necore.mat_scale(self.zoom, self.zoom)),
            necore.mat_translate(-tx, -ty)))
        self._snd("reprint", polygon, (tx, ty))
        self._objective("RECALLED TO THE SEED")

    # ------------------------------------------------------------------
    # the mind map: thinking-as-time and effect wiring (9.2 + seed-pod UI)
    # ------------------------------------------------------------------

    def set_focus(self, node_id: str) -> bool:
        """Choose what the Commando thinks about in the field (pod call,
        menu-time). Frontier nodes only; no component cost. Switching
        focus parks the old node's progress -- thought is never lost."""
        from . import mindmap
        if node_id in self.think_done:
            return False  # already finished; awaits its reveal
        if not mindmap.available(self.mind, node_id):
            return False
        if self.think_focus == node_id:
            return True
        self.think_focus = node_id
        mark = len(self.fx)
        self._snd("terminal_type", self.player_polygon(), self.player_pos(), 0.6)
        self._park_oob(mark)
        return True

    def _think_tick(self, ppolygon: int) -> None:
        """One field tick of background rumination on the focus node.
        Runs ONLY from tick() (menus don't tick -- thinking happens out
        there, under fire, diegetically). Completion emits a quiet field
        cue; the unlock itself waits for the pod reveal."""
        if self.think_focus is None:
            return
        from . import mindmap
        nid = self.think_focus
        p = self.think_progress.get(nid, 0) + 1
        self.think_progress[nid] = p
        if p >= mindmap.think_ticks(nid):
            self.think_focus = None
            self.think_done.append(nid)
            # quiet: a thought has finished (sfx placeholder; pipeline)
            self._snd("think_complete", ppolygon, self.player_pos(), 0.6)
            self.fx.append(("thought_done", nid))

    def complete_focus(self, node_id: str) -> bool:
        """The pod reveal calls this at its ignition: fold a
        finished thought into the mind and wire its effects. This -- not
        field completion -- is the moment of unlock (the reveal is the
        reward)."""
        from . import mindmap
        if node_id not in self.think_done:
            return False
        self.think_done.remove(node_id)
        self.think_progress.pop(node_id, None)
        self.mind.add(node_id)
        self._recompute_mind()
        mark = len(self.fx)
        ppolygon = self.player_polygon()
        self._snd("pickup_key", ppolygon, self.player_pos())
        label = mindmap.nodes()[node_id]["label"]
        self._objective(f"INTEGRATED: {label.upper()}")
        self._park_oob(mark)
        return True

    def pod_heal(self) -> bool:
        """Entering the seed pod heals the frame (SEEDPOD_UI_DESIGN.md:
        the pod is where the Commando heals, upgrades, and thinks)."""
        if self.dead or self.hp >= self.max_hp:
            return False
        self.hp = self.max_hp
        mark = len(self.fx)
        self._snd("pickup_medkit", self.player_polygon(), self.player_pos(), 0.8)
        self._objective("FRAME INTEGRITY RESTORED")
        self._park_oob(mark)
        return True

    @property
    def faith(self) -> int:
        from . import mindmap
        return mindmap.faith_score(self.mind)

    def _recompute_mind(self) -> None:
        """Fold the purchased nodes' unlock keys into flat combat numbers,
        recomputed whole on every purchase. Keys with no combat meaning
        here (dialogue depth, intel translation, beacons) are read by the
        app/dialogue layers straight from `self.mind`."""
        from . import mindmap
        u = mindmap.unlocks(self.mind)
        self.mind_unlocks = u
        dmg = 1.0
        if "blessed_rounds_dmg_adversary" in u:
            dmg *= 1.20   # everything that walks here is Adversary biology
        if "monstrous_power_1" in u:
            dmg *= 1.15
        self._dmg_out_mul = dmg
        # legitimate targets: bonus only against enemies bearing down on
        # you (state != idle) -- sleepers are not yet combatants
        self._target_mark_mul = 1.10 if "target_mark_1" in u else 1.0
        self._spread_mul = 0.75 if "recoil_control_1" in u else 1.0
        self._armor_mul = 0.85 if "shield_charge_1" in u else 1.0
        self._accel_mul = (1.0
                           * (1.08 if "overclock_1" in u else 1.0)
                           * (1.07 if "overclock_2" in u else 1.0)
                           * (1.05 if "monstrous_power_1" in u else 1.0))
        if "weakpoint_scan_2" in u:
            self._crit_p, self._crit_mul = 0.20, 2.0
        elif "weakpoint_scan_1" in u:
            self._crit_p, self._crit_mul = 0.10, 1.75
        else:
            self._crit_p, self._crit_mul = 0.0, 1.0
        self._salvage_mul = 1.5 if "salvage_yield_1" in u else 1.0
        self._ammo_mul = 1.25 if "faction_tech_mk1" in u else 1.0
        if "adversary_organ_slot_2" in u:
            self._regen_cap_frac, self._regen_rate = 0.75, 1
        elif "adversary_organ_slot_1" in u:
            self._regen_cap_frac, self._regen_rate = 0.50, 1
        else:
            self._regen_cap_frac, self._regen_rate = 0.0, 0
        self._protected_revival = "protected_revival" in u
        self._hole_bonus = 1 if "hole_stability_1" in u else 0

    def reseat_player(self, polygon: int, pos) -> None:
        """Move the player's engine entity to another polygon (engine set_pos
        does not move polygon membership; respawn under the same groups)."""
        st = self.sim.get(self.pid)
        self.sim.remove(self.pid)
        self.pid = self.sim.spawn(polygon, pos[0], pos[1], PLAYER_RADIUS,
                                  PLAYER_MASS, GROUP_PLAYER)
        self.sim.set_props(self.pid, rest_wall=0.0, rest_ent=0.05,
                           max_substep=6.0)
        self.sim.set_dir(self.pid, st[5], st[6])

    def respawn_at_station(self) -> bool:
        """Chassis path: a racked hull prints at the nearest seed station.
        The world stays exactly as it lies -- enemies, doors, and the wreck
        you just left. Returns False with no chassis or no station (the
        caller falls back to the cold restore)."""
        if self.chassis <= 0 or not self.stations:
            return False
        death_polygon = self.player_polygon()
        best = min(self.stations,
                   key=lambda st: (self.sim.hop_distance(st["polygon"], death_polygon)
                                   if self.sim.hop_distance(st["polygon"], death_polygon) >= 0
                                   else 1 << 20))
        self.chassis -= 1
        for eid in list(self.bullets):
            self.sim.remove(eid)
        self.bullets.clear()
        polygon, (px, py) = best["polygon"], best["pos"]
        if self.player_polygon() != polygon:
            self.reseat_player(polygon, (px, py))
        else:
            self.sim.set_pos(self.pid, px, py)
        self.sim.set_vel(self.pid, 0.0, 0.0)
        self.hp = self.max_hp
        self.dead = False
        self.freeze = 0
        self.tau_charge = 0
        self.hole_mark = None
        self._set_cam(necore.mat_mul(
            necore.mat_mul(
                necore.mat_translate(self.screen_w / 2, self.screen_h / 2),
                necore.mat_scale(self.zoom, self.zoom)),
            necore.mat_translate(-px, -py)))
        mark = len(self.fx)
        self._objective(f"REPRINTED - {self.chassis} CHASSIS RACKED")
        self._snd("reprint", polygon, (px, py))
        self._park_oob(mark)
        return True

    def _station_scan(self, ppolygon: int, inp: InputFrame):
        if not inp.interact:
            return
        if self.station_near(ppolygon) is not None:
            self.fx.append(("shop",))

    def _terminal_scan(self, ppolygon: int, inp: InputFrame):
        if not inp.interact:
            return
        px, py = self.player_pos()
        for t in self.terminals:
            if t["polygon"] != ppolygon or t["read"]:
                continue
            if math.hypot(t["pos"][0] - px, t["pos"][1] - py) < 26.0:
                t["read"] = True
                self.fx.append(("terminal", t["text"]))
                self._snd("terminal_open", ppolygon, t["pos"])

    def _exit_scan(self, ppolygon: int):
        if not getattr(self, "exit_enabled", True):
            return
        if self.exit_polygon < 0:
            return
        px, py = self.player_pos()
        near = (ppolygon == self.exit_polygon and
                math.hypot(self.exit_pos[0] - px, self.exit_pos[1] - py) < 18.0)
        if not near:
            # prompts are transient (~4s): stepping away and coming back to
            # a still-sealed exit re-explains it
            self._objective_fired.discard("exit_locked")
            self._objective_fired.discard("exit_gated")
            return
        lvl = self.level
        if lvl.exit_key and lvl.exit_key not in self.keys:
            if "exit_locked" not in self._objective_fired:
                self._objective_fired.add("exit_locked")
                self._objective(
                    self.exit_gate_prompt
                    or f"EXIT SEALED - {lvl.exit_key.upper()} SEAL REQUIRED")
            return
        gate_polygons = getattr(self, "exit_gate_polygons", None)

        def _gates(eid, e):
            if e["kind"] != lvl.exit_gate_kind:
                return False
            if gate_polygons is None:
                return True
            r = self.sim.get_polygon(eid)
            return gate_polygons[0] <= r < gate_polygons[1]

        if lvl.exit_gate_kind and any(
                _gates(eid, e) for eid, e in self.enemies.items()):
            if "exit_gated" not in self._objective_fired:
                self._objective_fired.add("exit_gated")
                self._objective(f"EXIT SEALED - THE "
                                f"{lvl.exit_gate_kind.upper()} HOLDS THE DOOR")
            return
        self.complete = True
        self.metrics["completed"] = True

    # ------------------------------------------------------------------
    # bullets ttl (called from tick loop indirectly, cheap sweep)
    # ------------------------------------------------------------------

    def sweep_bullets(self):
        for bid in list(self.bullets):
            b = self.bullets[bid]
            b["ttl"] -= 1
            dead = b["ttl"] <= 0
            if not dead and b["kind"] in ("bullet", "tracer", "turret"):
                # WOUNDED-ROUND GUARD (2026-07-19, ground-truth trace
                # of bullet 429/seed 2200): a round spawned grazing a
                # wall loses its aim velocity to spawn-overlap
                # resolution WITHOUT the wall event that despawns
                # bullets, and survives as a ~120u/s drifter carrying
                # the shooter's inherited velocity — measured as ~40%
                # of ALL damage the player took (the round hits its
                # own shooter ~0.5-1s later). Straight rounds fly at
                # constant speed by design: any round at a fraction
                # of muzzle velocity has already hit something and
                # must not exist. (tau/taucharged excluded: ricochets
                # are designed; spit/dart fly slow by design.)
                if self.sim.exists(bid):
                    _, _, _, bvx, bvy, _, _ = self.sim.get(bid)
                    if bvx * bvx + bvy * bvy < 490000.0:   # <700 u/s
                        dead = True
            if dead:
                if b["kind"] == "dart" and self.sim.exists(bid):
                    _, x, y, *_ = self.sim.get(bid)
                    self._detonate_dart(bid, self.sim.get_polygon(bid), x, y)
                self.sim.remove(bid)
                del self.bullets[bid]

    # ------------------------------------------------------------------
    # queries for renderer / bots / tests
    # ------------------------------------------------------------------

    # Apex clamp margin: keeps the visibility apex a comfortable positive
    # distance inside the current polygon's polygon (any positive value clears
    # the "apex behind the portal line" hard cull from transfer overshoot;
    # see visible()). MUST STAY STRICTLY LESS than the engine's own
    # visibility::EDGE_BAND (currently 1.0, engine/necore/src/visibility.rs)
    # -- that constant's job is to widen a near-doorway sightline into a
    # full 180-degree fan BEFORE the polygon re-roots, so the pre-crossing
    # render already matches what root will show. If this margin ever grew
    # to meet or exceed EDGE_BAND, the clamped apex would sit pinned
    # exactly on/outside that band on every approach tick, `wide` could
    # never trigger pre-crossing, and doorway jamb walls (collinear with
    # the portal line, clipped away by the resulting narrow wedge) would
    # pop from absent to fully lit in the single tick the polygon re-roots --
    # this was a real, shipped bug; see game/tests/test_root_invariance.py.
    _APEX_EPS = 0.75

    def _clamp_apex(self, polygon: int, px: float, py: float):
        """Pull the visibility apex just inside `polygon`'s polygon. For 1-3
        ticks after a portal transfer the entity is registered in the new
        polygon while its position still sits marginally OUTSIDE it (collision
        overshoot; physics reclaims it). An exterior apex makes the
        traversal's sight-line cull discard the entry portal -- the polygon
        you just left, and everything behind it, blinks out for those
        ticks. At every doorway, constantly: the campaign-video flicker."""
        verts = self.sim.polygon_verts(polygon)
        n = len(verts)
        for i in range(n):
            x1, y1 = verts[i]
            x2, y2 = verts[(i + 1) % n]
            ex, ey = x2 - x1, y2 - y1
            ln = math.hypot(ex, ey)
            if ln < 1e-9:
                continue
            # inward normal for this vertex winding (verified empirically
            # in test_economy's clamp tests: interior points are fixpoints)
            nx_, ny_ = ey / ln, -ex / ln
            d = (px - x1) * nx_ + (py - y1) * ny_
            if d < self._APEX_EPS:
                push = self._APEX_EPS - d
                px += nx_ * push
                py += ny_ * push
        return px, py

    def visible(self, max_depth: int = 14, max_instances: int = 96):
        ppolygon = self.player_polygon()
        px, py = self.player_pos()
        # the camera apex is the player (strict LOS from the character),
        # clamped into the polygon so mid-transfer overshoot can't blind it
        px, py = self._clamp_apex(ppolygon, px, py)
        # keep the frame's attached work lamp on the player: same clamped apex,
        # so its visibility cast can never start outside the polygon either
        self.player_light.polygon = ppolygon
        self.player_light.pos = (px, py)
        self.player_light.dir = self.aim
        self.player_lamp.polygon = ppolygon
        self.player_lamp.pos = (px, py)
        if self.muzzle_light.intensity > 0.0:
            self.muzzle_light.polygon = ppolygon
        return self.sim.visible_set(ppolygon, self.cam, px, py,
                                    float(self.screen_w), float(self.screen_h),
                                    max_depth, max_instances)

    def _gate_count(self) -> int:
        kind = self.level.exit_gate_kind
        if not kind:
            return 0
        rng = getattr(self, "exit_gate_polygons", None)
        n = 0
        for eid, e in self.enemies.items():
            if e["kind"] != kind:
                continue
            if rng is not None:
                r = self.sim.get_polygon(eid)
                if not (rng[0] <= r < rng[1]):
                    continue
            n += 1
        return n

    def sight_map(self, polygon: int, x: float, y: float,
                  radius: float = 700.0, max_depth: int = 4,
                  max_instances: int = 24) -> list:
        """The renderer's own portal-clipped visibility from an
        arbitrary viewpoint, served to the AI (director 2026-07-19:
        'that shadow-solving information has already been calculated
        by the rendering engine — save it and make it available').
        Same engine query the lighting system uses for occlusion.

        Returns a list of dicts, one per visible polygon instance:
          polygon: the polygon id seen
          xform:   matrix mapping that polygon's LOCAL frame into the
                   viewer-centred frame (viewer at the origin)
          clip:    the visible region of that instance, as a polygon
                   in the viewer-centred frame
        A point P (local to polygon Q) is visible from the viewpoint
        iff some instance with polygon==Q maps P (via xform) inside
        its clip. The complement of the clips is shadow — real cover,
        by the same math that decides what draws on screen."""
        pad = radius * 0.1
        win = 2.0 * (radius + pad)
        off = radius + pad
        cam = necore.mat_translate(off - x, off - y)
        raw = self.sim.visible_set(polygon, cam, x, y, win, win,
                                   max_depth, max_instances)
        out = []
        for poly, xform, _depth, clip_screen, _w, _e, _ents in raw:
            if len(clip_screen) < 3:
                continue
            out.append(dict(
                polygon=poly,
                xform=necore.mat_mul(
                    necore.mat_translate(-off, -off), xform),
                clip=tuple((cx - off, cy - off)
                           for cx, cy in clip_screen)))
        return out

    @staticmethod
    def point_in_sight(sight: list, polygon: int,
                       px: float, py: float) -> bool:
        """Is local point (px, py) of `polygon` visible in `sight`
        (a `sight_map` result)? Standard even-odd test against each
        matching instance's clip region."""
        for inst in sight:
            if inst["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(inst["xform"], px, py)
            verts = inst["clip"]
            n = len(verts)
            inside = False
            j = n - 1
            for i in range(n):
                xi, yi = verts[i]
                xj, yj = verts[j]
                if (yi > sy) != (yj > sy) and \
                        sx < (xj - xi) * (sy - yi) / ((yj - yi) or 1e-12) + xi:
                    inside = not inside
                j = i
            if inside:
                return True
        return False

    def _spit_snapshot(self, ppolygon: int) -> list:
        """Enemy projectiles in the player's polygon — a human SEES spit
        flying at them; bots read the same honest snapshot boundary."""
        out = []
        s = self.sim
        for bid, b in self.bullets.items():
            if b.get("kind") != "spit":
                continue
            try:
                r = s.get_polygon(bid)
            except Exception:
                continue
            if r != ppolygon:
                continue
            _, x, y, vx, vy, _, _ = s.get(bid)
            out.append(dict(pos=(x, y), vel=(vx, vy)))
        return out

    def snapshot(self) -> dict:
        ppolygon = self.player_polygon()
        px, py = self.player_pos()
        enemies = []
        for eid, e in self.enemies.items():
            r = self.sim.get_polygon(eid)
            _, x, y, *_ = self.sim.get(eid)
            enemies.append(dict(id=eid, kind=e["kind"], polygon=r, pos=(x, y),
                                hp=e["hp"], state=e["state"],
                                hops=self.sim.hop_distance(r, ppolygon)))
        pickups = []
        for eid, p in self.pickups.items():
            r = self.sim.get_polygon(eid)
            _, x, y, *_ = self.sim.get(eid)
            pickups.append(dict(id=eid, kind=p["kind"], polygon=r, pos=(x, y),
                                hops=self.sim.hop_distance(r, ppolygon)))
        return dict(
            tick=self.tick_count, hp=self.hp, dead=self.dead,
            complete=self.complete, polygon=ppolygon, pos=(px, py),
            weapon=self.weapon, weapons=list(self.weapons), ammo=dict(self.ammo),
            keys=set(self.keys),
            lightning_ready=self.lightning_charge >= LIGHTNING_RECHARGE_TICKS,
            holes=self.holes, tau_charge=self.tau_charge,
            components=self.components, chassis=self.chassis,
            station_kits=self.station_kits, max_hp=self.max_hp,
            recalls=self.recalls, recall_t=self.recall_t,
            mind=set(self.mind), faith=self.faith,
            think_focus=self.think_focus,
            think_progress=dict(self.think_progress),
            think_done=list(self.think_done),
            stations=[dict(polygon=st["polygon"], pos=st["pos"])
                      for st in self.stations],
            cloister=(dict(links=len(self.cloister["links"]),
                           attached=self.cloister["attached"])
                      if self.cloister else None),
            enemies=enemies, pickups=pickups,
            spits=self._spit_snapshot(ppolygon),
            exit_polygon=self.exit_polygon,
            exit_next_edge=self.sim.next_edge(ppolygon, self.exit_polygon)
            if self.exit_polygon >= 0 else -1,
            exit_key_needed=self.level.exit_key
            if self.level.exit_key and self.level.exit_key not in self.keys
            else "",
            exit_gate_kind=self.level.exit_gate_kind,
            exit_gate_remaining=self._gate_count(),
            exit_gate_polygons=getattr(self, "exit_gate_polygons", None),
            door_keys_needed=sorted(
                {d["key"] for d in self.doors if not d["open"] and d["key"]}
                - self.keys),
        )
