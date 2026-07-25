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
- **A core kill is a status effect the player applies to the enemy.** The reinforcement layer goes down for **a couple of minutes** (tune deep-negative depth × regen rate to that spec), then the core comes back as soon as its reserve climbs above zero. Use it tactically — cut off a fortified area's reinforcements before charging it. Until the core is destroyed, breaches keep being called in.
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

# Open design units (from the 07-25 Q&A)

- **The hub area** — an entire game area unto itself (a corrupted Testator construction); layout, approach, guardian ring.
- **Vagrant & lacuna** — the two Adversary spotter classes have only ever been placeholders; design them for real (stats, silhouettes, behaviors, which is the weaker).
- **The CORE as an organ** — a system of agents with regeneration and its own defense, not a static NPC.
- **Leader AI** — deferred; garrisons emerge around oblivious leaders for now.
- **Find/senses API** — the query shape of the shared perception infrastructure.
- **Pheromone scrubber / cleaning robot** — costs, damping strength and coverage, component-emission rate.

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

The room stores what simulation tick it was last updated on; decay is always computed from the delta. This makes it so a room that has stopped recieving or is recieving updates less often decays at the same effective rate.

Distress is the inflammation analogue and behaves like real-world inflammation: it responds only to **agents being harmed** (there is no structural damage in this game); it integrates under a persistent stimulus and resolves when the stimulus stops.

**Coordination behaviors (the designed TARGET — none verified live; build and verify each):**

*Not "shipped." **The reverted base (`d85d3765`, 07-19) predates ALL of this — none of the coordination behaviors or the signal fields exist in it yet; it is all to be built.** And what was later built (07-20 → 07-23) was never confirmed working: the coordination never got a chance to show (a sparse stomp — "the enemies just don't have any chance to react"), and reinforcements never reached the player. The signal set above is a redesign. Treat every item as a spec to implement and verify against a real run, not as existing behavior.*

- **Chemotaxis:** patrolling agents climb the Distress gradient, looking for trouble, refusing to enter rooms with high Danger
- **Quorum:** idle agent wakes when combined Distress+Noise crosses a **per-agent-varying** threshold — a chamber cascades over a second or two, no order given.
- **Relay-recruit:** agents in a "target in sight" state emit Distress+Muster — contact → more signal → more agents → a self-growing response from local re-broadcast.
- **Flocking:** boids steering, **keep-apart weighted above bunch-together**, gap scales to agent size — loose formation with visible gaps.
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
