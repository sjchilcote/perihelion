"""L07 — RECURSION STACK, rebuilt at Marathon density (standalone module).

Contract: `l07()` mirrors campaign.py's l07() exactly — no args, returns a
LevelBuilder; `build()` returns the resolved level dict (what campaign.py
passes to `save_level(b.to_dict(), ...)`).

What is preserved verbatim from tools/levelgen/campaign.py's l07():
  - name/tier/ambience, the {corridor, records, core} kind vocabulary
    (extended with corridor-family transit/storage cells and one
    `otherworld` cell per the l07 dosage: exactly one, isolated),
  - the five original rooms at their exact canvas coordinates, in the
    original index order (entry=0, stack=1, closet=2, deep=3, annex=4) so
    the enter_room radio triggers keep their original indices,
  - THE PARADOX (playbook §11, untouched): the endless aisle — stack's
    north edge welded to its own south edge via
    connect_pts(stack,(410,0),stack,(410,140)) — plus the annex "shoot"
    door secret with its no_connect,
  - gold key_meta, key_gold pickup position, exit position/key,
  - all six terminals (texts and positions), intro, and all radio lines.

What changed (allowed: approach corridors may be re-dressed): the three
plain door-hops between the original five rooms are replaced by five
authored districts (231 cells, MARATHON_LEVEL_STANDARDS.md rules 1-8;
measured visible() median 12.5 / max 22, mean adjacency degree 2.59):
  A  checkpoint corridors + octagon rotunda hub + guard stores
  B  catalog hall (3x3 seam-welded chamber) with foyer and alcoves
  C  the aisle stacks: 9 shelf aisles x 16 shelf-bay cells with 50 u
     slot perforations between ranks, cross-corridors, one dead aisle,
     and ONE isolated `otherworld` cell bridging two aisles
     (connective ambush tissue; no doors/keys/terminals/exit in it)
  D  core-wing approach to the closet
  E  deep-records intake (2x2 chamber) to deep
Corridors are chains of ~90-110 u quads bending every 2-3 cells; chamber
seams are 150-170 u; alcove slots are 60 u; ~10% of cells are dead ends;
14 cells carry a 30 u chamfer (5 verts) at bends and chamber corners.

Streaming (playbook §10): entry keeps its whole 140 u west wall solid
(spawn-side carve) and deep keeps its whole 140 u east wall solid
(exit-side carve).

Run standalone:  uv run python tools/levelgen/dense/l07.py [out.json]
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402

CUT = 30.0  # chamfer size


# --- helpers copied from tools/levelgen/campaign.py (standalone module; ---
# --- campaign.py must not be imported or edited)                        ---

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


# --- dense-mesh helpers ---------------------------------------------------

def rect_c(b: LevelBuilder, x, y, w, h, cut: str | None = None,
           kind: str | None = None, c: float = CUT) -> int:
    """Rect cell, optionally with one 30 u chamfered corner (5 verts).
    Vertex orders keep the engine-canonical negative-shoelace winding."""
    if cut is None:
        return b.rect(x, y, w, h, kind=kind)
    if cut == "nw":
        verts = [(x, y + c), (x, y + h), (x + w, y + h), (x + w, y), (x + c, y)]
    elif cut == "sw":
        verts = [(x, y), (x, y + h - c), (x + c, y + h), (x + w, y + h), (x + w, y)]
    elif cut == "se":
        verts = [(x, y), (x, y + h), (x + w - c, y + h), (x + w, y + h - c), (x + w, y)]
    elif cut == "ne":
        verts = [(x, y), (x, y + h), (x + w, y + h), (x + w, y + c), (x + w - c, y)]
    else:
        raise ValueError(f"bad cut {cut!r}")
    return b.room(verts, kind=kind)


def grid(b: LevelBuilder, x, y, cols, rows, cw, ch, kind,
         cuts: dict | None = None) -> dict:
    """cols x rows chamber of touching rects; coincident full edges weld
    into seam-register (>=150 u) portals automatically."""
    ids = {}
    for j in range(rows):
        for i in range(cols):
            ids[(i, j)] = rect_c(b, x + i * cw, y + j * ch, cw, ch,
                                 cut=(cuts or {}).get((i, j)), kind=kind)
    return ids


# --- the level ------------------------------------------------------------

def l07() -> LevelBuilder:
    b = LevelBuilder("RECURSION STACK", 3, "amb_drone_late")

    # ---- legacy rooms, exact original coordinates and index order -------
    entry = b.rect(0, 0, 160, 140, kind="corridor")          # 0
    stack = b.rect(300, 0, 220, 140, kind="records")         # 1  THE PARADOX
    closet = b.rect(700, 300, 120, 140, kind="core")         # 2  staff-mind cores
    deep = b.rect(700, -300, 200, 140, kind="records")       # 3
    annex = b.rect(740, -390, 120, 90, kind="records")       # 4  the aisle before aisle one

    b.door_pts(deep, (800, -300), annex, (800, -300), "shoot")
    b.no_connect(deep, annex)
    # the endless aisle: top of the stack feeds its own bottom (SACRED —
    # playbook §11; do not touch)
    b.connect_pts(stack, (410, 0), stack, (410, 140))
    b.key_meta("gold", "REGISTRAR'S STAMP", "STACK GATE",
               "STACK GATE SEALED - REGISTRAR'S STAMP REQUIRED",
               "ACQUIRED: REGISTRAR'S STAMP")

    # ---- district A: checkpoint corridors + rotunda hub ------------------
    # entry(140-wide east wall) -> threshold -> 90-wide chain bending
    # south then east into the rotunda; guard stores hang off it south.
    a1 = b.rect(1200, 0, 100, 140, kind="transit")           # threshold
    a2 = b.rect(1300, 25, 90, 90, kind="corridor")
    a3 = rect_c(b, 1390, 25, 110, 90, cut="ne", kind="corridor")  # bend
    v1 = b.rect(1400, 115, 90, 100, kind="corridor")
    v2 = b.rect(1400, 215, 90, 90, kind="corridor")
    # h-row grown from 90 to 150 u tall (south wall only -- the 75 u gap
    # down to guard/g_stub at y=470 is otherwise empty): the checkpoint
    # approach is what a 30 s AggroBot walk from spawn actually samples, so
    # widening its portals is what moves this level's median (rule 1).
    h1 = b.rect(1400, 305, 110, 150, kind="corridor")
    h2 = b.rect(1510, 305, 90, 150, kind="corridor")
    h3 = rect_c(b, 1600, 305, 100, 150, cut="ne", kind="corridor")
    rotunda = b.ngon(1815, 350, 110, 8, phase=math.pi / 8, kind="transit")
    a_alc1 = b.rect(1315, -35, 60, 60, kind="storage")       # slot off a2 north
    a_alc2 = b.rect(1490, 230, 60, 60, kind="storage")       # slot off v2 east
    g_stub = b.rect(1770, 470, 90, 60, kind="corridor")
    guard = grid(b, 1735, 530, 2, 2, 160, 150, "storage",
                 cuts={(0, 1): "sw", (1, 1): "se"})
    b.connect_pts(entry, (160, 70), a1, (1200, 70))
    b.connect_pts(h3, (1700, 350), rotunda, (1710, 350))     # rotunda west
    b.connect_pts(rotunda, (1815, 455), g_stub, (1815, 470))  # rotunda south

    # ---- district B: catalog hall ----------------------------------------
    f1 = b.rect(1200, 860, 100, 90, kind="corridor")
    f2 = b.rect(1300, 860, 90, 90, kind="corridor")
    f3 = b.rect(1390, 860, 110, 90, kind="corridor")
    hall = grid(b, 1500, 800, 3, 3, 170, 160, "records",
                cuts={(0, 2): "sw", (2, 0): "ne"})
    b_alc1 = b.rect(1600, 740, 60, 60, kind="storage")       # slot off hall north
    b_alc2 = b.rect(2010, 850, 60, 60, kind="storage")       # slot off hall east
    bx1 = b.rect(1880, 1280, 90, 100, kind="corridor")
    bx2 = rect_c(b, 1880, 1380, 90, 90, cut="sw", kind="corridor")  # bend
    bx3 = b.rect(1970, 1380, 100, 90, kind="corridor")
    bx4 = b.rect(2070, 1380, 90, 90, kind="corridor")
    b.connect_pts(rotunda, (1920, 350), f1, (1200, 905))     # rotunda east

    # ---- district C: the aisle stacks ------------------------------------
    # 9 shelf aisles (records), 16 cells of 90x50 each (shelf-bay beats),
    # 40 u shelf-rank gaps; cross-corridors top and bottom; aisle 4 is the
    # dead aisle (14 cells, sealed short of the bottom corridor — the
    # shelving nobody logged). Shelf ranks are perforated with 50 u slot
    # portals (crawl/window register) on a checkerboard cadence — the
    # Marathon lattice texture that lets a screen hold 8+ cells here.
    top = [rect_c(b, 1200 + 130 * i, 1700, 130, 90,
                  cut=("nw" if i == 0 else "ne" if i == 8 else None),
                  kind="corridor") for i in range(9)]
    bot = [rect_c(b, 1200 + 130 * i, 2590, 130, 90,
                  cut=("se" if i == 8 else None),
                  kind="corridor") for i in range(9)]
    aisles: dict[int, list[int]] = {}
    for i in range(9):
        n_cells = 14 if i == 4 else 16
        aisles[i] = [b.rect(1220 + 130 * i, 1790 + 50 * k, 90, 50,
                            kind="records") for k in range(n_cells)]
    # ONE otherworld cell (l07 dosage): soft-walled tissue bridging aisles
    # 2 and 3 mid-run, overlapping the shelf gap in plan (silent 5D — rule
    # 8). Connective/ambush only: no door, key, terminal, or exit in it.
    ow = b.rect(1545, 2090, 90, 100, kind="otherworld")
    b.connect_pts(ow, (1545, 2140), aisles[2][6], (1570, 2115))
    b.connect_pts(ow, (1635, 2140), aisles[3][6], (1610, 2115))
    # shelf-rank slot portals between adjacent aisles (skip the pair the
    # otherworld cell owns, and the mouth rows next to the corridors).
    # Density tuning: two rows open for every one skipped (was checkerboard,
    # half the rows) -- the aisle district is ~140 of this level's 231
    # cells and its shelf-bay cells (90x50) are too narrow to see far down
    # their own aisle, so cross-aisle sightlines are what carries this
    # district's potentially-visible count into the Marathon band (rule 1).
    for i in range(8):
        for k in range(1, 15):
            if k >= min(len(aisles[i]), len(aisles[i + 1])):
                continue
            if (i + k) % 3 == 0:
                continue
            if i == 2 and k in (6, 7):
                continue  # ow holds aisle2[6].east / aisle3[6].west
            y = 1790 + 50 * k + 25
            b.connect_pts(aisles[i][k], (1310 + 130 * i, y),
                          aisles[i + 1][k], (1220 + 130 * (i + 1), y))
    c_alc1 = b.rect(1245, 1640, 60, 60, kind="storage")      # slots off the
    c_alc2 = b.rect(1765, 1640, 60, 60, kind="storage")      # cross-corridors
    c_alc3 = b.rect(1375, 2680, 60, 60, kind="storage")
    c_alc4 = b.rect(2265, 2680, 60, 60, kind="storage")
    # approach to the stack proper: bottom corridor -> 3 cells -> stack west
    c_app1 = b.rect(900, 2565, 100, 140, kind="records")
    c_app2 = b.rect(1000, 2590, 100, 90, kind="records")
    c_app3 = b.rect(1100, 2590, 100, 90, kind="records")     # welds bot[0]
    b.connect_pts(bx4, (2160, 1425), top[8], (2370, 1745))   # B -> C
    b.connect_pts(bot[8], (2370, 2635), rotunda, (1815, 245))  # return loop
    b.connect_pts(c_app1, (900, 2635), stack, (300, 70))     # C -> the aisle

    # ---- district D: core-wing approach ----------------------------------
    d1 = b.rect(2600, 0, 100, 140, kind="corridor")          # matches stack east
    d2 = b.rect(2700, 25, 90, 90, kind="corridor")
    d3 = rect_c(b, 2790, 25, 110, 90, cut="ne", kind="corridor")  # bend
    d4 = b.rect(2800, 115, 90, 100, kind="corridor")
    d5 = b.rect(2800, 215, 90, 90, kind="corridor")
    d6 = rect_c(b, 2800, 305, 90, 110, cut="sw", kind="corridor")  # bend
    d7 = b.rect(2890, 315, 100, 90, kind="corridor")
    ante = b.rect(2990, 290, 140, 140, kind="transit")
    d_alc1 = b.rect(2715, -35, 60, 60, kind="storage")
    d_alc2 = b.rect(2890, 230, 60, 60, kind="storage")
    d_alc3 = b.rect(3030, 430, 60, 60, kind="storage")
    b.connect_pts(stack, (520, 70), d1, (2600, 70))
    b.connect_pts(ante, (3130, 360), closet, (700, 370))

    # ---- district E: deep-records intake ----------------------------------
    e1 = b.rect(3600, 700, 100, 140, kind="corridor")        # matches closet east
    e2 = b.rect(3700, 725, 90, 90, kind="corridor")
    e3 = rect_c(b, 3790, 725, 100, 90, cut="se", kind="corridor")  # bend
    e4 = b.rect(3800, 635, 90, 90, kind="corridor")
    e5 = b.rect(3800, 545, 90, 90, kind="corridor")
    intake = grid(b, 3740, 245, 2, 2, 160, 150, "records",
                  cuts={(0, 1): "sw"})
    s1 = b.rect(4060, 275, 90, 90, kind="corridor")
    s2 = b.rect(4150, 250, 100, 140, kind="corridor")        # matches deep west
    e_alc1 = b.rect(3715, 665, 60, 60, kind="storage")
    e_alc2 = b.rect(3940, 185, 60, 60, kind="storage")
    b.connect_pts(closet, (820, 370), e1, (3600, 770))
    b.connect_pts(s2, (4250, 320), deep, (700, -230))

    # ---- spawn / lore: all text verbatim from campaign.py's l07() --------
    b.player(entry, (80, 70))
    b.intro("Records. Aisle 9 is missing.\nAisle 9 is where the missing things go.")
    # LLM-generated verbatim (Hermes-4-405B via OpenRouter, same call
    # pattern as tools/dialogue/generate.py). Content-normalized similarity
    # to the raw candidate: 1.0000. Seed beat 3/3 of the docent-voice arc
    # (l05-l07): a recovered fragment nobody can classify.
    b.terminal(entry, wall_pos(b, entry, 1, 0.5, 15.0),
               "ARTIFACT RECOVERY LOG AR-2287\n"
               "Item recovered from stack gamma. Physical\n"
               "medium: unknown composite. Extensive damage\n"
               "to substrate and surface. Partial text\n"
               "recovered via multispectral imaging. Textual\n"
               "content does not conform to known archival\n"
               "formats. No hazard markers or technical\n"
               "specifications present. Sequential structure\n"
               "suggests instructional or procedural nature.\n"
               "Unable to assign category. Submitted to\n"
               "central review for analysis. Item placed in\n"
               "secure holding pending evaluation.")
    b.terminal(stack, (410, 105),
               "SHELF TAG, AISLE 9\nEverything filed here is filed here.\n"
               "Everything filed here is filed here.\n"
               "Everything filed here is filed here.\n"
               "[the tag continues for some time]")
    b.terminal(deep, wall_pos(b, deep, 1, 0.5, 15.0),
               "INCIDENT FILE 0001\nFirst contact was not a signal.\n"
               "It was an inventory discrepancy.\n"
               "We had one more room than we built.\n"
               "We sent SURVEYOR S-6 to measure it.\nIt measured back.")
    b.terminal(closet, wall_pos(b, closet, 3, 0.4, 15.0),
               "CORE RECOVERY MANIFEST\n"
               "Staff-mind cores, recovered from Records:\n"
               "  SURVEYOR W-2 - damaged, held the west ring\n"
               "  WATCH J-4 - damaged, held the junction\n"
               "  SURVEYOR S-6 - [NO CORE RECOVERED]\n"
               "They held the subverted peripherals out of the\n"
               "core ring so the administrator could seal.\n"
               "SURVEYOR S-6 walked into Aisle 9 to buy them the\n"
               "time.\n"
               "Effects racked below the cores: one records\n"
               "stamp, registrar's issue. The deep-stack gate\n"
               "releases on the stamp. Sign it back in after.")
    b.terminal(annex, wall_pos(b, annex, 3, 0.5, 15.0),
               "INCIDENT FILE 0000\n"
               "Empty folder. The tab reads 0000.\n"
               "Someone filed the folder itself as\n"
               "the incident.\n"
               "Appendix: one requisition slip,\n"
               "approved, for 'one additional room'.")
    cache(b, annex, "ammo_cell ammo_cell medkit")
    b.terminal(entry, wall_pos(b, entry, 3, 0.5, 15.0),
               "VOICE LOG, TRANSCRIBED — SURVEYOR S-6\n"
               "Going in with the tape measure this time, not\n"
               "the laser. If the laser's reading wrong the tape\n"
               "will tell me different, and if the tape agrees\n"
               "with the laser I'll believe the laser about\n"
               "everything else too.\n"
               "Ratio wanted someone with steady hands for this.\n"
               "I have steady hands. I also have a tape measure.\n"
               "Belt, suspenders.")
    b.terminal(annex, wall_pos(b, annex, 0, 0.5, 15.0),
               "REQUISITION SLIP — APPROVED\n"
               "Item: one (1) additional room. Justification\n"
               "field: blank.\n"
               "Approving signature: illegible scan, three\n"
               "characters resolve, the rest is scanner noise.\n"
               "The three that resolve are not initials MIRIAD\n"
               "uses for anyone on this posting.\n"
               "Cost center charged: Track Quanta-118093,\n"
               "pre-existing allocation. Track Quanta-118093 had\n"
               "no pre-existing allocation. The charge went\n"
               "through anyway.")

    # ---- combat / supplies: legacy roster verbatim, grown modestly ------
    squad(b, stack, "mite mite mite mite mite mite")
    squad(b, closet, "spitter spitter")
    squad(b, deep, "brute brute shrieker")
    cache(b, stack, "ammo_9mm ammo_shell", off=(60, 30))  # the aisle has no free wall
    cache(b, closet, "medkit ammo_cell portable_hole", wall=3, t=0.6, inset=16.0)
    cache(b, deep, "medkit ammo_cell ammo_shell", wall=0, t=0.5, inset=14.0)
    # new-district pacing (playbook §5/§6: racked caches, quiet foyers)
    squad(b, rotunda, "husk husk mite")
    squad(b, guard[(0, 0)], "husk husk")
    squad(b, hall[(1, 1)], "spitter mite mite")
    squad(b, top[4], "mite mite")
    squad(b, bot[3], "spitter")
    squad(b, ow, "shrieker")                       # the ambush tissue
    squad(b, ante, "husk husk")
    squad(b, intake[(0, 1)], "brute")
    cache(b, a1, "ammo_9mm", wall=1)
    cache(b, guard[(0, 0)], "ammo_9mm ammo_9mm", wall=0)
    cache(b, b_alc2, "ammo_shell medkit")          # the find, in its slot
    cache(b, aisles[4][-1], "medkit ammo_9mm ammo_9mm")  # dead-aisle cache
    cache(b, c_app2, "ammo_9mm ammo_shell medkit", wall=1)
    cache(b, d1, "medkit", wall=1)
    cache(b, ante, "ammo_9mm ammo_shell", wall=3)
    cache(b, intake[(0, 0)], "medkit ammo_shell ammo_shell", wall=3)
    cache(b, e1, "ammo_shell medkit", wall=1)

    # the stamp sits with the recovered effects, below the racked cores
    b.entity(closet, "key_gold", (735, 335))
    b.exit(deep, (860, -230), key="gold")

    # silence the linters for cells referenced only by weld geometry
    _ = (a_alc1, a_alc2, b_alc1, c_alc1, c_alc2, c_alc3, c_alc4,
         c_app3, d_alc1, d_alc2, d_alc3, e_alc1, e_alc2, s1,
         a2, a3, v1, h1, h2, f2, f3, bx1, bx3, d2, d3, d4, d5, d6, d7,
         e2, e3, e4, e5, aisles)
    return b


def build() -> dict:
    """Resolved level dict — feed straight to perihelion.levels.save_level."""
    return l07().to_dict()


if __name__ == "__main__":
    from perihelion.levels import save_level, level_from_dict

    d = build()
    lvl = level_from_dict(d)  # validates winding/schema/spawn
    out = sys.argv[1] if len(sys.argv) > 1 else None
    if out:
        save_level(d, out)
    print(f"l07 dense: {lvl.name!r} rooms={len(lvl.room_verts)} "
          f"connects={len(lvl.connects)} doors={len(lvl.doors)} "
          f"terminals={len(lvl.terminals)} "
          f"otherworld={sum(1 for k in lvl.room_kinds if k == 'otherworld')}")
