# FOLD NOTATION — what the Testators' inscriptions say (proposal, 2026-10-01)

**Status: proposal for the director.** TESTATOR_DESIGN_LANGUAGE.md §5 fixes that
the Testators write in "nested self-similar geometry: a polygon containing a
smaller rotated copy of itself, arcs that reference other arcs", that the
inscriptions are diagrams of spatial connection, and that the decoration near
a non-Euclidean join diagrams the join. This note proposes what the notation
literally encodes, so artists, level generators and the docents' lessons all
draw the same language, and so an attentive player really can learn to read it.

## What it describes: the engine's own model of space

The station is what the engine is: rooms are convex polygons, and every
doorway is a **gluing** — an edge of one room joined to an edge of another
(or of the same room) by a rigid motion. Nothing else exists; there is no
world space. Space is "impossible" in exactly one way: walking around a loop
of gluings brings you back **turned, shifted or mirrored** relative to where
you started. Mathematicians call that the loop's *holonomy*; the Testators
treat it as the only fact about a place worth carving. Fold notation is a
**gluing diagram** with the holonomy written into it — a cousin of the
topologist's fundamental polygon (a square whose edges, labelled a b a⁻¹ b⁻¹,
make a torus), drawn by a people who had no linear script for space at all.

## The grammar (seven marks)

1. **The room-glyph.** A room is written as its own floor polygon, drawn to
   its true proportions (a long corridor is a long glyph). Polygon = noun.
2. **Edge ticks.** Each doorway edge carries a small notch on its outside;
   the notch's count (1–5, spaced by golden-ratio gaps) names that doorway
   within the room. A chevron on the notch gives the edge's direction, so the
   two ends of a gluing can be matched like the arrows on a fundamental
   polygon.
3. **The bridge (a gluing).** An arc joins two notched edges. An arc between
   two different glyphs is an ordinary door. An arc that leaves a glyph and
   **returns to the same glyph** is a self-gluing: the room opens onto itself.
4. **The inset (holonomy).** Inside a glyph, or at the heart of a closed
   ring of glyphs, sits a **smaller copy of the room, rotated by exactly the
   angle you are turned through** when you walk that loop. Scale is the
   golden ratio (each inset 0.618 of its parent), so insets can nest without
   ambiguity. This is the "polygon containing a smaller rotated copy of
   itself": a room you cannot leave without coming back turned.
   - Inset upright: a quiet loop; the Testators carve these anyway, the way
     a careful mason marks a plumb line.
   - Inset turned: a twisted loop (HYDROPONICS TORUS: walk half the arc and
     you are home, rotated — its glyph holds a turned copy of itself).
   - Inset **reflected** (drawn outlined in bone, on the far side of a bar):
     a mirror join (MIRROR WARD).
   - Inset **displaced** (sliding off-centre along the arc that causes it):
     a loop that lands you somewhere else at the same heading (four left
     turns and you arrive somewhere new).
5. **The spiral of insets (recursion).** When each lap adds the same twist
   again, the insets repeat inward, each turned and shrunk by the same step,
   until they vanish into a point: a golden spiral of rooms. RECURSION STACK
   is a corridor-glyph spiralling into itself; the infinite aisle is written
   as an infinite inscription that ends in a dot.
6. **Petals (one heart, many routes).** A ring of glyphs around one central
   glyph, each petal bridged to the heart and to its neighbours, with every
   petal's inset showing the same heart: THE FOLD ("six petals around a
   heart; every route adds a room that was already there").
7. **Counting by the golden angle.** Where several marks share a centre
   (insets of different loops, notches around a heart), they are placed at
   137.5° intervals, never evenly — the phyllotaxis of the design language,
   here used as punctuation so that no two marks ever sit on the same ray.

## Where it appears

- **Thresholds.** Over every impossible doorway, the join itself is carved:
  the two room-glyphs, the bridge, and the inset. Reading it tells you what
  the door will do *before* you walk through. This is the canon's "the
  decoration near a non-Euclidean join quietly diagrams the join".
- **Floors.** At the centre of a room that belongs to a twisted loop, the
  loop's ring of glyphs is inlaid in bone with its holonomy inset at the
  heart: the room's address.
- **The docents' lessons.** The museum (the School's exhibit halls) teaches
  it in escalating plates, each paired with a small walkable demonstration
  room: (1) a room-glyph and its notches; (2) a bridge between two rooms;
  (3) a quiet loop with an upright inset; (4) a twisted loop and the turned
  inset, with the demonstration room in which the visitor walks it and comes
  back turned; (5) a mirror join; (6) recursion; (7) a fold. The final plate
  diagrams the station itself, and it does not close: one bridge runs off
  the edge of the plate into a mark the docents decline to translate (the
  Breach — the Adversary has no glyph, only the absence of one).
- **Depth gradient.** In the shallows the notation is carved small, as
  wayfinding beside furniture. In the depths (TESTATOR_DESIGN_LANGUAGE §4)
  furniture thins out and the notation takes over the surfaces: walls that
  are nothing but the diagram of the space they bound.

## Why this reading

- It is literally true of the game: every glyph could be generated from a
  level's `connects` and the holonomy of its cycles (the BFS layout in
  tools/artgen/paint_floor.py already finds the gauntlet's nine non-closing
  loops and how far each is off).
- It is learnable in the order the level design already teaches geometry
  ("from horror to grammar", NARRATIVE_DESIGN_DOC §6.3).
- It honours both halves of the design language: biology's mathematics
  (golden-ratio scaling, golden-angle placement) carrying the one thing the
  Testators mastered, connection.
- It makes the Adversary's absence legible: inconsistency itself can't be
  written in a notation of consistent gluings.
