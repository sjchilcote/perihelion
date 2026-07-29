# Primary collective-systems research appendix

Date: 2026-07-28

## Scope and method

This appendix examines source systems that solve navigation, allocation,
consensus, construction, and congestion problems without a central planner.
Only experiments and formal models reported by their original authors are used
as evidence. Reviews were used to locate papers, never as the basis for a
mechanical claim.

The translation rule is strict:

- source-domain names are replaced by neutral system descriptions;
- a measured result is separated from the proposed game rule;
- a single demonstration is never presented as a universal law;
- failed replications and competing explanations are retained;
- mathematical models are distinguished from physical experiments;
- source URLs and identifiers remain unchanged for provenance.

Twenty-one primary studies were inspected across five research lanes:

1. adaptive transport networks and external trace memory;
2. route traffic, encounter-rate control, and local trail decisions;
3. quorum decisions, cross-inhibition, and noisy vector messages;
4. shared-environment construction;
5. learning, recovery, transfer, and context-dependent choice.

## Executive findings

The strongest cross-lane principles are:

1. **Overbuild, measure use, then prune.** Efficient networks emerge by
   reinforcing high-flow links and withdrawing low-flow links. The result is
   not the shortest network alone; it balances travel cost, material cost, and
   alternate-route tolerance.
2. **External traces are useful when they describe action history.** A trace
   saying “already searched,” “recently crossed,” or “work happened here” can
   coordinate later action without identifying who wrote it.
3. **Congestion is best regulated before entry.** High-density transport can
   preserve throughput when arrivals slow before entering, avoid reversals
   after commitment, and reduce expensive pairwise interactions.
4. **Positive feedback needs a distinct brake.** Recruitment alone creates
   lock-in and deadlock. Targeted inhibition, expiring advertisements, or
   declining message strength lets a collective abandon bad options.
5. **Quorum should be measured locally and should trigger a mode switch.**
   Encounter rate can estimate local support without a census. After the
   switch, repeatedly checking the quorum wastes time and destabilizes action.
6. **Repeated harmless input should lose authority, but specifically and
   reversibly.** Repeated exposure can reduce response to one nuisance while
   leaving responses to a different nuisance intact; the response returns
   after a quiet interval.
7. **Shared structures are durable coordination memory.** Construction can be
   driven by active work, surface shape, and evaporation gradients without a
   dedicated message layer.
8. **Choice quality depends on context and urgency.** Distributed decisions
   show speed-versus-accuracy tradeoffs and can change preference when an
   irrelevant third option appears. A game rule should not assume perfect,
   stable utility rankings.

## Lane A — adaptive networks and external trace memory

### A1. Flow-weighted reinforcement produces efficient, fault-tolerant routes

Tero et al. 2010 placed demand points in a spatial pattern corresponding to a
large rail region and measured the network that connected them. They also
defined a model in which link conductivity rises with flow and falls without
flow. The generated networks were evaluated on material cost, transport
efficiency, and tolerance to link removal rather than on path length alone.

The important result is multi-objective: retaining some alternate links costs
more material than a minimum tree but improves failure tolerance. Changing the
reinforcement response shifts the solution along that tradeoff.

Evidence strength: high for the demonstrated source system and strong as a
network-design model; moderate for transfer into moment-to-moment game AI.

Source: Tero et al. 2010, DOI 10.1126/science.1177894,
https://pubmed.ncbi.nlm.nih.gov/20093467/

Game translation:

- every directed doorway already has enough identity to hold a use estimate;
- crossings reinforce a preferred-route value;
- unused values fade;
- a route is not removed from consideration merely because it is second-best;
- under disruption, an alternate route that retained some use history becomes
  available faster than a wholly unexplored route.

Do not copy the continuous flow equation into runtime AI. Use the qualitative
law and tune it against route diversity and queue delay.

### A2. “Already searched” residue enables obstacle escape

Reid et al. 2012 tested navigation around a U-shaped obstacle. The source system
left a persistent traversal residue and avoided regions carrying it. On a
clean surface, it could distinguish its prior search area and escape the trap.
When the whole test surface was pre-coated, performance became much slower and
less reliable. The key manipulation was environmental: changing the trace
substrate changed navigation while the obstacle and goal stayed fixed.

Evidence strength: high for external trace avoidance in this task; unknown for
how well the rule scales to rapidly changing multi-actor spaces.

Source: Reid et al. 2012, DOI 10.1073/pnas.1215037109,
https://pmc.ncbi.nlm.nih.gov/articles/PMC3491460/

Game translation:

- add a short history of recently inspected dead ends to each scout;
- optionally write it to the existing directed doorway storage so peers can
  avoid repeating the same inspection;
- the player’s signal scrubber may flatten this history, causing repeated
  searches rather than simply making the area quiet;
- never treat the trace as proof that a route remains empty.

This is a search-coverage tool, not a combat pursuit tool.

### A3. Network growth alternates exploration and consolidation

Direct network observations consistently describe an early surplus of links
followed by selective reinforcement and withdrawal. A 2021 surface and
network-joining experiment additionally showed that environmental conditions and
connection count alter path efficiency and drag; the network continues to
adapt while expanding rather than solving a fixed graph once.

Evidence strength: moderate. The expansion-pruning pattern is well supported,
but exact outcomes depend strongly on substrate and setup.

Source: Patino-Ramirez et al. 2021, DOI 10.1038/s41598-020-80320-2,
https://pmc.ncbi.nlm.nih.gov/articles/PMC7810851/

Game translation:

- a newly alerted group should initially fan across several legal approaches;
- after contact establishes which approaches deliver agents, traffic should
  consolidate;
- when the player blocks the main route, retained weak alternatives should
  regrow in use rather than being rediscovered from zero.

This supports directed congestion marks plus route hysteresis. It does not
support a global path optimizer.

## Lane B — local traffic and dispatch control

### B1. High-density traffic can plateau without collapsing

Poissonnier et al. 2019 ran 170 bridge experiments across three widths and
large variations in source-group size, producing 612,000 flow-density pairs.
Below roughly 8 agents per square centimetre, flow rose with density. Above
that point, flow remained near a plateau instead of collapsing into a jam.
Observed density did not exceed roughly 18 per square centimetre.

Tracked agents slowed with density, avoided entering crowded bridges, almost
never reversed after entry, and reduced time-consuming interactions. The
reported reversal probability was about 0.01; each contact imposed about
0.24 seconds of crossing cost.

Evidence strength: high, with extensive physical trials and released data.

Source: Poissonnier et al. 2019, DOI 10.7554/eLife.48945,
https://pmc.ncbi.nlm.nih.gov/articles/PMC6805160/

Game translation:

- admission leases should regulate entry rather than motion halfway through a
  doorway;
- committed crossers should strongly resist reversing;
- waiting agents should spread along the approach instead of increasing
  contact density indefinitely;
- throughput should plateau at high demand, not collapse or grow without
  bound.

This directly strengthens recommendations 1–3 in the final mechanics list.

### B2. Return encounters regulate outgoing work

Pinter-Wollman et al. 2013–2015 tracked entrance-chamber interactions and
manipulated returning traffic. Outgoing workers experienced higher interaction
rates than agents that returned deeper into the home site. One reported mean
was 1.47 versus 0.83 interactions per second. Observed timing correlations were
far more frequent than randomized controls, supporting a local encounter-rate
controller rather than a global demand estimate.

Evidence strength: high for local interaction-rate regulation in the measured
system; moderate for exact timing causality across all tested groups.

Source: Pinter-Wollman et al. 2015, DOI 10.1371/journal.pone.0141971,
https://pmc.ncbi.nlm.nih.gov/articles/PMC4635008/

Game translation:

- a local station may release another patrol only after enough returning
  traffic has crossed its chamber;
- lack of returns should not immediately imply failure; it should reduce the
  release rate after a short observation window;
- the remote reserve should remain blind to this local controller.

Do not add this to the central dispatch economy. It belongs only to settled
local groups if they gain a patrol-release mechanic.

### B3. Negative route markers are not a universal law

An older line of work reported a localized “do not enter” marker near a route
split. However, a 2025 bridge-swap experiment on hazardous-route abandonment moved
the physical bridge independently of its map location. Avoidance followed the
remembered location rather than the moved bridge. The authors also report that
the original negative-marker result has not generalized broadly and that at
least one direct replication found no evidence for it.

Evidence strength: high as a warning against generalization. It does not erase
the original result in its original system.

Source: Zanola et al. 2025, DOI 10.1038/s42003-025-07818-1,
https://pmc.ncbi.nlm.nih.gov/articles/PMC11933468/

Game translation:

- do not add a universal negative route field justified by this literature;
- use directly observed congestion, remembered failed approaches, and durable
  map events instead;
- if a negative mark exists, make it class-specific and testable rather than
  granting every agent the same response.

This changes the earlier research direction: the final design should prefer
directed congestion marks over a generic avoidance trail.

### B4. Positive trails can create symmetry breaking

When two equal demand sites are offered, positive feedback can concentrate
traffic onto one. I’Anson Price et al. 2016 found that symmetry breaking weakened
as equal-site resource quality increased: rich equal sites produced a more
even split, while poor equal sites produced stronger winner-take-all behavior.

Evidence strength: moderate-high for the tested system; mechanism attribution
rests on the known trail feedback loop plus the experimental quality
manipulation.

Source: I’Anson Price et al. 2016, DOI 10.1007/s00265-016-2187-y,
https://pmc.ncbi.nlm.nih.gov/articles/PMC5054046/

Game translation:

- when several routes all deliver successful contact, reinforce them more
  evenly;
- when all routes perform poorly, allow one route to win temporarily rather
  than diffusing weak pressure everywhere;
- do not force equal route splitting under every condition.

## Lane C — quorum, inhibition, and noisy messages

### C1. Encounter rate can be a quorum sensor

Pratt 2005 manipulated crowding and direct contact at candidate sites. Blocking
contact made a crowded site behave like an empty one. Increasing encounter
rate by shrinking the site triggered the transport mode at a lower absolute
population. The switch tracked encounter rate rather than population count.
After switching, agents stopped monitoring the quorum and shortened their
visits by roughly 2 minutes.

Evidence strength: high for the tested relocation task.

Source: Pratt 2005, DOI 10.1093/beheco/ari020,
https://doi.org/10.1093/beheco/ari020

Game translation:

- keep the existing fractional local quorum;
- once a group commits, stop re-evaluating the same quorum every tick;
- release commitment only through a separate quiet-time or contradiction rule;
- crowding without contact must not count as agreement.

This confirms the shipped architecture and suggests auditing for unnecessary
post-commit quorum reads.

### C2. Quorum can average a fluctuating option over time

Franks et al. 2015 offered one stable medium-quality site and one site
alternating between good and poor states. Choice probability followed the
fraction of time the fluctuating site was good: approximately 0.809 when good
75 percent of the time, 0.484 at an even split, and 0.327 when good 25 percent
of the time. The result indicates temporal integration through repeated local
assessments rather than a snapshot decision.

Evidence strength: high for the experiment; moderate for the specific proposed
averaging mechanism.

Source: Franks et al. 2015, DOI 10.1038/srep11890,
https://www.nature.com/articles/srep11890

Game translation:

- garrison-site evaluation should integrate several seconds of local safety
  rather than sample one tick;
- fluctuating danger near a threshold should yield intermediate commitment,
  not deterministic chatter;
- the integration window should be visible in telemetry.

### C3. Targeted inhibition counters positive recruitment

Nieh 2010 directly manipulated aggressive encounters at a resource site.
Agents that received attacks increased inhibitory signals about 43-fold and
preferentially targeted peers associated with the same location. Simulated
bites and alarm exposure produced roughly 88-fold and 14-fold increases.
Agents that attacked others without receiving aggression did not show the same
increase. The signal reduces ongoing recruitment.

Evidence strength: high for a targeted negative-feedback channel, with direct
manipulation and multiple triggers.

Source: Nieh 2010, DOI 10.1016/j.cub.2009.12.060,
https://escholarship.org/uc/item/8b6292qp

A later primary experiment found that inhibitory signal frequency and duration
varied with threat severity and context, though some alternative cues could
not be fully excluded.

Source: Tan et al. 2016, DOI 10.1371/journal.pbio.1002423,
https://pmc.ncbi.nlm.nih.gov/articles/PMC4807812/

Game translation:

- a damaged agent that successfully disengages may carry one targeted
  suppression token naming the chamber it left;
- delivering that token to nearby reinforcements temporarily reduces
  commitment to that chamber;
- the player can prevent suppression by disabling the carrier, or deliberately
  allow it to escape to redirect pressure;
- inhibition must name one location and must expire.

This is a strong candidate for addition after congestion routing. It creates a
new “damage and release” tactic that ordinary danger fields do not.

### C4. Message repetition supports averaging, not perfect precision

Repeated-vector measurements show substantial variation within one repeated
message. Middle repetitions were more stable than the first and last.
Recruit-flight directions were narrower than individual message directions and
fit multi-repetition averaging better than single-message rules.

Evidence strength: high that receivers integrate repeated noisy vectors;
weak against claims that noise itself is always adaptive.

Sources:

- Couvillon et al. 2012, DOI 10.1242/bio.20121099,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC3507209/
- Tanner and Visscher 2008, DOI 10.1007/s00265-008-0619-z,
  https://doi.org/10.1007/s00265-008-0619-z

Game translation:

- a completed call should average several position samples gathered during the
  stationary broadcast;
- early interruption yields no call;
- late interruption may yield a lower-confidence position rather than a
  perfectly precise position;
- do not add random error merely because noise exists in the source system.

This refines the current all-or-nothing broadcast rule. It should be tested as
an optional replacement, not stacked on top.

### C5. Site value changes message persistence

Seeley and Visscher 2008 offered high- and medium-value sites. Scouts inspected
both for similar durations but produced more advertisement circuits for the
higher-value site. Value changed persistence of broadcast rather than the
measurement procedure itself.

Evidence strength: high for value-coded advertisement persistence.

Source: Seeley and Visscher 2008, DOI 10.1242/jeb.021071,
https://citeseerx.ist.psu.edu/document?doi=78641967b12584154f46c3c25b1b2d8576849db7&repid=rep1&type=pdf

Game translation:

- caller broadcast duration may encode confidence in site safety;
- a marginal site receives a short, fragile attempt;
- a repeatedly verified quiet site receives a longer and more persistent
  attempt;
- the reserve remains free to ignore either call.

## Lane D — construction through shared state

### D1. Active excavation can organize construction

Green et al. 2017 tracked individual work in new construction arenas. Work
concentrated at a small number of excavation sites, and those sites became
templates for deposition. The probability of joining increased with the number
already working. Statistical analysis separated aggregation around active work
from a putative material-borne message. Agent simulations supported the active
excavation interpretation.

Evidence strength: high for early-stage construction in two tested systems.

Source: Green et al. 2017, DOI 10.1098/rspb.2016.2730,
https://pmc.ncbi.nlm.nih.gov/articles/PMC5474063/

Game translation:

- builders should join visible active work rather than read a hidden build
  order;
- removing the active builder interrupts recruitment even if the unfinished
  structure remains;
- completed geometry then becomes the durable cue for later work.

### D2. Surface curvature predicts work location

Calovi et al. 2019 placed workers on printed surfaces whose curvature,
inclination, and height could be varied independently by rotating the same
surface. Construction-material displacement correlated consistently with surface curvature, not
height or inclination. Exploration showed a weaker relationship in the same
direction.

Evidence strength: high for the controlled surface experiment.

Source: Calovi et al. 2019, DOI 10.1098/rstb.2018.0374,
https://pmc.ncbi.nlm.nih.gov/articles/PMC6553597/

Game translation:

- fortification should attach to corners, damaged edges, and opening lips
  already present in geometry;
- builders need no global blueprint;
- adding or removing geometry changes later work locations automatically.

### D3. Evaporation gradients can provide the local blueprint

Facchini et al. 2024 supplied clean, unmarked construction material and
prebuilt pillars or walls, tracked collection and deposition separately, and
mapped evaporation on matching structures. Construction still occurred
without prior material marks. Deposition concentrated where curvature focused
evaporation; the same rule could extend in still air and seal under
disturbance.

Evidence strength: high for the tested physical cues; the authors explicitly
avoid claiming one cue explains every construction scale.

Source: Facchini et al. 2024, DOI 10.7554/eLife.86843,
https://pmc.ncbi.nlm.nih.gov/articles/PMC11006414/

Game translation:

- a garrison fortification rule can read geometry, recent airflow-like portal
  traffic, and existing damage;
- the same local rule may extend cover in quiet and seal a narrow opening under
  repeated disturbance;
- do not invent a construction-only scalar field.

This is the strongest basis for a new fortification mechanic.

## Lane E — learning, recovery, and context effects

### E1. Repeated harmless obstacles lose authority

Boisseau et al. 2016 repeatedly exposed a distributed crawler to one harmless
deterrent over several days. Crossing became faster by day 5. After 2 days
without exposure, the initial aversion returned. Training on one deterrent did
not remove aversion to a different deterrent, which argues against simple
general slowdown or total input shutdown.

Evidence strength: high for stimulus-specific, reversible habituation in the
tested setup.

Source: Boisseau et al. 2016, DOI 10.1098/rspb.2016.0446,
https://pmc.ncbi.nlm.nih.gov/articles/PMC4855389/

Game translation:

- each scout tracks repeated low-consequence false alarms by category;
- repeated noise with no sighting gradually raises that scout’s response
  threshold;
- direct sight, damage, or a different signal category bypasses the learned
  suppression;
- 60–90 seconds of quiet restores baseline sensitivity;
- learning remains per-agent unless a separate physical transfer occurs.

This is a high-value anti-decoy mechanic because it is specific, reversible,
and legible through delayed response.

### E2. Learned suppression can transfer, but only through prolonged fusion

Vogel and Dussutour 2016 joined trained and untrained source units. A combined
unit containing a trained minority showed the trained response, but transfer
required a minimum duration of connection. The experiment demonstrates state
sharing through actual material continuity; it does not establish broadcast
learning between separate actors.

Evidence strength: high for the physical combination setup, poor as support for
ordinary peer-to-peer communication.

Source: Vogel and Dussutour 2016, DOI 10.1098/rspb.2016.2382,
https://pmc.ncbi.nlm.nih.gov/articles/PMC5204175/

Game translation:

- do not let nearby agents copy habituation automatically;
- transfer is justified only through explicit docking, a carried record, or a
  shared station with dwell time;
- a brief encounter must not synchronize learned state.

This supports physical incident records and argues against instant shared
adaptation.

### E3. Time pressure changes the speed-versus-accuracy policy

Latty and Beekman 2011 varied task difficulty, resource pressure, and light stress in a
three-option discrimination task. Under difficult choices, stressed units made
faster decisions than unstressed units. Under easy choices, the direction
reversed. The result is not a universal “stress means faster” law; urgency
interacts with choice difficulty.

Evidence strength: high for the experiment and high as a warning against a
single monotone urgency modifier.

Source: Latty and Beekman 2011, DOI 10.1098/rspb.2010.1624,
https://pmc.ncbi.nlm.nih.gov/articles/PMC3025689/

Game translation:

- when only one legal route exists, urgency should not add random delay;
- when several similar routes exist, urgency may force an earlier, less
  informed commitment;
- telemetry must record option count, urgency, decision latency, and outcome.

### E4. Preference can change when an inferior third option appears

Latty and Beekman 2011 found transitive pairwise ranking but a violation of
independence from irrelevant alternatives: adding an inferior third option
increased preference for one focal option.

Evidence strength: high for the specific choice design; not evidence that every
distributed system uses the same comparison rule.

Source: Latty and Beekman 2011, DOI 10.1098/rspb.2010.1045,
https://pmc.ncbi.nlm.nih.gov/articles/PMC3013386/

Game translation:

- local route scoring may be comparative rather than absolute;
- adding a bad escape route can make the best remaining route more dominant;
- tests should include three-route chambers, not only binary choices.

This is primarily a verification lesson. It is not worth a standalone mechanic.

## Replication and confidence table

| Finding | Direct evidence | Generality | Design confidence |
|---|---:|---:|---:|
| Flow reinforcement plus low-use withdrawal | Multiple experiments and a fitted model | Medium | High |
| External searched-area trace | One strong obstacle experiment | Low–medium | Medium |
| Entry-side congestion regulation | 170 trials, released data | Medium | High |
| Encounter-rate dispatch | Multiple observation/manipulation studies | Medium | High for local patrols |
| Universal negative route marker | Conflicting results | Low | Reject |
| Local fractional quorum | Multiple source systems and models | High | Already shipped |
| Targeted inhibitory message | Direct manipulation plus later extension | Medium | High |
| Noisy-vector averaging | Multiple message measurements | Medium | High |
| Active-work construction recruitment | Direct tracking plus simulation | Medium | High |
| Curvature/evaporation construction cue | Several controlled experiments | Medium | High |
| Stimulus-specific habituation | Controlled repeated-exposure experiment | Unknown outside source system | Medium-high |
| State transfer through physical joining | One strong experimental program | Low | Medium only with physical carrier |
| Context-dependent speed/accuracy | Controlled experiment | Medium as a principle | Medium |

## Changes to the final mechanics list

The primary-source pass changes the shortlist as follows.

### Promote: targeted retreat inhibition

Add after congestion routing and before incident records.

Rule:

- an agent that takes damage and then leaves contact receives one
  location-bound suppression token;
- it may deliver the token only through physical contact with peers in its
  current or adjacent chamber;
- recipients reduce commitment toward the named chamber for 8 seconds;
- direct sight overrides suppression;
- the token expires after 12 seconds and cannot cross more than two handoffs.

Why: this creates a player choice between finishing a damaged agent and
allowing it to suppress its own side’s push. The source evidence is direct,
quantified, targeted, and explicitly negative feedback against recruitment.

### Promote: specific decoy habituation

Add after expiring task claims.

Rule:

- each scout stores a small per-category false-alarm score;
- hearing a signal without later gaining sight or taking damage increments the
  score;
- high score raises only that category’s response threshold;
- quiet fades the score to zero in 60–90 seconds;
- sight and damage never habituate.

Why: the player can use decoys, but repetition becomes less effective without
granting the opposition global learning or arbitrary stat scaling.

### Add to the later backlog: geometry-driven fortification

Rule:

- settled builders choose work sites from doorway lips, corners, damaged
  barriers, and active excavation;
- active work attracts at most two nearby helpers;
- quiet conditions extend cover;
- repeated crossing pressure biases work toward narrowing or sealing one side;
- all placed material remains ordinary collision geometry and can be removed.

Why: the evidence for physical cues is stronger than the classic hidden-marker
story, and the result would make held ground visibly change.

### Refine: calls should integrate repeated position samples

Do not add arbitrary aim error. Instead:

- sample the caller’s position throughout the stationary broadcast;
- a full broadcast uses the mean of the stable middle samples;
- an early interruption yields nothing;
- a late interruption may yield a lower-confidence position derived from the
  samples already sent;
- confidence affects site-selection radius, not reserve policy.

This should replace the current all-or-nothing rule only if playtests show that
partial interruption needs a graded reward.

### Reject: generic negative trail

Do not create a universal “do not enter” signal based on the older literature.
Use observed congestion, local failed-route memory, or physical incident
records. The negative-marker claim is system-specific and has conflicting
replication evidence.

### Retain unchanged

- directed congestion marks;
- doorway admission leases;
- congestion-triggered path rotation;
- expiring task claims with priority aging;
- perimeter debt and local work stealing;
- physical incident records with bounded counter packages.

## Revised priority order

1. Directed congestion marks.
2. Doorway admission leases.
3. Congestion-triggered path rotation.
4. Targeted retreat inhibition.
5. Expiring task claims with priority aging.
6. Specific decoy habituation.
7. Perimeter debt and local work stealing.
8. Physical incident records with bounded counter packages.
9. Geometry-driven fortification.
10. Repeated-sample call confidence, only if partial interruption needs it.

## Required experiments before implementation

1. Measure current doorway queue delay, reversals, and stationary time on
   one-exit, two-exit, and narrow-to-wide transitions.
2. Run a controlled retreat test comparing complete shutdown, damage-and-release,
   and no-damage conditions; measure inflow over the next 12 seconds.
3. Run repeated false-alarm sequences by category and determine whether a
   60–90 second recovery window is tactically legible.
4. Test three-route chambers for oscillation and irrelevant-option effects.
5. Prototype fortification as plain geometry in one held chamber before adding
   any builder role.
6. Keep all new rules deterministic under identical input and event histories.

The research does not justify shipping all ten items at once. It justifies the
ordering, identifies which claims are robust, and removes one attractive but
poorly generalizing mechanism from consideration.
