# Dead-air analysis — filmed gate seeds 2/4/7, 2026-07-26

Measured against `out/eval_gate/run_s2|s4|s7` (240 s / 14400 ticks each,
`gauntlet4`, farm zoom 0.45). The gate's own run dirs were deleted by a
concurrent re-run mid-analysis, so every trace here was regenerated with
`tools/playtest/marrow_demo.py --seed N --ticks 14400 --zoom 0.45`. The
regenerated `trace.jsonl`/`events.jsonl` are **byte-identical in size** to
the originals for all three seeds (2763558/1362293, 2845860/1343881,
2659569/1207431), so the sim is deterministic per seed and skipping frame
rendering does not perturb it.

Cross-bank context: `out/marrow_farm_a.json` + `_b.json` (16 seeds) and
`out/marrow_farm_density.json` (8 seeds).

---

## 1. What "quiet" has to mean (a measurement correction)

The literal brief — *no `damage_applied` and no enemy sound at all* — is
not the thing the judge is reacting to, because `Audio.handle_sounds`
(`game/perihelion/audio.py:113`) writes every sound to `events.jsonl`
**after** hop attenuation: `v = vol * 0.55 ** hops`. The emit volumes are
known constants (`sim.py:1787/1945/2664/3029` and the `alert_snd` sites),
so each logged `vol` decodes to an exact hop distance from the player.

Decoded hop histogram of all enemy cues:

| seed | h0 | h1 | h2 | h3 | h4 | h5+ |
|---|---|---|---|---|---|---|
| 2 | 154 | 352 | 485 | 904 | 674 | 286 |
| 4 | 95 | 358 | 474 | 1020 | 659 | 381 |
| 7 | 46 | 229 | 390 | 697 | 359 | 173 |

**60–65 % of enemy cues are 3+ hops away**, i.e. logged at amplitudes of
0.017–0.058 (1.7–5.8 % of full scale) under a live music bed and the
player's own SMG. Counting those as "pressure" is what makes the literal
metric read 6 %. They are inaudible; the judge, who gets no audio at all,
correctly does not count them either.

So the table below reports four tiers. **`h<=1` (the player's own chamber
or one adjacent, which is what renders through the portal fold) is the
tier that matches the judge's findings** and is used everywhere after §2.

Validation against the gate's own flagged windows:

| gate finding | window | containing `h<=1` quiet span |
|---|---|---|
| `chunk_s2_3` "~16 s of near-total dead air", frames 002544–002712 | 212–226 s | **209.2–232.1 s (22.8 s)** |
| `chunk_s4_3` "chamber 27 empty and silent", frames 002400–002448 | 200–204 s | **197.6–207.1 s (9.5 s)** |
| `chunk_s4_2` "long visually-empty traversal", frames 001440–001608 | 120–134 s | *none* — see below |

Two of three land inside a measured span. The third does not, and the
reason matters: seed 4 at 120–134 s logs 14 same/adjacent-chamber cues
(5 `hit_flesh` at h0, 9 at h1, 9 heavy footfalls at h1) and 15
`damage_applied` events. That window is **not** dead air; it is the
*other* P2 blocker ("damage lands on enemies that never render") wearing
dead air's clothes. Roughly a third of the gate's dead-air findings are
that second failure mode misfiled.

---

## 2. Measured distributions

### 2.1 Quiet-stretch table (maximal spans with no `damage_applied` and no enemy cue at or below the tier's hop distance)

**Tier `ANY` — the literal brief (any enemy sound at any distance):**

| seed | thr | n | mean | median | p90 | max | total | quiet frac |
|---|---|---|---|---|---|---|---|---|
| 2 | ≥3 s | 2 | 7.44 | 7.44 | 8.72 | 8.72 | 14.9 s | **6.2 %** |
| 4 | ≥3 s | 5 | 7.22 | 6.83 | 13.53 | 13.53 | 36.1 s | **15.0 %** |
| 7 | ≥3 s | 5 | 7.10 | 6.50 | 14.68 | 14.68 | 35.5 s | **14.8 %** |
| 2 | ≥6 s | 2 | 7.44 | 7.44 | 8.72 | 8.72 | 14.9 s | 6.2 % |
| 4 | ≥6 s | 3 | 9.39 | 7.80 | 13.53 | 13.53 | 28.2 s | 11.7 % |
| 7 | ≥6 s | 3 | 9.53 | 7.40 | 14.68 | 14.68 | 28.6 s | 11.9 % |

**Tier `h<=1` — cue audible from the player's own or an adjacent chamber (the operative metric):**

| seed | thr | n | mean | median | p90 | max | total | quiet frac |
|---|---|---|---|---|---|---|---|---|
| 2 | ≥3 s | 16 | 7.27 | 5.73 | 11.67 | 22.85 | 116.3 s | 48.5 % |
| 4 | ≥3 s | 15 | 7.68 | 7.82 | 11.45 | 15.55 | 115.3 s | 48.0 % |
| 7 | ≥3 s | 18 | 7.52 | 6.71 | 14.92 | 20.82 | 135.4 s | 56.4 % |
| **2** | **≥6 s** | **8** | **10.64** | **9.33** | **22.85** | **22.85** | **85.1 s** | **35.5 %** |
| **4** | **≥6 s** | **10** | **9.13** | **8.48** | **11.45** | **15.55** | **91.3 s** | **38.1 %** |
| **7** | **≥6 s** | **10** | **10.36** | **8.88** | **14.92** | **20.82** | **103.6 s** | **43.2 %** |
| 2 | ≥10 s | 2 | 17.26 | 17.26 | 22.85 | 22.85 | 34.5 s | 14.4 % |
| 4 | ≥10 s | 2 | 13.50 | 13.50 | 15.55 | 15.55 | 27.0 s | 11.3 % |
| 7 | ≥10 s | 3 | 15.78 | 14.92 | 20.82 | 20.82 | 47.3 s | 19.7 % |

**Mean quiet fraction (h≤1, ≥6 s): 38.9 %.** Tier `h=0` (own chamber
only) gives 38.4 / 41.7 / 46.9 %; tier `h<=2` gives 29.3 / 25.8 / 32.2 %.
The conclusion is stable across the tier choice: **roughly a third of every
session is a ≥6 s stretch with nothing near the player**, and the
distribution is not a long tail of small gaps — the median stretch is
8.5–9.3 s and the p90 is 11.5–22.9 s, i.e. exactly the "6–20 s" band the
gate reports.

### 2.2 Shape over the session

Quiet fraction (h≤1, ≥6 s) per 60 s quarter:

| seed | 0–60 s | 60–120 s | 120–180 s | 180–240 s |
|---|---|---|---|---|
| 2 | 25 % | 22 % | 44 % | 51 % |
| 4 | 24 % | 44 % | 23 % | 61 % |
| 7 | 10 % | 54 % | 34 % | 73 % |
| **mean** | **20 %** | **40 %** | **34 %** | **62 %** |

The last minute of every session is 51–73 % dead. Kills per 30 s bin fall
the same way (seed 2: 27, 18, 14, 11, 9, 8, 11, 3).

---

## 3. Where the quiet is

All three seeds spend 78–85 % of the session in `kind: corridor`
polygons, and **95–100 % of measured quiet time is in corridors**
(seed 2: corridor 100 %; seed 4: corridor 87 %, storage 8 %; seed 7:
corridor 95 %).

Top chambers by quiet seconds (h≤1, ≥6 s), with the chamber's authored
enemy count from `levels/gauntlet4.json`:

| seed | chambers (quiet s / authored enemies) |
|---|---|
| 2 | **29** (22.0 / **0**), **27** (14.8 / 1), **30** (12.5 / **0**), **28** (10.8 / 1), 22 (6.8 / **0**), 25 (5.0 / 1), 10 (3.0 / **0**), 26 (2.5 / 1) |
| 4 | **29** (13.3 / **0**), 11 (8.8 / **0**), **27** (8.5 / 1), 10 (7.3 / **0**), 17 (5.8 / 6), **28** (5.5 / 1), 7 (4.8 / 1), 25 (4.3 / 1) |
| 7 | **29** (14.5 / **0**), **27** (13.3 / 1), **40** (11.5 / **0**), **45** (8.5 / **0**), **42** (7.0 / **0**), 22 (6.5 / **0**), **44** (6.3 / **0**), 25 (6.0 / 1) |

Aggregates:

| | seed 2 | seed 4 | seed 7 |
|---|---|---|---|
| quiet in chambers with **zero** authored enemies | 48.0 s (**56 %**) | 42.2 s (**47 %**) | 68.0 s (**66 %**) |
| quiet inside the **boss-1 donut**, poly 25–46 | 69.0 s (**81 %**) | 42.2 s (47 %) | 84.8 s (**82 %**) |
| quiet inside the sentry chokes, poly 10/11/22/23 | 11.5 s (13 %) | 22.8 s (25 %) | 9.8 s (9 %) |
| chambers visited in 240 s | 26 of 163 | 26 of 163 | 36 of 163 |

The cause is in the level data, not the sim. Authored enemy density by
region:

| region | polygons | enemies | per chamber | empty chambers |
|---|---|---|---|---|
| lanes (6 × 5) | 1–5, 13–17, 47–51, 77–81, 114–118, 150–154 | 109 | **3.63** | 0 of 30 |
| boss 1 (donut) | 25–46 | 20 | 0.91 | **10 of 22** |
| boss 2 (cross) | 58–76 | 8 | 0.42 | **14 of 19** |
| boss 3 (ring) | 93–113 | 7 | 0.33 | **16 of 21** |
| boss 4 (dark) | 130–149 | 10 | 0.50 | **15 of 20** |

**Boss compounds are 4–11× emptier than lanes, and 55 of their 82
chambers ship zero enemies.** A 240 s session traverses the whole of
boss 1; the ring corridors 29–31 and 40–46 are ten consecutive empty
chambers, and they are the top of every seed's quiet list.

---

## 4. When the quiet is — phase attribution

| phase | seed 2 | seed 4 | seed 7 |
|---|---|---|---|
| pre-first-breach | 14.4 s of 59.6 s = **24 %** | 6.9 s of 25.4 s = **27 %** | — |
| loop live (first open → last seal) | 44.1 s of 133 s = **33 %** | 48.0 s of 155 s = **31 %** | — |
| post-seal (no reinforcement possible) | 26.6 s of 46.6 s = **57 %** | 36.5 s of 59.6 s = **61 %** | — |
| never any reinforcement | — | — | 103.6 s of 240 s = **43 %** |

Breach lifecycles:

- **seed 2** — opened 59.6 s (world chamber 24, **4 hops** from the player), opened 116.6 s (ch. 35, **2 hops**); both sealed `exhausted` at 193.4 s.
- **seed 4** — opened 25.4 s (ch. 13, **5 hops**), opened 136.0 s (ch. 24, **5 hops**), both sealed `exhausted` 157.8 s; opened 166.1 s (ch. 27, **1 hop**), sealed `exhausted` 180.4 s.
- **seed 7** — **zero breaches all session.**

Scout census depletion (7 authored: 2 vagrant + 5 lacuna, all in polygons
12–28, hops 8–20 of a 128-hop level):

| seed | last caller killed | session left with no possible reinforcement |
|---|---|---|
| 2 | 117.0 s | 123 s (51 %) |
| 4 | 192.2 s | 48 s (20 %) |
| 7 | **106.7 s** | **133 s (55 %)** |

A lacuna has 42 hp — one rail shot. Five of seed 2's seven scouts died in
under 3 s of first contact each.

**The structural result: pre-breach quiet is ~25 %, loop-live quiet is
~32 %, post-seal quiet is ~59 %.** The economy is designed to run dry
(120 reserve, mean `STRIKE_CYCLE` cost 2.75 at a 2.2 s cadence = 1.25/s
burn against 0.10–0.35/s regen — a 3.6× overdraw, exhausted at ~130–160 s)
at almost exactly the moment the caller census is gone. Every session's
last 40 % is silent by construction.

---

## 5. Marginal effect of each lever

### 5.1 Delivery, not production, is the binding constraint

Tracing each `dispatch_decision` `entity_id` to its first `portal_crossing`
into the player's current polygon:

| seed | dispatches | ever reached the player's chamber | median latency | p90 | max |
|---|---|---|---|---|---|
| 2 | 63 | **11 (17 %)** | 8.7 s | 53.2 s | 54.2 s |
| 4 | 67 | **13 (19 %)** | 12.0 s | 137.7 s | 139.8 s |

**81–83 % of every pour never arrives.** The marrow spends its entire
120-point reserve (down to 5 and 0 respectively by 180 s) to put 11–13
bodies in front of the player. Even the arrivals are slower than the
dead-air threshold: the median 8.7–12.0 s exceeds the 6 s bar on its own.

The `knows_position` flag does not currently repair this. Pooled across
both seeds: **3 of 15 knowers arrived (20 %) vs 21 of 115 blind (18 %)** —
no measurable effect. The mechanism is visible at `sim.py:2554`:

```python
knows = br.setdefault("sent", 0) % 10 == 0
...
if knows:
    e["dispatch_target"] = br["polygon"]
```

`br["polygon"]` is the **breach's own chamber** — the chamber the body is
already standing next to. A knower is told to walk where it already is.

Breach placement does matter: the one breach that opened 1 hop from the
player (seed 4, 166.1 s) is the one the gate praised ("the tear visibly
opens and teal/violet adversary scouts arrive on screen in sync with
`dispatch_decision`"); the 4- and 5-hop opens are the ones it filed as
"breach-open moments land off-camera".

### 5.2 What is *not* the constraint

- **Reserve / regen.** Seed 7 never touched the pool — 120.0 at every one
  of 230 samples. Seed 2 sat at ≤1 for 5 of 229 samples (2 %); seed 4 for
  19 of 231 (8 %), a ~40 s window. Raising `RESERVE_CAP` or `REGEN_BASE`
  buys nothing in two of three seeds and ~40 s in the third.
- **Dispatch cadence / more breaches.** `_next_dispatch` is a single
  scalar on the controller (`marrow.py:184`, `:256`), so 2.2 s is global
  across all live breaches — three live breaches deliver the same total
  body count as one, and each open adds a 3 s global `FORMATION_TICKS`
  freeze to the others. Halving the interval doubles a pipeline with a
  17 % delivery rate; it would deliver ~24 instead of ~12 bodies while
  draining the reserve in half the time, moving the exhaustion cliff from
  ~160 s to ~80 s and making the back half worse.
- **Hub residents.** 18 bodies (`hub.py:65-77`) sit 2–9 hops behind the
  apses with no tether and no dispatch tag; they trickle, they cannot
  pour, and none of the 36 / 55 / 30 enemy arrivals into the player's
  chamber occurred during a quiet span in any seed.

### 5.3 Structurally unavoidable travel

The pre-first-breach phase is the cleanest floor estimate: full authored
population, densest region of the map (chambers 1–21 at 2.14 enemies per
chamber), no reinforcement yet. It measures **24–27 % quiet**. Against a
current mean of 38.9 %, the addressable headroom is roughly **14
percentage points**, and ~25 % is the honest floor for a level of this
density without changing how far the player walks between fights.

---

## 6. Recommendations, ranked by expected quiet reduction per unit of design risk

### #1 — Populate the boss-compound ring corridors (content, level data only)

**Change.** In `levels/gauntlet4.json`, raise the ten empty boss-1 ring
corridors (polygons **29, 30, 31, 40, 41, 42, 43, 44, 45, 46**) from 0 to
2 authored enemies each, and apply the same rule to the 45 empty chambers
in compounds 2–4. Keep the total census at 226 by **moving** bodies out
of lanes 4–6 (polygons 77–81, 114–118, 150–154 — no 240 s session reaches
them; seeds 2/4 stop at polygon 35, seed 7 at 46), not by adding new
ones. Prefer screen/ranged kinds (husk, mite, spitter) over breakers so
the difficulty delta stays flat.

**Predicted effect.** 47–66 % of measured quiet (mean 56 %, 52.7 s per
session) occurs in chambers that ship zero enemies, and 47–82 % occurs
inside poly 25–46. Assuming half of that block converts to contact — some
bodies will already be dead when the player loops back through the donut,
which seeds 2 and 7 do repeatedly — quiet fraction falls **38.9 % → ~28 %**.
This is also the *only* lever that does anything for seed 7, where zero
breaches ever opened and 66 % of the quiet is in empty chambers.

**Risk: lowest.** Level data only. No system change, no interaction with
the marrow economy, the three-seam cap, or the suppression-is-a-win law.
Per-chamber reversible. The one hazard is thinning the strong opening —
quarter 1 is already the least quiet at 20 % — which taking exclusively
from the unreached back-half lanes avoids.

### #2 — Move callers past polygon 28 (content, authoring re-run)

**Change.** Re-run `tools/design/author_scouts.py` with `--band 3:40`
(currently `3:12`, `author_scouts.py:72`) so the seam-viability trial
carve considers chambers out to hop 40, and require at least 2 of the 5
lacunas to land beyond polygon 28. The census stays at 7 — a
redistribution, not an addition, so the "census only ever shrinks" law and
the suppression-is-a-win reading are untouched.

**Predicted effect.** Post-seal quiet is 57–61 % against 31–33 % while the
loop is live. Extending the loop-live window over the post-seal windows
measured here (46.6 s in seed 2, 59.6 s in seed 4) removes ~12 s and ~17 s
respectively — **−5 to −7 percentage points** on the session. In seed 7,
where all seven callers died by 106.7 s without a single completed
broadcast, a surviving forward caller is the only mechanism that can
produce any reinforcement at all across the final 133 s.

**Risk: medium.** Forward chambers must pass the 96 u seam trial carve —
23 of 58 dry calls in the 16-seed bank were already geometry failures — so
this needs a farm re-run to confirm the dry-call rate does not rise, and
it shifts difficulty later in the session, which touches the open U16
question. It is content regeneration, not a code change.

### #3 — Point `dispatch_target` at the player, not at the breach (code, one line + a stored field)

**Change.** At `sim.py:2554`, replace `e["dispatch_target"] =
br["polygon"]` with the chamber the scout's imprint actually observed the
player in (store it on the breach at open time, alongside `br["polygon"]`),
and raise the knower quota from `% 10 == 0` to `% 3 == 0`.

**Predicted effect.** Only 17–19 % of dispatched bodies reach the player;
the knower flag as shipped delivers no measurable improvement (20 % vs
18 % arrival, n=15) precisely because it aims bodies at the chamber they
spawned beside. If a corrected target lifts the arrival share to ~35 %,
delivered bodies rise from 11–13 to ~22–25 per session at **unchanged
reserve spend**, roughly doubling contact events across the 133–155 s
loop-live window: quiet in that phase 31–33 % → ~22–25 %, i.e. **−5 to −7
percentage points** on the session.

**Risk: highest of the three.** The 10 % quota *is* the mechanism of the
ratified "killing scouts is a GRADED counter, not a switch" law; raising
it and giving it a live target moves the marrow toward omniscience and
away from the hunt-by-scent reading. A stale target can also funnel bodies
to where the player stood 30 s ago, which is worse than the signal fields.
Requires a 16-seed farm A/B on delivered-body count and dry-call rate
before it ships.

---

## 7. Measurement caveats (not lever changes, but they inflate the finding)

Two defects in the gate itself mean part of the reported dead air is
instrument, not game:

1. **The `HEARD:` soundscape line never renders.** `_soundscape`
   (`tools/playtest/evaluate_fun.py:198`) filters on
   `r.get("kind") != "sound"`, but the capture writes `"kind": "sfx"`
   (`marrow_demo.py:56` via `audio.py:76`). All three runs contain **0**
   lines with kind `sound` and 4231 / 4183 / 2949 with kind `sfx`, so
   `sounds` is always `{}`. The chunk prompt's explicit carve-out — "an
   'empty' corridor with heavy off-screen combat audio is dread, not dead
   air… weigh pacing with ears as well as eyes" — can never fire, because
   the data it depends on never reaches the judge. Every frame without a
   trace line is presented to it as `(quiet)`.
2. **The judge sees a 2 s still-frame slideshow.** `--judge-every 24`
   over frames recorded every 5th tick yields 120 judged stills per seed
   at exactly 2 s apart. Measured on that grid, an enemy is audible within
   one hop in 51 % / 48 % / 34 % of stills and in the player's own chamber
   in 25 % / 22 % / 11 %. Anything that enters and dies between two stills
   is invisible to the gate.

Fixing (1) is a one-word change and should land **before** any pacing
lever is tuned, so that the next verdict measures the change rather than
the instrument.

---

## Appendix — reproduction

```
python tools/playtest/marrow_demo.py <out> --ticks 14400 --zoom 0.45 \
    --seed {2,4,7} --every 100000     # traces only, sim-identical
```

Quiet stretches are computed from `events.jsonl` by decoding each enemy
sfx `vol` to a hop count via `vol = base * 0.55 ** hops` (bases:
alert 0.35/0.4/0.5/0.55/0.7/0.9; step 0.35/0.6; `hit_flesh` 0.8;
`shrieker_scream` 0.85/1.0; `spitter_shoot` 0.9), unioned with
`damage_applied` ticks from `trace.jsonl`, then taking maximal gaps over
[0, 240] s. Chamber attribution uses the 0.25 s `sample` records.
