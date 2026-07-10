# High-pixel (HP) art integration plan

Generated assets live in `game/perihelion/assets-hp/*.png` + `manifest.json`.
This document describes exactly how `game/perihelion/render.py` should
consume them. **No render.py code was changed in this pass** (per brief —
render.py is being modified in parallel); this is a plan for whoever wires
it in next.

## What was generated

13 PNGs, RGBA, true alpha (see "How transparency was produced" below):
`player`, 6 enemies (`enemy_husk`, `enemy_mite`, `enemy_spitter`,
`enemy_brute`, `enemy_shrieker`, `enemy_warden`), `prop_terminal`,
`prop_seed_station` (the `safe_room_core` pickup), `prop_corpse_husk`, and
3 pickup archetypes (`pickup_ammo` covers `ammo_9mm`/`ammo_shell`/
`ammo_cell`, `pickup_medkit`, `pickup_weapon` covers all `weapon_*` kinds).

Each entry in `manifest.json` has:

```json
"enemy_husk": {
  "file": "assets-hp/enemy_husk.png",
  "role": "enemy",
  "sim_kind": "husk",
  "world_radius_units": 8.0,
  "sprite_px_size": [593, 540],
  "sprite_px_radius": 290.0,
  "px_per_world_unit": 36.25,
  "rotation": "continuous",
  "anchor": "center"
}
```

`world_radius_units` is read directly from `ENEMY_STATS[kind]["radius"]` /
`PLAYER_RADIUS` / `PICKUP_STATS[kind]["radius"]` in `sim.py` — the same
number the renderer already receives per-frame as `srad` (screen-space
radius = world radius × current zoom). `sprite_px_radius` is the measured
half-extent (max of bbox width/height ÷ 2) of the sprite's opaque silhouette
in its own source PNG. **The integration formula is:**

```python
scale = srad / manifest_entry["sprite_px_radius"]
draw_w = sprite.get_width() * scale
draw_h = sprite.get_height() * scale
```

This reproduces exactly what the vector path already does — it scales a
fixed reference shape by `srad` — so HP sprites size themselves identically
to the vector shapes they replace at every zoom level, with no new per-asset
tuning constant needed beyond what's in the manifest.

## How transparency was produced (read before regenerating anything)

**Finding, logged here so it isn't rediscovered the hard way:** the
OpenRouter image-gen endpoint (`google/gemini-3.1-flash-image`, same model
`tools/artgen/gen.py` already used) does not support a real alpha channel.
A direct test — prompt asks explicitly for "a transparent background PNG
with real alpha," no other instructions — still returns a plain RGB image
with the model's own painted checkerboard texture standing in for
transparency. `tools/artgen/gen.py`'s old `generate_image()` additionally
made this worse by unconditionally calling `.convert("RGB")` before saving,
which would have discarded a real alpha channel even if one existed.

Fix (now in `tools/artgen/gen.py`, `--chroma-key` flag /
`chroma_key=True` kwarg): prompt for a **flat, solid, pure magenta
(`#FF00FF`) background** instead of "transparent," then key it out in post
with `chroma_key_to_alpha()` (distance-threshold + edge despill + 2px alpha
erosion to kill spill fringing) and `autocrop_alpha()`. This is the
standard green-screen-photography trick and it works reliably — but it is
not perfectly reliable on the *model's* side: twice during this batch
(`enemy_shrieker`, `prop_corpse_husk`) the model ignored the magenta
instruction and painted a dark scene-colored background instead (a purple
vignette, a floor-tile disc), which keyed as *mostly* opaque and would have
shipped a visible rectangle in-game. **The Gemini in-context verifier missed
both** (composited against dark test scenes, the opaque rectangle blended
in well enough to score 0.95) — a real false negative worth knowing about,
not just a caveat. They were only caught by a follow-up programmatic audit
(alpha value at the sprite PNG's own corners/edges, independent of any
scene). **Any future regeneration must re-run that audit, not just the
LLM verifier**, e.g.:

```python
a = np.asarray(Image.open(path).split()[-1])
assert max(a[0,0], a[0,-1], a[-1,0], a[-1,-1]) < 15, "corner not transparent"
```

## Draw-order / canvas integration

Relevant structure in `render.py` today:

- `Renderer._draw_world_pygame` / the rust equivalent draw, per room
  instance: floor → detail → decals → exit/terminals → walls → doors, all
  onto the **world** canvas (already clipped per-instance to that room's
  screen polygon, so no union-mask trick needed there).
- Then `_draw_entities` draws player/enemies/bullets/pickups **whole and
  unclipped** onto a separate **entity** layer, which afterwards gets
  masked by the *union* of every visible room's screen polygon
  (`_cov_mask`, `BLEND_RGBA_MIN`) before being blitted onto `surf`. This is
  the documented "no seams" invariant: a body is only ever cut against
  void, never against something else that would make the cut visible.

HP sprites are raster images with their own bounded alpha silhouette, not
vector fills straddling a clip edge — the seam problem the union-mask
solves mostly doesn't apply to them. Recommended approach, in order of how
much new engine work each needs:

1. **Simplest, recommended first cut:** after the existing world+entity
   passes finish and `surf` is fully composited (end of `Renderer.draw`,
   right before `_draw_post`), do one more pass over `instances` and, for
   each entity/prop that has an HP sprite and is `fully_inside` its room's
   clip polygon, `pygame.transform.rotozoom` + blit it directly onto `surf`
   at `(sx, sy)`, replacing the vector draw for that instance. When
   `fully_inside` is `False` (entity straddles a portal/doorway — the
   `_draw_entities` signature already carries this flag per-entity), fall
   back to the existing vector draw for that one instance. This needs zero
   changes to the `_PygameCanvas` / `_RustCanvas` abstraction or the Rust
   raster wire format — it's a plain pygame blit on the final opaque
   `surf`/`_frame`, which is a real `pygame.Surface` on both backends.
   Tradeoff: an entity that is mid-doorway keeps rendering as a vector
   shape for the 1-2 frames it takes to cross (rare, already the coarsest
   edge case in the current system).
2. **Cleaner but more work:** add a real `OP_SPRITE` command to the
   `necore.Raster` display-list format (`engine/necore/src/raster.rs`) that
   blits a pre-uploaded RGBA texture with per-instance rotation/scale,
   composited through the raster's existing coverage/clip machinery so
   sprites get exact per-pixel clipping instead of the `fully_inside`
   fallback above. Only worth doing once option 1 is shipped and the
   "vector flicker at doorways" tradeoff is actually felt in playtesting.

Either way, the call sites to change/branch on are:

- `_draw_entities` → player case and `_draw_enemy` (per `ekind`) —
  `manifest["player"]` / `manifest["enemy_<kind>"]`.
- `_draw_pickup` — map `kind` through `ammo_9mm|ammo_shell|ammo_cell` →
  `pickup_ammo`, `medkit` → `pickup_medkit`, `weapon_*` → `pickup_weapon`,
  `safe_room_core` → `prop_seed_station`. (`turret`, `implant_lightning`,
  `key_*`, `portable_hole` have no HP sprite yet — keep their vector draw.)
- `_draw_terminal` — `prop_terminal`, see rotation note below.
- `_draw_decal` → the `kind.startswith("corpse_")` branch — only
  `corpse_husk` has an HP sprite today; other `corpse_<kind>` should keep
  falling back to the existing darkened-vector-copy path until more corpse
  variants are generated (cheap to add later: same recipe, different
  `ENEMY_COLOR`/shape per kind).

## Rotation

All 6 enemies + the player were generated as genuine top-down orthographic
art (matching the vector shapes' own convention — a fixed local "forward"
axis, continuously rotated per-frame by the entity's facing angle `ang`),
**not** pre-rendered 8-directional billboard frames. This means the natural
integration is runtime continuous rotation via
`pygame.transform.rotozoom(sprite, -math.degrees(ang), scale)`
— matching current behavior exactly (instant facing feedback, zero new
asset variants, no directional-frame bookkeeping). The `-` sign is because
`ang = atan2(diry, dirx)` is a math-convention angle in a y-down screen
space, while `pygame.transform.rotate`/`rotozoom` rotate counter-clockwise
for positive degrees in a y-down surface — **this sign was reasoned from
the existing `_xform_pts` convention, not confirmed by running the actual
renderer (out of scope for this pass); verify against one moving enemy
before shipping.**

- `prop_terminal`: not continuously rotating — it should be rotated once to
  match the wall tangent angle already computed by
  `_nearest_wall_point`/`_draw_terminal` (`math.atan2(wall["ty"], wall["tx"])`),
  same as the existing slab polygon. Cache the rotated surface per terminal
  instance (walls don't move) rather than rotating every frame.
- `prop_seed_station`, pickups: no rotation (the vector versions don't
  rotate either).
- `prop_corpse_husk`: corpses are decals with a `angle` baked in at spawn
  time (see `_draw_decal`'s `corpse_` branch) — rotate once at decal-spawn
  time using that stored angle, not per-frame, then cache like the terminal.

## Draw scale / performance note

Generated PNGs are large (up to ~1400×770, several were autocropped tight
but the model's native output resolution is high) since they were generated
once, well above final on-screen size, specifically so downscaling has
headroom to filter cleanly (the brief's "2-4x on-screen footprint" ask).
**Before shipping, pre-scale each sprite once at load time** (or as a build
step) to a handful of fixed sizes bucketed by expected `srad` range, rather
than calling `rotozoom` on the full-resolution source every frame — at
640×360 internal resolution an on-screen enemy is typically 20-60px, so
blitting from a 1400px source every frame is wasted work. `pygame.Surface`
caching keyed on `(asset_name, round(scale, 2), round(degrees(ang)))` with
an LRU cap is the standard fix if profiling shows this matters.

## Palette / style QA

All 13 assets passed an in-context verifier (paste the real sprite into a
real gameplay screenshot at its intended on-screen size, judge with
`google/gemini-3.5-flash` over OpenRouter — same methodology as
`tools/artgen/verify_in_context.py`, adapted for sprites in
`tools/artgen/verify_sprite_in_context.py`) at `p_shippable ≥ 0.95` on the
final pass, checking silhouette match, palette match, coherence, and clean
transparency. Two assets needed one regeneration each (`enemy_shrieker`,
`prop_corpse_husk` — both were the false-negative transparency case above,
not silhouette/palette problems). See `media/hp_asset_sheet.png` for the
full set and `media/hp_before_after.png` for a scene-level before/after
mock (sprites pasted at illustrative scale/position, not final integration).
