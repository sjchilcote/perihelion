# PERIHELION — Engine & Game Architecture

Working title: **PERIHELION** — a Teleglitch-like survival shooter aboard a station
falling into the sun, set in a non-Euclidean graph of polygons. This document defines
the from-scratch rewrite: a Rust engine core (`necore`) that owns everything that
never changes — the geometry, the simulation, the invariants — and a Python game
layer that owns everything artistic: mechanics, scripting, rendering style, juice,
content. `design_document_2.md` §11 is the constitution; this document is the law.

## 0. Prime directives

1. Every §11 invariant of `design_document_2.md` holds. No world space. Convex CCW
   polygons. Transforms are arbitrary invertible affine maps. `t → 1−t` at every edge
   crossing. Transitions are imperceptible.
2. **AI-testability is a first-class requirement.** The sim is deterministic and
   headless-runnable; every feature must answer "how do I test this with no human?"
   before it is built. That includes *fun*: the harness exposes metrics and captures
   screenshots/GIFs/audio for LLM judging.
3. The Rust core is verified by property tests, including an *oracle test*: a
   planar-embeddable level simulated both as a polygon graph and as flat Euclidean
   geometry must agree exactly.

## 1. Repository layout

```
engine/                 Rust workspace
  necore/               pure Rust: math + sim + visibility (no PyO3, proptest suite)
  necore-py/            PyO3 cdylib (maturin), thin binding layer
game/                   uv project, package `perihelion`
  perihelion/
    app.py              window, fixed-timestep loop, scene stack
    render.py           immediate-mode renderer from necore draw lists
    sim.py              GameSession: engine world + Python entity scripting
    entities/           player, enemy archetypes, projectiles, pickups, props
    weapons.py          weapon definitions (data-driven)
    juice.py            screenshake, hitstop, particles, decals, flashes
    audio.py            mixer, sound bank, graph-propagated positional audio
    narrative.py        Ratio radio lines, terminals, level intro cards
    hud.py, menus.py
    levels.py           level loading (JSON v2), campaign manifest
    editor/             level editor (same renderer, same engine)
    testkit/            headless session, replay, bot policies, metrics, capture
tools/
  soundgen/             numpy SFX/music synthesis → game/assets/sfx/*.wav
  playtest/             LLM/Gemini judge harnesses
levels/                 campaign JSON + lore text
```

## 2. The engine core (`necore`, Rust)

f64 everywhere. No RNG in the engine. No I/O. Pure state machine:
`World` + inputs → `step()` → state + events. Everything queryable.

### 2.1 Types

- `Vec2`, `Mat3` (row-major homogeneous 3×3; full inverse; `apply_point`,
  `apply_dir` = linear part only). Transform composition is the only way
  coordinates ever relate across polygons.
- `Polygon { verts: Vec<Vec2> /* CCW, centroid at origin */, edges: Vec<Option<Portal>> }`
- `Portal { target_polygon, target_edge, xform: Mat3 /* target-polygon coords → this-polygon coords */ }`
- `Entity { polygon, pos, vel, dir, radius, mass, restitution_entity, restitution_wall,
  group: u8, max_substep, alive }` — circle collider for entity-entity; the polygon
  *sprite* is a Python-side artistic concern. Group×group collision mask is a
  16×16 bit matrix set from Python (player, enemy, pbullet, ebullet, pickup, prop…).
- `restitution_wall = 0` → slide (kill normal component; Teleglitch handling),
  `1` → elastic bounce; anything between works.

### 2.2 World construction

- `add_polygon(verts) -> PolygonId` — verts are re-centered on centroid, validated convex
  CCW (auto-rewound if CW; rejected if concave).
- `connect(a, edge_a, b, edge_b)` — computes the rigid transform aligning edge_b of
  polygon b flush against edge_a of polygon a (rotate 180° across the shared edge,
  translate midpoints together), stores mutually inverse transforms on both edges.
  Handles self-connections (a==b, even edge_a==edge_b: the mirror).
- `connect_with_xform(a, edge_a, b, edge_b, m)` — arbitrary invertible affine
  (scaling corridors, chirality flips) for the late game. Nothing in the engine may
  assume rigid motion.
- Edge lengths need not match: the transform maps edge_b's span onto edge_a's span
  (scale along the edge is allowed on `connect` only when lengths differ ≤ tolerance;
  otherwise use `connect_with_xform` deliberately).

### 2.3 Visibility (the renderer's brain)

`visible_set(camera_polygon, cam: Mat3 /*polygon→screen*/, screen_w, h, max_depth, max_instances) -> Vec<DrawInstance>`

Iterative portal traversal from the camera polygon. A frustum through a portal is
represented as **three half-planes**: the portal line itself plus the two rays from
the apex through the visible segment's endpoints. This stays exact and
well-conditioned at any view angle — there is no "promotion" hack; skating along an
edge evolves smoothly by construction. The visible region of a polygon instance is the
convex polygon `polygon ∩ frustum` via Sutherland–Hodgman. Recursion: for every other
portal edge of the polygon, intersect it with the current frustum (parametric segment,
**flip t → 1−t crossing over**), transform apex + segment into the child's space,
recurse. Terminate on: depth, instance cap, visible-segment length < ε, clipped
polygon screen-bbox off-screen or area < ~2px². Dedup key: (polygon,
quantized-6-float-xform, quantized-segment) — the same polygon seen via *different*
paths at different places must all render; identical repeats must not.

`DrawInstance { polygon, xform /*polygon→screen*/, clip_local: Vec<Vec2>,
clip_screen: Vec<Vec2>, depth, entities: Vec<(EntityId, screen_pos, screen_dir, fully_inside)> }`

Returned deepest-first (painter's order). The engine also exposes
`clip_polygon(subject, clip)` and `clip_polyline(pts, clip)` so the Python renderer
can clip polygon detail geometry and boundary-straddling sprites exactly, with zero
mask surfaces.

### 2.4 Simulation

`step(dt) -> Vec<Event>` — fixed dt (1/60). Substepped per entity
(`max_substep` distance, e.g. bullets use their radius). Hard-won robustness rules
from the prototype, now law:

- Wall test = signed distance vs CCW edge normals (convexity ⇒ interior is the
  half-plane intersection). Edge spans extended slightly past endpoints so vertex
  seams can't leak (safe by convexity).
- Portal transfer only when velocity points out through the edge
  (dot(vel, normal) > ε) — kills boundary ping-pong. Position maps through the
  portal's inverse, vel/dir through its linear part; epsilon nudge (1e-3 units,
  a *real* epsilon) into the new interior.
- After any collision resolution the remainder of the substep re-runs the **full**
  pipeline; time refunds use computed collision time. Iteration cap with
  velocity-zeroing fallback (never tunnel, never hang).
- Entity-entity: circle-circle, group-mask filtered, impulse response with mass +
  restitution. Polygon-local only (polygons are large relative to entities; the nudge
  keeps membership decisive). Broad phase: per-polygon lists (the polygon *is* the
  spatial index).
- Events: `Transfer{ent, from, to, edge, xform}`, `WallHit{ent, polygon, edge, point,
  normal, speed}`, `Contact{a, b, point, normal, rel_speed}` — Python turns these
  into damage, sound, particles, camera rebasing. The engine never decides what a
  collision *means*.

### 2.4a Walk-mask terrain (director's directive, 2026-07-13)

Per-polygon painted terrain (equipment, troughs, machinery) that physically
blocks movement and shots but never occludes vision — the art pipeline
generates it as a texture-aligned mask, the engine turns it into collision.

**Format.** `Polygon::terrain: Vec<geom::Rect>` — a small set of axis-aligned
rects in the polygon's OWN local coordinates, the identical frame
`Polygon::verts` and the floor texture live in (`texture_geom.py`'s texel
law: texel `(tx,ty)` ↔ `bbox_min + (tx,ty)/DENSITY`). No world space, same
as everything else in the engine: a rect is meaningless outside its polygon.
`World::set_polygon_terrain(polygon, rects)` installs it wholesale (replace, not
merge); an empty/never-called polygon has `terrain == []`, which means fully
walkable — terrain is never fabricated.

**Loading.** `game/perihelion/terrain.py` decodes
`<textures_dir>/<level_id>/polygon_<i>_walkmask.png` (white = walkable,
black = terrain; same directory and naming pattern as the floor texture
`polygon_<i>.png`, same size/mapping — a size mismatch is a loud error, not a
silent stretch), downsamples texels into coarse cells (`DOWNSAMPLE = 4`,
majority-vote per cell), and greedily merges blocked cells into rects. It
is deliberately dependency-free (stdlib `zlib`/`struct` PNG decode, no
pygame) so `sim.py` — which states its own contract as "Pure python +
necore, no pygame" — can call it directly: `GameSession.__init__` and
`append_chunk` both call `terrain.apply_walk_masks(sim, level, offset)`
right after their `add_polygon` loop, so the collision data flows straight
into the engine, never through the renderer. Absence of a walk-mask file
is the common case and costs one `Path.is_file()` check.

**Movement/projectile collision.** `Sim::step_entity` folds terrain into
the exact same "earliest blocking obstacle this substep" resolution as
polygon walls (`physics.rs`): a swept-circle-vs-rect test
(`geom::swept_circle_vs_rect`, a Minkowski-sum-by-radius slab test,
conservative at corners so it never tunnels) picks whichever of {nearest
wall, nearest terrain rect} the entity would hit first, and the response
(project out the normal component, scaled by `rest_wall` — 0 slides, 1
bounces) is identical either way, so terrain reads as "wall-like"
throughout: slide, don't stick, don't tunnel at any speed. Projectiles are
entities like any other, so they are blocked by terrain automatically —
terrain is opaque solid equipment, it blocks light, so it blocks shots —
gated by a per-group bitmask (`Sim::terrain_blocks`/`set_terrain_block`,
every group blocked by default) for the rare entity that should be exempt.
A defense-in-depth pass (`push_out_of_terrain`, mirroring
`contain_in_polygon`) corrects any entity whose center ends a tick embedded
in terrain anyway (a portal transfer landing there, a mask hot-loaded
under a standee).

**Root-frame invariance.** Terrain lives entirely in polygon-local state
(`Polygon::terrain`, keyed by `PolygonId`) and `step_entity` only ever reads the
entity's *current* polygon and its own local fields — there is no "root",
accumulated transform, or path-history concept anywhere in `Sim`/`World`
for it to depend on. Re-rooting (which polygon the game's camera-transform
chain currently anchors at, ENGINE_DESIGN.md invariant #8) is therefore
automatically inert to collision outcomes; `properties::
terrain_collision_after_portal_crossing_matches_native_local_simulation`
proves this empirically (reach the same polygon-local state two different
ways — natively vs. via an arbitrary-transform portal crossing — and the
subsequent terrain-collision trajectory is identical).

**Bot routing.** `Router` still only routes at POLYGON granularity (the
portal graph); it does not know about in-polygon terrain and does not need
to. What it does need is a caller that doesn't grind against an obstacle
forever: physics-level sliding alone resolves a *glancing* approach (any
nonzero tangential velocity carries the entity around a corner, same as a
wall) but not an exactly *head-on* one — a bot that re-aims straight at a
target directly behind a flat terrain face regenerates zero tangential
velocity every tick and deadlocks (confirmed fail-first; a polygon's convex
boundary never has this problem because there's no "straight through" on
the far side of a wall, but mid-polygon terrain does). `query::
terrain_avoid_dir(polygon, pos, radius, desired, lookahead)` casts the
desired heading, and if it would enter a terrain rect, blends in a
tangential deflection away from whichever side the obstacle's center
leans toward (a deterministic tie-break, no per-tick chatter). `sim.py`'s
`_enemy_ai` calls it for the movement heading on both AI legs (in-polygon
hunting and cross-polygon pursuit toward the next portal), while facing/aim
(`set_dir`, projectile spit direction) keeps using the true un-steered
bearing — a bot sidesteps an obstacle without visibly looking away from
its target.

**Light-occlusion INTERFACE (not yet consumed).** Terrain is meant to
block lamp/world light — including the player's own worklight — the same
way a wall does, while leaving vision/visibility completely alone
(enemies behind terrain stay visible as sensor traces; entities already
render on the sensor plane, unaffected by the lightmap, and this feature
does not touch `visibility.rs`/`EDGE_BAND`/frustum code at all).
`query::terrain_light_segments(world, polygon)` / `Sim.terrain_light_segments`
exposes each terrain rect's four edges as polygon-local segments — the same
shape a wall segment takes — so a future lighting pass can treat them as
occluders exactly like walls when building a light's visible wedge (see
§3.2a for how `lighting.py` already builds wedges via a second
`visible_set` pass from the light's own apex). **This function is
additive and currently unused**: `render.py`'s lighting composite is
owned by an in-flight sibling fix (the ghost-line seam hunt) per explicit
scope fence, so integrating occlusion into `_build_lightmap`/the rust
`Raster` compose path is deliberately left for that lane to pick up.

### 2.5 Queries

- `raycast(polygon, origin, dir, max_hops, max_len)` — walks portals (transforming ray
  at each crossing), returns wall hit or entity hit with the accumulated transform.
  Line-of-sight for AI, hitscan weapons, audio occlusion.
- `route_next_edge(from_polygon, to_polygon)` — Dijkstra over the polygon graph, cached per
  destination, invalidated on topology change. Path state is polygon/edge sequences,
  never positions.
- `hop_distance(a, b)`, `polygons_within(polygon, hops)` — activity horizon + audio
  attenuation.
- `rebase(cam, portal_xform)` — the camera composition for seamless transfer.

### 2.6 Property tests (proptest, in `necore`)

1. `connect` invariants: paired transforms mutually inverse (‖M·M⁻¹−I‖ < 1e-9);
   mapped edge endpoints coincide with orientation flip.
2. Transfer roundtrip: cross an edge and come back ⇒ pos/vel restored (< 1e-6).
3. Visibility: every clip polygon is convex, ⊆ polygon, ⊆ frustum half-planes;
   deeper instance's portal segment ⊆ parent's clip.
4. Containment: after arbitrary force sequences, every entity is inside its polygon
   polygon (+ε). *The* anti-tunneling invariant.
5. Energy: collisions with restitution ≤ 1 never increase total kinetic energy.
6. **Euclidean oracle**: generate a random planar level (grid polygons glued
   Euclideanly), simulate/raycast/render both as polygon-graph and as flat geometry;
   positions, hits, and visible polygons must agree to 1e-6. This single test
   validates traversal, transforms, transfer, and visibility together.
7. t-flip: parametric quantities crossing any edge obey t → 1−t (checked via
   marked points on glued edges).
8. **Root-frame invariance**: which polygon `session.player_polygon()` currently
   names as root (the portal-chain anchor camera transforms compose from)
   is pure bookkeeping and must have zero pixel consequence. For a fixed
   world state and camera pose expressible in two adjacent polygons' local
   frames (a point in/near an open doorway span), rendering with root=A at
   local pose p is byte-identical (within float-rounding tolerance) to
   rendering with root=B at portal_xform(p) — across floors (flat and
   bespoke-textured), wall strokes, detail prims, decals, entities, and
   the darkness field. Re-rooting must never pop a polygon's appearance the
   instant the player crosses its threshold. This parallels the no-seams
   visibility invariant (#3) one level up: #3 says two simultaneously
   visible instances of the same geometry must not show a seam between
   them; this says two sequential *root choices* for the same instance
   must not show a seam in time. Game-layer regression coverage:
   `game/tests/test_root_invariance.py`.

## 3. The game layer (Python, pygame-ce)

### 3.1 Loop & determinism

Fixed 60 Hz sim tick, render decoupled (interpolation unnecessary at lo-fi).
`GameSession(level, seed)` is pure: `tick(InputFrame)` → state; pygame only in
`app.py`/`render.py`. `InputFrame {keys bitfield, mouse_pos, buttons}` — recorded
per tick into replays; `seed` drives one `random.Random`. Same level+seed+inputs ⇒
bit-identical run. This is the AI-testability keystone.

### 3.2 Rendering (immediate-mode, lo-fi)

Internal resolution **480×270** (`PERIHELION_INTERNAL_RES` can override; current
build default is 640×360), integer-scaled to window with nearest neighbor —
chunky Teleglitch grit and a hard perf ceiling. Per DrawInstance, back-to-front:
floor = flat dark polygon (`clip_screen`) + polygon detail primitives (static
per-polygon grime: lines, plates, stains in local coords) clipped via engine and
drawn as vector strokes; walls = thick bright segments on the visible span;
world illumination is the lightmap (see 3.2a) — **zero ambient**, no
screen-space darkness field; entities as rotated polygon sprites (engine-
clipped when straddling a portal), composited ON TOP of the lightmap multiply,
unaffected by it (3.2a). The same entity legitimately renders in several
instances at once — that's the game. Post: vignette, scanline flicker on
damage, screenshake applied to the final blit offset. No per-frame surface
allocation anywhere.

### 3.2a Lighting

**Zero ambient (the director's order, 2026-07-11):** the world layer's ONLY
illumination is the lightmap described below. There is no screen-space
darkness field, warm or otherwise — the earlier player-centered radial
vignette (`_apply_darkness`'s `0.72*max(w,h)` falloff) is gone, along with the
"additive glow on top of an already-lit scene" compositing it implied. A
world-layer pixel no enabled light reaches renders BLACK. Unless a level
places a specific fixture, the frame's own attached work lamp is the only
light that always exists (`sim.py`'s `player_light`, intensity 0.95/radius 85,
tuned as the SOLE source rather than an addition on top of ambient).
Otherworld polygons keep their pre-existing, unrelated identity (the floor IS the
light source, self-luminous, sculpted by an inverted cold-distance field) —
untouched by this order.

Lights are real world objects, not a screen-space glow: a level's `lights` list
(`LightSpec` — polygon, local pos, color, intensity, radius, kind `static`|
`attached`) is authored the same way as entities/terminals. Illumination is
literally the engine's own visibility pass run a second time, from the light's
apex instead of the camera's: `perihelion.lighting.compute_light_instances`
calls `necore.visible_set(light.polygon, cam, light.pos, ...)` and recovers each
reached polygon's own local lit polygon plus the light's virtual local position
there by inverting the returned transform — no engine (Rust) changes were
needed, `visible_set` already returns everything required. Shadow is simply
absence of wedge, and since the lightmap is black by default, absence of
wedge IS absence of illumination.

Static lights (fixed geometry + fixed position) are cached once at level load,
keyed **per polygon**, not per portal-chain: because a polygon's own local geometry
is chain-independent (ENGINE_INVARIANTS R1, root-frame invariance), a cached
wedge computed from the light's own visibility pass is valid for ANY camera
instance of that polygon forever — the "per-polygon caching, exact rather than
approximate" case the design allows for when chain-relative keying is
intractable. `attached` lights (the player's own light) recompute every frame.

Per frame, `render.py:_build_lightmap` accumulates EVERY source of
illumination — static/attached world lights (`_draw_world_lights`, which looks
up each visible camera instance's polygon in the lighting system, transforms the
cached local wedge to screen space via that instance's own transform, gates it
against the camera's own visible-region polygon via `necore.clip_polygon`, and
additively blits a polygon-clipped radial falloff — `a = clamp(1 - dist/
radius, 0, 1); a*a`, the same smooth-to-zero kernel `OP_GLOW`/`_bake_glows`
already use), plus this frame's dynamic point lights (muzzle flashes, bolts,
lit screens/terminals) — into ONE black-by-default lightmap surface. `draw()`
then multiplies the drawn world layer by that lightmap instead of adding
glows on top of an already-lit scene: the lightmap literally IS the world's
illumination, shaped by real occlusion instead of a fixed-radius disc. The
entity plane (enemies/pickups/player/effects — "stylized sensor traces": the
frame SEES them by sensor, not by light, per TESTATOR_DESIGN_LANGUAGE) is
composited AFTER that multiply, unaffected by it, so it stays visible in the
dark; pickups get the same treatment as enemies (a salvage signature reads on
the same sensor overlay a hostile does).

The rust backend does the equivalent multiply natively: `necore.Raster`
exposes `set_lightmap` (an RGB byte buffer, same shape `_build_lightmap`
produces), and `compose()`'s fixed order runs the lightmap multiply on the
WORLD plane BEFORE the entity coverage fold — reordered from the pre-zero-
ambient code, which folded entities in first and would otherwise darken them
along with the floor. Because compositing still happens on the already-
assembled pixel surface (Python builds the lightmap once per frame for both
backends), no additional parity surface is introduced beyond that reorder.

**One-bounce light (future work, design only):** a cheap approximation of
indirect/bounce light is to treat each STATIC light's own cached lit wall
segments as secondary emitters: for every wall edge a static light's wedge
directly illuminates, cache a low-intensity "bounce light" whose apex sits on
that segment (offset slightly off the wall along its inward normal), color
tinted toward the floor/wall material, intensity a fixed fraction (~8–15%) of
the incident light's own falloff at that point, and radius scaled down
sharply (a bounce shouldn't reach as far as its source). Because this is
computed from data the static cache already holds (the lit wall spans),
it is itself cacheable at level-load time with zero extra runtime visibility
queries beyond the one pass needed to build each new bounce emitter's own
wedge — the cost is proportional to (lit wall segments) not (frames), so it
stays within the existing static budget. This is flagged as future work, not
implemented in this pass: it roughly doubles the static cache's visibility-
query count and needs its own falloff/color tuning pass to avoid muddying the
handcrafted palette work, and was out of scope for the lighting rewrite itself.

### 3.3 Combat (Teleglitch DNA)

WASD screen-relative (via inverse camera rotation), mouse aim, force+friction
movement. Weapons data-driven: knife (infinite, desperate), pistol, SMG, shotgun,
rivet rail, **lightning cannon** (signature AOE, long cooldown, graph-propagating
flash). Ammo scarce; every corpse and crate matters. Enemies: husk (rusher), mite
(fast swarm), spitter (ranged arc), brute (tank, door-breaker feel), shrieker
(summons through portals — the non-Euclidean enemy), warden (endgame). HP low,
death fast, checkpoints at level start.

### 3.4 Juice (from Vlambeer/Nuclear Throne canon, tuned darker)

Screenshake (magnitude-clamped, decaying), 40–60 ms hitstop on kills, muzzle flash
that briefly lights the floor polygon, tracers, casings, blood decals that
**persist in polygon-local space** (so you recognize a polygon you've "never" visited),
corpse persistence for the same reason, damage flash + heartbeat vignette at low
HP, kill-confirm sound layering. Horror pacing: silence is the default; sound is
information (enemies audible through portals with hop attenuation before visible).

### 3.5 Audio

Procedurally synthesized bank (tools/soundgen, numpy → wav): layered gunshots,
impacts, deaths, pickups, Ratio radio blips, drone beds per level tier. Positional:
pan/volume from portal-chain transform when audible instance is visible, hop-count
attenuation otherwise. Every generated sound is judged by Gemini (johnny/
autoclipping recipe) against a description of intent before acceptance.

### 3.6 Narrative delivery

Ratio radio lines (typewriter text, bottom bar) triggered by level events;
terminal props with lore pages; level intro cards. Arc: mundane maintenance sweep →
creeping wrongness → the Connection revealed → Guard-ending stinger. The game never
says "non-Euclidean"; Ratio's growing unease says it for us.

### 3.7 Levels (format v2)

JSON: `{name, tier, polygons: [{id, verts, edges: {idx: {polygon, edge} | {polygon, edge,
xform}}, entities: [{type, pos, props}], detail_seed}], lights: [{polygon, pos,
color, intensity, radius, kind}], player_spawn, lore, music}`. Campaign
manifest orders levels along the §8.1 escalation curve. Authored
via `perihelion.editor` + generator helpers (corridor, loop, Möbius pair, mirror
polygon, hypercube, Cayley graph, de Bruijn).

## 4. Testing & the playtest loop

- **Rust**: cargo test + proptest (§2.6) on every engine change.
- **Python unit/integration**: pytest, headless (`SDL_VIDEODRIVER=dummy`);
  screenshot goldens for named scenarios (dip_test heritage); perf scenarios with
  p50/p90/max budgets (perf_test heritage), CI-style script `./check.sh`.
- **Bot playtests**: policies (rusher, camper, explorer, pacifist) drive
  `GameSession` via InputFrames; metrics per run: survival time, damage taken/dealt,
  ammo pressure (fraction of time < 1 mag), near-misses, backtracks, portal
  crossings, fps. Every level must be *completable by the aggressive bot* and
  *lethal to the pacifist*.
- **LLM judge**: capture GIFs/screenshot strips of bot runs → judge for
  readability, juice, horror mood, "would a Teleglitch fan grin"; Gemini judges the
  audio bank. Findings feed tuning until convergence.

## 5. Performance budget

60 fps floor on this machine: `visible_set` < 2 ms at 40 instances; python draw
< 8 ms at 480×270; step < 2 ms at 100 live entities. Measured, not vibed —
`tools/playtest/perf.py` runs the worst-case scenes (hub center, mirror polygon,
infinite corridor) every session.

## 6. Addenda (built during the rewrite day)

- **Runtime wall-splitting** (`split_edge`): inserts collinear vertices into
  a solid wall at parametric (t0, t1), remapping every portal in the world
  that references shifted edges. This is the portable hole's substrate:
  dynamic graph modification as a player verb. Same-polygon double splits
  cross-shift each other's indices — sim.py handles the bookkeeping.
- **Fit rule**: portal transfer requires 2*radius <= opening * 1.05. Player-
  width hole corridors exclude brutes by physics, not by AI special cases;
  mites leak through, which is a feature.
- **Tau cannon**: bouncing rounds via rest_wall=1.0 engine reflection with a
  Python-side bounce budget; hold-to-charge on alt with overcharge bite.
- **Boss tethering**: `tether` entity prop — arena guardians never pursue
  beyond their polygon. Chosen engagements, no cross-map warden rushes.
- **alert_hops** per level: gunshot alert radius in polygon-hops (default 2);
  dense graphs (the Fold, the Core) use 1 — the fold eats sound.
- **Between-sortie conversations**: nine tight-beam exchanges between levels
  (conversations.py), the campaign's relationship arc.
