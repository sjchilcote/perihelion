---
This specfile includes all Python files in `tools/playtest/`, and the state of `tools/dialogue/`.
---

# The `playtest` instruments

This file contains requirements for the Python code in `tools/playtest/`. These test tools run the simulation without a window, record frames, and examine the recordings. They are not part of the simulation that a player operates. Simulation code is in the `perihelion` package in `game/` and the Rust engine `necore`. The repository installs `perihelion` as a package. Thus, its import results with `uv run` are the same for each start directory.

Conventions for all tools:

- The simulation runs at 60 ticks each second.

- A recording directory contains `frame_%06d.png` images and `events.jsonl` audio taps. Some tools also write `trace.jsonl` simulation records or `inputs.jsonl` with input for each tick.

- Most tools put `<repo>/game` at the front of `sys.path` before the `perihelion` imports. `run.py` does not. It uses the installed package.

- Play, recording, and batch runs all use zoom `0.45`, as specified by the user on 2026-07-28.

- Gate recordings in `out/eval_gate/` use constant seeds 2, 4, 7, and 11.

Some files in `tools/playtest/` are not Python code. They are not units of this file: `gate.sh`, `gate_wait.sh`, `GATE_PROMPT.md`, `FRAME_REVIEW_RUBRIC.md`, `cost_log.json`, `judge_out/`, and `parity_out/`.

This file includes 31 Python files in 9 groups, plus one record about
`tools/dialogue/`. The 3 sections for `mkvideo.py` are 3 units in one file.
The gate 55 section includes 3 Python files.

- Runs and campaigns: the headless `playtest` run (`run.py`). The campaign run (`campaign_run.py`). The campaign `soak` (`stream_soak.py`). The `batch` recording tool (`farm_record.py`).

- `Trace` check: the `trace` structure test (`trace_check.py`). The `coordination` live test (`coord_trace_check.py`). The gate 55 A2 check (3 files).

- More `trace` checks: the return audio audit (`audit_return_audio.py`). The `ground truth` tool (`ground_truth.py`). The replay check (`replay_study.py`).

- Image check: the `frame` sample tool (`framecheck.py`). The camera phase test (`camera_phase_check.py`). The `pixel` `oscillation` `scan` (`flicker_scan.py`). The flicker crossing `harness` (`flicker_cross.py`).

- More image checks: the movement image tool (`ghost.py`), the inspection `scan` (`attention_scan.py`), and the inspection `score` (`score_attention.py`).

- `Judges`: the person `judge` (`human_judge.py`). The audio `judge` (`audio_judge.py`).

- Light demos: the light `preview` (`light_preview.py`). The light occlusion demo (`light_occlusion_demo.py`). The terrain shadow demo (`terrain_shadow_demo.py`).

- More demos: the `lurker` demo (`flicker_lurker_demo.py`). The `feature` demo (`feature_demo.py`). The tint probe (`probe_arrival_tint.py`). The `marrow` demo (`marrow_demo.py`). The `marrow` `batch` (`marrow_farm.py`).

- Video output: the sound mix, the telemetry overlay, and the CLI of `mkvideo.py`. The `bundle` tool (`submit.py`).

## The headless `playtest` run — `run.py`

### Goal

Run one deterministic bot on one level without a window or user input and print a JSON result to standard output. A model or `CI` process uses this entry point to check if the bot can complete the level. With `--gif`, the tool also records frames and makes a `GIF` animation.

### Invariants

- The simulation result is deterministic for a given level file, bot, seed,
  and maximum tick count. Recording flags and if the renderer is available can change
  the `JSON` recording result. They do not select bot input or the simulated result.

- The exit code is 0 only when the `outcome` is `complete`. All other results give exit code 1.

- The tool does not install Pillow if Pillow is not available. Without Pillow, recorded PNG frames stay on disk and the report gives information about that result.

### Verification

- Run `uv run python tools/playtest/run.py --level levels/smoke_4polygon.json --bot aggro --seed 3`. Make sure that standard output contains one JSON object and that the exit code agrees with `outcome`.

- Run the same command with `--gif` on a system with Pillow. Make sure that `gif.status` is `ok` and that the `GIF` is on disk.

- Run without Pillow and make sure that `gif.status` is `pil_missing` and the report includes the frame count and directory.

### Implementation

The tool has 5 bots from `perihelion.testkit`: `aggro`, `steady`, `pacifist`, `camper`, and `explorer`. Its necessary flag is `--level`. The defaults are `aggro` for `--bot`, 0 for `--seed`, and 18,000 for `--max-ticks`. Other flags are `--gif`, `--capture-every` with default 6, and `--capture-dir`. A `GIF` run without `--capture-dir` makes a temporary directory.

The tool reads the level, makes the seeded bot, and calls `run_bot` with the recording configuration. Without `--gif`, `capture_every` is 0 and no frames are recorded. `summarize(res)` makes the report.

With `--gif`, `_finish_gif` adds a `gif` entry to the report. Its `status` values:

- `no_capture_dir` — no recording directory was set.

- `skipped` — the run returned `capture_skipped` because `perihelion.render` could not be imported or renderer construction raised an error.

- `no_frames` — the directory has no `frame_*.png` files.

- `pil_missing` — `Pillow` does not import. The entry holds the `frame` count and a note.

- `ok` — Pillow wrote `playtest.gif` with 100 ms for each frame and a continuous loop. The entry contains the `GIF` path and frame count.

For the values `skipped`, `pil_missing`, and `no_frames`, the tool also prints one line to stderr.

### Caveats

- `Pillow` is not a repository `dependency`. The docstring records this decision.

- Recording is optional in the harness. If the renderer is not available or raises an error, the simulation can complete and the report states that no recording occurred.

- This is the only tool in the directory that does not change `sys.path`. It must use the installed `perihelion` package from `uv run`.

## The campaign run — `campaign_run.py`

### Goal

Measure campaign results with the simulation's continuity operation. Player health, ammunition, and weapons stay across levels. Health at the next level is clamped to 40 or more. Death retries the same level from its entry state, and `MAX_RETRIES` failures on one level end the run. This is the primary campaign-difficulty instrument.

### Invariants

- A `retry` of a level always starts from the entry state of that level, not from the state at death.

- After a level completes, health for the next level is 40 or more.

- The result has one row for each level that was tried.

### Verification

- Run `uv run python tools/playtest/campaign_run.py --seed 1 --bot aggro`. Make sure that each level prints tries, result, time, kills, health, ammunition, and weapon count. The run must end with `CAMPAIGN CLEARED` or `CAMPAIGN FAILED at L<n>` and a total try count.

### Implementation

`MAX_RETRIES` is 6, and `MAX_TICKS` is 25200 (420 seconds). The available bots are `aggro`, `pacifist`, and `explorer`. The tool reads `levels/campaign.json` and walks its `levels` list in sequence.

For each level, the entry state is a copy of the state from the previous level or `None` for the first level. Each try makes a bot with seed `seed * 1000 + level_index * 17 + attempts` and a `GameSession` with seed `seed + attempts` and the constant entry state. `run_level` updates the session until death, a complete level, or `MAX_TICKS`.

When a level completes, state for the next level contains `hp`, `ammo`, `weapons`, `weapon`, `holes`, and `cloister`. The tool does not change the `cloister` value. Health is clamped to 40 or more. After `MAX_RETRIES` tries without a complete level, the campaign ends. The result row uses measurements from the last try.

### Caveats

- The session seed changes on each try (`seed + attempts`). A `retry` replays the same level and entry state, but not the same random sequence.

- `MAX_TICKS` here is 25200. The campaign `soak` uses a different limit. Thus, the two tools do not use the same constant.

- When the campaign ends at a level, the printed numbers of that level come from the last try.

- The CLI accepts `--seed` as an integer and `--bot` as text. The bot text must be `aggro`, `pacifist`, or `explorer`. Different text causes a `KeyError` and a traceback.

- Defect: the CLI does not give `cleared` to `SystemExit`. It prints the campaign verdict and total try count but exits with `status` 0 after a satisfactory result and a failure.

- Decision open (see `spec/open-questions.md`, item `PLAYTEST-CAMPAIGN-EXIT`):
  the user has not selected if campaign failure must return a nonzero exit `status`.

## The campaign soak — `stream_soak.py`

### Goal

Play the continuous 10-chunk campaign with `AggroBot` and `cold-restore` respawns. This gate supplied the measurements used for difficulty floors. It prints one line for each seed with result, ticks, deaths, kills, last component count, and maximum component count.

### Invariants

- A seed has a satisfactory result only when the campaign completes before the tick limit.

- The exit code is 0 only when all seeds complete.

### Verification

- Run `uv run python tools/playtest/stream_soak.py --seeds 23 --max-ticks 200000`. Make sure that the seed prints one result line, followed by `PASS (0 incomplete)` or `FAIL (n incomplete)`, and that the exit code agrees.

### Implementation

Flags are `--seeds` (default `23,2175,7,101,4242`), `--hard`, and `--max-ticks` (default 200000). The tool reads the campaign level list, makes a `GameSession` on its first level, and makes a `WorldStreamer` for all level paths. Difficulty is `hard` when `--hard` is set and `normal` when it is not set.

The loop runs until the campaign ends or the tick limit. On death, it calls `ws.respawn()` and continues. Each step gives the bot a snapshot, updates the session with the bot's input, and updates the streamer. The maximum `components` value across snapshots is the maximum component count. The result line contains result, ticks, deaths, kills, active chunk, maximum component count, and last component count.

### Caveats

- `campaign_paths` opens `levels/campaign.json` and does not close it. The file closes when Python frees the object.

- The default tick limit (200000) is not the limit of the campaign run tool.

## The `batch` recording tool — `farm_record.py`

### Goal

Record frames and audio taps from the batch simulation path. The previous simulation recording path does more work: it reads terminals, updates the streamer, and pushes overlays. Seed 7095 completed through `tune_pass_rate.one()` but ended in death 4 times in a simulation recording. This tool thus runs the `one()` loop with the same session construction and bot operation.

Frame output and audio-tap records for `mkvideo` do not change the simulation.

### Invariants

- Simulation uses the batch path without a change to it. The renderer, audio tap, and music system read simulation state but do not change it.

- Audio `tap` times are in seconds of recording time (ticks divided by 60).

### Verification

- Run `uv run python tools/playtest/farm_record.py 7095 out/farm7095 --every 4`. Make sure that it writes `frames` and `events.jsonl` and that the last line prints ticks, `frames`, `outcome`, and kills.

- Compare the `outcome` with `tune_pass_rate.one()` for the same seed and level. The results must agree.

### Implementation

Arguments are `seed`, `out`, `--level` (default `levels/gauntlet_cal3.json`), `--every` (default 4), `--max-ticks` (default 64800), and `--skill`. The default for `--skill` is the bot's default `skill`.

Session construction copies `FULL_LOADOUT` and sets `max_hp` and `hp` to the `loadout` maximum. It sets `dmg_taken_mul` to `1.0` and makes a `GameSession` with a `640 x 360` screen at zoom `0.45`. The level gives the value for `session.music_tier`.

A comment records that this value changes only music-bed selection, which reads state but does not change the batch trajectory. The bot is `HumanBot` with the specified or default `skill`.

The audio is `Audio(mute=True)`. A `tap` writes each event as one `JSON` line with `t`, `kind`, `name`, `vol`, and `pan`. It writes volumes with 4 decimal positions. The music is a `MusicSystem` on the tick clock, across all `album_*` banks that hold a `bank.json`.

Each tick gets a snapshot, runs the bot step, updates the session, and calls `renderer.consume_fx`. It sends sound instances in view through `audio.handle_sounds` and calls `music.update`. Each `--every` ticks, the tool renders a frame, draws the HUD, and writes it through `necore.write_png`. The loop ends on death, a complete session, or the tick limit.

### Caveats

- The docstring names `tune_pass_rate.one()` as the source loop. That function is out of this directory. A change there must also go into this tool, or the text of an equal loop breaks with no signal.

## The `trace` structure test — `trace_check.py`

### Goal

Check that a session or bot trace file follows the structure used by all gates. Print a `census` of record types and return an exit code for use in a shell gate sequence with `&&`.

### Invariants

- The first line must be a `header` record. Each line must parse as `JSON`.

- Each `seq` must be more than the previous value, and `t`, the tick, must not decrease.

- Each record type must be in the known set.

- The `trace` holds no audio events. Simulation facts do not travel on audio events.

- The exit code is 0 only when there is no error.

### Verification

- Run `uv run python tools/playtest/trace_check.py out/sessions/<file>.jsonl` on a correct trace and make sure that the `census` prints and the exit code is 0.

- Add `--require damage_applied=1` to a trace without damage records. Make sure that the exit code is 1 and the missing requirement is in an error.

- Put incorrect data in one line of a trace copy and make sure that the tool reports its line number.

### Implementation

The known set contains 16 types. They are `header`, `input`, `sample`, `agent_transition`, `portal_crossing`, `damage_applied`, `impulse_applied`, and `topology_changed`. Types kept for subsequent use are `field_sample`, `call_lease`, `call_imprint`, `breach_lifecycle`, `reserve_sample`, `dispatch_decision`, `core_part`, and `structure_event`. All other types are errors. This includes an audio-event type.

The tool reads the file line by line. An empty line is an error, and the first line must have type `header`. From the second line, it checks 3 more error classes.

These classes are an unknown record type and an incorrect `seq` or `t`. A correct `seq` is an integer more than the previous sequence value. A correct `t` is an integer more than or equal to the previous tick.

The header can contain `seq` and `t`, but the tool does not examine those fields.
The header type must be `header`. After the header, the sequence check starts at
0 and the tick check starts at -1. A parsed `JSON` value that is not an object
causes an attribute error that the code does not catch.

Each `--require KIND=N` argument makes a `census` count below `N` an error. Callers can give this argument more than one time. The value after `=` is not necessary, and its default is 1. The tool prints the `census` and at most 40 errors to standard error. It then prints the number of errors not printed.

When JSON data has an error, the tool records one error and goes to the next source line. The malformed line does not change the `census`, previous sequence, or previous tick. The parser contract must have a JSON object. A JSON value of a different type causes an attribute error at `rec.get` that the code does not catch.

### Caveats

- The `seq` and `t` requirements do not apply to the header line.

- After a bad `seq` or `t`, the last correct value stays the same. Thus, one bad record makes one error and does not make a cascade.

## The coordination live test — `coord_trace_check.py`

### Goal

Show in a live run of the complete level that `coordination` layers `U4` and `U5` work in addition to unit tests. The tool runs a bot through `gauntlet4` with trace output enabled. It examines the trace for 6 necessary operations and prints `PASS` or `FAIL` for each. Its exit code agrees with those results.

### Invariants

- The run is constant: `HumanBot(2200)`, seed 2200, 14000 ticks, level `gauntlet4.json`, `trace` at `out/u5_gauntlet_trace.jsonl`.

- The exit code is 0 only when each hard requirement has a satisfactory result. The `stand-down` item prints `WARN` but does not cause a run failure. See Caveats.

### Verification

- Run `uv run python tools/playtest/coord_trace_check.py`. Make sure that a `[run]` line prints the `outcome`, that 6 result lines follow, and that the exit code agrees with them.

### Implementation

The 6 checks calculate from trace records:

- Noise follows firing: one or more `input` records have `fire`, and one or more `field_sample` records have `totals.noise > 0.3`.

- `Distress` follows damage: one or more `damage_applied` records occur, and one or more `field_sample` records have `totals.distress > 0.1`.

- `Danger` starts only after enemy damage. The printed requirement states death, but the code uses the first `damage_applied` record with a target other than the player as the boundary. Before that record, no `field_sample` can have positive `totals.danger`. Across the complete trace, one or more samples must have `totals.danger > 0.3`.

- A cascade from peer signals must have 3 or more transitions to `waking` in one 120-tick `bin`, calculated as `t // 120`.

- `Stand-down` events. Changes from `hunt` to `idle` print `PASS` when they occurred and `WARN` when they did not occur. This item does not make the run a failure.

- Different paths must have one or more polygons that enemies exited through 2 or more different portal edges. Crossings by the player, `other`, or `bullet*` types do not count.

### Caveats

- The `stand-down` item prints `WARN` and does not print `FAIL` until breaches are in this part of the simulation. A comment dated 2026-07-26 gives the cause. An enemy in `hunt` state that can get to the player stays active because it continues to have a target. An enemy in that state more than 5 hops from the player is not in the active window and receives no update.

A live `stand-down` test thus must have enemies in `hunt` state in isolated areas. `Scout` bodies and breaches in `U7` and `U9` make those conditions. The isolated unit test puts the mechanism at `300 +/- 1` ticks, and the hard gate returns in the `marrow` test harness.

- Cascade `bins` are constant at 120 ticks. A cascade across a `bin` boundary can divide between the 2 `bins` and have less than 3 transitions in each one.

- When no enemy damage occurs, the `danger` check can have a satisfactory result. By construction, the set of samples before the first enemy-damage record is empty.

- Defect: the printed requirement states death, but the test uses damage to a target other than the player. A hit that does not kill an enemy starts the permitted risk period.

## The gate 55 A2 check — `gate55_a2.py`, `gate55_a2b.py`, `gate55_a2c.py`

### Goal

Measure `hunt` operation for all enemies in 3 `passes` with gate records for seeds 2, 4, 7, and 11. `Pass` 1, `gate55_a2.py`, checks `hunt` length, movement, samples, death sources, warning time, and the `distress` latch from the environment. `Pass` 2, `gate55_a2b.py`, corrects the movement check and examines each long `hunt`. `Pass` 3, `gate55_a2c.py`, checks if long `hunts` move nearer to the player.

### Invariants

- The tools only read the records. They change no simulation state.

- Each `pass` writes one `JSON` result: `out/eval_gate/a2_run55.json`, `a2_run55b.json`, and `a2_run55c.json`.

- The session length constant is 14400 ticks in all 3 `passes`.

### Verification

- Run each `pass` from the repository root with the gate records on disk. Make sure that it writes the `JSON` result and that the printed lines agree with the result's data.

- For `pass` 1, make sure that each regression entry names an item (`A2/Q1` to `A2/Q6`), a seed, a type, and a `severity`.

### Implementation

All 3 `passes` read each seed's `trace.jsonl` into lists grouped by record type. `Hunt` spans come from `agent_transition` records. They open on a transition to `hunt` and close on a transition from `hunt`, entity death, or session end. Positions come from `enemy_positions` records.

`Pass` 1 gives one result for each seed. It has checks numbered 1, 2, 4, 5, and 6.
It has no check numbered 3. The sample count list below comment number 3
gives data for the results, not a result for check 3. `Pass` 3 gives results for check 3.

- The `hunt` length list contains the 10 longest spans and each span's end type. A `stand-down` comes from `coord_event` records (`shrieker_stand_down`, `hunt_stall_stand_down`) or is `stand_down(generic)` for an exit to `idle`.

- An `A2/Q1` error has high `severity`. It is a span longer than 2,900 ticks without a send or an enemy tick in the player's polygon.

- Windows without movement have type `A2/Q2` and moderate `severity`. Such a window lasts more than 1,200 ticks and contains less than 5 units of total entity movement. It has one or more samples in an active state (`hunt` or `waking`). A polygon change counts as movement. The result keeps only the longest window for each entity. Each kept window is an error.

- The result includes sample counts for 4 record types.

- Death-source check `A2/Q4` has high `severity`. For each `player_death`, it examines damage records from the previous 240 ticks. A mismatch between the death source and last damage source is an error.

- Check `A2/Q5` uses `shrieker_phase` transitions into and out of `warning`. A `stand-down` event with `detail` value `patience spent` must occur 2,701 ticks (`SHRIEK_APPROACH_PATIENCE + 1`) after its `approach` entry. A mismatch has moderate `severity`. A median warning length of one tick or less is an error with high `severity`.

- The environment-`distress` latch check `A2/Q6` has high `severity`. For each span from an entity that is not a `shrieker` and is longer than 3,000 ticks, it finds the longest time between player weapon fires. A time of 1,000 ticks or more with no ticks in the player's polygon is an error. Fire times come from `events.jsonl` sound records with names in a 7-name weapon set.

`Pass` 2 corrects 3 errors in `pass` 1, as recorded in its docstring. Before its first logged transition, an entity is at its initial position and thus idle, not unknown. A window without movement must stay active for its complete duration, not only at one sample. Position samples with 60 ticks between them cannot show that the player stayed out of view.

`Pass` 2 reports long `hunts` of more than 2,000 ticks with total path length, polygon changes, and end type. It also reports corrected windows without movement, the `distress`-decay values from `field_sample` records, and times between player fires.

`Pass` 3 makes a polygon-neighbor graph from the union of all `portal_crossing` events. For each long `hunt`, it measures hop distance from each sampled enemy polygon to the nearest player sample no more than 30 ticks from it. The search has a limit of 12 hops. Player samples are in tick and polygon sequence. If 2 are equally close in time, `min` selects the first entry in that sequence. This usually is the entry with the lower tick unless their ticks are equal.

Enemy polygons come from `enemy_positions.positions`, where element 0 is the type and element 1 is the polygon. For each span, the result reports minimum and median hops. It also reports fractions at a distance of one hop or less and in the same polygon, plus the first time at that distance. It prints spans that stayed more than one hop from the player for more than 2,900 ticks.

Gate 55 check 3 examines each `hunt` longer than 2000 ticks. It checks if the enemy comes to one graph hop or less from the player. `hops` returns 0 for the same polygon. It returns a distance from 1 through 12 when it finds the target.

It returns -1 when it does not find the target. This can mean that the graph is disconnected. It can also mean that the shortest path is more than 12 hops.

These samples count in `samples` and `unreachable_samples`. They do not count in the two fractions, the minimum, or the median. A span with no sample that the graph can connect has `null` values for those fields. Its `first_within_1hop_t` field is also `null`. The `NEVER` list includes this span when its length is more than 2900 ticks.

### Caveats

- The source path, seeds, and session length are constants in the code. `gate55_a2.py` accepts one optional work directory. The other two `passes` run from the repository root only.

- `Pass` 1 keeps its first calculation for windows without movement. `Pass` 2 records its errors, but only the result from `pass` 1 contains incorrect windows.

- Weapon-fire name sets are different: `pass` 1 uses 7 names, for example `gun_fire` and `player_fire`, while `pass` 2 uses 5. The `passes` can thus report different times between fires.

- This specfile identifies the neighbor graph in `pass` 3 as approximate. Breaches change the portal graph during the session, while this graph is the union across the complete session. The docstring records this limit.

- Decision open (see `spec/open-questions.md`, item `PLAYTEST-TIME-UNION`):
  the user has not selected if the union is correct for a result about one sample time.

- The position tuple layout is different between the `passes`. Each `pass` uses one layout through its code.

## The return audio audit — `audit_return_audio.py`

### Goal

Audit gate run 65 audio with 3 checks for each constant seed. There must be one `adversary_return` sound near each known return tick. List other sounds near each return. Find sounds that occur again after a short interval across the complete event stream.

### Invariants

- The tool only reads `events.jsonl` of each record. It calculates and prints. It writes no file.

### Verification

- Run `uv run python tools/playtest/audit_return_audio.py` with gate records on disk and make sure that each seed prints 3 numbered parts: fire count, window data, and error `scan`.

### Implementation

The constants are the full record source path and `RETURNS`. `RETURNS` maps each seed to its known return ticks: seed 2 has two returns, seed 4 has none, seed 7 has 3, and seed 11 has 6. The tool reads each seed's `sfx` events in time sequence.

Part 1 aligns each known return time with `adversary_return` events no more than `0.5` seconds from it. Return time is the tick divided by 60, and each return counts events in its window. One event can thus count for two returns when their windows overlap.

It prints `OK`, `MISSING`, or `DUP xN`. A fire is `PHANTOM` only when it is external to all known return windows. The line includes time, volume, and `pan`.

Part 2 prints each sound no more than 0.5 seconds from each known return. It reports the count, return volume, and number of other sounds at or above that volume. It also reports the 10 most frequent names and their maximum volumes, plus sounds no more than 0.15 seconds from the return.

Part 3 prints the 15 names with the largest counts and their rates for 60 seconds. For the top 12 names, it then prints the maximum count in a window of one second. A maximum above 5 receives a `<<< FLAG` mark.

### Caveats

- The source is a full file path (`/home/login/...`). The tool runs only on this system without a change.

- The known return ticks are constants from one gate run. Update them for a new run.

- The tool always exits 0. The results are for a person, not for a CLI shell gate.

## The `ground truth` tool — `ground_truth.py`

### Goal

Calculate objective facts for one session from a gate record's trace. These facts give data for `judge` checks when visual inspection can be incorrect.

The report checks if the health bar changed by the logged damage and how long the player fired without a hit. It also checks if `wardens` moved and how many polygons the player went into.

### Invariants

- The tool only reads `trace.jsonl` of the recording. It writes one file, `ground_truth.json`, in the recording directory, and prints the same data.

- Fire ticks in death, respawn, and walk back spans do not count in the dry fire measurement.

### Verification

- Run `uv run python tools/playtest/ground_truth.py <capture_dir>`. Make sure that it writes `ground_truth.json` with `camera`, `player_hp_drops_match_logged_damage`, `longest_zero_hit_firing_ticks`, `total_damage_events`, `player_hits`, `damage_by_source`, `player_chamber_changes`, `warden_movement_spans`, `enemies_tracked`, `enemies_never_moving`, and `session_stats`.

### Implementation

`ground_truth(rec)` walks the `trace` once. It collects fire ticks from `input` records with `fire`. It collects damage records with time, target type, source, and `amount`. It collects player health from `sample` records and the player polygon from `field_sample` records.

It also collects player death spans. A death span opens at the first `sample` with health at or below 0. It closes 300 ticks after the `breach_lifecycle` event `player_respawn`.

Fire ticks in death spans do not count.

The measurement of firing with no hit reads fire ticks in sequence. A time of more than 30 ticks ends a firing period. The previous version included idle walk periods between combat and reported 889 ticks, not 88, in run `42b`. A damage record from 30 ticks before a projectile through 90 ticks after it also ends the period. The result is the longest remaining firing period.

The health measurement selects each damage record for the player and one health sample before and after it. The check does not use a record without one of the 2 samples. A health drop equal to or more than `0.8 * amount - 0.5` agrees with the record.

The result contains the count that agrees and the number of compared records. This is not an equality check. It accepts 80 percent or more of the logged quantity minus `0.5` health. It also accepts larger drops that can include other damage.

The movement measurement reads `enemy_positions` records. For each entity, it sums path length in each polygon. Each polygon change counts as one crossing, not as a distance. Positions in different portal spaces do not have a distance between them.

The previous measurement reported some `warden` paths a maximum of `9.7` units too short. `warden_movement_spans` reports path length and polygon count for each `warden`. `enemies_never_moving` counts entities with a path of less than one unit that stays in one polygon.

`session_stats(rec, capture_meta)` counts `breach_lifecycle` events (`opened`, `dry*`, `sealed`), send decisions, and hits on the player. It copies the last 600 characters of the record stdout from `capture_meta`.

### Caveats

- The `camera` value is constant text. It states that zoom is constant, with no zoom change or close death view. The tool does not measure this value.

- The camera field is thus an assertion, not a trace measurement. Other fields calculate from trace records but stay limited by samples from different times.

- Defect: one condition has no effect. It checks for damage to the player but contains only `pass`. Different code below does the damage calculation.

- Defect: when player health becomes 0 without a respawn after it, the last death span does not close. This causes fire ticks after death to count in firing with no hit.

- `player_chamber_changes` counts different polygon values that the player `visited`, not changes. A return to a previous polygon adds zero.

- When the CLI calls `session_stats`, it receives an empty `capture_meta`. Thus, the `record` field stays empty.

## The replay check — `replay_study.py`

### Goal

Replay a person's recorded session from its input stream. Measure `survival`, damage and its conditions, firing distance for each weapon, `warden` contacts, movement, and use of `cover`. With the same level, seed, `loadout`, and input for each tick, the simulation is deterministic. Before it reports measurements, the tool checks parity against recorded music-debug lines.

### Invariants

- Session construction is the same as the recorded simulation. Because inputs use screen coordinates, screen dimensions and zoom are part of deterministic replay.

- A record without `inputs.jsonl` ends the run with a message that gives the cause: the record occurred before input recording was added.

- When parity is not complete, the tool reports it and marks all measurements as approximate.

### Verification

- Run `uv run python tools/playtest/replay_study.py --rec out/director_fc/attempt_04`. Make sure that it prints the parity fraction, result, damage `ledger`, firing distances, movement, test measurements, and `warden` contacts.

- Run with `--json OUT.json` and make sure that the file contains result, `ledger`, contacts, firing distances, and health values.

### Implementation

Flags are the necessary `--rec`, `--level` (default `levels/gauntlet4.json`), `--seed` (default 2200), `--json`, and `--parity-lines` (default 40).

For parity, the tool reads at most `--parity-lines` recorded `music_dbg` names from `events.jsonl`. When the list is not empty, it makes muted `Audio` with a tap that collects live `music_dbg` names. It also makes a tick-clock `MusicSystem`.

It compares positions through `zip`. The `numerator` is the count of equal pairs. The denominator is the full recorded list length. Missing live lines decrease the fraction.

More live lines do not change the fraction. Without recorded names, parity is `null`, no warning prints, and the tool reports all measurements. If the count of equal pairs is below the recorded count, the tool prints `PARITY IMPERFECT`.

It then marks all measurements as approximate. This check compares only music-debug names and does not show parity for inputs, result, health, positions, or damage.

The session receives a deep copy of `FULL_LOADOUT`, the internal `render` dimensions, and zoom `ZOOM_BASE[0] * INTERNAL_RES_ZOOM_SCALE`. Each input row becomes an `InputFrame` (movement, point, fire, `alt`, weapon, `interact`). For each tick, the tool collects:

- The damage `ledger`: each health drop, with the type and distance of the nearest threat in the same polygon at that tick.

- Fire distances: on a fire tick with a threat, the distance to the nearest threat, for each weapon.

- Movement: a speed value for each tick pair, grouped into `bins` of 20 units for each second. It also includes a count of slow ticks while a threat is near the player.

- `Cover` is sampled once each 6 ticks. The renderer's view query has a high cost. Thus, the tool checks only `spitter` or `warden` enemies in `hunt` state no more than 3 hops from the player. It reads each enemy's view map to check if the player point is in view. It then totals ticks in view, ticks not in view, and lengths of continuous time in view.

- A `warden` contact period opens when a `warden` comes to a distance of one hop or less and records distance each tick. It closes 300 ticks after the last contact and reports duration and health cost.

The last result prints the `outcome` and the `ledger` report by nearest type. It prints median fire distance for each weapon, movement distribution, test fraction with median burst, and each `encounter`.

### Caveats

- Defect: the line `wardens0 = sum(1 for k in ... if False)` always calculates 0. No code reads it. This code has no effect.

- The view cache holds one entry. Each cache query without a result clears the cache and keeps only the new map. Thus, it keeps only the last query and not results across enemies in `hunt` state.

- A continuous time in view that is open at run end is not in the result. A `warden` contact period that is open at run end is also not in the result.

- The parity test compares only music debug names. It does not compare `outcome`, health, positions, damage, or input count.

## The `frame` sample tool — `framecheck.py`

### Goal

Make a sample at equal intervals from a record for inspection of each frame with `tools/playtest/FRAME_REVIEW_RUBRIC.md`.

### Invariants

- Decision open (see `spec/open-questions.md`, item `PLAYTEST-SAMPLE-INTERVAL`):
  the user has not selected the requirement for an interval that does not divide by the record interval.

- `manifest.json` maps each sample to its record clock time in seconds.

- A run on a directory without `frames` prints an error and exits 1.

### Verification

- Run `uv run python tools/playtest/framecheck.py --rec DIR` on a record. Make sure that `DIR/review/` contains `sample_*.png` files and `manifest.json`, and that each entry's time equals its source frame number multiplied by `--record-every / 60`.

### Implementation

Flags are necessary `--rec`, `--record-every` with default 2 to agree with the record, and `--every-ticks` with default 10. The step through sorted frames is `max(1, every_ticks // record_every)`. The tool removes the previous `review/` directory, copies sampled frames to `sample_%05d.png`, and writes `manifest.json` entries with `frame`, `source`, and `t` to `0.01` precision. It prints the sample count and returns 0.

Integer division discards the fractional part when `every_ticks` is not divisible by `record_every`. Thus, the interval that results is `step * record_every`, not the requested interval. When `every_ticks` is smaller, the step is 1. The tool does not check the range. Zero or negative values can cause division errors or incorrect times.

The program removes a previous `review/` directory before it writes the new one.
The manifest is a JSON list. Each item contains `frame`, the new sample file name.
It also contains `source`, the copied record file name. The `t` value is the source frame number multiplied
by `record_every / 60` and rounded to the nearest 0.01.

### Caveats

- The time value comes from the `frame` number in the file name, not from a clock record.

## The camera phase test — `camera_phase_check.py`

### Goal

Measure two forms of the camera movement defect. Pair mode finds the tick when the camera `lattice` moves to a new integer position and all thin lines change together. Span mode finds a phase offset that stays after an incorrect move until a new move occurs. Across a span, a correct camera makes an integer total offset.

### Invariants

- Span mode exits 1 when the fractional part of the fitted total offset is more than `0.2` on the x or y axis. It exits 0 for all other values.

- Span mode does not use the middle of the screen. The player and `combat` effects are there, and they pull the fit.

### Verification

- Run span mode with `--span T1 T2` across a window with a small quantity of movement in a good record. Make sure that the total offset prints as an integer and that the exit code is 0.

- Run pair mode with `--start A --end B` across a known move. Make sure that the change tick prints as an outlier with a `HALF` mark.

### Implementation

The 2 modes read frames as `grayscale` arrays and remove default 80-pixel margins through `--crop` to remove the HUD. Tick `T` maps to `frame_{T // record_every:06d}.png`.

In pair mode, the first pair can start at `--start`, but a pair cannot start at `--end`. Thus, `end-1 -> end` is the last pair. The tool reports missing files and does not use them. If no pair is on disk, the command returns 0. In span mode, the 2 tick values select endpoint frames.

Pair mode fits an offset for each `frame` pair. It examines 0.25-`pixel` steps in a 6-`pixel` square. The `score` is the mean squared difference after linear interpolation in 2 dimensions. It prints `HALF` when one offset has a fractional part of 0.5.

It then prints the median `residual` and the outliers. A 0.5-`pixel` mark or a `residual` above 3 times the median is an outlier. This mode always exits 0.

Span mode first subtracts a `5 x 5` box-filter result because smooth image data with slow changes can pull the fitted offset below one pixel. It aligns the frames through phase `correlation`. It then fits the offset again at `0.25`-pixel steps in a 2-pixel square.

Span mode removes a `140x200` box from the image center. The tool prints the total offset, the `residual`, and the `residual` with the offset held to integer values. Then it prints the verdict.

The docstring records instrument limits measured on seed 7. Combat images add approximately `0.25` pixels of fit error when the matrix test shows a locked `lattice`. A fractional offset of `0.4` or more is a satisfactory result because the defect step is `0.5`. A value of `0.25` or less makes a new run during an interval with less image change necessary. The matrix test without image noise is `game/tests/test_camera_phase_lock.py::test_phase_lock_transitive_across_spans`.

### Caveats

- Pair mode has no failure exit code. Its output is for a person.

- Conversion from tick to `frame` discards the fractional part. With `record_every` above 1, adjacent ticks can select the same `frame`. The code checks only that this value is more than zero.

- The docstring records the requirement in this tool. `Frame`-pair differences cannot `reveal` a phase offset that continues. The check must align 2 `frames` that are far apart in world space.

## The `pixel` `oscillation` `scan` — `flicker_scan.py`

### Goal

Find pixels that change direction many times across time, a defect that one image cannot `reveal`. At a sampled frame rate, a blink can be almost the same as movement. A camera pan changes pixel values smoothly in one direction, while `oscillation` changes direction many times. The tool thus counts sign changes for each pixel across a window.

It reports location and magnitude but does not give a defect decision. Weapon flashes can also have `oscillation`. The output identifies an area for inspection, not a verdict.

### Invariants

- The tool only reads `frames`. It writes only the optional image.

- A `flip` counts only between one nonzero sign and the next nonzero sign. The threshold is 18 `grayscale` levels.

### Verification

- Run `uv run python tools/playtest/flicker_scan.py FRAMEDIR --range 100:160 -o /tmp/osc.png` on a record with a known blink. Make sure that it prints the `flip` count, bounding box, and 6 `24 x 24` cells with the largest counts. It must mark the blink area with the first RGB channel in the output image.

### Implementation

Arguments are `framedir`, `--range FROM:TO[:STRIDE]`, `--min-flips`, and `-o`. The default minimum is 4. The output image is optional. The tool reads the window as `grayscale` arrays.

A minimum of 5 frames is necessary. `oscillation` calculates differences across time, applies the threshold, and counts changes between adjacent nonzero signs for each pixel.

The result prints the count and bounding box of `pixels` at or above `--min-flips`. It also prints the 6 `24x24` cells with the largest counts. The image starts as the middle `grayscale` `frame`. At each `pixel`, the first RGB channel increases by 40 for each `flip` and is clamped to 255. The RGB channel at index 2 becomes 0 at each `pixel` where a `flip` occurred.

### Caveats

- None.

## The flicker crossing `harness` — `flicker_cross.py`

### Goal

Assemble a small test world for the decal flicker defect. A square polygon has 4 square neighbors with bright `chip` decals at known `pixel` positions. Each tick uses the simulation's `render` path.

The tool probes the decal `pixels` for each neighbor. A large `ink` decrease with less than 3 units of player movement is a flicker event. The `frame` pair goes to disk for inspection.

### Invariants

- The tool uses the program `render` path from `GameSession.visible` into `Renderer.draw`.

- The exit code is 1 when one or more flicker events occurred. Otherwise, it is 0.

- The player walk is deterministic for a given world and tick count.

### Verification

- Run `uv run python tools/playtest/flicker_cross.py --world cross --ticks 1400`. Make sure that the last line prints the event count and the ticks at the instance limit. It must also print the maximum instance count. Make sure that `log.json` and `events.json` are in the output directory.

- Make sure that the `frame` pair `evNNN_t<T-1>.png` and `evNNN_t<T>.png` is on disk for each of the first 20 events.

### Implementation

The tool gives 3 worlds. `cross` has a middle polygon with 4 neighbors. Each square has 120-unit sides and a 24-unit doorway at the center of each side, the same as the campaign doorway shape. `braided` adds a loop of 4 corner polygons to the cross.

Two or more chains then lead to each neighbor. The changed traversal and that it can get to the `max_instances=96` limit are the test's two primary causes. `grid` is an `N` by `N` grid with all doorways, and the default for `N` is 7. From its center, the renderer can make more instances than the limit when `rendering` is correct.

`plant_decals` writes 7 `chip` decals in a `pattern` with the shape of a plus sign at the local center of each probe polygon. `probe_ink` transforms each decal through its screen instance and counts bright `pixels` in a `9x9` box at the same screen position. A `pixel` is bright when its first and second RGB values are above 85. For each tick, the tool records the instance count and each neighbor's `ink`.

A flicker event must have 3 conditions. The previous tick had instances and `ink` at or above 15. The player moved less than 3 units. The active tick has one of 2 results: zero instances or `ink` below 0.3 times its previous value.

The player does not move for 120 ticks. For each direction in sequence, it then walks to the doorway, moves from side to side there with a `sine` `sweep`, and walks back. The `settle` and `phase_len` values scale the walk but do not change its shape. A comment records that a 700-tick run with the defaults got to only two of the 4 doorways.

### Caveats

- Defect: the doorway-point calculation in `build_world` makes temporary center values that the code then discards. It also sets `eym` a second time in the `braided` loop. The last values work, but the code does not clearly identify the active calculation.

- Defect: `build_grid` contains an `if False` selection that has no effect. Only the value after `else` can occur.

- The primary loop calls `random.seed(tick)` on each tick. This sets the process-wide random state for each renderer consumer. No comment gives the cause.

## The movement image tool — `ghost.py`

### Goal

Show fast objects in a static image. Sparse frame samples cannot always show a projectile that crosses the screen between two `frames`. This once made a returned player projectile look as if it caused damage with no threat in view. The tool gives two views of movement and can make one point larger. `ghost` composites a span of frames into one image. `sheet` lays the span out as a contact sheet and gives the clearest timing information.

`patch` cuts an area around one point and makes it larger. A reader can then check if an object was on screen at a hit.

### Invariants

- Each `panel` of a contact `sheet` contains its `frame` number and clock to let a reader identify the source `frame`.

- The tool exits with an error when none of the requested `frames` are on disk.

### Verification

- Run `uv run python tools/playtest/ghost.py FRAMEDIR --at 500 --span 5 -o /tmp/g.png`. Make sure that it writes `g_ghost.png`, `g_mean.png`, and `g_sheet.png`, and that the contact `sheet` identifies `frame` 496 as the start.

- Run with `--range 100:200:10`. Make sure that the contact `sheet` contains 11 panels at intervals of 10 `frames`.

- Run with `--at-xy X,Y`. Make sure that the maximum mix and mean outputs contain larger cut areas while the contact `sheet` keeps its full dimensions.

### Implementation

Arguments are `framedir`, `--at`, `--span`, and `--range FROM:TO[:STRIDE]`. The `--at` `frame` is the last `frame` in a span. The default span length is 5. A range selects a full window, not a span, and its default `stride` makes about 12 panels. Other arguments are `--mode`, `--at-xy`, `--patch-size`, `--zoom`, and the necessary `-o`.

The modes are `ghost`, `mean`, `sheet`, and `all`. Their default is `all`. Patch dimension defaults to 120, and zoom defaults to 4.

A range uses `range(lo, hi + 1, stride)`. Thus, it includes the high value when the `stride` ends on it. The default `stride` is `max(1, (hi - lo) // 11)`. The tool does not use missing images.

`Panel` IDs start at `lo` and increase by the `stride`. Thus, a missing image between 2 available images makes all `panel` IDs after it incorrect. A zero `stride` causes an error. A negative `stride` can select no `frames` and cause an error.

`ghost` stacks the `frames` and calculates their maximum or mean. The maximum keeps a bright object at full brightness along its path. The mean gives the average image across time. `sheet` uses 5 columns, or one column for each `panel` for a shorter span.

A 13-`pixel` label area is above each `panel`, with a 3-`pixel` space between them. Each label shows `#index mm:ss.ss` in color `(255, 220, 90)`. The clock uses 20 `frames` for each second.

`patch` cuts a square from the image and makes it larger because it copies each `pixel` more than once. In `all` mode, the output suffixes are `_ghost`, `_mean`, and `_sheet`.

### Caveats

- The patch applies to the maximum mix and mean outputs only, not to the contact `sheet`.

- The `panel` clock uses a constant rate of 20 `frames` for each second. Records made at a different rate receive incorrect clock labels.

- Defect: missing requested `frames` do not cause an error when one or more
  `frame` is available. A missing middle `frame` also makes each subsequent `panel`
  ID name the incorrect source `frame`. This does not obey the `panel` ID invariant.

## The inspection `scan` — `attention_scan.py`

### Goal

Score each record window for visual `novelty` with no named target. Other instruments can find only `features` specified before the test. A reader who does not know the simulation can incorrectly identify correct operation as a defect. This tool does not `judge` operation. It selects windows for inspection with 2 signals.

`gate` is the `StreamMind` head of `Mage-VL` and scores a segment's inspection value. `novelty` is the segment's distance from the session's median visual `embedding`. The list is sorted by `score` and is an inspection queue, not a verdict.

### Invariants

- The `novelty` signal comes from model image `features`, but not from defect labels or the `gate` value. It measures only if a window is unusual in its session.

- A window without an `embedding` has no `novelty` value.

- The tool does not use missing `frame` files and prints no warning. One `frame` that can be read is
  sufficient for a row. The row keeps its requested `frame` limits and time when it
  contains a smaller number of images than `--frames-per-window`.

### Verification

- Run `uv run python tools/playtest/attention_scan.py FRAMEDIR -o /tmp/scan.json --limit 5`. Make sure that the output contains one row for each window with `window`, `frame_lo`, `frame_hi`, `t`, and `gate`. When the tool makes `embeddings`, each row must also contain `novelty`. Make sure that no row contains an `embedding`.

### Implementation

Flags are `framedir`, `--model`, `--fps`, `--window`, `--frames-per-window`, `--limit`, and the necessary `-o`. The defaults are 20 `frames` for each second, 5 seconds, 8 `frames`, and no limit. Without `--model`, the tool uses the first `Mage-VL` cache path returned by `glob`. It stops with an error if none is available.

The tool sets the step to the integer part of `window * fps`. Window starts are an integer times that step and below `n_frames - step`. Thus, the tool does not include a last full window with a start equal to that boundary. `--limit N` keeps the first `N` starts when `N` is not zero. Zero means no limit. A negative value uses a Python slice and removes starts from the end.

Each window samples integer `frame` indexes at equal intervals and includes the 2 endpoints. Missing files drop out, and a window makes no row if none of its `frames` can be read.

For each window, the tool makes a request through `apply_chat_template` with a video item. The template makes the `<|video_pad|>` values that the model counts. A text `<video>` tag does not work. `AutoProcessor` gives the `frames` to the model as images and gives `patch_positions` as a different input. The model's image component must receive `3D` position values.

For each window, `get_image_features` returns a float32 `embedding`, which the code averages across image patches. `streammind_gate_forward` supplies the gate value as the mean of its output. The two calls have different `try` blocks, and a failure sets only that call's value to `None`. Only failures in the first window print their cause.

After the loop, each row with an `embedding` receives a `novelty` value equal to its distance from the median `embedding`. The code scales the distances to a mean of 0 and a standard `deviation` of 1. The divisor is the standard `deviation` plus `1e-9`. Equal distances make a value of 0. The rows are written to `JSON` without the `embeddings`.

### Caveats

- `Feature` and gate failures after the first window print no message. When every `feature` call fails, rows have no `novelty` values.

- A gate-call failure writes `gate: null`. A `feature`-call failure keeps the row without `novelty`. When every `feature` call fails, the command writes a `JSON` list and exits 0.

- Decision open (see `spec/open-questions.md`, item `PLAYTEST-MODEL-FAILURE`):
  the user has not selected if total model failure must return a nonzero exit `status`.

- The model reads with `trust_remote_code=True`.

## The inspection `score` — `score_attention.py`

### Goal

Score an inspection instrument against known defect windows. The docstring uses `a mood, not an instrument` for an instrument without a `score`. The labels are time ranges from one measured `playtest` and contain no cause text. Thus, this code cannot calibrate its calculations to the results. The scorer knows defect times but not their type.

### Invariants

- The labels are constants: 11 defects (`D1` to `D11`) from the user `playtest` on 2026-08-01. Each label is a time range in seconds, without cause text.

- The output values are `recall@k`, `precision@k`, and `lift`. `Recall` is the fraction of defects found by the top `k` windows. Precision is the fraction of those windows that overlap a labeled range. Lift is precision divided by the reference rate.

A lift of 1.0 is the random reference value. A lift below 1.0 means that random selection does better than the instrument. The tool prints that result.

### Verification

- Run `uv run python tools/playtest/score_attention.py /tmp/scan.json --key novelty`. Make sure that the first lines print the window count and source rate. One line for each `k` in `10,20,30,50` must follow. The last lines show the 12 windows with the largest scores and their hits.

### Implementation

The flags are `scan`, `--key`, `--window`, and `--ks`. The `scan` value is the inspection `scan` `JSON`. The default for `--key` is `novelty`, the default for `--window` is 5 seconds, and the default for `--ks` is `10,20,30,50`. Rows without the key drop out, and an empty result causes an error exit. The remaining rows are in sequence from the largest key to the smallest. The estimated session length is the largest kept time plus the window length.

A `scan` range `[t, t + window]` hits a label `[lo, hi]` when `t < hi` and `lo < t + window`. Contact only at an endpoint is not an overlap. One `scan` window can find more than one defect but adds only one precision hit. For each requested `k`, the top list contains no more rows than the input, but the precision denominator stays `k`. `Recall` uses all 11 defect labels as its denominator.

Precision does not use the kept top list length or the count of different defects. Lift divides precision by the reference rate. The reference-rate `numerator` sums all label spans, with overlaps.

### Caveats

- The printed `recall` percent value uses integer division and thus selects the next lower integer.

## The person `judge` — `human_judge.py`

### Goal

Measure if a model can identify the `human` bot and the `aggro` bot as different. Each `trial` records the same level, seed, and segment 2 times, once with each bot through the simulation's `--record` path. A seeded `shuffle` sets the recording names to `A` and `B`. The model selects the recording that looks as if it is from a person, and the result counts correct and incorrect `trials`.

Control mode compares two `aggro` recordings. About 50 percent of control selections in each group with low `confidence` is the reference for a satisfactory `judge`. A `judge` that identifies a person in most bot-only pairs measures noise.

### Invariants

- No file path that the `judge` reads contains the bot type. The seeded `shuffle` selects the `a/` and `b/` directories. A version from 2026-07-13 used `human/` and `aggro/`. A verdict used those directory names as its cause, which leaked the correct selection.

- A recording failure ends the `trial` with an error. The tool does not `judge` files from a run before.

- The verdict must name `A` or `B`. All other responses are an error.

### Verification

- Run the control: `uv run python tools/playtest/human_judge.py --seeds 101,102,103 --control`. Make sure that each `trial` prints its selection and that the report prints the counts. About 50 percent in each group with low `confidence` is the reference result.

- Run `A/B` mode with the same CLI instruction but without `--control`. Make sure that the report prints `human bot identified as the human in W/N trials` and that it writes `judge_out/ab/seed_*/verdict.json` and `summary.json`.

### Implementation

Flags are the necessary `--seeds`, `--level` (default `levels/l01.json`), `--seconds` (default 12), `--frames-per-clip` (default 10), `--hard`, `--model` (default `sonnet`), `--control`, and `--out` (default `tools/playtest/judge_out/<ab|control>`).

`record_clip` runs `uv run python -m perihelion` headless, with `--bot KIND --seed N --autoplay --record DIR --record-every 2 --record-seconds S`. It sets `SDL_VIDEODRIVER=dummy` and `SDL_AUDIODRIVER=dummy`, with a 600-second time limit. It returns the sorted `frame` paths. `sample_frames` selects `N` `frames` with equal steps.

`judge` makes a prompt with the `frame` paths and 3 decision conditions: aim movement, path shape, and response time. It calls the `claude` CLI with `JSON` output, Read access, and a 300-second time limit. It then removes lines that start or end a code block and reads `human`, `confidence`, and `reason` from the verdict. The response must contain no other text.

For each seed, the `shuffle` is `Random(seed).random() < 0.5`. Control mode uses `aggro` at the seed and at seed plus 5000. It has no correct selection. `A/B` mode uses `human` and `aggro` at the same seed.

The `shuffle` controls which selection is correct. Each `trial` writes `verdict.json`, and the run writes `summary.json`.

Control mode calculates no correct selection, accuracy, or `pass` verdict. Each row has `null` values for `correct` and `is_correct`. The last line gives only the `A` and `B` selection counts. It states that about equal counts with low `confidence` are necessary. Completed `trials` always return 0. No balance or `confidence` threshold changes the exit code.

A failure of the recording command raises a process error that the code does not catch. It stops the command before subsequent `trials` or the report. A `judge` timeout, command failure, malformed `JSON`, or incorrect verdict also stops with a nonzero `status`.

### Caveats

- Defect: `--hard` uses `action="store_true"` with `default=True`. It is always on. The flag changes no value, and there is no procedure to run normal difficulty.

- The measurement must have Read access for the `claude` CLI because the `judge` reads the `frames` from disk by path.

## The audio `judge` — `audio_judge.py`

### Goal

Check audio-tool output with an audio model through the `OpenRouter` `chat/completions` API and the Python standard library. `judge(wav, spec)` returns a verdict with `p_shippable`, `matches_spec`, `amateur_tells`, and a report. `judge_bank(manifest)` examines a full `bank`. Errors stay in the result. After all `retries`, a call with no result becomes a clear error entry with `p_shippable` equal to `None`. The tool makes no verdict without model output.

### Invariants

- Each `HTTP` response that gets to the response parser logs its cost in
  `cost_log.json`, adjacent to the tool. A request failure before a response adds no
  row. A `retry` that receives a response adds the row for that try.

- The key does not print and does not go into a log.

- `matches_spec` in a verdict is `true` only when all `passes` without an error gave `true`.

- A problem counts only when the model heard it. The prompt tells the model to report a problem only when its report about the record gives data for that problem.

### Verification

- Run `uv run python tools/playtest/audio_judge.py <wav> <spec text>` with a key available. Make sure that the printed `JSON` contains the `schema` fields and that `cost_log.json` increases by one call.

- Remove the key. Make sure that the run raises an error with all 4 key locations it examined.

### Implementation

Constants set the model `google/gemini-3.5-flash`, the `OpenRouter` `URL`, and the default simulation `context`. The key comes from `OPENROUTER_API_KEY` or one of 3 fallback files. One file is adjacent to the tool. The other two are `~/.config/autoclipping/openrouter_key` and `/home/login/Documents/youtube/autoclipping/.openrouter_key`.

Before the call, the tool copies a record shorter than 0.6 seconds 4 times with 0.35-second spaces between copies. This gives the `judge` sufficient audio. This operation uses only the Python `wave` module. `to_mp3` uses `FFmpeg` to make a mono `MP3` limited to `max_s` seconds.

When the source is longer, the last second has a fade. A hard cut can sound the same as a sudden stop in the `asset`. Loop drones do not end in the simulation.

There are two prompts. The first requests audible facts from the model and then a verdict against `spec`. It also sets the `p_shippable` scale. The audio-anchor prompt sends two records.

Record `A` is the simulation reference, and record `B` is the candidate. A note identifies records copied 4 times. Requests use `temperature` 0.2.

The response must contain `JSON` only. The parser removes lines that start or end a code block.

`_ask_with_retry` makes 3 tries, with a wait of 8 seconds times the try number. After the last try with no result, it returns `{"error": ...}`. `judge` runs `n_passes` `passes`, with a default of 2.

It calculates mean `p_shippable` from satisfactory `passes`, connects their reports, and removes duplicate problem entries. With an audio anchor, it also records the anchor name and `better_or_worse` verdicts.

`judge_bank` reads a list of entries with a name, `spec`, path, and `category`. To control cost, it examines only the first 15 seconds of each `drone`. It returns totals with mean and minimum `p_shippable`. Each call adds a cost-log row with the model and `token` counts and adds the call's cost to `total_cost`.

Each `HTTP` try that gets to the cost log adds one call-log row. A failure before that point adds none. `Retries` can thus make the call-log count different from the requested `pass` count. When all `passes` for one sound have no result, that sound has `null` values for `p_shippable` and `matches_spec`. When all sounds have no result, the `bank` has zero good results. Its error count equals the sound count, and its mean and minimum are `null`.

The result list keeps each error. The `bank` calculates no `pass` or failure verdict.

### Caveats

- A cost log that does not parse becomes a new empty log, and the tool prints no warning. The tool does not keep the previous total.

- Two fallback key paths point into the directories of one user. On different systems, only `OPENROUTER_API_KEY` or a copied fallback file works.

- As specified, the `retry` catches all error types. After the last try, it returns a clear error entry and does not make a satisfactory result without model data.

- The `judge` API has no `pan` or volume input. Its candidate and audio anchor records are mono `MP3` files.

## The light `preview` — `light_preview.py`

### Goal

Give a visual test loop for light `placement` in `levels/*.json`. The tool renders selected polygons through the simulation's `render` path. This includes zero `ambient`, floor textures, and the occlusion wedges of each light. The lightmap multiplies the world layer. For each image, the player is at the polygon's local center with the work light on, as during play. The docstring gives this text: `what you see is what ships`.

### Invariants

- The `preview` uses the program `render` path and not a different faster path.

- `--list` renders no image. It prints the polygons and lights.

### Verification

- Run `uv run python tools/playtest/light_preview.py --level levels/l02.json --list`. Make sure that each polygon prints with its type, centroid, and vertex count, and each light with its polygon, position, color, intensity, and radius.

- Run with `--polygons 0,7`. Make sure that it writes `polygon_000.png` and `polygon_007.png` at `1280x720`.

### Implementation

The tool sets `SDL_VIDEODRIVER=dummy`, `SDL_AUDIODRIVER=dummy`, and the internal `render` dimensions `1280x720` before it imports the simulation. The necessary flag is `--level`. `--polygons` accepts a list, for example `0,7,23`. `--sweep N` selects each polygon with an index divisible by `N`. Other flags are `--list`, `--out` with default `/tmp/light_preview_<level>`, and `--settle` with default 5 ticks before each image.

One or more of `--polygons`, `--sweep`, and `--list` are necessary. For each selected polygon in range, the tool calls `session.reseat_player(polygon, (0, 0))`. It runs the wait ticks, calls `consume_fx`, renders once, and writes one `PNG`.

`argparse` accepts more than one mode. `--list` runs first and returns before `rendering`. Without it, `--polygons` has priority compared with `--sweep`. A zero `sweep` does not select a mode. A negative `sweep` usually selects no polygons and returns `status` zero.

The docstring is the record of the light facts for the `JSON` writer:

- The format of a `lights` entry. `pos` uses the same `canvas` coordinates as the polygon's `verts`, and the level reader moves them together.

- The brightness sequence. With zero `ambient`, the lightmap multiplies the world layer. The last `pixel` value is floor albedo times tint times squared falloff, and no `ambient` light can mask a weak light.

- The hue limit. The `render` tint is `min(255, channel * intensity * LIGHT_STRENGTH)`, with `LIGHT_STRENGTH` equal to 3.0. A colored light above intensity 1/3 limits its strong channels and changes hue. Intensity 1/3 makes the level color without this number limit. More brightness must then come from the radius. Fixtures with equal RGB channels can use higher intensity with no hue change.

- The fan angle. A light's wedge through a doorway has an angle equal to `atan(half_door_width / distance)` on each side of its center. It forms a wide fan near a doorway and a thin ray at a larger distance.

### Caveats

- The `return 2` after `ap.error(...)` does not run. `argparse` exits first.

- The docstring is the one record of the light facts. No other file records them.

## The light occlusion demo — `light_occlusion_demo.py`

### Goal

Show on camera that occlusion stops light. The assembled world and constant walk use the simulation path. The record is one continuous `FFmpeg` input, and the probes read the last `MP4`. The 6 views show a doorway cone, a wall cut, and a bend through two portals. They also show two light sources, a wall with 5 openings of small width, and a portal bend that changes rotation.

The far bend corner stays at RGB zero. The two light colors mix, and each side of the wall cuts its light wedge. The wall with openings of small width makes 5 isolated wedges with RGB-zero bands between them. The last view sends the cone through a portal with a 90-degree turn.

### Invariants

- The verdict comes from the `mp4` file, not from `frames` in memory (the same artifact requirement).

- The gates use set values and a ratio. A probe with light must have a mean of 110 or more. A probe with no light must have a mean of 8 or less. The minimum value with light divided by the maximum value without light must be 10 or more. The user added the set gates after a ratio approved a `frame` with RGB values near zero.

- The walk is a set input list, not a bot. No session state from the simulation selects an input.

### Verification

- Run `uv run python tools/playtest/light_occlusion_demo.py`. Make sure that the `mp4` goes to `media/lighting/`. The probes must print their screen positions and means for each view. The last line must be `VERIFICATION OK` with exit 0 or `VERIFICATION FAILED` with exit 1 and `!!` lines.

- Run with `--quick`. Make sure that it makes no video and writes one image for each mark. Short mode prints only its `frame` and image report. It does not read `pixels`, print probe values, or apply a verdict.

### Implementation

World construction facts, recorded in the code:

- `door()` makes one doorway with `connect_pts`, then immediately calls `no_connect(ra, rb)`. The docstring records the root cause repaired here. The automatic connection step in `LevelBuilder.resolve()` connects each edge pair at the same `canvas` position. It thus also connected the solid segments on the 2 sides of a doorway. This removed the walls that this demo must show as light stops.

- The demo floor albedo is `(228, 230, 236)`, applied through the renderer's floor-color cache for each polygon. The default `corridor` floor `(26, 26, 33)` limits each `pixel` with light to 26/255. The first record had a `contrast` ratio of 88 between values near zero.

- The colored fixtures use intensity 1/3. See the light `preview` unit for the hue limit. Their distances from the doorways set the 0.5-radian fan angles. The inactive corner probe thus sees no doorway `aperture`. The radius values correct for the distances.

- The wall with openings of small width comes from a helper that reads their center points in each direction. This lets the 2 polygons of the same wall use it with their correct winding.

- The end with changed rotation connects through `connect_x` with a matrix that contains a 90-degree rotation and a translation. The translation puts the turned edge center on the `aperture`. A comment calculates the 2 local `frames` in full.

The script is a list of hold segments (`mx`, `my`, ticks) with named marks. At each mark, the tool maps each probe point from world coordinates to screen coordinates. It uses the polygon instance shown in that `frame`. `screen_xy_for` subtracts the polygon centroid and applies the instance transform. It keeps instances with a record polygon that contains the point and selects the one with the lowest portal-hop count.

A probe point not in a record polygon is not used, and the tool prints a line. This prevents a sample of an empty screen with no warning. Each `frame` goes to the video, and mark `frames` also go to image files.

For verification, the tool reads one `frame` from the `MP4` for each mark with probes through `ffmpeg -ss <t> -i <mp4>`. It samples a `9x9` mean box at each probe, applies the minimum, maximum, and `contrast` gates, and prints each value.

### Caveats

- The `frame` read puts `-ss` before `-i`. The terrain shadow demo found that this move through the video is accurate only to a keyframe. It once selected an incorrect `frame` without an error. That tool moved `-ss` after `-i`, while this tool keeps the faster form. Marks at the ends of holds decrease the risk but do not remove it.

- `--quick` does no verification and exits 0.

- The gates are different from the terrain shadow demo: 110 and 8 here, compared with 60 and 12 there. Each tool contains its local threshold.

## The terrain shadow demo — `terrain_shadow_demo.py`

### Goal

Show on camera that terrain not in the walk area stops light from a fixture, as the user specified on 2026-07-13. This is a tool fixture and is not part of the program campaign. One bright fixture and a terrain rectangle are between the bot and the open floor. The bot walks through the shadow band and back into the light. The tool makes the world and scripts a deterministic walk. It samples probes from the `MP4` through the same `ffmpeg` procedure that reads one `frame` as the occlusion demo.

### Invariants

- The terrain is installed before the light. A static light's shadow geometry goes into a cache when the light is added. Thus, a light added before the terrain keeps an empty shadow for its complete lifetime. In the measured failure, the `in_shadow` probe read near 30, not 0.

- The player light is off (`player_light.intensity = 0`). This isolates the fixture.

- A mark fires on the last tick without movement in a hold, not when the player gets there. The docstring records the cause: an `mp4` move is accurate only to a keyframe. A mark during movement read correctly from memory but incorrectly from the `mp4`. Deep in a hold, the `frames` adjacent to the mark are equal. Thus, the move error does not change the result.

- The `MP4` gates must have a mean of 60 or more for probes with light and at most 12 for probes with no light.

### Verification

- Run `uv run python tools/playtest/terrain_shadow_demo.py`. Make sure that the walk gets to all 5 marks: `lit_start`, `cleared_rect`, `past_rect`, `in_shadow`, and `exit_lit`. Each probe must print with its target. The run must end with `VERIFICATION OK` and exit 0.

- Run with `--quick`. Make sure that it writes only the images. Short mode prints the `frame` count, image directory, and mark list. It does not print probe values or apply the light gates, and it exits 0.

### Implementation

The world is one polygon with the player near a warm fixture. The terrain rectangle is solid and blocks movement. Thus, the `waypoint` path goes around it before it goes into the shadow band. The fixture is near the samples.

This configuration clearly shows the difference between points with and without light. A point at a large distance can be dim only because of its distance. That can give 2 possible causes for the result.

`_drive` chases a `waypoint`. At 6 units or less from the target, it counts ticks without movement. It fires the mark when that count equals the hold count.

Above 4000 total ticks, the tool raises an error because the player cannot get to a `waypoint`. Each `frame` goes to `ffmpeg`. At a mark, the tool calculates the probe point from the world-floor position of the `waypoint`. It moves the point 22 units in the direction of the map top to clear the player `sprite`. It then applies `session.cam` for that tick. The player screen position is not a satisfactory probe because the camera holds it near the center of each `frame`.

Verification reads each mark `frame` from the `mp4` with `-ss` after `-i`. Thus, the `decoder` moves from the keyframe to the requested `frame`. The docstring records the measured failure of the faster form. The tool samples one `pixel` at the probe point and applies the gates.

### Caveats

- `--quick` does no verification and exits 0.

- The probe samples one `pixel`, not a box. The occlusion demo samples a `9x9` box.

## The `lurker` demo — `flicker_lurker_demo.py`

### Goal

Make a verification record for the shadow `lurker`. The user requested an enemy that stays in shadow until the player comes near and then attacks. The user selected not to put it in a campaign level. This tool fixture contains one dim polygon, terrain that makes a shadow, and one `flicker` that waits in that shadow. A bot walks near it and starts the attack.

### Invariants

- The `lurker` must be in state `lurk` at the marks `start`, `cleared_rect`, and `approach`.

- At `trigger_zone` or `aftermath`, the state must be `ambush` or `hunt`. Otherwise, the verification result is `FAILED`.

- The terrain is installed before the light is added, in the same cache sequence as the terrain shadow demo.

### Verification

- Run `uv run python tools/playtest/flicker_lurker_demo.py`. Make sure that the state at each mark prints and that the run ends with `VERIFICATION OK` and exit 0 when the `lurker` waited and then attacked.

- Run with `--quick`. Make sure that it writes only images, prints the marks and states, and exits 0.

### Implementation

The world is one dim polygon (`520x280`). It has one dim fixture near the entrance, a terrain rectangle, and a `lurker` in the shadow made by the terrain. The demo floor albedo is `(150, 150, 158)`.

The `waypoints` follow the top of the map, go into the `ambush` radius of the `lurker`, and continue to the last `waypoint`. This keeps the attack on camera.

`_drive` is the `waypoint` chase of the terrain demo, with a limit for each `waypoint`. After 500 ticks at one `waypoint`, the walk fires the mark and moves on. After the `lurker` attacks, its body hits the player on each touch. Knockback can keep the player out of the 6-unit target radius.

That operation is `combat`, not a defect in this tool. Thus, the record continues through it. Above 6000 total ticks, the tool raises an error.

At each mark, the tool records the `lurker` state and writes an image. The state is `dead` when the entity is gone. After the `aftermath` mark, 60 more ticks go to the video to keep an attack immediately after the mark fully in view. The last stop prints the state at each mark and applies the state requirements.

### Caveats

- `--quick` exits 0 without the state verification.

- The short modes of the 3 demo tools write images, make no video, apply no last verdict, and return 0. The light tools print no probe values in short mode. This `lurker` tool prints marks and states while it runs but does not apply the last state requirements.

- Decision open (see `spec/open-questions.md`, item `PLAYTEST-SHORT-VERDICT`):
  the user has not selected if a short mode must apply a probe or state verdict.

- The 60 ticks after `aftermath` run as a loop in the `frame` loop. The walk then completes with the standard procedure.

## The `feature` demo — `feature_demo.py`

### Goal

Record a `synthetic` `scenario` for each important enemy operation, with the camera on the entity. The docstring calculates two requirements from measured failures. First, the tool makes a `scenario` and does not search seeds. A seed search runs complete sessions without a cost limit, and a simulation change can make the selected seed incorrect. Each demo makes a world in which the operation is about to occur.

Second, the entity supplies the camera root, apex, and matrix. A player camera is not satisfactory for enemy operation that can occur off screen. In gate 61, no `cyan` `pixels` showed that an `arrival` was off camera, not that the `arrival` did not occur. A demo that cannot show its `feature` writes no file and exits 1.

### Invariants

- `Frames` stay in memory until the operation fires. A `scenario` in which the operation does not fire writes no file.

- The `soundtrack` comes from the simulation's audio `bus`. `Audio.tap` events contain volume and `pan` from the rendered `frame`. This code makes no loudness decisions.

- The video goes through the engine `encoder` (`necore.VideoRecorder`), not a `PNG` set of files plus `ffmpeg`.

- The audio mix does not clip. A maximum above 1.0 causes the full mix to be divided down.

### Verification

- Run `uv run python tools/playtest/feature_demo.py --feature shrieker_mark`. Make sure that the `MP4` goes to `media/features/` and that the fire tick prints. The last line must report the `frame`, sound, and `trace` counts plus the file dimensions.

- Change a `scenario` to prevent the operation from firing. Make sure that the tool writes no file and exits 1.

### Implementation

There are 4 `features`. Each has a `scenario` function, a name line, a text line, a tick limit, and a tail:

- `adversary_lob` has a 300-tick tail. A player comes near a `vagrant` held at `scout=flee` across a doorway. The world contains a large polygon and a small 130-unit polygon. A wall stops the `vagrant` about 117 units from the doorway. A 180-unit `lob` can thus get to it while the player stays out of the small polygon. `_walk_toward` holds at a distance of 170 units.

Without that hold, the 2 bodies went into one polygon. Records then had `shooter_polygon == player_polygon`, although the label was "across a doorway." A test world with one polygon did not show the gate 66 `frame` defect.

- `adversary_snare` has a 300-tick tail. It uses the same world and holds at 400 units, in the snare band from 180 through 560 but not in the `lob` band. The 2 polygons have light. Light in only one gave the test body RGB values of zero in 2 out of each 3 `frames`.

- `shrieker_mark` has a limit of 2400 ticks and a tail of 780. It puts a `shrieker` in full view of the player through no more than 3 connected polygons. `husk` and `mite` bodies are one polygon from it on opposite sides. A comment gives the cause for 3 polygons. After the mark, the `shrieker` goes into `RALLY` for 720 ticks. On a map with one polygon, the `RALLY` walk returns without a step.

This record showed a `shrieker` that did not move through the necessary phase. The 620-unit `spawn` distance gives each `FSM` phase time on screen. The 780-tick tail includes the `RALLY` phase. The previous 240-tick tail included only 25 percent of it.

- `adversary_return` has a 420-tick tail. It is the only `scenario` that uses a program world because a breach is a measured hole in a measured map. The `scenario` runs the program level with a bot until a breach opens. It raises an error if none opens before the limit. It then adds a collected body to `s.adversary_out` with a return set 180 ticks after that. Thus, the record first shows the breach through which the body returns.

The demo polygons fill the `frame` at zoom 0.45. A 1280-`pixel` `frame` spans about 2844 world units at that zoom. A previous `1100x750` polygon filled only 25 percent of the `frame` and left an RGB-zero border. `_room` puts the player at the `canvas` center. The engine moves a rectangle to its centroid.

A writer position of `(0, 0)` thus put the player in a corner while the lights illuminated the center. `_light` puts 4 static lights in a polygon's local `frame`.

The record loop ticks the session, drains the `trace`, and finds the `feature` event. A record agrees when its `event` or `to_state` is equal to the `feature` target. The renderer then uses the entity as its view target. The tool changes each `frame` from column sequence to row sequence before encoding.

Without that change of dimensions, the encoder made a correct `MP4`, but its image data had incorrect row layout. `audio.handle_sounds` runs after `rendering` and uses the instances from that `frame`. Thus, `pan` comes from the screen `x` coordinate in the same `frame`.

The loop ends after the `feature` tail.

After the operation fires, the tool encodes all held `frames` with an overlay. The overlay has name, text, entity state, and `>>> HERE <<<` at the fire tick. It mixes `taps` offline with `RATE`, `_load_wav`, and `_place` from `mkvideo`. It attaches the audio and a compressed replay record.

That record has one header line and one `JSON` line for each `trace` record. A `shrieker` label shows its `FSM` phase and state. An `Adversary` label shows type, `scout`, state, and `JUST RETURNED`.

Before recording, the tool removes an `MP4` with the same `feature` name. If the `feature` does not fire, it returns 1 and keeps no `MP4`. `Scenario`, `encoder`, audio, and file errors are not caught. They stop the tool with a traceback.

With `--all`, the tool calculates bitwise OR for standard return codes. The next `features` continue after a return of 1, but an error stops the remaining `features`.

A satisfactory result must have one or more held `frames` and an output file that is not empty.

### Caveats

- The tool imports `mkvideo` as a module adjacent to it. This works because Python puts the script directory on `sys.path`. It does not work as a package import from a different directory.

- `scenario_return` adds to `session.adversary_out` without an engine API. The docstring records this state write as the snapshot procedure.

- The `lob` and snare `scenarios` set `scout` and `scout_t` on the spawned enemy with the same type of write.

## The tint probe — `probe_arrival_tint.py`

### Goal

Measure for gate 63 if each body tint changes `pixels` for each `Adversary` type at each blink phase. The docstring tells the user to run this tool before the user reports body-tint results. For each phase value, the tool renders the same live `frame` 2 times. One render has the slot set, and one has it cleared. The tool counts the changed `pixels`.

### Invariants

- Only one tint-slot value is different between the two renders in a check.

- A slot is `LIVE` when one or more probed phases changed one or more `pixels`. Otherwise, it is `DEAD`.

### Verification

- Run `uv run python tools/playtest/probe_arrival_tint.py`. Make sure that all 3 slots print their `pixel` counts for each phase. They must also print a `LIVE` or `DEAD` verdict for each type: `lacuna`, `vagrant`, and `grunt`.

### Implementation

For each type, the tool makes a `400x300` probe polygon and `spawns` the enemy at a constant point. It ticks once and makes a renderer. `diff_px` clears the slot dictionary, renders at `640x360`, sets `slot[eid] = value`, and renders again. It clears the dictionary and counts `pixels` with a value that changed in one or more channels.

It probes `_arrival_flash` at 9 values from 26 down to 1. A comment records that the blink is on when `(rf // 3) % 2 == 0`. It also probes `_attacker_flash` at 16, 8, and 1, and `_hitflash` at 3.

### Caveats

- The tool writes the renderer's internal dictionaries: `_arrival_flash` and the other two slots. A name change for one in the renderer breaks the tool with an attribute error.

- The script runs at import. The probe loop is at module level, without the standard `__main__` check.

## The `marrow` demo — `marrow_demo.py`

### Goal

Record the first live `marrow` loop in `gauntlet4` as a normal program session. The `scout` moves, calls, and opens the wall. The `shelf` then sends bodies through the breach. `Combat` continues until the breach runs dry and seals. Deaths stay in the recording. After a death, the tool holds through the fade, makes a new player at the nearest seed `station`, and continues play.

### Invariants

- The session is the program simulation. The tool `spawns` no enemies. See Caveats.

- The record ends at the tick limit, when the session completes, or when the `chassis` count runs out.

### Verification

- Run `uv run python tools/playtest/marrow_demo.py out/marrow_pour --ticks 12000`. Make sure that it writes `frames`, `events.jsonl`, and `trace.jsonl`, and that the last output shows the `outcome`, breach event list, and `Adversary` `census`.

### Implementation

Arguments are `out`, `--seed` (default 2200), `--ticks` (default 12000), `--every` (default 5), and `--zoom` (default 0.45). The help text records the user's 2026-07-28 decision that play, record, and `batch` all use this same zoom.

The player state copies `FULL_LOADOUT` with full health, `dmg_taken_mul` 1.0, and `chassis` 3. A comment records that the start `pod` gives a new player after each death. Without this operation, each recording ends at the first death. The loop is the same as the `batch` recording loop: audio `tap`, tick-clock music, renderer plus HUD, and `frames` each `--every` ticks. It adds a `TraceWriter` that drains the session `trace` on each tick.

On death, a `linger` counter starts. At `linger` 90, the tool calls `session.respawn_at_station()`. If the call returns `true`, it sets the counter to 0 again. If the call returns `false` at 90, the tool does not try it again. The session stays in its death state and continues to tick. The loop stops once `linger` is more than 180.

No remaining `chassis` thus causes one respawn call to return `false`. The record then ends after the death-state wait. The tool reads `trace.jsonl` and prints each `breach_lifecycle` event, the `outcome`, and the `census`.

### Caveats

- Defect: the module docstring does not agree with the code. It states that the demo `spawns` `Adversary` `scout` bodies behind the opening path, but the code `spawns` none. A comment after it correctly states that the level contains the `Adversary` group and that the demo records a normal session. The `submit.py` docstring has the same incorrect text about `spawn`.

## The `marrow` `batch` — `marrow_farm.py`

### Goal

Give measured data about the effect of `marrow` on difficulty. Only measurements from this tool can give the result. It runs a set of normal `gauntlet4` seeds without a window with `HumanBot`. It prints `marrow` measurements for each seed and totals for all seeds.

### Invariants

- The sessions use program requirements with no added `harness` help. Their
  difficulty is `hard`. “Usual” here refers to the session path.

- A body in `session.adversary_withdrawn` does not count as a kill. Kills and entries in `session.adversary_withdrawn` have different counts.

### Verification

- Run `uv run python tools/playtest/marrow_farm.py --seeds 2 --ticks 2000`. Make sure that one line prints for each seed and that the totals print as `JSON` and are written to `out/marrow_farm.json`.

### Implementation

Flags are `--seeds` (a count, default 16), `--seed-start` (default 1), `--ticks` (default 24000), `--level` (default `levels/gauntlet4.json`), and `--out` (default `out/marrow_farm.json`).

For each seed, the tool ticks a session and drains the `trace` on each tick. It counts breach `opened` events (with a tick list and the first tick), `dry*` events, `sealed` events, send decisions with the count that `knows_position`, and `shelf_replaced` events. The `dry*` events divide by their `detail` text: `apse seam`, or `96u seam` with a count map by polygon.

After the run, it records `survival`, kills, and the start and end `census`. It gets the 2 counts from `session.adversary_lost` and `session.adversary_withdrawn`. A previous `census`-difference calculation counted an entry in `session.adversary_withdrawn` as a kill.

The `survival` set contains each row where `dead` is `false`, for example completed rows and tick-limit rows. The `survival` rate divides this count by all rows. The mean death tick uses only death rows and is `null` when there are none.

The mean and minimum values for the first breach use only first ticks that are not `null`. The 2 values are `null` when there are no first ticks for a breach. Event values are sums.

The send and killed `scout` values are means across rows. The fraction for bodies that know the position is their total divided by total sends. Its denominator is 1 when there are no sends. `geometry_migration_worklist` lists wall-dry polygons from the largest count to the smallest.

With `--seeds 0`, divide and mean calculations raise errors. The tool writes no result.

### Caveats

- The `dry*` event `classification` reads parts of the `detail` text. A change to that engine text breaks the `classification`, and the tool prints no warning.

## The video tool, sound mix — `mkvideo.py`: `build_mix` and the mix functions

### Goal

Make a record's complete `soundtrack` without a live mixer from the audio `taps` in `events.jsonl`. Use the same WAV `bank` that the simulation plays. This gives simulation audio to a record made without a window or live mixer. The music layer makes the live music-engine output in 2 versions. One is the chunk-queue mixer, controlled by `music_bank` and `music_bar` `taps`. The other is the previous 3-`stem` mixer.

### Invariants

- Sound `placement` uses the volumes and pans that the simulation calculated at recording time. This code makes no loudness decisions.

- The last mix does not clip. A maximum above 0.9 scales the full mix to 0.9.

- A WAV that is not on disk prints one line and is not in the mix. It does not stop the mix.

- At a death stop, all music cuts at the specified sample and has no sound until the engine starts it again. Sound effects continue.

### Verification

- Run the video tool on a recording with `taps`. Make sure that it writes `mix.wav` in the recording directory as 16-bit audio with 2 channels at 44100 Hz.

- On a record with a death, make sure that the music has no sound until the next `bar` `tap` while sound effects continue.

### Implementation

`build_mix` makes a float array with 2 channels that is one second longer than the video. It then adds these layers:

- Ambience: each `ambience` `tap` loops its WAV from its timestamp until the next ambience `tap` or the end. An empty name makes a span of silence.

- Heartbeat: each `heartbeat_on` `tap` loops until the subsequent heartbeat `tap`.

- Effects: each `sfx` `tap` puts its WAV once. Left `gain` is `(1 - pan) * vol`, and right `gain` is `pan * vol`.

- Music, as stated below. The maximum limit and WAV write follow.

`_load_wav` reads from `game/assets/sfx/` with a contract of 44100 Hz and 16 bits. It folds 2 channels into one and caches the result. Missing files are also cached. `_place` adds a mono sound to the stereo array at a specified time, with an optional loop endpoint.

`_mix_music` selects the version. When a `music_bank` `tap` is in the events, the chunk-queue mixer runs. The engine records its `bank` selection in `taps`, not in environment configuration. The user made this decision on 2026-07-16. Without this `tap`, the previous mixer uses the `hymn01` `bank`.

The chunk-queue mixer, `_mix_music_rich`, renders into its local array. Thus, a stop can cut music but does not change sound effects. Its `music_bar` `taps` contain the complete decision for each `bar`: a form `bar` number and each lane in `lane:key:gain` form. Its `music_bank` `taps` contain the engine's `bank` transition.

`music_jump` `taps` divide into loop returns, identified by a `~s` name suffix, and hard changes. `music_halt` `taps` identify deaths. `music_riser`, `music_riser2`, `music_sting`, and `music_stab` control their related layers. The tool finds a named `bank` in `game/assets/music/` or `out/banks/` and reads its `bar` length of `240 / bpm` seconds from `bank.json`.

The specfile records these `bar` facts:

- A lane key can contain two suffixes. `~f` marks a last `bar` with `gain` that falls to zero across the `bar`. `@N` selects a free position because the `monk` voice contains its `bar` clock, not the form number.

- `Bar` 0 fill: the engine starts lanes before the first `bar` `tap`. The mixer thus puts the tail of the `bar` slice before that `tap` and cuts it to end at the `tap`. A comment records the measured incorrect procedure. A full `bar` at time 0 added a second `bar` slice on the first and made `RMS` 0.040, not 0.033.

- `Bank` change with `ROTATION_XFADE` on: lanes from the previous `bank` continue in a deterministic form. They use the next `bars`, the same key, and the held `gain`. They then fade out across 2 `bars`. Each lane in the new `bank` uses one continuous fade-in across 2 `bars`. With the constant off, the tool renders the previous hard cut for verification only.

- The `holy` voice lane has continuity requirements. At a change, it fades the previous line across 0.5 `bar` while it starts the new line. This prevents a cut in a spoken unit and lets only one tail play. On a loop return to `bar` 0, it adds the `prayer_tail` `stem`. A transition from a `bar` with no sound has no entry `ramp`. A comment records a previous interval with no sound and a transition at 387 seconds.

Each voice `gain` change spans the full `bar`. A measured 0.29 `gain` step caused a 5 dB connection defect. The voice must not step or receive a lower `gain` for a short time.

- Other lanes: a `gain` increase equal to or more than `COMEUP_DELTA` (0.4) receives a 0.5-`bar` `ramp`. A `bar` in the window after a `music_riser2` `tap` receives no such `ramp` because it supplies the sudden change. A hard change applies a `ramp` to each lane other than `holy`, `bed`, and `monk`. These continuity lanes do not decrease for an `arrival`.

Loop returns have no `ramp` by default. `LOOP_SEAM` selects `clean`, `micro`, or `comein`. `micro` applies a short `crossfade` across the seam, while `comein` gives each lane a 0.5-`bar` entry. Tests on 2026-07-17 selected this variant.

- Each lane `gain` multiplies by 0.8. A stop makes the music array 0 from the stop to the `bar` `tap` that follows.

The `riser` `stem` is put at each `envelope` start and increases into its hit. Its scale is the tapped `envelope` times 0.85. `music_riser2` puts the `riser_half` `stem` at its value times 0.85. The tool puts stings at 0.8 and stabs at 0.7, then folds each to one channel.

The previous mixer loops the `prayer`, `contempt`, and `stalwart` `stems` until a stop. Step gains come from `music_vals` `taps` as the square root of each value, while the `riser` `stem` uses its tapped `gain` times 0.85. A gain decrease fades across 1.5 `bars` at 140 `bpm`, as specified by the user. A gain increase steps immediately. Stings are put at 0.8.

### Caveats

- The previous mixer's fade for a gain decrease runs a Python loop for each sample, or 44100 iterations for each second. This path is slow for a long record.

- `_load_wav` uses `assert` for the format contract. With `python -O`, the contract is gone.

- The comment above the `micro` seam calls it 100 ms. The window constant is `0.05 * RATE` on the 2 sides of the seam.

- The chunk-queue mixer keeps a `prev_idx` value that no code reads. This value has no effect.

- The `pan` calculation must have `pan` from 0 through 1 and volume at or above 0.
  `_place` checks no range. A value external to these ranges can apply a negative
  channel `gain` or increase a channel before the maximum limit.

## The video tool, telemetry overlay — `mkvideo.py`: `overlay_frames` and its helpers

### Goal

Add a music telemetry area to each `frame`. It contains a `frame` counter, a `status` line, and 3 input meters. Each meter shows values before and after the `filter` operation, while text lists the 3 largest components of each input and the `agg` `census`. The area also contains a `strip` for each of 9 chunk lanes, plus `riser`, `sting`, and `stab`.

Each `strip` displays a measured `waveform` below a `playhead`. The `now:` and `nxt:` labels contain the `stem` and form `bar`. Thus, a lane with no sound continues to show an engine decision, not a playback failure. A ticker includes intensity events, transitions, loop returns, boss releases, and `riser` changes. At death, all lanes use RGB values of zero and a large `DEATH — MUSIC HALTED` line is shown.

### Invariants

- The complete operation must make about 8000 `frames` quickly. A runtime near 3600 seconds is too slow. The tool thus reads each `stem` once, decreases its sample rate once, and builds lane timelines in one traversal. Each `frame` `waveform` is an array slice with no Python `pixel` loop.

- The `waveform` moves as one solid piece. The window start aligns to an integer times the `bin` count for each `pixel` column. Thus, an audio `bin` always maps to the same `pixel` in the window. This is the `shimmer` correction from 2026-07-17.

- The lane scale uses the maximum across the full `timeline`, not the window on screen. A window scale makes the shown level change as data moves (correction number 2).

- `nxt:` flashes only when the queued key changes. A normal advance to the next `bar` keeps the key and must not flash (correction number 1).

- Each lane ID is above its local `strip` (correction number 4).

### Verification

- Run the video tool with `--overlay` on a record with music `taps`. Make sure that `overlay_frames/` contains `JPEG` `frames` with telemetry and that the `playhead` follows time. A death must display `DEATH — MUSIC HALTED` with lane `strips` that have no sound.

### Implementation

`_build_lane_timelines` makes a maximum `timeline` at 200 `bins` for each second. A `stem` first becomes pairs of minimum and maximum values at 210 `bins` for each second, with 210 samples in each `stem` `bin`. The tool does not use a last group that is not complete. For a destination interval, the code selects and clamps source index `a + floor(i * source_count / destination_count)`. This maps the 210-`bin` data to 200-`bin` data without interpolation.

Chunk lanes are assembled `bar` by `bar` from the `music_bar` data. The `bank` is the last `bank` event at or before the start of the `bar`. A `bar` that overlaps a `bank` change keeps its start `bank` for the complete interval. The next `bars` use the new `bank`.

The `stem` slice receives the `bar` `gain` and a `ramp` for a last `bar`. The free suffix `@N` selects a slice by the lane clock. The `riser` `timeline` puts maximum blocks from the `bank` at its start. `sting` and `stab` use the `bank` active at their event time.

`_lane_wave_rgb` renders one lane window without a `pixel` loop. It divides the window into `pixel` columns, finds each column's minimum and maximum, and paints the rows between those values.

The area starts with a `status` line with the `frame` counter, time, `bank`, form `bar`, and `crossfade` state from `music_dbg`. It then shows the 3 inputs. Each has a name, raw meter, filtered meter, and text for its 3 largest components (`ct`, `st`). The `agg` `census` and the lanes follow.

For each chunk lane, `now:` is `stem[bar]`, with a `~F` mark on an end `bar`. `nxt:` is the queued `stem` and `bar` from the subsequent `bar` `tap`. The `riser` lane shows its live value. `sting` and `stab` show `hit` for 0.3 seconds after a start.

An outline in the first RGB channel flashes around a lane for 0.45 seconds after its `music_int` event. A hard change flashes around all live chunk lanes. The ticker prints the last 3 events in a 2.5-second window. Its event labels are `INT`, `JUMP`, `LOOP`, `REL boss-comedown`, `STING`, and `STAB`. It also shows `music_riser` transitions from or to zero. `JUMP` is bright.

`LOOP` is dim and does not flash. `Frames` are written as `JPEG` images at quality 90.

### Caveats

- The ticker does not contain `music_halt` because the large state line shows it.

- The telemetry area is 200 source `pixels` wide at the selected scale. It extends across the right side of the simulation `frame`.

## The video tool, CLI — `mkvideo.py`: `encode`, `cut_segments`, `main`

### Goal

Give the video tool's CLI operation. Make the mix and encode the `MP4`. Make the overlay when the caller sets `--overlay`. Cut and connect selected segments when the caller sets `--segments`.

### Invariants

- The `frame` rate flag must equal 60 divided by the recording's `--record-every` value. The help text tells this. The tool cannot find an incorrect value.

- Without `frames`, the tool prints an error and exits 1.

### Verification

- Run `uv run python tools/playtest/mkvideo.py --rec DIR --out run.mp4 --fps 30` on a recording. Make sure that `mix.wav` is written in the recording directory and the `mp4` at the output path.

- Run with `--segments "12-40,95-120" --labels "one,two"`. Make sure that the output contains only those two spans and that each label is there for its first 3 seconds.

### Implementation

Flags are the necessary `--rec` and `--out`, plus `--fps` (default 30), `--scale` (default 2), `--overlay`, `--segments`, and `--labels`. The length is the `frame` count divided by the `frame` rate. The mix is made first. With `--overlay`, overlay `frames` render into `overlay_frames/`, and the encoder reads them with the scale applied before this step.

`encode` reads from `frames_dir` when supplied and from the recording directory when it is not supplied. It selects `JPEG` only when `frame_000000.jpg` is there. For all other conditions, it selects `PNG`. It gives `FFmpeg` the `pattern` `frame_%06d.<type>` in that directory but does not check `frame` indexes or mixed file types.

Output configuration values are `libx264`, `crf 20`, `yuv420p`, `aac` at `160k`, and `-shortest`. Each output `pixel` copies the nearest input `pixel` to make each `frame` `640*scale` by `360*scale`. The encoder does not apply this scale when overlay `frames` include it before encoding.

`cut_segments` encodes the complete video before it cuts each span. When supplied, `drawtext` shows a span's label for its first 3 seconds with the repository font. The text has equal RGB values of 255 and a border with RGB values of zero. `FFmpeg` connects the parts with `-f concat` without encoding them again.

### Caveats

- With `--segments`, the middle file `full.mp4` goes into the recording directory and stays there.

- The caller must obey the `frame` rate contract. An incorrect value makes time longer or shorter compared with the audio. No code finds it.

## The `bundle` tool — `submit.py`

### Goal

Make the artifact `bundle` for a change. The change agent records the run, and the `judge` only examines it. A previous gate made a different recording with a command from its prompt. That command then changed to a demo script.

The demo script's docstring stated that it added `scout` bodies. Thus, the gate examined a prepared world. This tool uses the program entry point without a fixture or special condition.

It gives the `judge` a versioned `bundle`.

### Invariants

- The recording CLI instruction is `python -m perihelion` with `--autoplay`: the program entry point.

- The `bundle` names its `build`: the short `git` hash, plus `-dirty` when tracked files changed.

- The tool changes the output path to an absolute path before recording starts. Thus, a `-o` path that is not absolute continues to identify the same location from the repository root and the simulation directory.

- A failure step ends the run with an error. The tool stops at the first failure.

### Verification

- Run `uv run python tools/playtest/submit.py -o out/submission --seeds 2 --ticks 1200`. Make sure that the output contains `run_s2/`, `run_s2.mp4`, and contact `sheets` for injury ticks. Make sure that `manifest.json` contains `build`, level, ticks, zoom, and one entry for the seed.

### Implementation

Defaults are seeds `2,4,7,11`, level `levels/gauntlet4.json`, 14400 ticks, zoom 0.45, and a 6 `frame` contact `sheet` span. `build_id()` reads the short `git` hash and dirty state, or uses `nogit`.

The tool changes `a.out` to an absolute path before it makes that directory. For each seed, `record` runs the simulation without a window from the `game/` directory with `--autoplay --bot aggro --mute --zoom 0.45 --seed N --record DIR --record-every 3 --record-seconds ticks/60`. It then runs `mkvideo.py` on the recording to make `run_sN.mp4`.

`session_trace(seed)` examines `game/out/sessions/` and finds the newest `trace` with a header `argv` that contains `--seed N`. `frame_index` maps ticks to written `frames` with `frame` records in `events.jsonl`. `hurt_moments` collects `player_death` ticks and player `damage_applied` ticks, puts deaths first, and keeps at most 6 events. For each event, the tool selects the first written `frame` at or after its tick.

It runs `ghost.py` with that `frame` as `--at`. This writes maximum, mean, and contact `sheet` images. The manifest records each event tick, `frame`, type, and contact `sheet` name.

The last line states that the `judge` examines this `bundle` and does not make a different recording.

### Caveats

- The `trace` lookup uses only the seed. It sorts files by time and searches the newest first. If a new run writes no `trace`, a previous run with the same seed can agree.

- Defect: the tool accepts artifacts from a previous run's `trace`. It checks no `build` ID, level, start time, or record path.

- The injury tick list is limited to 6 entries. A session with more injury events does not include those after the first 6, with deaths kept first.

- `manifest.json` records each contact `sheet` name with the `<stem>_sheet.png` `pattern` that `ghost.py` writes in `all` mode. The tool does not check that the file is on disk.

- Defect: the tool accepts a missing contact `sheet`. When `ghost.py` returns 0 without that file, the manifest names it. The `bundle` returns a zero `status`.

## The state of `tools/dialogue/`

### Goal

Record the state of the second directory in the scope of this specfile. `tools/dialogue/` holds no Python source files. There is no source code to record.

### Invariants

- The directory holds only bytecode caches and an empty test directory.

### Verification

- List `tools/dialogue/` and the directories in it. Make sure that they contain no `.py` files.

### Implementation

There is no implementation. The bytecode in `__pycache__/` names modules from a previous source set. They are `generate`, `judge`, `comprehension_check`, `marathon_monologue_check`, `naturalism_rank`, `regen_scenes3578`, and `script_v2_naturalism`. Other names are `scene0_whole`, `scene3_whole`, `scene4_whole`, `scene5_whole`, `scene7_whole`, `scene8_whole`, and `t1_experiment/generate_t1`.

### Caveats

- The sources are removed. Only bytecode for Python 3.11 and 3.14 stays, and bytecode is not a unit of this specfile.

- `audio_judge.py` states that its cost log follows the name `pattern` of `tools/dialogue/judge.py`. That source file is no longer in the repository.
