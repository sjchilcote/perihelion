# Coordinate spaces: the design

Date: 2026-07-29
Status: **settled in conversation with the director. Authoritative.**

Companion documents, each with a distinct job:

* `docs/FRAME_SYSTEM_REDTEAM_20260729.md` — five readers implementing
  advanced operations from the documentation alone, what they got right,
  and every gap they found (all closed, one of which added an engine
  primitive).

* `docs/FRAME_ALGEBRA_NOTES_20260729.md` — the reasoning and the
  impossibility proofs behind the choices here. Read it to understand
  *why*, not *what*.
* `docs/FRAME_SYSTEM_STE_20260729.md` — the same design in Simplified
  Technical English, for reading back.
* `docs/consults/frames_20260729/` — the packet and Sol's answer.

---

## 1. Why

Positions are pairs of numbers, and a pair of numbers is only meaningful
in one coordinate space. Nothing in the code says which. So code can ask
two objects for their positions, subtract them, and get a number that is
silently wrong because the two are in different chambers.

This shipped. Gate 66 failed it at p=0.04: 63 of 64 filmed fires were
cross-chamber, so aim, the range gate and the knockback direction all ran
on meaningless numbers, and the behaviour was delivered once in 57,600
ticks. The composed answer was already in hand — `SenseHit.position` —
and the code recomputed a worse one from raw parts. The unit tests were
blind because every fixture was a single chamber, which is the one case
where the bug is invisible.

**The target is narrow and specific.** Three failures, no more:

1. Ask two objects for their positions, subtract, receive a number when
   they are not in the same space.
2. Transform along a legitimate route to the **wrong destination**, then
   use the result as though it were where the code assumes.
3. Be pushed into restricting work to one polygon because transforming
   properly is inconvenient. The observed symptom is
   `if polygon == ppolygon` guards, which do not compute a wrong answer
   but decline to compute at all — silent degradation, and a violation
   of the game's own law that nothing goes inert across a doorway.

In all three the defect is **silence**. A loud refusal is fine.

## 2. Explicitly not goals

* A transform derived across a link that no longer exists may still pass.
* There need be no way to express a transform between two unlinked
  spaces. That question never arises, because they are not linked.
* An author who declares two spaces linked when they are not is allowed
  to succeed. That is their doing and may be deliberate.
* No general guarantee of spatial correctness beyond §1.
* **The engine is not deterministic and nothing here assumes it is.**

## 3. The parts

### CoordinateSpace
Held as a component by anything that defines a space — today every
polygon, and the screen. Two fields:

* `id` — a runtime-allocated integer. This is identity. Comparison uses
  only this.
* `name` — `"Screenspace"`, `"Polygon 7"`. For messages only. Never
  load-bearing, so a collision after a seal reuses a number is cosmetic
  rather than a correctness problem.

Ids are allocated at runtime because they must be. There is no intrinsic
property of a coordinate system to identify it by, and no construct that
recovers a destination space from the numbers — see the proofs in the
algebra notes.

### Coordinate
A place. Carries its values, its space, and a **record** of every
transform applied: for each step, the id of the space it moved *into*
and the matrix that moved it.

A Coordinate never consults the world. It replays only the matrices in
its own record, so it can never be invalidated by a carve or a seal — it
keeps meaning what it meant.

### Offset
A difference, produced by subtracting one Coordinate from another.
Belongs to a space but is not a place.

A portal can rotate and can scale, so a **Coordinate moves by the full
affine matrix and an Offset moves by the linear part only.** A difference
pushed through the full matrix collects a spurious translation. A
direction is a normalised Offset.

### Transform
A matrix plus the ids of the two spaces it maps between. Applying it to a
Coordinate appends to that Coordinate's record. It should also validate
its source against the Coordinate's terminal space — a cheap backstop,
though not strictly necessary, because the algebra check catches the same
error later.

### Track
A **report of a sighting**, returned by perception. Not a proxy for an
entity; a record about one.

* the entity **id** as it was at the sighting. (The plan said "resolved
  lazily so it reads `None` once the entity is in no polygon". Built
  otherwise, on reflection: a Track is a snapshot, and "does that body
  still exist" is a question about the world NOW — `sim.exists(id)`.
  Making one field a live query is the two-moments confusion the tick
  stamp exists to prevent. A Track holds an integer, so it cannot keep
  anything alive to begin with.)
* a Coordinate in the space the caller asked for;
* the tick of the sighting;
* relational facts already computed.

**Which relational facts is implementation-dependent**, and the rule is
the *intersection* of what perception already computes and what callers
would find useful. Path distance and line of sight are the obvious
starting pair. More get added when several call sites are observed
recomputing the same thing — not speculatively.

Why a Track rather than the entity: the developed Coordinate cannot come
from the entity, because the entity does not know who is asking or by
what route; one entity yields many Tracks, because the same body seen by
two routes has two images; relational facts are properties of the
observer-subject pair and have no home on the subject; a captured
snapshot is what continuous operations need, or a slew can snap when the
route changes under it; a Track can outlive its subject; and not
everything perceivable is an entity — a breach is a hole, not an entity.

## 4. Algebra

Legal, all within one space:

    Coordinate - Coordinate -> Offset
    Coordinate + Offset     -> Coordinate
    Offset +- Offset        -> Offset
    Offset * scalar         -> Offset
    |Offset|                -> scalar
    Coordinate + Coordinate -> does not exist

This is the torsor structure: positions form an affine space over the
translation vectors, which is exactly why there is no `Coordinate +
Coordinate`.

An operation on two Coordinates examines both records:

1. Both terminate at the same space id — proceed.
2. The records share an earlier space — bring the right operand back to
   that shared space by inverting its later transforms, then forward
   along the left operand's transforms from there. Both are now in one
   space; proceed.
3. No shared space — raise, naming both space names and both records.

Reconciliation uses **only the records**, never the world. That is what
keeps a Coordinate topology-independent, and it is why case 3 exists at
all. A "bad path" cannot arrive here on its own, because every
Coordinate originates from perception with a shortest-path record; to
construct one you must do it deliberately, and then it is yours.

## 5. Asking the world

    world.develop(coord, into=space) -> Coordinate | None

The one operation that consults live topology: a deep graph search for
the shortest path from the Coordinate's space into the named one,
followed by the transform. It **belongs to the world, not to the
Coordinate** — putting it on the Coordinate would imply the answer is
derivable from what the Coordinate holds, when in fact it is a search
against world state that can fail.

This is also the only place where "the route can change as the world
changes" is true, which is acceptable because the caller asked for it
there.

## 6. Perception

A search by globally-agreed entity **tag** — `Player`, `Testator`,
`Adversary`, `Enemy`, `Building`, `PlayerBuilding`, `EnemyBuilding` — plus
the space the answer should arrive in. Returns Tracks.

Route policy: the **shortest physical path through the assembled world**,
measured as total distance and not as hop count. This is the simplifying
assumption the support code makes on the caller's behalf, and it is the
answer that looks right to the player almost always.

Two modes:

* shortest path only, the default;
* a generator over every distinct path, shortest first, **which may never
  terminate**, because a portal graph with a loop admits unbounded paths.
  "Distinct" means distinct developed image, which is the bounded
  enumeration the renderer already performs via `max_depth` /
  `max_instances`.

A caller that wants something other than the shortest-path answer uses
the generator and owns the consequences.

## 7. The Python gate

**`sim.get` returning a Coordinate in that entity's own space is the
whole gate on the Python side.** Confirmed with the director.

*As built:* `sim.get(id)` returns an `EntityState` whose `pos` is that
Coordinate, alongside `vel` and `dir` as Offsets and `polygon` as a bare
index. The fields allocate only when read, so `st.polygon` costs nothing;
`st.space`, `st.pos.space`, `st.vel.space` and `st.dir.space` are all the
same space. The stub (`game/stubs/necore.pyi`) is authoritative on shape.

Consequences:

* An entity reading its own position is unaffected — its own space is
  the same space, so the arithmetic is same-frame by construction.
* Reading *another* entity's position becomes visible instead of silent:
  you hold a Coordinate in someone else's space, and algebra against your
  own either reconciles or raises.
* A Coordinate straight from `sim.get` has an **empty record**, so two
  fresh coordinates from different rooms share no space and correctly
  raise. Failure mode 1 is caught with no perception involved.
* Writes (`set_vel`, `set_dir`) take an Offset in the entity's own space
  rather than bare floats.
* Only the engine sees raw numbers. Physics stays in-engine, knows its
  spaces, and handles them itself.

## 8. Collision

**Friendly fire is on.** This is a 2D immersive sim, not an arcade game,
so physical honesty is the default. Rounds collide with rounds; an
enemy's round hits an enemy.

With that, everything collides except pickups, and the group system holds
no information. `set_collision_pair` leaves the Python surface, the
16-wide bitmask goes, and `GROUP_PICKUP` goes. One fact remains — a
pickup is not a physics object — and it belongs on the pickup.

What it buys, all of it landing on machinery that already exists: a crowd
obstructs itself, so a pack must spread or hold, which adds texture to
the garrison and quorum rules; the player can put one enemy between
itself and another; and the Adversary's thrown object shoves Testators,
which matches how it regards them.

The AI stays deliberately ignorant of friendly fire. A
don't-shoot-your-friend check is the arcade answer, and an immersive sim
prefers an enemy the player can turn against itself.

**Rider.** Enemies can now kill Adversaries, and `adversary_lost`
increments on every death. That count is what the "player causes 30% of
adversary attrition" ruling rests on. Dead is still lost, so the count
stays true, but attribution must separate player kills from
friendly-fire kills or the ruling document's number stops meaning what it
says. `_damage_enemy` already carries `source=`, so the data exists and
is merely not split.

## 9. The validating test case: the rubber grenade

The Adversary's shove becomes a **large, high-mass, low-velocity
projectile**, fired only when the player is close.

It still has to be aimed, and aiming across portals is exactly what the
new system makes routine. What disappears is the other half:

* `shove_imp` goes — the knockback is mass times velocity.
* The push direction goes — the collision normal is the direction.
* The `_apply_impulse` call and the whole `elif bx["kind"] == "shove"`
  branch go, which is where the second frame error lived.

Bullets are mass 0.01 precisely so they do not shove. Mass up, velocity
down, radius up, `rest_wall` from 0.0 to something springy, and the
bespoke impulse plumbing deleted.

Loose aim becomes acceptable, which suits a panicking runner rather than
a marksman: a slow lob at a moving target misses without lead, and a
near-miss heavy object still makes the player back off. Big and slow is
also self-telegraphing at 0.45 zoom — the object is the tell — and it is
a physical obstacle while it exists.

## 10. Implementation order

1. `CoordinateSpace`, `Coordinate`, `Offset`, `Transform` in necore.
   Nothing calls them. No behaviour change.
2. PyO3 wrappers. Python cannot build a Coordinate from numbers.
3. `sim.get` and friends return Coordinates; writes take Offsets.
4. Perception: tag search, Tracks, the two route modes.
5. Migrate call sites, innermost first, one cluster per commit.
6. Delete the raw accessors from Python. This is the step that makes the
   error unwritable.
7. Collapse the collision matrix; friendly fire on; split kill
   attribution.
8. The rubber grenade, as the test that the system did its job.
9. Turn mypy on for `game/perihelion`.
10. Last, revisit the four `polygon == ppolygon` guards. Each is a
    behaviour change and each needs its own filmed gate.

Audit surface: 63 arithmetic sites in `sim.py`, 15 of the
hypot-of-a-difference shape, 28 `sim.get()` unpacks, 24 `player_pos()`
calls against only 13 uses of the composed `sight_of` path.

## 11. Open items

* A Track holds values computed at one tick, and that tick must be
  visible or an old answer reads as current. This is the same
  silent-wrongness shape as the frame bug, in time rather than space.
  **Built:** `Track.tick`, stamped at the query.
* A fact computed on demand evaluates against the current world while
  the Coordinate is a snapshot of an earlier one, so a Track must not
  hold two moments without saying so. **Built:** every field on a Track
  is computed at the one instant it reports; nothing is lazy.
* A distance is a scalar and a scalar has no space, so a threshold
  expressed in one space is not comparable with a distance measured in
  another. Under a scaling portal this is live, and it already affects
  the range constants shipped today. **Still open** — see §13.
* What mypy proves is the type distinctions — Coordinate versus Offset
  versus a raw tuple — and not space identity, because the id is a
  runtime value. Claiming more than that would be dishonest.

---

# AS BUILT — 2026-07-29

Everything in §1–§10 shipped. This section records what the code does,
where it deviates from the plan above and why, and what the system found
the moment it met the existing codebase.

The machine-checkable API reference is **`game/stubs/necore.pyi`**. If a
signature there disagrees with `engine/necore-py/src/`, the stub is the
bug.

## 12. Deviations, each with its reason

**A place can be built — but never without naming its space in the same
expression.** §10 step 2 said "Python cannot build a Coordinate from
numbers", and that turned out to be one word too strong. Level files say
"polygon 7, at (40, -12)", and a mouse arrives from the OS in screen
coordinates; something has to turn those into places. Two doors do it:

    sim.place(polygon, x, y)     the door for authored data
    space.place(x, y)            the door for screen input

Note what stays impossible. The gate-66 defect was numbers whose space was
*never stated anywhere* — not numbers whose space is stated out loud and
then checked by the algebra. Both doors state it in the same call as the
numbers, so the pairing cannot drift, and everything downstream is checked.

**`Coordinate.local()` is the one documented unwrap.** Sound, decals and
the fx queue are wire formats the renderer and mixer read as
`(tag, polygon, x, y, …)`. They are a legitimate reason to take raw numbers
out of a place, and they take them at three funnels in `sim.py` (`_snd`,
`_decal`, `_fx_at`) rather than at a hundred call sites. Gameplay code
holds no bare pairs; `local()` does not appear in the AI at all.

**A Track carries velocity and facing as well as place.** §3 left the set
of relational facts to implementation, as "the intersection of what
perception already computes and what callers would find useful". Two
callers needed more than distance: the husk's lunge leads a moving target,
and the shrieker's mark aims at the ground *behind* him. Both need the
subject's velocity/facing **in the observer's space**, and the only way to
get that right is to carry it along the route the sighting itself took —
developing the place and a one-second-ahead point through two
independently chosen routes gives a difference polluted by the holonomy
between them, which is a real number about nothing. Adding them retired a
punt: the mark used to read his raw facing out of his own chamber and then
give up (`# a rotated frame: just close in`) whenever the shot crossed a
doorway.

**Route policy is measured between doorway midpoints.** §6 asks for "total
distance of the shortest physical path". A true geodesic through a polygon
soup needs a funnel algorithm; `query::route` runs Dijkstra over
`(polygon, entry edge, hops)` with legs measured doorway-centre to
doorway-centre in each polygon's own metric. That is an upper bound on the
geodesic, exact when the path runs through doorway centres, and it is
already enough to disagree with hop-count routing — which is the property
that mattered (`route_measures_distance_and_not_hops` builds a world where
the hop-minimal route is 990u and the physical one is 90u across three
chambers).

**The confirming ray now gets the same reach as the compose walk.**
`sightline` composed transforms up to `VISION_HOPS = 12` and then
confirmed with a raycast hardcoded to 3 hops, so a straight sightline down
a colonnade of five small chambers composed correctly and was refused.
That is failure mode 3 wearing a magic number. Both are `max_hops` now.

**The collision matrix is gone, replaced by one boolean on the body.**
`Entity.physical` (default true) carries the single fact the 16×16 mask
encoded — a pickup is not a physics object. `set_collision_pair` is off
the Python surface entirely.

**Three `polygon == ppolygon` guards removed; the fourth was not a guard.**
`music.py`'s was `hops = 0 if polygon == ppolygon else hop_distance(...)`
— a redundant fast path around a function that already answers 0 for a
chamber against itself. Deleting it changes nothing but the reading. The
three real ones:

* the **notice beat** was two branches, an immediate one gated on sharing
  the player's chamber and a staggered line-of-sight one that lacked the
  growl's volume, the fx and the turn toward the intruder. One beat now,
  fired by a sighting at whatever depth the geometry gives it. The frame
  test bought 9 ticks of latency in the player's own chamber and cost the
  game its own law.
* the **flicker's ambush** would not spring with the intruder a
  body-length away through a doorway, and its hunt walked to the next door
  the instant he stepped over a threshold. An ambush predator that cannot
  reach across a doorway is an ambush predator with no doorways, in a game
  made of them.

A grep for `== ppolygon` still finds three, and all three are kept
deliberately, because they ask a topological question rather than decline a
geometric one:

* the seed-station scan and the exit scan — you must be IN the chamber with
  the pod or the door. That is a design statement about interaction, not an
  inconvenient transform avoided.
* the music's lurker term — a flicker holding the dark in *your* room is a
  different dread from one a doorway away, and the music is entitled to say
  so.

The distinction that matters: a frame test used as a cheap stand-in for
"close enough to fight" is the defect; a frame test asking "is this thing
in the room with me" is a question with a real answer.

## 13. What the system found on contact with the codebase

The point of a type that refuses is what it refuses. Four defects fell out
during the migration, none of them known beforehand, none reachable by
reading:

1. **`Event::Contact` resolved its polygon too late.** The PyO3 layer
   looked up "entity a's polygon" when it converted the event, but events
   are consumed after the whole physics step, and the rest of that step can
   transfer either body through a doorway. So a contact normal was
   occasionally read in the chamber a body *ended* in. `Contact` carries
   the polygon it happened in now, recorded at contact time, because it is
   not recoverable afterwards. Caught the first time a turret round's
   knockback crossed a threshold mid-step.
2. **The post-physics scans used the chamber the player had left.**
   `ppolygon` is read at the top of the tick, before physics; `_pickup_scan`,
   `_terminal_scan`, `_station_scan` and `_exit_scan` all run after it and
   all measure a distance from the player's *current* place to something in
   that named chamber. After any transfer they compared one chamber's
   numbers with another's. Shipped, unnoticed, for however long.
3. **A capture could pull its captive nowhere.** `capture.py` subtracted
   the captor's raw position from the captive's — and a warden's grip
   straddles a doorway routinely, because portal geometry puts bodies in
   each other's laps. It develops the captor's place into the captive's
   space now, and releases the grip if the world can find no route.
4. **The rail's knockback pushed in the shooter's frame.** The beam is
   aimed in the shooter's space and pierces up to three bodies, which may
   be chambers away; `_damage_enemy` was handed the shooter's numbers as
   the impulse direction. It now carries the heading into the struck body's
   own space through the ray's own composition (`RayResult.to_origin`,
   inverted).
5. **Firing point-blank into a captor a doorway away pushed nowhere** —
   and this one was found by 14,400 ticks of filmed play, after 943 tests
   were green. `_fire`'s inside-the-grip branch (and the charged tau's)
   handed the damage door a heading in the PLAYER's space, and a warden's
   grip straddles a threshold routinely. Every fixture that exercised a
   grip had both bodies in one chamber — the one case where the bug is
   invisible, which is precisely how gate 66 got through too.

   The fix is one named carry, `GameSession._carry`, at the damage door
   and the push door: it asks the world for ONE transform
   (`Sim.transform_between`) rather than developing two places and
   differencing them, and answers None when no route exists. A hit whose
   direction cannot be expressed still lands; it just does not push,
   because there is no honest direction to push along. The engine's writes
   stay strict — the carry is in the game, where the target is known.
   Regression: `game/tests/test_grip_across_a_doorway.py`.

A fifth was a design smell rather than a bug: the AI kept a copy of each
body's heading in `e["hdg"]`, a bare pair that the engine's own `dir`
duplicated — except the engine transports `dir` through a doorway
transform on transfer and a python pair cannot. Every portal crossing
slewed the body from a heading expressed in the chamber it had just left.
One value now, owned by the thing that knows how to carry it.

## 14. What is still open

* **A length has no space.** `snare_range = 560.0` means 560 in *whose*
  metric? Today: the observer's, because `Track.distance` is measured
  there. Under a scaling portal the same pair of bodies is genuinely
  further apart measured from one side than the other, and there is no
  fact of the matter about which is "the" distance. The types make the
  choice visible (`Offset.length` is documented as space-free) but they do
  not make it for you. A `Length` carrying a space would be the next
  increment if scaling portals ever carry gameplay weight.
* **The renderer is exempt by construction, not by proof.** Per-frame bulk
  geometry (`visible_set` instances, decal blobs, the raster command
  stream) crosses the boundary as raw tuples in one named space — screen —
  and is consumed immediately. That is a performance decision (this is a
  240 fps target with the pixel work in Rust), and it is safe because
  nothing there mixes two spaces. The three places where the renderer
  reaches into *sim* state do go through Coordinates.
* **`_peer_bodies` is same-chamber by construction.** The flocking
  separation rule reads chamber-mates as raw triples out of one space in
  one loop. The day keep-apart reaches through a doorway it needs
  Coordinates, and the comment there says so.
* **The existing detonations do not cross doorways.** `_detonate_tau` and
  `_detonate_dart` iterate `polygon_entities(polygon)`, so a blast stops at
  a threshold — failure mode 3 in the shipped code, in a shape the §10
  audit never looked for (it searched for `polygon == ppolygon`).
  `Sim.transform_between` was added so the fix is cheap when it is wanted;
  changing blast reach is a difficulty question and is not folded in here.
  Found by red-teaming the documentation
  (`docs/FRAME_SYSTEM_REDTEAM_20260729.md`).
* **A straight-line radius through a doorway is a chord, not a walking
  distance.** Nothing in this system says otherwise, and nothing yet
  decides whether an AoE should reach by one or the other.
* **Friendly fire's first two consequences were defects, and gate 69
  found both.** Making enemy rounds hit enemies meant the enemy arm of
  `_contact` was reached for the first time — and it had neither guard the
  player arm had grown: no shooter exclusion (the Adversary shoved
  *itself* on ~30% of throws, s4 t10468 / s7 t12529 / s11 t990) and no
  once-per-object spend (one bouncing grenade billed a husk four times).
  Both now sit above the dispatch, where they belong to every round rather
  than to one branch. Regressions in
  `test_a_round_never_damages_the_body_that_loosed_it` and
  `test_one_throw_bills_a_body_once`.
* **Separating the arsenal's bands made the snare mute, and that needed
  the other half of the design.** Gate 69 measured 3 connects in 43: with
  the lob owning everything inside 165-180u, the snare only ever fires
  past that, where an unled 400 u/s round cannot catch a moving player.
  "Middle buys TIME" has to be something the player experiences. The snare
  now LEADS — a thrown net is aimed — using `Track.vel`, which is the
  velocity carried along the sighting's own route and is exactly what §12
  added it for. The lob stays unled on purpose. Measured 10/10 after,
  against 3/43 before.
* **Friendly fire's balance has not been tested.** It is on, the physics is
  honest, and the AI is deliberately ignorant of it. What that does to
  difficulty over a full session is a question for the difficulty pass
  (U16), not for this system.
