# Canon-probe frame review — 2026-07-26 overnight

**Capture:** `tools/playtest/farm_record.py 2200 out/canon_probe --level
levels/gauntlet4.json --every 5 --max-ticks 12000` (farm-exact HumanBot, full
loadout). Outcome: **timeout at 12000 ticks — the bot survived** the full run
under the new canon (the push/fall-back HumanBot handles faster enemies; the
kiting AggroBot dies at ~2766 ticks on the same seed — the intended doctrine).
Video: `out/canon_probe_seed2200.mp4` (200s, real audio taps).

**Review:** 12 vision reviewers, 480 frames (every 5th captured frame = every
25 sim ticks), U0 renderer rubric + U2 combat-canon rubric. Full structured
results in the session workflow journal; adjudicated below.

## Verdict

**0 P0.** All 12 spans: layering clean, no frame retention, portal seams
clean, no rectangular light clips, text bitmap-sharp, HUD present and
sensible. Combat canon visibly reads in most fight spans: enemies close
distance on a retreating player, struck bodies displace continuously (never
teleport), large bodies re-approach in arcs instead of pivoting.

## Findings and adjudication

1. **hp "02" with a near-full bar** (5 independent reviewers, throughout).
   ADJUDICATED — GLYPH LEGIBILITY, FIXED. Deterministic replay shows hp was
   **82/100** at the flagged ticks; the HUD number and bar were never
   decoupled. FSEX's '8' rendered at 14px loses its waist and becomes
   indistinguishable from the dotted '0' (verified by rendering both through
   the game's own text path). The ratified rule (DESIGN_7_25 §4: FSEX always
   16px) was being violated by the HUD's 14px/12px sizes. Fix: all HUD text
   now ui(16); gate `test_hud_text_is_16px` pins it. At 16px the glyphs are
   unambiguous.

2. **Player readability at farm zoom** (P1, frames ~145-195). ADJUDICATED —
   CAPTURE ARTIFACT. The chevron is present and tracked; farm captures run at
   zoom 0.45 vs the game's 1.35, so the player is ~3x smaller than in real
   play. No renderer defect. If farm videos are meant for director review,
   consider capturing at play zoom.

3. **Light pool in unexplored black space** (P1, frames ~755-795).
   ADJUDICATED — HONEST COMPOSITE, reads odd. A lit projectile/pulse crossing
   a visible-through-portal room whose floor is essentially unlit: the light
   is real and correctly propagated; the floor beneath is too dark to see, so
   the pool reads as floating. Logged for the director as a legibility
   question (should near-black floors catch more of a transient light?), not
   a bug.

4. **Enemy clusters in LoS not pursuing** (3 spans: ~600-680, ~800-880,
   ~2245-2285). ADJUDICATED — REAL BEHAVIOR GAP, deferred to U5 by design.
   Idle enemies wake only by alert propagation or co-chamber proximity; a
   visible player one chamber away does not wake them. DESIGN_7_25 §3 ("fire
   on line-of-sight; it should not be possible to get more than 75% of a
   screen away without them becoming aware") requires sight-based awareness —
   which is exactly the U5 coordination rewrite (fractional quorum + senses-
   driven commitment). Input for U5, not churned tonight because U5 replaces
   the wake mechanism wholesale.

5. **Ammo counters jumping up without visible pickups** (2 reviewers).
   ADJUDICATED — off-screen/decal-obscured pickups by the bot (drop tables
   feed ammo on kills; the bot vacuums corpse drops). Counter logic is
   sim-side and covered by economy tests.

6. **Warning triangles over unlit space** (2 reviewers). By design: they are
   threat MARKERS (overlay), not bodies. Logged as a director-taste question.

7. Minor one-frame nits (screen-edge clipped marker, one-frame sprite at the
   viewport boundary, full-screen damage vignette washing occlusion for one
   frame). Logged, no action.

## The one deliberate combat observation

Reviewers could rarely isolate a single dramatic knockback shove at 25-tick
sampling; what they saw instead was continuous displacement under fire and
enemies that keep coming. The per-shot impulse numbers are first-pass values
(DESIGN_7_25 §1b discipline: structure fixed, numbers move) — the killbox
measurement (U16) is where push magnitudes get tuned against real outcomes.
