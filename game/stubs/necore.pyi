"""Type stubs for the engine extension module.

WHAT THIS BUYS. `necore` is a compiled PyO3 module, so mypy sees nothing at
all without a stub — and with one it can prove the TYPE distinctions that
the coordinate system rests on, statically, before anything runs:

    place - place   -> difference          checked here
    place + diff    -> place               checked here
    place + place   -> REJECTED            no such overload exists
    diff  + diff    -> diff                checked here
    a tuple where a place belongs -> REJECTED

What it cannot prove is space IDENTITY, because a space id is a runtime
value: whether two places are in the same chamber is a fact about a running
world, and no amount of annotation decides it. That half is the runtime
algebra, which raises `FrameMismatch`. Claiming more than this would be
dishonest (docs/FRAME_SYSTEM_DESIGN_20260729.md §11).

This file is also the API reference. If a signature here disagrees with
engine/necore-py/src/, the stub is the bug.
"""
from typing import Iterable, Sequence

M9 = tuple[float, float, float, float, float, float, float, float, float]
Pair = tuple[float, float]

class FrameMismatch(ValueError):
    """Two values were combined across spaces that share no route."""

# --------------------------------------------------------------------------
# coordinate spaces
# --------------------------------------------------------------------------

class Space:
    """A coordinate space's identity. Constructing one MINTS a new space."""

    def __init__(self, name: str) -> None: ...
    @property
    def id(self) -> int: ...
    @property
    def name(self) -> str: ...
    def place(self, x: float, y: float) -> Coordinate:
        """The place in THIS space at (x, y) — for numbers whose space is
        known but which no engine query produced (screen-space input)."""
    def __eq__(self, other: object) -> bool: ...
    def __hash__(self) -> int: ...

class Coordinate:
    """A place: values, the space they are in, and the record of how they
    got there. NOTE THE ABSENCE OF A CONSTRUCTOR — a place can only come
    from somewhere that knows which space it is in.

    EVERY OPERATION BELOW THAT TAKES A SECOND VALUE CHECKS THE SPACES, and
    all of them use the same three-case rule:

      1. both terminate in the same space          -> proceed, no work
      2. their records share an EARLIER space      -> the right operand is
         inverted back to it and carried forward along the left operand's
         steps, then proceed
      3. no shared space                           -> raise FrameMismatch

    Case 1 is the common one and costs nothing. Case 2 is what lets a
    sighting developed one way meet a value developed another, without
    consulting the world. Nothing here ever guesses."""

    @property
    def space(self) -> Space: ...
    @property
    def chain(self) -> list[Space]:
        """Every space this place has been in, oldest first."""
    def local(self) -> Pair:
        """The raw pair, in this place's own space.

        For handing to a channel that names the space alongside it — a
        sound at (polygon, x, y), a decal, a screen-space bounds test.
        NEVER for arithmetic against a coordinate whose space you have not
        already established: `a.local()[0] - b.local()[0]` is the bug this
        whole module exists to stop. Two values you have PROVED to be in
        one space (both minted there, or both carried there by a checked
        transform) may be compared as numbers — that is the legitimate
        use, and the proof is the part that matters."""
    def offset(self, dx: float, dy: float) -> Offset:
        """A difference expressed in THIS place's space."""
    def distance_to(self, other: Coordinate) -> float: ...
    def toward(self, other: Coordinate) -> Offset:
        """The offset FROM self TO other, in self's space."""
    def transformed(self, t: Transform) -> Coordinate:
        """Apply a transform, appending to the record. RAISES
        FrameMismatch if this place is not in the transform's source
        space — immediately, at the mistake, rather than leaving it for
        the algebra to notice later."""
    def __sub__(self, other: Coordinate) -> Offset: ...
    def __add__(self, o: Offset) -> Coordinate: ...

class Offset:
    """A difference. Belongs to a space but is not a place, so it moves by
    the LINEAR part of a transform only.

    `__add__`, `__sub__`, `dot` and `cross` check spaces by the same
    three-case rule as `Coordinate` (see above) and raise FrameMismatch
    rather than trusting the caller. `__mul__`, `__neg__`, `rotated` and
    `normalized` take no second operand and cannot fail that way."""

    def __init__(self, space: Space, dx: float, dy: float) -> None: ...
    @property
    def space(self) -> Space: ...
    @property
    def length(self) -> float: ...
    @property
    def angle(self) -> float: ...
    def local(self) -> Pair: ...
    def normalized(self) -> Offset:
        """Unit-length, same space. A ZERO-LENGTH offset normalises to
        (1, 0) rather than raising or returning NaN — a defined fallback,
        and a trap: an arbitrary (1, 0) is a real direction that points
        somewhere, so check `length` (or truth) before relying on it. This
        exact fallback, one layer down, was the root cause of THE FLICKER
        (a zero-length polygon edge whose "normal" fabricated a phantom
        half-plane)."""
    def rotated(self, theta: float) -> Offset: ...
    def dot(self, o: Offset) -> float: ...
    def cross(self, o: Offset) -> float: ...
    def transformed(self, t: Transform) -> Offset:
        """Apply a transform's LINEAR PART, appending to the record.
        Raises FrameMismatch on a wrong source space, like the Coordinate
        form."""
    def __add__(self, o: Offset) -> Offset: ...
    def __sub__(self, o: Offset) -> Offset: ...
    def __mul__(self, k: float) -> Offset: ...
    def __rmul__(self, k: float) -> Offset: ...
    def __truediv__(self, k: float) -> Offset: ...
    def __neg__(self) -> Offset: ...
    def __bool__(self) -> bool:
        """False for a zero offset, true otherwise — so `if not heading:`
        is the guard to write before `normalized()`."""

class Transform:
    """A matrix plus the two spaces it maps between."""

    def __init__(self, from_space: Space, to_space: Space, m9: M9,
                 name: str = ...) -> None: ...
    @property
    def from_space(self) -> Space: ...
    @property
    def to_space(self) -> Space: ...
    @property
    def m9(self) -> M9: ...
    def inverse(self) -> Transform: ...

class EntityState:
    """One body's state at one instant.

    `space`, `pos.space`, `vel.space` and `dir.space` are all the same
    space — the body's own — so `space` is a shorthand, never a second
    opinion."""

    @property
    def polygon(self) -> int:
        """Which polygon the body is in. An index, not a coordinate:
        comparing two of these is a topology question and is always
        meaningful."""
    @property
    def space(self) -> Space: ...
    @property
    def pos(self) -> Coordinate: ...
    @property
    def vel(self) -> Offset: ...
    @property
    def dir(self) -> Offset: ...
    @property
    def radius(self) -> float: ...
    @property
    def speed(self) -> float: ...

class Track:
    """A report of a sighting, from perception.

    Not a proxy for an entity — a record ABOUT one. `pos`, `vel` and `dir`
    are all developed INTO THE OBSERVER'S OWN SPACE (the space of the
    polygon the observer is standing in), along the SAME route. That is
    what makes a sighting directly comparable with the observer's own
    position, its chamber's doorway midpoints, and anything else read out
    of that space — no `develop` call needed.

    Tracks are produced by `Sim.track_of` / `Sim.tracks_to` /
    `Sim.sentry_acquire`, and by the game's own `perihelion.senses`
    module (`sight_of`, `find`, `nearest`, `every_route`), which adds
    identity and tag filtering on top. `senses` is documented in its own
    module docstring; everything it returns is one of these."""

    @property
    def entity_id(self) -> int:
        """WHO was seen — the id, as it was at `tick`.

        Always an int, never None: a Track is a snapshot, and "does that
        body still exist" is a question about the world NOW, which is
        `sim.exists(id)`. (An earlier draft of the design had this read
        None once the subject left the world; that would have made one
        field of a snapshot a live query, which is exactly the two-moments
        confusion the tick stamp exists to prevent.)"""
    @property
    def polygon(self) -> int:
        """The polygon the body was in when it was seen."""
    @property
    def pos(self) -> Coordinate: ...
    @property
    def vel(self) -> Offset: ...
    @property
    def dir(self) -> Offset: ...
    @property
    def path_distance(self) -> float:
        """Physical path length along the route taken."""
    @property
    def distance(self) -> float:
        """Straight-line distance in the OBSERVER's space."""
    @property
    def portal_depth(self) -> int:
        """How many doorways the sighting crossed. 0 = same chamber."""
    @property
    def tick(self) -> int:
        """The tick this sighting was taken on. Compare it with the current
        tick before acting on anything else here."""

class RayResult:
    @property
    def kind(self) -> str:
        """"wall", "ent" or "none"."""
    @property
    def entity_id(self) -> int | None: ...
    @property
    def polygon(self) -> int: ...
    @property
    def edge(self) -> int | None: ...
    @property
    def pos(self) -> Coordinate:
        """Where it ended, in the HIT polygon's space."""
    @property
    def to_origin(self) -> Transform:
        """Hit space -> the space the ray was fired from."""
    @property
    def distance(self) -> float: ...
    @property
    def hops(self) -> int: ...

# --------------------------------------------------------------------------
# the simulation
# --------------------------------------------------------------------------

class Sim:
    def __init__(self) -> None: ...

    # world construction
    def add_polygon(self, verts: Sequence[Pair]) -> int: ...
    def connect(self, a: int, ea: int, b: int, eb: int) -> None: ...
    def connect_with_xform(self, a: int, ea: int, b: int, eb: int,
                           m9: M9) -> None: ...
    def disconnect(self, a: int, ea: int) -> None: ...
    def split_edge(self, polygon: int, edge: int, t0: float,
                   t1: float) -> int: ...
    def num_polygons(self) -> int: ...
    def polygon_verts(self, r: int) -> list[Pair]: ...
    def polygon_portals(self, r: int) -> list[tuple[int, int] | None]: ...
    def portal_xform(self, r: int, e: int) -> M9 | None: ...
    def edge_endpoints(self, r: int,
                       e: int) -> tuple[float, float, float, float]: ...
    def polygon_radius(self, r: int) -> float: ...

    # coordinate spaces
    def polygon_space(self, r: int) -> Space: ...
    def polygon_of(self, space: Space) -> int | None: ...
    def place(self, r: int, x: float, y: float) -> Coordinate:
        """The place in polygon `r` at local (x, y) — the door for authored
        data, which states the space in the same call as the numbers."""
    def portal_transform(self, r: int, e: int) -> Transform | None:
        """The doorway's map, from the NEIGHBOUR's space into `r`'s."""
    def develop(self, c: Coordinate, into: Space) -> Coordinate | None:
        """Carry a place into another space along the physically shortest
        route. THE ONE OPERATION THAT CONSULTS LIVE TOPOLOGY, which is why
        it belongs to the world and can fail.

        `into` may be passed by keyword. Developing into the space a place
        is already in is a no-op that returns it unchanged — deliberately,
        so callers never need an `if same_space` guard, which is the exact
        shape of the guards this system exists to delete.

        None means NO ROUTE EXISTS, over the whole graph: unlike the
        perception calls there is no hop ceiling here, so None is
        "unreachable", not "farther than some budget". A place in a space
        this world did not mint (the screen) is also None, because no
        route of doorways reaches it — the camera Transform is the only
        way in and out of there."""
    def edge_midpoint(self, r: int, e: int) -> Coordinate:
        """A doorway's midpoint, as a place IN POLYGON `r`'s OWN SPACE —
        the same space `sim.get` reports for a body standing in `r`, so
        an agent in `r` can subtract the two directly. The steering
        target when something heads for a door."""
    def edge_normal(self, r: int, e: int) -> Offset:
        """An edge's unit INWARD normal, as a direction in polygon `r`'s
        own space."""

    # walk-mask terrain
    def set_polygon_terrain(
        self, r: int,
        rects: Sequence[tuple[float, float, float, float]]) -> None: ...
    def polygon_terrain(
        self, r: int) -> list[tuple[float, float, float, float]]: ...
    def set_terrain_block(self, group: int, blocked: bool) -> None: ...
    def terrain_light_segments(
        self, r: int) -> list[tuple[float, float, float, float]]: ...
    def terrain_avoid_dir(self, from_: Coordinate, radius: float,
                          desired: Offset,
                          lookahead: float = ...) -> Offset: ...

    # entities
    def spawn(self, at: Coordinate, radius: float, mass: float,
              group: int) -> int:
        """Put a body AT a place. The polygon comes from the coordinate's
        space, so a position from one chamber cannot be paired with the
        index of another.

        WHAT `group` STILL MEANS. It is no longer a collision rule — the
        16x16 collision matrix is gone, everything physical collides with
        everything physical, and the one surviving fact (a pickup is not a
        physics object) lives on the body as `set_props(physical=False)`.
        `group` is now only a QUERY TAG: `raycast`'s `mask` is a bitmask
        over it (`1 << group`), and `track_of`/`sentry_acquire` take the
        target's group so their confirming ray can look for it. The game
        keeps five (player, enemy, player-round, enemy-round, pickup)."""
    def remove(self, id: int) -> None: ...
    def exists(self, id: int) -> bool: ...
    def get(self, id: int) -> EntityState:
        """One body's state at this instant. `pos` is in the body's OWN
        space (that is, `polygon_space(get_polygon(id))`), which is the
        whole Python-side gate: an entity reading its own position is
        unaffected, and reading ANOTHER entity's becomes visible instead
        of silent. Raises ValueError for an id that does not exist —
        check `exists(id)` first if that is possible."""
    def get_radius(self, id: int) -> float:
        """A body's radius — a length, so no space (see Offset.length).
        A Track reports a PLACE and not a size, so anything that needs a
        body's extent (a marquee selection, an overlap test) asks here."""
    def get_polygon(self, id: int) -> int: ...
    def polygon_entities(self, polygon: int) -> list[int]: ...
    def set_vel(self, id: int, vel: Offset) -> None: ...
    def set_dir(self, id: int, dir: Offset) -> None: ...
    def set_pos(self, id: int, at: Coordinate) -> None: ...
    def apply_impulse(self, id: int, j: Offset) -> None: ...
    def set_props(self, id: int, rest_wall: float | None = ...,
                  rest_ent: float | None = ...,
                  max_substep: float | None = ...,
                  transfers: bool | None = ...,
                  radius: float | None = ...,
                  mass: float | None = ...,
                  group: int | None = ...,
                  physical: bool | None = ...) -> None: ...
    def soften_polygon(self, polygon: int) -> None: ...
    def soft_wall_impulse(self, polygon: int, edge: int, t: float,
                          magnitude: float) -> None: ...

    # activation
    def set_active_within(self, polygon: int, hops: int) -> None: ...
    def activate_also(self, polygon: int, hops: int) -> None: ...
    def set_all_active(self) -> None: ...
    def active_polygons(self) -> list[int]: ...

    # simulation and queries
    def step(self, dt: float) -> list[tuple]: ...
    def visible_set(self, camera_polygon: int, cam_m9: M9, apex_x: float,
                    apex_y: float, screen_w: float, screen_h: float,
                    max_depth: int, max_instances: int) -> list[tuple]: ...
    def raycast(self, from_: Coordinate, dir: Offset, max_hops: int,
                max_len: float, mask: int,
                ignore: int = ...) -> RayResult: ...
    def track_of(self, observer: int, target: int, group: int,
                 max_hops: int, tick: int = ...) -> Track | None:
        """TARGETED sight: where `target` is, from `observer`, or None.

        Developed into the observer's own space along the physically
        shortest route and raycast-confirmed, so there are no wallhacks at
        any depth. `group` is the TARGET's query tag (see `spawn`), used to
        aim the confirming ray. `tick` is stamped onto the Track and is
        NOT read from anywhere — the engine has no clock of its own, so
        the caller passes the tick it is on (the game passes
        `session.tick_count`). Leaving it at 0 makes every Track claim
        tick 0, which is worse than useless if anything downstream checks
        freshness."""
    def tracks_to(self, observer: int, target: int, max_hops: int,
                  max_images: int, tick: int = ...) -> list[Track]:
        """EVERY distinct image of one body, shortest first.

        A portal graph with a loop admits unboundedly many routes, so this
        takes a budget and the caller raises it to see further; an empty or
        short list means "nothing more inside THIS budget", never
        "unreachable" (for that, `develop`). Distinct means distinct
        developed place. Not raycast-confirmed, unlike `track_of`: an
        alternate image is a fact about the geometry, and a caller
        enumerating them is asking about the world rather than about what
        it can shoot."""
    def sentry_acquire(self, observer: int, candidates: Sequence[int],
                       group: int, max_hops: int, max_range: float,
                       tick: int = ...) -> Track | None: ...
    def next_edge(self, from_polygon: int, to_polygon: int) -> int: ...
    def hop_distance(self, a: int, b: int) -> int: ...
    def polygons_within(self, polygon: int, hops: int) -> list[int]: ...

# --------------------------------------------------------------------------
# the rest of the engine surface
# --------------------------------------------------------------------------

class Raster:
    def __init__(self, w: int, h: int) -> None: ...
    @property
    def width(self) -> int: ...
    @property
    def height(self) -> int: ...
    def begin(self, bg_rgba: int = ...) -> None: ...
    def set_darkness(self, on: bool) -> None: ...
    def set_lightmap(self, data: object) -> None: ...
    def add_light(self, cx: float, cy: float, radius: float, tint_r: int,
                  tint_g: int, tint_b: int, polys: Sequence[float],
                  poly_lens: Sequence[int], shadows: Sequence[float],
                  shadow_lens: Sequence[int]) -> None: ...
    def lightmap_add_region(self, x0: int, y0: int, rw: int, rh: int,
                            data: object) -> None: ...
    def lightmap_bytes(self) -> bytes: ...
    def apply_post(
        self, frame: bytearray,
        passes: Sequence[tuple[int, int, int, int, bool]]) -> None: ...
    def set_decal_shape(self, id: int, pts: Sequence[float]) -> None: ...
    def set_decals(self, list_id: int,
                   records: Sequence[float]) -> None: ...
    def mark_otherworld(self, clip_idx: int, mix: float = ...) -> None: ...
    def add_clip(self, pts: object, coverage: bool = ...) -> int: ...
    def add_xform(self, m9: M9) -> int: ...
    def set_texture(self, id: int, w: int, h: int, data: object) -> None: ...
    def draw(self, cmds: object, coords: object) -> None: ...
    def draw_blob(self, cmds: object, coords: object, xform_idx: int,
                  clip_idx: int) -> None: ...
    def finish(self) -> bytes: ...
    def finish_into(self, out: object) -> None: ...

class SignalField:
    def __init__(self, tick: int = ...) -> None: ...
    def set_adjacency(self, adj: Sequence[Sequence[int]]) -> None: ...
    def emit(self, kind: int, polygon: int, amount: float,
             tick: int) -> None: ...
    def emit_many(self, kind: int, polygons: Sequence[int], amount: float,
                  tick: int) -> None: ...
    def emit_at_least(self, kind: int, polygon: int, level: float,
                      tick: int) -> None: ...
    def sample(self, kind: int, polygon: int, tick: int) -> float: ...
    def sample_all(self, polygon: int, tick: int) -> list[float]: ...
    def totals(self, tick: int) -> list[float]: ...
    def step_to(self, tick: int) -> None: ...
    def deposit_doorway_trail(self, polygon: int, edge: int, amount: float,
                              tick: int) -> None: ...
    def doorway_trail(self, polygon: int, edge: int, tick: int) -> float: ...
    def drain(self, polygon_weights: Sequence[tuple[int, float]],
              capacity: float, tick: int) -> float: ...

class AudioMixer:
    def __init__(self, *a: object, **k: object) -> None: ...
    def __getattr__(self, name: str) -> object: ...

class Window:
    def __init__(self, *a: object, **k: object) -> None: ...
    def __getattr__(self, name: str) -> object: ...

class VideoRecorder:
    def __init__(self, path: str, width: int, height: int,
                 fps: int) -> None: ...
    def add_frame(self, frame: object) -> None: ...
    def finish(self) -> None: ...
    @property
    def frames(self) -> int: ...

def write_png(path: str, width: int, height: int, data: object) -> None: ...
def mat_mul(a: M9, b: M9) -> M9: ...
def mat_inv(m: M9) -> M9: ...
def mat_apply(m: M9, x: float, y: float) -> Pair: ...
def mat_apply_dir(m: M9, x: float, y: float) -> Pair: ...
def mat_translate(x: float, y: float) -> M9: ...
def mat_rotate(theta: float) -> M9: ...
def mat_scale(sx: float, sy: float) -> M9: ...
def mat_rotation_angle(m: M9) -> float: ...
def mat_identity() -> M9: ...
def clip_polygon(subject: Sequence[Pair],
                 clip: Sequence[Pair]) -> list[Pair]: ...
def clip_polyline(pts: Sequence[Pair],
                  clip: Sequence[Pair]) -> list[list[Pair]]: ...
