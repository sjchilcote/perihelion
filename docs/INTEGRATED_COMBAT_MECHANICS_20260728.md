# Integrated combat mechanics

Date: 2026-07-28

## Decision

Add five mechanics. They extend systems that already ship and do not add an
enemy class, a chamber-wide field, a global planner, or a second dispatch
economy.

1. Doorway traffic protocol.
2. Primer-and-impact assault.
3. Wounded retreat report.
4. Local garrison posts.
5. Exhaustible ranged packages.

The first three form the initial vertical slice. Together they make an attack
read as a coordinated process:

- traffic gathers without becoming a doorway pile;
- ranged units prepare an opening;
- melee units exploit it;
- a damaged survivor can make the next push more cautious.

The last two make held territory and attrition matter after the immediate
fight.

## Existing foundations that remain authoritative

The game already has:

- fractional local commitment using visible peers;
- finite sight and one-hop field observations;
- nine shared chamber fields;
- directed doorway-use marks;
- danger-based holding beside a doorway;
- a multi-route raid fraction;
- automatic stand-down after quiet;
- a physical player mark and traversal residue;
- a caller that wakes nearby defenders;
- emergent garrison settlement around a physically present `warden`;
- `warden` capture with a visible charge and a kill-the-captor escape rule;
- a closed, blind reserve with cost-fair breach scheduling;
- a fixed twenty-slot strike composition;
- universal physical impulse from damaging player weapons;
- deterministic replay and structured coordination telemetry.

None of those systems is replaced. The new rules must compose through their
public state rather than reaching into private controller data.

## Role ownership

| Existing role | Current job | Added job |
|---|---|---|
| `mite` | Fast screen and gap closer | Uses one doorway slot; may consume a primer for displacement |
| `husk` | Basic melee pressure and lunge | Primary primer consumer |
| `spitter` | Ranged spacing pressure | Places the primer; carries a visible finite package |
| `brute` | Breaker, heavy contact, lunge | Strong primer consumer; consumes two doorway slots |
| `shrieker` | Warning, physical mark, pursuit guidance | No new job |
| `warden` | Heavy pressure, capture, settlement anchor | Consumes two doorway slots; carries a small ranged package |
| `flicker` | Independent low-light ambush | Exempt from group attack scheduling |
| `vagrant`, `lacuna` | Finite callers and expansion personnel | Exempt from group attack scheduling |

The exclusions are deliberate. The caller and ambusher already have complete
state machines. Folding them into every group rule would erase their identity
and create difficult cross-state failures.

## 1. Doorway traffic protocol

### Purpose

Replace unregulated approach piles with a local admission rule, while retaining
the existing positive route-use marks and danger holding.

### State

Each open doorway direction owns:

```text
active_slots
slot_capacity
wait_load
last_progress_tick
```

This is edge state, not a chamber field.

Slot capacity derives from usable opening width:

```text
slot_capacity = max(1, floor(usable_width / 18))
```

Small and ordinary units consume one slot. `brute` and `warden` consume two,
clamped so either can use a one-slot opening alone. A slot lease lasts at most
75 ticks.

### Claim rule

An agent may claim a slot only when:

- the doorway is its committed route;
- it is within 48 units of the doorway midpoint;
- it is not currently danger-holding;
- it is not in an attack wind-up;
- enough capacity is free.

The lease releases on:

- crossing;
- route change;
- knockback outside the approach zone;
- shutdown;
- expiry;
- topology change.

Only a slot holder aims directly through the opening. A waiting agent uses the
existing keep-apart steering to occupy an alternating offset beside the frame.
It may still fire if its existing role permits it.

### Wait load

A denied claim adds wait load in that direction. A lease that crosses reduces
it. Lack of waiting fades it.

First-pass rule:

```text
denied claim: +0.08
successful crossing: -0.25
half-life: 3 seconds
clamp: 0 to 2
```

Route scoring becomes:

```text
existing attraction - 0.65 * wait_load
```

The positive doorway-use mark remains positive. Do not overload one scalar
with opposite meanings.

### Interaction with existing rules

- Danger holding happens before admission. A holder does not reserve a slot.
- The raid fraction may select a second route before admission.
- The progress watchdog may force a route change and must release the lease.
- A one-door chamber never reroutes; waiting agents simply remain offset.
- A dispatched unit keeps its breach destination, but may choose another legal
  local route toward it.
- A topology change invalidates every lease attached to the changed edge.

### Player consequence

Knocking the front unit away creates a real, short opening. Sustained pressure
raises wait load and diverts some traffic when an alternate route exists.
Brief obstruction does not turn the whole attack around.

### Required tells

- the slot holder leans or points through the opening;
- waiting units visibly occupy alternating frame offsets;
- a lease lost to knockback produces a brief re-selection motion;
- rerouting begins only after the queue was visible.

### Acceptance gates

- No doorway direction exceeds its slot capacity.
- An expired or dead claimant releases within one simulation tick.
- A `brute` cannot overlap an ordinary unit in a one-slot opening.
- A one-door chamber remains live and eventually crosses.
- A two-route pressure test sends less traffic to a continuously blocked edge.
- A sub-second obstruction does not change route.
- No agent changes route more than once per 180 ticks.
- p90 and maximum crossing delay improve against the current pile-up case.
- Uncongested one-agent movement is unchanged.

## 2. Primer-and-impact assault

### Purpose

Create cooperation between the existing ranged and melee roles without an
invisible focus-fire multiplier.

### State

The player may carry one primer:

```text
source_id
placed_tick
expires_tick
strength
```

The primer is a physical visible patch distinct from the existing tracking
mark. It does not write fields, reveal position, slow movement, or deal damage
over time.

### Placement

An unprimed `spitter` projectile behaves as follows:

- direct damage falls from 9 to 6;
- a hit places one primer for 240 ticks;
- a second hit refreshes duration but does not stack strength;
- a `warden` projectile never places a primer.

This gives `spitter` a support identity without turning every ranged unit into
the same weapon.

### Consumption

The next qualifying melee contact consumes the primer:

| Consumer | Existing contact damage | Added effect |
|---|---:|---|
| `mite` | unchanged | 70 outward impulse |
| `husk` | unchanged | 140 outward impulse |
| `brute` | unchanged | 230 outward impulse |

The effect is displacement, not bonus damage or a stun. It uses the same
physics impulse path as every other damaging attack.

The following do not consume it:

- `warden` capture or ordinary contact;
- `flicker` ambush;
- caller contact;
- returned projectiles;
- environmental damage.

### Why one primer

Multiple stacks would become a status HUD and encourage unavoidable burst.
One binary physical patch is readable, creates a short assault window, and
lets the player clear the condition simply by denying melee contact until it
expires.

### Interaction with the tracking mark

The two marks stay orthogonal:

- tracking mark: movement history and pursuit;
- primer: short combat setup.

They need different shape, color, sound, and lifetime. Neither refreshes the
other.

### Player consequence

The ranged hit is no longer merely chip damage. The player must decide whether
to keep firing while retreating, break line of sight until the primer expires,
or spend knockback ammunition to deny the approaching consumer.

### Required tells

- the projectile has a unique core color;
- the primer appears on the player body, not underfoot;
- its visual intensity declines over four seconds;
- the consuming impact produces a directional burst from the attacker;
- expiration makes a small dry break with no damage.

### Acceptance gates

- Only one primer exists.
- Refresh never increases strength.
- Expiration occurs exactly 240 ticks after the latest valid hit.
- Consumption uses physical impulse and applies no movement lock.
- `warden`, `flicker`, and callers cannot consume it.
- Primer state crosses portals with the player without coordinate artifacts.
- A primer hit followed by denied contact deals less total damage than the old
  projectile over the same interval.
- A successful ranged-plus-melee sequence produces clearly greater
  displacement than either attack alone.

## 3. Wounded retreat report

### Purpose

Let a surviving defender alter the next local push using the existing danger
memory. This makes “finish it or let it run” a tactical choice.

### Qualification

An ordinary combat unit becomes report-ready when all are true:

- it falls below 35 percent integrity;
- it had direct sight of the player within the previous 120 ticks;
- it subsequently crosses away from that sighted chamber;
- it has not reported before.

`shrieker`, `flicker`, callers, fixed structures, and dispatched units still
marching to their delivery point are excluded.

### Report

On the first qualifying crossing:

- add 0.22 danger to the chamber the unit left;
- add 0.08 muster to the chamber it entered;
- set `retreat_reported = true`;
- emit one telemetry record naming both chambers.

No token is handed between agents. The survivor physically carried the report
across a doorway and wrote into fields that already mean “this ground has hurt
us” and “gather here.”

### Boundaries

- One unit reports at most once.
- The report never writes danger into the destination.
- Damage without a retreat produces nothing.
- A unit removed before crossing produces nothing.
- A crossing toward the last sighting is not a retreat.
- Direct sight still overrides danger holding as currently specified.
- The report does not affect reserve dispatch or strike composition.

### Player consequence

Letting a damaged unit escape can delay the next lone entry and encourage a
gathered push. Finishing it prevents that report but may cost time or
ammunition while other threats close.

### Required tells

- the ready unit displays an intermittent retreat trace;
- the qualifying doorway crossing leaves one brief edge pulse;
- waiting defenders use the existing beside-the-frame Muster pose;
- there is no new persistent floor decal.

### Acceptance gates

- A qualifying survivor changes only the two local field values specified.
- Killing it before crossing changes neither.
- Repeated crossings cannot repeat the report.
- A reported chamber measurably increases later danger-hold frequency.
- Direct sight and recent damage still break a hold.
- Reserve, breach scheduling, and remote chambers are bit-identical.

## 4. Local garrison posts

### Purpose

Give settled groups a readable defensive arrangement instead of leaving every
settler at an arbitrary resting point.

### Post generation

When the second settler makes a functioning garrison, generate ephemeral posts
from local geometry:

- two flanking points beside each open doorway;
- one rear point opposite the most recently active doorway;
- one center reserve point.

Posts are derived, never saved as world entities. A topology change regenerates
them.

### Local claims

Every settler evaluates only posts in its own chamber. The bid is:

```text
distance + occupancy penalty - recent-hostile-traffic priority
```

The lowest bidder claims the post for 240 ticks. Visible progress refreshes
the claim. Loss of the route, combat contact, or leaving the chamber releases
it.

An unclaimed doorway post gains priority for six seconds. This is the only
aging rule. There is no global task board and no one-hop post stealing.

### Behavior

- `spitter` prefers the rear point, then a doorway flank.
- `brute` and `warden` are not settlers and claim nothing.
- `mite` prefers the center reserve until hostile traffic appears.
- `husk` prefers doorway flanks.
- a settled unit abandons its post immediately on direct sight;
- after stand-down it returns to any locally available post, not necessarily
  the old one.

### Interaction with garrison fields

Post claims do not change field emission. Existing interior/reach behavior
still depends only on settled occupancy and converging propagation.

### Player consequence

A defended chamber has a legible shape. Repeated probing at one doorway pulls
the center reserve toward that edge and can expose another entrance without
granting the defenders awareness beyond their chamber.

### Acceptance gates

- No two settlers retain one exclusive post for more than one claim step.
- Two-settler garrisons cover different positions.
- Direct sight interrupts every post claim.
- A topology change leaves no stale claim.
- Repeated traffic at one doorway moves at least one reserve unit toward it.
- A quiet chamber reaches a stable arrangement within eight seconds.
- No post query crosses a doorway.

## 5. Exhaustible ranged packages

### Purpose

Turn ranged pressure into attrition that the player can read and manipulate,
while making garrisons and live breaches useful as physical supply points.

### Package counts

| Role | Capacity | On depletion |
|---|---:|---|
| `spitter` | 4 | retains movement and weak contact; seeks resupply after losing sight |
| `warden` | 3 | retains capture and contact; cannot fire ranged shots |

Package count is visible on the chassis. Authored and dispatched units begin
full.

### Resupply

A depleted unit may resupply only while:

- it has had no direct sight for 180 ticks;
- it is in its settled garrison chamber, a live breach endpoint, or the reserve
  hub;
- it remains within 36 units of the supply point;
- it remains uninterrupted for 180 ticks.

Completion restores the full package at once. Damage, sight, movement away, or
topology change resets progress.

There is no reserve cost. These are local combat packages already included in
the unit’s dispatch price. The rule limits fight cadence rather than creating
another economy.

### Player consequence

The player can bait four `spitter` shots into cover, then push. A depleted unit
that escapes may return dangerous if allowed three quiet seconds at a supply
point. Following it risks entering defended ground.

### Required tells

- one visible package light extinguishes per shot;
- the last shot uses a distinct empty click after release;
- resupply roots the unit and lights packages sequentially;
- interruption visibly clears partial progress.

### Acceptance gates

- A unit cannot fire at zero packages.
- Every ranged shot consumes exactly one.
- No passive timer restores packages.
- Resupply occurs only at an allowed physical location.
- Damage or sight resets partial resupply.
- Dispatch cost and cadence remain unchanged.
- A depleted `warden` can still capture.
- Identical shot and resupply histories replay identically.

## Interaction sequences

### Killbox approach

1. Repeated player fire raises danger beyond a doorway.
2. Lone attackers hold beside the frame and emit Muster.
3. Waiting attackers do not consume admission slots.
4. Once the push releases, only slot holders enter.
5. Repeated denied admission raises directional wait load.
6. A raid member may take another route if one exists.

This preserves the current danger-hold drama while preventing the released
push from becoming a collision pile.

### Ranged setup into melee impact

1. A `spitter` spends one visible package.
2. The projectile hits and places the four-second primer.
3. `husk`, `mite`, and `brute` continue their existing pursuit.
4. The first qualifying contact consumes the primer for role-scaled impulse.
5. Ordinary contact damage and cooldown remain unchanged.

No attacker is commanded to focus the primed player. The cooperation emerges
because existing attacks can exploit the physical state when they arrive.

### Failed attack and cautious next push

1. The player wounds an ordinary unit below 35 percent.
2. The unit loses sight and retreats through a doorway.
3. The chamber it left gains a bounded danger increment.
4. Later lone attackers are more likely to hold outside that chamber.
5. The survivor cannot report again.

### Garrison attrition

1. Settlers occupy local posts.
2. A ranged defender spends its packages during contact.
3. After stand-down, it moves to a local supply point.
4. The player may chase and interrupt, or leave it to re-arm.
5. Doorway probes pull the center reserve toward recent traffic.

## Research candidates deliberately not added

| Candidate | Disposition | Reason |
|---|---|---|
| New relay-wave system | Cut | Sighted agents already relay Muster and Distress; the caller already wakes a bounded two-hop region |
| Target-tag quorum | Folded into primer | A multi-stack authorization would duplicate the tracking mark and become a HUD |
| New capture mesh | Cut | `warden` capture already supplies containment with a physical escape rule |
| Perimeter execution around captured player | Cut | Capture is already lethal; adding a firing formation would produce unavoidable damage |
| Contact counterlance | Defer | `husk`, `brute`, `flicker`, and `warden` already have committed burst attacks |
| Synchronized ranged volley | Defer | Needs formation readability proven by local posts first |
| Sacrificial area charge | Cut | Conflicts with salvage readability and makes low-integrity cleanup unpredictable |
| Geometry construction | Defer | No builder role or removable cover grammar exists |
| Per-agent false-signal adaptation | Defer | The player has no sufficiently distinct decoy categories yet |
| Physical incident courier | Defer | Valuable only after equipment categories produce clearly different tactics |
| Dynamic counter composition | Cut | Violates the fixed strike cycle and blind reserve |
| New shared scalar | Cut | Existing fields and edge state cover every adopted rule |
| Generic negative route trail | Cut | Evidence conflicts, and wait load plus danger already express the useful cases |

## Shared implementation structures

### Edge coordination record

Doorway admission and directional wait load belong in one record keyed by
doorway side. Do not create separate dictionaries for leases, queues, and
congestion.

### Timed physical status

Primer and retreat readiness use the same generic pattern:

```text
source
created_tick
expires_tick
consumed
```

They remain different statuses because they have different owners and visual
language.

### Local claim record

Admission and posts may share claim lifecycle helpers:

```text
claimant
target
claim_tick
expiry_tick
progress_tick
```

They must not share target namespaces or arbitration policies.

## Implementation order

### Phase 1 — doorway protocol

- Add edge coordination records.
- Add lease lifecycle and offset waiting.
- Add directional wait load to route scoring.
- Add topology invalidation.
- Add telemetry and deterministic tests.
- Measure `hubA_near_edge`, `hubB_center`, and `mirror_polygon`.

### Phase 2 — assault pair

- Add the player primer.
- Change only `spitter` projectile contact.
- Add role-specific consumption impulse.
- Add render and audio tells.
- Run combat-canon and portal-crossing tests.

### Phase 3 — retreat report

- Add readiness transition on integrity threshold.
- Validate away-crossing from the last sighted chamber.
- Write existing fields once.
- Add a field-isolation test proving no remote effect.

### Phase 4 — garrison posts

- Derive posts from current geometry.
- Add local bidding, expiry, and traffic aging.
- Reuse existing garrison settlement and stand-down.

### Phase 5 — ranged packages

- Add visible counts.
- Gate existing firing functions.
- Add physical resupply at already meaningful locations.
- Verify that reserve accounting is untouched.

## Performance requirements

Implementation must use `perf_test.py` before and after every phase.

The adopted rules are bounded:

- doorway work scales with active approach agents, not all agents;
- post bidding runs only for settlers in their own chamber;
- primer work is one player status check;
- retreat reporting runs only on actual crossings;
- package counts are constant-size per-agent state.

No phase may add a deeper visibility query, a per-agent graph search, or a
full-world scan.

Required performance reports:

```text
python perf_test.py --name "doorway_protocol"
python perf_test.py --name "primer_impact"
python perf_test.py --name "retreat_report"
python perf_test.py --name "garrison_posts"
python perf_test.py --name "ranged_packages"
```

Judge p90 and maximum time first. Average improvement does not excuse a new
stutter at a long sightline, the large hub, or the self-connecting polygon.

## Global acceptance

- Existing replays without a triggering event remain deterministic.
- Every cooperative effect has a physical precursor and visible resolution.
- Killing or displacing the relevant role breaks the cooperation.
- No rule reads player integrity to make an enemy decision.
- No rule changes reserve regeneration, dispatch cost, or strike composition.
- No rule adds a tenth chamber field.
- No new class is required.
- No effect crosses a sealed connection.
- Player knockback remains useful against every adopted attack.
- All new state appears in telemetry.
- Automated tests cover topology changes, shutdown, portal crossing, and
  replay equality.

## Research trace

The source measurements, confidence grades, competing explanations, and
rejected generalizations remain in:

- `docs/PRIMARY_COLLECTIVE_SYSTEMS_RESEARCH_20260728.md`
- `docs/PRIMARY_COORDINATED_ATTACK_RESEARCH_20260728.md`
- `docs/FINAL_MECHANICS_RESEARCH_20260728.md`

This document is the integration decision. When it conflicts with an earlier
candidate list, this document wins.
