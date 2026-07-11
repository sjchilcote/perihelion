# TESTAMENT exterior hero sprite — artist commission brief

**Status (director's ruling, 2026-07-11):** AI generation reached its limit on this
asset. `media/concepts/testament_exterior_v3/foldlink/foldlink_a.png` is the
PLACEHOLDER going forward; the final asset is a commission for a human pixel artist.
This document is the commission spec — it condenses three concept rounds
(media/concepts/testament_exterior/, _v2/, _v3/ + their MANIFESTs) and the locked
design rulings.

## What it is

The TESTAMENT: a vast, ancient, HANDMADE alien warning-station, seen from outside —
the hero image behind the game's intro scroll (text over a dynamically generated
starfield; the station is an isolated sprite composited in-engine).

Canon: TESTATOR_DESIGN_LANGUAGE.md (binding), NARRATIVE_DESIGN_DOC.md §4.2.
The builders had no industrial society — everything is a handcraft, including the
station. It is a reliquary the size of a city, adrift since before life on Earth.

## Locked design (from the concept rounds)

1. **Composition:** 45° view looking down THROUGH the ring; the station takes a
   healthy fraction of the frame; off-center-friendly (scroll text needs negative
   space). Isolated sprite: pure #000000 background, no stars/glow/vignette —
   starfield, sun, and all light effects are engine-side.
2. **Structure:** spin-gravity habitat RING (dwelling: window rows, hospitality) +
   despun axial SPINE (the guts: ingestion machinery, remass, vault bays) joined at
   a hub bearing the eye can find. The two differ in character, not just shape.
3. **Surface language:** phyllotactic scale-plate armor (golden-angle tiling, no two
   plates identical), golden-angle aperture rows, spiral-chamber growth revealed at
   an erosion break (nautilus as ORGANIZING RULE, never a shell shape), laminated
   deep-time wear. Palette: worn bronze, verdigris, bone, warm window light.
4. **Scale:** sold by human-scale details — thousands of tiny windows (some lit),
   airlock rings with door detail. (Concept-round failure to avoid: without these
   it reads as a bracelet.)
5. **Impossible geometry (the point of the whole image):**
   - STATIC: the Penrose hub — ring/spoke/strut crossings that are locally innocent
     and globally unresolvable (see r3_05 for a generated approximation).
   - ANIMATED (engine does the animation; artist supplies geometry + layer masks):
     the FOLD-LINK — a small ring whose one arc enters an aperture in the spine and
     never exits; its other arc emerges from a DIFFERENT, non-aligned aperture;
     plate pattern continuous across both arcs. Impossible to assemble in Euclidean
     space; proven to the viewer by plate-highlight flow along both arcs in shared
     phase (palette-cycling style).
   - Design law learned the hard way: impossibilities must be LOCALLY coherent and
     only GLOBALLY wrong (impossible occlusion and inconsistent lighting read as
     errors and were "corrected" by every AI model; they'll read as errors to human
     viewers in static art too unless motion proves them).
6. **Impossible light (engine-side; artist supplies masks/regions):**
   - the STOLEN SUNBEAM: hard-edged keylight patch on night-side plating, conforming
     to plate contours, whose shape matches an aperture on the sunlit side;
   - the DISPLACED BEACON SWEEP: rotating beacon crossing the hull, entering a fold,
     re-emerging displaced, phase-continuous;
   - window-row light drift along the ring band (sells the spin).
7. **Format:** full-resolution pixel art — the pixel grid IS the image pixels (1:1,
   no fat emulated blocks). Game internal res 640x360 (flagship 1280x720); sprite
   sized to occupy a healthy share at 45°. Deliverables: base sprite + separate
   mask layers (windows, fold-link arc paths, sunbeam patch, beacon path) as
   PNG/JSON per the prototype format in
   media/concepts/testament_exterior_v3/foldlink/foldlink_annotations.json.

## Reference set for the artist

- foldlink_a.png — the placeholder; overall read to beat.
- r3_05_final_convergence.png — best Penrose hub + full checklist.
- r3_04, 10_scale_dominant_edge_on_erosion (v2), 01_ring_dominant_edge_on (v2) —
  erosion reveal, aperture silhouette.
- game/tools/intro_probe.py + testament_intro_probe.mp4 — working compositor
  prototype for all animated devices (device *implementations* are crude; the
  pipeline and mask format are the deliverable contract).
