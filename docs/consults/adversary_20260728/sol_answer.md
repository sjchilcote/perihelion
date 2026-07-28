# Proposed canonical roster

**Ship exactly two Adversary classes and eight Testator classes.**

```text
ADVERSARY: vagrant, lacuna
TESTATOR:   mite, husk, spitter, brute, warden, shrieker, flicker, sexton
CORE:       organ parts, not enemy classes
```

- `vagrant` remains the identifier and becomes the **frontier caller**.
- `lacuna` remains the identifier and becomes the **boundary caller**.
- Add one Testator class, `sexton`, for corpse, evidence, and chassis recovery.
- Do **not** add Warrant, Herald, Executioner, Damper, Reanimator, Anchor, Chaff, or a kin-check class.
- Do **not** add a tenth coordination field.

## Bayesian compression

Live hypotheses:

| Hypothesis | Prior |
|---|---:|
| One general caller | 20% |
| **Two differentiated callers only** | **45%** |
| Two callers plus several Adversary specialists | 35% |

Evidence 1: the ratified design names two Adversary classes and requires **every Adversary class to call**.

- `P(E|one) ≈ .55`
- `P(E|two) ≈ .90`
- `P(E|many) ≈ .25`

Posterior after E1: approximately **18% / 67% / 15%**.

Evidence 2: at 0.45 zoom, Warrant and Damper have the same read, Herald duplicates quorum, and Executioner duplicates high-tier Testator pressure while requiring another readable silhouette.

- `P(E|one) ≈ .25`
- `P(E|two) ≈ .80`
- `P(E|many) ≈ .30`

Posterior: approximately **7% / 86% / 7%**. I haircut that to **80% confidence** for unmodelled playtest failure.

**Strongest reason this may be wrong:** two evasive strategic units may still read as “the same caller twice,” or may make the actual invaders feel less immediately dangerous than their disposable equipment.

---

# 1. The Adversary roster

## Common law for both classes

Both retain the complete ratified caller loop:

1. **Infiltrate** using only own-chamber and one-hop fields.
2. Verify through the senses API that:
   - no active breach occupies the room;
   - no ally in the room is already tasked;
   - it is the weakest Adversary class present.
3. **Brace → rooted broadcast → release.**
4. Leave the existing 15-second call imprint.
5. Observe the room for three seconds through ordinary senses only.
6. Resume expansion whether or not anything came.
7. Alternate:
   - descend Trail, Danger, and Kin toward quiet ground for a garrison delivery;
   - climb toward a Danger peak without entering `Danger ≥ 0.35` for a raid call.

The caller receives **no acknowledgement** and never reads reserve, marrow state, dispatch composition, or breach ownership. If the call is dry, it is simply dry.

`lacuna` remains the weaker class. If both are present, Lacuna calls and Vagrant keeps acting. If the world call-medium lease is occupied elsewhere, neither waits in place: both continue their class-specific movement and re-evaluate later.

Transmission rings are removed. **Rings mean aggro and nothing else.** Broadcasts use body posture, moving silhouette, and ordinary two-hop audio.

## Stat rows

| Class | HP | Radius | Mass | Accel | Friction | Turn | Touch | Broadcast |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **Vagrant** | 84 | 9.5 | 1.5 | 701 | 3.4 | 3.5 | 6 / 50 ticks | 6 s rooted, 8 s total |
| **Lacuna** | 42 | 8.5 | 1.4 | 653 | 3.8 | 3.2 | 4 / 50 ticks | 8 s rooted, 10 s total |

These preserve the ratified weapon arithmetic:

- Vagrant: one charged Tau or two rail shots.
- Lacuna: one rail shot.
- Both remain faster, heavier, and worse-turning than the unmodified Commando.

## Vagrant — frontier caller

### The query it alone answers

> **Where is the last safe chamber from which a call can still alter the fight already happening?**

### Local sampling and action

Vagrant samples:

- Noise, Distress, Muster, Danger, Trail, and Kin in its own chamber and one hop;
- raycast-confirmed hostiles and visible allies;
- active portals through `PortalSense`.

It takes long, committed legs through broad chamber interiors. It climbs Noise and Distress but refuses the next chamber at `Danger ≥ 0.35`, transmitting from the last safe chamber. “Frontier” therefore means the safe edge of a live fight, not the front line itself.

When another caller owns the lease:

- if the player is visible, Vagrant makes wide, poor-turning contact passes through the Testator screen;
- otherwise it continues toward another safe edge;
- it never queues motionless behind the transmitter.

After a visible pour, it stays one chamber behind the first Testator bodies, using them as cover, then begins the required quiet-ground expansion leg. It does not know those bodies answered its call; it merely sees allies moving through a portal.

### Tell

- Gross silhouette: a tall, split, forward-canted fork.
- Internal edges and outline never settle; the envelope is recognizable but its construction continually contradicts itself.
- During broadcast, the two tines ratchet together once per second for six beats.
- Audio: six hard, widely spaced metal-on-stone knocks.
- No ring, icon, text, or field overlay.

### Death and counterplay

A completed withdrawal preserves it. HP reaching zero or failed withdrawal permanently removes the identity from the census.

The player learns to:

- turn around immediately when hearing the six-beat call;
- use one charged Tau during the rooted window;
- exploit its broad, committed route by fighting backward across its approach;
- deny its eventual retreat rather than merely driving it off.

**Film prediction:** Vagrant calls cluster near the safe edge of active Noise/Distress, cross chamber centres, and produce six unmistakable body beats.

**Forbids:** wall-hugging portal probes; calling from inside `Danger ≥ 0.35`; waiting motionless for the lease; reacting differently because the marrow is empty.

**Odds:** **3:1 (75%)**.  
**Strongest risk:** its safe-edge placement may be so safe that interruption becomes uncommon, defeating the caller-vulnerability rule.

---

## Lacuna — boundary caller

### The query it alone answers

> **Where has the intruder crossed a boundary but failed to hold the quiet ground behind it?**

### Local sampling and action

Lacuna samples:

- Trail, Noise, Danger, Kin, Patrol, Garrison Interior, and Garrison Reach in its own chamber and one hop;
- visible portal mouths and their immediate geometry;
- raycast-confirmed hostiles.

For its quiet leg, first-pass eligible ground is:

```text
Danger < 0.20
Noise  < 0.10
Trail  < 0.15
no strong Garrison Interior
```

Among eligible neighbours it descends Kin and Trail, preferring high-Patrol, low-Danger routes. It hugs walls and portal mouths.

It may root for three seconds to probe the chamber immediately through a portal. The probe is a visibly active wall-contact animation, not an idle freeze, and provides no information deeper than that one chamber. It may still call only into the chamber physically containing its body.

When the call-medium lease is occupied, Lacuna keeps moving or probing. It does not wait.

After a visible pour, it leaves in the direction of falling Noise and Kin, seeking the next unheld seam. Its required raid leg subsequently climbs Danger but stops before the `0.35` hold line.

### Tell

- Gross silhouette: a low, open crescent with a moving absence through its centre.
- During broadcast, three hooks visibly bite the wall or floor while the central absence opens and closes eight times.
- Audio: eight slower rasping pulses.
- Probe posture has one wall contact and no pulse or broadcast sound; it cannot be mistaken for a call.

### Death and counterplay

The player learns to:

- hold portal crossings rather than hunt every quiet room;
- watch his own rear boundary after moving forward;
- recognize that a probe does not call through the wall;
- use one rail shot during the longer broadcast;
- prevent the retreat after interrupting the call.

**Film prediction:** Lacuna travels along chamber boundaries, probes portals without crossing, and calls in low-Trail ground behind the player’s route.

**Forbids:** calls appearing in the probed chamber; centreline movement statistically indistinguishable from Vagrant; waiting for the lease; entering a high-Danger room to find a better site.

**Odds:** **2:1 (67%)**.  
**Strongest risk:** an off-screen rear call may feel arbitrary unless cordons, the wall-hugging silhouette, and the eight-beat audio are all plainly readable.

---

## Why there are no other Adversary classes

- **Warrant:** the caller’s transmitted location is already the Adversary judgement. A second authorisation field adds a class and a scalar without a new player decision.
- **Herald:** duplicates the existing quorum virtual-supporter term.
- **Executioner:** duplicates Warden’s high-tier pressure and risks becoming a second engulf attack. It would also still need call behaviour under the ratified constitution.
- **Damper:** overlaps stand-down and gives the same low-resolution silhouette as an unarmed caller holding short of danger.
- **Kin-check:** there is no final, carryable Adversary salvage object in this roster. Adding a detector before adding a clear player action would be hidden omniscience.
- **Reanimator:** no field resurrection. Any authored reanimated body uses Husk behaviour and can only originate through the CORE.
- **Dynamic Anchor/Local Unfolding:** rejected below.

**Film prediction for the cut:** only two doubled-boiling gross silhouettes ever appear, and both can be recognized as callers.

**Forbids:** a third precious specialist, a transmission ring, a hidden authorisation scalar, or a caller that cannot call.

**Odds:** **4:1 (80%)**.  
**Strongest risk:** the actual Adversary may lack a sufficiently direct combat presence.

---

# 2. Withdrawal rule

## Environmental input: no tenth signal field

Use the existing authored **Otherworldness** value that already drives the corruption gradient and breathing treatment.

- `O = 0`: ordinary station.
- `O = 1`: marrow/home ground.
- Intermediate authored values are permitted in existing corrupted spaces.
- It does not diffuse, decay, recruit, or carry coordination meaning.
- Agents sample their own chamber and compare one-hop neighbours only through the senses API.

There is no runtime Local Unfolding field and no enemy-built Anchor. Garrisons consist of Testators and do not make ordinary ground permanently safe for personnel.

Bayesian decision:

- Prior odds for “no new field” versus “add Local Unfolding”: `3:2`.
- Engine evidence—authored gradient already exists, live soften/unsoften does not, and dynamic cache composition is unresolved—has approximately `P(E|no field)=.85`, `P(E|new field)=.35`.
- LR ≈ 2.4; posterior ≈ **3.6:1, or 78%**, for no new field.

**Strongest risk:** authored Otherworldness may provide too few useful refuges outside the hub.

## What accumulates

Every manifested Adversary carries **dwell debt** `E`, initially zero and clamped to `[0, 90]`.

```text
C = 1 while broadcasting,
    or while a hostile is raycast-confirmed,
    or for 3 seconds after taking a hit;
    otherwise 0.

dE/dt = (1 - O) * (1 + 0.5 * C) - 3 * O
```

Consequences:

| Condition | Debt rate |
|---|---:|
| Quiet in ordinary space | +1.0/s |
| Fighting or broadcasting in ordinary space | +1.5/s |
| Full Otherworldness | −3.0/s |
| Quiet at O = 0.25 | neutral |

First-pass thresholds:

- `E = 60`: mandatory withdrawal.
- `E = 90`: six-second overdrawn window.
- Successful return at `O = 1` clears a full 90 debt in 30 seconds without a separate recovery timer.

A caller does not begin bracing unless its current debt runway can cover its complete eight- or ten-second transmission. If conditions worsen and debt reaches 60 anyway, withdrawal interrupts the broadcast and releases the lease without an imprint.

The exact numbers have lower confidence than the structure:

- **Structure odds:** **3:2 (60%)**.
- **Exact 60/90/6 tuning odds:** **1:2 (33%)**.
- **Strongest risk:** the useful encounter duration may be much shorter or longer than the assumed 40–90 seconds.

## What the player sees

The doubled boiling outline always means **Adversary lane** and never changes meaning.

Dwell debt uses a separate body-anchored cold seam:

- `E = 0–30`: full, continuous seam.
- `E = 30–60`: seam visibly shortens.
- `E = 60–90`: only the rear third remains while the body retreats.
- Overdrawn: one steady point remains; acceleration and turn are visibly degraded.

It never flashes, blinks, or becomes intermittent, avoiding collision with hit flashes, Warden charge, and Flicker’s trace.

## Withdrawal behaviour

At `E = 60`:

1. Calling and ordinary recruitment cease.
2. The body writes one standard local **Muster** beat, buying its exit with nearby Testators.
3. It stops answering Muster, Distress, and combat targets.
4. It begins withdrawal.

### Local routing

Each Adversary keeps a bounded private stack of at most 24 portal crossings.

- Crossing forward pushes `(chamber, doorway)`.
- Immediately crossing back pops rather than adding a loop.
- Seeing a live breach or authored refuge in its own chamber establishes a home checkpoint.
- A newly traversed breach supplies the first stack entry.
- No shared trail field is read for retreat routing.

Withdrawal priority:

1. A live breach visible in the current or adjacent chamber.
2. Reverse the exact private stack toward the last personally observed live breach or refuge.
3. If the stack is empty, climb one-hop Otherworldness.
4. If none applies, enter **Last Ground**.

It never queries “nearest breach” globally. It may die close to a breach it never personally observed.

### Sealed route

If the stored doorway or final breach no longer exists, the body does not search the map for another one. It enters Last Ground at that seam:

- it circles and attacks at full aggression;
- it never becomes a statue;
- debt continues accumulating.

### Overdrawn

At `E = 90`:

- a six-second terminal window begins;
- acceleration and turn are reduced by 35%;
- it continues its retreat or Last Ground attack;
- reaching a live breach still succeeds;
- otherwise it ruptures at the end of six seconds.

### Contested breach

When several personnel can see the same mouth, the body with the shorter visible dwell seam crosses first. Others orbit one body-length back and continue spending debt. There is no hidden queue number.

### Successful withdrawal

Crossing the portal line causes a 0.6-second inward fold on the hub side:

- no corpse;
- no death sound;
- no Distress or Danger write;
- no census decrement.

The same roster identity enters `recovering`. Once its debt returns to zero, it becomes available in the hub and may later walk through a live breach under ordinary local AI. The CORE never creates or substitutes it.

### Failed withdrawal or combat death

HP reaching zero or the overdrawn window expiring causes:

- a loud geometric rupture;
- a collapsed negative carcass;
- the ordinary Distress death write;
- a saturating `+1.0` Danger deposit instead of a Testator’s ordinary `+0.4`;
- permanent removal of that identity.

Both use the existing 180-second Danger half-life. No new decay rule is introduced.

## No far simulation requirement

Outside the active simulation window:

- dwell debt and hub recovery use timestamp arithmetic;
- no steering, crossing, combat, or death is resolved;
- a manifested body resumes in the debt state implied by elapsed time when activated;
- census loss is never silently resolved off-camera.

Dormant Adversaries are authored in nonzero-Otherworldness ground or remain folded out of ordinary space until waking; they do not require active remote locomotion.

## Why withdrawal is a threat rather than an anticlimax

Letting one escape means the same finite caller can return. Pursuing it means:

- following a predictable reverse route;
- fighting through the disposable Muster screen it purchased;
- using knockback to keep it off the mouth;
- deciding whether to hold the route or continue the main fight;
- converting a temporary tactical win into a permanent strategic loss.

The enemy does not run because its HP became low. It runs on a visible clock that the player can accelerate by maintaining sight, landing repeated hits, forcing repeated broadcasts, and delaying it with knockback.

**Film prediction:** in zero-O ground, an idle body begins retreat near 60 seconds and a continuously engaged body near 40 seconds; an open gate produces a silent fold, while a sealed route produces Last Ground and a loud death.

**Forbids:** HP-triggered retreat; global homing; census decrement on a quiet return; disappearing without a visible gate; a body freezing when its path fails.

**Odds:** **3:2 (60%)**.  
**Strongest risk:** the fixed breach mouth may make withdrawal denial trivially easy, turning precious personnel into predictable gate-camping rewards.

---

# 3. The two-lane relationship

## How personnel spend Testators

Adversaries do not issue orders or keep follower references.

They use existing Muster:

- Every broadcast beat writes the same ordinary Muster amount as a committed fighter.
- At withdrawal threshold, the personnel body leaves one additional standard Muster beat in the chamber it is abandoning.
- Testators already committed to the fight climb Muster and flock normally.
- The withdrawing Adversary no longer answers the field, so the Testators move toward the pursuer while the personnel body moves away.

A completed call also spends reserve indirectly, but the caller never knows what the marrow paid or whether it paid anything.

This makes the relationship visible:

1. The Adversary stands behind the danger line.
2. Testators cross it, surround it, and die.
3. The Adversary uses their bodies as moving cover.
4. When its own clock runs low, it leaves them behind.

## How personnel protect themselves

- They refuse high-Danger rooms.
- Vagrant uses Testator groups as moving screens.
- Lacuna avoids Trail, Noise, and dense Kin.
- Both abandon combat recruitment when withdrawing.
- Sextons prioritize fallen Adversary remains above ordinary Testator wrecks.
- The same Testator loss is locally ordinary; an Adversary loss leaves the stronger TOLL Danger deposit.

## What changes when no Adversary is present

Without personnel in a sector, Testators still:

- see and fire;
- relay Distress and Muster;
- hunt gradients;
- mark, flock, hold thresholds, flank, and attack structures;
- maintain an existing Warden garrison.

They do **not**:

- place a normal called breach;
- deliberately find quiet rear ground for a new garrison delivery;
- generate a personnel withdrawal screen.

Killing a caller after its broadcast does not close the breach or stop the current Testator response. It only removes future calls by that identity.

**Film prediction:** killing a transmitting caller interrupts that call, but every already-committed Testator continues fighting; during a later retreat, Testators converge on the caller’s former chamber while the caller retraces away.

**Forbids:** Testators shutting off when personnel die; a caller directly assigning escorts; Testators knowing the caller’s dwell value; a personnel death ending an open breach.

**Odds:** **3:2 (60%)**.  
**Strongest risk:** Muster may make the rooted transmitter too well screened, erasing the intended vulnerability or clogging the breach mouth.

---

# 4. Role split

## Complete role ruling

| Packet role | Lane ruling and final owner |
|---|---|
| 1. Standing pickets | **Testator — Husk.** Some authored Husks use the existing posted-doorway tether. |
| 2. Alarm amplification | **Testator — all combat bodies.** Contact relays ordinary Distress + Muster. |
| 3. Gradient hunters | **Testator — Husk, Spitter, Brute, Warden.** |
| 4. Marking | **Testator — Shrieker.** Existing mark and follow-me trail. |
| 5. Warrant/authorisation | **Adversary — both callers.** The call imprint is the judgement; no Warrant class or field. |
| 6. Licensed execution | **No separate role.** Warden remains the normal high-tier enemy; Shrieker mark already coordinates focus. |
| 7. Kin-check enforcement | **Adversary in principle, cut from this roster.** No clear player carry action exists to justify it. |
| 8. Area denial | **Testator — live Spitter fire and body pressure only.** No persistent mat substrate yet. |
| 9. Cordon-seal | **Cut.** No impassable or automatic doorway seal. |
| 10. Suppression/resolution | **Shared substrate.** Existing stand-down plus signal half-lives; no Damper. |
| 11. Recruitment/dispatch | **Marrow.** Unchanged closed-loop economy. |
| 12. Breach opening | **Adversary — Vagrant and Lacuna only.** |
| 13. Courier | **Testator — Sexton.** |
| 14. Repeat-intruder memory | **Sexton + Scriptorium ledger.** No Veteran statistic. |
| 15. Clean-up | **Testator — Sexton.** |
| 16. Environment shift | **Authored environment.** Existing Otherworldness and breathing walls; no tenth field or Anchor unit. |
| 17. Garrison | **Both lanes.** Callers choose delivery ground; Warden’s oblivious presence permits Testator settlement. |
| 18. Withdrawal discipline | **Adversary — both classes.** |
| 19. Residents | **Testator — existing hub and garrison stock.** No parallel local-production pathway. |
| 20. Dormancy | **State/placement, not a class.** Deep personnel and resident stock use higher wake thresholds. |
| 21. Traffic control | **Testator — Trail, threshold holds, raid fan.** Flicker strongly favours the second route. |
| 22. Anti-structure | **Testator — Spitter and Warden at range; Brute/Warden/contact bodies at contact.** No new specialist. |
| 23. Barrier/lifeline denial | **Testator — Mite and Shrieker.** They use the Portable Hole as an ordinary fitted portal. |

## Persistent snare and cordon rejection

Hypothesis: add Mite death mats now.

- Prior: `1:1`.
- Evidence: the ratified spec explicitly says to measure breach-mouth dominance before adding anything to the stream, and already prescribes geometry and multi-route pressure as the first repair.
- `P(E|add mats) ≈ .25`
- `P(E|do not add) ≈ .80`
- LR ≈ .31; posterior for mats ≈ **24%**.

Therefore Mites leave **no snare mat**, and no Cordon Web ships in this roster.

**Film prediction:** retreat remains governed by enemy bodies, knockback, route pressure, and flanking—not unexplained floor drag.

**Forbids:** side-selective slow fields, fused corpse barriers, or a doorway the player cannot cross.

**Odds:** **3:1 (75%)**.  
**Strongest risk:** fighting backward may remain too free, or fixed-mouth killboxes may remain dominant.

## Existing Testator assignments

| Kind | Final work | Film prediction | Forbidden observation | Odds / main risk |
|---|---|---|---|---|
| **Mite** | Cheapest Noise runner; Portable Hole pursuer | Shelling through a Hole draws Mites through it | Waiting at a fitted Hole or leaving a death mat | **4:1**; portal topology may not reach normal pathing |
| **Husk** | Posted picket, baseline hunter, garrison settler | A posted Husk returns to its crossing when the player withdraws | Pursuit several chambers beyond its post, or statue behaviour | **3:1**; may recreate the deleted doorway standoff |
| **Spitter** | Ranged pressure; first ranged anti-structure body | A visible sentry draws its fire even with the player nearby | Only ever targeting the player, or shooting through terrain | **3:1**; structures may become too fragile |
| **Brute** | Frontal breaker and contact demolition | It fights through knockback toward structures and formations | Global structure knowledge or ranged demolition | **4:1**; body collision may be enough without special AI |
| **Warden** | High-tier breaker, engulf, oblivious garrison anchor | Followers settle only while a Warden is physically present and the room is quiet | Warden selecting a base, counting followers, or commanding them | **4:1**; engulf may dominate every other read |
| **Shrieker** | Tail, mark, follow-me trail, Hole pursuit | It marks then stays at following distance while others converge | Calling a breach or refusing a fitted Hole | **3:1**; marking may be too visually subtle amid a horde |
| **Flicker** | Shadow ambush, second-route flank, rear structure pressure | It arrives from a different portal than the main push | Euclidean beelining or waiting at a route it cannot fit | **2:1**; flanks may still fail to emerge from one-hop decisions |
| **Sexton** | Chassis recovery, evidence courier, corpse clearance | It enters only after danger falls, lifts one visible load, and walks away | Calling, fighting while laden, or deleting cargo on death | **3:2**; long logistics paths may be unreadable or unfair |

All existing Testator classes remain. None is replaced.

## Sexton — the Testator courier

### Stat row

```python
"sexton": dict(
    hp=18,
    radius=8.0,
    mass=2.2,
    accel=680.0,
    fric=3.6,
    turn=3.8,
    touch_dmg=0,
    touch_cd=60,
    score=2,
)
dispatch_cost = 2
laden_accel_factor = 0.92
```

It remains about 1.3× Commando cruise speed unloaded and about 1.2× while laden.

One of the baseline screen positions in the deterministic 20-slot dispatch cycle becomes a Sexton position. It is not dispatched because cargo exists; the marrow remains blind. Replacement costs reserve normally.

### Local behaviour

A cargo candidate must:

- be in its own chamber or one hop;
- be at least 15 seconds old;
- have remained under `Danger < 0.35` and `Noise < 0.20` for five seconds.

Priority:

1. fallen Adversary remains;
2. the player’s wrecked chassis;
3. a Testator wreck carrying a damage-source record.

The Sexton carries exactly one object.

While laden it:

- stops answering Muster;
- refuses combat;
- follows its private reverse portal stack toward its breach and Scriptorium route;
- prefers rising Kin and falling Danger if the route is incomplete;
- patrols a short moving loop in quiet ground if no route exists.

It never stands indefinitely.

At the Scriptorium, a player chassis is placed in a visible rack rather than deleted. Killing a laden Sexton drops the exact cargo at its death position.

### Visual lane

The Sexton is unmistakably Testator:

- a one-off bier frame;
- unequal golden-angle clamps;
- bone and verdigris under corruption;
- a visible empty saddle when unloaded;
- the existing carried-load grammar when laden.

It never receives the Adversary doubled outline.

### Evidence ledger

The Scriptorium stores at most eight evidence records.

```text
record weight = 2 ** (-(age / 75 s))
W = sum(all current weights)
biased slots = min(6, round(W))
```

The biased slots are distributed among evidence categories by their fraction of `W` and replace no more than six positions in the ordinary 20-slot strike cycle.

- Turret evidence biases toward breakers.
- Rail/Tau evidence biases toward mobility.
- Close ballistic evidence biases toward ranged pressure.
- New evidence evicts the lowest current-weight record.
- Destroying the Scriptorium clears the ledger.
- Player death does not clear it.
- No physical delivery means no learning.

A switch in tactics therefore slips the old answer naturally:

- after 75 seconds, old weight halves;
- after 150 seconds, it quarters;
- capacity pressure can remove it sooner.

**Film prediction:** three fresh deliveries caused by one tactic bias roughly three of the next twenty positions; after 150 seconds without another such delivery, at most one remains. Killing the Sextons prevents the shift.

**Forbids:** live Distress or Muster changing composition; evidence registering before physical arrival; permanent Veteran statistics; player death resetting the ledger.

**Odds:** **1:1 (50%)**.  
**Strongest risk:** a three-to-six-slot composition change may still be too slow and statistical to teach without repeated controlled encounters.

## Structures, Portable Hole, blackout, and home ground

- Buildings receive real collision and durability as required by the ratified spec.
- Any enemy except Mite destroys a building on contact.
- Projectile enemies prioritize visible buildings through the senses API.
- Mites and Shriekers treat a Portable Hole as an ordinary portal if their radius fits and Noise, Trail, sight, or doorway traffic makes that route attractive.
- A large body that cannot fit takes its second-best route or continues its current attack; it never waits at the mouth.
- Reserve exhaustion does **not** change agents already on the map. No agent reads reserve. The tells remain stalls, dry calls, and breach closure.
- In the hub, authored `O = 1` prevents debt accumulation. Dense visible peers and Garrison Interior support ordinary quorum and threshold crossing; there is no `if hub` combat mode.
- CORE parts remain organ parts. Caretaker repair belongs to the organ system, not a ninth autonomous Testator class.

---

# 5. Finite personnel pool

## Ship count

**Thirty identities total:**

| Class | Active in station | Dormant in station | In marrow | Total |
|---|---:|---:|---:|---:|
| Vagrant | 3 | 6 | 3 | **12** |
| Lacuna | 5 | 9 | 4 | **18** |
| **Total** | **8** | **15** | **7** | **30** |

Dormant placement is by portal depth and quiet ground, not a random per-body flag. Dormant station personnel begin in authored nonzero-Otherworldness ground and wake only to direct contact or their high threshold.

### Why thirty

The plausible order of magnitude is tens:

- Fewer than roughly 15 makes extermination a normal clear strategy.
- More than roughly 50 makes individual permanent loss practically invisible.
- At a target of one denied withdrawal every 6–8 minutes, thirty identities represent roughly three to four hours of unusually successful hunting.
- Lacuna is more numerous because quiet boundary coverage is spatially expensive; active Noise can pull a smaller number of Vagrants toward a fight.

The **order-of-magnitude confidence is 3:1 (75%)**.  
The **exact count confidence is 2:3 (40%)**.

**Strongest reason the number may be wrong:** actual permanent-kill cadence and world chamber count are not yet measured.

## What loss changes

No living agent reads the census. There is no low-census enrage, retreat bonus, spawn substitution, or difficulty branch.

Loss changes behaviour only by removing physical workers:

- Vagrant losses make immediate safe-edge calls rarer.
- Lacuna losses make quiet rear reclamation and garrison deliveries rarer.
- Calls become more geographically sparse because remaining personnel must physically reach the sector.
- The marrow shows more vacant personnel spaces.
- A killed identity never returns through reserve regeneration.
- A successful withdrawal preserves the identity and can eventually return it.

Either class can still perform the common alternating expansion loop, so eliminating one class thins and biases the response rather than disabling all calls. Eliminating all thirty permanently disables **called** breaches. The extreme Distress direct connection remains available because it is explicitly spotterless.

The stronger TOLL Danger write makes each loss locally perceptible without exposing a number.

**Film prediction:** after personnel are permanently removed from a cordoned sector, ordinary Testators still react there but calls become sparse until another caller physically crosses the cordon. Later hub footage shows fewer doubled-outline bodies and vacant positions.

**Forbids:** the CORE producing a replacement; quiet withdrawal reducing the roster; an immediate global AI change at a census threshold; called breaches after all personnel are dead.

**Odds:** **2:1 (67%)** for the organic loss behaviour.  
**Strongest risk:** the single call-medium lease and reserve economy may already be the rate limit, making the first half of census attrition behaviorally invisible.

---

# 6. Landing order

Every stage first uses an isolated vector, then a complete run in canonical `gauntlet4.json`, reviewed every fifth frame. Human play receives the same instrumentation as bot play. Nothing lands behind a feature flag.

| Stage | Hardwired landing | Film gate | Forbidden result | Odds / main risk |
|---|---|---|---|---|
| **1. Two readable callers** | Final silhouettes, movement policies, lease contention, body/audio broadcasts; existing call economy retained | A blind reviewer labels Vagrant vs Lacuna before seeing the resulting breach and observes both moving while lease-blocked | Reviewer distinguishes them only by broadcast length or HP; any transmission ring | **3:1**; tiny silhouettes may erase the distinction |
| **2. Dwell and roster truth** | Existing O sample, debt arithmetic, guttering seam, private stack, Quiet Gate, Last Ground, roster return instead of decrement | One open-gate clip and one sealed-gate clip visibly produce silent survival versus loud permanent death; full run shows no off-camera census loss | Global homing, frozen failures, quiet return decrement, CORE replacement | **3:2**; gate camping may dominate |
| **3. Personnel spend equipment** | Broadcast Muster beats, withdrawal rearguard beat, post-pour behaviour, common garrison/raid alternation | A caller is screened without pointer-following; killing it does not stop existing Testators; an aggressive clean kill prevents the call | Caller becomes invulnerable behind a pile; Testators shut down on its death | **3:2**; Muster may overconcentrate |
| **4. Testator pressure contracts** | Real building durability/targets, Spitter priority, contact demolition, Mite/Shrieker Hole pathing, large-body alternate route, Warden settlement | Firebase footage shows structures threatened through ordinary LOS; Hole footage shows small pursuit and large rerouting | Indestructible sentry, player-only ranged targeting, large body frozen at Hole | **3:1**; bases may flip from dominant to disposable |
| **5. Sexton logistics** | New Testator body, cargo eligibility, LADEN mode, reverse route, spill, Scriptorium rack | A filmed death-site race shows pickup, visible carriage, interception, and exact cargo spill; another clip shows successful filing | Working an active firefight, deleting cargo, calling, or fighting while laden | **3:2**; route length and walk-back fairness |
| **6. Ledger and long census** | Eight-record decay ledger, strike-cycle bias, 12/18 population, dormant placement, long-session instrumentation | Repeated-tactic film shows a delivered-evidence skew and its decay after switching; long run shows local caller depletion without global state change | Mix changes without delivery; bias never decays; reserve recreates personnel | **1:1**; statistical effects may not teach themselves |

If a stage’s predicted observation is absent in the real Gauntlet run, it is revised before merge rather than landed disabled.

## Bottom line

The final Adversary is **two kinds of precious caller**, not a second combat horde:

- **Vagrant converts a live fight into a safe-edge call.**
- **Lacuna converts unheld rear ground into a new front.**

Both carry a visible, exploitable clock and preserve themselves by spending Testators. The Testator roster remains the combat vocabulary, with **Sexton** added as the disposable body that takes wrecks and evidence home. The design’s main unresolved empirical risk is whether two strategic, evasive invaders remain distinct and threatening at actual play speed; the first two filmed stages are deliberately arranged to falsify that quickly.