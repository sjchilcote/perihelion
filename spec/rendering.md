---
This specfile is the warm-start decompile of the `PERIHELION` renderer.

Source files: `game/perihelion/render.py`, `game/perihelion/lighting.py`,
`game/perihelion/fb2d.py`, `game/perihelion/texture_geom.py`,
`game/perihelion/capture.py`.

All sections tell the facts of the code as it is. Caveats marked `Defect:`
tell where the code does not obey a goal or an invariant. Unmarked caveats
are plain facts.
---

# Rendering

This file tells how `PERIHELION` changes simulation state into pixels. One
`Renderer` builds each frame. The engine raster fills the world and entity
planes from a command list. It multiplies lights onto the world, and then
Python adds the last effects. This file also includes the light system and
the pixel-paint library for menu scenes. It includes the floor-texture
convention and the `grip` module.

## Unit 1 — Internal resolution and UI scale

### Goal

`PERIHELION` paints at a set internal resolution, `640x360` by default. One environment value can select a different resolution. The selected width sets the scale for image-layout values and the camera. Resolutions with the default 16:9 `aspect ratio` keep the same layout proportions and show the same world area.

### Invariants

- At the default resolution, `ui()` does not change an `int` input. The
  output at `640x360` does not change.

- An incorrect resolution value stops the program with an error. It does not use a fallback.

- At resolutions with the default 16:9 relation of width to height, the world area on image
  does not change. The zoom scale factor cancels the resolution change.

### Verification

- Start `PERIHELION` with no environment value. Check that the frame is
  `640x360`.

- Start `PERIHELION` with `PERIHELION_INTERNAL_RES=1280x720`. Check that
  the frame is `1280x720` and that the camera shows the same world area.

- Start `PERIHELION` with `PERIHELION_INTERNAL_RES=bad`. Check that the
  program stops with a `ValueError` that names the correct format.

### Implementation

- `_parse_internal_res()` reads `PERIHELION_INTERNAL_RES` once during module import. An empty value selects the default `(640, 360)`.

- The value must have the form `WxH`, with 2 positive numbers. The parser changes the text to `lowercase` and divides it at `x`. An incorrect value raises `ValueError` with a message that includes `must be WxH`.

- The parse accepts `X` or `x`. The Python `int` function accepts space
  characters around each number. It also accepts an optional `+` sign on
  one or the two numbers. It rejects a missing number, more than one `x`,
  or a number that `int` cannot read. It rejects a number at or below 0 and
  all other text. Python integers have no set maximum.

- `INTERNAL_W, INTERNAL_H` hold the result. `INTERNAL_RES_ZOOM_SCALE` is
  `INTERNAL_W / 640`.

- `ui(px)` returns `round(px * INTERNAL_RES_ZOOM_SCALE)` as an `int`. The
  HUD and the menus use it for layout constants.

- The camera zoom in the sim multiplies by the same scale factor. Thus the
  world area on image stays constant.

### Caveats

- The scale factor uses only the width. For example, `800x600` has a different
  relation of width to height. This changes the vertical world view and the
  vertical fraction that scaled UI values use. The
  horizontal world view and the horizontal fraction used by scaled UI
  values stay constant. The code accepts this resolution and does not correct
  the difference.

- Decision open (see `spec/open-questions.md`, item `RENDER-ASPECT-RATIO`): the implementation accepts ratios other than 16:9 and scales from width only. The open item selects one result: keep this operation, reject such resolutions, add bars, or cut the image. This file does not select a result.

- The module reads the environment value only during import. A subsequent change has no effect.

## Unit 2 — Palette and `descent` color curves

### Goal

The `station` is on a long material `descent`. Each polygon's `descent` field contains normalized progress into the `station` from 0 to 1, and that value changes the palette. At the `dock`, `FLOOR_BASE`, `WALL_COLOR`, and `WALL_MIN` supply the cold start colors. The middle `descent` values increase `RGB[0]` and decrease `RGB[2]`.

Near the `Perihelion Core`, the palette has high `RGB[0]` values and the first `growth` is shown. The `marrow` uses different color curves that lead to the cold `otherworld` palette. Adjacent values change by a small quantity. Thus a portal crossing is not shown as a palette seam.

### Invariants

- The renderer does not divide `descent` into steps. It samples the color curves continuously from the polygon's `descent` value and changes each result channel to an `int`. Adjacent values must have small channel differences, with no color seam at a portal crossing.

- The accent colors in `_DESCENT_KEEP` do not move with `descent`. They are
  `SCREEN_COLOR` `(110, 235, 165)`, `SCREEN_DIM` `(46, 96, 78)`, the `medbay`
  mark `(200, 90, 90)`, and the `growth` palette.

- `_corruption(d)` returns 0 when `descent` is at or below 0.55, and returns 1.0 when `descent` is 1.0.

- A floor with no light stays `RGB (0, 0, 0)`. The floor constants only change the
  result of a light, because the lightmap is the only light source.

### Verification

- Walk down from the `dock` to the `Perihelion Core`. Check that no portal crossing shows a palette step.

- Compare a lit `instrument-display` prop at `descent` 0 and `descent` 1. Check that the color is the same.

- Check that `_corruption(d)` adds `growth` to props only after `descent` 0.55.

### Implementation

- The first constants: `FLOOR_BASE` `(104, 104, 132)`, `WALL_COLOR`
  `(184, 196, 204)`, `WALL_MIN` `(74, 80, 88)`, and `SHADOW_FLOOR`
  `(11, 11, 15)`. Also `OW_FLOOR` `(52, 64, 58)`, `DOOR_COLOR`
  `(208, 128, 24)`, and the `KEY_COLORS` table for the `red`, `blue`,
  `gold`, and `void` keys.

- `FLOOR_BASE` is `(104, 104, 132)`, which is 4 times the removed value `(26, 26, 33)`. Texture-channel measurements are approximately 100 to 150. This tells the cause of the value change but does not add a requirement.

  `FLOOR_BASE` is the floor color before the lightmap multiply. It sets the
  maximum output color when the lightmap channels are full. A floor with no
  light stays `RGB (0, 0, 0)`.

- The prop palette is between the floor and enemy colors. It has
  `PROP_COLOR` `(58, 62, 72)`, `PROP_RIM` `(90, 96, 108)`, and `PROP_DARK`
  `(38, 40, 48)`. It also has `HAZARD_COLOR`, `PIPE_COLOR`, `PUDDLE_COLOR`, display colors, and `HYDRO_TRAY`.
  Objects must not pull the look from a live threat.

- The standard palette has 3 color curves with 3 points each: `_FLOOR_RAMP`, `_WALL_RAMP`, and `_WALL_MIN_RAMP`. The `marrow` palette has 3 more curves. Polygon types `marrow` and `otherworld` select those curves.

- `_mix(a, b, t)` mixes 2 colors linearly and changes each channel to the nearest `int`. `_ramp(way, d)` samples a sequence of 3 colors. The first segment uses `0 <= descent <= 0.5`, and the second uses `0.5 <= descent <= 1`.

- `_warm(color, d)` adds `_PROP_WARM` `(18, -6, -16)` multiplied by `d`, then clamps each channel to 0 through 255. Colors in `_DESCENT_KEEP` do not change.

- `_corruption(d)` returns `max(0, (d - 0.55) / 0.45)`.

- `_ow_mix(d)` calculates the level of `otherworld` light mode for the
  polygon. It applies the `smoothstep` curve to `(d - 0.45) / 0.55` and
  clamps the result to 0 through 1. The curve centers on the polygon-type
  change. The first `otherworld` polygon thus has an inverse-field level of
  approximately 0.5. The source cells are almost fully in that field.

- The `growth` palette: `GROWTH_FILL` `(44, 14, 16)`, `GROWTH_RIM`
  `(92, 34, 28)`, `TENDRIL_COLOR` `(84, 30, 24)`. `grime` colors and wall-symbol
  colors mix from a cold pair to a deep pair.

### Caveats

- The polygon type changes at one depth, but `_ow_mix` changes the light mode smoothly. A hard change at the type boundary can show a sudden style change, not `growth`.

- The source has no maximum difference between adjacent level `descent` values. Only a visual check checks the seam requirement.

- `SHADOW_FLOOR` has no caller. It is a kept constant, not a color that
  the active renderer paints.

- Decision open (see `spec/open-questions.md`, item `RENDER-DESCENT-SEAM`): select a numeric limit and conditions for the boundary check. Or accept the visual check as the complete requirement.

## Unit 3 — Entity shapes and colors

### Goal

Each entity type has one silhouette and one palette. The set values keep larger enemy types larger in the image at each camera zoom. High `RGB[0]` values, low RGB values, and edge effects keep body colors different from objects colors. Adversary types use sensor-return colors from `ADVERSARY_TRACE`. No other item in `PERIHELION` uses those colors.

### Invariants

- Each enemy type keeps a minimum image radius in set groups. A `warden`
  does not compress to the same small mark as a `mite`.

- The rim of each enemy is the fill color plus 70, unless a table entry
  replaces it.

- `GRIP_RIM` is a named constant. Thus the test reads the renderer value, not a different copy.

- A `corpse` decal keeps no hue (`CORPSE_DRAIN = 1.00`). Its shape identifies the enemy type, while its color shows death.

- Vertex movement is a pure function of tick, entity id, and vertex index. The same frame always receives the same offsets.

### Verification

- Record video of all enemy types at the standard 0.45 zoom. Check that no 2
  types compress to the same small mark. Check that a `warden` stays
  larger than the small types.

- See `game/tests/test_grip_is_visible.py` for the `GRIP_RIM` check.

### Implementation

- `PLAYER_SHAPE` is a 4-point `kite` shape. `PLAYER_COLOR` is
  `(205, 248, 255)`.

- `_regular_lumpy(n, radii, phase)` returns an `n`-corner shape and uses the radius list again around its corners.

- `ENEMY_SHAPE` holds one shape for each type. `husk` has 7 corners,
  `spitter` 6, `brute` 5, `warden` 9. `shrieker` is a thin 4-point
  shape. `flicker` has 6 corners with sharp radius changes. `vagrant`
  has 8 and `lacuna` has 10, with radius values near 1.0.
  `_CIRCLE_SHAPE` is the 8-corner default shape.

- The first `vagrant` radius set ranged from 0.45 to 1.2 and was shown as 2 different types from different angles. In this version, the radius values stay near 1.0.
  The constant movement comes from `_boil`, not from the initial shape.

- `_boil(pts, tick, eid, amp)` moves each vertex around a small loop. The operation `hash(entity_id, vertex_index) % 997` sets the vertex phase. The `x` and `y` offsets use different rates. Thus the movement is not shown circular.

- `ENEMY_MIN_PX`: `mite` 3, `husk` and `spitter` and `shrieker` and
  `flicker` 6, `vagrant` and `lacuna` 7, `brute` 8, `warden` 10.

- `ENEMY_COLOR` holds one fill for each type. `ENEMY_RIM` replaces only
  the `warden` rim: `(235, 235, 245)`. `ENEMY_RIM_W` sets the `brute` to a
  2 pixel rim. `GRIP_RIM` is `(255, 190, 60)`.

- `ADVERSARY_TRACE`: `vagrant` `(120, 245, 230)`, `lacuna`
  `(185, 140, 255)`. `ADVERSARY_TRACE_SCALE = 1.5` renders the sensor return wider
  than the body radius. The sim does not read it.

- `_luma_of(c)` returns the luma. `BLOOD_BLOB` and `SPLAT_BLOB` are the
  decal shapes for `BLOOD_COLOR` marks.

### Caveats

- `CORPSE_DRAIN` was 0.75, and a video check logged `corpse` types as not
  easy to read at zoom. The full drain is not an error. A `corpse` decal has
  no simulation effect, thus only the death-state read is important. The one `corpse` with an
  effect is the `corpse_frame` pickup (unit 26).

## Unit 4 — Image geometry helpers

### Goal

Small pure functions transform points, shapes, and colors between coordinate spaces. Each call `site` thus sends the same rounded image geometry to the raster.

### Invariants

- `_point_in_poly` returns the same result for the two directions of a polygon's vertex sequence. A portal transform can put that sequence in the opposite direction.

- `_snap_prims_f32` changes cached prop geometry to `float32` before the frame reads it. The movement after this change is below `1e-4` pixels.

- `_dim`, `_floor_dim`, and `_polygon_tint` return set values (1.0 and
  `RGB (0, 0, 0)`). Distance lighting replaced depth dim steps, and props replaced
  hash tints for each polygon. The call points stay.

### Verification

- Give `_point_in_poly` one polygon in the 2 vertex-sequence directions. Make
  sure that the results agree.

- Check that `_shade` clamps each channel to 0..255.

### Implementation

- `_dilate_poly(pts, px)` pushes each vertex `px` pixels outward from the arithmetic mean of the shape vertices. That point is not the `area centroid`. Only the entity-coverage mask uses this function.

- `_point_in_poly(x, y, poly)` uses a ray-crossing count with `x < intersection_x` and the vertical test `(yi > y) != (yj > y)`. It does not always put a boundary point in the polygon.

- `_xform_pts(points, cx, cy, scale, ang, squash)` turns, scales, and
  moves a local shape. `squash` multiplies the local `y` before the
  turn.

- `_xform_scale(xform)` is the length of the transformed direction
  `(1, 0)`.

- `_pt` and `_pts` set coordinates to the nearest `int` pixels.

- `_f32` and `_snap_prims_f32` change primitive coordinates to `float32`,
  the precision of the command list.

- `_size_of(surf)` reads a dimension from a `pygame` surface, from a numpy
  array, or from a `(w, h)` pair. The renderer uses the target
  only for its dimension and does not write into it.

- `_shade(color, dim, tint)` returns `(color + tint) * dim` for each
  channel, with a clamp. `_brighten` adds a constant with a clamp at
  255. `_scale_color` multiplies and cuts the fraction part.

- `_mult_into` and `_add_into` are the `pygame` multiply and add mix
  steps on numpy views. They calculate the same values.

### Caveats

- `_mult_into` and `_add_into` have no caller in the repository. The engine does these 2 composition steps. These functions have no effect during play.

## Unit 5 — `Rect` and the raster canvas

### Goal

A small drawing interface records commands in the engine stream. Each call `site` sends the same rounded values previously sent to `pygame.draw`. The same input has the same pixels.

### Invariants

- The raster primitives do the operations from `pygame-ce 2.5.7`, with no pixel difference.
  The same input on the canvas has the same pixels as the removed
  `pygame` path.

- The world canvas and the entity canvas add to the same 2 lists. Thus
  the stream keeps the call sequence. The plane bits route each command
  to its plane.

- `Rect` keeps `int` values only, as `pygame.Rect` did.

### Verification

- Paint one frame and compare it with a recorded frame. See
  `game/tests/test_render_headless.py` and
  `game/tests/test_render_pygame_free.py`.

### Implementation

- Each command is 6 `uint32` values. They are an operation code, flags, a
  clip index, a transform index, an RGBA color, and a point count.
  Coordinates go to a parallel `float32` list.

- The operation codes are polygon fill 0, polygon outline 1, line path 2,
  circle fill 3, circle outline 4, rectangle fill 5, and rectangle outline 6.
  Clip fill is 8, texture fill is 9, and decals are 10.

- `_flags(plane, clipmode, closed, width)` encodes the plane in 2 bits and
  the clip mode in 2 bits. It also encodes a closed bit and the stroke width
  in one byte.

- `_rgba(color)` encodes a color as `0xRRGGBBFF`. The alpha is always
  255.

- `Rect` is the renderer rectangle type: `x, y, w, h` as `int` values,
  with edge and center read properties. The center can also be set. Construction also accepts one 4-item value.

- `_RustCanvas` methods: `polygon`, `line`, `lines`, `circle`, `rect`,
  `set_at`, and `ellipse`. `set_at` is a 1 by 1 rectangle fill, which
  writes the same pixel as the `pygame` clip-checked operation.

- `ellipse` is a `port` of the `pygame-ce 2.5.7` filled ellipse, line
  by line. It walks the 2 curve parts and sends each pixel row piece as
  a 1 pixel high rectangle fill. Only the filled shape is in the `PERIHELION` code.

### Caveats

- The command format lives in `engine/necore/src/raster.rs`. This file and
  that file must agree on the operation codes and the flag bits.

- The goal of zero pixel difference applies to the applicable calls in this
  module. Coordinate values must be finite. Colors must have 3 channels.
  Polygons must have 3 or more points. Dimensions and widths must be 0 or more.

- `PERIHELION` uses only filled ellipses. The goal also applies to the values in
  the named tests. Bad values and other degenerate values have no contract.

## Unit 6 — Key item glyphs

### Goal

A key item renders as a small object silhouette that agrees with its name. Thus the player can identify it from the world without text.

### Invariants

- An unknown name returns `False`, after which the caller renders the default key glyph. The function does not select an incorrect named glyph.

- The glyph radius has a floor of 4 pixels.

### Verification

- Put items from each name group in a level and check that each renders its named silhouette.

### Implementation

- `draw_key_glyph(canvas, item_name, cx, cy, r, color)` changes the
  name to `uppercase` and finds the first name group in it.

- `WHEEL`: a circle, 4 lines out from the center, and a center disc.
  `CARTRIDGE` or `CANISTER`: a high rectangle with 3 lines and a top
  mark. `CARD`: a wide rectangle with a cut corner and a small plus sign.
  `HANDLE` or `LEVER`: 2 thick lines and a small box outline.

- `STAMP`: a head disc, a stem line, and a bottom line. `TOKEN`: a
  6-corner outline with 4 pixels. `SIGNET`: a circle and a small ellipse.
  `KEY`: a circle, a stem line, and 2 short down strokes.

- Each name group returns `True`. If no group agrees, the function returns `False`.

### Caveats

- None.

## Unit 7 — Prop position helpers

### Goal

Prop functions use helpers to put objects in polygon-local coordinates.
The helpers process rectangles, circles, arcs, wall lists, and equal distance
along a wall. They do not include portal and door edges. Thus objects
cannot block a doorway that is open or can open.

### Invariants

- The polygon-local origin is the arithmetic mean of its vertices, not the `area centroid`. The level contract sets this result. Thus the direction to the internal area always points to `(0, 0)`.

- `_wall_edges` does not include portal edges, door edges, or edges shorter than 16 world units. It sorts the other edges from longest to shortest.

- `_place_along_wall` returns an empty list when the wall cannot hold
  one item with its margins.

### Verification

- Render one polygon with a portal edge. Check that these helpers put no wall prop on the portal edge.

### Implementation

- `_rect_local(cx, cy, w, h, ang)` returns 4 turned corners. `_ring_local` and `_arc_local` sample circles. `_basis_arc_local` returns a circular curve in the wall's (along, inward) frame. The curve thus points into the polygon with no wall-direction branch.

- `_edge_inward_normal` selects the edge normal that points to the
  origin point.

- `_wall_edges(verts, portal_edges, min_len=16)` returns one dict for
  each kept edge. It contains the 2 ends, the length, the along direction,
  the in normal, and the middle point.

- `_place_along_wall(wall, item_w, gap, inset, margin=6)` centers `n`
  items along the wall with equal spaces. Each item moves in by
  `inset`. The result is a list of `(cx, cy, ang)` values with the wall
  angle.

- `_crate(...)` returns a filled rectangle with a rim. With `p = 0.85`, it adds one diagonal line between opposite corners. A large crate adds a second diagonal with `p = 0.6`. After `descent` 0.55, a short line path extends from one corner with `p = 0.10 + 0.35 * _corruption(descent)`.

- `_vent_grate(...)` returns a dim rectangle with 3 lines across it.

### Caveats

- Defect: streamed polygons receive an empty portal-edge set. Thus these helpers can put props on their portal edges. See unit 17.

- Decision open (see `spec/open-questions.md`, item `RENDER-POLYGON-ORIGIN`):
  the implementation uses the arithmetic mean of the vertices as
  the local origin and in point. Select if this level
  contract stays, or if irregular shapes use the `area centroid`.

## Unit 8 — Polygon prop functions

### Goal

The objects show each polygon's function with no other signal. The types are `dock`, `corridor`, `transit`, `storage`, `pump`, `lab`, `hydro`, `quarters`, `chapel`, `records`, `medbay`, `core`, `generic`, `marrow`, and `otherworld`. Deep types show `growth`. The `otherworld` uses the objects again but puts them in irregular positions by source instruction.

### Invariants

- The table `_POLYGON_PROP_GENERATORS` has one entry for each type name and one
  function. `transit` uses the path function. An unknown type
  uses the `generic` function.

- All output is polygon-local geometry as primitive records. No
  function touches the raster or the frame.

- Only the first random stream selects the initial objects. A depth change thus does not change that selection sequence. The second stream can add `growth` or change the position and angle of selected objects.

- A lit instrument display adds a `screenglow` primitive and becomes a frame light source.

### Verification

- Render and record one polygon of each type. Check that its objects show its function. `transit` and `corridor` must be equivalent, while each other pair must be different.

- Check that the same polygon and seed have the same objects on each run.

### Implementation

- `dock`: crate stacks are near 2 random corners. A hazard stripe band is
  along one wall, with 2 colors in sequence. Wall circles with short lines
  are along a different wall.

- `corridor` (also `transit`): a pipe run along at most 2 walls,
  with short connection marks. A `vent grate` shows with `p = 0.7`. 2
  direction arrow marks go on the long axis of the floor.

- `storage`: 2 or 3 crate rows keep a clear path along the middle of the long axis. The function stops crate addition when the primitive count is 70 or more. The last crate can raise the result above 70. `Shelf-line` pairs extend along at most 3 walls.

- `pump`: 2 circles form a large `tank`. An input pipe runs from the nearest
  wall to the nearest rim point without crossing the `tank`. With `p = 0.5`,
  the function tries to add a second, smaller `tank`. It keeps this `tank`
  only if it fits in the bounding box. It always adds 2 to 4 `puddle`
  `stains`. After `descent` 0.55, rimmed `growth` patches and line paths
  show on the `tank` rim.

- `lab`: console blocks line at most 3 walls. Each block is a dim block with an instrument display. A display is lit with `p = 0.8 - 0.45 * descent`. Thus deeper `decks` have a smaller number of lit screens. Lit screens glow, and one work table is near the center.

- `hydro`: `plant` `troughs` along at most 3 walls with `stalk` `dots`, and
  one center `trough` with 3 to 5 `stalks`.

- `quarters`: `cot` groups along at most 3 walls, each a `cot`, a
  bright rectangle, and a small dim box. Near the `Perihelion Core`, the second stream
  turns and moves each `cot` by `_corruption(descent)`.

- `chapel`: 4 to 6 `pew` lines that face the longest wall, and a front
  circular curve. Near the `Perihelion Core`, the second stream turns and moves each `pew`.

- `records`: 3 to 5 long `shelf` line pairs in rows across the floor.

- `medbay`: `cots` line at most 2 walls, with a circular curve near each `cot`. One `cabinet` with an RGB (200, 90, 90) medical mark is shown on the first wall longer than 30 units.

- `core`: 2 or 3 center circles, 6 to 10 radial lines, and an RGB warning circle at radius `1.05 * r_max`, with tick marks.

- `marrow`: the distances between `machined` wall `ribs` are different. It
  also includes open `fold-symbol` paths, dim `bone` blocks with rims, and illuminated
  `conduits` that point inward. The fold paths stay open because only a
  closed circle shows aggro. After `descent` 0.55, RGB `growth` paths extend
  across the `machinery`.

- `otherworld`: draw the polygon edge again at 0.82 scale. Also draw it
  at 0.62 scale when `descent` is above 0.5. A lit console block has no set
  orientation, and a crate shape is at a wall point. Small `pew` shapes at
  0.5 scale follow a `GOLDEN_ANGLE` sequence that is not full. Floor `dots`
  use `DETAIL_COLOR` and do not add to the lightmap. The objects count
  decreases as `descent` increases, with keep factor
  `1 - 0.65 * descent`.

- `generic`: 2 to 5 axis-aligned panel lines, 4 to 9 `dots`, 1 or 2 `stains`,
  and offset lines along at most 4 walls. Some wall lines have endpoint
  `dots`. The table contains a
  correct `generic` entry. An unknown type selects the same `_props_generic`
  function and has the same output for the same other inputs.

### Caveats

- The first `otherworld` function ignored its `descent` input and thus did not change with depth. The keep factor and second outline corrected that defect.

## Unit 9 — Floor marks that change with depth and the warm `bake`

### Goal

Each polygon collects `grime` with depth, `Congregation` symbols from the middle `decks` down, and `growth` after `descent` 0.55. Prop colors also become warmer with depth. All these colors stay between the floor and prop ranges. Thus the mark brightness stays below the brightness of a live threat.

### Invariants

- These floor and wall marks show only above `descent` 0.05.

- The second random stream controls all `depth-dependent` marks. Thus it does not change the selection sequence from the first stream.

- The renderer `bakes` the warm color change into cached primitives once, with no cost on each frame.

### Verification

- Compare polygons at `descent` 0, 0.31, and 0.56. Check that the 0.31 polygon with one applicable wall shows a symbol, and the 0.56 polygon shows a `growth` patch. The polygon at 0 must not show the two `depth-dependent` marks.

### Implementation

- `_descent_dressing(crng, descent, walls, ...)` sets `g` to `descent`. It adds `round(g * 3)` `grime` `stains`, `round(g * 5)` `grime` `dots`, and wall-streak lines with `p = 0.25 + 0.5 * g` for each wall.

- When `g > 0.3`, 1 or 2 small symbols show near walls. Each has 2 lines in the wall's (inward, along) frame. The count increases with the progress of `Congregation` down the `station`.

- After `descent` 0.55, a polygon with one or more walls receives `1 + round(_corruption(descent) * 2)` `growth` tries. A try adds no mark when it selects a wall shorter than 20 world units. Each accepted try adds one rimmed patch with 1 or 2 line paths.

- `_warm_prims(prims, descent)` applies `_warm` to each color value
  in the primitive list: lines, `dots`, `stains`, filled shapes, and paths.
  Geometry does not change. Primitives with no color value stay the same.

### Caveats

- None.

## Unit 10 — Renderer construction and baked glow sprites

### Goal

`Renderer(session)` holds all draw state: raster, framebuffer views, caches, effect pools, and baked glow sprites. These values continue across frames, which lets the renderer `age` effects and use calculated results again.

### Invariants

- The raster and framebuffer read their dimensions from the render target, not from a constant. A target-dimension change replaces them. Tests render at `480x270`, while `PERIHELION` uses the internal resolution.

- The glow falloff lives in the RGB values (the square of the linear
  falloff), because an add copy has no alpha.

### Verification

- Call `Renderer(session)` and then call `draw` with 2 target dimensions that have different pixel counts. Check that each frame has the requested dimensions. The caveat records the failure for dimensions with equal pixel counts.

### Implementation

- `Renderer.__init__(session, max_depth=22, max_instances=320)` keeps
  the session and the 2 visibility limits.

- The raster, the raw framebuffer, and the `(W, H, 3)` RGB view start
  as `None` until the first frame.

- Caches use the polygon index as the key. They hold command blobs, data
  primitives, palette sets, floor colors, wall colors, loaded textures,
  and `uploaded` texture ids. The portal edge table is one dict for the
  level.

- `polygon_texture_lookup` is a hook that the streamer sets: polygon
  index to `(level_id, local index)` or `None`. The default `None`
  means: use the session level id and the same index.

- Effect pools: gibs, `corpse` falls, sparks, electric arc, `screams`, and
  pickup texts. Tick dicts for each entity: hit flash, attacker flash,
  `arrived` event flash, and crossing flash. Player state: `hurt` ticks, the
  death fade, and a `_dying` latch.

- `spectate_eid` selects a body for the demo camera. The 3 queues hold
  instrument display glows, electric arc glows, and pickup texts. Another list,
  `_deferred_bolts`, is cleared for each frame but has no writer or reader.

- Each `draw` empties the 4 frame-end queues and then uses them again. The
  raster, buffers, baked sprites, and caches continue across frames. The
  effect pools, flash counts, death state, and `spectate_eid` also continue.

- `_radial_sprite(r, rgb)` `bakes` a square glow disc with the side
  `2 * r + 4`. The falloff is `a * a` with `a = 1 - dist / r`,
  multiplied into each channel.

- `_bake_glows()` `bakes` warm glow discs `(235, 212, 164)` at radius 8,
  16, 26, 40, 60, and 90. It `bakes` instrument display glows
  `(70, 200, 150)` at radius 6, 10, and 16. The display palette is different, thus a lit
  instrument cannot look the same as a `sentry` flash.

### Caveats

- No code in this module empties the polygon caches. Polygon indices
  only increase, thus streams that only add stay correct. The portal
  edge table does not obey this (see unit 17). Some demo tools write
  `_floor_color_cache` entries from external code.

- A frame-dimension change replaces the raster and framebuffer. It clears the texture-id set for the replaced raster but keeps texture images and polygon caches. A byte-count change uses a new snapshot buffer. The next render at the same dimensions changes data in the returned array. An array backed by a buffer of different dimensions keeps its data.

- Defect: the snapshot buffer is new only when its byte count changes.
  Two target dimensions with the same pixel count but different dimensions use
  the previous numpy shape. `draw` then returns an array with the previous width
  and height. This does not obey the target-dimension goal.

- `_lightmap` and `_deferred_bolts` are kept fields with no serviceable
  use in this module.

## Unit 11 — Effect intake (`consume_fx`)

### Goal

The caller sends simulation-effect events to the renderer once each simulation tick. Pools `age` in tick units. Thus effect timing is the same at all display frame rates.

### Invariants

- All pool `age` values and flash counts increase once each simulation tick, not once each display frame.

- Each pool has a hard limit. With no message, the renderer discards the
  first entries above the limits. The limits are 400 gibs, 40 `corpse`
  falls, and 200 sparks. They are also 30 electric arc effects, 20 `screams`,
  and 12 pickup texts.

- The death fade is for one death only. `playerreprint` clears the death latch
  and sets the fade to zero. Thus the second death does not start at `RGB (0, 0, 0)`.

- A pair of event circles around an entity increases in radius and uses RGB (255, 255, 255). It shows that the entity's aggro state started. `Scream`, equipment, prop, `recall`, and snare circles are different in color, movement, position, or `context`. This requirement applies only to event circles that increase in radius, not to each circular outline.

### Verification

- Send a `playerreprint` after a death. Check that the next death
  fades from the start and does not start at `RGB (0, 0, 0)`.

- Send 2 pickups at one point in one tick. Check that the texts
  stack and do not print on top of each other.

- See `game/tests/test_floater_render.py` for the pickup text path.

### Implementation

- Decrease comes first. Gibs move by their speed times `DT`, with a factor
  0.90 for each tick, and their life count decreases by 1. `Corpse` falls, sparks, electric arc,
  `screams`, and pickup texts `age`. The 4 flash dicts count down and drop
  at 0. The `hurt` tick count decreases.

- `gib`: the count, the position, and the direction come from the
  event. The color is the fill of the enemy type, times 0.7, or the
  `BLOOD_COLOR` when the type is unknown. Each gib receives a random angle in
  about 1.1 radians around the hit direction. Speed is 40 to 220, life
  is 18 to 34 ticks, and dimension is 1.5 to 3.5.

- `corpsefall`: a 14-tick silhouette fall at the `corpse` position. The sampled factors and shown transition to the `corpse` decal are in unit 27.

- `spark` and `marker_fire`: a 4 tick spark with a surface normal.

- `alerted`: an RGB (255, 255, 255) circle set for 10 ticks. `scream`: an RGB (236, 228, 150) circle set for 16 ticks. The `wave` thus is shown to come from that body, while only aggro uses RGB (255, 255, 255) circles.

- `attacker_mark`: 16 ticks of high `RGB[0]` blink on the attacker body. The
  source of a hit reads on the attacker, not as circles.

- `electric arc`: 4 to 8 lines with a bend, in the radius, for 6 ticks.

- `marked` and `playerhurt`: the `hurt` vignette,
  `HURT_VIGNETTE_TICKS = 14`. The value was 2 ticks, and a person could
  not tell the hit source at recording rate.

- `pickup_text`: the text and the position. Each live text in the same
  polygon lifts the new one by 13 world units.

- `hitflash`: 3 ticks of `RGB (255, 255, 255)` on the hit body.

- `arrived`: 26 ticks — sufficient for a 12 frame each second recording
  to sample the blink. `crossing`: 48 ticks — the last event of this
  body, with no second look.

- `playerdie` sets the `_dying` latch. `playerreprint` clears the latch
  and the fade. While the latch is set, the death fade increases by 1
  for each tick, with a limit at 150.

- The tags `sound`, `objective`, and `terminal` are for other
  modules. The renderer does not read them.

### Caveats

- The first version had the tags `flash`, `holemark`, and `holeopen`.
  They are gone. Muzzle flashes are lights in the sim. Breaches are also
  lights in the sim. Glow discs for one polygon ended in a hard bright edge
  at the first portal.

- Defect: the code applies pool limits before it adds events from the active call. One event list can be above a pool limit for one tick. The next `consume_fx` call removes the entries above the limit.

- Gib direction, speed, life, and dimensions, plus electric arc-line geometry, use the process-wide random generator. The same effect event can have different particles or electric arc after other code changes that generator state.

- Decision open (see `spec/open-questions.md`, item `RENDER-AGGRO-RINGS`):
  the implementation keeps only the RGB (255, 255, 255) event-circle pair
  for aggro. It uses other circles for the states that this file lists. This file
  does not select if `PERIHELION` must keep all circle shapes for aggro.

## Unit 12 — The frame (`draw`)

### Goal

`draw(surf, debug=False)` renders one frame and usually returns it as a `(W, H, 3)` `uint8` NumPy array. The caveats state the `equal-pixel-count` resize defect. The frame lightmap is the world plane's only light source. `ambient` light is zero.

On a frame without an `otherworld` polygon, the renderer composites the entity plane after the world-light multiply. Entities thus stay shown as sensor data, not as lit bodies. The `otherworld` floor uses an inverse cold field. The caveat records the different composition sequence on a mixed frame.

### Invariants

- A world pixel that no lit light touches stays `RGB (0, 0, 0)`.

- On a frame with no `otherworld` polygon, the entity plane does not dim from
  the lightmap.

- `surf` only supplies the frame dimension. The renderer does not write into
  it.

- The returned array views one renderer snapshot buffer. Its data stays stable until the next `draw` call on that renderer. The next call writes a new frame into the same buffer. Thus each kept view then shows the new frame. A caller must copy the array to preserve a frame across another `draw` call.

- The instance list that the frame painted stays as `last_instances`.
  Thus the audio pan agrees with the frame, with no second visibility
  step.

- `Spectate` mode does not move the session camera, because the bot sees
  through the session visibility.

### Verification

- Paint a frame with all lights off. Check that the world is `RGB (0, 0, 0)`
  and that entities show.

- Paint frames at 2 dimensions with different pixel counts. Check that each
  returns its dimension. In a different test, run the `equal-pixel-count` array-shape defect
  recorded below.

- See `game/tests/test_render_layers.py` for the plane requirements.

### Implementation

- The 4 paint queues empty at the start of each frame.

- `Spectate`: when `spectate_eid` names a live entity, the root polygon and
  apex go into the visibility query. A camera locked on that body also goes
  into the query. The session camera does not move.

- `session.visible(max_depth, max_instances, root, cam, apex)` returns
  the instance list. Each instance holds a polygon index, a transform, and
  a depth. It also holds an image clip polygon, image wall pieces, an entry
  edge, and the entities in it.

- The world step (unit 13) fills the raw framebuffer. `_draw_post`
  (unit 28) mixes the last effects. With `debug` set, unit 29 adds
  labels.

- The output copy runs on the raw `RGBX` bytes — one block copy of
  about 0.05 ms. An element by element copy through the view cost about
  0.7 ms for each frame. The returned array is a `(W, H, 3)` view of
  the copy buffer.

### Caveats

- The `draw` docstring tells that `otherworld` frames come back at full
  brightness and that Python reads the lightmap back. That text is
  incorrect. The engine mixes the `otherworld` field (see unit 13).

- Defect: when a frame contains an `otherworld` clip, the engine does the
  lightmap `multiplication` after the entity fold. For pixels not in the
  `otherworld` clips, that last step uses the standard lightmap. An entity
  in a standard polygon with no light can thus become `RGB (0, 0, 0)`.
  This occurs only when the frame also contains an `otherworld` polygon.
  This does not obey the sensor-data goal.

- A comment in `Renderer.__init__` names a second raster for coverage
  masks. There is no second raster.

- Decision open (see `spec/open-questions.md`, item `RENDER-SNAPSHOT-OWNERSHIP`):
  every array returned by a renderer's `draw` method shares that renderer's
  snapshot buffer. A caller must copy an array to preserve its data across
  another draw. The open decision is whether to retain this ownership model
  or return an independently owned array from each call.

## Unit 13 — The world step

### Goal

One raster call paints the complete world. Floors come first, then all
other world `content`, and the entity plane folds on top in one union
coverage mask. Cached prop blobs go into the frame stream in the call
sequence. The raster transforms and clips them in Rust.

### Invariants

- The code traverses the instance list twice. Thus each floor renders before other world `content`. Instances are ordered from farthest to nearest, and floor fills are opaque. One mixed operation can thus cut sprites at boundaries.

- The entity coverage mask is the union of the instance clips. Each
  clip increases by `ENTITY_SPILL_U` (18 world units) times the
  instance scale. Thus no body is cut at a boundary. The floor fill
  uses the clip as it is.

- The engine fold is `min(entity_alpha, coverage)`, with alpha as on
  or off.

- On frames with no `otherworld` `content`, the engine multiplies the world
  by the lightmap first. It then folds the entities in with no multiply.

- On a frame with one or more `otherworld` clips, the engine folds entities
  first and then multiplies the complete frame. In a marked clip it mixes
  the standard lightmap with the inverse cold field by that polygon's
  `_ow_mix` value. For pixels not in the marked clips, it uses the standard lightmap.

- The blob cache holds polygon-local `float32` geometry. Each blob copy
  patches only the clip and transform indices. Thus the cached
  geometry is the same for each instance.

### Verification

- Put a `station` sprite across a portal boundary. Check that the 2
  parts paint. See `game/tests/test_render_layers.py`.

- Check that a body in a doorway paints complete, to the world boundary
  that the frame shows.

### Implementation

- `_ensure_raster(size)` starts a raster and raw `RGBX` buffer at the frame dimensions. It attaches the decal shapes to the raster and clears the `uploaded`-texture set. `self._rgb` is a `zero-copy` `(W, H, 3)` view of that buffer.

- `_get_blob(polygon)` encodes the data primitives of the polygon one
  time. Lines, `stains`, filled shapes, and paths clip against the
  geometry clip. `Dots` clip by their center point. Image glows stay out
  of the blob — Python processes them for each frame (unit 14).
  Primitives with no color get the floor color with an 18 lift for each
  channel.

- `_draw_world_rust(size, instances)` runs the frame:

- The floor step first adds the clip and the increased coverage clip for
  each instance. It then adds the transform and paints the floor. The floor is
  a texture fill when the polygon has a texture. Otherwise, it is a clip
  fill with the floor color. An `otherworld` polygon also receives an engine flag
  with its `_ow_mix` weight. The engine mixes the inverse cold field
  onto the lightmap for the marked clips, after the entity fold.

- The `content` step runs for each instance, in sequence. It adds the
  prop blob to the stream. It queues the blob instrument display glows: it
  transforms the point, tests it against the clip, and scales the
  radius. It sends the decal command. It paints the exit and the
  fixtures, the walls, the doors, the entities, and the pooled
  effects.

- Then the `content` step strokes the player `kite` outline again, above
  the effects. Muzzle and spark stacks at zero distance included the
  player body for 7 frames in a run record.

- Assemble the frame command list into NumPy arrays once. Blob copies patch their clip and transform values, then go into the stream between frame pieces. One `r.draw` call does the complete stream.

- `_accumulate_lights_rust` fills the lightmap (unit 14).
  `set_darkness(True)` turns the multiply on. `finish_into` writes the
  mixed `RGBX` frame into the buffer.

### Caveats

- `_draw_world_rust` returns the `otherworld` clip list, and its only
  caller does not read it.

- The local name `kinds` in `_draw_world_rust` is set and not read.

## Unit 14 — The lightmap

### Goal

One engine lightmap collects all frame light from fixtures, attached lights, and glow sprites. Before addition, the renderer mixes all wedges from one light into one mask. Boundaries between polygons thus add light once. They do not cause seams or more lines.

### Invariants

- One light adds its value once at each image apex for all wedge counts. If visibility transforms that light to 2 different image apexes, each instance adds its value once.

- The group key uses a 1-pixel distance test, not a grid. Two transform chains can put the same apex 0.001 pixels apart. The grid method divided such a light into 2 groups and caused a portal seam.

- A `sliver` wedge with a mean width below 0.8 pixels does not
  paint. The polygon fill always paints its outline. Thus a wedge with
  an inner area near zero showed as a bright streak where correct
  coverage showed no light.

- `LIGHT_STRENGTH = 3.0` multiplies each light at the one add point,
  fixtures and flashes the same.

- Terrain shadow polygons cut out of the light fill, but do not touch
  the entity plane. The complete enemy stays shown in a terrain shadow.

### Verification

- Put one light before a straight path doorway. Check that the floor
  shows no brightness step at the portal column.

- Put a terrain rectangle between a `lamp` and the floor. Check that it decreases floor brightness behind it while a body in the shadow stays shown.

- See `game/tests/test_lighting_invariants.py` and
  `game/tests/test_terrain_light_shadows.py`.

### Implementation

- `_light_groups(session, instances)` calls `frame_lookup` on each `draw`.
  This renderer lookup is different from the lookup that the AI caller keeps
  for all queries in one sim tick.

- For each instance, it reads each light instance in its polygon. It
  transforms the wedge to image and cuts it to
  the instance clip. It drops results below 3 points. It calculates the
  image apex and the image radius, and drops a radius below 1 pixel.
  Shadow polygons transform and cut the same.

- For each light, a wedge is added to the first group when it agrees with 3 tests.
  The absolute differences in image `x`, image `y`, and radius must each be
  at most 1.0 pixel. The group values change to their arithmetic means after
  each item. Thus, the instance sequence can select a different first group
  when two groups overlap. If no group is near, a new group starts. If the
  light has a cone direction, the group receives its image transform.

- `_prep_gate_polys(cx, cy, radius, polys, cone)` drops `sliver` wedges
  when `abs(signed_double_area) / perimeter` is below `0.8`. This value
  equals `2 * area / perimeter`. Then it cuts each wedge to the
  cone polygon.

- `_cone_wedge` is a convex fan: the apex plus 11 points at radius
  `1.25 * radius` across the cone angle width. The cone is a clip, not a sprite,
  because a turned sprite cannot give the same pixels for each chain.
  The cone angle width must stay below `pi` to keep the fan convex.

- `_accumulate_lights_rust` sends each group to `Raster.add_light`. It sends
  the apex and the radius. It sends the color times `intensity * 3`, with a
  limit at 255. It also sends the wedge polygons and the shadow polygons. The engine fills the
  union with the `pygame` parity fill and adds the radial falloff.

- The queued instrument display glows and electric arc glows then add as sprites. The
  code selects the baked disc with the nearest radius. It cuts the copy
  area to the frame and to the clip bbox. Then it adds the disc into
  the lightmap area, with a limit at 255.

### Caveats

- The cone clip has a hard edge on image. The brightness at the edge of the
  AI light query (unit 32) decreases gradually. The 2 do not agree at the cone border.

- A cone angle width `>= pi` has a fan that is not convex, and the cut
  result is then not correct. No light in `PERIHELION` does this.

- The renderer does not reject or clamp a cone angle width at or above `pi`.

- Decision open (see `spec/open-questions.md`, item `RENDER-WIDE-CONE`):
  select a requirement for cone angle widths at
  or above `pi`. The alternatives are reject, limit to less than `pi`, or use them
  with no limit.

## Unit 15 — Polygon identity and colors

### Goal

Each polygon has a `descent` value, type, and palette. The session keeps `marrow` area identity because those areas are not part of a level. This identity continues across chunk changes.

### Invariants

- The `descent` value and type stay constant for each polygon. The renderer fills each polygon's palette cache once.

- Walls do not dim below the wall minimum color. Walls are the read
  frame of the level.

- The same `_ow_mix` curve adds the `otherworld` floor color and the light
  mode to the frame. The first `otherworld` polygon thus stays visually
  connected to the area before it.

### Verification

- Read the palette of one polygon 2 times. Check that the results
  agree.

### Implementation

- `_polygon_descent(polygon)` first checks the session's `hub_polygon_meta` table, then the level's `descent` list. An index `>= len(descent)` uses the last value. The module cannot set a maximum error because it has no chunk `descent` step. A missing list returns 0.

- `_polygon_kind(polygon)`: the hub table is first, then the level type
  list, then `generic`.

- `_polygon_pal(polygon)`: the (floor, wall, wall minimum) set,
  sampled at the polygon `descent`. The types `marrow` and `otherworld`
  use the `marrow` color curves. The remaining use the standard color curves. Cached.

- `_floor_color(polygon)`: for `otherworld`, the palette floor mixed to
  `OW_FLOOR` by `_ow_mix`. For the remaining, the palette floor through
  `_shade`. Cached.

- `_wall_color(polygon)`: the palette wall through `_shade`, with a
  clamp for each channel at the palette wall minimum. Cached.

### Caveats

- None.

## Unit 16 — Floor textures

### Goal

A polygon can have a floor-texture image from its level. The renderer loads it once and `uploads` it once on each raster. The engine then samples it for each pixel through the instance transform.

### Invariants

- The texture cache continues for the process lifetime. A missing file is cached as `None` for that same lifetime. Thus the renderer reads disk at most once for each polygon.

- The bbox corner comes from the local polygon corners at first load.
  These are the static corners that the texture tool used.

- A new raster starts with no textures. Thus each texture
  `uploads` again on next use after a dimension change.

### Verification

- See `game/tests/test_render_textures.py` for the texture path. See
  `game/tests/test_root_invariance.py` for the check that the sampled texel
  does not change with the portal chain.

### Implementation

- `_texture_key(polygon)`: the streamer hook when set, then
  `(level.level_id, polygon)`, then `None` when the level has no id (a
  test level from code).

- `_load_polygon_texture(polygon)`: the path comes from
  `texture_geom.texture_path`. The image loads through PIL as RGB
  `uint8`. The result is the array plus the bbox minimum corner.

- `_polygon_texture_for_raster(polygon)`: on first use for each raster,
  it `uploads` the image bytes with the polygon index as the id. It
  returns the texture id and the bbox corner for the texture fill
  command.

### Caveats

- A polygon has no texture when the `soft-body` simulation changes its vertices
  at run time. A texture on such a polygon can sample against incorrect corners.

## Unit 17 — Polygon data cache

### Goal

The renderer calculates each polygon's props once from its seed and caches them as primitives. Two random streams keep the initial objects stable and add `depth-dependent` floor and wall marks.

### Invariants

- The same polygon and seed give the same primitives on each run and
  each frame.

- Random selections from the first stream are the same at each depth. Only the second stream controls `growth` and `depth-dependent` changes. Its seed is `seed ^ 0x5EED5EED`.

- The `_warm` `bake` and `float32` conversion run once when the cache entry is filled.

### Verification

- Fill the cache for one polygon in 2 processes and check that the primitive lists agree.

### Implementation

- On the first call, `_portal_edges_for(polygon)` fills a dictionary from
  each polygon to its portal-edge set. It reads the level connection list
  in the two directions and the door list. It then caches the result for the
  process lifetime. A polygon without an entry receives an empty set.

- `_get_detail(polygon)`: the seed is the level seed for the polygon,
  or `polygon * 7919 + 13` after the end of the seed list. The first
  stream is `Random(seed)`. The second stream uses the changed seed
  (above).

- The type function runs first. The function for marks that change
  with depth runs next. The warm `bake` and the `float32` conversion run
  last. The result caches.

- `_draw_detail(...)` is the first version: a Python painter for the
  same primitives, run for each frame.

### Caveats

- Defect: streamed chunks and areas that the simulation adds are not in the portal-edge table. `append_chunk` connects new polygons only in the engine and does not extend the level connection list. The table also does not change after the first frame. These polygons thus receive empty portal sets, which lets wall props render across open doorways. This does not obey the position goal in unit 7.

- `_draw_detail` has no caller. The blob path (unit 13) replaced it.
  No caller.

- `_get_detail` returns an empty list for an index after the level
  corner list, and does not cache that result.

## Unit 18 — Decals

### Goal

Floor marks that continue—`blood`, particles, burn mark marks, and `corpse` shapes—live in the engine. Python `uploads` a polygon's decal records only when their version changes. One command for each instance then renders them.

### Invariants

- The `upload` has a version gate for each polygon. Decals with no change
  cost one command for each instance and no Python loop.

- A `corpse` decal keeps its type's shape but no hue. Its equal RGB channels contain the `type-fill` luma times 0.45. The player factor is 0.4 and squash is 0.55. In a test, 3 persons marked `corpses` with hue as live enemies.

- `BLOOD_COLOR` stays below each live enemy fill. `BLOOD_COLOR` must not pull the
  look from a threat.

### Verification

- Kill one enemy of each type and record the floor. Check that each decal clearly shows death and keeps a `type-specific` shape.

### Implementation

- Shape ids at raster construction: the `blood` shape 1, the `splat`
  shape 2, and the circle 3. Then 2 particle lines 4 and 5, 2 short line
  shapes 6 and 7, and the player `kite` 8. Each enemy type receives one shape
  from id 16 up, in sorted type sequence.

- `_decal_records(decals)` changes each sim decal to one or more
  records of 12 numbers:

  ```text
  [style, x, y, dimension, angle, squash, effect_multiplier,
   r, g, b, shape_id, rotate_shape]
  ```

  Style 0 paints a cached shape. Style 1 paints the burn mark disc. Style 2
  paints a line shape. A `rotate_shape` value of 1.0 turns the cached
  shape by `angle`. A value of 0.0 does not turn it.

- `blood`: the `blood` shape, factor 0.72. `splat`: the `splat` shape,
  factor 0.6. `chip`: the 2 particle lines, style 2. `burn mark`: style 1 with the
  burn mark color.

- `corpse_<type>`: the shape record of the type plus the 2 line records.
  All have equal RGB channels from the drain and squash 0.55. An unknown
  type falls back to the circle shape and initial `(90, 90, 90)`. The
  luma and factor set the last equal channel value.

- `_emit_decals` reads the session decal list and version for the
  polygon. It `uploads` on a version change. Then it sends one decal
  command with the instance clip and transform.

### Caveats

- The engine record replay in `raster.rs` is the `port` of the first
  version, a Python loop for each frame. That version cost more
  than 1.3 ms for each frame at about 220 decal polygons.

## Unit 19 — Fixtures: the exit, wall terminals, pods, repair stations

### Goal

World-plane fixtures render at their world positions. The exit symbol breathes. Wall terminals are flat against walls and have lit displays. A `pod` is shown as a body-production fixture with its `inventory` count. A repair `station` is shown as deployed field equipment. A line connects each `pod` to the turrets it supplies.

### Invariants

- A fixture paints only when its position point is in the instance clip.

- A wall terminal scores each edge. A portal edge receives 6 times its squared
  distance as the score. Thus the function usually selects an edge that is not a portal but can
  select a sufficiently near portal edge.

- The `pod` `rack` shows at most 3 body marks. A bar above a full `rack` shows `inventory > 3`, while an empty RGB frame is shown at count 0. The `rack` looked empty when it was behind the column. Thus the `rack` is on the panel below the column.

- A repair `station` or turret shows a circular outline during its
  construction period. The outline contracts as the remaining construction
  time decreases. It shows no charge
  circle or circle for no ammo before the period is complete.

- Breaches have no floor symbol. The broken wall is the portal, and the breach light comes from the simulation. A floor circle incorrectly showed a material floor object.

### Verification

- Add a `pod`, put a turret in the same polygon, and record them. Check that a supply line connects the `pod` to the turret and has a bright point that moves.

- Damage a repair `station` and check that its damage bar is shown.

- Read a wall terminal and check that its display dims after the read.

### Implementation

- The exit: a circle with radius `9 + 4 * sin` on a 90 tick cycle, plus a
  small triangle, in the exit color.

- `_nearest_wall_point(polygon, pos)` walks all edges. It clamps the
  nearest point to the middle 84 percent of each edge. It scores by the
  squared distance, times 6 for portal edges, and returns the best
  point with the wall directions.

- `_draw_terminal` renders a dim `13 x 6` block flat against the wall, with a rim and display at 0.62 of the block depth. Before the read, the display uses RGB (100, 255, 140) and queues a glow. After the read, it uses RGB (55, 110, 75) without a glow. In a polygon without an applicable edge, it uses the initial small rectangle glyph.

- The `pod` (the session `stations` list) paints in parts:

- Roots: the root factor is `min(1, age / (unpack_ticks * 1.5))` —
  about 45 seconds to full. 5 root paths extend through the lower 180 degree
  circular curve. Each has a bend, a short side line, and an end point that
  flashes when almost full. The start tick of the first spawn `pod` is far
  back, thus it starts full.

- The body: a bottom panel with 3 bright points, and a column with 4 `rib`
  lines. A bright center space breathes on a 120 tick cycle. A 2 piece arm
  is above an output slot, plus the `rack` (above).

- 2 circles flash around the `pod`, radius `19 + 6 * sin`.
  These circles also flash while the root factor increases for a `pod` with a limited body supply. The
  `pod` does not use the `unpack circle` requirement of a repair `station` or turret.

- Supply lines: one line extends from the `pod` to each supplied turret in
  the same polygon. It paints when the turret position is in the clip. One
  bright point moves `pod` to turret on a 44 tick cycle. Supply across
  polygons works in the sim but paints no line — there is no portal
  to route it through.

- The repair `station` is in the session's `boosters` list. It has a bottom
  panel, body box, open top panel, and dim plus sign. The sign has a long
  stem and a high horizontal bar. It does not use the RGB (200, 90, 90)
  medical mark because that mark is kept for medical equipment.

- A charge display of 6 cells against the pool maximum, with a frame.
  Before construction is complete, a circular outline contracts from
  radius 15 pixels to radius 6 pixels. The remaining construction fraction
  decreases from 1 to 0. After that, with charge above 0, a circle changes brightness slowly on a 150 tick
  cycle. With damage, a dim bar with a bright fill fraction paints above the
  body.

### Caveats

- The supply line reads `session.turrets` and the sim position of each
  turret in each frame, for each `pod` instance.

- Defect: the goal states that a wall terminal is attached on a wall. The edge
  check multiplies a portal score by 6. A portal can have the best
  score and put the terminal block in a doorway. The portal-edge cache from the first frame
  cache of unit 17 increases this risk for streamed polygons.

- Decision open (see `spec/open-questions.md`, item `RENDER-POD-PULSE`):
  select if `pod` flashes can continue as roots
  become full. The alternative is one construction requirement with no flash for all
  fixtures after construction. The implementation lets the `pod` flashes continue.

## Unit 20 — Walls and doors

### Goal

Walls render as 2-pixel strokes in the polygon's wall color. Open portal edges have no wall stroke. This obeys the seam requirement. A locked door uses its key color. A `secret` door uses the wall color with one small identity mark.

### Invariants

- `_draw_walls` draws no wall stroke on an open portal edge. A closed door is
  in the portal-edge table, and `_draw_doors` paints the door stroke.

- A `secret` door uses the wall color of this polygon, which turns with
  `descent`. A cold `WALL_COLOR` block in a warm deep `deck` is a tell.

### Verification

- Record video of a doorway between 2 polygons. Check that no line goes across the
  opening.

- Find a `secret` door and check that only one short line is different from the wall.

### Implementation

- `_draw_walls` strokes each wall piece from the instance data with the
  cached wall color, width 2. It does not stroke portal pieces.

- `_draw_doors` walks the session door edge table for this polygon and
  reads the edge end points from the sim. A read with an error drops that
  edge for this frame.

- A door with the key `shoot` is a `secret` door. It has the wall color
  stroke and a 1 pixel mark at 0.62 along the edge. The mark is 3 pixels
  into the polygon.

- Each other door: a 3 pixel stroke in the key color (or the door
  color), plus a `4 x 4` filled square at the middle.

### Caveats

- The endpoint read catches `Exception`. If a door edge is incorrect, the
  renderer does not draw it in that frame and supplies no message.

## Unit 21 — Entity dispatch and the player body

### Goal

The renderer draws each shown entity by its `role`. The player `kite` shows all player state marks on its body: back load, `revival` blink, `brand`, snare, and `recall` circle. The HUD does not show them again.

### Invariants

- Entities always paint complete. The engine coverage mask cuts them at
  the world boundary that the frame shows, not the code for each entity.

- An RGB outline on the player body identifies the `brand`. Other marks with the same RGB channels, for example the marker projectile, do not outline the player's body.

- The `revival` blink fills the body with RGB (255, 255, 255). Only the event-circle pair that increases in radius with those channels shows aggro. Snare, `recall`, equipment, prop, circles for no ammunition, flash, and `scream` circles use different colors or `contexts`.

- The held load turns with the body. Thus it looks attached to the body, not a sprite that stays behind it.

### Verification

- Collect a `pod` and turn with no movement. Check that the `pod` shape stays behind the `kite`.

- Receive the `brand` and check that its RGB outline and `glob` stay attached to the body.

- See `game/tests/test_crossing_is_visible.py` and
  `game/tests/test_grip_attribution.py`.

### Implementation

- `_role_kind(eid)` tests the id against session tables in this sequence: player, enemies, bullets, pickups, and turrets. The removed version did not set a `role` for turrets. Thus they could fire and kill while not shown.

- `_draw_entities` reads the entity list of each instance. It reads the id,
  image position, direction, image radius, and `fully_inside` flag. The clip
  value is always `None` at each call point.

- The player, in sequence:

- `_draw_carried` comes first, thus the `kite` is on top of the load.
  `Pods` render as 8-corner shapes in the `pod` palette with a center that
  breathes. Kits render as squares. Items stack behind the
  body, and a short line connects the first item.

- The `kite` at radius 7 or more. During `revival_grace`, the fill blinks
  with RGB (255, 255, 255) each 8 ticks. Otherwise, the player color.

- The outline: RGB (255, 90, 220), width 2, while the `brand` holds. Otherwise, RGB (255, 255, 255),
  width 1.

- `_draw_brand`: an RGB (255, 90, 220) `glob` at body scale stays opposite
  the travel direction. It has a bright center and a dimension that changes in a cycle. When the body
  moves, a 6 point trail paints down the travel path. A small `glob`
  changed 8 pixels at the play zoom. Thus, a person does not read it immediately.

- `_draw_snared`: 6 line lines attached to the body, each a dim
  stroke below a light stroke. Thus the hold reads on bright floors
  and on dim floors. The strokes thin as the hold runs out, thus the
  release shows before it occurs. A circle pair is at the
  center.

- The `recall` channel: a circle that closes as the count runs, radius
  `9 + 26 * (count / 90)`.

### Caveats

- Decision open (see `spec/open-questions.md`, item `RENDER-AGGRO-RINGS`):
  see unit 11 for the one open selection about circle shapes. The
  implementation keeps only the RGB (255, 255, 255) event-circle pair that increases in dimension.

- The clip value is always `None`. Thus all clip tests in the `role` paint
  functions are code paths with no effect during play.

## Unit 22 — Enemy bodies

### Goal

An enemy body displays each state mark directly on its body. The marks are
hit flash, `lurk` dim state, `wind-up`, and attacker blink. They also include
the `arrived` blink, crossing change, and `grip`. The player must identify
the damage source through each combat overlay in the frame.

### Invariants

- The sensor-intensity channel only scales or mixes the type's fill and rim. It does not add another draw path.

- A body in `lurk` stays shown because the simulation clamps its intensity to `>= 0.12`.

- The attacker blink is on the attacker body, not circles.

- During a `warden` `grip`, the dim 9-corner body does not turn RGB
  (255, 255, 255) or gain circles. Its rim shows the signal. It uses RGB
  warning channels during the active attacker blink. It uses RGB
  (255, 255, 255) when the player hits it. The `grip` uses the warning rim
  because high `RGB[0]` values fill much of the image. A signal with the
  same values is not easy to see.

- The `arrived` event and crossing tints for the Adversary types must mix in
  the sensor-return painter (unit 23). A tint in this function has no effect for
  those types, which go to unit 23 before it applies.

### Verification

- Let a `spitter` hit the player. Check that its RGB attacker blink lasts 16 ticks, approximately 0.267 seconds at `60 ticks/s`. During that interval, it is on for 2 ticks and off for 2 ticks.

- Let a `warden` `grip` the player. Check that its body keeps low brightness while the `warning-colored` rim blinks.

- See `game/tests/test_grip_is_visible.py`.

### Implementation

- `_draw_enemy` lifts the radius to the type minimum. The hit flash
  turns fill and rim to RGB (255, 255, 255).

- The intensity channel: below 1, fill and rim scale down (the `lurk`
  `flicker`). Above 1, fill and rim mix to RGB (255, 255, 255) by the
  quantity above 1 (the `engulf` `wind-up`). The sim controls it, not a
  free timer.

- The attacker blink: the fill mixes 0.75 to RGB (255, 60, 45), and the
  rim uses a higher `RGB[0]`. It is on for 2 ticks and off for 2 ticks.

- The crossing: let `k` be the remaining count divided by 48. The fill
  mixes to `(44, 92, 74)` by `1 - 0.75 * k`. Thus the mix starts at 0.25
  and increases to 1 as the count runs out. The rim mixes to
  `(150, 255, 210)` by `0.5 + 0.45 * k`. Thus the rim mix starts at 0.95
  and decreases to 0.5.

- The `arrived` event: the fill mixes 0.85 to `(120, 255, 160)`, on for 3
  ticks and off for 3 ticks. RGB (120, 255, 160) has no other tell.
  A high `RGB[0]` means "this one caused injury." RGB (255, 255, 255)
  means a hit.

- Types with the prefix `core_` go to `_draw_core_part`: one RGB group
  with slow movement only. The work of each part shows in its
  silhouette.

- `core_source` keeps the beat tell: lines that extend out with the
  beat, and a hot center that expands. `core_collar` has an inner circle
  with 4 clamp ticks. `core_anchor` is a low block held to the floor
  with 2 lines. `core_bud` has an inner disc that expands on its phase.
  `core_caretaker` uses RGB (150, 120, 160) with a plus symbol.
  `core_scriptorium` has a circle of 6 short lines.

- All beat phases key on the entity id, thus the group does not beat
  in step.

- A `mite` is a disc with a rim. The Adversary types go to unit 23.

- Each other type: the initial shape fills after the function moves its vertices. Then a shadow copy at
  0.62 scale is behind the direction of the body, and a bright point
  is forward (the `spitter` point uses its type RGB, and the `shrieker`
  has none). A `brute` adds 2 RGB (255, 255, 255) strokes at the head sides. A `warden`
  adds an inner circle. The rim strokes last. A `husk` adds a center
  `dot`.

- `_draw_scan_pips`: with `deep_scan_1` or `deep_scan_2`,
  an enemy below full HP shows a thin HP bar above the body. The bar
  is 2 pixels, in the instrument RGB on a dim back.

- A body in the `call` state calls `_draw_caller_tell`, which paints
  no pixels (below).

### Caveats

- `_draw_caller_tell` returns with no work, as specified: the
  breach is the complete tell. The first version painted circles and a
  center, and that was incorrect. The call point and the transmit count
  value stay in the code. This path has no caller.

- Defect: `_attacker_flash` changes the local fill and rim in `_draw_enemy`.
  But `vagrant` and `lacuna` go to `_draw_adversary`, which ignores those
  values. An Adversary body that causes player injury does not show the
  large `RGB[0]` attacker blink. This does not obey the goal to show the
  source of damage.

- The `_draw_entities` docstring names a removed `pygame` world step.
  Incorrect text.

## Unit 23 — Adversary sensor returns

### Goal

An Adversary body renders as a sensor return that the instrument cannot identify as an object. It does not render as an outlined body. It contains simultaneous open-contour segments at radii from 0.58 to 1.02 times the trace radius. Lines extend through the boundary, and the center is empty space, not an internal region.

### Invariants

- The contour does not close. Each contour keeps one or more spaces, and the
  spaces move.

- No part follows a circular path. The body moves side to side through a
  limited `sine` function. In the first version, circular movement caused
  small parts to orbit the body.

- Each vertex moves at all times.

- The sensor return is wider than the collision body. It uses
  `ADVERSARY_TRACE_SCALE` with a 7-pixel minimum. This is a
  `rendering-only` change. Simulation state and recorded seeds do not
  change.

- The blink from an `arrived` event mixes into the color from
  `ADVERSARY_TRACE`. The crossing change and hit flash also mix into this
  color in this function. This function ignores the fill and
  rim from unit 22. The 3 video checks showed that a tint in unit 22
  causes zero changed pixels for these types.

- The attacker blink is also necessary on these types. The caveat in unit 22
  records that the implementation does not supply it.

### Verification

- Record a `vagrant` and `lacuna` at play zoom. Check that the two are
  not shown as closed shapes. They must stay larger than a small mark.

- Put one in the world through an entry event, and put one out of the
  world through a crossing exit. Check that the sensor return displays
  the two events through the specified entry blink and crossing RGB
  change.

### Implementation

- The type selects its color from `ADVERSARY_TRACE`. An `arrived` blink
  mixes by 0.85 to RGB (120, 255, 160). It is on for 3 ticks and off for
  3 ticks. As the crossing counter decreases, the color changes
  to RGB (44, 92, 74). A hit flash changes the complete sensor return to
  RGB (255, 255, 255).

- The parts, from mass to accents:

- The center region uses the shape at 0.86 radius with vertex offsets
  calculated at 0.5 times the tick rate. Its fill is RGB (7, 9, 12).
  This is a hole in the world frame. The initial dim fill was not
  shown on dim floors.

- The strong contour: the shape at 1.02 radius. Its angle changes through
  a limited `sine` function. The function
  moves its vertices and adds a stroke at width 2. One space moves one piece each 6
  ticks.

- The second outline: 0.58 radius, with an angle change in the other
  direction, at 0.42 brightness, with 2 spaces that move.

- 2 lines: the start points walk the contour. Each line extends
  and retracts on a slow `sine`. A bend point in the middle moves fast.
  The brightness follows the length.

- Short bright strokes deep in the center area blink on tick gates.

### Caveats

- This function did not apply body RGB changes 3 times, for `arrived`,
  damage source, and crossing. The invariant above prevents this defect
  in new body-RGB events.
  Each new body-RGB event must also be mixed in this function.

## Unit 24 — Sentries

### Goal

A deployed `sentry` renders at a set pixel dimension as equipment with
clear legs, drum, head, and `barrel`. It uses the same `warning-colored`
RGB channels as `sentry` fire. Rotation, fire, construction, empty
ammunition, and damage are all shown on the body.

### Invariants

- Set pixel dimension: a `sentry` that the player deploys must keep its
  turret shape at the standard zoom. It must not become 3 dim pixels.

- The `sentry` uses `warning-colored` channels. A triangle with the
  instrument RGB is not easy to identify apart from an Adversary trace at
  play scale.

- The legs stay. Only the head and the `barrel` turn, with the sim
  `face` value.

### Verification

- Put a `sentry`, let it fire, exhaust its ammunition, and damage it.
  Check that fire causes a muzzle flash. Zero ammunition adds an RGB
  (90, 70, 40) circle around the drum. Damage adds a bar, and construction
  adds a circle.

- See `game/tests/test_sentry_turret.py`.

### Implementation

- 3 leg strokes at wide angles behind the direction. A drum disc with a
  rim, 5 pixels behind the head. A head triangle with a bright rim. A
  `barrel` stroke 15 pixels long with a small muzzle circle.

- Muzzle flash: for 4 ticks after the sim fire tick, 2 bright discs
  paint at the muzzle. A short streak paints down the `barrel` line. All
  dimensions follow the fraction that stays.

- Construction: a circular outline contracts from radius 14 pixels to radius 6
  pixels as the remaining construction fraction decreases from 1 to 0.

- Dry: with ammo 0 and no supply, a dim circle around the drum.

- Damage: a dim bar with a bright fill fraction below the body when
  the HP fraction is below 1.

### Caveats

- None.

## Unit 25 — Bullets

### Goal

Each projectile stays shown through its movement and shows its source.
No enemy projectile can agree pixel for pixel with player fire. Tool
projectiles have different shapes and RGB values.

### Invariants

- Turret projectiles use RGB (150, 240, 205), while the player tracer
  uses RGB (255, 245, 180). Other enemy projectiles use different RGB
  values.

- The `lob` paints at the sim radius as a filled mass. Each player
  projectile is a thin streak. Thus the 2 cannot form one shape.

- The `snare` projectile is a `dotted` line. Thus it cannot have the
  same shape as the damage projectile, also where the palette is full.

### Verification

- Record combat with an active player, turret, `spitter`, and `shrieker`. Check that each projectile stays shown and identifies its source without other `context`.

### Implementation

- `marker` (the `shrieker` tag projectile): an RGB (255, 90, 220) point
  with an 11 pixel streak and an RGB (255, 215, 245) center.

- `spit`: an RGB (140, 205, 60) `glob` with a 14 pixel RGB (90, 140, 40)
  streak. This threat must be shown while the projectile moves, not only
  on the hit.

- `dart`: 4 short RGB (120, 240, 255) strokes out from the center, plus
  a small disc.

- `turret`: an RGB (150, 240, 205) streak with a point.

- `lob`: a filled dim disc at the sim radius with a rim pair, plus 2
  lines that turn as it travels. Thus it is shown to be a heavy object that
  turns, not as a fast projectile.

- `snare`: 5 `dots` behind the point, plus a bright center.

- All other types: the RGB (255, 245, 180) tracer streak, 12 pixels.

### Caveats

- The clip test at the top is a code path with no effect during play
  (see unit 21).

## Unit 26 — Pickups

### Goal

Each pickup type has a clear small glyph. Thus the player can identify it
in the world at play zoom.

### Invariants

- A key item paints its named glyph group (unit 6). An unknown name
  falls back to a small key glyph.

- The `corpse_frame` and the dropped structures flash. An item that the
  player can use pulls the look.

### Verification

- Drop one pickup of each type and record the floor. Check that the
  player can identify each type at play zoom.

### Implementation

- `ammo_9mm`: an RGB (200, 150, 40) box. `ammo_shell`: an RGB
  (180, 60, 50) box. `ammo_cell`: an RGB (60, 200, 220) disc with an
  RGB (200, 250, 255) rim.

- `medkit`: an RGB (40, 40, 44) box with an RGB (235, 235, 235) plus sign.

- `turret` (the kit): a low triangle with a bright rim and a point.

- `safe_polygon_core`: an RGB (30, 26, 44) disc with an RGB
  (170, 140, 255) rim and an RGB (220, 205, 255) point.

- `weapon_*`: an RGB (190, 195, 200) weapon side shape from 2 rectangles.

- `components`: a small triangle, a small rectangle, and a bright
  triangle outline, in 3 RGB values.

- `corpse_frame`: a flat dim frame shape with a rim that flashes on a
  90 tick cycle. The flash marks it as an item the player can use.

- `dropped_pod`: the `pod` in its transport crate, with RGB (30, 46, 40),
  3 short vertical lines, and a point that flashes.

- `dropped_repair`: the repair `cabinet` on its bottom panel, with an
  RGB (120, 200, 235) rim.

- `dropped_sentry`: the turret on its 3 legs, muzzle down, with an RGB
  (235, 190, 110) rim.

- `implant_lightning`: an RGB (90, 220, 255) 4-corner shape on its point.

- `key_*`: the key color from the table, then the glyph group from the
  item name, then the small key glyph.

### Caveats

- None.

## Unit 27 — Pooled effects

### Goal

For each instance, pooled effects render on the entity plane. They are
`corpse` falls, gibs, sparks, electric arc centers, `scream` circles, and pickup
text.
The last `corpse-fall` frame must touch the `corpse` decal without an RGB
step. Electric arc centers must stay after the normal frame's lightmap
`multiplication`. Pickup text must be easy to read in a dim polygon.

### Invariants

- `_draw_effects` returns before it calculates the instance scale only when all
  6 effect pools are empty. The empty check includes the pickup-text pool.
  Thus a pickup text paints when all other pools are empty. This also occurs
  for a pickup with no combat.

- The electric arc center paints on the entity plane. The normal frame's
  lightmap step does not dim it. The `mixed-otherworld` defect in unit 12
  can dim it. Its glow is added to the lightmap as a light.

- A `corpse` fall stays at the `corpse` decal position. The specified last factors
  are radius 0.9, squash 0.55, and brightness 0.45. The caveat records that
  the sampled frames do not use them.

### Verification

- Collect ammunition far from combat and check that the pickup text is shown.

- Kill an enemy and record the fall. Check that the last fall image keeps
  the live hue. The decal has equal RGB channels. Record this RGB step as
  the defect below.

### Implementation

- Each render path checks the item's polygon and tests its point against the instance clip.

- `Corpse` falls: across 14 ticks, the shape of the type turns to the
  `corpse` angle. The dimension decreases to 0.9, and the squash decreases to 0.55. A
  factor for each live color channel decreases from 1.0 to 0.45. The change
  is linear. The color keeps its hue during the fall.

- Gibs: discs at 0.5 of their dimension times the instance scale, in the
  color of the enemy type.

- Sparks: 5 pixel strokes along the transformed surface normal.

- Electric arc: when `life % 2 == 0`, the lines with bends paint on the entity
  plane in `LIGHTNING_COLOR`, cut to the clip. On each tick, a glow
  at `radius * scale * 0.6` is added to the lightmap queue.

- `Scream` effects: 2 circles that expand with `age`, 6 pixels apart.

- Pickup texts: each queues its text and its image position, lifted
  by `age` (10 pixels plus 22 across the life). The alpha holds full for
  the first 0.5 of the life, then fades to 0.25. Unit 28 paints them.

### Caveats

- Defect: the fall keeps the live type's hue while the decal changes to
  equal RGB channels. The pool removes the record when `age` is 14.
  Thus the last rendered value uses `k = 13 / 14`. It does not use the
  specified dimension, squash, or brightness factors. The last fall
  frame and `corpse` decal thus have different RGB values and geometry.
  Thus it does not obey the goal for an RGB change with no step.

## Unit 28 — Post overlays and pickup text

### Goal

The last frame composition adds pickup text with a shadow copy. It also adds
the low HP flash, the `hurt` vignette, and the death fade. The engine does
operations on the complete frame. Their NumPy versions cost 3 to 6 ms on
frames with high render cost. These frames cause `stutter`.

### Invariants

- Injury is clear at the frame edges. The center of the world stays clear
  through each edge step. The low HP and `hurt` steps use the edge falloff
  field. The low HP alpha has a limit at 95.

- The kill is clear before the dim step. The death fade has a large `RGB[0]`
  step that decreases while an RGB (0, 0, 0) step increases across 150
  ticks. No cut changes the frame to RGB (0, 0, 0) in one step.

- Pickup text does not print on a different pickup text. Texts that touch
  move up on the image, top text first.

- Pickup text paints after the lightmap. Thus it reads in dim polygons. An
  RGB (0, 0, 0) copy has a 1 pixel offset below a 16 pixel face.

### Verification

- Decrease the player to low HP and check that the edge flash is shown while the center stays clear.

- Kill the player once. Check that the frame changes through large `RGB[0]`
  channels before it changes continuously to RGB (0, 0, 0).

### Implementation

- Pickup texts sequence by image `y`, top first. Each new text in a 64 by 18
  pixel area that contains text moves 18 pixels above it. Each paints 2
  times: RGB (0, 0, 0) at a 1 pixel offset, then the text color scaled by its
  alpha.

- The step list, in sequence:

- HP below 35 and while the player lives: an RGB (160, 8, 8) edge step. Its flash is
  `0.55 + 0.45 * sin(tick * 0.25)`, and its alpha is `int(95 * pulse)`.
  The angle is in radians. One full cycle is about 25.13 ticks.

- Active `hurt` ticks: an RGB (160, 8, 8) edge step with alpha `150 * k`
  plus an RGB (190, 26, 26) flat step with alpha `24 * k`. Here, `k` is
  the fraction that stays.

- During death with an active fade, a flat RGB (200, 16, 16) step fills the frame.
  Its alpha is `170 * (1 - fade / 60)` while the integer result is above 2. Then a flat
  RGB (0, 0, 0) step uses alpha `255 * fade / 150`.

- One engine call applies the step list to the framebuffer.

### Caveats

- A breach opening causes no step on all frame pixels. The light of the breach
  increases in the sim. A flash with no source is noise.

## Unit 29 — Diagnostic labels

### Goal

With `debug` set, each instance displays its polygon index and depth at
the clip center. A debug user can then compare the frame with the world
graph.

### Invariants

- Debug labels render after full composition and change only the returned frame.

### Verification

- Call `draw` with `debug=True` and check that each shown polygon instance shows `r<index> d<depth>` in the set debug color.

### Implementation

- For each clipped instance, render the debug text at the arithmetic mean
  of its clip points. If one polygon is shown through 2 or more portal
  chains, each instance receives a different label. The text module uses
  dimension `ui(12)`.

### Caveats

- None.

## Unit 30 — Light instances (`lighting.py`)

### Goal

A world-light object has a position from which the engine calculates
visibility. Each polygon in that calculation receives a lit wedge in its
local coordinates. Engine invariant `R1`, chain-free geometry, means that
one static result is correct for each camera instance of that polygon. The
result stays correct for the process lifetime only if the portal graph does
not change after calculation.

### Invariants

- A wedge is chain-free. The clip, apex, radius, and cone direction all live
  in local coordinates of the found polygon. The shadow polygons also use
  those local coordinates.

- The query camera only moves points. It does not turn or scale them.
  Thus the cone direction is the same in world and in query space.

- The function discards an instance with no message if its transform chain
  has zero area or scale near 0.

### Verification

- See `game/tests/test_lighting_invariants.py` for the check that
  cached wedges agree with wedges calculated again.

- See `game/tests/test_root_invariance.py` for the chain-free invariant.

### Implementation

- `LightInstance` is a frozen record. It holds the polygon index, the
  local clip points, the local apex, and the local radius. It also
  holds the local cone direction or `None`, and the local terrain
  shadow polygons.

- `compute_light_instances(sim, light, max_depth=6, max_instances=12)` calculates the wedges as follows.

- The query area is a square with the side
  `2 * (radius + 15 percent)`. A camera that only moves centers it on the
  light.

- `sim.visible_set` runs the same code path as the player camera, with
  the light as the camera position.

- For each instance, apply the inverse transform to the clip and apex.
  Divide the radius by the chain scale, and transform the cone direction
  through that inverse.

- Terrain shadows calculate for each instance with a `reach` of 4
  times the local radius. Thus the far edge of a shadow polygon does
  not cut a shadow short. The correct limits come after: the radial
  falloff and the clip.

### Caveats

- The scale reads from 2 set matrix cells. That agrees with the
  engine transform format, and unit 14 reads the same cells.

## Unit 31 — Terrain shadows

### Goal

Terrain in the `walk-mask` blocks `lamp` light as a wall does. It does not
block the player's view of entities. Each terrain rectangle has one shadow
polygon from the light position.

### Invariants

- The shadow polygon follows the rectangle's unlit side and includes its unlit
  near corners, so oblique views preserve the correct shadow boundary.

- When the apex is in the rectangle, all 4 signed edge tests are positive
  and the function returns no shadow. It also returns no shadow when all 4
  tests are 0 or negative. There is no `epsilon` for a position on an edge.
  A zero result is in the nonpositive group.

- Terrain shadows do not touch the entity plane.

### Verification

- See `game/tests/test_terrain_light_shadows.py`.

### Implementation

- The code traverses the 4 corners of the rectangle in a fixed winding order. The
  code sets each edge to lit or dim, with the turn sign against the
  apex. The code uses `cross_product > 0` with no `epsilon`.
  A zero result sets the edge to dim.

- All lit or all dim returns `None` because there is no clear dim side. A
  position in the rectangle sets all edges to lit. Thus a filled rectangle
  around the light has no shadow.

- If a corner is `1e-9` world units or less from the apex, projection returns
  that corner. Other positions use a floating-point compare and can change
  side at the zero boundary.

- The dim edge run identifies the dim side. Its 2 end corners extend from
  the apex to the `reach` distance, and the shadow polygon closes
  through the 2 far points.

- `terrain_shadow_polys(sim, polygon, apex, reach)` applies this to
  each terrain rectangle of the polygon. A terrain query error
  returns the empty result.

### Caveats

- A light in a terrain rectangle has no shadow from that rectangle. This
  incorrect position applies the condition above with no warning at the
  call `site`.

## Unit 32 — The light level query

### Goal

The `lurk` AI reads the light level at a point. The query sums lights from
the tick's lookup table. It uses the same falloff formula as the rendered
frame.

### Invariants

- The caller calculates the lookup table once each tick, not once each query.

- A point in the terrain shadow of a light receives zero from that light.

- The result clamps to 0..1.

### Verification

- Test a point directly below a `lamp`, a point inside its terrain shadow, and
  a point beyond its radius. Check that the first is lit and the latter 2 are
  dark.

### Implementation

- `light_level_at(light_map, lights, polygon, x, y)`: for each light
  instance in the polygon, the linear falloff is
  `1 - distance / max(1e-6, radius)`, with a clamp.

- The function does not test the point against `LightInstance.clip_local`.
  The point's polygon in the lookup is its only visibility gate before
  cone, radius, and terrain-shadow checks.

- A cone gates the point. Let `half = LightSpec.arc / 2` and
  `feather = max(0.05, half * 0.35)` radians. The cone factor is 1 through
  `half`, decreases linearly to 0 across the next `feather`, and is 0 after
  `half + feather`. A `LightSpec.arc` value at or below 0 bypasses this cone
  gate. No direction or a point `1e-6` world units or less from the apex
  also bypasses it.

- The added quantity is the falloff squared, times the light
  intensity.
  The sum clamps to 0..1.

### Caveats

- Defect: the query ignores the lit wedge in `clip_local`. It can report
  light at a point in the same polygon but not in the region shown from
  that light. The renderer clips light to the wedge. Thus the query does
  not obey the goal that the query and renderer agree.

- The query does not multiply by the renderer constant `LIGHT_STRENGTH`
  (3.0). AI light levels and rendered brightness thus use different scales.

- The brightness at the query cone edge decreases gradually. The painted cone edge is a hard clip
  (unit 14). The 2 do not agree in the band.

## Unit 33 — The lighting system

### Goal

One object for each session holds the world-light list and wedge caches.
`add_lights` calculates static-light wedges once. Those wedges stay correct
only while the portal graph does not change. Attached lights calculate for
each displayed frame and use a geometry-key cache. The renderer reads one
table of static and attached instances for each frame.

### Invariants

- The system does not calculate a static light's wedges again after
  `add_lights`.

- An attached light with intensity 0 costs zero: no visibility step
  runs for it. The pools for muzzle lights and other effect lights are at 0 almost always.
  This gate keeps the cost of a pool of short sim lights low.

- The attached cache key holds all step inputs other than the world graph.
  It holds the polygon, position, radius, direction, and `arc`. Color and intensity stay out, because they do not change
  geometry.

- A light does not use the cache if it touches a polygon that the
  `soft-body` simulation changes. Those vertices move each tick without a
  graph event. If the system uses a cached wedge, it could thus put a shown
  lit boundary column at an incorrect position.

- A graph change (a door, a breach, a `carve`) empties the attached
  cache. The next `frame_lookup` assembles attached wedges again. Static wedges
  do not update.

### Verification

- See `game/tests/test_lighting_invariants.py` for the static cache
  check.

- Open a door near an attached light and check that its light goes through
  on the next frame.

### Implementation

- `add_lights(sim, lights)` extends the list and calculates wedges for
  each `static` light into the table for each polygon.

- `attached_lights()` selects the `attached` type with intensity above
  0.

- `frame_lookup(sim, soft_polygons)`: on each renderer `draw`, copy the static
  table. For each live attached light, first get the cached wedges. Do not use
  them if the `soft-body` simulation changes the light polygon or a wedge
  polygon. If there is no good cache entry, calculate with a limit of 24
  instances. Cache the result only when none of these polygons is touched.

- Above 256 cache entries, the complete cache
  empties. The movement of a light causes a new key each frame, and a full
  clear has a small cost.

- `on_topology_changed()` empties the attached cache only.

- `cache_count()` reports the static wedge count.

### Caveats

- Defect: static wedges keep the world graph from the `add_lights` call. A
  door that opens after that does not let static light go through. A breach
  and a `carve` do not update those wedges. Static world lights thus do not
  follow visibility changes in the topology.

- Decision open (see `spec/open-questions.md`, item `RENDER-STATIC-LIGHTS`):
  the implementation updates attached lights but not static
  lights after a topology change. This file records the difference. It does
  not select if static lights must update. If an update is necessary, also
  select when the image shows the update. It can occur in the topology
  change call, at the next light lookup, or after another `add_lights` call.

- The renderer multiplies each light by 3 at paint time. The wedge
  geometry here does not include `LIGHT_STRENGTH`.

## Unit 34 — The 2D frame library (`fb2d.py`)

### Goal

The menu and scene layer renders onto NumPy frames. It keeps the `patterns`
previously used with `pygame.draw`: opaque frames, RGBA overlays, alpha
fills, copies, and the primitive set.

### Invariants

- The axis sequence is `buf[x, y]`, the `pygame` surface array
  sequence, for each function in the module.

- On an opaque `(W, H, 3)` frame, primitives write solid color. The
  alpha of an RGBA color has no effect — as `pygame.draw` on a surface
  with no alpha.

- On a `(W, H, 4)` overlay, primitives write raw RGBA with no mix —
  as `pygame.draw` on an alpha surface. Only `blit` mixes.

- The mix division is correct with no error. `_div255` equals a floor
  division by 255 for each `uint16` input from 0 through 65279.

- All writes clamp to the buffer. Geometry out of the buffer cuts, it
  does not raise.

### Verification

- See `game/tests/test_ui_pygame_free.py`.

- Fill an area 2 times at alpha 128 and check that the result agrees with
  the `pygame` overlay `pattern`.

### Implementation

- `Rect`: `int` values `x, y, w, h`, edge and center read properties,
  and `inflate`. Each primitive accepts a `Rect` where it accepts a
  4-item rectangle.

- `overlay(w, h)` returns a zero RGBA work image.

- `fill` writes a solid color into a rectangle or the complete buffer.

- `alpha_fill` mixes a color at an alpha into an opaque frame. Alpha
  255 becomes a solid fill. For smaller alpha, each result channel is
  `floor((source * alpha + destination * (255 - alpha) + 127) / 255)`.

- `blit(fb, src, x, y, alpha)`: an RGB source copies (or mixes at the
  global alpha). An RGBA source mixes for each pixel, times the global
  alpha. With an overlay that is all alpha 0, the function returns and does
  no work.

- Global alpha and each source alpha clamp to 0..255. For an RGBA source,
  global alpha first changes the source alpha to
  `floor((source_alpha * global_alpha + 127) / 255)`. The RGB mix then uses
  the same rounded division as `alpha_fill`. All middle mix arrays use
  `uint16`. The stated maximum input to `_div255` prevents overflow.

- `rect` with a width paints 4 edge bands. The width clamps to 0.5 of each
  dimension, rounded up. On a dimension that is not divisible by 2,
  opposite bands can use the same center row or column.

- `line` is the standard step line walk on `int` pixels. A width above
  1 paints offset copies of the line, centered. When `dx >= dy`, the
  copies move in `y`. Otherwise, they move in `x`. Straight lines go
  through the band fill path.

- `circle` fills a disc, or a circle area for an outline width, from a
  squared distance mask. `ellipse` fills from a scaled distance mask,
  with an inner cut for an outline width.

- `arc` samples an ellipse curve at `int` pixels, one step for each width
  step. Angles use radians. Angle 0 is the right side. As an angle increases,
  its point moves up, left, and then down. When the end angle is below the
  start angle, the function adds `2 * pi` to the end once.

- Equal angles paint one sampled point. A difference of `2 * pi` paints one full ellipse.
  Larger differences paint the requested more turns.

- `polygon` fills row by row. It finds the points where the edges cut the
  row, sorts them, and fills between each pair. With a width it
  strokes the closed path.

### Caveats

- `circle` with an outline width and a radius below 1 paints zero
  pixels. A filled circle with a radius below 1 sets the radius to
  1.

- This module and unit 5 each have a `Rect` type with the same primary
  fields. Only the renderer `Rect` can set its center, while only this
  module's type has `inflate`.

## Unit 35 — Texture geometry convention (`texture_geom.py`)

### Goal

The renderer and offline texture tools must agree on each floor texture's
dimensions, origin, and path. They do not import each other. The two
import this `dependency-free` module for the Python-side convention. The
Rust rasterizer keeps sample `density` in a different constant, as the caveat
records.

### Invariants

- The texel requirement: texel `(tx, ty)` is at the local point
  `bbox_min + (tx + 0.5, ty + 0.5) / DENSITY`. Rows increase with
  local `y`, which agrees with image row sequence and with the engine
  `y` down convention.

- Python-side texture geometry uses `DENSITY = 3` pixels for each world unit,
  set by the measured projection in `ARTSTYLE_DIRECTION.md`.

- Texture dimensions always include the bounding box. Each dimension is `max(1, ceil(value))` pixels.

### Verification

- See `game/tests/test_walk_mask_terrain.py` and
  `game/tests/test_render_textures.py`.

### Implementation

- `polygon_bbox(verts)` returns the local bbox corners.

- `texture_size_for_polygon(verts)` returns the bbox dimension times
  `DENSITY`, rounded up for each side.

- `texture_path(dir, level_id, index)` returns
  `<dir>/<level_id>/polygon_<index>.png`.

### Caveats

- The walk mask loader in `terrain.py` reads the same requirement at a larger
  cell dimension.

- The renderer does not call `texture_size_for_polygon` and does not check
  the dimensions of a texture file. It `uploads` and samples each RGB image at
  the specified path. The `generation` tool must obey the convention.

- Defect: the Rust rasterizer has a different `TEX_DENSITY = 3.0` constant.
  No build-time or run-time check compares it with `texture_geom.DENSITY`.
  If only one changes, the sampler and Python `generation` tools use
  different `density` values.

## Unit 36 — The `grip` module (`capture.py`)

### Goal

The recording module knows no `PERIHELION` objects. It has a `grip` record with 2
entity ids, a pull speed, a burn rate, and a release condition. The `warden`
`engulf` is its first user, but the module has no `warden` or player code.
Damage flows through one callback supplied by the session. This callback
forms the agreed boundary between player and `warden` code.

### Invariants

- One `captor` for each `captive`. A second `begin` call while held
  returns `False` and changes no state.

- The module does not touch HP. The burn callback is the one damage
  door of the session.

- If the `captor` or `captive` is no longer in the world, the same `step`
  call releases the `grip`. It does this before it applies movement or burn.

- A `grip` can extend across a doorway. The pull direction comes from the
  transformed `captor` position in the space of the `captive`. When the
  world finds no route between them, the `grip` ends. This correctly shows
  a `captor` that is not near.

- The `forced_target` result is a query. The module hooks no weapon code.

### Verification

- See `game/tests/test_warden_engulf.py` and
  `game/tests/test_grip_across_a_doorway.py`.

### Implementation

- `CaptureSpec` is a frozen record. It holds the `captor` id, the
  `captive` id, and the pull speed in world units each second. It
  also holds the `damage_per_second` value, and a `redirect_fire` flag
  with the default `True`.

- `begin(spec)` returns `False` for a `captive` that a `grip` holds. Otherwise,
  it records the input `CaptureSpec`.

- `held_by(captive_id)` returns the `captor` id or `None`.

- `forced_target(entity_id)` returns the `captor` id when the entity is
  held and its `CaptureSpec` sets `redirect_fire`, or `None`.

- `release_for_entity(entity_id)` drops each `grip` that the entity is
  in, on each side.

- For each `grip`, `step(world, burn)` releases it when an entity is gone or
  the `develop` query finds no route. Otherwise, it sets the `captive` velocity
  to the transformed `captor` position at the specified pull speed. It then
  calls `burn(captive, captor, damage_per_second)`.

- `step` uses a list snapshot of the `captive-to-grip` table in dictionary
  entry sequence. A removed `grip` receives no burn during that call. An
  external callback can change a subsequent `grip`, but the snapshot sets
  which entries the call processes.

### Caveats

- `step` calls the burn callback once each tick and supplies a rate for each
  second. The callback must multiply that rate by the tick duration.

- While the `grip` holds, `step` replaces the complete `captive` movement
  each tick. Player input does not move the `captive`.
