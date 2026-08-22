---
This specfile includes the testkit modules in `game/perihelion/testkit/`: `__init__.py`, `harness.py`, `bots.py`, `humanbot.py`, `perception.py`, `mouse_model.py`, `tactician.py`, `loadouts.py`, `replay.py`, `perf.py`, and `graphs.py`.
---

# The testkit

This specfile tells how the code in `game/perihelion/testkit/` operates. These modules run Perihelion without a window. On each tick, a bot reads simulation state and returns the same `InputFrame` structure as keyboard and mouse input. The simulation uses the same procedure for bot and player input.

These modules assemble tools on that contract. They include a run `harness` with metrics, a level gate, and a replay system. They also include a bot that copies player input, timing measurements, and a graph fixture for `mindmap.py`.

This file has 19 units plus package-API coverage:

- The package API (`game/perihelion/testkit/__init__.py`) supplies the bot, replay, and `harness` names from the units below. It adds no other operation.

- The run `harness` (`harness.run_bot`, `harness.Result`, `harness.summarize`, `harness._start_capture`, `harness._save_frame`).

- The bot matrix (`harness.run_matrix`, `harness._instantiate`).

- The level gate (`harness.assert_playable`).

- The bot functions (`bots.choose_weapon`, `bots.nav_to_point`, `bots.nav_to_polygon`, `bots.nav_to_exit`).

- The bot classes `bots.Bot`, `bots._UnstickMixin`, and `bots._CombatMixin`.

- `AggroBot` and `SteadyBot` (`bots.py`).

- `PacifistBot`, `CamperBot`, and `ExplorerBot` (`bots.py`).

- The perception model (`perception.PerceptionModel`).

- The mouse model (`mouse_model.MouseModel`).

- `HumanBot` state and senses (`humanbot.HumanBot.__init__` and its small functions).

- `HumanBot` step (`humanbot.HumanBot.step`).

- `HumanBot` `combat` (`humanbot.HumanBot._combat_input`, `_update_flank_escape`).

- `HumanBot` movement (`_objective_move`, `_nav_exit_move`, `_nav_polygon_move`, `_portal_goal`, `_steer_target`, `_best_field`, `_retreat_gain_update`).

- `HumanBot` set sequences and travel `aim` (`_travel_aim`, `_distant_threat_input`, `_sweep_aim`, `_humanize_move`, `_maybe_start_threshold_pause`).

- The `tactician` (`tactician.Tactician`).

- The calibration `loadout` (`loadouts.FULL_LOADOUT`).

- The replay (`replay.Replay`, `replay.record`, `replay.play`).

- The `perf` module (`perf.py`, the full module).

- The test graph for `mindmap.py` (`graphs.synthetic_mindmap`).

## The run `harness` — `harness.run_bot`, `harness.Result`, `harness.summarize`

### Goal

Run one bot on one level without a window and collect data for level inspection. The result includes the `outcome`, metrics, hp and `ammo` `timelines`, and an event list. It also includes the `combat` tick count and the number of ticks without `ammo`. The function can also write images and the session `trace` to files.

### Invariants

- `run_bot` starts a new `GameSession(level, seed=seed)`. For each `bot.step` result, it runs one `session.tick`.

- The loop ends at `max_ticks` ticks, at player death, or at the level end. `Result.outcome` is `complete`, `died`, or `timeout`.

- An error in image output does not stop the run and does not raise. The code sets `Result.capture_skipped` to `True` and the run continues.

- When the caller supplies `trace_path`, the same `TraceWriter` class used by Perihelion writes the `trace`. Bot and player `traces` thus use one format by construction.

- Two calls return the same simulation `Result` values when 3 conditions hold. They use equivalent new level data, new bots of the same class and configuration, and the same seed. Image paths, `trace` paths, and their file effects have no effect on this equality.

### Verification

- Run `run_bot` twice with equivalent level data loaded for each call. Use new bots of the same class and the same seed. Check that all simulation `Result` fields agree (`game/tests/test_testkit.py::test_two_identical_aggro_runs_are_bit_identical`).

- Run with a renderer class that raises in `draw`. Check that the run completes and `capture_skipped` is `True` (`test_capture_is_best_effort_and_never_fails_the_run`).

- Run `AggroBot` on the small test level. Check that the `outcome` is `complete` (`test_aggro_bot_completes_smoke_level`).

### Implementation

`run_bot(level, bot, seed, max_ticks=18000, capture_every=0, capture_dir=None, renderer=None, trace_path=None)` returns a `Result`. The default `max_ticks` is `60 * 300`, or 300 seconds of simulation time.

Each loop step does this sequence:

- It reads `session.snapshot()`. If an enemy in the snapshot is in the player polygon, it increments `time_in_combat_ticks`.

- It calls `bot.step(snap, session)` and sends the result to `session.tick`.

- If a `TraceWriter` is open, it writes all new events from `session.trace` to the file.

- If image output is on, it does the image output step below.

- It compares `session.metrics` with the previous tick's values. An increase in `kills`, `dmg_taken`, or `pickups` adds an event dictionary with the type, change, and tick.

- If total `ammo` is at most 0, it increments `ammo_starved_ticks`. Each 60 ticks, it adds one `(tick, ammo sum)` pair and one `(tick, hp)` pair to the two `timelines`.

When `capture_every > 0`, `_start_capture` starts the renderer objects. If `renderer` is `None`, it imports `perihelion.render.Renderer`. The `draw` dimensions are `(INTERNAL_W, INTERNAL_H)`. When the caller supplies a directory, it adds all necessary `capture_dir` directories. On an error, `_start_capture` returns `(None, None)` and `run_bot` sets `capture_skipped`.

The loop calls `consume_fx(session.fx)` on each tick because the renderer's effect pools decay once for each tick. Only `draw` follows the `capture_every` interval. When `capture_dir` is set and `session.tick_count % capture_every == 0`, the loop calls `draw`.

`_save_frame` then writes the image as `frame_<index>.png` with `PIL`. Because the `draw` output has shape `(W, H, 3)`, `_save_frame` changes the axis sequence to `(H, W, 3)` before it writes. A write or `draw` error sets `capture_skipped`, after which the code writes no more images.

After a last drain, the code closes the `TraceWriter` and fills the `Result`. Its fields are the `outcome`, metrics dictionary, `ticks_alive`, number of `visited` polygons, and two `timelines`. The fields also include two tick counts, `portal_crossings` from `metrics["transfers"]`, events, image output fields, seed, and bot class name.

`summarize(res)` returns a `JSON`-safe dictionary of the same data. Because `metrics["polygons_visited"]` is a Python `set`, `summarize` changes it to a sorted list. All other values are `JSON`-safe.

### Caveats

- If `capture_every > 0` and `capture_dir` is `None`, the code starts the renderer. It calls `consume_fx` on each tick but writes no images.

- The `combat` count comes from the snapshot before the tick. The event tick values come from `session.tick_count` after the tick.

- An event dictionary for a kill or pickup contains the count change. A damage event contains the hp change.

- The module imports `os` and does not use it.

- The `trace` header contains the level name, seed, and bot class name.

## The bot matrix — `harness.run_matrix`, `harness._instantiate`

### Goal

Run each `(bot, seed)` pair. Return a flat table with one report row for each run to compare bots and seeds.

### Invariants

- Each `(bot, seed)` pair receives a new bot instance. Bot state does not leak between runs.

- An item of `bots` can be a `Bot` subclass or a `factory` from a seed to a bot. It can also be a bot instance.

### Verification

- Run `run_matrix` with two bot classes and two seeds. Check that the table has 4 rows and each row contains the bot name, seed, and `outcome`.

### Implementation

For each pair, `_instantiate` calls the bot constructor. For a `Bot` instance, it calls `type(bot_like)(seed)`. For all other inputs, it calls `bot_like(seed)`. It then calls `run_bot` with the supplied `max_ticks`. Each row contains `bot`, `seed`, `outcome`, `ticks_alive`, `kills`, `dmg_dealt`, `dmg_taken`, `polygons_visited`, `portal_crossings`, `ammo_starved_ticks`, and `time_in_combat_ticks`.

### Caveats

- For a bot instance, `_instantiate` calls the class with only the seed. The other constructor values do not go into the new instance. For example, a `HumanBot(seed, skill=7.0)` instance in `bots` runs with the default `skill`.

- `run_matrix` uses the same supplied `Level` for each pair. Bot state is isolated, but level state is not. Sessions with deformable walls write changed vertex positions back to the level. A subsequent pair can receive those changes.

## The playable gate — `harness.assert_playable`

### Goal

Give a fast level gate that returns a list of clear errors. An empty list means that no error was found. The gate examines 4 properties. A player with low `skill` can complete the level. `Combat` is mandatory. Bots complete a basic radial movement check.

Mean tick cost is at or below its limit.

### Invariants

- `AggroBot` must complete the level. A different `outcome` adds an error with the `outcome` and the tick counts.

- If the level has enemies, `PacifistBot` must not complete it. Its completed run adds an error, because the level structure makes `combat` mandatory.

- For each of the 4 bot classes, measure the player's distance from the polygon center. It must stay below `polygon_radius + 8.0` for the first `containment_ticks` ticks (default 3600).

- The mean wall time of `session.tick()` across 600 `AggroBot` ticks must be less than 2.5 ms.

### Verification

- Run `assert_playable` on the small test level with seed 0. Check that the error list is empty (`test_testkit.py::test_assert_playable_smoke_level_has_no_issues`).

- Run it on a level with no player path to its exit. Check that the gate reports the `AggroBot` error.

### Implementation

Check 1 runs `AggroBot` through `run_bot` for not more than `max_ticks`. Check 2 searches `level.entities` for enemy types in `ENEMIES`. It runs `PacifistBot` only if the level contains enemies.

Check 3 runs `AggroBot`, `PacifistBot`, `CamperBot`, and `ExplorerBot`, each in a new session, for at most `min(max_ticks, containment_ticks)` ticks. On each tick, it compares position radius `hypot(px, py)` with `session.sim.polygon_radius(polygon) + 8.0`. At the first error, it records the polygon, tick, and the two values, then stops that bot. Check 4 runs `AggroBot` in a different new session for at most 600 ticks. It times only the `session.tick` calls with `time.perf_counter` and compares their mean with 2.5 ms.

### Caveats

- Defect: the docstring calls the gate deterministic, but check 4 measures wall time. A slow system, or a system with load, can change the result of that check. Checks 1 to 3 are deterministic.

- Defect: check 3 is not polygon containment. `polygon_radius` is the maximum distance of a vertex from the local origin. A body can cross a polygon edge while it stays in that maximum radius plus 8 units. The gate does not always report such boundary crossings.

- `assert_playable` uses the supplied `Level` for all of its runs. On a level with `soft walls`, a run can change the vertex positions that a subsequent check uses at its start.

- Check 3 stops a bot at its first error. It can report at most one containment error for each bot.

## The shared bot functions — `bots.choose_weapon`, `bots.nav_to_point`, `bots.nav_to_polygon`, `bots.nav_to_exit`

### Goal

Give free functions used by all bots. `choose_weapon` selects a weapon for combat at a given distance and enemy count. The `nav_*` functions return movement vectors to targets through the router.

The weapon `policy` comes from the 2026-07-16 calibration: a player who has all weapons uses all of them. Heavy enemies call for the `rail`, and large groups at range call for the `tau`. Close groups call for the `shotgun`, and small enemies call for the `smg`.

### Invariants

- `choose_weapon` returns a value for `InputFrame.weapon`: the index in `WEAPON_ORDER` plus 1, or 0 for no change.

- The movement functions return a normalized screen-space vector, or `(0.0, 0.0)` when there is no route or no target.

- The coordinate changes obey the convention of `sim.py`. `mat_apply_dir(cam, ...)` changes a polygon-space direction to a screen-space direction. `mat_apply(cam, ...)` changes a polygon-space point to a screen-space point.

### Verification

- Give `choose_weapon` a snapshot with a `warden` at hop distance 1 or less, the `rail`, and `cell` `ammo`, at distance 100. Check that it returns the `rail` value.

- Give it empty `ammo` pools, distance 30, and the `knife`. Check that it returns the `knife` value.

- Give `nav_to_polygon` the player polygon and a target point. Check that the returned vector points to the target.

### Implementation

`choose_weapon(snapshot, dist, n_enemies)` tests these conditions in sequence and returns at the first condition that applies:

- All of `9mm`, `shell`, and `cell` are 0, the distance is less than 40, and the bot has the `knife`: the `knife`.

- A `warden` or `brute` at hop distance 1 or less, the `rail` with `cell` `ammo`, and distance above 55: the `rail`.

- 5 or more enemies, distance above 90, and the `tau` with `cell` `ammo`: the `tau`.

- Distance less than 70 and the `shotgun` with `shell` `ammo`: the `shotgun`.

- The `smg` with `9mm`. Then the `pistol` with `9mm`. Then the `rail` with `cell` `ammo`. Then the `shotgun` with `shell` `ammo`. Then the `knife`, then 0.

`nav_to_point(session, px, py, target)` accepts a pair or a `necore.Coordinate`. Because each engine geometry query returns a `Coordinate`, callers can use its result directly. A `Coordinate.local()` call returns its pair. The function changes the polygon-space difference to unit length and transforms it with `mat_apply_dir(session.cam, ...)`. It then changes the result to unit length again.

In the target polygon, `nav_to_polygon(session, snapshot, target_polygon, target_point=None)` steers to `target_point` or returns `(0.0, 0.0)` when none is supplied. From a different polygon, it reads the next portal edge from `session.sim.next_edge` and steers to that edge's midpoint. A negative edge returns `(0.0, 0.0)`.

`nav_to_exit(session, snapshot)` returns `(0.0, 0.0)` when there is no exit polygon. In the exit polygon, it steers to `session.exit_pos`. From a different polygon, it reads the routed edge from `snapshot["exit_next_edge"]` and does not query the router.

### Caveats

- The previous weapon selection conditions did not select the `rail` or the `tau`, and each `warden` killed the bot. The conditions above let the bot select these weapons.

- The `tau` condition applies only to 5 or more enemies at range. Without a different applicable condition, `choose_weapon` does not select the `tau` in a `duel`.

## The bot parent class and the mixins — `bots.Bot`, `bots._UnstickMixin`, `bots._CombatMixin`

### Goal

`Bot` defines the interface and shared state for all bots: each bot has its own random stream and only reads the session. The `unstick` `mixin` frees a bot when wall contact prevents movement. The `combat` `mixin` gives combat decisions used by many bots. It calculates `aim` error from player measurements and fires only when that error is small. It also applies weapon `hysteresis` and adjusts movement to maintain the selected weapon range.

### Invariants

- Each bot has a `Random(seed)`, and no bot reads `session.rng`. A change to one bot or its seed has no effect on a different bot's decisions. It also has no effect on the simulation's random stream.

- Bots read the session (`cam`, sim queries, exit data, screen dimensions) and do not write to it. `session.sim.next_edge` and `hop_distance` cache route data internally. That is a read query, not a write to simulation state.

- `Bot.step` raises `NotImplementedError`. Each subclass must supply `step`.

- The `unstick` override changes only `mx` and `my`. The `aim` and the fire values stay.

### Verification

- Run one bot twice with the same seed on the same level. Check that the two runs return the same input on each tick.

- Put a bot in a corner where its `policy` pushes into the wall. Check that its position changes in 50 ticks or less.

- `test_human_bot.py::test_aggro_bot_fires_on_the_same_tick_the_enemy_becomes_copolygon` shows that the `mixin` fires with no perception `latency`.

### Implementation

`_UnstickMixin` keeps the last 30 positions in a `deque`. When the distance between the first and last positions is less than 4.0 world units, it samples a random screen direction. It writes that direction into `mx` and `my` for 20 ticks. `_apply_unstick(px, py, inp)` runs at the end of each `step`.

`_CombatMixin._combat_input(session, snapshot, enemies_in_polygon, mobile)` targets the nearest enemy in the player polygon:

- The `aim` error is a limited random walk. Each tick it adds a sample from ±0.05 `rad` and limits the result to ±0.22 `rad`. The `aim` angle is the correct angle plus the error. The `aim` point is at the enemy distance along it, changed to screen space with `mat_apply`.

- The fire condition scales with range. The permitted error is `max(3.0 degrees, atan2(0.9 * target_radius, dist))`. The bot fires when the error is below that limit. When the target id is no longer in the simulation, the radius falls back to 8.0.

- A weapon change waits for `hysteresis`. Because `choose_weapon` keeps no state, combat near a range threshold can return a new selection on each tick. This can change the weapon and HUD on many ticks. The bot thus sends a change only when the selection equals the active weapon or stays the same for 12 ticks.

- `alt` (the `discharge`) is on when 3 or more enemies are in the same polygon. `lightning_ready` must also be `True`, and the bot must have the `lightning`.

- When `mobile` is `True`, movement closes distance with the `knife`, retreats below 60 world units, and closes above 140. Between those distances, it strafes with the lateral direction times a sign. It also adds a sample from ±0.3 along the enemy axis. The sign changes with probability 0.02 on each tick.

### Caveats

- The `aim` error controls the fire decision and also turns the `aim` point. As a result, the bot can fire in a direction other than the target direction. This models player `aim`, which is not fully accurate.

- `_init_combat` sets the initial `_CombatMixin` state, and `_init_unstick` sets the initial `_UnstickMixin` state. A subclass that does not call them raises attribute errors.

## `AggroBot` and `SteadyBot` — `bots.py`

### Goal

`AggroBot` is the primary bot that completes levels. It engages enemies in its polygon and collects a `medkit` when its hp is low and no enemy is near. If that condition does not apply, it heads to the exit. It also moves for door keys, enemies that block the exit, and `ammo`.

`SteadyBot` is `AggroBot` with 0.5 times the `aim` error. It models a person with moderate `skill`.

Each bot supplies one measurement. `AggroBot` tests if a player with low `skill` can complete the level. It must complete near 100 percent of the runs on `normal` difficulty.

`SteadyBot` tests if a player with good `skill` can complete the level. It must complete near 100 percent of the runs on `hard` difficulty while `AggroBot` usually does not complete them. The difference between their results measures difficulty. Gates for `hard` difficulty must use `SteadyBot`.

### Invariants

- In `combat`, the movement comes from the `combat` `mixin`. After more than 10 seconds of `combat` `pressure`, the bot walks in the exit direction while it fires.

- When not in `combat`, `combat` `pressure` decreases by 2 on each tick and does not become 0 immediately. Each subsequent movement through one doorway can thus continue to increase `pressure`.

- When the bot is not in `combat`, it searches for a `medkit` if its hp is below 60. The search uses hop distance 0 to 3. The bot keeps one selected `medkit` until that item is no longer in the level.

- Door keys come before all other route turns, but after `combat` and hp. A door-key search targets the pickup types `key_<k>` for each named key `k`.

- The idle `aim` point is the screen center.

### Verification

- Run `AggroBot` on the small test level. Check that it completes (`test_testkit.py::test_aggro_bot_completes_smoke_level`).

- Put the bot in combat at a doorway where its `strafe` pushes it out of the polygon. Check that the run does not stay in combat for more than 60 seconds.

- Run `SteadyBot` and `AggroBot` on a set of `hard` levels. Check that `SteadyBot` completes more runs.

### Implementation

When enemies are in the polygon, `AggroBot.step` increments the `combat` streak and calls the `combat` `mixin` with `mobile=True`. When the streak is more than 600 ticks, `nav_to_exit` replaces the movement. A strafe without other movement cannot always exit the polygon. A polygon that adds enemies on many ticks can thus keep combat active without a limit.

Without enemies, the streak decreases by 2 and the bot selects one target:

- With hp below 60 and a `medkit` at hop distance 0 to 3, move to the kept `medkit`. Its selection key is `(polygon, pos)`. A new selection on each tick can change between two `medkits` through opposite portals. Because positions in different polygons are in different coordinate spaces, distance is not a correct selection key. A new target is the minimum by `(hops, polygon)`.

- If no previous condition applies, `_navigate` checks door keys and enemies that block the exit. It then checks `ammo` and the exit. When `door_keys_needed` or `exit_key_needed` names keys, the bot moves to the nearest `key_<k>` pickup by hop count. When `exit_gate_remaining` is nonzero, it `hunts` the nearest enemy of `exit_gate_kind` in `exit_gate_polygons`. When total `ammo` is at most 6, it moves to the nearest `ammo_*` pickup. If none of these conditions apply, it uses `nav_to_exit`.

`SteadyBot._combat_input` calls the `Bot` method and then limits the `aim` error to ±0.11 `rad`.

### Caveats

- The `SteadyBot` limit runs after the `Bot` class calculates the tick's `aim` and fire decision. The `Bot` class can add at most 0.05 `rad` before the limit. Thus the error at `aim` time can be 0.16 `rad`, not 0.11.

- The `medkit` selection clears when the `medkit` is no longer in the level or when hp is 60 or more.

- The `pressure` override changes only the movement. The `aim`, the fire value, and the weapon stay set for combat.

## `PacifistBot`, `CamperBot`, and `ExplorerBot` — `bots.py`

### Goal

Give 3 test bots that measure levels. `PacifistBot` does not fire. It moves in the direction opposite enemies in its polygon and walks to the exit when not in combat. If it completes a level that contains enemies, the level gate reports that `combat` did not occur.

`CamperBot` holds position and engages enemies to measure a bot that does not move. `ExplorerBot` goes to the nearest `unvisited` polygon until its `unvisited` set is empty. It then heads to the exit to measure which polygons a player can go into.

### Invariants

- `PacifistBot` sets `fire=False` and `alt=False` each tick.

- `CamperBot` does not travel. Its only movement is a small `strafe` from side to side during combat.

- `ExplorerBot` records each polygon after it moves to that polygon. Its target is an `unvisited` polygon with the smallest hop distance.

### Verification

- Run `PacifistBot` on a level with no enemies. Check that it completes (`test_testkit.py::test_pacifist_bot_survives_empty_level_and_reaches_exit`).

- Run it on a level with mandatory `combat`. Check that it does not complete (`test_pacifist_bot_does_not_complete_level_with_mandatory_combat`).

- Run `CamperBot` and `ExplorerBot` on the small test level. Check that each bot runs without an error (`test_camper_and_explorer_bots_run_without_crashing`).

- Run `ExplorerBot` twice with one seed. Check that the runs agree (`test_explorer_bot_run_is_deterministic`).

### Implementation

With enemies in the polygon, `PacifistBot.step` moves to the other side of the player from the nearest enemy. That point is `(2*px - ex, 2*py - ey)`. It `aims` at that enemy. Without enemies, it uses `nav_to_exit` and `aims` at the screen center. It includes the `unstick` `mixin`.

When the polygon contains enemies, `CamperBot.step` calls the `combat` `mixin` with `mobile=False` and then sets its `strafe`. The `strafe` follows the lateral direction to the nearest enemy, scaled by `sin(phase) * 0.6`. The phase increases by 0.15 on each tick. The result is transformed to screen space and limited to length 0.6. Without enemies, the bot stays in one position and `aims` at the screen center.

When the polygon contains enemies, `ExplorerBot.step` calls the `combat` `mixin` with `mobile=True`. Without enemies, `_pick_unvisited` checks each polygon. It does not select a `visited` or unreachable polygon. It returns the polygon with the smallest `hop_distance`. When no `unvisited` polygon stays, the bot uses `nav_to_exit`.

### Caveats

- `CamperBot` has no `unstick` `mixin`. That is the goal: it must hold its position.

- `PacifistBot` `aims` at the enemy as it increases its distance from that enemy. In recorded images, the bot thus looks at the threat.

- `_pick_unvisited` queries `hop_distance` for each level polygon on each tick. On large levels, this is the bot's primary cost.

- `ExplorerBot` marks a polygon as `visited` only when it is in it. A polygon that it only sees through a portal stays a target.

## The perception model — `perception.PerceptionModel`

### Goal

`GameSession.snapshot()` contains each enemy in the level at its simulation position and without a limit on view distance. The bots in `bots.py` can read all that information. The perception tests use that information as a comparison reference.

`PerceptionModel` gives only data for enemies that a person could see and engage in combat. An enemy becomes a candidate only when it is in the player's polygon. It also becomes a candidate when a person can see it on screen. The bot can use this data only after a sampled `latency`.

The model also uses only movement to set the enemy's `active` value. As specified by the `director` on 2026-07-18, the bot must not know internal enemy data. This includes state values and hp. This agrees with the movement information that a person sees.

### Invariants

- An enemy is a candidate when its polygon equals the player's polygon or `visible_ids` contains its id. The `visible_ids` set can only add candidates. A caller without a session does not give this set and receives only polygon candidates.

- The model releases a new candidate only after its sampled `latency`. The range is 0.18 to 0.28 seconds for an id in `anticipated_ids`. It is 0.28 to 0.45 seconds for a different id. `latency_scale` multiplies each sample.

- All random samples come from one `Random(seed)` made at construction. The same seed and snapshot sequence give the same releases.

- A released enemy dictionary contains only `id`, `kind`, `polygon`, `pos`, `hops`, and the calculated `active` value. It contains no state values or hp.

- `active` is `True` when the model saw the enemy cross a polygon boundary during the previous 120 ticks. Speed above 45 world units each second during that period also sets it.

### Verification

- Give the model a snapshot sequence in which an enemy becomes a candidate on a specified tick. Check that release occurs only after the `latency` (`test_human_bot.py::test_perception_model_releases_entity_only_after_sampled_latency`).

- Check that the model releases an id in `visible_ids` from a different polygon (`test_perception_model_widens_to_visible_ids_not_just_polygon_local`).

- Across many samples, check that releases for ids in `anticipated_ids` are faster than releases for other ids (`test_anticipated_reactions_are_faster_than_surprise_reactions`).

- Check that the released dictionary contains no hp or state fields (`test_perception_returns_no_npc_internals`).

- Move an enemy quickly and then stop it. Check that `active` is `True` during movement and `False` after 2 seconds (`test_perception_activity_inferred_from_movement`).

### Implementation

`perceive(snapshot, tick, anticipated_ids, visible_ids)` builds the candidate list. `_forget` then removes records for ids that are no longer candidates. For each new candidate, the model records the tick and samples `latency` from the applicable range, multiplied by `latency_scale`.

For each candidate seen between 1 and 30 previous ticks, the model calculates `active`. A polygon change sets `_active_until` to `tick + 120`. If there is no polygon change, the model calculates speed from the position and tick differences. A speed above 45 sets the same value. It then releases each candidate after the candidate's `latency`. For tests and logs, `ticks_perceivable(eid, tick)` returns the number of ticks since the first candidate tick, or -1.

### Caveats

- An enemy that is no longer in the candidate set becomes a new candidate when it returns. Because `_forget` removed its record, the model samples its `latency` again.

- A released enemy not in the player polygon has a position in that enemy's polygon space. The caller must not compare it with the player position. See `HumanBot._distant_threat_input`.

- The speed check compares positions only when the position records are not more than 30 ticks apart. After a longer interval, the first new position only makes the record again.

- The 120-tick hold keeps `active` on for approximately 2 seconds. This prevents many changes to the value after enemy touch cooldown pauses and slow corner movement.

## The mouse model — `mouse_model.MouseModel`

### Goal

Model player `aim` as a path with speed and acceleration limits. Do not model it as movement that occurs immediately or a line with constant speed. The model keeps position and speed as state and steers the two to the target on each tick. After a large and fast movement, it moves through the target and then corrects back. A small correction stops before the target. Near the target, slow `jitter` always gives the point some movement.

### Invariants

- The `cursor` speed is not more than `max_speed`, and its change on each tick is not more than `max_accel * dt`. At `agility` 1.0, those values are 2200 and 26000 screen units each second in the internal 480 × 270 screen space.

- A target at a distance of more than 120 screen units pulls the `cursor` to a point on the same line. The pull point is at 1.14 times the target distance from the `cursor`. A near target pulls the `cursor` to the target point.

- At a distance of 0.5 screen units or less from the target, speed becomes a small random movement. Its limit is 40 screen units each second.

- All random samples come from one `Random(seed)` made at construction. The same seed gives the same movement.

- `agility` multiplies the speed limit once and the acceleration limit twice. Thus the acceleration limit scales by `agility * agility`.

### Verification

- Step the model to a target far from the `cursor`. Check that the distance moved and the speed change are not more than their limits (`test_human_bot.py::test_mouse_model_never_teleports_velocity_and_accel_are_bounded`).

- Make a large target change. Check that the path moves through the target and then returns (`test_mouse_model_overshoots_on_large_flicks`).

- Hold the target constant. Check that the `cursor` stops near it and then moves slowly at random (`test_mouse_model_settles_near_target_and_drifts_at_rest`).

### Implementation

`step(target_x, target_y, dt)` calculates the distance to the target. Below 0.5, it adds a random sample to speed and clamps the result to the random movement limit. At more distance, it selects the pull point. For a target far from the `cursor`, this point is on the same line at 1.14 times the target distance. It calculates the target speed `max_speed * min(1, distance / 60)` in that direction. It limits the speed change to `max_accel * dt`, clamps speed to `max_speed`, adds `speed * dt` to position, and returns the new position.

### Caveats

- `_overshoot_target` and `_t` are values that no code reads: the constructor and `step` write them, and no code reads them.

- The model starts at its construction point with speed 0. `HumanBot` makes it at the first `aim` target. Thus a run's first `cursor` sample is on that target.

- The code calculates the pull point again each tick from the active distance. The overshoot comes from the speed state, not from a kept point.

## `HumanBot` state and senses — `humanbot.HumanBot.__init__`, `perception`, `_ensure_mouse`, `_apply_flinch`, `_anticipated_ids`, `_visible_enemy_screens`

### Goal

`HumanBot` follows the requirements in `BOT_REALISM_DESIGN.md`. All differences from `AggroBot` occur before the `InputFrame`. It does not read `snapshot["enemies"]` directly, only enemies that `PerceptionModel.perceive` releases after `visibility` and `latency`. Its `aim` comes from the mouse model, not from a calculated angle.

Its seeded streams supply `flinch` and `pressure` state. One value, `skill`, scales 3 player limits: mouse speed, `latency`, and `flinch`. The default of 4.0 gives the calibrated bot.

### Invariants

- One `Random(seed)` supplies seeds for the perception, mouse, `flinch`, `strafe`, and route streams. The streams are isolated. Use of values from one stream does not move a different stream forward.

- `_limit = max(0.25, 4.0 / max(0.5, skill))`. The perception `latency` scale is `_limit`. The mouse `agility` is `1 / _limit`. The `flinch` length and angle scale with `_limit`.

- A damage tick starts a `flinch`. The `aim` angle receives a randomly signed offset of 0.10 to 0.22 `rad` times `_limit` for `max(2, round(6 * _limit))` ticks. When the ticks end, the offset returns to 0.

- The code makes the mouse model at the first `aim` request and puts it at that `aim` point.

- An enemy id goes into `anticipated_ids` when 3 conditions hold. The enemy is in the player's polygon, and the model does not track it. Its direction is also not more than 35 degrees from the previous `aim`. This set comes from the `aim` before the event, not from a special polygon-entry value.

- `_visible_enemy_screens` returns each entity id in `session.visible()` with its screen position. This is the same portal-`visibility` query that the renderer runs for each image. Thus, the code uses the set that a person can see as the screen set. The operation is only a geometry walk and measures far below the `draw` cost.

### Verification

- Run `HumanBot` twice with one seed. Check that the two runs give the same input on each tick (`test_human_bot.py::test_two_identical_human_bot_runs_are_bit_identical`).

- Run two different seeds. Check that their runs are different (`test_different_seeds_produce_different_human_bot_runs`).

- Damage the bot while it `aims`. Check that the `aim` error increases and then returns to its low level (`test_aim_deviates_after_taking_damage_then_recovers`).

- Check that the bot does not fire before the perception `latency` ends (`test_human_bot_never_fires_before_perception_latency_elapses`).

### Implementation

The constructor keeps `skill`, the `diag` dictionary, and the state used by each system in `step`. That state includes `_focus_id`, the `combat` streak, position trail, holds, and `retreat` weight. It also includes the freeze test, travel `aim` movement, `tempo`, and `flinch`. The state includes `medkit` selection and the list of `medkits` that the bot must not select. It also includes the `policy` dictionary. The `policy` defaults are `movement="advance-carefully"`, `risk="normal"`, and `target_priority=None`.

`_apply_flinch` compares hp with the previous tick, starts `flinch` after a decrease, and subtracts 1 from its tick count. It sets the angle to 0 when the count ends. The `perception` property gives the model to tests.

### Caveats

- Code comments record a corrected `flinch` defect: each hit set the angle, but no code cleared it. After the first damage, each projectile thus had a permanent random offset. The code clears the angle after the tick count and corrects the defect.

- After removal of the fire gate that it scaled, `skill` had no effect on bot decisions. Values 4, 7, and 10 gave the same runs in measurements from 2026-07-18. Its connection through `_limit` corrected the defect.

- The comment block above `DEFAULT_SKILL` continues to give information about the removed fire gate. The constant works only through `_limit`.

- The module imports `ENEMIES`, `GROUP_ENEMY`, `GROUP_PLAYER`, and `PLAYER_RADIUS` and uses none of them. The constant `FIRE_ERR` is also not used.

- The module docstring points at `tools/playtest/tactician.py`. The `tactician` module is `game/perihelion/testkit/tactician.py`.

## `HumanBot` step — `humanbot.HumanBot.step`

### Goal

Give the combat-response layer. Threat removal is the highest priority, as specified by the `director` on 2026-07-13. When the bot receives enemy data, all procedures not related to threats stop. Until no threat stays in the perception data, the bot engages the enemy or moves near it. It keeps its weapon raised during this time.

Movement is a `schema` sum, as specified by the `director` on 2026-07-16. Combat, `retreat`, and forward movement each give a screen-space vector. Continuous weights scale those vectors for the threat conditions, and their sum becomes the command.

A small set of `reflex` overrides applies after the sum. These overrides move out of side attacks, push back from doors, and keep `warden` `standoff`. They also prevent projectile contact, move from enemy contact, and break a freeze. Procedures without threats run only when no threat is active.

### Invariants

- Perception means `"on the screen"`, not `"in the same polygon"`. An enemy in view through a door counts before the player crosses the border. The polygon-only gate caused the bot to walk by enemies in full view.

- `Combat` continues across portals, as specified by the `director` on 2026-07-18. A `perceived`, active enemy at a distance below 340 world units can go into the local combat list `co_polygon`. It must also be at hop distance 3 or less. Its position changes to player space. Enemies at a distance of 340 units or more stay on the channel for threats in other polygons. Enemies at more than 3 hops also stay on that channel.

- The bot uses each threat in the `render-visible` set (`director`, 2026-07-27). When a `distant` `perceived` enemy is in that set, the bot points at the nearest one and fires. The `render-visible` set, not a hop count, controls the gate.

- An enemy at touch range overrides the full sum. The bot moves directly back from the contact mass at full speed, and the `aim` stays on the combat.

- The threshold-pause and `look-around` procedures have 3 requirements. No threat is `perceived`, hp is 50 or more, and the last contact occurred more than 3 seconds before this tick.

- `Pressure` counts only enemies with a calculated `active` value of `True`. An idle enemy on screen gives no `pressure`. The bot engages it without movement and does not move back.

- A procedure that gives no movement does not start the `unstick` `jitter`.

### Verification

- Put an enemy in view through a portal but in a different polygon from the player. Check that the bot does not walk by it (`test_human_bot.py::test_human_bot_does_not_run_past_an_enemy_seen_through_a_doorway`).

- Check that no procedure without a threat runs while the perception data contains a threat (`test_rituals_never_fire_while_any_threat_is_perceived`).

- Check that the first view of each `warden` starts a `retreat` response. The same id can start a second response after 10 seconds without that `warden` in view. No id can start more than two responses.

- Check that the `visibility` data agrees with the renderer's query (`test_husk_is_viewport_visible_through_the_portal_before_copolygon`).

### Implementation

Each tick starts when the bot updates `flinch`, uses polygon changes, and starts `look-around` when applicable. On a polygon change, the bot keeps the last 8 polygons as a `retreat` trail. A step to the previous trail polygon removes its last item, while all other steps add one. This lets a `retreat` through many polygons continue through more previous polygons. It does not make a new target of the polygon that the bot left in the previous step.

The bot also keeps the entry doorway midpoint. During a `retreat` hold, it measures depth in polygons because coordinates from different polygon spaces are not comparable. The polygon's bounding box sets its long axis. The first time that the bot is in a polygon starts `look-around`. This does not occur in the `spawn` polygon.

Next, `_visible_enemy_screens`, `_anticipated_ids`, and `perceive` give the `perceived` list. The code divides it into `co_polygon` for the player's polygon and `distant` for all others. Active `distant` enemies go into `co_polygon`: always from adjacent polygons, and from deeper polygons only when they are `render-visible`. `_chain_xf` transforms each added position through at most 3 hops along the router path, and the copy receives `thru=True`. The bot then counts threats, sets `_listen_t = tick + 300` while a threat is live, records kills, and updates `_warden_hunting`.

When `co_polygon` contains threats, the `fight` component sets the procedure tick counts to 0 and increments the streak. It gets the input and `fight` vector from `_combat_input`. Its weight is `min(1, 0.75 + 0.12 * n) * max(0.45, 1 - 0.5 * rg)`. Here, `n` is the number of active local enemies in `hunt` state, and `rg` is the `retreat` weight.

When only threats in different polygons stay, the bot selects the nearest `render-visible` screen position. It `aims` through the mouse model at that position and sets `fire=True`. Weapon selection uses a camera-scaled distance estimate. In a polygon with a short side below 220 world units, selection runs again without the `tau`. If no threat in a different polygon is `render-visible`, `_distant_threat_input` turns only the `aim`.

For the `retreat` component, `_retreat_gain_update` updates `rg`. Above 0.05, the bot selects the best `sentry` field again each 30 ticks, and `ret_vec` points to it.

The doorway `retreat` follows. When the trail contains an item, its start condition latches a hold. The hold lasts 600 ticks for a new `warden` pull or 240 ticks for other starts.

With the default `BOT_FUNNEL_FORM=co`, one of two conditions applies. One is an active local enemy in `hunt` state with hp below the threshold. The other is 3 or more active local enemies in `hunt` state. The hp threshold is 40 in a `warden` `duel` and 65 in other combat conditions. A `duel` contains the `warden` and at most one other active enemy in `hunt` state.

The bot stays in a `duel` because a retreat from a `warden` at its doorway kills no enemy. Such a retreat can loop without end. A local, active `warden` with 4 or more enemies in `hunt` state also latches the hold. The hold is set again to 240 ticks or more when `pursuit` contains 5 or more enemies.

The hold is also set again with 2 or more live `warden` enemies in `hunt` state. The first view of each new `warden` id starts a recoil, limited to two for each id. After 10 seconds without a `warden` in view, ids below that recoil limit are removed from the seen set. They can then start a recoil again.

While the hold is active, a local enemy in `hunt` state sets the `retreat` target to the last trail polygon. A total `pursuit` of 5 or more does the same. The same target applies until the `retreat` crosses two polygons. 3 corrections then apply:

- When enemies are in the trail polygon, the bot falls back to an adjacent polygon. A `warden` counts as 10 enemies. The bot first selects the lowest enemy count, then 2 or more doors, then `visited` polygons.

- During `warden` `pursuit`, a target polygon with a long side below 300 changes to a longer polygon. A short polygon is a route with no exit for a retreat.

- The route turns to the strongest `sentry` field with 5 or more enemies in `pursuit`. An active `warden` `hunt` also causes this turn. The field must be at not more than 8 hops. The turn does not occur when 4 or more enemies are in the polygon through the next doorway.

During the hold, the `retreat` vector goes into the `retreat` channel with `rg` of 0.9 or more. The combat weight is multiplied by 0.55.

For the forward movement `schema`, `_objective_move` supplies the vector. Its weight starts at `max(0.08, 1 - rg - 0.5 * len(co_polygon) - 0.2 * min(3, n_distant))`.

4 conditions give it a lower maximum. Enemies in `hunt` state in different polygons without a local combat cap it at 0.12. The `planted` condition caps it at 0.05. A live `retreat` hold caps it at 0.02. An active `warden` at not more than 3 hops also caps it at 0.02. This lets the pull finish before the objective starts again.

The threshold hold sets the forward movement weight to zero. Without a local combat, the bot examines doorways at a distance below 190 world units in edge sequence. It anchors 60 to 120 units from the first doorway that has one of these conditions:

- The polygon through the doorway contains 3 or more `distant` enemies.

- A `warden` doorway applies the armed condition: hp of 70 or more and `discharge` available. The bot is not armed and has no `medkit` route.

- A doorway with a width below 80 world units leads into `unvisited` polygons. It applies one of two conditions: the same armed condition or the listening wait. During that wait, the bot stays at the doorway because its weapon fire pulls enemies. It waits until it has no threat for 5 seconds.

A doorway to an `unvisited` polygon can set entry caution at a distance below 90 world units. When no hold condition applies, entry caution limits `pace` to 0.5.

A hold breaks after 1500 ticks. The bot moves through the doorway for 900 ticks when its hp is 70 or more. It also moves through after 3 hold cycles when its hp is 40 or more. Otherwise, it walks back for 1400 ticks. Without an active hold, the hold count decreases by 4 and the code does not set it to 0. This decrease makes sure that many doorway changes do not always prevent the breaker.

The sum is `v = fight_gain * fight + RG_W * rg * ret + adv_gain * adv`, where environment key `BOT_RG_W` supplies `RG_W` with a default of 1.15. The listed overrides apply in sequence:

- During a local combat, one steered direction moves the bot out of a side attack. It receives 4 times the sum's weight.

- The boss-door push moves the bot back when it is less than 85 world units from a `warden` doorway. It applies while the bot is in combat or has hp below 90. The threshold hold controls entry, and the push is off during a break window.

- While a local `warden` `hunts`, a push moves the bot back near a doorway to a small polygon. The distance must be less than 75 world units. Its long side is below 300. As a result, the `standoff` push cannot move the bot through this doorway into a route with no exit.

- The entry doorway pull applies during a `warden` combat with 2 or more enemies in `hunt` state. The pull applies at more than 140 world units from the entry doorway. It receives weight 1.3 against 0.5. The enemy group through it gives a risk that enemies move around the bot.

- The `warden` `standoff` applies to each active local `warden` at a distance of 350 world units or less. It pushes the bot in the opposite direction with weight 1.5 against 0.4. A `warden` closes at speed 137 against the bot's 133. It is a free `rail` target at range but causes 10 to 30 hp of damage each second at touch range.

- The projectile response applies to each `spit` that will touch the bot in 0.55 seconds or less. Its lateral distance from the bot must be below 30 world units. It pushes a lateral step from the projectile path. Its weight is 1.6 against 0.45.

- Movement from contact is the highest layer. It starts when an enemy is less than 45 world units from the bot. The bot immediately returns movement at full speed in the direction opposite the inverse-square-weighted contact mass. It keeps its `aim`.

- The freeze breaker activates when a threat is live and movement stays below 8 world units across an 18-tick window. This condition must stay for more than 10 ticks. It then holds a `strafe` steered around terrain for 24 to 42 ticks at a `pace` near 1. It changes a blocked `strafe` to the opposite direction. The breaker reads position and not cause. Thus it catches freezes from the `planted` condition, `schema` vectors that cancel each other, or terrain.

Command length is limited to 1. The `planted` condition caps `pace` at 0.35, and entry caution caps it at 0.5. A strong combat or `retreat` raises it to 0.95 or more. When only the forward movement `schema` is active, its weight becomes its `pace`. The code does not change each command to length 1 because that change erases the caution signal. With an active threat, the function returns at this point and applies `_humanize_move` only when the combat is not local.

Without an active threat, these procedures run: the threshold pause, the `look-around`, the travel `aim`, and the `tempo`. The threshold pause stops, `sweeps` the door, and clears the `unstick` record. The `look-around` uses `pace` times 0.75 and `sweeps` to the front. The `tempo` is a limited random walk on the `pace` in 0.85 to 1.0.

`BOT_SPRINT=1` is a key used only for comparison runs. It sets the forward movement weight to 1.0, clears all holds, and caps `rg` at 0.2. The comparison checks if routes around combat stay possible.

### Caveats

- Defect: the code counts a portal threat added to `co_polygon` twice. The copy operation adds it to `co_polygon` but does not remove the source item from `distant`. Thus, `_threats_total`, `pursuit`, and the count of `warden` enemies in `hunt` state all include it in both lists. One adjacent active `warden` thus activates the `warden`-pair latch (`n_ward_hunt >= 2`) without a second `warden`. `Pressure` counts are also too high by the number of copied threats.

- Defect: the direction that moves the bot out of a side attack is in polygon space. The code adds it to the screen-space `schema` sum without the camera transform. Each other `reflex` transforms its vector with `mat_apply_dir`. When the camera turns, this direction is thus incorrect.

- The `_listen_t` comment states that fire also sets the clock to zero. The code sets it to zero only for `perceived` threats.

- The `render-visible` fire path holds `fire=True` with no error gate, and without the weapon lock of `_combat_input`.

- The code reads the environment keys `BOT_RG_W`, `BOT_FUNNEL_FORM`, and `BOT_SPRINT` each tick. The `BOT_RG_W` read imports `os` through `__import__`, but the module imports `os` at the top.

- The threshold hold uses the first door in edge sequence where a condition applies. A different edge sequence gives a different anchor door.

- The `merge` sets `thru=True` on each `merged` copy. No code reads that value.

- Comments keep measured negative results as a decision record. Corner protection was the most negative result measured by the program. Movement from projectiles across polygons was negative in two tests. Routes with protection on the side were negative. A `retreat` start condition that does not include `mite` counts was negative. A stop for accurate fire was negative in two tests.

## `HumanBot` `combat` — `humanbot.HumanBot._combat_input`, `humanbot.HumanBot._update_flank_escape`

### Goal

Give the combat procedure. The `director` specified the fire `policy` on 2026-07-16. It points at the nearest enemy that a person can see and fires continuously. A small `hysteresis` prevents target changes on each tick. An enemy at touch range has higher priority than each other target.

Movement keeps range bands for each enemy type and moves to a `medkit` during combat. It also moves out of side attacks or groups around the bot. All decisions use only the `perceived` list. Thus weapon selection, target selection, and movement from threats use only enemies that the bot can see.

### Invariants

- The target is the nearest enemy in the target pool, with target-lock `hysteresis`. The bot keeps the lock while the target distance is at most 1.15 times the nearest distance. Without this condition, two enemies at the same distance can change between nearest on each tick. The `cursor` then does not stop at one target.

- 3 or more active enemies in `hunt` state other than a `warden` can be less than 200 world units from the bot. Then the code removes the `warden` from the target pool. A standard `warden` has 168 hp and can absorb many projectiles while `mite` enemies with low hp make contact. A `warden` at a distance of 140 world units or less is always a target.

  With the `rail` selected, the nearest `warden` at 420 world units or less can become the target. This occurs only when less than 4 enemies in `hunt` state are near the bot. Because the `rail` goes through 3 bodies, its line can also kill smaller enemies in front of the `warden`.

- The bot fires when the target is at most two hops from it. It holds fire at more hops because the renderer does not show that polygon clearly at zoom 0.45. There is no `aim` error gate. The mouse model supplies the `aim`, and projectiles that do not hit while the `cursor` moves model player error.

- The `aim` point is 50 or more world units along the `aim` direction. Before addition of this condition, the `cursor` at touch distance was only pixels from the player. A small error could then give a random direction. In that version, 81 percent of projectiles occurred below 30 world units.

- A weapon change locks selection for 120 ticks. The lock opens when the selected weapon has no `ammo`. It also opens when an enemy is less than 60 world units from the bot. The `lightning` condition bypasses the lock.

- Below 40 `cell`, while other `ammo` stays, the bot does not select the `tau`. `cell` ammunition is kept for boss combat because approximately 13 `rail` projectiles kill each `warden`. The bot also does not select the `tau` when the polygon's short side is below 220 world units. Its projectiles bounce off walls. Projectiles that return from walls caused 39 to 43 percent of all measured damage to the bot.

- Geometry controls `discharge`, not general threat level. The condition includes 4 or more `perceived` enemies at a distance of 150 world units or less. It also includes one enemy at 45 or less, or a `warden` at 120 or less. It does not fire while the `tau` is selected because `alt` controls the `tau` and not `discharge` in that state.

### Verification

- Put two enemies at the same screen distance. Check that the `cursor` does not change between them on many ticks.

- Put a `warden` and 4 `mite` enemies in the polygon. Check that the bot kills the `mite` enemies first. Give the bot the `rail` and check that the `warden` becomes the target.

- Put enemies on two sides of a bot in a doorway with a small width. Check that the bot moves through the weaker side (`test_human_bot.py::test_flank_escape_commits_through_the_weaker_side`, `test_flanked_choke_is_survived_and_escape_engages`).

### Implementation

The function calculates the target pool, target lock, `aim` angle, and mouse-model `cursor`. The `aim` angle is the correct angle plus the `flinch` offset. It then selects a weapon with `choose_weapon` from the `perceived` list.

A second selection without the `tau` applies the kept `cell` quantity and the condition for a short polygon. The function then applies the `lightning` condition of 5 or more `perceived` enemies. It also applies the 12-tick `hysteresis` and the 120-tick lock. Movement uses the first applicable condition:

- This response applies with hp below 65 and a target more than 40 world units from the bot. A `medkit` must also be in the polygon at a distance of 320 units or less. Move to the `medkit` and keep `aim` on the target.

- During a live response to an attack from the side, steer the kept movement direction around terrain.

- The `knife`: close.

- Against a `warden` or `brute`, use a ranged `duel`: retreat below 170 world units, close above 260, and `strafe` between those distances. The `strafe` direction stays latched until the freeze breaker changes it. If the bot turns in the direction opposite a heavy enemy, it can receive `spit` damage across 3 polygons. The bot thus holds the `rail` band and continues to fire.

- An idle target with hp of 30 or more activates the `planted` condition. The bot stays in one position and kills the free target. Movement previously pulled it off the target and back through the doorway.

- This condition applies when distance is below 80 or hp is below 30. The bot finds 2 or more melee enemies at a distance of 110 world units or less. It moves through the largest free space between them. It keeps `aim` on the target. Against one enemy, it moves in the direction opposite that enemy while it fires.

- Above distance 140, a melee enemy that moves near receives only a `strafe`. The bot stays and lets the enemy cross its fire. A previous retreat moved the bot back through the portal that it crossed on the previous tick. This started the combat again. The bot closes on each other enemy type.

- Otherwise, move back with a `strafe` that has a 0.55 component in the direction opposite melee types. Add `jitter` that increases with `pressure`, and change sides with probability 0.02.

`_update_flank_escape` runs first on each `combat` tick. One start condition is 6 or more threats at a distance of 170 world units or less and hp below 65. It starts movement for 90 to 140 ticks in the direction opposite the inverse-square threat mass. The code changes this direction to the polygon's long axis. Thus the bot moves along a `corridor` in the direction opposite the threats and not into a wall.

A second condition starts movement for 50 to 80 ticks through the weaker side. It applies with 2 or more threats, hp below 70, and a threat arc of 2.2 `rad` or more. When the threat mass is balanced, the bot moves in the direction opposite the nearest threat.

### Caveats

- The `perceived` list includes portal copies added by `step`. Thus, movement from an attack on the side uses a `warden` through a portal as a local enemy. The range bands also use it as a local enemy. This is a specified condition. In the recorded death, a `warden` caused touch damage from the far side of a portal. Each `reflex` did not include it.

- The fire gate reads `hops` with a default of 0: an entry without the field counts as the player polygon.

- The gate for `warden` `enrage` was removed with internal enemy state reads because it read the `warden` hp. The `enrage` sound is the signal for a person, and the bot cannot hear. If the bot can hear in a subsequent version, that gate returns there.

## `HumanBot` navigation — `_objective_move`, `_nav_exit_move`, `_nav_polygon_move`, `_portal_goal`, `_steer_target`, `_best_field`, `_retreat_gain_update`

### Goal

Move to the objective and go around terrain. The objective is a `medkit` at low hp or `ammo` when pools are low. If no previous condition applies, the objective is the exit. The functions in `bots.py` steer in a straight line. They can stay blocked by terrain for many seconds, but a person walks around a terrain object. `_steer_target` routes around terrain rectangles corner by corner.

`_portal_goal` aims through a portal and not at it. The edge midpoint does not work because the polygon and target change when the bot crosses. After that tick, the bot can move along the portal line without a crossing. `_best_field` selects the `sentry` field for `retreat`. `_retreat_gain_update` continuously adjusts the weight of combat that turns against the bot.

### Invariants

- The `medkit` search range increases as the number of threats decreases. It is 3 hops with a live threat and 6 without one. During a break window with low hp, it is 12 hops.

- The hp threshold is 60, or 75 during a break window. With a `medkit` in the player's polygon, it is 70. Because the simulation's pickup threshold is 70, a bot threshold above 70 causes a loop without end.

- While a `warden` `hunts`, the bot does not go into a polygon with one door for a `medkit`. Two recorded deaths occurred in such small polygons. The `medkit` was near the bot but through a doorway that contained the `warden`.

- A bot can move to a `medkit` for 8 seconds without a pickup. That `medkit` goes on the list of items that the bot must not select for 30 seconds.

- Low ammunition pools change the route with the same conditions as `medkits`. Thresholds are `9mm` below 90, `shell` below 14, and `cell` below 30. The range is 6 hops without a live threat and 3 with a live threat.

- `_retreat_gain_update` increases quickly on bad signals and decreases slowly. Its step to the target level is 0.08 as the value increases. It is 0.035 when kills are more than new threats and 0.012 with other conditions.

- Bad signals include more new threats than kills during a long combat with 3 or more threats. This sets the target level to 0.6. An active `warden` `hunt` sets it to 0.85. Hp below 45 with 2 or more threats sets it to 0.5.

- A `retreat` weight above 0.5 without a kill for 15 seconds means that the combat has no progress. It also means that the enemies do not move near. The code sets the weight to zero, and a 10-second cooldown prevents a new increase.

- `_best_field` scores a seen `sentry` field as 3 points for each weapon minus hop distance. A long polygon adds 3 points. A route with no exit and 3 or more live threats subtracts 8. Seen means `visited` or through one doorway from a `visited` polygon. The hop limit is 8 during a `warden` `hunt` and 6 at other times.

### Verification

- Put a terrain rectangle between the bot and the exit. Check that the bot walks around it without `unstick` `jitter`.

- Set hp to 50 with a `medkit` at 5 hops and no threat. Check that the bot collects it.

- Put the only `medkit` in a polygon with one door and an active `warden` in view. Check that the bot does not go into that polygon.

### Implementation

`_objective_move` applies the `medkit` conditions, then the `ammo` conditions, and `_nav_exit_move` last. A target in a different polygon routes through `next_edge` and `_portal_goal`, with `_steer_target` steering each segment. `_steer_target` applies a `Liang-Barsky` segment test against each terrain rectangle expanded by 0.7 times the 9-unit clearance. When blocked, it selects the corner with a clearance offset to which the bot has the shortest total route. This process runs on each tick and routes around fields of rectangles one corner at a time.

`_portal_goal` is 40 world units through the edge midpoint in the direction opposite the polygon center. `_nav_polygon_move` travels to a target polygon and then anchors at its nearest `sentry`. It stops at a distance of 34 world units or less. This keeps it in the field to fire. Below 60 hp, it first collects a `medkit` in the field polygon. `_nav_exit_move` uses `nav_to_exit` and terrain steering together.

### Caveats

- The list of items that the bot must not select is necessary because terrain blocks routes to some `medkits`. This previously caused the bot to move in a circle without end.

- `_best_field` expanded "seen" to include a polygon through one doorway from a `visited` polygon. This is necessary because `sentry` fields in small polygons are not on the route through the `corridors`. Previously, logs reported many ticks without a seen field when a field polygon was one doorway from the trail.

- The condition for combat with no progress was necessary for the first full clear. A bot in combat without a kill walks forward again.

## `HumanBot` rituals and travel `aim` — `_travel_aim`, `_distant_threat_input`, `_sweep_aim`, `_humanize_move`, `_maybe_start_threshold_pause`

### Goal

Add the visual properties that show the difference between player and system movement. The `judge` identified a `cursor` held at screen center or on the movement vector as a sign of system movement. Without movement, this bot's `cursor` stays in front of the movement direction with a radius and offset that change. A `distant` threat receives a rough look and not accurate continuous `aim`.

The first doorway into `unvisited` polygons receives a short pause and `sweep`. Movement also gains `wobble` in its direction and a wall-side entry push after the pause. It gains lower `pace` on sharp turns.

### Invariants

- The travel `aim` stays in front of the movement at a radius that changes from 45 to 115 world units. Its offset changes in ±45 by ±35. With no movement, it is near the center plus the offset.

- `_distant_threat_input` does not fire. Its `aim` is the screen position of the target plus a limited random offset of ±30 world units. The movement keeps the objective route.

- A threshold pause starts at most once for each `(polygon, edge)`. It starts only at a distance of 42 world units or less from a doorway into an `unvisited` polygon. It lasts 8 to 16 ticks. `Look-around` lasts 12 to 22 ticks at 0.75 `pace`. The pause and `sweep` end immediately when the bot receives threat perception data.

- The direction `wobble` is a limited random walk of ±0.16 `rad`. A turn sharper than approximately 60 degrees decreases the `pace` to 0.75. The entry push adds 0.45 to the side for 14 ticks after a pause.

- The pause and `sweep` durations were made shorter together after the `director` called the bot `"way too hesitant to move"` on 2026-07-13. The previous pauses of 0.47 to 0.92 seconds were too long. These values give a short stop.

### Verification

- Check that the bot pauses at the threshold of a polygon it has not `visited` (`test_human_bot.py::test_human_bot_pauses_at_the_threshold_of_an_unexplored_polygon`).

- Check that the `aim` `sweeps` at the threshold (`test_human_bot_sweeps_aim_at_the_threshold`).

- Check that the direction from `HumanBot` changes by `wobble` while the direction from `AggroBot` does not (`test_human_bot_heading_wobbles_but_aggro_bot_does_not`).

### Implementation

`_travel_aim` changes the random offset and radius on each tick and returns a point in front of movement. `_distant_threat_input` selects the `distant` enemy with the smallest number of hops, with id as the tiebreaker. Hop count can compare distances across polygons, while distance measured directly cannot. The function reads that enemy's screen position from the view set and adds a random look offset. It then steps the mouse model to that position.

`_sweep_aim` moves `aim` through a ±0.9-`rad` arc around the center direction at a distance of 120 world units. Its phase step is 0.11. It records the world angle for the test that builds `anticipated_ids`.

`_humanize_move` applies the entry push, `wobble` in the direction, and a lower speed on sharp turns. It sets `pace` to 0.75 when `cos` is below 0.5. It keeps the movement for the next tick's turn test. `_maybe_start_threshold_pause` checks doorways and starts the pause, `sweep` phase, and entry push side.

### Caveats

- The `_distant_threat_input` docstring gives information that no weapon hit test connects different polygons. That information is no longer correct: since 2026-07-27, `step` fires through portals at `render-visible` enemies. The function applies only to `distant` threats not in that set, at which the bot correctly does not fire.

- The code adds a random look offset because of a result for seed 401 on 2026-07-13. The `judge` called accurate `aim` on a doorway threat `"aimbot-style instant target acquisition"`. The bot does not fire on that channel, and accurate continuous `aim` does not help.

## The `tactician` — `tactician.Tactician`

### Goal

Give the decision layer from section 7 of `BOT_REALISM_DESIGN.md`: `policy` `consults` after events, with a rate limit, for one `HumanBot`. This models a player who pauses to think. Each `consult` sends a `JSON` `digest` of the conditions to `claude -p`. It uses the headless CLI and `sonnet` model, then parses the result into `HumanBot.policy`. The model sets `policy` and not input values. Thus it is not in the `reflex` loop.

A `consult` with an error keeps the previous `policy` and always records its cause. A `null` `policy` without a recorded cause is an error without a report. `--bot human` runs without this module, while `--bot human --tactician` turns it on.

### Invariants

- `Consult` causes have a priority sequence. They are run start, entry into a new polygon, and an hp drop below 40 percent. The last cause is 45 seconds without a new polygon.

- At most one `consult` occurs in each 25 seconds of wall time. A cause that starts during the wait window is dropped and is not kept for a subsequent tick.

- The `policy` `filter` keeps only `movement`, `risk`, `target_priority`, and `intent`. `movement` must be one of 6 permitted values, and `risk` one of 3. An incorrect value removes its key. If the result after the `filter` is empty, the operation is an error and the previous `policy` stays.

- Each `consult` adds a record with the tick, cause, `digest`, `policy`, and error to `self.log`. When the caller supplies `on_consult`, the same record also goes to that callback.

### Verification

- Run `maybe_consult` on the first tick. Check that the cause is `run-start`.

- Supply a result with incorrect `movement` and correct `risk`. Check that only `risk` changes the `policy`.

- Remove the `claude` CLI from the path. Check that the record contains the error and the `policy` does not change.

### Implementation

`maybe_consult(snapshot, session, tick, now=None)` runs once on each simulation tick. It finds the `consult` cause, records polygon and hp state, and then applies the rate limit. The `digest` contains the cause, tick, polygon, hp, `max_hp`, weapons, and `ammo`. It also contains enemy counts for each type at zero hops, exit hold state, and active `policy`.

`_consult` runs `subprocess.run(["claude", "-p", prompt, "--model", self.model, "--output-format", "json"], timeout=45)`. A timeout, missing CLI, nonzero exit code, or malformed `JSON` each becomes a `(None, error)` pair. The code reads the `result` field from the outer CLI `JSON` object. It then gets the `policy` object from that field.

### Caveats

- Defect: `subprocess.run` blocks the caller's thread for 45 seconds or less. The program calls `maybe_consult` from the primary loop. Thus, a slow `consult` blocks that loop. This does not agree with the requirement that it must not block the loop.

- Defect: no code reads `HumanBot.policy`. The constructor writes defaults and the `tactician` writes updates, but the `reflex` layer does not use them. A `consult` thus changes only the log and `digest`. The model thus does not set bot `policy`.

- `target_priority` and `intent` go through the `filter` with no value checks.

- The rate limit uses wall time (`time.monotonic`) and not simulation time. A headless run faster than the simulation clock receives a smaller number of `consults` in each simulated 60 seconds.

- The constructor makes `self.rng`, but no code reads it. `_build_digest` also does not use its `session` input.

- The `digest` counts only enemies at zero hops. The model does not see a threat at one hop.

## The calibration `loadout` — `loadouts.FULL_LOADOUT`

### Goal

Give one source `loadout` for calibration and test runs. On 2026-07-16, the `director` requested all weapons to make it possible for the player to complete the run. `tune_pass_rate`, `run_farm`, and the program's `--loadout` flag must all import these values. This makes recorded runs and `run_farm` runs use the same numbers.

### Invariants

- The `loadout` contains all 8 weapons: `knife`, `pistol`, `smg`, `shotgun`, `rail`, `lightning`, `tau`, and `hole`. Its ammunition counts are 400 `9mm`, 80 `shell`, and 120 `cell`. Its hp and `max_hp` are 100, and its damage factor is 1.0.

### Verification

- Check that each consumer—`app.py`, `farm_record.py`, `replay_study.py`, and the tests—imports `FULL_LOADOUT` and contains no local copy of these values.

### Implementation

The module contains one dictionary constant. Consumers receive a copy through `dict(...)` or `copy.deepcopy` before use.

### Caveats

- The module state in the constant can change. Each consumer in the repository copies it. If a consumer writes to the constant directly, it changes the data for each subsequent run in the same process.

## The replay — `replay.Replay`, `replay.record`, `replay.play`

### Goal

Give deterministic record and playback for sessions that use the default player state, difficulty, screen dimensions, zoom, and tick schedule. A `Replay` contains the level as a dictionary or path, the seed, and the row from `InputFrame.pack` for each tick. It contains no other session inputs. With these defaults, playback gives the same run through `GameSession.tick`.

### Invariants

- `record` runs the session with quantized rows: it adds the row from `inp.pack()` and ticks with `InputFrame.unpack(row)`. `pack` changes `mx` and `my` to the nearest increment of 0.0001. It changes `ax` and `ay` to the nearest increment of 0.01. Physics can make a small difference larger and give a different run during the first 1000 ticks. Thus recording must use the same rows as playback.

- For sessions made with default values, `play(record(...)[1])` ends in the same state as the recorded run.

- A `Replay` without a level source raises `ValueError` at construction. `record` also raises without one.

- `save` writes `JSON` text in `gzip` format, and `load` returns the same data.

### Verification

- Record an `AggroBot` run, play it back, and compare the last metrics, position, hp, and tick count (`test_testkit.py::test_replay_record_play_roundtrip_identical_final_state`).

- Write a replay, load it, and compare all fields (`test_replay_save_load_gzip_roundtrip`).

### Implementation

`record(session_factory, input_source, max_ticks, *, level_path=None, level_dict=None, meta=None)` makes the session and loops. On each tick, `input_source(session, tick)` supplies a frame. The row from `pack` goes into `replay.frames`, and the session ticks with `InputFrame.unpack(row)`. The loop ends at `max_ticks`, death, or when the bot completes the level.

The function then writes `ticks` and `outcome` into `meta` through `setdefault`. It does not change values supplied by the caller. It returns `(session, replay)`.

The caller must identify the level through `level_path` or `level_dict`. A `GameSession` contains only the prepared `Level` object, not its `JSON` source. Thus the caller must supply the source necessary for playback. `Replay.level()` uses `level_dict` when it is available. `play(replay, screen=(480, 270), zoom=0.45)` makes a new `GameSession(level, seed, screen, zoom)` and ticks each row until death or until the bot completes the level. It then returns `(session, session.metrics)`.

### Caveats

- Defect: a `Replay` contains no player state, difficulty, screen dimensions, or zoom. `play` makes the session with defaults. Thus, a run recorded by a `factory` with a different `loadout`, difficulty, or screen dimensions plays back differently. This does not agree with the stated goal. Only tests call `record` in this repository, and they use default sessions. Thus the defect has no effect on these tests.

- `play` stops at death or when the bot completes the level if the file contains more rows. `record` writes no rows after that point. Thus this condition applies only to files from other sources.

## The `perf` module — `perf.py`

### Goal

Measure the performance of the 4 world shapes with the highest cost from section 5 of `ENGINE_DESIGN.md`. The hub has 8 `corridor` loops and many portals open at the same time. The mirror polygon connects opposite edges and makes `visibility` depth have no limit. The grid has 40 polygons and adds load to collision and routing. A `corridor` of 2 polygons with no end is the other depth shape.

`AggroBot` operates each world. One timer samples wall time for `session.tick()` on each tick. A different timer samples it for `session.visible(14, 96)`. The command entry prints the table and reports each budget failure.

### Invariants

- The limits are `tick_p90` below 2.5 ms and `visible_p90` below 3.0 ms. Each comparison uses twice the stated value to absorb noise in test systems.

- Each world builder is a pure function that returns the same level on each call. The measurement seed defaults to 1, and its run length defaults to 600 ticks.

- At death or when the bot completes the level, the performance run starts a new session with a new bot. It continues to collect samples.

- The module entry exits with code 1 and one `BUDGET FAIL` line for each failure. With no failure it prints `all perf budgets OK` and exits 0.

### Verification

- Run `uv run python -m game.perihelion.testkit.perf`. Check that the table prints and that the exit code agrees with the budget result.

- `test_testkit.py::test_perf_budgets_fast_subset` and `test_perf_budgets_full_suite` run the module in the tests.

- `test_radial_hub_world_is_well_formed` examines the hub geometry.

### Implementation

The 4 `build_*` functions use `LevelBuilder`. The hub is an 8-sided polygon. Each edge connects to a 3-polygon `corridor`. It closes into a different loop and does not return through the hub. Each `corridor` polygon contains a `husk`. The mirror world is one 300 × 300 rectangle with opposite edges connected and 6 `mite` entities.

The grid contains 8 by 5 cells of 140 world units, each connected to the cell on its right and below. Each cell with `index % 5 == 0` contains a `husk`, and the player starts in the center cell. The `corridor` world contains two long rectangles connected end to end in the two directions and 4 `mite` entities.

`_bench_world` samples the times of the two operations on each tick and sorts their samples. It returns `p50`, `p90`, and maximum values for each. A percentile between two samples uses linear interpolation. `run_perf_suite` builds and measures each world, then prints the table. `assert_perf_budgets` compares the `p90` values and returns the error list.

### Caveats

- The `visible(14, 96)` query adds work after each tick. The performance test measures the two operations as different values. The view query cost is not part of the tick limit.

- The builder accepts `canvas` positions for entities and the player, not polygon-local offsets. Each builder adds the polygon origin again, and code comments note this in two puts.

- Wall-time samples are different on each system. The margin of 2 absorbs noise in tests. A different process that does much work on the same system can cause a failure.

## The synthetic mind map — `graphs.synthetic_mindmap`

### Goal

Give a fixture for requirements checks and tests at the target scale. In the second inspection, the `director` specified `"hundreds, maybe _thousands_ of vertices"`. `data/mindmap.json` contains a 33-node instance of the same structure from the initial version. That instance is too small to check the local camera view and label results at the target scale.

The generator makes a deterministic graph with one rooted node structure in each region. It gives one or two entries in `prereqs` for each node. It also gives a large depth and labels selected from the source map's text set. It does not change `data/` and does not use level data from the program.

### Invariants

- The output is a pure function of `(n_nodes, seed, regions)`. It gives the same graph on each system and run.

- Each node other than a root has one or two ids in `prereqs`. They come from previous nodes in the same region. The graph thus contains no cycles, and its regions stay easy to read as areas at scale.

- The code usually selects a `parent` from nodes added near the end. When a region has more than 3 nodes, the `parent` comes from its newest 35 percent with probability 0.7. This gives a large depth, approximately 8 to 12 levels at 400 nodes. It does not make a flat graph with one center.

- A node can receive a second id in `prereqs` with probability 0.2. Its region must contain more than one node, and the selected id must be different from its `parent`.

- Labels contain one to 4 text items with weights `1:4:4:2`. Items come from a 50-entry list with the same text as the source map.

### Verification

- Call the function twice with one seed. Check that the outputs are equal.

- Call it with `n_nodes=400`. Check that each id in `prereqs` points to a node added before it in the same region. Check that depth is 8 or more.

### Implementation

Node ids start at `s0000`. Each region's first node is its root. The first `len(regions)` nodes cycle through the regions in sequence, and each subsequent node selects a random region. Each node dictionary contains `id`, `region`, `label`, `prereqs`, and a constant cost of 1 component and 0 data. It also contains `faith` 0, `unlock` set to `None`, and empty `blurb` and `brief` text.

### Caveats

- A label can contain the same text item twice. Each selection uses the full list and does not use the previous selection.

- When `regions` contains more items than `n_nodes`, the remaining regions receive no nodes.
