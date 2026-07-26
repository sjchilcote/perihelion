# Marrow implementation plan — working checklist

Distilled from the round-3 Sol consult (`docs/consults/marrow_20260725/sol_answer_round3.md`,
which is the full text — unit APIs, complete gate vectors, killbox design).
The spec is `DESIGN_7_25.md`; where this file and the spec disagree, the spec wins.

## Operating rule (every unit)

1. Start from a green parent (`./check.sh`).
2. Add the construction invariant + fail-first test BEFORE the behavior;
   demonstrate a deliberate mutant fails the gate, then revert the mutant.
3. Run the unit's focused gate, then `./check.sh`.
4. Commit only if both are green. Append a line to `out/build_manifest.jsonl`:
   `{"unit": "U2", "commit": "<hash>", "gates": ["<test cmds>"], "artifacts": ["<paths>"]}`
5. A unit that cannot go green stops at the last green commit — no fallback
   paths, no flags, no half-wired substrate left on the branch.

## Unit order and gate one-liners

| # | Unit | Gate core (full vectors in the consult answer) |
|---|---|---|
| U0 | Pygame-free renderer (cherry-pick 203da395) | AST: no pygame in render path; one backend; draw() returns (W,H,3) uint8. DONE 2026-07-26 (200d1cc1) |
| U1 | Instrumentation spine (`telemetry.py`, TraceBus) | typed events, no query API, import-boundary AST test; 120-tick vector with exact event counts; app/harness emit identical schemas. DONE 2026-07-26 (e6cf05f3) |
| U2 | Engine impulse + combat canon (Rust `apply_impulse`) | Δv mass law ±1e-9; 4×rail/2×charged-Tau kills a 168 Warden; every weapon pushes; kinematic ratios measured; no `set_vel` knockback anywhere. DONE 2026-07-26 (dd949c3b) |
| U3 | find/senses API (`senses.py`) | frozen dataclasses; ambient frame one-hop (deeper raises); targeted sight composes to 3 hops per the cross-room law; wallhack vector. DONE 2026-07-26 (5a93dfb2) |
| U4 | Nine-field signal substrate (`signals.py`) | exponential decay from stored tick delta (update-frequency invariance <1e-9); half-life vectors (Trail 12s/Danger 180s); one-hop sampling; topology invalidation. DONE 2026-07-26 (8ce2a319) |
| U5 | Coordination behaviors (`coordination.py`) | fractional quorum (3-peer room ≥2× commits of 12-peer); priority-budget flocking (opposed 100/100 → full left); raid fan 80–120/300 via second route; stand-down; alert_enemies() REMOVED. DONE 2026-07-26 (8ce2a319; vigil deleted same commit) |
| U6 | Generic capture + Warden engulf (`capture.py`) | no `warden` check in player code; dot 0.49 no-capture / 0.51 capture; 75±1 HP over 60 ticks; release on captor death. DONE 2026-07-26 (215f4769; engulf range derived from lunge's physical reach ~120u) |
| U7 | Call medium + finite scouts (`callmedium.py`, `scouts.py`) | one lease; imprint = chamber/pos/tick/class only; dry call consumed without retry; lacuna calls only from its body's chamber; census only decreases. DONE 2026-07-26 (30445e13) |
| U8 | Topology owner + 24-chamber hub (`topology.py`, `hub.py`) | connect_equal asserts lengths AND derived scale 1±1e-9; 96↔52 raises; hub depth 10–11, three apses, sources pairwise nonadjacent. DONE 2026-07-26 (84e88817). Remaining sweep: route hole/cloister/door/stream mutations through the owner + the no-raw-splice source gate (lands with the next unit batch) |
| U9 | Breach lifecycle + reserve + dispatch (`marrow.py`) | reserve regen 0.10→0.35; payment stalls (warden ≈23s); shelf-first pour, hub-side spawns only, honest closure trio; cost-fair ≤8 skew. DONE 2026-07-26 (6656afbc). Deferred within-unit: ratified composition tables + ~10% position knowledge (with U11), shelf replacements (U11), exhausted-shelf production accounting nuance |
| U10 | Scout cycle + garrisons + shrieker trail (`garrisons.py`) | settle at exactly 720 quiet ticks with Warden present; Warden schema rejects follower fields; scout alternates low-Kin safe call ↔ danger-peak raid call. SETTLEMENT HALF DONE 2026-07-26 (test_garrisons.py, committed with U9 era); shrieker mark/glob FSM remains |
| U11 | CORE organ (`core_organ.py`) | part HP table (42/84/126/168); collar loss 2.20→3.14→4.89s immediately; 3 sources → reserve=-32, no timer anywhere; reform 1S/1A/3B/1C at reserve>0. DONE 2026-07-26 (bbd7178f organ + 096271a2 visuals); U11b same night (5fa5c918): shelf replacements ≥12s canonical-order quiet-only, ratified 35/25/15/25 STRIKE_CYCLE, ~10% position knowledge (knows_position traced). Remaining: composition table for RESIDENT hub population |
| U12 | Buildings + persistent death (`structures.py`) | zero-or-one kit; inert at tick 1799 / active 1800; brute contact kills structure, mite doesn't; sentry 50 shots unsupported, hop-distance pod support; 20s in-station repair; death NEVER cold-restores |
| U13 | Scrubber + cleaning robot (`cleaning.py`) | 1.2 u/s TOTAL shared sink (not per field); own 1.0 / adjacent 0.5; components only after completed physical tasks; no "scrubbed = suspicious" query exists |
| U14 | Lighting + tells + HUD strip | all tells read real state (renderer cannot subscribe to telemetry); topology invalidates static lights; top-left = scrap only; FSEX 16px everywhere |
| U15 | Canonical gauntlet4 integration | one gauntlet; vigil deleted; every portal scale 1; 1–3 valid 96-wide sites per call-capable chamber (GEOMETRY MIGRATION REQUIRED — see conflicts); authored finite scouts; storage-area repair kits. AUTHORING HALF DONE 2026-07-26 (9f3e7ff1): tools/design/author_scouts.py measured placement, 2 vagrants + 5 lacunas (2 dormant) at band 5:20, loop fires in 3/3 ordinary seeds (first breach 50-79s). Geometry migration + repair kits remain |
| U16 | Acceptance harness + killbox experiment | 30-point mechanical checklist + every-5th-frame full-run vision review + 64-trial paired killbox measurement |

## First overnight cut line (Sol's, ratified for tonight)

U0 → U1 → U2 → U3. If U3 incomplete, stop after U2.
Do NOT start U4 unless there is time to finish U5 too — substrate without a
decision consumer is a bad unattended stopping point.

## Survey/spec conflicts Sol flagged (must be resolved, not routed around)

1. **Shipped chambers can't hold a 96-unit breach** (walls 60–90u exist).
   Resolution = geometry migration in U15; level build FAILS until every
   call-capable chamber has a valid site. No silent skipping.
2. **5-hop active window vs 10–11-deep hub.** Economy/timers advance
   analytically; guardians live in shallow bands; log inactive-breach
   incidence; never claim distant physical simulation. Far-sim stays deferred.
3. **Death with no chassis cold-restores the world** — violates the System
   Shock rule; the starting pod's infinite chassis must make that path
   unreachable (U12).
4. **No turn-rate model exists** — enemies snap heading per tick; U2 adds
   heading/turn-limited motion or the kinematics directive is unmeetable.
5. **Sentries/stations are indestructible GROUP_PICKUP entities** — U12
   moves them to a real collidable structure group; no parallel old path.
6. **Chamber Trail ≠ doorway trail** — both exist; conflating them loses
   either player scent or route lanes.

## Structure that must not drift during tuning

scale-1 breach construction · no world-side reinforcement spawning · finite
scouts · one-hop sensing · Kin stays a field · reserve blind to player state ·
dry calls consumed · no cheap-unit substitution · cost-fair dispatch · no
blackout timer · no Warden/player coupling · persistent world on death · no
feature flags, no duplicate pathways.
