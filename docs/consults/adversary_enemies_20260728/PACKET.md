# PERIHELION — ADVERSARY ENEMY DESIGN: FINAL RESEARCH PACKET

**Date:** 2026-07-28 · **For:** final synthesis pass, then the director
**Deliverable this packet provisions:** replace the two placeholder Adversary units (`vagrant`,
`lacuna`) with final designs, and fill out the distributed strategic response around them.

Everything in this document is stated in tactics and game-design language. No source-domain
vocabulary appears anywhere in it. Where a mechanism came from a reading lane, it is carried
here as mechanism only.

---

## 1. WHAT THIS PACKET IS

### 1.1 The situation on screen

The player is a single Commando inside a station he does not own. He is the **intruder**. He
is outnumbered and undergunned, so he prepares ground — plants pods, turrets, repair
stations — and when he bites off more than he can chew he falls back. Falling back has to be
fought for, not free.

Everything that fights him belongs to one defending **swarm**. The swarm is decentralised
and non-conscious. It has **no commander** and no unit whose shutdown ends the response.
Removing any one agent **thins** it. It coordinates entirely through **nine scalar signal
fields**, one value per chamber, spreading hop-by-hop across the portal graph and decaying by
half-life. An agent's whole legal view of that medium is **its own chamber and chambers one
portal away** — there is no deeper query, no map, no global view. Sight is separate and
raycast-confirmed at whatever depth the geometry allows.

Reinforcements do not instantiate. They come from an off-map **reserve** (the dispatch fabric) through
**breaches** that an agent must physically travel to, stand still in the open, and broadcast
to open. The dispatch fabric is structurally blind to the fight: its regeneration reads only how empty
its own depot is.

### 1.2 The two lanes — the whole point of this program

The defending swarm is two populations with completely different worth, and today the game
does not show the difference on screen.

**TESTATOR lane — equipment and wildlife.** Repurposed local chassis: `mite`, `husk`,
`spitter`, `brute`, `warden`, `shrieker`, `flicker`. Produced by the CORE, paid for out of
reserve on a dispatch sheet (mite 1 → warden 8), thrown at a firebase without a second
thought, left lying where they fall. The swarm does not care if one shuts down on an errand. It
does not care if a hundred die at a doorway. Testator chassis **cannot call** — they only
fight.

**ADVERSARY lane — precious, finite, non-renewing personnel.** The interdimensional invaders
themselves. Authored into the world at build, **never produced by the CORE**, counted in a
**census that only ever goes down**. Only they can call a breach. Exterminating them
permanently disables called reinforcement — which is intended, and in practice near
impossible, because the stream they call keeps protecting them.

Three consequences the synthesis must honour:

1. **Anything the swarm spends freely is Testator.** The courier that carries evidence back
   to the control centre and the hauler that drags a wrecked chassis there are Testator,
   because the swarm does not care whether they arrive.
2. **Judgement is Adversary.** Anything that authorises, licenses, or decides on behalf of
   others is Adversary personnel.
3. **The Adversary cannot stay.** Ordinary space is zero-Otherworldness and it wears them
   down. An Adversary chassis carries a **dwell budget** and must **withdraw into a live breach**
   before it empties. Withdrawal is the Adversary's *normal* outcome; shutdown is the exceptional
   one. **The census falls only when the player denies the withdrawal.** That is the
   director's new mechanic and it is the spine of this whole packet (§4).

### 1.3 What is being replaced

Today the Adversary lane is two chassis that differ in almost nothing:

| | `vagrant` | `lacuna` |
|---|---|---|
| hp | 84 | 42 |
| speed / turn | 1.45× Commando / 0.55× | 1.20× / 0.50× |
| rooted broadcast | 6 s (8 s total exposure) | 8 s (10 s total exposure) |
| everything else | identical loop | identical loop |

Both run one state machine (creep to the edge of the hot zone → brace → take the world's
single call-medium lease → rooted, fully exposed broadcast → leave an imprint → watch → then
alternate expansion legs, quiet ground and danger peak). `lacuna` is the weaker **class** and
therefore calls first. That is the entire axis of difference: hit points and broadcast length.
It is not enough to carry two units, and it is what the director asked to be fixed.

### 1.4 How to read this packet

- §2 is the **role map**: every job in the response, who fills it, which lane, and what is
  still empty.
- §3 is the **catalogue**: 49 surviving mechanisms, deduplicated across lanes, grouped by
  role rather than by which lane found them.
- §4 is the **environment-dependence dossier**: everything the sweep found about a population
  that cannot survive outside its own ground. It gets its own section because it is the spine
  of the Adversary lane and because two lanes answered it differently.
- §5 is what the critics rejected, my ruling on each, and the gaps still open.
- §6 is the open questions the synthesis has to actually decide.

Entries marked **RECOVERED** were produced by a reading lane, dropped before the catalogue
was assembled, and are reconstructed here from the lane's own record. They are real
mechanisms, but they have had one pass fewer against the shipped code than the rest — treat
their engine-fit claims as claims, not verifications.

---

## 2. THE ROLE MAP

Twenty-three jobs. **17 filled, 6 empty.** Empty rows are the ones the synthesis has to
either design or explicitly decline.

| # | Job | Lane | Why that lane | Filled by |
|---|---|---|---|---|
| 1 | **Standing pickets** — the first Noise spike when the intruder crosses | Testator | Cheap resident watchers the swarm expects to lose at the crossing they watch | RIM (1), WATCH-ROOT (2), TRIPWIRE (3) |
| 2 | **Alarm amplification** — units in contact re-broadcast Distress + Muster, so the response grows itself from local re-broadcast | Testator | The chassis in contact are the cheap ones | **Ships** (relay-recruit) |
| 3 | **Gradient hunters** — climb Distress, refuse chambers above the danger hold line, hold at a doorway emitting Muster instead of entering alone | Testator | Patrol stock, spent freely | **Ships** |
| 4 | **Marking** — paints the intruder so others aim, commit and converge; the mark outlives the marker | Testator | The shrieker's job; it shuts down constantly | **Ships** (shrieker) |
| 5 | **Warrant / authorisation** — fights nothing, licenses specialists; its shutdown thins, never stops | **Adversary** | Judgement is precious personnel work by the lane rule | WARRANT (13), HERALD (14), CONFIRM (15) |
| 6 | **Licensed execution** — engages only a marked, warranted target; otherwise inert-but-mobile | **Adversary** | The lane's only top-end chassis; the swarm withdraws it rather than lose it | EXECUTIONER (16), RELEASE-AND-REACQUIRE (17) |
| 7 | **Kin-check enforcement** — attacks whatever fails to read as one of theirs; the hook for punishing a player who wears or carries Adversary material | **Adversary** | An identity ruling, not a reflex | **EMPTY** — see §5.2 |
| 8 | **Area denial** — residue that costs the player ground and time, not hit points | Testator | It is the residue of chassis that were spent | CHAFF (4), CAUSTIC CHAFF (5), SNARE MAT (6), CORDON WEB (7), DRAG FIELD (8) |
| 9 | **Cordon-seal / walling-off** — when the intruder cannot be killed, seal him in and starve it | Both | Testator chassis do the standing; the decision to stop attacking is Adversary | **EMPTY** — both candidates rejected, see §5.2 |
| 10 | **Suppression and resolution** — end a response so the swarm does not burn its reserve on an empty chamber; the counterweight to signal overheat | **Adversary** | A chassis that decides the fight is over on everyone's behalf | DAMPER (19), SURGE CAP (20) |
| 11 | **Recruitment and dispatch** — finite reserve, cost-fair queue across live breaches, strike-package composition, a guardian shelf that genuinely empties | — | The dispatch fabric owns it | **Ships**; extended by POUR SURGE (47) |
| 12 | **Breach opening** — travel to quiet ground behind the line, take the single call-medium lease, stand still and fully exposed for the whole broadcast, leave an imprint the dispatch fabric may or may not answer | **Adversary** | Only personnel can call — ratified | **EMPTY of replacements.** Filled today only by the two units being deleted. **This is the deliverable.** See §5.2 |
| 13 | **Courier to the control centre** — physically carry evidence of how the intruder fights back through a live breach to the Scriptorium | Testator | The swarm does not care if it shuts down on the way | HAULER (9), LADEN (10), SPILL (11) |
| 14 | **Memory of a repeat intruder** — counter-biasing toward counters, and a measurable slip when the player switches tactics | — | Ledger is hub-side; per-chassis memory is on the chassis | **PARTIAL / EMPTY** — VETERAN (48) and LEDGER BIAS (49) cover accumulation; **nothing specifies forgetting or the slip.** See §5.2 |
| 15 | **Clean-up of the dead** — drag a wrecked chassis to the control centre; clear the swarm's own dead, which damps Distress and thins the future response | Testator | The director's explicit example, and the swarm spends these freely | HAULER (9), REANIMATOR (12) |
| 16 | **Environment shift** — Otherworldness rising in ground the Adversary holds: both the tell that ground has been taken and their own runtime support | **Adversary** | It is what they do to geometry, and what keeps them operational | LOCAL UNFOLDING (21), ANCHOR (22) |
| 17 | **Garrison and entrenchment** — followers settling behind an oblivious leader, holding a cluster, works that make retaking expensive | Both | Testator chassis settle; Adversary personnel shelter inside | **Ships**; extended by LOCAL LEVY (39), RE-TILE (40), GAP-FILL (41), WARD-TENDER (42), OCCUPANCY CAP (43), BLOOM (44), SHELL (45) |
| 18 | **Reserve husbandry / withdrawal discipline** — personnel spend a dwell budget in ordinary space and withdraw before it empties; census falls only when the player denies it | **Adversary** | The director's new mechanic; the definition of precious | MOORING (23) and the whole §4 family (24–38) |
| 19 | **Residents** — the non-Adversary population already occupying the hub and any taken ground, reading visibly lighter than a delivered strike package | Testator | Already-present local stock | **Ships in the hub**; extended off-hub by LOCAL LEVY (39), OCCUPANCY CAP (43), BLOOM (44) |
| 20 | **Dormancy** — units inert with high thresholds until a real disturbance, so clearing visible pressure does not clear the census | **Adversary** | The census is what dormancy protects | DEEP DORMANCY (46), EMBER DOCTRINE (29) |
| 21 | **Traffic control** — doorway trail marks self-organising movement into lanes, arrest positions at chokes, the raid fan down second-best routes | Testator | Ordinary push stock | **Ships** |
| 22 | **Anti-structure specialists** — prioritise pods, turrets and repair stations over the player, so a firebase decays under pressure | Testator | A chassis sent to die against a turret | **EMPTY** — and it does not "partly exist"; see §5.2 |
| 23 | **Barrier and lifeline denial** — pressure that follows the player through his own shortcuts, including small chassis through a Portable Hole aperture | Testator | Only the small cheap chassis fit | **EMPTY** — see §5.2 |

**Empty: rows 7, 9, 12, 14, 22, 23.** Row 12 is the deliverable itself and is the single most
important hole in this packet.

---

## 3. THE CATALOGUE

49 mechanisms. Each card gives lane, the eight required answers in compressed form, the
player's counterplay, how it sits on the shipped systems, and the observation that would
prove it was not built as specified.

Card key — **L** lane · **TRG** trigger · **PER** perception · **ACT** action · **CST** cost ·
**TIM** timescale · **RES** residue · **TELL** on-screen read at 0.45 zoom in a 640×360 frame,
no HUD text.

---

### 3.A — STANDING PICKETS (role 1, Testator)

Three different answers to "something crossed here." They are not interchangeable: RIM owns a
doorway, WATCH-ROOT owns a chamber and never leaves it, TRIPWIRE spends itself once and loudly.

#### 1. RIM
- **L** Testator. **TRG** any Noise, Trail, or sighted contact inside its own chamber; no
  quorum wait — it is its own audience of one. **PER** own chamber only, plus raycast sight.
  **ACT** holds position with steering biased hard at the one doorway it is posted at;
  engages anything that crosses; **never pursues past that doorway** — if the target steps
  back across, RIM returns to post and re-engages only if it re-enters. **CST** reserve,
  cheapest tier. **TIM** immediate; no build-up. **RES** an ordinary chassis. **TELL** it is the
  one enemy that reliably lets the player walk away once he is back through a specific
  doorway, mid-fight. That disengage is the tell; no ring.
- **Counterplay** the boundary is absolute and learnable. Bait it, step back one doorway, and
  you are safe. It makes a crossing cost something once, rather than being a standing threat,
  so a player who knows the layout routes around the chamber it holds.
- **Engine fit** `sim.py` already ships a posted-guardian primitive (a per-entity tether flag
  set from `spec.props` at instantiation) that holds position, waives pursuit, and fights through the
  doorway rather than chasing. RIM is that flag plus **one** new datum — an edge id, so the
  steering bias points at a specific doorway instead of the chamber generally.
- **Falsifier** RIM seen more than one chamber from its post, or chasing across two doorways.

#### 2. WATCH-ROOT — **RECOVERED**
- **L** Testator. **TRG** a hostile arriving in its own chamber — it never goes to the fight,
  the fight comes to it. **PER** own chamber only. No one-hop read at all; this is the
  cheapest perception on the roster and the reason it is affordable in numbers. **ACT** it is
  rooted: it does not patrol, does not travel, does not answer Muster from anywhere. On
  contact it fires a fast, short-reach Distress + Muster write into its own chamber and the
  one hop out — the standard relay-recruit emission, from a chassis that was already there.
  **CST** reserve, cheapest tier; placed as resident stock rather than dispatched to a fight.
  **TIM** fires within a tick of contact; contributes nothing afterwards. **RES** a chassis.
  **TELL** it is the only enemy that is standing still in an empty chamber before the player
  arrives and does not walk toward him — it turns in place and shouts.
- **Counterplay** it cannot be drawn out. A player who wants a chamber quiet has to enter it
  and kill the thing in it; there is no baiting it into a corridor. Killing it before it
  emits is a real timing play — it is the first Distress write in most chambers.
- **Engine fit** a settled, non-patrolling chassis reusing the existing relay-recruit write; no
  new field, no new sensing.
- **Falsifier** a WATCH-ROOT observed walking toward a fight in an adjoining chamber.

#### 3. TRIPWIRE — **RECOVERED**
- **L** Testator. **TRG** contact or near-contact in its own chamber. **PER** own chamber,
  contact-range only. **ACT** discharges its whole response in **one shot**: an oversized,
  one-off Distress + Muster burst plus a **SNARE MAT (6)** laid where it stands, then it is
  **spent** — it cannot repeat, keeps moving, and fights only with weak contact damage until
  killed. **CST** reserve, cheap; the swarm accepts one-use chassis. **TIM** the burst is
  under a second; the spent state lasts until it shuts down. **RES** a snare mat plus a chassis.
  **TELL** the discharge draws on the chassis as a single hard flash, and the chassis afterwards
  visibly moves differently — slower, no longer closing.
- **Counterplay** it has exactly one dangerous moment. Trigger it from range, or accept the
  burst and take the ground while it is spent. A player who learns which chassis this is stops
  wasting ammunition on it after it has fired.
- **Engine fit** existing relay-recruit emission at a larger amount, once, plus the area-denial
  substrate (see 6). Per-agent state: one spent flag.
- **Falsifier** a TRIPWIRE firing a second burst, or standing still after it has fired (a spent
  chassis must keep moving — no unit may freeze in an active state).

---

### 3.B — MASS RESPONSE AND AREA DENIAL (roles 2 and 8, Testator)

This group is the brief's own worked example, plus the pieces that make it a system rather
than a debuff. **All area denial in the game must sit on ONE substrate.** No movement-multiplier
or area-denial zone system exists anywhere in the codebase today, so whoever builds the first
one owns it for all of them. Cards 6, 7 and 8 are one mechanism with three triggers.

#### 4. CHAFF — **RECOVERED** (this is the brief's WORKED EXAMPLE 1)
- **L** Testator, **dispatch cost 1** — the cheapest thing the dispatch fabric will pay for. **TRG**
  any Noise above the picket line in its own chamber or one hop away. **No quorum check** — it
  does not wait for peers and it never evaluates Danger, so it walks into chambers a patroller
  would refuse. That is exactly why it is the thing the player meets first. **PER** one-hop
  fields plus sight. **ACT** straight-line commit up the strongest Noise gradient; touch damage
  only; no ranged, no disengage. **CST** reserve, spent faster than anything else on the sheet.
  **TIM** shuts down inside one engagement. It is also disposable **on a clock** — an unengaged chaff
  chassis expires and quietly stops rather than loitering as a standing threat, so a corridor the
  player avoided does not accumulate a garrison of them. **RES** a **SNARE MAT (6)** where it
  fell. **TELL** a chassis-drawn splash under the disabled chassis that stays after the disabled chassis is gone.
  No ring, because a ring means aggro.
- **Counterplay** killing chaff is cheap and always available — but a corridor that killed
  twenty of them is a corridor the player cannot fall back through at speed. That is the point:
  it makes killing chaff a decision instead of a freebie, and it is the mechanical answer to
  "falling back must be fought for, not free."
- **Engine fit** ordinary dispatch stock reading existing Noise; the residue needs the new
  area-denial substrate (6).
- **Falsifier** chaff that waits for quorum, refuses a high-Danger chamber, or leaves no mat.

#### 5. CAUSTIC CHAFF — **RECOVERED** (the kin-misfire variant)
- **L** Testator. **TRG** identical to CHAFF. **PER** identical. **ACT** on shutdown it releases a
  short-range damaging burst instead of a pure movement residue — and the burst **does not
  check side**. Its own-side splash **scales with local crowding**: one caustic chassis failing in an
  empty corridor hurts only the player; six failing in a packed doorway visibly kill each other.
  **CST** reserve, cheap. **TIM** the burst resolves instantly on shutdown. **RES** a smaller,
  hotter mat. **TELL** the swarm visibly damaging itself in a crowd — a chassis-drawn burst that
  makes neighbouring chassis flash their own hit reaction.
- **Counterplay** this is the only mechanism in the packet where the player can make the swarm
  hurt itself, and it is deliberately learnable: **funnel them.** Fighting a dense push at a
  doorway is rewarded, not just survivable. It is also the closest thing the packet has to a
  comedy beat — the response over-committing and paying for it.
- **Engine fit** an on-shutdown damage event with no side filter; density is read as the count of
  chassis in touch range, the same local read flocking separation already does.
- **Falsifier** a caustic burst that never damages another Testator chassis no matter how crowded.

#### 6. SNARE MAT
- **L** field/structure — the residue itself, and the substrate all area denial in the game
  should share. **TRG** deposited by a chassis failing (chaff, tripwire) or by a specific attack.
  **PER** none — it is floor. **ACT** applies a movement penalty to **anything** crossing it,
  player and swarm alike. It is **side-blind**; the swarm pays the same tax routing its own
  reinforcements through it. **CST** nothing standing. **TIM** decays on its own short
  half-life (order of twenty seconds), independent of the fight that made it. **Passage
  re-arms it to full rather than stacking it without bound** — the existing Trail idiom, so a
  much-used corridor does not accumulate an impassable floor. **RES** it *is* the residue.
  **TELL** a floor decal that outlives the disabled chassis. The floor is one of the few genuinely
  unused tell channels in the game (see §6.7).
- **Counterplay** ground you won is not ground you can retreat through at speed. Sweeping a
  corridor clean and *then* falling back is a different plan from falling back through the
  sweep.
- **Engine fit** **new substrate.** One per-chamber-or-per-patch decaying scalar plus one
  movement-multiplier read at the physics step. Structurally parallel to how Danger is stored.
- **Falsifier** mats that slow only the player and never a reinforcing chassis.

#### 7. CORDON WEB — **RECOVERED**
- **L** field/structure. **TRG** enough mats laid close together inside one time window —
  a mass-shutdown event in one place, not a scatter of single kills. **PER** none. **ACT** the
  mats **fuse** into an actual barrier that separates the two sides of the chamber, rather than
  merely slowing traffic across it. **CST** nothing standing; it is bought entirely with
  Testator chassis the player himself killed. **TIM** a longer half-life than a single mat,
  but still a half-life — it always dissolves. **RES** it is the residue. **TELL** the mats
  visibly join up: separate floor patches merge into one continuous shape.
- **Counterplay** this is the swarm's honest answer to a killbox. Grinding a hundred chassis in
  one doorway eventually walls that doorway — with their remains. It is also the answer to the
  standing "killbox question": it degrades a fixed firing position **without** touching enemy
  hit points or damage.
- **Engine fit** a fusion threshold on the mat substrate (6). One mechanism, two triggers —
  never two systems.
- **Falsifier** a web forming from mats laid minutes apart, or from a handful of scattered kills.

#### 8. DRAG FIELD
- **L** field. **TRG** a chamber whose **Danger has held above the hold line (0.70) for a
  sustained stretch** — a real fight, not one shutdown. **PER** own chamber. **ACT** lays a
  chamber-wide movement tax on the same substrate as (6), side-blind. **CST** none standing;
  the swarm pays it too, on its own reinforcement traffic. **TIM** its own long half-life,
  independent of the Danger reading that created it. **RES** it is the residue. **TELL** same
  floor channel, at chamber scale rather than patch scale.
- **Counterplay** **winning fast never triggers it.** Speed is the counter. Once it exists,
  holding the ground can beat retreating through it, because the next wave pays the same tax.
- **Engine fit** same substrate as (6), different trigger and different granularity. It is
  explicitly **not** a second system.
- **Falsifier** a drag field appearing after one quick kill, or slowing only the player.
- **Note for synthesis** cards 6 and 8 push in opposite directions on pace (mats punish grinding
  through a corridor, drag punishes letting a fight run long). See §6.6.

---

### 3.C — LOGISTICS: HAULERS, CLEAN-UP, AND WHAT COMES BACK (roles 13 and 15, Testator)

Four lanes independently designed the same chassis four times (Retriever, Courier, Clearance,
Carrier) plus a fifth object for it to carry. At 0.45 zoom they are all the same read: a
non-combat chassis picks something off the floor and walks away from the fight. **They are merged
here into one class with three cargo types.**

#### 9. HAULER
*(the merge of Retriever + Courier + Clearance + Carrier + the recovered UNDERTAKER and GLEANER)*
- **L** Testator, cheap dispatch tier. **TRG** it senses, in its own chamber or one hop, an
  unclaimed cargo **while that chamber's Danger has fallen back under the hold line** — it
  will not work an active fight. Three cargo types, in priority order:
  1. **a wrecked player chassis** — the player's lost salvage, hauled through a live breach to
     the Scriptorium at the control centre;
  2. **the swarm's own dead** — a short haul, one or two chambers, into an adjoining chamber
     with lower Distress;
  3. **a disabled chassis as evidence** — the chassis itself is the record of how it shut down; the game already
     threads a damage-source string through every kill and every shutdown trace, so **no fifth
     floor object needs to be invented** for the ledger to have a payload.
- **A disabled chassis is not a valid target the instant it falls.** It becomes claimable after a short
  window. **That window is the player's loot race** — get back to your own wreck before the
  window opens and it is still yours.
- **PER** one-hop fields plus the existing find/senses API; a wrecked chassis already persists
  as a pickup entity after shutdown, so it is already something the find API can see. Inside the
  control centre it stops sampling fields entirely and walks the fixed hop-distance route to
  the Scriptorium, reusing the same nearest-landmark-by-hop-distance lookup the existing
  nearest-station search already performs, aimed at a different landmark.
- **ACT** picks the cargo up (removing it from the floor), enters **LADEN (10)**, and routes
  home. It carries no weapon and will not engage; it detours around any chamber whose Noise or
  Danger is climbing rather than crossing it.
- **It has a finite carry bout.** After clearing enough material it measurably slows and has to
  return and unload before it works at full rate again — never an unlimited vacuum.
- **CST** reserve, cheapest tier. Losing one costs the swarm nothing but the cargo it drops.
- **TIM** the haul is tens of seconds. **An uncleared own-side chassis keeps writing a small
  trickle of Distress every few seconds until a hauler moves it** — that is the whole reason
  clean-up matters, and it is one extra periodic writer against a call site that already
  exists (a failing agent already writes Distress once on shutdown).
- **RES** nothing of its own; it *removes* residue. **TELL** it carries a visible load on its
  back — the same visual grammar as the player carrying a pod, reusing the shipped carried-load
  draw. It walks **away** from the fight while everything else walks toward it.
- **Counterplay** three real, different plays:
  - **Race it.** A player who wants his salvage back has to beat a hauler to his own shutdown site,
    which puts time pressure on the walk-back the shutdown rule already imposes.
  - **Kill it.** Killing haulers on sight starves the ledger and keeps chambers loud. That is a
    genuine trade, not a free win: **leaving your own kills lying where they fell keeps a
    chamber's Distress elevated and the future response fatter, but it also keeps the swarm's
    attention there.** Letting haulers work calms a sector for a quieter return, at the price of
    the swarm learning about you.
  - **Let it go and take it back later.** A hauler that gets the wreck home turns a loss into a
    reason to run a hub raid the player might otherwise skip.
- **Engine fit** existing Danger gate, existing find/senses API, existing doorway-trail routing
  bias, existing carried-load draw, existing nearest-landmark hop lookup. New per-agent state:
  a laden flag and a carried-object reference — the same shape as the player's own carried-pod
  state.
- **Falsifier** haulers pathing to a wreck through an active firefight; a killed hauler whose
  cargo vanishes; a chamber whose tension resets on the same timer whether or not its dead were
  cleared.

#### 10. LADEN
- **L** shared behavioural mode, not a chassis. **TRG** holding cargo. **PER** unchanged — same
  one-hop sampling, different targets. **ACT** while laden, a unit **stops sampling whatever
  field sent it looking for work** and instead climbs Kin upward and Danger downward — the
  direction reversal a carrier shows the moment it stops looking for trouble and starts looking
  for its own side. **Laden units stop answering Muster and relay-recruit** — they will not join
  a fight while carrying, which is also how the player identifies one mid-haul as
  not-right-now-hostile. **If no route home exists** (every breach cordoned, the reserve spent),
  a laden unit **settles** at a quiet chamber under the same conditions a garrison follower
  already uses (Danger low, Noise low, held about twelve seconds), keeps its cargo, and patrols
  short loops rather than standing still. It resumes the moment Kin starts rising in its
  neighbourhood again. **CST** none. **TIM** as long as the haul. **RES** none. **TELL** the
  carried load plus the visible refusal to turn and fight.
- **Counterplay** a player who has cordoned every breach in a region gets to watch cargo stack
  up at one or two predictable forward waypoints — a huntable stash, and a second way to deny
  the swarm's memory short of a full hub raid.
- **Engine fit** one boolean and a carried-object reference, read by the gradient-climb code
  every field consumer already runs. The settle path reuses the shipped garrison-follower
  conditions directly.
- **Falsifier** a laden unit answering Muster, or standing motionless indefinitely when denied a
  route (a direct no-freeze violation).

#### 11. SPILL
- **L** interruption rule attached to LADEN. **ACT** on a laden unit's shutdown its cargo **drops
  at the shutdown position** as an ordinary floor pickup, indistinguishable from one never picked
  up, and fades on the same residue timer. Nothing a carrier holds is ever simply deleted.
  **TELL** the load visibly leaves the chassis and lands.
- **Counterplay** intercepting a hauler near your own shutdown site gets your salvage back on the
  spot — a cheaper resolution than invading the hub for it. That choice is the whole point.
- **Engine fit** reuses the drop-and-instantiate-pickup call already used for the player's own shutdown.
- **Falsifier** cargo vanishing with the chassis.

#### 12. REANIMATOR — **RECOVERED**
*(the answer to "the hauler's cargo goes in and nothing comes out")*
- **L** Testator. **TRG** an inert chassis lying unclaimed in a chamber whose Danger is under the
  hold line — a player kill, a resident, or an Adversary chassis. **PER** own chamber and one hop.
  **ACT** a small, cheap, unthreatening crawler lands on the chassis and, over a **visible dwell
  period**, converts it into a new hostile Testator-lane unit that then behaves like ordinary
  dispatch stock. The crawler supplies only direction; the chassis it lands on does the work.
  **This is the mechanism behind "reanimated chassis," which the ratified design already names
  on the Adversary's non-caller roster and has never explained.** **CST** reserve, cheapest
  tier for the crawler; the resulting chassis costs whatever its class costs. **TIM** the
  conversion is slow enough to be interrupted — that is the whole play. **RES** if interrupted,
  the chassis stays a chassis. **TELL** a small thing sitting **on** a disabled chassis, working, for several
  seconds. A chassis event drawn on the chassis — no ring.
- **Counterplay** shooting the crawler mid-conversion is cheap and always available, which
  makes leaving a battlefield unattended a real cost. It also gives the player's own wrecked
  chassis a second possible fate: **the player must recognise his own wrecked chassis walking
  at him.** That is a strong art-direction claim and it must be checked against the authorship
  lanes before it is proposed — the corrupted chassis has to still read as Testator handcraft
  under its defacement, never as invader chaos.
- **Constraint** the CORE never produces Adversary personnel and the census never grows, so
  **anything that comes back is Testator lane, cheap, and probably wrong in some legible way.**
- **Falsifier** a conversion that completes instantly, or that produces an Adversary-lane chassis.

---

### 3.D — AUTHORISATION AND LICENSED EXECUTION (roles 5 and 6, Adversary)

The cleanest demonstration of the no-commander law the design has: a unit that fights nothing,
whose shutdown makes specialists inert without stopping chaff, pickets, patrollers or breakers.
Two lanes produced these, they were orphaned, and they are recovered here in full.

#### 13. WARRANT
- **L** **Adversary.** Authored into the world at build, never produced by the CORE, counted in
  the census. **It has no attack of any kind.** **TRG** it moves toward — never into — chambers
  where Danger is rising. **PER** own chamber and one hop, like everything else. It does not
  know where its executioners are and they do not know where it is; the coupling is the field,
  never a pointer. **ACT** climbs toward the highest adjacent Danger **below 0.35**, refuses
  anything at or past it, and holds at the last safe chamber — the same "as close as is safe"
  shape the caller already uses, on a **different** composition, so it reads as the same caste
  doing a different job. While holding, it writes a short-reach authorisation over its own
  chamber and one hop out. **It is the only class that writes that field.** **CST** census.
  **TIM** its authorisation rides a **fast half-life (seconds, well under Kin's 8 s)**, so
  losing the writer and drifting out of its reach show up as the same reading — the field
  crossing its floor — inside about one to two seconds. Its own dwell budget is deliberately
  tuned **longer than a single engagement**, so a warrant expiring on its own clock is the rare
  case and **the player denying it is the common one**. It carries a real withdrawal phase and
  walks toward a breach when it runs low, continuing to write the whole way so the licence
  visibly recedes with it rather than cutting off in place. **RES** on shutdown, the ordinary loud
  shutdown plus the enlarged deposit of TOLL (18). **TELL** it is the only unit on screen that
  walks toward a fight and never shoots. The licence itself draws **on the executioner's chassis**,
  as a slow chassis-anchored pulse — not as a ring, and not on the warrant.
- **Counterplay** it never fires a shot, so a player who identifies it can kill it for the price
  of walking into its stand-off range once — after which nearby specialists go inert within a
  second or two, not instantly, leaving a beat where they are still dangerous. A sharper player
  baits it to hold at a doorway and kills it from the safe side without ever crossing the line
  it was guarding. Cutting the portal it needs to reach its breach is a slower, separate play
  against the same chassis: **cordon the breaches and you starve the licence out of an area without
  ever getting a shot at the unit.**
- **No-commander compliance** killing it does not stop the response. Chaff, pickets, patrollers
  and breakers all fight on exactly as before. It only makes the specialists inert. It is a way
  of thinning, never of switching off.
- **Engine fit** reads Danger through the ordinary one-hop neighbourhood; reuses the shipped
  `HIGH_DANGER_ENTER = 0.35` constant for its hold line — deliberately **not** the caller's hot
  composite, which belongs to a different job. Writes **one new per-chamber scalar**, reach of
  own chamber plus one hop.
- **Falsifier** WARRANT attacking; or standing frozen at the hold line with its dwell bottomed
  out instead of turning to withdraw.
- **Ruling recorded** a two-tier authorisation chain (something that licenses the warrant, which
  then licenses the executioner) was considered and **declined**: the extra tier adds no
  distinguishable on-screen behaviour, and the reason holds even now that the warrant itself
  must withdraw, because the warrant's dwell is tuned to outlast the fight it authorises.

#### 14. HERALD
- **L** **Adversary.** **TRG** it advances up the Noise/Distress gradient like a caller, but
  **will not fire its effect until it has an actual raycast-confirmed line of sight to the
  intruder** — a hot field reading is not enough. **PER** one-hop fields plus raycast sight.
  **ACT** on confirming, it forces the local quorum's virtual-supporter term to its ceiling in
  its own chamber for a short window, then goes quiet until it re-confirms. It holds no
  permanent broadcast. It **breaks line of sight rather than fight** if approached; it has no
  attack worth risking census over. **CST** census. **TIM** the confirm window is a few
  seconds. Because confirming requires exposing itself to sight rather than merely standing in
  a hot chamber, it **burns risk faster than WARRANT, which never needs sight at all**.
  **RES** loud shutdown plus TOLL. **TELL** a chassis that circles at range and deliberately breaks
  cover instead of closing — and the moment it gets a clean look, the room it is in visibly
  commits noticeably faster than an equally noisy room that has not been confirmed.
- **Counterplay** **deny sightlines and you throttle it specifically**, without touching
  WARRANT. Breaking line of sight measurably slows how fast a corridor turns into a coordinated
  push. That is a distinct, stackable lever from denying the warrant.
- **Engine fit** existing find/senses raycast API; writes into the **existing** quorum formula
  rather than adding a field.
- **Falsifier** a chamber with heavy Noise but no confirmed sighting committing exactly as fast
  as a confirmed one.

#### 15. CONFIRM
- **L** rule, not a chassis. **ACT** on a HERALD confirm, the quorum virtual-supporter term is
  forced to its ceiling in that chamber for roughly three to five seconds instead of being
  computed from ambient Noise + Distress; it decays back to the ordinary formula when the
  window ends or sight breaks, whichever comes first. **Why it is a boost and not a switch:**
  the correct read is a standing local raising of how easily nearby chassis commit, not a one-off
  unlock. **TELL** carried entirely by (14).
- **Engine fit** modifies the existing quorum term for a duration. No new field, no new
  per-agent state beyond the timer HERALD already owns. A chamber with no herald in it is
  entirely unaffected.
- **Falsifier** cascades in a confirmed room taking exactly as long as in an unconfirmed one.

#### 16. EXECUTIONER
- **L** **Adversary.** The lane's only genuinely dangerous chassis. **TRG** it samples its own
  chamber's authorisation field every tick. **Below the floor it moves like an ordinary
  patroller — chases nothing, attacks nothing, and never freezes; it always has somewhere to
  walk.** Above the floor **and** with a Marked target in its own chamber, it commits.
  **PER** own chamber for the field (it only fights what is in its own chamber, so it never
  needs the one-hop reach), plus the existing mark state the shrieker already writes, plus
  sight. **ACT** closes, takes a brief high-damage grip, then **releases and immediately
  reacquires** the next marked chassis in reach rather than grinding one target to zero and
  standing over the disabled chassis. **A grip already in progress is honoured through to its release
  even if the field drops mid-grip; a new grip will not start without a live reading.**
  **CST** census. **TIM** grips are short — seconds. **RES** loud shutdown plus TOLL. **TELL** an
  armed chassis walking calmly past the player when no warrant is in range, turning hostile the
  instant it enters a chamber where a warrant is holding and the player is marked. Kills arrive
  as short grip-release bursts, not one long grind. The licence draws on **its** chassis.
- **Counterplay** killing the warrant (or breaking its reach) is a cheaper way to neutralise it
  than fighting it head-on; killing the executioner while the warrant lives just gets a fresh
  one dispatched against the same authorisation. Learning which of the two pays is the point of
  the pairing.
- **It must not be a second engulfer.** The game already owns engulf (the warden: draw-in, DoT,
  shoot your way out). The executioner's hold has to be mechanically distinct **and** it must
  respect the standing anti-stunlock law — the codebase uses knockback rather than a root
  specifically so a hit chain always breaks. A brief, high-damage, self-releasing grip that the
  unit itself ends is the shape that satisfies both.
- **Engine fit** reads the field WARRANT writes plus the shipped mark state. No pointer to the
  warrant. New per-agent state: which target it is currently gripping.
- **Falsifier** attacking a marked target with no warrant anywhere nearby; or standing
  stock-still mid-fight instead of cycling.

#### 17. RELEASE-AND-REACQUIRE
- **L** rule. **ACT** on grip end (timer or target down) it rescans its own chamber for the next
  marked, authorised target and re-engages within a fraction of a second — no idle beat between
  kills. With no second target it exits the engagement pose and returns to ordinary patrol
  movement rather than standing over the down target.
- **Counterplay** keeping only one target marked at a time denies the chain anything to roll
  into, forcing it to idle-patrol between fights instead of snowballing through a group.
- **Falsifier** one executioner parked on a single target while other marked chassis stand
  untouched in the same chamber.

#### 18. TOLL
- **L** rule on an existing field write. **ACT** an Adversary shutdown — including a failed
  withdrawal — writes its **Danger deposit at a larger initial amplitude** than a Testator shutdown
  in the same spot, then rides the same 180 s half-life. **No new field, no new decay curve;
  only the amplitude at the moment of writing differs by lane.** **TELL** patrollers and
  gradient hunters visibly avoid a chamber where personnel shut down for noticeably longer than an
  equally-fought chamber where only equipment shut down.
- **Why this and not the inverse** an earlier proposal tried to record the same fact by lowering
  **Kin** where personnel shut down. That has the sign backwards: a caller **descends** Kin to find
  thin ground, so scarring Kin would send the next caller straight back to the player's best
  killing ground. Danger is already "this room has stayed lethal," is already descended by
  everything that avoids ground, and already carries the longest half-life in the game. TOLL is
  the correct wire for that intent.
- **Counterplay** baiting personnel to die in ground you intend to hold makes that ground read
  deadlier for longer, discouraging the swarm from recontesting it soon — a reason to
  specifically hunt Adversary lives in ground you want to keep, rather than taking any kill.
- **Engine fit** a one-line amplitude branch on the existing write-on-shutdown path. It does not
  touch the dispatch fabric's census counter; this is purely local and purely legible.
- **Falsifier** patrol avoidance decaying at the identical rate for both lanes' deaths.

---

### 3.E — SUPPRESSION AND RESOLUTION (role 10, Adversary)

Both entries here are **RECOVERED**. Row 10 had no agent in the catalogue at all, and the
engine already ships the exact capability it needs, with no caller anywhere in the game.

#### 19. DAMPER — **RECOVERED**
- **L** **Adversary.** **TRG** rising Distress in its own chamber or one hop out. **PER** one
  hop, like everything else. **ACT** walks toward the rising field and **holds below the danger
  hold line the same way the caller does** — it does not enter the fight. While holding, it
  spends a shared drain capacity per second against its own chamber and one hop out, **removing
  signal-units across the fields proportionally to what is actually there**. It fights nothing.
  **CST** census. **TIM** seconds-scale drain against fields whose half-lives are 1 s (Muster)
  to 45 s (Distress); it works fastest exactly where the response is loudest.
  **RES** loud shutdown plus TOLL. **TELL** this is the most legible of the whole Adversary set:
  **Muster falls, arrivals stop, and the chamber visibly loses interest in the player** while
  a chassis stands at the edge doing nothing. The player sees the response deflate.
- **Why an agent and not a rule** resolution is an **active** job with its own dedicated
  mechanism, not passive fading. A rule that reached in and cut Distress and Muster by a
  multiplier was proposed and rejected (§5.1): the signal substrate's own law is that
  **separation in time comes from half-lives, never amplitude**, and a one-shot multiplicative
  cut makes a chamber's level stop being reconstructible from its emission history. A chassis
  spending a bounded drain capacity is the same effect through the front door.
- **Counterplay** the genuinely novel one in this packet: **killing it makes the response harder
  to shake.** A player who wants a quiet exit lets it work. A player who wants to keep the
  pressure — to farm the stream, to hold the swarm's attention in one sector while he works
  elsewhere — kills it. That is a real reason to leave an enemy operational.
- **Engine fit** **zero new engine work.** `SignalField.drain(polygon_weights, capacity, tick)`
  already exists and is called from nowhere in the game — "remove up to `capacity` signal-units
  total across all nine fields, proportionally to what is there." Weights of 1.0 on its own
  chamber and 0.5 on neighbours match the already-settled signal-scrubber shape. The hold rule
  reuses the shipped danger-hold line.
- **Falsifier** a damper that enters the hot chamber; or a chamber's Muster falling at exactly
  its own half-life while a damper stands next to it.

#### 20. SURGE CAP — **RECOVERED**
- **L** rule inside the dispatch fabric's own dispatch bookkeeping. **TRG** high committed density
  already at a site. **ACT** **the chassis that amplify recruitment desensitise to their own
  recruiting signal once local density is high**, which caps the swarm at that site with no
  central controller. Concretely: a per-chamber dispatch throttle keyed to local Muster and
  committed count, sitting inside the existing cost-fair breach queue. **CST** none. **TIM**
  rides Muster's 1 s half-life, so it releases the moment the crowd thins. **TELL** the stutter
  at a saturated gate — the same reserve-gauge grammar the economy already uses.
- **Why it matters** it is the mechanism that stops the dispatch fabric dumping its whole reserve into
  one doorway. Without it, "signal overheat" — a runaway Muster/Distress cascade the swarm
  cannot stand down from — has no counterweight on the dispatch side, only on the field side
  (19). It also directly addresses the standing killbox risk: a fixed mouth that concentrates
  chassis stops being fed once it saturates.
- **Counterplay** a player who saturates one doorway is choosing to be throttled there; pressure
  goes elsewhere instead. The raid fan already sends a third of a push down its second-best
  route, so what arrives instead is pressure from another direction.
- **Engine fit** inside the dispatch fabric's existing queue — a second input to a decision it already
  makes. **It must not read a signal field directly**; the dispatch fabric's blindness to the fight is
  structural. Feed it the committed count the dispatch side can already see, not Distress.
- **Falsifier** a single doorway absorbing the entire reserve with no throttle.
- **Naming collision** this is unrelated to POUR SURGE (47). Two lanes coined near-identical
  names for unrelated mechanisms. One of them must be renamed before this ships.

---

### 3.F — ENVIRONMENT SHIFT (role 16)

#### 21. LOCAL UNFOLDING
- **L** field — a **tenth** per-chamber scalar, proposed explicitly rather than smuggled in.
  **TRG** presence, not events: any Adversary chassis standing still or settled (not sprinting
  through) continuously writes a small amount into its own chamber. **PER** own chamber, one
  hop, like every field. **ACT** rises where personnel hold ground; decays on a **long**
  half-life once none remain; spreads only a faint fraction one hop — a bleed under the
  doorway, not a broadcast. It is a walkable property of the ground, **never a signal the swarm
  coordinates over**. **CST** none. **TIM** long. **RES** it is the state. **TELL** **this is
  what a held chamber's breathing-wall intensity IS.** A chamber the Adversary has held for
  thirty seconds visibly breathes harder than one taken ten seconds ago; a chamber cleared and
  left alone settles back to still walls.
- **What it does mechanically** it is the scalar an Adversary chassis's dwell budget draws against
  (§4). It is the mechanical reason personnel need to **hold** ground rather than roam it, and
  the reason a player who never lets them settle starves the whole lane's runtime support.
- **Engine cost — priced honestly, and it is not free plumbing.** An earlier estimate claimed
  two render call sites gate wall-breathing on a binary polygon-kind switch and could simply
  read a float instead. Verified, that is wrong in three ways: (i) "otherworld" is an **authored
  polygon kind** assigned at world build by hub depth and validated by a build-time invariant;
  (ii) it drives a soften call that is **one-way** — there is no unsoften anywhere in the
  engine, so breathing walls cannot currently be turned **off** in a chamber; (iii) the render
  side already crossfades on the authored corruption gradient and caches floor colour per
  polygon, so a live float collides semantically with that gradient and invalidates the cache
  every tick. Real work: runtime soften/unsoften in the engine, cache invalidation, and a ruling
  on how a live value composes with the authored gradient so the two do not fight.
- **Cut from the original proposal** an invisible aim-cone and sight-range tax on the player
  standing in high-Unfolding ground. That is the opposite of a tell, and the cost of this ground
  must be paid by the Adversary side, not smuggled onto the player's.
- **Falsifier** wall-breathing intensity identical the instant a chamber flips from zero to one
  Adversary chassis present — that would be the old binary switch with extra steps.

#### 22. ANCHOR
*(recast from OTHERWORLD ANCHOR: it **writes** Local Unfolding, it does not invent a second copy
of that field — two lanes independently proposed the same field and the duplicate is removed)*
- **L** structure. **TRG** built only inside a chamber the swarm already garrisons (a Garrison
  interior reading, never reach alone) — never in contested or unclaimed ground, only behind an
  already-won line. **PER** none. **ACT** while standing it writes a large, steady amount of
  Local Unfolding into its own chamber and, weakly, one hop; personnel inside its reach drain
  dwell at a fraction of the standing rate. **It has no attack and cannot move.** **CST** the
  reserve that builds it; it costs no census. **TIM** if destroyed, its contribution decays over
  a short, **visible** window rather than vanishing — so any personnel caught in that chamber get
  a hard visible readout of running dry, not a silent stat change. **RES** rubble. **TELL** the
  chamber's breathing intensity is the tell (21); the anchor itself is the quiet unarmed thing
  at the centre of a firebase.
- **Counterplay** **attacking the quiet unarmed structure at the centre of a held cluster is
  strictly more valuable than attacking any single chassis standing near it**, once the player
  learns to read it. Destroying it turns every Adversary chassis there overdrawn within seconds and
  forces a visible scramble for the nearest breach.
- **Engine fit** reads the shipped Garrison interior field to gate where it may be built; writes
  Local Unfolding. Nothing else.
- **Falsifier** personnel holding indefinitely in a chamber with no anchor and no breach nearby;
  or destroying an anchor having no visible effect on nearby chassis.

---

### 3.G — DWELL, WITHDRAWAL AND ROUTING (role 18, Adversary)

Sixteen cards. This is the director's headline mechanic and the spine of the lane; **§4 is the
dossier that reads them as one system**, including the two places where lanes disagree.

#### 23. MOORING — *the control law*
- **L** field/rule carried by every Adversary chassis. **TRG** every tick. **PER** **its own
  chamber only** — this is a property of where the chassis is, so it needs no hop-out read.
  **ACT** sample local Otherworldness (21); drain or refill dwell at the rate that scalar
  implies. Continuously compare current dwell against the **low edge**; the instant it is
  crossed, switch movement bias toward rising Otherworldness — the nearest already-held chamber
  or live breach mouth — overriding whatever it was doing, **with no decision tick and no
  broadcast**. While below the low edge it **refuses to advance deeper into falling-Otherworldness
  chambers even if Muster is calling from there.** **CST** it is the cost. **TIM** see §4.2.
  **RES** none by itself. **TELL** GUTTERING (37).
- **Why a band and not a countdown** the recovered source shape is a **continuously sampled
  balance with reversal at both edges**, not a timer: too exposed at one end, uselessly deep with
  no line of engagement at the other. That is strictly richer than a countdown, it is what
  RECALL DRIFT (24) implements at the far edge, and it is directly buildable on the one-hop
  sampling substrate with no global coordinate.
- **Counterplay** a player who tracks which chambers read as held ground can predict where a
  pressured chassis will run and beat it there. A player who never sustains a fight past about a
  minute never sees the system fire at all — **it rewards sustained pressure, not burst damage.**
- **Engine fit** one new per-agent scalar on Adversary chassis; reads a chamber scalar exactly
  the way any gradient climb reads a field. The low-edge override composes with existing
  movement the same way the danger-hold-line refusal already overrides pursuit.
- **Falsifier** Adversary chassis fighting indefinitely in a chamber that never reads as held
  ground, with no dwell-triggered peel-off across a long session.

#### 24. RECALL DRIFT — *the other edge of the band*
- **L** rule. **TRG** dwell above the **high edge** (≈70% of ceiling) **and** a sustained
  stretch — order of eight seconds, which is eight full Muster half-lives, long enough that a
  stray blip cannot fire it — with Noise, Distress and Muster all near baseline in its own
  chamber and one hop. **PER** the same three fields every hunter already samples, plus its own
  dwell. **ACT** begins gradient-**descending** on Otherworldness instead of climbing it —
  drifting back out toward relevance. Cancels the instant any of those three reads live again
  anywhere in its neighbourhood. **CST** none. **TIM** as above. **RES** none. **TELL** a lone
  Adversary chassis walking calmly back into a cleared wing from deeper held ground, with no alarm
  and no escort.
- **Why it exists** without it, safe ground becomes a permanent sink for chassis that topped off
  once and never re-entered play — turtling, by the enemy.
- **Counterplay** **a wing you cleared and left comes back to life behind you.** Ground the
  Adversary still holds is not safe for good; taking it — pushing Otherworldness down — is the
  only way to keep it clear. A player camping a quiet corridor eventually gets a lone, exposed,
  telegraphed chassis walking into it.
- **Falsifier** topped-up chassis sitting motionless in held ground with live Noise one hop away
  that they never answer.

#### 25. OVERDRAWN — *the terminal window*
- **L** **Adversary** state. **TRG** dwell reaching zero. **ACT** a fixed ~6-second window
  during which it **keeps running the low-edge climb under a visibly degrading chassis** — accel
  and turn both cut about a third, so it staggers and its turning arc widens. **It never stops
  moving.** If it reaches a live breach mouth or held ground before the window elapses, it
  resolves as a clean withdrawal (26) with no penalty for the near miss. If the window elapses
  first, it **self-terminates on the spot**, emitting the same Danger deposit and Distress burst
  a combat kill emits. **CST** this **is** the census loss. **TIM** 6 s, hard. **RES** a chassis,
  a Danger deposit (at TOLL amplitude), a Distress burst. **TELL** the spent stage of GUTTERING
  (37), plus the stagger.
- **Why it matters** this is the piece that makes cutting off a breach a **kill** rather than a
  debuff. It closes the loop the whole finite-personnel fiction depends on.
- **Counterplay** trapping a chassis away from every reachable breach yields a census point without
  a shot — **but self-termination is a LOUD shutdown** (Danger + Distress at that spot), so farming
  it in one corridor deliberately provisions the response there. Finishing an overdrawn chassis with a
  shot instead denies its slim escape chance and trades a noisy shutdown for a quiet one. A real
  choice either way.
- **Engine fit** reuses the existing on-shutdown emission path unmodified; self-termination routes
  through the same call as a combat kill. New: a bounded per-agent countdown plus a movement
  multiplier composed with existing accel and turn — still the same climb, degraded, **not** a
  special-cased branch.
- **Falsifier** a chassis that reaches zero dwell and simply stops moving. That is a direct
  no-freeze violation and proves it was not built as specified.

#### 26. QUIET GATE — *what success looks like*
- **L** rule. **TRG** a chassis at any dwell level standing in a live breach mouth. **ACT** a
  fixed sub-one-second fold-inward animation on its own silhouette, then removal. **No shutdown
  bark, no chassis, no touch-damage window during the fold, and nothing emitted to any field.**
  Dwell resets off-map on the dispatch fabric's own clock, entirely outside the chamber it left.
  **TELL** the **total absence** of any shutdown cue is the tell. That asymmetry against a loud
  shutdown is the defining, deliberate design of the pair.
- **Counterplay** a player mid-fight with a chassis that reaches a breach mouth learns immediately
  that it got away rather than shut down, and that nothing nearby got recruited by it — the tell that
  says *that one doesn't count*, which matters because the census only moves on the loud version.
- **Engine fit** a short animation state plus explicit suppression of the on-shutdown emission for
  this exit only. The on-shutdown emission is currently unconditional, so the difference between
  this and (25) is a real code path, not a rendering skin.
- **Falsifier** a withdrawing chassis leaving a disabled chassis, a Danger deposit, or a shutdown bark.

#### 27. LAST CALL — *who gets the exit first, with no commander*
- **L** rule. **TRG** approaching a breach mouth already occupied or contested by another
  Adversary chassis within sight. **PER** ordinary sight through the shared find/senses API — it
  compares **the same on-chassis degradation tell the player can see** (37), never a hidden queue
  number. **ACT** if any visible contender reads more overdrawn than itself, **yield**: hold one
  step back, let it cross first, re-check every tick until the mouth clears. The yield is a
  one-step hold, never a stop-in-place. **CST** every contender keeps spending dwell while it
  waits — **a crowded breach mouth measurably costs the swarm more census than a clear one.**
  **TELL** visibly-more-degraded chassis crossing first while less-degraded ones hang back a step
  — not a scrum, and not arrival order.
- **Counterplay** a cluster of overdrawn chassis queuing at one breach is often winnable even
  several at once, because the ones yielding are actively choosing not to fight through. **A
  crowd at a breach mouth is a learnable soft-target tell**, and forcing the pile-up by
  threatening a breach early is a deliberate, high-value play.
- **Engine fit** no new field, no new sensing channel — the same sight the quorum rule already
  uses to count committed peers, keyed on the degradation render state instead of a commit flag.
  Fully diegetic: what an agent senses is exactly what the player sees.
- **Falsifier** crossing order uncorrelated with visible degradation (e.g. consistently
  first-arrived-first-through) — that would mean a hidden queue is standing in for the rule.

#### 28. BREACH PRESSURE
- **L** structure state on the breach mouth. **TRG** more than a small fixed count of Adversary
  chassis within its immediate contest range for a sustained beat. **PER** a local chassis count at
  the mouth — no global tally. **ACT** escalates its visual state from the ordinary single-fold
  cue to a **held, swelling pulse** that persists while contention continues and drops back the
  instant the count clears. **TELL** that pulse — it makes LAST CALL's queue visible, since one
  yield is subtle but four are not.
- **Counterplay** the player can tell across a chamber whether a breach is worth camping for a
  multi-kill or serves one chassis at a time — and since every chassis in the jam is still spending
  dwell while it waits, **holding the doorway punishes the swarm for trying to save itself.**
- **Falsifier** a mouth that looks identical busy and empty.

#### 29. EMBER DOCTRINE — *the ruling on dormant chassis*
- **L** ruling, zero new mechanism. **ACT** a dormant Adversary chassis samples Otherworldness on
  the same cadence as an active one and drains or refills by the same curve. **Dormancy changes
  what it does with the result — nothing, until its wake threshold fires — never whether it
  accrues it.** The safety of a sleeper is a **placement** property, not a runtime exemption: it
  is only ever seeded on ground whose baseline Otherworldness already sits above the held-ground
  floor.
- **Consequence, and it is the payoff** a wing the player merely passed through still has a
  sleeper ticking toward nothing, safe, because the ground is still held. **A wing the player
  physically takes and holds starts killing sleepers on a clock even if none ever wake to
  fight.** That gives the player a real, learnable reason to hold cleared ground rather than
  just clear it — and it is the only way dormant census is ever actually reduced.
- **Why the alternative is banned** an exemption flag for inert chassis is a feature flag, and
  feature flags are forbidden outright.
- **Falsifier** sleepers failing of dwell while their garrison is intact; or never failing no matter
  how long their garrison has been gone and the ground held.

#### 30. UNDERTOW — *the routing answer*
- **L** **Adversary** per-agent state. **TRG** dwell under the low edge. **PER** for its core
  decision it samples **nothing external**: it watches its own dwell and, on crossing any portal,
  pushes the (chamber, doorway) pair it just used onto a **private bounded stack** (cap around
  24; oldest silently drop off the far end so memory never grows without bound). **ACT** once
  overdrawn it stops answering Muster, Distress and Kin recruitment entirely, drops any target,
  pops the top of its own stack and walks the **reverse of that exact doorway** — the last one it
  came in by, then the one before, one hop at a time. Purely local reversal, no coordinate
  anywhere. It is still moving every tick. **CST** none beyond the dwell it is already spending.
  **RES** SEAM MARK (31) on the way in. **TELL** the retrace lights the same corridor in
  mirrored order as the advance did.
- **Why not a homing field** three options were weighed. (1) The breach emits a long-spread
  homing scalar only Adversary chassis read — buildable in principle (that is exactly how Muster,
  Kin and Garrison reach already work), rejected on governance: it needs either an **eleventh**
  field or the overloading of Garrison reach with a second, not-always-coincident meaning
  ("the FOB is this way" **and** "the breach is this way"), and breaches are not always inside a
  garrison's reach — a direct one-symbol-one-meaning violation. (2) The private stack — chosen.
  (3) No routing at all: withdraw only if a breach is inside the legal one-hop view, otherwise
  die where you stand — which would make ANCHOR placement the entire game.
  **Recorded for the director:** option (1) is the closer analogue and is reopenable if he wants
  to reopen the ratified field list. This packet does not make that call.
- **Critically, it does not read the shared doorway-trail scalar for its routing.** That pooled
  value also carries ordinary hunt-trail deposits and the player's own mark trail; reading it
  would let a busy corridor mislead an overdrawn chassis away from its real path home, reproducing
  exactly the "wanders and shuts down" failure the design forbids.
- **Counterplay** the retrace is a **deterministic replay of the exact doorways it used going
  in**. The player does not need to chase it across the map: **holding or contesting the single
  doorway furthest down its stack reliably stops it.** A corridor already cleared is worth
  holding a few extra seconds rather than pushing past for free.
- **Engine fit** new per-agent state only: a dwell float and a bounded stack of (chamber, edge).
  Both filled by hooking the existing portal-crossing event. Reversal is a strictly local
  one-hop lookup at the far end of the stored edge.
- **Falsifier** an overdrawn chassis taking a route it never advanced through, or beelining toward
  a breach it has no recorded path to.

#### 31. SEAM MARK
- **L** field write, for the **player's** benefit, not the swarm's. **ACT** deposits a faint
  per-doorway residue through the existing doorway-trail call at the same moment UNDERTOW pushes
  to its stack, at an amount **well below the ordinary hunt trail and far below the player's own
  mark trail**, so it reads as its own distinct weight rather than blending into either. Decays
  on the same half-life as any other write to that scalar; only an actual chassis crossing again
  refreshes it. **TELL** a distinctly light doorway mark that says *the Adversary itself came
  through here*.
- **Counterplay** a player who learns to read it gets **advance notice of where an overdrawn
  survivor will retrace, before UNDERTOW ever fires.**
- **Engine fit** rendering and tuning only, on a shipped primitive. **Nothing reads it for
  navigation** — decoupled from (30) on purpose, so retuning its amount or decay can never
  change where a chassis actually withdraws.
- **Falsifier / standing test** disabling UNDERTOW's stack push while leaving this write on
  should produce **zero** change in where chassis withdraw. If a withdrawal route ever shifts when
  this mark is retuned, the two systems were coupled by accident.

#### 32. WARM SEAM
- **L** structure/rule. **TRG** standing in a chamber whose Garrison interior reading is above
  its floor. **ACT** an overdrawn chassis standing there **stops spending dwell** for as long as it
  remains, and resumes the instant it leaves — waystations along a deep withdrawal route, giving
  it more reach than one unbroken sprint on the raw budget. **CST** none. **TELL** the
  degradation tell (37) visibly **holds steady** only inside garrison-held chambers.
- **Counterplay** **breaking a garrison removes every waystation on a raid's retrace at once** —
  a second, higher-leverage reason to hunt garrisons beyond the ground they hold.
- **Open conflict** this pauses dwell on **Garrison interior**; MOORING (23) and ANCHOR (22)
  pause/slow it on **Local Unfolding**. Those are two different answers to the same question and
  only one should ship. See §6.3.
- **Falsifier** dwell pausing anywhere with no Garrison interior reading (under this version).

#### 33. NEAR SEAM
- **L** priority branch. **TRG** while overdrawn, an ordinary raycast-confirmed sighting of **any**
  breach mouth. **ACT** abandon the remembered retrace and walk straight for the sighted one —
  the sure thing over the memorised route — so a chassis never visibly ignores an open way out
  standing in front of it. If none is in sight, (30) proceeds unchanged.
- **Counterplay** **line-of-sight denial becomes a lever on the withdrawal.** Keeping a breach
  mouth out of an overdrawn chassis's sightline — fighting from cover, around a corner — forces it
  back onto the slower, interceptable retrace.
- **Falsifier** an overdrawn chassis walking past an in-sight open breach to continue an unrelated
  multi-hop retrace.

#### 34. LAST GROUND
- **L** **Adversary** state branch. **TRG** the private stack is empty **and** no breach mouth is
  within the ordinary one-hop sight check. **ACT** stop moving toward anything, **plant, and
  fight at full aggression** until dwell hits zero or it is killed — producing the ordinary loud
  shutdown rather than an unexplained walk-off. **CST** guaranteed census loss the moment it
  commits. **TELL** it stops retreating and fights harder — a clear behavioural switch.
- **Why it exists** it is the exact case a pure retrace leaves open, and the case the design
  explicitly forbids leaving unhandled. Overdraw must always resolve to a legible loud shutdown,
  never to a chassis wandering aimlessly.
- **Counterplay** a player who recognises it knows the census cost is already guaranteed and can
  commit to the kill without worrying about a clean withdrawal escaping.
- **Falsifier** a chassis wandering aimlessly with nonzero dwell and no combat commitment. That
  state should not exist under this design.

#### 35. DEAD SEAM
- **L** **Adversary** branch. **TRG** at the final stack entry, the breach it was banking on has
  already sealed — so the ordinary crossing it always attempts is simply not there. **ACT** after
  a short refusal window with no crossing available, it falls straight through to LAST GROUND on
  the spot. **TELL** overdrawn chassis converging and piling up fighting right at a chamber whose
  breach sealed moments before they arrived — a small last stand exactly at the seam.
- **Counterplay** **the single highest-leverage play the whole mechanic offers.** Forcing a
  breach closed — denying reinforcement, or outlasting its closure timer — while a raid is still
  inside converts every chassis banking on that breach into a guaranteed kill, without hunting any
  of them individually.
- **Engine fit** no new state; it reads portal existence at the chamber pair the dispatch fabric already
  tracks per breach, then falls into (34).
- **Falsifier** an overdrawn chassis re-routing to a different live breach after its original
  sealed — that would require the live map query this design deliberately does not have.

#### 36. FIRST STEP
- **L** instantiate-time initialisation. **ACT** at dispatch/pour, the chassis's private stack is seeded
  with **the single crossing the pour itself performs** (hub chamber → world chamber), so it
  always has a correct one-entry route home from the instant it exists. Every subsequent crossing
  pushes on top exactly as (30) specifies.
- **Why** without it, an early overdraw hits LAST GROUND one hop from an open breach for no
  reason. One line at the existing dispatch call site.
- **Falsifier** a freshly poured chassis hitting LAST GROUND with its home breach open one hop away.

#### 37. GUTTERING — *the tell*
- **L** rendering only. **ACT** a chassis-anchored, cold-light seam across the chassis that narrows
  and dims as dwell falls, interpolating continuously through **three stages — steady, guttering,
  spent** — so it reads as a countdown in progress rather than a flag flipping. Reads UNDERTOW's
  dwell float directly and writes nothing.
- **Why it is load-bearing** it is what makes the entire dwell system legible at 0.45 zoom with
  no HUD number, which the standing law makes a ship requirement: **if you cannot name the tell,
  the mechanism does not ship.** It is also the value LAST CALL (27) compares — agents read the
  same thing the player reads.
- **Deliberately never a ring.** A ring means aggro and nothing else. This is a chassis event and
  chassis events draw on the chassis.
- **Counterplay** a player who reads the stage on sight can choose to disengage from a chassis about
  to hit LAST GROUND (a guaranteed kill either way, not worth the ammunition) versus one still
  operational and worth avoiding entirely.
- **Falsifier** a chassis failing to overdraw with no visible change from its instantiate appearance.

#### 38. STRAIN — **RECOVERED**
- **L** rule on dwell. **TRG** each engagement. **ACT** a **per-engagement surcharge stacked on
  top of the ordinary dwell burn**, so a specialist that fights hard is forced to withdraw sooner
  than one that merely stands around. This is keyed to **repeated engagement**, not elapsed
  presence — which is exactly what separates it from dwell itself, which burns on time in
  ordinary space regardless of combat. **CST** accelerates census exposure. **TELL** it shows up
  through GUTTERING (37) advancing visibly faster on a chassis that has been fighting.
- **Why it matters** without it, an Adversary chassis that fights constantly and one that hides in a
  corner run down at exactly the same rate, and the player's damage output has no relationship to
  the withdrawal mechanic. With it, **pressure itself shortens the enemy's clock.**
- **Falsifier** two chassis of the same class, one in constant combat and one idle in the same
  chamber, reaching the low edge at the same time.

---

### 3.H — GARRISON, RESIDENTS AND DORMANCY (roles 17, 19, 20)

All eight are **RECOVERED**. Two lanes' worth of resident and entrenchment work was dropped
wholesale before the catalogue was assembled. Row 19 currently only exists inside the hub;
ground the swarm has held for minutes reads identically to ground it took thirty seconds ago.

#### 39. LOCAL LEVY — **RECOVERED**
- **L** Testator. **TRG** a Garrison interior chamber below its resident count. **ACT** a
  **cheap, capped, slow local trickle** of new resident chassis inside garrison-interior chambers
  — functionally and visibly distinct from a dispatch fabric-dispatched strike package. When the local
  supply is unavailable or the population is emptied faster than the trickle refills, the gap is
  instead filled by the dispatch fabric at full dispatch cost (see 41). **CST** minimal reserve, capped
  rate. **TIM** slow — tens of seconds per chassis. **TELL** held ground quietly repopulating on its
  own, in ones, versus a pour arriving in a burst at a breach mouth.
- **Counterplay** a garrison the player thins but does not break refills for free; a garrison he
  breaks costs the dispatch fabric real reserve to restore. **Half-clearing is the worst outcome for the
  player** and that is legible.

#### 40. RE-TILE — **RECOVERED**
- **L** Testator. **TRG** a neighbouring posted watcher (1–3) is killed, leaving a gap in
  coverage. **ACT** the immediate neighbours **reposition to re-cover the gap within a short
  window**, restoring even coverage with no central signal telling them to. Fast, free,
  individual. **CST** nothing. **TIM** seconds. **TELL** kill one posted watcher and the next one
  along visibly slides over to cover its doorway.
- **Why it is distinct from 41** this is the **free, fast, local reshuffle**; GAP-FILL is the
  **slow, reserve-funded replacement** when there is no neighbour left to slide over. Different
  timescale, different cost, and the difference is legible.
- **Counterplay** clearing a boundary one chassis at a time never opens it — the coverage repairs
  behind you. Opening a boundary means killing **enough at once** that no neighbour is left.

#### 41. GAP-FILL — **RECOVERED**
- **L** Testator. **TRG** a coverage gap with no adjacent watcher available to re-tile. **ACT**
  the dispatch fabric funds a replacement at ordinary dispatch cost, arriving no faster than the dispatch
  queue allows. **CST** reserve. **TIM** slow. **TELL** the replacement walks in from elsewhere
  rather than sliding over from next door.

#### 42. WARD-TENDER — **RECOVERED**
- **L** Testator. **TRG** locally sampled Distress. **ACT** the same chassis reversibly switches
  posture between **fighting** and **tending the garrison works** — gated on the local field:
  live Distress favours the combative posture, its resolution favours the building one. An
  unresolved combative posture is what produces a garrison that never finishes its works.
  **CST** reserve. **TELL** two visibly different postures on the same silhouette; a quiet
  garrison is visibly *building*, a disturbed one visibly is not.
- **Counterplay** **keeping a garrison agitated stops it entrenching.** Harassment without
  committing to a clear is a real strategy with a visible payoff, and the reverse is legible too:
  leave it alone and come back to works that make retaking the ground expensive.

#### 43. OCCUPANCY CAP — **RECOVERED**
- **L** rule on garrison seeding. **ACT** a resident population **denies ground to a settler
  simply by already being there** — no fight needed. A chamber at its occupancy cap cannot be
  seeded as a new garrison, so the caller's expansion leg has to go further out.
- **Why it matters** it is the mechanism that makes "most ground is already spoken for" true, and
  it makes the caller's descend-Kin search meaningful rather than decorative.
- **Counterplay** thinning the residents of a chamber **opens** it to a garrison seed. Clearing a
  quiet room and walking away can be strictly worse than leaving it alone — the packet's sharpest
  statement of "this is a war, the enemy does not simply let you have ground you took but didn't
  hold."

#### 44. BLOOM — **RECOVERED**
- **L** rule on residents. **ACT** individually inert below a local density threshold; **above it
  the whole local group flips together** into a different, active behaviour. Structurally
  identical to the game's shipped fractional quorum rule and therefore **reused rather than
  reinvented** — the local, visible-peer count, never a global one.
- **TELL** a room full of apparently inert chassis that all come operational at once when enough are
  present — a collective, not an individual, reaction.
- **Counterplay** keep a resident chamber below its threshold and it never activates. Killing
  down to just under the line is a real, learnable target.

#### 45. SHELL — **RECOVERED**
- **L** structure. **ACT** a garrison **collectively builds a shared shell over itself** (see 42
  for who builds it). The shell, not the individual members, is what resists: it must be damaged
  down by different means than ordinary single-target damage, while the members underneath stay
  cheap and replaceable. **The shell is the investment; the chassis are not.**
- **Counterplay** this is the enemy-side answer to a player firebase, and it should read as the
  same kind of object: a thing you have to bring the right tool to, not a thing you chip.
- **Open** what "different means" is mechanically — area damage, sustained damage, structural
  damage — is a synthesis decision, not settled here.

#### 46. DEEP DORMANCY — **RECOVERED** *(role 20 — the strongest recovered item in this group)*
- **L** Adversary (and residents). **TRG** **depth in the portal graph** — hops from any breach
  and from ordinary traffic — not a per-chassis coin flip. **ACT** chassis many hops from the front
  sit at a **much higher wake threshold** and answer only direct contact, not ordinary field
  levels. Chassis near the exposed surface run ordinary thresholds and react readily. **CST**
  none. **TELL** ground deep behind the line is visibly still while the same field level would
  have woken a chamber near the front.
- **Why it matters** it is exactly what row 20 asks for: **clearing visible pressure near the
  front genuinely does not touch the census.** A player who wants dormant census reduced has to go
  and physically find it — or hold the ground and let EMBER DOCTRINE (29) do it for him.
- **Counterplay** depth is legible from the portal graph itself, so a player can reason about
  where the sleepers are without being told.

---

### 3.I — DISPATCH AND POUR (role 11 extension)

#### 47. POUR SURGE *(renamed from SURGE to end the collision with SURGE CAP (20))*
- **L** field. **TRG** the instant a breach opens and a strike package begins pouring, a brief
  pulse is written **once** at the breach mouth's chamber, decaying inside a couple of seconds.
  **PER** own chamber. **ACT** agents in the pour read it and spend the resulting extra
  acceleration budget **on cohesion only**, within the existing priority-budget flocking split —
  never on separation, so a surged pour keeps its formation gaps and just closes them faster.
  **CST** none. **TIM** a couple of seconds, once. **RES** none. **TELL** the pour arrives as a
  tight cluster and then visibly spreads back to normal loose formation.
- **Counterplay** the first couple of seconds after a breach opens is when the wave is fastest and
  most bunched — the best window for an area attack and the worst to be caught flat-footed in the
  doorway. Waiting the pulse out to pick off stragglers is the slower, safer play.
- **Falsifier** agents pouring ten seconds after the open still showing the tightened cluster.

---

### 3.J — MEMORY OF A REPEAT INTRUDER (role 14)

Both accumulate. **Neither forgets**, and nothing here specifies the slip. See §6.5.

#### 48. VETERAN — **RECOVERED**
- **L** per-agent state, either lane. **ACT** memory that lives **in an individual persisting
  chassis**, not in a central ledger: a chassis that has survived a real engagement carries a
  permanently shifted personal commit threshold. Local, personal, and **destroyable** — killing
  the veteran deletes that memory, which a global stat can never offer.
- **Why it is separate from the ledger** the ledger is population-level counter-biasing of the
  strike-package mix; this is one chassis being harder to surprise a second time. Keeping them
  distinct is what lets the player attack each one differently.
- **TELL** open — a veteran must be distinguishable from a fresh chassis at 0.45 zoom or it is a
  hidden statistic. **This is an unfilled tell slot and the synthesis must close it or cut the
  candidate.**
- **Counterplay** killing the chassis that have fought you before is a real, targeted play; letting
  them live means the same corridor gets harder each time.

#### 49. LEDGER BIAS
*(the salvaged half of a rejected candidate — see §5.1)*
- **L** rule inside the dispatch fabric's own bookkeeping. **ACT** the Scriptorium's small fixed-capacity
  ledger, fed by haulers that physically arrived, **biases the deterministic 20-slot strike
  cycle** toward counters. **It reads no signal field at all** — the dispatch fabric's blindness to the
  fight is structural and must not be broken. It counts what has been filed, nothing else.
- **What was cut and why** the original proposal gated dispatch on a live Distress/Muster read
  plus a hop-distance ledger lookup. The dispatch fabric's step function takes tick, imprint, live
  breaches, shelf census, dispatch factor and capacity — **nothing about the player or the
  fight** — and composition today is a deterministic cycle, not a field-driven decision. Wiring a
  live field read into dispatch is exactly the cross-system reach the design forbids. What
  survives is the honest half: **bias the cycle from a hub-side count.**
- **Counterplay** killing haulers before they arrive keeps the mix at baseline however loud the
  player gets. Letting evidence through means the mix skews toward whatever counters him.
- **TELL** the composition of what walks out of a breach, over repeat visits. Slow, but real, and
  the player can see it in what arrives.
- **Falsifier** an identical mix whether or not any hauler ever reached the Scriptorium.

---

## 4. THE ENVIRONMENT-DEPENDENCE DOSSIER

*The spine of the Adversary lane. This section reads cards 21–38 as one system, states the
numbers, names the two places where lanes disagreed, and flags the one place where the shipped
code contradicts the director outright.*

### 4.1 The three-tier model

The sweep converged on a three-tier picture of a population and its ground, and all three tiers
already have a home in this game:

1. **The dependent tier — Adversary personnel.** Ordinary space (zero Otherworldness) does not
   merely inconvenience them; it wears them down on a clock. They are confined to pockets and
   must return to one. This is the director's ruling, and it is the whole lane.
2. **The indifferent tier — Testator chassis.** Already true in the game and requiring no work:
   these are ordinary local chassis. Ordinary space is where they are from. They never withdraw,
   never carry a budget, and die like any other chassis.
3. **The pocket-makers.** A chassis that, by its own sustained presence, **raises the local
   condition** and opens livable ground inside otherwise hostile territory. That is LOCAL
   UNFOLDING (21), produced passively by presence, and concentrated by the ANCHOR (22).

The design consequence: **the Adversary must hold ground rather than roam it**, and a player who
never lets them settle starves the lane's runtime support without ever fighting for it.

### 4.2 The control law, and the numbers

The lane that swept this found something strictly richer than a countdown and it must not be
flattened back into one. The correct shape is a **livable band with reversal at both edges**,
maintained purely by continuous local sampling with no global coordinate:

- **Low edge — too exposed.** Dwell running down forces a pull-back toward rising Otherworldness
  (MOORING, 23).
- **High edge — uselessly deep.** Topped up with nothing to fight forces a drift back out toward
  relevance (RECALL DRIFT, 24).

Chassis released into such a gradient oscillate inside the band. That is a population that holds a
front instead of either evaporating into ordinary space or turtling in its own ground forever.

**First-pass numbers**, chosen so the reasoning is visible, all expected to move once measured:

| Quantity | Value | Why that number |
|---|---|---|
| dwell ceiling | 90 units | 2× the Distress half-life (45 s), so the maximum unsupported presence is legible against a signal the player already learns to read |
| drain, zero Otherworldness | 1.0 / s | ceiling ÷ drain = **90 s** absolute maximum unsupported time in raw ground |
| drain, fully held ground | 0.1 / s | ~900 s, i.e. 20× the Distress half-life — deliberately far enough into "does not matter this session" that held ground reads as **true safety**, not a slower countdown |
| low edge | 30 / 90 (33%) | sized against Adversary run speed and the shipped rooted-broadcast timings so a chassis turning back at the edge has roughly 2–3 hops of travel before the terminal window opens |
| high edge | 63 / 90 (70%) + 8 s quiet | eight full Muster half-lives, long enough that a stray blip cannot fire the drift |
| terminal window | 6 s | bounded, always moving, always shootable |
| degrade while overdrawn | ≈35% cut to accel and turn | staggers and widens its turning arc; never zero |

Layered on top: **STRAIN (38)**, a per-engagement surcharge, so a chassis that fights burns faster
than one that stands around. Without it, the player's own pressure has no relationship to the
mechanic.

### 4.3 The retreat decision, and how a chassis with one-hop perception finds a breach

**This is the hardest buildability question in the director's mechanic** and it deserves the
plainest possible statement of the problem: an agent's whole legal field view is its own chamber
and one hop. "Withdraw into a breach" therefore needs a homing rule that reaches further than one
hop. The obvious candidates fail:

- **Garrison reach** is emitted by settled chassis and is consumed by **exactly zero agents
  anywhere in the game** — nothing gradient-climbs it. It is also the wrong meaning.
- **Kin** is climbed **downward** by callers looking for thin ground. Wrong direction, wrong
  meaning, and overloading it would invert the caller.

Three buildable answers were weighed, and the lane picked one (see UNDERTOW, 30):

| Option | Shape | Verdict |
|---|---|---|
| A breach-homing scalar | the breach emits a long-spread, short-half-life field only Adversary chassis read | **Rejected on governance, not buildability.** It needs an eleventh field (reopening the ratified appendix) or the overloading of Garrison reach with a second, not-always-coincident meaning — a direct one-symbol-one-meaning violation, since breaches are not always inside a garrison's reach. **Recorded as reopenable if the director wants to reopen the field list.** |
| **A private crossing memory** | the chassis pushes each (chamber, doorway) it crosses onto a bounded private stack and walks the reverse when overdrawn | **Chosen.** No new field, no coordinate, no map. Makes cutting a withdrawal route a matter of **holding the doorways it actually used**, which is a play the player can see and execute. |
| No routing at all | withdraw only if a breach is inside the one-hop view, otherwise die where you stand | Rejected: it would make ANCHOR placement the entire game and turn the census into a passive drain the player never earns |

The chosen answer needs four guard cases, all specified: **FIRST STEP (36)** so a fresh chassis is
never stranded at the door it was born at; **NEAR SEAM (33)** so it never walks past an open
breach it can see; **DEAD SEAM (35)** for the breach that sealed underneath it; and **LAST
GROUND (34)** so an exhausted stack resolves to a legible loud shutdown rather than a chassis wandering
aimlessly. Combined with **LAST CALL (27)** for who gets a contested mouth first — decided
locally, by comparing the visible degradation tell, never by a queue number.

Read together, the three layers are: **NEAR SEAM handles what it can see, MOORING's climb handles
the last hop, UNDERTOW's stack handles the multi-hop route.** That reading is coherent, but it is
a merge of two lanes' answers and the synthesis should ratify it explicitly rather than inherit it.

### 4.4 What a watcher sees

The whole system is worthless if the player cannot read it. The tells, and the asymmetry that
carries the fiction:

- **GUTTERING (37)** — a chassis-anchored cold seam through three stages, steady → guttering →
  spent, interpolated continuously. Never a ring. This is the only readout; there is no number
  anywhere.
- **QUIET GATE (26) versus a loud shutdown (25).** A successful withdrawal is a sub-second silent
  fold with **no chassis, no deposit, no bark, and nothing emitted**. A failure is a loud shutdown that
  leaves a chassis, a Danger deposit at TOLL amplitude, and a Distress burst that recruits. **That
  asymmetry is the player-facing point of the entire lane**: the absence of a shutdown cue is the
  tell that says *that one doesn't count*, because the census only moves on the loud version.
- **BREACH PRESSURE (28)** — a mouth under a mass withdrawal swells and holds instead of
  showing the ordinary single fold, so "cordon the exits" becomes a readable, targetable moment
  rather than an invisible bookkeeping event.
- **The behavioural tells** — a chassis peeling off mid-engagement and running while nothing is
  chasing it (23); a lone chassis walking calmly back into a wing you cleared ten seconds ago (24);
  a chassis that stops retreating and plants (34); a small last stand exactly at a seam that just
  sealed (35).

### 4.5 The contradiction nobody caught: the census is a counter, and it must be a roster

**The shipped code does the opposite of what the director asked for.** In `sim.py`, an Adversary
chassis that crosses into the hub is *reabsorbed*, and the code decrements the census **permanently**
— its own comment says "not a shutdown — a departure; the census decrement is permanent either way."

The director's mechanic requires the reverse: **withdrawal preserves the chassis**, and the census
falls **only** when the player denies the route. As written, going home costs the swarm exactly
as much as failing, which drains the census automatically over any long session and deletes the
player's entire reason to cordon a breach.

**This is not a per-agent timer change. It is a change to the census model itself:** an off-map
roster that a withdrawn chassis returns *to* and can re-emerge *from*, replacing a counter that only
ever decrements. Nothing in the catalogue noticed this, and it is a prerequisite for every card
in §3.G. It also raises a live question the synthesis must answer: **what does a withdrawn chassis
do off-map, and under what conditions does it come back?**

### 4.6 The open conflicts inside this section

1. **What pauses dwell.** WARM SEAM (32) pauses it on **Garrison interior**; MOORING (23) and
   ANCHOR (22) slow it on **Local Unfolding**. Two answers, one question. Local Unfolding is the
   better wire (it is also the render tell, and it does not overload a field that already means
   "inside the wire"), but Garrison interior is free and Local Unfolding is real engine work.
2. **Whether the tenth field ships at all.** Local Unfolding costs runtime soften/unsoften in the
   engine, cache invalidation, and a ruling on composing with the authored corruption gradient.
   If it does not ship, the whole lane runs on Garrison interior and the environment tell stays
   binary.
3. **Whether dormant chassis accrue dwell.** EMBER DOCTRINE (29) rules **yes**, with safety coming
   from placement rather than an exemption — because an exemption is a feature flag. That ruling
   is cheap, honest, and gives the player a real payoff for holding cleared ground. It needs
   confirming against whatever the shipped dwell design ends up being, not assuming.

---

## 5. WHAT THE CRITICS REJECTED, AND WHAT IS STILL OPEN

### 5.1 Rejections, with my ruling

| Candidate | Critics' reason | Ruling |
|---|---|---|
| **CARRIER, Courier, Clearance** | One chassis designed four times; at 0.45 zoom they are the same read | **Upheld.** Merged into HAULER (9) with three cargo types. Clearance's one load-bearing idea — an uncleared chassis keeps trickling Distress until moved — is preserved as a HAULER clause, because it is the only part of the hauler family that changes how a later fight goes |
| **Kill-Sign** | A fifth floor object invented so a redundant class had something to carry; the disabled chassis already **is** the record, and the kill path already threads a damage-source string | **Upheld.** Cut. At 0.45 zoom a typed pickup is a small blob among small blobs; its own prediction ("switching weapons visibly changes what gets dropped") is not achievable in that budget |
| **The Filing, Stage, Spill, Laden** | Four roster slots spent on the bookkeeping of one job | **Partly upheld.** LADEN (10) and SPILL (11) survive as named shared rules because three consumers need them and they carry real counterplay. The Filing's one real contribution — a player can camp the Scriptorium and deny deliveries from inside — is folded into HAULER. Stage is folded into LADEN |
| **Corroboration** | Breaks the dispatch fabric's structural blindness and misdescribes what it extends: dispatch composition is a deterministic 20-slot cycle, not a field-driven decision | **Upheld as written.** The salvageable half survives as LEDGER BIAS (49): bias the cycle from a hub-side count, with **no field read at all** |
| **Kin Scar** | Sign error — a caller **descends** Kin to find thin ground, so scarring Kin would steer the next caller **to** the player's best killing ground, not away | **Upheld.** Cut. The intent (personnel deaths should mark ground more heavily than equipment deaths) is correctly wired by TOLL (18) on the Danger side instead |
| **BLANK** | Kin is emitted **uniformly by every enemy**, so a Kin deficit reports thin swarm density, never "something here is not one of ours." The counterplay (carry Adversary salvage to raise your own reading) is unimplementable — the player emits no Kin — and if implemented would **invert** the caller's thin-ground search, making salvage a reward | **Upheld.** Cut. Role 7 is genuinely missing and needs a different channel — see §5.2 |
| **TEMPER** | Falls with BLANK; has no tell ("visibly differ in twitchiness" is a statistic, not a screen read); and its documented counterplay is its own defeat | **Upheld.** Cut |
| **GAUGE** | Fires on the variance of an invisible scalar — unlearnable, so waking reads as random; and it punishes deliberate metering, the one stealth-adjacent play the game supports | **Upheld.** Cut |
| **STARK** | Punishes the exact play the ratified design rewards (fast, clean, no stragglers); no distinguishable tell; and it inherits BLANK's broken Kin premise | **Upheld.** Cut |
| **CULL** | Needs the senses to expose a recently-damaged tag, which the entity-description contract deliberately withholds; and it thins the response **for** the player | **Upheld.** Cut. Note that the second objection is the decisive one — it is a gift dressed as a threat |
| **SEAM** | Needs three pieces of new substrate (a persistent garrison structure entity, an edge-scoped threshold override, edge-keyed adjacency the field layer does not have) for an effect that falls out of calibration for free | **Upheld.** Cut |
| **Paint Cascade** | Its cited substrate turned out to be an unrelated flat player upgrade; a stack count on a 7-px chassis is a HUD in disguise; its mobility-cancel branch collides with the standing anti-stunlock law; and it duplicates the shipped mark | **Upheld.** Cut |
| **Brace Call** | An invisible defensive buff — its own prediction is "his first hit reads weaker than his second," which the player experiences as inconsistent damage; and it duplicates Muster at the same call site with the same emit shape | **Upheld.** Cut |
| **Stand-Down Pulse** | A one-shot multiplicative cut violates the substrate's own law that separation in time comes from half-lives and never amplitude, and duplicates two shipped resolutions | **Upheld.** Cut. Row 10 goes to DAMPER (19), which achieves the same end through the already-built drain capacity |
| **Cordon-Seal Ring** and **CORDON-SEAL WORKS** and **SEALWRIGHT** | They collide with each other (a soft auto-releasing hold versus a hard barricade, same trigger, same on-screen picture, incompatible rules), and both reintroduce the permanent doorway standoff the codebase spent filmed runs deleting — there are two live scars in `sim.py` from exactly that failure. SEALWRIGHT is separately a statue with hit points | **Upheld, all three.** Row 9 is left **EMPTY** rather than filled badly — see §5.2 |
| **SCAR GROUND** | Permanent, irreversible geometry change plus a permanent Danger emitter, in a game whose containment reward is that cleared and cordoned ground stays clear; "never decays" is not a half-life; and the runtime disconnect/carve/reconnect sequence is the highest-risk operation in the codebase, fired mid-fight with chassis in the doorway | **Upheld.** Cut. If the idea returns it must be bounded — a very long half-life, not permanence, and a cap per level |
| **BEACON WORKS** | Amplifies Garrison reach, which **has zero consumers anywhere in the game**; the catalogue contradicted itself on this point | **Upheld.** Cut |
| **ARREST COLLAR** | A structure re-depositing a full-strength doorway mark forever changes what the mark **means** — from "recent traffic" to "traffic, ever" — a second meaning on one symbol; and its prediction is a cross-run statistic | **Upheld.** Cut |
| **MUSTER GATE** | Not a design: its own fields say it adds no machinery and it retracts the routing signal it was named for | **Upheld.** Cut as a roster row. It survives as a **level-design note**: a firebase's reinforcement traffic funnels through whichever doorway is the least-hopped link to the nearest breach or hub route, so a player can scout that doorway and interdict resupply there instead of assaulting the perimeter |
| **OTHERWORLD ANCHOR** | Invents a second copy of the same field Local Unfolding proposes | **Upheld as a substrate collision.** Not cut — **recast** as ANCHOR (22), a structure that *writes* Local Unfolding, which is what it should have been |

### 5.2 The gaps still open

**Row 12 — breach opening. The deliverable itself is missing, and this is the single most
important line in this packet.**
Not one candidate across every lane proposes what replaces `vagrant` and `lacuna`. The catalogue's
Adversary chassis are hunters, enforcers, authorisers and specialists; **none of them calls, roots,
holds the lease, or does garrison expansion.** If the synthesis shipped today, deleting the
placeholders would delete breach-opening from the game. The shipped caller loop is short and
concrete — creep to the edge of the hot zone, brace, take the world's single lease, transmit
rooted and fully exposed, leave an imprint, watch three seconds for an answer it cannot be told
about, then alternate the expansion legs (descend toward quiet ground for a garrison seed, climb
toward the danger peak for a raid call) — and the two replacement designs must still do all of it.
**What the synthesis must produce is not two names but an axis of difference**, since the defect
being fixed is that today's two differ only in hit points and broadcast length. Per class it needs:
root ticks; where it sits in the weakness ordering and why that ordering is the weakness ordering;
what it does while the other one holds the lease (it must not freeze); what it does after the pour
it called arrives; its dwell budget; its row in the enemy stat table (hp, radius, mass, accel,
friction, turn, touch); a distinct silhouette in the doubled-boiling-outline channel that already
marks the lane; and the tell that distinguishes the two **mid-broadcast** at 0.45 zoom.

**Row 7 — kin-check enforcement.** The role is real; BLANK was the wrong wire. The buildable
channel exists and nobody used it: the entity-description path already returns state tags for the
player and the sight hit already carries ground-truth side. **A carry-state tag on the player, read
through sight at raycast range**, gives a kin-check chassis a real, legible trigger and the player a
real choice — carry the Adversary salvage and be hunted differently, or leave it. That is the
mechanic the precious-personnel framing implies, and it needs a designed false-positive story too:
a response that never misidentifies reads as omniscient, which the constitution warns against. The
coinage **kin misfire** exists and nothing uses it (CAUSTIC CHAFF (5) is the only own-side damage
mechanism in the packet).

**Row 9 — cordon-seal / walling-off.** All three candidates rejected. The role is real and the
source mechanism is clear: **when a target cannot be removed by force, many responders instead
seal it in place and hold it, over an extended period, with the seal itself persisting long
after.** What killed the candidates was the implementation: a permanent doorway blockade is a hard
mobility cancel by another name, the codebase has already deleted two versions of that standoff,
and combat canon buys spacing with knockback rather than denial of movement. A working version has
to seal **without** producing a doorway the player cannot walk through, and it has to release.
CORDON WEB (7) — a barrier bought entirely with chassis the player himself killed, on a half-life —
is the nearest thing in the packet to a legal answer and may be the whole answer.

**Row 14 — memory: nothing forgets, and the slip is unspecified.** Accumulation is covered
(48, 49). The row explicitly requires **a measurable slip in the counter when the player switches
tactics**, and no candidate specifies decay, capacity pressure, or the slip arithmetic. Worse, the
shutdown rule means shutdown does not reset the world, so the ledger persists across the player's own
deaths and nobody has said what that means. A ledger that only accumulates converges on one hard
counter and stays there — a difficulty ramp, not a conversation.

**Row 22 — anti-structure specialists. This does not "partly exist"; it does not exist.** Nothing
in the game targets a pod, a station, a repair point or a turret. Sentries have **no hit-point
field at all** and the code states they are indestructible and never collide with enemies under the
session's collision matrix. So a player who builds a firebase owns that ground forever and the
whole building economy has no pressure term. Zero candidates addressed it. **This is the
catalogue's biggest omission for play** — it is the difference between a base being a decision and
a base being a win button. It must be priced honestly: making sentries killable needs a new
collision pair **and** teaching ranged chassis to aim at something that is not the player. The
design questions are: what makes a pod or a turret a target at all (a sentry emits; a pod does
not); whether the specialist ignores the player entirely while structures are in reach (it should,
or it is not a specialist); its dispatch cost; how it reads on screen walking past the player
toward a turret; and what it costs the swarm to send one, since a chassis that ignores the player is
a chassis the player kills for free.

**Row 23 — barrier and lifeline denial.** The ratified design is explicit that the Portable Hole's
aperture passes only small chassis, that hole-capable pursuers must exist, and that firing through
a hole mouth draws pursuit through it — a hole is a lifeline, never a consequence-free firing slit.
No candidate engaged with it. The likely cheap answer: **a hole is a runtime portal, so it should
already appear in the adjacency the topology-change handler rebuilds, and therefore signals already
cross it** — which may be most of the work. What still needs designing: how a chassis decides to enter
a hole using only one-hop perception; whether a hole mouth accumulates a doorway mark like any
other crossing; what a large chassis does when it can sense through a hole it cannot fit through (it
must not freeze); and whether the swarm can deny the hole from the far side instead of following.

**Two more holes nobody swept, both worth naming:**

- **What the swarm does when it is starved.** Reserve exhaustion, the CORE blackout and a full
  breach cordon are all shipped or ratified economy states, and **nothing says what chassis already
  on the map do in them.** The dispatch fabric stops dispatching; the chassis keep fighting exactly as
  before, so the player gets no behavioural read that he has won the economy. The vocabulary for
  this already exists and is unused: **spent** — a chassis that no longer answers Muster. This is the
  cheapest way to make the reinforcement economy legible without a HUD and it is empty. It must be
  built without letting any agent read the reserve, since the dispatch fabric's blindness is structural.
- **Home-ground doctrine.** Every card in this packet is designed for field conditions: patrol,
  gradient climb, doorway hold, breach pour. The hub is an entire game area, the most heavily
  defended place in the world, and the player is expected to invade it — and **nothing addresses
  what changes when the fight is inside the control centre**, where the guardian shelf is the
  population, residents are already in place, and there is no breach to withdraw through because
  you are already home. Specific questions: does the danger hold line apply on home ground (a
  garrison that refuses to enter a hot chamber inside its own hub is absurd, but removing the rule
  is a special case, and special cases are forbidden — resolve it through the fields, e.g. Garrison
  interior as an input to the hold rule); do the CORE's own parts have any behaviour at all (today
  they are skipped in the agent loop entirely, and whether the Caretaker in particular should act
  is unanswered); and is dwell infinite inside the hub (presumably yes — the hub is fully unfolded,
  and **that is the reason the precious chassis live there** — but it should be said explicitly).

---

## 6. THE OPEN QUESTIONS FOR SYNTHESIS

These are the real decisions. Each names its tension.

### 6.1 How many Adversary units should exist, and what is each one for?

The lane currently has two chassis that do one job. The catalogue proposes, across all lanes, up
to six distinct Adversary jobs: **two callers** (row 12), **a warrant** (row 5), **an executioner**
(row 6), **a herald** (row 5's sensing half), **a damper** (row 10), and **a kin-check chassis**
(row 7). Six classes of precious personnel is a lot of silhouettes to teach at 0.45 zoom on a
7-pixel chassis, and every one of them competes for the same doubled-outline render channel.

*The tension:* the fiction wants the Adversary to feel like **personnel** — individuals with jobs,
not a horde — which argues for differentiation. The legibility law wants the smallest set the
player can actually learn, and the census wants each class rare enough that meeting one is an
event. Two callers plus two or three specialists is probably the ceiling. **Which of warrant,
executioner, herald, damper and kin-check are separate chassis, and which are behaviours the
callers themselves take on when the situation calls for it?** Note that warrant and damper are
nearly the same silhouette-level read — an unarmed chassis that walks toward a fight and stops short
— which is an argument for merging them and an argument against, since one symbol should mean one
thing.

### 6.2 Which coordination roles go to Testators, and which does the Adversary keep?

The director's rule is clear in principle: the swarm treats Testators as somewhere between
equipment and wildlife, so anything it spends freely is Testator, and judgement is Adversary. The
packet applies it: haulers, couriers, clean-up, pickets, chaff, area denial, traffic, entrenchment
→ Testator. Warrant, execution, suppression, kin-check, dwell, dormancy → Adversary.

*The tension nobody resolved:* **the relationship itself is asserted and never mechanised.** With
no commander, an Adversary chassis cannot *order* Testators to screen it. So how does a precious chassis
get cheap chassis to interpose without telling them to? It must be a field write plus an existing
gradient consumer, never a pointer. Candidate shapes, all unbuilt:

- personnel emit an outsized Kin or Muster contribution, so Testators cohere toward them and end
  up between them and the player **as a side effect of ordinary flocking**;
- a withdrawing chassis emits a terminal Distress/Muster spike that pulls Testators into the chamber
  it is leaving — **buying its exit with their chassis**, which is the sharpest possible statement
  of the relationship;
- personnel position by descending Noise while staying inside Kin reach, so they are structurally
  always the second rank.

The reverse direction is equally empty: **what is the Adversary willing to do to Testators?**
Nothing in the packet covers spending them deliberately, harvesting them, or the Testator lane
visibly degrading in quality when no personnel are present in a sector. Today a `vagrant` and a
`mite` fight in exactly the same way, which means "somewhere between equipment and wildlife" never
appears on screen at all.

### 6.3 How should the withdrawal rule read in play so it is a threat and not an anticlimax?

*The tension:* a chassis that runs away when it is losing is, on its face, **an anticlimax** — the
player lines up a kill and the game takes it away. Everything in §3.G exists to make that the
opposite of what happens, and the synthesis has to be sure it lands:

- The escape must be **denied-able**, and denying it must be a **play**, not luck: hold the doorway
  furthest down its route (30), cut the sightline to the nearest mouth (33), force a breach closed
  underneath it (35), cordon the region (32's waystations), or just be at the mouth (27, 28).
- The escape must **cost the swarm something visible even when it succeeds** — a crowded mouth
  spends more census than a clear one (27), and a chassis that fought hard leaves sooner (38).
- The failure must be **loud and the success silent** (25 versus 26), so the player learns to tell
  the two apart instantly and knows which one counted.
- And it must never resolve as a chassis standing still: overdraw is a bounded, always-moving,
  always-shootable terminal window (25), or a chassis that plants and fights harder (34).

Three sub-decisions remain live: **what pauses dwell** (Garrison interior versus Local Unfolding —
§4.6.1); **whether the tenth field ships at all**, given the real engine cost (§4.6.2); and
**whether the census model gets rewritten from a counter to a roster**, without which the whole
mechanic is inverted (§4.5).

### 6.4 How should a finite, non-renewing personnel pool feel as it is spent?

*The tension:* the census is currently **invisible**. The player has no way to know he has taken
three of them out of the world rather than three of anything. Making it visible with a counter is
forbidden (no HUD text) and would also be wrong — the swarm has no global view either, so nothing
in the fiction knows the number.

What the packet offers instead is **local legibility**: TOLL (18) makes a chamber where personnel
shut down read as deadlier for longer than one where equipment shut down, so ground the player has bled them
in stays visibly avoided. DEEP DORMANCY (46) plus EMBER DOCTRINE (29) mean clearing the front does
not touch the census but **holding** ground does. And the fiction's own framing — containment, not
extermination, is the practical strategy — means the player is not supposed to be counting down to
zero.

The open question is whether that is **enough feedback for a resource whose scarcity is the whole
point**, and if not, what else carries it without a number on screen. Candidate directions:
personnel becoming visibly rarer in the mix that walks out of breaches; the tells the economy
already generates (the stutter at a gate, the lost guardian burst, a dry transmission) getting a
personnel-side equivalent; or the hub itself reading emptier of the doubled-outline lane on a
later visit.

### 6.5 What does the player learn to exploit?

The ratified constitution names this as the target: *a truly advanced player will intuit how the
system communicates with itself and manipulate it to his advantage.* Across every lane, deception
appeared only as scattered counterplay footnotes. **There is no candidate whose subject is the
exploit surface.** Without one, the fields are a system the player can only obey.

The nine fields plus the ledger give a fixed list of attack surfaces, and each needs a designed,
learnable play **with a designed limit**:

- **False Kin** — wearing or carrying salvaged Adversary material. Needs the carry-tag channel
  from §5.2, not the Kin field. What does the player physically carry, what does it read as, and
  why does it work at the frontier and fail against a thick garrison?
- **False Trail and false Noise** — decoys that draw a raid fan down a chosen route.
- **Feeding the ledger deliberately** — letting a hauler get home carrying evidence of a weapon
  the player is about to stop using, so the counter-bias arrives aimed at nothing.
- **Spoofing Muster** to pull a garrison off a breach.
- **Deliberately sparing** a damper or a warrant to shape the response — the packet already has
  this one (19), and it is the model for the rest.
- **Baiting the swarm into hurting itself** — funnelling caustic chassis (5) is the only own-side
  damage lever in the packet.
- **Deliberately overheating** a chamber to trigger the spotterless flank breach at a time and
  place the player controls — already ratified as an intended advanced play, and nothing in the
  packet builds toward it.

For each: what the player physically does, which field it writes, what it costs him, and **how the
swarm can be wrong about it without the swarm being stupid.**

### 6.6 What single axis is the Adversary teaching?

*The tension, and it is a synthesis failure rather than four independent design failures:* the
lanes never agreed on what the player is being taught, so the catalogue as submitted taxed **every**
way of taking a chamber. STARK punished fast clean clears; DRAG FIELD punishes long fights;
the cordon-seal family punished winning the same room repeatedly; TEMPER rewarded thinning slowly
with downtime. A rule set where every outcome is punished carries no information and reads as
arbitrary difficulty.

Cutting STARK and TEMPER (§5.1) removes most of the contradiction, but the synthesis should still
**name the one axis explicitly and check every survivor against it.** The strongest candidate,
straight out of the shipped code and the director's own mechanic, is **denial of withdrawal**:
*fast and complete costs them census; slow and partial costs you ground.* Under that axis, DRAG
FIELD (8) and SNARE MAT (6) still need a second look, since they both push toward "slow costs you
ground" and one of them may be redundant.

### 6.7 Two audits that must happen before synthesis, not after

**The tell budget.** One symbol means exactly one thing is a **global** constraint, checkable only
globally, and no individual candidate can verify it. The vocabulary already spent: closed rings =
aggro; a magenta glob on the chassis = the mark; a red chassis blink = this is what just hurt you; a
white chassis flash = your hit landed; expanding violet rings = a caller transmitting; a dimmed trace
= a lurking ambusher; a brightened trace = an engulf charge; a doubled boiling outline = the
Adversary lane; a teal shape on the back = a carried load; a closing ring = unpack or recall. At
0.45 zoom, chassis are **3–10 screen pixels.** The genuinely unused channels are: **the floor**
(decals already ship and survive the disabled chassis), **the walls** (soft deformation), **chassis silhouette
shape**, and **audio**. This packet's new tells claim: the floor (6, 7, 8), the walls (21), the
chassis (37, and the licence pulse on 16), the carried-load channel already in use (9), and the
breach mouth as a structure (28). **Every survivor must claim a channel or be cut, and the
rejection must happen on the tell first.**

**The tempo ladder.** Shipped half-lives: Muster 1 s, Garrison interior 1.5 s, Garrison reach 2 s,
Noise 3 s, Kin 8 s, Trail 12 s, Distress 45 s, Patrol 60 s, Danger 180 s. Every new or extended
duration in this packet needs to sit on that ladder with a one-line statement of what it means that
nothing else already means — and anything landing within a factor of two of an existing field has
to justify why it is not that field. Live items: Local Unfolding's long half-life (21), the mat and
web and drag timers (6, 7, 8), the authorisation field's fast seconds (13), the dwell ceiling's
90 s and its explicit derivation from Distress (§4.2), and the ledger's decay, which is currently
unspecified (§5.2). **Separation in time comes from half-lives, never amplitude** — that is the
substrate's own law and it is what killed one candidate outright.

### 6.8 What should the two placeholders become?

The final question, and the one the director actually asked. What is settled: they stay
**Adversary lane, finite, authored at build, never produced by the CORE**; they keep the entire
caller loop including the single lease and the fully exposed rooted broadcast; they carry a dwell
budget and must withdraw; and **the axis between them must be something other than hit points and
broadcast length.**

The shape the gap analysis argues for is **two callers that answer different questions with the
same lease**:

- one that works **at the edge of the hot zone** — a contact call, a short root, shuts down if the
  player turns around, and exists to convert a live fight into more chassis arriving now;
- one that works **quiet ground behind the line** — a long root, refuses anything above the entry
  line, deliberately slips past the player rather than fighting, and exists for garrison seeds and
  raid calls that reclaim ground the player took but did not hold.

That reading has real support: the shipped expansion loop already alternates a **descend-toward-
quiet** leg and a **climb-toward-the-danger-peak** leg, and those are genuinely two different jobs
that two classes could specialise in rather than one class alternating. It also gives the two
opposite counterplay: the first is denied by turning around fast, the second by cordoning and
watching your own back line. And it gives the weakness ordering a reason to exist — the weaker
class calls first because the swarm risks the cheaper judgement first.

*The tension:* every Adversary chassis added elsewhere in §6.1 competes with these two for the
player's attention and for the lane's render channel, and **the census cannot afford six kinds of
precious.** If the synthesis wants a warrant and an executioner, the two callers may have to carry
more of the other jobs themselves. **That trade is the last thing to decide, and everything else
in this packet is input to it.**

---

*End of packet. Provenance for every recovered mechanism is held in the program's internal
translation and provenance files, which are gitignored and are the only place the reading-side
vocabulary exists.*
