# First-pour frame review — 2026-07-26 overnight

**Capture:** `tools/playtest/marrow_demo.py out/marrow_pour --ticks 18000`
(gauntlet4, HumanBot full loadout, 3 seeded scouts). The full ratified arc
happened unscripted: scout call → breach opened t2576 → the shelf poured in
its exact order (3 mites, 2 husks, spitter, shrieker, flicker, brute,
warden) → production took over → 285 body crossings → idle self-seal t8825.
One lacuna survived; the dead scouts are permanently gone from the census.
Video: `out/marrow_first_pour.mp4`.

**Review:** 8 vision reviewers over the breach window (frames 460–1795,
every 5th). **0 P0.** Bodies unsquashed in every span (the scale-1 gate
holds visually); no seams, smears, or HUD defects; the early fight reads
(player gives ground, hp drops, ammo drains, salvage climbs).

## Findings and actions

1. **The breach under-read at farm zoom** (4 spans, P1): a 16px ring read
   as "a dark knot/smudge — a director would ask 'what is that dot?'".
   FIXED same night: the tear is now sized against its 96u seam (26+6px
   core, doubled rim, outer bruise + halo ring), and every open breach
   sheds a REAL violet light (born with the breach, dying with the seal)
   that washes the invaded chamber — verified in-situ
   (`out/breach_tear_v2.png`). Re-review at play zoom comes with the U15
   content pass.

2. **Markers/entities over LOS blackness** (P1/P2 in 2 spans): the amber
   threat triangles (an overlay, by design) plus the breach ring itself
   drawing against unlit floor, and two small overlay glyphs in the void.
   Same class as the canon-probe finding — a standing director-taste
   question on overlay occlusion, logged for U14, not churned tonight.

3. **Mid/late pour pressure invisible at the camera** (2 spans, P1): the
   bot outruns the stream; ~50s into the pour the camera sees a nearly
   empty station while 20+ bodies exist near the breach. NOT a render
   defect — a pacing/behavior measurement: the stream hunts fields near
   the breach and loses a sprinting target (stand-down and Trail decay
   working as specced). This is exactly the "reinforcement stream vs
   mobile player" pressure question the killbox measurement (U16) exists
   to answer; input logged.

4. Nits: pre-breach idle pack near a pinch (quorum wake correctly needs
   noise/sight — they were parked by design but read "blind" at this
   zoom); one-frame LOS flicker during a turn (known consecutive-frame
   ambiguity class); projectile dots vs pickup dots at farm zoom.

## Live findings for U15 (measured, not speculative)

- gauntlet4's own sentries shred unescorted scouts near the start; scout
  authoring must respect sentry coverage.
- A call from a small-walled chamber returns `dry_no_site: no wall holds
  a 96u seam` — Sol's geometry-migration conflict observed in-game.

## Play-zoom re-capture (same night, after the tear v2 fix)

`out/marrow_pour_close` → `out/marrow_pour_playzoom.mp4` (zoom 1.35, the
shipping camera). Richer run than the first: ALL THREE apse seams opened
(t2019, t3235, t7841) and the stream ended the session — cornered the
bot in a throat and killed it at t10757 with 2 lacunas still alive. The
marrow can now win on film.

**Personal frame audit (11 frames across the arc):** pre-breach station
reads clean; mid-pour convergence legible (wardens + doorway arrows);
corpse fields accumulate correctly; the v2 breach ring + violet
breach-light wash both read unmistakably at play zoom (fr410, fr1200,
fr2130); two wardens wind up engulf charges point-blank (fr1570, the
white-hot rim tell); final frame is a proper death — hp 0, vignette,
wardens overhead. No seams, no squashed bodies, no HUD defects, no
overlay-in-void instances spotted at this zoom. The farm-zoom P1
(breach under-read) is CLOSED by this capture; the overlay-occlusion
taste question (U14) remains open.
