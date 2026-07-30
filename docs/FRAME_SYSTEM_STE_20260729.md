# The coordinate-space system: report in Simplified Technical English

Date: 2026-07-29
Status: design settled in conversation with the director. Not implemented.

*Descriptive text in ASD-STE100. Project terms (polygon, portal, frame,
Coordinate, Offset, Transform, Track, torsor, holonomy) are technical
nouns. Sentences have a maximum of 25 words.*

## 1. Purpose

The game holds positions as pairs of numbers. A pair of numbers is only
correct in one coordinate space. Nothing in the code shows which space a
pair belongs to.

As a result, code can subtract two positions from different chambers and
get a number. The number is wrong and no message says so. This occurred,
a filmed playtest found it, and the cost was two gate cycles.

The new system gives every position an object that knows its space. Two
positions from different spaces cannot combine without a message.

## 2. The parts

- **CoordinateSpace** — an object that one polygon, or the screen, holds
  as a part of itself. It knows an identifier and a name. The identifier
  gives identity. The name is only for messages.
- **Coordinate** — a position with the space it belongs to, and a record
  of every Transform applied to it. Each entry in that record holds the
  identifier of the space it went into, and the matrix that moved it.
- **Offset** — the result when one Coordinate is subtracted from
  another. An Offset belongs to a space, but it is not a place. It is a
  difference between two places.
- **Transform** — a matrix with the identifiers of the two spaces it
  moves between. When a Transform is applied to a Coordinate, it adds to
  that Coordinate's record.
- **Track** — a report of one sighting from the perception system. It
  holds the identifier of the entity seen, a Coordinate in the space the
  caller asked for, the tick of the sighting, and the relational values
  that are already calculated.

## 3. How the check operates

An algebra operation on two Coordinates examines the record of each one.

If both records end at the same space identifier, the operation
continues.

If the records share an earlier space, the system can make the two
agree. It applies the inverse of the right operand's later Transforms,
and then the left operand's Transforms from that shared space. Both
Coordinates are then in one space and the operation continues.

If the records share nothing, the operation stops and gives a message.
The message names both spaces and both records.

## 4. Where each answer comes from

The perception system answers a search by entity tag. It gives back
Tracks. Each Coordinate in a Track is already in the space the caller
asked for. The route is the shortest physical path through the assembled
world, and not the smallest number of hops.

A caller can ask for the shortest path only. A caller can also ask for
every different path, shortest first. That second answer is a generator
and it can continue without an end, because a portal graph with a loop
holds paths without limit.

A Coordinate never examines the world. It replays only the matrices in
its own record. Thus a Coordinate stays correct after a breach carves a
chamber or a seal closes one.

One operation does examine the world: the world can develop a Coordinate
into a space the caller names. That operation does a deep graph search,
it belongs to the world and not to the Coordinate, and it can fail when
no path exists.

## 5. Why the split between a place and a difference

Positions in one space form a torsor. A torsor is a set that operates
like a group but has no start point.

The torsor gives the correct algebra. A Coordinate minus a Coordinate is
an Offset. A Coordinate plus an Offset is a Coordinate. Two Offsets add.
A Coordinate plus a Coordinate has no meaning and the system does not
hold it.

A portal can turn and can change scale. Thus a Coordinate moves by the
full matrix, and an Offset moves by only the turn-and-scale part of it. A
difference moved by the full matrix collects a wrong shift.

## 6. What the design catches

- Two positions from different chambers, subtracted. The system gives a
  message instead of a number.
- A position moved along a correct route to the wrong space, and then
  used as though it were in the space the code assumes. The system finds
  this at the first operation against a correct position.
- Code that holds itself to one polygon because a Transform is difficult
  to do. The perception system does the Transform, thus the difficult
  path is no longer the only correct one.

## 7. What the design does not do

- It does not find a Transform that crossed a portal which no longer
  exists. The director accepts this.
- It gives no way to express a Transform between two spaces with no
  path. That question does not occur, because no path exists.
- It does not prevent an author who says two spaces are joined when they
  are not.
- It does not make the type checker prove space identity. The identifier
  is a value at run time, thus the check is at run time.

The type checker still rejects a raw pair of numbers where a Coordinate
is correct, and it rejects an Offset where a Coordinate is correct.

## 8. The sequence of work

1. Add CoordinateSpace, Coordinate, Offset and Transform to the engine.
   Nothing calls them. Behavior does not change.
2. Add the Python objects for them. Python cannot build a Coordinate
   from numbers.
3. Give every entity query a Coordinate in that entity's own space. An
   entity that reads its own position is not affected, because its own
   space is the same space.
4. Give the perception system its tag search and its Tracks.
5. Move the call sites, innermost first, one group in each commit.
6. Remove the raw number accessors from Python. This step makes the
   error impossible to write.
7. Start the type checker on the game module.
8. Last, examine the four guards that compare a polygon with the
   player's polygon. Each one is a behavior change and each one needs its
   own filmed gate.

## 8b. The collision group system, examined

The director asked whether the collision group system is necessary. The
result: it is connected, but it holds very little.

Five groups exist. One function reads the matrix, in the collision loop.
The matrix holds 25 pairs and 5 of them are on: the player and an enemy
collide, two enemies collide, a player round hits an enemy, an enemy
round hits the player, and a player round can come back and hit the
player.

The pickup group collides with nothing. A pickup is collected by a
distance test and not by a collision. Thus that group can go.

The concept is necessary, because rounds must not collide with each
other. The interface is not: the matrix is set one time when the world is
built and it never changes again, so it can be a constant in the engine
and the Python function that sets it can go. That agrees with the law
that behavior is hardwired.

## 9. Open items

- A Track holds values calculated at one tick. The tick must be visible,
  or an old answer can look current.
- A value calculated when the caller asks for it examines the world at
  that moment, but the Coordinate is from an earlier moment. One Track
  must not hold two moments without a statement.
- A distance is a number and a number has no space. Thus a limit in one
  space is not comparable with a distance in a different space.
- The tie between two shortest paths must break the same way every time,
  because a stable answer is easier to reason about. The engine is not
  deterministic and this design does not assume that it is.

## 8c. Collision: everything touches, except a pickup

The director's ruling: friendly fire is on, and the game is a 2D
immersive simulation and not a generic arcade game. Thus rounds collide
with rounds, and a round from an enemy hits an enemy.

As a result the group system holds no information. The function that
sets a pair leaves the Python interface, the 16-wide mask goes, and the
pickup group goes. One fact remains: a pickup is not a physics object.
That fact belongs on the pickup.

What this gives, and all of it uses systems that already exist:

- A crowd obstructs itself. A group cannot fire through itself, thus it
  spreads or it holds. This adds to the garrison and quorum rules.
- The player can put one enemy between itself and a second enemy.
- The Adversary's thrown object pushes a Testator, which agrees with how
  the Adversary treats them.

The enemy stays ignorant of friendly fire on purpose. A check for a
friend in the line is the arcade answer, and an immersive simulation
prefers an enemy the player can use against itself.

One consequence needs work. An enemy can now kill an Adversary, and the
count of lost Adversaries increases on every death. That count is the
number behind the measurement that the player causes 30 percent of
Adversary losses. The count stays correct, because a dead body is lost,
but the cause must separate a player kill from a friendly-fire kill, or
the measurement no longer means what the ruling document says. The
damage function already carries its cause, so the information exists and
is only not separated.


---

# The work as built — 2026-07-29

## 10. What changed from the plan, and why

The plan said that Python cannot make a place from numbers. This is one
word too strong. A level file gives a polygon and a pair of numbers, and a
mouse gives a pair of screen numbers. Something must make a place from
them. Two operations do this:

    sim.place(polygon, x, y)     for authored data
    space.place(x, y)            for screen input

Each operation states the space in the same expression as the numbers.
This is the condition that makes them safe. The failure this system
prevents is numbers whose space is never stated. It is not numbers whose
space is stated and then checked.

A place has one operation that gives its raw numbers. The name is
`local()`. Three functions in the simulation use it: the sound function,
the decal function and the effect function. These functions write to
channels that the renderer and the mixer read, and those channels use raw
numbers. No other part of the game holds a raw pair.

A sighting report now carries the speed and the facing of the body, and
not only its place. Two behaviours need them: a body that jumps at a
moving target must lead the target, and the caller that marks the player
must aim at the ground behind him. Both need the value in the space of the
observer. The only correct method is to carry the value along the same
route as the place. A value carried along a different route differs by the
holonomy between the two routes. Such a value is a real number about
nothing.

The route policy measures between the centres of doorways. A true
shortest line through a set of polygons needs a different algorithm. The
measurement here is an upper limit on that line, and it is exact when the
path goes through the centres of the doorways. This is sufficient,
because it already disagrees with a measurement in hops, which was the
necessary property.

The confirming ray now goes as far as the transform walk. Before, the
walk was permitted twelve doorways and the ray was permitted three. A
straight line of sight through five small chambers therefore gave a
correct place and was then refused.

The collision matrix is deleted. One value on the body replaces it: the
body is physical, or it is not. A pickup is not.

Three tests of the form "if this polygon is the player's polygon" are
deleted. A fourth was not a restriction: it was a shorter method to get a
number that the function already gives, and it is deleted for clarity.

## 11. What the system found in the existing code

A type that refuses is worth what it refuses. Four defects appeared
during the change. Nobody knew about them before, and reading the code
did not show them.

1. The contact event gave the wrong polygon. The event is read after the
   whole physics step, and that step can move a body through a doorway.
   The event now records the polygon at the moment of contact.
2. Four functions that measure a distance from the player ran after the
   physics and used the polygon from before the physics. After the player
   crossed a doorway, they compared numbers from two chambers.
3. A capture could pull its captive to the wrong place. A grip across a
   doorway is normal, and the code subtracted two raw places.
4. The beam weapon pushed bodies in the wrong direction. The beam is
   aimed in the space of the shooter and can hit a body several chambers
   away.
5. A shot fired at point-blank range into a body that holds the player
   pushed in the wrong direction. A hold across a doorway is normal. This
   defect appeared only after 14,400 ticks of recorded play, when the
   whole test set was already correct: every test of a hold put both
   bodies in one chamber, which is the one condition that hides the
   defect. The correction is one named operation that carries a direction
   into the space of the body that receives it. It asks the world for one
   transform. If no route exists, the answer is none, and the hit does
   damage but gives no push, because no direction is correct.

A fifth item was a bad design and not a defect. The behaviour code kept
its own copy of each body's facing. The engine carries a facing through a
doorway transform; a copy in the game cannot. Every crossing therefore
used a facing from the previous chamber. There is now one value, and the
engine owns it.

## 12. What a type checker proves

The type checker proves the difference between a place, a difference and a
raw pair. It does this before the program runs. The addition of two places
has no definition, so the checker refuses it.

The type checker does not prove that two places are in the same space.
The identity of a space is a value that exists only when the program
runs. That half of the system refuses at run time.

A test holds this property. The test writes thirteen expressions, runs the
type checker, and requires that six are refused and seven are accepted.
Both halves are necessary. A system that refused every expression would
pass a test of the refusals alone, and would be useless.

## 13. What is still open

* A length has no space. A range of 560 units is 560 units in the metric
  of one space, and a portal that scales makes the same separation a
  different number on each side. The types make this choice visible. They
  do not make the choice.
* The renderer is outside this system by decision, not by proof. Bulk
  data for each frame crosses as raw numbers in one space, which is the
  screen. This is a decision about speed. It is safe because nothing in
  that data mixes two spaces.
* The two blast functions do not reach through a doorway. This is the
  third failure in the shipped code, in a form the first survey did not
  look for. The operation that makes the correction cheap now exists.
* Friendly fire is not yet measured for difficulty.


## 14. What the recorded playtest found

The test set was correct and the recorded playtest was not. Run 69 gave
0.87 against a limit of 0.95, and named two defects. Both were in the new
code and both were correct.

The first defect: a thrown object damaged the body that threw it, on
about three throws in ten. Friendly fire is new, so a round from an enemy
could reach another enemy for the first time, and that path did not have
the two rules the player path had: a round does not damage its own
shooter, and one object bills one body one time. Both rules now sit above
the choice of round type. They apply to every round.

The second defect: the net almost never connected. Three connects in
forty-three. The cause was the correction made earlier in this same work:
the two tools now hold separate distance bands, so the net only fires
beyond 165 units, and at that distance a round of 400 units per second
cannot catch a player who is moving. The promise "the middle buys time"
was a promise the player did not experience.

The correction is that the net now aims at where the player will be. A
thrown net is aimed. The heavy object stays unaimed, because a body that
is running away and heaving a mass at a pursuer who is already closing is
not a marksman. The measurement after the change is ten connects in ten.
