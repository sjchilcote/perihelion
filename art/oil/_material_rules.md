## What a game floor material must be (read carefully — this is not a picture)

This painting is a **floor texture** for a top-down game, PERIHELION. The game
will tile it across the floors of the Gauntlet level (163 rooms and
corridors), so:

1. **Seen straight down, flat.** No perspective, no horizon, no vanishing
   point, no cast shadows from a light direction, no vignette, no focal
   point. Even illumination everywhere: the game adds its own lighting on top.
2. **It must tile seamlessly.** The canvas is square (`aspect=1`), 1000×1000
   canvas units. Your canvas repeats edge to edge in both directions:
   whatever leaves the right edge re-enters on the left, top ↔ bottom. Build
   it on a **periodic grid of 125 canvas units** (8 × 8 cells): every
   structural line (panel seams, plate rows, inlay lines) sits on x or y =
   0, 125, 250, … 1000, or on a regular subdivision of those cells, so lines
   continue across the wrap. Put structural lines exactly ON the canvas edges
   (x=0 / x=1000 and y=0 / y=1000 are the same line). No single large feature
   (a big hatch, a big stain) may cross the canvas edge; keep large unique
   features well inside. Grime, scratches and wear should be spread evenly
   across the whole canvas, not concentrated anywhere — a repeated tile shows
   any blotch as a pattern. After you finish, the studio will cross-fade the
   last few units at the edges with a half-offset copy to hide residual paint
   variation; you only need structure to line up.
3. **Scale.** 2 canvas units = 1 game world unit. The player's body is about
   13 world units across (26 canvas units); a corridor is ~110 world units
   wide (220 canvas units). Each 125-unit grid cell is ~62 world units —
   a floor panel a little wider than a person is tall.
4. **Value.** Mid-dark overall (avoid near-white and pure black areas): the
   game's characters, bullets and lights are drawn ON TOP of this floor in
   bright vector lines, and they must read against it. Keep contrast within
   the floor modest; detail should be felt more than seen at a glance.
5. **It should be beautiful paint.** The whole point: the team tried
   diffusion-model textures and lacked control; painted textures in games
   look wonderful. Let the brush show. A viewer should see oil paint, not a
   photo — but a floor first.

For reference, /tmp/cp/notes/current_floor_textures_l01.png shows the current
(generated) MIRIAD floor textures of another level: cool gray deck plates,
verdigris-tinted, rust at seams, rivets, treadplate, pipe runs. Yours replace
that look with painted ones for the Gauntlet.

When done, save to /tmp/cp/<SESSION>/final.png as usual.
