# Red-teaming the coordinate-space documentation

Date: 2026-07-29

## The test

Five readers were each given one non-trivial operation to implement in the
coordinate system, and **only three files to work from**:

    docs/FRAME_SYSTEM_DESIGN_20260729.md
    docs/FRAME_SYSTEM_STE_20260729.md
    game/stubs/necore.pyi

Reading anything under `engine/`, `game/perihelion/`, `game/tests/` or
`tools/` was forbidden, as was running the game or looking for an existing
example. Each was asked to write the code, then state **which coordinate
space every intermediate value is in and why**, then report what it had to
guess at and how confident it was.

The point is not whether they can guess method names. It is whether the
documentation carries the *reasoning*: reach for a sighting rather than two
raw positions, know that a difference moves by the linear part, know which
question belongs to the world and which to a value.

The operations, chosen so each probes a different claim:

| # | operation | what it probes |
|---|-----------|----------------|
| 1 | a turret leads a target **two doorways away** | use the Track, and use *its* velocity for the lead |
| 2 | flee to the doorway **furthest from the player** | doorway midpoints as places; a hop count is not a distance |
| 3 | an AoE blast that **reaches through a doorway** | both transform directions; a radius has no space |
| 4 | a **screen-space** marquee selection | the screen is a space; `develop` cannot reach it |
| 5 | a **boomerang** that returns after both parties moved | stored place vs. asking the world; honest failure |

## Result

**Five out of five got the operation substantively right on the first
attempt.** Not one reached for raw subtraction of two positions. Not one
confused a place with a difference. Not one tried to guard with a polygon
comparison. Two answered a deliberately-planted trick question correctly
without prompting:

* #4 was asked whether `sim.develop` can move a body into screen space. It
  said no, and gave the right reason — the screen is not a polygon, no
  doorway route reaches it, and `polygon_of` returning `int | None` is the
  tell. It then correctly identified `track.pos.transformed(camera)` as the
  route, and named the alternative (`sim.get(enemy).pos`) as "exactly the
  raw-parts recomputation blamed for the Gate 66 defect".
* #5 was offered a stored place versus asking the world afresh, and chose
  the world — for the right reason: "A stored Coordinate is inert... Option
  (A) would chase a point in empty space." It also ordered the catch check
  *before* normalising, so a caught boomerang never normalises a zero
  offset.

Self-reported confidence ran 58–70. Every one of them discounted for the
same class of reason: an inference the documentation left them to make.
That is the useful output.

## What they found

Six gaps were reported by more than one reader independently, which is the
signal worth acting on. All are now closed.

**1. A Track's destination space was never stated.** (3 of 5, and each
called it their single highest-risk assumption.) The stub said fields are
"developed into the space the observer asked for", but no Track-producing
call takes a space argument — so "the space the observer asked for" had to
be inferred to mean the observer's own. #2 put it precisely: "it's the
single most load-bearing space fact my function depends on, and it's the
one place a one-line docstring would have removed all doubt."
*Closed: the `Track` docstring now says it outright, and names the
`perihelion.senses` module as the other producer.*

**2. `edge_midpoint` had no docstring at all.** (Reader #2.) Its space was
inferred by analogy with `portal_transform`, which does spell its
directions out. *Closed: both `edge_midpoint` and `edge_normal` now name
the space, and say that a body standing in that polygon can subtract them
directly.*

**3. `Track.entity_id`: the design said `None`, the stub said `int`.**
(3 of 5.) A real contradiction between two documents both declared
authoritative. *Closed by deciding it rather than papering over it: a Track
is a snapshot, "does that body still exist" is `sim.exists(id)`, and making
one field of a snapshot a live query is the two-moments confusion the tick
stamp exists to prevent. Both documents now say so.*

**4. `group` was unexplained after the collision matrix was deleted.**
(3 of 5.) The design says the 16-wide mask is gone, yet `group` survives on
`spawn` and the perception calls. #1 declined to invent a value and made it
a required parameter — the right call. *Closed: `group` is documented as a
query tag only (ray masks, and the confirming ray's target), never a
collision rule.*

**5. Nothing exposes "the current tick".** (2 of 5.) `Track.tick` instructs
the reader to compare it against the current tick, and the engine has no
clock. #1 added an optional `current_tick` parameter rather than skip the
check. *Closed: `track_of` documents that the caller supplies the tick, and
that leaving it 0 makes every Track claim tick 0.*

**6. `develop` into the space you are already in was undemonstrated.**
(2 of 5.) Both readers deliberately declined to add an
`if same_space` short-circuit, on the grounds that it would resurrect the
anti-pattern the design spends two sections deleting — and then flagged
that they were reasoning from the design's spirit rather than a stated
guarantee. *Closed: documented as a no-op that returns the value unchanged,
"so callers never need an `if same_space` guard".*

Also closed: `normalized()` on a zero-length offset (returns `(1, 0)`, and
that fallback one layer down was THE FLICKER's root cause); `__bool__`'s
meaning; whether `Offset` arithmetic checks spaces (it does, by the same
three-case rule); `transformed()`'s failure mode (raises at the mistake);
`sim.get` on a dead id (raises); that a Track carries no radius, so
`get_radius` is where an extent comes from; and that `EntityState.space`
and `pos.space` are the same space rather than two opinions.

## The one that changed the code

Reader #3, on the cross-chamber blast, needed each body's place in the
blast's space (to measure falloff) **and** the blast's place in each body's
space (to push it away). It correctly used two `develop` calls, and then
reported the problem with that:

> two `develop()` calls per in-range enemy (one each direction) typecheck
> cleanly against the stub, but I could not find any documented way to get
> both directions' results from one graph search — `develop` returns a
> `Coordinate`, never the composed `Transform`

That is right, and it was a real hole: two searches whose routes are not
even guaranteed to be the same one. `Sim.transform_between(from, into)` now
returns the composed transform along the shortest route, and a transform is
invertible, so one search answers both directions and the pair provably
agrees.

Reader #3 also raised, unprompted, that a straight-line radius through a
doorway is a chord and not a walking distance — a genuine geometric
subtlety neither document mentions.

## What this leaves open

* **The existing detonations do not cross doorways.** `_detonate_tau` and
  `_detonate_dart` iterate `polygon_entities(polygon)`, so a blast stops at
  a threshold. That is failure mode 3 in the shipped code, in a form the
  design's audit never enumerated (it looked for `polygon == ppolygon`, and
  this wears a different shape). The primitive to fix it now exists;
  changing blast reach is a difficulty question, so it is recorded here
  rather than folded into this diff.
* **A length still has no space.** Every reader who was asked about it got
  the answer right and every one of them noted the docs decline to decide
  it. That remains true and remains the honest state.
