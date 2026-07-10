# Decal / Prop Diegesis Audit

Audit of every procedural mark `game/perihelion/render.py` draws into a room, against
the director's standard: *what is this mark actually doing where it's placed — not
"can we think of a reason," but what is its job where it is — and did the Testators
put it there, or MIRIAD? The former should look older and more alien than the latter.*

Scope: `render.py`'s `_ROOM_PROP_GENERATORS` dispatch table (13 `_props_<kind>`
functions), `_descent_dressing` (kind-independent overlay), and the corruption
tendrils baked into `_crate`/`_props_pump`. Cross-referenced against
`NARRATIVE_DESIGN_DOC.md` (canon), `LEVEL_DESIGN_PLAYBOOK.md` (placement rules), and
actual `kind=` usage across `tools/levelgen/campaign.py` + `tools/levelgen/dense/*.py`
(31 levelgen files, ~500 kind-tagged rooms) so verdicts are checked against how the
tags are *actually used*, not just how they're named.

Audit-only: **no code changes made.**

---

## 0. Canon primer (the two authorship layers)

- **MIRIAD** (§3.2 NDD): secular, knowledge-maximizing faction. Built the prefab
  research outpost the game currently plays inside almost entirely — "human-scale
  (machine-scale) corridors, modular habs, pressure doors, cargo bays, laboratories...
  Geometry: almost entirely Euclidean" (§4.1). This is **all of Stratum One**.
- **The Testators** (§4.2, §4.5): a 1.1-million-year-extinct machine-successor
  civilization. Built the vast station MIRIAD's outpost is bolted onto. Their
  architecture is deliberately non-Euclidean but still "built for creatures" —
  "quarters, gardens, pressurized halls: retention engineering." Marks the Testators
  left should read **older, alien, non-orthogonal, asymmetric, weathered** — never
  regular MIRIAD rivet-and-plate language.
- **A third, real category the codebase already gets right**: the Commando's own
  seed/frame. §9.3 explicitly flags that his forward-seed network "lands in a hostile
  place, eats it, and fills it with copies of itself" — organic growth that is
  *neither* Testator nor MIRIAD. `GROWTH_FILL`/`TENDRIL_COLOR` already encode this as
  its own palette family, distinct from both. Keep it that way; the two-language spec
  in §5 below formalizes it as a third lane so nobody accidentally folds it into either
  authorship.

**Ground truth on what the current game actually renders:** every level file
(`l01`–`l10`, `campaign.py`, `dense/*.py`) tags rooms with the 14 `kind` strings in
`_ROOM_PROP_GENERATORS`. Grepping actual usage: `corridor` (141), `storage` (95),
`records`/`quarters` (34 each), `otherworld` (20), `medbay`/`dock`/`pump` (10-12),
`core` (8), `chapel` (6), `lab` (5), `hydro`/`generic`/`warden` (1-2). A separate,
unshipped tool (`tools/artgen/pilot_texture_lib.py`) already declares
`TESTATOR_KINDS = {"otherworld", "chapel", "core"}` and writes Testator-flavored
material-language prompts for them — but **that classification lives only in a
texture-prompt generator that hasn't shipped a single asset.** `render.py`'s actual
prop-drawing code, which the director asked to be audited, gives all three of those
kinds the exact same `PROP_COLOR`/`PROP_RIM`/`PROP_DARK` palette and rectilinear
placement grammar as every MIRIAD room. **The core finding of this audit: there is
currently zero code-level visual differentiation between Testator-authored and
MIRIAD-authored marks anywhere in `render.py`.** Only `otherworld`'s floor tint
(`OW_FLOOR`, a cold luminous green) breaks from the shared palette; `chapel` and
`core` do not even get that.

---

## 1. Mark-by-mark audit

Legend: **J**=has a real job at its placement, **U**=UNJUSTIFIED (no real job, or job
contradicts placement), **A**=authorship, **L**=look matches author.

### `dock` (`_props_dock`, render.py:693)

| # | Mark | Placement rule | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 1 | Corner crate stacks | 2 random corners, 3-5 crates each, jittered offset from corner | Staged freight waiting to load/unload — real cargo-bay behavior | MIRIAD | regular/rectilinear, matches | J |
| 2 | Hazard-stripe floor strip | One random wall, 60% of wall length, amber chevron ticks | Marks a loader/foot-traffic lane or spill zone | MIRIAD | matches | J |
| 3 | Mooring rings | Evenly spaced along one random wall | Tie-down points for parked cargo/pods during pressure events | MIRIAD | matches | J |

All three read as an honest working cargo bay. No changes.

### `corridor` / `transit` (`_props_corridor`, render.py:735)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 4 | Wall-hugging pipe runs + elbow joints | First 2 walls, inset 5u | Utility conduits (power/coolant/atmo) routed along a hallway — real infrastructure | MIRIAD | matches | J |
| 5 | Vent grates | 70% chance, one spot per corridor | HVAC intake/return | MIRIAD | matches | J |
| 6 | Floor chevrons | Two fixed fractions (0.28/0.72) along the corridor's long axis | Directional wayfinding/traffic-flow markers | MIRIAD | matches | J |

Clean. No changes.

### `storage` (`_props_storage`, render.py:780)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 7 | Dense crate rows + walkable aisle | Grid rows/cols, aisle band excluded | Actual inventory, aisle required for access | MIRIAD | matches | J |
| 8 | Wall shelf-line silhouettes | First 3 walls, double-line inset | Racking | MIRIAD | matches | J |

No changes.

### `pump` (`_props_pump`, render.py:824)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 9 | Tank ring(s) | Room-center-ish, jittered | Fluid reservoir/pressure tank | MIRIAD | matches | J |
| 10 | Inflow pipe | Nearest wall to tank, elbowed | Connects tank to utility runs | MIRIAD | matches | J |
| 11 | Floor puddle stains | 2-4 random blobs | Aging-tank leakage, plausible wear | MIRIAD | matches | J |
| 12 | Corruption growth patches on tank rim (`cor>0`) | Colonizes rim near the deep core | The Commando's seed spreading through infrastructure as he descends — canon §9.3 | **Commando/seed** (3rd lane) | distinct reddish-organic palette, correctly *not* MIRIAD or Testator | J |

No changes. #12 is a model example of the third-lane authorship working correctly —
formalize it in §5 so it doesn't get folded into "Testator" by a future pass.

### `lab` (`_props_lab`, render.py:885)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 13 | Console blocks, lit/dim screens | First 3 walls | Research instrumentation; dim-screen probability rises with descent (failing power deeper in — a nice diegetic touch) | MIRIAD | matches | J |
| 14 | Specimen table | Center-adjacent, jittered | Ties directly to canon: MIRIAD's survey studying "the derelict" (§7 Act 1 beat 2) | MIRIAD | matches | J |

No changes — this generator is a good model for the rest.

### `hydro` (`_props_hydro`, render.py:909)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 15 | Planter troughs + stalks | Walls + center row | Food/O2 crop bay, real necessity for a long-duration outpost | MIRIAD | matches | J |

No changes.

### `quarters` (`_props_quarters`, render.py:940)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 16 | Cot + pillow + footlocker bays, askew near the core | Walls, skewed/jittered by `cor` | Sleeping berth + personal storage; askew-ness near the deep core reads as crew panic/evacuation, not tidied-up quarters | MIRIAD (crew disorder, not alien) | matches — the skew is legibly "someone left in a hurry," not "alien geometry" | J |

No changes. Correctly MIRIAD; the corruption-skew here is a decay/panic signal, not
an alien-authorship signal, and doesn't get confused with one visually.

### `chapel` (`_props_chapel`, render.py:960) — **flagged**

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 17 | Pew rows + dais, askew near the core | Rows facing `walls[0]`, dais arc at 6u offset | A room for directed collective worship needs a *reason to exist on a secular MIRIAD base* — MIRIAD's utility function (§3.2) has nothing in it that provisions a chapel | ambiguous — currently unmarked | pew/dais furniture is drawn in plain `PROP_COLOR`/`PROP_RIM`, structurally identical to `quarters`/`medbay` furniture — no alien signature at all, despite `pilot_texture_lib.py` already independently flagging this kind's *floor* as Testator | **U (as executed)** |

**Why unjustified as executed:** the room's function (pews + dais) has no textual
grounding for who built it. `pilot_texture_lib.py`'s prompt language already guesses
the right answer without being asked — "Testator-altered ceremonial flooring...
alien symbol fragments worn into the surface" — which strongly implies the intended
canon reading is: **this is a Testator ceremonial chamber the outpost found near the
seam and a Congregation-linked minority of the (mixed AI/human) crew adapted for
prayer.** That's a real, specific job (a found sacred space, repurposed) consistent
with §4.1's "the seam" being an early, deliberate discovery point. But `render.py`
currently draws *none* of that: no alien base geometry, no crude/improvised overlay
signal, just clean regular pews. A player has no way to read "someone converted
this," only "there happens to be a chapel here."

**Fix (relocation-by-visual, not relocation-by-position):** make the room's underlying
geometry/floor read Testator (irregular ring or off-grid dais placement, older/
weathered rim), and render the pews/dais as an obviously improvised MIRIAD/crew
overlay — inconsistent spacing, orientation snapped to the room's own asymmetric axis
rather than a clean rectangular wall, a visibly different (newer, cruder) material
tone than the surrounding structure. This turns "why is there a chapel here" from an
unanswered question into a two-second environmental read: *found, not built.*

### `records` (`_props_records`, render.py:992)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 18 | Shelf-stack rank lines | 3-5 parallel rows | Archive/filing racks | MIRIAD | matches | J |

No changes.

### `medbay` (`_props_medbay`, render.py:1013)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 19 | Cots + curtain arcs | First 2 walls, up to 2 each | Patient beds + privacy screens | MIRIAD | matches | J |
| 20 | Cross-marked cabinet | Offset from a wall midpoint | Universal medical-supply marking (real-world convention, not a Congregation religious mark — no conflict with the Congregation-cross palette used in descent-dressing, but worth a comment noting the deliberate distinction so nobody "fixes" it into ambiguity later) | MIRIAD | matches | J |

No changes; flag the deliberate distinction from Congregation crosses (#29) in code
comments so a future author doesn't merge the two accidentally.

### `core` (`_props_core`, render.py:1035) — **flagged**

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 21 | Concentric ring inlays + radial spokes + amber hazard ring | Room-centered, evenly spaced | **Two unrelated jobs share one generator.** In `l10.py` this is the literal Perihelion Core / reactor sanctum (containment inlays, conduit spokes, hazard perimeter — plausible for the endgame reactor). In `l07.py` (`closet ... # staff-mind cores`, line 156) the *identical* generator dresses a MIRIAD server closet holding recovered colleagues' mind-backups (§5.4: "The outpost's dead: staff-minds whose cores the player finds") | **Testator** (l10 reactor) vs. **MIRIAD** (l07 server closet) — same tag, same code, two true authors | perfectly regular ring/spoke spacing reads MIRIAD-clean even for the l10 Testator reactor — canon calls for "non-human geometry/asymmetry" and gets none | **U for l07 usage; L mismatch for l10 usage** |

**Why unjustified for l07:** a data closet holding personality backups needs server
racks, status LEDs, cable trays — not a reactor-containment mandala. The `kind="core"`
tag is overloaded between "the literal Perihelion Core" and "any room whose function
loosely rhymes with 'core'" (the playbook itself invites this looseness — §1: "a
server-closet of recovered minds reads close enough to `core`" — but that guidance
predates this audit and should be corrected).

**Fix:** either (a) split the tag — add a `mindcore`/`archive-server` kind with a
MIRIAD-appropriate generator (rack units, blinking status lights, cable trays) and
reserve `_props_core`'s reactor-mandala language for genuine reactor/Testator rooms,
or (b) branch `_props_core` on `descent`/an explicit flag so low-descent, non-endgame
usages get the server-rack treatment and only the true Perihelion Core keeps the
mandala. Also: even the true reactor usage needs its ring/spoke placement de-
regularized (irregular spoke angles/radii) to read as Testator per §5.

### `generic` (`_props_generic`, render.py:1060)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 22 | Sparse plates/rivets/dots/stains fallback | Any untagged room | **By design, no job** — LEVEL_DESIGN_PLAYBOOK §1 and §8 explicitly license this only at the pure-graph tier (L8-10), where uniform anonymity *is* the place. Everywhere else it's a silent "someone forgot to tag this room" | N/A (deliberately featureless) | N/A | **J at pure-graph tier; U anywhere else, but audited usage found none misused** — the only actual `kind="generic"` call in the campaign is the vigil's 6 petal cells (`campaign.py:239`), a legitimate pure-graph-adjacent use |

No fix needed today; flagged as a **regression risk** — an author who forgets to tag
a room degrades silently into this with no warning. Worth a lint/assert in the level
builder (out of scope for this audit, noted for a follow-up).

### `otherworld` (`_props_otherworld`, render.py:1215)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 23 | Afterimage outlines (shrunk copies of the room's own polygon) | Two shrink factors, 0.82/0.62 | Deliberately non-functional — the room "remembering" its own shape wrong. Job is meta: communicate wrongness through familiar-grammar-broken (§6 step 2, canon's own device) | Testator/Adversary-adjacent, deliberately ambiguous | irregular, context-broken by design | **J (deliberate exception)** |
| 24 | Floating console slab facing nothing | 80% chance, mid-room | Same meta-job: a fixture with no functional orientation | ambiguous | matches (broken-grammar is the point) | J |
| 25 | Half-scale seat ring around nothing | 60% chance | Same | ambiguous | matches | J |
| 26 | Wall-embedded crate silhouette | 70% chance, centered on a wall vertex | Same | ambiguous | matches | J |
| 27 | Floor speckle | 3-7 dots | "The floor is starting to be sky" (docstring) — atmospheric, not a functional mark | ambiguous | matches | J |

This is the one kind where the playbook (§8) explicitly *wants* placement rules
violated as the content itself — LEVEL_DESIGN_PLAYBOOK.md's own carve-out. No fix
needed; flagged here only so a future pass doesn't "correct" it by giving these marks
real jobs, which would undo the intended effect. Authorship leans Testator/Adversary
per canon (§4.3, §4.5.4 — the Testators' final embodiment-abandoning architecture) —
should never pick up MIRIAD-regular geometry cues, and currently doesn't.

### Kind-independent: `_descent_dressing` (render.py:1096)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 28 | Grime stains/dots, wall streaks | Density scales with `descent` | Ambient weathering, not attributable to a builder | environmental (no author) | N/A | J (not a "mark," a texture) |
| 29 | Congregation crosses scratched near walls | `descent>0.3`, RNG-placed near a random wall | Docstring claims "the faithful went down, and kept writing" (plural, implying repeated past visitors) | **the Commando** (singular, this playthrough) | matches (Christian, worn-in) | **J, but job description overclaims — see below** |
| 30 | Seed growth patches + tendrils | Past corruption threshold, wall-anchored | The Commando's forward-seed network spreading — canon §9.3 | Commando/seed (3rd lane) | correctly distinct reddish-organic palette | J |

**#29 nuance:** the mechanism places crosses purely as a function of `descent` and
RNG — it has no tie to the Commando's actual death history in that room. A first
attempt and a hundred-death attempt render identically. The docstring's "the faithful
went down" (plural) implies multiple past visitors, which doesn't match: there is
only ever one Commando instance walking this playthrough. This isn't a Testator/
MIRIAD problem, but it is a job-description mismatch worth correcting cheaply:
reframe the comment as "his own habit under danger — he marks a cross whenever the
mission turns dangerous, not a record of prior deaths" (true to his characterization,
§5.1: "prays the hours on internal clock-time"), rather than implying an
un-implemented multi-frame memorial system. Zero code change required, a one-line
comment fix.

### `_crate` corruption tendrils (render.py:652, feeds `dock`/`storage`)

| # | Mark | Placement | Job | A | L | Verdict |
|---|---|---|---|---|---|---|
| 31 | Tendrils creeping from crate corners | 10-45% chance scaling with `cor`, any crate in dock/storage | Same seed-spread job as #12/#30 | Commando/seed (3rd lane) | matches | J |

---

## 2. Summary tally

- **31 distinct mark types audited** across 13 room-kind generators + descent-dressing
  + crate corruption.
- **2 firmly UNJUSTIFIED as currently executed**: `chapel`'s pew/dais furniture (#17,
  no job-grounding signal despite a plausible fix), and `core`'s reuse for the l07
  MIRIAD server closet (#21, wrong iconography for that room's actual function).
- **1 systemic-risk watch item, not currently triggered**: `generic` fallback (#22) —
  correctly scoped today, silently unsafe if an author forgets a tag.
- **All Testator-attributed marks are mis-authored by look** — every one of `chapel`
  (#17), `core`'s reactor usage (#21), and `otherworld` (#23-27) draws from the same
  `PROP_COLOR`/`PROP_RIM`/`PROP_DARK` palette and regular-geometry placement grammar
  as every MIRIAD room. `otherworld` partially escapes this via its distinct floor
  tint (`OW_FLOOR`); `chapel` and `core` get no distinguishing treatment at all. This
  is the single largest finding: **render.py currently has no Testator visual
  language, full stop** — the only place the Testator/MIRIAD distinction exists today
  is in prompt text for an unshipped texture-generation tool.
- **28 of 31 marks are correctly justified, correctly MIRIAD, and correctly
  MIRIAD-looking** — the bulk of the prop language (dock, corridor, storage, pump,
  lab, hydro, quarters, records, medbay) is in good shape and should be the reference
  model for whatever Testator-language pass follows.
- **The third authorship lane (Commando/seed) is real, canon-grounded, and already
  correctly executed and correctly distinct** (#12, #30, #31) — worth protecting
  explicitly in the spec below so a Testator-language pass doesn't accidentally
  absorb it.

---

## 3. Two-visual-language spec (for a follow-up implementation pass)

### MIRIAD lane (28 of 31 marks; already the codebase's default — keep as-is)

- **Geometry:** strict orthogonality where the room allows it; perfectly even
  spacing (`_place_along_wall`'s uniform-gap algorithm is correct for this lane and
  should stay the default); symmetric groupings; rectangles and evenly-divided rings.
- **Line weight:** uniform 1-2px, no variation within a single object.
- **Palette:** existing `PROP_COLOR` (58,62,72) / `PROP_RIM` (90,96,108) /
  `PROP_DARK` (38,40,48) family, plus the existing functional accents
  (`HAZARD_COLOR`, `SCREEN_COLOR`, `HYDRO_TRAY`/`RIM`, the medbay cross red). Regular,
  desaturated, "maintained."
- **Wear model:** clean at low descent, degrading toward panic/disorder (askew cots,
  dimming screens) at high descent — but disorder reads as *abandonment*, never as
  *alien intrusion*. Keep those two decay languages visually distinct.

### Testator lane (`chapel`, `core`-as-reactor, `otherworld`; currently unimplemented)

- **Geometry:** deliberately non-orthogonal — irregular spoke/ring spacing (jitter
  angle and radius per element rather than `2*pi*i/n` even division), off-grid
  orientation (rotate the whole fixture group to the room's own asymmetric axis
  rather than to a wall's tangent), asymmetric groupings (odd counts, uneven gaps).
- **Line weight:** vary width per segment (1-3px) rather than the MIRIAD lane's flat
  1-2px — reads as hand/tool-worn rather than machine-tooled.
- **Palette:** a distinct cold accent family, separate from both MIRIAD's warm ambers/
  greens and the Commando/seed's reddish-organic family — e.g. a violet-grey or
  bone-cold hue in the `OW_FLOOR` (52,64,58) neighborhood, extended into a
  `TESTATOR_RIM`/`TESTATOR_DARK` pair reused across `chapel`/`core`/`otherworld` so
  the three kinds read as one visual family. (`otherworld` already half-has this via
  `OW_FLOOR`; extend the same treatment to `chapel` and `core`.)
- **Wear model:** old, not decaying-in-real-time — pitted/weathered from a million
  years, not from the outpost's few months of occupation. Should look categorically
  older than even the most corrupted MIRIAD room, not just "further along the same
  decay ramp."
- **Hybrid rooms** (`chapel` specifically): draw the Testator-lane base geometry
  first, then overlay MIRIAD-lane furniture visibly out-of-register with it (angled
  off the room's true axis, a slightly different material tone) — the mismatch
  between the two lanes *is* the "found, not built" read.

### Commando/seed lane (3 marks; already implemented correctly — protect, don't touch)

- **Palette:** `GROWTH_FILL`/`GROWTH_RIM`/`TENDRIL_COLOR` (reddish-organic),
  distinct from both lanes above.
- **Geometry:** organic polylines/blobs, already correctly irregular.
- **Rule for future authors:** never reuse this palette for genuine Testator marks —
  it means "the Commando's seed has been here," a specific and different claim from
  "the Testators built this."

---

## 4. Priority-ordered change list

1. **`_props_core` split** — separate the l10 Perihelion-Core/reactor usage from the
   l07 MIRIAD staff-mind-closet usage. Either a new `mindcore` kind with a rack/LED/
   cable-tray generator, or a descent/context branch inside `_props_core`. Fixes
   mark #21's unjustified-placement finding.
2. **`_props_chapel` hybrid rework** — Testator base geometry (irregular dais/ring)
   under visibly improvised MIRIAD pew/altar furniture, replacing today's uniform
   `PROP_COLOR` pews. Fixes mark #17's unjustified-as-executed finding and gives the
   room the job pilot_texture_lib.py already assumed it had.
3. **Testator accent palette** — add `TESTATOR_RIM`/`TESTATOR_DARK` (or equivalent)
   and apply to `chapel` and `core`-as-reactor so all three `TESTATOR_KINDS` rooms
   share one distinct, non-MIRIAD visual family instead of two of the three using the
   default palette. Fixes the "zero Testator visual language" core finding for the
   two kinds `otherworld`'s floor tint doesn't already cover.
4. **De-regularize `_props_core`'s ring/spoke geometry** for the true reactor case —
   jittered spoke angle/radius instead of perfectly even `2*pi*i/n` division. Fixes
   the look-mismatch half of mark #21 (even after the split in #1, the reactor case
   still reads too regular for "non-human geometry/asymmetry").
5. **Correct the Congregation-cross job description** (mark #29) — the docstring/
   comment at render.py:1131-1133 claims multiple past visitors ("the faithful went
   down, and kept writing"); the mechanism is single-Commando, RNG-placed, untied to
   actual death history. One-line comment fix: reframe as his own reflexive habit
   under danger, not a memorial record. Zero code change, prevents a future writer
   from building on a job description the implementation doesn't back up.
6. *(lower priority, no active bug)* Add a lint/assert against untagged rooms
   silently falling through to `generic` outside the pure-graph tier, protecting
   mark #22's currently-correct-but-fragile status.
7. *(lower priority, documentation only)* Reconcile `pilot_texture_lib.py`'s
   `TESTATOR_KINDS` set and `KIND_MATERIAL` strings with this audit's findings once
   items 1-4 land, since the texture-prompt tool's classification predates and is
   more confident than anything `render.py` currently draws.
