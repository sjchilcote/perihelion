# The everything-session — 2026-07-26, pre-dawn

**Artifact:** `out/full_marrow_session_seed4.mp4` (400s, zoom 1.35, seed 4).
An ORDINARY gauntlet4 session — no harness seeding, no scripts. Every
system shipped tonight is in frame or in trace:

- Authored scouts call on their own; **three breaches** open t1463/2207/
  2853 — all three apse seams committed.
- Two further calls return **dry: "no free apse seam"** — a brand-new
  tell on film (the marrow's inventory is finite and visibly so).
- 39 dispatches pour; **6 know the site** (min-one per pour × 3, the
  ~10% rule); the rest run on fields — strays visible on camera.
- All three breaches **seal idle** by t6893 when the bot refuses the
  bait, and — trace-perfect — **shelf replacement #1 lands at t6894**,
  one tick into the quiet, then every 720 ticks in canonical order
  (3 mites, 2 husks, spitter...) until the shelf stands at ten again.
- The bot **survives** the full 400s (census cut 7→4). Together with
  the play-zoom pour where the stream kills the bot at t10757
  (`out/marrow_pour_playzoom.mp4`), the difficulty envelope has both
  outcomes on film.

**Personal frame audit (7 frames):** breach ring reads in the throat at
open (fr300); pour convergence with doorway arrows (fr575); an engulf
tell stalking through the post-seal quiet (fr2400); corridor fight past
a still-live breach (fr1300); late quiet sweep (fr4500). No seams, no
squash, no HUD defects.

**Crash caught and fixed by this capture:** first run died at the music
census — a shrieker rally scream flipped a Dispatch Collar to 'hunt'
(`DANGER_CO[core_collar]` KeyError). Root fix in `_set_enemy_state`
itself: organ parts have no state machine; no caller can animate one.

## Fleet frame audit (4 reviewers, 200 frames + supplements)

**0 P0. 0 surviving P1.** Every span verified readability, portal
seamlessness (zoom-cropped boundary checks), lighting falloff,
diegesis, combat legibility, HUD sanity (two reviewers cross-checked
HUD digits against trace.jsonl tick-for-tick — exact match), motion
continuity, and post-seal breach cleanliness (no orphaned ring or
glow anywhere after t6893).

Span 1 raised a P1 "14-second combat stall at a pinch" — REFUTED by
the trace: husk hits land at t859–866 and t1362, turret fire joins at
t1475, the engagement resolves from t1531 with the expected salvage
jump. An ~8s cautious hold against spitters at a choke is bot pacing,
not a deadlock. (Reviewer legend omitted stationary sentries; the
"threat-marked corpse" note dissolves the same way.)

P2 notes retained for the director's glance: warden hit-flash rim
reads orange vs the white engulf tell (one-frame, fr4128); a sparse
dressing stretch fr900–1188 (belongs to the U15 content pass); breach
ring partly under the salvage counter for 3 frames at fr586. One
reviewer confirmed pod-unpack rings and scorch decals against
render.py rather than reporting them — the intended systems read as
intended.
