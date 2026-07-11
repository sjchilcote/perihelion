# FLOORPLANS.md — sample-set floorplan rationale (director-ordered iteration, 2026-07-11)

Written BEFORE generation, per the director's ruling: each functional room
kind gets a real floorplan a worker could use — where the equipment rows
are, where people walk, where wear/stains/drains go — not a decorative
geometric pattern. The hydroponics room is the calibration case: a prior
pipeline run baked edge-only trays with no walking path into the base
texture; this pass corrects it at the prompt/geometry level, not by
post-hoc decoration.

Sample set: 10 rooms across 3 levels (l01, l03, l05) — chosen to cover
dock, corridor, storage, hydro (x2), lab, quarters (x2), and one
Testator-pure deep-station room (chapel), per the director's scope
instruction ("2-3 levels... hydroponics-type room... corridor, dock, and
one deep-station Testator-pure room").

Every room below reuses `game/perihelion/render.py`'s existing prop
authoring as ground truth (GEOMETRY_LOCK in the texture prompt forbids
inventing new props) — the floorplan rationale here explains WHY that
authored layout already reads as a working room, and what the texture
must add (wear paths, stains, drainage) to sell it, without inventing new
furniture geometry.

## dock — l01/room_0, l01/room_2 (MIRIAD lane)
Authored props: corner crate stacks (2 corners, offset rows), a
hazard-striped loading strip along one wall, mooring rings along another.
Floorplan: this is a cargo airlock antechamber — crates are stacked
against the two corners farthest from the door threshold (out of the
main thoroughfare), the hazard strip marks the loader's working lane
along one wall, and the open center + the path from door to mooring
rings is the walk/tow lane. Texture expression: anti-slip deck plating
with a visibly worn, slightly lighter travel path from the doorway to
the mooring wall; grime pooling in the two crate corners (low traffic);
the hazard strip itself reads as paint-on-metal, not a 3D raised object.
Lane: MIRIAD (heavy industrial cargo infrastructure, right-angle plating,
stenciled bay numbers).

## corridor — l01/room_55 (MIRIAD lane)
Authored props: wall-hugging pipe runs with elbow joints on up to 2
walls, an occasional vent grate, floor lane chevrons at 28%/72% along
the long axis. Floorplan: a through-corridor — the chevrons mark the
center walk lane, pipes/vents are hugged against the walls out of the
way. Texture expression: worn traffic polish down the center axis
(lighter, smoother-looking plating) fading to grimier plating at the
wall edges under the pipe runs; chevrons read as faded floor paint, not
raised trim. Lane: MIRIAD.

## storage — l01/room_117 (MIRIAD lane)
(Originally sampled l01/room_116; it failed the programmatic full-bleed/
geometry gate twice across two independent regeneration rounds — invented
props along a wall margin, then an invented notch cut into the polygon.
Per the director's ship-no-texture rule it ships with NO bespoke texture
(honest flat-floor fallback) and is kept as the sample set's documented
failure case rather than silently swapped away. l01/room_117, a same-kind
same-level room, replaces it in the reviewed/shipped sample.)
Authored props: 2-3 dense crate rows with a deliberate walkable aisle
between them (already coded into `_props_storage`), shelf lines along
the walls. Floorplan: a stockroom — rows run perpendicular to the main
aisle so a worker can push a cart straight through; shelving hugs the
walls. Texture expression: aisle shows polished/worn plating (cart
traffic), under-shelf and under-row zones show dust and undisturbed
grime — the contrast between aisle and row-shadow IS the floorplan
signal, not a painted stripe. Lane: MIRIAD.

## hydro — l03/room_0, l03/room_5 (MIRIAD lane, CALIBRATION ROOM)
Authored props: planter troughs along up to 3 walls (spaced, not
touching), each with occasional stalks; ONE additional center trough
offset 10-18 units from room center at a random angle, with its own
stalks. This already leaves the bulk of the room's interior as open
floor — the failure mode is not the prop layout (which does provide
walk space) but a texture that (a) invents ADDITIONAL tray-like
geometric patterning across the open floor, turning it into a
checkerboard with nowhere to step, or (b) renders the troughs as
2D decal patterns rather than raised trough objects with a floor
underneath them. Floorplan: wall-mounted trough rows are the growing
beds; the center trough is a single island bed, not a second row; the
remaining open floor — especially the direct path from the doorway to
the center trough and around it to each wall trough — is the walk
aisle. Texture expression: damp organic-stained deck plating with
mineral/algae bloom concentrated AT and RADIATING FROM the trough
footprints (condensation/overflow staining), NOT as an even all-over
pattern; the walk aisle between troughs stays comparatively clean
scuffed plating, not decorated; drainage grate implied near the lowest
point of the stain gradient. This is the room the director singled out
by name — extra scrutiny, minimum 2 generation attempts, personal frame
read against the base-truth prop mask before accept. Lane: MIRIAD
(hydroponics is human-built infrastructure even this deep — no Testator
material language here).

## lab — l03/room_59 (MIRIAD lane)
Authored props: a center specimen table (rect prop) offset from center,
a wall-mounted screen array with occasional lit screens. Floorplan: a
work lab — the specimen table is the workstation, screens are
wall-mounted reference/monitoring, the rest is clear floor for
movement around the table. Texture expression: clean-room composite
flooring, faint chemical staining concentrated near the table
footprint, embedded cable trays running from the screen wall toward the
table (implying power/data run, not decoration), open floor stays
plain. Lane: MIRIAD.

## quarters — l05/room_4 (MIRIAD lane); l05/room_5 DROPPED (see below)
Authored props: cot bays along up to 3 walls, each with a pillow prop
and a footlocker; near-core rooms get the bays shoved askew (corruption
scaling — not the case at l05, still near the outpost). Floorplan:
personal bunks ringing the walls, a shared open floor in the middle for
moving between them. Texture expression: worn residential deck
composite, scuff/wear concentrated at each bunk's foot (where a person
stands to dress/use the footlocker) and the doorway-to-bunk paths,
open center floor reads as plain lightly-worn composite. Lane: MIRIAD
(human domestic infrastructure, gone a little derelict but not
Testator-touched).

**In-situ boundary QA (real Renderer, real doorway, `verify_in_situ.py`)
caught a genuine seam**: l05/room_4 and l05/room_5 shared a doorway; the
judge flagged "a severe, hard-edged misalignment running vertically right
down the center of the room" where the two independently-generated
same-kind textures met, and personal review of the overview frame
confirmed a real tone/rust-density jump across the threshold despite both
rooms being graded toward the same kind_windows.json tone target.
Force-regenerated room_5 twice (a fresh 2-attempt round); both attempts
failed the programmatic full-bleed gate for unrelated reasons (a painted
darkened margin/border), so per the ship-no-texture rule room_5 now ships
with NO bespoke texture -- the engine's flat procedural floor fallback
applies there, room_4 keeps its accepted texture. The boundary is no
longer two mismatched plates; it is one textured room meeting one honest
flat-fallback room, which is the documented acceptable case. **Residual
flag**: tone-window grading alone is not sufficient to guarantee doorway
continuity between independently-generated same-kind rooms -- the in-situ
gate is doing real work here and should stay in the loop for the full
199-room set, not just this sample.

## chapel — l05/room_7 (TESTATOR-PURE, deep-station lane) — DROPPED, see below
Authored props: pew-row lines all facing one "front" wall, a dais arc
near that wall. Floorplan: a ceremonial space — pews face the dais,
the aisle down the center (perpendicular to pew rows) and the space
around the dais are the walk/ritual paths. This room is Testator
base architecture, not MIRIAD-altered: no signage, no grid regularity,
no printed labels. Texture expression: non-human asymmetric geometric
inlay radiating from the dais, old dark ritual stains following the
aisle and dais-approach paths (where feet/bodies moved), unsettling
non-orthogonal proportions in the inlay grooves — the KIND_MATERIAL
"chapel" language already encodes this; this room gets ZERO MIRIAD
industrial signage/hazard-stripe/stencil language even though it sits
in an otherwise MIRIAD-adjacent outpost level, because chapel is one of
the three Testator-authored kinds (TESTATOR_KINDS in
pilot_texture_lib.py) — the station's human occupants did not build or
alter this room. Lane: TESTATOR (pure).

**Personal frame review caught a real defect here that both automated
gates (programmatic full-bleed check AND the Gemini geometry judge)
missed on the first attempt**: the model painted an invented octagonal/
chamfered room silhouette (black void wedges in all four corners) over
a base truth that is a plain full-bleed rectangle (verified by reading
`gen_rooms_v2/l05_room007_a1.png` against `basetruth/l05/room_007.png`
directly — the corner-cutting exists in the model's raw output before
any masking, so it is a genuine geometry hallucination, not a masking
bug). That attempt had been auto-accepted and shipped. Caught by eye,
force-regenerated (2 fresh attempts); both failed their own gates for
unrelated invented-geometry reasons, so per the ship-no-texture rule
this room now ships with NO bespoke texture — chapel is the only
chapel-kind room in the whole 1,815-room census (count=1 in
room_census.py), so there is no same-kind alternate to swap in. The
stale (defective) accepted texture was deleted. **Residual flag**: the
`verify_fullbleed` heuristic (programmatic gate) and the Gemini
geometry-verify prompt both need a check for large solid-black regions
fully enclosed by the polygon interior (an "invented corner void"),
not just edge-adjacent darkening gradients — this is a real pipeline
gap, not a one-off model mistake, and likely affects other rooms in the
full 199-room set that were accepted without a human eye on them.

## core — l07/room_2 (TESTATOR-PURE variant, MIRIAD server intrusion) — substituted deep-station room
Authored props: a radial console ring with two blocky server/machine
housings flanking the center, matching TESTATOR_DESIGN_LANGUAGE.md's
note that l07's core room specifically gets MIRIAD server language
grafted onto Testator-corrupted reactor architecture (human plating
overtaken by alien growth-like geometry). Floorplan: the ring aisle
between the outer wall and the console ring, and the cross-paths to the
two server housings, are the walk paths; the ring's total open center
around the "dark heart" is off-limits/inert rather than a walkway.
Verified geometry-clean against base truth (full rectangle, no invented
corners) on personal review — used here in place of the failed chapel
room to keep one Testator-pure/deep-station example in the shipped
sample (4th level, l07, added specifically for this).

## Authorship lane summary for this sample
| room | kind | lane |
|---|---|---|
| l01/room_0 | dock | MIRIAD |
| l01/room_2 | dock | MIRIAD |
| l01/room_55 | corridor | MIRIAD |
| l01/room_116 | storage | MIRIAD |
| l03/room_0 | hydro | MIRIAD |
| l03/room_5 | hydro | MIRIAD |
| l03/room_59 | lab | MIRIAD |
| l05/room_4 | quarters | MIRIAD |
| l05/room_5 | quarters | MIRIAD |
| l05/room_7 | chapel | TESTATOR (pure) |

No MIRIAD signage/stencil/hazard language appears in the chapel room;
every other sample room is emphatically human-built utility
infrastructure with no Testator organic-geometric material.
