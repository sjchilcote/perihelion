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

## Runs 48-49 (7/28): the engine program lands

The perf program (engine owns pixels: lightmap/ow-compose/post/decals/
sightline/sentry/SignalField into necore; 13ms -> 2.6ms p50 / 4.8ms p99)
went to the gate with the UI de-pygame conversion. Run 48 FAIL p=0.57:
the renderer rewrite came back clean on every seed, but the judge
priced the old march-grind watch item at full depth — units frozen
6120-8220 ticks in active states, second acts flatlining. Fixes: awake
units always keep their chamber active (lurk excepted — it is rest),
march stall-breaker (5s sidestep, 15s shed-the-tag on the record),
shrieker stand-down after 45s with the squad. Run 49 PASS p=0.96, zero
blockers. Seed 4's quiet tail held up as the suppression design (all
scouts dead, marrow blind, zero calls) rather than a defect. Landed as
618b89f6e6..bd8e440e57, 768 tests green.

## Runs 50-51 (7/28): pygame eliminated

The platform layer moved into the engine (winit window + input,
softbuffer present, cpal mixer, png writer) and every pygame call
site in game/tests/tools converted. Run 50 FAIL p=0.04 — six
blockers, ALL in the port itself, all on live paths the films and
the old suite never walked: plated UI text crashed on a changed
fb2d.rect signature, the SFX pool was unbounded (2.3-3.7x clipping),
a chunk queued on an idle channel never started (PRAYER died after
any stop), OS auto-repeat flooded KEYDOWNs (pause menus stacked),
button events had no cursor position (editor first-click crash),
and screen shake was silently dropped. All six fixed at the source
and pinned in test_platform_contracts.py.

Run 51 PASS p=0.96, zero blockers. The judge's verify pass proved
the diff behavior-preserving where it must be (seed-7 session ends
at the identical tick; trace.jsonl byte-identical through the full
render+audio path) and better where it touches audio (loops off the
SFX pool, 1:1 sound-event causality on all four seeds; the old
pygame pool measured empirically WORSE). Every blocker-class claim
from 18 scanners died under adversarial verification. Carried watch
items ledgered in verdict.json: live 12-voice saturation drops
audible one-shots (pre-existing, two-part fix filed), woken hub
residents in one-door chambers, telemetry gaps (enemy positions,
first-class death record), chassis design-text drift, sentry
alert sound reuse.

Landed as five per-unit commits (engine platform module; audio/music
port; app/ui window loop; tests/tools sweep; dependency removal).
807 tests green. pygame-ce is out of pyproject; the runtime is
necore + numpy + soundfile.

## Run 52 (7/28): the carried watch items close

Run 51's ledger, worked through: the SFX pool now culls inaudible sends
before they claim a voice (17.8k silent sentry sends per session were
each able to evict something audible), holds 24 voices instead of
pygame's 12, and steals the QUIETEST voice for a louder newcomer rather
than dropping the newcomer — measured unmuted, enemy deaths voiced 28%
-> 54%. The sentry got its own generated voice (it had been firing the
player's pistol). Telemetry gained bulk enemy-position snapshots, x/y on
every AgentTransition, a first-class player_death record, and the
missing PickupTaken branches; ground_truth path-integrates movement
instead of the bounding-box diagonal that under-read a patrolling warden
9.7x. Two behaviour leaks closed: a scream-woken shrieker no longer
screams back, and a hunt that has pushed a one-door chamber's only
doorway for fifteen seconds with nothing in sight stands down on the
record. And the chassis design-text drift: the starting pod always
prints (DESIGN_7_25's infinite backup chassis), while protected_revival
finally buys the grace window the mindmap promised.

PASS p=0.96, zero blockers. The judge confirmed every targeted item
closed or materially improved, found the run-49/51 shrieker signature
absent from all four seeds, and filmed every beat of seven deaths.
Landed as three commits.

Operational note: waiting on the gate is now `tools/playtest/gate_wait.sh`.
Run 51's verdict sat unread for twenty minutes because the ad-hoc watcher
grepped for `gate.sh` and matched its own command line — it waited on
itself. gate.sh writes gate.pid and gate.exit; the waiter polls those and
distinguishes PASS, FAIL, killed-mid-run, and timeout.

## Run 53 (7/28): FAIL p=0.92 — the marrow visual pass, and a machine
## that ran without ever firing

The diff: all 24 hub chambers reshaped from rectangles into one-off
convex biogenic shells, the corruption gradient carried into the
cathedral on a crossfade centred at depth 6, and U10 — the shrieker's
mark — salvaged from the ratified b2c27600.

The geometry passed cleanly, which was the risky half: six film
scanners over ~700 frames on four seeds found zero wall-embedding,
zero tunneling, zero portal pile-ups, and no chamber reading as a
rectangle, with the kind boundary reading as two architectures and
the seed-4 negative control (hub never connects) showing zero palette
leakage. 844 tests green.

Four blockers, every one a thing that runs but does nothing:

1. **The WARNING arc was dead code.** `home` was assigned at the
   sighting instant, so "run home to raise the squad" exited on the
   next tick. Its unit test passed only because it pre-set `home`.
2. **APPROACH had no exit but LOS or death.** 26 shrieker hunt
   entries, 0 hunt->idle, seven callers ending the session in
   permanent hunt (up to 11062 ticks), each holding its chamber
   active forever. RALLY->SENTINEL had zero execution coverage.
3. **Wall-pinned hub garrison**, novel to the new facets: five
   non-dispatched bodies held one coordinate for 24-128s.
4. **PlayerDeath.source lied on 2 of 3 deaths**, and the periodic
   instrument samples were still dropping 4-9% of their ticks —
   re-diagnosed as hitstop, not the death lingers fixed in run 52.

And the ledger's sharpest observation: ONE mark landed in 64 minutes
of play, against a spec that calls tailing-and-marking a defining
behavior.

## Run 54 (7/28): the blockers, root-caused

Each blocker was reproduced before it was fixed, and the reproduction
is what changed the diagnosis in three of the four cases.

**The pin was not the stall-breaker's absence.** A headless rerun of
seed 2 recorded the wedged brute's own steering: it held a *correct*
heading at its doorway, want=(0.70,-0.71), the exact bearing of the
portal midpoint, and never moved for 3969+ ticks. The grant was
(18.4, 200.2) — separation taking its capped 0.7 of the budget and
spending it pushing the body INTO the facet, with the objective's
remaining 0.3 unable to overcome it. The peer generating the demand
was a core organ body, which never moves, so the demand never decayed.
The 0.7 cap (added when packed muster rooms jammed) bounds the claim
but not its futility. The rule now: a keep-apart demand that is not
increasing the gap yields the budget entirely, and stays yielded until
the body is genuinely clear of where it stuck — releasing on the gap
alone just re-pins it, which measured 1.4u of travel in 400 ticks.

**The mark could not fire, arithmetically.** Instrumenting the branch's
own gate conditions over a full session: 15 of 15 in-range marking
ticks sat inside the player's forward cone, and the lock never started
once. The lock demanded the caller slip outside his ~120° front arc —
a condition on the player's INSTANTANEOUS aim, and the Commando turns
instantly at whatever he sees. A gate the mechanic cannot pass is not
difficulty, it is deletion. Two further changes followed from the same
measurement: the tag may now be taken from one doorway away (the
sightline is portal-composed and the marker flies through the door;
demanding depth 0 confined the tag to the chamber where a caller lives
13-37 ticks), and a started lock sees itself through a broken
sightline — it fires at where he was, and can miss.

**SENTINEL was deaf.** The machine woke only on its own sighting; the
generic path it replaced also woke on the fractional quorum and on
damage. Both are restored through the SHARED doors — the same quorum
every idle watcher runs, and `last_hit`, which only `_damage_enemy`
writes. The anti-latch property is preserved by construction: the
quorum commits to APPROACH *uncried*, so another caller's Distress can
send this one LOOKING but can never make it SCREAM. WARNING now also
refuses to hand off before the cry actually leaves it — a caller
standing on its own post with a hot cooldown used to fall straight
through to the tag having raised nothing.

Measured on seed 2, 14400 ticks, before -> after:
FSM phases {sentinel: 6214} -> {sentinel: 292, approach: 3096,
warning: 455, marking: 152, rally: 36}; markers fired 0 -> 2;
worst hub hunt-stillness 3969t -> 240t.

Instrument note: `consult_adversary.py`'s packet gate refused a clean
packet, having scraped the translation lexicon's LEFT column — ordinary
English descriptions of each concept — as if it were the banned
vocabulary. It now reads the lexicon's own banned-list section and
refuses to run at all if that section is missing or parses short. A
checker that fires on correct output teaches you to override it.

## Run 54 (FAIL p=0.89) — the stand-down was cosmetic under alarm

All four run-53 blockers certified dead in situ (WARNING travels home,
median 117t; patience ceiling exact at 2701t, zero permanent hunters;
631 wall-pins certified gone, the run-53 sites now roam 519-3338u; mark
rate 8x with both filmed marks fully legible). The judge's adversarial
pass then found the machine I had just given an exit could not USE it:

**Quorum self-excitation.** s4 e406: `shrieker_stand_down` ("nothing
calls") at t=7310, hunt re-entry at t=7414 — 104 ticks later, standing
in nearly the same spot. Mechanism, confirmed in code: WARNING deposits
DISTRESS 0.25 every 15t along the run home; DISTRESS carries a 45s
half-life, so the residue was effectively undecayed when the unit
returned to SENTINEL inside it; the quorum door sampled that same field
and re-committed. Its own scream is zero bits — it already knew it
screamed — but the door double-counted it as fresh evidence. A
refractory cannot fix this honestly (any window short enough to be
reasonable re-latches at a longer period; the residue outlives minutes)
and per-entity field attribution is machinery. The structural fix
mirrors the ratified MUSTER precedent — a guild's own calling never
drives the guild's own door: the caller's commit door hears NOISE only.
Gunfire is what a firefight actually is, pours at 0.8-1.0/shot against
EXCITE_NORM 0.6, lives 3 seconds, and physically cannot latch anything.

The seed-4 re-probe then caught the SECOND latch channel behind the
first: with DISTRESS excluded, every fast re-commit (19-209t) ran on
the committed-peers term alone — committed==peers (3/3, 5/5) at noise
0.000-0.015. A caller posted in a garrison of permanently-hunting
bodies re-armed off the CROWD; and all that crowd-driven tenure
(12661 approach ticks on seed 4) bought zero markers all session —
pure dead patrol. So the door is now LIVE only while local Noise is
not FAINT: the same STAND_DOWN_FLOOR (0.05), in the same ratified
sense, that lets a hunter exit. A crowd alone is not a call; peers
amplify a live fight (cascade wake), they never substitute for one.
Sight and damage doors are untouched.

Probes with the film's exact reprint loop, before -> after: seed 4
flap dead (4 fast re-commits -> 0; callers hold posts, honestly quiet
— no fight ever crossed their ground); seed 2 keeps its full chain
(warning 117t -> marking 418t -> marker_fire -> brand_renew, matching
the film's 1 landed mark); seed 7's single pre-fix mark did not recur
(its one chain started first-hand and ended before regaining LOS — a
Poisson-1 event under changed contact geometry). Bank-level mark rate
~1/16min vs 2/16min pre-fix: the rate the POST design produces once
evidence-free roaming stops manufacturing contacts. The one fast
re-commit left anywhere (s2, +32t) is gunfire-justified — the door
opening for a real fight next door, which is its purpose.

**The marker borrowed the scream** (run-53 note, now a blocker): the
launch — the one dodge cue the mark machine gives the player — played
`shrieker_scream`. It has its own voice now, `marker_launch` (a wet
pneumatic thwip and a falling doppler whistle: a trajectory, not a
throat), authored in the soundgen bank next to `mark_hit`, whose
docstring already stated the law.

**The mark machine was invisible to the trace** (run-52 directive,
two gates late): both filmed mark_hits were orphan sounds and phase
tenure was unmeasurable. `_shrieker_phase` is now the one writer of
the phase key and every transition records itself (`shrieker_phase`
frm->to); `marker_fire` records the shot; `brand_renew` (fresh|renew,
with source) and `brand_expired` bracket the brand's whole life.

Tests: the door test discriminates by construction — arm 1 saturates
the caller's chamber with DISTRESS and holds until first legitimate
sight (mutant run against the pre-fix door: fails at the in-loop
assertion); arm 2 proves NOISE alone still commits it, so the run-53
deafness cannot return. Two arena lessons cost an hour: an unreachable
island chamber gets no AI at all under ACTIVE_HOPS (a wax-museum pass),
and the patrol has no leash, so any connected arena eventually yields
legitimate sight — the hold-window must END at first sight, which is
exactly the law being asserted anyway.

Watch items (judge "review", not blockers): DISTRESS in the generic
hunter stand-down peak vetoes stand-down for ~105s per cry train (45s
half-life vs STAND_DOWN_FLOOR 0.05) — s4 mite 9974 hunted 7684t on it.
From the mite's side the cry is world-signal, the alarm doing its job;
whether ~2 minutes of sustained aggression per scream is the intended
difficulty is a design question for the next gate's film, not a patch
tonight. The warden still borrows `shrieker_scream` (alert + engulf
lunge) — same class as run-51's sentry borrowing pistol_fire; needs its
own voice in a later pass.
