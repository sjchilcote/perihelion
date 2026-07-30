"""The shared find/senses API (U3, DESIGN_7_25).

Agents are allowed to SEE — chemotaxis was never meant to be their only
sense. Every perception question ("what can I see from here?", "is there
an active portal here?") goes through this one infrastructure, so no
system reaches into another's internals to look around.

Three kinds of query, deliberately different in reach:

- `frame(observer)` — AMBIENT awareness: line-of-sight-confirmed entities
  in the observer's own chamber and chambers ONE portal away. This is the
  agent-facing observation the one-hop law governs (`portal_depth > 1`
  raises); it is what coordination decisions consume.
- `sight_of(observer, target)` — TARGETED vision down a real sightline:
  positions compose through portal transforms as deep as the geometry
  lets them (director 2026-07-19: "one hop was never the law" — an enemy
  that goes inert when the player steps over a threshold is not a
  fight). Still raycast-confirmed: there are no wallhacks at any depth.
- `find(observer, tag)` — a search by what a thing IS rather than by its
  id. You say `Sighting.ENEMY` or `Sighting.ADVERSARY` and get back the
  Tracks, sorted by how far away they really are.

WHAT COMES BACK IS A TRACK, NOT A POSITION. A Track is a *report of a
sighting*: the subject's id, its place as a `necore.Coordinate` developed
into the space the observer asked for, the tick it was taken on, and the
relational facts perception had already computed anyway (path distance,
straight-line distance, portal depth). It is not a proxy for the entity —
the developed place cannot come from the entity, because the entity does
not know who is asking or by what route, and the relational facts are
properties of the observer-subject pair with no home on the subject.

WHY THE COORDINATE. A pair of numbers is only meaningful in one
coordinate space. Gate 66 failed the Adversary's shove at p=0.04 because
aim, range and knockback all subtracted the shooter's frame from the
player's — meaningless the moment a shot crosses a chamber, which 63 of
64 filmed fires did. A `Coordinate` refuses that subtraction instead of
answering it. See docs/FRAME_SYSTEM_DESIGN_20260729.md.

ROUTE POLICY. One route is chosen on the caller's behalf: the shortest
PHYSICAL path through the assembled world, measured as total distance and
not as hop count. A caller that wants something else asks `every_route`
and owns the consequences — that generator has no end, because a portal
graph with a loop admits unboundedly many routes.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterator, Callable, Protocol

import necore

# Sight is bounded by GEOMETRY — the raycast — never by graph hops. A
# battlespace can cover tens of polygons (director 2026-07-28), and a
# straight sightline through a colonnade of small chambers must work at
# whatever depth the geometry allows. This constant is only a cost
# ceiling on the compose-transforms walk, set far above any real
# sightline; it must never be the thing that ends an engagement.
VISION_HOPS = 12


class Sighting:
    """The globally-agreed entity tags `find` searches by.

    A tag is what a thing IS to a perceiving agent, and nothing finer: an
    Adversary scout looking for cover cares that a body is Testator, not
    that it is a husk. Finer questions are answered by reading the
    session's own records once you have the id.
    """

    PLAYER = "Player"
    TESTATOR = "Testator"
    ADVERSARY = "Adversary"
    ENEMY = "Enemy"                 # Testator or Adversary
    BUILDING = "Building"
    PLAYER_BUILDING = "PlayerBuilding"
    ENEMY_BUILDING = "EnemyBuilding"

    ALL = (PLAYER, TESTATOR, ADVERSARY, ENEMY, BUILDING,
           PLAYER_BUILDING, ENEMY_BUILDING)


@dataclass(frozen=True, slots=True)
class PortalSense:
    polygon: int
    edge: int
    target_polygon: int       # -1 while the doorway is still a wall
    active: bool
    midpoint: necore.Coordinate     # in the observer's own space
    portal_depth: int


@dataclass(frozen=True, slots=True)
class SenseFrame:
    observer_id: int
    polygon: int
    hits: tuple[necore.Track, ...]
    portals: tuple[PortalSense, ...]


class SenseWorld(Protocol):
    """What the engine must answer. `necore.Sim` satisfies this as-is."""

    def get(self, eid: int): ...
    def get_polygon(self, eid: int) -> int: ...
    def polygon_space(self, polygon: int): ...
    def polygon_entities(self, polygon: int): ...
    def polygon_portals(self, polygon: int): ...
    def polygons_within(self, polygon: int, hops: int): ...
    def edge_midpoint(self, polygon: int, edge: int): ...
    def track_of(self, observer: int, target: int, group: int,
                 max_hops: int, tick: int): ...
    def tracks_to(self, observer: int, target: int, max_hops: int,
                  max_images: int, tick: int): ...


# describe(entity_id) -> (kind, faction, role, state_tags, group) or None
# for entities that are not sensable beings (bullets, pickups, decals).
Describe = Callable[[int], tuple[str, str, str, frozenset, int] | None]


def tags_for(faction: str, role: str) -> frozenset[str]:
    """The tags a body answers to, from what the session says it is.

    One place, so `find` and every caller agree about what "Enemy" means.
    A building is tagged by whose it is AND as a building, because both
    questions get asked: "is there cover near me" and "is that mine".
    """
    out: set[str] = set()
    if faction == "commando":
        out.add(Sighting.PLAYER)
    elif faction == "testator":
        out.update((Sighting.TESTATOR, Sighting.ENEMY))
    elif faction == "adversary":
        out.update((Sighting.ADVERSARY, Sighting.ENEMY))
    if role == "building":
        out.add(Sighting.BUILDING)
        out.add(Sighting.PLAYER_BUILDING if faction == "commando"
                else Sighting.ENEMY_BUILDING)
    return frozenset(out)


class SenseQuery:
    __slots__ = ("_w", "_describe", "_tick")

    def __init__(self, world: SenseWorld, describe: Describe,
                 tick: Callable[[], int] = lambda: 0):
        self._w = world
        self._describe = describe
        self._tick = tick

    # -- targeted sight ---------------------------------------------------

    def sight_of(self, observer_id: int, target_id: int) -> necore.Track | None:
        """The target as a Track whose `pos` is a Coordinate in the
        OBSERVER's own space, if a real sightline exists (portal
        transforms composed along the shortest physical route,
        raycast-confirmed). Same-chamber sight is unconditional — the
        chambers are convex, nothing inside one can hide a body.

        The geometric walk lives in the engine (`Sim.track_of`) — one
        call instead of a per-hop Python loop; at ~270 sight queries per
        tick the Python walk was the sim's single largest cost."""
        desc = self._describe(target_id)
        if desc is None:
            return None
        group = desc[4]
        return self._w.track_of(observer_id, target_id, group, VISION_HOPS,
                                self._tick())

    def every_route(self, observer_id: int, target_id: int, *,
                    batch: int = 4) -> Iterator[necore.Track]:
        """Every distinct image of one body, shortest first.

        THIS GENERATOR MAY NEVER TERMINATE. A portal graph with a loop
        admits unboundedly many routes to the same body, and each is a
        real place the body appears to be. The engine answers in batches
        and this doubles the budget as the caller keeps asking, so the
        cost tracks how much the caller actually wanted.

        Not raycast-confirmed, unlike `sight_of`: an alternate image is a
        fact about the geometry, and a caller enumerating them is asking
        about the world rather than about what it can shoot."""
        want = max(1, batch)
        served = 0
        while True:
            got = self._w.tracks_to(observer_id, target_id, VISION_HOPS,
                                    want, self._tick())
            if len(got) <= served:
                return          # the budget bought nothing new: really out
            for t in got[served:]:
                yield t
            served = len(got)
            want *= 2

    # -- search by what a thing IS ----------------------------------------

    def find(self, observer_id: int, tag: str, *,
             within_hops: int = 2,
             limit: int = 0) -> list[necore.Track]:
        """Every body tagged `tag` that the observer can actually see,
        nearest first by real path distance.

        `within_hops` bounds only which chambers are SCANNED — the cost
        ceiling on the candidate sweep, not a law about sight. A body
        found there is reported at whatever depth the geometry gives it.
        `limit` caps the number returned (0 = all)."""
        if tag not in Sighting.ALL:
            raise ValueError(f"unknown sighting tag {tag!r}")
        w = self._w
        r0 = w.get_polygon(observer_id)
        out: list[necore.Track] = []
        for r_ in w.polygons_within(r0, within_hops):
            for eid in w.polygon_entities(r_):
                if eid == observer_id:
                    continue
                desc = self._describe(eid)
                if desc is None:
                    continue
                _kind, faction, role, _tags, _group = desc
                if tag not in tags_for(faction, role):
                    continue
                t = self.sight_of(observer_id, eid)
                if t is not None:
                    out.append(t)
        out.sort(key=lambda t: t.path_distance)
        return out[:limit] if limit else out

    def nearest(self, observer_id: int, tag: str, *,
                within_hops: int = 2) -> necore.Track | None:
        got = self.find(observer_id, tag, within_hops=within_hops, limit=1)
        return got[0] if got else None

    # -- ambient one-hop frame --------------------------------------------

    def frame(self, observer_id: int, *, portal_depth: int = 1) -> SenseFrame:
        """Line-of-sight-confirmed beings in the observer's chamber and
        chambers one portal away. The one-hop law is enforced here, not
        documented: asking deeper raises."""
        if portal_depth > 1:
            raise ValueError(
                f"agents sample only one portal away (asked {portal_depth})")
        w = self._w
        r0 = w.get_polygon(observer_id)
        chambers = [r0]
        if portal_depth >= 1:
            for portal in w.polygon_portals(r0):
                if portal is not None:
                    chambers.append(portal[0])
        hits: list[necore.Track] = []
        for r_ in chambers:
            for eid in w.polygon_entities(r_):
                if eid == observer_id:
                    continue
                h = self.sight_of(observer_id, eid)
                if h is not None and h.portal_depth <= portal_depth:
                    hits.append(h)
        return SenseFrame(observer_id=observer_id, polygon=r0,
                          hits=tuple(hits),
                          portals=self.active_portals(observer_id))

    def kind_of(self, eid: int) -> str | None:
        """What a sighted body is, for a caller holding a Track. The
        Track deliberately carries no kind: it is a report about a
        sighting, and what the body IS is the session's record, not the
        geometry's."""
        desc = self._describe(eid)
        return desc[0] if desc is not None else None

    def describe(self, eid: int):
        """(kind, faction, role, state_tags, group), or None."""
        return self._describe(eid)

    # -- portals ------------------------------------------------------------

    def active_portals(self, observer_id: int) -> tuple[PortalSense, ...]:
        """Every edge of the observer's own chamber, with whether it is a
        LIVE portal right now — a sealed door or a sealed breach is a
        wall, and reads as one."""
        w = self._w
        r0 = w.get_polygon(observer_id)
        out: list[PortalSense] = []
        for edge, portal in enumerate(w.polygon_portals(r0)):
            out.append(PortalSense(
                polygon=r0, edge=edge,
                target_polygon=portal[0] if portal is not None else -1,
                active=portal is not None,
                midpoint=w.edge_midpoint(r0, edge), portal_depth=0))
        return tuple(out)
