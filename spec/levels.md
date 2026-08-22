# Levels: the file format, the loader, the streamer, and the level tool

Frontmatter. This specfile tells about `game/perihelion/levels.py`, `game/perihelion/stream.py`, the level tool directory `game/perihelion/editor/`, and the level files `levels/*.json`. Its `__init__.py` adds no runtime operation. This is a warm-start specfile: all sections tell the facts of the code as it is.

## Unit 1 — The level file format, version 2

### Goal

One JSON file holds one full level. It includes polygons, connections, doors, entities, the player start, the exit, text metadata, and lights. The level writer writes all positions in global coordinates. The loader changes them to local coordinates at load time.

### Invariants

- The file holds one JSON object at the top level. The `version` value, when the file has one, is `2`.

- The vertex sequence of each polygon is standard: the area value is less than zero. In global coordinates where `y` points down, this is visual counterclockwise.

- Edge `i` of a polygon runs from vertex `i` to vertex `i + 1`. The last edge goes back to vertex 0.

- Each position in the file is in global coordinates: entity, player, exit, terminal, and light positions.

- One edge can have at most one connection or door. A mirror connection counts as one use. The loader does not check this file requirement. The level tool checks it. `LevelBuilder.resolve` checks it for automatic connections and point connections. Refer to the defect in Unit 5 for point doors.

### Verification

- `game/tests/test_levels.py::test_level_structure` loads each included `l*.json` file and runs a live session on it.

- `game/tests/test_level_winding.py` shows that the loader rejects a polygon with its vertex sequence in the incorrect direction, at each polygon position.

- `game/tests/test_editor.py::test_double_used_edge_blocks_save` shows that the level tool rejects two connections on one edge.

### Implementation

The JSON object holds these keys:

- `version` — the number `2`.

- `name` — the level name that `PERIHELION` shows.

- `tier` — an integer. Specified levels use values 1 to 4. The default is 1. The loader accepts other integers and clamps the calculated `descent` value to the range 0 to 1.

- `ambience` — the ambience id. The default is `amb_drone_early`.

- `polygons` — a list. Each entry holds `verts` (a list of `[x, y]` pairs) and `entities` (a list). The two keys `kind` and `detail_seed` are optional.

- `connects` — a list of `[a, ea, b, eb]` entries: polygon `a` edge `ea` connects to polygon `b` edge `eb`.

- `connects_x` — a list of `[a, ea, b, eb, m]` entries, where `m` is a list of 9 numbers for a special connection.

- `doors` — a list of objects `{a, ea, b, eb, key}`. A door waits: the two polygons connect only when the player unlocks the door with the door key. A locked door is a wall, and the player cannot see through it.

- `player` — an object `{polygon, pos}`: the player start.

- `exit` — an object `{polygon, pos}` with two optional keys: `key` (a door key id that the player must hold) and `gate_kind` (an enemy type, and the player must kill all enemies of this type first).

- `keys` — an object from door key id to the text metadata of that id in this level: `{item_name, gate_name, gate_prompt, acquire_prompt}`.

- `lore` — an object `{intro, radio, terminals}`. `radio` entries are `{trigger, text}`. `terminals` entries are `{polygon, pos, text}`.

- `lights` — a list of objects `{polygon, pos, color, intensity, radius, kind}`.

- `alert_hops` — the hop count for enemy attacks after the player fires. The default is 2.

- `texture_map` — an object from a polygon index to a `[level id, polygon index]` pair, for a texture from a different level.

An entity entry holds `type`, `pos`, and `props`. The `props` key is optional. A message `trigger` value is one of `start`, `enter_polygon:<idx>`, `kills:<n>`, `pickup:<key>`, `exit`.

### Caveats

- No included level file uses `connects_x`.

- The `DoorSpec` comment keeps the empty door key id `""` for a function that no code uses.

- Some tools write more keys into level files: `boss_polygons` (from `tools/musiccal/build_gauntlet3.py`) and a `marathon` object on each polygon (from `tools/marathon/convert.py`). The loader drops them. Refer to Unit 3.

- No other file contains the complete format. The loader and the level tool checks contain it together, and they do not agree fully. Refer to Unit 3 and Unit 12.

## Unit 2 — The level data model

### Goal

Python data classes hold one loaded level in local coordinates, in the shape that the engine accepts. The classes are `EntitySpec`, `DoorSpec`, `TerminalSpec`, `LightSpec`, `RadioLine`, `KeyMeta`, and `Level`.

### Invariants

- All positions in these classes are local: the loader subtracts the centroid of the polygon.

- `Level.polygon_verts` holds the local vertex lists. `Level.polygon_centroids` holds the global centroids that the loader subtracted.

- The lists `polygon_verts`, `polygon_centroids`, `polygon_seeds`, `polygon_kinds`, and `polygon_descent` stay parallel: index `i` in each list tells about polygon `i`.

### Verification

- `game/tests/test_levels.py::test_key_meta_round_trips_through_save_and_load` shows that `KeyMeta` data stays through a write and a load.

- `game/tests/test_editor.py::test_move_polygon_moves_verts_and_entities` shows that entity positions stay attached to their polygon.

### Implementation

- `EntitySpec` — `type`, `pos` (local), `props` (a `dict`, default empty).

- `DoorSpec` — `a`, `ea`, `b`, `eb`, `key`.

- `TerminalSpec` — `polygon`, `pos` (local), `text`.

- `LightSpec` — `polygon`, `pos` (local), `color` (3 values, 0 to 255), `intensity`, `radius` (local units), `kind`. `kind` is `static` (calculated once at level load) or `attached` (calculated again for each tick). Two more fields are in the class for a light with a direction. `dir` is a local direction with default `None`. `arc` is the full light angle in angle units, with default `0.0`. A `dir` value of `None` means that the light emits in all directions.

- `RadioLine` — `trigger`, `text`.

- `KeyMeta` — the text metadata of one door key id in one level: `item_name` (the pickup), `gate_name` (the object that it opens), `gate_prompt` (the blocked line), `acquire_prompt` (the pickup line). All values are short and contain only `A-Z`. They supply the objective line and the pickup text. The id is the same across levels. The text metadata is different in each level.

- `Level` — the full level. Its fields: `name`, `tier`, the parallel polygon lists, `connects`, `connects_x`, `doors`, and `entities` (a list of `(polygon, EntitySpec)` pairs). More fields: `player_polygon`, `player_pos`, `exit_polygon`, `exit_pos`, `exit_key`, `alert_hops`, `exit_gate_kind`, `intro`, `radio`, `terminals`, `lights`, `ambience`, `texture_map`, `polygon_descent`, `key_meta`, and `level_id`.

- `Level.polygon_descent` — one `descent` value for each polygon. In a streamed campaign, the streamer controls this list (refer to Unit 7). A level load without the streamer uses one value for all polygons. The difficulty level supplies this value.

- `Level.key_meta` — an object from door key id to `KeyMeta`. The comment states that a level with no entry for an id uses `<ID> SEAL` text.

- `Level.level_id` — the file name of the level without its directory and without its `.json` suffix. `load_level` sets it. It selects the texture path `assets/textures/<level_id>/polygon_<index>.png`. It also selects the chunk texture data in `stream.py`. A level with no source file has the value `""`. Its polygons render without a texture.

### Caveats

- Defect: the `LightSpec` fields `dir` and `arc` are for lights with a direction. The loader does not read them from a file, and `LevelBuilder.light` does not set them. No input operation can add a light with a direction. Refer to Unit 3.

- `Level.texture_map` has the default `None`, not an empty `dict`. The loader always sets a `dict`. A `Level` not from the loader can contain `None` there.

- `exit_polygon` is `-1` when the file has no exit.

## Unit 3 — The loader: `load_level`, `level_from_dict`, `save_level`

### Goal

`level_from_dict` changes one JSON object into a `Level`. It moves each polygon until its centroid is at `(0, 0)`. The engine `add_polygon` does the same. It changes each specified position into the local coordinates of its polygon. `load_level` reads a file, calls `level_from_dict`, and sets `level_id`. `save_level` writes a level object to a file.

### Invariants

- The loader rejects a version value that is not `2`. The error names the two versions.

- The loader rejects a polygon with an area value that is more than zero. The engine can change such a vertex list to the opposite sequence and not report it. Each edge then has a new index. All specified connection indices are incorrect. Because of this, the loader stops with an error at load time.

- The loader calculates the centroid with the area weights, the same as the engine center step in `add_polygon`.

### Verification

- `game/tests/test_level_winding.py::test_reversed_winding_polygon_is_rejected_loudly` and `::test_reversed_winding_is_caught_in_any_polygon_position` show the reject path.

- `game/tests/test_levels.py::test_level_structure` shows the accept path on all included campaign levels.

### Implementation

`level_from_dict` does these steps:

- Version check: a value different from `2` raises `ValueError`. The loader accepts a file with no `version` key.

- For each polygon: read `verts`, and raise `ValueError` when the area value is more than zero. Calculate and keep the centroid, then subtract it from each vertex. A polygon with an area near zero uses the average of its vertices as its centroid. That test compares twice the area with `1e-12`.

- `detail_seed` default: `index * 7919 + 13`. `kind` default: `generic`.

- Each entity of the polygon becomes a `(polygon index, EntitySpec)` pair with a local position and a copy of `props`.

- `tier` defaults to 1. Each polygon receives the same `descent` value, `clamp((tier - 1) / 3, 0, 1)`.

- `doors` become `DoorSpec` objects. `keys` become `KeyMeta` objects. Message lines and terminals come from `lore`. Terminal and light positions become local through the centroid of their polygon.

- Light defaults: `color` `(255, 220, 170)`, `intensity` `1.0`, `radius` `140.0`, `kind` `static`.

- Exit: with no `exit` object, `exit_polygon` is `-1`, `exit_pos` is `(0.0, 0.0)`, and `exit_key` and `exit_gate_kind` are `""`.

- Other defaults: `name` `?`, `alert_hops` 2, `ambience` `amb_drone_early`, `intro` `""`.

- `texture_map`: the JSON object keys become integers, and the values become tuples.

`load_level` reads the file at the given path and parses the JSON. It calls `level_from_dict` and sets `level_id` to the file name without its suffix. `save_level` copies the given `dict`, sets `version` to `2`, and writes JSON with `indent=1`.

### Caveats

- The loader accepts a file with no `version` key. Only an incorrect value causes the error.

- The loader accepts a polygon with an area value of zero. The level tool check rejects it (refer to Unit 12).

- The loader drops unknown keys and does not report them. Examples are `boss_polygons` and the `marathon` data on polygons. The level tool keeps them (refer to Unit 11).

- Defect: the loader reads no `dir` and no `arc` for lights. The direction data of `LightSpec` has no input path.

- `save_level` does no checks. A program can write a file that the loader rejects.

- The loader reads message lines, but `LevelBuilder.radio` raises an error (refer to Unit 4). Message stays only as legacy data: previous files keep it, and new levels cannot add it.

## Unit 4 — `LevelBuilder`: a level specified in code

### Goal

`LevelBuilder` collects polygons, connections, doors, entities, points, and text metadata in global coordinates. `to_dict` returns the level `dict` after `resolve` finishes. `build` changes that `dict` into a `Level`. The campaign generator and the tests use `LevelBuilder`.

Polygons can be at all global positions. They can also overlap. Only a connection sets two polygons as adjacent.

### Invariants

- `rect` and `ngon` return vertex lists in the standard direction. Specified edge indices thus stay correct through `add_polygon`.

- `build` raises `ValueError` when no player start is set.

- `radio` always raises: spoken text lives at terminals and in the scenes between chunks.

### Verification

- `game/tests/test_stream.py` and many other test files build levels with `LevelBuilder` and run them.

- `game/tests/test_objective.py` shows that `radio` raises.

- `game/tests/test_levels.py::test_no_connect_keeps_walls_solid` shows the `no_connect` operation.

### Implementation

- `polygon(verts, detail_seed, kind)` — adds a polygon entry and returns its index.

- `set_kind(polygon, kind)` — sets the `kind` of a polygon.

- `rect(x, y, w, h, seed, kind)` — a polygon with 4 corners, in standard vertex sequence.

- `ngon(cx, cy, r, n, phase, seed, kind)` — a polygon with `n` equal corners on a circle. The angle decreases from `phase`, and the area value is thus less than zero. Edge `i` runs from vertex `i` to vertex `i + 1`.

- `poly(verts, seed)` — a polygon from a given vertex list. When the area value is more than zero, it changes the vertex sequence to the opposite sequence. Edge indices then follow the changed sequence. Use standard input to keep the specified edge indices. This function has no `kind` input.

- `connect(a, ea, b, eb)`, `connect_x(a, ea, b, eb, m9)`, `door(a, ea, b, eb, key)` — index entries, given with edge indices.

- `connect_pts(ra, pa, rb, pb)` and `door_pts(ra, pa, rb, pb, key)` — point entries, given with points. `resolve` changes each point to the edge with the nearest edge center. Points stay safe through the doorway division step, which changes edge indices.

- `key_meta(key, item_name, gate_name, gate_prompt, acquire_prompt)` — the text metadata of one door key id. It applies to each door with this id, and to the exit when the exit has this id.

- `no_connect(ra, rb)` — the automatic connect step must not open a doorway between these two polygons.

- `entity(polygon, type, pos, **props)`, `player(polygon, pos)`, `exit(polygon, pos, key, gate_kind)`, `intro(text)`, `terminal(polygon, pos, text)`, `light(polygon, pos, color, intensity, radius, kind)` — data entries with the same shapes as Unit 1.

- `build()` — checks the player start, calls `resolve`, and returns `level_from_dict` of the result.

- `to_dict()` — returns `resolve()`. This is the last `dict` shape, the one that `save_level` writes.

### Caveats

- `autoconnect` is a legacy entry point. It immediately returns `None`. The operation is in `resolve`.

- `poly` cannot set a `kind`. `rect` and `ngon` can.

- `light` cannot set `dir` or `arc` (refer to Unit 2).

## Unit 5 — `LevelBuilder.resolve`: the build steps

### Goal

`resolve` turns the collected data into the level `dict` in 3 steps. Step 1 is the doorway division. A short edge can be on the same line as a longer wall. This step adds new vertices to the wall at the ends of the short edge. The short edge then becomes part of the wall.

Step 2 changes point doors and point connections to edge indices. Step 3 automatically connects all remaining free edge pairs. The two ends of each pair must align.

### Invariants

- The tolerance for all point tests is `0.5` global units, or the `tol` value that the caller supplies.

- An edge that an index connection uses cannot receive an automatic connection.

- A polygon pair in the `no_connect` set cannot receive an automatic connection.

- Point doors change to edge indices before point connects, and before the automatic step. The automatic step thus cannot use their edges.

- Index connections and index doors do not change. The function does not update their edge indices after a division and does not check that they stay correct. A caller must use index entries only for polygons that the division step does not change.

### Verification

- `game/tests/test_levels.py::test_doorway_splitter_makes_doorways` shows step 1 and step 2 together.

- `game/tests/test_levels.py::test_no_connect_keeps_walls_solid` shows the `no_connect` set.

### Implementation

- The function works on a full copy of the collected data.

- Step 1 examines each edge pair from two different polygons. The pair divides a wall when all these conditions hold. The wall edge is longer than the tolerance. The two edges point in opposite directions. The distance from each end of the short edge to the line of the wall is the tolerance or less. The short edge is in the wall span, with the same tolerance.

- The step adds the internal end points to the vertex list after the wall start vertex. After each change, the search starts again from the first polygon. The loop runs at most 200 iterations.

- Step 2 first collects each edge that an index connection, an index `connect_x`, or an index door uses.

- Point doors then change to edge indices. For each side, the function selects the edge with the nearest center. It adds the changed door to `doors`.

- The point connects then also change to edge indices. When a changed edge is in use, the function raises `ValueError` and names the polygon and the edge.

- Step 3 then examines all edge pairs. A pair connects when its edges are free and from different polygons. The pair must not be in `no_connect`. The ends must also align. End `a0` aligns with end `b1`, and end `a1` aligns with end `b0`. Each distance is the tolerance or less.

### Caveats

- The division step stops after 200 iterations and does not report this stop. No error tells the level writer when this limit prevents more divisions.

- Defect: point doors do not check if one of the two selected edges is in use. A point door can use the same edge as an index connection or index door. It can also use the same edge as a previous point door. The function records all entries on the same edge. This does not obey the limit of one use for each edge in Unit 1. Only the subsequent change of point connections checks the collected set of edges in use.

- The division step finds the wall start vertex by value in the vertex list. When the value is not in the list, the step ignores that pair and does not report it.

- The function does not check this requirement for callers. After a division, an index entry can refer to a different edge. No error occurs.

## Unit 6 — The shipped level files

### Goal

The `levels/` directory holds the campaign manifest, the 10 campaign levels, 5 calibration levels, and 3 more levels for tests. Each file obeys Unit 1.

### Invariants

- `levels/campaign.json` lists the 10 campaign files `l01.json` to `l10.json`, in play sequence.

- Each included polygon has an area value that is less than zero.

- The player can collect each door key before the door. The campaign test checks this.

### Verification

- `game/tests/test_levels.py::test_campaign_exists_and_generator_runs` checks the manifest length.

- `game/tests/test_levels.py::test_keys_reachable_before_their_doors` and `::test_every_shipped_key_has_diegetic_metadata` check the campaign door keys.

- `game/tests/test_gauntlet_level.py` checks the calibration levels.

### Implementation

The campaign, in sequence:

- `l01.json` — `DOCK 4 — SWEEP`, difficulty level 1, 120 polygons. 8 terminals, no doors.

- `l02.json` — `COOLANT ROW`, difficulty level 1, 143 polygons. 1 door, `red` door key text metadata.

- `l03.json` — `HYDROPONICS TORUS`, difficulty level 2, 177 polygons. 1 door, `blue` door key text metadata.

- `l04.json` — `THE LONG GALLERY`, difficulty level 2, 131 polygons. 1 door, `blue` door key text metadata, one `implant_lightning` pickup.

- `l05.json` — `TWO WINGS`, difficulty level 3, 160 polygons. The exit has the door key `gold`. Two `key_gold` pickups, two `portable_hole` pickups.

- `l06.json` — `MIRROR WARD`, difficulty level 3, 174 polygons. The exit has the door key `red`. One mirror connect, `[170, 3, 170, 3]`. Two `weapon_tau` pickups.

- `l07.json` — `RECURSION STACK`, difficulty level 3, 231 polygons. The exit has the door key `gold`. 8 `flicker` enemies.

- `l08.json` — `THE FOLD`, difficulty level 4, 175 polygons. The exit has `gate_kind` `warden`. One `warden` with `props` `{hp: 180, tether: 1}`. One `safe_polygon_core` entity. `alert_hops` 1.

- `l09.json` — `TESSERACT DECK`, difficulty level 4, 253 polygons. The exit has the door key `void`.

- `l10.json` — `PERIHELION CORE`, difficulty level 4, 244 polygons. The exit has `gate_kind` `warden`. 2 doors, `void` door key text metadata, `alert_hops` 1.

The other files:

- `gauntlet_cal.json` — `GAUNTLET — CALIBRATION RUN`, 46 polygons. A small number of enemies, 7 `sentry` entities.

- `gauntlet_cal2.json` — `GAUNTLET II — DENSE CALIBRATION`, 46 polygons. The same map with many enemies.

- `gauntlet_horde.json` — `GAUNTLET — HORDE SHOWCASE`, 46 polygons. The same map with 360 `husk` entities.

- `gauntlet4.json` — `GAUNTLET III — TACTICAL CALIBRATION`, 163 polygons. Holds `boss_polygons`, two `lacuna` entities with `dormant` property values, two `vagrant` entities, and a `texture_map` into `l06` textures.

- `gauntlet_cal3.json` — `GAUNTLET III — TACTICAL CALIBRATION`, 163 polygons. A near copy of `gauntlet4.json`, without the `lacuna` and `vagrant` entities.

- `marathon_arrival.json` — `Arrival (M1)`, 253 polygons. A `marathon` object on each polygon. No lights.

- `maze_demo.json` — `The Maze From Arrival`, 68 polygons. The one message line in the level files, with the `trigger` value `start`.

- `smoke_4polygon.json` — `smoke_4polygon`, 4 polygons in a row. The smallest level.

All included lights have the `kind` value `static`. No included file has `connects_x` entries, `dir` or `arc` on a light, or a `vigil` key.

### Caveats

- These included entity types are not in the level tool palette: `flicker`, `sentry`, `lacuna`, `vagrant`, `portable_hole`, `weapon_tau`, `safe_polygon_core`. `PERIHELION` includes them as entities. The level tool shows those in a file but cannot add new ones (refer to Unit 13).

- `gauntlet4.json` and `gauntlet_cal3.json` have the same `name` value. Only the file names and the entity lists are different.

- The `texture_map` entries of these files point at `l06` textures, not at textures with the same file id.

- Some `flicker` entities hold an empty `props` object. It has no effect.

## Unit 7 — `WorldStreamer`: one live world from campaign chunks

### Goal

The campaign plays as one world without load screens. Each level file becomes a chunk of polygons in one live sim. The streamer loads chunk `k + 1` when the player is in the connection section of chunk `k`. It then connects the new polygons to the world. In campaign mode, `app.py` starts a `WorldStreamer` and calls `tick` and `respawn`.

### Invariants

- Chunk `k` of `N` is at `descent` `k / (N - 1)`: `0.0` at the first chunk, `1.0` at the last chunk.

- The far side of each connection section is a new area. The held door keys clear when the player moves into the next chunk.

- Only the last chunk has a live exit. In all other chunks the exit marker is off, and it points at the path forward. Routing queries and bots thus always have a target.

- Each chunk entry point has a seed device.

- The parallel polygon lists of `session.level` (Unit 2) receive an entry for each polygon that the streamer adds. Index `i` thus stays correct in each list.

### Verification

- `game/tests/test_stream.py::test_stream_lazy_load_arrival_and_completion` walks a campaign of 3 chunks to the end.

- `game/tests/test_stream.py::test_stream_respawn_at_chunk_entry` shows the respawn contract of Unit 9.

- `game/tests/test_economy.py` runs the streamer and checks the fields that are only for the state file.

### Implementation

- The constructor receives `session`, `level_paths`, and `start_chunk`. Before construction, the session holds the level of chunk `start_chunk` as chunk 0.

- The constructor does not check its inputs. It uses the level in `session` and does not compare it with `level_paths[start_chunk]`. With an empty path list, the first chunk is also the last chunk. A `start_chunk >= path count` has the same result. A negative `start_chunk` can select paths through negative Python indices. These inputs do not have a specified campaign use, but the constructor does not reject them.

- A chunk record holds `offset` (the first engine polygon index of the chunk), `n_polygons`, `level`, `entry_polygon` (an index local to the chunk), `entry_pos`, `spine_polygons` (a pair or `None`), and `loaded_next`.

- The constructor records chunk 0 and replaces the `descent` values from the difficulty level with the campaign values. It records the entry state (Unit 9), adds a seed device at the player start, and sets `exit_enabled`. For a last chunk it points the exit with the operation below. For all other chunks it adds the connection section (Unit 8) and calls `_retarget`.

- A chunk is last when `start_chunk` plus its local index equals the index of the last path.

- `_chunk_descent` — `min(1.0, (start_chunk + local index) / max(1, path count - 1))`. Thus, the only chunk of a campaign with one path has `descent` `0.0` when `start_chunk` is 0.

- `_extend_descent` — adds `descent` values for new engine polygons. The sim also adds polygons between stream events. Examples are the open polygons of `portable_hole` and the `cloister`. These new entries receive the last known value, because such polygons are always near the player.

- `_retarget` — with a loaded next chunk, the exit marker points at the recorded entry position in the chunk entry polygon. With only a connection section, it points at position `(0.0, 0.0)` in the far connection polygon. In a last chunk it returns with no state change.

- `_point_exit_at(k)` — sets the session exit to the exit point of chunk `k` plus its offset. It copies `exit_key` and `exit_gate_kind` from the level of chunk `k` onto `session.level`. This is necessary because `session.level` is the level object of chunk 0. The blocked line comes from the `key_meta` of chunk `k`. `exit_gate_polygons` limits the gate count to the polygon range of chunk `k`. Only the enemies of this chunk count for its exit gate.

- `polygon_chunk(polygon)` — the chunk index of an engine polygon, found through the ranges and the connection pairs. An unknown polygon returns the chunk in `current`.

- `polygon_texture_key(polygon)` — the callback for floor textures. In a chunk range, it returns the `texture_map` entry when there is one. It returns `(level_id, local index)` when there is no entry, and `None` when the level has no id. Connection polygons and unknown polygons also return `None`.

### Caveats

- The chunk pointer `current` only increases. When the player walks back into a previous chunk, `current` does not change. A death then moves the player to the entry of the newest chunk, not the chunk that contains the player.

- `on_campaign_complete` is set to `None` at construction. No code in the repository reads it or calls it.

- `on_chunk_entered` is a callback with the campaign chunk index and the level name. `app.py` sets it.

## Unit 8 — The connection section and chunk entry

### Goal

The exit point of chunk `k` becomes a doorway cut into a connection section of two polygons. The player walks through this section while chunk `k + 1` loads. Each section uses the visual type of its scene and displays its name once. A terminal in the section plays the `conversation` between the chunks.

### Invariants

- The connection polygons are `SPINE_LEN` by `SPINE_W` units (260 by 70). A doorway cut into a wall is `DOOR_W` wide (70).

- The connection section receives the midpoint of the two chunk `descent` values. The palette transition thus occurs in this section, not at a doorway.

- The first entry into the connection section of chunk `k` loads chunk `k + 1`. Subsequent entries do not load it again.

- The name of the connection section shows only at the first entry.

### Verification

- `game/tests/test_stream.py::test_stream_lazy_load_arrival_and_completion` moves into a connection section, sees the next chunk load, and completes the campaign.

### Implementation

- `_carve_in_chunk(chunk, polygon, pos)` — cuts a doorway near the position. Some polygons have no free wall, for example the center polygon of `l08.json` and polygons of `l09.json`. Then the function examines adjacent polygons in the chunk, one distance step at a time, until a cut is possible. When no polygon in the chunk has a free wall, it raises `RuntimeError`.

- `_build_spine(k)` — cuts a doorway near the exit point of chunk `k`, and adds two connection polygons to the sim. It connects the exit doorway to connection polygon `a` edge 0. It connects connection polygon `a` edge 2 to connection polygon `b` edge 0.

- `_build_spine` extends the parallel level lists. The seed values equal the loader default values. The types are the scene type and `transit`. The `descent` value is the middle value of the two chunks. The vertex lists are centered rectangles, and the centroids are `(0, 0)`.

- `_build_spine` records the section name and adds a terminal with the text `__CONV__<campaign index>` at the center of connection polygon `a`. That text causes `PERIHELION` to play the `conversation` at that index.

- `SCENE_STAGES` — the scene list for campaign chunks 0 to 8, for example 0: `dock` and `CARGO RELAY`, and 7: `core` and `THE VAULT ANTECHAMBER`. A chunk without an entry uses the type `transit` and has no name.

- `_load_next(k)` — returns with no state change when the load occurred before, or when chunk `k` is last. It loads the next file, adds the chunk to the sim with `append_chunk`, and extends the `descent` values. It cuts an entry doorway near the specified player start. When the cut moves to a different polygon, the entry position becomes the center `(0, 0)` of that polygon. It connects connection polygon `b` edge 2 to the entry doorway and records the chunk. When chunk `k + 1` is not last, it adds that chunk's connection section.

- `tick()` — runs only when the player polygon changed. In the connection section of the chunk in `current`, it displays the section name once through a `locname` effect. It then calls `_load_next` and `_retarget`.

- `tick()` in the polygon range of the next chunk: it adds 1 to `current` and records the entry state (Unit 9). It adds a seed device at the entry and clears the door keys. It sets the exit live in a last chunk, or calls `_retarget`. It sends `locname` and `ambience` effects with the name and the ambience of the new level. Then the `on_chunk_entered` callback runs.

- When the player held door keys at the area change, the objective line `ZONE BOUNDARY - PRIOR CLEARANCES VOID` shows. This line tells the player that the keys were cleared.

### Caveats

- `SCENE_STAGES` ends at campaign chunk 8. In a campaign with more than 9 connection sections, all subsequent sections use the type `transit` and have no name.

- The centroids of the connection polygons are `(0, 0)` in the records. These polygons have no global position. Thus no code has a global centroid for them.

## Unit 9 — Death and respawn in a streamed campaign

### Goal

The seed device prints a new player body at the entry of the active chunk. It uses the state from the first entry into that chunk. The function respawns the enemies and specified items of the chunk. The body pickup that contains items dropped at death stays where it fell.

### Invariants

- Each respawn in chunk `k` uses the recorded entry state of that chunk, with the minimum values below.

- Body pickups (`corpse_frame`) stay when the function supplies items again. Items in a body pickup stay there until the player collects that pickup. Other pickups in the active chunk are removed before the function supplies specified items again.

- A door that the player opened stays open.

- The held door keys, the `tau_charge` value, and the `hole_mark` value clear at each respawn.

- The recorded entry state has `hp >= 70` and `9mm >= 45`. In `hard` mode, it has `hp >= 85`, `9mm >= 90`, and `shell >= 8`.

### Verification

- `game/tests/test_stream.py::test_stream_respawn_at_chunk_entry` causes player death and checks the entry contract.

- `game/tests/test_economy.py::test_cold_restore_preserves_corpses_and_does_not_refund` checks that the body pickup stays and that `components` do not come back at a respawn.

### Implementation

- `_snapshot_state` — records `hp` and weapon supplies with the minimum values above. It also records the weapon list, active weapon, hole count, and `cloister` flag. The comment records the cause of these minimums. A player with low `hp` or weapon supplies can have the same death on each new try. One long automatic campaign had more than 400 deaths with 9 units of `9mm` ammunition. The minimums change only the lowest conditions.

- The snapshot also holds `components`, `chassis`, `station_kits`, `max_hp`, `hp_ups`, `recalls`, `mind`, `think_focus`, `think_progress`, and `think_done`, for the state file only. `_restore_state` does not touch them. The body pickup holds items that death removed, and the live session holds the node state.

- `_restore_state` — sets `hp` (limited to `max_hp`), weapon supplies, the weapons, the active weapon, and the holes. It clears the door keys, the `tau_charge` value, and the `hole_mark` value.

- `respawn` — removes all bullets in the world. It removes enemies and pickups in the polygon range of the chunk in `current`, but keeps body pickups. It then adds all specified entities of the chunk from the level data. It uses the door key text metadata of that level.

- `respawn` then copies the entry state and moves the player body to the entry point. It sets the player speed to zero and clears the death and freeze flags. It adds 1 to the death count in `metrics`. It sets the camera to the entry point and shows the level name.

- The player move first calls `place` in the polygon that contains the player before the move. The engine position call cannot change the body polygon. If that polygon is different from the chunk entry polygon, `session.reseat_player` moves the body to the entry polygon and position.

### Caveats

- `respawn` removes all bullets in all polygons, but enemies and pickups only in the polygon range of the chunk. An enemy that walked into a connection section stays when the function supplies items again and keeps its state.

- The function adds a collected pickup again at respawn because it adds the full specified list. Door keys clear at each respawn. Thus the player must collect a previous door key again, and the key is there again.

- The entry state is recorded once, at the first entry into the chunk. Each subsequent death in the chunk uses that first state.

## Unit 10 — The level tool program and its entry point

### Goal

`uv run python -m perihelion.editor [file.json]` opens the level tool. Without a file, it opens an empty level. The tool changes the JSON structure from Unit 1 in global coordinates and writes all data back to disk.

### Invariants

- The model imports no `pygame` and no engine code. Only the view module touches the window system. The tests run the model without a window.

- The level tool does not write a level that its checks reject (refer to Unit 12).

### Verification

- `game/tests/test_editor.py` runs the full model without a window.

- `game/tests/test_editor.py::test_add_polygon_connect_save_loads_and_runs` adds and writes a level in the level tool model. It loads the level with the runtime loader and runs a live session.

### Implementation

- `editor/__main__.py` parses one optional file name on the command line and calls `view.run`.

- `view.run(path)` starts an `EditorApp` and runs its loop (refer to Unit 14).

### Caveats

- None.

## Unit 11 — The level tool model: state, `undo`, `redo`, and files

### Goal

`EditorModel` holds the level `dict` in the file shape, a selection, an `undo` stack, and a `redo` stack. A bad load does not damage good state. A write with errors writes no file.

### Invariants

- Each change call records a snapshot before it changes data. `undo` and `redo` move between these snapshots. Each stack holds at most 100 snapshots.

- `dirty` is on when, and only when, the data is different from the last written or loaded snapshot.

- A load with errors changes no state: the model keeps its data, its path, and its stacks.

- A `save` or an `export` call with check errors writes no file and returns the error list.

- `export` does not change `path`, `dirty`, or the written snapshot.

### Verification

- `game/tests/test_editor.py::test_undo_restores_exact_prior_dict`, `::test_move_polygon_is_a_single_undo_step`, and `::test_load_malformed_file_does_not_crash_or_clobber_state`.

- The tests of the file write gate, listed in Unit 12.

### Implementation

- `_blank_level` — an empty level with version 2, name `untitled`, difficulty level 1, and ambience `amb_drone_early`. It has empty lists, no player, no exit, and empty text metadata.

- `_normalize` — fills the known keys when a file does not have them. The model code after it thus has no checks for a file with missing keys. It keeps unknown keys without change. It does not raise on missing keys.

- `new` — empty data, no path, empty stacks, and a clean state.

- `load(path)` — returns a list of error strings. An empty list means that there is no error. It parses the file, accepts only a JSON object at the top level, and calls `_normalize`. When there is no error, it replaces the data, the path, and the written snapshot. It also clears the stacks.

- `save(path=None)` — runs the checks of Unit 12. With errors it returns them and writes no file. Without a target path it returns `no file path to save to`. When there is no error, it writes the file, sets `path`, and records the written snapshot.

- `export(path)` — the same gate, but it writes to the given path only. The test play uses it, and a test play thus does not change the write target.

- `_write_out` — a copy of the top level of the `dict`, with `version` set to 2, as JSON with `indent=1`. Unknown keys stay, because the copy keeps all keys.

- `snapshot`, `undo`, `redo` — the snapshot system. `undo` and `redo` clear the selection.

### Caveats

- `_blank_level` has no `lights` key and no `keys` key. The loader accepts that, and a manual change can add them.

- The level tool has no controls for lights, door key text metadata, `kind`, `tier`, `name`, `ambience`, `alert_hops`, or `texture_map`. It keeps all these through a load and a write, but only a manual change can change them.

- Two modules set `LEVEL_VERSION = 2`: `levels.py` and `editor/model.py`. A version change must touch the two.

## Unit 12 — The level tool checks

### Goal

`validate` returns all errors in one call: bad polygons, missing points, and bad connections. The write gate and the message line use it.

### Invariants

- A polygon error names the polygon. A connection error names the entry. The check collects all errors and stops at none.

- A level is correct only when all these conditions hold. Each polygon has `vertex_count >= 3`, an area value less than zero, and only convex or collinear vertices. A player start is set, and its polygon index is in range.

  An exit is set, and its polygon index is in range. Each connection and each door refer to polygon and edge indices in range. Each edge has at most one connection.

- A level `dict` can have no exit when `bool(data.get("vigil"))` returns `True`. A missing value or `False` means that an exit is necessary. All other exit requirements stay.

- A mirror connection is one use of its edge, not two.

- Vertices on one line are not convex errors. The doorway division step adds them, and they are not errors.

### Verification

- `game/tests/test_editor.py::test_convexity_violation_blocks_save`, `::test_wrong_winding_blocks_save`, `::test_missing_player_or_exit_blocks_save`, `::test_double_used_edge_blocks_save`, and `::test_self_mirror_connect_is_not_a_double_use_conflict`.

### Implementation

- `canonical_winding(verts)` — changes the vertex sequence to the opposite sequence when the area value is more than zero. The level tool applies it to each new polygon from the `poly` tool.

- `convex_flags(verts)` — one flag for each vertex. The flag is on where the polygon is not convex at that vertex. The test compares the turn direction of the two edges at the vertex with the direction of the full area. The tolerance is `1e-6`. A polygon with less than 3 vertices, or with an area dimension below `1e-9`, flags each vertex.

- `validate` — does the checks above in one operation through the data. A polygon or connection entry that raises in a check reports as an entry with a bad shape. The function also keeps the result in `last_errors`.

- No included file uses `vigil`. The `vigil` mode during play has such levels in code.

### Caveats

- The level tool check rejects an area value of zero. The loader accepts it. A polygon with zero area can come only from a manual change, and only the level tool reports it.

- `validate` does not check if positions are in their polygon or if connected edges have equal lengths. It also does not check if door key ids and entity types are known. The view shows a warning for edges with different lengths only while it renders the editor frame (refer to Unit 15).

## Unit 13 — The level tool change operations

### Goal

All level changes use model calls that first record a snapshot. These changes include polygons, vertices, entities, points, terminals, and connections. A removal repairs each index that points at moved or removed items.

### Invariants

- A vertex removal does not move a polygon below 3 vertices.

- A vertex removal drops each connection with an edge that touched the removed vertex. The edge is no longer there. A connection to a different edge is an incorrect adjacency. All other connections of that polygon receive their new edge indices.

- A polygon removal drops each connection, door, marker, terminal, and message line of that polygon. It moves all higher polygon indices down by one.

- A polygon move also moves its entities, and the player, the exit, and the terminals in it.

- `add_entity` accepts only the `POLYGON_ENTITY_TYPES` set below. It raises `ValueError` for all other types. This set is smaller than the full set of entity types that `PERIHELION` can load from files.

- The exit keeps its `key` and `gate_kind` when it moves.

### Verification

- `game/tests/test_editor.py::test_delete_polygon_reindexes_everything`, `::test_delete_polygon_reindexes_terminals_and_radio_triggers`, `::test_delete_vertex_drops_bound_connections_not_others`, `::test_delete_vertex_refuses_below_triangle`, `::test_move_polygon_moves_verts_and_entities`, and `::test_add_entity_rejects_unspawnable_type`.

### Implementation

- The type lists. `ENEMY_TYPES`: `husk`, `mite`, `spitter`, `brute`, `shrieker`, `warden`. `PICKUP_TYPES`: `ammo_9mm`, `ammo_shell`, `ammo_cell`, `medkit`, `weapon_smg`, `weapon_shotgun`, `weapon_rail`, `implant_lightning`, `key_red`, `key_blue`, `key_gold`, `key_void`. `POLYGON_ENTITY_TYPES` is the union of these two lists. The palette is `player`, `exit`, the enemies, the pickups, and `terminal`.

- `add_rect_polygon`, `add_poly_polygon` — new polygons. The second applies `canonical_winding`.

- `move_polygon(ri, dx, dy)` — one snapshot, then the move of the polygon and its items.

- `set_vertex`, `delete_vertex` — vertex changes. The removal calculates an edge index map. An edge that touched the vertex maps to `None`. All other edges map to their new index. `connects`, `connects_x`, and `doors` change through the map.

- `delete_polygon(ri)` — the removal with full index repair, also for message lines with a `trigger` of the shape `enter_polygon:<idx>`.

- `add_entity`, `move_entity`, `delete_entity` — entity changes in the polygon entity list.

- `set_player`, `set_exit`, `set_exit_key`, `set_exit_gate_kind` — marker changes. The door key values for the overlay are `red`, `blue`, `gold`, and `void`. The `gate_kind` values in `GATE_KIND_PRESETS` are the empty value and the enemy types.

- `add_terminal`, `move_terminal`, `delete_terminal`, `set_terminal_text` — terminal changes in `lore.terminals`.

- `connect_edges` — adds a connection. The same edge on the two sides is a mirror connection. That is a permitted input, as in `l06.json`.

- `connect_door` — adds a door with a door key id.

- `delete_connection(kind, idx)` — removes one entry from `connects`, `connects_x`, or `doors`.

- `delete_selected` — removes the item that the selection points at. The item can be a polygon, vertex, entity, player, exit, terminal, or connection.

### Caveats

- No code calls `set_exit_key` or `set_exit_gate_kind`, and no code reads `GATE_KIND_PRESETS`. The view has no control for them. An exit with a door key or a gate comes only from a manual change or from `LevelBuilder`. `set_exit` keeps `key` and `gate_kind` for such files.

- The palette does not have the included types listed in Unit 6. The model rejects them in `add_entity`, but keeps them when they are in a loaded file.

- The comment on `connect_edges` points to `l06.json [2, 1, 2, 1]`. The entry in `l06.json` is `[170, 3, 170, 3]`. The comment numbers are incorrect.

- A message line with a `trigger` of the shape `kills:<n>` or `pickup:<key>` does not change at a removal. Only `enter_polygon` values change. No included file has such lines.

## Unit 14 — The level tool window, input, and modes

### Goal

The view turns mouse and key input into model calls. It has a camera, a grid with grid alignment, 6 modes, and 2 overlays. A test play starts `PERIHELION` on the level in work.

### Invariants

- The view holds no level state. Each level change goes through a model call.

- While an overlay is open, it receives all keyboard input, and mouse input has no effect.

- A drag changes the model once, at release, as one `undo` step. During the drag, only the view shows the live position.

- The camera zoom from `MOUSEWHEEL` input keeps the world point at the mouse in the same position.

- With no overlay open, `Esc` returns to select mode and clears the `poly` points and connect start edge. With an overlay open, `Esc` cancels only that overlay because the overlay receives the key first.

### Verification

- The model tests of Unit 11 to Unit 13 check the calls from the view.

- No test operates the view. A person must look at the window to check the view operation.

### Implementation

- The window is an engine window, 1440 by 900, with the name `PERIHELION -- Level Editor`. The loop reads events and applies camera movement from the arrow keys. It renders the full frame into a `numpy` framebuffer and sends it to `window.present`. The loop waits to keep 60 ticks each second. At the end of the loop, the view stops an active test play process.

- Camera. `_fit_camera` centers on the level and selects a zoom that shows it. It uses 0.85 and limits the result to the range 0.05 to 3.0. `world_to_screen` and `screen_to_world` change positions between the two spaces. `MOUSEWHEEL` input multiplies the zoom by `1.1` for each step, in the range 0.02 to 20. The middle mouse button moves the camera with pointer movement.

  The arrow keys move the camera each tick by `14 / zoom`.

- The grid step is 10 units. Grid alignment is on at the start and moves each added or moved point to the nearest grid point. `G` sets the grid display on or off. `S` sets grid alignment on or off. `I` sets the index numbers on or off.

- The modes: `select`, `rect`, `poly`, `entity`, `connect`, and `move`. Their keys: `R`, `P`, `E`, `C`, `M`, and `Esc` for `select`.

- Select mode. A click selects with a tolerance of 8 screen pixels. The selection sequence is a vertex first. A polygon entity, player, exit, or terminal is second.

  A connection follows, and a polygon is last. The function selects the nearest item in each group. When two polygons contain the click point, it selects the polygon last in the list.

  A click on a vertex, a polygon entity, or a terminal starts a pointer movement of that item. The right mouse button always selects and moves a full polygon, in each mode. `Delete` or `Backspace` removes the selection. `X` removes only a selected connection.

- `rect` mode: a drag adds a polygon with 4 corners. A result smaller than 4 by 4 units adds no polygon.

- `poly` mode: each click adds a point. `Enter` with `point_count >= 3` adds and selects the polygon. The mode stays active.

- Entity mode: a click adds the active palette type at the click point, in the polygon at that point. Without a polygon there, the message line tells the user and no change occurs. `MOUSEWHEEL` input or the `[` and `]` keys cycle the palette. The types `player` and `exit` move their one mark. The type `terminal` opens a text overlay first.

- Connect mode: the first click selects the nearest edge, and the second click adds the connection. The same edge on the two sides is a mirror connection. With `Shift` held at the second click, a door key overlay opens. The keys 1 to 4 select `red`, `blue`, `gold`, or `void`.

- Move mode: the left button moves a full polygon, the same as the right button.

- Key commands. `Ctrl+S` writes the file and shows `saved <path>`, or `save refused: <errors>`. `Ctrl+N` starts a new level. `Ctrl+Z` and `Ctrl+Y` run `undo` and `redo`. `Ctrl+O` only shows the message that a load goes through the command line. `F5` starts a test play.

- `TextPrompt` is a text box with one line. `Enter` sends the text, and `Esc` cancels. `KeyPrompt` is the door key list, and the number keys 1 to 4 select a key. `Esc` cancels. Other keys have no effect. While open, the two overlays receive all keyboard input and ignore mouse input.

- Test play: if a play process is active, the view stops it. It writes the level with `export` to `perihelion_editor_playtest_<pid>.json` in the temporary directory of the system. It then starts `uv run python -m perihelion --level <file> --autoplay` from the top directory of the repository. The message line shows the process id, or the `export` errors, or the start failure.

- A window-close event stops the level tool immediately. The level tool does not check `dirty` and does not show a file-write prompt. `Ctrl+N` also replaces dirty data immediately without a prompt.

### Caveats

- Defect: a window dimension change sets a flag `_resized`, and a comment states that the loop starts the window again. No code reads the flag, and the loop does not start a new window. Only the framebuffer follows the new dimension.

- Defect: the constant `KEYBIND_HELP` holds the full list of key commands, but no code renders it. The level tool shows no help.

- The attribute `screen` is set to `None` once and has no other use. Its comment has information about a previous implementation.

- `Ctrl+O` does not open a file. A file opens only through the command line.

- The commands with one character, `Delete`, and `Backspace` run in each mode. `S` in `poly` mode changes grid alignment, and does not add a point.

- In entity mode, `MOUSEWHEEL` input up cycles the palette in the opposite direction. Input down cycles forward.

## Unit 15 — Level tool rendering

### Goal

Each tick renders a complete editor frame. The grid, text metadata marks, connections, polygons, and entities render first. The player and exit marks, shapes for the selected tool, mode text, open overlay, and message line follow. The frame immediately shows incorrect geometry and state.

### Invariants

- A vertex that is not convex shows in the error color on each tick and in each mode.

- The message line always shows the file name, selection, grid alignment and grid states, and zoom. It shows `*` when the state is not written.

- When the checks find errors, the message line shows `INVALID (<count>)` and the first error, in the error color. This replaces the message text.

- When the edge length difference is more than 2 percent, the connection displays a warning triangle at its center.

- A selected item renders with a special color or a larger dimension.

### Verification

- No automatic test checks the rendered editor frame. A person must examine the window.

### Implementation

- The render sequence starts with the window fill, grid, text metadata marks, connections, polygons, and entities. The player, exit, shapes of the selected tool, mode text, overlay, and message line follow. Thus connections render below the polygons.

- The grid has lines at each grid step when `line_distance >= 4 screen pixels`. The two lines through `(0, 0)` use a special color.

- A polygon displays a text-metadata overlay when it has a terminal. The same overlay shows when an `enter_polygon` message names the polygon. Its color is `(60, 90, 60)` with alpha 70.

- Normal connections, `connects_x` entries, and doors each use a different color. A mirror connection renders as a circle at the edge center, in the mirror-connection color. All other connections render as curves to one side of the line between the two edge centers. A door displays its door key id text. A selected connection uses color `(255, 255, 255)` and a wider stroke.

- For polygons, the tool renders the fill, edge lines, vertices, and polygon index. The vertices use the flag colors of Unit 12. The polygon index is at the average vertex position. When the index view is on, edge index numbers show at the edge centers. During a drag, the polygon or vertex renders at its live position.

- Each entity is a filled circle in its type color, with a symbol of one character. For example, `H` means `husk` and `9` means `ammo_9mm`. A type without a color entry uses the neutral color `(200, 200, 200)` and the symbol `?`. This displays the Unit 6 types that the palette does not contain. Terminals render as squares with `T`.

- The player is a circle with `P`. The exit is a triangle with `EXIT`, plus `+<key>` and `/<gate kind>` when set.

- The shapes of the active tool: the `rect` pointer movement as an edge line. The `poly` points show as a line, with a segment to the mouse. The first `connect` edge shows as a circle.

- The mode text shows the mode. In entity mode it also shows the active palette type and the cycle keys.

- The message line runs the full checks of Unit 12 each tick.

### Caveats

- The click target of a connection is the straight line between the two edge centers. The rendered curve bends to one side of that line. Near the middle of a long connection, the click target and the curve do not align.

- The check run in each tick reads the full level each tick. On the included levels this is sufficiently fast.
