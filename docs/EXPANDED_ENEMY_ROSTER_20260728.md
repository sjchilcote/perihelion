# Expanded enemy roster and subsystem specification

Date: 2026-07-28

## Decision

Expand the defending force from seven renewable combat roles and two finite
callers into a complete war machine with logistics, engineering, recovery,
structure attack, local suppression, authorization, and a direct personnel
threat.

Implementation decision recorded 2026-07-29:

| Role | Status |
|---|---|
| `sexton` | Go — implement and experiment |
| `rasp` | Go — implement and experiment |
| `loom` | Go — implement and experiment |
| `censer` | Go — implement and experiment |
| `mason` | Go — implement and experiment |
| `threader` | Design candidate; not yet approved for implementation |
| `effigy` | Design candidate; not yet approved for implementation |
| `notary` | Design candidate; not yet approved for implementation |
| `damper` | Design candidate; not yet approved for implementation |
| `bailiff` | Design candidate; not yet approved for implementation |

“Go” authorizes prototype implementation, tuning, playtesting, and removal or
revision when an experiment fails its listed falsifiers. It does not make the
first tuning values permanent.

Add seven renewable chassis:

1. `sexton` — wreck and evidence hauler.
2. `rasp` — anti-structure dismantler.
3. `loom` — doorway control and capture-line projector.
4. `censer` — pulsed two-part area-denial unit.
5. `mason` — local fortification builder.
6. `threader` — small shortcut and breach infiltrator.
7. `effigy` — reconstructed one-off made from a recovered player frame.

Add three finite personnel roles:

8. `notary` — target authorization and attack-window control.
9. `damper` — active response suppression and field cleanup.
10. `bailiff` — licensed contact execution and immediate withdrawal.

Add six supporting subsystems:

1. Wreck claims and physical cargo.
2. Scriptorium rack and evidence ledger.
3. Bounded composition bias.
4. Removable fortification works.
5. Personnel dwell and withdrawal.
6. Structure threat and repair interruption.

The existing roster remains intact. New roles fill jobs that are currently
absent; they do not replace the readable basics.

## Governing split

The force has two fundamentally different lanes.

### Renewable chassis

Renewable chassis are produced by the reserve, use the fixed dispatch cycle,
and may be spent freely. They cannot call breaches, authorize other units, or
make strategic judgements.

Existing:

- `mite`
- `husk`
- `spitter`
- `brute`
- `shrieker`
- `warden`
- `flicker`

New:

- `sexton`
- `rasp`
- `loom`
- `censer`
- `mason`
- `threader`
- `effigy`, which is reconstructed rather than normally dispatched

### Finite personnel

Finite personnel are authored into the campaign. Their census never
increases. They can call, authorize, suppress, and withdraw, but the reserve
cannot manufacture them.

Existing:

- `vagrant`
- `lacuna`

New:

- `notary`
- `damper`
- `bailiff`

Every finite role carries a dwell budget outside supported ground. Normal
success for these roles is completing a task and withdrawing through a live
breach. Permanent shutdown is the exceptional player victory.

## Full roster map

| Job | Owner | Tactical question created |
|---|---|---|
| Cheap screen | `mite`, `husk` | Can the player maintain spacing? |
| Ranged pressure | `spitter` | Can the player deny the primer window? |
| Breaker | `brute`, `warden` | Can the player survive committed contact? |
| Warning and tracking | `shrieker` | Can the player interrupt a physical mark? |
| Ambush | `flicker` | Can the player manage light and proximity? |
| Calling | `vagrant`, `lacuna` | Can the player stop a rooted broadcast? |
| Wreck recovery | `sexton` | Does the player race, intercept, or raid the hub later? |
| Structure attack | `rasp` | Can the player defend a firebase without body-blocking it? |
| Doorway control | `loom` | Can the player cut lines before the room becomes segmented? |
| Area denial | `censer` | Can the player exploit pulse timing and precursor tanks? |
| Fortification | `mason` | Can the player prevent quiet ground from hardening? |
| Shortcut intrusion | `threader` | Is the player’s escape route also an attack route? |
| Repeat-intruder reconstruction | `effigy` | Can the player confront and reclaim a previous loss? |
| Authorization | `notary` | Can the player break a specialist attack before permission completes? |
| Response suppression | `damper` | Does the player want the current sector to quiet down? |
| Licensed execution | `bailiff` | Can the player bait and survive one extreme committed strike? |

## Shared subsystem 1 — wreck claims and physical cargo

### Existing object

Player shutdown already creates one `corpse_frame` pickup holding carried
components and station kits. Recovery returns those contents exactly.

The new system changes ownership and motion, not conservation.

### Claim lifecycle

Every cargo-capable floor object carries:

```text
cargo_id
cargo_kind
created_tick
claimable_tick
claimant_id
claim_expiry_tick
contents
damage_category
origin_chamber
```

The player frame remains exclusively player-recoverable for the first
15 seconds after shutdown. After that it becomes claimable by a `sexton`.

Ordinary renewable shutdowns remain decals and do not all become entities.
Only one evidence token may exist per chamber. It represents the most recent
unfiled damage category and prevents entity count from scaling with casualties.

Finite-personnel wrecks remain physical until recovered or destroyed. Their
larger local danger record makes leaving one in place strategically meaningful.

### Cargo types

Priority order for an unloaded `sexton`:

1. player frame;
2. finite-personnel wreck;
3. chamber evidence token;
4. renewable wreck selected for local cleanup.

A `sexton` carries exactly one object.

### Spill law

Nothing carried can vanish with the carrier.

On carrier shutdown:

- remove the carrier-to-cargo attachment;
- place the exact cargo at the shutdown position;
- preserve contents, age, and damage category;
- clear the claim;
- add a short pickup lock so the carrier cannot immediately reacquire it.

### Uncleared wreck pressure

A claimable wreck emits a small Distress increment every five seconds while
unclaimed. Moving it stops the emission. Filing or destroying it removes the
source permanently.

This creates a real cleanup trade:

- leave wrecks to keep attention concentrated in one region;
- permit cleanup to quiet the route;
- intercept the carrier to deny evidence;
- race back to recover player property.

## New renewable chassis 1 — `sexton`

### Identity

The `sexton` is a fast, unarmed hauler with an empty saddle visible even when
unloaded. It is the only ordinary unit whose default movement is away from an
engagement.

First-pass specification:

```text
integrity: 20
radius: 8
mass: 1.8
terminal speed unloaded: 175 units/s
terminal speed laden: 150 units/s
turn rate: 4.2 rad/s
touch damage: 0
dispatch cost: 2
```

### Search rule

Every 30 ticks, an unloaded `sexton` inspects its own chamber and one hop:

- cargo must be claimable and unclaimed;
- cargo chamber Noise must remain below 0.20 for three seconds;
- cargo chamber Danger must remain below 0.70;
- the unit must have a legal return route or a quiet fallback chamber.

It bids by cargo priority, then travel estimate, then entity id.

### Pickup

Pickup requires 45 rooted ticks beside the cargo. Damage or rising Noise
interrupts the pickup. Completion removes the floor object and attaches a
visible load.

### Laden mode

While laden, the `sexton`:

- ignores Muster;
- emits no relay;
- does not fight;
- follows its private reverse route toward the breach it arrived through;
- inside the hub, follows fixed depth toward the Scriptorium;
- avoids rising Danger when an alternate one-hop route exists;
- moves to a quiet fallback chamber if no return route exists.

It never stands indefinitely. A route failure produces short patrol loops
around the fallback cargo cache.

### Delivery

At the Scriptorium:

- a player frame enters a visible rack;
- an evidence token becomes one ledger record;
- a finite-personnel wreck restores no census but yields a high-weight record;
- a renewable wreck yields a low-weight record and local cleanup credit.

### Player counterplay

- Recover the frame before its claim delay ends.
- Interrupt the rooted pickup.
- Kill the laden unit and recover the exact spill.
- Cordon every breach and raid the predictable fallback cache.
- Allow cleanup deliberately to quiet a route.

### Falsifiers

- It enters an active firefight for cargo.
- It fights while laden.
- Cargo disappears on shutdown.
- A delivery changes composition without reaching the Scriptorium.
- The player frame loses or gains contents.

## Shared subsystem 2 — Scriptorium rack and evidence ledger

### Rack

The Scriptorium has eight physical rack positions.

A filed player frame occupies one position and remains visible. If all
positions are full, the oldest non-player evidence record is evicted first.
A player frame is never silently deleted. If all eight positions contain
player frames, further carriers wait in the outer hall or use fallback caches.

Destroying the Scriptorium:

- ejects every stored player frame as a recoverable pickup;
- clears every evidence record;
- disables new filing until reconstruction;
- leaves carriers holding their cargo.

### Evidence categories

Only four categories exist:

1. close ballistic;
2. scatter ballistic;
3. high-impulse precision;
4. electrical or field discharge.

The category comes from the existing damage-source record. It never reads
equipped weapon state.

### Weight and forgetting

The ledger holds at most eight records.

```text
record_weight = 2 ** (-(age_seconds / 75))
total_weight = sum(record_weight)
biased_slots = min(6, round(total_weight))
```

New evidence evicts the lowest current-weight record. No record is permanent.
Player shutdown does not clear the ledger.

### Composition bias

Evidence may replace at most six positions in the forty-slot renewable strike
cycle:

| Evidence | Favored response |
|---|---|
| Close ballistic | `spitter`, `loom` |
| Scatter ballistic | `brute`, `warden` |
| High-impulse precision | `flicker`, `threader` |
| Electrical or field discharge | `rasp`, `censer` |

Replacement preserves cost within two reserve units. An unaffordable selected
unit still stalls the queue; it is never substituted.

This is the only route from combat evidence to dispatch composition.
Live fields, player position, player integrity, and kill totals remain
structurally unavailable to the reserve controller.

### Player counterplay

- Kill carriers.
- Switch tactics and wait for old records to fade.
- Feed misleading but physically delivered evidence.
- Destroy the Scriptorium.
- Recover stored frames during the raid.

## New renewable chassis 2 — `rasp`

### Identity

The `rasp` is a slow anti-structure specialist with a front-mounted rotary
cutter. It prefers player-built objects over the player but cannot ignore
direct obstruction.

First-pass specification:

```text
integrity: 44
radius: 11
mass: 5
terminal speed: 145 units/s
turn rate: 2.8 rad/s
touch damage: 8
structure damage: 34 per second
dispatch cost: 4
```

### Target rule

It may target a structure only when:

- the structure is in direct sight;
- the structure is within its own chamber or visible through a clear portal;
- no hostile body is within 32 units;
- it has not been hit within 45 ticks.

Priority:

1. active sentry;
2. repair station;
3. signal scrubber;
4. pod;
5. removable fortification.

It never reads global structure lists. Candidate acquisition uses the same
visible-entity query as ordinary combat.

### Attack

The cutter requires:

- 30 ticks of bracing;
- continuous contact;
- a visible shower and rising cutter tone.

Player knockback breaks contact and resets the brace. The unit deals weak
ordinary contact damage so body-blocking is possible but not free.

### Wreck interaction

A destroyed structure leaves a short-lived component spill. A `sexton` may
carry one evidence token from it, but cannot carry the structure itself.

### Player counterplay

- Step between it and the structure.
- Use knockback to reset the brace.
- Lead it toward a less valuable object.
- Kill it before the cutter reaches full contact.
- Use a Portable Hole to change the firing geometry.

### Falsifiers

- It damages a structure through another chamber’s wall.
- It ignores a player standing in contact.
- It reaches into structure state without sight.
- Its brace survives knockback.

## New renewable chassis 3 — `loom`

### Identity

The `loom` projects removable lines between geometry points. It divides space
and supports capture without adding a chamber movement tax.

First-pass specification:

```text
integrity: 28
radius: 9
mass: 2.2
terminal speed: 160 units/s
turn rate: 4.0 rad/s
line packages: 3
dispatch cost: 3
```

### Placement sites

The `loom` may connect:

- the two lips of one doorway;
- a doorway lip to a nearby corner;
- two existing fortification pieces;
- a `warden` hold position to one nearby wall point.

Every endpoint must be in the current chamber and directly visible.

### Placement

The unit roots for 75 ticks while extending one visible line. Damage interrupts
placement and consumes no package. Completion consumes one package.

### Line effects

A completed line is ordinary collision-sensitive geometry with:

- low integrity;
- no direct damage;
- strong velocity reduction only while physically intersecting it;
- a break threshold from high impulse;
- a maximum lifetime of 20 seconds.

The player, enemies, projectiles, and removable works all interact with the
same line. Friendly units do not pass through it for free.

### Capture cooperation

If a `warden` holds the player, a `loom` may place one line behind the hold
only if it already had direct sight before capture began. This line blocks
reinforcement or retreat routes; it does not increase hold damage.

### Player counterplay

- Shoot the rooted projector.
- Cut the line.
- Use high impulse to break it.
- Bait placement across an enemy route.
- Cross before construction completes.

### Falsifiers

- A line appears without visible construction.
- Allies ignore it.
- It creates a chamber-wide slow.
- It survives beyond its lifetime.
- It crosses a portal or unsupported empty space.

## New renewable chassis 4 — `censer`

### Identity

The `censer` carries two visibly separate precursor tanks and a reinforced
reaction chamber. It produces pulsed area denial rather than continuous
damage.

First-pass specification:

```text
integrity: 36
radius: 10
mass: 3
terminal speed: 150 units/s
turn rate: 3.3 rad/s
precursor pairs: 4
dispatch cost: 3
```

### Firing cycle

1. Track the player for 30 ticks.
2. Lock a 55-degree arc and stop tracking.
3. Fire four pulses at 8-tick intervals.
4. Enter a 120-tick pressure-recovery state.

One firing cycle consumes one precursor pair. Each pulse places a small patch
lasting six seconds.

### Patch effect

The patch:

- deals no immediate impact damage;
- applies low damage only while occupied;
- reduces traction equally for every moving body;
- blocks garrison settlement while present;
- contributes Noise through the existing field;
- can be removed by the cleaning subsystem.

Patches do not stack damage. Overlap extends coverage only.

### Component damage

The two tanks are targetable subparts:

- losing one disables firing;
- destroying both causes no explosion;
- a charged high-impulse hit during the locked firing arc ruptures the active
  chamber and spills one patch at the unit’s position.

### Player counterplay

- Reverse direction after arc lock.
- Push through between pulses.
- Destroy one tank.
- Force rupture beside other enemies.
- Lure it into sealing its own doorway.

### Falsifiers

- Continuous tracking after lock.
- An invisible chamber-wide effect.
- Damage stacks from overlapping patches.
- Unlimited ammunition.
- A destroyed tank silently regenerates.

## New renewable chassis 5 — `mason`

### Identity

The `mason` hardens quiet garrisons using removable, ordinary geometry. It
never constructs during active contact and never follows a global blueprint.

First-pass specification:

```text
integrity: 30
radius: 9
mass: 2.4
terminal speed: 145 units/s
turn rate: 3.5 rad/s
material packages: 3
dispatch cost: 3
```

### Activation

A `mason` may work only when:

- it is inside a functioning garrison;
- no direct hostile sighting occurred for six seconds;
- local Noise is below 0.20;
- local Danger is below 0.35;
- fewer than four friendly works exist in the chamber.

### Site selection

Candidate sites come from:

- doorway lips;
- corners;
- damaged player structures;
- existing friendly work endpoints;
- the most recently crossed doorway.

The score favors recent traffic, exposed corners, and active nearby work.
There is no hidden construction field.

### Works

The `mason` can create:

1. **Baffle** — a short angled barrier beside a doorway.
2. **Brace** — adds integrity to one existing friendly work.
3. **Socket** — a resupply point for ranged packages.

Every work:

- uses ordinary collision;
- is removable;
- has a strict footprint;
- cannot seal the last player-traversable route;
- is destroyed on incompatible topology change.

### Construction

Construction takes 180 rooted ticks and consumes one package on completion.
At most two nearby `mason` units may cooperate, reducing remaining time but
not material cost.

### Player counterplay

- Keep the garrison noisy.
- Interrupt rooted work.
- Destroy the small unit before the structure.
- Use the new cover against its owners.
- Remove the `warden` before new settlers establish the work site.

### Falsifiers

- Construction during direct sight.
- A wall appearing without a worker.
- An impassable final exit.
- More than four works in one chamber.
- Runtime geometry surviving a topology conflict.

## New renewable chassis 6 — `threader`

### Identity

The `threader` is a long, narrow infiltrator specifically sized for Portable
Holes and congested breach mouths. It turns the player’s shortcut into a
two-way tactical commitment.

First-pass specification:

```text
integrity: 11
radius: 4.5
mass: 1.5
terminal speed: 205 units/s
turn rate: 8.0 rad/s
touch damage: 7
dispatch cost: 2
```

### Route rule

The `threader` values:

- a visible Portable Hole;
- a doorway whose ordinary admission wait load is high;
- a path with recent player traversal residue;
- routes rejected by large units.

It does not know that an exit is “safe.” It merely sees a legal small aperture
and a strong route signal.

### Attack

After crossing a Portable Hole, it receives one 45-tick acceleration burst but
cannot attack for the first 18 ticks. This prevents unavoidable spawn contact
while preserving the intrusion.

When three `threader` units occupy one chamber, only the first two pursue
directly. Others orbit entry geometry and attack from different headings.

### Player counterplay

- Stop firing through a hole once small silhouettes gather.
- Collapse or abandon the shortcut.
- Use the turret at the destination.
- Kill them during the attack lockout.
- Exploit their low integrity with area damage.

### Falsifiers

- A large unit follows through an undersized aperture.
- Contact damage lands during the lockout.
- A whole group occupies one point after crossing.
- The unit routes through a shortcut it cannot locally observe or trace.

## New renewable chassis 7 — `effigy`

### Identity

An `effigy` is a hostile reconstruction made from a player frame stored at the
Scriptorium. It is not a copy of the player build and does not duplicate
equipment. It is a one-off reminder of a specific unrecovered loss.

### Creation

Creation requires:

- one stored player frame;
- a functioning Scriptorium;
- an empty reconstruction cradle;
- 12 reserve units;
- 30 uninterrupted seconds.

Only one `effigy` may exist per stored frame. Starting construction removes
the frame from its rack into the visible cradle. Destroying the cradle returns
the original frame and exact contents.

### Loadout selection

The frame’s last damage category selects one fixed weapon:

| Last recorded category | `effigy` weapon |
|---|---|
| Close ballistic | short predictive fan |
| Scatter ballistic | stored-energy impact |
| High-impulse precision | contact lance |
| Electrical or field discharge | three-pulse field projector |
| Unknown | ordinary `husk` lunge |

This is not player equipment replication. It is a small authored response
table keyed to the frame’s recorded failure.

### Behavior

The `effigy`:

- cannot call;
- cannot be filed as evidence;
- follows ordinary field pursuit;
- ignores garrison settlement;
- carries a bright rack index matching its source frame;
- drops the original frame and contents on shutdown.

### Player counterplay

- Recover the frame before construction.
- Destroy the Scriptorium.
- Destroy the reconstruction cradle.
- Kill the `effigy` and reclaim the exact frame.
- Deliberately influence the last recorded damage category before shutdown.

### Falsifiers

- It duplicates player ammunition or weapons.
- Its frame contents change.
- More than one exists per frame.
- It enters the ordinary strike cycle.
- Killing it fails to return the original frame.

## Shared subsystem 3 — active authorization

### Two-stage attack

Authorization uses two physical stages:

1. a `shrieker` tracking mark establishes a candidate;
2. a `notary` maintains direct sight and applies a warrant.

The warrant permits one `bailiff` strike. It does not amplify ordinary damage,
change dispatch, or reveal the player through walls.

### Warrant state

The player may hold one warrant:

```text
notary_id
created_tick
expires_tick
licensed_strikes
```

It expires after eight seconds or after one licensed strike.

## New finite personnel 1 — `notary`

### Identity

The `notary` is an unarmed authorization specialist. Its threat is the attack
window it creates for another finite role.

First-pass specification:

```text
integrity: 70
radius: 9
mass: 1.6
terminal speed: 170 units/s
turn rate: 4.5 rad/s
touch damage: 0
dwell budget outside supported ground: 45 seconds
```

### Authorization

It may begin only when:

- the tracking mark is active;
- the `notary` has direct sight;
- no other warrant exists;
- a living `bailiff` is in the same chamber or one hop;
- local Danger is below 0.70.

It roots for 90 ticks and projects a visible line from itself to the tracking
mark. Breaking sight, damage, knockback, or mark expiration cancels progress.

Completion creates one eight-second warrant.

### Withdrawal

After successful authorization or loss of half integrity, the `notary`
withdraws toward supported ground. It does not authorize again until it
completes a 12-second reset there.

### Player counterplay

- Remove or outlast the tracking mark.
- Break line of sight.
- Hit the rooted specialist.
- Kill or separate the `bailiff`.
- Let it withdraw and hunt it away from the main push.

### Falsifiers

- Authorization through a wall.
- A warrant without a living nearby `bailiff`.
- Ordinary units gaining bonus damage.
- Immediate reauthorization without reset.
- Reserve manufacture of a replacement.

## New finite personnel 2 — `damper`

### Identity

The `damper` actively ends a response. It is a strategically ambiguous enemy:
killing it can make the current sector harder to escape.

First-pass specification:

```text
integrity: 56
radius: 8
mass: 1.5
terminal speed: 165 units/s
turn rate: 4.0 rad/s
touch damage: 0
shared drain capacity: 1.2 units/s
dwell budget outside supported ground: 50 seconds
```

### Activation

It moves toward rising Distress but refuses to enter a chamber above the danger
hold line. From the adjacent chamber it roots and calls the existing shared
signal drain with:

- weight 1.0 on its own chamber;
- weight 0.5 on each adjacent chamber;
- one total shared capacity across all nine fields.

It drains proportionally to what is present. It never multiplies field values
or changes half-lives.

### Consequences

While it works:

- Muster falls;
- stale pursuit stands down sooner;
- garrison reach weakens;
- player tracking residue thins;
- real new contact can still overwrite the drain.

### Player counterplay

- Let it work to create a quieter escape.
- Kill it to preserve a loud diversion.
- Push it into the high-danger chamber where it refuses to operate.
- Use new Noise to exceed its bounded capacity.

### Falsifiers

- Instant field deletion.
- Entry into the hot chamber.
- Drain exceeding total capacity.
- Direct reserve or dispatch effects.
- Passive operation while moving.

## New finite personnel 3 — `bailiff`

### Identity

The `bailiff` is the direct combat presence of the finite lane. It carries one
extreme contact lance, fires only under a warrant, and then withdraws.

First-pass specification:

```text
integrity: 110
radius: 11
mass: 4
terminal speed: 185 units/s
turn rate: 3.8 rad/s
ordinary touch damage: 6
lance packages: 1
dwell budget outside supported ground: 35 seconds
```

### Unlicensed behavior

Without a warrant it:

- stays near a `notary`;
- avoids direct approach;
- uses ordinary collision and weak contact only;
- refuses danger-held doorways;
- withdraws if no `notary` remains nearby.

### Licensed strike

On warrant:

1. flash the lance twice over 300 milliseconds;
2. lock a predicted intercept heading;
3. accelerate for 18 ticks;
4. on direct contact, apply 32 damage and 360 impulse;
5. miss or hit consumes the package and warrant;
6. immediately withdraw.

The strike cannot capture, turn during the burst, cross a portal, or fire
without direct same-chamber sight.

### Reset

The lance can be rebuilt only after 20 uninterrupted seconds at the
Scriptorium or a deep hub station. Reset does not restore a shut-down
`notary`; personnel remain finite.

### Player counterplay

- Break authorization.
- Bait the committed intercept and turn inside it.
- Put geometry between the charge line and the player.
- Knock it off heading during the flashes.
- Hunt it during withdrawal before reset.

### Falsifiers

- A strike without a warrant.
- Mid-burst homing.
- A charge through a portal.
- More than one strike per package.
- Normal reserve dispatch.

## Shared subsystem 4 — removable fortification works

### World representation

Runtime works are first-class ordinary entities:

```text
work_id
kind
polygon
endpoints
integrity
owner_id
created_tick
expires_tick
```

They use collision and sight blocking only when their geometry visibly
supports it. No work modifies authored polygon vertices.

### Limits

- Maximum four works per chamber.
- Maximum one line across any doorway.
- No work may reduce the final player clearance below 15 units.
- No work may seal the last reachable route.
- A topology change runs a compatibility check and removes conflicts.
- Destroyed works may drop at most one component.

### Ownership after worker shutdown

Completed works persist without their builder. Incomplete works vanish when
the builder stops, returning no material.

### Player structures

Player and enemy works use the same collision and damage services. Allegiance
affects target selection, not physics.

## Shared subsystem 5 — personnel dwell and withdrawal

### Dwell

Every finite role carries:

```text
dwell_remaining
supported
withdraw_target
reset_required
```

Supported ground is:

- the hub;
- the far side of a live breach;
- an authored high-support chamber.

Garrisons do not create supported ground.

### Consumption

Outside supported ground:

- ordinary movement drains at one unit per second;
- rooted specialist work drains at 1.5 units per second;
- direct combat drains at two units per second.

Below 25 percent, the role stops taking new tasks and withdraws.
At zero, it loses speed and authorization capability but does not
automatically shut down.

### Reset

Returning to supported ground restores dwell over 12 seconds. Damage or direct
sight interrupts restoration.

### Player consequence

The player can win a personnel encounter by denying withdrawal rather than
out-damaging the whole escort. A retreating finite silhouette becomes a
high-value chase target.

## Shared subsystem 6 — structure threat and repair interruption

### Structure damage

All player structures gain:

- integrity;
- damage source;
- last damaged tick;
- repair-blocked tick;
- visible damage states.

Existing sentry behavior remains otherwise unchanged.

### Repair

A repair station may restore nearby structures only after six seconds without
damage. A `rasp` hit resets this window. Repair consumes components through the
existing player economy.

### Destruction

Destroyed structures:

- stop functioning immediately;
- remain as collision wrecks for five seconds;
- then become a small component spill;
- may generate one evidence token;
- never become renewable enemies.

## Revised renewable dispatch cycle

Replace the twenty-slot cycle with a deterministic forty-slot cycle so rare
support roles can exist without appearing in every small wave.

Target composition:

| Band | Share | Members |
|---|---:|---|
| Screen and intrusion | 35% | 6 `mite`, 6 `husk`, 2 `threader` |
| Ranged and control | 25% | 5 `spitter`, 2 `shrieker`, 1 `loom`, 2 `censer` |
| Mobility, logistics, and engineering | 20% | 3 `flicker`, 1 `sexton`, 2 `rasp`, 2 `mason` |
| Breakers | 20% | 6 `brute`, 2 `warden` |

Breakers remain nonadjacent. `sexton`, `mason`, and `loom` do not occur in the
first five positions. The first visible pour remains combat-capable.

First-pass costs:

| Role | Cost |
|---|---:|
| `mite` | 1 |
| `husk` | 2 |
| `spitter` | 2 |
| `threader` | 2 |
| `sexton` | 2 |
| `shrieker` | 3 |
| `flicker` | 3 |
| `loom` | 3 |
| `censer` | 3 |
| `mason` | 3 |
| `brute` | 4 |
| `rasp` | 4 |
| `warden` | 8 |

The guardian shelf gains one `rasp` and one `sexton` but does not gain a
`mason`; hub works should be authored or constructed only after the first
quiet rebuild.

## Encounter packages

### Salvage race

- One `sexton`
- Two `husk`
- One `spitter`

The player sees an unloaded carrier moving toward a previous shutdown site
while the escorts delay pursuit.

### Firebase dismantling

- One `rasp`
- One `loom`
- Two `mite`
- One `brute`

The line projector segments approach space while the cutter braces against a
structure.

### Hardened garrison

- One `mason`
- One `spitter`
- Two `husk`
- Existing settlers

The room changes between visits because quiet time was allowed, not because a
level script advanced.

### Personnel warrant

- One `notary`
- One `bailiff`
- One `shrieker`
- Renewable screen

This is the most dangerous new attack and must remain rare. Removing any one
specialist breaks the full sequence.

### Quieting crew

- One `damper`
- One `sexton`
- Renewable escort

The player chooses whether to allow the battlefield to be cleaned and the
response to deflate.

### Shortcut breach

- Three `threader`
- One `flicker`

The player’s own Portable Hole or narrow route becomes the threat vector.

### Reaction-line denial

- Two `censer`
- One `loom`
- One `spitter`

Pulse timing and removable geometry reshape the chamber without adding a
permanent movement debuff.

## Campaign introduction order

1. `sexton` and wreck race.
2. `rasp` and structure integrity.
3. `threader` and two-way Portable Hole pressure.
4. `censer` and pulsed area denial.
5. `loom` and removable lines.
6. `mason` and garrison works.
7. Scriptorium rack and evidence ledger.
8. `effigy` reconstruction.
9. `damper`.
10. `notary` and `bailiff` together.

Never introduce `notary` without `bailiff`, or the authorization tell has no
meaning. Never introduce `effigy` before the player has learned that a
`sexton` can take a frame.

## Implementation sequence

### Phase 1 — physical logistics

- Make `corpse_frame` transferable by a carrier without changing contents.
- Add cargo claims, pickup dwell, laden state, and spill.
- Add Scriptorium rack storage.
- Add `sexton`.
- Add deterministic conservation tests.

This phase delivers the director’s missing remains-recovery creature before
any adaptive composition work.

### Phase 2 — structure warfare

- Add structure integrity and repair interruption.
- Add `rasp`.
- Add structure evidence tokens.
- Confirm existing sentry encounters remain fair.

### Phase 3 — alternative pressure

- Add `censer` projectiles, patches, tanks, and cleanup interaction.
- Add `loom` lines using ordinary collision.

### Phase 4 — territorial engineering

- Add work entities and chamber limits.
- Add `mason`.
- Integrate works with local garrison posts.
- Add topology-conflict removal.

### Candidate phase 5 — shortcut intrusion

- Requires a separate implementation decision.
- Add `threader`.
- Validate narrow-route traversal and post-crossing vulnerability.

### Candidate phase 6 — memory and reconstruction

- Requires a separate implementation decision.
- Add the eight-record ledger and 75-second decay.
- Expand to the forty-slot cycle.
- Add bounded cost-preserving replacement.
- Add reconstruction cradle and `effigy`.

### Candidate phase 7 — finite personnel

- Requires a separate implementation decision.
- Add shared dwell and withdrawal.
- Add `damper`.
- Add warrant state.
- Add `notary` and `bailiff` as one vertical slice.

## Performance constraints

Every implementation phase requires a before/after `perf_test.py` report.

Bounded-state requirements:

- at most one evidence token per chamber;
- at most eight ledger records;
- at most four works per chamber;
- at most one active warrant;
- one cargo per carrier;
- cargo searches limited to own chamber and one hop;
- no per-agent full graph search;
- no runtime polygon-vertex mutation;
- no new chamber field;
- finite roles sampled only while active.

Required reports:

```text
python perf_test.py --name "sexton_logistics"
python perf_test.py --name "structure_warfare"
python perf_test.py --name "alternate_pressure"
python perf_test.py --name "garrison_engineering"
python perf_test.py --name "scriptorium_ledger"
python perf_test.py --name "finite_personnel"
```

Judge p90 and maximum time at the long sightline, large hub, and
self-connecting polygon.

## Global acceptance

- Every new role has a task it owns and a condition where it does nothing.
- No cargo, stored frame, or carried component can disappear.
- No finite role can be manufactured.
- No renewable role can call or authorize.
- Dispatch remains blind except for physically filed ledger records.
- Every specialist action is interruptible and visibly telegraphed.
- Every persistent object is removable.
- Friendly units obey the same runtime collision geometry as the player.
- No new effect crosses a sealed connection.
- Every new role has typed telemetry for task start, completion, interruption,
  withdrawal, and shutdown.
- New mechanics preserve deterministic replay.

## Explicit cuts

- No unrestricted resurrection of ordinary decals.
- No enemy copying the player’s full build or ammunition.
- No live combat field feeding dispatch directly.
- No invisible structure damage.
- No friendly-only collision exemption for capture lines.
- No dynamic wall that seals the final traversable route.
- No area effect without visible source, finite supply, and removal rule.
- No global cargo task board.
- No personnel respawn disguised as reconstruction.
- No evidence record without physical delivery.

## Authority

This document expands `docs/INTEGRATED_COMBAT_MECHANICS_20260728.md`.
The five integrated combat mechanics remain in force. Where an earlier
research shortlist says to defer a role that is explicitly adopted here, this
expanded roster document wins.
