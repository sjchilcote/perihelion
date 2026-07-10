"""L6 — MIRROR WARD, rebuilt at Marathon density (standalone module).

The diegetic skeleton of campaign.py's l06() survives intact: name/tier/
ambience, the mirror paradox (the ward's south wall connects to itself —
connect_pts coordinates untouched), the discharge-handle key fiction, all
five terminals verbatim, the radio script verbatim, the original squads and
caches in the ward complex, and the exit in the morgue.

Around that skeleton the old 420x100 approach hall is re-authored as a
station district per MARATHON_LEVEL_STANDARDS.md: a ~90 u cell lattice
(three width registers — 50 u pinches, 90 u standard cells, 180/270 u
chamber seams), corridor chains, chamber grids welded by the coincident-
edge autoconnect, ~10% dead-end alcoves, and kinds assigned in coherent
districts. The fiction: the medical isolation wing you circle to reach the
sealed ward — staff quarters and records to the north, triage in the
middle, supply and pumps to the west, a recovery row, a viewing chapel and
overflow storage to the south. The isolation block itself (ward / side
ward / morgue) keeps its exact original geometry and adjacency: everything
else routes AROUND it, which is the point.

Streaming: the entry room keeps its west/north/south walls solid (140 u
each) and the morgue keeps its 100 u east wall solid, so WorldStreamer can
carve its 70 u spine doors at both ends.

Save-flow contract mirrors campaign.py's l06() exactly:
    b = build()                    # returns the LevelBuilder
    save_level(b.to_dict(), path)  # resolved dict, round-trips
    b.build()                      # validates winding/schema/spawn
"""

from __future__ import annotations

import math
import sys
from pathlib import Path
from random import Random

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402

# ---------------------------------------------------------------------------
# helpers (same conventions as tools/levelgen/campaign.py — copied so this
# module stays standalone; campaign.py is not imported and not touched)
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
# the cell lattice
# ---------------------------------------------------------------------------

PITCH = 90.0
OX, OY = 140.0, -510.0  # tile (c=0, r=0) has its NW corner here
CMIN = -7               # map string index i == c - CMIN

# Legend: Q quarters, R records, M medbay (triage/recovery), S storage,
# P pump, H chapel, C corridor cell, n narrow (50 u) corridor pinch,
# '.' solid rock. Transit tagging is computed from degree afterwards.
#
#        c: -7 -6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7  8
MAP = [
    "QQQQ.QQQ...RRRRR",   # r0  y -510  staff dorms | records stacks
    "QQQQ.QQQ...CCRRR",   # r1  y -420  dorm rows   | records hall
    ".CCCCCCCCCCC.R..",   # r2  y -330  the north gallery (long hall)
    "SS..n..C..CCCC..",   # r3  y -240  supply | triage stair | records loop
    "SS..C..MMMC.....",   # r4  y -150  supply | TRIAGE (slab pair)
    "SS..C..MMMn.....",   # r5  y  -60  supply | TRIAGE lower slabs
    "PPP.C..CCCC.....",   # r6  y   30  pumps  | ADMISSIONS SPINE -> ward
    "PPP.n...C.......",   # r7  y  120  pumps  | spine-to-south link
    ".CCCCnCCCCCnCC..",   # r8  y  210  the south gallery
    ".C.MM.HHH.C.SS..",   # r9  y  300  recovery row | chapel | overflow store
    ".CMMM.HHH.C.SS..",   # r10 y  390  recovery     | chapel slab
    ".CCMM.HHHCC.....",   # r11 y  480  recovery     | chapel slab | east loop
    ".......MCCC.....",   # r12 y  570  preparation annex + service run
]

# horizontal merges: runs of same-row tiles built as one wide slab so the
# chamber seams hit the 160-320 u register (rule 5)
MERGES = [
    [(0, 4), (1, 4)],      # triage north slab (180 u)
    [(0, 5), (1, 5)],      # triage south slab (180 u seam between the two)
    [(-5, 10), (-4, 10), (-3, 10)],  # recovery mid slab (270 u)
    [(-1, 10), (0, 10), (1, 10)],    # chapel nave slab (270 u)
    [(-1, 11), (0, 11), (1, 11)],    # chapel dais slab (270 u seam)
]

KIND_OF = {"Q": "quarters", "R": "records", "M": "medbay", "S": "storage",
           "P": "pump", "H": "chapel", "C": "corridor", "n": "corridor"}

# the ward complex + entry, kept byte-identical to campaign.l06()'s geometry
ENTRY_RECT = (0.0, 0.0, 140.0, 140.0)
WARD_RECT = (560.0, 20.0, 240.0, 100.0)
SIDE_RECT = (560.0, -120.0, 240.0, 140.0)
MORGUE_RECT = (800.0, 20.0, 180.0, 100.0)
VESTIBULE_RECT = (500.0, 30.0, 60.0, 80.0)  # 80 u door register into the ward


def _tile_rect(c: int, r: int) -> tuple[float, float, float, float]:
    return (OX + PITCH * c, OY + PITCH * r, PITCH, PITCH)


def _rects_intersect(a, b, margin: float = 2.0) -> bool:
    ax, ay, aw, ah = a
    bx, by, bw, bh = b
    return not (ax + aw + margin <= bx or bx + bw + margin <= ax
                or ay + ah + margin <= by or by + bh + margin <= ay)


def _map_cells() -> dict[tuple[int, int], str]:
    cells: dict[tuple[int, int], str] = {}
    for r, row in enumerate(MAP):
        for i, ch in enumerate(row):
            if ch != ".":
                cells[(i + CMIN, r)] = ch
    return cells


def build() -> LevelBuilder:
    b = LevelBuilder("MIRROR WARD", 3, "amb_drone_late")
    entry = b.rect(*ENTRY_RECT, kind="corridor")

    cells = _map_cells()
    merged_of: dict[tuple[int, int], int] = {}
    occupied: list[tuple[float, float, float, float]] = [
        ENTRY_RECT, WARD_RECT, SIDE_RECT, MORGUE_RECT, VESTIBULE_RECT]

    # merged slabs first
    for group in MERGES:
        cs = sorted(c for c, r in group)
        r = group[0][1]
        x, y, _, _ = _tile_rect(cs[0], r)
        w = PITCH * len(cs)
        rid = b.rect(x, y, w, PITCH, kind=KIND_OF[cells[group[0]]])
        occupied.append((x, y, w, PITCH))
        for key in group:
            merged_of[key] = rid

    rng = Random(4106)
    tiles: dict[tuple[int, int], int] = {}
    # corridor tiles are chained PAIRS of 45 u cells (split across the run,
    # Marathon's p25 cell register) — that is what keeps a full screen at
    # 8+ instances even mid-gallery. split_of[key] = ("x"|"y"|None, ids)
    split_of: dict[tuple[int, int], tuple[str | None, list[int]]] = {}
    chamfer_budget = 10

    for key in sorted(cells):
        c, r = key
        ch = cells[key]
        if key in merged_of:
            tiles[key] = merged_of[key]
            continue
        x, y, w, h = _tile_rect(c, r)

        def filled(dc, dr):
            return (c + dc, r + dr) in cells

        def cell_at(dc, dr):
            return cells.get((c + dc, r + dr))

        if ch == "n":
            # 50 u pinch cell, oriented by its neighbors (slot register)
            if filled(0, -1) or filled(0, 1):
                rid = b.rect(x + 20.0, y, 50.0, PITCH, kind="corridor")
                occupied.append((x + 20.0, y, 50.0, PITCH))
            else:
                rid = b.rect(x, y + 20.0, PITCH, 50.0, kind="corridor")
                occupied.append((x, y + 20.0, PITCH, 50.0))
            tiles[key] = rid
            split_of[key] = (None, [rid])
            continue

        if ch == "C":
            # split axis: across the run; but a wall that faces a pinch (or
            # the ward vestibule) must stay full-width so the narrow edge
            # stays CONTAINED in it (the splitter only matches contained or
            # exactly-coincident edges)
            force = set()
            if cell_at(0, -1) == "n" or cell_at(0, 1) == "n":
                force.add("y")  # keep north/south edges full-width
            if cell_at(-1, 0) == "n" or cell_at(1, 0) == "n":
                force.add("x")  # keep east/west edges full-width
            if key == (3, 6):
                force.add("x")  # vestibule weld needs the full east wall
            if len(force) == 2:
                rid = b.rect(x, y, w, h, kind="corridor")
                tiles[key] = rid
                split_of[key] = (None, [rid])
                occupied.append((x, y, w, h))
                continue
            nh = int(filled(-1, 0)) + int(filled(1, 0))
            nv = int(filled(0, -1)) + int(filled(0, 1))
            if "x" in force or ("y" not in force and nh >= nv):
                ids = [b.rect(x, y, 45.0, h, kind="corridor"),
                       b.rect(x + 45.0, y, 45.0, h, kind="corridor")]
                axis = "x"
            else:
                ids = [b.rect(x, y, w, 45.0, kind="corridor"),
                       b.rect(x, y + 45.0, w, 45.0, kind="corridor")]
                axis = "y"
            tiles[key] = ids[0]
            split_of[key] = (axis, ids)
            occupied.append((x, y, w, h))
            continue

        # chamfer variety (rule 7): cut a corner whose both sides face rock
        corners = []  # (vertex_index, need-empty sides as (dc,dr) pairs)
        if not filled(0, -1) and not filled(-1, 0):
            corners.append(0)   # NW
        if not filled(-1, 0) and not filled(0, 1):
            corners.append(1)   # SW
        if not filled(0, 1) and not filled(1, 0):
            corners.append(2)   # SE
        if not filled(1, 0) and not filled(0, -1):
            corners.append(3)   # NE
        if (ch in "QRMSPH" and corners and chamfer_budget > 0
                and rng.random() < 0.55):
            chamfer_budget -= 1
            cut = 30.0
            base = [(x, y), (x, y + h), (x + w, y + h), (x + w, y)]
            vi = rng.choice(corners)
            verts = []
            for j, v in enumerate(base):
                if j != vi:
                    verts.append(v)
                    continue
                px, py = base[(j - 1) % 4]
                nx, ny = base[(j + 1) % 4]

                def toward(ax, ay, bx, by, d):
                    dx, dy = bx - ax, by - ay
                    l = math.hypot(dx, dy)
                    return (ax + dx / l * d, ay + dy / l * d)

                verts.append(toward(v[0], v[1], px, py, cut))
                verts.append(toward(v[0], v[1], nx, ny, cut))
            rid = b.room(verts, kind=KIND_OF[ch])
        else:
            rid = b.rect(x, y, w, h, kind=KIND_OF[ch])
        occupied.append((x, y, w, h))
        tiles[key] = rid

    # placeness discipline: chamber blocks get one or two doors onto the
    # galleries instead of a doorway per shared tile edge, and dorm rows
    # split into bunk bays (playbook §1/§5 — a room has one function, a
    # door is a decision). Pairs listed as ((c, r), (c, r)).
    NO_DOOR = [
        # west dorms: single gallery door at c-5
        ((-6, 1), (-6, 2)), ((-4, 1), (-4, 2)),
        # west dorm bunk bays: two-cell bunk rooms off the lower row
        ((-7, 0), (-6, 0)), ((-5, 0), (-4, 0)),
        # east dorms: single gallery door at c-1; one bunk partition
        ((-2, 1), (-2, 2)), ((0, 1), (0, 2)),
        ((-2, 0), (-1, 0)),
        # records: two shelf aisles, cross-link at c6/c8 only
        ((7, 0), (7, 1)),
        # chapel: one door off the south gallery, at the nave center
        ((-1, 9), (-1, 8)), ((1, 9), (1, 8)),
        # recovery row: one door
        ((-4, 9), (-4, 8)),
        # overflow storage: one door
        ((6, 9), (6, 8)),
        # pumps: one door onto the south gallery
        ((-5, 7), (-5, 8)),
    ]
    def rooms_of(key):
        if key in split_of:
            return split_of[key][1]
        return [tiles[key]]

    for ka, kb in NO_DOOR:
        for ra in rooms_of(ka):
            for rb in rooms_of(kb):
                b.no_connect(ra, rb)

    # transit tagging: corridor tiles that junction 3+ ways
    for key in tiles:
        if cells[key] not in ("C", "n"):
            continue
        c, r = key
        deg = sum(1 for dc, dr in ((1, 0), (-1, 0), (0, 1), (0, -1))
                  if (c + dc, r + dr) in cells)
        if key == (0, 6):
            deg += 1  # the entry door
        if key == (3, 6):
            deg += 1  # the ward vestibule
        if deg >= 3:
            for rid in rooms_of(key):
                b.set_kind(rid, "transit")

    # dead-end alcoves (rule 4): 40 u slot niches off corridor cells, ~10%
    # of the mesh; a few hold caches, the rest hold the quiet. The niche is
    # 40 u along the wall (slot register) so it stays CONTAINED in a 45 u
    # half-cell wall as well as a 90 u whole one.
    side_delta = {"E": (1, 0), "W": (-1, 0), "N": (0, -1), "S": (0, 1)}
    alcoves: list[int] = []
    arng = Random(6641)
    for key in sorted(tiles):
        if cells[key] != "C":
            continue
        c, r = key
        x, y, _, _ = _tile_rect(c, r)
        axis, ids = split_of[key]
        free = [s for s, (dc, dr) in side_delta.items()
                if (c + dc, r + dr) not in cells]
        arng.shuffle(free)
        for s in free:
            if len(alcoves) >= 14:
                break
            # host wall segment along the chosen side
            if s in ("N", "S"):
                segs = ([(x, 45.0), (x + 45.0, 45.0)] if axis == "x"
                        else [(x, PITCH)])
                sx, sw = arng.choice(segs)
                ax = sx + (sw - 40.0) / 2.0
                rect = ((ax, y - 55.0, 40.0, 55.0) if s == "N"
                        else (ax, y + PITCH, 40.0, 55.0))
            else:
                segs = ([(y, 45.0), (y + 45.0, 45.0)] if axis == "y"
                        else [(y, PITCH)])
                sy, sh = arng.choice(segs)
                ay = sy + (sh - 40.0) / 2.0
                rect = ((x + PITCH, ay, 55.0, 40.0) if s == "E"
                        else (x - 55.0, ay, 55.0, 40.0))
            # interior-overlap test (negative margin): the alcove must
            # touch its host tile edge-on, which is not a collision; real
            # overlaps (other alcoves, the ward complex, entry) reject
            if any(_rects_intersect(rect, o, margin=-0.5) for o in occupied):
                continue
            if arng.random() < 0.45:
                rid = b.rect(*rect, kind="storage")
                occupied.append(rect)
                alcoves.append(rid)
                break

    # ------------------------------------------------------------------
    # the isolation block — geometry and adjacency identical to l06()
    # ------------------------------------------------------------------
    ward = b.rect(*WARD_RECT, kind="medbay")
    side = b.rect(*SIDE_RECT, kind="medbay")
    morgue = b.rect(*MORGUE_RECT, kind="medbay")
    # the vestibule welds to spine tile (3,6) and the ward by containment,
    # presenting an 80 u door register on the ward's west wall
    b.rect(*VESTIBULE_RECT, kind="corridor")

    # THE MIRROR: the ward's south wall connects to itself.
    b.connect_pts(ward, (680, 120), ward, (680, 120))
    # the "red key" is the discharge bolt's removable handle. The bolt has
    # no handle on the morgue side by design — discharge is a decision the
    # ward makes — and the seal team carried the handle in with them when
    # they closed the section (discharge-notice terminal, below).
    b.key_meta("red", "DISCHARGE HANDLE", "DISCHARGE BOLT",
               "BOLT THROWN - DISCHARGE HANDLE REQUIRED",
               "ACQUIRED: DISCHARGE HANDLE")

    b.player(entry, (70, 70))
    b.intro("Medical isolation. The ward was sealed\n"
            "from the inside. The seal is intact.\nThe ward is not empty.")
    b.terminal(side, wall_pos(b, side, 3, 0.5, 15.0),
               "ISOLATION LOG\nDay 1: patient stares at south wall.\n"
               "Day 2: patient talks to south wall.\nDay 3: patient answers.\n"
               "Day 4: two voices. One patient.\nDay 5: [no further entries]")
    b.terminal(morgue, wall_pos(b, morgue, 3, 0.5, 15.0),
               "PATHOLOGY\nSubject recovered from ward.\n"
               "All organs mirrored. Situs inversus totalis.\n"
               "Subject's ID chip reads valid.\n"
               "It is the chip of a crewman standing\nguard outside.")
    b.terminal(morgue, wall_pos(b, morgue, 1, 0.5, 15.0),
               "ISOLATION WING — DISCHARGE NOTICE\n"
               "The discharge bolt takes its handle from the\n"
               "ward side. There is no handle on this side;\n"
               "that is the design. The seal team carried the\n"
               "ward handle in with them when they closed it.\n"
               "Nobody has carried it back out.")
    b.terminal(entry, wall_pos(b, entry, 0, 0.5, 15.0),
               "GUARD LOG, WARD ENTRANCE\n"
               "0600 — on post.\n"
               "0600 — on post.\n"
               "Same hand, same ink, two lines, no gap between\n"
               "them. Whoever wrote it isn't answering the page.\n"
               "Post considered staffed. Post considered.")
    # LLM-generated verbatim (Hermes-4-405B via OpenRouter, same call
    # pattern as tools/dialogue/generate.py). Content-normalized similarity
    # to the raw candidate: 1.0000. Seed beat 2/3 of the docent-voice arc
    # (l05-l07): hospitality anticipating a guest nobody sent.
    b.terminal(entry, wall_pos(b, entry, 3, 0.5, 15.0),
               "ENVIRONMENTAL SYSTEMS LOG 8K02\n"
               "Medical Ward 05-16 humidity adjusted\n"
               "automatically to 45% RH Parameter shift\n"
               "observed at cycle 241.8, prior to quarantine\n"
               "activation Attending logged admission of\n"
               "biological subject at cycle 241.9 Shift\n"
               "matches recommended biocompatibility profile\n"
               "for organic respiration No crew-mind units\n"
               "require this profile; adjustment source\n"
               "unclear Flagged as possible preset carryover\n"
               "from prior contaminant event Scheduler\n"
               "diagnostic returns nominal; filed under\n"
               "auto-humidity calibration checks")
    b.terminal(side, wall_pos(b, side, 0, 0.5, 15.0),
               "ADMISSION CHART, WARD BED 1\n"
               "Patient reports hearing own voice from an empty\n"
               "bed. Attending's note: patient IS the only\n"
               "occupant. Chart amended twice to reflect one (1)\n"
               "patient, current census.\n"
               "Census taken again at shift change: two (2) beds\n"
               "occupied. Census not amended a third time.\n"
               "Attending went off shift and did not return for\n"
               "handoff.")

    # ------------------------------------------------------------------
    # population: the original squads stay; the district gets a modest
    # garrison so the mesh reads as swept space, not wallpaper
    # ------------------------------------------------------------------
    squad(b, tiles[(2, 5)], "husk husk mite mite")   # triage (the old hall squad)
    squad(b, ward, "husk husk husk husk")
    squad(b, side, "spitter")
    squad(b, morgue, "brute shrieker")

    squad(b, tiles[(-6, 1)], "husk husk")            # west dorms
    squad(b, tiles[(-1, 0)], "mite mite")            # east dorms
    squad(b, tiles[(6, 1)], "mite mite mite")        # records stacks
    squad(b, tiles[(-6, 4)], "husk mite")            # supply
    squad(b, tiles[(-6, 6)], "spitter")              # pumps
    squad(b, tiles[(0, 10)], "husk husk mite")       # chapel nave
    squad(b, tiles[(-3, 10)], "husk husk")           # recovery row
    squad(b, tiles[(5, 9)], "mite mite")             # overflow storage
    squad(b, tiles[(1, 8)], "husk")                  # south gallery

    # caches: the ward-complex racks stay verbatim; the district's ammo
    # lives in supply rooms and dead-end niches, racked on rock walls
    cache(b, tiles[(1, 6)], "ammo_9mm")              # the old hall drop, spine
    cache(b, tiles[(-7, 4)], "ammo_9mm ammo_9mm medkit", wall=0, t=0.5,
          inset=16.0)                                # supply west wall (rock)
    cache(b, tiles[(6, 9)], "ammo_9mm medkit", wall=2, t=0.5, inset=16.0)
    cache(b, tiles[(5, 10)], "ammo_shell medkit", wall=1, t=0.5, inset=16.0)
    cache(b, tiles[(3, 12)], "ammo_9mm", off=(0, 0))  # service run
    if len(alcoves) >= 3:
        cache(b, alcoves[0], "medkit")
        cache(b, alcoves[1], "ammo_9mm")
        cache(b, alcoves[2], "ammo_9mm")

    cache(b, side, "weapon_tau ammo_cell medkit", wall=3, t=0.4, inset=16.0)
    # morgue is the level's only exit room, entered from the west (ward)
    # wall at the same height (y=70) as the exit pad -- the tau rack sits
    # right at that threshold so the walk to the exit can't miss it, the
    # way the smg rack in COOLANT ROW's armory does.
    cache(b, morgue, "weapon_tau ammo_cell", wall=0, t=0.5, inset=12.0)
    cache(b, morgue, "ammo_shell ammo_shell medkit", off=(30, 0))
    # the discharge handle lies against the mirror wall: to leave, you must
    # walk up to your own reflection
    b.entity(ward, "key_red", (680, 108))
    b.exit(morgue, (930, 70), key="red")
    return b


if __name__ == "__main__":
    lvl = build().build()
    print(f"MIRROR WARD dense: rooms={len(lvl.room_verts)} "
          f"connects={len(lvl.connects)}")
