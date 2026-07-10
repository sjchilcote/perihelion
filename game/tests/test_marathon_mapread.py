"""Unit tests for tools/marathon/mapread.py against a real extracted
fixture: M1's net level "5-D space" (game/tests/fixtures/m1_5dspace.wad,
produced by tools/marathon/make_fixture.py — geometry chunks only)."""

import math
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "marathon"))

from mapread import OBJ_PLAYER, MapFile  # noqa: E402

FIXTURE = ROOT / "game" / "tests" / "fixtures" / "m1_5dspace.wad"


@pytest.fixture(scope="module")
def level():
    mf = MapFile(FIXTURE)
    assert mf.header.version == 0
    assert mf.header.wad_count == 1
    assert mf.directory[0].offset == 128
    return mf.level(0)


def test_known_level_facts(level):
    # ground truth from the shipped Marathon 1 map
    assert level.name == "5-D space"
    assert len(level.polygons) == 50
    assert len(level.lines) == 152
    assert len(level.points) == 92
    assert len(level.player_starts()) == 14
    assert all(o.type == OBJ_PLAYER for o in level.player_starts())


def test_polygons_are_convex_clockwise(level):
    # Marathon polys wind positive-shoelace in y-down coords, convex,
    # 3..8 vertices — the properties the converter relies on
    for pi in range(len(level.polygons)):
        vs = level.poly_verts(pi)
        assert 3 <= len(vs) <= 8
        area2 = sum(vs[i][0] * vs[(i + 1) % len(vs)][1]
                    - vs[(i + 1) % len(vs)][0] * vs[i][1]
                    for i in range(len(vs)))
        assert area2 > 0, f"poly {pi} winds the wrong way"
        for i in range(len(vs)):
            ax, ay = vs[i]
            bx, by = vs[(i + 1) % len(vs)]
            cx, cy = vs[(i + 2) % len(vs)]
            cross = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
            assert cross >= 0, f"poly {pi} concave at vertex {i}"


def test_lines_and_polygons_cross_reference(level):
    # every polygon edge k is line_indexes[k] joining endpoints k, k+1;
    # every walkable line's owner polygons both list it
    for pi, poly in enumerate(level.polygons):
        n = poly.vertex_count
        for k in range(n):
            ln = level.lines[poly.lines[k]]
            e0, e1 = poly.endpoints[k], poly.endpoints[(k + 1) % n]
            assert {ln.e0, ln.e1} == {e0, e1}
            assert pi in (ln.cw_poly, ln.ccw_poly)
            # adjacent[] mirrors the line's other owner
            other = ln.cw_poly if ln.ccw_poly == pi else ln.ccw_poly
            assert poly.adjacent[k] == other
    for li, ln in enumerate(level.lines):
        for owner in ln.polys:
            assert li in level.polygons[owner].lines


def test_portal_widths_are_door_scale(level):
    # portals in a real level sit in Marathon's door register
    # (>= ~0.35 WU, i.e. nothing degenerate slipped through parsing)
    widths = []
    for ln in level.lines:
        if ln.is_portal:
            (x0, y0), (x1, y1) = level.points[ln.e0], level.points[ln.e1]
            widths.append(math.hypot(x1 - x0, y1 - y0) / 1024.0)
    assert len(widths) > 30
    assert min(widths) > 0.3
    assert max(widths) < 40.0
