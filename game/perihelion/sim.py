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
from .lighting import LightingSystem

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
WEAPONS: dict[str, dict] = {
    "knife": dict(dmg=9, cd=22, ammo=None, sound="knife_swing", range=27.0, arc=math.radians(55)),
    "pistol": dict(dmg=12, cd=20, speed=1500.0, spread=math.radians(1.6), pellets=1,
                   ammo="9mm", per=1, sound="pistol_fire", kick=2.2),
    "smg": dict(dmg=7, cd=6, speed=1350.0, spread=math.radians(5.5), pellets=1,
                ammo="9mm", per=1, sound="smg_fire", kick=1.6),
    "shotgun": dict(dmg=6, cd=54, speed=1150.0, spread=math.radians(11.0), pellets=8,
                    ammo="shell", per=1, sound="shotgun_fire", kick=7.0),
    "rail": dict(dmg=42, cd=84, ammo="cell", per=1, sound="rail_fire", pierce=3, kick=5.0),
    "lightning": dict(dmg=26, cd=None, speed=720.0, sound="lightning_fire",
                      radius=110.0, force=1500.0),
    "tau": dict(dmg=9, cd=7, speed=1900.0, spread=math.radians(2.0), pellets=1,
                ammo="cell", per=1, sound="tau_fire", kick=2.6, bounces=2),
    "hole": dict(cd=18, sound="terminal_open"),
    # weaponize what's at hand: the scrap driver fires your salvage as
    # shot (ammo IS the currency), printed at any fabricator
    "scrap": dict(dmg=13, cd=46, speed=980.0, spread=math.radians(8.5),
                  pellets=3, ammo="components", per=2,
                  sound="scrap_fire", kick=5.5),
    # a harvested spitter gland, grafted (Void path): fat slow caustic
    # glob; each discharge costs 1 integrity -- flesh feeds on the frame
    "gland": dict(dmg=16, cd=36, speed=560.0, spread=math.radians(2.5),
                  pellets=1, hp_cost=1, sound="gland_fire", kick=3.0),
}
WEAPON_ORDER = ["knife", "pistol", "smg", "shotgun", "rail", "lightning",
                "tau", "hole", "scrap", "gland"]
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
ENEMIES: dict[str, dict] = {
    "husk": dict(hp=15, radius=8.0, mass=1.0, accel=430.0, fric=3.2, touch_dmg=12,
                 touch_cd=38, alert_snd="enemy_alert_husk", die_snd="enemy_die_husk",
                 score=1),
    "mite": dict(hp=4, radius=4.0, mass=0.35, accel=690.0, fric=4.5, touch_dmg=4,
                 touch_cd=24, alert_snd="enemy_alert_mite", die_snd="enemy_die_mite",
                 score=1),
    "spitter": dict(hp=18, radius=9.0, mass=1.4, accel=340.0, fric=3.8, touch_dmg=8,
                    touch_cd=45, alert_snd="enemy_alert_husk", die_snd="enemy_die_husk",
                    spit_cd=95, spit_speed=380.0, spit_dmg=9, keep_min=110.0,
                    keep_max=190.0, score=2),
    "brute": dict(hp=65, radius=13.5, mass=7.0, accel=260.0, fric=2.6, touch_dmg=24,
                  touch_cd=55, alert_snd="enemy_alert_husk", die_snd="enemy_die_brute",
                  score=4),
    "shrieker": dict(hp=10, radius=7.0, mass=0.8, accel=520.0, fric=3.4, touch_dmg=0,
                     touch_cd=60, alert_snd="shrieker_scream", die_snd="enemy_die_mite",
                     scream_cd=60 * 5, score=3),
    "warden": dict(hp=300, radius=16.0, mass=12.0, accel=330.0, fric=2.4, touch_dmg=30,
                   touch_cd=48, alert_snd="shrieker_scream", die_snd="enemy_die_brute",
                   spit_cd=70, spit_speed=460.0, spit_dmg=13, keep_min=0.0,
                   keep_max=100.0, score=25),
}

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
    "safe_room_core": dict(radius=7.0),
    "turret": dict(radius=6.0),
    "implant_lightning": dict(radius=7.0),
    "key_red": dict(radius=5.5), "key_blue": dict(radius=5.5),
    "key_gold": dict(radius=5.5), "key_void": dict(radius=5.5),
    "components": dict(radius=5.0),
    "corpse_frame": dict(radius=8.0),
    "organ_gland": dict(radius=6.0),
}

# The fabricator's price sheet. Components are salvaged mass — every enemy
# yields its score in components (the same number the metrics already used,
# so salvage income equals fight difficulty by construction).
SHOP: dict[str, dict] = {
    "chassis": dict(cost=8, label="SPARE CHASSIS"),
    "station_kit": dict(cost=12, label="SEED STATION KIT"),
    "hp_up": dict(cost=10, label="HULL PLATING +15", growth=6),
    "scrap_driver": dict(cost=15, label="SCRAP DRIVER"),
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
    "warden": [],
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
        # Soft (otherworld) rooms deform level.room_verts in place via the
        # per-tick refresh; copy so a Level object reused across sessions
        # never inherits another session's deformations.
        level.room_verts = [list(map(tuple, vs)) for vs in level.room_verts]
        self.difficulty = difficulty
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
        for verts in level.room_verts:
            s.add_room(verts)
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
        self.player_light = _LightSpec(
            room=level.player_room, pos=tuple(level.player_pos),
            color=(255, 226, 188), intensity=0.95, radius=85.0,
            kind="attached")
        self.lighting.lights.append(self.player_light)

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
        self.pid = s.spawn(level.player_room, *level.player_pos,
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
        self.stations: list[dict] = []  # {room, pos}: planted + chunk seeds
        # the seed you just printed from is a station by definition (the
        # streamer's chunk-entry add_station dedupes against this one)
        self.add_station(level.player_room, level.player_pos)
        self.keys: set[str] = set()
        # key id -> KeyMeta of the object actually picked up (for HUD/world
        # glyphs); intersect with self.keys — the streamer clears keys on
        # zone crossings without touching this
        self.held_key_meta: dict = {}
        # Otherworld: rooms whose walls are soft (mass-spring vertices).
        self.soft_rooms: set[int] = set()
        for i, k in enumerate(level.room_kinds):
            if k == "otherworld":
                self.sim.soften_room(i)
                self.soft_rooms.add(i)
        self.weapon = st.get("weapon", "pistol")
        if self.weapon not in self.weapons:
            self.weapon = self.weapons[-1]
        self.lightning_charge = LIGHTNING_RECHARGE_TICKS  # full
        self.cooldown = 0
        self.hurt_cd = 0
        self.aim = (1.0, 0.0)
        self.holes = int(st.get("holes", 0))
        self.hole_mark: tuple | None = None  # (room, edge, t0, t1, x, y)
        self.tau_charge = 0
        self.cloister: dict | None = None  # {sanctum, corridor, links, attached}
        self.turrets: dict[int, dict] = {}

        # --- camera: player-room local -> internal screen ---
        px, py = level.player_pos
        self._set_cam(necore.mat_mul(
            necore.mat_mul(necore.mat_translate(self.screen_w / 2, self.screen_h / 2),
                           necore.mat_scale(zoom, zoom)),
            necore.mat_translate(-px, -py)))

        # --- scripted/world objects ---
        self.enemies: dict[int, dict] = {}
        self.bullets: dict[int, dict] = {}
        self.pickups: dict[int, dict] = {}
        self.terminals: list[dict] = [
            dict(room=t.room, pos=t.pos, text=t.text, read=False)
            for t in level.terminals
        ]
        for room, spec in level.entities:
            self._spawn_from_spec(room, spec)

        self.exit_room = level.exit_room
        self.exit_pos = level.exit_pos
        self.wave = 0
        self.wave_timer = 60 * 6 if level.vigil else -1
        if st.get("cloister"):
            self._build_cloister()

        # --- output channels ---
        self.fx: list[tuple] = []  # drained by app each tick
        self._oob_fx: list[tuple] = []  # menu-time events; join next tick
        self.decals: dict[int, list] = {}  # room -> [(kind,x,y,size,angle)]
        self._objective_fired: set[str] = set()  # once-gates for objective fx
        self.metrics = dict(ticks=0, shots=0, hits=0, kills=0, dmg_dealt=0.0,
                            wave=0,
                            dmg_taken=0.0, pickups=0, transfers=0, deaths=0,
                            rooms_visited={level.player_room}, hp_series=[],
                            completed=False)

    # ------------------------------------------------------------------
    # spawning
    # ------------------------------------------------------------------

    def _spawn_from_spec(self, room: int, spec, key_meta=None) -> None:
        """`key_meta` is the key-id -> KeyMeta table of the LEVEL this spec
        came from — the streamer passes each chunk's own table because
        `self.level` is chunk 0's and key ids mean different objects on
        different decks. None = use this session's level."""
        t = spec.type
        if t in ENEMIES:
            eid = self.spawn_enemy(room, spec.pos, t)
            if "hp" in spec.props:
                self.enemies[eid]["hp"] = float(spec.props["hp"]) * self._hp_mul
            if spec.props.get("tether"):
                self.enemies[eid]["tether"] = True
        elif t in PICKUPS:
            meta = None
            if t.startswith("key_"):
                table = key_meta if key_meta is not None else self.level.key_meta
                meta = table.get(t[4:])
            self.spawn_pickup(room, spec.pos, t, meta)
        elif t == "player":
            pass  # player spawn handled by level.player
        else:
            raise ValueError(f"unknown entity type {t!r} in level")

    def spawn_enemy(self, room: int, pos, kind: str) -> int:
        d = ENEMIES[kind]
        eid = self.sim.spawn(room, pos[0], pos[1], d["radius"], d["mass"], GROUP_ENEMY)
        self.sim.set_props(eid, rest_wall=0.0, rest_ent=0.2, max_substep=8.0)
        self.enemies[eid] = dict(kind=kind, hp=d["hp"] * self._hp_mul, state="idle",
                                 touch_cd=0, spit_cd=0, scream_cd=0,
                                 wander_cd=0, buff=0)
        return eid

    def spawn_pickup(self, room: int, pos, kind: str, meta=None,
                     extra: dict | None = None) -> int:
        d = PICKUPS[kind]
        eid = self.sim.spawn(room, pos[0], pos[1], d["radius"], 100.0, GROUP_PICKUP)
        self.sim.set_props(eid, transfers=False)
        rec = dict(kind=kind)
        if meta is not None:
            rec["meta"] = meta  # KeyMeta: the object this key id is here
        if extra:
            rec.update(extra)
        self.pickups[eid] = rec
        return eid

    # ------------------------------------------------------------------
    # helpers
    # ------------------------------------------------------------------

    def _snd(self, name: str, room: int, pos, vol: float = 1.0):
        self.fx.append(("sound", name, room, pos[0], pos[1], vol))

    def _shake(self, mag: float):
        self.fx.append(("shake", mag))

    def _hitstop(self, ticks: int):
        self.freeze = max(self.freeze, ticks)

    def _decal(self, room: int, kind: str, x: float, y: float,
               size: float, angle: float = 0.0):
        lst = self.decals.setdefault(room, [])
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
                      "lightning": "LIGHTNING IMPLANT", "tau": "TAU CANNON",
                      "scrap": "SCRAP DRIVER", "gland": "GRAFTED GLAND"}

    def _objective(self, text: str):
        self.fx.append(("objective", text))

    def _acquired(self, item: str):
        self._objective(
            f"ACQUIRED: {self.ACQUIRE_LABELS.get(item, item.upper())}")

    def _set_cam(self, m) -> None:
        """All camera writes come through here: `_cam_smooth` keeps the
        exact float matrix (the follow integrates on it), while the
        rendered `cam` snaps its translation to whole internal pixels.
        Unsnapped, sub-pixel camera dither (the exponential follow
        oscillating against collision push-out) flips every 1-px prop
        outline between pixel rows frame to frame -- world-wide decor
        flicker, the campaign-video finding."""
        self._cam_smooth = m
        mm = list(m)
        mm[2] = float(round(mm[2]))
        mm[5] = float(round(mm[5]))
        self.cam = tuple(mm)

    def player_pos(self):
        _, px, py, *_ = self.sim.get(self.pid)
        return px, py

    def player_room(self) -> int:
        return self.sim.get_room(self.pid)

    WAKE_TICKS = {"husk": 32, "mite": 18, "spitter": 26, "brute": 45,
                  "shrieker": 12, "warden": 20}

    def alert_enemies(self, room: int, hops: int):
        for eid, e in self.enemies.items():
            if e["state"] != "idle":
                continue  # hunting already, or mid-wake (keep the beat)
            er = self.sim.get_room(eid)
            d = self.sim.hop_distance(er, room)
            if 0 <= d <= hops:
                e["state"] = "waking"
                e["wake"] = self.WAKE_TICKS[e["kind"]]
                if d == 0:
                    _, ex, ey, *_ = self.sim.get(eid)
                    self._snd(ENEMIES[e["kind"]]["alert_snd"], er, (ex, ey), 0.8)
                    self.fx.append(("alerted", er, ex, ey))

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
        if self.tick_count % 60 == 0:
            self.metrics["hp_series"].append(self.hp)
        if self.dead or self.complete:
            return
        if self.freeze > 0:
            self.freeze -= 1
            return

        s = self.sim
        proom = self.player_room()
        s.set_active_within(proom, ACTIVE_HOPS)

        if self.soft_rooms:
            rv = self.level.room_verts
            for r_ in self.soft_rooms:
                if r_ < len(rv):
                    rv[r_] = self.sim.room_verts(r_)
        if self.tick_count % 30 == 0:
            self._containment_sweep(proom)
        self._recall_tick(proom)
        if self._regen_rate and self.tick_count % 60 == 0:
            # grafted Adversary organs knit the hull -- up to a fraction of
            # max only; flesh does not respect fabrication tolerances
            cap = self.max_hp * self._regen_cap_frac
            if self.hp < cap:
                self.hp = min(cap, self.hp + self._regen_rate)

        self._think_tick(proom)
        self._player_control(inp, proom)
        self._enemy_ai(proom)

        # friction (artistic, so it lives here not in the engine)
        self._apply_friction(self.pid, PLAYER_FRICTION)
        for eid, e in self.enemies.items():
            self._apply_friction(eid, ENEMIES[e["kind"]]["fric"])

        events = s.step(DT)
        self._consume_events(events)
        self.sweep_bullets()

        self._turret_tick()
        if self.dead:
            # death landed mid-tick (contact/spit during the event sweep):
            # a dead frame reads no terminals, opens no shops, exits no
            # levels, and -- critically -- does not scoop its own corpse
            # in the tick that dropped it
            return
        self._pickup_scan(proom)
        self._terminal_scan(proom, inp)
        self._station_scan(proom, inp)
        self._exit_scan(proom)

        if self.level.vigil:
            self._vigil_tick(proom)
        if self.cooldown > 0:
            self.cooldown -= 1
        if self.hurt_cd > 0:
            self.hurt_cd -= 1
        self.lightning_charge = min(LIGHTNING_RECHARGE_TICKS, self.lightning_charge + 1)

        # camera follow (after physics; transfers already re-based the
        # matrix). Integrates on the SMOOTH matrix; the rendered cam is
        # the pixel-snapped copy (_set_cam).
        px2, py2 = self.player_pos()
        spx, spy = necore.mat_apply(self._cam_smooth, px2, py2)
        k = min(1.0, 7.0 * DT)
        self._set_cam(necore.mat_mul(
            necore.mat_translate((self.screen_w / 2 - spx) * k,
                                 (self.screen_h / 2 - spy) * k),
            self._cam_smooth))

    # ------------------------------------------------------------------

    def _apply_friction(self, eid: int, fric: float):
        try:
            _, _, _, vx, vy, _, _ = self.sim.get(eid)
        except Exception:
            return
        f = max(0.0, 1.0 - fric * DT)
        self.sim.set_vel(eid, vx * f, vy * f)

    def _player_control(self, inp: InputFrame, proom: int):
        s = self.sim
        # weapon select
        if 1 <= inp.weapon <= len(WEAPON_ORDER):
            w = WEAPON_ORDER[inp.weapon - 1]
            if w in self.weapons:
                self.weapon = w
        # aim
        inv = necore.mat_inv(self.cam)
        awx, awy = necore.mat_apply(inv, inp.ax, inp.ay)
        _, px, py, vx, vy, _, _ = s.get(self.pid)
        dx, dy = awx - px, awy - py
        dl = math.hypot(dx, dy)
        if dl > 1e-6:
            s.set_dir(self.pid, dx / dl, dy / dl)
            self.aim = (dx / dl, dy / dl)
        else:
            self.aim = s.get(self.pid)[5:7]
        # move (screen-space -> room-space through inverse camera rotation)
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
            self._fire(proom, px, py)
        # alt: tau charge when tau is in hand, lightning implant otherwise
        if self.weapon == "tau" and "tau" in self.weapons:
            if inp.alt and self.ammo.get("cell", 0) > 0:
                self.tau_charge += 1
                if self.tau_charge == 1:
                    self._snd("tau_charge", proom, (px, py), 0.8)
                if self.tau_charge > TAU_OVERCHARGE:
                    self._damage_player(12, proom)
                    self._snd("tau_overcharge_hurt", proom, (px, py))
                    self.tau_charge = 0
            elif self.tau_charge > 0:
                self._fire_tau_charged(proom, px, py)
                self.tau_charge = 0
        elif inp.alt and self.lightning_charge >= LIGHTNING_RECHARGE_TICKS \
                and "lightning" in self.weapons:
            self._fire_lightning(proom, px, py)

    def _fire(self, proom: int, px: float, py: float):
        w = WEAPONS[self.weapon]
        adx, ady = self.aim
        if self.weapon == "lightning":
            # the implant fires the same whether triggered or selected
            self.cooldown = 18
            if self.lightning_charge >= LIGHTNING_RECHARGE_TICKS:
                self._fire_lightning(proom, px, py)
            else:
                self._snd("dry_click", proom, (px, py))
            return
        if self.weapon == "hole":
            self.cooldown = w["cd"]
            self._hole_shot(proom, px, py, adx, ady)
            return
        if self.weapon == "knife":
            self.cooldown = w["cd"]
            self._snd("knife_swing", proom, (px, py))
            self.metrics["shots"] += 1
            hit_any = False
            for eid in list(self.sim.room_entities(proom)):
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
                    self._damage_enemy(eid, w["dmg"], (ddx / dist, ddy / dist), 260.0)
                    hit_any = True
            if hit_any:
                self._snd("knife_hit", proom, (px, py))
                self._shake(1.5)
            return
        ammo_t = w.get("ammo")
        if ammo_t == "components":
            # the scrap driver eats the currency itself
            if self.components < w.get("per", 1):
                self.cooldown = 18
                self._snd("dry_click", proom, (px, py))
                return
            self.components -= w.get("per", 1)
        elif ammo_t and self.ammo.get(ammo_t, 0) < w.get("per", 1):
            self.cooldown = 18
            self._snd("dry_click", proom, (px, py))
            return
        elif ammo_t:
            self.ammo[ammo_t] -= w.get("per", 1)
        hp_cost = w.get("hp_cost", 0)
        if hp_cost:
            if self.hp <= hp_cost:
                self.cooldown = 18
                self._snd("dry_click", proom, (px, py))
                return
            self.hp -= hp_cost  # the gland drinks from the frame
        self.cooldown = w["cd"]
        self.metrics["shots"] += 1
        self._snd(w["sound"], proom, (px, py))
        self._shake(w.get("kick", 2.0))
        mx_, my_ = px + adx * (PLAYER_RADIUS + 5), py + ady * (PLAYER_RADIUS + 5)
        self.fx.append(("flash", proom, mx_, my_, 26.0))
        if self.weapon == "rail":
            self._fire_rail(proom, px, py, adx, ady)
        else:
            _, _, _, pvx, pvy, _, _ = self.sim.get(self.pid)
            for _ in range(w.get("pellets", 1)):
                ang = math.atan2(ady, adx) + self.rng.uniform(
                    -w["spread"], w["spread"]) * self._spread_mul
                spd = w["speed"] * self.rng.uniform(0.95, 1.05)
                brad = 3.0 if self.weapon == "gland" else 1.6
                bid = self.sim.spawn(proom, mx_, my_, brad, 0.002, GROUP_PBULLET)
                self.sim.set_props(bid, rest_wall=0.0, rest_ent=0.0, max_substep=3.2)
                self.sim.set_vel(bid, math.cos(ang) * spd + pvx * 0.4,
                                 math.sin(ang) * spd + pvy * 0.4)
                self.sim.set_dir(bid, math.cos(ang), math.sin(ang))
                self.bullets[bid] = dict(kind="bullet", dmg=w["dmg"], ttl=90)
                if self.weapon == "tau":
                    self.bullets[bid].update(kind="tau", ttl=140,
                                             bounces=w.get("bounces", 0))
                    self.sim.set_props(bid, rest_wall=1.0)
                elif self.weapon == "scrap":
                    # shards of salvage: hard-hitting, short-lived
                    self.bullets[bid].update(kind="scrap", ttl=34)
                elif self.weapon == "gland":
                    self.bullets[bid].update(kind="gland", ttl=170)
        # gunfire is loud: it travels the graph
        self.alert_enemies(proom, self.level.alert_hops)

    def _fire_rail(self, proom, px, py, adx, ady):
        ox, oy, room = px + adx * (PLAYER_RADIUS + 3), py + ady * (PLAYER_RADIUS + 3), proom
        dx, dy = adx, ady
        ignore = self.pid
        w = WEAPONS["rail"]
        for _ in range(w["pierce"]):
            hit = self.sim.raycast(room, ox, oy, dx, dy, 8, 2000.0,
                                   1 << GROUP_ENEMY, ignore)
            kind = hit[0]
            if kind == "ent":
                _, eid, hroom, hx, hy, dist, hops, m9 = hit
                self._damage_enemy(eid, w["dmg"], (dx, dy), 420.0)
                r = self.sim.get_radius(eid) if self.sim.exists(eid) else 8.0
                ox, oy, room, ignore = hx + dx * (2 * r + 1.0), hy + dy * (2 * r + 1.0), hroom, eid
            else:
                if kind == "wall":
                    _, hroom, hedge, hx, hy, dist, hops, m9 = hit
                    self._decal(hroom, "scorch", hx, hy, 4.0)
                break
        # visual tracer that flies the same path
        bid = self.sim.spawn(proom, px + adx * (PLAYER_RADIUS + 3),
                             py + ady * (PLAYER_RADIUS + 3), 1.2, 0.0005, GROUP_PBULLET)
        self.sim.set_props(bid, rest_wall=0.0, max_substep=4.0)
        self.sim.set_vel(bid, adx * 5200.0, ady * 5200.0)
        self.bullets[bid] = dict(kind="tracer", dmg=0, ttl=14)
        self._hitstop(2)

    def _fire_lightning(self, proom, px, py):
        self.lightning_charge = 0
        adx, ady = self.aim
        w = WEAPONS["lightning"]
        _, _, _, pvx, pvy, _, _ = self.sim.get(self.pid)
        bid = self.sim.spawn(proom, px + adx * (PLAYER_RADIUS + 6),
                             py + ady * (PLAYER_RADIUS + 6), 3.0, 0.02, GROUP_PBULLET)
        self.sim.set_props(bid, rest_wall=0.0, max_substep=4.0)
        self.sim.set_vel(bid, adx * w["speed"] + pvx * 0.5, ady * w["speed"] + pvy * 0.5)
        self.bullets[bid] = dict(kind="dart", dmg=w["dmg"], ttl=240)
        self._snd("lightning_fire", proom, (px, py))
        self._shake(4.0)
        self.alert_enemies(proom, self.level.alert_hops + 1)

    def _fire_tau_charged(self, proom, px, py):
        adx, ady = self.aim
        frac = min(1.0, self.tau_charge / TAU_CHARGE_FULL)
        cost = min(self.ammo.get("cell", 0), 5)
        if cost <= 0:
            self._snd("dry_click", proom, (px, py))
            return
        self.ammo["cell"] -= cost
        power = frac * (0.4 + 0.6 * cost / 5.0)
        dmg = 18 + 46 * power
        _, _, _, pvx, pvy, _, _ = self.sim.get(self.pid)
        bid = self.sim.spawn(proom, px + adx * (PLAYER_RADIUS + 5),
                             py + ady * (PLAYER_RADIUS + 5), 2.2, 0.006,
                             GROUP_PBULLET)
        self.sim.set_props(bid, rest_wall=1.0, max_substep=4.0)
        self.sim.set_vel(bid, adx * 2600.0 + pvx * 0.3, ady * 2600.0 + pvy * 0.3)
        self.bullets[bid] = dict(kind="taucharged", dmg=dmg, ttl=160, bounces=3)
        self.metrics["shots"] += 1
        self._snd("tau_charged_fire", proom, (px, py))
        self._shake(4.0 + 5.0 * power)
        self._hitstop(2)
        self.fx.append(("flash", proom, px + adx * 12, py + ady * 12, 30.0))
        self.alert_enemies(proom, self.level.alert_hops)

    # ------------------------------------------------------------------
    # portable hole
    # ------------------------------------------------------------------

    def _hole_shot(self, proom, px, py, adx, ady):
        if self.holes <= 0:
            self._snd("dry_click", proom, (px, py))
            return
        hit = self.sim.raycast(proom, px, py, adx, ady, 0, HOLE_RANGE, 0, self.pid)
        if hit[0] != "wall":
            self._snd("dry_click", proom, (px, py), 0.5)
            return
        _, room, edge, hx, hy, dist, hops, m9 = hit
        x1, y1, x2, y2 = self.sim.edge_endpoints(room, edge)
        elen = math.hypot(x2 - x1, y2 - y1)
        along = (hx - x1) * (x2 - x1) / elen + (hy - y1) * (y2 - y1) / elen
        half = HOLE_WIDTH / 2.0
        if along < half + 2.0 or along > elen - half - 2.0:
            self._snd("dry_click", proom, (px, py), 0.5)
            return
        t0, t1 = (along - half) / elen, (along + half) / elen
        if self.cloister is not None:
            if room in (self.cloister["sanctum"], self.cloister["corridor"]):
                self._snd("dry_click", proom, (px, py), 0.5)
                return
            mid = self.sim.split_edge(room, edge, t0, t1)
            self._shift_edge_maps(room, edge)
            self.cloister["links"].append((room, mid))
            self._attach_cloister(len(self.cloister["links"]) - 1)
            self.holes -= 1
            self._decal(room, "scorch", hx, hy, 8.0)
            self._snd("door_unlock", room, (hx, hy))
            self.fx.append(("holeopen", room, hx, hy))
            self._shake(2.5)
            return
        if self.hole_mark is None:
            self.hole_mark = (room, edge, t0, t1, hx, hy)
            self._decal(room, "scorch", hx, hy, 5.0)
            self._snd("terminal_type", room, (hx, hy))
            self.fx.append(("holemark", room, hx, hy))
            return
        m_room, m_edge, m_t0, m_t1, mx, my = self.hole_mark
        if m_room == room and m_edge == edge:
            self._snd("dry_click", proom, (px, py), 0.5)
            return
        # split the FIRST mark's wall first; if the second mark shares the
        # room with a later edge index, account for the insertion shift
        if m_room == room and edge > m_edge:
            edge += 2
        mid_a = self.sim.split_edge(m_room, m_edge, m_t0, m_t1)
        self._shift_edge_maps(m_room, m_edge)
        mid_b = self.sim.split_edge(room, edge, t0, t1)
        self._shift_edge_maps(room, edge)
        if m_room == room and mid_a > edge:
            mid_a += 2  # the second split renumbered the first doorway
        w = HOLE_WIDTH
        cor = self.sim.add_room([(0.0, 0.0), (0.0, w),
                                 (HOLE_CORRIDOR_LEN, w), (HOLE_CORRIDOR_LEN, 0.0)])
        self.sim.connect(m_room, mid_a, cor, 0)
        self.sim.connect(room, mid_b, cor, 2)
        self.level.room_seeds.append(cor * 7919 + 13)
        self.holes -= 1
        self.hole_mark = None
        self._snd("door_unlock", room, (hx, hy))
        self.fx.append(("holeopen", room, hx, hy))
        self._shake(3.0)

    def carve_door(self, room: int, near, width: float = 70.0) -> int | None:
        """Split the wall nearest `near` (room-local) to make a door-width
        sub-edge; returns its index, or None if no wall has the span."""
        best = None
        for e in range(len(self.sim.room_portals(room))):
            if self.sim.room_portals(room)[e] is not None:
                continue
            x1, y1, x2, y2 = self.sim.edge_endpoints(room, e)
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
        mid = self.sim.split_edge(room, e, t0, t1)
        self._shift_edge_maps(room, e)
        return mid

    def append_chunk(self, level) -> int:
        """Stream another level's rooms into this live world. Returns the
        room-index offset where the chunk begins. Doors, terminals, and
        entities all arrive re-indexed."""
        offset = self.sim.num_rooms()
        for verts in level.room_verts:
            self.sim.add_room(verts)
        for a, ea, b, eb in level.connects:
            self.sim.connect(a + offset, ea, b + offset, eb)
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
            self.terminals.append(dict(room=t.room + offset, pos=t.pos,
                                       text=t.text, read=False))
        for room, spec in level.entities:
            self._spawn_from_spec(room + offset, spec, key_meta=level.key_meta)
        if level.lights:
            from dataclasses import replace as _dc_replace
            shifted = [_dc_replace(lt, room=lt.room + offset) for lt in level.lights]
            self.level.lights.extend(shifted)
            self.lighting.add_lights(self.sim, shifted)
        self.level.room_seeds.extend(level.room_seeds)
        for i, k in enumerate(level.room_kinds):
            if k == "otherworld":
                self.sim.soften_room(offset + i)
                self.soft_rooms.add(offset + i)
        self.level.room_kinds.extend(level.room_kinds)
        self.level.room_verts.extend(level.room_verts)
        self.level.room_centroids.extend(level.room_centroids)
        return offset

    def _shift_edge_maps(self, room: int, edge: int):
        """A split inserted two edges after `edge` in `room`; every python-
        side (room, edge) reference beyond it shifts by 2."""
        remapped = {}
        for (r, e), k in self.door_edges.items():
            remapped[(r, e + 2 if r == room and e > edge else e)] = k
        self.door_edges = remapped
        for d in self.doors:
            if d["a"] == room and d["ea"] > edge:
                d["ea"] += 2
            if d["b"] == room and d["eb"] > edge:
                d["eb"] += 2
        if self.cloister:
            self.cloister["links"] = [
                (r, e + 2 if r == room and e > edge else e)
                for (r, e) in self.cloister["links"]]

    # ------------------------------------------------------------------
    # the vigil: the wave director. Things still come through. They are met.
    # ------------------------------------------------------------------

    # no shriekers: a thing that flees forever stalls a holdout
    VIGIL_COSTS = (("mite", 1), ("husk", 2), ("spitter", 4), ("brute", 7))

    def _vigil_tick(self, proom: int):
        if self.wave_timer > 0:
            self.wave_timer -= 1
            return
        if any(e for e in self.enemies.values()):
            # stragglers do not stall the watch: after a grace period the
            # next push comes through anyway
            self.wave_stall = self.wave_stall + 1 if hasattr(self, "wave_stall") else 1
            if self.wave_stall < 60 * 60:
                return
        self.wave_stall = 0
        self.wave += 1
        self.metrics["wave"] = self.wave
        budget = 3 + 2 * self.wave
        # spawn away from the player: petal rooms only (never room 0's heart
        # unless the player left it)
        rooms = [r for r in range(self.sim.num_rooms())
                 if r != proom and (self.cloister is None or
                 r not in (self.cloister["sanctum"], self.cloister["corridor"]))]
        spawned = 0
        while budget > 0 and spawned < 22:
            kinds = [(k, c) for k, c in self.VIGIL_COSTS if c <= budget]
            if self.wave >= 5 and self.wave % 5 == 0 and spawned == 0:
                kind, cost = "warden", budget  # a fresh print at the door
            else:
                kind, cost = kinds[self.rng.randrange(len(kinds))]
            room = rooms[self.rng.randrange(len(rooms))]
            a = self.rng.uniform(0, 6.28)
            eid = self.spawn_enemy(room, (55 * math.cos(a), 55 * math.sin(a)), kind)
            self.enemies[eid]["state"] = "hunt"
            budget -= cost
            spawned += 1
        self.wave_timer = 60 * 8
        # wave feedback is the stinger + the HUD wave counter; no dialogue
        self._snd("stinger_wrongness", proom, self.player_pos(), 0.5)
        # the seed keeps the pantry stocked between pushes
        if self.wave % 2 == 0:
            kind = "medkit" if self.wave % 4 == 0 else                 ("ammo_shell" if self.wave % 3 == 0 else "ammo_9mm")
            a = self.rng.uniform(0, 6.28)
            self.spawn_pickup(0, (60 * math.cos(a), 60 * math.sin(a)), kind)

    # ------------------------------------------------------------------
    # the cloister (safe room): an isolated pocket with no address,
    # linked to wherever the portable hole has cut
    # ------------------------------------------------------------------

    def _build_cloister(self):
        if self.cloister is not None:
            return
        self.hole_mark = None  # paired-mode marks cannot complete anymore
        s = self.sim
        verts = []
        for i in range(8):
            a = math.radians(22.5) - i * math.pi / 4.0
            verts.append((85.0 * math.cos(a), 85.0 * math.sin(a)))
        sanctum = s.add_room(verts)
        elen = 2 * 85.0 * math.sin(math.pi / 8.0)
        t0 = 0.5 - 7.5 / elen
        t1 = 0.5 + 7.5 / elen
        door = s.split_edge(sanctum, 4, t0, t1)
        corridor = s.add_room([(0.0, 0.0), (0.0, 15.0), (36.0, 15.0), (36.0, 0.0)])
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
        self.level.room_seeds.extend([sanctum * 7919 + 13, corridor * 7919 + 13])

    def _attach_cloister(self, idx: int):
        c = self.cloister
        if c["attached"] is not None:
            self.sim.disconnect(c["corridor"], 2)
        room, edge = c["links"][idx]
        self.sim.connect(room, edge, c["corridor"], 2)
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
            room = s.get_room(tid)
            _, tx, ty, *_ = s.get(tid)
            best, bd = None, 1e18
            for eid in s.room_entities(room):
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
            bid = s.spawn(room, tx + nx * 8, ty + ny * 8, 1.6, 0.002, GROUP_PBULLET)
            s.set_props(bid, rest_wall=0.0, max_substep=3.2)
            s.set_vel(bid, nx * 1200.0, ny * 1200.0)
            self.bullets[bid] = dict(kind="turret", dmg=6, ttl=40)
            self._snd("smg_fire", room, (tx, ty), 0.35)
            self.fx.append(("flash", room, tx + nx * 8, ty + ny * 8, 14.0))

    def _detonate_dart(self, bid: int, room: int, x: float, y: float):
        w = WEAPONS["lightning"]
        self.fx.append(("lightning", room, x, y, w["radius"]))
        self._snd("lightning_fire", room, (x, y), 1.0)
        self._shake(9.0)
        self._hitstop(5)
        self._decal(room, "scorch", x, y, 22.0)
        for eid in list(self.sim.room_entities(room)):
            e = self.enemies.get(eid)
            if not e:
                continue
            _, ex, ey, evx, evy, _, _ = self.sim.get(eid)
            d = math.hypot(ex - x, ey - y)
            if d > w["radius"]:
                continue
            fall = 1.0 - d / w["radius"]
            nx, ny = ((ex - x) / d, (ey - y) / d) if d > 1e-6 else (1.0, 0.0)
            self.sim.set_vel(eid, evx + nx * w["force"] * fall,
                             evy + ny * w["force"] * fall)
            self._damage_enemy(eid, w["dmg"] * (0.4 + 0.6 * fall), (nx, ny), 0.0)

    # ------------------------------------------------------------------

    def _damage_enemy(self, eid: int, dmg: float, ndir, knock: float):
        e = self.enemies.get(eid)
        if e is None:
            return
        dmg *= self._dmg_out_mul
        if e["state"] != "idle":
            dmg *= self._target_mark_mul
        if self._crit_p > 0.0 and self.rng.random() < self._crit_p:
            dmg *= self._crit_mul
        e["hp"] -= dmg
        e["state"] = "hunt"
        self.metrics["hits"] += 1
        self.metrics["dmg_dealt"] += dmg
        room = self.sim.get_room(eid)
        _, ex, ey, evx, evy, _, _ = self.sim.get(eid)
        if knock > 0.0:
            m = ENEMIES[e["kind"]]["mass"]
            self.sim.set_vel(eid, evx + ndir[0] * knock / m, evy + ndir[1] * knock / m)
        self._snd("hit_flesh", room, (ex, ey), 0.8)
        self._decal(room, "blood", ex + self.rng.uniform(-4, 4),
                    ey + self.rng.uniform(-4, 4), self.rng.uniform(3, 7),
                    self.rng.uniform(0, 6.28))
        self.fx.append(("hitflash", eid))
        if e["hp"] <= 0:
            self._kill_enemy(eid, room, (ex, ey), ndir)

    def _kill_enemy(self, eid: int, room: int, pos, ndir):
        e = self.enemies.pop(eid)
        kind = e["kind"]
        d = ENEMIES[kind]
        self.metrics["kills"] += 1
        self._snd(d["die_snd"], room, pos)
        self._decal(room, "corpse_" + kind, pos[0], pos[1],
                    d["radius"], math.atan2(ndir[1], ndir[0]))
        for i in range(int(d["radius"])):
            a = self.rng.uniform(0, 6.28)
            r = self.rng.uniform(2, d["radius"] * 1.8)
            self._decal(room, "blood", pos[0] + math.cos(a) * r,
                        pos[1] + math.sin(a) * r, self.rng.uniform(2, 5), a)
        self.fx.append(("gib", room, pos[0], pos[1], int(d["radius"]),
                        (ndir[0], ndir[1])))
        self._hitstop(4 if kind in ("husk", "mite") else 7)
        self._shake(2.5)
        self.sim.remove(eid)
        # drops
        for p, kind_ in DROP_TABLES[kind]:
            if self.rng.random() < p:
                self.spawn_pickup(room, (pos[0] + self.rng.uniform(-6, 6),
                                         pos[1] + self.rng.uniform(-6, 6)), kind_)
                break
        # Void path: with the harvesting protocol integrated, a spitter's
        # intact gland is a weapon waiting for a socket
        if kind == "spitter" and "gland" not in self.weapons and \
                "adversary_organ_slot_1" in self.mind_unlocks and \
                not any(p["kind"] == "organ_gland"
                        for p in self.pickups.values()):
            self.spawn_pickup(room, (pos[0], pos[1] + 8), "organ_gland")
        # salvage: every kill yields its score in components (9.1 -- wrecks
        # are materials; score already priced each enemy's difficulty)
        self.spawn_pickup(room, (pos[0] + self.rng.uniform(-5, 5),
                                 pos[1] + self.rng.uniform(-5, 5)),
                          "components",
                          extra=dict(amount=int(math.ceil(
                              d["score"] * self._salvage_mul))))
        # nearby enemies hear the death
        self.alert_enemies(room, 1)

    def _damage_player(self, dmg: float, room: int):
        if self.hurt_cd > 0 or self.dead:
            return
        self.hurt_cd = 30
        if self.recall_t > 0:
            self.recall_t = 0
            self._objective("RECALL SEVERED")
        dmg *= self._dmg_mul * self._armor_mul
        self.hp -= dmg
        self.metrics["dmg_taken"] += dmg
        px, py = self.player_pos()
        self._snd("player_hurt", room, (px, py))
        self._shake(min(8.0, 2.0 + dmg * 0.25))
        self.fx.append(("playerhurt", dmg))
        self._decal(room, "blood", px + self.rng.uniform(-5, 5),
                    py + self.rng.uniform(-5, 5), self.rng.uniform(3, 6))
        if self.hp <= 0:
            self.dead = True
            self.metrics["deaths"] += 1
            self._snd("player_die", room, (px, py))
            self.fx.append(("playerdie",))
            self._decal(room, "corpse_player", px, py, PLAYER_RADIUS)
            self._drop_corpse(room, (px, py))

    def _drop_corpse(self, room: int, pos) -> None:
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
            self.spawn_pickup(room, pos, "corpse_frame",
                              extra=dict(contents=contents,
                                         line=self.rng.randrange(1 << 30)))

    # ------------------------------------------------------------------

    def _enemy_ai(self, proom: int):
        s = self.sim
        active = set(s.rooms_within(proom, ACTIVE_HOPS))
        px, py = self.player_pos()
        for eid, e in list(self.enemies.items()):
            room = s.get_room(eid)
            if room not in active:
                continue
            kind = e["kind"]
            d = ENEMIES[kind]
            _, ex, ey, evx, evy, edx, edy = s.get(eid)
            for k in ("touch_cd", "spit_cd", "scream_cd", "wander_cd"):
                if e.get(k, 0) > 0:
                    e[k] -= 1
            if e.get("buff", 0) > 0:
                e["buff"] -= 1

            # footfalls: the dread channel again — mass on deck plating,
            # audible through walls before anything is visible. Deltas are
            # only meaningful within one room's local frame, so a transfer
            # resets the stride.
            if kind not in ("mite", "shrieker"):
                lroom, lx, ly = e.get("step_from", (room, ex, ey))
                if lroom == room:
                    e["step_acc"] = e.get("step_acc", 0.0) + \
                        math.hypot(ex - lx, ey - ly)
                else:
                    e["step_acc"] = 0.0
                e["step_from"] = (room, ex, ey)
                stride = 44.0 if kind in ("brute", "warden") else 30.0
                if e.get("step_acc", 0.0) >= stride:
                    e["step_acc"] = 0.0
                    self._snd("step_heavy" if kind in ("brute", "warden")
                              else "step_soft", room, (ex, ey),
                              0.6 if e["state"] == "hunt" else 0.35)

            if e["state"] == "idle":
                if room == proom:
                    # the notice beat: growl first, charge after — the
                    # player always gets the first move
                    e["state"] = "waking"
                    e["wake"] = self.WAKE_TICKS[kind]
                    self._snd(d["alert_snd"], room, (ex, ey), 0.9)
                    self.fx.append(("alerted", room, ex, ey))
                    ddx, ddy = px - ex, py - ey
                    dl = math.hypot(ddx, ddy) or 1e-6
                    s.set_dir(eid, ddx / dl, ddy / dl)
                    continue
                else:
                    # aimless drift
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
                    e["state"] = "hunt"
                continue

            # hunting: audible before visible — the dread channel
            e["groan_cd"] = e.get("groan_cd", self.rng.randrange(60, 200)) - 1
            if e["groan_cd"] <= 0:
                e["groan_cd"] = self.rng.randrange(140, 260)
                self._snd(d["alert_snd"], room, (ex, ey), 0.35)
            accel = d["accel"] * (1.25 if e.get("buff", 0) > 0 else 1.0)
            if kind == "shrieker":
                self._shrieker_ai(eid, e, room, proom, ex, ey, accel)
                continue
            if room == proom:
                ddx, ddy = px - ex, py - ey
                dist = math.hypot(ddx, ddy) or 1e-6
                nx, ny = ddx / dist, ddy / dist
                s.set_dir(eid, nx, ny)
                # husks lunge: a sudden burst inside close range reads as an
                # attack, not a shove
                if kind in ("husk", "brute") and dist < 95.0 \
                        and e.get("lunge_cd", 0) <= 0:
                    e["lunge_cd"] = 120 if kind == "husk" else 150
                    burst = 300.0 if kind == "husk" else 240.0
                    s.set_vel(eid, evx + nx * burst, evy + ny * burst)
                    self._snd(d["alert_snd"], room, (ex, ey), 0.55)
                if e.get("lunge_cd", 0) > 0:
                    e["lunge_cd"] -= 1
                # warden enrage below half health
                if kind == "warden" and not e.get("enraged") \
                        and e["hp"] < ENEMIES["warden"]["hp"] * 0.5:
                    e["enraged"] = True
                    e["buff"] = 10 ** 9
                    self._snd("shrieker_scream", room, (ex, ey), 1.0)
                    self.fx.append(("scream", room, ex, ey))
                keep_min = d.get("keep_min")
                if keep_min is not None and d.get("spit_cd") is not None:
                    # ranged: hold the band, spit on cooldown
                    if dist < d["keep_min"]:
                        s.set_vel(eid, evx - nx * accel * DT, evy - ny * accel * DT)
                    elif dist > d["keep_max"]:
                        s.set_vel(eid, evx + nx * accel * DT, evy + ny * accel * DT)
                    if e["spit_cd"] <= 0:
                        e["spit_cd"] = d["spit_cd"] // 2 if e.get("enraged") \
                            else d["spit_cd"]
                        self._spit(eid, room, ex, ey, nx, ny, d)
                        if e.get("enraged"):
                            # radial burst: the warden's room fills with spit
                            for k in range(6):
                                a2 = k * math.pi / 3 + self.tick_count * 0.05
                                self._spit(eid, room, ex, ey,
                                           math.cos(a2), math.sin(a2), d)
                    if kind != "warden":
                        continue
                s.set_vel(eid, evx + nx * accel * DT, evy + ny * accel * DT)
            else:
                if e.get("tether"):
                    continue  # arena guardian: holds its ground
                edge = s.next_edge(room, proom)
                if edge < 0:
                    continue
                mx_, my_ = s.edge_midpoint(room, edge)
                ddx, ddy = mx_ - ex, my_ - ey
                dist = math.hypot(ddx, ddy) or 1e-6
                s.set_dir(eid, ddx / dist, ddy / dist)
                s.set_vel(eid, evx + ddx / dist * accel * DT,
                          evy + ddy / dist * accel * DT)

    def _spit(self, eid, room, ex, ey, nx, ny, d):
        bid = self.sim.spawn(room, ex + nx * (d["radius"] + 4),
                             ey + ny * (d["radius"] + 4), 2.5, 0.01, GROUP_EBULLET)
        self.sim.set_props(bid, rest_wall=0.0, max_substep=3.0)
        ang = math.atan2(ny, nx) + self.rng.uniform(-0.06, 0.06)
        self.sim.set_vel(bid, math.cos(ang) * d["spit_speed"],
                         math.sin(ang) * d["spit_speed"])
        self.bullets[bid] = dict(kind="spit", dmg=d["spit_dmg"], ttl=180)
        self._snd("spitter_shoot", room, (ex, ey), 0.9)

    def _shrieker_ai(self, eid, e, room, proom, ex, ey, accel):
        s = self.sim
        d = ENEMIES["shrieker"]
        px, py = self.player_pos()
        if e["scream_cd"] <= 0:
            e["scream_cd"] = d["scream_cd"]
            self._snd("shrieker_scream", room, (ex, ey), 1.0)
            self.fx.append(("scream", room, ex, ey))
            for oid, oe in self.enemies.items():
                if oid == eid:
                    continue
                orr = s.get_room(oid)
                hd = s.hop_distance(orr, room)
                if 0 <= hd <= 2:
                    oe["state"] = "hunt"
                    oe["buff"] = 60 * 5
        if room == proom:
            ddx, ddy = ex - px, ey - py  # away from player
            dist = math.hypot(ddx, ddy) or 1e-6
            _, _, _, evx, evy, _, _ = s.get(eid)
            s.set_dir(eid, ddx / dist, ddy / dist)
            s.set_vel(eid, evx + ddx / dist * accel * DT, evy + ddy / dist * accel * DT)

    # ------------------------------------------------------------------

    def _consume_events(self, events):
        for ev in events:
            tag = ev[0]
            if tag == "transfer":
                _, ent, from_room, to_room, edge, m9 = ev
                if ent == self.pid:
                    if self.cloister and to_room == self.cloister["sanctum"]:
                        self._rotate_cloister()
                    # camera re-base: zero visible change by construction
                    self._set_cam(necore.mat_mul(
                        self._cam_smooth, necore.mat_inv(m9)))
                    self.metrics["transfers"] += 1
                    self.metrics["rooms_visited"].add(to_room)
            elif tag == "wall":
                _, ent, room, edge, px_, py_, nx, ny, speed = ev
                if ent == self.pid:
                    self._door_bump(room, edge)
                if room in self.soft_rooms:
                    b_ = self.bullets.get(ent)
                    if b_ is not None:
                        mag = 10.0 + 5.5 * float(b_.get("dmg", 0))
                    else:
                        e_ = self.enemies.get(ent)
                        mass = ENEMIES[e_["kind"]]["mass"] if e_ else 1.2
                        mag = min(90.0, 0.06 * mass * speed)
                    if mag > 1.0:
                        verts = self.sim.room_verts(room)
                        a_ = verts[edge]
                        b2_ = verts[(edge + 1) % len(verts)]
                        ex_, ey_ = b2_[0] - a_[0], b2_[1] - a_[1]
                        el2 = ex_ * ex_ + ey_ * ey_ or 1.0
                        t_ = ((px_ - a_[0]) * ex_ + (py_ - a_[1]) * ey_) / el2
                        self.sim.soft_wall_impulse(room, edge,
                                                   max(0.0, min(1.0, t_)), mag)
                b = self.bullets.get(ent)
                if b is not None and b["kind"] != "spit" \
                        and self.door_edges.get((room, edge)) == "shoot":
                    # a cracked wall gives way
                    for d in self.doors:
                        if not d["open"] and d["key"] == "shoot" and (
                                (d["a"], d["ea"]) == (room, edge)
                                or (d["b"], d["eb"]) == (room, edge)):
                            d["open"] = True
                            self.sim.connect(d["a"], d["ea"], d["b"], d["eb"])
                            self.door_edges.pop((d["a"], d["ea"]), None)
                            self.door_edges.pop((d["b"], d["eb"]), None)
                            self._snd("door_unlock", room, (px_, py_))
                            self._decal(room, "scorch", px_, py_, 10.0)
                            self._shake(3.0)
                            self.fx.append(("holeopen", room, px_, py_))
                            break
                if b is not None:
                    if b["kind"] in ("tau", "taucharged") and b.get("bounces", 0) > 0:
                        b["bounces"] -= 1
                        self._snd("ricochet", room, (px_, py_), 0.5)
                        self.fx.append(("spark", room, px_, py_, nx, ny))
                        continue  # engine already reflected it (rest_wall=1)
                    if b["kind"] == "spit":
                        self._decal(room, "splat", px_, py_, 4.0)
                    elif b["kind"] == "dart":
                        self._detonate_dart(ent, room, px_, py_)
                    elif b["kind"] == "bullet":
                        self._decal(room, "chip", px_, py_, 2.0)
                        self._snd("hit_wall", room, (px_, py_), 0.35)
                        self.fx.append(("spark", room, px_, py_, nx, ny))
                    self.sim.remove(ent)
                    self.bullets.pop(ent, None)
            elif tag == "contact":
                _, a, b, cx, cy, nx, ny, rel = ev
                self._contact(a, b, cx, cy, nx, ny)

    def _door_bump(self, room: int, edge: int):
        """The player pressed against a locked door: name the mechanism
        and the object it wants. Rate-limited per key id — the prompt
        holds ~4s on screen; re-arm after 5s of continued shoving."""
        key = self.door_edges.get((room, edge))
        if not key or key == "shoot" or key in self.keys:
            return
        last = self._door_prompt_at.get(key)
        if last is not None and self.tick_count - last < 300:
            return
        self._door_prompt_at[key] = self.tick_count
        prompt = ""
        for d in self.doors:
            if not d["open"] and d["key"] == key and (
                    (d["a"], d["ea"]) == (room, edge)
                    or (d["b"], d["eb"]) == (room, edge)):
                prompt = d.get("gate_prompt", "")
                break
        self._objective(prompt or f"DOOR SEALED - {key.upper()} SEAL REQUIRED")

    def _contact(self, a: int, b: int, cx: float, cy: float, nx: float, ny: float):
        # normalize order: identify roles
        for x, y in ((a, b), (b, a)):
            bx = self.bullets.get(x)
            if bx is not None and y in self.enemies:
                if bx["kind"] == "dart":
                    room = self.sim.get_room(x) if self.sim.exists(x) \
                        else self.sim.get_room(y)
                    self._detonate_dart(x, room, cx, cy)
                elif bx["kind"] in ("bullet", "tau", "taucharged", "turret"):
                    self._damage_enemy(y, bx["dmg"], (nx if x == b else -nx, ny if x == b else -ny), 90.0)
                self.sim.remove(x)
                self.bullets.pop(x, None)
                return
            if bx is not None and y == self.pid:
                room = self.sim.get_room(y)
                if bx["kind"] == "spit":
                    self._damage_player(bx["dmg"], room)
                elif bx["kind"] == "dart":
                    self._detonate_dart(x, room, cx, cy)
                    px_, py_ = self.player_pos()
                    self._damage_player(WEAPONS["lightning"]["dmg"] * 0.6, room)
                elif bx["kind"] == "turret":
                    pass  # the guardians do not miss that badly
                else:
                    # a round you fired found its way back through the fold
                    self._damage_player(bx["dmg"] * 0.75, room)
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
                    self._damage_player(d["touch_dmg"], self.sim.get_room(self.pid))

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

    def _containment_sweep(self, proom: int) -> None:
        """Entities must never exist outside their room's polygon. The
        engine's collision guarantees this in normal play, but a crowded
        shove at a carved door jamb can press an entity through a wall
        (soak seed 1993: a fleeing shrieker escaped the mirror ward and
        drifted 14k units out, untargetable, wedging the run). Recover
        escapees to the room centroid and say so loudly -- this is
        damage control for an engine bug, not normal flow."""
        verts_all = self.level.room_verts
        streaks = getattr(self, "_outside_streaks", None)
        if streaks is None:
            streaks = self._outside_streaks = {}
        for eid in (self.pid, *list(self.enemies)):
            if not self.sim.exists(eid):
                streaks.pop(eid, None)
                continue
            room, x, y, *_ = self.sim.get(eid)
            if room >= len(verts_all):
                continue
            off = self._outside_by(x, y, verts_all[room])
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
                # verts: level.room_centroids is authored-frame bookkeeping
                # and teleporting there re-corrupts (that bug ate this
                # sweep's first version)
                vs = verts_all[room]
                cx = sum(v[0] for v in vs) / len(vs)
                cy = sum(v[1] for v in vs) / len(vs)
                self.sim.set_pos(eid, cx, cy)
                self.sim.set_vel(eid, 0.0, 0.0)
                self.metrics["containment_recoveries"] = \
                    self.metrics.get("containment_recoveries", 0) + 1
                import sys as _sys
                print(f"[sim] CONTAINMENT: entity {eid} "
                      f"({'player' if eid == self.pid else self.enemies.get(eid, {}).get('kind', '?')}) "
                      f"was {off:.1f}u outside room {room} at ({x:.0f},{y:.0f}); "
                      f"recovered to centroid", file=_sys.stderr)

    def _pickup_scan(self, proom: int):
        px, py = self.player_pos()
        for eid in list(self.sim.room_entities(proom)):
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
                self._snd("pickup_ammo", proom, (x, y))
                self.fx.append(("pickup_text", proom, (x, y),
                                f"+{amt} {t.upper()}"))
            elif kind == "medkit":
                if self.hp > 70:
                    continue  # leave it for later — scarcity respects foresight
                self.hp = min(self.max_hp, self.hp + PICKUPS[kind]["amount"])
                self._snd("pickup_medkit", proom, (x, y))
                self.fx.append(("pickup_text", proom, (x, y),
                                f"+{PICKUPS[kind]['amount']} INTEGRITY"))
            elif kind.startswith("weapon_"):
                w = kind[7:]
                if w not in self.weapons:
                    self.weapons.append(w)
                    self.weapon = w
                self.ammo_bonus_for(w)
                self._snd("pickup_ammo", proom, (x, y))
                self._acquired(w)
            elif kind == "safe_room_core":
                self._build_cloister()
                if "hole" not in self.weapons:
                    self.weapons.append("hole")
                self.holes += 2
                self._snd("pickup_key", proom, (x, y))
                self._acquired("cloister")
            elif kind == "turret":
                continue  # not a pickup; the guardians are furniture
            elif kind == "portable_hole":
                self.holes += 1 + self._hole_bonus
                if "hole" not in self.weapons:
                    self.weapons.append("hole")
                self._snd("pickup_key", proom, (x, y))
                self._acquired("hole")
            elif kind == "implant_lightning":
                if "lightning" not in self.weapons:
                    self.weapons.append("lightning")
                self._snd("pickup_key", proom, (x, y))
                self._acquired("lightning")
            elif kind == "organ_gland":
                if "gland" not in self.weapons:
                    self.weapons.append("gland")
                    self.weapon = "gland"
                self._snd("pickup_key", proom, (x, y))
                self._acquired("gland")
            elif kind == "components":
                n = p.get("amount", 1)
                self.components += n
                self._snd("pickup_ammo", proom, (x, y))
                self.fx.append(("pickup_text", proom, (x, y),
                                f"+{n} COMPONENTS"))
            elif kind == "corpse_frame":
                c = p.get("contents", {})
                self.components += c.get("components", 0)
                self.station_kits += c.get("station_kits", 0)
                self._snd("corpse_recover", proom, (x, y))
                got = []
                if c.get("components"):
                    got.append(f"+{c['components']} COMPONENTS")
                if c.get("station_kits"):
                    got.append(f"+{c['station_kits']} SEED KIT")
                self.fx.append(("pickup_text", proom, (x, y),
                                "FRAME RECOVERED  " + "  ".join(got)))
                self.fx.append(("logvoice", p.get("line", 0)))
            elif kind.startswith("key_"):
                key = kind[4:]
                self.keys.add(key)
                self._snd("pickup_key", proom, (x, y))
                meta = p.get("meta")
                self.fx.append(("pickup_text", proom, (x, y),
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
                self.door_edges.pop((d["a"], d["ea"]), None)
                self.door_edges.pop((d["b"], d["eb"]), None)
                mx, my = self.sim.edge_midpoint(d["a"], d["ea"])
                self._snd("door_unlock", d["a"], (mx, my))

    # ------------------------------------------------------------------
    # the revival economy: seed stations, the fabricator, chassis reprint
    # ------------------------------------------------------------------

    STATION_RADIUS = 30.0

    def add_station(self, room: int, pos) -> None:
        """Register a seed station (chunk-entry seeds are planted by the
        streamer; the player plants forward seeds with kits, 9.3)."""
        for st in self.stations:
            if st["room"] == room and \
                    math.hypot(st["pos"][0] - pos[0], st["pos"][1] - pos[1]) < 24.0:
                return
        self.stations.append(dict(room=room, pos=(pos[0], pos[1])))

    def station_near(self, proom: int):
        px, py = self.player_pos()
        for st in self.stations:
            if st["room"] == proom and \
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
        proom = self.player_room()
        px, py = self.player_pos()
        self.station_kits -= 1
        self.add_station(proom, (px, py))
        self._snd("seed_plant", proom, (px, py))
        self._objective("SEED PLANTED - REVIVAL ANCHORED HERE")
        self._park_oob(mark)
        return True

    def buy(self, item: str) -> bool:
        d = SHOP[item]
        cost = d["cost"] + d.get("growth", 0) * (self.hp_ups if item == "hp_up" else 0)
        if self.components < cost:
            return False
        if item == "scrap_driver" and "scrap" in self.weapons:
            return False  # one is plenty; the pattern doesn't wear out
        self.components -= cost
        if item == "chassis":
            self.chassis += 1
        elif item == "station_kit":
            self.station_kits += 1
        elif item == "hp_up":
            self.hp_ups += 1
            self.max_hp += 15
            self.hp = min(self.max_hp, self.hp + 15)
        elif item == "scrap_driver":
            self.weapons.append("scrap")
            self.weapon = "scrap"
        elif item == "recall":
            self.recalls += 1
        elif "ammo" in d:
            t, n = d["ammo"]
            self.ammo[t] = self.ammo.get(t, 0) + n
        mark = len(self.fx)
        proom = self.player_room()
        self._snd("fabricate_buy", proom, self.player_pos())
        self.fx.append(("pickup_text", proom, self.player_pos(),
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
        self._snd("terminal_open", self.player_room(), self.player_pos())
        self._park_oob(mark)
        return True

    def _recall_tick(self, proom: int) -> None:
        if self.recall_t <= 0:
            return
        self.recall_t -= 1
        if self.recall_t > 0:
            return
        # channel held: the beacon spends itself and the seed takes you
        self.recalls -= 1
        px, py = self.player_pos()
        best = min(self.stations,
                   key=lambda st: (self.sim.hop_distance(st["room"], proom)
                                   if self.sim.hop_distance(st["room"], proom) >= 0
                                   else 1 << 20))
        room, (tx, ty) = best["room"], best["pos"]
        self.fx.append(("flash", proom, px, py, 30.0))
        if proom != room:
            self.reseat_player(room, (tx, ty))
        else:
            self.sim.set_pos(self.pid, tx, ty)
        self.sim.set_vel(self.pid, 0.0, 0.0)
        self._set_cam(necore.mat_mul(
            necore.mat_mul(
                necore.mat_translate(self.screen_w / 2, self.screen_h / 2),
                necore.mat_scale(self.zoom, self.zoom)),
            necore.mat_translate(-tx, -ty)))
        self._snd("reprint", room, (tx, ty))
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
        self._snd("terminal_type", self.player_room(), self.player_pos(), 0.6)
        self._park_oob(mark)
        return True

    def _think_tick(self, proom: int) -> None:
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
            self._snd("think_complete", proom, self.player_pos(), 0.6)
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
        proom = self.player_room()
        self._snd("pickup_key", proom, self.player_pos())
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
        self._snd("pickup_medkit", self.player_room(), self.player_pos(), 0.8)
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

    def reseat_player(self, room: int, pos) -> None:
        """Move the player's engine entity to another room (engine set_pos
        does not move room membership; respawn under the same groups)."""
        st = self.sim.get(self.pid)
        self.sim.remove(self.pid)
        self.pid = self.sim.spawn(room, pos[0], pos[1], PLAYER_RADIUS,
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
        death_room = self.player_room()
        best = min(self.stations,
                   key=lambda st: (self.sim.hop_distance(st["room"], death_room)
                                   if self.sim.hop_distance(st["room"], death_room) >= 0
                                   else 1 << 20))
        self.chassis -= 1
        for eid in list(self.bullets):
            self.sim.remove(eid)
        self.bullets.clear()
        room, (px, py) = best["room"], best["pos"]
        if self.player_room() != room:
            self.reseat_player(room, (px, py))
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
        self._snd("reprint", room, (px, py))
        self._park_oob(mark)
        return True

    def _station_scan(self, proom: int, inp: InputFrame):
        if not inp.interact:
            return
        if self.station_near(proom) is not None:
            self.fx.append(("shop",))

    def _terminal_scan(self, proom: int, inp: InputFrame):
        if not inp.interact:
            return
        px, py = self.player_pos()
        for t in self.terminals:
            if t["room"] != proom or t["read"]:
                continue
            if math.hypot(t["pos"][0] - px, t["pos"][1] - py) < 26.0:
                t["read"] = True
                self.fx.append(("terminal", t["text"]))
                self._snd("terminal_open", proom, t["pos"])

    def _exit_scan(self, proom: int):
        if not getattr(self, "exit_enabled", True):
            return
        if self.exit_room < 0:
            return
        px, py = self.player_pos()
        near = (proom == self.exit_room and
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
        gate_rooms = getattr(self, "exit_gate_rooms", None)

        def _gates(eid, e):
            if e["kind"] != lvl.exit_gate_kind:
                return False
            if gate_rooms is None:
                return True
            r = self.sim.get_room(eid)
            return gate_rooms[0] <= r < gate_rooms[1]

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
            if b["ttl"] <= 0:
                if b["kind"] == "dart" and self.sim.exists(bid):
                    _, x, y, *_ = self.sim.get(bid)
                    self._detonate_dart(bid, self.sim.get_room(bid), x, y)
                self.sim.remove(bid)
                del self.bullets[bid]

    # ------------------------------------------------------------------
    # queries for renderer / bots / tests
    # ------------------------------------------------------------------

    # Apex clamp margin: keeps the visibility apex a comfortable positive
    # distance inside the current room's polygon (any positive value clears
    # the "apex behind the portal line" hard cull from transfer overshoot;
    # see visible()). MUST STAY STRICTLY LESS than the engine's own
    # visibility::EDGE_BAND (currently 1.0, engine/necore/src/visibility.rs)
    # -- that constant's job is to widen a near-doorway sightline into a
    # full 180-degree fan BEFORE the room re-roots, so the pre-crossing
    # render already matches what root will show. If this margin ever grew
    # to meet or exceed EDGE_BAND, the clamped apex would sit pinned
    # exactly on/outside that band on every approach tick, `wide` could
    # never trigger pre-crossing, and doorway jamb walls (collinear with
    # the portal line, clipped away by the resulting narrow wedge) would
    # pop from absent to fully lit in the single tick the room re-roots --
    # this was a real, shipped bug; see game/tests/test_root_invariance.py.
    _APEX_EPS = 0.75

    def _clamp_apex(self, room: int, px: float, py: float):
        """Pull the visibility apex just inside `room`'s polygon. For 1-3
        ticks after a portal transfer the entity is registered in the new
        room while its position still sits marginally OUTSIDE it (collision
        overshoot; physics reclaims it). An exterior apex makes the
        traversal's sight-line cull discard the entry portal -- the room
        you just left, and everything behind it, blinks out for those
        ticks. At every doorway, constantly: the campaign-video flicker."""
        verts = self.sim.room_verts(room)
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
        proom = self.player_room()
        px, py = self.player_pos()
        # the camera apex is the player (strict LOS from the character),
        # clamped into the room so mid-transfer overshoot can't blind it
        px, py = self._clamp_apex(proom, px, py)
        # keep the frame's attached work lamp on the player: same clamped apex,
        # so its visibility cast can never start outside the room either
        self.player_light.room = proom
        self.player_light.pos = (px, py)
        return self.sim.visible_set(proom, self.cam, px, py,
                                    float(self.screen_w), float(self.screen_h),
                                    max_depth, max_instances)

    def _gate_count(self) -> int:
        kind = self.level.exit_gate_kind
        if not kind:
            return 0
        rng = getattr(self, "exit_gate_rooms", None)
        n = 0
        for eid, e in self.enemies.items():
            if e["kind"] != kind:
                continue
            if rng is not None:
                r = self.sim.get_room(eid)
                if not (rng[0] <= r < rng[1]):
                    continue
            n += 1
        return n

    def snapshot(self) -> dict:
        proom = self.player_room()
        px, py = self.player_pos()
        enemies = []
        for eid, e in self.enemies.items():
            r = self.sim.get_room(eid)
            _, x, y, *_ = self.sim.get(eid)
            enemies.append(dict(id=eid, kind=e["kind"], room=r, pos=(x, y),
                                hp=e["hp"], state=e["state"],
                                hops=self.sim.hop_distance(r, proom)))
        pickups = []
        for eid, p in self.pickups.items():
            r = self.sim.get_room(eid)
            _, x, y, *_ = self.sim.get(eid)
            pickups.append(dict(id=eid, kind=p["kind"], room=r, pos=(x, y),
                                hops=self.sim.hop_distance(r, proom)))
        return dict(
            tick=self.tick_count, hp=self.hp, dead=self.dead,
            complete=self.complete, room=proom, pos=(px, py),
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
            stations=[dict(room=st["room"], pos=st["pos"])
                      for st in self.stations],
            cloister=(dict(links=len(self.cloister["links"]),
                           attached=self.cloister["attached"])
                      if self.cloister else None),
            enemies=enemies, pickups=pickups,
            exit_room=self.exit_room,
            exit_next_edge=self.sim.next_edge(proom, self.exit_room)
            if self.exit_room >= 0 else -1,
            exit_key_needed=self.level.exit_key
            if self.level.exit_key and self.level.exit_key not in self.keys
            else "",
            exit_gate_kind=self.level.exit_gate_kind,
            exit_gate_remaining=self._gate_count(),
            exit_gate_rooms=getattr(self, "exit_gate_rooms", None),
            door_keys_needed=sorted(
                {d["key"] for d in self.doors if not d["open"] and d["key"]}
                - self.keys),
        )
