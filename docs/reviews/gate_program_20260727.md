# The filmed-playtest gate program — 36 runs, 2026-07-26/27

## The trajectory

Chunk-score mean (what the frame judges measure, per bank) climbed
from 0.47-0.61 (runs 1-8, the bug era) through 0.67-0.78 (runs
12-24, the legibility era) to a stable 0.76-0.86 (runs 26-36, the
polish era). The final bank: seeds 2/4/7/11 = 0.83/0.86/0.75/0.80,
several chunks with zero or one finding.

The final-verdict scalar p climbed 0.03 -> 0.62 through the same
arc but then plateaued, oscillating 0.15-0.62 with no correlation
to chunk quality in the last ten runs (0.81-mean bank -> p 0.35;
0.80-mean bank -> p 0.62). The verdict judge synthesizes a blocker
narrative from whatever unverifiable single-frame claims survive,
and its gestalt does not integrate the chunk evidence.

## What the program fixed (all verified on film, all in the tree)

Every AI-brokenness class: kill-cone door camps, muster self-locks,
fold standoffs (field + sighted watchdogs), hold patience, sponge
wardens (diagonal weave), scout state thrash, untasked scouts that
would not flee, hub-stranded scouts starving the call channel,
omniscient conga lines, contact stunlocks (universal knockback +
hit-and-run flickers). Simulation honesty is certified per bank:
HP/damage/ammo tick-exact, warden movement spans in ground truth,
zero desyncs. The signature loop lands on film: tear + violet wash
(2.5s), pour burst, seal wash, death-as-translocation reprints.
Readability at the director's 0.45 zoom: tiered minimum silhouettes,
two-tone flicker rim + pounce streak, spit streaks, attacker marks,
pickup floaters, capped vignettes, death surge.

## What remains, bucketed

1. DESIGN (director rulings): pacing texture between pours (beacon /
   census / staging levers; dead-air analysis ranked them), payoff
   staging vs a kiting camera (arrest positions, U16), ambush
   telegraph strength taste.
2. BOT (its own program): does not fire at contact-range ambushers;
   abandons its own sentry killboxes mid-fight; camps turret nests.
3. INSTRUMENT: the verdict scalar needs mechanical calibration
   (e.g. p from confirmed-finding density x chunk mean) or a
   multi-bank pooling rule; single-frame UNVERIFIABLE claims need a
   default (currently they survive into blocker narratives).

## The asks

- Rule on the verdict formula (mechanical vs gestalt).
- Rule on the design levers above, or schedule U16.
- Decide whether the ~40-commit-equivalent gameplay diff ships at
  the current verified state or keeps riding the loop.

## Post-collapse addendum (7/27, runs 40-42)

The 198-line judge prompt was ruled prompt theater ("give it the
north star as I gave it to you, and nothing else — more instructions
is worse"). GATE_PROMPT.md collapsed to 34 lines: the north-star
question, reference class, scope, the Bayescraft/workflow orders,
and bare operational pointers. The judge is Fable in this repo — it
gets Bayescraft from CLAUDE.md and reads DESIGN_7_25.md itself.
Two judge-obedience errors were also reverted under the corrected
legibility law ("mechanics happening ON SCREEN must be clearly
visible; off-screen events need no representation"): the dry-call
sfx (there is no "finite economy tell" — my invention) and, earlier,
the flicker visibility spiral.

Run 41 — the first under the minimal prompt — was the sharpest
verdict of the program (p=0.05): it located, to the line, that the
run-39 transit fix was a no-op. activate_also() widened only the
ENGINE active set (physics); _enemy_ai rebuilt its own
player-centered BFS and never consulted it, so dispatched units
kept physics and lost their minds beyond ACTIVE_HOPS: 28-39 of ~70
units/seed frozen mid-transit, economies draining into a dead hub,
every late breach sealing unwitnessed, the last third of every
session filmed as empty corridor. Less prompt produced a better
judge.

Fixes (verified before run 42): the engine now exposes the one
canonical active set (active_polygons()) and _enemy_ai consumes it;
warden sidestep lifted above the sighted-branch gate (two s7 wardens
had sponged 19 hits with zero dodges); player death unified into
_player_death (the engulf branch died silent — no sound, fx, corpse,
or component drop). Fresh s7 film: 74/76 dispatched units reached
the world (was ~half), shriekers 10/11 (their "kind-specific"
failure was the same bug); both stragglers were end-of-session
dispatches. 742 tests green.

## Runs 43-44: the verdict moved up a layer

Run 43 (p=0.03) certified every historical blocker fixed — delivery
97-99%, sidestep pixel-tracked, the engulf death "the strongest beat
in the footage" — and moved the fight to pacing/economy and on-screen
spectacle. Its blockers all verified at mechanism level:
- Seam starvation was CAUSED by the delivery fix: delivered bodies
  kept their transit tags, route interest pinned every breach open,
  all 3 apse seams consumed in 85s, later calls dry. Fix: delivered
  means delivered — the tag drops at the world mouth; breaches
  idle-close and seams return. Every seed now re-opens breaches
  after seals (spectacle recurrence).
- The black second-death was death ORDINAL: the renderer's fade
  latch never reset after a reprint (first death always filmed
  perfectly — "passes casual testing, fails players"). Reprint now
  emits playerreprint fx; renderer resets.
- Flicker bite metronomes: bite RECOIL (director clarified the
  flicker ruling was visibility-only). One fixed impulse, mass does
  the tiering — flicker rebounds ~3 radii, warden shrugs.
- Door-thrash took three passes to actually kill: (1) anti-backtrack
  ×0.25 in _hunt_edge — halved it; (2) march memory in the hub
  override (next_edge flips on breach-topology churn walked one mite
  across the apse-court door 947 times); (3) HARD backtrack block
  for 1s + the route-memo bypass (cached routes pointing at each
  other locked a 3-4-tick bounce the scoring never saw). Worst
  portal-pair counts: 947 -> 41-69 (ordinary traffic).
- Instruments: enemy_death + coord_event telemetry, truthful hold
  durations (last-held-tick, no wall-clock ghosts, no flutter),
  prowl proven reachable by test, ground_truth dry-fire metric
  fixed, carve-fallback marked in breach opens.
- Floaters 16px shadowed; seal light CONTRACTS as it dims (fade was
  mechanically perfect and perceptually flat — compositing
  saturates; the judge's photometry was right).

Run 44 bank (pre-judge verification): delivery 98% all seeds,
shriekers 36/38, transit 167-187t, all dances dead, deaths present,
ledger clean, prowl organic. Judge in flight.

## Run 45: PASS (p=0.97) — the program closes

First bank where every preregistered disconfirming outcome for the
changed subsystems either failed to occur or died under adversarial
verification with primary evidence (deterministic re-runs, pixel
tracking, photometry, code reads): delivery 300/301 at 172t median,
both second deaths film every beat, second-generation breach opens
tick-exact on film in all seeds, audio spatialization live (r=0.788),
sfx causality 1287/1287, zero door dances (the thrash alarm itself
was refuted as seam-straddle telemetry wobble, 0.03-0.09 px on
screen). One preregistered negative fired — three wardens stationary
45-76s in hunt, off-camera — and was probed sub-threshold (all-enemy
re-run: zero stationary hunt enemies co-present with the player
anywhere; 99% delivery; pressure intact). Watch items handed to the
task ledger: march-grind statue / delivered-tag activation hole,
flicker cadence at the cooldown floor, engulf cold-grip margin,
reserve dead-tail pacing (director's design bucket).

The accumulated diff landed as nine per-unit commits (engine active
set, telemetry, sim program, render, marrow, audio, bot, levels,
tests) through the open hook. 745 tests green.

## Runs 46-47 (7/28): the vocabulary redo lands

The director watched the demo video and reported five defects the
gate had passed: rings on every event (the aggro symbol spent on
kills, bites, grips), enemies vanishing instead of dying, turrets
doing nothing (polygon-scoped, 300u), bot and enemies ignoring each
other, and bodies/buildings leaking past LOS shadows (fixed-px mask
spill). One session of fixes -> run 46 FAIL p=0.92 (the warden-grip
branch made the new red attribution dead code; sentries took 57-68%
of killing blows) -> fixes + retune -> run 47 PASS p=0.97, zero
blockers, both run-46 blockers confirmed live on film (grip blink
pixel-proven at s4 f440; sentry share 29-49%, under parity).

Rulings ratified along the way: one symbol = one meaning (rings =
aggro only; body events on the body); hops are never a targeting law
(VISION_HOPS=12 is a cost ceiling, the raycast is the limit; "a
battlespace might cover TENS of polygons"); 0.45 IS the zoom (no
play-vs-film distinction; mousewheel zoom planned). Landed as
43f7bfd7 + 74c094fd, 748 tests green.
