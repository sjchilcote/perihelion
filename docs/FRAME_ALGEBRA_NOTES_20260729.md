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
