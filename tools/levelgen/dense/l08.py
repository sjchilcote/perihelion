"""L8 — THE FOLD, rebuilt at Marathon density (standalone module).

The paradox construct — one chapel heart, six identical petals, every petal
folded onto petal i+2 ("the count depends on the walker") — is preserved
byte-for-byte from tools/levelgen/campaign.py:l08(): same ngon calls, same
connect_pts coordinates, same terminals/squads/caches/exit/radio. What is
new is the approach: the chapel deck itself, a ~165-cell district authored
per MARATHON_LEVEL_STANDARDS.md (90 u tile grid, corridor chains that bend
every 2-3 cells, chambers as welded rect grids with 180 u seam portals,
56 u alcove slots and 60 u service ducts for the narrow register, ~10%
dead-end alcoves, kinds assigned in coherent districts: dock narthex ->
quarters/records -> medbay -> nave -> undercroft/pump -> the Fold).

Otherworld (l08 dosage: one small cluster): six soft-walled cells bridged
into the corridor ladder as a side loop — connective/ambush tissue only.
No door, key, terminal, or exit touches an otherworld cell.

The player now spawns at the district's west dock (free 90 u west walls for
the WorldStreamer's entry carve); the exit stays on the Fold's core, whose
neighboring petals keep 100 u free edges for the streamer's exit-side BFS
carve (stream.py handles the saturated core itself).

Contract mirrors campaign.py's l08(): build() returns a LevelBuilder; the
save flow is save_level(build().to_dict(), path), and .build() validates.

Run standalone:  uv run python tools/levelgen/dense/l08.py [out.json]
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

_GAME = Path(__file__).resolve().parents[3] / "game"
if str(_GAME) not in sys.path:
    sys.path.insert(0, str(_GAME))

from perihelion.levels import LevelBuilder, save_level  # noqa: E402

# ---------------------------------------------------------------------------
# helpers (copied verbatim in behavior from tools/levelgen/campaign.py so the
# preserved fold fixtures land at identical coordinates)
# ---------------------------------------------------------------------------


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
    mx, my, tx, ty, nx, ny = wall_basis(b, room, wall, t)
    return (mx + nx * inset, my + ny * inset)


def cache(b: LevelBuilder, room: int, spec: str, off=(0.0, 0.0),
          wall: int | None = None, t: float = 0.5, inset: float = 16.0):
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


# ---------------------------------------------------------------------------
# the chapel-deck district: 90 u tile grid, 31 cols x 14 rows, west of the
# fold (fold occupies roughly x in [-360, 360]; district east edge is -910).
# ---------------------------------------------------------------------------

T = 90.0
OX, OY = -3700.0, -720.0

# legend: . void | D dock | c corridor | d 60u duct | Q quarters | R records
#         M medbay | C chapel | S storage | P pump (merged) | O otherworld
#         G gate antechamber (transit) | a dead-end alcove (56u slot)
MAP = [
    ".............a.........CCCCC...",   # 0
    ".......QQQQ.RRRRR.....aCCCCC...",   # 1
    ".......QQQQ.RRRRRa.MMM.CCCCC...",   # 2
    ".......QQQQcccccc..MMMcccccc...",   # 3
    "......cccccc.c..ccccccc..a.c...",   # 4
    "......c..a.a.c......c......c...",   # 5
    "DDD...c......cOOO...c......c.a.",   # 6
    "DDDcccc......cOOOdddc......cccG",   # 7
    "DDD...ca.....c......ca.....c...",   # 8
    "......c.....ac......c......c...",   # 9
    ".....acccccc.c...ccccccccccc...",   # 10
    "..........cccccccc..CCCCC......",   # 11
    "...........SSSSSPPa.CCCCC......",   # 12
    "...........SSSSSPP...a.a.......",   # 13
]

KINDS = {"D": "dock", "c": "corridor", "d": "corridor", "Q": "quarters",
         "R": "records", "M": "medbay", "C": "chapel", "S": "storage",
         "P": "pump", "O": "otherworld", "G": "transit"}

# merged multi-tile cells: (r0, c0, nrows, ncols) — nave set-piece + pump hall
MERGES = [(0, 23, 2, 2), (0, 25, 2, 2), (0, 27, 2, 1), (12, 16, 2, 2)]

# cross-district tile pairs allowed to weld (90 u door register); everything
# else across a district boundary stays a sealed wall (no_connect)
DOORS = {
    frozenset({(7, 2), (7, 3)}),      # dock -> hall
    frozenset({(3, 8), (4, 8)}),      # quarters twin doors
    frozenset({(3, 10), (4, 10)}),
    frozenset({(2, 13), (3, 13)}),    # records twin doors
    frozenset({(2, 16), (3, 16)}),
    frozenset({(3, 20), (4, 20)}),    # medbay
    frozenset({(2, 23), (3, 23)}),    # nave twin doors
    frozenset({(2, 26), (3, 26)}),
    frozenset({(6, 13), (6, 14)}),    # otherworld west mouth
    frozenset({(10, 21), (11, 21)}),  # side chapels
    frozenset({(10, 23), (11, 23)}),
    frozenset({(11, 12), (12, 12)}),  # undercroft storage
    frozenset({(11, 15), (12, 15)}),
    frozenset({(11, 16), (12, 16)}),  # pump hall from spine
    frozenset({(12, 15), (12, 16)}),  # storage <-> pump interior
    frozenset({(7, 29), (7, 30)}),    # gate antechamber
}

# same-district seams kept solid (quarters suite dividers)
SEALS = {
    frozenset({(1, 7), (1, 8)}), frozenset({(1, 8), (1, 9)}),
    frozenset({(1, 9), (1, 10)}),
    frozenset({(2, 7), (2, 8)}), frozenset({(2, 8), (2, 9)}),
    frozenset({(2, 9), (2, 10)}),
}

# dead-end alcove kinds (niche dressing per neighboring district)
ALCOVE_KIND = {
    (0, 13): "records", (1, 22): "chapel", (2, 17): "records",
    (4, 25): "chapel", (5, 9): "storage", (5, 11): "storage",
    (6, 29): "storage", (8, 7): "storage", (8, 21): "storage",
    (9, 12): "storage", (10, 5): "storage", (12, 18): "storage",
    (13, 21): "chapel", (13, 23): "chapel",
}

AW, AD, ACH = 56.0, 64.0, 16.0  # alcove slot width / depth / chamfer


def _tile(r: int, c: int) -> str:
    if 0 <= r < len(MAP) and 0 <= c < len(MAP[0]):
        return MAP[r][c]
    return "."


def _alcove(b: LevelBuilder, r: int, c: int, kind: str, chamfer: bool) -> int:
    """A 56 u-mouth dead-end niche inside tile (r, c), welded to its single
    walkable neighbor by the doorway-splitter (slot register). Chamfered far
    corners face solid tiles only, so no weld geometry is disturbed."""
    nbrs = [(r + dr, c + dc) for dr, dc in ((0, 1), (0, -1), (1, 0), (-1, 0))
            if _tile(r + dr, c + dc) not in (".", "a")]
    assert len(nbrs) == 1, f"alcove {(r, c)} needs exactly 1 neighbor, has {nbrs}"
    nr, nc = nbrs[0]
    x0, y0 = c * T + OX, r * T + OY
    ch = ACH if chamfer else 0.0
    if nc == c - 1:    # opens west
        x, y, w, h = x0, y0 + (T - AW) / 2, AD, AW
        verts = [(x, y), (x, y + h), (x + w - ch, y + h), (x + w, y + h - ch),
                 (x + w, y + ch), (x + w - ch, y)]
    elif nc == c + 1:  # opens east
        x, y, w, h = x0 + T - AD, y0 + (T - AW) / 2, AD, AW
        verts = [(x + ch, y), (x, y + ch), (x, y + h - ch), (x + ch, y + h),
                 (x + w, y + h), (x + w, y)]
    elif nr == r - 1:  # opens north
        x, y, w, h = x0 + (T - AW) / 2, y0, AW, AD
        verts = [(x, y), (x, y + h - ch), (x + ch, y + h), (x + w - ch, y + h),
                 (x + w, y + h - ch), (x + w, y)]
    else:              # opens south
        x, y, w, h = x0 + (T - AW) / 2, y0 + T - AD, AW, AD
        verts = [(x + ch, y), (x, y + ch), (x, y + h), (x + w, y + h),
                 (x + w, y + ch), (x + w - ch, y)]
    if not chamfer:
        verts = [(x, y), (x, y + h), (x + w, y + h), (x + w, y)]
    room = b.poly(verts)
    b.set_kind(room, kind)
    return room


def _build_district(b: LevelBuilder) -> dict[tuple[int, int], int]:
    """Emit the tile mesh; returns tile -> room index (merged tiles share)."""
    room_at: dict[tuple[int, int], int] = {}

    merged: dict[tuple[int, int], int] = {}
    for r0, c0, nr, nc in MERGES:
        kind = KINDS[_tile(r0, c0)]
        room = b.rect(c0 * T + OX, r0 * T + OY, nc * T, nr * T, kind=kind)
        for r in range(r0, r0 + nr):
            for c in range(c0, c0 + nc):
                assert _tile(r, c) == _tile(r0, c0), f"merge mismatch {(r, c)}"
                merged[(r, c)] = room

    for r, row in enumerate(MAP):
        for c, ch in enumerate(row):
            if ch == ".":
                continue
            if (r, c) in merged:
                room_at[(r, c)] = merged[(r, c)]
                continue
            if ch == "a":
                chamfer = (r + c) % 2 == 0
                room_at[(r, c)] = _alcove(b, r, c, ALCOVE_KIND[(r, c)], chamfer)
            elif ch == "d":
                # 60 u service duct (narrow register), horizontal runs only
                assert _tile(r, c - 1) != "." or _tile(r, c + 1) != "."
                room_at[(r, c)] = b.rect(c * T + OX, r * T + OY + 15.0, T, 60.0,
                                         kind="corridor")
            else:
                room_at[(r, c)] = b.rect(c * T + OX, r * T + OY, T, T,
                                         kind=KINDS[ch])

    # adjacency policy: same district welds (autoconnect), district borders
    # seal unless a DOOR names them, alcoves/ducts always weld to their host
    done: set[frozenset[int]] = set()
    for r, row in enumerate(MAP):
        for c, ch in enumerate(row):
            if ch == ".":
                continue
            for r2, c2 in ((r, c + 1), (r + 1, c)):
                ch2 = _tile(r2, c2)
                if ch2 == ".":
                    continue
                ra, rb = room_at[(r, c)], room_at[(r2, c2)]
                if ra == rb:
                    continue
                pair = frozenset({ra, rb})
                if pair in done:
                    continue
                done.add(pair)
                tpair = frozenset({(r, c), (r2, c2)})
                if "a" in (ch, ch2) or "d" in (ch, ch2):
                    continue  # always weld
                if ch == ch2:
                    if tpair in SEALS:
                        b.no_connect(ra, rb)
                    continue
                if tpair not in DOORS:
                    b.no_connect(ra, rb)
    return room_at


# ---------------------------------------------------------------------------
# the level
# ---------------------------------------------------------------------------


def build() -> LevelBuilder:
    b = LevelBuilder("THE FOLD", 4, "amb_drone_late")
    b.data["alert_hops"] = 1  # the fold eats sound

    # -- the paradox construct, verbatim from campaign.py:l08() -----------
    # `core` is the chapel's own heart -- SERMON text below -- kept a real
    # kind despite the pure-graph tier; `petals` stay `generic` on purpose
    # (see LEVEL_DESIGN_PLAYBOOK.md §8): six visually-identical cells is the
    # paradox ("the count depends on the walker"), not a tagging gap.
    core = b.ngon(0, 0, 100, 6, phase=math.radians(90), kind="chapel")
    petals = []
    angs = []
    for i in range(6):
        a = math.radians(90) - (i + 0.5) * math.pi / 3
        angs.append(a)
        petals.append(b.ngon(260 * math.cos(a), 260 * math.sin(a), 100, 6,
                             phase=a + math.radians(90), kind="generic"))
    for i, a in enumerate(angs):
        b.connect_pts(core, (86.6 * math.cos(a), 86.6 * math.sin(a)),
                      petals[i],
                      (260 * math.cos(a) - 86.6 * math.cos(a),
                       260 * math.sin(a) - 86.6 * math.sin(a)))
    # fold: each petal's far-right edge to the far-left edge of petal i+2
    for i in range(6):
        j = (i + 2) % 6
        ai, aj = angs[i], angs[j]
        pi_c = (260 * math.cos(ai), 260 * math.sin(ai))
        pj_c = (260 * math.cos(aj), 260 * math.sin(aj))
        b.connect_pts(
            petals[i], (pi_c[0] + 86.6 * math.cos(ai - math.pi / 3),
                        pi_c[1] + 86.6 * math.sin(ai - math.pi / 3)),
            petals[j], (pj_c[0] + 86.6 * math.cos(aj + math.pi / 3),
                        pj_c[1] + 86.6 * math.sin(aj + math.pi / 3)))

    # -- the chapel deck around it ----------------------------------------
    room_at = _build_district(b)

    # gate antechamber east edge -> petal 0's free west wall (edge 5; the
    # paradox uses petal edges 0/2/4 only, so this is approach re-dressing,
    # not topology change)
    gate = room_at[(7, 30)]
    b.connect_pts(gate, (OX + 31 * T, OY + 7.5 * T),
                  petals[0], (260 * math.cos(angs[0]) - 86.6,
                              260 * math.sin(angs[0])))

    # -- player: the district's west dock (streamer-carvable west walls) --
    b.player(room_at[(7, 0)], center(b, room_at[(7, 0)]))

    # -- diegetics preserved verbatim from campaign.py:l08() --------------
    b.intro("The chapel deck. Folded.\nSix rooms around one. Or one room\n"
            "around six. The count depends on the walker.")
    b.terminal(core, (0, -60),
               "SERMON, UNDELIVERED\nThey ask: is the station haunted?\n"
               "No. A haunting is a place remembering.\n"
               "This is a place being remembered —\nby something on the other side.")
    squad(b, core, "warden")
    b.data["rooms"][core]["entities"][-1]["props"] = {"hp": 180, "tether": 1}
    b.terminal(petals[0], wall_pos(b, petals[0], 1, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 8%]\n"
               "six were sent. six return, always six.\n"
               "the seventh count is a mistake in the counting,\n"
               "not a seventh room. we filed it that way for a\n"
               "long time. the filing is also how the room first\n"
               "appeared. we do not file it that way now, and\n"
               "the room has not gone.")
    b.terminal(petals[3], wall_pos(b, petals[3], 3, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 19%]\n"
               "students were walked here blind, on purpose,\n"
               "early. counting the doors and losing the count\n"
               "was the whole of the lesson. you cannot fear a\n"
               "direction you have already used to find your way\n"
               "home once.")
    b.terminal(petals[5], wall_pos(b, petals[5], 5, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 6%]\n"
               "we did not name them once we understood them.\n"
               "naming a thing is agreeing it has one shape. the\n"
               "closest word left in any of our tongues\n"
               "translates, roughly, as 'the un-arriving guest.'")
    petal_squads = ["husk", "spitter", "mite mite mite",
                    "brute", "shrieker", "spitter"]
    petal_caches = ["ammo_9mm ammo_shell medkit", "medkit", "medkit ammo_cell",
                    "ammo_shell medkit", "ammo_shell ammo_9mm", "medkit"]
    for i, p in enumerate(petals):
        squad(b, p, petal_squads[i])
        if petal_caches[i]:
            cache(b, p, petal_caches[i])
    cache(b, core, "medkit medkit ammo_cell ammo_shell ammo_9mm safe_room_core portable_hole")
    b.exit(core, (0, 40), gate_kind="warden")

    # -- district population (playbook pacing: fights in named rooms, the
    # dock and most corridor chains stay quiet beats) ----------------------
    squad(b, room_at[(7, 4)], "husk husk")             # hall first contact
    squad(b, room_at[(1, 8)], "husk husk mite")        # quarters suite
    squad(b, room_at[(2, 14)], "spitter mite mite")    # records stacks
    squad(b, room_at[(6, 13)], "shrieker husk")        # ladder junction
    squad(b, room_at[(2, 20)], "husk husk")            # medbay
    squad(b, room_at[(0, 23)], "brute shrieker")       # nave (set-piece)
    squad(b, room_at[(2, 25)], "husk husk")            # nave south aisle
    squad(b, room_at[(7, 15)], "mite mite mite mite")  # otherworld ambush
    squad(b, room_at[(13, 13)], "spitter husk")        # undercroft
    squad(b, room_at[(12, 16)], "brute")               # pump hall
    squad(b, room_at[(12, 22)], "shrieker mite mite")  # side chapels
    squad(b, room_at[(12, 20)], "spitter")             # side chapel west bay
    squad(b, room_at[(7, 29)], "spitter")              # gate antechamber

    # caches racked where a quartermaster would put them (playbook §5)
    cache(b, room_at[(6, 1)], "ammo_9mm medkit", wall=3)
    cache(b, room_at[(1, 7)], "medkit", wall=3)
    cache(b, room_at[(0, 13)], "medkit")                      # records niche
    cache(b, room_at[(2, 19)], "medkit medkit", wall=3)
    cache(b, room_at[(4, 25)], "ammo_shell ammo_9mm")         # reliquary niche
    cache(b, room_at[(12, 11)], "ammo_9mm ammo_shell ammo_cell medkit", wall=0)
    cache(b, room_at[(8, 7)], "ammo_9mm")
    cache(b, room_at[(9, 12)], "ammo_shell")
    cache(b, room_at[(13, 21)], "medkit")
    # armory beat at the fold's threshold (playbook §5.1: entry-threshold
    # placement, centered on the walk line so a route-following player
    # cannot miss it; by campaign time this shotgun is an idempotent
    # duplicate of L3's, standalone it arms the fold fight)
    cache(b, room_at[(7, 28)], "weapon_shotgun ammo_shell ammo_shell")
    cache(b, room_at[(6, 29)], "medkit medkit ammo_9mm")      # gate stash
    # triage shelf at the last normal cell before the fold: medkits are
    # only consumed at <=70 hp (sim rule), so a healthy walker leaves them
    cache(b, room_at[(7, 30)], "medkit medkit")
    return b


def main() -> None:
    b = build()
    lvl = b.build()  # validates winding/schema/spawn
    kinds = {}
    for k in lvl.room_kinds:
        kinds[k] = kinds.get(k, 0) + 1
    print(f"THE FOLD (dense): rooms={len(lvl.room_verts)} "
          f"connects={len(lvl.connects)} kinds={kinds}")
    if len(sys.argv) > 1:
        save_level(b.to_dict(), sys.argv[1])
        print(f"wrote {sys.argv[1]}")


if __name__ == "__main__":
    main()
