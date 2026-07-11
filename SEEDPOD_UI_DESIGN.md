# SEED-POD UI (director-directed design, 2026-07-10)

Naming (director-directed, 2026-07-11): the seed pods' official
hardware-class name is **CUCULUS** -- the UI identifies itself as a
CUCULUS unit in its chrome; colloquial "pod" stays colloquial in help
text. The mind page's tab carries the in-universe encyclopedia's name
(the mind map is the Commando integrating the public encyclopedia the
Church dumped on his pod's drive): working label **ENCARTA**, spelling
pending the director's confirmation -- a single constant in podscene.py
(`MIND_TAB_LABEL`) so the respelling is a one-line change.

Director's brief, verbatim anchors: upgrade and mindmap UIs become "pages
of a single full-screen UI that comes up whenever Commando re-enters a
seed-pod to heal, upgrade, and think." Mind-map expansion does NOT take
components — "it should be a separate resource. Maybe just _time_": you
pick what the Commando thinks about in the background, it fills as a
timer runs, and the node expands (neighbors appearing) when you next open
the UI after completion. "Make it a show — expanding a new mind map node
is a big deal, it should have some presentation, some juice — and maybe
corrupt the animation a little if it's a faith-reducing node, Commando has
been _ruminating_ and losing his faith."

Also ruled: enemies stay stylized sensor traces (rendering constraint
embraced — Testator enemies in full splendor would be visually noisy).
Testator EQUIPMENT gets its full glory in menus as confined hero images.

## Structure

One full-screen scene (native window resolution — this UI is the flagship
of the native-res mandate) that opens on E at any seed station. Entering
the pod heals (existing behavior, now framed by the UI). Two pages,
tab-switched:

1. FABRICATOR — everything components buy: chassis, station kits,
   weapons, gear. Left: item list (keyboard nav). Right: HERO PANEL —
   full-glory art of the selected item from assets/hero/<item>.png when
   present; absent art falls back to the item's vector glyph enlarged
   (never a placeholder). Testator scavenged equipment is where hero art
   pays off: handcrafted one-off splendor, confined where it can't
   clutter the field.

2. MIND — the map as a REAL GRAPH (the text-column exemplar dies here).
   Nodes positioned by region (regions as territory), prereq edges drawn,
   fog-of-war: only unlocked nodes + frontier (locked neighbors of
   unlocked) are visible. Keyboard nav walks edges.

## Thinking as a resource: TIME

- At the MIND page you choose ONE focus node from the frontier. No
  component cost. The Commando thinks about it IN THE FIELD: progress
  accrues in sim ticks during normal gameplay (menus don't tick — so
  thinking happens out there, under fire, diegetically).
- Progress and focus live in the sim (deterministic), persist through
  snapshots, cold restore, death, and chassis reprint — the mind
  survives the body by construction. Dying costs you loot, never
  thought.
- Node think-time derives from the old prices (price -> seconds mapping,
  single documented constant), so the existing progression curve's shape
  is preserved in a new currency.
- HUD gets a minimal unobtrusive think-progress pip; completion in the
  field emits a quiet fx cue ("a thought has finished") but the unlock
  itself waits for the pod.

## The reveal (unlock animation)

On opening MIND with a completed focus: the page auto-plays the
expansion reveal (~5s, skippable after first beat). The grammar follows the
authorship lanes (TESTATOR_DESIGN_LANGUAGE.md) — the UI itself speaks the
game's three languages:

- FAITH-POSITIVE nodes: PHYLLOTACTIC BLOOM. Graph dims, view glides to
  the node, it ignites and unfurls golden-angle petals; edges to new
  neighbors grow like tendrils reaching; warm bloom, choral-adjacent
  cue. The Testator lane: reverence, organic mathematics.
- NEUTRAL/TECH nodes: MIRIAD SCHEMATIC SNAP. The node assembles from
  clean vector parts — alignment guides flash, segments snap in, a
  drafting-table register; crisp industrial cue. The lane of the works
  of Man.
- FAITH-REDUCING nodes: CORRUPTED BLOOM. The bloom starts, then goes
  wrong — color drains mid-unfurl, petals go angular, the glide
  overshoots and corrects like a hand tremor, new edges arrive as
  cracks rather than growths; the cue sours, the ambient dips. The
  Commando has been RUMINATING. Small, wrong, unmistakable.

New neighbors fade in only after the animation — the reveal is the reward.

## Cut/changed from current build

- ShopScene + MindMapScene (text columns) are replaced by the pod scene.
- sim.buy_node (component-priced) is replaced by sim.set_focus /
  tick-accrual / sim.complete_focus (called by the reveal; fx via the
  _park_oob contract). Economy tests update to the time model.
- mindmap.json price fields become think-times (converted, not deleted —
  data field semantics documented in mindmap.py).

## Later (slots reserved, not built now)

- Hero art generation for Testator equipment via the image pipeline.
- Reveal sfx through the Gemini sfx pipeline (three cues).
- Mind-map region "territory" backgrounds per authorship lane.
