# Executive recommendation

Ship a deliberately smaller first marrow than the packet proposes:

- **Closed-loop reserve governor:** yes.
- **Runts, overshoot, corpse recycling, dynamic aperture growth, reverse-traffic veterans, field factories, vitrification, false beacons:** not in the first implementation.
- **CORE:** a redundant production network with optional attack surfaces, not a scripted boss sequence.
- **Guardian ring:** the live front shelf of the reserve, so dispatch weakens the hub.
- **Breaches:** fixed-width, scale-free real portals cut at prevalidated wall sites nearest the transmitted position.
- **Vagrant:** fast open-ground infiltrator.
- **Lacuna:** weaker boundary scout that probes through a portal without crossing, but may only call into the chamber it physically occupies.
- **Garrisons:** leader-anchored, follower-created. The leader remains oblivious.
- **Scrubber:** a subtractive, capacity-limited sink. Quiet is not independently suspicious.
- **Reinforcement fight:** opening burst, sustained pour, then an arresting cordon. No conga line and no bespoke entry behavior.

I would build this vertical slice before adding the packet’s more exotic mechanisms.

## Confidence calibration

I did not count duplicated packet findings as independent evidence. In particular, the reserve-governor reports in lanes A and E are the same underlying experiment, as are several of the arrest findings.

Two representative updates:

- **Closed-loop governor versus flat regeneration:** prior 1:1. Evidence that it satisfies finite supply, deficit response, and spotter decoupling is likely under the governor at about 0.9 and under flat regeneration at about 0.4: LR ≈ 2.25, posterior ≈ 2.25:1. The sourced mechanism weakly increases that, but not as an independent replication. I land around **3:1, 75%** that the basic rule survives.
- **Arresting cordon versus continuous gradient rush:** prior 1:1. The previous conga/failure observation is about 0.8 likely if continuous rushing is the wrong model and perhaps 0.3 if it is adequate: LR ≈ 2.7. The requirement that fallback be fought through adds roughly another ×1.5. That reaches about 4:1 before implementation risk; I discount to **7:3, 70%**.

Those are design odds, not claims of fact.

---

# Part 1 — Recommendations on the open questions

## 1. The CORE as a system of agents

### Recommendation

Ship a four-part redundant production network:

1. **Three Source Knots** in the deepest chamber.
   - Each contributes one-third of source capacity.
   - Destroying one reduces future regeneration after a pipeline delay.
   - Destroying all three causes a CORE kill and drives the reserve negative.

2. **Four Anchors**, each supporting three **Producer Buds**.
   - An attached bud contributes to reserve regeneration.
   - Destroying an anchor immediately releases its attached buds as ordinary low-tier defenders and removes their production after the pipeline delay.
   - Anchors are rebuilt by caretakers.

3. **Four Caretakers**.
   - They heal damaged parts, reconstruct anchors, and replace missing buds.
   - Killing them does not damage production immediately, but prevents rapid recovery.

4. **Two Dispatch Collars** near the receiving chamber.
   - Destroying them immediately reduces dispatch cadence.
   - They do not affect reserve regeneration.
   - They are optional attack surfaces, not keys required to reach the Sources.

The intended attack order is therefore:

- Collars for immediate relief.
- Caretakers to make damage stick.
- Anchors for delayed economic damage.
- Sources for the tactical blackout.

The player may ignore the first three and rush the Sources. Nothing is invulnerable, no door waits for a phase transition, and there is no master health bar.

### Mechanism

The parts have opposite time constants:

- Collars affect the current fight immediately.
- Anchors and buds affect regeneration after a delay.
- Caretakers determine whether damage persists.
- Source loss determines the blackout.

That makes target choice contextual instead of a prescribed boss sequence. A player entering an almost-empty hub may rush the Sources. A player caught in a heavily occupied hub may destroy a collar first and retreat.

CORE self-defense is also systemic: damage to a core part schedules a response six seconds later. At that time attached buds detach into defenders and local guardians converge through normal Muster behavior. The CORE never reads the player; it responds to damage to its own parts.

### Predicts

A successful implementation should produce different valid raid traces:

- A collar-first raid should reduce dispatch within seconds but leave reserve regeneration unchanged.
- An anchor-first raid should create an immediate local defender spike, followed around 20 seconds later by slower reserve regeneration.
- A caretaker-first raid should show little immediate benefit but markedly less restored CORE health on a second push.
- A Source rush should be fastest but have the highest incoming pressure.

### Forbids

- A mandatory attack order.
- An invulnerable CORE phase.
- One high-HP object whose death alone ends the response.
- CORE health remaining partially depleted after an ordinary death-and-walk-back unless the player established a real foothold.

### Odds

**68%** that this overall shape survives.

**Strongest reason I may be wrong:** the distinctions may be mechanically real but unreadable during a very fast top-down firefight, leaving players to shoot whatever is nearest. If target attribution is weak in recorded play, simplify the organ rather than adding UI.

---

## 2. Reserve economy

### Recommendation

Endorse the **depot-deficit governor**, but do **not** ship degraded runt variants in the first implementation.

Use dispatch-unit costs:

| Kind | Reserve cost |
|---|---:|
| Mite | 1 |
| Husk | 2 |
| Spitter | 2 |
| Shrieker | 3 |
| Flicker | 3 |
| Brute | 4 |
| Warden | 8 |

First-pass reserve:

```text
reserve_cap = 120 units

regen =
    0.10 units/s
    * (1 + 2.5 * clamp(1 - reserve/reserve_cap, 0, 1))
    * delayed_production_factor
```

Thus:

- Near full: about **0.10 units/s**.
- Empty: about **0.35 units/s**.
- Regeneration never reads Distress, Noise, kills, player state, or difficulty.
- Reserve is clamped at 120 while the CORE is alive.
- No overshoot in the first implementation.

Use this reinforcement mix:

| Kind | Weight |
|---|---:|
| Mite | 24% |
| Husk | 22% |
| Spitter | 16% |
| Brute | 12% |
| Shrieker | 10% |
| Flicker | 10% |
| Warden | 6% |

The average dispatch costs approximately 2.56 reserve units.

### Why no runts yet

The packet’s runt proposal is attractive as diegetic feedback, but it has three risks:

1. It creates a reverse difficulty curve: sustained success makes later enemies individually worse.
2. It multiplies silhouettes, tuning, and class testing before the base stream works.
3. It can make farming the breach increasingly safe, contrary to “eventually overwhelm and win.”

Low reserve is already legible through:

- Longer pauses when the remaining balance cannot pay for the sampled class.
- Increasingly cheap composition as expensive draws become unaffordable.
- Faltering dispatch before closure.
- Visible collapse of an existing breach when the reserve is exhausted.

Do not add explicit “runt” variants until the stable stream has been proven too opaque.

I also reject the research packet’s 28:1 sizing anchor. The critic correctly flags it as unsupported, and a roughly twelve-minute drain would make the invasion window irrelevant to ordinary play.

### Mechanism

At one dispatch every 2.2 seconds, the nominal demand is about 1.16 reserve units/s. Against maximum regeneration of 0.35 units/s, a fresh reserve drains in roughly 2.5–3 minutes, plus the initial guardian shelf. That is long enough to make fighting the stream a substantial encounter but short enough for exhaustion to occur in a deliberate firebase stand.

### Predicts

- Plotting regeneration against reserve deficit should produce a near-linear relation.
- Adding Distress or kill count to a regression should add no explanatory value.
- A sustained one-breach fight should usually exhaust a fresh reserve in about 150–210 seconds.
- Light intermittent calls should recover between contacts; a committed sustained call should outrun production.

### Forbids

- Regeneration increasing because the player is performing well.
- A constant unlimited trickle.
- Reserve exhaustion in one incidental ten-second skirmish.
- An ordinary breach taking ten or twelve minutes to drain.
- Low reserve automatically producing weaker stat variants.

### Odds

**76%** for the governor and approximate drain window.

**Strongest reason I may be wrong:** the existing combat’s actual kill rate may be far below or above the assumed dispatch rate. The first measurement should be player kills per minute and ammunition spent during a defended breach, not whether the stock graph looks elegant.

---

## 3. CORE kill as a status effect

### Recommendation

Keep the director’s ruled deep-negative economy. Do not replace it with a separate rebuild timer.

On destruction of all Source Knots:

```text
reserve = -42 units
core_state = BLACKOUT
```

During blackout:

```text
home_resupply_rate = 0.35 units/s
```

Therefore:

```text
blackout duration = 42 / 0.35 = 120 seconds
```

This produces the required couple of minutes from the same unit economy. There is no separate “120-second blackout” countdown.

At reserve crossing above zero:

- Reconstruct one Source Knot, one Anchor, three Producer Buds, and one Caretaker.
- Return the CORE to an alive but weak state.
- Resume the ordinary governor.
- New breaches still require a fresh valid call; old calls are not queued indefinitely.

### What the player observes

At the start:

- Dispatch stops.
- Existing breaches receive a ten-second exhaustion grace, then collapse regardless of crossings.
- No new portal opens.
- Scouts continue to transmit because they do not know anything happened.
- A dry transmission is consumed with no portal. It may produce a brief non-crossable wall scar or failed-incision effect, but never a portal.

During blackout:

- Signal fields, scouts, existing garrisons, and ordinary enemies continue operating.
- No called or direct breach opens.
- If the player remains in the hub, surviving guardians and ordinary agents still fight.

At the end:

- The hub’s deep chamber visibly resumes pulsing.
- A minimal production chain reforms.
- There is no global klaxon or HUD message.
- The next valid scout call may reopen the reinforcement layer.

### Predicts

Across runs with no further interference:

```text
core_kill_to_reserve_zero ≈ 120 seconds
```

Changing the home resupply rate should change the outage duration proportionally. There should be zero newly opened breaches during negative reserve.

A player holding the sanctum can repeatedly kill the newly reconstructed network and extend the outage, which is the intended reward for establishing a real foothold.

### Forbids

- A fixed timer independent of reserve.
- Reserve regeneration shortening because of combat elsewhere.
- Existing old calls all resolving immediately at blackout end.
- Permanent victory from one CORE kill.

### Odds

**82%**.

**Strongest reason I may be wrong:** two minutes may be tactically useless if travel from the hub to a fortified objective consumes most of the window. Measure “usable blackout seconds after returning to the intended assault front,” not just the exact economic duration.

---

## 4. Dispatch and crossing

### Recommendation

Take half of the packet’s patch-inventory proposal:

- **Yes:** precompute viable wall sites at world initialization.
- **No:** no aperture growth, seam agitation, key cache, antechamber, pressure valve, or moving mouth in the first implementation.

Each chamber receives one to three validated breach sites on ordinary wall segments. A scout transmits its exact position. The marrow selects the viable site in that chamber nearest the transmitted position, subject to clearance.

The resulting portal:

- Is two-way.
- Uses a rigid transform with translation and rotation only.
- Has no scale field at all.
- Has width:

```text
max(96 world units, 2 * largest_dispatchable_radius + 16)
```

- Connects to a distinct wall segment in the hub Receiving Apse.
- Uses ordinary navigation, collision, portal traversal, and AI.
- Never adjusts an agent’s velocity, radius, or position specially.

The site inventory never grows. The aperture never widens. Reuse only affects the ordinary 45-second crossing timer.

### Pour cadence

- Breach formation: 3 seconds.
- Global dispatch interval: 2.2 seconds with both collars intact.
- First dispatches come from the physical guardian ring.
- Later dispatches are instantiated in the hub production area and walk normally to the portal.
- With multiple breaches, dispatch assignments use strict round-robin. Crossing-count difference should never exceed one except for unaffordable class draws or path failure.

### Closure

A breach closes on the first applicable condition:

1. No entity or projectile crossing for 45 seconds.
2. Reserve exhausted, followed by a 10-second invasion grace.
3. No normal path reservation by a hub-side dispatched agent for 12 seconds after opening grace.

The breach object itself does not inspect the reserve or other breaches. The marrow requests exhaustion closure; the pathing system supplies ordinary route-interest counts.

### Why reject dynamic growth

The packet’s dynamic width proposals conflict with the director’s instruction to make the aperture simply wide enough. Starting it narrow intentionally recreates the failure mode the spec is trying to eliminate. The alleged antechamber timing ratio is also explicitly flagged as unfetched and must not anchor tuning.

### Predicts

- Every dispatched class should cross without collision intervention.
- Time spent blocked inside the aperture should be statistically similar to time spent at an ordinary wide portal.
- Two live breaches should receive nearly equal dispatch counts.
- Repeated calls in one chamber should reuse a small learnable set of sites near the caller’s actual position.

### Forbids

- Spawn bursts directly on the world side.
- Agent scaling at the connection.
- Entry invulnerability or immobility.
- A one-wide mouth that the player “levels up” by allowing crossings.
- Older breaches receiving more agents than newer ones.

### Odds

**78%**.

**Strongest reason I may be wrong:** fixed sites may become too predictable and make every eligible wall a pre-solved killbox. If that happens, increase the number and spatial spread of validated sites before adding dynamic width or crossing machinery.

---

## 5. Vagrant and lacuna

### Recommendation

### Vagrant — stronger open-ground infiltrator

- HP: 84.
- Speed: 1.45× base Commando speed.
- Mass: 1.6× Commando.
- Turn rate: 0.55× Commando.
- Contact damage: 18, 1.1-second recovery.
- Prefers broad chambers, low Patrol, low Trail, low Danger, and low Kin.
- Uses long committed room-to-room legs but still runs the standard sight query at 5 Hz. I reject the packet’s deliberately blind long legs because they conflict with the ratified line-of-sight behavior.
- Silhouette: tall split sail, narrow body, long forward lean.

### Lacuna — weaker boundary scout

- HP: 42.
- Speed: 1.20× Commando.
- Mass: 1.4× Commando.
- Turn rate: 0.50× Commando.
- Contact damage: 10, 1.3-second recovery.
- Hugs walls and portal mouths.
- May root for 3 seconds at a portal and probe the adjacent chamber through the `find` API.
- A probe reveals visible players, structures, and enemies in the adjacent chamber from the portal plane.
- A probe does not count as a crossing and may be severed by damage through the portal mouth.

Critically, a lacuna may only transmit a position in the chamber its body physically occupies. It cannot call a breach behind a cordon merely because it probed through it. The research candidate allowing that would contradict the director’s containment reward.

Lacuna is the weaker Adversary class. If both classes are in a chamber, lacuna receives the call priority and vagrant keeps fighting.

### Transmit sequence

Both classes:

1. **Brace:** stationary for 1.5 seconds.
2. **Rooted broadcast:** stationary, unable to attack or steer.
3. **Release:** 0.5 seconds before moving again.

Broadcast durations:

- Vagrant: 6 seconds.
- Lacuna: 8 seconds.

Total exposure:

- Vagrant: 8 seconds including brace and release.
- Lacuna: 10 seconds.

The whole sequence is interruptible by damage or displacement. Interruption releases the shared transmission lease and forces a new site selection.

The broadcast emits a distinctive pulse once per second. It is:

- Visually obvious on the silhouette.
- Audible through up to two portal hops using the ordinary audio propagation system.
- Logged through the telemetry event stream independently of audio.

### Mechanism

Vagrants are dangerous because they travel quickly through open ground and can survive contact. Lacunae are dangerous because they collect information without entering the defended chamber and can choose safer routes, but they are easier to kill and slower to reposition.

This makes doorway coverage useful without nullifying a true cordon.

### Predicts

- Vagrants should account for most deep infiltrations and long displacement.
- Lacunae should spend more time at portal boundaries and should be killed disproportionately during probing or broadcasting.
- A turret covering a portal mouth should interrupt more lacuna actions than a turret covering only the chamber interior.
- Players should identify a transmission before they can name the scout class.

### Forbids

- Lacuna calling into a chamber it never entered.
- Vagrant becoming blind to a player in ordinary line of sight.
- Either scout fighting and transmitting simultaneously.
- One class being only a stat-swapped version of the other.

### Odds

**67%**.

**Strongest reason I may be wrong:** probing may not be valuable enough in a portal graph where both classes already sample adjacent signal values. If recorded lacuna route choices and survival do not differ from vagrants, remove the probe rather than adding hidden bonuses.

---

## 6. Held ground and garrisons

### Recommendation

Use the director’s **leader-anchored version**, composed with a follower settlement threshold. Do not use leaderless Distress conversion.

Initial leader class: **Warden**.

The Warden remains completely oblivious:

- It does not emit a special leader command.
- It does not acquire followers.
- It does not select a base.
- Its state machine is unchanged.

A non-leader agent may settle if:

- A Warden is physically present in its chamber.
- No hostile is visible.
- Noise < 0.20.
- Danger < 0.35.
- It has remained in that chamber for 12 continuous seconds.

On settlement:

- The follower stops answering ordinary Muster outside the chamber.
- It continues fighting normally if threatened.
- It emits Garrison Reach and emits Garrison Interior in its own chamber.
- At least two settled followers are required before the chamber counts as a functioning garrison source.

Interior spreads into another chamber only when garrison emissions arrive there through two different portal fronts. Otherwise it remains Reach.

The Warden can wander away. If no Warden remains, settled followers persist, but no new followers settle until another leader-capable agent arrives.

### Why reject leaderless conversion

Leaderless Distress conversion would make the hottest combat chambers become enemy bases. That contradicts the specified caller behavior of finding safe ground behind the line and would cause nearly every major fight to leave a garrison. It also directly overrules the director’s leader ruling.

The packet’s “weak fighter but loud emitter” proposal is also rejected. Settlers should remain real combatants. Otherwise visual threat and strategic threat diverge in a way likely to feel like a targeting trick rather than an intelligible system.

### Predicts

- Garrison formation locations should correlate strongly with Warden dwell time, even though Wardens never enter a leader state.
- Killing or driving away a Warden before the 12-second follower dwell completes should prevent settlement.
- An existing garrison should survive the Warden’s later departure.
- A run that kills Wardens promptly should show materially fewer garrisons.

### Forbids

- A garrison forming solely because Distress is high.
- Warden AI knowing it has followers.
- A hidden base object or garrison health bar.
- Random reactivation behind a physically intact cordon.

### Odds

**72%**.

**Strongest reason I may be wrong:** Wardens may be too rare, causing the entire garrison system to appear only occasionally. The first fallback should be adding Brute as a second leader-capable class—not deleting the leader requirement.

---

## 7. Signal damping and cloaking

### Recommendation

Ship the scrubber as a **subtractive, shared-capacity sink**.

At 10 Hz, one scrubber removes up to:

```text
1.2 total signal-units/second
```

across:

- Its own chamber at weight 1.0.
- Every chamber one portal away at weight 0.5.
- All signal channels, sharing the same capacity budget.

Removal is proportional to the covered positive values. Unused capacity is lost; it is not banked. Several scrubbers add capacity linearly.

This means:

- Quiet movement and residue can be almost erased.
- Sustained weapons fire, repeated kills, and multiple channels saturate the sink.
- A scrubbed base is concealed under low load and leaks under heavy combat.
- An agent physically entering the base still sees and attacks structures normally.
- Calls and call imprints are not chemo-signals and are not erased.

A scrubbed region is **not** suspicious merely because it is quiet. Agents only sample their chamber and adjacent chambers. They have no regional baseline against which to infer an anomalous absence. Adding a “quiet-hole detector” would undermine stealth and introduce an extra recognition system with no need.

The natural cost is opportunity and fragility:

- Scrubber kit: 6 components.
- Thirty-second ordinary unpack period.
- Destroyed on contact like other player buildings.
- Projectile enemies prioritize it as a building.
- It occupies a carried-kit cycle that could have built a sentry or repair station.

### Cleaning robot

A scrubber linked to a pod within one portal hop provides one robot:

- Move speed: 0.8× Commando.
- One corpse carried at a time.
- Five seconds to process a corpse at the pod.
- Each corpse has a 25% chance to produce two components.
- Splatter and casings are cosmetic cleanup and never produce reserve currency.
- A corpse may yield only once.

Do not ship cleanup ramping or corpse spoilage in the first implementation. The packet explicitly admits the proposed ramp magnitude is invented, and corpse-generated Distress conflicts with the ratified signal rule that Distress comes from agents being harmed.

### Predicts

- Under low activity, covered field values should fall by substantially more than half.
- Under a major fight, scrubber consumption should pin at 1.2 units/s and signals should leak.
- A quiet pod without a scrubber should often remain undiscovered; a frequently fought-over unscreened pod should eventually attract patrols.
- Agents already inside scrubbed ground should still acquire buildings through ordinary sight.

### Forbids

- “Scrubber on” meaning signals are disabled.
- A scrubber cancelling direct vision.
- A quiet region automatically becoming a target.
- Cleanup directly regenerating or draining the marrow.
- One robot becoming an unlimited component fountain.

### Odds

**62%**.

**Strongest reason I may be wrong:** this may still become a mandatory tax on every serious pod. Compare survival and discovery rates for quiet unscreened pods, active screened pods, and active unscreened pods. If quiet unscreened pods are routinely purged, patrol logic—not scrubber price—is wrong.

---

## 8. Where the reinforcement stream becomes the fight

### Recommendation

Give one breach a four-part arc:

1. **Opening tell, 3 seconds**
   - Visible wall removal and portal lighting.
   - No world-side spawning.

2. **Guardian burst, approximately 6 seconds**
   - Up to four existing guardian-ring agents receive the route first.
   - They physically cross at roughly 1.2–1.8-second spacing depending on travel.

3. **Sustained pour**
   - Global purchase opportunity every 2.2 seconds.
   - All agents spawn in the hub, walk normally, and cross normally.
   - Multiple breaches split assignments evenly.

4. **Cordon formation and exhaustion**
   - Agents integrate local Muster exposure.
   - Once saturated, agents without direct contact stop rushing and hold portal approaches or likely retreat crossings.
   - Other agents continue pressing the player.
   - The result should be attackers near the player plus a looser outer shell obstructing fallback.
   - Eventually reserve stalls and the breach collapses.

Per-agent arrest threshold:

```text
muster_exposure += local_muster * dt
muster_exposure decays at 0.5 units/s
threshold sampled once in [2.5, 4.0] signal-seconds
```

An agent may enter `CORDON` only if:

- It is in or adjacent to the target chamber.
- It does not currently see the player.
- It is not already in contact.
- Its exposure exceeds its threshold.

Direct sight or damage breaks the cordon state into combat.

### Why this differs from a player-started fight

A player-started fight begins with immediate local contact and then recruits outward through Noise and Muster.

A breach fight has:

- A visible opening.
- A short hard burst from existing defenders.
- A sustained supply rhythm.
- A delayed spatial transformation as arrivals begin holding exits rather than merely charging.

The stream has a beginning, escalation, positional consequence, and economic end. It is not a flat spawn timer.

### Predicts

- Agent distance from the player should become bimodal: contact attackers plus an outer holding shell.
- Retreat attempts should increasingly encounter held portal approaches.
- Reinforcements should no longer appear as a single line walking into the same gun.
- A player standing still at a perfect mouth should take increasing positional pressure even if his raw kill rate remains high.

### Forbids

- Every reinforcement taking the shortest route into the same doorway.
- A fixed number-wave followed by silence while reserve remains.
- A scripted formation controller.
- Mouth-transit invulnerability or attack locks.
- A breach fight looking identical to waking a room of idle enemies.

### Odds

**65%**.

**Strongest reason I may be wrong:** the fixed portal is intrinsically such a strong killbox that arrest outside it cannot compensate. If a competent firebase converts ammunition to kills with negligible health or territorial cost, cadence and approach fan must be fixed before adding more reserve.

---

## 9. Load-bearing assumption most likely wrong

The most questionable assumption is:

> A physically fixed, finite-throughput portal can be both the player’s intended place to stand and fight and a source that can eventually defeat a competent prepared firebase.

Those goals are in tension. A fixed mouth concentrates enemies, exposes their approach, and makes sentry fire maximally efficient. If the stream is strong enough to defeat that system by raw cadence, an unprepared player may find it arbitrary and irresistible.

My prior that the first cadence solves this without redesign is about 1:1. Arrest and multi-route movement increase the chance, but the mouth remains a severe geometric advantage. I put the chance that the assumption survives unchanged at **40%**.

### Discriminating test

Run matched full encounters and record:

- Player ammunition spent.
- Damage taken.
- Structures lost.
- Retreat portals denied.
- Reserve units dispatched.
- Concurrent agents near the fight.
- Kills per minute at the mouth versus one chamber away.

The assumption is falsified if fighting directly at the mouth is strictly better on all of those dimensions. In that case, do not simply increase enemy HP or damage. Change approach geometry, arrest positions, and multi-route pressure.

A related known limitation is that distant agents are not richly simulated. Therefore offscreen garrison expansion will pause outside the active window in this draft. Instrument how much scout and garrison time is lost to inactivity; do not explain that artifact as successful containment.

---

# Part 2 — First implementation draft

## 1. Agent and entity inventory

## 1.1 Hub layout

Build the hub at every world initialization. It is never optional and never `None`.

First hub graph:

```text
                    [Guardian Ambulatory L]
                   /                        \
[Receiving Apse] --                          -- [Reserve Nave]
                   \                        /
                    [Guardian Ambulatory R]

[Reserve Nave] -- [Production Chapel L] --\
                                            [Caretaker Crossing] -- [Inner Choir]
[Reserve Nave] -- [Production Chapel R] --/
```

Eight convex chambers:

1. **Receiving Apse**
   - Every live world breach connects to a separate validated wall segment here.
   - Large enough for several simultaneous portals without overlap.
   - No source parts placed near the mouths.

2–3. **Guardian Ambulatories**
   - Two routes around the receiving chamber.
   - Initial guardian ring patrols here and in the Reserve Nave.

4. **Reserve Nave**
   - Two Dispatch Collars.
   - Main route between breach mouths and production.

5–6. **Production Chapels**
   - Two Anchors in each.
   - Three Producer Buds per Anchor.

7. **Caretaker Crossing**
   - Caretaker patrol loop.
   - Joins both production routes.

8. **Inner Choir**
   - Three Source Knots.
   - Deepest chamber and hardest retreat point.

The diamond structure gives two approach routes without creating a maze. The player may flank guardians, destroy either production side, or rush the Inner Choir.

## 1.2 CORE entities

### Source Knot ×3

```text
hp                 168
move_speed         0
source_share       1/3
passive_regen      1 hp/s after 12 s without damage
caretaker_heal     8 hp/s per attached caretaker
rebuild_missing_caretaker_after 25 s
rebuild_missing_source_after    60 s, if another Source survives
```

A rebuilt Source begins at 50% HP. If all three are absent, ordinary rebuild stops and blackout begins.

### Anchor ×4

```text
hp                 84
move_speed         0
bud_capacity       3
caretaker_rebuild  30 s
```

Destroying an Anchor detaches its live buds. Detached buds become defenders and stop production immediately at the source, with the reserve effect delayed by the production pipeline.

### Producer Bud ×12

```text
hp                 42
move_speed         0 while attached
production_share   1/12
caretaker_rebuild  12 s
```

On anchor loss or delayed defense release, a bud converts into a Mite or Husk through the existing enemy creation path. Do not create a new combat class for it.

### Caretaker ×4

```text
hp                 42
speed              1.25 × Commando
mass               1.5 × Commando
turn_rate          0.5 × Commando
contact_damage     8
contact_recovery   1.5 s
repair_range       ordinary physical contact range
heal_rate          8 hp/s
```

Priority:

1. Flee direct line of fire.
2. Heal a damaged Source.
3. Rebuild a missing Anchor.
4. Rebuild a missing Bud.
5. Repair a Dispatch Collar.
6. Patrol the Caretaker Crossing.

All choices use local and one-hop observations. A Caretaker travels deeper by repeatedly selecting a one-hop portal, never by querying a global target list.

### Dispatch Collar ×2

```text
hp                 126
move_speed         0
repair_time        45 s
```

Cadence multiplier:

| Live collars | Multiplier | Dispatch interval |
|---:|---:|---:|
| 2 | 1.00 | 2.20 s |
| 1 | 0.70 | 3.14 s |
| 0 | 0.45 | 4.89 s |

Collars do not stop dispatch completely.

## 1.3 Delayed CORE response

Any damage to a CORE part after 20 seconds without prior CORE damage schedules one defense response for six seconds later.

At response time:

- Detach up to two Producer Buds from the damaged chamber.
- Convert them through the normal Mite/Husk creation path.
- Emit local Muster.
- Wake guardian-ring members through ordinary quorum rules.

No direct player reference is stored. The trigger record is:

```text
damaged_part_id
damaged_chamber_id
response_due_tick
```

## 1.4 Guardian ring

Initial live roster:

- 3 Mites
- 2 Husks
- 1 Spitter
- 1 Brute
- 1 Shrieker
- 1 Flicker
- 1 Warden

The first four eligible dispatches after a quiet period are assigned from this ring. Once those agents cross into the world, the hub is physically weaker.

Missing ring positions are replenished from reserve at no more than one agent per ten seconds. Replenishment uses the same reserve costs and enemy factory as ordinary dispatch.

There is no separate immortal guard population.

## 1.5 Scout classes

Use the Vagrant and Lacuna definitions from Part 1.

Every scout has:

```text
class_rank                 # lacuna 0, vagrant 1
call_state
calls_completed
last_seen_player_chamber
last_seen_player_position
committed_call_position
broadcast_lease_id
current_portal_probe
garrison_cycle_phase
safe_dwell_time
```

The scouts never hold a hub reference, reserve reference, breach manager reference, or CORE reference.

## 1.6 Breach entity

```text
Breach:
    id
    world_chamber_id
    world_site_id
    hub_site_id
    portal_handle
    target_position
    opened_tick
    active_tick
    last_crossing_tick
    exhaustion_close_tick | None
    zero_interest_since_tick | None
    close_reason | None
```

The portal transform is a rigid transform type that contains only:

```text
translation
rotation
```

It has no scale member. Portal construction fails if the world and hub apertures do not have matching physical width.

Every body and projectile crossing emits the ordinary generic `PortalCrossed` event. The breach listens only for events naming its portal handle.

## 1.7 Call imprint

A completed broadcast creates:

```text
CallImprint:
    chamber_id
    position
    created_tick
    expires_tick
    caller_class
    caller_id_for_telemetry_only
```

Lifetime: 15 seconds.

The imprint does not contain reserve demand, hub state, desired enemy mix, or success state.

The marrow independently consumes an imprint when it samples it. Consumption happens whether or not a portal is opened. Calls do not queue until resources become available.

## 1.8 Direct flank breach controller

At 2 Hz, scan Distress for the extreme-turtle rule:

```text
Distress >= 1.60 continuously for 20 s
global direct-breach cooldown = 180 s
```

If eligible:

- Select the hot chamber or one adjacent chamber with the lowest Trail and a valid site.
- Open one direct breach if reserve permits.
- It may temporarily raise total live breaches from two to three.
- It then participates in the same even round-robin dispatch.

This controller is separate from the CORE’s regeneration. It reads the shared signal substrate, not player state.

---

## 2. State and ownership

## 2.1 Find/senses API

Agents receive immutable observations, never system references.

```python
find.visible(
    observer_id,
    kind_mask,
    portal_depth=0 | 1,
) -> tuple[SenseHit, ...]

find.in_chamber(
    observer_id,
    tag_mask,
) -> tuple[SenseHit, ...]

find.adjacent_portals(
    observer_id,
) -> tuple[PortalSense, ...]

find.probe_through_portal(
    observer_id,
    portal_id,
    kind_mask,
) -> tuple[SenseHit, ...]
```

`SenseHit` contains only perceptible information:

```text
entity_id
kind
class_rank if visually identifiable
chamber_id
position
velocity
bounds
visible_tags
```

`PortalSense` contains:

```text
portal_id
active
portal_kind
aperture
opposite_chamber_id
visible_mouth_position
```

It does not expose destination internals, reserve state, queued agents, or breach age.

Queries are rejected if `portal_depth > 1`.

The lacuna probe uses the portal-plane viewpoint and only returns entities visible from that plane. It is not a general adjacent-room wallhack.

## 2.2 Signal storage

One strictly necessary new signal is added: **Kin**. It is explicitly required by the ratified garrison expansion.

No other chemo-signal is added.

```text
SignalKind:
    DISTRESS
    DANGER
    NOISE
    TRAIL
    PATROL
    MUSTER
    GARRISON_INTERIOR
    GARRISON_REACH
    KIN
```

Per chamber:

```text
values[9]
pending_emission[9]
last_decay_tick
garrison_incoming_portal_mask
```

Decay is always applied from `current_tick - last_decay_tick` before reading or writing the chamber.

Call imprints are not a new scalar signal. They are exact-position transient transmissions. Encoding them as a diffusing chamber scalar would destroy the transmitted position and make multiple calls indistinguishable.

## 2.3 Signal constants

All values are unitless.

| Signal | Cap | Half-life | Hop spread | Primary writes |
|---|---:|---:|---:|---|
| Distress | 2.0 | 45 s | 0.45 | harm, death |
| Danger | 1.0 | 180 s | 0 | death |
| Noise | 2.0 | 4 s | 0.65 | gunfire, movement, contact |
| Trail | 1.0 | 12 s | 0 | player presence |
| Patrol | 1.0 | 60 s | 0 | patroller presence |
| Muster | 1.5 | 1.2 s | 0.25 | engaged and holding agents |
| Garrison Interior | 1.0 | 5 s | special | settled agents |
| Garrison Reach | 1.0 | 6 s | 0.65 | settled agents |
| Kin | 1.0 | 6 s | 0.35 | Adversary presence |

Initial emissions:

```text
Distress on damage = 0.30 * damage/max_hp
Distress on death  = +0.35
Danger on death    = +0.40
Noise ordinary shot = +0.35
Noise heavy shot    = +0.60
Trail player write  = max(current, 0.80), every 0.25 s
Patrol emission      = +0.05/s
Muster engaged       = +0.50/s
Muster holder        = +0.25/s
Garrison Interior    = +0.40/s in settled chamber
Garrison Reach       = +0.35/s
Kin per Adversary    = +0.04/s
```

Distress is not emitted merely because an agent sees the player. Contact emits Noise and Muster. This preserves the ratified rule that Distress represents agents being harmed.

Garrison Interior is emitted directly in the settled chamber. It crosses into another chamber only if that chamber receives live garrison input through two distinct portal IDs during the same signal window. Otherwise only Reach propagates.

## 2.4 Per-agent signal memory

Each coordination-capable agent keeps:

```text
accumulator[SignalKind]
muster_exposure
quorum_threshold
arrest_threshold
faint_signal_time
```

First-pass thresholds:

```text
quorum_threshold  ~ uniform(0.35, 0.55)
arrest_threshold  ~ uniform(2.5, 4.0) signal-seconds
muster exposure decay = 0.5/s
stand-down local threshold = 0.15
stand-down duration = 5 s
```

The accumulator time constants may initially match chamber half-life behavior rather than adding the packet’s full priority model. Once fields are verified live, add per-agent short/long retention only if mixed-field navigation is actually incoherent.

## 2.5 System read/write matrix

| System | Reads | Writes |
|---|---|---|
| Vagrant | own/adjacent signals, local find results, own memory, call-medium result | Patrol, Kin, Call Imprint |
| Lacuna | same, plus probe result | Patrol, Kin, Call Imprint |
| Combat enemies | own/adjacent signals, local find | Distress through damage events, Noise, Muster, Kin |
| Settled followers | same | Garrison Interior, Reach, Kin, Muster |
| Call medium | current lease and time | lease result, Call Imprint |
| Marrow | Call Imprints, reserve, CORE state, collar count, breach handles | portals, dispatch assignments, reserve balance |
| Breach | portal crossing events, route-interest count, close requests | portal lifetime state |
| CORE | own part state, own reserve balance, local damage | production factor, repair jobs, defenders |
| Flank controller | chamber Distress/Trail, reserve eligibility | direct Call-equivalent request |
| Scrubber | covered signal values | subtractive signal consumption |
| Cleaning robot | visible debris/corpses, pod location | debris removal, component entities |

No scout reads any row owned by the marrow.

---

## 3. State machines

## 3.1 Scout state machine

```text
PATROL / INFILTRATE
    -> COMBAT
    -> SEEK_CALL_SITE
    -> BRACE
    -> TRANSMIT
    -> POUR_ASSUMED
    -> GARRISON_DESCENT
    -> SEEK_LEADER
    -> RAID_ASCENT
    -> SEEK_CALL_SITE
```

### PATROL / INFILTRATE

At 5 Hz:

- Sample current and adjacent chambers.
- Prefer lower Patrol, Trail, Danger, and Kin.
- Vagrant biases toward broader chambers.
- Lacuna biases toward portal boundaries and may enter PROBE as a substates.

Enter COMBAT on ordinary target acquisition.

Enter SEEK_CALL_SITE if all are true:

- No active reinforcement portal is visible in the chamber.
- No local Adversary ally is visibly bracing or transmitting.
- The scout is the weakest Adversary class in the chamber.
- If tied, lowest stable entity ID wins locally.
- It has evidence of hostile presence through sight, recent memory, Trail, or Noise.

### COMBAT

Use normal class combat behavior.

Reevaluate call eligibility every 0.2 seconds. Stronger Adversaries keep fighting when a weaker caller is present.

### SEEK_CALL_SITE

Move one chamber at a time down hot fields:

```text
prefer lower Danger
prefer lower Noise
prefer lower Trail
prefer lower Kin
```

A chamber is safe enough when:

```text
Danger <= 0.30
Noise  <= 0.20
Trail  <= 0.25
no hostile visible
valid breach wall site exists
```

The scout stops at the first chamber meeting these constraints. This implements “as close as safe” without a global search.

For RAID_ASCENT, invert the Danger preference but never enter:

```text
Danger > 0.65
```

Stop at a local peak at or below 0.55.

### BRACE

Attempt to acquire the single world call-medium lease.

The API returns only success or failure. It reveals nothing about the hub.

On success:

- Become stationary.
- Begin class-specific visual deployment.
- Duration 1.5 seconds.

On damage, displacement, loss of footing, or death:

- Release the lease.
- Return to SEEK_CALL_SITE.

### TRANSMIT

Stationary and fully exposed.

- Vagrant: 6 seconds.
- Lacuna: 8 seconds.
- Emit one audio/visual pulse per second.
- Does not attack or move.
- On completion, create one Call Imprint and release the lease.

On interruption, create no imprint and return to SEEK_CALL_SITE.

### POUR_ASSUMED

This is intentionally based only on the scout’s own completed broadcast.

- Duration: 8 seconds.
- The scout does not check whether a breach opened.
- It moves away from Kin and resumes self-preservation.
- Increment `calls_completed`.

If this was the first completed call, transition to GARRISON_DESCENT. Otherwise continue the alternating garrison cycle.

### GARRISON_DESCENT

Descend Danger, Trail, and Kin. Seek a safe chamber.

The scout does not create a garrison object. It looks locally for a Warden and other combat agents.

### SEEK_LEADER

If a Warden is in the chamber:

- Stay nearby without commanding it.
- Emit ordinary Kin.
- Allow the normal follower settlement rule to operate.

If no Warden appears after 20 seconds, resume GARRISON_DESCENT.

When two followers settle in the chamber, transition to RAID_ASCENT. The scout learns this only by seeing settled posture or sensing Garrison Interior locally.

### RAID_ASCENT

Climb Danger toward the highest locally safe chamber, refusing values above 0.65. At the safe peak, enter SEEK_CALL_SITE using the raid thresholds, then broadcast and return to GARRISON_DESCENT.

## 3.2 Garrison follower state

```text
MOBILE
    -> SETTLE_ELIGIBLE
    -> SETTLED
    -> DEFENDING
    -> SETTLED
```

### SETTLE_ELIGIBLE

Conditions:

- Warden in same chamber.
- No visible hostile.
- Noise < 0.20.
- Danger < 0.35.

Accumulate 12 seconds of continuous eligibility. Any failed condition resets the timer.

### SETTLED

- Do not answer external Muster.
- Remain in the chamber.
- Emit Garrison Interior, Reach, and Kin.
- Patrol locally.
- Fight normally if a hostile enters.

The Warden has no corresponding state.

## 3.3 Reserve and dispatch state machine

```text
READY
    -> LOW
    -> EXHAUSTED
    -> READY

any live state
    -> BLACKOUT on CORE kill
    -> RECONSTITUTING at reserve > 0
    -> READY
```

### READY / LOW

Regenerate using the deficit governor and delayed production factor.

Thresholds:

```text
LOW when reserve < 30
READY when reserve >= 30
```

These labels are for telemetry and internal animation only; they do not branch core logic.

On Call Imprint sample:

1. Consume the imprint.
2. Reject if reserve cannot pay the cheapest possible dispatch and no guardian is eligible.
3. Reject if two ordinary breaches are already active.
4. Resolve the nearest validated site.
5. Begin a three-second breach formation.

### EXHAUSTED

Entered when:

- No eligible live guardian remains for dispatch, and
- Reserve balance < 1.

Effects:

- No new breach formation.
- No new dispatch.
- Request ten-second exhaustion closure on every active breach.
- Continue regeneration.

When reserve reaches at least one, return to READY, but do not reopen anything without a new call.

### BLACKOUT

On all Source Knots destroyed:

```text
reserve = -42
production_factor = 0
```

- No new portal.
- No dispatch.
- Existing breaches receive exhaustion closure.
- Reserve rises at 0.35 units/s from home resupply.

### RECONSTITUTING

At reserve crossing above zero:

- Spawn minimal CORE chain.
- Resume normal production-factor calculation.
- Return to READY.
- Remaining organ parts rebuild through their ordinary rules.

## 3.4 Dispatch selection

On every dispatch opportunity:

1. Gather active breaches.
2. Select the one with the lowest successful assignment count; break ties round-robin.
3. Prefer an undispatched guardian-ring agent.
4. Otherwise sample the class mix.
5. If the sampled class is unaffordable, resample among affordable classes.
6. Instantiate the agent in an eligible hub production alcove.
7. Give it a normal navigation goal through the selected portal toward the transmitted target position.
8. Deduct reserve when the agent is instantiated.
9. Do not move or teleport it specially after creation.

A route must exist before reserve is spent. The agent then uses normal AI and physics.

## 3.5 CORE production state

Target production factor:

```text
source_factor = live_sources / 3

bud_factor =
    0.25 + 0.75 * (live_attached_buds / 12)

target_production_factor =
    source_factor * bud_factor
```

Changes take effect after a 20-second fixed pipeline delay.

Implementation can store timestamped factor changes in a deque rather than a 200-slot per-tick array.

A surviving Source may rebuild another Source after 60 seconds. The timer resets if the rebuilding Source is damaged. Once no Sources survive, only home resupply can restart the organ.

---

## 4. Consolidated first-pass constants

## Simulation

| Constant | Value |
|---|---:|
| Signal update | 10 Hz |
| Agent senses/state update | 5 Hz |
| Marrow call sampling | 2 Hz |
| Direct-breach scan | 2 Hz |
| Call imprint lifetime | 15 s |
| Call lease timeout | 10 s |
| Max ordinary breaches | 2 |
| Max including direct flank | 3 |

## Breach

| Constant | Value |
|---|---:|
| Formation time | 3 s |
| Uncrossed closure | 45 s |
| Exhaustion grace | 10 s |
| No-route-interest closure | 12 s |
| Opening route-interest grace | 8 s |
| Width | `max(96, 2*max_radius+16)` |
| Scale | nonexistent; rigid transform only |

## Reserve

| Constant | Value |
|---|---:|
| Capacity | 120 |
| Base regeneration | 0.10/s |
| Deficit gain K | 2.5 |
| Empty regeneration | 0.35/s |
| Core-kill balance | −42 |
| Expected blackout | 120 s |
| Production delay | 20 s |
| Base dispatch interval | 2.20 s |
| Ring replenishment interval | 10 s |

## Scouts

| Constant | Vagrant | Lacuna |
|---|---:|---:|
| HP | 84 | 42 |
| Speed | 1.45× | 1.20× |
| Mass | 1.6× | 1.4× |
| Turn rate | 0.55× | 0.50× |
| Contact damage | 18 | 10 |
| Recovery | 1.1 s | 1.3 s |
| Brace | 1.5 s | 1.5 s |
| Broadcast | 6 s | 8 s |
| Release | 0.5 s | 0.5 s |
| Probe | — | 3 s |

Broadcast sound:

```text
maximum propagation = 2 portal hops
per-hop volume multiplier = 0.55
pulse interval = 1 s
```

## Garrison

| Constant | Value |
|---|---:|
| Settlement dwell | 12 s |
| Warden-search wait | 20 s |
| Minimum settled followers | 2 |
| Settlement Noise ceiling | 0.20 |
| Settlement Danger ceiling | 0.35 |
| Raid refusal Danger | 0.65 |
| Raid stop target | ≤0.55 |

## CORE

| Part | Count | HP | Rebuild |
|---|---:|---:|---:|
| Source Knot | 3 | 168 | 60 s while another survives |
| Anchor | 4 | 84 | 30 s |
| Producer Bud | 12 | 42 | 12 s |
| Caretaker | 4 | 42 | 25 s |
| Dispatch Collar | 2 | 126 | 45 s |

Additional:

```text
CORE defense delay = 6 s
CORE defense cooldown = 20 s
buds detached per response = 2
Source passive regen delay = 12 s
Source passive regen = 1 hp/s
Caretaker heal = 8 hp/s
```

## Scrubber and robot

| Constant | Value |
|---|---:|
| Scrubber cost | 6 components |
| Unpack | 30 s |
| Capacity | 1.2 signal-units/s |
| Own-chamber weight | 1.0 |
| Adjacent-chamber weight | 0.5 |
| Robot speed | 0.8× Commando |
| Corpse process time | 5 s |
| Component chance | 25% |
| Component yield | 2 |
| Robot carry capacity | 1 corpse |

## First constants expected to be wrong

Measure these first, in this order:

1. Dispatch interval: 2.20 seconds.
2. Reserve cap: 120.
3. Arrest threshold: 2.5–4.0.
4. Broadcast exposure: 8/10 seconds.
5. Scrubber capacity: 1.2/s.
6. Settlement dwell: 12 seconds.
7. Blackout depth: 42, because usable travel time may invalidate the nominal 120 seconds.

---

## 5. Update loop

## 5.1 Per simulation tick

### 1. Advance clocks and materialize lazy decay

For any chamber touched this tick:

```text
value *= 2 ** (-delta_time / half_life)
last_decay_tick = current_tick
```

Do this before accepting new emissions or reads.

### 2. Physics and ordinary portal traversal

- Integrate movement and impulses.
- Resolve collisions.
- Move projectiles.
- Process generic portal crossings.
- Emit `PortalCrossed` events.

No breach-specific body handling occurs here.

### 3. Resolve damage and deaths

- Apply damage.
- Apply universal mass-scaled knockback through physics.
- Emit Distress, Danger, Noise, and Muster contributions.
- Schedule CORE delayed-defense records where applicable.
- Release call leases held by killed scouts.

### 4. Propagate signal fields at 10 Hz

Using a previous-buffer/next-buffer pass:

- Apply pending emissions.
- Diffuse across portal edges.
- Apply special Garrison Interior front logic.
- Clamp by per-signal caps.

Cost:

```text
O(signal_count * (chambers + portals))
```

at 10 Hz.

### 5. Apply scrubbers

- Gather covered chambers.
- Spend each scrubber’s shared subtraction budget.
- Remove values proportionally across channels and weighted chambers.

This happens after emission and propagation but before agent sensing, so saturation is visible immediately.

### 6. Rebuild the sense snapshot at 5 Hz

Update chamber spatial indices and portal-visible sets.

Agent queries cost approximately:

```text
O(local entities + adjacent visible entities)
```

not world population.

### 7. Update active agents at 5 Hz

For each active agent:

- Sample own and adjacent signals.
- Query the find API.
- Update quorum, stand-down, arrest, combat, scout, and garrison state.
- Produce steering and action intents.

Flocking uses a chamber-local spatial hash, not pairwise all-agent scans.

### 8. Update the call medium

- Expire dead or timed-out leases.
- Advance braces and broadcasts.
- Create completed Call Imprints.
- Emit simulation events for rendering, audio, and telemetry separately.

Audio and telemetry are independent subscribers. Logging never calls audio and audio never owns instrumentation.

### 9. Update marrow and direct-breach controller

- Consume sampled Call Imprints.
- Evaluate direct-flank thresholds.
- Advance reserve regeneration.
- Apply delayed production-factor changes.
- Start valid breach formations.
- Assign dispatch opportunities evenly.

Cost:

```text
O(active breaches + hub staging agents + newly sampled calls)
```

### 10. Update CORE jobs

- Advance scheduled defense responses.
- Advance Source, Anchor, Bud, Caretaker, and Collar reconstruction.
- Apply caretaker healing.
- Process CORE kill and reconstitution transitions.

Only scalar timers advance when the hub is inactive.

When a live breach connects the hub to an active world chamber, the hub becomes graph-adjacent and its agents enter the ordinary active simulation. This is not general far-simulation.

### 11. Update breach lifecycle

For each breach:

- Apply crossing timestamps.
- Apply exhaustion-close requests.
- Read generic route-interest count.
- Close if any condition is met.
- Remove the portal through the normal portal-system mutation path.

Cost is O(number of breaches), capped at three in this draft.

### 12. Update buildings and cleaning robots

- Advance unpacking.
- Find debris locally.
- Path robots physically.
- Process corpses.
- Emit component entities.

### 13. Publish immutable frame events

Rendering, audio, and telemetry consume the same simulation facts independently. The renderer remains Pygame-free.

---

## 6. Expected failure modes and cheapest instruments

| Failure mode | Cheapest discriminating instrument |
|---|---|
| Portal scale mismatch returns | Assert the portal transform type has no scale member; log body radius, entry speed, crossing completion, and time inside aperture |
| Agents still logjam | Histogram time from first aperture contact to completed crossing by class; compare with ordinary wide portals |
| Reinforcements never reach the player | One causal trace: call started → call completed → imprint consumed → breach active → agent created → agent crossed → agent acquired hostile |
| Calls appear despite no valid scout behavior | Per-call record of caller state, chamber ranks, visible tasked allies, and lease owner |
| Scouts accidentally read hub state | Dependency test forbidding scout modules from importing marrow/core/breach modules; runtime interface objects expose no such fields |
| Weakest-in-room selection fails | Log all local Adversary ranks whenever BRACE starts; flag a stronger caller while a weaker eligible unit is present |
| Global call lease starves callers | Lease wait-time histogram and percentage of safe scouts blocked for over ten seconds |
| Reserve never exhausts | Trace reserve, regeneration, dispatch spending, guardians dispatched, and time-to-zero |
| Reserve exhausts incidentally | Count exhaustion events with less than 60 seconds of sustained dispatch |
| Blackout is not actually economic | Log core-kill tick, reserve trace, first nonnegative tick, first accepted post-blackout call |
| Blackout mostly expires during travel | Record core-kill-to-frontline-return time and remaining usable blackout |
| Multiple breaches are not even | Per-breach successful dispatch count; flag difference greater than one while both were valid |
| Fixed breach sites become solved killboxes | Compare player damage, ammunition, and structure loss by site ID over repeated openings |
| Reinforcements remain a conga line | Portal-choice entropy, doorway occupancy, and agent-to-player distance distribution |
| Arrest makes agents look broken | Log CORDON reason, target visibility, local Muster exposure, speed, and held portal |
| Arrest never matters | Fraction of reinforcements entering CORDON before contact; target provisional range 25–60% |
| Arrest produces a passive perimeter the player ignores | Time in CORDON without denying a player crossing or firing; high values mean hold-site choice is wrong |
| Guardian ring does not weaken after dispatch | Ring occupancy before call, after burst, and when player enters; correlate with dispatched count |
| CORE becomes a scripted boss anyway | Record target order across human runs; if nearly all runs require the same order because alternatives fail, simplify |
| CORE can be chipped across deaths | Record part HP at player death and at hub re-entry; expected recovery toward full without a foothold |
| CORE heals too quickly to attack | Damage dealt versus repaired during uninterrupted player presence |
| Garrison system never appears | Count settlement eligibility starts, resets by reason, completions, and Warden chamber dwell |
| Garrison appears in active combat | Flag any settlement completed with Noise or Danger above thresholds |
| Leader accidentally commands followers | Assert Warden state has no follower count, garrison target, or settlement writes |
| Lacuna probe is irrelevant | Compare route choice, survival, and completed calls with/without a successful probe in ordinary runs—not a feature-flag A/B in production |
| Lacuna violates containment | Flag any call position whose caller body never entered that chamber |
| Scrubber is a mandatory tax | Compare discovery time for quiet unscreened, hot unscreened, and hot screened pods |
| Scrubber becomes a turtle button | Log raw emissions, capacity consumed, leakage, visible enemy contacts, and global call rate |
| Stacked scrubbers erase a major battle | Track total capacity versus total emissions and count calls/contacts through heavily stacked coverage |
| Cleaning becomes an economy exploit | Components gained per corpse, per ammo spent, and per minute at a defended breach |
| Breaches remain open forever | Log age, last crossing, route interest, exhaustion request, and final close reason |
| Breaches close while agents are approaching | On close, count hub-side agents whose current ordinary route included the portal |
| Direct flank breach triggers in normal aggressive play | Track peak Distress and sustained duration in full runs; threshold should be untouched in nearly all aggressive clears |
| Offscreen inactivity masquerades as containment | Record wall-clock time versus active-simulation time for every scout and settlement timer |
| Transmission tell is not learned | Human telemetry: distance/hops at first orientation toward a broadcaster, interruption attempts, and recognition after repeated encounters |

## Verification sequence

1. **Portal vector:** every existing enemy class walks through a breach in both directions without combat or special entry code.
2. **Call vector:** one scout, two safe chambers, one valid site, reserve full.
3. **Dry call vector:** reserve below one; completed call produces no portal.
4. **Two-breach vector:** verify assignment counts remain even.
5. **Reserve vector:** uninterrupted one-breach dispatch to exhaustion and economic recovery.
6. **CORE vector:** separate collar-only, anchor-only, caretaker-only, and Source-only attacks.
7. **Garrison vector:** stationary oblivious Warden plus eligible followers; then repeat with the Warden removed at 11 seconds.
8. **Scrubber vector:** low emissions followed by an emission burst exceeding capacity.
9. **Actual Gauntlet run:** full run, every fifth frame reviewed, with the causal reinforcement trace and human instrumentation enabled.

The isolated vectors establish mechanism. The Gauntlet run establishes whether any of it matters in the actual game.