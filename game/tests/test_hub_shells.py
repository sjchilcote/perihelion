"""The marrow's authored shells and its corruption gradient.

The director, 2026-07-28: "polygons are just that - individual polygons.
This engine is not constrained to square rooms by any means... It should
transition to the otherworld room type as you get deeper in."

The reshape is only allowed to change SHAPE. These pin the preservation
contract (Sol consult docs/consults/marrow_visual_20260728 section 1.4):
the portal graph, the depths, the anchors of every landed system, and
the scale-1 glue all survive it — and the gradient actually reaches
every chamber, which is the defect that made the cathedral render as
generic rooms in the first place.
"""
from __future__ import annotations

import math
from pathlib import Path

from perihelion import hub
from perihelion.levels import load_level
from perihelion.sim import GameSession, InputFrame
from perihelion.testkit.loadouts import FULL_LOADOUT


def _session():
    level_path = Path(__file__).resolve().parents[2] / "levels" / "gauntlet4.json"
    level = load_level(level_path)
    return GameSession(level, seed=2, player_state=dict(FULL_LOADOUT),
                       screen=(640, 360), zoom=0.45)


# --- the shells themselves ------------------------------------------------

def test_every_chamber_is_a_one_off_convex_shell():
    seen = set()
    for name, (verts, _doors, _breach) in hub.CHAMBER_SHELLS.items():
        assert 5 <= len(verts) <= 10, f"{name}: {len(verts)} facets"
        sign = None
        for i in range(len(verts)):
            ax, ay = verts[i]
            bx, by = verts[(i + 1) % len(verts)]
            cx, cy = verts[(i + 2) % len(verts)]
            cross = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
            assert abs(cross) > 1e-9, f"{name}: colinear vertices"
            s = cross > 0
            if sign is None:
                sign = s
            assert s == sign, f"{name}: not convex"
        key = tuple(sorted((round(x, 1), round(y, 1)) for x, y in verts))
        assert key not in seen, f"{name}: a repeated template, not a one-off"
        seen.add(key)


def test_no_chamber_is_a_rectangle():
    """The whole point of the pass. A rectangle has four facets and four
    right angles; nothing here may."""
    for name, (verts, _d, _b) in hub.CHAMBER_SHELLS.items():
        right = 0
        n = len(verts)
        for i in range(n):
            ax, ay = verts[(i - 1) % n]
            bx, by = verts[i]
            cx, cy = verts[(i + 1) % n]
            v1 = (ax - bx, ay - by)
            v2 = (cx - bx, cy - by)
            l1 = math.hypot(*v1) or 1e-9
            l2 = math.hypot(*v2) or 1e-9
            ang = math.degrees(math.acos(max(-1.0, min(
                1.0, (v1[0] * v2[0] + v1[1] * v2[1]) / (l1 * l2)))))
            if abs(ang - 90.0) < 4.0:
                right += 1
        assert right < 3, f"{name}: {right} right angles — still reads as a box"


def test_every_doorway_has_a_palate_long_enough_to_seat_it():
    """A door carved into a facet that barely holds it leaves no wall to
    either side; Sol's rule is 12u of intact wall per side (16u for the
    breach seam)."""
    for name, (verts, doors, breach) in hub.CHAMBER_SHELLS.items():
        n = len(verts)
        lens = [math.hypot(verts[(i + 1) % n][0] - verts[i][0],
                           verts[(i + 1) % n][1] - verts[i][1])
                for i in range(n)]
        assert min(lens) >= 22.0, f"{name}: a {min(lens):.0f}u facet"
        links = sum(1 for a, b in hub._LINKS if name in (a, b))
        assert len(doors) == links, (
            f"{name}: {len(doors)} authored door seats for {links} links")
        assert (breach is not None) == (name in ("A1", "A2", "A3")), (
            f"{name}: breach seat presence is wrong")


# --- the preservation contract, measured on the BUILT world ---------------

def test_the_portal_graph_survives_the_reshape():
    s = _session()
    expect = hub._expected_degrees()
    for name, polygon in s.hub.chambers.items():
        live = sum(1 for p in s.sim.polygon_portals(polygon) if p is not None)
        assert live == expect[name], (
            f"{name}: {live} portals, ratified graph says {expect[name]}")


def test_the_sources_stay_ten_or_eleven_crossings_deep():
    s = _session()
    c = s.hub.chambers
    for src in ("S1", "S2", "S3"):
        d = min(s.sim.hop_distance(c[a], c[src]) for a in ("A1", "A2", "A3"))
        assert d in (10, 11), f"{src} sits {d} crossings from the nearest apse"


def test_no_new_one_door_chambers():
    """One-door chambers are where hunts grind (run 49/51). The reshape
    may not create more of them than the ratified graph already has."""
    expect = hub._expected_degrees()
    ratified = sum(1 for v in expect.values() if v == 1)
    s = _session()
    live = sum(1 for polygon in s.hub.chambers.values()
               if sum(1 for p in s.sim.polygon_portals(polygon)
                      if p is not None) == 1)
    assert live == ratified, f"{live} one-door chambers, ratified {ratified}"


def test_every_landed_system_still_stands_inside_its_chamber():
    """Organ bodies, residents, the shelf and the lights were all placed
    against the old rectangles. After the reshape each must still be
    inside the polygon the sim put it in — the engine would otherwise
    quietly resolve it out through a wall."""
    s = _session()
    hub_polygons = set(s.hub.chambers.values())
    checked = 0
    for eid, e in s.enemies.items():
        polygon = s.sim.get_polygon(eid)
        if polygon not in hub_polygons:
            continue
        ex, ey = s.sim.get(eid).pos.local()
        assert _inside(s, polygon, ex, ey), (
            f"{e['kind']} {eid} is outside chamber {polygon}")
        checked += 1
    assert checked > 30, f"only {checked} hub bodies checked"


def _inside(s, polygon, px, py) -> bool:
    n = len(s.sim.polygon_portals(polygon))
    sign = None
    for e in range(n):
        x1, y1, x2, y2 = s.sim.edge_endpoints(polygon, e)
        cross = (x2 - x1) * (py - y1) - (y2 - y1) * (px - x1)
        sg = cross > 0
        if sign is None:
            sign = sg
        elif sg != sign:
            return False
    return True


def test_the_breach_seams_are_exactly_breach_width():
    s = _session()
    for h in s.hub.breach_edges:
        polygon, edge = s.topology.current_edge(h)
        x1, y1, x2, y2 = s.sim.edge_endpoints(polygon, edge)
        ln = math.hypot(x2 - x1, y2 - y1)
        assert abs(ln - hub.BREACH_W) < 1e-6, f"seam is {ln}, not {hub.BREACH_W}"


# --- the corruption gradient ---------------------------------------------

def test_the_gradient_reaches_every_chamber():
    """Before the pass the hub's polygons carried no kind or descent at
    all: the cathedral rendered as generic rooms at whatever descent the
    world's last polygon happened to have. The metadata lives on the
    SESSION because the hub belongs to no level and outlives a swap."""
    s = _session()
    for name, polygon in s.hub.chambers.items():
        assert polygon in s.hub_polygon_meta, f"{name} has no metadata"
        kind, descent = s.hub_polygon_meta[polygon]
        assert kind in ("marrow", "otherworld")
        assert 0.05 < descent <= 1.0


def test_corruption_rises_monotonically_with_depth():
    s = _session()
    depths = hub.chamber_depths()
    for name, polygon in s.hub.chambers.items():
        for other, opolygon in s.hub.chambers.items():
            if depths[name] < depths[other]:
                assert (s.hub_polygon_meta[polygon][1]
                        < s.hub_polygon_meta[opolygon][1]), (
                    f"{name} (depth {depths[name]}) is not less corrupt than "
                    f"{other} (depth {depths[other]})")


def test_the_kind_switches_at_depth_six_and_not_before():
    s = _session()
    depths = hub.chamber_depths()
    for name, polygon in s.hub.chambers.items():
        want = "otherworld" if depths[name] >= hub.OTHERWORLD_DEPTH else "marrow"
        got = s.hub_polygon_meta[polygon][0]
        assert got == want, f"{name} at depth {depths[name]} is {got}"


def test_the_lighting_model_arrives_on_a_crossfade():
    """A hard swap at the kind boundary reads as a theme trigger. The
    first otherworld chamber must compose mostly ordinary light and the
    source cells almost pure inverse."""
    from perihelion.render import _ow_mix
    assert _ow_mix(0.10) == 0.0, "the apses are not otherworld-lit at all"
    first = _ow_mix(0.72)     # N3/AN2, the first otherworld chambers
    deep = _ow_mix(1.00)      # the source cells
    assert 0.2 < first < 0.85, f"the boundary chamber composes at {first:.2f}"
    assert deep > 0.98, f"the deepest cells compose at {deep:.2f}"
    assert first < deep


def test_the_marrow_has_its_own_prop_vocabulary():
    from perihelion.render import _POLYGON_PROP_GENERATORS
    assert "marrow" in _POLYGON_PROP_GENERATORS


def test_the_otherworld_generator_reads_its_descent():
    """It took a descent parameter and ignored it, so nothing progressed
    with depth (Sol consult section 2.3)."""
    import random

    from perihelion.render import _props_otherworld
    verts = [(0.0, 0.0), (0.0, 200.0), (240.0, 200.0), (240.0, 0.0)]
    walls = [dict(p0=(0.0, 0.0), p1=(240.0, 0.0), len=240.0, tx=1.0, ty=0.0)]

    def run(d):
        return _props_otherworld(random.Random(7), verts, walls,
                                 0.0, 0.0, 240.0, 200.0, descent=d,
                                 crng=random.Random(9))
    shallow = run(0.72)
    deep = run(1.0)
    assert shallow != deep, "descent changed nothing in the otherworld props"
    dots = lambda ps: sum(1 for p in ps if p[0] == "dot")   # noqa: E731
    assert dots(deep) > dots(shallow), (
        "the floor does not become more sky-like with depth")


def test_no_prop_generator_emits_a_closed_ring():
    """One symbol, one meaning: a free-standing closed circle is the
    aggro tell and nothing else may present as one. The otherworld
    generator used to lay out a perfect ring of evenly spaced seats."""
    import random

    from perihelion.render import _props_marrow, _props_otherworld
    verts = [(0.0, 0.0), (0.0, 200.0), (240.0, 200.0), (240.0, 0.0)]
    walls = [dict(p0=(0.0, 0.0), p1=(240.0, 0.0), len=240.0, tx=1.0, ty=0.0)]
    for gen in (_props_marrow, _props_otherworld):
        for seed in range(24):
            prims = gen(random.Random(seed), verts, walls, 0.0, 0.0,
                        240.0, 200.0, descent=0.8,
                        crng=random.Random(seed + 100))
            centers = {}
            for p in prims:
                if p[0] != "poly":
                    continue
                pts = p[1]
                cx = sum(x for x, _ in pts) / len(pts)
                cy = sum(y for _, y in pts) / len(pts)
                centers.setdefault(round(math.hypot(cx - 120.0, cy - 100.0)),
                                   []).append((cx, cy))
            for radius, group in centers.items():
                assert len(group) < 5 or radius == 0, (
                    f"{gen.__name__} seed {seed}: {len(group)} props at a "
                    f"constant radius {radius} — that reads as a ring")
