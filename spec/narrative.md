---
This specfile covers the narrative and concept layer: the concept map model and its layout engine (`game/perihelion/mindmap.py`), the seed station UI (`game/perihelion/podscene.py`), the conversation scene (`game/perihelion/convscene.py`), and the conversation supply (`game/perihelion/conversations.py`).

---

# The narrative and concept layer

This specfile tells how the `concept map` operates, how `PodScene` shows it, and how `ConversationScene` plays between levels. The `concept map` is a graph of nodes. The Commando thinks about one frontier node at a time. Think progress increases in sim ticks during field play. `PodScene` shows the map with a local camera, live physics, and a completed node animation for each completed node.

`ConversationScene` plays lines between `RATIO` and the Commando. It shows each line one character at a time. Selection turns change the `dialogue score`. The script supply is empty by source instruction. No scene plays until the script source supplies scripts and a loader.

The reference files named in the code are the repository-root files `SEEDPOD_UI_DESIGN.md`, `MINDMAP_DESIGN.md`, `TESTATOR_DESIGN_LANGUAGE.md`, and `NARRATIVE_DESIGN_DOC.md`. The layout and physics in `mindmap.py` have no clock input and use only directly seeded random generators. The result is the same for the same input in one Python and NumPy environment. Floating-point results can be different across systems or library versions.

## Mind-map data and the progression queries (`mindmap.py`)

### Goal

This unit is the data model of the `concept map`. The data file `data/mindmap.json` holds 33 nodes. Each node has an `id`, a `region`, a `label`, and a `cost` with 2 columns. The other fields are `prereqs`, `kind`, signed `faith`, `unlock`, `blurb`, and `brief`. The value of `unlock` can be `null`.

Opening a node costs time, not components. The source cost columns are the weights for `think_ticks`. `PERIHELION` calculates `faith_score` from the integrated nodes and does not show it as a meter.

### Invariants

- `weight(node_id)` is the sum of the 2 integer cost columns, `components` and `data`.

- `think_ticks(node_id)` is `weight * 600` ticks. The one constant that changes cost to time is `THINK_SECONDS_PER_WEIGHT = 10`: 10 seconds for one weight unit at `60 ticks/s`.

- A node is available when it is not integrated and all its prereqs are integrated. `frontier(purchased)` is the sorted list of the available nodes.

- The standard shown set is the integrated set plus the frontier. `PodScene._visible()` also includes each id in `session.think_done`. During a completed node animation, it temporarily removes the new frontier nodes until the animation shows them.

- `faith_score(purchased)` is the sum of the `faith` values of the integrated nodes. `unlocks(purchased)` is the set of their `unlock` keys, without empty values.

- The 4 regions are `vocation`, `history`, `comprehension`, and `void`, in that sequence, with the display labels `VOCATION`, `HISTORY`, `COMPREHENSION`, and `THE VOID`.

- All queries have no random part. `frontier` returns a sorted list. `by_region` sorts each region by `(weight, id)`. `faith_score` returns an integer. The set from `unlocks` has no set sequence.

### Verification

The canonical map loads 33 nodes across the 4 regions. The weight sum across the map is 576, thus the full map costs 5,760 seconds of field time. One node costs between 30 and 480 seconds. `frontier(set())` returns only the nodes with no prereqs. The sim uses `think_ticks` to end node progress.

It uses `faith_score` for `GameSession.faith` and `unlocks` for combat numbers. The `PodScene` tests check how `_visible` adds `think_done` and applies the animation filters.

### Implementation

`nodes()` reads the JSON file once and keeps it in `_NODES`, a `dict` from node id to node. `weight`, `think_ticks`, `available`, `frontier`, `faith_score`, and `unlocks` only read that table. `faith_score` and `unlocks` ignore an id that is not in the table. `by_region()` groups the nodes by region and sorts each group by `(weight, id)`. `depths()` returns the cached prereq depth of each node. The depth is 0 with no prereqs, or 1 plus the maximum prereq depth.

### Caveats

- `by_region()` builds its output groups from `REGION_ORDER` only. A node with a region that is not one of the 4 raises `KeyError`.

- `depths()` and the internal `_depths_of(tbl)` are near copies. `depths()` reads the prereq list directly, thus a prereq id that is not in the table raises `KeyError`. `_depths_of` filters such ids out. The layout code uses only `_depths_of`.

- These two depth functions do not find a prereq cycle. A cycle calls the same function again until Python raises `RecursionError`.

- The `blurb` field of each node holds the placeholder text `TODO-HERMES` in the data file. No module in this layer reads `blurb`. The node data panel reads `brief`.

- The module caches (`_NODES`, `_LAYOUT`, and the caches below) stay full for the life of the process.

- `nodes()` does not check the JSON schema. A missing `id` raises `KeyError`. The caller receives malformed JSON and file errors. For duplicate ids, the last node in file sequence replaces the nodes before it with no message. Queries can then raise for missing or incompatible fields.

## The standard canvas (`mindmap.py`)

### Goal

All layout geometry is calculated against one standard canvas. Thus a check at the standard dimension holds at each internal frame dimension. The map area is between the tab header and the node data panel. No node position is calculated below the chrome.

### Invariants

- The standard canvas is `CANVAS_W x CANVAS_H` = 640 by 360 px. This is the default internal frame dimension of `render.py`.

- The map from unit space to px is set: scale fractions `SX_FRAC` = 0.44 and `SY_FRAC` = 0.32, center fractions `CX_FRAC` = 0.5 and `CY_FRAC` = 0.42.

- The top 34 px (`HEADER_MARGIN_PX`) and the bottom 78 px (`FOOTER_MARGIN_PX`) of the canvas are chrome. Label position selection and header position selection stay out of these areas.

- `_to_px` and `_to_unit` are inverse functions of each other.

### Verification

`podscene.PodScene._to_screen` reads the same 4 fractions, thus the geometry on screen agrees with the calculated geometry. `test_podscene.py` checks that rendered labels fit the standard boxes. `test_mindmap_layout.py` checks the containment invariants in this same frame.

### Implementation

`_to_px` maps a unit-space point to canvas px: `x_px = 640 * 0.5 + x * 640 * 0.44`, and the same on the `y` axis with 0.42 and 0.32. `_to_unit` is the inverse. `_to_world_px` multiplies the scale part of `_to_px` by a zoom factor. Local label position selection works in this frame.

### Caveats

- The center is at 0.42 of the height, not 0.5. Thus the map area between the 2 chrome areas is not centered on the canvas in the vertical direction.

## Depth bands (`mindmap.py`)

### Goal

Each prereq depth holds a radial band, by source instruction. A node cannot go across the boundary of its band. Thus the map keeps a circle structure for the full map, while the local structure stays free. The boundary circles on screen and the containment use the same numbers by construction.

### Invariants

- The seed circle radius of depth `d` out of `maxd` levels is `0.30 + 0.70 * (d / maxd)` in unit space (`_ring_radius`).

- Band 0 starts at radius 0: no hole is at the map center. Each other band boundary is the midpoint between the 2 adjacent seed circles. The last band extends by 0.5 times the space after its circle. Thus it has the same width on the two sides.

- `ring_boundary_radii(maxd)` is the `hi` limit of each band, but not of the last. The circles on screen and the band edges are the same values, not 2 versions.

- With `maxd <= 0` (all nodes at depth 0), the one band spans the full disc to `_BOUNDS_R` = 0.985.

### Verification

`test_relax_respects_depth_annulus`, `test_real_mindmap_relax_respects_annulus`, and `test_live_trajectory_never_leaves_annulus` in `test_mindmap_layout.py` hold layouts to these bands. `PodScene` draws its boundary circles from `ring_boundary_radii`.

### Implementation

`depth_bands(maxd)` calculates the distance between circles 0 and 1, divided by 2. It then returns `(lo, hi)` for each depth as `(r - interval, r + interval)`, with `lo = 0` at depth 0. `node_bands(graph)` maps each node to the band of its depth, through `_depths_of`. The ellipse limit is the outer limit that applies to the last band. The outer interval of a wide graph can extend across the canvas limit.

### Caveats

- None.

## The seed layout (`mindmap.py`)

### Goal

This unit sets the start condition of the relaxation. Nodes are in their region sector and in the band for their prereq depth. The seed is always the same in the same environment.

### Invariants

- Each region holds a sector: `vocation` up (-90 degrees), `history` right (0), `comprehension` left (180), and `void` down (90). Each sector is 92 degrees wide. Adjacent sectors thus overlap by 2 degrees. The implementation does not divide the circle into disjoint sectors. In screen coordinates, `+y` is down.

- Nodes of one `(region, depth)` group are at equal steps across the sector, in id sequence.

- The seed radius of a node is in its band. It is clear of the two boundaries by 0.20 of the band width (`BAND_MARGIN_FRAC`). The radial position comes from `crc32(id)`, not from `hash()`, because `hash()` changes between processes.

### Verification

`test_layout_deterministic` and `test_real_mindmap_deterministic` show the same positions on a second call. `test_real_mindmap_radial_variance_within_bands` shows that seed and stable radius values are different in their bands, not on one circle.

### Implementation

`seed_layout(graph)` groups the sorted node ids by `(region, depth)`. The angle of node `i` of `n` in a group is `base + span * ((i + 1) / (n + 1) - 0.5)`. The radius fraction is `(crc32(id encoded as UTF-8) % 4096) / 4095`, mapped into the band with the margin removed at each end. The position is the point at that angle and radius.

### Caveats

- The raw seed has no ellipse check. The last band can put a node at `ellipse_coordinate > 1`. The relaxation and `contain_layout` apply the containment downstream. A local value `maxd` in `seed_layout` is calculated and not used.

- The named tests run each call again in one Python and NumPy installation. They check equal results only in that installation. This unit does not state that floating-point results are equal across systems or library versions.

## Label metrics (`mindmap.py`)

### Goal

Accurate label geometry without pygame: the glyph moves forward of the included IBM Plex faces, measured once by `tools/gen_mindmap_font_metrics.py` into `data/mindmap_font_metrics.json`. The push field and the `PodScene` renderer use the same numbers, thus the shown geometry is the measured geometry.

### Invariants

- The standard label cell height is `LABEL_H_PX` = 16 px, which IBM Plex Regular renders at `LABEL_FONT_PT` = 12 pt.

- `text_width_px(text, face)` is the sum of the measured moves forward. A glyph that is not in the table uses 8 px. This is the widest possible move forward, thus the sum does not come out low.

- `label_size_px(label)` returns `max(8, advance_sum * 1.04)` in pixels, where `_LABEL_W_SLACK = 1.04`. This 0.04 width margin absorbs the floored point dimension of the renderer. The maximum measured overshoot is below 0.03 of the width.

- A node disc has radius 6 px, plus 2 px for a node with no prereqs (`node_radius_px`).

- Label boxes hang below the node. The space from the rim is 6 px (`LABEL_GAP_PX`). The margin around the glyph box is 2 px (`LABEL_PAD_PX`).

### Verification

`test_label_renders_fit_canonical_boxes` in `test_podscene.py` renders labels from the canonical map with PIL and compares them against these boxes. Kerning in IBM Plex only tightens, thus the width is accurate or safe.

### Implementation

`_font_metrics()` reads the JSON table once into a module value. `text_width_px` sums `adv.get(ch, 8.0)` across the characters. `label_size_px` applies the width factor and the minimum.

### Caveats

- None.

## The push field (`mindmap.py`)

### Goal

One push function moves the map. The batch relaxation and the live step function use the same field. Thus the 2 procedures use one push calculation.

### Invariants

- `_force_step(P, sysd)` is a pure function of the positions and the prepared system. It has no random part and no clock input.

- Each pair push points along the line between the 2 centers. The 2 items receive equal pushes in opposite directions. Thus damping can move the live system to a stable state.

- Two points at the same position receive a deterministic tiebreak direction from `GOLDEN_ANGLE * node_index`, before division by distance.

### Verification

`test_live_rest_open_reaches_exact_bitwise_rest` shows that this field moves the live system to a stable state, and its bits do not change. The code comments keep the measured record. With the previous axis-select label push, speed stayed at `1.5-3.7 px/s` after 20,000 ticks. With the center-line push, speed decreases to about `1e-12 px/s`.

### Implementation

`_build_system(tbl)` prepares the sorted ids, radius values, label dimensions, region angles, and edge index arrays. It prepares edge pairs that do not use the same node for crossing tests. It also prepares tiebreak directions, node band limits, and canvas factors. `_cached_system` caches it by `id(tbl)`, because the live step function runs at 60 Hz.

The push function returns one 2-axis acceleration value for each node. All position values in the calculation use canvas px. Each direction below is a unit vector unless the text states a different calculation.

- Disc repulsion: 2 discs closer than `r_i + r_j + 10` push apart. The dimension is `overlap * 900 / (d^2 + 1)`. Each node receives this dimension along the direction from the other center to that node center.

- Label-box repulsion: 2 overlapped label boxes push apart along the line between the box centers. The magnitude is the smaller axis overlap multiplied by 0.9. The 2 nodes receive equal values in opposite directions. The selected direction is the center line, not the axis of minimum overlap. With the previous axis-select push, all damping did not stop a movement cycle.

- Label and disc repulsion: the calculation finds the nearest label-box point to the center of a different node. When that point is in the disc, the dimension is the penetration distance multiplied by 0.9. The label node and disc node receive equal values in opposite directions. These values follow the line from the nearest point to the disc center.

- Prereq springs: each edge pulls to length 56 px. Its signed dimension is `(distance - 56) * 0.06` along the edge direction. The 2 end nodes receive equal values in opposite directions.

- Node and edge repulsion: the calculation finds the nearest point on each edge that does not touch the node. At a distance below 22 px, the node receives magnitude `(22 - distance) * 900 / (distance^2 + 1)` along the direction from that nearest point to the node. The edge endpoints receive the equal opposite value. Their weights are `1 - t` and `t`. Here, `t` is the clamped position of the nearest point from the first endpoint to the second endpoint.

- Crossing correction: the code does an accurate segment-intersection test for each edge pair. It does not test a pair that uses the same node. For a pair with an intersection, each endpoint of the first edge receives magnitude 24. Its direction is from the second edge midpoint to the first edge midpoint. Each endpoint of the second edge receives the opposite value.

- Region component: a weak tangential push, `-angle difference * 0.020 * radius`, turns each node to the sector of its region.

- Band-boundary push: a radial push has stiffness 12. It engages at a distance of 0.20 of the band width or less from each boundary. It is zero in the center part of the band and does not decrease tangential movement there.

- Ellipse limit: for a node out of the canvas ellipse, `e` is its ellipse-normalized radial distance. The in dimension is `(e - 1) * 6` along the canvas-px direction from the node to the center.

### Caveats

- `_cached_system` and `_cached_rest` use `id(tbl)` as the cache key, and the caches only increase. Defect: after Python releases a table, Python can give the same `id` to a new table. The new table then receives arrays from the released graph. `PERIHELION` uses one stable table, thus only synthetic graphs in long processes are at risk.

- The comments contain the full measured adjustment record: crossing counts, push floors, and dates. With push constants 5/400/16, the position animation fell back to the seed. The trajectory test finds that regression if it occurs again.

## Hard containment (`mindmap.py`)

### Goal

Containment holds without conditions, not only usually. These pushes give the position animation its shape, and a projection backs them each step. No node position out of its band or the canvas ellipse stays after a step.

### Invariants

- `_hard_contain` first moves each node to the nearest point in its band (`_hard_contain_bands`). It then pulls a point out of the canvas ellipse back onto the ellipse.

- The band clamp targets a point in the band by 0.35 of the boundary-push margin (`BAND_CLAMP_INSET_FRAC`). Thus no stable position is on a boundary circle.

- The 2 clamps do not change a contained layout: a second use of the clamps returns the same bits. Only the last depth band extends out of the outer ellipse. Thus the ellipse clamp can decrease the radius only for that band. The outer ellipse is the outer limit of this band. The clamp cannot move a node across an inner band limit.

- The 2 clamps use a tolerance of `1e-9`. Without it, a boundary node in a stable state starts the clamp again without end, across some `ULP`. The clamp then holds the push of the neighborhood above zero. Measured: a permanent push floor near 5.8 without the tolerance, decrease to about `1e-12` with it.

- `contain_layout(seed, graph)` applies the 2 clamps to a layout as a value: the accepted standard that the crossing compare measures against.

### Verification

`test_geometry_within_bounds`, `test_real_mindmap_within_bounds`, `test_rest_never_rides_band_boundary`, and `test_live_sleep_never_rides_band_boundary` in `test_mindmap_layout.py`.

### Implementation

The band clamp divides each position by the raw unit scale of each axis (`bx0`, `by0`). These factors do not include the 0.985 decrease because band radius values are in raw unit space. It moves a point below `lo` to `lo + inset` and a point above `hi` to `hi - inset`, along the radial direction. The `GOLDEN_ANGLE` tiebreak applies at radius 0.

The ellipse clamp then divides the offset from the center by the ellipse radius. Band is first, and ellipse is second. By selection, the last band extends out of the ellipse. Thus the two clamps agree.

### Caveats

- The measured record: 12 of the 33 canonical map nodes stopped on a band boundary before the boundary-push margin was added. This put the nodes in a row on the circle. The source instruction rejects this result.

## Batch relaxation and the stable layout (`mindmap.py`)

### Goal

`relax` turns the seed into the stable layout across a set iteration schedule. It can record the trajectory for the position animation. The layout is calculated on the full graph. Fog-of-war is a UI filter downstream, thus positions do not move when the fog-of-war opens. The crossing count of the result is not more than the count of the contained seed.

### Invariants

- The schedule is set: 220 iterations. The step of each node is below a movement limit that falls at a constant rate from 34 px to 0.15 px. The bits are the same for the same input in one Python and NumPy environment. The first section states the cross-environment limit.

- `_hard_contain` runs during each iteration and once again before the return, so containment holds on each return path.

- Crossing invariant: `count_crossings(result) <= count_crossings(contain_layout(seed))`, measured in the unit space of the caller. When the stable layout has more crossings, the function returns the contained seed.

- `layout()` caches the last frame for the canonical map. With a positive `record_every`, `relax` records the seed. It records a primary iteration when `(iteration + 1) % record_every == 0`. It also records the last primary iteration.

If a crossing-correction operation runs, `relax` records each correction iteration. It then records the selected corrected position and the last position only if each is different from the previous frame. A zero or negative value records no frames in `relax`. `layout_steps` must have a positive value because its callers read the last frame.

- `_edge_list(graph)` returns `(prereq_id, node_id)` pairs in node-id sequence and does not include prereq ids missing from the supplied graph. `count_crossings` uses this list to count accurate segment crossings. It tests edge pairs that do not use the same node, in px space, in Python without NumPy. It is a measurement tool, not the path that runs each iteration.

### Verification

`test_crossings_relaxed_never_worse_than_seed` is a property test on synthetic graphs. `test_real_mindmap_crossings` shows that relaxation changes the canonical map from 9 crossings to 5. The other tests are `test_crossings_batch_substantial_reduction` and `test_real_mindmap_trajectory_reaches_last_frame`.

### Implementation

Each iteration calculates `_force_step`, limits the movement of each node, applies it, and clamps. When the stable layout has more crossings than the contained seed, a correction operation runs. This operation uses 40 more small iterations and a movement limit that falls from 12 px. It uses only disc repulsion, the crossing push, the band-boundary push, and the ellipse limit. It keeps the position with the smallest crossing count. For equal counts, it keeps the last position.

A second repair procedure starts from the contained seed, because containment of the raw seed can add a crossing. Measured: 42 raw, 43 contained on one synthetic graph. The procedure selects the best of the stable layout repair, the contained seed, and the seed repair. The last compare measures again in unit space after the change back from px. A change to the nearest px can change a crossing near the limit. Found 2026-07-19: 134 in px space against 133 in unit space.

### Caveats

- The unit-space crossing compare runs only when the caller supplies a graph. Each runtime caller supplies the table, thus the compare always runs in `PERIHELION`. A call `relax(seed)` with no graph does not run it.

- The repair operation adds its frames to the end of the recorded trajectory. Thus a recorded position animation can show the repair movement after the schedule.

## Live physics (`mindmap.py`)

### Goal

The map moves while `ENCARTA` is open until its stop counter freezes it. The step function applies the same push calculation, with velocity, damping, and less friction along each node circle. On the canonical 33-node map, the stable system returns the same bits on each tick. Selection moves only the camera and does not change the push calculation. The Caveats keep the target-scale stop condition open.

### Invariants

- `LiveState` is a frozen dataclass. It contains positions and velocities in unit space, a small movement counter, and a stopped marker. `live_relax_step` returns a new state and does not change one.

- The step runs at `dt` = 1/60 second. The push sets the velocity change. The velocity updates first, and the position updates from the new velocity.

- Each node has a permanent spring to its `layout()` position. Its stiffness is `REST_SPRING_K` = 200. At the stable layout, the raw field does not equal zero.

- The damping is different by direction: 50 on the radial velocity part, 20 on the tangential part, by source instruction. Speed is limited to `600 px/s`.

- No node moves more than 40 screen px from its stable position. `LIVE_LEASH_SCREEN_PX`, divided by the zoom, supplies the canvas-px limit. At the limit, the outward velocity part is removed, as at wall contact.

- The stop latch sets velocities to zero when movement stays small for 10 ticks in sequence. The thresholds are a position change below `0.02 px` and a speed below `1.5 px/s`. A stopped state with continuous low movement returns without bitwise change.

- The stop signal is the applied position change after the clamps, not the raw push or the raw velocity. A stable node against the ellipse keeps a permanent push and internal velocity above zero. Its position does not move. At such nodes, the measured internal speed is `>= 38 px/s`.

- The path is a pure function of state and graph in one Python and numpy environment. The caller ticks it at the set sim rate.

### Verification

`test_live_rest_open_reaches_exact_bitwise_rest`, `test_live_rest_from_seed_reaches_exact_bitwise_rest`, `test_live_relax_deterministic`, `test_live_rest_respects_annulus_at_sleep`, and `test_target_scale_live_physics_leashed`. The position animation limit constant is `_LIVE_SETTLE_BOUND_TICKS = 600`. It is above the measured maximum on the canonical map, and is not an empty top value.

### Implementation

`live_rest_state(graph)` returns each node at its stable position, with zero velocity and `quiet = 0`. The first ticks measure the stable state again. `_cached_rest` is `layout()` for the canonical map. For a different graph, it is a new `relax` from the seed, cached by `id`.

`live_relax_step` changes the state to px and adds `(rest position - position) * 200` to the push result. Mass is 1. Thus acceleration equals the push result minus damping. The function divides velocity into radial and tangential parts about the view center. It subtracts 50 times the radial part and 20 times the tangential part from acceleration.

The `GOLDEN_ANGLE` tiebreak applies at the center. The function then uses semi-implicit Euler integration: `velocity = velocity + acceleration * (1/60)` and `position = position + velocity * (1/60)`. It applies the speed limit before the position step. It then applies the 40 px movement limit and `_hard_contain` and uses the stop latch. A node that is not in the given state falls back to its stable position and zero velocity.

### Caveats

- Defect: the bitwise stop invariant holds for the canonical 33-node map. It does not hold for the 400-node target-scale test graph. On that graph, the total pushes are stronger than the stable spring. A position can be 0.64 unit from `layout()`. A node can continue to move along the 40 px limit circle. The limit contains the movement.

Decision open (see `spec/open-questions.md`, item `NARRATIVE-LAYOUT-SLEEP`): must target-scale layouts stop with the same bits on each tick? Or can contained movement continue? An adjustment step has not started (code comment, measured 2026-07-11).

- `LIVE_DAMPING` is a second name equal to the radial value, kept for previous callers.

## Camera glide and local zoom (`mindmap.py`)

### Goal

Selection moves the camera, not a node. The glide finishes at the target in finite time, and all subsequent frames are bitwise static. The zoom scales with the graph. Thus the neighborhood on screen stays at about 5 to 8 nodes with 33 or 2,000 integrated nodes.

### Invariants

- `camera_glide(t, t0, dur, p_from, p_to)` is a pure function. It returns `p_from` before `t0`. It returns `p_to` with the same bits at and after `t0 + dur`, or when `dur <= 0`. Between these times, it uses smoothstep.

- `local_zoom(graph)` is `max(3.0, 3.0 * sqrt(n / 33))`, and does not go below the standard. A graph with 33 nodes or a smaller number thus uses the same zoom. The square-root scale keeps almost the same number of nodes in the view as the graph count increases. It does not set the count to 5 through 8 nodes for all graph layouts.

### Verification

`test_camera_glide_exact_arrival_and_static_after`, `test_camera_glide_zero_duration_snaps`, `test_camera_glide_deterministic`, `test_local_zoom_reference_and_scaling`, and `test_target_scale_local_framing`.

### Implementation

As stated. A spring path with damping comes near its target but does not have the same bits at the target. Thus smoothstep was selected: the code must have bitwise-static frames after the glide ends.

### Caveats

- None.

## Local label position selection (`mindmap.py`)

### Goal

The camera is local, and the full map is not in frame. Labels are necessary only near the camera: a far node is a point without a label. Each shown label is adjacent to its node, with no far anchor levels or long connection lines. A label that does not fit is not shown, but the selection always receives a box.

### Invariants

- `label_view_alpha(node, cam, zoom)` is 1 through ellipse view distance 0.42 and 0 at and after 0.80. It decreases at a constant rate between these limits. The ellipse 0.5 dimensions are 320 px wide and 117.2 px high: the shown area between the chrome margins.

- Label position selection runs in scaled canvas px (canvas px times zoom). A camera move does not change that frame. Thus the pair geometry of the labels does not change while the camera glides.

- The selected node is first. All other nodes then sort by distance from the camera in 24 px groups, then by id. Thus anchor selections do not change fast during a glide, and a far label cannot push out a near one.

- In the standard process, a box does not overlap a box selected before it or a node disc. The anchor list has rim offsets 0, 4, 10, and 18 px. Only the bottom and top anchors use offset 0, followed by 8 angles. The nearest edge of a box is at most 34 px (`LOCAL_LABEL_MAX_GAP_PX`) from its node center.

- Only the selection falls back to the bottom anchor with no offset when no collision-free anchor fits. It is first in the layout and cannot overlap a different label with the stated sequence. A second `RuntimeError` checks that condition. The fallback does not check node discs and can overlap one. The selected name also shows on the bottom data panel. The Caveats keep the necessary result for this node-disc overlap open.

- A node that is not in the result renders as a point without a label. The result is deterministic.

### Verification

`test_local_labels_never_overlap`, `test_local_labels_clear_of_node_discs`, `test_local_labels_adjacent_to_their_node`, `test_local_labels_lod_law`, `test_local_labels_deterministic`, `test_real_mindmap_local_labels_every_camera`, and `test_target_scale_local_labels`.

### Implementation

The candidate set is each node with alpha above 0, plus the selection. A first filter keeps only the discs at or below a calculated camera distance. Thus the cost scales with the local node count for each area, not graph dimension. The safe distance limit includes the fade radius along the larger view axis and the node radius. It also includes label distance, maximum anchor offset, full maximum label width, margin, and an additional maximum node radius.

The comment records the previous free constant. It removed a disc at 556 px without reporting an error, while a 454 px wide label extended to a larger distance. Each label tries the anchor list in sequence and uses the first box without a collision. The bottom anchor fallback for the selection raises `RuntimeError` if it overlaps a label. The code marks this as a path that cannot occur.

Defect: the fallback does not do the disc check. Thus, the disc-clear verification does not apply to this path. Decision open (see `spec/open-questions.md`, item `NARRATIVE-LABEL-FALLBACK`): which result is necessary when no collision-free selected label position is available? The UI can show the overlap, not show the label, or use a different display.

### Caveats

- The entry of the selection keeps its view alpha, which can be 0 when the selection is far from the camera. `PodScene` multiplies its draw alpha by that value. Thus the label of the selection can be out of view during a long glide, although a box is there. See the `ENCARTA` render unit.

## Region headers (`mindmap.py`)

### Goal

Each region names its sector. The anchor is a unit-space point, thus the camera moves headers with the nodes as one body. The kept box and the shown text use the same one measurement, thus their dimensions always agree.

### Invariants

- A header renders in the `medium` face at a 13 px cell, with 2 px space between adjacent glyphs. The kept width adds 6 px for glyph shape that extends after the move forward.

- The anchor radius is 1.10 in unit space, out of the node ellipse. In a stable state, the box is clamped into the safe area. It stays 4 px from the sides and 2 px in from the chrome margins.

- Regions sort by `REGION_ORDER` position, then name. Unknown region names sort after the 4 named regions. In a synthetic graph, each unknown region receives the angle for its index in that full sorted list. Thus unknown regions are at equal steps around the circle, but named regions keep their set angles.

### Verification

`test_region_headers_render_at_reserved_width` in `test_podscene.py`.

### Implementation

`region_header_size_px(label)` scales the measured `medium` character widths to the 13 px cell and adds the character distance and the 6 px margin. `region_header_layout(graph)` returns the canvas-px box, unit-space center, and display label for each region.

### Caveats

- The clamp applies in a stable state in canvas space. While the camera glides, it can move a header into the chrome areas. `PodScene` clips the map drawing to the area, thus the header is cut and does not draw onto the chrome.

## IBM Plex text for the concept tab (`podscene.py`)

### Goal

`ENCARTA` uses IBM Plex. It does not use the `Fixedsys` terminal face. This visual difference identifies the map as the display of nodes that the Commando completed. Text draws directly at the target pt dimension for each internal frame dimension and is not a scaled bitmap. The code uses PIL and NumPy, not pygame.

### Invariants

- `mind_font(pt, face)` reads the included `OFL` faces `regular`, `medium`, and `semibold` from `assets/fonts/`. A missing included face raises an error. The function does not read a system font as a fallback.

- `label_pt(font_px, k)` floors the pt dimension and does not go below 5. The floor keeps the maximum width overshoot on the canonical map below 0.03 of the width. The 0.04 width margin absorbs this overshoot. A pt dimension rounded up measured about 0.11 too wide.

- `_label_img` caches rendered text by `(text, pt, color, face)`. It clears the full cache after 4096 entries to limit memory use.

- `_blit_label` mixes a coverage bitmap onto the `(W, H, 3)` framebuffer, with an optional more alpha factor, clipped at the edges.

### Verification

`test_label_renders_fit_canonical_boxes` measures rendered labels against the standard boxes.

### Implementation

`_LabelImg` holds a `(h, w)` `uint8` coverage array and a color. Its `get_width` and `get_height` agree with the pygame surface that it replaces. `_label_img` renders with `ImageDraw.text` in mode `L`. `_blit_label` changes the coverage to the axis sequence of the framebuffer and blends with integer arithmetic. `mind_text_size` uses the right edge of the font bounding box as the width and `ascent + descent` as the height. `_size(surf)` reads a numpy shape, a `(w, h)` tuple, or `get_size()`.

### Caveats

- None.

## `PodScene` shell (`podscene.py`)

### Goal

`PodScene` fills the screen when the Commando returns to a `seed pod`. There, the Commando can repair the body, use components for items, and think (`SEEDPOD_UI_DESIGN.md`). It has 2 tab views: `FABRICATOR` and `ENCARTA`.

All drawing occurs at the internal frame dimension. Graphics from vectors and code draw onto the NumPy framebuffer. Thus no image asset is necessary. The scene holds no sim state: the active think node, progress, and queue live in `GameSession`.

### Invariants

- Entry repairs the body: `on_enter` calls `session.pod_heal()`.

- The `seed pod` opens on `FABRICATOR`, or on `ENCARTA` when a completed node waits. The centered heading is `CUCULUS UNIT`, and the second tab label is `ENCARTA`, each one constant.

- `ESC` or `E` seals the `seed pod` (`app.pop()`). `TAB` or `M` changes the active tab. `PodScene` ignores all mouse input. During a completed node animation, keyboard keys have no effect before the 1.3-second first beat. After that beat, each keyboard key finishes the animation. This includes `ESC`, `E`, `TAB`, and `M`.

- A change to `ENCARTA` starts the completed node animation when a completed node waits, or the position animation when not.

- The chrome draws the 2 tabs and centered heading on each frame. It also draws the item counts at the right and a footer instruction. The active tab has a `VERDIGRIS` line below it. The count text shows `{components}c`, `session.chassis`, and `session.station_kits`.

- The first layer of `PodScene` is a vertical gradient with low brightness. On `FABRICATOR` only, 7 arcs at `GOLDEN_ANGLE` intervals cross the shell, and the arc nearest the center changes brightness with `SEED_RED`. `ENCARTA` removes these arcs. By source instruction, arcs stay at one screen position behind the map-band arcs. They form a second circle system (2026-07-11).

### Verification

`test_pod_opens_on_fabricator_and_heals`, `test_escape_seals_the_pod`, and `test_fog_of_war_shows_unlocked_plus_frontier_only` in `test_podscene.py`.

### Implementation

`__init__` sets the active tab from `session.think_done` and uses `mindmap.layout()`. It prepares the camera at the selection with a glide of time 0. It also prepares the live physics at `live_rest_state()` and the caches. `on_enter` repairs the body, points the camera again, and starts the recorded position sequence when `ENCARTA` is open. It also starts the completed node animation when a completed node waits.

These two animations can start together. During their 0.7-second overlap, standard nodes use the recorded positions. The completed node graphics and camera use stable positions. `on_exit` sets the ambience level back when a negative `faith` animation left it low.

`update` moves the scene clock and decreases the operation flash to zero at `1 unit/s`. It also ends the position animation and the label fade at their times, and ticks the physics. On a selection change, it sets a new camera-glide target when no position animation or node animation runs. It then moves the node-animation timeline forward. `draw_fb` draws the first layer, the active tab view, and then the chrome. `handle_event` maps the keys as stated, through `uievent.from_pygame`.

### Caveats

- Defect: `on_enter` with a completed node starts the two animations at the same time. For 0.7 seconds, standard node discs and labels use recorded positions, while all completed node graphics use stable positions. The camera also targets the stable position. The recorded tail is near stable, thus the shown offset is small.

- The footer instruction is empty during the first animation beat. The player cannot finish the animation at that time, and no text tells the player.

- During a completed node animation, `ESC` does not seal the `seed pod`. Each key, with `ESC` included, finishes the completed node animation after the first beat.

## The fabricator tab (`podscene.py`)

### Goal

`FABRICATOR` lists all 7 items on which the player can use components. A large image panel shows an image of the selected item. The image comes from `assets/hero/{item}.png` when that file is there. If the file is not there, the panel shows an item glyph in the `MIRIAD` style. The panel does not show a placeholder box.

### Invariants

- The item sequence is set: `chassis`, `station_kit`, `hp_up`, `recall`, `ammo_9mm`, `ammo_shell`, `ammo_cell`.

- `W`/`S` or the arrows move the selection around the list. `ENTER` or `SPACE` uses components through `session.buy`. An accepted call flashes the row with `RGB (140, 255, 160)` and plays `fabricate_buy`. A rejected call flashes the row with `RGB (255, 120, 110)` and plays no sound.

- When the components are less than the cost, the row draws dim. Costs come from `session.shop_price`, and labels from `sim.SHOP`.

- The large image panel frames its item with corner marks and movement lines. A slow arc turns around the item. It draws 9 dimension marks along the bottom. Marks 0, 2, 4, 6, and 8 are 4 px high. The remaining marks are 6 px high. Each item has one `ITEM_DESC` text value, wrapped to at most 3 lines.

### Verification

`test_fabricator_buys_through_the_pod` and `test_hero_panel_prefers_art_else_vector_glyph`.

### Implementation

`_draw_fabricator` lists the items from `y = ui(58)` in steps of `ui(20)`. Each row draws the item label at the left of a field 22 characters wide. It then draws the cost at the right of a field 3 characters wide, followed by `c`. The selected row uses `RGB (240, 245, 240)`, with a `VERDIGRIS` pointer triangle and a color set by the flash sign. `_hero_art` reads the PNG once as an RGBA array in framebuffer axis sequence, and caches `None` on a read error. The panel scales the image to fit with `Image.BILINEAR`.

`_draw_item_glyph` draws the schematic for each item with line, circle, and polygon functions in a 100-unit frame. For `chassis`, it draws a body shape on a horizontal line, with an `AMBER` circle mark. For `station_kit`, it draws the folded seed shell around a `SEED_RED` line that turns around its center. For `hp_up`, it draws 2 panels with small circle marks and an `AMBER` plus. For `recall`, it draws a vertical line with 4 arcs. Their radius values increase by 1.618.

For the ammo items, `_draw_item_glyph` draws circular forms by type. `AMBER` marks the active part of each glyph.

### Caveats

- No item image files are in the repository. Thus the item glyph is the active path for all items (code comment).

- `ITEM_DESC` is item text. The `recall` line states `ninety-tick channel`: the sim holds the correct number, and this text does not read it.

## Concept-map state: fog-of-war, selection, and the walk (`podscene.py`)

### Goal

`ENCARTA` shows only known nodes. These are the integrated set, its frontier, and completed nodes that wait for animation. The player moves selection along prereq edges with the arrow keys or `W`, `A`, `S`, and `D`. `ENTER` or `SPACE` sets the active think node.

### Invariants

- `_visible()` is `session.mind` plus the frontier plus `think_done`. During a completed node animation, it subtracts `completed node animation["new"] - completed node animation["shown"]`. The animation record starts `shown` as an empty set. It fills the set with all new node ids at 3.4 seconds or when input finishes the animation.

- `_visible()` reads `shown` only while that animation record is active. This keeps new frontier nodes out until 3.4 seconds. After the completed node animation, the standard frontier calculation keeps these nodes shown.

- `_edges(vis)` is each prereq edge with the 2 ends shown.

- `_ensure_selection` keeps a shown selection. When the selection is not shown, it tries a sequence and uses the first shown node. It tries the active think node and then `session.think_done` in its list sequence. It then tries the sorted frontier, sorted integrated ids, and first sorted shown node. When no node is shown, the selection becomes `None`.

- The walk first examines all shown edge neighbors in the direction of the arrow key. It examines other shown nodes only when no edge neighbor has a direction component of 0.25 or more. A candidate has the correct direction when 0.25 or more of its unit direction is along the key direction. When no candidate has the correct direction, selection does not change. When selection is `None`, the first direction key only runs `_ensure_selection`.

- `ENTER` or `SPACE` calls `session.set_focus(sel)` and accepts an available frontier node. It rejects an integrated node and a node with prereqs that are not all integrated. It also rejects a completed node that waits for its completed node animation. A call for the active think node returns `True` without a state change. A different accepted node becomes active, but the first node keeps its think progress. The flash is `RGB (140, 255, 160)` when the call returns `True`, and `RGB (255, 120, 110)` when it returns `False`.

### Verification

`test_fog_of_war_shows_unlocked_plus_frontier_only` and `test_enter_sets_focus_and_nav_walks_edges`.

### Implementation

`_nav` scores each candidate as `distance * (2.2 - along)`. Here, `along` is the part of the candidate direction that agrees with the key direction. It uses the lowest score.

The first pool is the shown neighbors along edges. It includes selection prereqs and shown nodes that have the selection in their prereqs. The second pool is each other shown node. Positions come from the stable layout, not the small live movement. Thus the walk is stable while the map moves.

### Caveats

- None.

## Concept-map camera, positions, and the position animation (`podscene.py`)

### Goal

Selection changes only the camera: a 0.6 second glide to the selected node through `mindmap.camera_glide`. The map opens with the last part of the recorded relaxation positions. Live physics stays in a stable state while a position animation or completed node animation runs. An active recorded position sequence is the first source for its nodes. When no sequence is active, the completed node animation causes standard nodes to use stable positions.

### Invariants

- `_to_screen` maps unit space through the same 4 canvas fractions, scaled by the active zoom, with the view center at `_cam_pos()`. This holds during the completed node animation: the completed node animation camera is a usual glide, not a move.

- `_zoom()` is `mindmap.local_zoom()`. A factor raises it to 1.35 while the animation isolates its node, with no move at animation start. A negative `faith` animation adds a small shake to the zoom and a small circle movement to the view center.

- The position animation (`_start_settle`, `_settle_trajectory`) plays the last 14 frames of the cached `layout_steps(record_every=4)` trajectory in 0.7 seconds. An animation without a subset moves the full graph. After the last completed node animation, the subset is the completed node plus the new frontier nodes that it opened. That animation moves only this subset, while the remaining graph does not move.

- Node positions come from the first active source in a set sequence. An active position animation supplies values between adjacent frames. Live physics supplies the next source when no completed node animation runs. The stable layout is last.

- The physics ticks only while `ENCARTA` is open with no position animation and no completed node animation. It runs on an accumulator at the set sim rate, thus the path is the same at each frame rate. During these animations, the physics state goes back to a new stable state each frame.

- Labels of a position animation subset stay out of view until the movement stops, then fade in across 0.35 seconds. The cause: the label boxes are shown clear of collisions only in a stable state.

### Verification

`test_selecting_a_node_glides_the_camera_toward_it`, `test_camera_owned_by_reveal_while_it_plays`, `test_reveal_pulls_camera_continuously_from_selection`, and `test_node_never_leaves_its_band_while_selected`.

### Implementation

`_cam` is a small `dict`: from, to, start time, time. `update` sets its target again from the active camera position when the selection changes. It does this only when no position animation or completed node animation runs. Thus a fast new selection turns the camera smoothly. `_node_pos` calculates a position between adjacent trajectory frames for a node in the position animation.

`_update_physics` runs `live_relax_step` once for each full tick in the accumulator. `_map_clip` returns the area between the scaled chrome margins. `_mind_scale` is the surface width divided by 640.

### Caveats

- The camera points at the stable position of the selection, not its live position. The small live movement can move the node as far as the 40 px movement limit from the calculated view center.

## The concept-tab render (`podscene.py`)

### Goal

The player sees the containment. The depth bands draw as filled circles, with boundary circles from the same numbers that the clamps use. Edges use low alpha on the first layer. The edges of the selection use the strongest color, and labels show only near the camera. The node data panel at the bottom shows the selected node name, region, think state, and `brief`.

### Invariants

- The map draws onto a copy of the frame, and only the area between the chrome margins copies back. Thus no map drawing goes onto the chrome. This also holds while the camera glides or a completed node animation runs.

- The band layer (`_bands_underlay`, `_draw_bands`) is calculated again only when the camera, zoom, surface dimension, or selected depth changes. In a stable state it is a cached copy.

- A depth band with an index divisible by 2 uses a low fill (alpha 13). The band of the selected node adds 10 to that alpha, and each boundary circle keeps a thin stroke. The fill of a band is an outer ellipse with the inner part cleared.

- Edges between 2 integrated nodes draw brighter than frontier edges. The edges of the selection draw last and brightest, in `VERDIGRIS`. During a completed node animation, no bands draw, and the graph dims below the animation.

- The node state sets its graphics. An integrated node is a `BONE` disc with a `REGION_COLOR` circle. A completed node changes brightness with a `GOLD` circle. A frontier node is a disc with low brightness and a `REGION_COLOR` circle at 0.5 brightness. The active think node has a progress arc that moves around it as think ticks increase. The selection has 3 arc segments that turn at `1.4 rad/s`, with a color set by the flash.

- Labels come from `mindmap.local_label_layout` each frame, held to the screen position of the node. The offset scales by the surface factor only, because zoom is in the scaled canvas px frame. The selection label uses `BONE`, and the label for a completed node uses `GOLD`. The label for an integrated node uses `REGION_COLOR`, and a frontier label uses `MIRIAD_DIM`.

- Region headers draw with the same LOD fade as labels. They use the region color at 0.60 and IBM Plex `medium`, with space between characters.

- The node data panel is the 58 px band above the footer. It shows the label in `semibold`, with each character in its large form. It also shows the region tag and the think state line. It shows at most 3 wrapped lines of the `brief` text. The state line is one of: `INTEGRATED`, `THOUGHT COMPLETE - REVEAL PENDING`, `THINKING - {p}% of {s}s`, `PARKED AT {p}% of {s}s`, or `THINK TIME: {s}s IN THE FIELD`.

### Verification

`test_fog_of_war_shows_unlocked_plus_frontier_only`, `test_label_renders_fit_canonical_boxes`, and `test_region_headers_render_at_reserved_width`. The recording tool `game/tools/capture_mindmap_demo.py` operates this tab for recording videos.

### Implementation

`_draw_mind` builds the shown set and selects the first layer. It uses cached bands in a stable state, or a new empty overlay during a completed node animation. It draws bright selection edges and dim other edges on the first layer. Then it copies that layer to the frame. It draws the headers, calculates the frame labels, and draws the nodes in sorted sequence. Then it draws the completed node animation overlay with its dim layer and copies the map area back.

`_draw_node` draws the disc, circles, arcs, and label. The label alpha multiplies the dim for the completed node, the position animation fade, and the LOD alpha. `_draw_detail` wraps the `brief` text with PIL measurement, cached by node, scale, and width. The text starts at `x = max(ui(268), ui(20) + heading width)`.

### Caveats

- During a completed node animation, inactive labels dim to alpha 26 until 3.4 seconds. They then fade back across 0.6 seconds. The completed node has no standard label, and the node data panel is also missing while the animation runs. The animation overlay draws no text heading. Defect: the completed node name is not shown during the 5-second animation. It returns in the node data panel when the animation finishes.

- The label alpha of the selection multiplies by its LOD alpha. Thus the label for the selection can be out of view while the camera is far from it. See the local label position selection unit.

- The frame copy for the map is a full NumPy copy on each `ENCARTA` frame.

## The completed node animation (`podscene.py`)

### Goal

A completed node plays a 5-second animation when the player next opens `ENCARTA`. The player can finish it at or after the first beat at 1.3 seconds. The animation uses one of the 3 visual styles of `PERIHELION` (`TESTATOR_DESIGN_LANGUAGE.md`). Positive `faith` nodes use a flower animation at `GOLDEN_ANGLE` intervals. Neutral `faith` nodes assemble as a `MIRIAD` schematic.

A negative `faith` node starts with the flower animation and changes to the `corrupt` form during the primary animation. New neighbor lines start to extend at 3.1 seconds. The usual map layer records the new nodes at 3.4 seconds, before the completed node animation ends at 5.0 seconds.

### Invariants

- The sim updates the simulation first: `_start_reveal` calls `session.complete_focus(node)` before drawing a frame. Thus an exit in the middle of the animation does not remove integrated node progress.

- The completed node animation type is by `faith` sign: positive is `bloom`, negative is `corrupt`, zero is `snap`.

- The camera pulls from its position to the node in a usual 0.9-second glide. It does not move to a different frame.

- The timeline has a 0.9-second glide and the `REVEAL_IGNITE` beat at 1.3 seconds. The primary animation continues until 3.4 seconds, and the full time is 5.0 seconds. The `corrupt` change is at 2.2 seconds. Mouse input has no effect. Keys have no effect before the `REVEAL_IGNITE` beat, and each key calls `_finish_reveal` after it.

- The animation sound fires once at 0.9 seconds. This is 0.4 seconds before the 1.3-second `REVEAL_IGNITE` beat, at the end of the camera glide. An update at or after 0.9 seconds fires it. It uses `reveal_bloom` for `bloom` and `corrupt`, or `reveal_snap` for `snap`. A negative `faith` animation fires `reveal_sour` at the `sour` turn. It decreases ambience to 0.35 until the animation ends or the scene exits.

- New neighbors go into the usual map layer at 3.4 seconds. Their usual node discs are available from that time. Their usual labels fade from alpha 0 to full alpha across the next 0.6 seconds. The animation overlay starts its neighbor lines at 3.1 seconds. It starts its different neighbor-disc fade at 3.7 seconds. When more completed nodes wait, the next animation starts immediately.

- The list sequence of `session.think_done` is the animation sequence because `_start_reveal` always reads element 0. After the last animation, the completed node and its new nodes play a subset position animation.

- All random values in the completed node graphics are deterministic for each node (`_node_rng`): `Random(crc32(id + salt))`, not `hash()`. Thus the animation does not change between opens.

### Verification

`test_reveal_commits_unlock_at_start_and_admits_neighbors`, `test_reveal_skippable_only_after_first_beat`, `test_reveal_queue_chains`, `test_corrupted_reveal_dips_ambience_and_restores`, and `test_reveal_pulls_camera_continuously_from_selection`.

### Implementation

The `flare` has 3 circles with alpha-blended edges around the node and one bright circle. It uses `GOLD` for `bloom` and `corrupt`, and `MIRIAD` for `snap`. It is gone 0.5 seconds after the animation sound. The `bloom` shows 21 `petal` shapes at `GOLDEN_ANGLE` intervals. The radius of each `petal` increases with the square root of its index.

Color changes from `BONE` to `GOLD` with the index. Each `petal` starts before 3.4 seconds and extends for 0.7 seconds. A negative `faith` animation draws the same `petal` shapes in `SOUR` after 2.2 seconds, with deterministic sharp turns.

The `snap` flashes movement lines and moves in 8 circle segments with a small overshoot. It closes corner marks, then adds 8 `AMBER` index marks. `_reveal_neighbors` extends a line to each new node from 3.1 seconds. The line is curved for `bloom`, straight for `snap`, or has sharp turns and a dim shadow for `corrupt`. It then fades in the neighbor disc. `_finish_reveal` marks all new nodes shown and sets the ambience to its usual level.

The function then starts the next node animation or the subset position animation. `update` calls it at 5.0 seconds. A key after 1.3 seconds calls the same function immediately. Thus an input finish shows all neighbors and sets the ambience to its usual level. It continues the queue and runs the last subset position animation by the same path as a timed finish.

### Caveats

- The completed node animation draws at stable layout positions, while node discs draw at `_node_pos` positions. The 2 are different only during the position animation overlap recorded in the shell unit.

- When more than one completed node waits, the node animations play in sequence. Only the neighborhood of the last node animation receives the subset position animation. New nodes from animations that played first show without one.

- `_reveal_neighbors` does not draw the neighbor label. This is the selected operation. The standard label operation draws it after the 3.4-second boundary lets the node into the shown set. The previous version draws two copies at the same position (code comment).

## The conversation script (`convscene.py`)

### Goal

`ConversationScene` input is a list of 2-item tuple turns. A usual turn is `(speaker, text)` with speaker `RATIO` or `COMMANDO`. A selection turn is `("CHOICE", options)`. Its `options` value is a list or tuple with 2 or more alternative tuples. The turn pauses the scene and shows the alternatives.

The `posture` form uses the names `warm` and `cold` (`NARRATIVE_DESIGN_DOC.md` section 8.2). Its construction check accepts 2 or more alternatives and sets no maximum. The `stance` form uses 3 alternatives named `INQUISITIVE`, `MISSION`, and `HOSTILE` (section `8.2b`). Construction checks reject the shapes and values listed below. They do not check the text type of standard lines, Commando lines, or `ratio_replies`. The `posture` form can accept more alternatives than the UI can show.

### Invariants

- A `posture` form alternative is `(posture, commando_line, *ratio_replies)`, with `posture` set to `warm` or `cold` and a line that is not empty. Zero `ratio_replies` is correct. `warm` adds +1 to the `dialogue score`, and `cold` adds -1.

- A `stance` form alternative is `(stance, commando_line, trust_delta, flags, *ratio_replies)`. The alternative holds an integer `dialogue score` change and a list or tuple of `story flags`. Zero `ratio_replies` is correct.

- A `stance` form `CHOICE` has 3 alternatives with the 3 `stance` names, and no other shape. A `CHOICE` that has a `stance` name and a different shape raises.

- Empty `ConversationScene` input raises `ValueError`. A turn that is not a 2-item tuple and an unknown speaker also raise it. An unknown `posture` and an alternative without its Commando line also raise it.

- `STANCE_COLOR` uses `STANCE_COOL` for `INQUISITIVE`, `STANCE_NEUTRAL` for `MISSION`, and `STANCE_HOT` for `HOSTILE`.

### Verification

`test_scene_rejects_empty_or_unknown_speaker` in `test_convscene.py`.

### Implementation

`_validate(lines)` walks the turn list once. A turn with the head `CHOICE` starts the alternative checks. An alternative head in `VALID_STANCES` identifies the `stance` form. A `stance` form selection has 3 alternatives. A `posture` form selection has 2 or more alternatives. All other turn heads must be in `SPEAKER_COLORS`.

### Caveats

- The checks accept more than 2 alternatives for the `posture` form. But there are only 3 number keys, and only 3 alternatives draw. See the prepared list unit.

- The `RATIO` values in `ratio_replies` after the Commando line are accepted, but construction does not check their text type. A value that is not text raises when drawing wraps it or draws it.

- Construction also does not check that the body of a standard turn or a Commando selection line is text. Some incompatible values cause an error before the text wrap, in `len` or a slice operation. Other values cause an error when drawing wraps or uses them.

## `ConversationScene` prepared list (`convscene.py`)

### Goal

`ConversationScene` fills the screen with lines between campaign levels, above the scene of the next level on the stack. One line types at a time, and `SPACE`, `ENTER`, or a mouse click completes the line or moves forward. A complete line moves forward with no input after 2.5 seconds. `ESC` finishes the full scene. A selection pauses progress through the prepared list, and the number keys select. The `dialogue score` and `story flags` report only once, when the scene finishes: at the script end or when `ESC` finishes it.

### Invariants

- The integer character count starts at 0 for each turn and increases at `CHARS_PER_SEC = 55`. Each space and text mark counts as one character. The scene compares `shown // 3` before and after each update and plays one `radio_blip` when that value changes. Thus one update does not play that sound more than once. This also holds when a long update crosses more than one 3-character boundary. The text wrap during drawing does not set the count.

- The scene adds script turns to a prepared list until the next `CHOICE`. It then waits at the selection gate with each line complete.

- A selected alternative adds its Commando line and its `RATIO` lines to the prepared list. It applies the `dialogue score` change and `story flags`, then continues. Keys `1` to `3`, on the top row or console, select alternatives 0 to 2. No other input selects.

- `initial_trust` and `initial_flags` supply effect changes that fired before the scene. Selections add more changes. Flags collect in a set, thus more than one copy of a flag name becomes one. The last callback receives the flags in sorted sequence.

- `dialogue score` is the interface name for the signed score change from `ConversationScene`. `trust_delta` is the field for one `stance` form alternative. `initial_trust` is the score change supplied before the scene. `result_trust` is the scene total. `save_data["trust_total"]` is the kept absolute total after `App._add_trust` adds that scene total.

- `_finish` runs once: it calls `on_trust(result_trust)`, then `on_flags(sorted flags)`, then removes the scene from the stack. `result_trust` is the total delta for this scene, not the kept absolute `dialogue score` value. `App._add_trust` adds this delta to `save_data["trust_total"]`. `ESC` at each point reports the deltas collected at that time.

### Verification

`test_scene_plays_synthetic_lines_to_completion` plays a synthetic script through the character display, the move forward, and the finish. `App` connects `on_trust` to `App._add_trust` and `on_flags` to `App._add_flags`, which write into the keep data.

### Implementation

`_pull_until_choice` moves turns from the script into `_turns` until a `CHOICE` head, and keeps its alternatives. At the selection gate, alternatives wait and the index is at the end of the prepared list. `_advance` steps the index, stays at the gate, or finishes. `choose` reads fields by form. A `stance` form alternative contains the `dialogue score` change and flags. A `posture` form alternative maps its `posture` through `TRUST_DELTA`.

`choose` adds the alternative turns to the prepared list and reads again, thus adjacent selections work. `update` moves the character counter or idle clock. The 2.5-second idle clock starts only after the line is complete, from time or input. `handle_event` maps input as stated. A `finished` check prevents a second callback.

### Caveats

- Defect: the module docstring states that `App` does not call the `dialogue score` callback. But `app.py` connects the 2 callbacks and writes the results into the keep data. Thus the docstring is incorrect.

- Defect: a `posture` form `CHOICE` with more than 3 alternatives is accepted by the construction checks. The player cannot select alternatives after number 3, and those alternatives do not draw. The footer instruction lists one number for each alternative, but the scene ignores some named keys. Decision open (see `spec/open-questions.md`, item `NARRATIVE-CHOICE-COUNT`): must a `posture` form selection contain 2 alternatives? If not, must the UI and input accept all alternatives?

- A mouse click moves forward lines, but it cannot select a selection alternative.

## `ConversationScene` render (`convscene.py`)

### Goal

The scene uses a dim panel, a thin border, `SPEAKER_COLORS[RATIO]`, and `SPEAKER_COLORS[COMMANDO]` for the terminal voice. The 2 voices are clear immediately. The transcript moves up, and the newest rows always show. A selection draws as a numbered menu. The `stance` form uses `STANCE_COLOR`, while the `posture` form uses `CHOICE_AMBER`.

### Invariants

- The header line is `TIGHT-BEAM // FRAME IN TRANSIT`, with a requirement below it.

- The text with a speaker prefix and each selection label wrap at 52 characters. Rows after the first then add 2 spaces for speaker text or 3 spaces for selections. Their last length can be 54 or 55 characters. An empty spacer goes between transcript turns and follows the transcript at a selection gate. It does not follow the active last line during standard playback.

- Only the last rows that fit between the header and footer draw. Thus the newest rows stay on screen.

- The active line is cut at the shown character count before it draws. At a selection gate, all lines draw in full, followed by the numbered alternatives.

- The footer instruction is `{keys}: choose    ESC: skip` at a selection, or `SPACE: next    ESC: skip`, at the right.

### Verification

`test_scene_plays_synthetic_lines_to_completion` renders frames through this path.

### Implementation

`_rows` builds `(text, color)` rows for prepared turns. `_choice_rows` adds numbered alternatives. Each `stance` form alternative shows `n) [STANCE] line` in its `STANCE_COLOR`. Each `posture` form alternative shows `n) line` in `CHOICE_AMBER`. `draw_fb` fills with `DIM_GREEN` and draws the border 8 px inward. It then draws the header, last rows, and footer instruction.

### Caveats

- The wrap width is a set 52 characters. The code requests font dimension 12. `font_px` sets it to the nearest scaled 16 px bitmap dimension and uses a scaled 16 px row step. The default internal framebuffer is 640 px wide. The incorrect source comment calls it a 480 px panel. On other panel widths the text does not wrap differently.

## The conversation supply — empty (`conversations.py`)

### Goal

`PERIHELION` has no scripts between campaign levels, by source instruction (2026-07-11). The placeholder script and its compositor are removed. The script source writes all lines. The scenes will come in engine-checked markup with a loader for it (`DIALOGUE_SCAFFOLD.md`). Until then, campaign progress plays no `ConversationScene`. The stable interface for `App` stays.

### Invariants

- `conversation_for(gap, trust, flags)` returns `None` for each input. It ignores its inputs.

- `ConversationBundle` keeps the shape from the compositor period: `lines`, `base_trust` = 0, `base_flags` = `()`. For a subsequent `ConversationBundle` with lines, `App` supplies `base_trust` and `base_flags` to `ConversationScene` as `initial_trust` and `initial_flags`. Thus a subsequent loader can use the `App` code with no changes.

- The speaker constants are `RATIO` and `COMMANDO`.

### Verification

`test_every_gap_is_silent_until_the_directors_scripts` in `test_convscene.py`. In `app.py`, `_push_gap_conversation` calls `conversation_for` at each campaign space, and pushes a scene only for a `ConversationBundle` with lines. With `None`, no space plays a `ConversationScene`.

### Implementation

The 4 names for callers are the 2 speaker constants, the dataclass, and the stub function.

### Caveats

- The empty result from `conversation_for` is a source instruction, not an open decision or a defect. `_push_gap_conversation(idx - 1)` runs after campaign progress reads the next level. A level start from the level selection menu does not request a scene. The `conv_gapN` debug event can also request scene `N`. `App` keeps `dialogue score` values and `story flags` in keep data for the scripts and loader.
