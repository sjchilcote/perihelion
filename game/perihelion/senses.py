"""The shared find/senses API (U3, DESIGN_7_25).

Agents are allowed to SEE — chemotaxis was never meant to be their only
sense. Every perception question ("what can I see from here?", "is there
an active portal here?") goes through this one infrastructure, so no
system reaches into another's internals to look around.

Two kinds of query, deliberately different in reach:

- `frame(observer)` — AMBIENT awareness: line-of-sight-confirmed entities
  in the observer's own chamber and chambers ONE portal away. This is the
  agent-facing observation the one-hop law governs (`portal_depth > 1`
  raises); it is what coordination decisions consume.
- `sight_of(observer, target)` — TARGETED vision down a real sightline:
  positions compose through portal transforms as deep as the geometry
  lets them (director 2026-07-19: "one hop was never the law" — an enemy
  that goes inert when the player steps over a threshold is not a
  fight). Still raycast-confirmed: there are no wallhacks at any depth.

Observations are immutable value objects carrying no object references —
no reserve, no hub identity, no HP, no private dictionaries. The world
behind the query is a `SenseWorld` (the engine sim satisfies it); who an
entity IS comes from a `describe` callback supplied by the session, so
this module never imports the game.
"""
from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, Protocol

import necore

# Sight is bounded by GEOMETRY — the raycast — never by graph hops. A
# battlespace can cover tens of polygons (director 2026-07-28), and a
# straight sightline through a colonnade of small chambers must work at
# whatever depth the geometry allows. This constant is only a cost
# ceiling on the compose-transforms walk, set far above any real
# sightline; it must never be the thing that ends an engagement.
VISION_HOPS = 12


@dataclass(frozen=True, slots=True)
class SenseHit:
    entity_id: int
    kind: str                 # "player" | enemy kind
    faction: str              # "commando" | "testator" | "adversary"
    role: str                 # "intruder" | "fighter" | "scout" ...
    polygon: int              # the chamber the entity is physically in
    position: tuple[float, float]   # in the OBSERVER's local frame
    distance: float
    portal_depth: int         # 0 = same chamber
    state_tags: frozenset[str]


@dataclass(frozen=True, slots=True)
class PortalSense:
    polygon: int
    edge: int
    target_polygon: int       # -1 while the doorway is still a wall
    active: bool
    midpoint: tuple[float, float]   # observer-local
    portal_depth: int


@dataclass(frozen=True, slots=True)
class SenseFrame:
    observer_id: int
    polygon: int
    hits: tuple[SenseHit, ...]
    portals: tuple[PortalSense, ...]


class SenseWorld(Protocol):
    """What the engine must answer. `necore.Sim` satisfies this as-is."""

    def get(self, eid: int): ...
    def get_polygon(self, eid: int) -> int: ...
    def polygon_entities(self, polygon: int): ...
    def polygon_portals(self, polygon: int): ...
    def portal_xform(self, polygon: int, edge: int): ...
    def next_edge(self, polygon: int, target: int) -> int: ...
    def hop_distance(self, a: int, b: int) -> int: ...
    def edge_midpoint(self, polygon: int, edge: int): ...
    def raycast(self, polygon: int, x: float, y: float, dx: float, dy: float,
                steps: int, max_dist: float, mask: int, ignore: int): ...


# describe(entity_id) -> (kind, faction, role, state_tags, group) or None
# for entities that are not sensable beings (bullets, pickups, decals).
Describe = Callable[[int], tuple[str, str, str, frozenset, int] | None]


class SenseQuery:
    __slots__ = ("_w", "_describe")

    def __init__(self, world: SenseWorld, describe: Describe):
        self._w = world
        self._describe = describe

    # -- targeted sight ---------------------------------------------------

    def sight_of(self, observer_id: int, target_id: int) -> SenseHit | None:
        """The target's position in the OBSERVER's local frame, if a real
        sightline exists (portal transforms composed along the chain,
        raycast-confirmed). Same-chamber sight is unconditional — the
        chambers are convex, nothing inside one can hide a body.

        The geometric walk lives in the engine (`Sim.sightline`) — one
        call instead of a per-hop Python loop; at ~270 sight queries per
        tick the Python walk was the sim's single largest cost."""
        desc = self._describe(target_id)
        if desc is None:
            return None
        kind, faction, role, tags, group = desc
        res = self._w.sightline(observer_id, target_id, group, VISION_HOPS)
        if res is None:
            return None
        wx, wy, depth, dl = res
        return SenseHit(entity_id=target_id, kind=kind, faction=faction,
                        role=role, polygon=self._w.get_polygon(target_id),
                        position=(wx, wy),
                        distance=dl, portal_depth=depth,
                        state_tags=tags)

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
        hits: list[SenseHit] = []
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

    # -- portals ------------------------------------------------------------

    def active_portals(self, observer_id: int) -> tuple[PortalSense, ...]:
        """Every edge of the observer's own chamber, with whether it is a
        LIVE portal right now — a sealed door or a sealed breach is a
        wall, and reads as one."""
        w = self._w
        r0 = w.get_polygon(observer_id)
        out: list[PortalSense] = []
        for edge, portal in enumerate(w.polygon_portals(r0)):
            mx, my = w.edge_midpoint(r0, edge)
            out.append(PortalSense(
                polygon=r0, edge=edge,
                target_polygon=portal[0] if portal is not None else -1,
                active=portal is not None,
                midpoint=(mx, my), portal_depth=0))
        return tuple(out)
