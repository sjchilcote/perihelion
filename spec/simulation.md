---
This specfile covers the simulation system of PERIHELION: the module `game/perihelion/sim.py` (the `GameSession` class and its data tables), the module `game/perihelion/topology.py` (the runtime topology owner), and the module `game/perihelion/terrain.py` (`walk-mask` terrain).

---

# Simulation

This specfile states the deterministic simulation of `PERIHELION`. `GameSession` holds the complete simulation state and moves it forward one tick at a time. Two runs have the same bits when they use the same level data, terrain-mask files, seed, and tick inputs. Menu-time calls and visibility-query calls must also be the same. The call sequence includes each call, its arguments, and its position in the tick sequence.

A default `visible()` call writes the active player position and aim to the player lights. A call with a different root or apex moves those lights to that viewpoint. The lighting map can then change `flicker` operation. Thus the visibility-query sequence is a deterministic input when it can change the light state before an AI tick.

The module uses Python and the `necore` engine. It does not use `pygame` or a wall clock. During construction and chunk addition, the terrain module reads the specified `walk-mask` files. The renderer and mixer read `session.fx` and `session.decals`. Bots and tests read `snapshot()` and `metrics`.

The world is a set of polygons. A portal connects an edge in one polygon to an edge in a different polygon. Bodies, projectiles, light, and sightlines cross these portals. Each polygon uses a different coordinate space. The code compares positions only after they use one space. Engine types raise an error for a comparison across spaces.

## Data tables — the module constants of `sim.py`

### Goal

The tables contain the numbers for weapons, enemy types, pickup types, turret types, `shop` items, and drops. Each number has one table as its source.

### Invariants

- Each weapon that does damage has an impulse value `imp` more than 0. An import-time `assert` checks this for each weapon other than `hole`.

- Each enemy type has more mass than the player (1.2) and a turn rate more than 0. An import-time `assert` checks the two conditions.

- The `warden` has 168 hp: 2 full `tau` charge hits (84 each) or 4 `rail` hits (42 each) kill it. An import-time `assert` checks this `relationship`.

### Verification

The module import stops at the `assert` when a weapon entry has no `imp`. Session values agree with the tables. For example, a `pistol` hit causes 12 damage and a `husk` has 15 hp.

### Implementation

`DT` is 1/60 second and `TICK_RATE` is 60. Entity groups use numbers 0 through 5 for the player, enemies, player projectiles, enemy projectiles, pickups, and structures. `ACTIVE_HOPS` is 5. The player has 100 hp, radius 6.5, acceleration 820, friction 5.6, and mass 1.2.

`WEAPONS` has these complete records. Angles are in radians.

```text
knife: dmg 9, cd 22, ammo None, sound knife_swing, range 27, arc radians(55), imp 420
pistol: dmg 12, cd 20, speed 1500, spread radians(1.6), pellets 1, ammo 9mm, each 1, sound pistol_fire, kick 2.2, imp 260
smg: dmg 7, cd 6, speed 1350, spread radians(5.5), pellets 1, ammo 9mm, each 1, sound smg_fire, kick 1.6, imp 110
shotgun: dmg 6, cd 54, speed 1150, spread radians(11), pellets 8, ammo shell, each 1, sound shotgun_fire, kick 7, imp 90
rail: dmg 42, cd 84, ammo cell, each 1, sound rail_fire, pierce 3, kick 5, imp 700
lightning: dmg 26, cd None, speed 720, sound lightning_fire, radius 220, force 1500, arc_range 150, arc_dmg 16, max_arcs 18, imp 1500
tau: dmg 9, cd 7, speed 1900, spread radians(2), pellets 1, ammo cell, each 1, sound tau_fire, kick 2.6, bounces 2, imp 160
hole: cd 18, sound terminal_open
```

`WEAPON_ORDER` is `knife, pistol, smg, shotgun, rail, lightning, tau, hole`. The `tau` charge numbers are radius 48 and center damage 42 with linear falloff. Burst impulse is 300. The impulse at full charge is 400. Full charge is 80 ticks. `TAU_OVERCHARGE` is 160 ticks.

The `hole` numbers are width 15, range 160, and connection polygon length 36. The `lightning` `implant` charges again in 540 ticks.

`ENEMIES` contains hp, radius, mass, acceleration, friction, turn rate, contact damage, cooldown, sounds, score, and special values. It has 15 enemy types. The types are `husk`, `mite`, `spitter`, `brute`, `shrieker`, `warden`, `vagrant`, `lacuna`, `flicker`, and 6 `core_*` part types.

`ADVERSARY` is the pair (`vagrant`, `lacuna`). `WARDEN_CRUISE` is the `warden` acceleration divided by its friction. The `engulf` values include range 120, charge 12 ticks, lunge multiplier 2.5, and catch threshold 0.5. They also include hold damage 75 each second, pull 260, and cooldown 300 ticks.

The Adversary timer constants are `recovery` 3600 ticks, `arrival` `grace` 600 ticks, crossing 48 ticks, and root 150 ticks. The safe window is 300 ticks. The `strand` limit is 420 ticks. The mark decays fully in 840 ticks. It adds 0.30 `NOISE` on each 5-tick beat and adds 8.0 doorway trail on each crossing.

The `shrieker` constants are speed multiplier 3.0, fire range 210, aim lock 18 ticks, and marker speed 620. Marker life is 150 ticks, `rally` is 720 ticks, search limit is 2700 ticks, and the position behind the target is 95.

`PICKUPS` has these complete records: `ammo_9mm (radius 5, amount 30)`, `ammo_shell (5, 7)`, `ammo_cell (5, 8)`, `medkit (6, 35)`, `weapon_smg (7)`, `weapon_shotgun (7)`, `weapon_rail (7)`, `weapon_tau (7)`, and `portable_hole (6)`. The other records are `safe_polygon_core (7)`, `turret (6)`, `implant_lightning (7)`, `key_red (5.5)`, `key_blue (5.5)`, `key_gold (5.5)`, `key_void (5.5)`, `components (5)`, and `corpse_frame (8)`.

`SHOP` has these complete records: `chassis (cost 8, label SPARE CHASSIS)`, `station_kit (12, SEED STATION KIT)`, `hp_up (10, HULL PLATING +15, growth 6)`, `recall (6, RECALL BEACON)`, `ammo_9mm (3, 9MM x30, ammo (9mm, 30))`, `ammo_shell (3, SHELLS x7, ammo (shell, 7))`, and `ammo_cell (4, CELLS x8, ammo (cell, 8))`.

`DROP_TABLES` has these complete records.

```text
husk [(0.35, ammo_9mm)], mite [(0.04, ammo_9mm)], spitter [(0.30, ammo_shell)], brute [(0.55, ammo_cell)], shrieker [(0.5, ammo_9mm)]
warden [(1.0, ammo_9mm), (1.0, ammo_shell), (0.5, ammo_cell)], flicker [(0.4, ammo_9mm)], vagrant [(0.3, ammo_9mm)], lacuna [(0.2, ammo_9mm)]
core_scriptorium [(1.0, ammo_cell), (1.0, medkit)]
```

The other 5 `core` types have empty lists. `SENTRIES` has the one `sentry` record: radius 7, damage 14, cooldown 18, range 700, start wait 10, projectile speed 1400, and sound `sentry_fire`. `BUILDING_UNPACK_TICKS` is 1800. `CALL_TRANSMIT_TICKS` is 480.

### Caveats

Defect: the drop loop in `_kill_enemy` stops at the first accepted `roll`. Thus a table with more than one pair can return only one item. The `warden` table lists `ammo_9mm` at 1.0 first. Thus its `ammo_shell` (1.0) and `ammo_cell` (0.5) pairs cannot occur.

The `core_scriptorium` table lists `ammo_cell` at 1.0 first. Thus its `medkit` pair cannot occur. Comments at the two tables state that more than one item is necessary.

No enemy type drops a medkit. The tables contain ammunition only. The approved requirement is that a kill does not increase hp.

## `InputFrame` — one tick of input

### Goal

One record holds all player input for a tick: movement, aim point, fire, `alt`, `interact`, and weapon selection. A run with a recorded sequence of these records has the same bits.

### Invariants

- `pack` and `unpack` are inverse operations on the `pack` output.

- `weapon` 0 keeps the weapon. The values 1 to 8 select `WEAPON_ORDER[weapon - 1]`.

### Verification

`InputFrame.unpack(f.pack())` returns a record equal to `f` after `pack` decreases its precision. A run from the recorded `InputFrame` list has the same bits. A call to `unpack` with less than 8 values raises `IndexError`. Values after position 7 have no effect.

### Implementation

The fields `mx` and `my` are screen-space movement in -1 to 1. Their defaults are 0. The fields `ax` and `ay` are the aim point in internal screen pixels. Their defaults are 240 and 135. The 3 Boolean fields have a default of `False`.

The `weapon` field has a default of 0. `pack` keeps 4 decimals for movement and 2 decimals for aim. It changes the 3 Boolean fields to 0 or 1. Python `round` selects the nearest value. At an equal distance between values, it selects the value with a last number divisible by 2.

`unpack` indexes the first 8 values. It does not check types or ranges. The first 4 values and `weapon` stay without change. The 3 Boolean values use `bool(value)`. A value can go through this function and cause an error during a subsequent tick.

### Caveats

`pack` cuts precision. A replay from its output agrees with a run that received values with decreased precision, not the raw values.

## `Brand` — the mark on the player

### Goal

The mark is the state that a `shrieker` marker applies to the player. While it holds, the player emits signals. Each portal crossing writes a trail value on the crossed doorway. The mark decays each tick, and only a new marker hit sets it to full.

### Invariants

- `strength` stays in 0 to 1. `active` is `True` only when `strength` is more than 0.

- `renew` sets `strength` to 1.0 and records the source entity id.

### Verification

After a marker hits the player, the mark is active. Without a subsequent hit, decay call 841 ends it. Floating-point calculation keeps a positive value after call 840. Call 841 clamps the value to 0 and emits `brand_expired` in that tick. While the mark is active, the `NOISE` field increases on each 5-tick beat. Each portal crossing adds 8.0 doorway trail on the `departure` edge reported by the transfer event.

### Implementation

`Brand` has 2 fields: `strength` (starts 0.0) and `source_eid` (starts -1). `decay(per_tick)` decreases `strength` by `per_tick` and stops at 0. `tick` calls `decay(1 / 840)` each tick. When the mark goes from active to not active, `tick` emits a `brand_expired` trace event with the source id.

### Caveats

`source_eid` keeps its last value after the mark ends. The `brand_expired` event reads it after the decay. This is correct because `decay` does not touch `source_eid`.

## `GameSession.__init__` — session construction

### Goal

Construction assembles the full world from a `Level` and a seed. It adds the engine polygons, `walk-mask` terrain, portals, lights, and doors. It also adds the player, specified entities, hub, `marrow`, `core` `organ`, and all output channels. The first `tick` call can run after construction.

### Invariants

- The same level data, seed, and difficulty result in the same initial state.

- Construction replaces `level.polygon_verts` with a new list of copied point lists before it assembles the engine world. The session keeps the supplied `Level`. Ticks for `soft` walls write active engine points back into that level.

- The hub is in each world, off the map that the player can walk. One `TopologyManager` controls the topology.

- Each material body has contact with each other material body. Only pickups and structures have `material=False`. There is no collision matrix. An enemy projectile can contact a different enemy. A `lob` or `dart` can damage that enemy, while a `spit`, marker, or snare is removed without damage.

### Verification

Two sessions from the same level and seed return equal `snapshot()` output at each tick when their input is equal. On `hard`, enemies receive 1.35 times hp and the player receives 1.25 times damage. An enemy projectile can hit a different enemy, and one enemy body can block a different body.

### Implementation

The construction sequence:

- Construction accepts a full `Level`, an integer seed, a screen pair, zoom, player state, and difficulty. A deterministic session also includes the full input sequence, plus all menu-time calls, their arguments, and their sequence. The defaults are seed 0, screen (480, 270), zoom 0.45, no player state, and difficulty `normal`. Only `hard` changes operation. All other difficulty text uses the `normal` multipliers.

- The session keeps the given difficulty text. On `hard`, enemy hp uses 1.35 and player damage uses 1.25. Construction starts `Random(seed)`.

- It assembles `necore.Sim`, adds each polygon, applies the terrain masks (see the terrain unit), and connects the specified portals. Pairs without a transform go through `connect`. Pairs with a transform go through `connect_with_xform`.

- Construction assembles the `LightingSystem` and 3 attached player lights. The `flashlight` cone has RGB (255, 226, 188), intensity 1.0, radius 230, and arc 1.15 along the aim. The work `lamp` has intensity 0.64 and radius 88. The muzzle light has radius 320 and intensity 0. A pool has 4 flash lights with radius 200 and intensity 0. There is no general light level.

- Each `level.doors` entry becomes a record with its 2 edges, its `key`, and `open=False`. It also receives the gate prompt from the key metadata. `door_edges` maps each of the 2 (polygon, edge) pairs to the `key`. The exit prompt comes from the exit key metadata.

- The player body has radius 6.5 and mass 1.2. It uses the player group, `rest_wall=0`, `rest_ent=0.05`, and `max_substep=6`. The complete player state schema is below.

```text
max_hp=100, hp=max_hp, ammo={9mm:48, shell:0, cell:0}, weapons=[knife,pistol], weapon=pistol
components=0, `chassis`=0, station_kits=0, hp_ups=0, `mind`=[], think_focus=None
think_progress={}, think_done=[], `recalls`=0, holes=0, dmg_taken_mul=1.0, `cloister` missing or False
```

- The code applies `int` to `max_hp`, components, `chassis`, `station` kits, hp `upgrades`, thought progress, `recalls`, and holes. It applies `float` to the damage multiplier. It applies no minimum or maximum. If the selected weapon is not in the weapon list, it selects the last weapon. An empty weapon list then causes `IndexError`. Construction calls `_recompute_mind` and adds the start position as the first seed `station`.

- Polygons with type `otherworld` become `soft` polygons through `sim.soften_polygon`.

- The screen is a named space (`Screenspace`). The aim starts as an `Offset` (1, 0) in the player polygon space. `_set_cam` starts the camera matrix with translation to the screen center. It then applies the zoom scale and translation by the negative player position.

- It adds the empty containers: `enemies`, `bullets`, `pickups`, `terminals` (from the level, each with `read=False`), `stations`, `decals`, and `decal_versions`. It starts the Adversary counts: `adversary_census`, `adversary_lost`, `adversary_withdrawn`, `adversary_returned`, `adversary_out`, and `adversary_killed_by`.

- It spawns each specified entity through `_spawn_from_spec` and keeps the exit polygon and position. When `player_state` records that the player had the `cloister`, construction adds the `cloister`.

- Output objects are the `fx` and `_oob_fx` lists and the `TraceBus`. Helper objects are the `SenseQuery`, the `SignalField`, the `CaptureSystem`, and the `CallMedium`. `_describe_entity` is the identity source of the `SenseQuery`.

- For the hub, construction starts the `TopologyManager` with `signals.on_topology_changed` as its change hook. It assembles the hub, `MarrowController`, and `CoreOrgan`, then calls `_embody_core`. It reads the free seams from `hub.breach_edges`.

- It spawns the hub `shelf` from `GUARDIAN_SHELF`, with one body for each entry. The bodies form a grid across the hub areas, and each body has `tether=True`. It spawns the level entities from `RESIDENT_PLACEMENT` at random positions in their polygons.

- `metrics` starts with `ticks`, `shots`, `hits`, `kills`, damage given, damage received, pickups, transfers, and deaths. It also has the set of `visited` polygons, the hp list, and `completed=False`.

### Caveats

Defect: the new `polygon_verts` list on the supplied `Level` does not isolate sessions. A session changes that same level as `soft` walls move. A subsequent session can start from the changed points. Sessions that use the same `Level` at the same time also use the same metadata and can change it.

The topology change hook tells the signals only. The lighting system has its `on_topology_changed`. The door, hole, `cloister`, and stream paths call the two. The breach paths call only the `TopologyManager` hook. See the `marrow` unit for the defect this causes.

The construction does not compare `hp` from `player_state` with `max_hp`. A state with `hp` more than `max_hp` starts with those values.

## Spawn functions — `_spawn_from_spec`, `spawn_enemy`, `spawn_pickup`, `spawn_sentry`

### Goal

These functions add enemies and their AI records to the world. They also add pickups as touch objects and turrets as structures. Pickups and turrets have no physics. The level and the streamer use `_spawn_from_spec` for specified entities.

### Invariants

- An Adversary spawn increases `adversary_census` for its type.

- A pickup and a turret are not material and do not transfer through portals.

- Each enemy samples its threshold for the fraction of active peers and `raid` value at spawn.

### Verification

A spawned `husk` shows in `snapshot()` with 15 hp and state `idle`. A spawned `flicker` starts in state `lurk`. A pickup does not block movement. A level entity with an unknown type stops construction with `ValueError`.

### Implementation

`spawn_enemy` spawns the body with the radius and mass of the type, in the enemy group (`rest_wall` 0, `rest_ent` 0.2, `max_substep` 8). The complete initial record has `kind`, hp times the difficulty multiplier, and state `idle` (`lurk` for `flicker`). The fields `touch_cd`, `spit_cd`, `scream_cd`, `lob_cd`, `snare_cd`, `wander_cd`, and `buff` start at 0. `trace_intensity` starts at 1.0.

`q_thr` is one random value from 0.25 through 0.45. `raid` is a random truth value that is `True` for the fraction `coord.RAID_FRACTION`. Subsequent operation adds fields only when the related state starts.

`spawn_pickup` spawns at mass 100 in the pickup group and sets `transfers=False, material=False`. Its record starts with `kind`. It adds `meta` when the caller supplies key metadata. It then copies all entries from the optional `extra` dictionary into the record. Those entries can replace `kind` or `meta`.

`spawn_sentry` follows the same process in the structure group. Its record contains the type, cooldown 0, and `spin` at the initial wait value.

`_spawn_from_spec` sends on the entity record type. Enemy types go to `spawn_enemy` with 3 optional fields. They are an `hp` value times the difficulty multiplier, `tether`, and a `dormant` threshold with default 0.5. Turret types go to `spawn_sentry`.

Pickup types go to `spawn_pickup`, and key pickups attach their key metadata from the given table or session level. The function ignores the type `player`. Each other type raises `ValueError`.

The streamer supplies the key table of each chunk, because key ids mean different objects on different `decks`.

### Caveats

A `dormant` enemy does not move and has no task. Local `NOISE`, local `DISTRESS`, or a hit can `wake` it.

## Output channels and effect helpers

### Goal

The simulation sends events to the renderer and mixer through small output records. These records state sounds, positioned effects, screen shake, freeze ticks, decals, and prompt lines. Only the helper functions in this unit change a coordinate to bare numbers.

### Invariants

- Gameplay code does not hold a bare coordinate pair. Only these helpers call `Coordinate.local()` on the path out.

- The decal list of a polygon holds at most 250 entries.

- `decal_versions[polygon]` increases on each decal change, also when the list length stays 250.

### Verification

A fired weapon adds a `sound` entry to `fx` with the polygon and position. After 251 decal writes, a polygon holds 250 decals and has version number 251. `douse_player_lights` sets all player lights to intensity 0. After that call, a flash request does not change a light.

### Implementation

`_snd(name, at, vol)` adds `("sound", name, polygon, x, y, vol)`. `_fx_at(tag, at, *extra)` adds `(tag, polygon, x, y, *extra)`. `_shake(mag)` adds `("shake", mag)`. `_hitstop(ticks)` raises `freeze` to at least `ticks`. `_decal(kind, at, size, angle)` adds an entry to `decals[polygon]`, removes the first entries more than 250, and increments the version.

`_objective(text)` adds `("objective", text)`. `_acquired(item)` adds an `ACQUIRED:` prompt from `ACQUIRE_LABELS`. `pulse_light(at, radius, intensity, color)` selects the next of 4 flash lights in sequence and sets its polygon, position, color, radius, and intensity. After `douse_player_lights`, it does not change a light. `douse_player_lights` sets the intensity of the `flashlight`, work `lamp`, muzzle light, and all flash lights to 0. It then sets `_lights_doused`.

### Caveats

Spoken text lives only in `conversation` scenes and wall terminals. `PERIHELION` reads specified `level.radio` records as no data. The one combat text channel is the `objective` line.

## Camera — `_set_cam`, `_cam_step_follow`, `_cam_rebase`, `camera_transform`, and the position queries

### Goal

The camera maps the player polygon space to the screen. The smooth matrix keeps fractional precision, while the rendered matrix moves only by full pixels. Thus no tick shows a fraction-pixel step. A portal crossing writes the two matrices in the new polygon frame. The view does not change.

### Invariants

- The rendered `cam` and the smooth matrix always have the same linear part. Their translations are different by at most 0.5 pixel.

- Each screen change of `cam` from one tick to the next is a translation of full pixels, portal crossings included.

- `_set_cam` is only for hard camera cuts: spawn, `recall`, and `reprint`.

### Verification

A slow walk shows objects with stable 1-pixel outlines and no movement between pixel rows. A portal crossing shows no 0.5-pixel step of the full image. After a `reprint`, the camera centers on the `station`.

### Implementation

`_set_cam(m)` keeps `m` as the smooth matrix. It keeps `cam` as a copy with translation at the nearest full pixels. `_cam_step_follow(smooth_new)` changes the screen-space difference between the new smooth translation and `cam` to the nearest full pixel. It applies that full pixel translation to `cam` and keeps the new smooth matrix. No other value holds the error. `cam` contains the fractional-pixel error, which the next tick measures again.

`_cam_rebase(m9)` multiplies the two matrices on the right by the inverse portal matrix. This keeps the fractional-pixel error because the operation applies the same linear part to the two translations.

`camera_transform()` returns a named `Transform` from player polygon space to screen space. It uses the smooth matrix. `player_pos()` returns the player position as a `Coordinate` in player polygon space. `player_polygon()`, `player_space()`, and `entity_pos(eid)` are the related short queries. In `tick`, the follow step moves the smooth matrix in the direction of the screen center with multiplier `min(1, 7 * DT)`. It then calls `_cam_step_follow`.

### Caveats

The previous version changed the translation to an integer pixel again at each portal crossing. That result can be different from the previous frame by at most 0.5 pixel for one tick. This caused the full image to step. `_cam_rebase` replaces that path and does not change the translation again.

The aim change of 2026-07-12 (see the player control unit) removed the `cam` pixel adjustment from the sim. Bot recordings added before that change cause a different replay.

## `tick` — the tick sequence

### Goal

`tick(inp)` moves the world forward in a set sequence. Telemetry, signals, active set calculation, thought, player control, enemy AI, friction, physics, and events run first. Projectile decay, turrets, holds, `core`, `marrow`, `scans`, time counts, and camera follow run next. This sequence is part of the contract. Each unit below runs at its named point.

### Invariants

- At tick start, clear `fx` and move the parked menu-time events from `_oob_fx` into it before new events.

- The telemetry sample operations run before the returns at the top for `dead`, `complete`, and `freeze`. A world without movement continues to report.

- After physics, the code reads the player polygon again, before the pickup, terminal, `station`, and exit `scans`. Physics can move the player through a doorway.

- A tick with player death ends after the light decay step. No `scans` run on a player after death.

### Verification

A session in `hitstop` continues to emit its field samples on the 60-tick beat. A player who crosses a doorway and touches a pickup in the same tick collects it in the correct polygon. After a death, the `wreck` is not collected in the death tick.

### Implementation

The sequence of one tick:

- Move `_oob_fx` into `fx`. Increase `tick_count`, and set `metrics["ticks"]` to the new value. Thus the metric equals `tick_count` on live ticks, death ticks, complete ticks, and frozen ticks. Emit the `InputRecord` trace event. On each 15-tick beat, emit the player sample to the trace.

- Step the signal field to this tick. Decay the mark by 1/840, and emit `brand_expired` when it ended in this tick.

- While the player lives, raise `TRAIL` in the player polygon to a minimum of 0.80 on each 5-tick beat. While the mark is active, also emit `NOISE` equal to 0.30 times the mark's `strength`. On each 15-tick beat, emit 0.011 `KIN` in each enemy polygon. On each 60-tick beat, emit `FieldSample`, call `_sample_telemetry`, and add `hp` to the hp list.

- Return when `dead` or `complete`. When `freeze` is more than 0, decrease it and return.

- Build the active set with `set_active_within(player polygon, 5)`. For each breach, also activate its hub polygon in 3 hops and its world polygon in 1 hop. Keep each enemy marked `dispatched` and each body in `ascent`, `hunt`, `waking`, or `call` `awake`. Keep door-held bodies and bodies in `engulf` `awake`. Activate their polygons in 1 hop. Other idle bodies `sleep`.

- For each `soft` polygon, copy the active wall points from the engine into `level.polygon_verts`.

- On each 30-tick beat, run `_containment_sweep`. Run `_recall_tick`. When the `mind` unlocks regeneration, add the regeneration rate on each 60-tick beat. Stop at the limit fraction of `max_hp`.

- Run `_think_tick`, `_player_control`, and `_enemy_ai`. Apply friction to the player (5.6) and to each enemy (the value of its type): velocity times `max(0, 1 - fric * DT)`.

- Step the engine with `DT` and `consume` its events. Run `sweep_bullets`, `_turret_tick`, `_sentry_tick`, `captures.step` (with `_capture_burn` as the damage door), `_core_tick`, and `_marrow_tick`.

- Decay the muzzle light and each effect light: times 0.68 each tick, to 0 below 0.06.

- Return when the player had a death during the events. Read the player polygon again. Run `_pickup_scan`, `_terminal_scan`, `_station_scan`, and `_exit_scan`.

- Decrease the cooldown, damage gate, snare, and `revival` `grace` time counts. Increase the `lightning` charge to a maximum of 540. Do the camera follow step.

### Caveats

Friction is a simulation decision, thus it lives in the sim and not the engine. At the set tick rate, top speed is approximately 6 to 8 percent below `accel / fric`.

`_apply_friction` catches each error from a removed body and returns. This is the one tick error path that emits no message.

## `_player_control` — movement, aim, and weapon selection

### Goal

This function turns one `InputFrame` into player steps. The steps are weapon change, aim, movement acceleration, fire, and the two `alt` operations. The aim is in player space. The `alt` operations are `tau` charge and the `lightning` `implant`.

### Invariants

- A weapon change waits at most 18 ticks, not the full recycle time of the previous weapon.

- The aim maps through the smooth camera matrix, and not through the pixel-rounded `cam`. The sim result does not change with the render adjustment.

- Input supplies the aim point in screen space. The named inverse camera transform changes it to player polygon space.

### Verification

After a `rail` fire (cooldown 84), change to the `pistol` in the same second. The `pistol` then fires in 18 ticks or less. The snare slows movement by its multiplier while `snare_t` is more than 0. With the `tau` selected, `alt` held for more than 160 ticks does 12 damage and removes the charge.

### Implementation

The steps:

- Weapon selection: input 1 to 8 selects from `WEAPON_ORDER` when the player has that weapon, and sets `cooldown = min(cooldown, 18)`.

- Aim: read the aim point as a screen-space position and apply the inverse camera transform. Subtract the player position to calculate the direction. When its length is above `1e-6`, change it to unit length. Set the body direction and keep it as `self.aim`. If the length is not above this value, keep the body direction.

- Movement: the linear part of the same inverse transform maps the screen-space input direction back into world space. Calculate the push from the unit direction times `min(1, |m|) * 820`. Multiply it by the acceleration multiplier, the snare multiplier, and `DT`, and add it to the velocity.

- Fire: when `fire` is on and `cooldown` is 0 or less, keep `last_fire_tick` and call `_fire`.

- `alt` with the `tau` selected increases `tau_charge` while a `cell` is available. The first tick plays `tau_charge`. The charge fraction is `min(1, tau_charge / 80)`. The control function does not calculate damage or impulse. A release crosses the tick count to `_fire_tau_charged`, which calculates the projectile damage and impulse.

- A charge that is not full has no burst. Above 160 ticks, the player receives 12 damage from `tau_overcharge`. The damage sound plays, and the charge becomes 0. If `alt` stays held, a new charge starts on the next tick. A release of `alt` with a nonzero charge fires the charged `tau`.

- `alt` in the other condition: with the `lightning` `implant` and a full charge (540), fire the `lightning` projectile.

### Caveats

When the `cell` count becomes 0 while `alt` is held, the charge fires in that tick. The charge path operates only while a `cell` is available.

## Player weapons — `_fire`, `_fire_rail`, `_fire_lightning`, `_fire_tau_charged`, `_detonate_tau`, `_detonate_dart`, `sweep_bullets`

### Goal

`_fire` fires the selected weapon from the player position. Each damage weapon pushes through the physics with its `imp` value. The `rail` crosses through portals. The `lightning` projectile is the group control burst with chain arcs. A full `tau` charge causes its burst on contact with a small burst. `sweep_bullets` decreases the life of each projectile and removes the projectiles that have no life.

### Invariants

- Each direction is an `Offset` in the `shooter` coordinate space. Target positions come from a view record or world initialization. They do not come from a raw subtraction across spaces.

- The engine receives the muzzle point after it is pushed into the polygon. Thus a `shot` near a wall or portal cannot spawn out of the polygon and `rebound` into the `shooter`.

- Fire emits `NOISE` (0.8 to 1.0) in the `shooter` polygon. The field changes enemy state directly. It does not call `wake`.

- While a `captor` holds the player, each weapon fires into the `captor`. The aim direction has no effect.

- A straight projectile (`bullet`, `tracer`, `turret`) below speed 700 has speed below 700, and the code removes it. A slow straight projectile has hit something before.

### Verification

A `pistol` `shot` decreases `9mm` by 1, emits the fire sound and shake, and lights the muzzle flash at 1.35. It spawns a projectile with 12 damage. A `rail` `shot` damages at most 3 bodies along the ray and adds a `scorch` decal to the wall. A `lightning` burst damages each enemy in 220 units in its polygon.

It then chains through at most 18 arcs of 16 damage. A fully charged `tau` calls `_detonate_dart` on its first contact. A `knife` attack hits each enemy in the player polygon in a 55-degree arc. Its range is 27 units plus the body's radius.

### Implementation

`_fire` reads the weapon record and aim. The hold system can return a target in the world. The function then transforms the `captor` position into player space and aims in its direction. The weapon paths follow.

- `lightning`: set cooldown to 18. Fire the projectile when the charge is full. Otherwise, emit `dry_click`.

- `hole`: set the cooldown from the table, then call `_hole_shot` (see the hole unit).

- `knife`: set cooldown to 22, emit the `knife_swing` sound, and count the attack in `metrics`. Apply 9 damage and impulse 420 to each enemy in the player polygon that is in a 55-degree arc. The range is 27 units plus its radius. Emit the hit sound and shake 1.5 if an object is hit.

- Ammunition weapons: when ammunition is not sufficient, set cooldown 18 and emit `dry_click`. Otherwise, `spend` the ammunition and set the cooldown. Count the fire and emit the fire sound and `kick` shake. Light the muzzle flash at intensity 1.35 at the muzzle point.

- `rail`: see below.

- For each `pellet` from a weapon other than `tau`, turn the aim by a random spread. Multiply that spread by the spread multiplier. Multiply the weapon speed by a random value from 0.95 to 1.05.

- Spawn a projectile with radius 1.6 and mass 0.002. Its velocity is the `shot` direction times that speed plus 0.4 times the player velocity. Its record has a 90-tick life and the weapon's damage and impulse. A `tau` projectile has a 140-tick life, `bounces=2`, and `rest_wall=1`. Thus the engine lets it `rebound`.

- During a `captor` hold, apply the damage directly to the `captor` and do not spawn a projectile. The spawn-overlap correction can remove a projectile spawned in the `captor`.

`_fire_rail` raycasts through at most 8 portal hops and 2000 units against the enemy group, with at most 3 hits. At each hit, it transforms the ray direction into the body's coordinate space through the ray's transform chain. It applies 42 damage with impulse 700, then continues from a point on the far side of the body. A wall hit adds a `scorch` decal and stops the ray. A visual tracer follows the path at speed 5200 for 14 ticks, and the simulation freezes for 2 ticks.

`_fire_lightning` sets the charge to 0 and spawns a projectile with radius 3, mass 0.02, and a 240-tick life. Its velocity is the `shot` direction at speed 720 plus 0.5 times the player velocity. At the burst point, `_detonate_dart` emits the `lightning` effect, `NOISE` 1.0, the sound, and shake 9. It also emits a 5-tick freeze and a radius-22 `scorch` decal. Each enemy in 220 units in the burst polygon receives impulse `1500 * falloff` and damage `26 * (0.6 + 0.4 * falloff)`. It then adds at most 18 chain arcs.

Each arc selects the nearest enemy that is not in the hit set. The enemy must be in the same polygon and in 150 units of a previous hit point. The arc then applies 16 damage. The projectile also causes its burst when its life ends.

`_fire_tau_charged` `spends` the smaller of the available `cell` count and 5. Thus it `spends` all available cells when the count is 1 to 4, and it `spends` 5 when the count is 5 or more. It calculates the charge fraction as `min(1, tau_charge / 80)`. It calculates the `power` as the charge fraction times (0.4 + 0.6 times cost/5). Damage to the target that it hits directly is 18 + 66 times the `power`. The impulse on that target is 400 times the `power`.

At full `power` the projectile causes its burst on first contact (`bounces=0`, `aoe`). Full `power` is a charge fraction of 1 and a cost of 5 cells. A charge of 80 ticks with only 1 to 4 cells is not full `power` and keeps 3 wall `rebounds`. In a `captor` hold, the damage and impulse go into the `captor` directly. `_detonate_tau` damages and pushes each other enemy in the polygon in radius 48, with linear falloff (damage 42, impulse 300 at the center).

`sweep_bullets` decreases the life of each projectile. It also kills `bullet`, `tracer`, and `turret` projectiles below speed 700. The check removes a slow projectile before it can move back to its source. A projectile that touched a wall at spawn has no wall event, but the spawn overlap correction removes its speed. Without this check, it moves back into the `shooter`. A removed `dart` causes its burst at its last position.

### Caveats

Decision open (see `spec/open-questions.md`, item `SIM-CHARGED-BURST`): the Goal and Verification use “full charge” for an 80-tick charge. The Implementation uses `power` from the charge and ammunition cost for the burst on contact. This file records the active operation. It does not select the necessary requirement.

The `knife` connects only with enemies in the player polygon. Each other weapon operates through portals.

The `tau` burst and the `lightning` burst connect only with enemies in the burst polygon. The chain arcs also stay in that polygon. A body at a distance of one hop is safe from the two.

Before the muzzle push, hits on the `shooter` at spawn were approximately 40 percent of all player damage. The push, plus the 2-tick spawn requirement in `_contact`, removes that class.

## The carried hole and the `cloister`

### Goal

The hole cuts a pair of wall marks and connects them with a connection polygon. This adds a portal from the player. With the `cloister`, a hole fire connects to the `cloister` and does not complete a pair. The `cloister` is a safe polygon for the player only. Its connection polygon attaches again to the newest connection each time the player moves into the `sanctum`. `carve_door` and `_shift_edge_maps` form the wall-division system used by the two paths.

### Invariants

- A hole must have a wall span of width 15 plus a 2-unit margin on each side. A `shot` too near a corner emits `dry_click`.

- The hole does not cut the walls of the `cloister`.

- After each `split_edge`, `_shift_edge_maps` moves each Python-side (polygon, edge) value above the `split`. This includes the door records, `door_edges`, and the `cloister` connections.

- The `sanctum` holds 2 turrets that cannot receive damage, plus a `medkit` and `ammo_9mm` pickup.

### Verification

Two hole `shots` on two walls connect them with a 36 by 15 connection polygon. They emit the `door_unlock` sound, a light effect, and shake. A `shot` with no hole charges emits `dry_click`. With the `cloister`, each `shot` adds a connection and attaches the connection polygon to it in the same tick. When the player moves into the `sanctum`, the connection polygon attaches to the next connection.

### Implementation

`_hole_shot` raycasts 160 units in the `shooter` polygon without crossing a portal. A hit that is not a wall emits `dry_click`. It calculates the position along the edge. The two sides must fit 7.5 units for 0.5 of the opening plus a 2-unit margin.

Otherwise, it emits `dry_click`. With the `cloister`, `shots` at the `sanctum` or the walls of the connection polygon also emit `dry_click`. Each other applicable `shot` `splits` the wall, adds and attaches the connection, `spends` a hole, and plays the effects.

Without the `cloister`, the first fire keeps the mark (polygon, edge, `t0`, `t1`, position) with a small `scorch` and sound. The second fire on a different wall does these steps:

- `Split` the wall of the first mark, then the second. The two marks can have one polygon with the second edge index above the first. In that condition, add 2 to the second index first. When the second `split` moved the first door, add 2 to the first door index.

- Add the connection polygon (36 by 15) and connect the two doors to it.

- Emit 2 `TopologyChanged` trace events, tell the signal and lighting systems, and add a texture seed for the connection polygon.

- `Spend` a hole, remove the mark, and play the sound, flash, and shake.

`carve_door(polygon, near, width=70)` examines each wall that has no portal and is at least `width + 8` units long. It finds the point nearest to `near` and keeps a 3-unit margin at each end. It `splits` the best wall and updates the maps. It returns the new door-edge index, or `None` when no wall fits.

`_build_cloister` adds the 8-sided `sanctum` with radius 85. It cuts a door of width 15 in edge 4, adds the connection polygon, and connects them. It spawns turret structures at (-30, -34) and (-30, 34), spawns the supply pickups, and adds texture seeds. It removes 0.5 of the player's hole mark.

`_attach_cloister(idx)` disconnects the previous connection when it has one. It then connects the far edge of the connection polygon to connection `idx`, emits trace events, and sends the two topology messages. `_rotate_cloister` moves to the next connection.

### Caveats

Defect: `_shift_edge_maps` does not move `hole_mark`. A different `split` can move the marked polygon's edge indexes between the two mark fires. One example is a breach `carve` in that polygon. Then the kept mark is incorrect, and the second fire `splits` the incorrect span.

Defect: simulation-side `splits` do not tell the `TopologyManager`. It corrects its `EdgeHandle` records only for `splits` done through `carve`. A hole `shot` can divide an edge before a breach `mouth` edge. The `TopologyManager` then keeps an incorrect index for that `mouth`.

A subsequent seal disconnects the incorrect edge. The module text in `topology.py` states that `EdgeHandle` records stay correct across `splits`. That is `True` only for `splits` done through the `TopologyManager`.

## `append_chunk` — stream a different level into the live world

### Goal

The streamer adds polygons from a different `Level` to the live world. It applies the polygon offset to doors, wall terminals, entities, lights, texture seeds, polygon types, and `soft` polygons. The function returns the offset.

### Invariants

- Chunk-local polygon indexes move by the offset in each record: connects, doors, terminals, entities, and lights.

- Chunk polygons with type `otherworld` become `soft` and go into `soft_polygons`.

### Verification

After a chunk add, a door of the chunk opens with its key. A chunk terminal reads at its position. The specified enemies of the chunk stay in their polygons. The offset equals the polygon count before the add.

### Implementation

The function adds each polygon and applies the walk masks of the chunk at the offset. It connects the portals of the chunk. Pairs without a transform get a `TopologyChanged` trace event and the two topology `notices`. Pairs with a transform go through `connect_with_xform`.

It adds the doors, terminals, and entities. The doors have 2 edge map entries. The entities use `_spawn_from_spec` with the key table of the chunk. It moves and adds the chunk lights to the lighting system. It extends the texture seeds, sets the `otherworld` polygons to `soft`, and extends `polygon_kinds`, `polygon_verts`, and `polygon_centroids`.

### Caveats

Defect: connections with a transform (`connects_x`) do not emit a `TopologyChanged` trace event. They also do not emit a signal or lighting `notice`. Connections without a transform emit all 3. A chunk can move through a transformed seam. The signal and lighting caches can then stay incorrect until a subsequent topology change.

## Cloister turrets and `sentry` weapons — `_turret_tick`, `_sentry_tick`

### Goal

The `cloister` turrets keep enemies out of the `sanctum`. These weapons have no range limit in their sightline. The `sentry` weapons come from the level data. A `sentry` has range 700, a sightline through portals, and a start wait before the first fire. Its weapon direction follows the target for the renderer.

### Invariants

- The two weapon types fire only at targets in a sightline. The `sentry` search is one engine call that walks the polygon graph out from the weapon. Thus its cost follows its neighborhood, not the world count.

- A `sentry` with its target gone starts the 10-tick start wait again.

- The two fire projectiles of type `turret`. `_contact` does not let that type damage the player.

### Verification

An enemy in 700 units and in a `sentry` sightline receives 14 damage from each projectile. After the 10-tick start wait, the `sentry` fires one projectile each 18 ticks. Its `face` value follows the target each tick. A `cloister` turret fires a 6-damage projectile each 16 ticks at enemies in its sightline through at most `VISION_HOPS`. The hop limit and view query set its only range limit.

### Implementation

For each turret with cooldown 0, `_turret_tick` selects the first enemy returned by `senses.find`. The results are in sequence by path distance. It sets cooldown to 16 and spawns a projectile with speed 1200 and a 40-tick life. A `soft` fire sound and a light effect occur with it.

`_sentry_tick` decreases the cooldown of each `sentry`. It calls `find_closest_faction_member_with_los` with the enemy group, `VISION_HOPS`, range 700, and the held target. The weapon keeps the target while the result stays applicable. With no result, it removes the target and sets `spin` to its initial value. With a result, it keeps the target and `face`, then decreases `spin`.

When the `sentry` can fire, it sets cooldown 18 and keeps `fire_tick`. It spawns a projectile with speed 1400, life 50 ticks, and damage 14. It plays `sentry_fire` at 0.4 and flashes the muzzle light.

### Caveats

`Sentry` weapons and `cloister` turrets use different paths as specified. Tests hold the `cloister` pair at 2 turrets, and its numbers are set for a small safe `sanctum`. Turret projectiles use the `turret` projectile type, thus the contact requirements that are in the code include them.

No body damages a `sentry` or a turret: they have no hp, and their group has no collision. The counter to them is enemy `dread` (see the enemy AI unit), not damage.

## Damage, death, and impulse — `_carry`, `_apply_impulse`, `_set_enemy_state`, `_damage_enemy`, `_kill_enemy`, `_damage_player`, `_player_death`, `_drop_corpse`, `_capture_burn`, `_describe_entity`

### Goal

Most damage flows through 2 functions: `_damage_enemy` and `_damage_player`. `_capture_burn` applies continuous player damage through a different path. All pushes flow through `_apply_impulse`. All enemy state changes flow through `_set_enemy_state`. Each standard damage call, push, and state change emits one trace event. Hold burn emits one `DamageApplied` record on each 5-tick beat for the damage of those 5 ticks.

### Invariants

- Knockback is an impulse through the engine (`dv = J / m`), and not a velocity write.

- The code moves a push or hit direction into the space of the hit body. When no route is there, the positive local horizontal direction supplies the push direction.

- `Organ` parts do not change state. `_set_enemy_state` returns for `core` types in its first line. Thus no caller can set a `Collar` to `hunt`.

- A death releases the holds of the body and its call `lease`. An Adversary death decreases the `census` with no return, and records the cause.

- The player has one death path: `_player_death`. Each path to 0 hp goes there.

- During `revival_grace` and the 30-tick damage gate, the player receives no damage. A hit closes an open `recall` channel.

### Verification

A `rail` hit through a doorway pushes the body along the ray in that body's coordinate frame. A killed `husk` emits the death sound and adds a `blood` circle with a `corpse` decal below it. It emits the `corpsefall` and `gib` effects. It freezes the simulation and shakes the view. It does one drop table `roll` and spawns a `components` pickup equal to its score.

A hit enemy moves into `hunt`. A killed Adversary increments `adversary_lost` and the correct cause in `adversary_killed_by`. A player death emits `PlayerDeath`, drops a `wreck` with the held goods, and stops that tick's `scans`.

### Implementation

`_carry(off, into)` returns the offset without change when the two values use the same coordinate space. Otherwise, it transforms the offset through the one world transform between the spaces. It returns `None` when no route is available. `_apply_impulse` transforms the impulse into the body's coordinate space, applies it, and emits `ImpulseApplied`. `_set_enemy_state` ignores `core` types and states that did not change. For other records, it writes the state and emits `AgentTransition` with the position.

`_damage_enemy(eid, dmg, ndir, knock, source, by)` first applies the player damage multiplier. Against a target that is not idle, the target-mark node adds a factor of 1.10. An accepted `crit` `roll` also applies the `crit` multiplier. The function decreases hp and writes `last_hit`, plus `scout_hit` for Adversary types. It sets state to `hunt`, counts the hit and damage in `metrics`, and emits `DamageApplied`. For a `core` part, it reports the damage to the `organ` and copies the hp into the part record.

It then emits 0.15 `DISTRESS` in the polygon and transforms `ndir` into the body's coordinate space. If no route is available, it uses the positive local horizontal direction. It applies an impulse only when the impulse value is above 0, thus damage can occur without a push. At the end, it plays `hit_flesh`, adds a `blood` decal, and emits `hitflash`.

At 0 hp, call `_kill_enemy`.

`_kill_enemy` emits `EnemyDeath` and releases the body's holds and call `lease`. For a `core` part, it reports the death to the `organ`. A `blackout` result sets the `marrow` `reserve` value to the `core` kill `debt` and emits that event. Each other result emits the part's `destroyed` event. The function removes the record. For an Adversary, it decreases the `census` and increments `adversary_lost` and `adversary_killed_by[by]`.

It then counts the kill and plays the death sound. It adds the `blood` circle before the `corpse` decal. The `blood` above the decal can remove the outline. It emits `corpsefall` and `gib`, then freezes the simulation for 4 ticks or 7 for large types. It shakes the view and removes the body.

The function `rolls` the drop table and spawns the first accepted pair, then stops that loop. It also spawns a `components` pickup equal to the score times the `salvage` multiplier and emits 0.40 `DANGER` and 0.25 `DISTRESS`.

`_damage_player(dmg, polygon, source)` returns during `grace`, during the damage gate, or after player death. Otherwise, it sets the damage gate to 30 and closes an open `recall` with the `RECALL SEVERED` prompt. It applies the difficulty multiplier, `armor` multiplier, and `player_resist`. Then it decreases hp, counts the damage, emits `DamageApplied`, and keeps the source. It plays the damage sound, shakes by `min(8, 2 + dmg/4)`, emits `playerhurt`, and adds a `blood` decal.

At 0 hp, `_player_death` sets `dead`, counts the death, and emits `PlayerDeath` with the source and `chassis` count. It plays the death sound, emits `playerdie`, adds the player's `corpse` decal, and drops the `wreck`.

`_drop_corpse`: without the `protected_revival` node, the `wreck` receives the components and kits not `planted`, and the two counts become 0. With the node, the seed bank holds the components, and the `wreck` receives only the kits. When the `wreck` holds an item, spawn a `corpse_frame` pickup with the contents and a random voice line number. Weapons and hole charges do not go with the `wreck`. The seed `reprints` them with the player.

`_capture_burn(captive, captor, dps)` applies only to the live player. Damage is `dps * DT` times the multipliers, with no damage gate because the hold applies continuous damage. The source is `engulfed`. Each tick adds a `playerhurt` effect for that tick's damage.

On each 5-tick beat, it also emits the damage sound and adds `attacker_mark`. It emits one `DamageApplied` event for 5 ticks of damage. At 0 hp, it releases the hold and then runs the player death path.

`_describe_entity(eid)` supplies identity data to the senses. The player record is `("player", "commando", "intruder", tags, group)`, with a `dead` tag when applicable. Adversary types show as Adversary units, `core` types as `organs`, and all other enemy types as `Testator` units. The function returns `None` for projectiles and pickups. The tuple does not contain hp or internal records.

### Caveats

Defect: `_damage_enemy` applies the player damage multipliers, the `crit` `roll`, and the `metrics` hit and damage counts to each source. That includes turret projectiles and Adversary `crossfire` (`by="crossfire"`). Thus the player `mind` `upgrades` increase `crossfire` damage, and the metrics count hits the player did not fire.

The 30-tick damage gate applies usually. The code comments state knockback, and not damage protection, as the counter to hit chains. The active 0.5-second gate prevents damage from each source other than a hold.

## `_enemy_ai` — the enemy think loop

### Goal

One loop controls each enemy each tick. It runs the cooldowns, the `warden` `sidestep`, and the `dread` of turrets. It sends to the special systems (`shrieker`, `flicker`, Adversary units, `ascent`).

It runs the state system (`idle`, `waking`, `hunt`), the `wake` decision from the fraction of active peers, and the garrison `rest`. It also runs door holds, the chase, the ranged bands, and the field `hunts`. Enemies see through view records and fields only. This loop does not read the raw player position.

### Invariants

- The loop runs only for enemies in the engine's active set, as calculated previous in this tick.

- The AI receives the player only as a view record transformed into the enemy's space.

- The `notice` requirement finishes in one beat. A view record `wakes` the body for each condition of portal depth or distance. Because of the `wake` wait, the player always moves first.

- `DISTRESS` or `NOISE` above its threshold makes a body active immediately. The fraction of active peers limits only the path through peers.

- A `posted` hub unit (`tether`) stays at its `post`: it does combat through the door but does not chase.

- Active active enemies with no signal `prowl`. They do not stay frozen, and the `quiet` requirement returns them to `idle` after approximately 5 seconds.

### Verification

A `shot` at portal depth 2 raises `NOISE`, and idle enemies at a short distance `wake` without a view record. An enemy that sees the player through a doorway `wakes` the same as one in the same polygon. During ranged fire, a `warden` `sidesteps` across the lane each 30 ticks. Enemies that see a turret mark its ground with `DANGER`.

A small group increases its distance, while a large group pushes through. An enemy in `hunt` that does not close distance for 8 seconds discards its view record for 5 seconds. The field system then controls the chase.

### Implementation

For each active enemy, the loop:

- Writes the polygon change into `_came_from` and `_came_from_t`. Decreases the 7 cooldown fields and the `buff` timer.

- `warden` `sidestep`: hit in the last 60 ticks, no `engulf`, off cooldown. Apply an impulse of mass times 210, at 45 degrees across its movement axis, with the side in turn, cooldown 30.

- Closes hold and `prowl` periods on the first tick after they end. It emits `hold_end` and `prowl_end` with the correct times.

- Test `dread` on the body's 10-tick beat when turrets are in the world. This path does not apply to an Adversary, `core`, `dormant`, or `dispatched` unit. Find a weapon in a sightline at a distance of 700 units or less. Raise `DANGER` at the weapon polygon to a minimum of the `dread` level. This operation sets a floor and does not add a value. Count the peers that are not idle.

The `dread` requirement selects `flee` or hold ground. `flee` keeps a direction in this polygon's frame, `dread` ticks, and a cooldown.

- A body in `dread` moves along its kept direction at full acceleration and does not run the remaining AI steps. A door crossing `consumes` the `dread`. The cooldown lets only one `flee` during each continuous period in which the weapon stays in view.

- A `shrieker` that is not `tethered`, `dormant`, or marked `dispatched` runs its special system and no remaining AI steps. A `flicker` does the same unless marked `dispatched`. Thus a body marked `dispatched` `marches` and removes the `dispatched` field. Its breach can then seal.

- For each type other than `mite` and `shrieker`, collect each tick's travel distance in one coordinate space. Play a heavy step each 44 units for a `brute` or `warden`, or a `soft` step each 30 units for other types. A portal crossing sets the interval to 0.

- `Core` types stop here: `organs` are bodies, and the `organ` thinks.

- A `dormant` Adversary stays `dormant` until `NOISE` or `DISTRESS` is at its threshold, or until a hit `wakes` it. If a hit `wakes` a `dormant` Adversary that has no task, it `flees` in that tick. A returned Adversary in the world becomes `stranded` after it stays at a distance of 4 units or less for 420 ticks. Emit `return_stranded` and `withdraw` it.

- A body with `ascending` does its `ascent` step and no remaining AI steps. An Adversary with a `scout` task runs `_scout_ai` and also runs no remaining steps. This includes a task selected in this tick.

- For an `idle` body, test the garrison `rest` on each 15-tick beat. The polygon must contain a `warden`, and the player must not be in a sightline. `NOISE` and `DANGER` must be low, and the hold time must be sufficient. A body with these conditions moves into `settled` and emits that transition. On each subsequent 15-tick beat, it emits a small garrison field. It emits `GARRISON_INTERIOR` with a peer, or `GARRISON_REACH` if not.

- For an `idle` body, test `notice` each 10 ticks. A view record calls `_notice`. Without one, compare `DISTRESS` and `NOISE` with the body's signal threshold. A value at or above that threshold immediately sets `waking` with the type's `wake` duration. Otherwise, compare the body's threshold with the fraction of `visible` peers that are active plus the field component. A result above the threshold also sets `waking`.

- During the remaining `idle` path, `tethered`, `settled`, and held bodies stay in position. Each other idle body emits a small `PATROL` mark and moves at 0.35 acceleration. It selects a random direction each 45 to 150 ticks.

- A body in `waking` decreases `wake` and moves into `hunt` when the value becomes 0.

- A body in `hunt` emits a low sound at a random interval of 140 to 260 ticks. The `shrieker` is not included because its warning is its voice. A body marked `dispatched` that is not in the hub removes the `dispatched` field. Without a view record, it returns to its `rest` state.

- A body marked `dispatched` in the hub `marches` to the world `mouth` of its breach. During a `stall`, it `sidesteps` after each 300 ticks without movement. After 900 ticks, it removes the `dispatched` field and emits `march_stall_shed`. If its initial breach sealed, it changes to a live breach. It routes through `next_edge` and blocks the door behind it when a different door is available. It uses terrain steering, the turn limit, and budgeted movement.

- An `engulf` in progress runs `_warden_engulf_step` and does not run the `rest`.

- Read the view record through `sight_of(eid, player)`. With a view record, set `quiet` to 0 and emit `MUSTER` and `DISTRESS` on each 5-tick beat to draw more contact. Without a view record, count `quiet` ticks while `max(NOISE, TRAIL, DISTRESS)` stays below the `quiet` floor. Return the body to `idle` when the `quiet` requirement is complete. This calculation does not include `MUSTER`. `MUSTER` emissions cannot keep bodies at a door `awake`.

- The chase `watchdog` monitors progress across 480 ticks. A chase with a view record that increases less than 24 units drops the view record for 300 ticks and emits `pursuit_stuck`.

- A `warden` with a view record at depth 0, in 120 units, off cooldown, starts the `engulf` charge.

- A view record at depth 1 or more can hold at the doorway. The conditions: no hit for 120 ticks, hold not ended, and the `danger` hold requirement. That requirement reads the `DANGER` of the next polygon, the active peers, and the local `MUSTER`. The held body emits `MUSTER` on each 5-tick beat and runs `_hold_at_door`.

- Movement with a view record: turn to the target, steer around terrain, apply the turn limit. `husk` and `brute` lunge in 95 units on their cooldown (120 and 150). The velocity burst is 300 or 240 to the lead position of the target. The lead uses the view record velocity in the space of this body. Ranged types keep their band (`keep_min` to `keep_max`) and `spit` on cooldown, and the `warden` also closes. Bodies without `tether` chase with budget movement.

- Movement with no view record: `_hunt_edge` selects the maximum doorway. No doorway calls: `prowl` (the idle move at 0.4 acceleration) with `prowl_start` on the trace. A door below the `danger` hold requirement: hold there. When not: walk to the door center with the terrain steer, the turn limit, and budget movement.

`_notice` sets `waking` with the type's `wake` duration. It plays the warning sound at 0.9, emits the `alerted` effect, and turns the body in the direction of the player. It also emits the view record's `DISTRESS` value in the body's polygon. Because a view record is the strongest signal, this path tells the `swarm` where the player is.

### Caveats

The `wake` beat and the calculation of the fraction of active peers run on offset ticks for each entity (`(tick + eid) % n`). The `dread` `scan` and the garrison tests also use offset ticks. Thus the costs spread. Each test can wait a maximum of its applicable period: 10 ticks for `wake`, the fraction of active peers, and `dread`, and 15 ticks for garrison.

`WAKE_TICKS` has no entry for `flicker` or the `core` types. This causes no error because a `flicker` does not have state `idle`. The `core` types return from the loop before this step. A new type that moves into `idle` without a `WAKE_TICKS` entry raises `KeyError` at its first `wake`.

## Locomotion machinery — `_peer_bodies`, `_budget_move`, `_steer_heading`, `_steer_to_edge`, `_hunt_edge`, `_hold_expired`, `_hold_at_door`

### Goal

All enemy movement flows through an acceleration budget with a set sequence. Separation uses the first part, and only the remaining budget chases. Thus opposite requests do not average into a door frame. The direction turns at the turn rate of the type. Thus heavy types cross the target and arc. The field `hunt` selects the maximum doorway, with requirements for return block, `flank`, and stop.

Door holds collect at the side of the frame, out of the fire cone.

### Invariants

- Separation `claims` at most 0.7 of the budget. A request that closes no clearance for 2 seconds gives up its `claim`. The `claim` stays off until the body is 2 radius units clear of its `stall` position.

- The movement direction is its kept `Offset`, not the face direction. A held body faces the door and moves to the side. A kept direction from a different space changes to the face direction that the engine moved.

- The `hunt` does not select the door behind it when a different door is there. It blocks that door for 60 ticks, then gives it weight 0.25.

- A hold continues for at most 15 seconds, then stops for 10 seconds. A hit lifts a hold (the callers test `last_hit`).

### Verification

A full muster group spreads through its door and does not stop at the frame. A `brute` at full speed can cross a player who turns in its arc. An enemy in `hunt` at a 2-door `choke` changes doors after 10 seconds without a crossing and emits `flank_switch`. An enemy in `hunt` in a 1-door polygon with no view record stops after 15 seconds and emits `hunt_stall_stand_down`. Held bodies collect along the wall at the side of the frame. Their sides and depths change in turn, and they do not stay in the center of the doorway.

### Implementation

`_peer_bodies` returns peer (`x`, `y`, radius) tuples in the space of this polygon. All peers are in the same polygon, thus the raw tuples use one coordinate space. The separation calculation `consumes` them in that loop. `_budget_move` receives the separation request, limits it to 0.7, and runs the progress latch. A clearance increase below 0.5 units for 120 ticks keeps the `claim` at that position. Travel of 2 radius units releases it.

The function then applies acceleration first to separation and then to the objective. It adds the result times `DT` to velocity.

`_steer_heading` keeps `hdg` on the record. When its coordinate space is different, the function starts it from the body's direction. It turns `hdg` in the target direction by at most `turn * DT`. Then it writes the body direction and returns the movement direction. `_steer_to_edge` moves a body in the direction of a portal-edge center through terrain steering and the turn limit.

`_hunt_edge` caches its route for 45 ticks unless that route points back to the polygon left in the last 60 ticks. It reads the `TRAIL` value of each adjacent polygon. A new trail locks the body to that trail and sets `_tracking` for the renderer. For each open door, it calculates the pull from `TRAIL`, `NOISE`, `DISTRESS`, `MUSTER`, and the doorway trail. The door behind the body has weight 0 for the first 60 ticks and 0.25 then.

The remaining `_hunt_edge` requirements apply when the total signal pull is below 0.02. A body marked `dispatched` with a known target routes through `next_edge` to its `dispatch_target`. All other bodies return -1 in this condition. A body with the `raid` flag selects the second door when one is available.

The `stall` requirements follow. In a 1-door polygon, 15 seconds at the door with no view record stops the `hunt`. At one door with a second alternative, 10 seconds `flanks`. Each selection adds 0.5 doorway trail.

`_hold_expired` starts the hold clock and lets the hold through tick 900. It then blocks the hold until tick 1500 and removes the clock. A new hold can then start.

`_hold_at_door` records the period and emits `hold_engage` on the second tick in sequence. The wait position starts at the door center. It moves along the wall by 70 plus 26 times the entity's sequence step. It changes sides in turn and moves 40 units into the polygon. The body faces the door and walks to that position while its distance is more than 26 units. At the position, it moves randomly with 0.18 acceleration.

### Caveats

The internal offset is necessary. Flush against an open portal edge, the wall push from the physics can move the wait body through the doorway. That is the doorway it does not want to cross.

The trail add on each route selection is the cause of the return block. After one crossing, the same door is the maximum edge from the other side.

## `_warden_engulf_step` — the warden `engulf`

### Goal

The `engulf` is the kill move of the `warden`. The charge lasts 12 ticks with the body rooted and two flashes. The lunge uses 2.5 times `cruise`. A catch from the front holds the player, pulls it into the `core`, and burns 75 damage each second. The active hold can end after a `warden` death or player death. A different hold system operation can also release a body.

### Invariants

- The charge roots the body. The tell runs through `trace_intensity`, which is the state channel of the renderer and not a free timer.

- The lunge catches only from the front: contact in the two radius values plus 8, with the velocity `dot` 0.5 or more. A side touch does not catch.

- The lunge ends when friction drops the speed below `cruise`. Catch or not, the cooldown is 300 ticks.

- The start in the AI loop has an additional condition: a view record at depth 0 within 120 units, the physical range of the lunge.

### Verification

A `warden` that sees the player within 120 units stops, flashes twice across 12 ticks, and lunges with the `warden_engulf` sound. On each lunge tick, the code tests speed first. A speed below `cruise` ends the lunge before the catch test. At or above `cruise`, it reads a new view record in the active polygon and tests for a catch.

A `sidestep` during the lunge lets the `warden` cross the player. A catch from the front holds the player, pulls with value 260, and burns for 75 damage each second. Only `warden` death ends this catch.

### Implementation

In state `charge`, set velocity to 0 and decrease `engulf_t` from 12. Set `trace_intensity` to 2.0 and 1.0 in turn each 3 ticks. At count 0, cancel and set the cooldown if there is no view record. Also cancel if the view record crosses a door. Otherwise, set the lunge direction and speed to 2.5 times `cruise`. Play the sound and move into `lunge`.

In state `lunge`, a speed below `cruise` ends the lunge and sets the cooldown. Otherwise, a catch requires a depth 0 view record within contact range. Direction alignment must be at least 0.5, and the live player must not be held. A catch moves into `hold` and starts hold with pull 260 and 75 damage each second. The damage sound and `engulfed` effect occur with it. In state `hold`, hold end or player death removes the state, sets the cooldown, and sets intensity to 1.0.

### Caveats

The hold system contains the active hold. The pull, the burn through `_capture_burn`, and the selected weapon target all live there. While the player is held, all other bites do 0.5 touch damage.

Decision open (see `spec/open-questions.md`, item `SIM-WARDEN-HOLD`): the first Goal states that only the death of the `warden` ends the hold. The implementation also ends it after player death or when the hold system releases a body. This text records the active operation. It does not select the necessary exit requirement.

## Adversary Adversary units and the call — `_maybe_task_scout`, `_scout_move_to`, `_scout_ai`, `_adversary_arsenal`, `_adversary_round`, `_spit`

### Goal

The Adversary faction has a finite number of units. In each polygon, the weakest class receives the call task. The tasked body moves to the edge of the hot `zone` and holds position. It receives the world's one call `lease`, and then transmits. It stays rooted and open to damage during the `transmission`.

After `transmission`, the tasked body puts the `imprint` and waits for 3 seconds. It then changes between the two `expansion` legs. Damage stops the full sequence. Thus the tasked body is its weak point. The tools fire only during `flee`: the `lob` adds distance, while the snare `buys` time.

### Invariants

- At most one body in a polygon holds a call task. The weakest class there receives it. In equal classes, the lowest id receives it.

- The `transmission` has a root and flashes on each 60-tick beat through the standard audio path. A hit releases the `lease` and sets `flee`.

- The `lob` and snare bands do not cross: the `lob` in `lob_range`, the snare from there to `snare_range`. The two fire from `flee` only.

- The snare leads the target. The `lob` does not: a heavy object that it raises at a chaser who comes straight in.

- A projectile does not damage the body that fired it.

### Verification

When a `lacuna` and a `vagrant` are in one polygon, the `lacuna` receives the task. The selected Adversary stays without movement while it transmits. It flashes its sensor trace each second and plays the `terminal_type` sound again. A hit stops `transmission`. The selected Adversary then `flees` and fires the `lob` or snare in the applicable range band. A completed call adds an `imprint` that the `marrow` can `consume`.

### Implementation

`_maybe_task_scout` runs on the body's 30-tick beat. It sets a task only when no other body in the polygon has one. This body must be in the weakest Adversary class in the polygon. It must also have the lowest id in that class. The task sets `scout="seek"` with mode `contact`.

In `_scout_ai`, an Adversary in a hub polygon starts `ascent` after its `arrival` `grace`. A hit releases the `lease` and sets `flee` for 300 ticks. During `flee` and for 120 ticks after a hit, the outer state is `hunt`. Standard work on a `scout` task uses `idle`. The phases follow.

- `flee`: decrease the timer, then back to `seek`. The body fires the tools while it runs, and moves to the `quiet` next polygon from the field neighborhood.

- `brace`: do not move for 120 ticks, then move into `transmit`. A `vagrant` transmits for 360 ticks and a `lacuna` for 480. The renderer reads the remaining `transmission` time from `call_t`.

- `transmit`: stay without movement and decrease the timer. On each 60-tick beat, set `trace_intensity` to 2.0 for 6 ticks and play the sound. At 0, complete the call on the call `medium` as an `imprint` with polygon, position, tick, and type. Change mode from `contact` to `safe`, from `safe` to `peak`, or from `peak` to `safe`, then move into `observe`.

- `observe`: decrease the timer for 3 seconds, then `seek`.

- `seek`, in `contact` mode: calculate `NOISE + TRAIL + 0.6 * DISTRESS`. The body can move only to the first adjacent polygon with a higher value below 0.45. It `plants` when `0.06 <= local value < 0.45`. It also `plants` when an adjacent value is at least 0.45.

- `seek`, in `safe` mode: calculate `KIN + 0.5 * PATROL + TRAIL + NOISE`. Select the first adjacent polygon with the minimum value below the local value. Its `DANGER` must be no more than 0.35. `Plant` when there is no such polygon.

- `seek`, in `peak` mode: select the first adjacent polygon with maximum `DANGER` above the local value. The value must be no more than 0.35. `Plant` when no such polygon is available. A `plant` must receive the `lease` first. Without it, the body stays in this state.

`_scout_move_to` steps to the door of the adjacent target polygon, with the terrain steer, the turn limit, and budget movement. It removes the target when the target is not adjacent.

`_adversary_arsenal` reads the view record and selects the band. `_adversary_round` spawns the projectile. The `lob` is heavy and slow: the radius of its class, its mass, wall `rebound` 0.55, 300 ticks.

The snare is small and leads the target. It has radius 4, mass 0.01, life 180 ticks, and the class hold and slow multipliers. The `lob` has no impulse number: its velocity is the push, and the physics applies it on contact. Each fire emits a trace event with range and depth.

`_spit` applies to the `spitter` and the `warden`. It spawns a projectile of radius 2.5 at the type's `spit` speed. The projectile has a small random turn, life 180 ticks, and the `spitter_shoot` sound.

### Caveats

The task requirement applies independently to each polygon, thus two Adversary bodies in different polygons can hold two tasks. The call `medium` continues to let only one body hold its `lease`.

An Adversary from the level starts `ascent` when it walks into a hub polygon. A body can start `ascent` without a previous `withdrawn` state. A body with no `arrived` mark obeys the `grace` test.

## Adversary `departure` and return — `_otherworld_chambers`, `_is_otherworld`, `_begin_ascent`, `_ascend_step`, `_withdraw_adversary`, and the return in `_marrow_tick`

### Goal

`Withdrawal` is the standard Adversary result, and only a kill is permanent. A completed body walks to a `withdrawal` polygon. This is an `otherworld` hub polygon or a `soft` polygon. It stops and plays its `visible` crossing effect.

A `withdrawn` body subsequently returns through a live breach. A body stays in the world while the player can see it. The only exception is a body with a broken door.

### Invariants

- A body in `ascent` can receive damage, emits sound, and stays `visible` along the full path.

- View of the player, or a hit in the last 120 ticks, cancels the root and a started crossing.

- The crossing starts only after 300 ticks out of the player's view, then 150 root ticks, and lasts 48 ticks. The crossing is the one `visible` `departure`.

- A `withdrawal` writes an entry in the `recovery` queue, with a return tick plus `jitter` (3600 plus 0 to 1800). A return must have a live breach: seal them all and no body returns.

- A `withdrawal` `visible` to the player waits. Two causes do not wait: `no_door` (the seam had a death below the body) and `otherworld` (the played crossing).

### Verification

An Adversary with a completed task walks through the hub to a `withdrawal` polygon and stops there. It plays `adversary_cross` with the `crossing` effect. The function removes it after 48 ticks. A hit during the root stops it.

A sealed breach `withdraws` each body that crossed it, in that tick, with cause `no_door`. A returned body flashes with the `arrived` effect and plays `adversary_return`. It cannot cross its `arrival` seam again during its `grace` period.

### Implementation

On its first call, `_otherworld_chambers` calculates and caches the hub polygons with type `otherworld` and the session's `soft` polygons. `_begin_ascent` selects the nearest `withdrawal` polygon by hops, or `withdraws` as `stranded` when no route is there. It emits the transition with the source polygon and the target.

`_ascend_step`: view or a new hit writes `_last_saw`, cancels a started crossing (with an `interrupted` transition), and sets the root count to 0. A started crossing completes after 48 ticks into `_withdraw_adversary("otherworld")`. In a `withdrawal` polygon, it waits while seen in the last 300 ticks. It then stays at velocity 0 for 150 ticks and starts the crossing with its sound and effects. On the path, a `stall` requirement `strands` it after 420 ticks without movement. It uses `next_edge` to the target and the same door block as the `march`.

For a cause other than `no_door` or `otherworld`, `_withdraw_adversary(eid, e, why)` keeps the body while the player can see it. The function changes state to `leaving`, emits that transition once, and returns. The body continues its AI until the player cannot see it. The function then removes it. This wait has no limit.

Removal while `visible` can break visual continuity. This requirement adds a small simulation cost.

For all other conditions, the function releases holds and the caller `lease`. It decreases the `census` and increases `withdrawn`. It adds `(type, return tick)` to `adversary_out`, emits the `reabsorbed` transition with the cause, and removes the body.

The return (in `_marrow_tick`) occurs with a live breach and an entry at its return tick. Spawn the type at the breach `mouth` with a 40-unit `jitter`. Count `returned`. Write `arrived`, `arrived_via` (the breach id), and `_came_from` (the hub polygon, thus movement does not walk it back through the seam). Write a `grace` with `jitter` (600 plus 0 to 600). Emit the `arrived` effect (a color on the body, not a light), the sound, and the transition.

### Caveats

The `leaving` transition records position (0, 0). The `reabsorbed` transition after it records the correct position.

The cause `home` from the source text does not occur in this code: a hub `arrival` moves into `ascent`. The used causes are `otherworld`, `no_door`, and `stranded`.

## The `marrow`, breaches, and dispatch — `_marrow_tick`, `_open_breach`, `_dispatch_unit`, `_replace_shelf_unit`, `_seal_breach`, `_sample_telemetry`

### Goal

The `marrow` has no world data and is closed. It `consumes` at most one `imprint` each tick, runs its economy, and sends commands. The world-direction code cuts the selected wall and connects it to a free hub seam at scale 1. It sends live bodies through it and seals `quiet` breaches. The controller receives no player, combat, or geometry data.

### Invariants

- A breach opens at scale 1 or not at all. `connect_equal` does not accept a different scale. If the connection does not complete, the breach try stops.

- A breach try `consumes` the `imprint` when it does not complete. It stops when no wall fits, no free seam is available, or the call comes from the hub.

- A `dispatch` command uses the `shelf` first — `posted` hub units go out of their hub areas — and then production spawns in the hub. No body spawns world-side: bodies walk out through the breach.

- Only the first of each 10 bodies marked `dispatched` knows the transmitted position. The other bodies run on fields, view records, and trails.

- A seal returns the seam to the free pool. It decreases the breach light to 0 across 90 ticks, with a pool that contracts. It also `withdraws` each body that crossed that breach.

### Verification

A completed Adversary call cuts a wall. It emits `stinger_wrongness`, shake 7, and an RGB (190, 80, 235) light at the `mouth`. It also sets `NOISE = max(NOISE, 0.9)` and emits an `opened` trace event.

A call transmitted from a hub polygon is dry, with `dry_no_site`. The `shelf` units marked `dispatched` move out of their hub areas. Dispatch leaves vacancies in the guardian shelf until `replace` commands spawn new posted bodies. A `quiet` breach seals with the `sour` sound, one last `flare`, and a `sealed` event. Its light fades to 0 across 1.5 seconds.

### Implementation

On each tick, `_marrow_tick` performs these operations:

- It consumes at most one `imprint` from the call `medium`. It notes `interest` for each breach that has a live body marked `dispatched`.

- Decay the seal lights across 90 ticks with `k_ = 1 - age / 90`. Intensity is `0.85 * k_`, and radius is `max(12, r0 * k_)`. Then remove the light from the lighting list.

- It updates the light of each live breach. For 140 ticks after the open, a `flare` decreases from 3.25 to 0.85 while its radius decreases from 450 to 300. The light then remains at intensity 0.85 and radius 300.

- It processes returns as specified in the `departure` unit. The breach used is at index `tick % len(breaches)`.

- It prunes the `shelf` list to live bodies. Then it runs `marrow.step` with the `imprint`, live breaches, and the `shelf` `census`. It also supplies the `dispatch` multiplier and capacity of the `core`, then runs the `open`, `dispatch`, `replace`, and `seal` commands that the step returns.

`_open_breach` first sets the breach number. A call from a hub polygon stops the try. No free seam also stops the try.

The function then cuts a 96-unit door in the named polygon near the transmitted position. When all walls there are `consumed`, it cuts the first adjacent polygon that fits and records that polygon. The try stops when no door fits.

The function uses the first free seam and calls `connect_equal` with the cut door. On `TopologyError`, it returns the seam and records a dry call with the error text. Otherwise, it adds and keeps the `Breach` record and its `mouth` light. The light has RGB (190, 80, 235), intensity 0.85, and radius 190.

The function then emits the `presentation` effects. It puts 4 units of doorway trail on the edge from the hub area to the apse. It puts 4 more units on the edge from the apse to the primary hub polygon. This trail lets bodies marked `dispatched` without a world view record find the route out. It plays the primary sound at level 1.6 and the unlock sound. It shakes by 7, flashes a radius-340 light, raises `NOISE` to a minimum of 0.9, and emits `opened`.

`_dispatch_unit` first finds the breach. It searches the hub `shelf` for the requested enemy type. This `shelf` is the group of live `defenders` in the hub areas.

When it finds one, that selected `defender` exits its `post` and becomes the body marked `dispatched`. When it finds none, the function spawns a new body of the requested type. It selects a random position in the hub area behind the breach's apse. It sets the body's `dispatched` field to the breach id.

When `sent % 10 == 0`, the function sets the `imprint` polygon to the body's `dispatch_target`. The adjacent `carve` can put the `mouth` in different polygon. It then removes `tether`, sets `hunt`, and emits `DispatchDecision`.

`_replace_shelf_unit` spawns the requested type in the hub area that holds the smallest count of `shelf` bodies. It tethers the body and adds it to the `shelf`, with a `ShelfReplaced` event.

`_seal_breach` disconnects the connection through the `TopologyManager`, returns the seam to the pool, and moves the light to the decay list.

It then removes the breach and withdraws each body with `arrived_via` equal to this breach. It tells the `marrow`, plays the seal sounds at most once in each tick (`reveal_sour` 1.2, `door_unlock` 0.8, shake 4), flashes 260, and emits `sealed`.

`_sample_telemetry` (each 60-tick beat, above the returns at the top): emit `EnemyPositions` for each live enemy, and a `ReserveSample` with the `reserve` value, the live breach count, and `_pending_kind`.

### Caveats

Defect: `_open_breach` and `_seal_breach` do not call `lighting.on_topology_changed`. The `TopologyManager` change hook tells only the signals. Thus the static light cache of the lighting system is incorrect across a breach open and seal. A static light near the seam does not go through the new portal.

A sealed portal can keep its light. A subsequent topology change clears the cache. Each other topology path (doors, holes, `cloister`, stream connects without a transform) calls the two `notices`.

The telemetry sample reads `self.marrow._pending_kind`: an internal field read across the module limit.

## The `core` `organ` bodies — `_embody_core`, `_core_tick`

### Goal

The parts of the `core` `organ` are bodies in the hub that can receive damage. They are at the positions in the approved `plan`. They have no AI. Damage flows through the one damage function and reports to the `organ`.

A `core_caretaker` repairs each part that it touches. Damage starts a standard `MUSTER`. The smallest `organ` returns after its `blackout` `debt` returns to 0.

### Invariants

- Part hp is one of the weapon numbers: 42, 84, 126, or 168.

- A `core_caretaker` repairs only parts in its polygon, in 46 units.

- `Organ` parts do not go into a state system, do not `wake`, and do not count in the fraction of active peers.

### Verification

The `organ` spawns 3 `core_source`, 2 `core_collar`, 4 `core_anchor`, 1 `core_scriptorium`, 4 `core_caretaker`, and 12 `core_bud` bodies at their polygons. A `core_caretaker` repairs a damaged part near it on the interval of the `organ`. The `organ` can call a part kill a `blackout`. That result sets the `marrow` `reserve` value to the `core` kill `debt` and emits the `blackout` event.

### Implementation

`_embody_core` adds the position list and spawns each part with `core.add_part`. It puts `core_source` at (0, 0) in `S1`, `S2`, and `S3`, and `core_collar` at (0, -20) in `C1` and `C2`. In the two `AN1` and `AN2`, it puts `core_anchor` bodies at (-25, 20) and (25, 20).

It puts `core_scriptorium` at (0, 0) in `SC`, and `core_caretaker` at (18, -18) in `R`, `N2`, `V`, and `L`. Each of `N1` through `N4` has 2 `core_bud` bodies at (-30, -25) and (30, 25). `V` has 4 more bodies at x coordinates -120, -40, 40, and 120, all at y = -40.

`_core_tick` runs on each 15-tick beat. It collects the `core_caretaker` contacts (same polygon, in 46 units). It applies `core.step_heal` and copies the repaired hp into the enemy records. It emits 0.4 `MUSTER` and 0.2 `DISTRESS` for each polygon with a muster. On `reform_due` (which reads the `marrow` `reserve` value), it spawns the counts at their set polygons and emits `reformed`.

### Caveats

The parts are in `ENEMIES` with acceleration 0, large mass, and touch damage 0. Thus the physics moves them almost not at all, and touch does no damage.

## The shrieker system — `_shrieker_ai`, `_shrieker_patrol`, `_shrieker_phase`, `_fire_marker_at`, `_shrieker_rouse`

### Goal

The `shrieker` runs its `hunt`. `sentinel` `patrols` the polygons. `warning` `screams` and runs `home` to lift the group. `approach` follows the same `hunt` fields.

`marking` runs at 3 times `cruise` off the fire line. It locks approximately 300 ms and fires a marker that leads the target. `rally` spreads the warning, and the system returns to `sentinel`.

The mark is the payload: the marker applies the mark to the player.

### Invariants

- The state structure always shows the warning first. Only a view record or hit moves into `warning`. A caller in `approach` can have no `cried` value. A view record returns that caller to `warning` before it can mark.

- The path through active peers becomes active without a `scream` and reads weapon `NOISE` only. It does not read `DISTRESS`, which is the channel of its group, or a body count without a signal.

- The marker has its sound and its trace events. Each phase change goes on the record.

- The lock fires at the kept position. It holds through a broken sightline. The kept position moves across a doorway through start, and the projectile can cross the target position.

- The `scream` sets `hunt` and a 300-tick `buff` on each enemy in 2 hops. It does not touch a `shrieker`, a `core` part, or a body in an `engulf`.

### Verification

A `shrieker` that sees the player `screams`, runs `home` while it emits `DISTRESS`, then follows the fields to the combat. In `marking` it runs at 3 times `cruise` for the ground 95 units behind the player. It locks 18 ticks in range 210 at depth 1 or less, and fires the marker with `marker_launch`. The marker hit applies the mark to the player. Then it spreads the warning for 720 ticks and returns to `sentinel`. An `approach` that does not see the player for 2700 ticks stops with `shrieker_stand_down`.

### Implementation

The system keeps `home` — the polygon of its first run — at entry. The phases:

- `sentinel`: a view record or a hit in the last 30 ticks moves into `warning` and state `hunt`. On the 10-tick beat, test the fraction of active peers only when local `NOISE` is at or above the `quiet` floor. Count active peers other than `core` parts. Calculate their fraction with a field component from `NOISE` only. A result above the threshold moves into `approach` without a `scream`. Otherwise, `patrol` in the direction of a random open door at acceleration 0.4 and select that door each 150 to 360 ticks.

- `warning`: emit 0.25 `DISTRESS` on the body's 15-tick slot. When the `scream` cooldown ends, `scream` with sound 1.0, emit the effect, `wake` the group, and set `cried`. A caller without `cried` continues in the direction of `home` until it can `scream`. A caller with `cried` moves into `approach`. It writes the search clock when it is at `home` or has no route there.

- `approach`: a view record turns a caller without `cried` to `warning`, and a caller with `cried` to `marking`. The `mark_lock` and `mark_lost` counts return to 0. `_hunt_edge` routes it. No edge, or 2700 ticks with no result: emit `shrieker_stand_down`, back to `sentinel` and `idle`, and remove `cried`.

- `marking`: a view record at depth 1 or less keeps `mark_at`. The code moves a kept position from a different space into this one, and a route that is not available removes the lock. With the lock on and a position kept: face it, cut the velocity to 0.25, and count the lock. After 18 ticks, fire the marker at the kept position (the lead from the last view record velocity, or zero) and go to `rally`.

- `marking`, with no view record: chase through `_hunt_edge` at 3 times speed with no world data. After 120 ticks with no world data, fall back to `approach`. A view record at depth more than 1, or at range more than 210, starts a run at 3 times `cruise`. The goal point is 95 units behind the target, along the face direction from the view record. In range and depth: set the lock to 1.

- `rally`: decrease the timer from 720, `scream` on cooldown (0.9), `patrol` at 0.6 acceleration, then return to `sentinel` and `idle`.

`_fire_marker_at` leads the target by the travel time at speed 620 and spawns the marker (radius 2, 150 ticks, damage 0, the source id). It emits `marker_fire`, plays `marker_launch`, and emits the effect with the direction. `_shrieker_rouse` sets `hunt` and the `buff` as the invariant tells. `_shrieker_phase` is the one phase writer and emits each change.

### Caveats

The `shrieker` has touch damage 0: its full threat is the mark and the group it lifts.

The mark effects on the player live in 3 parts of the code. The `NOISE` increase is in `tick`. The doorway trail on each crossing is in `_consume_events`, and the call to `renew` on marker contact is in `_contact`.

## The flicker system — `_flicker_ai`, `_polygon_light_map`, `_flicker_dormant_trace`, `LURK_MAX_LIGHT`

### Goal

The `flicker` is the ambush type of the Adversary lane. It stays in low light and shows as a dim, intermittent sensor return. A view record at a short distance starts a fast burst, after which it does combat as a standard chaser. It returns to low light when combat stays `dark` and far. It uses the same light map as the renderer, thus terrain shadows change its decisions.

### Invariants

- The `rest` state is `lurk`, not `idle`. It holds ground as an active state and does not use the `wake` system.

- The `dormant` sensor trace changes between 0.34 and 0.12 on a random interval of 6 to 22 ticks. The sim random stream supplies the interval. It is at no time fully out of view.

- The burst fires on a view record in 70 units at each portal depth. It has a 560 burst, full sensor trace, and the warning sound.

- A position change occurs only while the position reads brighter than 0.12. The wait between tests is 12 to 24 ticks, not a bare timer.

- The light map is calculated at most once each tick, and only when a `flicker` is in the world.

### Verification

A `flicker` in a `dark` corner shows a dim return that flashes. A player who moves to a distance of 70 units or less starts the burst and then a standard chase. A chase that stays `dark` (level below 0.15) and far (more than 220) for 90 ticks ends with the body back in `lurk`. A lit body in `lurk` walks to the `darkest` of 16 sampled positions (8 angles at 44 and 110 units, with a random start angle).

### Implementation

`_polygon_light_map` caches `lighting.frame_lookup` for the tick. `_flicker_dormant_trace` changes `flicker_on` at its set interval and returns 0.34 or 0.12.

`_flicker_ai` reads the view record and the local light level. State `lurk`: the `dormant` sensor trace, then the burst test (state `ambush`, 18 burst ticks, the burst velocity, the sound and effect, sensor trace 1.0). For the position change, wait until the level is above 0.12 and the wait ends. Then sample 8 angles from a random start at steps 44 and 110. Keep the `darkest` as `lurk_target`, and walk to it at speed 95 with the terrain steer, or slow near it.

State `ambush`: full sensor trace, decrease the timer, move at the view record with full acceleration, then state `hunt`. State `hunt`: full sensor trace. With a view record, chase with the terrain steer. Count the `dark` beat when `dark` and far, and return to `lurk` after 90. With no view record: walk to the player polygon door by door through `next_edge`.

### Caveats

Defect: the `hunt` path with no view record routes with `next_edge` to the active player polygon. Other code paths replaced that chase type with field `hunts`. A `flicker` with the view record gone continues to know the player polygon.

The position change code processes equal values carefully. At positions not in a light, all 16 samples read 0.0. The previous version searched without limit for the first sample. The random start angle and the light test correct this defect.

## Engine events and contacts — `_consume_events`, `_door_bump`, `_contact`

### Goal

The engine reports transfers, wall hits, and body contacts after each step. This unit turns them into simulation effects. These are crossing records, camera change, `soft` wall pushes, and doors that open to fire. It also holds projectile results against walls and bodies. These results include the mark, snare, touch damage, and the `bite` knockback pair.

### Invariants

- The contact normal and position get in the polygon where the contact occurred. All knockback directions below come from them, and not from new geometry in Python.

- A projectile does not damage the body that fired it.

- During its full life, the `lob` damages each body at most once and damages the player at most once. It `rebounds` and stays a material blockage.

- A player projectile that returns in 2 ticks after its spawn is a spawn correction effect. The code removes it without sound. A return after that does 0.75 of its damage as `returned_round`.

- A body that crossed a doorway does not hold a door: the crossing removes its hold, route, and chase clocks.

- Touch damage obeys the hold. A touch from the `captor` returns without damage because the burn supplies the damage. Other bites do 0.5 damage while the player is held.

### Verification

A marker contact applies the mark to the player with `mark_hit` and a `brand_renew` event. A snare slows the player by its multiplier for its hold time. When two snares overlap, the stronger multiplier applies. A `bite` pushes the player with impulse 110 along the contact normal.

It `rebounds` the enemy with impulse 400 in the opposite direction. A projectile that hits a `shoot` door opens it, plays the unlock sound, and adds a `scorch`. A `tau` projectile that hits a wall with `rebounds` remaining plays `ricochet` and continues.

### Implementation

`_consume_events` walks the event list:

- `transfer`: identify the entity and, for an enemy crossing, remove `hold_since`, `route_stuck`, `chase_mark`, and `fold_stuck_until`. Emit `PortalCrossing`. If the crossed edge pair is part of a breach, note `interest` on that breach. When the player moves into the `sanctum`, turn the `cloister`. Also change the camera origin and count the transfer and the `visited` polygon. While the player is marked, add 8.0 doorway trail on the `departure` edge reported by the event.

- `wall`: a player push against a locked door calls `_door_bump`. A hit on a `soft` polygon calculates a push and applies `soft_wall_impulse` at the contact fraction along the edge. For a projectile, the impulse is `10 + 5.5 * damage`. For a body, it is the smaller of 90 and `0.06 * mass * speed`.

- `wall`, doors: a projectile other than `spit` opens a `shoot` door when it hits that door's edge. The path connects the door and emits the trace and the two topology `notices`. It plays the sound, adds a `scorch`, shakes the view, and flashes a light.

- `wall`, projectile results: `tau` and `taucharged` with `rebounds` remaining `spend` one and continue. `spit` adds a `splat`, while a `lob` `rebounds` and continues. A `dart` causes its burst, as does a `taucharged` projectile with full `power`. A `bullet` adds a `chip` decal and emits a sound and spark. Remove each other projectile.

- `contact`: `_contact`.

`_door_bump`: no key, a `shoot` key, or a held key returns. A limit of one prompt each 300 ticks for each key. Show the gate prompt of the door, or `DOOR SEALED - <KEY> SEAL REQUIRED`.

`_contact(a, b, spot, normal)` tests the two sequences of the pair. For a projectile `x` against body `y`:

- The `shooter` test is first. When `src` equals `y`, this sequence does not run.

- Against an enemy: a `dart` causes its burst. A `lob` applies `crossfire` damage at most once to each body, then continues. `bullet`, `tau`, `taucharged`, and `turret` damage with their impulse. A full charge also causes its burst, with the hit body left out. The projectile is removed (not the `lob`).

- Against the player, a marker sets the mark to full and emits its event, sound, and effect. `spit` causes damage. A `lob` causes damage at most once, emits `attacker_mark`, and continues. A snare raises `snare_t` to at least its hold duration and selects the stronger slow multiplier. The code processes the previous snare end before it arms the new snare, which thus starts with multiplier 1.0. It then emits the sound, mark, and event.

- Against the player, more: a `dart` causes its burst, plus 0.6 of the `lightning` damage as `lightning_self`. A `turret` projectile does no damage. The code removes a projectile that returns in 2 ticks without sound. Each other projectile is a returned projectile at 0.75. The projectile is removed, but a `lob` stays.

For contact between a player and an enemy, return if the enemy is the `captor` that holds the player. When the touch cooldown is 0 and touch damage is positive, add `attacker_mark` first. Apply 0.5 damage if a different body holds the player, or full damage if not. Then apply an impulse of 110 to the player along the contact normal.

Apply a `rebound` impulse of -400 to the enemy. All types receive one set `rebound`. Their mass adds the difference in movement.

### Caveats

An enemy projectile can contact an enemy. If it is a `spit`, `marker`, or `snare`, the code removes it with no effect. Fire between enemies does damage for the `lob` and the `dart` only, plus the physics push of each collision.

Two projectiles that touch have a physics effect only: no code effect, no removal.

## Containment sweep — `_outside_by`, `_containment_sweep`

### Goal

No entity can stay out of its polygon. The engine keeps this invariant during standard play. A group push at a cut door corner can push a body through a wall. The sweep returns a body that stays out to the polygon center and emits an important log line. This is damage control for an engine defect, not a standard path.

### Invariants

- Only a body that stays out returns: more than 25 units out on 6 sweeps in a row (3 seconds). A door push that the physics corrects does not start it.

- The `recovery` target comes from the live points, not from the specified centroid table.

### Verification

A body that stays 30 units out of its polygon for 3 seconds returns to the polygon center. Its velocity becomes 0, `containment_recoveries` increments, and a debug line is written to standard error. A body that stays out for only one sweep and is then corrected by physics does not change.

### Implementation

`_outside_by` calculates a point's signed distance from each wall of a convex polygon. It returns 0 or less for a point in the polygon. For a point out of the polygon, it returns the maximum outward wall distance.

`_containment_sweep` runs on each 30-tick beat across the player and all enemies. A distance of 25 or less sets the count to 0. Above 25 it counts, and at 6 the body moves to the vertex mean with velocity 0. The metric counts, and a `CONTAINMENT` line prints to the error output.

### Caveats

Defect: the module docstring states that the simulation does no input or output. This `recovery` path writes to standard error. The code comment states that this debug output is correct operation, but it does not obey the stated module boundary.

The long test campaign recorded two results. `Recovery` without the 6-sweep requirement blocked 54 of 985 runs. With the requirement, it blocked 1 of 1894 runs.

## Pickups and door unlocks — `_pickup_scan`, `ammo_bonus_for`, `_unlock_doors`

### Goal

The player collects ammunition, medkits, weapons, the `cloister` `core`, holes, the `implant`, components, `wrecks`, and door keys by touch. A collected key opens each related door in the same tick.

### Invariants

- The touch range is the player radius plus the pickup radius plus 2.

- A medkit stays on the floor while the player hp is above 70.

- A new weapon moves into the weapon list, becomes selected, and adds its ammunition quantity.

- A key unlock connects the two door edges and tells the signal and lighting systems. It also removes the door's locked edge entries.

- Each collected item emits `PickupTaken` and counts in `metrics`.

### Verification

A touch on `ammo_9mm` adds 30 times the ammunition multiplier and displays the pickup text. A touch on a medkit at 80 hp has no effect. The `cloister` `core` adds the `cloister` and adds 2 holes. A `wreck` returns its components and kits, with the `FRAME` text and a voice line. A `key_red` pickup displays its item name and prompt, then opens each `key_red` door.

### Implementation

`_pickup_scan` examines each pickup in touch range in the player polygon and processes it by type:

- Ammunition: the quantity times the multiplier, with sound and text.

- `medkit`: above 70 hp, do not run the pickup. Otherwise, set hp to `min(max_hp, hp + 35)`.

- Weapons: add, select, `ammo_bonus_for`, and the `ACQUIRED` prompt.

- `safe_polygon_core`: add the `cloister`, then add the `hole` weapon and 2 holes.

- `turret`: do not run the pickup. This type is objects, not a pickup.

- `portable_hole`: 1 plus the hole node value. `implant_lightning`: add the `lightning` weapon.

- `components`: its quantity. `corpse_frame`: the contents, plus the `logvoice` effect.

- Keys: add the key, sound, the item name text, the prompt, keep the metadata, and unlock.

Each collected item increments its metric, after which the code removes its body and record. `ammo_bonus_for` returns the set quantity for `smg`, `shotgun`, `rail`, and `tau`. `_unlock_doors` opens each closed door related to the key. It connects the edges and emits the trace and the two topology `notices`. It removes the locked edges and plays the unlock sound at the door.

### Caveats

Defect: the medkit threshold is the set number 70, not a fraction of `max_hp`. With `hp_up` `buys` (`max_hp` above 100), a player between 71 hp and `max_hp` cannot collect a medkit, although far below full hp.

## The `revival` economy — `stations`, the `shop`, `recall`, and the `reprint`

### Goal

Death costs travel progress but not the `mind`. The player `buys` all items with components received from kills. With one or more `chassis`, the player after death `reprints` at the nearest seed `station`. The remaining world, with the `wreck`, keeps its state. With no `chassis`, the start `pod` always does the `reprint`.

Seed kits `plant` new `stations`. The `recall` is an exit with a cost: a 90-tick channel that a hit closes.

### Invariants

- The functions `place_station`, `buy`, `use_recall`, `respawn_at_station`, `set_focus`, `complete_focus`, and `pod_heal` are menu-time calls. Their effects park in `_oob_fx` and go into the next tick.

- Only the first `station` at each position is recorded. A second `station` in 24 units in the same polygon does not change the record.

- The `reprint` with a `chassis` selects the nearest `station` by hops. A `station` with no route has distance 1,048,576. Equal distances select the first `station` in list sequence. `Recall` uses the same requirement. With no `chassis`, `reprint` selects the first `station`, which is the start `pod`. It sets full hp and removes each projectile in the world.

- The `recall` completes only after 90 ticks with no damage, `spends` the `recall`, and moves the player to the nearest `station`.

- The `hp_up` cost increases by 6 with each `buy`.

### Verification

A `buy` call for a `chassis` costs 8 components and displays the cost text. After a death with a `chassis`, the player `reprints` at the nearest `station` with full hp and the `REPRINTED` prompt. The `wreck` stays on the floor. Without a `chassis`, the player `reprints` at the `pod`. Damage during `recall` displays `RECALL SEVERED` without `spending` the item. A `planted` kit adds `revival` at its position.

### Implementation

`add_station` adds a `station` after the 24-unit distance test. `station_near` returns a `station` in 30 units in the player polygon, or `None`. `_park_oob(mark)` moves all fx entries at or after `mark` into `_oob_fx`. `place_station` `spends` a kit, keeps the position, and plays the `plant` sound and prompt.

`buy` indexes `SHOP` before it tests the simulation state. Thus an unknown item raises `KeyError`. It checks only the component cost. It returns `False` when the components are not sufficient.

It does not test `dead` or the player distance from a `station`. It also does not test if the player has the item. A correct call uses and applies the item.

The item can be a `chassis`, kit, `hp_up`, `recall`, or ammunition. The function lets the player `buy` the same item again. It plays the `buy` sound and displays the cost text. `shop_price` also raises `KeyError` for an unknown item and returns the increased cost for a known one.

`use_recall` returns `False` without a `recall` or while a channel is open. It also returns `False` after player death or when no `station` is available. Otherwise, it opens the 90-tick channel and displays the prompt. `_recall_tick` decreases that counter. At 0, it `spends` the `recall`, selects the nearest `station` by hops, and flashes an RGB (180, 235, 255) light.

It moves the player through `reseat_player` across polygons or `set_pos` in one polygon. It sets velocity to 0, does a camera hard cut, and plays the `reprint` sound and prompt.

`reseat_player` removes the player body and spawns it again in the target polygon with the same values. It then writes the face direction in the new coordinate space. `respawn_at_station` returns `False` only when no `station` is available. With at least one `chassis`, it selects the nearest `station` and decreases `chassis` by 1. With no `chassis`, it selects the first `station` at no cost.

Construction adds the start `pod` as the first `station`. Thus `reprints` with no `chassis` at the `pod` have no limit. The function then removes all projectiles, moves the player, zeros the velocity, and sets full hp. It removes `dead` and `freeze`, and emits the `player_respawn` trace event with the hop distance from the `wreck`. It sets the `tau` charge and the hole mark to 0, and does a camera hard cut. It arms the 180-tick `grace` with the `protected_revival` node, and plays the prompt, sound, and `playerreprint` effect.

`_station_scan` emits the `shop` effect when it receives an `interact` input while the player is near a `station`.

### Caveats

The `reprint` removes enemy projectiles too — each entry in `bullets`. Thus the code also removes live `spit` projectiles at the death.

`respawn_at_station` reads the death polygon through `player_polygon()` at call time. The caller must call it while the `wreck` stays where death occurred, and the app does.

The app layer controls where the user can call the external menu-time functions. `place_station`, `buy`, `set_focus`, `complete_focus`, `pod_heal`, and `respawn_at_station` do not test if a `station` or `pod` is near. The return-`False` requirements in their units are their complete requirements.

## The `mind` map — `set_focus`, `_think_tick`, `complete_focus`, `pod_heal`, `faith`, `_recompute_mind`

### Goal

The `mind` continues after the body. The player selects one `focus` node and thinks on it in the field, one tick at a time. A completed thought waits for the `pod`. Only the `pod` unlocks the node and connects its effects. `Focus` changes keep all progress, and death costs no thought.

### Invariants

- `_think_tick` runs only from `tick`: thought occurs in the field, and not in a menu.

- A completed node removes `focus`, moves into `think_done`, and waits. A call to `complete_focus` at the `pod` does the unlock.

- `_recompute_mind` calculates each multiplier again, in full, on each change. The combat effects live in flat fields.

- `pod_heal` sets full hp at the `pod`, with no cost, and returns `False` after death or when hp is full.

### Verification

A `focus` node completes after its tick count. The `quiet` `think_complete` sound and the `thought_done` effect occur, and the unlock waits. The `pod` call unlocks it with the `INTEGRATED:` prompt. With `weakpoint_scan_1`, approximately 10 percent of hits do 1.75 damage. With `recoil_control_1`, the spread multiplier is 0.75.

### Implementation

`set_focus` returns `False` for nodes that are complete or not available, and keeps the `focus`. `_think_tick` adds one tick to the progress of the `focus` node. It completes the node at the node's think tick count. `complete_focus` moves the node from `think_done` into `mind`, calculates again, and prompts. `faith` is the calculated score across `mind`, and no meter shows it.

`_recompute_mind` reads the unlock keys and sets the damage multiplier. It uses 1.20 for `blessed_rounds_dmg_adversary` and 1.15 for `monstrous_power_1`. It sets the target mark multiplier to 1.10 against targets not idle. It sets the spread multiplier to 0.75 and the `armor` multiplier to 0.85.

It also sets the acceleration multiplier (1.08 and 1.07 `overclock` nodes, 1.05 `monstrous_power_1`). It sets the `crit` values (0.10 at 1.75, or 0.20 at 2.0), the `salvage` multiplier (1.5), and the ammunition multiplier (1.25). Last: the regeneration limit and rate (0.50 or 0.75 of `max_hp`, 1 hp each second), the `protected_revival` truth value, and the hole node value (1).

### Caveats

Combat effects are not specified here for `dialogue` depth, text translation, and other keys. These keys go directly from `mind` to the app and `dialogue` layers.

## Wall terminals and the exit — `_terminal_scan`, `_exit_scan`, `_gate_count`

### Goal

A wall terminal sends its text to the renderer only after the first `interact` input in range. These 3 conditions complete the level. The player must be on the exit and hold the exit key. The gate-type count must be 0. Each new `visit` can display the closed exit condition again.

### Invariants

- A terminal reads only on its first `interact` input because `read` stays set.

- The exit first tests the exit key when the level names one. It then tests for zero live bodies of the gate type. A set gate polygon range limits that body test.

- The closed prompts occur at most once during each `visit`. A step off the exit arms them again.

### Verification

An `interact` input in 26 units of a terminal with `read=False` emits the `terminal` effect with its text and sets `read`. A walk onto the exit without the key shows the gate prompt or the `EXIT SEALED` key line. With the key but a live gate body, the gate line shows. With the two clear, `complete` and the metric become `True`.

### Implementation

`_terminal_scan` walks the terminals in the player polygon on an `interact` input and reads the first in 26 units. `_exit_scan` obeys `exit_enabled` and calculates the near condition (same polygon, in 18 units). When far, it arms the prompts again. When near, it tests the key and the gate type. `_gate_count` counts live bodies of the gate type, limited to the gate polygon range when set.

### Caveats

`exit_enabled` and `exit_gate_polygons` are optional fields that the streamer sets on the session. The `scan` defaults `exit_enabled` to enabled. It defaults `exit_gate_polygons` to no polygon limit.

## Visibility queries — `_clamp_apex`, `visible`, `sight_map`, `point_in_sight`

### Goal

`visible` is the one portal visibility query for the renderer and the bots, with the player as the root. Its result is screen geometry from the pixel-rounded rendered camera by default. This result does not become part of `snapshot()`. A bot calls `visible` directly to get the rendered visibility.

`sight_map` returns the AI's portal-wall visibility from a selected viewpoint. It uses the same calculation that the renderer uses but does not include painted terrain-mask data. `_clamp_apex` keeps each apex in the polygon. Thus a transfer in the same tick cannot cause the query to return an empty view.

### Invariants

- The apex margin (0.75) stays below the engine edge band (1.0). At or above it, the wide doorway fan before a crossing cannot start. The door side walls then show in one tick at each crossing.

- Gameplay callers of `visible` keep the default root and camera: the bot sees through this query. Only the renderer supplies them, only to look at a different position, and not during a measured run.

- Each call to `visible` also moves the player lights to the apex.

### Verification

A walk through a doorway shows no 1-tick blink of the polygon behind. A point not shown by a solid polygon wall is not in `point_in_sight`. The bot view equals the player view.

### Implementation

`_clamp_apex` pushes the point inward until it is at least 0.75 units from each polygon wall. It uses the internal normals from the vertex sequence. `visible(max_depth=14, max_instances=96, root=None, cam=None, apex=None)` pushes the apex in and moves the `flashlight`, the work `lamp`, and the lit muzzle light to it. Then it calls `sim.visible_set` with the pixel-rounded rendered camera, or with the given camera, and the screen dimensions. The camera selection changes the returned screen geometry. Player aim uses the smooth camera through `camera_transform()`.

`sight_map(polygon, x, y, radius=700, max_depth=4, max_instances=24)` adds a window around the viewpoint. Its width is 2 times the radius plus 10 percent. It calls `visible_set` and returns one record for each polygon instance in view. The record contains the polygon id and the matrix from its local frame into the viewpoint frame. It also contains the clip region in that frame.

`point_in_sight` maps the point through the instance matrix and tests the clip polygon with the standard crossing count. It has no special condition for a point on an edge or vertex. Thus edge direction and floating-point values can change its result. A boundary point is not always in the clip.

### Caveats

`visible` is a query with side effects because it moves the player lights. Thus the `lamp` sends light from the apex. Callers cannot use it as a read-only query.

Defect: `sight_map` and `point_in_sight` use only portal clip geometry. Painted `walk-mask` terrain can block movement and projectiles while a point behind that terrain continues to test as `visible`.

When `visible` receives a root different from the player polygon, the caller must also supply an apex. That apex must use the root's coordinates. The function does not check the `relationship`. A call with only `root` reads the player's local coordinate numbers in the other polygon's frame.

Decision open (see `spec/open-questions.md`, item `SIM-VISIBILITY-SIDE-EFFECTS`): a renderer call with different arguments can change the light map. A subsequent `flicker` AI tick can read that changed map. Thus the implementation uses these calls as part of deterministic operation. This text does not select if a visibility query must have no simulation effects.

The previous version of `visible` accepted and then discarded the camera argument. This put a viewed body at the incorrect screen position. The active version uses the argument.

## `snapshot` — the bot and test view

### Goal

`snapshot` supplies the world view for bots and tests. It contains the player state, exit state, and live `spit` projectiles in the player polygon. It also contains enemies and pickups with their polygons, positions, and hop distances. Hub bodies are not included until they move into the world.

### Invariants

- Enemies in hub polygons are not in the view. A body marked `dispatched` shows once it is in a world polygon.

- The `spit` list holds only enemy projectiles of type `spit` in the player polygon. These are the `spit` projectiles that a person can see.

### Verification

A bot reads the next edge to the exit, the necessary key, and the gate count from one call. A hub unit is not in the view until the code sends it into the world.

### Implementation

The dict holds tick, hp, `dead`, `complete`, polygon, and a position tuple. It also holds weapon, a weapon list, an ammunition dict, and a key set. Other fields are `lightning_ready`, holes, `tau_charge`, components, `chassis`, `station_kits`, `max_hp`, `recalls`, and `recall_t`. `Mind` is a set. `faith` is an integer. `think_focus` is a node id or `None`.

`think_progress` is a dict, and `think_done` is a list. Each `station` entry is `{"polygon": integer, "pos": position}`. `cloister` is `None` or `{"links": integer, "attached": integer}`.

Each enemy entry is `{"id": integer, "kind": string, "polygon": integer, "pos": (x, y), "hp": number, "state": string, "hops": integer}`. Each pickup entry has `id`, `kind`, `polygon`, `pos`, and `hops`. Each `spit` entry is `{"pos": (x, y), "vel": (vx, vy)}`. It includes only a live `spit` projectile in the player polygon. The lists keep the sequence of the dicts. The function does not sort them.

The exit fields are `exit_polygon`, `exit_next_edge`, `exit_key_needed`, `exit_gate_kind`, `exit_gate_remaining`, and `exit_gate_polygons`. `exit_next_edge` is -1 when there is no exit polygon. `exit_key_needed` is an empty string when no key is necessary or the player has it. The last field, `door_keys_needed`, is the sorted list of keys for closed doors that the player does not hold.

### Caveats

The enemy entries hold hp and state — more than the senses give an agent. The snapshot is for bots and tests, not for AI perception.

## `TopologyManager` — runtime topology ownership (`topology.py`)

### Goal

Each runtime cut and connection crosses through the `TopologyManager`. The engine calculates portal scale from the two connected edge lengths. A connection between different lengths adds a `lens` that resizes bodies. The `TopologyManager` uses two construction checks. Edge lengths must be equal before connection, and scale must be 1 after connection. A `lens` thus cannot stay in the world after construction.

### Invariants

- `connect_equal` does not accept edge lengths that are different by more than `1e-9`, before an engine call.

- After connection, a scale that is different from 1 by more than `1e-9` causes a disconnect and an exception. A code change can remove the length test, but cannot keep a live `lens` in the world.

- An `EdgeHandle` stays correct across `splits` that go through the `TopologyManager`. `_shift_after_split` corrects each held edge of the polygon.

- An incorrect `EdgeHandle` raises `TopologyError` and does not return an incorrect result.

### Verification

A connection between a 96-unit edge and a 52-unit edge raises, with the `lens` multiplier in the text. A connection between 2 equal edges returns a `PortalLink` with scale 1. A `carve` operation in a held polygon keeps each `EdgeHandle` at its edge. `current_edge` raises for a removed identifier.

### Implementation

The `TopologyManager` keeps a map from each `EdgeHandle` identifier to its polygon and edge. It also keeps a change hook, which has no operation by default. `adopt` receives a specified seam. `carve(polygon, near, width)` calls the world's `carve_door` and returns `None` when no wall fits. It moves held edge indexes at or after the new door by 2, adds the `EdgeHandle`, and fires the hook. `edge_length` measures the edge through the engine endpoints.

`connect_equal` finds the two edges, compares their lengths, connects them, and reads the portal matrix. It calculates scale as the length of the matrix's first column. If the scale is different from 1, it disconnects and raises. `disconnect(link)` finds the first edge, disconnects it, and fires the hook.

### Caveats

Defect (same as the hole unit): a `split` not done through the `TopologyManager` does not correct the `EdgeHandle` records. This includes a `split` added by the hole. The module text's requirement holds only for a `split` done through the `TopologyManager`.

The change hook is the topology `notice` of the signals. The lighting is not on this hook: see the defect in the `marrow` unit.

## Walk-mask terrain (`terrain.py`)

### Goal

A terrain-mask PNG adjacent to a polygon's floor texture states polygon-local rectangles. RGB (255, 255, 255) marks walkable pixels, while RGB (0, 0, 0) marks terrain. The engine receives the rectangles through `set_polygon_terrain`, and uses them the same as walls for movement and projectiles. Painted objects align with the floor graphics through the same texel map. Without a mask file, the polygon is fully walkable and the module adds no terrain.

### Invariants

- The mask must have the dimensions of the floor texture. Different dimensions raise `WalkMaskError`, and that mask cannot install.

- The decoder accepts only an 8-bit PNG with `interlace` 0 and type `gray`, `gray` with alpha, RGB, or RGBA. Each other format raises `WalkMaskError`. An incorrect mask count can cause a collision with no message. Thus the decoder raises for a format that does not obey these requirements.

- A missing mask file returns an empty list. A level with no `level_id` installs no terrain.

- The module uses only the standard library and `texture_geom`: `sim.py` stays free of `pygame`.

### Verification

A polygon with a painted crate blocks movement and projectiles along the crate outline at a 4-texel cell dimension. A polygon without a mask file is fully walkable. A palette PNG, 16-bit PNG, or `interlaced` PNG raises an exception with a clear message. A mask with different dimensions raises an exception. Its message contains the two dimensions.

### Implementation

`walkmask_path` is the texture path with `_walkmask` before the file extension. `decode_png_luminance` checks the first 8 bytes, then reads the chunks. It reads `IHDR` fields, collects `IDAT`, and stops at `IEND`. It must have `interlace` 0, bit depth 8, and a known color type. It expands the data with `zlib` and changes the direction of the 5 PNG row filters through `_unfilter`.

The decoder changes the result to one luminance byte for each pixel. An RGB (128, 128, 128) pixel copies directly. A `gray` pixel with alpha uses only its `gray` value. RGB and RGBA use the `BT.601` weights 299, 587, and 114, divided by 1000. Alpha is ignored.

`_coarse_grid` collects cells of 4 by 4 texels. Edge cells get their correct texel count. It marks a cell blocked when 0.5 or more of its texels are lower light than 128. The threshold uses the included texels. Thus one `gray` edge pixel cannot change a cell.

`_merge_rects` starts at each blocked cell that is not used and reads the complete horizontal run that starts there. The cells in that run must not be used. It extends that width down while each cell below is blocked and not used. A wider blocked run below can thus extend the rectangle only across the initial width. Remaining blocked cells form subsequent rectangles. The function does not include free cells.

`rects_from_mask` scales the cell ranges by 4 divided by the texture scale. It then offsets them by the polygon's minimum corner. This is the same texel alignment used by the floor graphics. `load_walk_mask_rects` first calls `Path.is_file()` and returns an empty list when the result is `False`. Thus a path that does not name a regular file installs no terrain.

When `Path.is_file()` returns `True`, `Path.read_bytes()` reads the file. An open or read error moves to the caller as its `OSError` type. The function checks the dimensions against `texture_size_for_polygon` and returns the rectangles. `apply_walk_masks` examines each polygon of a level and uses the streamer polygon offset. It installs the rectangle lists through `sim.set_polygon_terrain`.

### Caveats

The decoder does not test chunk `CRC` values. A damaged file usually raises during `expansion` or row filter direction change. Damage limited to a `CRC` does not cause an error or report.

Errors that occur when `zlib` expands the data, and structure errors from the standard library (`zlib.error`, `struct.error`), keep their initial types. They do not become `WalkMaskError`. The two conditions cause an error in the display, but callers do not receive the module-specified type.

## Public records and number tables

### Goal

This unit fully states the records available to callers and the enemy-number table.

### Invariants

- Each field below is part of the external record in the active code.

### Verification

Tests can compare each record with the schemas below.

### Implementation

The complete enemy records follow.

```text
husk: hp=15 radius=8 mass=1.6 accel=567 fric=3.2 turn=5 touch_dmg=12 touch_cd=38 alert_snd=enemy_alert_husk die_snd=enemy_die_husk score=1
mite: hp=4 radius=4 mass=1.4 accel=1012 fric=4.5 turn=7 touch_dmg=4 touch_cd=24 alert_snd=enemy_alert_mite die_snd=enemy_die_mite score=1
spitter: hp=18 radius=9 mass=1.7 accel=653 fric=3.8 turn=4.5 touch_dmg=8 touch_cd=45 alert_snd=enemy_alert_husk die_snd=enemy_die_husk spit_cd=95 spit_speed=380 spit_dmg=9 keep_min=110 keep_max=190 score=2
brute: hp=65 radius=13.5 mass=7 accel=430 fric=2.6 turn=3.2 touch_dmg=24 touch_cd=55 alert_snd=enemy_alert_husk die_snd=enemy_die_brute score=4
shrieker: hp=10 radius=7 mass=1.5 accel=701 fric=3.4 turn=6 touch_dmg=0 touch_cd=60 alert_snd=shrieker_scream die_snd=enemy_die_mite scream_cd=300 score=3
warden: hp=168 radius=16 mass=12 accel=386 fric=2.4 turn=2.6 touch_dmg=30 touch_cd=48 alert_snd=enemy_alert_warden die_snd=enemy_die_brute spit_cd=70 spit_speed=460 spit_dmg=13 keep_min=0 keep_max=100 score=10
vagrant: hp=84 radius=9.5 mass=1.5 accel=701 fric=3.4 turn=3.5 touch_dmg=6 touch_cd=50 alert_snd=enemy_alert_mite lob_cd=90 lob_speed=300 lob_dmg=3 lob_range=180 lob_mass=2.4 lob_radius=16 lob_rest=0.55 snare_cd=200 snare_speed=430 snare_range=560 snare_hold=90 snare_slow=0.35 die_snd=enemy_die_mite score=6
lacuna: hp=42 radius=8.5 mass=1.4 accel=653 fric=3.8 turn=3.2 touch_dmg=4 touch_cd=50 alert_snd=enemy_alert_mite lob_cd=110 lob_speed=280 lob_dmg=2 lob_range=165 lob_mass=2.1 lob_radius=14 lob_rest=0.55 snare_cd=240 snare_speed=400 snare_range=500 snare_hold=75 snare_slow=0.45 die_snd=enemy_die_mite score=4
core_collar: hp=126 radius=13 mass=60 accel=0 fric=8 turn=0.1 touch_dmg=0 touch_cd=999 alert_snd=terminal_type die_snd=enemy_die_brute score=6
core_scriptorium: hp=84 radius=14 mass=60 accel=0 fric=8 turn=0.1 touch_dmg=0 touch_cd=999 alert_snd=terminal_type die_snd=enemy_die_brute score=5
core_caretaker: hp=42 radius=9 mass=40 accel=0 fric=8 turn=0.1 touch_dmg=0 touch_cd=999 alert_snd=terminal_type die_snd=enemy_die_mite score=3
core_anchor: hp=84 radius=12 mass=60 accel=0 fric=8 turn=0.1 touch_dmg=0 touch_cd=999 alert_snd=terminal_type die_snd=enemy_die_brute score=4
core_bud: hp=42 radius=7 mass=40 accel=0 fric=8 turn=0.1 touch_dmg=0 touch_cd=999 alert_snd=terminal_type die_snd=enemy_die_mite score=2
core_source: hp=168 radius=15 mass=80 accel=0 fric=8 turn=0.1 touch_dmg=0 touch_cd=999 alert_snd=terminal_type die_snd=enemy_die_brute score=12
flicker: hp=22 radius=8.5 mass=1.5 accel=729 fric=3.4 turn=6.5 touch_dmg=16 touch_cd=42 alert_snd=enemy_alert_husk die_snd=enemy_die_husk score=3 lurk_speed=95 ambush_radius=70 ambush_burst=560 ambush_ticks=18 disengage_light=0.15 disengage_dist=220 disengage_beat=90
```

The Adversary class sequence from weakest to strongest is `lacuna`, then `vagrant`.

All decal entries use `(kind, x, y, size, angle)`. A polygon maps to its list of these entries. `decal_versions[polygon]` is an integer.

The external effect records follow. A position record added by `_fx_at` starts with `(tag, polygon, x, y)` and then has the listed fields.

```text
sound: (sound, name, polygon, x, y, volume)
shake: (shake, magnitude)
objective: (objective, text)
lightning: (lightning, polygon, x, y, radius)
corpsefall: (corpsefall, polygon, x, y, enemy_kind, radius, angle)
gib: (gib, polygon, x, y, integer_radius, (direction_x, direction_y), enemy_kind)
hitflash: (hitflash, entity_id)
playerhurt: (playerhurt, damage)
playerdie: (playerdie)
alerted: (alerted, polygon, x, y)
arrived: (arrived, entity_id)
crossing: (crossing, entity_id)
`scream`: (`scream`, polygon, x, y)
attacker_mark: (attacker_mark, entity_id)
engulfed: (engulfed, polygon, x, y)
marker_fire: (marker_fire, polygon, x, y, direction_x, direction_y)
spark: (spark, polygon, x, y, normal_x, normal_y)
marked: (marked, polygon, x, y)
pickup_text: (pickup_text, polygon, (x, y), text)
logvoice: (logvoice, line_number)
thought_done: (thought_done, node_id)
playerreprint: (playerreprint)
`shop`: (`shop`)
terminal: (terminal, text)
```

Each trace bus item is `TraceRecord(seq, tick, kind, data)`. JSON changes `tick` to `t` and writes the data fields adjacent to `seq`, `t`, and `kind`. The complete event data fields follow.

```text
input: mx my ax ay fire alt interact weapon
agent_transition: entity_id agent_kind from_state to_state x y
enemy_positions: positions, where each value is [enemy_kind, polygon, x, y]
player_death: polygon x y source chassis_left deaths
portal_crossing: entity_id entity_kind from_polygon to_polygon edge
damage_applied: target_id target_kind amount source
impulse_applied: entity_id jx jy source
field_sample: totals player_polygon player_own
breach_lifecycle: breach_id event world_chamber detail
core_part: part_id part_kind event detail
reserve_sample: `reserve` value live_breaches pending_kind
dispatch_decision: breach_id unit_kind entity_id from_shelf knows_position hub_chamber
pickup_taken: item amount
shelf_replaced: unit_kind entity_id hub_chamber
enemy_death: entity_id enemy_kind polygon
coord_event: entity_id agent_kind event detail
topology_changed: op a_polygon a_edge b_polygon b_edge source
sample: hp polygon pos weapon kills deaths dmg_taken ammo
frame_timing: frames fps ms_frame ms_worst ms_sim ms_draw ms_present ms_record ms_wait sim_ticks
```

The 9 signal records use `(half-life seconds, spread each second, hop gain)`.

```text
DISTRESS=(45, 0.12, 1), DANGER=(180, 0, 1), NOISE=(3, 1.20, 1)
TRAIL=(12, 0, 1), PATROL=(60, 0, 1), MUSTER=(1, 1.8, 0.35)
GARRISON_INTERIOR=(1.5, 0.9, 1), GARRISON_REACH=(2, 0.7, 1), KIN=(8, 0.45, 1)
decay_each_tick = 0.5 ** (1 / (half_life * 60)), spread interval=15 ticks
```

The complete `coordination` formulas and limits follow.

```text
threshold for the fraction of active peers at spawn: uniform(0.25, 0.45)
excitation = min(1, (NOISE + DISTRESS) / 0.60)
f = (committed_visible + excitation) / (all_visible + 1)
hazard = 0 when f <= 0, else f**4 / (f**4 + threshold**4)
commit probability on each 10-tick decision = 0.22 * hazard
immediate signal condition = DISTRESS >= 0.45 or NOISE >= 0.40
stand down = no view record and max(NOISE, TRAIL, DISTRESS) < 0.05 for 300 ticks
`danger` hold = DANGER in next polygon > 0.70 and active peers below the call limit and local MUSTER < 0.60
call limit = 1 for a sighted cross-portal chase, if not 2
settle = warden present, no hostile view record, NOISE < 0.20, DANGER < 0.35, held for at least 720 ticks
new TRAIL lock threshold = 0.30
```

Enemy movement uses each record's `accel`, `fric`, and `turn`. Idle move uses 0.35 of acceleration and changes direction after 45 to 150 ticks. `Prowl` uses 0.4 of acceleration. A `husk` lunges in 95 units at speed 300 with a 120-tick cooldown. A `brute` lunges in 95 units at speed 240 with a 150-tick cooldown.

The `spitter` keeps 110 to 190 units and fires damage 9 at speed 380 each 95 ticks. The `warden` stays in 100 units and fires damage 13 at speed 460 each 70 ticks. It can start `engulf` in the same polygon at a distance below 120 units. The enemy `wake` waits are `husk 32`, `mite 18`, `spitter 26`, `brute 45`, `shrieker 12`, `warden 20`, `vagrant 14`, and `lacuna 14` ticks.

The `vagrant` and `lacuna` target values are in their complete records above. Their `lob` and snare fire only during `flee`. The `shrieker` and `flicker` target values and state movement are in their units above. `Core` bodies have no movement AI.

### Caveats

The trace event classes live in `game/perihelion/telemetry.py`. This unit states the necessary external schema because `GameSession` emits those records.
