# Bespoke room floor textures

Lever one of `ARTSTYLE_DIRECTION.md`: bespoke generated textures for room
floors, sampled by both render backends through `necore.Raster`'s
`OP_TEX_FILL` (`engine/necore/src/raster.rs`) and its pygame/numpy mirror
(`game/perihelion/render.py::_draw_floor_textured`).

## Path convention

    game/perihelion/assets/textures/<level_id>/room_<room_index>.png

- `level_id` is the stem of the `levels/*.json` file the room was authored
  in (e.g. `levels/l01.json` -> `l01`). Streamed campaign chunks each keep
  their own `level_id` — a room's engine index is NOT the room index used
  here; `WorldStreamer` maps engine room -> `(level_id, local_room_index)`.
- `room_index` is the room's index within that level file's `"rooms"`
  list (0-based, same order `Level.room_verts` uses).
- A room with no file at this path renders exactly as it does today (flat
  floor color) — absence is never a placeholder.

## Geometry: room-local frame, 3 px/world-unit

Texture space is the room's LOCAL frame (post-recentering, the same frame
`Level.room_verts[i]` uses — centroid-relative, y-down). For a room whose
local vertices span bounding box `(min_x, min_y, max_x, max_y)`:

    DENSITY = 3.0                      # px per world unit
    w = ceil((max_x - min_x) * DENSITY)
    h = ceil((max_y - min_y) * DENSITY)

Texel `(tx, ty)` (row `ty` from the top, matching a normal decoded image)
covers the room-local point:

    local = (min_x, min_y) + (tx + 0.5, ty + 0.5) / DENSITY

Both backends sample the texture NEAREST-NEIGHBOR by inverting the
instance's room-local->screen transform per screen pixel: for pixel
center `(px+0.5, py+0.5)`, `local = inverse(xform).apply(px+0.5, py+0.5)`,
then `texel = floor((local - bbox_min) * DENSITY)`, clamped to
`[0, w-1] x [0, h-1]`.

`game/perihelion/texture_geom.py` is the single source of truth for
`DENSITY` and `texture_size_for_room(verts) -> (w, h)` — both the
generation tool and the renderer import it, so they can never disagree.
Textures are plain RGB (no alpha; floor coverage is the room's clip
polygon, which is always fully opaque).

## For the generation tool

```python
from perihelion.levels import load_level
from perihelion.texture_geom import texture_size_for_room, texture_path

level = load_level("levels/l01.json")
for room_index, verts in enumerate(level.room_verts):
    w, h = texture_size_for_room(verts)
    out = texture_path(TEXTURES_DIR, level.level_id, room_index)
    # generate a (w, h) RGB image for this room and save it to `out`
```
