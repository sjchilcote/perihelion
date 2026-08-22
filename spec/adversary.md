---
This specfile covers the `Adversary`: the signal field, the single senses API, the coordination rules, the scout decisions, the call medium, the hub, the `marrow` economy, and the `CORE` system. The module `sim.py` composes these units, and its spec is not in this file.

---

# The `Adversary`

The `Adversary` is the enemy side of `PERIHELION`. One part does not read the internal state of a different part. The parts write and read one signal field. They see through one senses API. Functions without state changes turn their views into decisions. The `marrow` uses one reserve for all enemies.

Enemies move through breaches. The hub is an isolated space of 24 polygons that contains the enemies before they are sent.

## `SignalField` — the 9 signal fields (`game/perihelion/signals.py`)

### Goal

The signal field is the data that all `Adversary` systems write and read (`U4`). Each polygon holds one value for each of the 9 signal types. A value spreads hop by hop through the portals, and it does not go through a wall. It also fades with time. The systems coordinate through these signals, and they do not read the internal state of a different system.

The engine calculates exponential decay from elapsed time and the tick of the last change. A polygon without a new signal fades at the same rate as one with a new signal each tick. The separation in time comes from the half-life values, not from the signal level (approved). The spread runs on a constant interval of 15 ticks (0.25 seconds), and the read times do not change that interval. A read does not change the state, thus the read frequency cannot change a value.

The 9 types, each with its half-life in seconds, its spread in 1 second, and its hop gain:

- `DISTRESS` — 45, 0.12, 1.0.

- `DANGER` — 180, 0.0, 1.0.

- `NOISE` — 3, 1.20, 1.0.

- `TRAIL` — 12, 0.0, 1.0.

- `PATROL` — 60, 0.0, 1.0.

- `MUSTER` — 1, 1.8, 0.35.

- `GARRISON_INTERIOR` — 1.5, 0.9, 1.0.

- `GARRISON_REACH` — 2, 0.7, 1.0.

- `KIN` — 8, 0.45, 1.0.

### Invariants

- Each polygon holds one value for each signal type.

- A read does not change the state.

- A signal crosses only a live portal. A sealed doorway is not in the neighbor lists, thus no signal crosses it.

- `neighborhood` with a depth of more than 1 raises `ValueError`. The permitted view of an enemy is its polygon and the polygons one hop from it.

- The `SignalKind` enum has 9 types, and an `assert` checks the count at import.

- Only the engine calculates, in `engine/necore/src/signals.rs`. This module holds only the enum boundary, the neighbor lists, and the frozen view types.

- The module uses no random values and does not read the system clock. The replay property of the sim stays.

### Verification

`game/tests/test_signals.py` checks these results:

- The read frequency does not change the values. A field that a test reads each tick agrees with a field that a test reads only at the end.

- `neighborhood` with a depth of 2 raises, and the one hop neighborhood does not show a polygon 2 hops out.

- Each type keeps its stated half-life and its stated spread rate, and `MUSTER` decreases fast at each hop.

- A disconnect stops the transfer between 2 polygons immediately.

- `drain` removes not more than the given capacity. All 9 fields use the same capacity.

### Implementation

`SignalKind` is an enum with the 9 types. `_SPEC` maps each type to the numbers in the Goal list. These are its half-life, spread rate, and hop gain. The hop gain below 1 for `MUSTER` is a faster decrease at each portal. `_DECAY_PER_TICK` calculates a fade ratio for each tick from `_SPEC`.

`SignalField` is a typed layer on the engine type `necore.SignalField`. Construction keeps the world, calls `necore.SignalField(tick)`, and builds the neighbor lists. Type values cross to the engine as index numbers, in the enum sequence, through `_IDX`.

`on_topology_changed` builds new neighbor lists. Each list contains the target polygons of the live portals of one polygon. The function then sends the lists to the engine. The sim calls it after each runtime connect, disconnect, or polygon add.

The write functions `emit`, `emit_many`, and `emit_at_least` go to the engine. `emit_at_least` lifts a value to a floor. This is the trail operation: a new crossing sets `TRAIL` to full. More crossings do not increase it without limit.

The read functions: `sample` returns one value. `neighborhood` returns a frozen `SignalNeighborhood` with the center polygon and its value map. It also has one `(chamber, values)` pair for each adjacent polygon. `total` and `totals` return world sums for each type. `deposit_doorway_trail` and `doorway_trail` write and read a trail mark for one edge of one polygon.

`step_to` moves the spread forward to the given tick, in full 15-tick steps. An interval of less than 15 ticks stays until a subsequent call completes it. The Python layer sends a tick less than the active tick to the engine without a check. The decay formula uses elapsed time and has no simulation step. The `SignalField` section of `spec/engine-core.md` contains the full spread calculation.

`drain(polygon_weights, capacity, tick)` uses the weights in sorted polygon sequence and the signal types in enum sequence. It calculates `weighted_total` as the sum of `value * weight`. Its scale is `min(capacity / weighted_total, 1)`. It removes `value * weight * scale` from each cell and clamps each cell at zero. The return value is the sum of the calculated cuts.

`spec/engine-core.md` contains the full engine operation. Its `SignalField` defects include the result of a weight more than one.

### Caveats

- The Python numbers do not go to the engine. `_SPEC`, `_DECAY_PER_TICK`, `SPREAD_DT`, `TICK_RATE`, and `_EPS` stay in Python, and the engine holds its copy of the numbers. The table here is a record for the reader. Its values can be different from the engine values. `_DECAY_PER_TICK` and `_EPS` have no use in the `PERIHELION` code.

- The comment on `GARRISON_INTERIOR` names a special condition for 2 fronts. The condition lives in the engine and is not in this module.

- Two portals between the same pair of polygons put the neighbor polygon 2 times into the neighbor list. Two transfers between that pair then occur during spread.

- The docstring of `drain` tells that `U13` reads it. No runtime module calls `drain` or `total`. Only the tests call them.

- The module cannot identify an expired neighbor list. When the sim does not call `on_topology_changed`, signals cross the previous topology graph.

- `neighborhood` with a depth of 0 returns the values of the center polygon and an empty adjacent list.

## `SenseQuery` — the single senses API (`game/perihelion/senses.py`)

### Goal

Enemies can see (`U3`). Each perception query goes through this one API, thus no system reads a different system for perception data. The API has 3 query types. The types have different depth limits:

- `frame` — the local view: entities with a satisfactory view test. It includes the polygon of the observer and polygons connected through one portal. A deeper request raises.

- `sight_of` — view of one target along a sightline, as deep as the world shape lets it go. The decision dated 2026-07-19 rejects a limit of one portal for view. An enemy that stops when the player steps across a threshold does not stay in combat. The engine raycasts cross-polygon view records. A path in one polygon applies to two bodies there, as given in the defects below.

- `find` — a search for entities of one tag, sorted by the path distance.

The result is a `Track`, not a position. A `Track` is a report of one view record. It holds the entity id, the position as a `necore.Coordinate` changed into the space of the observer, and the tick. It also holds the path distance, the straight line distance, and the portal depth.

A number pair is correct in one coordinate space only. Gate 66 gave `p=0.04`. 3 functions each used the difference between positions in 2 different spaces. That difference is not correct when weapon fire goes across a polygon. This occurred for 63 of 64 recorded weapon events. A `Coordinate` does not let code calculate that difference (see `docs/FRAME_SYSTEM_DESIGN_20260729.md`).

The API selects the shortest route through the assembled world. It measures total distance, not hop count. `every_route` returns each different image that the engine finds in 12 hops. It uses image budgets that increase. Each search and the generator are finite with this set hop limit.

### Invariants

- Each cross-polygon entity reported by `sight_of`, `find`, or `frame` has a satisfactory engine raycast check. `every_route` has no ray test. A path in one polygon for two bodies there also has no ray test.

- In the same polygon, view always applies. The polygons are convex, thus no entity in the polygon of the observer is out of view.

- `frame` with a `portal_depth` of more than 1 raises `ValueError`.

- `find` sorts nearest first, by `path_distance`.

- The position in a `Track` is a `necore.Coordinate` in the space of the observer.

- `VISION_HOPS` (12) is a cost limit on the transform walk, set far above each normal sightline. The goal: the limit must not end combat.

### Verification

`game/tests/test_senses.py` checks these results:

- An enemy in view one hop out is in the frame, and an enemy 2 hops out is not.

- `frame` with a depth of 2 raises.

- `sight_of` goes deeper than the frame.

- `find` returns nearest first, by the path distance, and `nearest` returns the first result.

- `active_portals` shows a locked doorway as a wall, and the view changes when the doorway unlocks.

- `every_route` returns different images of one entity, shortest first.

### Implementation

`Sighting` holds the agreed tags: `Player`, `Testator`, `Adversary`, `Enemy`, `Building`, `PlayerBuilding`, and `EnemyBuilding`. `tags_for(faction, role)` returns the tags together:

- The faction `"commando"` adds `Player`.

- The faction `"testator"` adds `Testator` and `Enemy`.

- The faction `"adversary"` adds `Adversary` and `Enemy`.

- The value `"building"` in `role` adds `Building`. It also adds `PlayerBuilding` for the faction `"commando"`, and `EnemyBuilding` for each other faction.

`SenseQuery` holds the world, a `describe` callback, and a tick callback. `describe(entity_id)` returns `(kind, faction, role, state_tags, group)`. It returns `None` for an entity that the senses do not include: a bullet, a pickup, a decal.

`sight_of(observer_id, target_id)`: when `describe` returns `None`, the result is `None`. Otherwise, one engine call `track_of(observer, target, group, 12, tick)` walks the route. The engine composes the portal transforms along the shortest route and does the ray test. One call replaced a Python loop across the hops. At about 270 view queries for each tick, that loop was the largest cost of the sim.

`every_route(observer_id, target_id, batch=4)`: a generator. The first requested image limit is the larger of 1 and `batch`. The generator keeps the count of tracks returned before. It requests the full list again with a limit 2 times larger. It returns only the suffix after the previous count. It stops when the returned list is not longer than the previous list.

Equal portal transforms put their positions in one engine image. The engine returns the images nearest first. A portal loop can continue to supply images until the 12-hop engine limit stops it. No ray test applies to these routes. The engine route contract is in `spec/engine-binding.md`.

`find(observer_id, tag, within_hops=2, limit=0)`: an unknown tag raises `ValueError`. The function sends `within_hops` directly to the engine `polygons_within` query. That query uses live portal connections and returns the engine `BFS` list. Its zero limit returns the observer polygon. The Python layer does not reject a negative limit. `spec/engine-binding.md` contains the binding operation for that input.

In each returned polygon, `find` drops the observer and the entities with a `describe` of `None`. It keeps the entities with the given tag.

`find` then drops each entity that does not have a satisfactory `sight_of` check. It uses a stable sort by path distance and cuts the list at `limit` (0 = all). Equal path distances keep the polygon and entity sequence from the engine queries. `nearest` is `find` with a limit of 1.

`frame(observer_id, portal_depth=1)`: a depth of more than 1 raises. The polygon list has the observer polygon and the target of each live portal. For each entity there, `sight_of` runs. The frame keeps hits with a `portal_depth` at or below the given depth. The frame also holds the result of `active_portals`.

`active_portals(observer_id)` returns a `PortalSense` for each edge of the observer polygon. It holds the target polygon, with -1 for a wall. It also holds the active flag, edge midpoint in observer space, and a depth of 0. A sealed door and a sealed breach read as walls.

`kind_of(eid)` returns the type of an entity for a holder of a `Track`. A `Track` holds no type. The identity of the entity is in the session record, not in the world shape. `describe(eid)` returns the full record.

### Caveats

- Defect: when 2 portals of one polygon go to the same polygon, `frame` examines that polygon 2 times. One entity is then 2 times in `hits`, and the 2 entries are equal.

- Defect: `track_of` reports 2 bodies in one polygon without a raycast or a terrain test. As a result, a terrain rectangle can stay between them while `sight_of`, `find`, and `frame` continue to report view. Convex polygon walls do not remove this internal occlusion.

- `frame` drops an entity in an adjacent polygon when its shortest view route crosses more than one portal.

- An entity with `role == "building"` holds its faction tags. `find` with `Enemy` returns enemy entities with the `Building` tag. `find` with `Player` returns player entities with the `Building` tag.

- If an entity does not have one of the 3 named factions, it receives no tags. Thus `find` does not return it. `frame` reports it, because `frame` filters only on `describe`.

- `find` examines only the polygons at or below `within_hops`. An entity in view but not in the query area is not in the result. The parameter limits the query cost, not view.

- A sightline that crosses more than 12 hops gives `None`. The comment sets the goal that the limit must not end combat. All `PERIHELION` shapes stay below the limit.

- The sim calls only `sight_of` and `find`. Only the tests call `frame`, `nearest`, `every_route`, `kind_of`, and `active_portals`.

- `every_route` can give many images on a portal loop, but the engine limits each search to 12 hops. The caller accepts the search cost.

- The module docstring states that `every_route` can continue without end. The set 12-hop limit makes the route set finite. The generator stops when a larger image budget returns no more routes.

## Coordination rules — pure decision functions (`game/perihelion/coordination.py`)

### Goal

The module turns permitted views into decisions (`U5`). Each function reads frozen inputs — sense frames, signal neighborhoods, numbers — and returns a decision. No function can touch the session, the `marrow`, the audio, or the render. The sim applies these calculations to the views its enemies get through the senses and the signals. The decision groups:

- The peer attack calculation. The calculation uses the fraction of its peers in the attack to set the probability that an idle enemy starts an attack. Peers not in the attack make the denominator larger, thus they hold the enemy back. The fields count as not more than one peer in the attack. Thus a strong signal event makes one enemy with no peers start an attack. The same event moves a group of 12 much less.

- The signal condition comes from the decision dated 2026-07-31. A view of the player emits `DISTRESS`. A value of `DISTRESS` at or above the limit makes an idle enemy start an attack in each state. Strong `NOISE` also makes the enemy start an attack because player weapon events have the highest `NOISE` values in the world. This condition is a fact about the world and does not count the peers.

- The 2-part track. `DISTRESS` is a beacon: it spreads, and it tells that there is combat in some direction. `TRAIL` does not spread, and it marks the last path of the player. An enemy that searches for the player follows the beacon until it finds `TRAIL`, and then follows only `TRAIL`.

- The turret `dread` comes from the decision dated 2026-08-01. An enemy that sees a turret without sufficient peers in the attack moves back and emits `DANGER` at the turret. This causes the group to select a different route. Sufficient peers in the attack cancel the `dread`.

- The `danger` hold. One enemy with no peers does not walk into a polygon with many deaths of its type. It waits at the doorway and calls with `MUSTER`, until a push collects or peers come.

- The steering budget. Separation uses acceleration first, and only the remaining acceleration goes to the target. The previous average of opposite directions pointed into the wall at a doorway. This budget replaced that operation.

- The garrison `settle` condition lets a follower stay with a `warden` after a long hold with low signal values. The route selection sends some enemies along the route with the next cost after the minimum. This prevents the group from use of only one doorway.

### Invariants

- Each function reads its inputs and returns a value, with no state change and no access to a different system.

- `quorum_excitation` stays in 0 to 1: not more than one peer in the attack of field weight.

- `commit_hazard` stays in 0 to 1 for each input.

- `allocate_acceleration` does not give more than the budget. The sum of the given quantities stays at or below the budget.

- The attack threshold band is 0.25 to 0.45. The sim selects the threshold of each enemy when it adds the enemy. Thus a different enemy can start each cascade, and a small number of enemies start a cascade.

### Verification

`game/tests/test_coordination.py`, `game/tests/test_alarm_and_dread.py`, and `game/tests/test_coord_telemetry.py` check these results:

- An enemy with a trail lock follows a new trail. A large `DISTRESS` beacon cannot pull it off the trail.

- The trail lock applies only when a trail is at or above 0.30.

- The signal condition makes the enemy start an attack at the `DISTRESS` line and at the `NOISE` line.

- An enemy moves back from a turret when it has less than 3 peers in the attack. When it has 3 or more peers in the attack, it does not select `dread`.

- Requests in opposite directions do not use an average. The request with the lower priority number receives its full vector length or the maximum remaining budget. The next request receives only the remaining budget.

### Implementation

The peer attack functions:

- `quorum_excitation(noise, distress)` — `(noise + distress) / 0.60`, held in 0 to 1.

- `quorum_fraction(committed_visible, all_visible, excitation)` — `(committed + e) / (all + 1)`. Peers not in the attack make the denominator larger. The `+1` prevents one enemy with no peers from a full fraction.

- `commit_hazard(f, threshold)` — the curve `f**4 / (f**4 + threshold**4)`, and 0 when `f <= 0`. The curve is smooth, and it changes fast around the threshold.

- `commit_probability(f, threshold)` — `0.22 * commit_hazard(f, threshold)`, the probability for each decision tick. A cascade starts at a thin edge of a group, where a small denominator makes a large fraction. It then moves into the polygon across 1 or 2 seconds.

The signal condition and the track:

- `alarmed(distress, noise)` — `True` when `distress >= 0.45` or `noise >= 0.40`. This does not use the peer attack calculation. A polygon of peers not in the attack lowers the peer fraction, but the signal condition does not count them.

- `scent_lock(trails)` — `True` when the largest doorway trail is at or above 0.30. That is a trail from the last 21 seconds, about.

- `hunt_attraction(trail, noise, distress, muster, doorway, locked)` — with a lock, `trail + 0.15 * doorway`. Without a lock, `noise + trail + 0.6 * distress + 0.4 * muster + 0.15 * doorway`. The lock cuts the pull of a doorway down to `TRAIL` only.

The `dread` and the hold:

- `dread_turret(peers_committed, needed=3)` — `True` when the peers in the attack are below `needed`. One enemy against a turret becomes a body that is not live and a `DANGER` mark with no gain. The same enemy attacks when other enemies push with it.

- `danger_hold(danger_next, committed_visible, muster_here, cross_peers=2)` — hold when 3 conditions apply. The `DANGER` in the next polygon is above 0.70. The peers in the attack that are in view are below `cross_peers`. The local `MUSTER` is below 0.60. A chase with a view record uses `cross_peers=1`: 2 enemies that see the killer go in together.

- `wants_stand_down(has_sighting, local_peak, quiet_ticks)` — `True` when there is no view record and each local field is below 0.05. The low field values must continue for 300 ticks, about 5 seconds. An enemy in the polygon of the player always has a view record, because the polygons are convex. Thus this function does not read the position of the player.

The movement functions:

- `allocate_acceleration(budget, requests)` — each request is `(priority, ax, ay)`, and a low priority number uses its quantity first. Separation has priority 0, and objective has priority 1. The budget and request quantities are vector lengths. For each positive request, the function uses the smaller value between its length and the remaining budget. It adds that quantity in the unit-vector direction and subtracts the quantity from the budget. A request at or below `1e-9` has no effect.

Opposite requests do not average. The first receives its full quantity, and the next receives the remaining budget.

- `separation_request(me_xy, me_radius, peers)` — the separation request from peers in the same polygon. For each peer, `d` is the distance between the 2 centers. `gap` is the sum of the 2 radius values plus 12. A peer at `2 * gap` or more adds no push.

A nearer peer adds `(gap / d)**2` times the unit vector from the peer to this body. The function sums the coordinate parts from all peers. At a distance below `1e-6`, the added value is `(1, 0)` without division by the distance.

- `choose_route(best_edge, second_edge, raid_member)` — when `raid_member` is `True` and `second_edge` is zero or positive, the function returns `second_edge`. Otherwise, it returns `best_edge`. The sim selects `raid_member`. See `spec/simulation.md`. `RAID_FRACTION` is 1/3.

The `settle` condition (`U10`) is `may_settle(warden_present, hostile_visible, noise, danger, held_ticks)`. It returns `True` when a `"warden"` is there and no entity of the player faction is in view. Also, `noise` must be below 0.20 and `danger` must be below 0.35. `held_ticks` must be 720 or more.

This function does not keep or clear `held_ticks`. The sim keeps the hold counter. `spec/simulation.md` contains its clear conditions. The `"warden"` record contains no follower count, origin data, or command state.

Constants that the sim reads: `SIGHT_DISTRESS` (0.50, emitted where an enemy views the player) and `TURRET_DREAD` (0.55, `DANGER` emitted where an enemy sees a turret). Also `TURRET_DREAD_TICKS` (90, about 1.5 seconds of retreat for each turret view record) and `TURRET_DREAD_COOLDOWN` (600, no new retreat for 10 seconds).

### Caveats

- Decision open (see `spec/open-questions.md`, item `ADVERSARY-DOORWAY-HOLD`): before the signal condition was added, enemies stayed in doorway holds for 61,446 of 87,662 ticks across 1,159 holds. The player's polygon was above the `danger` threshold 47 percent of the time. `MUSTER` stayed below 0.60 in all 1,461 samples. A hold had no exit. As a result, enemies stopped their response to the player. The user must select the correction.

- The signal condition replaced another calculation: one enemy walks up the `KIN` field to get help. That calculation cut the enemies that started an attack during a search from 56.7 to 31.8 in 60 seconds. The walk moves an enemy out of combat. Thus the calculation was removed. The hold problem stays open and must have a different correction.

- Recorded cause behind the 2-part track: the beacon and `TRAIL` were summed before. `DISTRESS` near a large combat measured 4.55 and went into the sum at 2.73. `TRAIL` tops at 0.80 by construction. The wide signal was stronger than the new signal, more than 3 to 1. Thus a tracker followed the wide signal while it was on the path of the player.

- Recorded cause behind the `NOISE` line: player weapon fire emitted `NOISE` 0.8, but only the peer attack calculation read it. That calculation caps the full field weight at one peer. Thus weapon fire in the next polygon made almost no change to the probability of an attack. Polygons activated one at a time, in a line, not as one response. `NOISE` has a 3 second half-life and spreads fast.

Thus the line reads as sound and not as an enemy that sees all.

- Recorded cause behind the `dread`: turrets made 56% of all kills in a measured session. Also, 74% of those kills occurred 3 or more hops from the player. Each death emitted `DANGER` where it occurred.

Thus the turrets made the polygons in front of the player dangerous before the player went in. Without the 600-tick floor on the interval, a retreat started again at each new view query. The turret stayed in view. The measured result was 746 continuous ticks of retreat, with all other decisions of that enemy stopped.

- Recorded cause behind the `danger` line: one kill emits 0.40 `DANGER` with a 180 second half-life. At a line of 0.35, each polygon behind the player path held the chase back. The hold continued for 180 seconds or more. The chase stopped at each door.

The line is 0.70, and it holds only polygons in which kills continue. A requirement of 3 peers at each position turned each pair of enemies into a shadow at a constant distance. Thus a chase with a view record uses 2 as its limit.

- `separation_request` pushes a peer at an equal position along `+x` only. A direction is better than none, and the selection is constant.

- Requests with equal priority in `allocate_acceleration` keep the input sequence, because the sort is stable.

- The module returns decisions only. The sim does each emit, each state change, and each random draw.

## Scout decisions — the caller of the `Adversary` (`game/perihelion/scouts.py`)

### Goal

The `"vagrant"` and the `"lacuna"` are personnel (`U7`). World construction puts a set number of each class in the world. A `CORE` spawns no personnel. Only they can call. This module controls where the caller walks and when it holds its position.

It also selects where a `plant` has value. It reads only the permitted `SignalNeighborhood` view through one portal. It returns polygon selections.

The module has no view of the sim, the `marrow`, breaches, or of the response to a call. When it calls and no body is free, no body comes.

The class sequence is the sequence from weak to strong: `"lacuna"`, then `"vagrant"`. `weakest_class_present` examines this sequence independently of entity sequence. It sets caller `duty` for the first class that is there. Hit points have no effect on the selection (approved).

### Invariants

- Each function reads only the neighborhood through one portal and does not change state.

- The contact walk does not target a polygon at or above the hot threshold (0.45). This signal boundary keeps the distance from player to caller above weapon range.

- The `expansion` walks do not target a polygon with `DANGER` above 0.35.

- `weakest_class_present` follows the constant sequence: `"lacuna"`, then `"vagrant"`.

### Verification

`game/tests/test_scouts.py` checks these results:

- The weakest class in the polygon receives the `duty`, and of 2 `"lacuna"` bodies only one transmits.

- The rooted transmit holds its set length, and the caller does not move in it.

- Damage stops the transmit, and the `imprint` names the polygon of the caller.

`game/tests/test_scout_authoring.py` checks these results:

- The world build sets the scout count. No `CORE` spawns scouts.

- An inactive scout becomes active when the combat comes to it. It stays inactive after `NOISE` below the threshold.

### Implementation

Two internal measures read the values of a polygon:

- `_hot(vals)` — `NOISE + TRAIL + 0.6 * DISTRESS`: how much a polygon smells of the player.

- `_quiet(vals)` — `KIN + 0.5 * PATROL + TRAIL + NOISE`: how much garrison work occurred on the ground. A low value is good ground for a garrison seed.

The selection functions, each across the center polygon and the adjacent polygons:

- `approach_target(nbh)` — the contact walk. It examines adjacent polygons in their input sequence. It drops each polygon at or above 0.45. It returns the first adjacent polygon with the largest heat above the heat of the center, or `None`. A subsequent equal value does not replace the first selection.

- `ready_to_plant(nbh)` — `False` when the center polygon is at or above 0.45. Otherwise, it is `True` when the adjacent heat maximum is at or above 0.45. It is also `True` when the center heat is 0.06 or more. A call does not start for a cold polygon with no signal in an adjacent polygon.

The function checks signal values only. Defect: it does not examine geometry, sightlines, weapon range, or the position of the player. It cannot check if the player can touch the caller.

- `safe_target(nbh)` — the `_quiet` `expansion` walk. It drops adjacent polygons with `DANGER` above 0.35. It returns the first polygon with the lowest `_quiet` value below the value of the center, or `None`. A subsequent equal value does not replace the first selection.

- `peak_target(nbh)` — the `raid` `expansion` walk. It drops adjacent polygons with `DANGER` above 0.35. It returns the first adjacent polygon with the largest `DANGER` value above the value of the center, or `None`. A subsequent equal value does not replace the first selection.

- `weakest_class_present(classes)` — the first class of `ADVERSARY_ORDER` that is in the set, or `None`.

- `root_ticks(caller_class)` — 480 ticks for the `"lacuna"`, and 360 ticks for each other class. A call holds the caller at its position for this time. A 2 second position hold comes after it (`BRACE_TICKS`, 120).

Constants that the sim reads: `POUR_OBSERVE_TICKS` (180, the time in which the caller stays and looks after a `plant`) and `FLEE_TICKS` (300, the retreat time).

### Caveats

- When the center polygon is at or above the hot line, `approach_target` returns `None`. The cause: a candidate must have more heat than the center, and it must also be below the line. When the center is at or above the line, no polygon can do the 2. The module returns no retreat target, and `ready_to_plant` is also `False` there. The sim selects the next step of the caller, not this module.

- `safe_target` tests `DANGER` on the candidates only, not on the center polygon.

- `root_ticks` returns the `"vagrant"` time for each class that is not `"lacuna"`, unknown classes included.

- No test calls `approach_target`, `safe_target`, `peak_target`, or `ready_to_plant` directly. The tests call these functions only through the sim.

## `CallMedium` — one radio channel for the world (`game/perihelion/callmedium.py`)

### Goal

Only one caller transmits at a time, and that is a property of `CallMedium`, not of the hub (`U7`). A scout holds the one `lease` and transmits. At the end, it keeps an `imprint` in `CallMedium`: the polygon, the position, the tick, and the caller class. The `imprint` expires in 15 seconds. A stop or a death releases the `lease`.

A reader removes the first live `imprint`, also when it does not use it. Calls do not wait in a queue. The `imprint` holds no reserve request, hub state, or enemy mix. Thus the caller has no view of the `marrow`, and only one caller transmits. The module has no view of scouts, hubs, or the sim: ids, ticks, and positions only.

### Invariants

- Not more than one `lease` is active in the world at a time.

- Only the holder can complete or release the `lease`.

- An `imprint` expires 900 ticks (15 seconds) after the `complete` call.

- `consume_one` removes not more than one `imprint`, the first live one. It removes it also when the reader does not use it.

- The `imprint` holds only the polygon, the position, the tick, the caller class, and the end tick.

### Verification

A second caller that requests the `lease` while the first holds it receives `None` and does not transmit. After `complete`, the `lease` is free, and the `imprint` is in `CallMedium`. `consume_one` returns and removes the first live `imprint`. A second read does not return it again. `game/tests/test_core_organ.py` checks that a dry call is used up: after a removed `imprint` that opened no breach, `pending` is 0.

### Implementation

`CallImprint` and `CallLease` are frozen data classes. `CallMedium` holds one `lease` slot and one `imprint` list.

- `try_lease(caller_id, tick)` — when a different caller holds the `lease`, the function returns `None`. When the same caller holds it, the function returns the active `lease` with its first tick. If no `lease` is active, it returns a new one.

- `holder()` — the id of the holder, or `None`.

- `release(caller_id)` — frees the `lease` when the given caller holds it. The sim calls this at a stop and at a death.

- `complete(caller_id, chamber, position, tick, caller_class)` returns `None` when there is no `lease`. It also returns `None` when a different caller holds it. These returns change no state. For the holder, the `lease` ends. The `imprint` goes into the list with the end tick `tick + 900`.

- `consume_one(tick)` — first removes each expired `imprint`, then removes and returns the first live `imprint`, or `None`.

- `pending(tick)` — the count of the live `imprints`.

### Caveats

- The `lease` has no time limit. Only a `release` or a `complete` call frees the channel. If the holder has a death and no code calls `release`, the channel stays blocked until the session ends. The sim holds those calls.

- A holder that requests again receives the initial `lease`, with the first tick.

- `consume_one` removes expired `imprints` as a side effect. Until a reader calls it, expired `imprints` stay in the list, and `pending` filters them out at read.

## `build_hub` — the `marrow` hub, a corrupted Testator cathedral (`game/perihelion/hub.py`)

### Goal

Each world contains one hub after world construction, and the hub is not `None` (`U8`). Its 24 polygons stay off the map that the player can walk. There is no connection to the world. The hop distance from each world polygon is -1 until a live breach is open. The shape is the approved one:

- The 3 apses, with the breach seams on them, and the guardian courts behind them.

- The transept, a short loop that lets bodies come around the side. The loop closes across a fold: adjacency is the portal graph, and the shell positions do not show it.

- The gatehouse, then the trunk, with the `collar` side polygons, the anchor side polygons, and the scriptorium off it.

- The long open polygon `L` as the last step, the vestibule, and the 3 source cells. No source cell is adjacent to a different source cell, and each is 10 to 11 hops deep.

The shape inspection dated 2026-07-28 sets a different convex shell for each polygon. Each shell has 5 to 9 facets of different lengths and accurate edges. Each doorway is on a set facet with sufficient length. A `70u` door uses `94u` or more, and a `96u` breach seam uses `128u` or more. The portal graph, door counts, depths from apse to source cell, and resident set positions do not change.

The `CORE` part positions and the light list also do not change. The build rejects each shell that moves them.

The hub holds its residents and its light list. Its visual `descent` effect increases with the hop depth from the apses. The residents read as a lighter mix than the bodies that the `marrow` sends.

### Invariants

The build checks these properties during construction and raises `RuntimeError` for an incorrect result:

- The door count of each polygon equals the approved graph. The build does not add a polygon with one door more than the set graph.

- The engine hop distance from the nearest apse to each source cell must be 10 or 11. The active set graph positions all 3 source cells at depth 10. The check lets a subsequent set graph use depth 11.

- Each light position and each polygon center is in its shell, on the engine shape after the cuts.

- Each hub polygon has its type (`"marrow"` or `"otherworld"`) and its `descent` value.

- Each breach seam is `96u` long, correct to `1e-6`.

Also by construction:

- Each internal connection goes through `TopologyManager.connect_equal`. Thus the scale-1 check runs about 26 times in each world build. Construction rejects the known `lens-portal` defect.

- The 3 breach seams are cut but stay not connected. The operation in `U9` connects the world side.

- The depth walk includes each polygon from an apse, or `chamber_depths` raises.

### Verification

`game/tests/test_hub_topology.py` checks the graph, the depths, and the seams. `game/tests/test_hub_shells.py` checks that the shells are convex and have the correct facet counts. It also checks that each facet has sufficient length for its door. `game/tests/test_hub_residents.py` checks the resident set against `RESIDENT_PLACEMENT` and the light count against `HUB_LIGHT_PLAN`.

### Implementation

`CHAMBER_SHELLS` maps each of the 24 polygon names to its set shell. Each entry has the corner list, doorway-facet list, and breach facet or `None`. The tool `tools/design/author_hub_shells.py` calculated and checked the shells. The checks include convexity and 5 to 9 facets. Each doorway must be on a sufficiently long flat facet: `94u`, or `128u` for a breach. No facet can be below `22u`, and no corner can be below 32 degrees.

Each shell area must be different by not more than 8 percent from the rectangle that it replaced. Each resident position must also have `16u` of wall clearance. The engine centers each polygon on its area centroid. The set doorway positions start in engine space.

The polygon groups: `A1`-`A3` are the apses, `G1`-`G3` the guardian courts, and `T1`-`T3` the transept. `R` is the gatehouse. `C1`-`C2` are the `collar` side polygons, and `N1`-`N4` are the trunk. `AN1`-`AN2` are the anchor side polygons, and `SC` is the scriptorium.

`L` is the long polygon, `V` the vestibule, and `S1`-`S3` the source cells. `_LINKS` lists the 24 portal pairs. The pair `T3`-`T1` closes the transept loop across a fold.

`chamber_depths()` calculates the hops from the nearest apse across `_LINKS`, with a walk out from `A1`, `A2`, and `A3`. It raises when one or more polygons have no path from an apse. The depths run from 0 at the apses to 10 at the source cells.

`build_hub(session, topo)`:

1. For each shell, it adds the polygon to the sim and records the index. It adds a seed (`r * 7919 + 13`) to `session.level.polygon_seeds`, because a polygon without a seed causes a renderer failure after the build.

2. It writes the type and `descent` into `session.hub_polygon_meta[r]`. The type is `"otherworld"` at a depth of 6 or more, and `"marrow"` below it. The `descent` comes from `_DESCENT_BY_DEPTH`: from 0.10 at the apses to 1.00 at the source cells. The data is kept on the session and not on the level, because the hub is part of no level. A chunk change replaces `session.level`. That change removes data parked there, and the hub then renders as standard polygons.

3. For each portal pair, it cuts one `70u` doorway at a set position on each side. It connects the 2 edges with `topo.connect_equal`. Each polygon uses its doorway positions in the set sequence. A polygon with more connections than doorway positions raises. A facet that cannot hold its door also raises.

4. It cuts the 3 breach seams at `96u` on the breach facets of the apses. The seams stay not connected.

5. `_validate` runs the checks in the Invariants.

6. It adds the light list to the static light cache after the door cuts. Thus each light wedge sees its doorways.

7. It returns a `HubLayout` with the polygon indices, the group indices, and the breach `EdgeHandle` items.

`RESIDENT_PLACEMENT` lists the 18 resident bodies by polygon. The screen classes hold the transept, and the trunk mixes ranged classes and the `"flicker"` bodies. The `breakers` are at the last polygons before the source cells.

`HUB_LIGHT_PLAN` lists 26 lights: cold `violet` at the apses and warm work light in the courts. The source cells use `violet-white`. Down the trunk, the light color stays constant, and the light radius increases from `110.0` to `140.0`. This lets the player see the deep destination from its doorway.

Colored lights have an intensity of 1/3. Above that intensity, the strong color channels become `(255, 255, 255)`. Only the source cells (0.45) and doors `R` and `V` on the deep path (0.40) use the higher set intensity.

The type value changes at depth 6, at about 0.6 of the full depth. The render mixes the 2 light models across depth (`render._ow_mix`), thus the change reads as continuous.

### Caveats

- `build_hub` puts no bodies in the world. The sim reads `RESIDENT_PLACEMENT` and the `shelf` list of the `marrow`, then spawns the bodies. The `CORE` part polygons (`C1`, `C2`, `SC`, `S1`-`S3`) keep no residents, because the `CORE` parts are there. `AN1` keeps one `"brute"`. The resident condition includes only `C1`, `C2`, `SC`, and `S1`-`S3`. It does not include the anchor side polygons.

- The comment lists the resident mix as 60% screen, 18% ranged, 10% `mobility`, and 12% `breaker`. The 18 set bodies contain 61% (11), 17% (3), 11% (2), and 11% (2). The comment numbers are the approved targets, and the set bodies come near them.

- The connection sequence and the set doorway-position sequence must agree. The check compares only their counts. It does not check that each doorway position is for the correct connection.

- The check reads the light positions and the polygon centers. The set resident locations have no set positions in this module.

- The depth check reads the engine `hop_distance`. Thus it checks the cut shape again, not the Python pair list.

## `MarrowController` — the reserve economy and the send (`game/perihelion/marrow.py`)

### Goal

The economy is a closed loop, and its inputs do not include the combat (`U9`). Regeneration follows how empty the reserve is, not how the combat goes. This module cannot read `DISTRESS`, kills, player health, or difficulty, because its inputs hold no such data.

When the reserve is below the cost of the next enemy, the `marrow` waits for that enemy. It does not send an enemy with a lower cost as an alternative. Thus the pause at the gate measures the reserve with no error. Breaches do not read the reserve and do not see other breaches. The `marrow` controls send, and only the `marrow` compares the breaches.

The decision dated 2026-08-01 calls for about 10 times more enemies. The world must stay full of enemies that work against the player. In a 1,440-second session before the change, the enemy count fell from 277 to 15 and did not increase again. Regeneration was `0.35/s`, against a mean enemy cost of 3. Thus the `marrow` output was about 7 enemies in 60 seconds, while the player killed 17. The reserve was at zero for 1,320 of the 1,440 seconds.

Regeneration was the first limit and not the only one: one send counter controlled all breaches. Thus 3 breaches sent no faster than one. The reserve kept 290 of 300 while the `pour` was near 27 in 60 seconds. The 2 corrections are the regeneration constants and division of the send interval by the breach count.

The approved `pour` shape starts with an initial wait of 3 seconds. A burst from the `shelf` follows, and production follows the burst. The burst gives one enemy each 0.6 seconds, and production gives one enemy each 2.2 seconds. The `shelf` is a set of bodies at the entrance that the `marrow` can send. The entrance becomes weaker after these bodies are sent. The safest entry time is while the `shelf` is out in the world.

### Invariants

- The parameters of `step` hold no data about the player or the combat. This input boundary is structural.

- The `marrow` does not send an enemy with a lower cost when the selected enemy cost is above the reserve. This applies at the gate and in the `shelf`.

- During controller operation, the reserve does not go above 300. Only the `blackout` call to `set_debt` moves it below zero. `pay` raises when the reserve is below a nonnegative cost.

- The `pour` queue of the `shelf` comes from the bodies at the set positions, again at each step. A guardian killed at its set position goes out of the records, the same as one that walked out.

- When the reserve is below 1.0, no new breach opens. The caller removed the call `imprint` before the `marrow` step. The `marrow` cannot use it after the reserve increases.

- The `shelf` fills again only while no breach is live. Each new guardian comes 720 ticks (12 seconds) or more after the last guardian.

- More than one breach divides the cost total, not the body count. The next enemy goes to the breach with the most credit, and its cost decreases that credit.

### Verification

`game/tests/test_marrow.py` and `game/tests/test_marrow_shelf.py` check these results:

- The rotation across many sends returns the approved mix.

- The pause starts when an enemy cost is above the reserve. That enemy holds the gate until the reserve is at or above its cost.

- The negative reserve from a `CORE` kill increases to zero at the negative-state rate. The `blackout` ends without a timer.

- The `shelf` queue follows the body count, and regeneration adds at most one guardian for each 12 seconds.

- A breach seals for the recorded cause, and a body that goes through starts the idle clock again.

### Implementation

`ReserveDepot.advance(elapsed_seconds, capacity)`: while the reserve is negative, regeneration is `1.0 * (1.0 + 2.5)` reserve units in 1 second. Capacity does not apply. This supply means that a `blackout` ends, also when the `CORE` parts are not live. While the reserve is zero or positive, regeneration is `1.0 * (1.0 + 2.5 * empty) * max(0, capacity)`. Here, `empty` is `1 - reserve / 300`, clamped to 0 through 1. The new reserve is the smaller of 300 and `reserve + regeneration * elapsed_seconds`.

The function does not reject a negative time interval or a capacity above 1. A negative time interval can decrease the reserve. A capacity above 1 can increase regeneration above the specified full capacity.

`can_pay`, `pay`, and `set_debt` are the full reserve API. `CORE_KILL_DEBT` is -320, about 90 seconds at the negative-state rate of `3.5 reserve units/s`. The number is scaled with the regeneration it is measured in.

`CostFairScheduler`: `accrue(amount=1.0)` adds `amount` to the credit of each live breach. A new breach starts at the sum of the active credits divided by their count, or 0 for the first breach. `assign(unit_cost)` returns `None` when there is no breach. If there is a breach, it selects the breach with the most credit and decreases that credit by the cost. Equal credit selects the smallest breach id. `DISPATCH_COST`: `"mite"` 1, `"husk"` 2, `"spitter"` 2, `"shrieker"` 3, `"flicker"` 3, `"brute"` 4, `"warden"` 8.

`Breach` is a hole in the material. It cannot be killed, and it has no view of reserves or of other breaches. It counts the bodies that go through, and it obeys close requests.

`note_crossing` records the tick of a crossing. `note_interest` records the last tick at which a hub-side enemy selected the breach as its route. `request_close(reason, tick, grace)` records the first close request, with its end tick. `cancel_close(reason)` clears a request with that cause.

Before `cancel_close`, an `"exhausted"` close kept its end tick after the reserve was filled again. Seals then fired on a good economy. That was a defect (run 39: seals at reserve 3.19 and 4.08).

`should_seal(tick)` returns in this sequence. It returns `"idle"` after 2,700 ticks (45 seconds) without a crossing. Then it returns a recorded request after its end tick. Last, it returns `"no_route"` after 720 ticks (12 seconds) without hub-side selection.

`MarrowController.step(tick, imprint, live_breaches, shelf_census, dispatch_factor, capacity)` runs each tick and returns a list of commands. More than one command can occur in one call. Commands stay in the sequence below. A `"replace"` command can be before an `"open"` command. An `"open"` command can be before a `"dispatch"` command. One seal for each applicable breach can follow them.

1. It moves the reserve forward by 1/60 seconds at the given capacity.

2. It counts `shelf_census` by class. It then walks `GUARDIAN_SHELF` in its constant sequence. For each entry, it adds that class to the queue if its remaining class count is positive. It then decreases that count.

   Bodies above the `shelf` class count have no effect. The count contains classes, not set positions or body identities. Thus the queue cannot identify a body at an incorrect set position.

3. While no breach is live, it steps the `shelf` fill. It subtracts the recorded class counts from the `GUARDIAN_SHELF` class counts. It selects the first class with a missing body in `shelf` sequence. If the reserve is at or above that guardian cost, `pay` subtracts the cost.

   The controller then adds one `"replace"` command. The screen classes fill first. If the reserve is below that class cost, no `"replace"` command occurs. The calculation has no set position identity.

4. The caller of `step` removes an `imprint` from `CallMedium` before this call. See `spec/simulation.md`. When `step` receives that `imprint` and the reserve is 1.0 or more, it adds an `"open"` command for it. Below 1.0, it adds no open command. The `imprint` is removed before this call and cannot be used after the reserve fills.

5. Below a reserve of 1.0, it requests an `"exhausted"` close on each live breach. The close occurs after a 600-tick (10 second) interval. At or above 1.0, it cancels those requests.

6. The send gate opens when breaches are live, `tick` is at or above `_next_dispatch`, and the reserve is above 0.0. It selects the held type from a previous pause. If there is no held type, it selects the `shelf` head or the production cycle type. A `shelf` enemy costs 0. If a production enemy cost is above the reserve, the controller keeps that type and pauses send.

7. The send adds one credit to each breach and selects the breach with `assign`. It calls `pay` or removes the `shelf` head, then adds a `"dispatch"` command. A `shelf` enemy decreases the breach credit by its `DISPATCH_COST` value. The next send tick is the active tick plus `max(1, int(base * max(1.0, dispatch_factor) / live_breach_count))`. The `int` operation drops the fraction. The `base` is 36 ticks for a `shelf` enemy and 132 ticks for a production enemy.

The 0.6-second and 2.2-second values in the Goal apply to one live breach and a send factor of 1. More breaches decrease the interval between send commands. A smaller number of live `collars` increases it.

8. For each live breach in input sequence, a `should_seal` result adds one `"seal"` command. Thus one call can return seal commands for more than one breach.

`on_breach_opened` adds the breach to the scheduler. It moves `_next_dispatch` to 180 ticks (3 seconds) or more after the open. This interval is the initial wait period. `on_breach_sealed` removes the breach.

The `shelf`: `GUARDIAN_SHELF` is 3 `"mite"`, 2 `"husk"`, and one each of `"spitter"`, `"shrieker"`, `"flicker"`, `"brute"`, and `"warden"`. It is one set of bodies for the full hub, not one for each breach. A new `pour` starts with guardians only while guardians are at their set positions. This is the second sign for the player: a call after that has no guardian burst.

`_rotation(tick)` selects the production mix from `STRIKE_CYCLE[(tick // 132) % 20]`. This is a constant cycle of 20 slots. It has 35% screen, 25% ranged, 15% `mobility`, and 25% `breaker`. In the set cycle no 2 `breakers` are neighbors, and the `"warden"` is in the last slot.

### Caveats

- Defect: `_rotation` reads the slot from `tick // 132`, not from a send count. With more than one breach, the interval decreases but the slot duration does not. One slot then supplies 2 or 3 sends in sequence, and the same enemy type occurs 2 or 3 times. That can include 2 `breaker` sends in sequence, against the stated cycle property. If `collar` damage makes the interval longer, the calculation does not use some cycle slots. The given mix equals the cycle only with one breach and an interval of 132 ticks.

- The comment on `MarrowCommand.kind` lists `"open"`, `"dispatch"`, and `"seal"`. The code also returns `"replace"`, and the sim does that command.

- Between a reserve of 0.0 and 1.0, the `marrow` requests an `"exhausted"` close on each live breach and continues send through them. `shelf` enemies cost 0 and can send, and production enemies pause. The open gate is at 1.0, and the send gate is above 0.0.

- `note_crossing` clears a recorded `"idle"` cause, but no code writes that value into the field. `should_seal` calculates the idle result at each call. That code path cannot run.

- The idle seal and the `"no_route"` seal fire at their limits, without an added interval. Only the `"exhausted"` seal has one (10 seconds).

- `assign` breaks equal credit in the direction of the smallest breach id, thus the selection is deterministic.

- The scheduler adds credit at each send, not at each tick.

- A new breach increases the interval before the next send of all breaches because all breaches use the same counter.

- The long record comment in the module stays as a requirement. It records that a calculation in a comment is not a code calculation.

- The external `ReserveDepot` methods do not check their full accepted range. `pay` with a negative cost increases the reserve and can move it above 300. `set_debt` accepts each float, with values above 300. Controller calls use positive costs and the negative `blackout` value.

## `CoreOrgan` — the `CORE`, an organ and not a boss (`game/perihelion/core_organ.py`)

### Goal

The `CORE` is a system of parts with different time scales (`U11`). A `collar` death immediately increases the send interval. This changes the active combat. Anchors and sources change the economy after a longer period.

The `caretakers` control how long player damage stays. There is no set sequence for part deaths. There is also no phase in which damage has no effect, master health bar, or `blackout` timer. The death of the last source makes the reserve negative. The `blackout` continues until the `marrow` raises it to zero.

This module keeps the records: which parts are there, which parts receive more health, and how much production the reserve receives. The part bodies are ordinary entities that weapon hits can damage, and the sim holds them. Damage comes in through the one damage door of the sim, and the sim reports it here.

### Invariants

- `on_destroyed` returns `"blackout"` only at the death of the last source. `reform` arms the result again.

- A health increase does not lift `hp` above `max_hp`.

- `dispatch_factor` follows only the count of the live `collars`.

- `production_capacity` is 1.0 with 3 sources and 12 `buds`, and 0.0 with no sources.

- The `CORE` system changes no body. `step_heal` returns the changed values, and the sim writes them to the bodies.

- After a `blackout`, the `CORE` system returns when the reserve crosses zero, not at a clock time.

### Verification

`game/tests/test_core_organ.py` checks these results:

- A `collar` death increases the send interval to the next step: 2.20 seconds, then 3.14 seconds, then 4.89 seconds.

- A source gains `2 hp/s` after 10 seconds without damage. A `caretaker` in contact adds `6 hp/s`.

- The `blackout` result occurs only at the death of the last source.

- `reform_due` becomes `True` immediately when the reserve crosses zero, and `reform` returns the minimum part set.

### Implementation

`PART_SPEC` lists the part types with their counts and `hp`. The `hp` values agree with the weapon damage of the player. A value of 42 equals one `rail` hit. A value of 84 equals one full `Tau` hit. A value of 168 equals 2 full `Tau` hits.

- `"core_collar"` — 2 at 126.

- `"core_scriptorium"` — 1 at 84.

- `"core_caretaker"` — 4 at 42.

- `"core_anchor"` — 4 at 84.

- `"core_bud"` — 12 at 42.

- `"core_source"` — 3 at 168.

`add_part(part_id, kind, chamber, hp=None)` records a `CorePart` with the `PART_SPEC` `hp` or the given value. `live(kind)` lists the live parts of a type.

`on_damage(part_id, tick)` returns without a change for an unknown part id or a part id that is not in `parts`. For a live part, it records the damage tick. It adds one `(tick + 360, chamber)` muster record to the list. Further damage adds another record for the same polygon.

`due_musters(tick)` returns the polygon from each record with a time at or before the given tick, in list sequence. It removes those records. `on_destroyed(part_id, tick)` returns `None` without a change for an unknown part id or a part id that is not in `parts`. For a live part, it removes the part. When the part was the last `"core_source"` and the `blackout` result is armed, it returns `"blackout"` and disarms that result.

The values the `marrow` reads: `dispatch_factor()` maps the live `collar` count through `{2: 1.0, 1: 3.14/2.20, 0: 4.89/2.20}`. `production_capacity()` is `(sources / 3) * (0.25 + 0.75 * buds / 12)`: the sources give the large factor, and the `buds` give the small factor.

`step_heal(tick, caretaker_contacts)` moves regeneration forward one tick. It changes `caretaker_contacts` to a set of part ids. Thus one or more contacts give the same `caretaker` effect to a part. The quantity of added health does not increase with the `caretaker` count. A damaged source with no damage for 600 ticks (10 seconds) gains `2/60` for each tick. A part with its id in the contact set gains `6/60` more for each tick.

The sim calculates the contact, and the `CORE` system applies the effect. The function returns `(part_id, new_hp)` pairs, and the sim writes them to the bodies.

`reform_due(reserve)` is `True` when the `blackout` fired and the reserve is above zero. `reform()` clears the `blackout` state and returns this minimum part set: 1 `"core_source"`, 1 `"core_anchor"`, 3 `"core_bud"`, and 1 `"core_caretaker"`.

### Caveats

- Defect: the module docstring tells that a full source kill sets the reserve to -32. The value is `CORE_KILL_DEBT` in `marrow.py`: -320, scaled with the regeneration rate it is measured in. The docstring has the previous value.

- The `CORE` system writes no negative reserve value. The sim calls `depot.set_debt(CORE_KILL_DEBT)` when `on_destroyed` returns `"blackout"`.

- A muster stays after the death of the part that added it. `on_destroyed` does not clear `pending_muster`, thus a response can come to the polygon of a part that is not live.

- The `caretaker` contact adds health to each part type in contact, `caretakers` included. A source in contact gains `8 hp/s` in total.

- Added health does not change `last_damaged_tick`, thus it does not change the time when the source can next gain health.

- `add_part` does not read the count in `PART_SPEC`, and it accepts an `hp` value. The sim controls the counts.

- `dispatch_factor` maps a `collar` count above 2 to the factor of 2 `collars`.

- No test reads `due_musters` or `pending_muster`. No test checks the muster path from `on_damage` to the response.

- With no `buds` live and all sources live, the capacity is 0.25. The `buds` give 3/4 of the production.
