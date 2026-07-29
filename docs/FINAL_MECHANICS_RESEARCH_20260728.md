# Final mechanics research — coordination additions

Date: 2026-07-28

Integration status: this research shortlist has now been reconciled against
the shipped combat and coordination systems. The implementation-facing
decision is `docs/INTEGRATED_COMBAT_MECHANICS_20260728.md`; where the two
documents differ, the integration document wins.

## Decision

Add nine mechanics, in the order below. The first three form one coherent
vertical slice: local congestion becomes visible, agents react to it, and the
player can manipulate it. The remaining six deepen tactical and territorial play without
granting any actor global knowledge.

Do not add a learned controller, a global tactical director, dynamic class
substitution at the reserve, or another scalar field. The current rules already
have enough state. The missing layer is better local use of that state.

## 1. Directed congestion marks

Each doorway keeps a short-lived congestion score for each direction.

An agent adds to the score when any of these occur:

- it waits near the doorway without crossing;
- it reverses after approaching;
- contact or obstruction prevents forward progress;
- another agent crosses the same doorway in the opposite direction.

The score fades quickly, with a first-pass half-life of 4 seconds. It is not a
new chamber field and does not spread. It extends the existing directed
doorway-mark storage.

Route choice samples the two best legal exits and chooses the one with lower
predicted completion time:

`route cost = hop cost + congestion score + estimated crossing delay`

Agents already assigned to a close target keep their route until congestion
crosses a high threshold. This prevents oscillation. A reroute is permitted
once per 3 seconds and only while the agent is outside the doorway approach
zone.

Player consequence: sustained fire into one entrance gradually diverts part of
the push to another route. Short bursts do not. A player can intentionally
shape the approach fan, but cannot switch the entire force instantly.

Why this is first: production deployments show that simple endpoint congestion
signals can reduce load imbalance and dropped work without a global map.
Selecting by estimated delay and requests already in flight also outperforms
balancing a raw count.

Acceptance gates:

- a blocked doorway receives less traffic within 8 seconds when another route
  exists;
- a single obstruction shorter than 1 second causes no reroute;
- agents do not alternate exits more than once in 3 seconds;
- a one-exit chamber behaves exactly as it does now;
- the player can create a measurable 60:40 or stronger route split by holding
  one approach under continuous pressure.

## 2. Doorway admission leases

Every narrow doorway exposes a small number of approach slots derived from
usable width. An agent entering the approach zone claims one slot for at most
1.25 seconds. Only slot holders aim directly through the opening. Other agents
hold offset positions, continue fighting, or evaluate another route.

The lease is local to the doorway. It is released on crossing, retreat,
shutdown, or expiry. No agent queries a chamber beyond the doorway and no
central owner assigns slots.

Large agents consume two slots. Small agents consume one. This makes mixed
groups sort themselves without class-specific entry scripts. It also makes a
large blocker visibly delay the agents behind it.

Player consequence: knockback against the current slot holder creates a brief
opening in the schedule. Repeatedly disrupting the front agent suppresses
throughput, while uncontrolled fire into the waiting group does not magically
clear the opening.

Acceptance gates:

- no more slot demand is active than the doorway width permits;
- expired leases are reclaimed within one simulation tick;
- mixed groups cross faster than the current unregulated pile-up baseline;
- the p90 crossing delay improves without increasing the maximum stationary
  queue duration;
- wide halls remain visually loose rather than forming artificial files.

## 3. Congestion-triggered path rotation

When an agent experiences a high directed congestion score for 2 continuous
seconds, it performs one randomized alternate-route probe. It considers only
legal exits visible in its current chamber, excludes the congested edge, and
uses its normal one-hop observations. If no alternate exit exists, it remains
committed.

This is intentionally asymmetric:

- short and lightly loaded movements retain stable routes;
- long pushes rotate only after demonstrated congestion;
- rotation happens during an idle movement beat, never during an attack;
- each agent receives a stable per-instance probe offset so a whole group does
  not reroute on the same tick.

Player consequence: an overbuilt firing lane causes some pressure to migrate
elsewhere. The migration is delayed and visibly preceded by a queue, giving
the player time to read what happened.

This follows deployed network practice: rotate only flows that have actually
experienced congestion, prefer idle transition points, and add distributed
jitter so reroutes do not synchronize.

Acceptance gates:

- an uncongested replay is bit-identical with this rule present;
- a congested two-route replay produces fewer long stalls and no synchronized
  route flip;
- reroutes occur only after locally observed congestion;
- removing the alternate route at runtime leaves no stale route commitment.

## 4. Expiring task claims with priority aging

Local group tasks—hold this doorway, inspect this chamber, carry this item, or
join this push—gain a claim record:

`task, claimant, claim tick, expiry tick, bid`

An agent bids using only travel estimate, current role fit, and current
commitment. Nearby peers resolve conflicts by retaining the lowest bid. Claims
expire after 4 seconds unless refreshed by visible progress.

An unclaimed task gains priority with time. After 8 seconds its effective bid
drops enough that an idle agent will take it even if the route is not ideal.
This prevents neglected perimeter and cleanup work without fixed assignments.

Claims are observations, not commands. The claimed task remains interruptible
by direct contact, danger holding, or loss of a legal route.

Player consequence: removing the current claimant creates a short,
understandable reassignment delay. Repeatedly interrupting replacements can
starve a task. The opponent appears coordinated but not telepathic.

Acceptance gates:

- two nearby agents never retain the same exclusive claim for more than one
  coordination step;
- a claimant that makes no progress loses the claim in 4 seconds;
- an eligible task remains unclaimed for no more than 8 seconds when an idle
  agent is locally available;
- distant agents never learn the claim;
- graph disconnection invalidates the claim immediately.

## 5. Perimeter debt and local work stealing

Every held doorway accumulates perimeter debt while it has no settled watcher.
Debt rises faster for:

- a doorway that recently carried hostile traffic;
- a doorway leading toward unsettled ground;
- a doorway whose watcher was recently removed.

Idle settled agents compare only doorways in their current chamber and one hop
away. They move toward the highest debt if it exceeds their current post by a
fixed margin. The margin supplies hysteresis; agents do not shuffle posts over
small differences.

This is work stealing rather than command. An unattended task advertises need;
an idle worker claims it. Existing local fields still determine whether the
ground is safe enough to settle.

Player consequence: repeatedly testing one edge pulls watchers toward it and
can thin a different edge. A false probe becomes a tactical tool, while a
full assault still receives the strongest local response.

Acceptance gates:

- a held region with enough agents covers all entrances after a bounded quiet
  period;
- a traffic burst moves at least one watcher toward the tested edge;
- the same watcher does not change posts twice within 6 seconds;
- a region with too few agents leaves a deterministic, debt-ranked gap rather
  than jittering between all gaps;
- no debt value crosses a sealed connection.

## 6. Physical incident records and bounded counter packages

Important combat events may create a small record item naming only:

- the chamber;
- event category;
- equipment category responsible;
- creation tick.

A non-combat courier may carry one record to the remote reserve area. The
record can be dropped, recovered, or destroyed in transit. The reserve area
does not read chamber fields, player state, or global counters.

Every four delivered records, the fixed 20-slot dispatch cycle may replace one
ordinary slot with a bounded counter slot chosen from the dominant recorded
equipment category. The replacement never changes total dispatch cost by more
than 2 and expires after one cycle. The ordinary cycle then resumes unless
more records arrive.

This is not continuous adaptation. It is delayed, lossy, physically
interruptible bookkeeping. It keeps the reserve structurally blind while
allowing the player to observe and prevent information delivery.

Player consequence: repetitive play eventually produces one limited answer,
but only if the record reaches the reserve area. Switching equipment before
delivery, intercepting the courier, or deliberately supplying misleading
records are valid counters.

Acceptance gates:

- no delivered record means no composition change;
- destroying the carrier destroys or drops the record according to one
  consistent rule;
- one record cannot affect more than one dispatch-cycle slot;
- the modified cycle stays inside the cost-skew bound;
- the same input and record-delivery history remains deterministic;
- no reserve-side function accepts player state or chamber-field values.

## 7. Targeted retreat inhibition

An agent that takes damage and then successfully leaves contact receives one
location-bound suppression token. It may deliver that token only through
physical contact with peers in its current chamber or one doorway away.

Recipients reduce commitment toward the named chamber for 8 seconds. Direct
sight overrides suppression. The token expires after 12 seconds and may cross
no more than two handoffs.

This is targeted negative feedback, not general fear. It gives the player a
choice: finish a damaged agent, or let it escape and briefly suppress its own
side’s push.

Acceptance gates:

- damage without disengagement creates no token;
- a token never affects commitment toward a different chamber;
- direct sight overrides suppression immediately;
- two handoffs are possible and a third is rejected;
- inflow toward the named chamber falls measurably during the suppression
  window without changing remote dispatch.

## 8. Specific decoy habituation

Each scout stores a small false-alarm score per signal category. Responding to
a signal without later gaining sight or taking damage increments only that
category’s score. High score raises that category’s response threshold.

Quiet fades the score to zero over 60–90 seconds. Sight and damage never lose
authority. State is private to the scout unless transferred by an explicit
physical record or station dwell.

This lets decoys work without remaining infinitely repeatable.

Acceptance gates:

- repeated false alarms in one category delay later responses to that category;
- another category retains its original response latency;
- a real sighting bypasses habituation;
- baseline sensitivity returns after the quiet recovery window;
- nearby agents do not copy the state merely by proximity.

## 9. Geometry-driven fortification

Settled builders choose work sites from doorway lips, corners, damaged
barriers, and locations where work is already active. Active work attracts at
most two nearby helpers. Quiet conditions extend cover; repeated crossing
pressure biases work toward narrowing or sealing one side.

There is no hidden construction message and no global blueprint. Existing
geometry is the durable shared record. Every placed piece remains ordinary
collision geometry and can be removed.

Acceptance gates:

- rotating or changing the local geometry changes selected work sites;
- removing the active builder stops helper recruitment;
- no work begins without a locally observable geometric cue;
- quiet and high-traffic conditions produce visibly different structures from
  the same initial chamber;
- construction cannot create an opening the player is unable to traverse or
  clear.

## Suggested implementation sequence

1. Directed congestion marks.
2. Doorway admission leases.
3. Congestion-triggered path rotation.
4. Targeted retreat inhibition.
5. Expiring task claims.
6. Specific decoy habituation.
7. Perimeter debt.
8. Physical incident records.
9. Geometry-driven fortification.

The first three should land behind one acceptance program and be tuned
together. Their success criterion is not average throughput alone. Measure p90
and maximum queue delay, route-flip count, time motionless near a doorway, and
the fraction of agents that reach contact.

Task claims and perimeter debt should share one generic local-task claim structure. Do not build
separate ownership systems for posts, inspection, carrying, and group pushes.

Incident records should wait until at least two equipment categories produce
meaningfully different player tactics. Otherwise its records have nothing
useful to distinguish.

Geometry-driven fortification should begin as a one-chamber prototype using
ordinary collision geometry. Do not create a full builder class until the
local placement rule is readable and tactically useful.

## Explicit cuts

- No global planner or omniscient task board.
- No reinforcement decision based directly on player integrity, position, or
  damage totals.
- No learned policy in the runtime simulation.
- No per-class handcrafted doorway script.
- No dynamic replacement of an unaffordable dispatch slot.
- No additional chamber-wide scalar field.
- No instant counter selection after an event.
- No hidden difficulty scaling.

## Research basis

- Abdul Kabbani et al., “PLB: Congestion Signals are Simple and Effective for
  Network Load Balancing,” SIGCOMM 2022. A deployed system rotates only
  congestion-exposed paths, prefers idle transition points, and reduced median
  utilization imbalance by 60 percent and packet drops by 33 percent:
  https://research.google/pubs/plb-congestion-signals-are-simple-and-effective-for-network-load-balancing/

- Bartek Wydrowski et al., “Load is not what you should balance: Introducing
  Prequal,” 2024. Asynchronous reusable probes choose using predicted latency
  and requests in flight rather than raw processor load:
  https://research.google/pubs/load-is-not-what-you-should-balance-introducing-prequal/

- Juntao Gao et al., “Multi-Agent Q-Learning Aided Backpressure Routing
  Algorithm for Delay Reduction,” 2017. Local neighboring congestion estimates
  retained distributed operation while reducing average delay against the
  compared backpressure method:
  https://arxiv.org/abs/1708.06926

- Han-Lim Choi, Luc Brunet, and Jonathan How, “Consensus-Based Decentralized
  Auctions for Robust Task Allocation,” IEEE Transactions on Robotics 2009.
  Local bids plus consensus converge to conflict-free assignments and tolerate
  inconsistent local awareness and changing communication topology:
  https://doi.org/10.1109/TRO.2009.2022423

- Payam Ghassemi, David DePauw, and Souma Chowdhury, “Decentralized Dynamic
  Task Allocation in Multi-Robot Systems for Disaster Response,” 2019.
  Asynchronous allocation accounts for deadlines, range, and limited worker
  capacity:
  https://arxiv.org/abs/1907.04394

- Aakriti Agrawal et al., “DC-MRTA: Decentralized Multi-Robot Task Allocation
  and Navigation in Complex Environments,” 2022. Feeding navigation delay back
  into task choice improved completion time and collision-free routing over
  myopic distance selection:
  https://arxiv.org/abs/2209.02865

- Allen Liu et al., “Distributed Load Balancing: A New Framework and Improved
  Guarantees,” ITCS 2021. Multiplicative local price updates provide
  near-optimal balancing for general convex load costs in polylogarithmic
  rounds:
  https://research.google/pubs/distributed-load-balancing-a-new-framework-and-improved-guarantees/

## Final priority

If only one addition ships, ship directed congestion marks.

If one complete feature set ships, ship directed congestion marks, doorway
admission leases, and congestion-triggered path rotation together.

After that, targeted retreat inhibition has the strongest direct evidence and
the clearest new combat choice. If territorial play still lacks manipulation,
add perimeter debt before incident records. Perimeter debt creates immediate
spatial tactics; incident records mainly add long-horizon variation.

The deeper primary-source audit, including conflicting results and rejected
mechanisms, is recorded in `docs/PRIMARY_COLLECTIVE_SYSTEMS_RESEARCH_20260728.md`.
