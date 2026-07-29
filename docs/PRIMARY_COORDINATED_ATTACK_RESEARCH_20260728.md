# Primary coordinated-attack and weapon-systems research

Date: 2026-07-28

## Scope and translation rule

This appendix examines decentralized attack coordination and unusual weapon
architectures reported by original experimenters. It covers microscopic
defense networks, group hunters, territorial collectives, and independently
operating combat platforms.

The on-disk translation is deliberately neutral:

- source-domain names are replaced by system roles;
- measured observations remain separate from game proposals;
- physical demonstrations, field observations, and models receive different
  confidence grades;
- attack coordination is separated from payload design;
- costs, counters, target restrictions, and shutdown rules are retained;
- source URLs and identifiers remain unchanged for provenance.

Thirty primary publications form the core evidence set. Additional papers were
used only to check whether a result generalized or had a conflicting
explanation.

## Executive findings

1. **A coordinated attack is usually a pipeline, not a damage bonus.** The
   recurring stages are detection, local marking, recruitment, containment,
   breach creation, payload delivery, and shutdown.
2. **The strongest amplification is target-bound.** Surface tags, contact
   points, or an occupied structure assemble the attack at the target. Free
   amplification is more likely to damage surrounding infrastructure.
3. **Sublethal hits can add over a bounded interval.** Several weak attackers
   can defeat a target when damage records decay slowly enough, without every
   attacker sharing a target-health variable.
4. **Containment may matter more than immediate elimination.** Against a large
   target, a surrounding group can delay growth or escape for hours even when
   it cannot finish the target.
5. **High-output weapons commonly split into two stages.** One component opens
   access or immobilizes; a second component exploits the opening.
6. **Stored-energy weapons trade preparation and alignment for extreme output.**
   They are poor generic attacks and excellent committed strikes.
7. **Area weapons need self-protection, pulsing, or sacrifice.** Continuous
   indiscriminate output is rare because it harms the emitter or exhausts the
   payload.
8. **The most interesting counters attack assembly.** Scrub the target tag,
   interrupt the first pore component, break the containment ring, force the
   stored-energy unit to discharge early, or remove the relay before the wave
   propagates.

## Lane A — coordinated attack protocols

### A1. Relay recruitment expands attack radius, then extinguishes itself

Lämmermann et al. 2013 used in-place imaging and perturbations to show that
early arrivals relay a short-range attract signal, greatly expanding directed
recruitment around a damage site. Blocking that relay reduced the radius and
coordination of the response.

A later 2024 experiment measured the relay as a propagating activation wave
and identified a locally generated brake that suppresses further relay at the
wave edge. The result is finite expansion rather than an indefinitely growing
alarm.

Evidence strength: high for relay amplification; high for the existence of a
self-extinguishing edge; exact range is environment-dependent.

Sources:

- Lämmermann et al. 2013, DOI 10.1038/nature12175,
  https://www.nature.com/articles/nature12175
- Poplimont et al. 2024, PMID 38971157,
  https://pubmed.ncbi.nlm.nih.gov/38971157/

Game translation:

- one agent in direct contact emits a short-range attack relay;
- a newly activated peer may relay once after a small delay;
- relays carry a hop budget or rising inhibition value;
- agents already inside the attack cluster stop relaying and begin holding;
- removing early relay carriers limits the response radius.

This is not permission for a chamber-wide alarm. The relay must be visible,
local, finite, and interruptible.

### A2. Target-bound tag clusters unlock an attack cascade

Diebolder et al. 2014 showed that six target-bound tags organize into a ring on
the target surface. That local assembly recruits the first component of a
multi-stage attack cascade. Altering tag-to-tag interaction could block,
restore, or strengthen the downstream attack.

Evidence strength: high structural and functional evidence. Transfer to game
rules is strongest as a target-local threshold, not as a six-stack literal.

Source: Diebolder et al. 2014, DOI 10.1126/science.1248943,
https://pubmed.ncbi.nlm.nih.gov/24626930/

Game translation:

- several independent confirmations place temporary marks on one target;
- marks become an attack authorization only when enough overlap in time;
- the authorization recruits a specialized finisher or enables a breach;
- removing or scrambling marks before threshold prevents escalation;
- unrelated nearby targets receive no benefit from the completed stack.

### A3. Surface-local assembly prevents wasted pore attacks

Heesterbeek et al. 2019 showed that efficient pore insertion requires the
initiating complex to assemble on the target surface. A freely assembled
complex was much less effective. Parsons et al. 2019 then measured individual
pore construction: initiating the first insertion was the bottleneck, while
subsequent assembly ran more than two orders of magnitude faster and completed
an approximately 11-nanometre opening.

Evidence strength: high, including direct imaging and kinetic measurement.

Sources:

- Heesterbeek et al. 2019, DOI 10.15252/embj.201899852,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC6376327/
- Parsons et al. 2019, DOI 10.1038/s41467-019-10058-7,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC6502846/

Game translation:

- a breacher must remain attached long enough to place an initiator;
- the first placement is slow and interruptible;
- once placed, nearby components snap into the breach rapidly;
- killing the breacher before initiation wastes the queued components;
- removing the initiator resets progress rather than leaving generic damage.

### A4. Multiple weak hits add within a decay window

Weigelin et al. 2021 imaged repeated attacks against the same target and found
that individually sublethal hits could add. Their fitted model separated
survival from failure with roughly three hits whose intervals stayed below
50 minutes. Recovery between widely separated contacts erased the advantage.

Evidence strength: high for additive multi-hit behavior in the test system;
the exact count and interval should not be copied directly.

Source: Weigelin et al. 2021, DOI 10.1038/s41467-021-25282-3,
https://pmc.ncbi.nlm.nih.gov/articles/PMC8410835/

Game translation:

- precision attacks add a private, decaying structural-failure record;
- any qualifying attacker can contribute without reading target hit points;
- three close hits may unlock a failure state;
- sufficiently long separation clears partial progress;
- telemetry shows contribution count and remaining decay time.

This produces cooperation without focus-fire telepathy.

### A5. Serial attackers change weapon after early payload depletion

Choi and Mitchison 2013 imaged single attackers making repeated target contacts
and found burst-like serial elimination. Prager et al. 2019 found that early
contacts relied more on a stored breach-and-payload package, while later
contacts increasingly used a slower receptor-triggered shutdown route.

Evidence strength: high for serial attacks and the weapon shift; throughput
varies substantially between individual attackers.

Sources:

- Choi and Mitchison 2013, DOI 10.1073/pnas.1221312110,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC3631668/
- Prager et al. 2019, DOI 10.1084/jem.20181454,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC6719417/

Game translation:

- an elite hunter begins with two or three fast stored shots;
- each successful release consumes a discrete package;
- after depletion it switches to a slower contact execution;
- resupply requires retreat and station dwell, not an automatic cooldown;
- the player can deliberately feed cheap targets to exhaust the fast package.

### A6. Oversized targets trigger containment rather than pursuit

Hopke et al. 2020 showed that coordinated clustering around an oversized target
restricted expansion for at least 10 hours. Successful control combined
encirclement, local oxidative output, and an adhesive mesh. A disabled
oxidative subsystem produced larger clusters but delayed mesh deployment and
worse control, showing that group size alone was a poor success metric.

Evidence strength: high for the measured source system and especially strong
as a warning against treating attendance as effectiveness.

Source: Hopke et al. 2020, DOI 10.1038/s41467-020-15834-4,
https://pmc.ncbi.nlm.nih.gov/articles/PMC7184738/

Game translation:

- a target above the normal carry or grapple threshold triggers a ring task;
- ring agents prioritize blocking exits and maintaining adjacency;
- two specialist actions apply slow structural damage and a pinning mesh;
- a larger ring without the specialists delays but does not finish;
- breaking one sector creates an escape direction.

### A7. Sacrificial containment creates a handoff target

Jorgensen et al. 2016 showed that a compromised defender can rupture while
retaining captured intruders inside its debris. The debris exposes clearance
signals and recruits a second attacker class, which acquires and finishes the
contained target.

Evidence strength: high for trapping and the two-role handoff. This is not
evidence for indiscriminate self-destruction.

Source: Jorgensen et al. 2016, DOI 10.1084/jem.20151613,
https://pmc.ncbi.nlm.nih.gov/articles/PMC5030797/

Game translation:

- a carrier containing a dangerous object may convert itself into a wreck;
- the wreck immobilizes the object and advertises a cleanup task;
- a second class must physically reach the wreck to finish disposal;
- destroying the wreck early can release the contained threat;
- the sacrifice is useful only after confirmed containment.

### A8. Contact-line weapons can be preemptive or retaliatory

Alteri et al. 2013 observed preassembled contact lances firing when two moving
fronts met. Basler et al. 2013 showed a different rule in which an incoming
lance strike caused a local counterattack. Both systems rely on direct contact
and private compatibility keys rather than ranged target recognition.

Evidence strength: high for contact-triggered firing. Whether attack is
preemptive or retaliatory is system-specific.

Sources:

- Alteri et al. 2013, DOI 10.1371/journal.ppat.1003608,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC3764213/
- Basler et al. 2013, DOI 10.1016/j.cell.2013.01.042,
  https://www.cell.com/cell/fulltext/S0092-8674(13)00145-0

Game translation:

- shield-line units hold a preloaded contact lance;
- one variant fires on first hostile collision;
- another fires only after receiving a qualifying contact hit;
- a fired assembly must visibly rebuild before reuse;
- allies carry matching compatibility keys, so the weapon needs no friendly-fire query.

### A9. Shared-medium vibration can coordinate group commitment

Hunt et al. 2021 varied synthetic target vibrations and starting proximity.
Attack latency and participation depended jointly on the shared-medium signal
and how close group members already were. The response did not require a
leader broadcasting an explicit order.

Evidence strength: moderate-high for the controlled experiment; generality
outside the tested shared medium is unknown.

Source: Hunt et al. 2021, DOI 10.1163/22244662-20191062,
https://pmc.ncbi.nlm.nih.gov/articles/PMC8186555/

Game translation:

- a struck surface carries a short vibration event with amplitude and rhythm;
- nearby agents independently decide whether to join;
- heavy or sustained movement recruits more attackers than a small impulse;
- cutting the shared structure interrupts recruitment;
- the same signal may be spoofed by the player.

### A10. Encirclement can precede a synchronized ranged volley

Bastos et al. 2021 documented repeated field events in which a large group
herded targets into shallow space, encircled them, and then small subgroups
launched near-simultaneous high-output discharges.

Evidence strength: moderate. The observation was repeated across years and
recorded, but it was not a controlled manipulation and does not establish the
coordination signal.

Source: Bastos et al. 2021, DOI 10.1002/ece3.7121,
https://onlinelibrary.wiley.com/doi/10.1002/ece3.7121

Game translation:

- ranged units first occupy a loose perimeter rather than firing immediately;
- a local occupancy threshold starts a short visible charge;
- only a small subset fires each volley;
- survivors rotate outward while charged peers step inward;
- disrupting the perimeter prevents synchronization.

Keep this mechanic experimental until it proves readable in play.

## Lane B — weapon architectures

### B1. Target-assembled pore

Architecture: several freely moving components assemble irreversibly at one
target-bound initiator. The first insertion is slow; completion is rapid.

Game identity: interruptible breacher followed by explosive assembly.

Counter: remove the initiator, break attachment, or block the required target
surface.

Primary basis: Heesterbeek et al. 2019 and Parsons et al. 2019, cited in A3.

### B2. Breach-and-payload package

Architecture: one stored component opens a temporary access path; a second
package passes through it and triggers internal shutdown. Delivery is focused
through a tight contact zone to protect surrounding structures.

Game identity: a two-part melee execution whose payload is harmless without a
successful breach.

Counter: separate the attacker during alignment, expend its stored packages,
or interrupt the breach before payload release.

Primary basis: de la Roche et al. 2022, DOI 10.1038/s41467-022-30809-3,
https://www.nature.com/articles/s41467-022-30809-3

### B3. Adhesive capture mesh

Architecture: a distributed mesh immobilizes multiple targets, concentrates
other weapons, and transfers captured material to cleanup agents. Its own
structural backbone can contribute to outer-shell disruption, but outcomes depend
strongly on target and context.

Game identity: persistent pinning geometry that becomes more dangerous when a
finisher arrives.

Counter: cutting or dissolving the mesh, forced movement before closure, or
destroying the cleanup carrier.

Primary basis:

- Halverson et al. 2015, DOI 10.1371/journal.ppat.1004593,
  https://pubmed.ncbi.nlm.nih.gov/25590621/
- Doster et al. 2021, DOI 10.1126/sciadv.abj2101,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC8442908/

### B4. Contractile contact lance with interchangeable payload

Architecture: a spring-loaded sheath drives a tipped tube through an adjacent
target. Different tips deliver pore-formers, bond cutters, or resource-stealing
packages. The chassis is reusable but must extend again after firing.

Game identity: short-range armor-piercing strike with modular ammunition and a
visible rebuild state.

Counter: spacing, baiting a premature shot, tip-specific resistance, or attack
during rebuild.

Primary basis:

- Basler et al. 2012, DOI 10.1038/nature10846,
  https://authors.library.caltech.edu/records/4nbgg-ned22
- Mariano et al. 2019, DOI 10.1038/s41467-019-13439-0,
  https://pmc.ncbi.nlm.nih.gov/articles/PMC6889166/

### B5. Electrical probe, stun volley, and field concentration

Architecture: the same emitter supports three modes. A low-output field senses
conductive objects. A brief double pulse forces hidden targets to reveal
themselves through involuntary motion. A high-frequency volley causes sustained
contraction, while wrapping the emitter around a target concentrates the field.

Game identity: search pulse, ranged stun, and costly contact finisher sharing
one charge reserve.

Counter: insulating cover, breaking line through the conductive medium,
forcing an early search pulse, or attacking during recharge.

Primary basis:

- Catania 2015, DOI 10.1038/ncomms9638,
  https://www.nature.com/articles/ncomms9638
- Catania 2015, DOI 10.1016/j.cub.2015.09.036,
  https://doi.org/10.1016/j.cub.2015.09.036

### B6. Stored-energy impact with a secondary collapse wave

Architecture: a latch slowly loads an elastic structure, then releases it into
an ultrafast strike. In fluid, the strike also creates a collapsing cavity that
delivers a delayed second impulse.

Game identity: telegraphed heavy melee with impact now and a small secondary
shock at the same location.

Counter: force discharge into terrain, change the approach angle, maintain
distance during the loaded state, or exploit the recovery interval.

Primary basis: Patek and Caldwell 2005, DOI 10.1242/jeb.01750,
https://ib.berkeley.edu/labs/patek/Publications/PatekandCaldwell2005JEB.pdf

### B7. Nanosecond spring harpoon

Architecture: a pressurized capsule and preloaded polymer spring launch a
barbed tube in as little as 700 nanoseconds, reaching reported accelerations up
to 5.4 million times standard gravity. The weapon is single-use at the capsule
level and depends on a close trigger.

Game identity: passive one-shot contact mine embedded in a surface or chassis.

Counter: sacrificial probe, ranged clearing, trigger masking, or armor that
prevents the tube from seating.

Primary basis: Nüchter et al. 2006, DOI 10.1016/j.cub.2006.03.089,
https://doi.org/10.1016/j.cub.2006.03.089

### B8. Predictive fan spray

Architecture: the emitter reacts to sudden target movement, tracks it, leads
the shot, and sweeps the jet into a spatial pattern. The goal is not a
pinpoint hit but intersecting a small vulnerable region on a moving target.

Game identity: movement-triggered cone shot that leads dodges and punishes
repeated lateral rhythm.

Counter: freeze before the release cue, break visibility, reverse after the
commit point, or use full-face protection.

Primary basis: Westhoff et al. 2010, DOI 10.1242/jeb.023143,
https://pmc.ncbi.nlm.nih.gov/articles/PMC2871007/

### B9. Pulsed two-part reaction spray

Architecture: two stable precursors remain separated until transferred into a
reinforced reaction chamber. Pressure closes the inlet valve, expels one hot
burst, then allows the chamber to refill. The result is a rapid train of
discrete explosions rather than one continuous discharge.

Game identity: pulsed area denial whose firing cadence emerges from pressure
and refill, with limited precursor tanks.

Counter: attack between pulses, rupture one precursor tank, force overheating,
or remain outside the articulated spray arc.

Primary basis: Arndt et al. 2015, DOI 10.1126/science.1261166,
https://pubmed.ncbi.nlm.nih.gov/25931557/

### B10. Sacrificial binary-mix charge

Architecture: two components remain safe while physically separated. During
an aggressive contact, an aging low-value unit ruptures, mixes them, and
creates a sticky disabling droplet. Both payload and readiness increase as the
unit’s value for other work decreases.

Game identity: expendable veteran that converts itself into a localized trap,
with obvious payload pouches and a grapple requirement.

Counter: ranged removal, forced premature rupture away from allies, separation,
or destroying one component pouch.

Primary basis: Šobotník et al. 2012, DOI 10.1126/science.1219129,
https://pubmed.ncbi.nlm.nih.gov/22837520/

### B11. Collective heat-and-atmosphere enclosure

Architecture: many low-output units physically enclose one armored target.
Their combined activity raises temperature while simultaneously changing the
local atmosphere. Neither effect alone explains the observed shutdown
threshold: the combination lowers the temperature required to finish.

Game identity: a grapple ring that converts occupancy into a slow dual-channel
execution rather than direct weapon damage.

Counter: break the enclosure, add ventilation, cool the occupied space, or
remove enough grapplers to drop below the maintenance threshold.

Primary basis: Sugahara and Sakamoto 2009, DOI 10.1007/s00114-009-0575-0,
https://pubmed.ncbi.nlm.nih.gov/19551367/

### B12. Fluid-jet collapse shock

Architecture: rapid actuator closure drives a high-speed fluid jet, producing
a low-pressure cavity. The principal shock occurs when the cavity collapses,
not when the actuator closes. The ranged effect is therefore offset in space
and delayed from the visible motion.

Game identity: a short-range directional shot with a delayed shock marker at
the jet endpoint.

Counter: leave the conductive fluid region, dodge the projected endpoint
rather than the emitter, or attack during actuator reset.

Primary basis: Versluis et al. 2000, DOI 10.1126/science.289.5487.2114,
https://pubmed.ncbi.nlm.nih.gov/11000111/

### B13. Range-shaped momentum jet

Architecture: the emitter changes nozzle timing so later fluid catches earlier
fluid at the target, concentrating momentum near a selected distance. The
projectile is not a rigid object; its internal timing shapes where peak force
appears.

Game identity: a ranged knockback shot with a tuned focal distance and weaker
effect both before and beyond that distance.

Counter: close inside the focal distance, retreat beyond it, change elevation,
or force the emitter to retune after moving.

Primary basis: Gerullis and Schuster 2014, DOI 10.1016/j.cub.2014.07.059,
https://www.sciencedirect.com/science/article/pii/S0960982214009221

### B14. Broadcast state-disruption followed by capture

Architecture: a specialized signaling mimic is released into the shared
medium, driving many nearby targets into a low-output state. The emitter then
closes distance and uses a separate contact weapon. The broadcast is a setup
tool, not the finishing payload.

Game identity: a costly chamber-local debuff whose real threat is the capture
unit approaching behind it.

Counter: leave the affected medium, scrub the signal, interrupt the slow
emitter, or exploit targets that do not use the mimicked control channel.

Primary basis: Safavi-Hemami et al. 2015, DOI 10.1073/pnas.1423857112,
https://pmc.ncbi.nlm.nih.gov/articles/PMC4330763/

## Cross-system weapon taxonomy

| Architecture | Delivery | Preparation | Friendly-fire control | Best game use |
|---|---|---:|---|---|
| Target-assembled pore | Attached | Slow first component | Target-bound assembly | Interruptible breach |
| Breach plus payload | Tight contact | Stored packages | Focused release zone | Elite execution |
| Adhesive mesh | Area/contact | Deployment time | Spatial boundary | Capture and handoff |
| Contractile lance | Direct contact | Visible rebuild | Compatibility key | Shield-line counter |
| Electrical field | Conductive range | Charge reserve | Geometry and medium | Probe/stun/finish suite |
| Stored-energy impact | Melee | Long load | Directional strike | Heavy telegraph |
| Spring harpoon | Trigger contact | Prebuilt, single-use | Trigger specificity | Surface mine |
| Predictive fan spray | Ranged cone | Short tracking phase | Aimed vulnerable region | Anti-dodge attack |
| Pulsed reaction spray | Ranged arc | Two precursor tanks | Articulated nozzle | Area denial |
| Binary sacrifice | Grapple/contact | Long-term accumulation | Carrier sacrifice | Local trap conversion |
| Heat-atmosphere enclosure | Group grapple | Ring formation | Threshold occupancy | Armored-target execution |
| Fluid-collapse shock | Short-range line | Actuator reset | Direction and medium | Delayed endpoint shock |
| Range-shaped jet | Ranged line | Distance retuning | Narrow firing axis | Focal-distance knockback |
| Broadcast disruption | Chamber-local medium | Scarce payload | Channel-specific effect | Capture setup |

## Design recommendations

### 1. Add decaying cooperative-hit records

Precision attackers place a private structural-failure record on the target.
Three qualifying records within 6 seconds trigger a brief vulnerability or
component break. Each record fades independently. Attackers do not read target
integrity; they merely see and contribute to the physical marks.

Player value: spreading contact prevents escalation, while allowing several
weak attackers repeated access becomes dangerous.

### 2. Add a breacher–payload pair

One class must attach and channel for 1.2 seconds to place an initiator.
Nearby payload carriers can complete it quickly, but their payload has little
effect without the initiator. Removing either role breaks the attack pipeline.

Player value: target prioritization changes dynamically without making the
largest enemy the universal answer.

### 3. Give oversized-target encounters a containment mode

When ordinary displacement fails, nearby agents form an incomplete ring,
block exits, and wait for mesh or structural-damage specialists. Ring size
alone does not increase damage. A missing sector remains a readable escape
route.

Player value: the player can deliberately break the weakest sector rather than
being surrounded by generic collision steering.

### 4. Add a finite relay attack wave

Contact agents emit a relay that peers may repeat once. Every hop increases a
shutdown value, and agents reaching the cluster stop relaying. The wave should
visibly stop without requiring the original caller to survive forever.

Player value: removing early relays contains escalation; arriving late means
fighting a settled cluster rather than an endless stream.

### 5. Add a stored-package serial hunter

An elite begins with three fast breach shots. After using them, it switches to
a slower contact attack until it physically resupplies. Package count is
visible on the chassis.

Player value: baiting shots into disposable cover is a real counter and makes
retreating hunters strategically important.

### 6. Add a contact-line counterlance

A defensive specialist fires only on hostile collision or immediately after a
blocked melee hit. The lance then enters a long, visible rebuild state.

Player value: repeated light attacks are unsafe, while one deliberate feint
creates an opening.

### 7. Prototype synchronized perimeter volleys

Ranged units occupying several sides of a chamber charge together, but only
two or three fire per beat. Breaking the perimeter cancels synchronization and
returns them to ordinary fire.

Player value: the player reads formation as the telegraph and can disrupt the
attack spatially. Keep this behind a prototype flag because its natural-source
evidence is observational rather than causal.

### 8. Reserve sacrificial binary charges for damaged veterans

Only an old or badly damaged utility unit with visible paired tanks may use
the charge. It must grapple or be struck at close range. The resulting patch
pins rather than dealing high immediate damage.

Player value: the weakest-looking leftover unit can become a terrain hazard,
but ranged removal and premature triggering remain reliable counters.

## Recommended integration order

1. Decaying cooperative-hit records.
2. Breacher–payload pair.
3. Finite relay attack wave.
4. Oversized-target containment.
5. Stored-package serial hunter.
6. Contact-line counterlance.
7. Synchronized perimeter-volley prototype.
8. Sacrificial binary charge.

The first four create the strongest coordinated-attack grammar. They should
share existing target marks, local claims, doorway observations, and physical
geometry. Do not add a global combat director.

## Acceptance requirements

- Every escalation stage has a visible precursor.
- Removing one required role breaks that stage rather than merely reducing a
  hidden damage multiplier.
- No unit reads global player state or remote target state.
- Partial cooperative-hit progress decays and is visible.
- Relay propagation has a strict finite bound.
- Containment has at least one geometric escape or disruption method.
- Stored packages require physical resupply.
- A contact lance cannot fire continuously.
- Every area weapon defines its friendly-fire rule and exhaustion rule.
- Synchronized volleys fail when formation breaks.

## Explicit rejections

- No invisible focus-fire multiplier.
- No global “all units attack this target” command.
- No unbounded relay chain.
- No generic poison damage shared by unrelated weapons.
- No sacrificial attack available to every low-integrity unit.
- No precision projectile that silently tracks through portal geometry.
- No permanent cooperative-hit stacks.
- No area attack without a supply, self-protection, or sacrifice cost.
