# TESTATOR DESIGN LANGUAGE (working doc, 2026-07-10)

Director's framing: the Testators are neither human-derived machine (that's
MIRIAD's lane) nor truly extradimensional (that's the invaders' lane). They
are a third thing: machine successors of organic creators they revered, who
fought geometry-dissolving invaders for ages, lost slowly, and spent their
extinction writing a will to strangers. The design language has to say all
of that without a word of text.

## The four authorship lanes (visual constitution)

| lane | who | geometry | repetition | wear |
|---|---|---|---|---|
| MIRIAD | human-derived utility | right angles, grids | modular, identical parts | use-wear: scuffs, grime, patched repairs |
| TESTATOR | machine heirs of the organic | curves, radial, folded self-similarity | NEVER repeats, always exact | time-wear: worn smooth, re-cut, curated decay |
| SEED | the Commando's growth | organic tendril | branching | fresh, wet, spreading (exists: GROWTH_FILL/TENDRIL) |
| ADVERSARY | the unfolders | inconsistency itself | anti-pattern | not wear — dissolution |

## Core principles

1. ONE-OFF PRECISION. Humans standardize because manufacture is expensive;
   MIRIAD inherits that (every bracket identical). The Testators had no
   scarcity and no assembly lines — every element they made could be, and
   was, unique. So the signature is: perfect execution, zero repetition.
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
