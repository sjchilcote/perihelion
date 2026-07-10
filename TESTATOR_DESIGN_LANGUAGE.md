# TESTATOR DESIGN LANGUAGE (director-ratified, 2026-07-10)

Director's formulation, verbatim law: MIRIAD = machine efficiency, vector
art, industrial signage. Invaders = total chaos, NOTHING EVER STATIC — the
walls breathe. Testator = machines weaving homage to the living things they
could not save into every artifact. "They gave up, while the works of Man
refuse to" — the Testators accepted extinction and spent it on an elegy;
the human lineage (MIRIAD, the outpost, the Commando) is defined by
refusal. The station is the TESTAMENT — built to save *someone*, and
corrupted (§4.3: the Adversary hijacked the gift).

Director's framing: the Testators are neither human-derived machine (that's
MIRIAD's lane) nor truly extradimensional (that's the invaders' lane). They
are a third thing: machine successors of organic creators they revered, who
fought geometry-dissolving invaders for ages, lost slowly, and spent their
extinction writing a will to strangers. The design language has to say all
of that without a word of text.

## The four authorship lanes (visual constitution)

| lane | who | geometry | repetition | wear |
|---|---|---|---|---|
| MIRIAD | human-derived utility | right angles, grids | modular, identical parts | use-wear: scuffs, grime, patched repairs — REFUSAL. Everything visibly kept alive past its design life: jury-rigs, mismatched replacement parts, hand-painted supplements to printed signage. The works of Man refuse to die, and the wear language says so. |
| TESTATOR | machine heirs of the organic | curves, radial, folded self-similarity | NEVER repeats, always exact | time-wear: worn smooth, re-cut, curated decay |
| SEED | the Commando's growth | organic tendril | branching | fresh, wet, spreading (exists: GROWTH_FILL/TENDRIL) |
| ADVERSARY | the unfolders | inconsistency itself | anti-pattern | not wear — dissolution. NOTHING EVER STATIC: invader-touched surfaces must move — the walls breathe. |

MECHANICAL CONSEQUENCE (new requirement from the breathing-walls law):
static textures are sufficient for MIRIAD and Testator lanes but NOT for
Adversary-touched spaces (otherworld, late corruption). Those need a
time-varying surface treatment — candidates: per-frame low-amplitude UV
warp on OP_TEX_FILL's inverse transform (cheap, in-raster), slow palette /
darkness-field drift (partly exists via the otherworld inverse-field
compositing), or a two-frame texture crossfade. Phase with lighting, not
with the pilot; the pilot's static otherworld textures are placeholders
for judging fidelity only.

## Core principles

1. ONE-OFF PRECISION, BECAUSE EVERYTHING IS HANDCRAFT (director's law:
   the Testators have no industrial society — perhaps their makers did
   not either. Everything is a handcraft, INCLUDING THEMSELVES). No
   assembly lines ever existed in their lineage: each Testator was a
   made, individual thing, and each thing they made was made once, by a
   maker, with a maker's idiom. Humans standardize because manufacture
   is expensive; MIRIAD inherits that (every bracket identical). The
   Testator signature is the opposite: perfect execution, zero repetition,
   and a faint individual "hand" — two artifacts doing the same job solve
   it differently, the way two master smiths would. Consequence for the
   station's autonomous defenses (enemy class 2), elevated to canon by
   the director: the corrupted turrets and defenders ARE TESTATORS — the
   lowest caste, sub-sentient machines of the same handcrafted lineage.
   This answers the mystery table's "where did they go": they've been
   here all along; the scavenged equipment and the enemies you fight are
   Testators. Each unit is a handcrafted individual, not a production
   run — one-of-a-kind within its role, a person-shaped absence when
   destroyed. Visual rule: class-2 enemies and scavenged Testator
   equipment carry the full Testator language (one-off precision,
   phyllotactic ornament, bone/verdigris palette) UNDER their corruption
   — corruption is a defacement of the elegy, never a replacement of it;
   they must not read as invader chaos or MIRIAD product. The weapons
   the player scavenges are the same caste: wielding one is wielding a
   member of the tomb's people — material for the docents and the faith
   axis.
   Two Testator rings are never the same two radii; the spacing is never
   uniform; and nothing about it reads as damage or noise — it reads as
   a decision made freshly every time. (The invaders, by contrast, have no
   consistency AT ALL; the Testator language is individually-consistent,
   globally-unrepeating. That's the exact middle of the director's "neither
   human nor extradimensional.")

2. PHYLLOTAXIS AS MEMORIAL. They revered their organic creators. Their
   ornament quotes biology's mathematics — golden-angle (137.5°) radial
   placement, Fibonacci-gapped ring spacing, spiral growth laws — executed
   in dead-perfect machined alloy. Nature's non-repeating patterns, drawn
   by something that no longer had a body. This is the single most
   implementable rule: wherever MIRIAD would space things evenly, the
   Testators space by golden angle / golden-ratio gaps. Reads instantly as
   deliberate-but-not-human, is one line of code, and IS the reverence.

3. HOSPITALITY COMPUTED, NOT REMEMBERED. The station is a classroom with
   good chairs, built by minds that inferred what embodied visitors need
   rather than remembering it. So the furniture is right but subtly
   over-solved: seats face sight lines a human architect wouldn't have
   privileged, clearances are exactly sufficient everywhere (no habit-
   driven slack), amenities appear precisely where a tired creature would
   want one — uncanny thoughtfulness, never wrongness. Comfort designed
   from first principles.

4. THE DEPTH GRADIENT = ABANDONING EMBODIMENT. Canon: their final
   generation left bodies behind, and the architecture tracks that drift.
   Shallow Testator spaces (chapel): curves + furniture + floors — still
   for creatures. The true core: the furniture thins out, ornament becomes
   pure fold-notation, floors become nominal. Implement as a lerp on the
   existing descent parameter: furniture density down, geometric
   recursion up.

5. FOLD-NOTATION AS TEXT. MIRIAD writes linear labels and barcodes. The
   Testators write in nested self-similar geometry: a polygon containing a
   smaller rotated copy of itself, arcs that reference other arcs — their
   inscriptions are diagrams of spatial connection, and (pedagogy!) the
   diagrams are lessons: the decoration near a non-Euclidean join quietly
   diagrams the join. Attentive players can learn to read the room.

6. TIME-WEAR, CURATED. 1.1 million years, but the station maintains
   itself. Testator surfaces are not grimy (MIRIAD's lane) — they are worn
   the way a cathedral threshold is worn: edges rounded by eons of
   cleaning cycles, engravings re-cut so many times they've softened,
   deliberate patina on everything non-critical (a tomb is kept AS a
   tomb), flawless finish on everything mission-critical (the armory
   gates). Wear is where the station CHOSE not to repair.

## Palette

MIRIAD owns cool structural grays + amber hazard. Adversary owns the
inverted/cold sensor look (otherworld already has OW_FLOOR). Seed owns
red-organic. Testator accent: aged noble alloy — deep bronze-verdigris
range with a pale bone tone for the memorial/inscription elements
(bone: the creators they revered). No pure saturated hues; everything
reads as one material that has been one material for a megayear.

## Mechanical rules for the prop pass (DECAL_DIEGESIS_AUDIT follow-up)

- Replace uniform radial spacing with golden-angle spacing in all
  Testator-attributed generators (true core reactor, chapel dais/rings).
- Ring radii sequences: golden-ratio gaps, not linear.
- Line weight: MIRIAD 1px uniform; Testator variable 1-3px, arcs > lines.
- Chapel = hybrid per audit: Testator floor geometry (irregular ring,
  off-grid dais, bone-tone inlay) under visibly improvised MIRIAD
  furniture in plain PROP_COLOR (the outpost dragged pews into a room
  that awed them).
- Split _props_core: l07 staff-mind closet gets MIRIAD server language;
  l10 reactor keeps the mandala but de-regularized per the above.
- Texture prompts for Testator kinds inherit all of this verbatim.
