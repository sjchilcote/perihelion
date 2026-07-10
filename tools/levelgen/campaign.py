"""PERIHELION campaign generator.

Ten levels along the escalation curve of design_document_2.md §8.1:
deniable wrongness -> confirmable paradox -> overt impossibility -> pure graph.

Authoring style: rooms are drawn adjacent on the canvas; the level builder's
doorway-splitter turns any short wall segment shared with a longer wall into
an opening automatically. Impossible connections are added with connect_pts
(edge chosen by midpoint, resolved after splitting). no_connect keeps a
shared wall solid.

Run: uv run python tools/levelgen/campaign.py   (writes levels/*.json)
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "game"))
sys.path.insert(0, str(Path(__file__).resolve().parent / "dense"))

from perihelion.levels import LevelBuilder, save_level  # noqa: E402

OUT = Path(__file__).resolve().parents[2] / "levels"


def center(b: LevelBuilder, room: int) -> tuple[float, float]:
    vs = b.data["rooms"][room]["verts"]
    return (sum(v[0] for v in vs) / len(vs), sum(v[1] for v in vs) / len(vs))


def squad(b: LevelBuilder, room: int, spec: str, spread: float = 32.0):
    kinds = spec.split()
    cx, cy = center(b, room)
    n = len(kinds)
    for i, k in enumerate(kinds):
        a = 2 * math.pi * i / max(1, n) + 0.7
        r = spread if n > 1 else 0.0
        b.entity(room, k, (cx + r * math.cos(a), cy + r * math.sin(a)))


def wall_basis(b: LevelBuilder, room: int, wall: int, t: float = 0.5):
    """(mx, my, tx, ty, nx, ny) for edge `wall` of `room` in absolute-canvas
    (authoring) coordinates: a point `t` along the wall, its tangent, and its
    inward normal (toward the room's own centroid). For any room authored
    with `LevelBuilder.rect(x, y, w, h)`, edge indices are stable and known:
    0=west, 1=south, 2=east, 3=north (verified against rect()'s vertex
    order) -- pass that index explicitly rather than guessing. For irregular
    rooms (ngons, polys), the caller is responsible for picking a `wall`
    index that is not a portal edge (see LEVEL_DESIGN_PLAYBOOK.md §5)."""
    verts = b.data["rooms"][room]["verts"]
    n = len(verts)
    cx = sum(v[0] for v in verts) / n
    cy = sum(v[1] for v in verts) / n
    x0, y0 = verts[wall % n]
    x1, y1 = verts[(wall + 1) % n]
    mx, my = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy) or 1.0
    tx, ty = dx / length, dy / length
    nx, ny = -dy / length, dx / length
    if (cx - mx) * nx + (cy - my) * ny < 0:
        nx, ny = -nx, -ny
    return mx, my, tx, ty, nx, ny


def wall_pos(b: LevelBuilder, room: int, wall: int, t: float = 0.5,
             inset: float = 15.0) -> tuple[float, float]:
    """A point `inset` units in from wall `wall` of `room`, `t` along its
    length -- a wall alcove for a terminal or a control lectern
    (LEVEL_DESIGN_PLAYBOOK.md §4), never a room's floor-center."""
    mx, my, tx, ty, nx, ny = wall_basis(b, room, wall, t)
    return (mx + nx * inset, my + ny * inset)


def cache(b: LevelBuilder, room: int, spec: str, off=(0.0, 0.0),
          wall: int | None = None, t: float = 0.5, inset: float = 16.0):
    """Place a supply cache. Default (`wall=None`): a literal offset from
    room-center, `off` -- kept for paradox-critical spots and irregular
    rooms where a wall index must be hand-verified against portal edges
    first. Pass `wall=<edge index>` to rack the cache in a single row along
    that wall's tangent instead (locker/shelf framing, LEVEL_DESIGN_
    PLAYBOOK.md §5) -- safe for any `LevelBuilder.rect` room using the
    stable 0=west/1=south/2=east/3=north edge order."""
    if wall is not None:
        mx, my, tx, ty, nx, ny = wall_basis(b, room, wall, t)
        bx, by = mx + nx * inset, my + ny * inset
        items = spec.split()
        span = (len(items) - 1) * 13.0
        for i, k in enumerate(items):
            tt = -span / 2.0 + i * 13.0
            b.entity(room, k, (bx + tx * tt, by + ty * tt))
        return
    cx, cy = center(b, room)
    for i, k in enumerate(spec.split()):
        b.entity(room, k, (cx + off[0] + (i % 3) * 15 - 15,
                           cy + off[1] + (i // 3) * 15))


def sector_ring(b, cx, cy, r_in, r_out, n, a0, a1) -> list[int]:
    rooms = []
    for i in range(n):
        t0 = a0 + (a1 - a0) * i / n
        t1 = a0 + (a1 - a0) * (i + 1) / n
        rooms.append(b.poly([
            (cx + r_in * math.cos(t0), cy + r_in * math.sin(t0)),
            (cx + r_in * math.cos(t1), cy + r_in * math.sin(t1)),
            (cx + r_out * math.cos(t1), cy + r_out * math.sin(t1)),
            (cx + r_out * math.cos(t0), cy + r_out * math.sin(t0)),
        ]))
    return rooms


def arc_mid(cx, cy, r, t):
    return (cx + r * math.cos(t), cy + r * math.sin(t))


# ---------------------------------------------------------------------------
# L1 — DOCK SWEEP. Deniable: the storage ring holds nine segments in an
# eight-segment footprint.
# ---------------------------------------------------------------------------

def l01():
    from l01 import l01 as _dense_l01  # tools/levelgen/dense/l01.py
    return _dense_l01()


# ---------------------------------------------------------------------------
# L2 — COOLANT ROW. Deniable-going-on-odd: a pump room whose north hatch
# drops you back into a different pump room facing the other way. Mites.
# Red key, SMG.
# ---------------------------------------------------------------------------

def l02():
    from l02 import l02 as _dense_l02  # tools/levelgen/dense/l02.py
    return _dense_l02()


# ---------------------------------------------------------------------------
# L3 — HYDROPONICS TORUS. Confirmable: walking half an arc is a full loop;
# you come back rotated. Shotgun. Brute.
# ---------------------------------------------------------------------------

def l03():
    from l03 import l03 as _dense_l03  # tools/levelgen/dense/l03.py
    return _dense_l03()


# ---------------------------------------------------------------------------
# L4 — THE LONG GALLERY. Confirmable: four crossings southside, three
# northside. Shrieker. The implant.
# ---------------------------------------------------------------------------

def l04():
    from l04 import build as _dense_l04  # tools/levelgen/dense/l04.py
    return _dense_l04()


# ---------------------------------------------------------------------------
# L5 — TWO WINGS. Two wings, one volume. Rail gun.
# ---------------------------------------------------------------------------

def l05():
    from l05 import l05 as _dense_l05  # tools/levelgen/dense/l05.py
    return _dense_l05()


# ---------------------------------------------------------------------------
# L6 — MIRROR WARD. The mirror room. Things come out of it.
# ---------------------------------------------------------------------------

def l06():
    from l06 import build as _dense_l06  # tools/levelgen/dense/l06.py
    return _dense_l06()


# ---------------------------------------------------------------------------
# L7 — RECURSION STACK. The infinite corridor.
# ---------------------------------------------------------------------------

def l07():
    from l07 import l07 as _dense_l07  # tools/levelgen/dense/l07.py
    return _dense_l07()


# ---------------------------------------------------------------------------
# L8 — THE FOLD. Six petals around a heart; every route adds a room that
# was already there. Warden's first stand.
# ---------------------------------------------------------------------------

def l08():
    from l08 import build as _dense_l08  # tools/levelgen/dense/l08.py
    return _dense_l08()


# ---------------------------------------------------------------------------
# L9 — TESSERACT DECK. Sixteen identical rooms on a 4-cube. Pure graph.
# ---------------------------------------------------------------------------

def l09():
    from l09 import l09 as _dense_l09  # tools/levelgen/dense/l09.py
    return _dense_l09()


# ---------------------------------------------------------------------------
# L10 — PERIHELION CORE. Cayley graph of Z6 with generators {+1,+2}; the
# Container; the Warden. Guard ending.
# ---------------------------------------------------------------------------

def l10():
    from l10 import l10 as _dense_l10  # tools/levelgen/dense/l10.py
    return _dense_l10()



# ---------------------------------------------------------------------------
# THE VIGIL — endless holdout on a fold arena. "Things still come through,
# some decades. They are met."
# ---------------------------------------------------------------------------

def vigil():
    b = LevelBuilder("THE VIGIL", 4, "amb_drone_finale")
    b.data["vigil"] = True
    b.data["alert_hops"] = 1
    # same fold shape as THE FOLD (L8): the heart is a real place (the
    # watch is kept here), the petals stay uniform on purpose (see
    # LEVEL_DESIGN_PLAYBOOK.md §8) since every wave arrives identically.
    core = b.ngon(0, 0, 110, 6, phase=math.radians(90), kind="chapel")
    petals = []
    angs = []
    for i in range(6):
        a = math.radians(90) - (i + 0.5) * math.pi / 3
        angs.append(a)
        petals.append(b.ngon(280 * math.cos(a), 280 * math.sin(a), 110, 6,
                             phase=a + math.radians(90), seed=4000 + i,
                             kind="generic"))
    for i, a in enumerate(angs):
        b.connect_pts(core, (95.3 * math.cos(a), 95.3 * math.sin(a)),
                      petals[i],
                      (280 * math.cos(a) - 95.3 * math.cos(a),
                       280 * math.sin(a) - 95.3 * math.sin(a)))
    for i in range(6):
        j = (i + 2) % 6
        ai, aj = angs[i], angs[j]
        pi_c = (280 * math.cos(ai), 280 * math.sin(ai))
        pj_c = (280 * math.cos(aj), 280 * math.sin(aj))
        b.connect_pts(
            petals[i], (pi_c[0] + 95.3 * math.cos(ai - math.pi / 3),
                        pi_c[1] + 95.3 * math.sin(ai - math.pi / 3)),
            petals[j], (pj_c[0] + 95.3 * math.cos(aj + math.pi / 3),
                        pj_c[1] + 95.3 * math.sin(aj + math.pi / 3)))
    b.player(core, (0, 0))
    cache(b, core, "medkit ammo_9mm ammo_shell")
    b.intro("The watch, kept.\n"
            "Things still come through, some decades.\n"
            "They are met.")
    b.radio("start", "Ratio: Contact plotting is live. They come through "
                     "the petals; the heart is yours to hold. I'll keep "
                     "the count.")
    return b



LEVELS = [l01, l02, l03, l04, l05, l06, l07, l08, l09, l10]


def main():
    OUT.mkdir(exist_ok=True)
    manifest = []
    kinds = ("husk", "mite", "spitter", "brute", "shrieker", "warden")
    for i, fn in enumerate(LEVELS, 1):
        b = fn()
        final = b.to_dict()
        lvl = b.build()  # validates winding/schema/spawn
        name = f"l{i:02d}.json"
        save_level(final, OUT / name)
        manifest.append(f"levels/{name}")
        n_enemies = sum(1 for _, e in lvl.entities if e.type in kinds)
        print(f"{name}: {lvl.name!r} rooms={len(lvl.room_verts)} "
              f"connects={len(lvl.connects)} doors={len(lvl.doors)} "
              f"enemies={n_enemies}")
    vb = vigil()
    vb.build()
    save_level(vb.to_dict(), OUT / "vigil.json")
    print("vigil.json: THE VIGIL arena")
    (OUT / "campaign.json").write_text(json.dumps({"levels": manifest}, indent=1))
    print(f"campaign.json: {len(manifest)} levels")


if __name__ == "__main__":
    main()
