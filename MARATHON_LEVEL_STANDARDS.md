# MARATHON LEVEL STANDARDS — the measured bar
### Numbers extracted from the actual Marathon 1/2/Infinity map files; what PERIHELION levels should hit

*Source: `tools/marathon/mapread.py` (wad parser, reverse-engineered from the
Steam Aleph One releases) + `tools/marathon/stats.py` (measurements). Every
number below is measured from the shipped `Map.scen`/`Map.sceA` files, not
remembered. Rerun: `uv run python tools/marathon/stats.py` (Marathon),
`--ours` (our levels, engine ground truth). Scale used throughout:
**1 Marathon WU = 1024 internal units = 80 PERIHELION u** (0.078125 u per
internal unit) — chosen so Marathon's median walkable portal (exactly 1.00 WU
across M1's 27 solo levels) lands on our standard 80 u doorway.*

---

## 1. Top-line: what a Marathon level measures

| metric (per solo level, median across levels) | M1 (27 solo) | M2 (28) | Inf (33) | PERIHELION today |
|---|---|---|---|---|
| polygons per level | **253** | 367 | 439 (max 1023) | **5-16 rooms** (med 9) |
| walkable portals per level | 299-358 | ~450 | ~620 | 4-17 |
| median polygon area | 1.41 WU² = **9,000 u²** (~90×90 u) | 1.98 WU² | 1.12 WU² | rooms typically 150-400 u across (22k-160k u²) |
| portal (door) width med | 1.00 WU = **80 u** | 1.28 WU = 102 u | 1.12 WU = 90 u | 70-90 u ✓ |
| mean adjacency degree | 2.5-2.6 | 2.5 | 2.5 | ~2 |
| potentially-visible polys, typical point | **21.5** (per-level med 10-44) | 26 | 45 | — |
| potentially-visible polys, level max | **69** (up to 212) | 75 (up to 205) | 166 (up to 317) | — |
| visible within one screen (~8 WU), typical | **17** | 19 | 35 | engine `visible()`: **3-8** |
| visible within one screen, max | 65 | 64 | 99 | 21 (l08's fold) |

Methodology: "potentially visible" = exact 2-D angular portal flood from
polygon centroids (depth ≤ 15, the plan-view analog of necore's
3-half-plane frustum; correct in 5D-overlap regions — each overlap counts
as an instance, like our DrawInstances). Our column is the real engine
`len(session.visible())` sampled during a 30 s AggroBot walk, which is
additionally screen-bounded — so compare it to the "within one screen"
rows, not the unbounded flood.

**Calibration anchor (same engine, same screen, same bot):** Arrival
converted into our format (`levels/marathon_arrival.json`) measures
`visible()` **med 8 / p90 14 / max 16** during the same 30 s bot walk that
gives our authored levels med 3-8 / max 21. The engine's 640×360 window
plus depth-14 cap eats roughly half of the raw flood density, so the
practical target band is the one in rule 1 below, not the raw flood
numbers.

**The verdict the numbers give:** a Marathon frame composes ~17-25 small
polygons; a PERIHELION frame composes 3-8 rooms. Marathon reaches its
density not with bigger levels but with *finer cells*: their median cell is
90×90 u — the size of one of our doorways squared — and a "room" in the
architectural sense is a *cluster* of 3-10 cells, while a corridor is a
*chain* of them.

## 2. The cell grammar (M1 aggregate, 6,665 polygons)

- **Degree histogram:** 0: 0% · **1: 10%** (dead-end alcoves) · **2: 48%**
  (pass-through/corridor cells) · **3: 24%** · **4: 13%** · 5+: 4%.
  Half of all Marathon cells are corridor links; hubs of degree ≥ 5 are
  rare (one or two per level, the big chambers).
- **Vertex counts:** 4 verts: **68%** · 5: 12% · 6: 11% · 3: 2% · 7-8: 6%.
  Marathon is overwhelmingly quads with occasional chamfers; the format
  caps at 8 verts (ours has no cap, but the taste transfer holds).
- **Cell sizes** (our units, scale 0.078125): p25 **57×57 u**, median
  **90×90 u**, p75 **146×146 u**, p90 **219×219 u**. Big set-piece rooms
  (40-160 WU² = 500-1,000 u across) exist — about one to three per level —
  and are themselves subdivided into ≤8-vert convex cells.
- **Corridor chains** (maximal runs of degree-2 cells): median 1, p90 5,
  max 22. A hallway is typically 1-5 chained cells of ~80-160 u each, i.e.
  a corridor is 100-600 u long *and has geometry beats along it* (light
  changes, width steps — in ours: kind-dressing and portals).
- **Doors:** portal widths p10 40 u, median 82 u, p90 226 u. Narrow 40-60 u
  slots exist and read as crawls/windows; wide 160-320 u portals are room
  subdivision seams, not doorways.
- **5D space is canon, sparingly.** Arrival alone has ~26 polygon pairs
  that overlap in plan without being connected (its east maze corridors
  cross through each other). Marathon shipped genuinely non-Euclidean
  space in level 1 of the 1994 game and never mentioned it. This is the
  license for our entire premise, and the dosage lesson: one district per
  level, not the whole map.

## 3. Authoring rules for PERIHELION

1. **Subdivide until a screen holds 8-16 cells.** Target engine
   `visible()` median 8-16, max < 60 (cap is 96) — that is what real
   Marathon geometry measures through our own engine (calibration anchor
   above). Measured, not vibed: `uv run python tools/marathon/stats.py
   --ours` after authoring. Today's levels sit at med 3-8; the density gap
   is ~2×, and it is the single biggest "feels like game rooms, not a
   place" contributor at the geometry layer.
2. **Cell size rhythm 60/90/150/220.** Author in Marathon's measured
   quartiles: alcove ~60 u, standard cell ~90 u, large cell ~150 u,
   chamber module ~220 u. A set-piece room is 3-10 cells connected by
   full-width (160-320 u) seam portals, not one 500 u polygon. (Rooms stay
   convex by construction; connect the fragments and the renderer's
   per-room detail seeds vary the dressing naturally.)
3. **A corridor is a chain, not a rectangle.** 1-5 cells of 80-160 u
   length each, degree 2, width 70-90 u. Bend it: Marathon corridors turn
   every 2-3 cells (that's what keeps the flood at ~20 instead of 200).
   Half the polygon budget of a level should be degree-2 chain cells.
4. **Ten percent dead ends.** One alcove per ~10 cells — a niche off a
   corridor holding a cache, a terminal, or nothing. Marathon's 10%
   degree-1 cells are where its secrets and its quiet live (playbook §6/§7).
5. **Door = 80 u, seam = 160-320 u, slot = 40-60 u.** Keep the three
   width registers distinct: 80 u reads as a door, 160+ u reads as open
   continuation of the same architectural room, 40-60 u reads as a crawl
   or a window (pair with `no_connect`/window framing). Don't author 120 u
   "doors" — they sit in the uncanny middle register Marathon avoids.
6. **Budget 150-250 cells per district.** Marathon holds ~253/level (the
   format caps at 255 — they authored *to the cap*; M2 relaxed it and
   levels grew to ~370). With rule 2 that is 15-30 architectural rooms
   per level — 2-4× our current density, achieved by subdividing what we
   already have, not by quadrupling floor plan extent.
7. **Quads with chamfers.** 68% 4-vert cells, chamfer (5-6 verts) where
   corridors meet chambers or turn. Reserve 7-8+-vert ngons for the one
   or two genuinely radial spaces per level (rotunda, core) — exactly the
   rooms allowed degree ≥ 5.
8. **Overlap one district per level, silently.** Marathon's maze-grade 5D
   (Arrival east maze: ~26 overlapping pairs among ~90 cells) is dense
   *locally* and textually unacknowledged — the automap contradiction IS
   the tell (playbook §8's textual-twin rule still applies to ours).

## 4. Where the numbers came from

- `tools/marathon/mapread.py` — wad container + PNTS/EPNT/LINS/POLY/OBJS/
  Minf chunk parser (format notes in its docstring: big-endian, MacBinary
  wrapper, v0 vs v2/v4 directory shapes).
- `tools/marathon/stats.py` — everything in §1-§2; `--ours` for the
  PERIHELION column.
- `tools/marathon/convert.py` — Marathon level → our JSON (proof the two
  formats are the same shape: polygon mesh + shared-edge portals ≙ convex
  rooms + connects). `levels/marathon_arrival.json` is M1 level 0 converted
  at the scale above and playable.
- `tools/levelgen/arrival_maze.py` — Arrival's east maze (the 5D one) as a
  reusable `build_maze()` stamp; demo in `levels/maze_demo.json`.
