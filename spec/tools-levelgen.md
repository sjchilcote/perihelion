# Tools: level generation, `Marathon` import, and model `consults`

This warm-start specfile gives the operation of `tools/levelgen/`, `tools/levelgen/dense/`, `tools/marathon/`, and `tools/design/`, plus `tools/flicker_placement.py`. The text records their warm-start state.

The units form 4 groups: Marathon import tools, campaign tools and their 10 dense level modules, the flicker-placement tool, and model-request tools.

## `Marathon` map parser (`tools/marathon/mapread.py`)

### Goal

Read `Marathon` map files into Python objects. The module parses the WAD container, directory, and level chunks. The result contains each level's points, lines, polygons, map objects, and name. It also selects solo levels and removes the MacBinary wrapper used by the Steam releases.

### Invariants

- All byte reads are big-endian.

- `strip_macbinary` returns the data fork when the buffer contains a MacBinary file. If not, it returns the buffer without changes.

- `WadHeader.parse` raises `ValueError` when the version field is not 0, 1, 2, or 4.

- A version-0 file uses defaults of 12 bytes for a chunk header and 8 bytes for a directory entry when its dimension fields are zero. Versions 2 and 4 use 16-byte chunk headers and 10-byte directory entries.

- `_validate` raises `ValueError` when an index is out of range: a line endpoint, a polygon endpoint, a polygon line index, or an adjacency index. It also raises when a vertex count is not in 3..8.

- A line is a portal only when it connects 2 polygons and its solid bit (`0x4000`) is clear.

### Verification

Run the module as a program. For each of the 3 Steam maps below `~/.steam/steam/steamapps/common`, it prints header data. It also prints one line for each level with the name, polygon count, line count, point count, player starts, and chunk tags. If the game is not installed, the tool prints `MISSING` with its path. Each printed level line shows that the level parsed without error.

### Implementation

The data classes are `Line`, `Polygon`, `MapObject`, and `MarathonLevel`. `Line` contains 2 endpoint indexes, flag bits, and 2 user polygons. A value of `-1` shows that there is no polygon. Its properties give the solid bit, transparent bit (`0x2000`), user tuple, and `is_portal`. `Polygon` contains its type, flags, vertex count, endpoint and line lists, floor and ceiling heights, and adjacency list. `MarathonLevel` contains these lists and the raw chunk map.

`MarathonLevel` has 5 helpers. `player_starts` selects objects of type 3. `poly_verts` maps endpoint indexes to points. `poly_area` returns the absolute polygon area from the shoelace formula, divided by 2 in internal units. `poly_centroid` returns the vertex mean. `poly_degree` counts a polygon's portal lines.

`strip_macbinary` tests byte 0 == 0, a name length in 1..63 at byte 1, and a data fork length at offset 83 that fits in the buffer.

`WadHeader.parse` reads the 128-byte header fields: version, data version, a 64-byte name, checksum, directory offset, WAD count, and 3 dimension fields. `read_directory` reads `wad_count` entries, each of length `dir_entry_size + app_data_size`. For version 2 and 4 maps, it also reads the entry index, `entry_point_flags`, and the 66-byte Mac Roman level name.

`read_chunks` reads one level's sequence of chunk tags, next offsets, and lengths. A next offset that moves rearward or to a location external to the WAD raises `ValueError`. Offset 0 ends the sequence.

The chunk parsers read `PNTS` as 4-byte point pairs. In Marathon 1, `EPNT` contains 16-byte records with the point at offset 6. `LINS` contains 32-byte records with endpoints, flags, and user polygons at offset 16. `POLY` contains 128-byte records. The parser clamps each record's vertex count to `0..8` and truncates its 3 index lists to that count.

`OBJS` contains 16-byte object records. The level name comes from the directory entry or offset 18 of `Minf`.

`MapFile` reads the file, removes its wrapper, and parses the header and directory. `level(i)` reads and checks one level, while the `levels()` generator gives each level. `solo_indices` uses bit 0 of `entry_point_flags` for versions 2 and 4. For version 0, it selects levels with one player start. `GAMES` maps `m1`, `m2`, and `inf` to their Steam paths.

### Caveats

- The parse accepts version 1. The module docstring names only versions 0, 2, and 4.

- The 2 checksum fields are read, and no code compares them with the data.

- `solo_indices` on a version-0 file reads each level in the file to count the player starts.

- If a `WAD` contains 2 chunks with the same tag, the chunk map keeps the second chunk and discards the first.

## `Maze` extraction (`tools/marathon/extract_maze.py`)

### Goal

Write `tools/levelgen/arrival_maze.py` from the maze on the east side of level 0, `Arrival`, in the `Marathon 1` map. The output stamp module contains the maze data and does not read the Steam files.

### Invariants

- Selection uses a portal BFS that starts at Marathon polygon 150. A polygon is included only when its centroid is in `x` 22800..32700 and `y` 13000..24500 and its area is less than 2 square WU.

- The tool changes each polygon vertex list to the opposite sequence. The emitted level then follows the repository's canonical winding, with a shoelace sum below zero. The engine accepts the two winding directions, but this tool writes the repository convention directly.

- The local zero point is the minimum corner of all selected vertices.

- The tool must find all 6 named graft edges and raises `AssertionError` if it does not find one.

- The `no_connect` pairs come from `convert._coincident_unconnected_pairs` and are kept only when the two polygons are selected.

### Verification

Run `uv run python tools/marathon/extract_maze.py`. The tool writes the module and prints the counts and the sorted `graft` names. The module in the `tree` holds 66 polygons, 71 connects, and 30 `no_connect` pairs.

### Implementation

`select()` does the BFS across portal lines with the coordinate-limit and area conditions. `main()` gives a local index to each selected Marathon polygon and moves all vertices to the local origin. It also changes each vertex list to the opposite sequence. For each portal line fully in the selection, it records a connection at the edge midpoint. For a portal with only one selected polygon, it looks up the `(inside, outside)` pair in `GRAFT_NAMES` and records the graft.

`TEMPLATE` contains the complete text of `arrival_maze.py` with placeholders for counts, dimensions, and 4 data tables. The tool formats those values and writes the file.

### Caveats

- The `TEMPLATE` constant is a copy of the `arrival_maze.py` text. When a person changes `arrival_maze.py`, the next tool run removes that change. The docstring of the output file tells this.

- `GRAFT_NAMES` maps 6 `Marathon` polygon pairs to the names `entry`, `exit`, `exit2`, `north`, `west`, and `west2`.

## Arrival `maze` stamp (`tools/levelgen/arrival_maze.py`)

### Goal

Add the maze on the east side from `Arrival` in `Marathon 1` as a campaign stamp. `build_maze(b, origin, scale)` adds its 66 polygons, connections, and `no_connect` pairs to a `LevelBuilder` and returns its graft points. This maze was the 1994 game's first non-Euclidean space: corridors overlap in plan but do not connect.

### Invariants

- `tools/marathon/extract_maze.py` writes the data tables. Change them only through that tool and do not change them manually.

- Coordinates are `Marathon` internal units (1024 for each `WU`) in the local frame of the `maze`. `build_maze` multiplies them by `scale / 1024` and adds the `origin` value.

- Each pair in `_NO_CONNECT` must stay disconnected. These polygons have the same plan coordinates but are disconnected in `Marathon`. A pair in `_NO_CONNECT` prevents autoconnection from welding them.

- A polygon with connection degree 3 or more has type `transit`. All others have type `corridor`.

- The `detail_seed` of each polygon is its `Marathon` index times 7919, plus 13.

### Verification

`tools/marathon/make_maze_demo.py` builds a level from the stamp. An `assert` in that tool checks 68 polygons: the 66 `maze` polygons plus a `hall` and a `vault`.

### Implementation

The tables: `_POLYGONS` holds 66 pairs (`Marathon` index, vertex list). `_CONNECTS` holds 71 records (index `i`, index `j`, edge midpoint). `_NO_CONNECT` holds 30 index pairs. `_GRAFTS` maps 6 names to (polygon index, edge midpoint).

`build_maze` calculates each polygon's connection degree and makes the polygon with its type and seed. It applies each connection through `connect_pts` at the scaled midpoint and adds each `no_connect` pair. The result maps `"polygons"` to a mapping from Marathon indexes to builder identifiers, and maps each graft name to `(builder polygon id, scaled point)`.

### Caveats

- The docstring dimensions are for information only: at scale 80 the `maze` is about 775 by 900 units, and its doors are 40 to 80 units wide.

- The default scale 80.0 comes from the measurement in `tools/marathon/stats.py`. The median `Marathon` 1 door is 1.00 `WU`, and the standard doorway of this game is 80 units.

## `Marathon` level import (`tools/marathon/convert.py`)

### Goal

Change a `Marathon` level into a PERIHELION level JSON file. The formats have the same polygon structure. Polygons map to polygons, portal lines to connections, and solid lines with 2 users to `no_connect` pairs. An optional demo stage adds a player, an exit, and a small set of enemies and pickups. This output is for geometry checks, not tuned combat.

### Invariants

- The scale is 80 units for each `WU`.

- The tool changes each vertex list to the opposite sequence. The output level then uses the repository's canonical winding. The engine accepts the two winding directions.

- After `resolve()`, the connect count must equal the `Marathon` portal count. A different count raises `AssertionError`. This is the point of the tool: no portal is gone, and `autoconnect` opens no more doorways.

- Solid lines with 2 user polygons and coincident polygon pairs that are not connected become `no_connect` pairs.

- Type selection follows a set sequence. Platform type 5 becomes `corridor`. Area of 10 or more square WU becomes `dock`. Degree of 5 or more with area of 4 or more becomes `core`.

  Area of at most `1.7` becomes `transit` when degree is 3 or more. Otherwise, it becomes `corridor`. All remaining polygons become `generic`.

- The floor height, the ceiling height, and the type go below a `marathon` key on each polygon. The loader ignores that key.

### Verification

Run `uv run python tools/marathon/convert.py`. It writes `levels/marathon_arrival.json` and prints the polygon and connect counts. `convert.py m1 3 out.json` imports a different level. The connect count check runs on each import.

### Implementation

`_coincident_unconnected_pairs` finds nonadjacent Marathon polygon pairs with collinear edge pairs. The edges point in opposite directions and are coincident in the builder tolerance of `0.5` units at this scale. Such pairs show 2-faced thin walls or coincident overlap contacts. The test maps each edge pair onto one axis and compares their offsets and span overlap.

`convert()` makes each polygon with `detail_seed = index * 7919 + 13` and the selected type, then applies each portal line through `connect_pts` at its scaled midpoint. The player uses the map's first player start. If the map has no player start or its first start is out of range, the player uses the centroid of polygon 0. The exit uses the polygon with the largest hop count from the start in the polygons with an area of 2 or more square WU. If no polygon is that large, it uses the polygon with the largest hop count without an area test.

The demo stage, enabled by default with seed 5, puts polygons 2 or more hops from the start in a random sequence. It puts husks in the first 22 and mites in 8 remaining polygons with an area of one square WU or less. It also selects polygons for 6 `ammo_9mm`, 3 `medkit`, and 2 `ammo_shell` pickups and sets an intro line with the level name.

### Caveats

- The `assert ri == pi` check is an `assert`. Python removes it with the `-O` flag.

- The pickup pool condition `2 <= hops[pi]` tests a condition that the pool obeys by construction.

- Enemies and pickups can go into the same polygon, at the same centroid.

- `convert()` accepts a `name` argument that the command-line interface does not make available.

## `Marathon` measurements (`tools/marathon/stats.py`)

### Goal

Measure geometry in Marathon maps. The measurements include polygon counts, area, vertex and degree distributions, portal widths, and the polygon visits that the viewer can see from each sample point. Visibility uses an angular portal flood in the top-down view that stays correct in spaces that overlap. The tool also calculates the scale conversion. Because the median Marathon 1 doorway is `1.00` WU, one WU maps to 80 game units. With `--ours`, it measures the levels of this game through the engine's `visible()` function while a bot walks.

### Invariants

- A view line goes through a line with 2 users when the line is not solid, or when it is solid and transparent.

- The flood has a maximum depth of 15 and a maximum of 400 polygon visits.

- A visit is one polygon record for one portal sequence. A path to the same polygon through 2 sequences gives 2 visits, which agrees with the engine drawing results.

- The near count uses a radius of 8 `WU` from the sample point.

### Verification

Run `uv run python tools/marathon/stats.py` for all 3 games or supply one game key. The report prints one line for each solo level, totals, and the calculated scale. With `--ours`, it runs each `levels/l*.json` for 30 or less seconds with an `AggroBot` and prints the `visible()` distribution.

### Implementation

`visible_flood` measures angles from the initial polygon's centroid and shows each portal edge as an angular wedge. When the flood goes through a portal, that portal's wedge clips the wedge sent into the adjacent polygon. A sequence stops when its wedge is empty, it is at the depth limit, or the visit limit is full. The stack traversal counts visits, clearly different polygons, and visits to a polygon with a vertex in the near radius.

`_dist` returns a report with count, minimum, `p10`, median, `p90`, maximum, and mean. The `p10` and `p90` values select indexes from the sorted list. `level_stats` calculates the distributions and runs the flood for a set sample of approximately 40 polygons at equal intervals plus each player-start polygon. `report_game` prints the table, totals, and scale calculated from median doorway width. `report_ours` loads each level, moves a `GameSession` forward with an `AggroBot`, and samples `len(session.visible())` once each 30 ticks.

### Caveats

- The `p10` and `p90` values are index selections, not values calculated between points.

- When the visit limit stops a flood, the counted set changes with the stack sequence. The traversal is deterministic. Thus, the results stay stable across runs.

## Fixture tool (`tools/marathon/make_fixture.py`)

### Goal

Write a small, correct version-0 WAD fixture with Marathon 1 level 29, `5-D space`, and only the chunks used by the parser. Level 29 is multiplayer, and its name refers to spaces with the same top-down coordinates. The output is `game/tests/fixtures/m1_5dspace.wad`, approximately 14,000 bytes, without a MacBinary wrapper.

### Invariants

- The kept chunks are `EPNT`, `LINS`, `POLY`, `OBJS`, and `Minf`, in that sequence, when the level has them.

- Chunk headers are the 12-byte version-0 form. The next offset of the last chunk is 0.

- The header is version 0 with one `wad`. The directory offset is 128 plus the `wad` length. The directory holds one entry: offset 128 and the `wad` length.

- The checksum is 0. The parser does not compare checksums.

### Verification

Run the tool. It writes the file and prints its byte count and kept chunk tags. A parse of the output with `MapFile` returns one level. Its points, lines, polygons, and objects agree with level 29 of the source map.

### Implementation

The tool opens the Marathon 1 map through `MapFile`, reads the chunks in directory entry 29, and assembles the kept chunks into one sequence. It then writes the 128-byte header, chunk sequence, and one directory entry.

### Caveats

- The level index 29 and the level name are facts about the Steam map file.

## `Maze` demo tool (`tools/marathon/make_maze_demo.py`)

### Goal

Write `levels/maze_demo.json`, a level that the player can use with the Arrival maze. A spawn hall is welded to the maze's entry graft edge, and an exit vault is welded to its exit edge. The two welds use coincident edges that autoconnection turns into connections.

### Invariants

- The level after `build()` has 68 polygons: the 66 `maze` polygons, the `hall`, and the `vault`. An `assert` checks the count.

- Each new outer polygon keeps the complete graft edge without a change. A centroid test makes sure that its outward direction points out from the maze polygon.

- `b.build()` runs before the write. The `schema`, winding, and `spawn` checks stop the tool on an error.

### Verification

Run the tool. It writes the `JSON` file and prints the polygon and connect counts.

### Implementation

`_edge_at` finds the polygon edge with a midpoint nearest a given point. `_extrude` reads that edge and finds its outward normal through a centroid test. It makes a 4-vertex cell from the edge endpoints and 2 offset points. It applies `depth` outward and `widen` along the edge. The hall is a `dock` with depth 140 and width increase 40. The vault is `storage` with depth 150 and width increase 60.

The player starts in the hall, and the exit is in the vault. The tool puts 5 husks at named maze crossings and 4 mites in small loop cells. It adds 4 supply pickups at the centroids of cells with one connection. The intro contains one line.

### Caveats

- Defect: the return annotation of `_extrude` is `int`, but it returns a tuple of the polygon identifier and a center point. The two callers correctly use the polygon identifier and center point. Only the annotation is incorrect.

## Campaign generation tool (`tools/levelgen/campaign.py`)

### Goal

Write the 10 campaign levels and arena to `levels/`. The campaign follows the progression in section 8.1 of `design_document_2.md`: deniable errors, paradox that the player can examine, open paradox, and, last, graph structure only. The module also gives position helpers copied by the dense level modules.

### Invariants

- The level sequence is `l01` to `l10`. The output names are `l01.json` to `l10.json`, plus `vigil.json` and `campaign.json`.

- Each level goes through `b.build()` before its data is written.

- The manifest `campaign.json` lists the 10 campaign files only. The `arena` is not in it.

### Verification

Run `uv run python tools/levelgen/campaign.py`. For each campaign level, it prints the name and polygon, connection, door, and enemy counts before it writes the file. The arena and manifest add 2 more lines, which makes 12 files in `levels/`.

### Implementation

The helper functions:

- `center` is the vertex mean of a polygon.

- `squad` divides a string of enemy names and puts them on a circle of radius 32 around the polygon center.

- `wall_basis` returns a point, wall direction, and inward normal for a specified edge. A rectangle has stable edge sequence: 0 west, 1 south, 2 east, and 3 north. A centroid test corrects the normal direction.

- `wall_pos` is a point at an inward offset from a wall, for `terminal` texts and items on racks.

- `cache` puts supply items in a level. With a wall index, it puts them along the wall at 13-unit intervals and an inward offset of 16. Without a wall index, it makes a small grid offset from the center with 3 items in each row.

- `sector_ring` makes `n` cells in a circle between 2 radii and 2 angles. `arc_mid` returns a point on an arc.

Functions `l01` through `l10` import the module with the same number from `tools/levelgen/dense/` and return its `LevelBuilder`. The campaign module first adds `game/` and `tools/levelgen/dense/` to `sys.path`.

`vigil()` builds `THE VIGIL`, an arena with a six-sided center area of radius 110 and 6 six-sided petals at radius 280. Each petal welds to the center, and petal `i` welds to petal `i+2`, which makes level 8's folded shape again. The function sets `data["vigil"]` to `True` and `alert_hops` to 1, puts the player and one cache at the center, and sets the intro.

For each level function, `main()` makes the `LevelBuilder` and reads `to_dict()`. It runs `build()` for validation, writes the data, and counts entities of the 6 enemy types. It then builds and writes the arena and writes the manifest.

### Caveats

- The printed enemy count contains `husk`, `mite`, `spitter`, `brute`, `shrieker`, and `warden`. It does not count `flicker` entities.

- `to_dict()` runs before `build()`. The written data is the `to_dict()` output, and `build()` only does the check.

- The comments above `l01`..`l10` keep the short specfile text of each level.

## Dense level modules — the same contract (`tools/levelgen/dense/`)

### Goal

Each module builds one campaign level again at the `Marathon` density specified by `MARATHON_LEVEL_STANDARDS.md`. It keeps the initial level with smaller cells. It keeps a skeleton from `campaign.py` and adds a specified mesh around it.

### Invariants

- The paradox structure of each level does not change: the same builder calls, the same coordinates, the same connect and `no_connect` topology. The module docstrings mark these structures as `sacred`.

- Lore data does not change. This data includes the name, `tier`, ambience, intro, terminal text, `key_meta` data, and radio-trigger targets.

- The `otherworld` quantity: zero cells in levels 1 to 6, and one isolated cell in level 7. Level 8 gets one small group. Level 9 gets full `districts`, and in level 10 most of the `mesh` is `otherworld`. No `otherworld` cell holds a door, a key item, a `terminal`, or the exit.

- The named `spawn` and exit walls stay fully solid. `WorldStreamer` cuts its 70-unit doors there.

- The position helpers (`center`, `squad`, `wall_basis`, `wall_pos`, and `cache`) are copies of the functions in `campaign.py`. These copies let each module work without an import of it. The only exception is `l03.py`, which imports those helpers from `campaign.py`.

### Verification

Each module runs as a program and prints its counts: polygons, connects, doors, and for some modules enemies or `type` counts. Each goes through `b.build()`, which checks winding, `schema`, and `spawn`. The docstrings of `l02`, `l03`, and `l07` record measured `visibility` numbers from the sample tool that scored the `meshes`.

### Implementation

The module APIs have 2 forms. Modules `l01`, `l02`, `l03`, `l05`, `l07`, `l09`, and `l10` have `lNN()`, which returns a `LevelBuilder`, and `build()`, which returns the output from `resolve()`. Modules `l04`, `l06`, and `l08` have `build()`, which returns a `LevelBuilder`. `campaign.py` imports the applicable function from each module.

All 10 modules use the same construction method. Adjacent rectangles weld into portals through autoconnection of coincident edges. The doorway splitter turns a short wall edge embedded in a longer wall into an opening, while `no_connect` keeps a wall solid.

Corridors are cell chains that bend each 2 or 3 cells and do not use long rectangles. Large areas are grids of adjacent cells, and about 10 percent of cells have one connection. Widths follow 3 ranges: 40–60-unit slots, 70–90-unit doors, and wider chamber seams.

### Caveats

- The name `build` has 2 different return forms across the 10 modules. Thus callers must know which form each module returns.

## Level 1 — `DOCK 4 — SWEEP` (`tools/levelgen/dense/l01.py`)

### Goal

The first level has difficulty level 1 and uses a dock district. Its deniable paradox is a storage ring with 9 segments in an 8-segment footprint.

### Invariants

- The paradox structure stays as a junction, 8 ring segments, and a phantom segment at `(960, -420)` far from the circle. `no_connect` keeps the junction disconnected from the north, west, and east segments. It also keeps 2 more pairs disconnected. 2 `connect_pts` calls route traversal through the phantom. This causes a walker to count 9 circle segments.

- No new cell has an edge coincident with the 10 structural polygons. The only permitted weld connects the hall to the junction's west wall.

- The `spawn` cell keeps a fully solid 180-unit west wall. The exit polygon keeps solid west, `east`, and `south` walls.

### Verification

Run the module. It prints the polygon, connect, and door counts of the `resolve()` output.

### Implementation

The `mesh` has about 120 cells in named groups:

- the `dock` bay with a `gantry walk` and `suit lockers`,

- the `north` `spine` with the `crew annex` (`quarters`, `mess`, `san block`, `medbay`, `records`),

- a west loop with the `west hold`,

- the `hall`, as 3 cells on the line of the `campaign.py` `hall`,

- the `apron` with the `cargo hall` and the `drum yard`,

- a `maintenance warren` with `pump` cells and a slot below the `ring`, and a `sump gallery` below the `drum yard`.

The module uses 6 more `no_connect` calls to control graph degrees. The sump gallery keeps 2 doors. The drum-yard cells keep 2 doorways into the cargo hall. The west hold keeps 2 of 3 doors, and the quarters row opens at the two ends.

9 terminal texts keep the lore without changes at `wall_pos` locations. Groups of `husk` enemies are in 5 ring segments with supplies on racks. The district adds combat to work areas while the crew annex has no combat. The player starts in the dock cell on the west side, and the exit is in the circle segment on the southeast side.

### Caveats

- The docstring marks the structure as `sacred` and points at `LEVEL_DESIGN_PLAYBOOK.md` section 11.

## Level 2 — `COOLANT ROW` (`tools/levelgen/dense/l02.py`)

### Goal

This level has difficulty level 1. Its paradox sends the player from the north door of pump bay A through the north wall of pump bay B. The player sees movement in the direction opposite to the travel direction. The level also attaches the Arrival maze as `HATCH SIX` and puts the `weapon_smg` armory behind the red door.

### Invariants

- The paradox is one `connect_pts` call that connects the north edge of bay A to the north edge of bay B. The two bays are `4 x 4` grids of `80 x 90`-unit cells.

- The maze graft uses the same call as `campaign.py`: `build_maze` at `(1300, 500)` with scale 80. Its 30 `no_connect` pairs prevent connections at contacts that overlap. The maze is optional because the player can get to the level exit without entry into it. A cache and terminal are in the vault at its far end.

- The `armory` has only one opening, the red door: `door_pts` plus `no_connect` on the same pair. The exit is in the `armory`.

- The entry cell keeps its full 140-unit west wall solid. The `armory` keeps its `north`, `south`, and `east` walls solid.

### Verification

Run the module. It writes a `JSON` file and prints the name and the polygon, connect, door, and enemy counts. The docstring records the measured `visibility` median: 8, equal to the `Arrival` import level with the same sample tool.

### Implementation

The Row is a sequence of 80-unit-wide corridor cells. It runs west, turns north, runs east, turns south, and ends in a tail toward the armory. `_grid` makes the 2 pump bays and the `4 x 2` filter district. The district is south of the Row.

Two routes lead to the filters. They are a 60-unit slot and an 80-unit connector cell that closes a loop. A sump chain continues south from the tail junction to a wet pump chamber. Approximately one alcove branches from each group of 10 Row cells.

The red key item (`VALVE WHEEL`) hangs on the `manifold` wall in the `filter` `chamber`, below the procedure `terminal`. The `armory` cache racks the `weapon_smg` directly in the red doorway.

The enemy set keeps the `campaign.py` groups cell for cell and adds more combat. `mite` enemies are in the Row, and `husk` enemies are in the bays. One spitter is in the filters, a second one is in the tail, and a spitter and mite are together in the sump.

### Caveats

- The `graft` `weld` into the `filter` grid uses the `east` edge midpoint (640, 337.5) of the `filter` cell `k[1][3]`.

## Level 3 — `HYDROPONICS TORUS` (`tools/levelgen/dense/l03.py`)

### Goal

This level has difficulty level 2 and a paradox that the player can examine: a circle of 6 sectors closes onto its opposite end. A walk through part of the arc that the player sees thus completes a full loop. The level contains `weapon_shotgun` and a blue door into the garden.

### Invariants

- The skeleton builds first with the same polygon indices as `campaign.py`: circle sectors at `0..5`, entry at 6, garden at 7, and `storepolygon` at 8.

- One `connect_pts` call joins the end face of `ring[5]` to the start face of `ring[0]`.

- The blue door connects `ring[2]` to the `garden`. The blue key item is a `SCRUBBER CARTRIDGE` on the `end cap` in `ring[5]`.

- There are no `otherworld` cells. The `otherworld` starts at level 7.

- The spawn cell keeps 2 free 110-unit walls, and the garden keeps its complete 166-unit south wall.

### Verification

Run the module. It prints the polygon, connect, door, and enemy counts. The docstring records the `mesh` dimension (about 120 cells) and the correction to view lines that the measured flood caused.

### Implementation

3 districts branch from the skeleton:

- District A is the `east` access. It holds a `dock` `spawn`, a `spine` gallery, a `lab` `annex` (3 by 3 grid), and 5 `bench` cells. It also holds a `medbay` `annex`, a `storage` `hall`, a `quarters` group, a `pump plant`, and a loop, connected by `transit` junctions.

- District C is west of the entry and contains a records annex and a route that goes down that gets to `storepolygon` from behind. This route forms a loop while it keeps the ring as the faster route.

- District B, west of the `storepolygon`, holds `drum` cells, a `records` `hall`, and a second `pump` `chamber`.

`_grid` and `_chain` make large areas and corridor runs. 2 `no_connect` calls close the north and south seams of the lab annex's center cell. The docstring records that the open `3 x 3` grid on the spine raised the measured visibility median to 18. This value is above the target range of `8..16`. 4 more `no_connect` calls make each bench cell have only one connection.

The `weapon_shotgun` cache is at the entry threshold of `ring[0]`. A code comment states that each route crosses `ring[0]` and the threshold is in the two directions of travel. The exit is in the garden.

### Caveats

- This module imports its helper functions from `campaign.py`. The other 9 modules copy them.

## Level 4 — `THE LONG GALLERY` (`tools/levelgen/dense/l04.py`)

### Goal

This level has difficulty level 2. Its paradox contains 2 galleries that are parallel. The player can see 4 crossings from the south side and 3 from the north. The level calls this `4 GOING 3 BACK`. The vault behind the blue door contains `implant_lightning`.

### Invariants

- The paradox topology uses 4 crossing chains of 4 cells between the galleries. One `no_connect` call closes the north mouth of the first crossing. 4 open mouths are on the south wall and 3 are on the north wall.

- Gallery seams in `SEAMS` put each crossing mouth, district door, and alcove in one segment wall. The doorway splitter accepts only a contained edge.

- The dock group touches the north gallery but must not open into it. The crossings are the only paths to the north gallery.

- The blue door on the `south` gallery is the only opening of the `vault` (`door_pts` plus `no_connect`). The blue key item, a `SURGEON'S CARDKEY`, is in the crossing that the `north` side does not have.

- The `spawn` cell keeps its west wall free.

### Verification

Run the module. It prints the polygon, connect, door, and entity counts.

### Implementation

The galleries are 2 chains of 9 segments. The crossings are chains of 4 cells at 4 `x` positions. Around them are 4 areas:

- a west `dock` group with a checkpoint station and `bunk` cells,

- a `south` medical wing: the `reliquary`, a `morgue`, `records` cells, `crew rows`, and `boilers`,

- a `records` `annex` with the `chapel` and the `undercroft`, `south` and `east` of the galleries,

- a north deck with 2 levels of pump and storage cells, a spine row, and a work run. A lab row connects through 2 stair cells.

`no_connect` calls shape the groups. They keep one reliquary door and 2 boiler doors, seal deck rows into halls, and keep niches with only one connection.

The `implant_lightning` item is at the `vault` entry threshold, on the line from the blue door to the exit. All routes cross that line. The exit is in the `east` part of the `vault`.

### Caveats

- The docstring gives the `district` dimension (about 122 cells) and the 3 width `registers`.

## Level 5 — `TWO WINGS` (`tools/levelgen/dense/l05.py`)

### Goal

This level has difficulty level 3. It has 2 wings in positions that the station drawing shows as one wing. The level contains 2 copies. The lobby's east door leads to the far wall of the east wing, and the 2 chapel doors cannot be on the same wall. The level contains `weapon_rail`.

### Invariants

- Skeleton polygons are made first in the `campaign.py` sequence. This keeps the indices referenced by radio-trigger targets.

- The paradox keeps its initial calls: the lobby's east wall connects to `e1` at `x = 1360`, and `w3` connects to the chapel's north wall. The west edge of `e3` connects to the chapel's east wall. The `bunk_f` chamber is behind a shoot door on `w1` paired with `no_connect`.

- One function stamps the wing district twice at x offsets 0 and 1360, the specified separation between the wings. The two districts contain the same polygon layouts, which is the level's primary narrative device.

- No new cell touches a wall with a specified connection point or the related wall in the other wing. The east district attaches only to `e2` and `e3`, which gives access to the east wing only through the paradox door. The chapel receives no new connections.

- One difference in the copies is a user decision. The last west `spine` cell opens into the `lobby` `annex`, and the same cell in the `east` copy has one connection.

### Verification

Run the module. It prints the polygon, connect, and door counts.

### Implementation

`_wing_district` makes approximately 50 cells for one wing:

- a `south` `chamber` with `storage` cells,

- a `north` band with `bunk` rows, `footlocker` `niches`, and a slot loop above the `bunk` row,

- a west wrap and a `spine` with alcoves,

- a `deck office`, a `laundry` pair, a 2 by 2 `common room` of 130-unit cells, and a `pantry`.

`_lobby_district` makes approximately 33 cells: a `deck` `junction`, a `mess hall` (2 by 3), a loop, a `medbay` `niche`, `mail slots`, a `laundry` group, and a `storage` run.

Each wing contains a copy of the gold key item, `STEWARD'S KEY`, in `bunk 12`. The chapel racks `weapon_rail`, ammunition, and a `portable_hole` at its 2 doorways. The player crosses only one wing before the key. A single cache at the center could therefore be missed, so each wing contains a copy.

The exit is the chapel's `REFUGE HATCH`, locked by the gold key. One lobby terminal text contains model output copied without changes. A code comment gives its source.

### Caveats

- The difference between the copies is not a written call. The west `s6` cell touches the west edge of the `deck` `junction`, and `autoconnect` connects them. The `east` `s6` cell has no neighbor there.

## Level 6 — `MIRROR WARD` (`tools/levelgen/dense/l06.py`)

### Goal

This level has difficulty level 3. In its mirror paradox, the ward's south wall connects back to the same wall. This sends a walker back to the ward. The `DISCHARGE HANDLE` is at the mirror wall and unlocks the morgue exit.

### Invariants

- The sealed group that contains entry, ward, side, morgue, and vestibule keeps the rectangles from `campaign.py` with the same bytes.

- The mirror contains one call: `connect_pts(ward, (680, 120), ward, (680, 120))`. The call connects opposite sides of the same polygon at the same point.

- The red key item is the `DISCHARGE HANDLE`, in the `ward` at the mirror wall. The exit opens only with it.

- The `entry` keeps its west, `north`, and `south` walls solid. The `morgue` keeps its `east` wall solid.

### Verification

Run the module. It prints the polygon and connect counts.

### Implementation

The district comes from a text tile map of 13 rows by 16 columns, with 90-unit tiles and one character for each type. Types are quarters, records, medbay, storage, pump, chapel, corridor, and 50-unit pinch cells. `MERGES` makes 5 larger cells from smaller cells: the triage pair, recovery cells, chapel nave, and dais. Their chamber seams use the wider width group.

Corridor tiles divide across the run into pairs of 45-unit cells. This keeps 8 or more visits across a full screen. A tile wall that faces a pinch or the vestibule stays at full width because the splitter accepts only a contained edge. A chamfer step cuts no more than 10 corner cells when the corner has no neighbor on the two adjacent sides.

`NO_DOOR` pairs limit each chamber group to 1 or 2 doors. The code does not open all coincident edges. Corridor tiles of degree 3 or more become `transit`. An alcove step adds no more than 14 slot niches with 40-unit mouths to corridor walls with no neighbor. It checks all rectangles and adds no alcove that overlaps one.

The code puts `weapon_tau` in 2 racks: one in the side chamber and one at the morgue threshold on the route to the exit. A code comment states that the player can miss the `weapon_smg` rack in level 2's armory. In contrast, the player must find this weapon.

### Caveats

- The `alcove` overlap test runs with a margin less than zero. An `alcove` can then touch its `tile` edge to edge. That contact is the `weld`, not a collision.

## Level 7 — `RECURSION STACK` (`tools/levelgen/dense/l07.py`)

### Goal

This level has difficulty level 3 and contains an aisle with no end. The stack's north edge connects to its south edge. Its spaces include records, a closet with the staff-mind cores, and a deep stack locked behind the `REGISTRAR'S STAMP`.

### Invariants

- The 5 initial polygons are made first at their initial coordinates and in a set sequence: entry 0, stack 1, closet 2, deep 3, and annex 4.

- The `paradox` is `connect_pts(stack, (410, 0), stack, (410, 140))`. The `annex` is behind a `shoot` door with a `no_connect`.

- One `otherworld` cell is in the level. It connects aisles 2 and 3 in the middle of the stacks and overlaps the shelf space in the top-down view. It holds no door, key item, `terminal`, or exit.

- The `entry` keeps its full west wall solid. The `deep` polygon keeps its full `east` wall solid.

### Verification

Run the module. It prints the name and the polygon, connect, door, `terminal`, and `otherworld` counts. The docstring records the measured numbers: 231 `district` cells, `visibility` median 12.5, maximum 22, mean degree 2.59.

### Implementation

5 districts replace the 3 doorway hops in the `campaign.py` version:

- District A contains a checkpoint threshold, corridor chains with an added south row, an 8-sided rotunda, and storage cells for the checkpoint station.

- District B: a `catalog hall` (3 by 3 grid of 170 by 160 cells) with a `foyer` and exit chains.

- District C contains 9 shelf aisles of 16 cells, each `90 x 50` units, with cross corridors at the two ends. Aisle 4 is sealed 2 cells before the south corridor. Slot portals connect adjacent aisles for 2 rows out of each 3. A comment records that cross-aisle sightlines set this district's visibility count.

- `District` `D`: the `corridor` route to the `closet`.

- `District` `E`: the `deep` `intake` (2 by 2 grid).

`connect_pts` connects districts and initial polygons across canvas distances. `rect_c` makes a cell with one 30-unit chamfer, while `grid` makes chamber grids with selected chamfers. The gold key item, `REGISTRAR'S STAMP`, is in the closet. The exit is in the deep polygon and opens only with gold.

### Caveats

- The module ends with a `_ = (...)` tuple of weld-only cell names. Static code checks then do not report an `unused` result for those names.

## Level 8 — `THE FOLD` (`tools/levelgen/dense/l08.py`)

### Goal

This tier-4 level has a central chapel and 6 equal petals, with each petal folded onto petal `i+2`. This makes the count depend on the walker's route. It contains the first warden fight.

### Invariants

- The fold keeps the `campaign.py` structure byte for byte. It uses identical `ngon` calls with center radius 100 and petal radius 100 at distance 260. It also keeps center-to-petal welds and fold welds from petal `i` to petal `i+2`.

- `alert_hops` is 1: the fold eats sound.

- The petals stay `generic`: 6 equal cells are the `paradox`, not a tag error.

- Otherworld space is limited to one 6-cell group connected to the corridor mesh as a side loop. It contains no door, key item, terminal, or exit.

- The gate chamber welds to free edge 5 of petal 0. The paradox uses only petal edges 0, 2, and 4.

### Verification

Run the module. It prints the polygon and connect counts and the `type` counts.

### Implementation

The chapel deck is a textual tile map of 14 rows by 31 columns with 90-unit tiles and one letter for each type. Types are dock, corridor, duct, quarters, records, medbay, chapel, storage, pump, otherworld, transit, and alcove. `MERGES` makes the nave cells and pump hall. `DOORS` lists tile pairs allowed to weld across district boundaries, while `SEALS` keeps named seams in one district solid, including the quarters walls. All other cross-district contacts receive `no_connect`.

Alcove tiles become niches with 56-unit mouths, and an assertion checks that each has exactly one walkable neighbor. Duct tiles become 60-unit corridor strips.

The code spawns the `warden` in the center with `hp` 180 and `tether` 1. The exit is in the center, behind a `warden` gate. A rack in the fold threshold cell on the walk line holds `weapon_shotgun`, and a `medkit` shelf is in the gate `chamber`. The comment records the game condition: a `medkit` on the floor goes into use only below 70 `hp`.

### Caveats

- Tile adjacency determines the mesh welds. The fold structure does not touch the tile mesh directly. Only the gate chamber reaches it through one `connect_pts` call.

## Level 9 — `TESSERACT DECK` (`tools/levelgen/dense/l09.py`)

### Goal

This tier-4 level is pure graph structure: 16 equal cells form the vertices of a 4-dimensional cube, with each cell connected to 4 others. Along the access route, station spaces progressively become otherworld.

### Invariants

- The structure stays 16 squares with one cut corner each. For each dimension `d`, cell `i` connects to cell `i^(1<<d)` through edge `[0, 1, 3, 4][d]` on the two cells. Edge 2, the chamfer, is the only solid wall and holds the items.

- The access mesh stays at `x <= -130`, leaving the structure's canvas area clear so the doorway splitter cannot alter its specified edge numbers.

- The `ANTE` cell is an additional chamfered cell in normal space. Its chamfered edge welds to the chamfered edge of cell 0000. The chamfered edge of cell 1111 stays free so `WorldStreamer` can carve the exit there.

- `Otherworld` cells hold no key items, `terminal` texts, doors, supply items, or the exit.

- The `void` key item (`DOCENT'S TOKEN`) is in cell 1010. The exit is in cell 1111, locked on it.

### Verification

Run the module. It prints the polygon, connect, and door counts. The docstring records the `mesh` size: 236 access cells and 253 cells in total. This total is the `Marathon` median.

### Implementation

The helper functions construct the access mesh. `_grid` makes chambers from width and height lists. `_hall` makes a corridor chain along axis-aligned legs, placing square corner cells at turns and leaving end faces open for the splitter. `_bay` makes an alcove with an optional chamfer on a free corner.

Normal and otherworld districts alternate along the route:

- `D1`: a `dock` area with the `spawn`, then a `corridor` chain.

- `D2`: a full `otherworld` `district`.

- `D3`: a `quarters` and `medbay` area, then a `corridor`.

- `D4`: a second `otherworld` `district` with a `south` group.

- `D5`: a `records` and `chapel` area, with welded outer cell rows along the `chamber` faces.

- `D6`: the threshold `otherworld` `district`, with a slot loop to the `ANTE` flank.

`weapon_smg` is on the route through D1, and `weapon_shotgun` is on the route to the deep district. Comments record a placement observation. An item on a threshold route is collected in almost every run. A centered item is collected in about half of all runs. Enemy groups grow stronger along the route, and otherworld cells contain only enemies.

### Caveats

- `_bay` builds a list named `v` and then deletes it. No path uses that list.

- The module ends with a `_ = (...)` tuple of names used only for `weld` operations.

## Level 10 — `PERIHELION CORE` (`tools/levelgen/dense/l10.py`)

### Goal

This last tier-4 level uses a group of hexagons that forms the Cayley graph of `Z6` with steps `+1` and `+2`. The sanctum contains the vault, warden, and last guard encounter. Normal cells are now a small minority, and most of the mesh is otherworld.

### Invariants

- The skeleton is made first with indices `0..8`: airlock, hexes `0..5`, sanctum, and alcove. Step connections stay hex `i` edge 0 to hex `i+1` edge 3 and hex `i` edge 1 to hex `i+2` edge 4. Hex edge 2 holds the shoot door on hex 1 and vault door on hex 3. Edge 5 stays free and carries the item racks.

- The `vault` door opens only with the `void` key item (`WATCH SIGNET`), which is in `hex` 5.

- The mesh occupies unused canvas at `y >= 720`. This keeps each skeleton wall noncollinear with mesh geometry so the splitter cannot alter the structure. Districts connect through `connect_pts`.

- The last `core` cell of the `mesh` `welds` to `hex` 0 at (348, -90), the same edge that the `airlock` used in `campaign.py`.

- The normal cells are only: the entry run, the checkpoint, 3 pockets (`records`, `storage`, `quarters`), and the 3 `core` cells before the hexes. All other `mesh` cells are `otherworld`. No `otherworld` cell holds a door, a key item, a `terminal`, or the exit.

- `alert_hops` is 1.

### Verification

Run the module. It prints the cell, connect, and door counts, plus the degree, vertex, and `type` counts.

### Implementation

The `Walk` class constructs corridor chains with a cursor. `cell(length)` puts one cell and advances the cursor. `turn(direction)` puts a square corner cell with an optional chamfer on its free corner. `alcove(side)` welds a niche to the last cell. `set_width` changes the width register, and the splitter accepts the contained narrow edge.

`Chamber` is a grid with optional solid pillar cells. `siderow` puts a row beside a run and welds each new cell to the full edge of its corresponding run cell. `chamber_at_cursor` puts a grid on the cursor edge.

The route begins with the airlock, a vestibule, and an entry run with `weapon_shotgun` at its threshold. A `2 x 3` checkpoint at the 160-unit seam register leads into the otherworld strands:

- the `concourse`, `chamber` `A`, and the 8-side rotunda,

- `chamber` `B`, a `records` pocket `north`, and `chamber` `C` `south`,

- a pillar `hall` `P1` with a loop, and a `quarters` pocket,

- the western route, which splits into 2 paths around a 56-unit pinch. A second pillar hall, P2, bypasses the pinch, followed by 3 core cells before the weld into hex 0.

Cross connections close the `mesh` into a `district`, not a `tree`. A rack at the threshold of the last `core` cell holds `weapon_smg`. The comment explains why: the `pistol` cannot maintain a distance of 60 to 140 units from the `warden`.

### Caveats

- Defect: the comment at `post2` states the code selects the 88-unit cell after the post cell. The code instead selects the entry 2 positions later in the cell list, which is a 96-unit cell. Hall P2 thus branches one cell later than the comment states. The level still builds and plays.

## Flicker tool (`tools/flicker_placement.py`)

### Goal

Place flicker ambush enemies in levels with adversary forces (`l07`, `l08`, and `l09`), under the user instruction dated 2026-07-13 that is copied into the docstring. Counts scale with each level's adversary presence: 8, 11, and 14. The tool writes entities to `levels/lXX.json` and records a one-line rationale for each in an audit log.

### Invariants

- Only levels 7, 8, and 9 receive flicker entities. The docstring records the supporting campaign-phase map and otherworld cell counts for each level.

- A candidate polygon must be dark, meaning no light fixture reaches it, and have graph degree 2 or more. Its bounding-box diagonal must be 120 or more units, and it must be in 40 hops of the player spawn.

- `Otherworld` cells are out. The comment records the cause: they are the `Adversary` area, not a location where a `flicker` waits.

- Each selected polygon receives one flicker. The intended minimum pairwise hop distances are 2 in `l07`, 2 in `l08`, and one in `l09`.

- The selection is deterministic: the `shuffle` seed comes from the level id.

- A placed `flicker` stays at least 26 units from every other entity `spawn` point in the polygon.

- The audit log write replaces the entries of the levels in the run and keeps the others.

### Verification

Run with `--apply` to print candidates and selections for each level, write the entities into the level files, and write `tools/flicker_placement_log.json`. With no flags, the tool only prints its plan. Each log entry contains the level, polygon, position, and rationale.

### Implementation

`analyze` loads the level and makes a `GameSession`, which initializes lighting data. It reads lit polygons from `session.lighting._by_polygon` and builds adjacency from `connects`, `connects_x`, and doors. It calculates BFS hops from the spawn and tests candidates against the 4 conditions.

`select_placements` prioritizes degree-2 chokepoints and then larger diagonals. A seeded shuffle followed by a stable sort breaks ties deterministically. Selection proceeds one candidate at a time and compares only each candidate's BFS depth from the player spawn. Defect: a sufficient difference in spawn depth does not guarantee the required pairwise graph distance between selected polygons. `justification` builds the rationale from each candidate's measurements.

`apply_placement` reads the level JSON and calculates the selected polygon's vertex mean. `_find_clear_spot` tests that center first, then tests 11 successively larger rings with 8 directions per ring. Each radius is one twenty-fourth of the bounding-box dimension. Each candidate point must lie inside the polygon and outside the separation radius of all entities. The tool appends an entity with a rounded position and empty `props`, then writes the file with `indent=1`.

### Caveats

- Defect: the parser accepts `--dry-run`, but no code reads it. A default run already writes nothing without `--apply`, so the flag has no effect.

- Defect: when no ring point is accepted, `_find_clear_spot` returns the bounding-box center. That point can lie outside the polygon or in another entity's separation radius. A comment calls this fallback a controlled stop.

- Defect: an apply run neither removes nor recognizes flickers from a previous run. A second application can place 2 flickers in each selected polygon, while the replaced audit entries describe only the newest additions.

- The first `sorted` call in `select_placements` has no effect because the following shuffle discards that sequence. Only the second sort determines the last sequence.

- The tool reads `session.lighting._by_polygon`, an attribute with a `_` name prefix.

- A level id out of `TARGETS` raises `KeyError` in `main`.

- The docstring records a known limitation. Terrain-shadow analysis is unavailable for levels 7 through 9 because the repository contains no textures for them. `polygon_terrain()` thus returns an empty list. Darkness is the only selection signal. Review the selection when those textures enter the repository.

## `Marrow` `consult` 1 (`tools/design/consult_marrow.py`)

### Goal

Request Sol's assessment, through OpenRouter, of the marrow—the adversary reserve, its organ, and the agents that pass through breaches. The prompt includes complete copies of `DESIGN_7_25.md`, the research packet, and the Bayescraft text. It does not change the copies. It asks for recommendations on each open question and a first implementation draft. The tool only sends the request and does not build game code.

### Invariants

- The specfile and packet must exist on disk. If the packet does not exist, the error explicitly states that the tool substitutes no placeholder.

- Input files are included in full and without changes.

- The API key is loaded first from `$OPENROUTER_API_KEY`, then from the key file at the repository root, and finally from a second key file. The key is never printed.

- With no key and no `--dry-run`, the tool stops with exit code 2.

- Each run writes `prompt.txt` in a new UTC-timestamped directory below `out/consult/marrow/`.

- The prompt text includes all hard requirements. Agents sample only near cells, a breach has no scale factor, and there are no feature flags.

### Verification

Run with `--dry-run`. The tool writes the prompt file, prints its length and the section names, and sends no API request. A live run streams the model response into the same directory through `consult_machinery.stream_consult_responses`, with the `provider` set to `openai` only and `allow_fallbacks` off.

### Implementation

The module imports `consult_machinery`, the shared model request engine, from `tools/musicgen/`. `PRODUCT_CONTEXT` and `ASK` are module constants. `build_prompt` puts together the header, product context, specfile, packet, and `ASK` text. It also adds the Bayescraft section extracted by `cm.extract_bayescraft` from the global `CLAUDE.md`. Each part receives a `cm.section` frame.

`main` parses `--dry-run`, `--model`, `--effort` with default `high`, `--max-tokens`, and `--out-root`. It then makes the timestamped directory and either stops for a dry run or sends the model request.

### Caveats

- The second key path points outside the repository into `~/Documents/youtube/autoclipping/`.

- The section-name print finds lines of 10 or more `=` characters, which form the `cm.section` frame.

## `Marrow` packet tool (`tools/design/build_marrow_packet.py`)

### Goal

Build `MARROW_CONSULT_PACKET.md` from the research fleet's journal. The research section comes from structured fleet results. The tool does not add transition edits between the research output and the model prompt. Critic results appear twice: once in full and once as objections attached directly to each named candidate.

### Invariants

- For each lane letter, the last result takes priority. A second workflow run appends results after the first set, and the critic numbers objections against that later set. Combining the two sets could duplicate research and attach objections to the wrong candidates, which is why the docstring records this rule.

- A journal with no lane results stops the tool. It does not write an empty packet.

- Each candidate with objections is followed by the corresponding objection text.

- The frame text, the open check list, and the end note are constants in this file.

### Verification

Run with a journal path. The tool writes the packet and prints totals for letters, lanes, candidates, sources, and items with objections, followed by one line for each lane. The checked-in packet is generated output from this tool.

### Implementation

`load` reads the journal as newline-delimited JSON and keeps `result` events. A result with `candidates` is a lane keyed by its letter, while one with `thin_lanes` is a critic result. `lane_letter` accepts labels in either `LANE G — ...` or `L — ...` form. `build_flag_index` maps `(lane letter, candidate number)` to objection text. An objection without a candidate number becomes a lane-level objection at number 0.

`render_lane` prints the lane header and lane-level objections. For each candidate, its fields appear in a fixed sequence, followed by its objections. Dead ends, `walk_path`, and sources come last. `render_critique` prints the critic lists without changes. `main` sorts lanes by letter and assembles the sections. It writes to the default output path or to the path in the second command-line argument.

### Caveats

- The candidate number scan reads only the first 200 letters of each objection.

- When a second command-line argument specifies the output path, `main` reassigns the module constant `OUT` through `globals()`.

## `Marrow` `consult` 2 (`tools/design/consult_marrow_r2.py`)

### Goal

The second marrow model request supplies the first model response as received and a second research stage. The model must revise its draft wherever new evidence contradicts it. It must then describe the hub layout as a playable area, the largest open unit requested by the user. `ASK` lists 6 numbered revision points, including peer commitment, the Kin field, flocking, and an error in the decay condition.

### Invariants

- The specfile, the `consult` 1 response file, and the `wave-2` packet must be on disk. When a file is not on disk, the error names it.

- The first model response and packet are included without changes.

- The tool does not change the hard requirements in `ASK`.

- Output goes to a new directory below `out/consult/marrow_r2/`, with the UTC time as its name.

### Verification

Run with `--dry-run`. The tool writes `prompt.txt`, prints the length and the section names, and sends no API request.

### Implementation

The module imports `PRODUCT_CONTEXT` and `load_api_key` from `consult_marrow`. `build_prompt` puts together the header, product context, Bayescraft text, specfile, first model response at `docs/consults/marrow_20260725/sol_answer.md`, `MARROW_PACKET_WAVE2.md`, and `ASK`. `main` uses the same flags, missing-key stop, and streamed request restricted to the OpenAI provider as model request 1.

### Caveats

- The external key-path caveat from model request 1 also applies. There are no additional caveats.

## `Marrow` `consult` 3 (`tools/design/consult_marrow_r3.py`)

### Goal

The last model request before implementation treats the fixed specfile as authoritative over the second model response and adds `CODEBASE_SURVEY_R3.md` as new input. It requests a build-sequenced plan, a 4-layer verification gate for each unit, and a risk analysis. The plan controls an agent through long runs without user inspection between commits.

### Invariants

- The specfile, the `consult` 2 response, and `CODEBASE_SURVEY_R3.md` must be on disk.

- `ASK` requires the model to keep the fixed specfile and its hard requirements, including a construction assertion for breach scale.

- Output goes to a new directory below `out/consult/marrow_r3/`, with the UTC time as its name.

### Verification

Run with `--dry-run`. The tool writes `prompt.txt`, prints the length and the section names, and sends no API request.

### Implementation

`build_prompt` puts together the header, product context, Bayescraft text, specfile, second model response at `docs/consults/marrow_20260725/sol_answer_round2.md`, `tools/design/CODEBASE_SURVEY_R3.md`, and `ASK`. `main` follows the same flow as the other model request tools.

### Caveats

- `ASK` records the failure that motivated the gate structure. An earlier build made agents too large to pass through breaches they opened. The incorrect code nevertheless satisfied each active check.

## `Marrow` visual `consult` (`tools/design/consult_marrow_visual.py`)

### Goal

Ask Sol to revise the marrow's visual design, covering the hub and the corruption gradient leading into it. `DIRECTOR_BRIEF` stores the user's decision: the hub structure is sound, but its appearance must transition toward the otherworld chamber type as the player descends. The prompt attaches rendered frames with one descriptive text part for each image.

### Invariants

- Each attached image file must be on disk. A file that is not on disk raises `FileNotFoundError`.

- The frames come from the game renderer, and the prompt states that fact.

- The art-direction file, `TESTATOR_DESIGN_LANGUAGE.md`, specfile, and `game/perihelion/hub.py` are included in full and without changes.

- Images are base64-encoded in the request, each preceded by one line of descriptive text.

- The run directory records `images.json` alongside `prompt.txt`. The JSON file has the paths and image texts.

### Verification

Run with `--dry-run`. The tool writes `prompt.txt` and `images.json`, prints the text length and the image count, and sends no API request.

### Implementation

`IMAGES` lists 8 frames: 4 hub captures from `out/organ_visual/`, one normal combat chamber, and 3 frames from `out/consult_visual_refs/`. `_excerpt_render` extracts 2 line-number ranges from `game/perihelion/render.py`: palette constants on lines 119–146 and otherworld prop code on lines 1411–1495.

`build_text` puts together the user brief, Bayescraft text, art direction, style-language file, specfile, hub source, renderer excerpts, and `ASK`. `build_input` makes the request list with the main text first, followed by the descriptive text and image part for each image. `main` follows the other model request tools and defaults `--out-root` below `out/consult/marrow_visual/`.

### Caveats

- The renderer excerpts are line-number cuts. A change to `render.py` moves the lines and changes the excerpt data with no warning.

- The docstring keeps the user's decision with its initial text errors, while `DIRECTOR_BRIEF` contains a corrected version.

## Visual capture tool (`tools/design/capture_visual_refs.py`)

### Goal

Capture 3 frames for the marrow visual model request. They show an otherworld chamber as a 6-vertex polygon, an otherworld rectangular chamber, and a normal dock chamber. All use the production renderer, zoom `0.45`, and a `640 x 360` frame.

### Invariants

- Each capture builds a one-chamber level, advances a `GameSession` 3 ticks, and draws with the production `Renderer`. No component is mocked.

- Output goes to `out/consult_visual_refs/` as `PNG` files through `necore.write_png`.

### Verification

Run the file. It prints one line for each written file and leaves all 3 PNG files on disk.

### Implementation

`shoot(name, build)` makes a `LevelBuilder` and invokes the supplied build function. That function adds a chamber, player, exit, and light. The tool builds the level, makes a session at zoom `0.45`, advances 3 frames, and consumes the effects queue. It draws, transposes the frame bytes, and writes them. Otherworld chambers receive cold blue-white light at intensity `0.9`. The dock chamber receives warm light at `1.0`.

### Caveats

- The 3 captures run at import time. The module has no `__main__` guard. An import of this module writes the files.

- `shoot` receives the polygon id from the build function and does not use it.

## `Adversary` roster `consult` (`tools/design/consult_adversary.py`)

### Goal

The last adversary-roster model request sends Sol the research packet and game specfiles and requests one definitive roster rather than a menu of options. Source terminology in the packet is translated into game language before this tool reads it. `ASK` contains the user's direction from 2026-07-28, including the requirement to turn 2 placeholder scouts into complete designs.

Adversary agents are precious personnel who must return through breaches, while Testator machines are their equipment. The tool must not send a packet with terminology inherited from the source field.

### Invariants

- The packet must exist on disk. If it does not exist, the error explicitly states that the tool substitutes no placeholder.

- The banned-term list comes only from the lexicon section `THE BANNED LIST`. The first version read a mapping table with ordinary English in its cells. This caused the gate to reject a clean packet. The docstring records this failure because a validation instrument that rejects correct output requires an override.

- If the lexicon exists but lacks the section, the tool stops rather than treating an unavailable check as successful.

- If parsing finds fewer than 120 terms, the tool stops because the list format changed enough to make the check ineffective.

- If the packet contains a banned term, the tool stops before the request and reports the match count and first 12 matches. Word-boundary checks prevent a match on a term inside a longer word.

- The enemy table and the signal table are cut from the live sources `game/perihelion/sim.py` and `game/perihelion/signals.py` by mark texts. The `consult` then reads the code as it is.

### Verification

Run with `--dry-run`. The tool writes `prompt.txt`, prints its length, the clean check's term count, and the section names, and sends no API request. The user specified the default `--effort` value `max`.

### Implementation

`banned_terms` locates the term-list section with a pattern and reads its labeled groups. Only labels that end in `:` introduce term lists. Each group is split at commas and periods into lowercase terms of 4 or more letters. `check_packet` tests each term once against the lowercased packet and returns the sorted terms that occur.

`build_prompt` puts together the header, product context, Bayescraft text, specfile, `TESTATOR_DESIGN_LANGUAGE.md`, enemy-table excerpt, signal-table excerpt, packet, and `ASK`. `_excerpt` uses `str.index` to extract source text between 2 markers and raises `ValueError` if it cannot find a marker. `main` follows the other model request tools and defaults `--out-root` below `out/consult/adversary/`.

### Caveats

- Defect: when the lexicon file does not exist, `banned_terms` returns an empty list and the check accepts the packet with zero terms. This contradicts the requirement that no packet be sent without this check. A missing section makes an error, but a missing file does not.

- The section pattern accepts the list only when another `## ` heading follows it. If the term list is the lexicon's last section, the tool does not find it and stops.

## Frames `consult` (`tools/design/consult_frames.py`)

### Goal

This model request asks for a coordinate type that turns reference-frame mistakes into build errors. `ASK` contains the user's brief. Sensory calls return a trace whose positions carry their reference frames and reject cross-frame operations. Rust types and `mypy` must make such errors unrepresentable.

The prompt includes the recorded failure: 63 of 64 shots crossed between different chambers, with judge probability `0.04`. It also includes the current API and the user's 3-layer proposal for critique.

### Invariants

- The prompt is fully in this file: 5 constants, no file reads.

- The failure text, the API list, and the proposal are the module text.

- The default `--effort` is `max`.

### Verification

Run with `--dry-run`. The tool writes `prompt.txt` below `out/consult/frames/`, prints the length, and sends no API request.

### Implementation

`build_prompt` puts together 5 sections: product context, the failure, the current API, the supplied proposal, and `ASK` with its 7 numbered checks. `main` follows the same flow as the other model request tools.

### Caveats

- None. This smallest model request tool transforms module constants directly into a prompt.

## Scout authoring tool (`tools/design/author_scouts.py`)

### Goal

Add adversary scouts (`vagrant` and `lacuna`) to a level file. Scouts enter the world at level start rather than through production by the CORE, and their placements derive from level measurements. Initial frame inspection found that unprotected scouts were placed where sentry turrets killed them.

### Invariants

- An eligible chamber is in the configured hop range from the player start, `3..12` by default. It has no sentry in it or any adjacent chamber. It also passes a seam test in which a 96-unit breach carve must produce a seam.

- The docstring explains why the seam test replaced a longest-edge test. The earlier test accepted chambers with walls full of doors. This caused geometry failures in 23 of 58 dry calls for the selected scout homes.

- A vagrant additionally requires floor area of 45,000 or more units for wide ground. Lacuna scouts use the remaining eligible chambers.

- Dormant scouts use eligible chambers with the greatest hop counts and lowest `combat_load`. Their `dormant` field is enabled, and their `dormant_threshold` is set to `0.5`.

- Each run replaces the scout census and first removes existing scouts of the specified types. This makes repeated runs idempotent.

- Hub chambers are excluded from the seam-test set.

- With no `--write` flag, the tool prints the plan and changes no file.

### Verification

Run against a level file. The tool prints the removal count and one plan line for each scout with type, polygon, hops, area, load, and dormant state. It then prints either a no-write notice or the number written. The docstring records the command that generated the census in `levels/gauntlet4.json`.

### Implementation

The tool loads the level JSON and removes existing scout entities. It makes a temporary `GameSession` and calls `topology.carve(i, (0, 0), 96)` for each non-hub chamber. A chamber enters the eligible seam set when the carve creates a seam.

It builds adjacency from `connects`, `connects_x`, and doors and calculates BFS hops from the spawn. It excludes sentry chambers and their neighbors. It calculates each chamber's `combat_load` from the count of entities other than medkits and ammunition. The code sorts candidates by hop count and then by index.

Vagrant scouts receive the first wide chambers, and lacuna scouts receive the next unassigned ones. Dormant selections prioritize depth and then combat load. With `--write`, the tool puts each scout at the polygon's vertex mean and writes the file.

### Caveats

- All test carves accumulate in one temporary session. A carve for one chamber remains when the next chamber is tested, so later tests run against modified topology.

- The docstring states dormant scouts go deeper than the midpoint of the hop range, but the code simply selects the deepest eligible chambers. It does not test that midpoint.

- The write path emits `JSON` with no indentation. The flicker tool writes with `indent=1`.

## Hub shell tool (`tools/design/author_hub_shells.py`)

### Goal

Calculate a convex shell with an organic, grown appearance rather than a constructed appearance for each of the 24 hub chambers. These shells replace rectangular rooms for the marrow's visual revision. The `CHAMBER_SHELLS` literal in `game/perihelion/hub.py` is generated by this tool, which validates each shell against the anchor contract and produces deterministic output.

### Invariants

The shape grammar is mandatory. If a shell violates any condition, the tool rejects it and tries another seed:

- The shell must be convex, contain 5 to 9 facets, and use the engine's required winding with the positive y direction downward.

- Each doorway receives one flat facet 94 or more units long for a 70-unit door or 128 units long for the 96-unit breach seam. Each of the 3 apse chambers also has one breach facet directed away from the hub.

- No facet may be shorter than 22 units, and no corner angle may be less than 32 degrees.

- Floor area stays within 8 percent of the replaced rectangle's area. Each bounding-box dimension may change only within the range from `-28` to `+38` percent of its initial size.

- Each required anchor point stays inside the shell with 16 units of wall clearance in the engine frame. These points include organ parts, resident-spawn corners, light positions, and reform points.

- Checks evaluate the exact vertices written to the literal. The tool rounds to `0.1` unit before validation. A `22.04`-unit facet once passed the minimum-length check but became `21.94` units in the literal.

- The seeds are deterministic: `crc32` of the `chamber` name, plus the try counter times 7919.

### Verification

Run the tool. It prints one line for each chamber with vertex count, seed offset, and area relative to the target. The facet-length range and doorway-facet lengths follow, then a summary. With `--emit`, it prints the `CHAMBER_SHELLS` literal for `hub.py`. If a chamber has no acceptable shell after 20,000 seeds, the run stops with an error.

### Implementation

`ROOMS` maps the 24 chamber names to the dimensions of their replaced rectangles. `LINKS` lists 24 doorway pairs. `ROLE` maps name classes to facet counts and shape ranges. `REQUIRED` maps chambers to anchor points, including resident-box corners used by many chambers.

`shell` constructs a candidate from an ellipse modified by 2 radial cosine terms. At angle `th`, the ellipse radius is `(a0*b0) / hypot(b0*cos(th), a0*sin(th))`, multiplied by `1 + a1*cos(th+p1) + a2*cos(2*th+p2)`. Here `a0=w/2`, `b0=h/2`, `a1` is a uniform sample from the role's intensity range times `0.5`, and `a2` is another sample times `0.35`. `p1` and `p2` are independent uniform phases from 0 through `2*pi`.

Each doorway receives an angular span. Its half-width is `asin(min(0.95, need*1.06/(2*radius(th))))`. Filler facets occupy the largest remaining angular spans. The function scales the result to target area, rounds it, sets winding, and runs each check.

Doorways then use the longest unassigned facets. `author_all` tries seeds until each chamber has a shell. `emit` formats the literal with distinct doorway points and an optional breach point.

### Caveats

- For some seeds, the radius function makes a nonconvex shape. The convexity check rejects it, and the seed loop tries again.

- The free-span calculation sorts spans without wraparound correction at `2*pi`. Validation rejects a bad selection and tries another seed, so this defect only increases the number of attempts.

## `Marrow` tour (`tools/design/marrow_tour.py`)

### Goal

Move a camera through the marrow from an apse that receives agents to a source cell. Record frames to show the corruption gradient as one continuous descent. This is a camera tour rather than a playtest. Normal play cannot reach the marrow before a breach opens, and no bot traverses it end to end.

### Invariants

- The game renderer produces each pixel from the game geometry. Nothing is mocked.

- The route visits one `chamber` for each depth band: `A1`, `G1`, `T1`, `T2`, `R`, `N1`, `N2`, `N3`, `N4`, `L`, `V`, `S1`.

- The tool moves the player to each chamber in sequence. Slow circular drift moves lights and props relative to the camera because a static frame can conceal how a chamber appears during play.

### Verification

Run with an output directory. By default, the tool writes 48 numbered PNG frames for each chamber. It prints each chamber's depth, type, and descent value and reports the total frame count. `tools/playtest/mkvideo.py` converts the directory into a video.

### Implementation

The tool loads `levels/gauntlet4.json` and makes a `GameSession` with the full loadout, zoom `0.45`, and a `640 x 360` screen. It reads `hub.chambers` and `hub_polygon_meta`. It calls `reseat_player` at each route chamber's origin and advances each held frame with circular drift of magnitude `0.22`. It consumes the effects queue, draws, and writes the frame.

### Caveats

- The defaults for `--seed`, `--hold`, and `--zoom` are 2, 48, and `0.45`. The zoom help text merely repeats the `0.45` default.

## Portal scale check (`tools/design/probe_portal_scale.py`)

### Goal

Measure portal scaling directly through the engine. A breach carved to equal widths on the two sides must produce a portal transform without scale, while unequal widths must produce scale. This check guards against the previous failure that made agents too large for their own gates and relies on execution rather than source inspection.

### Invariants

- The check builds 2 400-unit square chambers far apart in a raw `necore.Sim`. It carves a partial edge of the requested width in each, connects them, and reads the portal transform.

- The calculated scale is the length of the first column vector of the transform.

- A scale within `1e-9` of `1.0` prints `RIGID (no scale)`. Any other scale prints the factor and warns that bodies change size while crossing.

### Verification

Run the file. It prints 3 lines: equal widths (96/96), and the 2 width differences (96/52 and 52/96), with the edge lengths, the calculated scale, and the verdict.

### Implementation

`probe(width_a, width_b)` adds 2 square polygons with 400-unit sides and calls `split_edge` on edge 0 of each. Because the function uses normalized edge parameters, it subtracts and adds `width / 800` around `0.5` to carve a centered span of the requested width. It measures the two carved edges through `edge_endpoints`, connects them, and calculates scale from `portal_xform`.

### Caveats

- The file runs at import time: it has no `__main__` guard.
