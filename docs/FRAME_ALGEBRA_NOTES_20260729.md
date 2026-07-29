# What kind of mathematical object is a reference frame here?

Date: 2026-07-29
Status: **conceptual groundwork only.** No implementation, no API. The
director's instruction: this is foundational to everything else in the
game, it is not easy, and there is probably a well-characterized
construct with the properties we want. This document is the search for
it.

## 0. Two things I got wrong first, because they were steering the search

**"There is no hub-local frame."** True, but I then over-corrected to
*"there is exactly one kind of coordinate space: a polygon's frame,"*
which is also false. Screen space already exists and is not
polygon-local. Frames are a **general set**. We can have whatever spaces
we need; polygons merely supply most of them.

**I proposed splitting "category" from "which polygon" as two axes.**
They are not two axes. There is one question — *which frame* — and
"screen" and "polygon 7" are two answers to the same question, not
answers to different questions.

## 1. The structure is a groupoid

Objects: frames. Morphisms: transforms. Every transform is invertible
(a portal traversed backwards). Composition is associative, identities
exist. That is the definition of a **groupoid**.

Ours specifically is (close to) the **fundamental groupoid** of the
portal graph: the objects are chambers, and a morphism `A → C` is a
*route* — a path through portals — with composition by concatenation.

This immediately explains the operations we want:

* `Xform<A,B> ∘ Xform<B,C> = Xform<A,C>` is composition.
* `Xform<A,A> = id` is the identity morphism.
* Every `Xform<A,B>` has an inverse `Xform<B,A>`.
* `Pos<F>` is a family of types **indexed by the objects** of the
  groupoid, and applying a transform is transport along a morphism.

## 2. The groupoid is NOT thin, and that is the whole game

A *thin* groupoid has at most one morphism between any two objects. Ours
does not: `A→B→C` and a direct `A→C` are **different morphisms**, and
they generally carry **different matrices**.

The measure of this is **holonomy**. Take a loop `A→B→C→A`; compose the
transforms; you do not get the identity. The failure-to-be-identity is
the holonomy of that loop, and the set of them forms the holonomy group.

This is not a defect to be engineered away. It **is** non-Euclidean
space. A room seen through two different doors legitimately appears at
two different places, at possibly different scales and rotations. The
engine already commits to this: `visible_set` returns *per-instance*
transforms, precisely because one chamber can appear several times in
one frame by several routes.

**Consequence for the type design, and it is the important one:** a
frame identifier alone does not determine a transform. "Give me the
transform from polygon 7 to polygon 12" is an ill-posed request. The
route (or the visible instance) is part of the morphism's identity. The
Sol consult reached this independently and states it as its second
correction.

## 3. The classical name for what this game is

A portal space is a **(G, X)-structure** in Thurston's sense: a space
covered by charts into a model space `X` (here ℝ²) whose transition maps
lie in a group `G` (here the affine/similarity group). Chambers are the
charts; portal transforms are the transition maps.

Two standard objects come with it, and we have already built both
without naming them:

* The **developing map**: the attempt to build one global coordinate
  system by continuing charts along paths. It is well-defined on the
  *universal cover*, not on the space itself. **`visible_set` is a
  developing map** — it unfolds the portal graph into a tree of
  instances and hands back the composed transform for each.
* The **holonomy representation** `π₁ → G`: the homomorphism recording
  what each loop does to your coordinates.

This gives the sharpest possible statement of why our problem is
irreducible:

> **A single global coordinate frame exists if and only if the holonomy
> representation is trivial.** Ours is not trivial. Therefore no global
> frame exists, therefore positions are irreducibly frame-relative,
> therefore the type system has to carry the frame. There is no clever
> canonicalization that makes the problem go away.

That is worth knowing before spending effort looking for one. I was
half-looking for one.

## 4. The local structure is a torsor

Within one frame, positions form an **affine space**: a **torsor** over
the translation vector space. "Torsor" is the precise, well-studied name
for *a set that looks like a group but has no chosen origin*.

Every operation we want falls straight out of the torsor axioms:

    Pos - Pos   -> Disp     (the torsor's difference map)
    Pos + Disp  -> Pos      (the action)
    Disp + Disp -> Disp     (the underlying group)
    Disp * k    -> Disp     (the underlying vector space)
    Pos + Pos   -> undefined, because there is no origin to add relative to

So the point/vector distinction is not stylistic. It is the difference
between the torsor and the group acting on it, and getting it wrong is
the same class of error as mixing frames.

Directions and velocities are a third thing again: they transform by the
*linear part* of the morphism, not the affine part. That is a separate
family, and conflating it with `Disp` under a portal that scales is
another live bug class.

## 5. The type-theoretic view: an indexed family, and transport

`Pos : Frame → Type` is a **fibration** over the groupoid — a
type family indexed by the objects. Applying a transform is exactly
**transport** along a morphism (`subst`/`transport` in dependent type
theory; transport along a path in HoTT).

This is the right abstraction because it says precisely what a type
system must do: track the index, and permit an operation only when the
indices agree. Path-independence of comparability also falls out, since
the index records the endpoint, not the route.

Nuance worth keeping: two `Pos<C>` obtained by different routes are both
genuinely in C and are legitimately comparable *as coordinates*; they
just denote different **images** of the object. The type answers "can I
do arithmetic with these" (yes) and cannot answer "did you mean this
image" (a real question the type will never settle).

## 6. How do you get a static tag for a runtime-created object?

The director's worry: do we have to keep references to objects on the
vector type? No, and this is the best-characterized part of the whole
problem.

The canonical construct is **rank-2 existential branding**, whose
textbook instance is Haskell's `ST` monad:

    runST :: (forall s. ST s a) -> a

The `s` is a phantom index that cannot escape the scope and cannot be
unified with any other scope's `s`. Rust's equivalents are the
`generativity` crate and `GhostCell`; the verification community calls
the same idea **ghost state**.

Applied here: `with_frame(polygon, |f: Frame<'id>| ...)` mints a fresh
invariant lifetime per scope. `Pos<'id>` unifies only with the same
brand. Crucially the brand is a **phantom — zero bytes at runtime**, so
the answer to "do we keep references on the vector" is *no*: in scope,
nothing at all; in storage, a small **frame key** (an integer), never a
pointer to a polygon object.

## 7. Prior art, and where each one stops

* **ROS `tf2`** is the industrial version of this: transforms stamped
  with parent and child frame ids, composed on demand, timestamped. But
  tf2 assumes a **tree**. A tree has exactly one path between any two
  frames, i.e. a *thin* groupoid, i.e. no holonomy. Our graph has cycles,
  so tf2's central assumption is the one thing we cannot borrow.
* **Units of measure** (F#, `uom`, `pint`) are phantom types over a
  **free abelian group** of dimensions. That is the wrong generalization:
  units compose commutatively and every unit is comparable to every
  other via conversion. Frames compose *non-commutatively* and most
  pairs have no canonical conversion at all. Group is not groupoid.
* **Dependent/refinement types** (Idris, Agda, F\*, Liquid Haskell) can
  express the real thing — indices over runtime values. We do not have
  them in Rust or Python, and brands are the standard approximation.

## 8. The dimension I had not accounted for: the groupoid changes

Breaches carve **new chambers and new links at runtime**, and seals
remove them. So we do not have one groupoid; we have a **time-indexed
family of groupoids**, and a transform is only meaningful at the
revision it was derived from.

A stored `Xform` used after a seal is a distinct bug class from a frame
mismatch, and no amount of frame typing catches it. It needs a
**revision stamp** on the transform, checked on use. The consult reached
the same conclusion independently.

## 9. What this settles, and what it leaves open

Settled:

* The object is a **groupoid**, non-thin, with **holonomy**; the game is
  a **(G,X)-structure**; `visible_set` is a **developing map**.
* No global frame exists, provably, because holonomy is nontrivial.
* Within a frame: **torsor**, giving the point/vector algebra exactly.
* `Pos` is an **indexed family**; transform application is **transport**.
* Static tags for runtime objects: **rank-2 brands / ghost state**,
  phantom and free at runtime. No object references on the value.

Open, and these are the real design questions:

1. **Does a position carry only its frame, or also its route?** Frame
   alone is enough for arithmetic. Route matters for "which image of
   that chamber am I talking about". Answering this decides whether
   `visible_set` instances are first-class frames in their own right —
   which is attractive, because it would make screen space and instance
   space the same kind of thing.
2. **Is `Screen` one frame or one per instance?** If a chamber appears
   twice on screen, "screen space" may need to be indexed by instance to
   stay honest.
3. **Where is the boundary** between branded scoped computation and
   tagged persistent storage, given the ECS, replay, and the
   byte-identical-seed requirement?
4. **What is the revision discipline** for transforms across a breach or
   seal?

---

# 10. The simplification that collapses this (director, 2026-07-29)

> "We don't need to prove anything about the path that was taken, we only
> need to prove that it ended in the same spot."

This is correct, and it is a much bigger simplification than it sounds.

## 10.1 Why it is sound, not merely convenient

Holonomy makes *where you land* depend on the route. It does not make the
landing coordinate any less a coordinate of the frame you landed in.
Transport a position around a loop back to A and you get a different pair
of numbers — but they are still valid A-coordinates, and subtracting them
from an untransported A-position is legitimate arithmetic that answers a
real question ("how far apart are these two images").

So endpoint equality is **sufficient for well-formedness**. The remaining
question — *which image of the chamber did you mean* — is a decision
about which transform to apply, made before the arithmetic. It is a
gameplay question, and a type system should stay out of it.

## 10.2 What it deletes from the design

I had been heading toward putting the groupoid's **morphisms** into the
types: routes, path words, a free groupoid on the portal graph, types
that record how a value travelled. All of that goes.

**The groupoid lives at runtime. The types need only its object set.**

Concretely:

* `Pos<F>` is indexed by frame identity alone. No route, ever.
* `Xform<A,B>` needs only its two endpoints in the type. Which route the
  topology chose is a runtime property of the matrix, not of the type.
* Composition still type-checks as `Xform<A,B> ∘ Xform<B,C> = Xform<A,C>`
  and does not care that a direct `A→C` also exists with a different
  matrix. Both are `Xform<A,C>`. That is the *desired* behaviour.
* §2's non-thinness stops being a typing problem. It remains a real
  property of the world, handled where it belongs: in the topology, and
  in the caller's choice of which visible instance to ask about.

The director's worked example resolves with nothing left over:

| value | type | verdict |
|---|---|---|
| position in A | `Pos<A>` | refused where `Pos<C>` wanted |
| A→B | `Pos<B>` | refused |
| A→B→C | `Pos<C>` | accepted |
| A→C, after linking C—A | `Pos<C>` | accepted, identically |
| two positions, independently → screen | `Pos<Screen>` both | combine, no prior coordination |

## 10.3 What the problem reduces to

Exactly one question remains:

> **How do we reflect the identity of a runtime-created frame into the
> type system, so that "same frame" is a static fact?**

That is no longer geometry. It is the well-studied problem of giving a
runtime value a nominal type identity, and it has known answers:

* **Rank-2 existential branding** — Haskell's `runST`, `Data.Reflection`'s
  `reify`, Rust's `generativity` / `GhostCell`. A fresh invariant index
  per scope that cannot unify with any other. Phantom, zero bytes.
* **Singleton types** in dependently typed languages, which is the same
  idea with the runtime witness kept.

The essential ingredient is **invariance**: a merely covariant lifetime
would let the compiler unify two different frames by subtyping, which
silently destroys the guarantee.

## 10.4 The one seam left, and it is bounded

Two brands minted for the *same* polygon in different scopes will not
unify, even though they denote the same spot. This is conservative — it
refuses valid programs, never accepts invalid ones — but it is the thing
that will actually annoy in practice.

The standard remedy is a single **dynamic-to-static bridge**: compare
the two frame keys once at runtime and, on success, hand back a proof
witness that makes everything downstream static.

    fn unify<'a, 'b>(a: Frame<'a>, b: Frame<'b>) -> Option<Same<'a, 'b>>

This is the only place a runtime frame comparison should exist, and it
is sound because it produces a proof rather than permitting an operation.

## 10.5 What is unaffected

Endpoint-only typing does **not** help with:

* **Staleness.** A transform derived before a breach carved or a seal
  closed still has type `Xform<A,B>` while its matrix is wrong. Needs a
  revision stamp (§8), unchanged.
* **Scale.** A `float` distance carries no frame, so comparing it against
  a threshold expressed in another frame is still unchecked (§9).
* **Point vs vector vs direction.** Still the torsor distinction (§4),
  orthogonal to all of this.

---

# 11. Requirements read-back (2026-07-29)

No mechanism here on purpose. Several mechanism proposals have already
been wrong (parallel "hub-local" spaces, a static/runtime category split,
scope-generated brands, polygon ids as frame ids, allocated frame ids).
Each was proposed in reaction to a correction rather than derived from
the requirements, which is how a design gets talked into a shape nobody
chose. The requirements are recorded first, and stand on their own.

## 11.1 What must not be silently possible

R1. Ask two objects for their position, subtract, and receive a number
    when the two positions are not in the same frame.
R2. Transform a position along a legitimate route to the WRONG frame,
    and then use it as though it were in the frame the code assumes.
    The route being valid is not the question; the destination is.
R3. Be pushed into restricting work to a single polygon because
    transforming properly is inconvenient. This is a usability
    requirement with a correctness consequence: the observed failure is
    guards of the form `if polygon == ppolygon`, which do not compute a
    wrong answer but decline to compute at all, and so make bodies inert
    across doorways in a game whose stated law forbids exactly that.

In all three the defect is SILENCE. A loud refusal is an acceptable
outcome; a plausible number is not.

## 11.2 What must remain expressible

R4. position − position → displacement, within one frame.
R5. position + displacement → position.
R6. displacement arithmetic: add, subtract, scale, magnitude.
R7. Application of a transform to a position, and composition of
    transforms.
R8. Two positions that reached a common frame INDEPENDENTLY, with no
    prior coordination between the code paths that produced them, must
    be usable together. The worked case: both transformed to screen.
R9. Position + position must not exist. It has no meaning.

## 11.3 Identity

R10. Frame sameness must be decidable.
R11. Frame sameness must be STABLE and FINAL. The same frame reached
     twice — in different scopes, at different times, by different code
     — must compare as the same frame. Anything that mints a fresh
     identity per scope is rejected.
R12. Frame identity must not depend on the route taken to reach it.
     A→B→C and A→C both arrive at C.
R13. Frames are NOT polygons. A polygon has a frame; screen is a frame
     and has no polygon. The set of frames is its own thing.
R14. Frames can come into existence during a session, because breaches
     carve new chambers.

## 11.4 Enforcement

R15. The guarantee must come from construction, not from a convention or
     a hand-written guard the checker cannot see.
R16. Both Rust and mypy must reject what each is capable of rejecting.
R17. A frame mismatch must never yield a number.

## 11.5 Explicit non-goals (director, verbatim in spirit)

N1. A transform derived across a link that no longer exists may still
    pass. Not a concern.
N2. There need be no way to express a transform between two frames that
    are not linked. That question is never asked, because they are not
    linked.
N3. Deliberately pretending two things are linked is permitted to
    succeed. That is the author's doing and may be intentional.
N4. No general guarantee of spatial correctness is wanted. The target is
    exactly R1-R3.

## 11.6 Environment

E1. No dependent types in either language.
E2. Rust lifetimes do not cross the PyO3 boundary.
E3. The control seed must stay byte-identical through the migration.

## 11.7 What is genuinely open

Q1. R11 (stable identity) and "static proof" pull against each other.
    Generativity gives static distinctness but violates R11. A stable
    runtime key satisfies R11 but is, as observed, an arbitrary label
    carrying no static content. Whether some third thing satisfies both
    is the open question, and I do not currently know the answer.
Q2. Whether a frame must be a runtime object at all, or whether it can
    be purely a type-level thing that a runtime value merely witnesses.
Q3. What the carrier of frame identity should BE, if not an allocated
    id — whether a coordinate system has anything intrinsic to be
    identified by.

---

# 12. Can a transported sentinel detect "same frame"? No — proof

Director's question: is there a sentinel value we transform alongside
the real vector, applying every transform to both, such that comparing
sentinels detects "same reference frame" — without tracking frames?

## 12.1 Counterexample

Chambers A and C joined by two portals, P and Q. The transform through P
is the identity; through Q it is translate(100, 0). Both are legitimate
morphisms A→C. For a sentinel s0 in A:

    via P:  s = s0
    via Q:  s = s0 + (100, 0)

The sentinels differ, but both results are genuinely C-coordinates. The
test reports "different frames" and is wrong, violating R8 and R12.

## 12.2 The general obstruction

For a pushed-through sentinel to work there must be an assignment of a
marker to each frame preserved by EVERY morphism:

    T . s_A = s_B    for every T : A -> B

That is an invariant section of the groupoid action. Composing any loop
back to A requires h . s_A = s_A for every holonomy h at A. So the
section exists **iff the holonomy group has a common fixed point**. A
pure-translation holonomy has no fixed point at all, so generically no
such marker exists.

## 12.3 The one-line reason

**The destination frame is not a function of the accumulated matrix.**
A matrix is numbers; the same numbers can be a morphism between many
different pairs of frames. The codomain is extra structural data carried
by the morphism, not recoverable from it. No quantity pushed through the
same matrices can reconstruct it, because the information was never in
the numbers.

Corollary: the variant where the sentinel accumulates the transform
itself is route-dependent, so two values independently reaching screen
space would be refused — breaking the case the director specifically
requires.

## 12.4 What survives, and why it is not the rejected "arbitrary id"

The information must come from the morphism, because that is the only
place it exists. So the tag rides on the value and the TRANSFORM writes
it. No frame is ever named, looked up, or managed by a caller.

The director's lerp example then works exactly as described: a body in B
receives a displacement already transformed into B, samples points along
it, compares them with its own position, and every line is ordinary
single-frame Euclidean geometry. A vector transformed to the wrong place
is refused at the first comparison.

This differs from the rejected "allocated id" in the thing that matters:
nobody allocates or maintains an identity. The identity IS the codomain
of the morphism — structural data the topology already holds when it
builds the transform.

---

# 13. Two confirmations, and the static/runtime split they expose

## 13.1 A->B->C versus D->B->C

Confirmed: no construct detects by simple equality that these end in the
same coordinate system without knowing what A, D and C are. Both results
are float pairs, and a pair of reals carries nothing about which
coordinate system it belongs to. The frame of a result is the CODOMAIN
of the morphism — a label on the morphism, absent from both the matrix
and the coordinates. It has to be carried.

Near-miss tested and rejected: tagging a value with THE LAST TRANSFORM
APPLIED. Attractive because A->B->C and D->B->C share a final
T(B->C). It fails in both directions. A value native to C has no last
transform and a value arriving by E->C has a different one, so both are
in C and would be falsely refused. And it catches no errors at all,
because a transform does not inspect its input: apply T(B->C) wrongly to
a value in D and the tag still reads T(B->C). Neither necessary nor
sufficient.

## 13.2 Camera transforms

Confirmed for the general case: cam_A . p and cam_B . q are float pairs,
and recovering the shared camera factor needs the matrices in hand,
which is tracking.

## 13.3 The split this exposes, which is useful

A frame that is UNIQUE AND KNOWN AHEAD OF TIME can be a static type,
checked by the compiler and by mypy, at zero runtime cost. A frame
CREATED AT RUNTIME cannot be, and must carry its codomain as data.

Screen is in the first category: there is exactly one, and it exists at
compile time. So the case of two positions from different chambers
independently transformed to screen — the director's own example — is
fully statically solvable. A screen-typed value combines with another
screen-typed value; a chamber-local value used where screen is wanted is
a compile error.

Chambers are in the second category, because breaches carve them during
a session.

This is the first principled line between what the type system can hold
and what must be runtime data, and it is drawn by a property of the
FRAME (unique and statically known, or not), not by a property of the
code.
