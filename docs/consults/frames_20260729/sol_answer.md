# Bottom line

Keep the intent of layers 1 and 2, but change three claims:

1. **Rust generative brands should be a scoped computation layer, not the ECS/storage representation.**
2. **A polygon ID alone is not enough to request an arbitrary transform.** In this graph, the portal route or visible instance is part of the transform’s meaning.
3. **Mypy cannot prove equality of runtime polygon identities.** The honest Python guarantee is:
   - mypy proves coordinate **categories and algebra**;
   - the PyO3 objects perform exact frame-identity checks in **release builds**;
   - raw coordinates and direct point subtraction are absent, so the shipped expression is not expressible.

If the director literally requires every runtime frame mismatch to be rejected statically by mypy, that requirement is impossible while Python performs frame-sensitive arithmetic.

| Property | Rust | Python |
|---|---|---|
| Point vs vector vs direction | Compile-time | Mypy |
| Polygon-local vs screen/model space | Compile-time | Mypy |
| Exact runtime polygon identity | Runtime check when branded, then compile-time in scope | Runtime check on every operation |
| Wrong point subtraction | Compile-time | Operation absent |
| Wrong transform endpoint | Compile-time after branding | Mypy category check plus runtime exact-key check |
| Correct portal route/visible instance | Explicit runtime route value | Explicit runtime route value |
| Stale transform after breach | Snapshot/revision check | Runtime revision check |

That is the strongest design I would call sound.

---

# 1. Soundness of the goal

## What is achievable

Runtime-created frames do not prevent static safety in Rust. They prevent the compiler from knowing frame equality *before runtime*. Rust can:

1. inspect a runtime `FrameKey`;
2. mint a fresh invariant brand for it;
3. validate stored values while binding them to that brand;
4. statically reject mismatched arithmetic for the remainder of that scope.

Thus the Rust theorem can be:

> In safe code using the public API, every executed frame-sensitive arithmetic operation has operands bound to the same validated runtime frame.

The initial binding can fail at runtime. Once it succeeds, the arithmetic is statically safe.

## What is not achievable in mypy

Mypy cannot express:

> “This type parameter denotes whichever integer happened to be returned by this particular call.”

It has no:

- dependent types over runtime `int` values;
- generative nominal types per function invocation;
- lifetime or existential scoping comparable to Rust;
- reliable narrowing of generic parameters from `frame_a.id == frame_b.id`.

`Literal[17]` works only when `17` is statically present. A plugin cannot soundly extend that to IDs discovered in loops, ECS queries, replay data, or runtime breaches.

Also, mypy is bypassed by `Any`, `cast`, untyped functions, dynamic attribute use, and incorrect stubs. It cannot honestly support an “always” claim for arbitrary Python.

## Strongest honest Python guarantee

The Python contract should be:

> No frame-mismatched operation through the public necore API can return a numerical result. Mypy rejects category errors and unsupported algebra; exact runtime identities are checked by Rust before every multi-value operation.

That is structural runtime safety, not static proof of polygon identity.

If static proof of exact identity is non-negotiable, move the relevant calculation into Rust and expose higher-level operations such as `fire_at(trace)` or `shove_along(trace)`. Do not search for a mypy trick; there is not one.

---

# 2. Rust design: persistent tagged values plus scoped brands

Do **not** put generative lifetimes in ECS components, serialized records, replay events, or long-lived collections. That would be extremely viral and would make heterogeneous frame storage awkward.

Use two representations.

## 2.1 Persistent representation: tagged, opaque, non-arithmetic

```rust
pub enum PolygonSpace {}
pub enum ScreenSpace {}
pub enum ModelSpace {}

pub trait Space: private::Sealed {}
impl Space for PolygonSpace {}
impl Space for ScreenSpace {}
impl Space for ModelSpace {}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub struct FrameKey<K: Space> {
    world: WorldInstanceId,
    slot: u32,
    generation: u32,
    _kind: PhantomData<K>,
}

pub struct LocatedPoint<K: Space> {
    frame: FrameKey<K>,
    xy: [f64; 2],             // private
}

pub struct LocatedVector<K: Space> {
    frame: FrameKey<K>,
    xy: [f64; 2],             // private
}
```

`LocatedPoint` and `LocatedVector` have:

- no `Sub`, `Add`, `x()`, `y()`, tuple conversion, or public raw fields;
- a frame key for diagnostics and later binding;
- explicit internal wire conversions.

If polygon slots can be reused, `generation` is mandatory. A stale Python point must not become valid merely because another polygon later receives the same `u32`.

`world` is a runtime session identity and need not be serialized.

The existing replay wire format remains unchanged:

```rust
struct BodyWire {
    polygon: u32,
    x: f64,
    y: f64,
    vx: f64,
    vy: f64,
    dirx: f64,
    diry: f64,
}
```

Construct `FrameKey` and `Located*` values when reading the ECS record. Do not add tags to the replay bytes.

## 2.2 Scoped representation: generatively branded and arithmetic

Use an audited generativity primitive rather than hand-rolling lifetime variance.

```rust
pub struct Frame<'id, K: Space> {
    key: FrameKey<K>,
    _brand: InvariantLifetime<'id>,
}

pub struct Point2<'id, K: Space> {
    xy: [f64; 2],
    _brand: InvariantLifetime<'id>,
    _kind: PhantomData<K>,
}

pub struct Vector2<'id, K: Space> {
    xy: [f64; 2],
    _brand: InvariantLifetime<'id>,
    _kind: PhantomData<K>,
}

pub struct Direction2<'id, K: Space> {
    xy: [f64; 2], // guaranteed finite and unit length
    _brand: InvariantLifetime<'id>,
    _kind: PhantomData<K>,
}
```

The invariant brand is essential. Covariant lifetimes could otherwise be shortened and unified.

Legal operations:

```rust
impl<'f, K: Space> Sub for Point2<'f, K> {
    type Output = Vector2<'f, K>;

    fn sub(self, rhs: Self) -> Self::Output;
}

impl<'f, K: Space> Add<Vector2<'f, K>> for Point2<'f, K> {
    type Output = Point2<'f, K>;

    fn add(self, rhs: Vector2<'f, K>) -> Self::Output;
}

impl<'f, K: Space> Add for Vector2<'f, K> {
    type Output = Vector2<'f, K>;

    fn add(self, rhs: Self) -> Self::Output;
}

impl<'f, K: Space> Vector2<'f, K> {
    pub fn scaled(self, amount: f64) -> Self;
    pub fn norm(self) -> f64;
    pub fn dot(self, other: Self) -> f64;
    pub fn try_direction(self) -> Option<Direction2<'f, K>>;
}
```

There is no point-plus-point operation.

Do not expose general coordinate components. Otherwise this remains writable:

```rust
let dx = player.x() - shooter.x();
```

Raw component access belongs in a small `coords::kernel` module used by geometry, serialization, and bindings, not in gameplay-facing APIs.

## 2.3 Dynamic-to-static binding

```rust
impl SimSnapshot {
    pub fn with_polygon_frame<R>(
        &self,
        key: FrameKey<PolygonSpace>,
        f: impl for<'id> FnOnce(Frame<'id, PolygonSpace>) -> R,
    ) -> Result<R, InvalidFrame>;

    pub fn with_entity_frame<R>(
        &self,
        eid: EntityId,
        f: impl for<'id> FnOnce(
            Frame<'id, PolygonSpace>,
            BodyView<'id>,
        ) -> R,
    ) -> Result<R, EntityError>;
}

pub struct BodyView<'f> {
    pub position: Point2<'f, PolygonSpace>,
    pub velocity: Vector2<'f, PolygonSpace>,
    pub facing: Direction2<'f, PolygonSpace>,
}
```

Binding stored values validates exact identity:

```rust
impl<'f, K: Space> Frame<'f, K> {
    pub fn key(&self) -> FrameKey<K>;

    pub fn bind_point(
        &self,
        p: &LocatedPoint<K>,
    ) -> Result<Point2<'f, K>, FrameMismatch>;

    pub fn bind_vector(
        &self,
        v: &LocatedVector<K>,
    ) -> Result<Vector2<'f, K>, FrameMismatch>;

    // Explicit assertion that numeric data is expressed in this frame.
    pub fn point(&self, x: f64, y: f64) -> Point2<'f, K>;
    pub fn vector(&self, x: f64, y: f64) -> Vector2<'f, K>;
}
```

`Frame::point(x, y)` is necessarily an assertion by the caller. Type systems cannot prove the provenance of arbitrary numeric literals. It should be used for authored geometry and spawn data, while engine-produced values should use checked binding.

## 2.4 Transforms

```rust
pub struct InstanceTransform<
    'snapshot,
    'from,
    'to,
    From: Space,
    To: Space,
> {
    matrix: Mat3, // private
    source: FrameKey<From>,
    target: FrameKey<To>,
    revision: TopologyRevision,
    _snapshot: PhantomData<&'snapshot TopologySnapshot>,
    _from: InvariantLifetime<'from>,
    _to: InvariantLifetime<'to>,
}

impl<'s, 'a, 'b, A: Space, B: Space>
    InstanceTransform<'s, 'a, 'b, A, B>
{
    pub fn apply_point(
        &self,
        p: Point2<'a, A>,
    ) -> Point2<'b, B>;

    pub fn apply_vector(
        &self,
        v: Vector2<'a, A>,
    ) -> Vector2<'b, B>;

    pub fn apply_direction(
        &self,
        d: Direction2<'a, A>,
    ) -> Direction2<'b, B>;
}
```

Raw `mat_apply`, `mat_apply_dir`, and arbitrary affine construction must not remain public to gameplay. Otherwise callers can erase the proof manually.

Topology transforms require a route or visibility instance:

```rust
pub struct PortalRoute<'s> {
    revision: TopologyRevision,
    directed_portals: &'s [DirectedPortalId],
}

impl<'s> TopologySnapshot<'s> {
    pub fn transform_along<'a, 'b>(
        &'s self,
        route: &PortalRoute<'s>,
        from: &Frame<'a, PolygonSpace>,
        to: &Frame<'b, PolygonSpace>,
    ) -> Result<
        InstanceTransform<'s, 'a, 'b, PolygonSpace, PolygonSpace>,
        RouteError,
    >;
}
```

The implementation checks:

- route revision;
- source and destination endpoints;
- portal validity;
- generation validity.

### Important correction to the proposed layer 2

A function like this is under-specified:

```rust
transform(from_polygon, to_polygon)
```

Two routes may connect the same pair of polygons and yield different transforms. A cycle may even produce a non-identity transform from a polygon back to itself.

Endpoint brands prove that a transform maps between the declared coordinate bases. They do **not** prove that the chosen portal instance was semantically intended. The route remains a runtime value.

A single canonical global frame is therefore not a valid replacement. A spanning tree would arbitrarily discard alternate images and would jump when topology changes.

## 2.5 Trace API

Find operations should use the observer frame and preserve the selected route:

```rust
pub struct SenseTrace<'s, 'f, K: Space> {
    pub entity_id: EntityId,
    pub kind: EntityKind,

    pub origin: Point2<'f, K>,
    pub position: Point2<'f, K>,
    pub toward: Option<Direction2<'f, K>>,
    pub distance: f64,

    pub subject_frame: FrameKey<PolygonSpace>,
    pub portal_depth: u32,
    pub instance_id: VisibilityInstanceId,
    pub topology_revision: TopologyRevision,
    route: PortalRoute<'s>,
    pub state_tags: StateTags,
}

impl<'s> Senses<'s> {
    pub fn sight_of<'f>(
        &'s self,
        observer: EntityId,
        target: EntityId,
        observer_frame: &Frame<'f, PolygonSpace>,
    ) -> Result<Option<SenseTrace<'s, 'f, PolygonSpace>>, SenseError>;
}
```

`sight_of` validates that `observer_frame` is the observer’s current frame. If a target is visible through multiple instances, either:

- return all traces, or
- document the exact selector used by singular `sight_of`, such as minimum composed distance.

For another output frame:

```rust
impl<'s, 'f, K: Space> SenseTrace<'s, 'f, K> {
    pub fn rebase<'out, Out: Space>(
        &self,
        via: &InstanceTransform<'s, 'f, 'out, K, Out>,
    ) -> SenseTrace<'s, 'out, Out>;

    pub fn in_subject_frame<'sub>(
        &self,
        subject: &Frame<'sub, PolygonSpace>,
    ) -> Result<SenseTrace<'s, 'sub, PolygonSpace>, TraceError>;
}
```

`in_subject_frame` uses the inverse of the trace’s exact selected route. Arbitrary rebasing requires an explicit route-bearing transform.

The corrected weapon then consumes the trace:

```rust
snapshot.with_entity_frame(eid, |frame, shooter| {
    let Some(hit) = senses.sight_of(eid, pid, &frame)? else {
        return Ok(());
    };

    if hit.distance > shove_range {
        return Ok(());
    }

    let Some(heading) = hit.toward else {
        return Ok(());
    };

    commands.fire(eid, &frame, shooter.position, heading)
})?;
```

No target position lookup is involved.

## 2.6 ECS mutation model

The branded scope should borrow an immutable tick/phase snapshot. Entity and topology mutations should be queued in a command buffer and validated when committed.

Otherwise an entity could cross a portal while a scope still assumes its former body frame. If in-place interior mutation cannot be removed, commands must carry and validate the expected `FrameKey`.

---

# 3. PyO3 boundary

Do not export tuples. Convert the static Rust witness into an owned runtime witness.

```rust
#[pyclass(frozen, subclass = false)]
struct PyFrame {
    world: WorldInstanceId,
    key: UntypedFrameKey,
}

#[pyclass(frozen, subclass = false)]
struct PyPoint2 {
    world: WorldInstanceId,
    frame: UntypedFrameKey,
    xy: [f64; 2],
}

#[pyclass(frozen, subclass = false)]
struct PyVector2 {
    world: WorldInstanceId,
    frame: UntypedFrameKey,
    xy: [f64; 2],
}

#[pyclass(frozen, subclass = false)]
struct PyInstanceTransform {
    world: WorldInstanceId,
    source: UntypedFrameKey,
    target: UntypedFrameKey,
    revision: TopologyRevision,
    matrix: Mat3,
}
```

Rules:

1. No `#[new]` for points, vectors, directions, traces, or transforms.
2. `Frame.point(x, y)` is the only public numeric point constructor.
3. Classes are immutable and non-subclassable.
4. No tuple iteration, `.x`, `.y`, `components()`, or public matrix.
5. Every multi-object operation checks:
   - same world;
   - exact frame key, including generation;
   - expected coordinate kind;
   - topology revision where applicable.
6. These checks are **not debug assertions**. Python cannot statically establish identity, so they must run in release builds.

A binding call should re-establish a Rust brand:

```rust
fn py_vector_to(
    snapshot: &SimSnapshot,
    frame: &PyFrame,
    origin: &PyPoint2,
    target: &PyPoint2,
) -> PyResult<PyVector2> {
    check_same_world(frame, origin, target)?;
    check_exact_frame(frame, origin)?;
    check_exact_frame(frame, target)?;

    snapshot.with_polygon_frame(frame.typed_key()?, |f| {
        let origin = origin.bind(&f)?;
        let target = target.bind(&f)?;
        Ok(PyVector2::from_branded(&f, target - origin))
    })?
}
```

Thus the lifetime proof is not carried across FFI, but it is not silently erased either. It is converted to a checked runtime tag and reconstructed on entry to Rust.

Python may need to create spawn points and authored geometry, so the requirement should be:

> Python cannot construct an **unframed** point.

Not “Python can never construct a point.”

Any raw numeric adapter needed by a third-party renderer should be a trusted leaf adapter that does not return coordinates to gameplay. If `.x` and `.y` remain generally available, the original defect remains structurally writable.

---

# 4. Mypy design

Use invariant generics for true static coordinate categories and relational propagation. Do not pretend that the generic argument is a runtime polygon ID.

A representative `.pyi`:

```python
from typing import Generic, Never, Self, TypeVar, final

class Space: ...
class PolygonSpace(Space): ...
class ScreenSpace(Space): ...
class ModelSpace(Space): ...

S = TypeVar("S", bound=Space)
T = TypeVar("T", bound=Space)
U = TypeVar("U", bound=Space)
P = TypeVar("P", bound=PolygonSpace)
Q = TypeVar("Q", bound=PolygonSpace)


@final
class FrameKey:
    def __new__(cls, _token: Never, /) -> Self: ...


@final
class Frame(Generic[S]):
    def __new__(cls, _token: Never, /) -> Self: ...

    @property
    def key(self) -> FrameKey: ...

    def point(self, x: float, y: float, /) -> Point2[S]: ...
    def vector(self, x: float, y: float, /) -> Vector2[S]: ...

    def vector_to(
        self,
        origin: Point2[S],
        target: Point2[S],
        /,
    ) -> Vector2[S]: ...

    def translate(
        self,
        point: Point2[S],
        displacement: Vector2[S],
        /,
    ) -> Point2[S]: ...

    def add_vectors(
        self,
        a: Vector2[S],
        b: Vector2[S],
        /,
    ) -> Vector2[S]: ...

    def direction(
        self,
        vector: Vector2[S],
        /,
    ) -> Direction2[S] | None: ...

    def local_distance(
        self,
        a: Point2[S],
        b: Point2[S],
        /,
    ) -> float: ...


@final
class Point2(Generic[S]):
    def __new__(cls, _token: Never, /) -> Self: ...
    # Deliberately no __sub__, __add__, __iter__, x, or y.


@final
class Vector2(Generic[S]):
    def __new__(cls, _token: Never, /) -> Self: ...

    def scaled(self, amount: float, /) -> Vector2[S]: ...
    def norm(self) -> float: ...


@final
class Direction2(Generic[S]):
    def __new__(cls, _token: Never, /) -> Self: ...

    def scaled(self, amount: float, /) -> Vector2[S]: ...


@final
class InstanceTransform(Generic[S, T]):
    def __new__(cls, _token: Never, /) -> Self: ...

    @property
    def source(self) -> Frame[S]: ...

    @property
    def target(self) -> Frame[T]: ...

    def apply_point(self, point: Point2[S], /) -> Point2[T]: ...
    def apply_vector(self, vector: Vector2[S], /) -> Vector2[T]: ...
    def apply_direction(
        self,
        direction: Direction2[S],
        /,
    ) -> Direction2[T]: ...

    def then(
        self,
        next: InstanceTransform[T, U],
        /,
    ) -> InstanceTransform[S, U]: ...


@final
class BodyView(Generic[P]):
    @property
    def frame(self) -> Frame[P]: ...

    @property
    def position(self) -> Point2[P]: ...

    @property
    def velocity(self) -> Vector2[P]: ...

    @property
    def facing(self) -> Direction2[P]: ...


@final
class Trace(Generic[S]):
    def __new__(cls, _token: Never, /) -> Self: ...

    @property
    def output_frame(self) -> Frame[S]: ...

    @property
    def origin(self) -> Point2[S]: ...

    @property
    def position(self) -> Point2[S]: ...

    @property
    def toward(self) -> Direction2[S] | None: ...

    @property
    def distance(self) -> float: ...

    @property
    def subject_frame_key(self) -> FrameKey: ...

    @property
    def portal_depth(self) -> int: ...

    def rebase(
        self,
        via: InstanceTransform[S, T],
        /,
    ) -> Trace[T]: ...

    def in_subject_frame(
        self,
        frame: Frame[Q],
        /,
    ) -> Trace[Q]: ...


class Senses:
    def sight_of(
        self,
        observer: int,
        target: int,
        *,
        in_frame: Frame[P],
    ) -> Trace[P] | None: ...


@final
class LocalContext(Generic[P]):
    @property
    def frame(self) -> Frame[P]: ...

    @property
    def body(self) -> BodyView[P]: ...

    def sight_of(self, target: int, /) -> Trace[P] | None: ...

    def fire(self, heading: Direction2[P], /) -> None: ...


class Sim:
    def local_context(
        self,
        eid: int,
        /,
    ) -> LocalContext[PolygonSpace]: ...
```

A controller can be checked parametrically:

```python
F = TypeVar("F", bound=PolygonSpace)

def defensive_tick(
    ctx: LocalContext[F],
    player: int,
    shove_range: float,
) -> None:
    hit = ctx.sight_of(player)
    if hit is None or hit.distance > shove_range:
        return

    heading = hit.toward
    if heading is not None:
        ctx.fire(heading)
```

This relational `F` is useful: all values obtained through `ctx` remain tied together in mypy. It is still not a freshly generated runtime identity. Two `LocalContext[PolygonSpace]` values may refer to different polygons.

## What mypy catches

It catches:

- local point passed to a screen-frame operation;
- wrong transform direction;
- point/vector/category confusion;
- forgetting a transform to screen space;
- applying a direction from one statically distinct space to an API requiring another;
- the shipped tuple unpacking and subtraction, because `Point2` is neither iterable nor subtractable.

## What remains runtime-only

This is accepted by mypy because both are `PolygonSpace`:

```python
frame_a.vector_to(point_a, point_b)
```

If `point_b` belongs to another polygon, Rust raises `FrameMismatchError`. It cannot produce a vector.

## Observer/subject role types

`ObserverFrame` and `SubjectFrame` are provenance labels, not identities:

- two different observers would both have type `ObserverFrame`;
- the same polygon can be observer in one operation and subject in another;
- annotations or casts can relabel them.

They may be useful as a lint in a specific subsystem, but they are not a proof and should not be the core model.

## Plugins, literals, and token tricks

- `Literal[polygon_id]`: useful only for hand-written static tests.
- Generated `NewType`s: incompatible with runtime carving.
- Mypy plugin generating a synthetic type per expression: unsound across loops, aliases, containers, deserialization, and equality.
- `Frame[F]` token: genuinely useful for propagating a relationship, but does not mint fresh `F`.
- Plugin/linter banning legacy APIs, coordinate escape, or non-generic spatial systems: useful enforcement, but not dependent typing.

Use `mypy --strict`, `check_untyped_defs`, `disallow_any_generics`, `warn_return_any`, and `stubtest` for the PyO3 stubs. Coordinate-bearing modules containing `Any` or `cast` should fail CI.

---

# 5. Migration without a big bang

## Phase 0: establish the baseline

Before changing behavior:

- save replay bytes and per-tick state hashes for the control seed;
- record event/RNG streams;
- add characterization tests for the existing `SenseHit`;
- inventory every raw producer and arithmetic call site.

For each call site, record:

| Site | LHS provenance | RHS provenance | Intended output frame | Equality/path witness | Distance source |
|---|---|---|---|---|---|

If the intended frame or witness cannot be named, the site is not understood enough to migrate.

## Phase 1: add representations without changing arithmetic

- Introduce `FrameKey`, `LocatedPoint`, and branded scoped types.
- Keep ECS and replay wire structures exactly unchanged.
- Implement typed methods by calling the same numeric kernels in the same order.
- Add the new PyO3 classes alongside the legacy tuple API.
- Add compile-fail and runtime mismatch tests.

This phase should remain byte-identical.

## Phase 2: enrich traces

Add, without yet changing consumers:

- `origin`;
- typed `position`;
- `toward`;
- selected `instance_id`/route;
- topology revision;
- exact subject frame key.

Compute them in the existing sensing pass, where the composed transform and distance already exist. Do not recompute them from body getters.

## Phase 3: migrate cross-frame sites first

These are the highest-risk sites and usually become smaller:

```python
hit = ctx.sight_of(player)
if hit is None or hit.distance > shove_range:
    return
if hit.toward is not None:
    ctx.fire(hit.toward)
```

Use the following decision rule:

| Operation | Intended frame |
|---|---|
| Steering, facing, projectile spawn, local collision | Acting body’s current polygon frame |
| Edge/wall geometry | Polygon owning that geometry |
| Sensing another entity | Observer frame from the selected trace |
| Applying a direct effect to target state | Target frame via the trace’s exact inverse route |
| Rendering/culling/comparison | One exact view/screen frame token |
| Portal traversal | Source frame before crossing; selected portal transform to destination |
| Range gate for a sensed target | `Trace.distance`, not endpoint `hypot` |

Do not choose a frame based on variable names. Do not choose an arbitrary shortest transform between polygon IDs.

## Phase 4: migrate same-frame sites

Wrap each body update in `LocalContext`/`with_entity_frame`. Same-frame code becomes mechanical:

- numeric waypoint → `frame.point(...)`;
- desired delta → `frame.vector_to(body.position, waypoint)`;
- terrain avoidance → typed terrain API;
- body movement → `frame.translate(...)`.

New signatures should look like:

```rust
pub fn edge_midpoint<'f>(
    &self,
    frame: &Frame<'f, PolygonSpace>,
    edge: EdgeId,
) -> Result<Point2<'f, PolygonSpace>, GeometryError>;

pub fn terrain_avoid_dir<'f>(
    &self,
    frame: &Frame<'f, PolygonSpace>,
    at: Point2<'f, PolygonSpace>,
    radius: f64,
    desired: Direction2<'f, PolygonSpace>,
    lookahead: f64,
) -> Result<Direction2<'f, PolygonSpace>, TerrainError>;
```

## Phase 5: close the escape hatches

After call-site count reaches zero:

- remove public raw `get()` tuples;
- remove public `mat_apply`/`mat_apply_dir`;
- remove point tuple conversion and coordinate properties;
- prohibit imports of the legacy/raw module with a linter;
- turn strict mypy on for migrated modules;
- retain raw access only in an audited engine/renderer kernel.

Until this phase, the structural guarantee does not exist globally.

## Shadow execution

For migration safety:

- execute old and new calculations side-by-side;
- for same-frame sites, assert bit-identical results;
- for cross-frame sites, log differences without feeding the new result into simulation;
- ensure shadow execution consumes no RNG and emits no commands.

This cleanly separates representational refactoring from intentional behavior correction.

## Replay caveat

A type-only migration can and should preserve byte-identical replay behavior.

A correction to a cross-frame decision cannot remain byte-identical if the control seed executes that decision and the corrected result changes state. That is logically impossible. Treat these as separate gates:

1. representation migration: byte-identical;
2. semantic fix: approved replay delta and new golden result.

Do not preserve the wrong result merely to describe the fix as replay-identical.

---

# 6. Test lesson and mechanical enforcement

## General rule

An identity transform is not a valid sole fixture for a frame-sensitive behavior.

Every behavior that consumes coordinates from more than one provenance must have a **frame-contrast case** where the naive raw answer and the composed answer observably disagree.

At minimum, the shared fixture set should contain:

1. same-chamber baseline;
2. two chambers with nonzero translation and rotation;
3. a scale-changing portal;
4. the same target polygon visible through two different portal routes;
5. breach open/close and stale-route rejection;
6. slot/generation reuse if IDs can be reused.

For the motivating weapon test, construct coordinates so that:

- raw and composed headings differ substantially, ideally opposite hemispheres;
- raw and real distances fall on opposite sides of `shove_range`;
- portal depth is nonzero.

A fixture builder can assert those conditions and reject a non-discriminating test case.

## Mechanical enforcement

### Central parametrized fixture

All spatial behavior tests use one fixture:

```python
@pytest.mark.frame_sensitive
def test_defensive_weapon(spatial_case: SpatialCase) -> None:
    ...
```

`spatial_case` is parametrized over same-frame, transformed, multi-instance, and mutation cases.

A pytest collection plugin should fail a `frame_sensitive` test that does not request this fixture. Pure local geometry tests require an explicit exemption such as:

```python
@pytest.mark.same_frame_unit(reason="Tests only convex polygon clipping")
```

### Gauge/reparameterization tests

Test-only code can independently change each chamber’s local basis by `G_p`. Portal transforms must change as:

```text
M'_(a→b) = G_b · M_(a→b) · inverse(G_a)
```

Transform geometry and entity positions correspondingly. Physical decisions should remain invariant, while returned local directions transform covariantly.

Random rigid rotations/translations are particularly effective. Test portal scaling separately if scaling is physically meaningful rather than merely a basis change.

### Static contract tests

Use:

- Rust `trybuild` tests proving differently branded points do not subtract;
- mypy golden tests proving point subtraction, point unpacking, and wrong transform endpoints fail;
- release-build Python tests proving mismatched polygon IDs raise;
- stale generation and stale topology revision tests;
- tests proving `Point2(...)` and `Transform(...)` cannot be constructed by Python.

These test the claimed guarantees themselves, not merely gameplay outcomes.

---

# 7. What this does not fix

This design does not prove or prevent:

1. **Wrong portal route or visible instance.**  
   Two transforms can have identical endpoint frame types but represent different portal paths.

2. **Wrong hit selection.**  
   The target may be visible through several images; choosing the wrong trace remains a sensing-policy bug.

3. **Incorrect transform implementation.**  
   Types prove endpoint labels, not that the matrix multiplication or portal metadata is numerically correct.

4. **Explicitly lying at a constructor.**  
   `frame.point(x, y)` asserts that those numbers belong to that frame. No type system can determine their provenance.

5. **Stale observations.**  
   A trace may be correctly tagged but old. Revision checks protect route reuse, not the game-design decision to act on stale sensory data.

6. **Entity or temporal mistakes.**  
   Wrong entity ID, observer/target reversal, and mixing snapshots from different ticks need separate safeguards.

7. **Metric mistakes.**  
   Local Euclidean norm, portal-path distance, squared distance, and configured gameplay range are different concepts. Consuming `Trace.distance` fixes the motivating case, but the scalar type does not prove metric choice.

8. **Direction/displacement semantics beyond framing.**  
   Zero-length normalization, velocity versus displacement, handedness, degrees versus radians, and knockback sign remain possible errors.

9. **Same-frame semantic errors.**  
   Two points may legitimately share a frame but represent the wrong objects or the wrong visible image.

10. **Unsafe/raw escape code.**  
    Rust `unsafe`, internal raw kernels, Python `Any`/`cast`, or a coordinate-exposing renderer adapter remain trusted boundaries.

11. **Floating-point and replay differences.**  
    Reordered normalization, matrix composition, or `hypot` calls may alter bits even when frames are correct.

---

The key architectural boundary is:

> Durable values carry runtime frame evidence but cannot do arithmetic. Arithmetic happens only after binding to one scoped Rust brand, or through a PyO3 frame capability that performs unconditional exact-key checks.

That gives Rust a real static proof, gives Python the strongest honest guarantee available, and makes the shipped expression unavailable rather than merely discouraged.