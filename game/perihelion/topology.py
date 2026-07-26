"""Runtime topology ownership (U8, DESIGN_7_25).

Every runtime cut and glue goes through here, because the engine
DERIVES portal scale from the two glued edge lengths (s = la/lb —
measured: 96 against 52 gives x1.846, and the discarded build's
52-against-15 corridor mouth was a x3.47 lens that resized bodies until
reinforcements could not fit through their own gate). The guard is a
CONSTRUCTION RULE, enforced twice:

  1. both edge lengths must match to 1e-9 BEFORE connecting;
  2. the derived transform's scale must be 1 within 1e-9 AFTER —
     so even a mutant that skips the length check cannot leave a live
     scaling portal behind (it is disconnected and the build dies).

Edge indices shift when a wall is split (`split_edge` renumbers every
later edge in the polygon); EdgeHandles stay valid across that — the
manager re-resolves them, which is what the ad-hoc `_shift_edge_maps`
bookkeeping never guaranteed for anyone but its own callers.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

LENGTH_TOL = 1e-9
SCALE_TOL = 1e-9


class TopologyError(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class EdgeHandle:
    token: int


@dataclass(frozen=True, slots=True)
class PortalLink:
    a: EdgeHandle
    b: EdgeHandle


class TopologyManager:
    __slots__ = ("_w", "_edges", "_next", "_on_change")

    def __init__(self, world, on_change=None):
        self._w = world
        self._edges: dict[int, tuple[int, int]] = {}  # token -> (polygon, edge)
        self._next = 1
        self._on_change = on_change or (lambda: None)

    # -- handles -----------------------------------------------------------

    def _handle(self, polygon: int, edge: int) -> EdgeHandle:
        tok = self._next
        self._next += 1
        self._edges[tok] = (polygon, edge)
        return EdgeHandle(tok)

    def current_edge(self, h: EdgeHandle) -> tuple[int, int]:
        try:
            return self._edges[h.token]
        except KeyError:
            raise TopologyError(f"stale edge handle {h.token}") from None

    def adopt(self, polygon: int, edge: int) -> EdgeHandle:
        """Take ownership of an already-existing edge (an authored seam)."""
        return self._handle(polygon, edge)

    def _shift_after_split(self, polygon: int, mid: int) -> None:
        """A split at edge (mid-1) produced [left, mid=door, right]: every
        tracked edge of that polygon whose old index is >= mid moved up
        by 2 (the engine renumbers strictly-greater-than-the-split-edge,
        and old index k >= mid  <=>  k > split edge)."""
        for tok, (r, e) in list(self._edges.items()):
            if r == polygon and e >= mid:
                self._edges[tok] = (r, e + 2)

    # -- mutations ----------------------------------------------------------

    def carve(self, polygon: int, near, width: float) -> EdgeHandle | None:
        """Cut a door-width sub-edge into the wall nearest `near`
        (polygon-local). Returns a stable handle, or None when no wall
        has the span — the caller decides whether that is fatal."""
        edge = self._w.carve_door(polygon, near, width)
        if edge is None:
            return None
        self._shift_after_split(polygon, edge)
        h = self._handle(polygon, edge)
        self._on_change()
        return h

    def edge_length(self, h: EdgeHandle) -> float:
        polygon, edge = self.current_edge(h)
        x1, y1, x2, y2 = self._w.sim.edge_endpoints(polygon, edge)
        return math.hypot(x2 - x1, y2 - y1)

    def connect_equal(self, a: EdgeHandle, b: EdgeHandle) -> PortalLink:
        """The ONLY sanctioned runtime glue. Refuses mismatched lengths;
        verifies the engine's derived scale afterward and tears the
        portal back out if it is not exactly 1 — a scaling portal cannot
        survive construction, period."""
        ra, ea = self.current_edge(a)
        rb, eb = self.current_edge(b)
        la = self.edge_length(a)
        lb = self.edge_length(b)
        if abs(la - lb) > LENGTH_TOL:
            raise TopologyError(
                f"glued edges differ: {la:.9f} vs {lb:.9f} — the engine "
                f"would derive a x{max(la, lb) / min(la, lb):.3f} lens")
        self._w.sim.connect(ra, ea, rb, eb)
        m9 = self._w.sim.portal_xform(ra, ea)
        scale = math.hypot(m9[0], m9[3])
        if abs(scale - 1.0) > SCALE_TOL:
            self._w.sim.disconnect(ra, ea)
            raise TopologyError(
                f"derived portal scale {scale:.9f} != 1 — refused")
        self._on_change()
        return PortalLink(a=a, b=b)

    def disconnect(self, link: PortalLink) -> None:
        ra, ea = self.current_edge(link.a)
        self._w.sim.disconnect(ra, ea)
        self._on_change()
