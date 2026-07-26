# IMPLEMENTATION CORRECTIONS (architectural — re-apply on the reverted base)

- **Pygame-free renderer.** Delete pygame from the render path entirely — no `import pygame`, no `pygame.draw` in `render.py`. The reverted base restores the pygame renderer; this is re-apply item #1, preserved intact at commit `203da395` (cherry-pick it first).
- **spotter ↔ hub decoupling.** A spotter must not know the hub exists or read its state. It calls on its own rhythm; the marrow independently decides whether anything comes — "if it calls and nothing is available, nothing comes." No spotter→hub coupling.
- **Build a "find" support API — shared sense infrastructure for agents.** Agents are allowed to *see* things; chemotaxis was never meant to be their only sense. Perception ("what can I see from here?", "is there an active portal here?") goes through this shared infrastructure — senses, not tight coupling to other systems' internals.
- **The marrow / hub is built at initialization and is never None; every world has one.**
- **Use the existing systems; extend them if needed — do NOT build a parallel pathway** for behavior an existing system already covers.
- **Don't tightly couple systems.** Systems collaborate through the shared substrate (the signal fields), not by reaching into each other's internals.
- **Logging/instrumentation must not be coupled to the audio system**
- **No feature flags, no "off by default."** Behaviors ship hardwired and always-on; this is an *unreleased game*, any "legacy" or "fallback" or "compatibility" or "lazy loading" are absurd overcomplications. Branches are the enemy, eliminate them if possible.
- **One canonical version of any file.** Delete redundant/stale copies (git holds history) — duplicates are epistemic landmines. Canonical gauntlet = `gauntlet4.json`.
- **Extra gamemodes run their own initialization** and stay out of the core `GameSession`; don't complicate the single-world build for them (e.g. the Vigil holdout mode — keep as a shelved idea).
- **The game launches simply** — no tracking twenty flags to start it.

---

# (1) DIRECTOR-REQUESTED DESIGN & INTENT

## Combat canon — the approved 07-19 base + post-FC directives

The reverted base (`d85d3765`, 07-19) is what the director played to a **full clear** (recorded in `out/director_fc/`, seed 2200, ~5 tries; ~67% of play at zero aggro — verified-silence pacing, hp held 95+ by avoidance). Everything else is built **on top of** this combat canon from his post-FC debrief:

- **The intended loop.** You are **outnumbered and undergunned**, so you **prepare the battlespace** — plant seeds (a seed gives a full heal), turrets, etc. — and when you bite off more than you can chew you **fall back**. Falling back must be **fought for**, not free.
- **Enemy kinematics.** Every kind is **significantly faster than the un-upgraded Commando, heavier, with a worse turning circle.** Escape = **fight them backward**, not outrun them; kiting to turrets is a tool, not the universal optimum. Rebalance trivial-but-hard-hitting enemies via kinematics, **not damage inflation**.
- **All weapons push** enemies back (universal knockback — the lightning cannon's push generalized). Knockback is applied as **force through the physics (mass-scaled impulse), never a direct velocity write.** Holding a single light enemy off you this way is intended — 1v1s are easy, just kill it; you can't shoot the whole horde at once. Fully-charged **Tau** detonates on impact with a small AoE + push.
- **Warden = a normal high-tier enemy.** hp **168** (dies to 2 charged Tau or 4 rail shots — charged Tau max damage rises 64 → **84** so this arithmetic holds; rail stays 42), **no brood/adds, no enrage** — not "invulnerable."
- **Death does NOT reset the world (System Shock rule).** With a backup chassis you revive at the seed and the world stays as you left it — you lose progress by **losing physical progress** (the walk back), not by a reset.
- **Portable Hole belongs in the loop** — connect a distant boss chamber straight back to the saferoom turret (an immersive-sim moment); in the full loadout. Its aperture passes only small bodies, so the **hub guardian roster must include hole-capable pursuers (mite, shrieker)** and shelling through a hole mouth draws pursuit through it — a hole is a lifeline, never a consequence-free firing slit.
- **Lighting:** muzzle flash through the real lighting system; directional lights; the player flashlight reaches most of the screen, add directional lights to the lighting system.
- **Gland & scrap driver** were "entirely worthless" — remove.

## 1. Reinforcements — the marrow hub, callers, breaches (the heart)

### The breach
- A breach is a **hole — an absence of material.** It cannot be "killed." Do not model the breach mouth as a destructible entity.
- A breach is a **real two-way portal** cut into the wall of an ordinary existing chamber, linking to the off-map hub chamber. Reinforcement agents surge out and climb toward the intruder.
- **Multiple simultaneous breaches** are allowed and split enemies evenly.
- A breach **closes on its own if uncrossed for ~45 seconds.** A crossing is **anything crossing the line** — any entity or projectile, either direction. Pinning a breach open this way is bounded by the reinforcement economy, not the timer: the breach also closes **when the marrow's reserve runs out**, and **when it is no longer useful to the agents the hub spawns.**
- Enemies must **physically enter the level** through the breach — no log-jamming in the opening. DO NOT add any special casing around entry; simply ensure the breach is wide enough and does not end up with a scaling factor on its connection to the target room, enemies will simply walk through it on their normal AI.
- **How the scaling factor is actually avoided (verified against the engine 07-25).** `connect()` *derives* a uniform scale `s = la/lb` from the two glued edge lengths — scale is not an optional field to leave unset, it is computed from any mismatch. Measured: two 96-unit edges give `s = 1.000000` exactly; 96 against 52 gives `s = 1.846`, which resizes bodies as they cross. **The guard is therefore a construction rule, not a discipline:** carve both sides with `carve_door(..., width=W)` at the *same* W (it cuts a sub-edge of exactly W), then assert the resulting transform's scale is 1 within tolerance at breach construction. This is the bug that made a previous build's reinforcements unable to fit through the gate.
- Being a two-way door, an intruder who noticed a breach can **cross it back toward the source** before it seals. 

### Respawn Considerations
If the player enters it, unless the player finds a trick to keep it open (shooting through the portal counts as a crossing) it will seal behind him; this is okay, the player is expected to either plan ahead and bring a way back for an intentional expedition, and a player that entered out of curiousity can simply self-destruct (change the "restart level" command in the ESC menu to Self-Destruct - Revive at Pod) - an emergent built-in tutorial that "you need to bring a way back."

### The spotter
- A breach is **called in by an agent.** The hub can attach itself recieverless, but it needs to know _where_, so the location must either be given by an Adversary-lane spotter, or by causing so much disturbance that his location is obvious. 
- Only **Adversary-lane agents** (vagrant, lacuna) can call. Corrupted-Testator agents (mite, husk, spitter, brute, warden, shrieker, flicker, reanimated bodies) **cannot call** — they only fight.
- **Every Adversary-class enemy** has call-for-reinforcements behavior — not one special unit.
- The spotter **communicates/transmits a position** to the hub; it does **not build the portal itself.** The hub reaches through and opens the breach at the transmitted spot. *(The spotter is architecturally decoupled from the hub — see IMPLEMENTATION CORRECTIONS.)*
- **Selection rule (one unit, weakest-in-room):** if there is no active portal and no ally in the room already tasked with calling, then: *if I am not the weakest class of Adversary in the room, keep fighting; else make summoning reinforcements my top priority.* Stronger units keep fighting. *(These preconditions are the agent's own perception via the find/senses API — spotters and breaches know nothing about each other or about the hub.)*
- **Summoning is normal combat behavior** The tasked weakest unit places the call **as close to the player as is safe:** it retreats off the hot zone, advances only through rooms below the danger threshold, stops **at** that threshold, and plants the call there — keeping itself out of the player's reach.
- The spotter **deliberately places exits well clear of the front line** specifically to avoid being interrupted by the player.
- Non-combat spotting follows a state machine: **Infiltrate** (roam toward ground behind the intruder's line, steering away from player-scented chambers via the shared field) → **Transmit** (hold position deep enough behind the line and off player-y ground, **stationary and fully exposed for the whole broadcast** — this is the visible tell) → **Pour** (hub opens the breach; reinforcements surge and climb toward the intruder).
- **The spotter is the vulnerability.** You cannot shoot a hole in the wall, but you can catch the transmitting agent mid-broadcast to stop the breach opening, or kill it afterward to deny the next call. Only one agent transmits at a time and only so many breaches open at once, so the reinforcement rate is bounded.

### spotter garrison expansion (07-25)
This is a restock/reinforcement system; just clearing an area once _doesn't clear it_ - this is a war, the enemy does not simply let you have ground you took but didn't hold. Terrain _can_ be held - but it must be cordoned off with turrets preventing any spotters from entering and the player must take care not to have a potential spotter slip past him, which some types deliberately try.

- After planting its **first** breach, the spotter **pushes further behind** the player, **descending the chemotaxis gradients** to find safe spots where it plants **garrisons**.
- After a safe garrison, it **climbs the danger field to a peak** (refusing to enter high-danger rooms), plants a breach there to **raid the player's base**, then switches back to descending for the next safe spot.
- **A garrison is emergent, not an object.** Some agents patrol; some fall in behind a leader (e.g. a Warden) who directs them to fortify a room he chooses — an emergent "boss room." Leader AI comes later: for now leaders have no idea they have followers, and whatever room the leader happens to be in emerges as the base.
- Add a **friendly-scent (kin) chemotaxis field** so callers climb **away** from other friendlies — garrisons spread out instead of clustering.


### The marrow / hub economy
- The hub is a **safe chamber kept off the reachable map** — an entire extremely difficult game area holding the **CORE** (a supply organ) and a **ring of guardian agents.** It is the most heavily defended place in the world. Lore: **the hub is a Testator construction the Adversary corrupted to its own ends** — the Adversary sees the Testators as a *weapon*; Adversaries themselves are *personnel*. **The hub is an entire game area unto itself — to be designed.**
- The **marrow holds a finite reserve that regenerates slowly.** When the reserve is **exhausted it stops opening portals.**
- The brief window **between reserve exhaustion and the portal closing** is the player's chance to **invade and destroy the core.** Destroying the core drives the reserve **deep negative**, forcing a resupply from the Adversary's home universe — the reinforcement layer goes offline for the duration.
- **A core kill is a status effect the player applies to the enemy.** The reinforcement layer goes down for **~90 seconds** (placeholder: `reserve = -32` against 0.35/s resupply — see §1b; the real value depends on what a late-game player needs the hub down *for*, which we can't know yet), then the core comes back as soon as its reserve climbs above zero. Use it tactically — cut off a fortified area's reinforcements before charging it. Until the core is destroyed, breaches keep being called in.
- **The core is an organ, not a single static NPC** — an entire system of agents, to be designed. It **regenerates HP while alive**, so it cannot be chipped down across deaths unless the player has established a real foothold (e.g. fought a pod into place nearby).
- The hub is **reachable ONLY through a live breach, and VERY hard**, gated on the player **noticing** what's happening (the calling happens out of sight). Beating it is an **organic reward for paying careful attention**, not a signposted objective.
- **The core generates all kinds of enemies, including Shriekers** — but it **never spawns the finite Adversary spotter units** themselves. The Adversaries are a finite population. **Exterminating that population permanently disables called breaches — intended**, and in practice near-unachievable because the reinforcement stream keeps protecting them; containment, not extermination, is the practical strategy. (Adversary reinforcements from the home universe are a possible later addition.)

### Anti-turtle / direct connection (flank breach)
- If a chamber's Distress reaches an extreme level, perhaps twice the peak of what it ever becomes during aggressive play, the Adversaries on the other side **notice and open a direct, spotterless connection** on the flank, no spotter needed.
- **The direct-connection threshold must be extreme.** It is a **rare, near-irresistible punishment for extreme turtling/farming**, NOT part of ordinary play. It is *also* intended as a way for an advanced player to deliberately cause a breach at a time and location he controls - bait the enemy in to attacking an impenetrable fortress, burst out and kill your way in to the core.
- **Aggressive perfect play avoids reinforcements entirely:** kill every Adversary on sight, leave no stragglers, don't turtle → no combat reinforcements. This does _not_ avoid Adversaries simply avoiding the combat zone entirely, routing around you and reclaiming ground you didn't hold, though. ("Perfect" means **perfect** — a limit case, not humanly achievable.)

### Containment reward
- **Fully clearing and cordoning an area clears it permanently**, as long as nothing slips through the cordon. Cleared ground behind the front **re-arms unless truly HELD**: a cordon of held crossings with nothing slipping through starves the layer (a spotter can't reach quiet ground behind you; an uncrossed breach seals itself). Careful containment is genuinely rewarded.

### Intent for the moment-to-moment fight
- For most of a run, **the reinforcement stream itself is the fight.** Standing and fighting reinforcements as they arrive is usually a better use of ammo and time than hunting the source.
- If the Adversary force keeps fighting, it should **eventually be able to overwhelm and win.** Combat must be able to resolve in the enemy's favor. A competent player will intentionally manage how much aggro he's drawing, slow down to avoid getting overwhelmed, retreat to a firebase and fight out the reserves if he accidentally bites off more than he can chew. A player who is too timid to engage the enemy without backup will overheat the area and trigger the direct connection, a player who recklessly charges forward will be surrounded, mobility-cancelled, and destroyed.

---

## 1b. The ratified marrow shape (07-25)

*Everything below is the implementation shape settled after two research waves and two external consults. **Numbers here are first-pass values chosen so the reasoning is visible, not tuning results** — every one of them is expected to move once measured. What must NOT drift is the structure: the economy is closed-loop and blind to the player, the tells are generated by the same arithmetic they report on, and nothing special-cases the breach.*

### Reserve economy — closed-loop and blind

The marrow's regeneration is driven by **how empty its own depot is**, never by how the fight is going:

```
reserve_cap = 120 dispatch-units
regen       = 0.10/s * (1 + 2.5 * clamp(1 - reserve/reserve_cap, 0, 1))
            → ~0.10/s when full, ~0.35/s when empty
```

This **never reads Distress, Noise, kill counts, player health, or difficulty** — the decoupling is structural, not a rule someone has to remember. Per-class dispatch cost: mite 1, husk 2, spitter 2, shrieker 3, flicker 3, brute 4, warden 8. Against a ~2.2s dispatch interval, a full reserve drains in roughly **110–150 seconds** of sustained pour — long enough that fighting the stream is a real encounter, short enough that a deliberate firebase stand can actually exhaust it.

**When the next unit is unaffordable, the marrow waits for it — it never substitutes something cheaper.** This single rule is what makes the reserve legible without a HUD: the gap before a pending Warden stretches to ~23 seconds at low reserve, so *the stutter at the gate is the reserve gauge*, and it cannot lie without the economy itself lying.

### Core kill — a ~90 second blackout, derived not timed

Destroying all three Source Knots sets `reserve = -32`, which at the 0.35/s home-resupply rate returns to zero in **~90 seconds**. There is no blackout countdown anywhere; the outage *is* the debt being repaid. **90s is an explicit placeholder** — the right value depends on how long a late-game player actually needs the hub down for, which we won't know until there is late-game play. It is one scalar; retune it then, and never replace it with a timer.

During the blackout: dispatch stops, existing breaches get a 10-second exhaustion grace then collapse regardless of crossings, and no new portal opens. **Spotters keep transmitting, because they do not know anything happened** — a dry call is consumed and produces nothing. At recovery the CORE reforms minimal (one Source, one Anchor, three Buds, one Caretaker) and the ordinary governor resumes.

### Dispatch and the breach

- **Sites are prevalidated at world build:** 1–3 viable wall segments per chamber. The spotter transmits a position; the marrow opens the viable site *nearest* it. The inventory never grows and the aperture never widens.
- **Width** `max(96, 2 * largest_dispatchable_radius + 16)` — simply wide enough, once, forever.
- **Scale-free by construction** (see the breach section above): carve both sides at the same width, assert the derived scale is 1.
- **Pour shape:** ~3s formation tell → a burst drawn from the standing guardian shelf → sustained pour at ~2.2s/unit (3.14s with one Dispatch Collar destroyed, 4.89s with both) → cordon and exhaustion. Only **~10% of a dispatched group (minimum one) knows the transmitted position**; the rest run on ordinary one-hop fields, sight, and flocking. That produces strays and garrison seeds instead of an omniscient conga line, and makes killing scouts a *graded* counter rather than a switch.
- **Closure**, first condition to apply: nothing crossed for 45s; reserve exhausted (+10s invasion grace); or no hub-side agent has routed toward it for 12s after opening. The breach object never inspects the reserve or other breaches — the marrow requests closure, pathing supplies route interest.
- **Multiple breaches split combat EXPENDITURE, not headcount.** A cost-fair queue owned by the marrow: each live breach accrues equal dispatch credit, the readiest unit goes to the breach with the most credit, and its reserve cost is subtracted. A Warden through one gate is balanced by several cheap bodies through another; a new breach starts near mean credit so it neither starves nor floods. **Breaches never read each other** — the marrow, which owns dispatch, is the only thing comparing them.

### The CORE as an organ

Parts, with HP quantized to the player's own weapon arithmetic (42 = one rail shot, 84 = one charged Tau, 168 = two charged Tau / four rail):

| Part | Count | HP | Killing it does |
|---|---:|---:|---|
| Dispatch Collar | 2 | 126 | Slows dispatch **immediately**; no effect on production |
| Scriptorium | 1 | 84 | Erases the evidence ledger, stops learning |
| Caretaker | 4 | 42 | Removes repair/rebuild — makes other damage *stick* |
| Anchor | 4 | 84 | Releases its Buds as ordinary defenders; delayed production loss |
| Producer Bud | 12 | 42 | Removes 1/12 of Bud-supported production |
| Source Knot | 3 | 168 | Removes 1/3 of source capacity after a pipeline delay |
| *all three Sources* | — | — | `reserve = -32` → the ~90s blackout |

The parts have **deliberately opposite time constants** — collars change the current fight, anchors change the economy later, caretakers decide whether anything you did persists — so target choice is contextual. There is **no mandatory order, no invulnerable phase, and no master health bar**; a player who finds an emptied hub may simply rush the Sources. Self-defense is systemic: damage to a part schedules a response ~6s later (buds detach, local guardians converge through ordinary Muster). The CORE **regenerates while alive** (Sources 2 hp/s after 10s undamaged; Caretakers 6 hp/s in contact), so it cannot be chipped down across deaths without a real foothold.

### The hub — a corrupted Testator cathedral

**24 chambers, 10–11 portal crossings deep**, reachable only through a live breach. Half the floor area sits in the first three depth bands and shrinks with depth; a shallow transept loop gives early flanking, then a single axial trunk past the Rood Gatehouse. Breaches attach to seams in one of three **Receiving Apses**; **Guardian Courts** flank them; **Collar Chapels** hold the dispatch machinery; **Anchor Chapels** are mid-band side objectives; the **Scriptorium** receives returning evidence carriers; a **Long Exposed Connector** at ~three-quarters depth is the final commitment; three **Source Cells** branch off the last vestibule, separate enough that one Tau cannot take all three, attackable in any order. It is not a maze — the challenge is commitment, attrition, and fighting back out.

**The guardian shelf IS the dispatch shelf.** Ten real, dispatchable agents stand between the production interior and the breach mouths. When the marrow dispatches them they physically leave, the entrance genuinely weakens, and replacements cost reserve and arrive no faster than one per 12s. That makes the timing the actual skill:

> **The safest moment to invade is when the thing that would have guarded the hub is currently fighting your firebase somewhere else.**

**Arrival must explain itself with no text and no objective marker.** Manufactured wall ribs and processional inlays say *built, not grown*; vacant guardian stations say *they left*; conduits carrying light inward and agents arriving from deeper say *that way is depth*. It should read as **a consecrated machine built for another purpose, seized and made to manufacture war** — repeated modular bays, brass and blackened steel, Latin maker's prayers, reliquary housings on the Sources, with the infestation visibly *secondary*: buds clipped onto old power rails, tendrils following existing conduit runs, icon panels obscured but intact. Never a cave, mound, or fleshy tunnel.

**The way out is honest and unrescued:** return through the breach before it seals, keep it alive by crossing/firing through it, use the Portable Hole (the intended prepared-expedition tool — and mites and shriekers *can* follow through it), reach another live breach, plant a pod foothold inside the hub, or Self-Destruct and revive at a pod having lost the expedition but not the world. **No hidden emergency teleporter.**

### Scouts — vagrant and lacuna

| | Vagrant | Lacuna |
|---|---|---|
| Role | open-ground infiltrator | boundary scout |
| HP | 84 | 42 |
| Speed / turn | 1.45× Commando / 0.55× | 1.20× / 0.50× |
| Behavior | long committed room-to-room legs through broad chambers | hugs walls and portal mouths; may root ~3s to **probe the next chamber through a portal without crossing it** |
| Broadcast | 6s rooted (8s total exposure) | 8s rooted (10s total exposure) |

Both transmit as **brace → rooted broadcast → release**, fully stationary and unable to fight for the whole broadcast, pulsing once per second, audible ~2 portal hops through the ordinary audio system. **Lacuna is the weaker class and therefore calls first** under the weakest-in-room rule. Critically, **a lacuna may only call into the chamber its body physically occupies** — probing through a cordon does not let it call past one, or the containment reward would be dead on arrival.

Both classes are **authored into the world at initialization and never produced by the CORE**. Some begin dormant in quiet chambers with high thresholds, so killing the active ones may not visibly reduce pressure — but every death permanently reduces the census.

**"Only one agent transmits at a time" is a property of the medium, not of the hub.** A scout takes a single world-level *call-medium lease* — the shared substrate, like one radio channel — broadcasts, and on completion leaves a **call imprint** (chamber, position, tick, caller class) that expires in ~15s. Interruption or death releases the lease. The marrow independently samples imprints and **consumes one whether or not it opens a portal**; calls never queue waiting for resources. The imprint carries no reserve demand, no hub state, and no desired enemy mix. That is how the spotter stays ignorant of the hub while the rule still holds — *if it calls and nothing is available, nothing comes.*

### Composition — the hub is not what comes through the gate

| Role | Resident hub | Delivered strike package |
|---|---:|---:|
| Screen (mite, husk) | 60% | 35% |
| Ranged (spitter, shrieker) | 18% | 25% |
| Mobility (flicker) | 10% | 15% |
| Breaker (brute, warden) | 12% | 25% |

The invaded hub reads visibly lighter than the force it sends, which gives the place an identity derived from the combat system rather than invented for it.

### Garrisons — leader-anchored, leader oblivious

A follower settles when a **Warden is physically present**, no hostile is visible, Noise < 0.20, Danger < 0.35, and it has held the chamber ~12 continuous seconds. The Warden's state machine is **completely unchanged**: no follower count, no base selection, no leader emission. Settled followers stop answering outside Muster, keep fighting normally, and emit Garrison Interior/Reach. Two settlers make a functioning garrison. If the Warden wanders off, existing settlers persist but no new ones settle. *(Leaderless Distress-conversion was considered and rejected: it would make the hottest combat chambers become bases, contradicting the spotter's whole job of finding quiet ground.)*

### The tells, ranked

1. **Gate payment stalls** — the strongest, because `wait = (cost - reserve)/regen` is generated by the economy itself.
2. **Loss of the guardian burst** — a fresh call leads with standing guardians; later calls don't.
3. **Dispatch machinery visibly missing beats** after collar damage.
4. **Increasingly irregular arrival gaps.**
5. **A dry transmission** — a scout completes a broadcast and no wall opens.
6. **Exhaustion closure** — a breach collapsing on its own.
7. **Direct inspection** — vacant posts and dim conduits, the highest-information observation, available only by committing to the raid.

The first causal tell a new player is likely to learn: *a stationary pulsing scout broadcasts, and afterwards a wall opens.* Do not rely on the player estimating variance or spotting subtle stat variants.

### Known risk, stated plainly

The load-bearing assumption most likely to be wrong is that **a fixed-width portal can be both the place the player wants to stand and fight and a source that can eventually beat a prepared firebase.** A fixed mouth concentrates enemies and makes sentry fire maximally efficient. If measurement shows fighting at the mouth is strictly better on ammunition, damage taken, structures lost, and retreat portals denied, the fix is **approach geometry, arrest positions, and multi-route pressure — not enemy HP or damage inflation.**

---

## 2. Buildings & firebases

- The bot must not be able to plop buildings in an enemy's face — it should have to **make distance and play strategically** around them.
- **Buildings are destroyed on contact by any enemy except the very smallest (mite).**
- **Projectile enemies prioritize buildings** as targets.
- **30-second "unpack" phase** after placement: inert and fragile until active — you can't drop a turret into a swarm and have it fight.
- **Sentries:** fire a couple times per second, kills a spitter in one shot, a single turret can 1v1 any enemy weaker than a Warden, which can 1v1 a sentry in open ground and win. They're glass cannons, designed to be highly lethal _as part of a system_ and highly vulnerable alone.
- **Sentry animation:** turret **rotates to face its target**. It fires a pulsed high-frequency laser beam; make it look like a realistic extreme UV laser beam scattering off microdebris in the air (the Commando can see UV). _It must be obvious to the player what the sentry is, and what it is doing right now, at all times_.
- **Sentry ammo:** run dry after **50 shots** unless **near a pod**, where nearness is **path (hop) distance, not straight-line.**
- **Pod roots:** the pod **slowly grows visible roots over time**, and every component spent there applies a temporary buff to the growth rate, as it digs into the station to extract resources. The roots grow towards points of interest in the room such as props or clusters of decals (it's repurposing materials from station machinery or dead enemies) and glowing tendrils reach towards player-placed buildings indicating the pod is interacting with them.
- **Repair station:** **no remote healing.** The player must **enter the station and stay vulnerable ~20 seconds** to be healed. Its niche: **it can be placed close to the fight**, where the pod cannot go. Losing a repair station is a minor sacrifice of a couple of components; **losing a pod is a major setback.**
- **Pheromone scrubber (new building):** an air filter that **severely damps ALL chemo-signals** in its area. Unscrubbed bases **eventually getting found and purged is intended behavior** — you must actively cloak the chemical signature of any base you mean to keep.
- **Cleaning robot:** a scrubber **linked to a pod** becomes the base station for a military-grade cleaning robot that keeps the FOB tidy. **Visually**: scrubs splatter off the ground, sweeps up shell casings, drags corpses into neat piles for the pod's roots to reach out and eat. **Mechanically**: cleaning up after a big fight (and sometimes moving a corpse) **emits a couple of components** — it cleans to make salvage easier and preps remains for recycling by the pod. **Standing rule: anything added to the game later that suggests an interaction with the cleaning robot gets one.**
- **Iconography:** remove the **red cross** (copyrighted, wrong for a robot); replace with **Christian iconography** - iterate on what looks best and would make sense in-world.

---

## 3. The enemies

- **Enemies can get behind the player / flank.** As of 07-23 they still couldn't. Simplest route: use chemotaxis to path to ground **behind the player's line**, avoiding **reinforced** and **player-scented** rooms. Each Adversary type gets a strategy suited to its capabilities.
- **Fire on line-of-sight.** Without stealth upgrades that aren't implemented yet, it should not be possible to get more than 75% of a screen away from enemies without them becoming aware and initiating combat.
- **Enemies corner-peek turrets** — approach/attack from cover. They can detect a room that requires peeking by the Danger scent.

### Shrieker
- A Shrieker **tails and marks the player**, emitting a "follow this / come only so close unless you smell enough friends" signal that lays a **follow-me trail** and **draws the swarm.**

### Warden — engulf attack (07-25)
- **Add to (not replace) the existing Warden state machine — keep all current behaviors.**
- Engulf sequence: **stop**, **the Warden's main body flashes a brighter color twice over ~200ms** chargeup, then **lunge at ~2.5x normal move speed.**
- The engulf-attack state **lasts until velocity drops back below normal.**
- If it touches the player **while engulfing AND `dot(velocity, direction-to-player) > 0.5`** (so glancing hits don't count), the player is **rapidly drawn into the Warden's core**, taking **~75 HP/s** DoT and must **shoot his way out** (until the Warden is killed). Firing any weapon always hits the Warden.
- ENSURE THERE IS NO STRONG COUPLING BETWEEN THE PLAYER AND THE WARDEN IN ARCHITECTING THIS SYSTEM!

---

## 4. Rendering & legibility

*(The pygame-free renderer itself is an architectural correction — see IMPLEMENTATION CORRECTIONS. This section is the visual/UX design.)*

- **Strip the HUD:** remove the banners and everything in the top-left **except the scrap count.** Retire the banners and the mid-screen objective one-liner.
- **Carrying a pod is shown on the character** (a load on the player's body), not via a HUD indicator.
- The **carried building sprite rotates with the player** so it reads as an object on his back, not a decal trailing him.
- **Fixedsys Excelsior font always drawn at 16px.**

---

## 5. Level / world

- **The final game is one connected world** — a single "level."
- *(Every world always builds a marrow hub — architectural, see IMPLEMENTATION CORRECTIONS.)*

---

## 6. Economy

- **Player carries only one thing at a time.** The pod (CUCULUS fabricator) prints an assembly kit; the player loads **one** on his back, carries it (slowed), and assembles it in situ. Loadout starts with **zero kits.**
- **The CUCULUS loop is self-reinforcing:** the pod is fired in; it creates the chassis; the chassis spreads more pods; the pods subvert more and more of the station's resources; the chassis grows more powerful. **Additional pods are fabricated and planted by the player** — the forward pod chain is the engine of expansion.
- **Chassis supply: for now the starting pod has an infinite supply of backup chassis** (revisit in a future unit).
- **Health packs → Testator field-repair kits:** much rarer, kept only in **designated storage areas**, never scattered randomly on the floor.
- **Marrow reserve** economy per §1 (finite, slow-regen, exhausts, drivable negative by killing the core).

---

## 7. Working-discipline rules the director insists on

*(Code-architecture rules — no feature flags, decoupling, one-canonical-file, simple launch, gamemodes-own-init — are collected in IMPLEMENTATION CORRECTIONS above. These are the working-discipline rules.)*

- **Don't fake around problems.** If a behavior isn't happening in the actual Gauntlet level, **diagnose why** — don't route around it in a test scaffold.
- **Build isolated, purpose-built test vectors.** Do not test everything in the real level all the time.
- **Verification = a full run with a Sonnet checking every 5th frame.** Ten frames is not verification. Watch the actual output.
- **Stop asserting things work and explaining away contrary evidence.** Investigate **all** competing hypotheses before concluding; gathering evidence after forming a theory biases the body of evidence. Allow yourself to notice confusion.
- **Never reward-hack** by shrinking/degrading the target. "Can't be done" is not an out.
- **Do not impose a determinism requirement** — it's a video game, not a deterministic system.
- **For live human playtests, instrument the human exactly like the bot** to study his strategy in detail.
- **Immune-inspiration research:** delegate to an **Opus 5**, and require it to **omit all medical/immunological terms** from report and response — frame everything purely as **game mechanics.** Immune terminology causes safety false-positives that can be avoided by simply referring to the concepts as lessons on distributed coordination agent design rather than using immune terms directly.

---

# Open design units

**Drafted in §1b** (07-25) and ready to build against: the hub area, vagrant & lacuna, the CORE organ, the reserve economy, breach/dispatch mechanics, and garrison settlement. Those need implementation and measurement now, not more design.

Still genuinely open:

- **Leader AI** — deferred; garrisons emerge around oblivious leaders for now.
- **Find/senses API** — shape is drafted (immutable `SenseHit`/`PortalSense` observations, `portal_depth ≤ 1`, a lacuna portal-probe that is *not* an adjacent-room wallhack); the query set needs to be settled against real callers as they are written.
- **Pheromone scrubber / cleaning robot** — direction settled (a subtractive, shared-capacity sink of ~1.2 signal-units/s over its own chamber at 1.0 and neighbours at 0.5, so a quiet base hides and a loud fight leaks; **a scrubbed region is *not* independently suspicious** — agents sample only one hop and have no regional baseline to notice an absence against). Costs, coverage, and the robot's component-emission rate still need numbers.
- **The learning layer** — adaptive counter-biasing, evidence relay, and counterplay reward. Direction: a small fixed-capacity evidence ledger in the Scriptorium, written by carriers that physically return through a live breach, decaying with a ~75s half-life so switching tactics measurably slips the counter. Destroying the Scriptorium erases it.
- **Late-game shape** — what a player actually wants the hub down *for*. This is what sets the real blackout depth.
- **The killbox question** — measure whether fighting at a breach mouth is strictly dominant before adding anything to the stream (see §1b, "Known risk").

---

# Appendix: Adversary constitution (ratified vocabulary, not implementation)

The Adversary is a **decentralized, non-conscious swarm** of many mostly-interchangeable defense agents coordinating through a **shared signal medium** — no chain of command, **no commander to kill**, no single unit whose death ends the response. Removing any one agent **thins** the response without stopping it. It **responds to disturbance, not identity**: gunfire, structural damage, and a hurt/killed agent recruit a response; standing still and quiet draws little. It should feel like a coordinated strategic response, and a truly advanced player will intuit how the system communicates with itself and manipulate it to his advantage.

**Signal fields** — scalar, one value per chamber (polygon), spreading **hop-by-hop across the portal graph** (never through a wall, never beyond the doorways), fading over time. Each agent samples **only its own chamber and chambers one portal away.**

| Signal | Emitted by | Spread / fade | Meaning (in general) |
|---|---|---|---|
| **Distress** | agent hurt/killed | spreads slowly, fades slowly | There is a persistent threat here, pay attention to this area |
| **Danger** | Agent _killed_ here | no spread, very slow fade | This room is deadly, don't enter unless you smell enough Muster to indicate you are part of a coordinated push |
| **Noise** | gunfire, movement, agents in contact with a hostile | spreads fast & wide, fades fast | There is an active intruder here |
| **Trail** | the intruder's passage, at their position | does not spread; fades enough that it can be consistently followed to the player | An intruder has been here recently |
| **Patrol** | Patrolling agents | no spread, slow fade | This room has been searched already recently, if patrolling look for a less explored place; if looking for a safe route, if patrol is high and danger is low the room must be a well explored safe route |
| **Muster** | agents already committed to a fight | Spreads with very exponential dropoff per hop, fades VERY FAST | Rally here, we are preparing for or currently executing a coordinated raid |
| **Garrison interior** | agents settled in an emergent base (e.g. around a leader such as the Warden) | special spread — needs two fronts to meet to spread "interior", otherwise spreads "reach"; fades fast if the garrison is destroyed | This is "inside the wire" — we are holding this cluster of polygons as a FOB |
| **Garrison reach** | (same garrison agents) | if garrison emission reaches a room by only a single path it spreads *reach* instead of *interior*; spreads far, fades fast | The FOB is this way |
| **Kin** | every Adversary agent, in its own chamber | spreads a short distance, fades moderately | *My own side is thick here.* Climbed **downward**: a spotter descends the Kin gradient to find underdefended ground |

**Kin is load-bearing and stays a field** (ruled 07-25). Scalars on polygons are cheap, and a diffusing scalar is the **only** way a spotter working behind the lines can tell where the *underdefended* polygons are. A purely local substitute — counting the friendlies an agent can see and damping its own recruitment — only reports "I am crowded *here*"; it cannot point at distant thin ground, which is exactly the query garrison expansion depends on. Contact-based damping may be layered on top as flavour, but it does not replace the field.

The room stores what simulation tick it was last updated on; decay is always computed from the delta. This makes it so a room that has stopped recieving or is recieving updates less often decays at the same effective rate.

**Decay is exponential, so separation in TIME comes from different half-lives — never from amplitude.** Under exponential decay, doubling a signal's initial value buys exactly one extra half-life above a fixed detection threshold: an additive offset, not a multiplier. Amplitude sets how *loudly* a fresh event reads; half-life sets how *long* it matters. First-pass half-lives, with `time_above_threshold = half_life * log2(initial / threshold)`:

| Signal | Half-life | Typical initial | Time above 0.10 |
|---|---:|---:|---:|
| **Trail** | 12 s | 0.80 | ~36 s |
| **Patrol** | 60 s | 1.00 saturated | ~199 s |
| **Danger** | 180 s | 0.40 per death | ~360 s |

That produces the intended ordering — Trail means *recent passage*, Patrol means *searched within the last few minutes*, Danger means *this room has stayed lethal through a substantial fight*. The ordering is the design; the exact half-lives are a first pass to be measured.

Distress is the inflammation analogue and behaves like real-world inflammation: it responds only to **agents being harmed** (there is no structural damage in this game); it integrates under a persistent stimulus and resolves when the stimulus stops.

**Coordination behaviors (the designed TARGET — none verified live; build and verify each):**

*Not "shipped." **The reverted base (`d85d3765`, 07-19) predates ALL of this — none of the coordination behaviors or the signal fields exist in it yet; it is all to be built.** And what was later built (07-20 → 07-23) was never confirmed working: the coordination never got a chance to show (a sparse stomp — "the enemies just don't have any chance to react"), and reinforcements never reached the player. The signal set above is a redesign. Treat every item as a spec to implement and verify against a real run, not as existing behavior.*

- **Chemotaxis:** patrolling agents climb the Distress gradient, looking for trouble, refusing to enter rooms with high Danger
- **Quorum (fractional, corrected 07-25):** an idle agent commits on the **fraction of the peers it can actually see that are already committed**, not on an absolute signal level. Calm visible peers form a *denominator* and inhibit commitment; the fields contribute one bounded virtual supporter, so a loud disturbance can still wake a lone picket. `f = (committed_visible + e) / (all_visible + 1)` where `e = clamp((Noise + Distress)/0.60, 0, 1)`, committed via a Hill curve against a per-agent threshold sampled **once at spawn** (not re-rolled per tick). Consequence: the same field value wakes a three-agent corridor while barely perturbing a twelve-agent hall, cascades start at sparse edges and propagate inward over a second or two, and killing habitual low-threshold initiators measurably thins future cascades. *(The old absolute-threshold rule had it backwards — it made a packed hall easier to flip than a thin picket.)*
- **Relay-recruit:** agents in a "target in sight" state emit Distress+Muster — contact → more signal → more agents → a self-growing response from local re-broadcast.
- **Flocking (priority budget, corrected 07-25):** boids steering where keep-apart outranks bunch-together **by allocation, not by weight** — each agent has an acceleration budget, separation claims from it first, and only the remainder goes to cohesion/alignment; influence falls off as 1/d². Weighted *averaging* fails precisely when two steering requests oppose (the average of "left" and "right" is "straight into the doorframe"), which is the doorway jitter we do not want. Gap still scales to agent size — loose formation with visible gaps.
- **Stand-down:** a hunting agent not sharing the intruder's chamber whose local signal stayed faint ~5s exits the combat state.
- **Room-danger / threshold-holding:** the collective tracks chambers that have hurt it persistently; a lone agent at such a chamber's doorway **holds and emits Muster** instead of entering alone; the group crosses together once enough force gathers.
- **Trails:** a searching agent marks the doorway it commits to; markers fade unless reused; later agents weight toward heavily-marked doorways → traffic self-organizes into lanes.
- **Raid (multi-approach fan):** ~1/3 of committed searchers take their **second-best** route so a push fans across multiple paths and reaches from multiple directions.
- **Adaptive counter-biasing** — learn how this intruder fights, bias later reinforcement mixes toward counters.
- **Evidence relay** — messenger agents carry evidence (remains, damage signatures) to a coordination chamber where it accumulates (feeds the counter-biasing).
- **Counterplay reward** — repeating one tactic makes the future counter increasingly effective; switching tactics measurably slips it.

**Hub as an emergent place:** it reads as a hub because of **what has gathered there** (off-map safe chamber + whatever a breach grows where it links in, cut into an ordinary chamber's wall wherever a spotter transmitted from) — the same way a firebase reads as a firebase from clustered pods and turrets. It deliberately does **not** use the level's own function tags, because the Adversary is a post-construction infestation.

---

*Revert bookkeeping: reverted `rewrite` to `d85d3765` (2026-07-19 13:56 — the last commit before the director's first-playthrough full clear, recorded in `out/director_fc/`; this is before coordination, reinforcements, and the CUCULUS building economy). The discarded 07-20 → 07-25 work is recoverable at `94b3397b` (git reflog), so nothing is lost — the AI's coordination/reinforcement implementations, the pygame-free renderer (`203da395`), and all commit history remain there to reference while rebuilding from this doc.*
