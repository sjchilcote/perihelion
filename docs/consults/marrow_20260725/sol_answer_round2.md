# Round-2 recommendation

The second wave changes three ratified coordination rules and several parts of my first draft:

1. **Replace absolute-level quorum with locally fractional quorum.**
2. **Delete the proposed Kin scalar.** Use contact pressure plus existing Garrison fields.
3. **Replace weighted flock steering with prioritized acceleration allocation.**
4. **Replace the fixed reinforcement table with separate resident and strike-package compositions.**
5. **Do not resample cheap units when reserve is low.** Let the selected unit wait for payment; the resulting gate latency becomes the reserve tell.
6. **Expand the hub from an eight-room system diagram into a 24-chamber, shallow-loop/single-trunk game area.**
7. **Give only a small informed minority of each reinforcement group the transmitted position.**
8. **Keep equal multi-breach allocation, but implement it as cost-fair scheduling rather than rigid round-robin.**

I still reject runt variants, return-gated dispatch, dynamic aperture growth, suspicious-quiet detection, mouth plugging, and mandatory CORE phases.

---

# Bayesian update summary

I treated repeated candidates using the same source as one observation.

| Decision | Prior odds for change | Main evidence: `P(E|change) / P(E|keep)` | Posterior | Action |
|---|---:|---:|---:|---|
| Fractional quorum | 1:2 | 0.80 / 0.25 = ×3.2; dense-group fit adds about ×1.5 | about 2.4:1 | **Change** |
| Contact pressure instead of Kin | 1:3 | 0.75 / 0.35 = ×2.1; reuse of existing Garrison fields adds about ×1.5 | about 1.1:1 | **Change, narrowly** |
| Priority-budget flocking | 1:1 | 0.85 / 0.30 = ×2.8; doorway relevance adds about ×1.5 | about 4.2:1 | **Change** |
| Resident/strike composition split | 1:2 | 0.80 / 0.25 = ×3.2; hub-identity fit adds about ×1.4 | about 2.2:1 | **Change** |
| Demand/return-weighted multi-breach allocation | 1:3 | Evidence modestly favors it, about ×1.6, but it conflicts with flanking intent by about ×0.4 | about 1:4.7 | **Keep equal allocation** |
| Single-trunk hub over round-1 diamond | 1:1 | 0.80 / 0.35 = ×2.3 | about 2.3:1 | **Change** |

These are design odds, not claims that the cited systems transplant directly.

---

# Part 1 — Revisions to my round-1 draft

## 1. Quorum: **CHANGE**

The ratified absolute rule is wrong as written.

An absolute `Distress + Noise > threshold` test makes a packed hall easier to flip than a thin picket. The verified result says the opposite mechanism is often more coherent: calm visible peers form a denominator and inhibit commitment.

I would not delete the scalar fields. They remain the long-range evidence that identifies a candidate disturbance. I would change how local agents turn that evidence into a cascade.

## Exact denominator

For agent `i` considering target chamber `q`:

```text
N_i(q) =
    coordination-capable friendly agents visible to i
    in i's own chamber or through one active portal,
    excluding i
```

“Visible” means returned by the ordinary `find.visible(..., portal_depth=1)` query. An agent hidden behind an opaque wall in an adjacent chamber is not in the denominator.

Split that set into:

```text
A_i(q) = agents visibly committed to q
C_i(q) = all other visible friendly agents
```

Agents committed to a rival target count as calm with respect to `q`. They do not positively support both choices.

The fields contribute one bounded virtual supporter:

```text
e(q) = clamp((Noise(q) + Distress(q)) / 0.60, 0, 1)

f_i(q) = (A_i(q) + e(q)) / (A_i(q) + C_i(q) + 1)
```

The `+1` denominator is the virtual-supporter slot. Therefore:

- A loud disturbance can wake a lone picket.
- One alerted agent among two calm peers is persuasive.
- One alerted agent among twelve calm peers is not.
- A scrubber suppresses `e(q)` but does not erase direct sight or visible active allies.

Commitment uses a Hill curve rather than a hard count:

```text
lambda_i = 3.0/s * f² / (T_i² + f²)
P(commit this 0.2 s sense tick) = 1 - exp(-lambda_i * 0.2)
T_i sampled once at spawn in [0.25, 0.45]
```

The persistent threshold preserves individual initiators. It is not rerolled per tick.

### What this predicts

- The same field value can wake a three-agent corridor while barely perturbing a twelve-agent hall.
- Cascades usually begin at sparse edges and propagate inward over roughly one or two seconds.
- Killing persistently low-threshold initiators measurably reduces cascade frequency.
- A scrubber suppresses initiation but cannot make visible combatants ignore one another.

### What it forbids

- One shot flipping every agent in a packed chamber simultaneously.
- Hidden agents contributing to a denominator the observer could not sense.
- Per-tick random thresholds.
- Relay recruitment committing agents without passing through the quorum calculation.

### Compute cost

The sense snapshot already enumerates locally visible entities. Quorum counts those returned hits; it does not perform a second world scan. Cost remains proportional to local visible population at 5 Hz.

**Odds it survives playtest: 70%.**

The main risk is over-inhibition in dense rooms. The discriminating test is identical field input in rooms containing 3, 6, and 12 calm agents.

---

## 2. Kin field: **CHANGE — delete it**

My round-1 draft added Kin because the spec explicitly required it. I now think that is unnecessary state.

The replacement has two pieces:

1. **Contact pressure suppresses positive recruitment emission.**
2. **Spotters avoid the already-existing Garrison Interior and Garrison Reach fields.**

That supplies both “crowds stop attracting more crowds” and “callers spread away from established bases” without a ninth chamber scalar.

## Contact-pressure mechanism

Each coordination-capable agent holds:

```text
contact_pressure
```

- Add `+1` when a distinct friendly enters personal-contact range.
- Half-life: **4 seconds**.
- Clamp: **12**.

Positive rally emission is multiplied by:

```text
m(c) = 0.18 + 0.82 / (1 + c/8.2)
```

Thus:

- `c = 0` → full emission.
- `c = 10` → about `0.55×`.
- Extreme crowding approaches about `0.18×`, close to the reported 5.6-fold reduction.

Apply this multiplier to:

- Muster emission.
- Garrison Reach emission.

Do **not** apply it to:

- Distress, because Distress records actual harm.
- Danger, because Danger records death.
- Trail or Patrol.
- Garrison Interior, because a settled base must remain locally identifiable.

A spotter with at least three recent contacts enters a short dispersal commitment: for its next two chamber choices it prefers the least occupied visible adjacent chamber, then resumes ordinary field navigation. Established garrisons are avoided by descending Garrison Reach and Interior.

### Why this is enough

A caller approaching a crowded garrison can already perceive:

- Its recent contacts.
- The visible friendly bodies.
- Garrison Interior/Reach.

A separate friend-scent adds little information and risks saturation, self-repulsion, and another scrubber interaction.

### Predictions

- Muster emission per agent falls as chamber occupancy rises.
- Thin fronts remain loud while packed reserves become quiet.
- Spotters spread without making settled defenders flee their own base.
- Garrison spacing remains local—typically a few hops—not globally optimal.

### Forbids

- Every friendly continuously painting an unconditional Kin field.
- Settled agents being chemically expelled from ground they are meant to hold.
- Distress being suppressed merely because many agents were harmed together.

**Odds it survives playtest: 55%.**

This is a close decision. If callers still cluster, restore a portal-valued refusal mark before restoring a chamber-wide Kin scalar.

---

## 3. Flocking: **CHANGE**

The spec’s literal “keep-apart weighted above bunch-together” should be corrected. Weighted sums can cancel at exactly the places where the game cannot tolerate them: walls, portal mouths, and opposing streams.

Use a strict acceleration budget:

```text
budget = agent.max_acceleration
```

Fill it in this order:

1. Imminent static collision and wall clearance.
2. Friendly-body separation.
3. Velocity matching.
4. Formation cohesion.
5. Field-gradient steering.
6. Tactical objective/path steering.

Each request consumes the remaining acceleration budget. The request that crosses the limit is trimmed; all lower-priority requests are dropped for that tick.

Friendly influence uses:

```text
weight ∝ 1 / distance²
```

Search only the six nearest friendly candidates, but apply separation only inside a body-size-scaled safety distance. This keeps the spec’s larger-body gap while avoiding an all-pairs scan.

### Predictions

- Opposed steering requests no longer average into a near-zero doorway jitter.
- A crowded breach surge spends nearly all acceleration on collision avoidance and separation.
- Once spacing clears, objective steering naturally resumes.
- Arrival formations fan sideways rather than compressing into one line.

### Forbids

- Weighted cancellation between “avoid body” and “follow route.”
- Direct velocity writes.
- Breach-specific anti-jam movement.
- A fixed all-population neighborhood.

**Odds it survives playtest: 85%.**

---

## 4. Decay-law correction: **KEEP the round-1 ordering, reject the amplitude argument**

The critic is correct. Under exponential decay, doubling amplitude adds one half-life above a fixed detection threshold. It does not multiply persistence by 2.4.

Use genuinely different half-lives:

| Signal | Half-life | Typical initial value | Approximate time above 0.10 |
|---|---:|---:|---:|
| Trail | **12 s** | 0.80 | 36 s |
| Patrol | **60 s** | 1.00 when saturated | 199 s |
| Danger | **180 s** | 0.40 per death | 360 s |

The duration calculation is:

```text
time_above_threshold =
    half_life * log2(initial_value / threshold)
```

These values produce the intended order:

```text
Trail: recent passage
Patrol: searched within the last few minutes
Danger: this room has remained lethal for a substantial fight
```

Amplitude still controls how strongly a fresh event is read. Time ordering comes from the half-lives.

I would retain Danger as a chamber field for the first implementation. Portal-valued refusal is promising for cordons, but it is additional substrate and should be added only if chamber Danger cannot produce doorway holding.

**Odds the ordering survives: 80%.**  
**Odds the exact half-lives survive: 45%.**

---

## 5. Wave composition: **CHANGE**

The fixed class percentages in round 1 are too simple. The hub’s resident population and its delivered strike package should be different.

I would not literally force brutes and Wardens to outnumber all light bodies. The evidence for that exact inversion is qualitative and concentrated in one review. I would invert the broader category: the hub is light-body-majority, while the strike package is specialist-majority.

## Resident versus delivered composition

Percentages are by headcount before learning bias:

| Role | Resident hub population | Delivered strike package |
|---|---:|---:|
| Screen: mite, husk | 60% | 35% |
| Ranged: spitter, shrieker | 18% | 25% |
| Mobility: flicker | 10% | 15% |
| Breaker: brute, warden | 12% | 25% |

Within roles:

```text
Screen:   55% mite, 45% husk
Ranged:   60% spitter, 40% shrieker
Breaker:  80% brute, 20% warden
```

The nominal strike package is therefore approximately:

| Class | Share |
|---|---:|
| Mite | 19% |
| Husk | 16% |
| Spitter | 15% |
| Shrieker | 10% |
| Flicker | 15% |
| Brute | 20% |
| Warden | 5% |

Average reserve cost is approximately **2.76 units per agent**.

This preserves Wardens as high-tier but ordinary, substantially raises mobility and breaker pressure, and gives the invaded hub a visibly different population from what came through the gate.

## Low reserve behavior

Change my round-1 affordable-resampling rule.

When a selected class is unaffordable:

- Do **not** substitute a cheaper class.
- Hold that purchase pending.
- Let reserve regeneration pay it.
- Dispatch it when paid.
- If the purchase leaves reserve below one unit, enter exhaustion and begin closure grace.

At near-zero reserve and `regen ≈ 0.35/s`, the maximum payment delays are:

| Cost | Maximum wait from zero |
|---:|---:|
| 1 | 2.9 s |
| 2 | 5.7 s |
| 3 | 8.6 s |
| 4 | 11.4 s |
| 8 | 22.9 s |

That creates an honest, class-dependent gate stutter without runt bodies or a fabricated warning timer.

## Finite Adversary population

Vagrants and lacunae remain completely outside this table.

- They are authored into the world at initialization.
- None exist in the hub’s producible inventory.
- The CORE never creates one.
- A substantial fraction should begin in low-duty states with high persistent quorum thresholds, physically distributed through quiet chambers.
- Killing active scouts can appear not to reduce pressure immediately because previously quiet scouts still exist, but every death permanently reduces the census.

Far-simulation limits this: dormant scouts outside the active window do not wake and migrate offscreen. That is a known undercount of strategic activity, not successful containment.

### Predictions

- Hub population is visibly lighter than breach composition.
- Low reserve changes timing before it changes silhouettes.
- Sustained scout extermination permanently reduces call opportunities.
- No cheap-only “last wave” appears automatically near exhaustion.

### Forbids

- Sampling the strike package directly from hub demographics.
- Runt stat variants.
- Regenerating vagrants or lacunae.
- Hiding reserve depletion by substituting mites whenever a Warden is unaffordable.

**Odds this composition shape survives: 65%.**

---

## 6. Other changes to round 1

### A. Reinforcement knowledge: **CHANGE**

Only a small informed minority receives the transmitted position.

For a dispatched group:

```text
informed_count = max(1, round(0.10 * group_size))
```

Informed agents retain the call position. All others use ordinary one-hop fields, local sight, and flocking. They are not told which agents are informed.

For the game’s small groups, 10% plus a minimum of one is more usable than importing the reported 5% literally.

This predicts occasional strays and garrison seeds without making every reinforcement omniscient.

### B. Return-gated dispatch: **KEEP REJECTING**

I do not adopt “agents must return through the breach to sustain dispatch.”

It conflicts with the game in three ways:

1. Mouth camping would become the winning pressure-control tactic.
2. Projectiles crossing the portal keep the 45-second timer alive, so the proposed automatic seal does not follow.
3. The player can himself cross toward the hub, creating exploitable return-credit ambiguity.

Return traffic may carry learning evidence, but it does not control basic pour cadence.

### C. Breach sites and width: **KEEP**

Keep prevalidated wall sites, rigid transforms, and fixed full width. No aperture growth, body plug, rubble plug, or entry-specific behavior.

### D. Portable Hole graph behavior: **CHANGE**

Every player-created hole is a real dynamic portal edge for:

- Signal propagation.
- Sight and sound.
- Pathfinding.
- Hop-distance building support.
- Local graph-derived queries.

Any cache derived from portal adjacency must invalidate locally when a hole opens or closes. No gameplay graph calculation may assume initialization-time topology is permanent.

### E. Direct-breach threshold: **CHANGE**

Delete my unsupported fixed `Distress >= 1.60` constant.

Measure the highest sustained Distress reached during aggressive full clears, then set the direct-breach condition near:

```text
2 × the measured aggressive-play peak
```

with a sustained-duration requirement. The exact threshold cannot be responsibly chosen before that trace exists.

### F. Eight-chamber hub: **CHANGE completely**

It was an implementation diagram, not a game area. The replacement follows.

---

# Part 2 — The hub as a game area

## 1. Overall spatial grammar

Ship a **24-chamber hub**, usually **10–11 portal crossings deep** from arrival to the Source Cells.

The sourced architectural findings support:

- Wide, numerous shallow chambers.
- Shrinking chamber area with depth.
- A mostly single trunk.
- Shallow branches rather than deep bypasses.
- The longest connector around 70–80% depth.
- Supply functions in a middle band.
- The protected production source deepest.

The exact 24-chamber count, encounter placement, and percentages below are game-design choices.

## Floor-area distribution

| Depth band | Share of hub floor area | Character |
|---|---:|---|
| 0–2 | 50% | Arrival and guardian halls |
| 3–5 | 30% | Gatehouse, dispatch, reserve works |
| 6–8 | 15% | Production and exposed deep approach |
| 9–10 | 5% | Source vestibule and three Source Cells |

The largest receiving halls should be roughly five times the area of an individual Source Cell.

## Graph

```text
                 [Receiving Apse A]
                        |
[Receiving Apse B]--[North Transept]--[Guardian Court N]
        |                                      \
        |                                       [Rood Gatehouse]
        |                                      /
[Receiving Apse C]--[South Transept]--[Guardian Court S]
                                               |
                         [Collar Chapel N]--[Processional Span I]--[Collar Chapel S]
                                               |
                                      [Processional Span II]
                                               |
                         [Anchor Chapel NW]--[Reserve Nave]--[Anchor Chapel NE]
                                               |
                         [Anchor Chapel SW]--[Caretaker Crossing]--[Anchor Chapel SE]
                                               |
                                         [Scriptorium]
                                               |
                                   [Long Exposed Connector]
                                               |
                                      [Source Vestibule]
                                      /       |       \
                             [Source Cell I][Cell II][Cell III]
```

Additional small service chambers and alcoves bring the total to 24, but none creates a deep bypass.

## Traffic grammar

- Breaches attach to validated seams in one of the three Receiving Apses.
- The shallow transept loop lets traffic route around local congestion and gives the player an early flank.
- Both Guardian Courts rejoin at the Rood Gatehouse.
- Past the Gatehouse there is one axial trunk.
- Anchor Chapels are side objectives in the middle band.
- The Scriptorium receives returning evidence carriers.
- The longest uninterrupted run is the Long Exposed Connector at about three-quarters depth.
- The three Source Cells branch only at the final vestibule. They may be attacked in any order.

This is not a maze. The challenge is commitment, attrition, and fighting back out, not finding a concealed key.

**Odds the grammar survives substantially intact: 65%.**

---

## 2. What sits where

### Receiving Apses and Guardian Courts

The physical guardian shelf lives in depths 0–2, between the production interior and the active breach mouths.

Initial roster:

- 3 Mites
- 2 Husks
- 1 Spitter
- 1 Shrieker
- 1 Flicker
- 1 Brute
- 1 Warden

Ten standing guardians are approximately the upper edge of a 15–20% standing guard fraction relative to a full reserve’s body-equivalent capacity. That fraction is an inspiration, not a directly transferable law.

All ten are real agents and all are dispatchable. They are not an immortal boss garrison.

When the marrow dispatches them:

- They physically leave their posts.
- The hub entrance becomes weaker.
- They are not silently copied.
- Replacements cost reserve and arrive no faster than one per 12 seconds.

This makes timing the invasion meaningful.

### Collar Chapels

Two Dispatch Collars remain near the shallow trunk because they serve the mouths.

| Live collars | Dispatch interval |
|---:|---:|
| 2 | 2.20 s |
| 1 | 3.14 s |
| 0 | 4.89 s |

They do not stop production or CORE recovery.

### Anchor Chapels

Four Anchors, each carrying three Producer Buds.

Their middle-band location lets the player damage long-term output without reaching the deepest source.

### Scriptorium

One optional learning target:

```text
hp = 84
rebuild = 45 s by a Caretaker
```

Destroying it:

- Erases the current eight-entry evidence ledger.
- Prevents new evidence writes until rebuilt.
- Does not stop basic dispatch.
- Does not unlock a door.

### Source Cells

Three Source Knots sit deepest because the original Testator installation isolated its supply terminus behind the service and distribution infrastructure. The Adversary preserved that topology and corrupted its output.

Each Source is in a separate small convex cell opening from the final vestibule. This prevents one Tau detonation from hitting all three while avoiding a mandatory linear attack order.

---

## 3. CORE parts and attack consequences

| Part | Count | HP | Immediate consequence |
|---|---:|---:|---|
| Dispatch Collar | 2 | 126 | Slows dispatch immediately |
| Scriptorium | 1 | 84 | Stops and erases learning |
| Caretaker | 4 | 42 | Removes healing/rebuild capacity |
| Anchor | 4 | 84 | Releases its Buds; delayed production loss |
| Producer Bud | 12 | 42 | Removes 1/12 of Bud-supported production |
| Source Knot | 3 | 168 | Removes 1/3 source capacity after pipeline delay |
| All Sources destroyed | — | — | Reserve set to −42; reinforcement blackout |

The HP values preserve existing weapon arithmetic:

- 42: one rail shot.
- 84: one charged Tau or two rail shots.
- 168: two charged Tau or four rail shots.

## Repair behavior

```text
Source passive repair:
    begins after 10 s without damage
    2 hp/s

Caretaker repair:
    6 hp/s in physical contact

Anchor rebuild:
    30 s

Bud rebuild:
    12 s

Collar rebuild:
    45 s

Scriptorium rebuild:
    45 s

Surviving Source creates one missing Caretaker:
    30 s
```

Caretakers use ordinary movement and can be intercepted. When the hub is inactive, static passive Source repair advances analytically, but Caretakers do not travel offscreen.

## Why this is not a phase boss

There is:

- No master health bar.
- No invulnerability.
- No room lockdown.
- No required target order.
- No scripted transition when a Collar or Anchor dies.
- No reset on player death.

The spatial order suggests Collar → Anchor/Caretaker → Source, but a player may run past every optional target and rush the Sources. That route is simply exposed to the most incoming pressure.

### Valid raid choices

- **Collar-first:** immediate reduction in external dispatch.
- **Caretaker-first:** little immediate relief, but damage persists.
- **Anchor-first:** local Bud defender spike, then delayed economic loss.
- **Scriptorium-first:** strips adaptive composition without affecting numbers.
- **Source rush:** fastest blackout, highest risk.

**Odds this CORE shape survives: 68%.**

---

## 4. The arrival problem: first three seconds

The arrival must explain itself without text.

### 0.0–0.5 seconds

The player exits onto fabricated Testator flooring. Behind him is the breach: an impossible live view into the ordinary chamber he left.

The hub side is visibly not another station room:

- Repeated manufactured wall ribs.
- Radial aperture mounts.
- Processional floor inlays.
- Directional light aimed along one dominant axis.
- Multiple empty guardian stations facing the breach mouths.

### 0.5–1.5 seconds

The player sees the causal machinery:

- Dispatch Collars ratcheting in the distance.
- Conduits carrying light from deeper rooms toward the active breach.
- Any remaining guardians moving outward, toward him and the mouth.
- Vacant posts where dispatched guardians used to stand.

The direction agents are coming from is the direction of depth.

### 1.5–3.0 seconds

Threat and purpose become readable:

- Guardian silhouettes appear in the flanking courts, not directly inside the aperture.
- The Shrieker and Mite silhouettes make clear that small pursuers are present.
- A deep, three-beat Source pulse travels down the axial lighting.
- Side machinery visibly feeds the trunk; the brightest current comes from the final axis.

No arrow or objective marker is needed. Traffic, light, and repeated architecture all point inward.

**Odds this arrival reads correctly on first entry: 75%.**

---

## 5. Raid arc

This is not a scripted three-phase encounter. These are expected play intervals.

## First minute: the condition of entry

A good raid begins just after reserve exhaustion.

The player should find:

- A thinned Receiving Apse.
- Missing guardians because they were the opening dispatch shelf.
- One or two survivors trying to hold the Guardian Courts.
- Dispatch Collars still moving but failing to produce a steady rhythm.
- A choice between damaging a Collar and immediately running deeper.

A badly timed raid finds the full ten-agent shelf. That should usually force retreat or death.

## Middle minute: dismantling recovery

The player crosses the Gatehouse and enters the reserve band.

Pressure changes from a formed guardian ring to:

- Caretakers withdrawing between damaged parts.
- Buds detaching as ordinary Mites or Husks.
- Newly affordable reserve agents arriving irregularly.
- Flanking through the four Anchor Chapels.

The player decides whether to spend time making damage persist or preserve health for the Source rush.

## Last minute: exposed commitment

The Long Exposed Connector is the final commitment point.

It is:

- Physically long.
- Narrow enough that turning matters.
- Too late for a casual return to the original breach.
- Overlooked from the Source Vestibule.
- Traversed while reserve has begun recovering.

The final Source Cells are small and mutually visible from the vestibule but not vulnerable to one blast. Destroying the third Source sets reserve to `−42`.

The trip out then occurs during the blackout the player created.

### Why the guardian shelf matters

The player is not merely waiting for a numeric reserve minimum. He is observing whether the actual entrance defense has already been spent into the world.

That is the core timing skill:

> The safest moment to invade is when the thing that would have guarded the hub is currently fighting your firebase somewhere else.

**Odds the raid arc is fun rather than merely punitive: 60%.**

The largest risk is that the initial portal remains such a good killbox that exhausting the shelf costs too little.

---

## 6. The way out

There is no permanent hub exit. The honest options are:

1. **Return through the original breach before it seals.**
   - Any crossing still resets its 45-second timer.
   - A shallow Collar raid and immediate withdrawal is valid.

2. **Keep the original breach alive.**
   - Fire through it.
   - Leave a sentry or other system that creates crossings.
   - Fight back to it before the pinning mechanism fails.

3. **Use the Portable Hole.**
   - This is the intended prepared expedition tool.
   - It creates a dynamic portal edge back to a prepared safe chamber.
   - Mites and Shriekers can pursue through it.

4. **Find another simultaneously live breach in a different Receiving Apse.**
   - This is possible but unreliable.
   - It may lead into a much worse world-side fight.

5. **Plant a pod foothold inside the hub.**
   - Expensive because the player enters slowed while carrying one kit.
   - Powerful because death then returns him to the contested area.
   - The CORE’s regeneration still prevents casual death-chipping.

6. **Self-destruct and revive at a pod.**
   - The world remains exactly as left.
   - The player loses the physical expedition, not world progress.

The unprepared curious player learns honestly: the aperture closes, the ESC command says **Self-Destruct — Revive at Pod**, and the next expedition is planned.

No hidden emergency teleporter should rescue him.

---

## 7. Making it Testator-built rather than an organic nest

The base architecture is visibly manufactured:

- Repeated modular wall bays.
- Convex chambers arranged on processional and cruciform axes.
- Brass, ceramic, blackened steel, and pale stone-like composite.
- Directional service lighting recessed into ribs.
- Latin maker’s prayers and inventory inscriptions.
- Reliquary-like housings around Sources.
- Apse, transept, nave, rood, and choir geometry used as functional industrial organization.
- Standardized maintenance clearances and repeated attachment points.
- Load-bearing structure that continues behind the corruption.

The infestation is secondary and parasitic:

- Buds clipped onto old power rails.
- Dark tendrils following cable conduits rather than defining the walls.
- Testator icon panels obscured but still physically present.
- Collars grafted over existing aperture machinery.
- Movement and light flowing contrary to the installation’s original processional direction.
- Breach mouths appearing as literal material absences in otherwise exact manufactured walls.

The place should read:

> A consecrated machine built for another purpose, seized and made to manufacture war.

It must not resemble a cave, mound, or fleshy tunnel.

---

# Part 3 — Systems round 1 did not reach

## 1. Honest tells of the off-screen system

I would rank the tells by how directly they reveal internal state.

## 1. Gate payment stalls — strongest reserve tell

The selected class is not replaced by a cheaper one when unaffordable. Therefore the delay is generated by:

```text
wait = (class_cost - current_reserve) / current_regen
```

Near exhaustion, that naturally creates 3–23 second gaps depending on the pending class.

The player does not know the exact number, but repeated long gaps strongly imply depletion. This signal cannot lie without the economy itself lying.

## 2. Loss of the guardian burst

A fresh call sends existing shallow guardians first. Later calls do not.

The player learns:

- Immediate organized burst: the hub’s ready shelf is still intact.
- No burst, only irregular production arrivals: the shelf has been spent.

This reports short-term readiness, not total reserve.

## 3. Dispatch machinery misses

Every scheduled dispatch attempt produces an ordinary Collar motion and light pulse. If the purchase cannot be paid, the machinery cycles but no silhouette enters the route.

This is not a special warning animation; it is the visible action of an unsuccessful dispatch attempt.

Sound propagates through the portal graph, so a nearby player may hear the missing-body rhythm through the breach.

## 4. Increasingly irregular inter-arrival gaps

As classes with different costs wait for payment, arrival variance rises before the gate stops. I adopt the “stutter before failure” concept, but not repeated portal closure and reopening.

The portal remains a stable full-width portal. The **dispatch rhythm** flickers, not the aperture.

## 5. Dry transmission

A visible scout completes its full broadcast, but no portal opens because the marrow cannot pay even the cheapest dispatch.

This tells the player that:

- The scout did its job.
- The reinforcement layer did not answer.

It does not tell him whether the cause was negative reserve, active-breach capacity, or blackout, so it is a weaker quantitative gauge.

## 6. Exhaustion closure

The breach receives its ten-second exhaustion grace and collapses. This is certain but late: it confirms the invasion window rather than predicting it.

## 7. Direct inspection

Crossing into the hub reveals:

- Vacant guardian posts.
- Empty staging tracks.
- Disabled or damaged Collars.
- Dim Source conduits.

This is the highest-information observation but requires committing to the raid.

### What a new player notices first

The first causal tell is probably:

> A stationary, pulsing scout broadcasts; a wall opens afterward.

The first reserve-state tell is probably:

> Reinforcements used to arrive regularly, then there was one unnaturally long empty beat.

Do not rely on the player estimating autocorrelation, reading a hidden composition chart, or recognizing a subtle stat variant.

**Odds latency becomes learnable without HUD: 70%.**

---

## 2. Multi-breach allocation: **KEEP equality, replace rigid round-robin**

I reject return-weighted, winner-take-all, and cross-inhibitory allocation for the first implementation.

Those mechanisms may describe distributed allocation elsewhere, but here they damage three ratified goals:

- Multiple breaches should produce multiple fronts.
- A solved killbox should not make the marrow automatically surrender that gate.
- Low reserve should not collapse a multi-front fight into one convenient front.

Use a reserve-cost fair queue owned by the marrow:

```text
Each active breach accrues equal dispatch credit over time.
When an agent is ready:
    choose the breach with the greatest credit
    randomize exact ties
    subtract the agent's reserve cost from that breach's credit
```

A newly opened breach starts near current mean credit, not at zero, so it neither starves nor receives a catch-up flood.

Consequences:

- Two breaches receive approximately equal reserve expenditure.
- A Warden sent through one gate is balanced by several cheaper bodies through another.
- Assignment order is not deterministic.
- No breach reads another breach.
- The marrow, which owns dispatch, is the only system comparing them.

This is a small correction to “split enemies evenly”: split **combat expenditure**, not raw body count.

### Predictions

- Per-breach cumulative reserve cost remains close over overlapping active time.
- Headcounts may differ when one breach receives heavy classes.
- No stable hottest/oldest gate emerges.
- A late breach joins smoothly rather than receiving an immediate flood.

### Forbids

- Global argmax over Distress.
- Return-credit farming.
- Winner-take-all low-reserve allocation.
- Breaches querying each other.

**Odds it survives: 80%.**

---

## 3. The smallest learning layer

Lane J supports bounded storage and forgetting as useful forms, but its absolute timing transplants are not reliable. I would ship one physical evidence path, one bounded ledger, and three tactic categories.

## Evidence categories

```text
STRUCTURE:
    sentry or other player building caused the damage

LINE_FIRE:
    sustained direct weapon fire caused the damage

BLAST:
    charged Tau detonation or other area event caused the damage
```

No global combat classifier exists.

## Evidence carrier

Any corrupted combat agent may carry one evidence tag.

An agent becomes a messenger only when:

- It has a tag.
- It is below 40% HP.
- It has lost direct sight for five seconds.
- It still retains a valid reverse route to the breach through which it arrived.

It then retraces its own stored portal path. It does not navigate “toward the hub” through a global field and does not know the hub’s internals.

If the breach closes, the delivery fails and the agent resumes ordinary survival behavior.

Vagrants and lacunae are not used as renewable messengers.

## Storage

The Scriptorium holds an ordered ledger of **eight entries**.

A delivered entry is pushed to the front; the oldest is evicted.

At dispatch, entry weight is:

```text
weight(entry k) =
    0.70^k
    * 2^(-age / 75 s)
```

The 75-second half-life is invented. Its order of magnitude is chosen because it lies:

- Above the 45-second breach lifetime.
- Below the 120-second CORE blackout.
- Within a few reinforcement cycles.

## Counter effect

Each tactic’s ledger score biases a role:

| Evidence | Bias |
|---|---|
| Structure | Spitter and Flicker |
| Line fire | Brute and Warden |
| Blast | Screen bodies with increased spacing |

Counter multiplier:

```text
counter_weight = min(2.0, 1 + 0.30 * ledger_score)
```

All role weights are renormalized against the same reserve-cost budget. Learning changes composition and spacing, not HP, damage, speed, or free body count.

Newly produced agents are stamped with the current response. Existing agents do not retroactively change.

## Counterplay

The player can:

- Kill a wounded messenger before it returns.
- Close the breach before delivery.
- Switch tactics, pushing old entries down the eight-slot ledger.
- Destroy the Scriptorium.
- Destroy all Sources, which clears the ledger during reconstitution.

### Predictions

- Repeating one tactic over several successful evidence deliveries approaches roughly a 2× role bias.
- Four entries from a new tactic push an old tactic’s positional weight down to about `0.70⁴ ≈ 0.24`.
- Switching is noticeable within a few waves rather than instantly.
- Perfectly killing every potential messenger prevents long-term adaptation.
- Two generations of the same fight may contain visibly different mixes.

### Forbids

- The marrow reading world-wide weapon statistics.
- Instant learning from a shot no survivor reported.
- Permanent accumulation.
- Stat buffs.
- A messenger walking to the off-map hub without a live breach.

**Odds this smallest learning layer survives: 55%.**

The evidence-delivery rate and 75-second decay are the first likely failures.

---

## 4. Emergent focal points and oblivious leaders

I keep the director’s leader-anchored version. The research does not justify deleting the leader requirement.

I would improve the follower dwell rule using the contact-pressure state already introduced.

## Revised settlement rule

A mobile follower becomes settlement-eligible when:

- A Warden is visibly present in the same chamber.
- No hostile is visible.
- Noise < 0.20.
- Danger < 0.35.
- It has encountered at least four distinct friendlies during the last six seconds.
- Fewer than six settled followers are locally visible.

It then needs **8 continuous safe seconds** to settle, reduced from my arbitrary 12.

On settlement it:

- Remains a normal combatant.
- Stops answering external Muster.
- Emits Garrison Interior and Reach.
- Holds the chamber independently of whether the Warden later leaves.

At least two settled followers are required for functioning Garrison Interior propagation.

The Warden:

- Has no follower count.
- Emits no command.
- Chooses no base.
- Does not enter a leader state.
- May wander away normally.

The focal point therefore forms around a Warden only when local traffic has actually gathered around it. A lonely Warden passing through a quiet chamber does not spontaneously create a base.

I do not adopt per-agent delayed signal ring buffers as a leadership mechanism. They are interesting but add memory and compute cost without solving a problem the Warden-plus-contact rule leaves open.

### Predictions

- Garrison formation correlates with Warden dwell and local friendly traffic.
- Driving the Warden out before the eight-second dwell prevents new settlement.
- Existing followers persist after its departure.
- Garrison size tends toward two to six settled followers.
- Crowding suppresses additional Muster and helps excess agents move elsewhere.

### Forbids

- Distress alone converting a battlefield into a base.
- Weak “strategic” settlers that are harmless in combat.
- Hidden leader commands.
- A garrison object or garrison health bar.

**Odds it survives: 68%.**

---

# Persistence, scrubbers, and active-window limits

## Player death

Death resets none of the following:

- Reserve.
- CORE damage and passive repair.
- Blackout balance.
- Breach closure clocks.
- Signal timestamps.
- Garrison state.
- Evidence ledger and decay.
- Finite scout census.

The player revives at a pod and loses only physical position.

## Scrubber interaction

The scrubber subtracts all chamber-valued signals as specified in round 1:

```text
capacity = 1.2 signal-units/s
own chamber weight = 1.0
adjacent chamber weight = 0.5
```

It suppresses:

- The quorum virtual supporter `e`.
- Routing gradients.
- Muster.
- Garrison Interior and Reach.

It does not suppress:

- Direct sight.
- Physical contact pressure.
- A messenger’s private carried tag.
- A completed exact-position call imprint.

Quiet remains non-suspicious.

## Active-window limitation

When neither a live breach nor the player connects the hub to active simulation:

- Guardian and Caretaker movement pauses.
- Static reserve arithmetic and timestamp-based decay continue.
- Passive Source repair continues analytically.
- No offscreen scout migration or garrison expansion occurs.

When the player is trapped inside after all breaches close, his presence keeps the hub active.

This limitation will understate strategic reclamation outside the active window. It must be instrumented, not described as containment success.

---

# Revised critical constants

| System | Value |
|---|---:|
| Reserve cap | 120 |
| Full-stock regeneration | 0.10/s |
| Near-empty regeneration | 0.35/s |
| Base dispatch opportunity | 2.20 s |
| Nominal strike cost | 2.76 units/agent |
| Expected fresh-reserve drain | roughly 110–150 s before path and combat variance |
| CORE kill balance | −42 |
| Blackout resupply | 0.35/s |
| Blackout duration | 120 s |
| Guardian shelf | 10 physical agents |
| Guardian replacement floor | no faster than 1 per 12 s |
| Hub chambers | 24 |
| Typical source depth | 10–11 portal crossings |
| Quorum threshold | persistent, 0.25–0.45 |
| Contact-pressure half-life | 4 s |
| Garrison safe dwell | 8 s |
| Garrison settled followers | 2–6 |
| Learning ledger | 8 entries |
| Learning half-life | 75 s |
| Maximum counter multiplier | 2.0× role weight |

The 120-second blackout is not a separate timer:

```text
42 units / 0.35 units/s = 120 seconds
```

---

# Constants most likely to be wrong

In order:

1. **Learning half-life: 75 seconds.**
2. **Messenger trigger: below 40% HP.**
3. **Contact-pressure half-life: 4 seconds.**
4. **Quorum threshold range: 0.25–0.45.**
5. **Strike-package breaker share: 25%.**
6. **Guardian shelf size: 10.**
7. **Hub depth: 10–11 crossings.**
8. **Garrison contact requirement: four friendlies in six seconds.**
9. **Reserve drain window: 110–150 seconds.**

The structural rules I am more confident in are:

- No portal scaling.
- No entry special case.
- No cheap-class substitution at low reserve.
- Dynamic portal-graph invalidation.
- Physical evidence return through a live breach.
- No renewable Adversary scouts.
- Cost-fair multi-breach allocation.
- No mandatory CORE attack order.

---

# Highest-risk remaining assumption

The load-bearing assumption most likely to fail is now:

> A player can afford to exhaust the guardian shelf, recognize the resulting latency, enter during closure grace, fight a two-to-three-minute hub raid, and still regard the blackout as tactically useful rather than as compensation for an expedition that consumed the entire opportunity.

My prior that this works without timing revision is about **2:3, or 40%**.

The discriminating human-playtest measurements are:

- First moment the player correctly predicts exhaustion.
- Delay from that recognition to crossing.
- Guardian count remaining on entry.
- Time to third Source kill.
- Time from CORE kill to return to the intended world-side objective.
- Usable blackout seconds remaining.
- Whether the player regards a Portable Hole as preparation or as a mandatory key.

If successful players return to the assault front with less than about 45 useful blackout seconds, keep the economic equation but deepen the negative balance. Do not add a separate timer.