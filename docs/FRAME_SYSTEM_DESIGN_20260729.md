# Coordinate spaces: the design

Date: 2026-07-29
Status: **settled in conversation with the director. Authoritative.**

Companion documents, each with a distinct job:

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

* the entity **id**, resolved lazily so it reads `None` once the entity
  is in no polygon, without a Track keeping a removed entity alive and
  valid-looking;
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
* A fact computed on demand evaluates against the current world while
  the Coordinate is a snapshot of an earlier one, so a Track must not
  hold two moments without saying so.
* A distance is a scalar and a scalar has no space, so a threshold
  expressed in one space is not comparable with a distance measured in
  another. Under a scaling portal this is live, and it already affects
  the range constants shipped today.
* What mypy proves is the type distinctions — Coordinate versus Offset
  versus a raw tuple — and not space identity, because the id is a
  runtime value. Claiming more than that would be dishonest.
