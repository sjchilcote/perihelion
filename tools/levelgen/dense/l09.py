"""L9 — TESSERACT DECK, rebuilt to Marathon density. Standalone module.

The paradox construct — sixteen chamfered cells connected as a 4-cube on
edges [0,1,3,4], chamfer edge 2 the only solid wall — is preserved verbatim
from tools/levelgen/campaign.py:l09 (geometry, connects, terminals, radio,
key/exit logic, squads, caches). Around it, a 236-cell approach mesh per
MARATHON_LEVEL_STANDARDS.md (253 cells total — Marathon's own median):
corridor chains (w=80, cells ~60-90 u, bends every 2-3 cells), chambers as
welded grids of 100-135 u convex cells with porticos/arcades threaded
along their faces, ~9% dead-end alcoves, three width registers (50-60
crawl / 70-80 door / 100-135 seam). The player now arrives through
station fragments dissolving
into THE OTHERWORLD: whole otherworld districts (soft walls, inverted
light) alternate with normal districts, and the deck is entered through a
chamfered antechamber welded chamfer-to-chamfer onto cell 0000 — the seam
the original authoring comment reserved for exactly this ("the seam the
world can be entered through"). Cell 1111's chamfer stays free for the
WorldStreamer's exit carve; the spawn chamber keeps free perimeter walls
for its entry carve.

Otherworld cells hold no keys, terminals, doors, caches, or the exit; the
construct and every mechanism stay in normal cells.

Usage:
    from l09 import build      # -> resolved level dict (save_level-ready)
    from l09 import l09        # -> LevelBuilder (campaign.py fn contract)
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402

W = 80.0  # door register


# --- helpers copied from tools/levelgen/campaign.py (standalone module) ---

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


# --- mesh authoring helpers ------------------------------------------------

def _grid(b: LevelBuilder, x: float, y: float, cols: list, rows: list,
          kind: str):
    """Chamber as a grid of touching rects; autoconnect welds every internal
    seam (a set-piece room is 4-9 convex cells joined by 120-180 u seam
    portals). Returns ({(i,j): room}, xs, ys)."""
    xs = [x]
    for w in cols:
        xs.append(xs[-1] + w)
    ys = [y]
    for h in rows:
        ys.append(ys[-1] + h)
    cells = {}
    for j in range(len(rows)):
        for i in range(len(cols)):
            cells[(i, j)] = b.rect(xs[i], ys[j], cols[i], rows[j], kind=kind)
    return cells, xs, ys


def _hall(b: LevelBuilder, pts: list, kind: str, w: float = W,
          seg: float = 60.0) -> list[int]:
    """Corridor as a CHAIN of cells along an axis-aligned centerline
    polyline: legs subdivided into ~seg-long cells, square corner cells at
    interior waypoints. All internal welds are exact-coincident edges; the
    two open end faces are left for the doorway-splitter to weld into
    whatever host wall they touch."""
    rooms: list[int] = []
    n = len(pts)
    for k in range(n - 1):
        (x0, y0), (x1, y1) = pts[k], pts[k + 1]
        if abs(y1 - y0) < 1e-9:  # horizontal leg
            d = 1.0 if x1 > x0 else -1.0
            lo = x0 + (w / 2) * d if k > 0 else x0
            hi = x1 - (w / 2) * d if k < n - 2 else x1
            length = (hi - lo) * d
            assert length > 1.0, f"degenerate leg {pts[k]}->{pts[k + 1]}"
            m = max(1, round(length / seg))
            bounds = [lo + (hi - lo) * i / m for i in range(m + 1)]
            for i in range(m):
                xa, xb = sorted((bounds[i], bounds[i + 1]))
                rooms.append(b.rect(xa, y0 - w / 2, xb - xa, w, kind=kind))
        else:  # vertical leg
            assert abs(x1 - x0) < 1e-9, "hall waypoints must be axis-aligned"
            d = 1.0 if y1 > y0 else -1.0
            lo = y0 + (w / 2) * d if k > 0 else y0
            hi = y1 - (w / 2) * d if k < n - 2 else y1
            length = (hi - lo) * d
            assert length > 1.0, f"degenerate leg {pts[k]}->{pts[k + 1]}"
            m = max(1, round(length / seg))
            bounds = [lo + (hi - lo) * i / m for i in range(m + 1)]
            for i in range(m):
                ya, yb = sorted((bounds[i], bounds[i + 1]))
                rooms.append(b.rect(x0 - w / 2, ya, w, yb - ya, kind=kind))
        if k < n - 2:  # corner cell at the next waypoint
            rooms.append(b.rect(x1 - w / 2, y1 - w / 2, w, w, kind=kind))
    return rooms


def _bay(b: LevelBuilder, x: float, y: float, w: float, h: float,
         kind: str, chamfer: str | None = None, c: float = 40.0) -> int:
    """Dead-end alcove; its welded edge exactly matches a host cell's edge
    (degree-1 cell, zero-or-one splitter insertions). `chamfer` cuts one
    OUTER corner ('ne','nw','se','sw') for 5-vert variety; callers keep the
    cut on the free side, away from the welded edge."""
    if chamfer is None:
        return b.rect(x, y, w, h, kind=kind)
    v = [(x, y), (x, y + h), (x + w, y + h), (x + w, y)]  # rect order
    if chamfer == "nw":
        verts = [(x, y + c), (x, y + h), (x + w, y + h), (x + w, y),
                 (x + c, y)]
    elif chamfer == "sw":
        verts = [(x, y), (x, y + h - c), (x + c, y + h), (x + w, y + h),
                 (x + w, y)]
    elif chamfer == "se":
        verts = [(x, y), (x, y + h), (x + w - c, y + h), (x + w, y + h - c),
                 (x + w, y)]
    else:  # ne
        verts = [(x, y), (x, y + h), (x + w, y + h), (x + w, y + c),
                 (x + w - c, y)]
    del v
    return b.room(verts, kind=kind)


# --- the level -------------------------------------------------------------

def l09() -> LevelBuilder:
    b = LevelBuilder("TESSERACT DECK", 4, "amb_drone_finale")

    # =====================================================================
    # APPROACH MESH — station fragments dissolving into the otherworld.
    # Everything sits at x <= -130; the tesseract keeps (0..1400)^2 to
    # itself, so the doorway-splitter can never renumber its authored
    # edges (its connects use explicit edge indices).
    # =====================================================================

    # --- D1: DOCK FRAGMENT (normal; dock/storage/pump) — player spawn.
    # Spawn cell A(0,0) keeps its whole north+west perimeter free: the
    # WorldStreamer's 70 u entry carve lands on a clean wall.
    A, ax, ay = _grid(b, -2700, 40, [135, 135, 135, 135], [120, 120, 120],
                      "dock")
    W1 = _bay(b, -2760, 160, 60, 120, "storage")           # west stores bay
    WJ = _bay(b, -2565, -20, 135, 60, "dock")              # mooring niche
    B, bx, by = _grid(b, -2660, 520, [110, 105, 105], [105, 105, 100],
                      "storage")
    V1 = _hall(b, [(-2500, 400), (-2500, 520)], "corridor")   # A -> B
    W2 = _bay(b, -2720, 520, 60, 105, "storage", chamfer="sw")
    W3 = _bay(b, -2160, 160, 60, 120, "dock", chamfer="ne")   # armory rack
    PU, pux, puy = _grid(b, -2260, 520, [100, 100, 100], [145, 145], "pump")
    PL = b.rect(-2340, 532, 80, 80, kind="corridor")          # B -> PU
    W4 = _bay(b, -2260, 810, 100, 60, "storage")
    WK = _bay(b, -1960, 520, 60, 145, "pump")
    # dock apron: portico cells welded full-width along A's south face
    APR = [b.rect(-2430, 400, 135, 80, kind="dock"),
           b.rect(-2295, 400, 135, 80, kind="dock")]

    # --- C1: D1 -> D2 corridor chain (bends every 2-3 cells) ---
    C1 = _hall(b, [(-2160, 100), (-1960, 100), (-1960, 365), (-1780, 365)],
               "corridor")
    N1 = _bay(b, -2080, 0, 80, 60, "generic")    # quiet niche off the chain

    # --- D2: OTHERWORLD (first whole district) ---
    O1, o1x, o1y = _grid(b, -1780, 190, [125, 125, 125, 125],
                         [117, 117, 116], "otherworld")
    W5 = _bay(b, -1840, 307, 60, 117, "otherworld")
    W6 = _bay(b, -1655, 130, 125, 60, "otherworld")
    W7 = _bay(b, -1530, 130, 125, 60, "otherworld")
    C2 = _hall(b, [(-1280, 250), (-1180, 250), (-1180, 100), (-1350, 100)],
               "otherworld", w=60, seg=90)               # crawl-register dead chain
    H3 = _hall(b, [(-1590, 540), (-1590, 610)], "otherworld")  # cul-de-sac
    # exit web: otherworld tissue hardening back into station corridor
    HC = _hall(b, [(-1355, 540), (-1355, 700), (-1235, 700), (-1235, 950),
                   (-1400, 950)], "corridor")
    for r in HC[:3]:
        b.set_kind(r, "otherworld")

    # --- D3: QUARTERS FRAGMENT (normal; quarters/medbay) ---
    Q, qx, qy = _grid(b, -1930, 760, [135, 130, 135, 130],
                      [130, 130, 125, 125], "quarters")
    # mess line: portico welded along Q's north face
    ARQ = [b.rect(-1930, 680, 135, 80, kind="quarters"),
           b.rect(-1795, 680, 130, 80, kind="quarters"),
           b.rect(-1665, 680, 135, 80, kind="quarters"),
           b.rect(-1530, 680, 130, 80, kind="quarters")]
    W8 = _bay(b, -1990, 1145, 60, 125, "quarters")   # cot bay
    WA = _bay(b, -1795, 620, 130, 60, "quarters")    # shell rack alcove
    WN = _bay(b, -1795, 1270, 130, 60, "quarters")
    C5 = _hall(b, [(-1930, 950), (-2360, 950)], "corridor")   # Q -> medbay
    # freight-hall second row: same endpoints -> identical cell bounds ->
    # pairwise exact welds along C5's south edge (160 u double-wide hall)
    C5b = _hall(b, [(-1930, 1030), (-2360, 1030)], "corridor")
    M, mx_, my_ = _grid(b, -2660, 900, [100, 100, 100], [100, 100, 90],
                        "medbay")
    ML = _hall(b, [(-2610, 830), (-2610, 900)], "corridor")   # B -> M
    WB = _bay(b, -2720, 1000, 60, 100, "medbay", chamfer="sw")

    # --- C6: D3 -> D4 corridor ---
    C6 = _hall(b, [(-1600, 1270), (-1600, 1460), (-1210, 1460)], "corridor")

    # --- D4: OTHERWORLD (second whole district) ---
    O3, o3x, o3y = _grid(b, -1210, 1160, [125, 125, 125, 125],
                         [120, 120, 120], "otherworld")
    # soft-walled gallery welded along O3's north-west face
    P3 = [b.rect(-1210, 1080, 125, 80, kind="otherworld"),
          b.rect(-1085, 1080, 125, 80, kind="otherworld")]
    O3b, obx, oby = _grid(b, -1040, 1520, [105, 100, 105], [135, 135],
                          "otherworld")   # seam-welded blob to the south
    WC = _bay(b, -1040, 1790, 105, 60, "otherworld")
    WD = _bay(b, -710, 1280, 60, 120, "otherworld", chamfer="se")
    WL = _bay(b, -1270, 1160, 60, 120, "otherworld")
    C7d = _hall(b, [(-730, 1720), (-640, 1720), (-640, 1850)],
                "otherworld", w=50, seg=90)              # ambush cul-de-sac
    C7 = _hall(b, [(-900, 1160), (-900, 1040), (-720, 1040), (-720, 940)],
               "corridor")                       # up into D5

    # --- D5: RECORDS / CHAPEL FRAGMENT (normal) ---
    R, rx, ry = _grid(b, -1150, 460, [125, 125, 125, 125],
                      [120, 120, 120, 120], "records")
    # reading portico: arcade welded along R's whole north face (the
    # Marathon move — the corridor threads THROUGH the cell fabric)
    AR = [b.rect(-1150, 380, 125, 80, kind="records"),
          b.rect(-1025, 380, 125, 80, kind="records"),
          b.rect(-900, 380, 125, 80, kind="records"),
          b.rect(-775, 380, 125, 80, kind="records")]
    WE = _bay(b, -1025, 320, 125, 60, "records")   # niches off the portico
    WF = _bay(b, -775, 320, 125, 60, "records", chamfer="ne")
    PV = b.rect(-650, 592, 80, 80, kind="corridor")   # chapel vestibule
    P, px_, py_ = _grid(b, -570, 580, [105, 100, 105], [105, 100, 105],
                        "chapel")
    # narthex: portico welded along the chapel's north face
    PP = [b.rect(-570, 500, 105, 80, kind="chapel"),
          b.rect(-465, 500, 100, 80, kind="chapel"),
          b.rect(-365, 500, 105, 80, kind="chapel")]
    WG = _bay(b, -465, 890, 100, 40, "chapel", chamfer="se", c=25.0)

    # --- C8: D5 -> D6 corridor ---
    C8 = _hall(b, [(-520, 890), (-520, 1020), (-235, 1020), (-235, 1100)],
               "corridor")

    # --- D6: OTHERWORLD (third whole district; the deck's threshold) ---
    O4, o4x, o4y = _grid(b, -660, 1100, [125, 125, 125, 125],
                         [110, 110, 110], "otherworld")
    WH = _bay(b, -535, 1430, 125, 60, "otherworld")
    WI = _bay(b, -660, 1030, 100, 70, "otherworld", chamfer="nw")
    LP = _hall(b, [(-600, 1430), (-600, 1600), (-290, 1600)],
               "otherworld", w=50, seg=90)   # crawl loop to the antechamber flank
    AL = _hall(b, [(-237, 1430), (-237, 1500)], "otherworld", w=70)  # door

    # --- ANTECHAMBER: a seventeenth chamfered cell, normal space, welded
    # chamfer-to-chamfer onto cell 0000. The construct's approach.
    ANTE = b.poly([(-290, 1500), (-290, 1700), (-90, 1700),
                   (-90, 1600), (-190, 1500)], seed=999)
    b.set_kind(ANTE, "generic")

    # =====================================================================
    # THE TESSERACT — preserved verbatim from campaign.py:l09.
    # =====================================================================
    rooms = []
    for i in range(16):
        x, y = (i % 4) * 400, (i // 4) * 400
        # cut-corner square: one sealed diagonal face per room — the only
        # solid wall on the deck, an anchor for the eye and the seam the
        # world can be entered through
        rooms.append(b.poly([(x, y), (x, y + 200), (x + 100, y + 200),
                             (x + 200, y + 100), (x + 200, y)],
                            seed=1000 + i))
        # pure-graph tier: sixteen address-bearing cells, deliberately
        # uniform (LEVEL_DESIGN_PLAYBOOK.md §8) -- not a tagging gap.
        b.set_kind(rooms[-1], "generic")
    # dims 0..3 live on edges [0,1,3,4]; edge 2 is the chamfer wall -- the
    # only wall every one of the sixteen rooms has in common, so it is
    # where every fixture in this level goes.
    DIM_EDGE = [0, 1, 3, 4]
    CHAMFER = 2
    for i in range(16):
        for d in range(4):
            j = i ^ (1 << d)
            if i < j:
                b.connect(rooms[i], DIM_EDGE[d], rooms[j], DIM_EDGE[d])

    # the seam: antechamber chamfer -> cell 0000 chamfer (both 141.4 u,
    # clean span-to-span weld). Cell 1111's chamfer stays free — that is
    # the streamer's exit-carve wall.
    b.connect_pts(ANTE, (-140, 1550), rooms[0], (150, 150))

    c15 = center(b, rooms[15])
    b.player(A[(0, 0)], center(b, A[(0, 0)]))
    # the "void key" is a Testator docent's token — the station admits no
    # one to the deep it cannot count as taught, and the token is the
    # proof-of-walk it counts (docent terminal in 1010, below).
    b.key_meta("void", "DOCENT'S TOKEN", "DESCENT APERTURE",
               "APERTURE SHUT - DOCENT'S TOKEN REQUIRED",
               "ACQUIRED: DOCENT'S TOKEN")
    b.intro("There is no deck like this on the station.\n"
            "You are not on the station anymore.\n\n"
            "Sixteen rooms. Every room borders four.\n"
            "Bleed carefully. It's the only ink you have.")
    b.terminal(rooms[5], wall_pos(b, rooms[5], CHAMFER, 0.5, 15.0),
               "SCRATCHED IN THE FLOOR\n0 1 0 1\nif you can read this,\n"
               "flip one bit at a time.\n— O.")
    b.terminal(rooms[7], wall_pos(b, rooms[7], CHAMFER, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 41%]\n"
               "welcome / student / stranger.\n"
               "this room is a lesson.\n"
               "the lesson: >>four<< is a direction.\n"
               "do not fear the direction.\n"
               "we feared it. fear did not help.")
    b.terminal(rooms[2], wall_pos(b, rooms[2], CHAMFER, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 33%]\n"
               "sixteen is not the number of rooms.\n"
               "sixteen is how many names one room accepts\n"
               "before it stops answering to the first.\n"
               "we did not choose one name each. the choosing\n"
               "was the mistake the last generation made.")
    b.terminal(rooms[10], wall_pos(b, rooms[10], CHAMFER, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 27%]\n"
               "a token waits where a student will stand.\n"
               "the aperture beneath the sixteenth name\n"
               "will not part for an untaught hand.\n"
               "carry the token. it remembers the walk\n"
               "for you.")
    b.terminal(rooms[11], wall_pos(b, rooms[11], CHAMFER, 0.5, 15.0),
               "CARGO TAG, MIRIAD STOCK NUMBER — FOUND HERE,\n"
               "HALF BURIED\n"
               "Contents: 2x fertilizer drum.\n"
               "This tag belongs four levels back, in a\n"
               "storeroom that grows food. There is no food\n"
               "here. There was no floor here, on any schematic,\n"
               "before today.\n"
               "Nobody has come to collect it.")
    squad(b, rooms[3], "husk husk")
    squad(b, rooms[5], "spitter spitter")
    squad(b, rooms[6], "brute")
    squad(b, rooms[9], "shrieker mite mite")
    squad(b, rooms[10], "husk spitter")
    squad(b, rooms[12], "brute shrieker")
    squad(b, rooms[15], "brute brute")
    cache(b, rooms[4], "ammo_9mm ammo_shell", wall=CHAMFER)
    cache(b, rooms[8], "medkit ammo_cell portable_hole", wall=CHAMFER)
    cache(b, rooms[7], "ammo_shell ammo_9mm medkit", wall=CHAMFER)
    cache(b, rooms[13], "ammo_cell ammo_shell", wall=CHAMFER)
    cache(b, rooms[6], "medkit", wall=CHAMFER)
    cache(b, rooms[12], "medkit", wall=CHAMFER)
    c10 = center(b, rooms[10])
    b.entity(rooms[10], "key_void", (c10[0] - 60, c10[1]))
    b.exit(rooms[15], (c15[0] + 60, c15[1]), key="void")

    # =====================================================================
    # MESH ENTITIES — modest growth per LEVEL_DESIGN_PLAYBOOK.md pacing;
    # otherworld cells stay ambush tissue (enemies only, no mechanisms).
    # =====================================================================
    # D1 — arrival, light contact, quartermaster shelves. The smg lies in
    # the freight corridor's walking line (playbook §5.1: threshold
    # placement is the difference between ~50% and ~100% pickup) — dropped
    # by whoever walked in before; its rack ammo stayed in the armory bay.
    squad(b, A[(2, 1)], "husk")
    squad(b, PU[(1, 1)], "mite mite")
    cache(b, W1, "ammo_9mm medkit", wall=0)
    cache(b, WJ, "ammo_9mm", wall=3)
    b.entity(V1[0], "weapon_smg", center(b, V1[0]))
    cache(b, W3, "ammo_9mm ammo_9mm", wall=2)              # armory rack
    # D2 — first otherworld: small fast things in the soft dark
    squad(b, O1[(1, 0)], "mite mite mite")
    squad(b, O1[(2, 1)], "husk husk")
    squad(b, C2[-1], "spitter")            # crawl cul-de-sac ambush
    squad(b, H3[-1], "husk")
    # D3 — quarters fragment
    squad(b, Q[(1, 1)], "husk husk")
    squad(b, Q[(2, 0)], "spitter")
    squad(b, M[(1, 1)], "spitter")
    cache(b, Q[(0, 0)], "ammo_9mm ammo_9mm", wall=3)
    cache(b, WA, "ammo_shell ammo_shell", wall=3)
    cache(b, WN, "medkit", wall=1)
    cache(b, M[(0, 0)], "medkit medkit", wall=0)
    # the shotgun fell where its bearer did: mid-corridor, on the walk to
    # the deep district (threshold line — the bot and the player both
    # cross this cell's center)
    b.entity(C6[0], "weapon_shotgun", center(b, C6[0]))
    # D4 — second otherworld
    squad(b, O3[(1, 0)], "shrieker mite mite")
    squad(b, O3b[(1, 1)], "husk husk")
    squad(b, C7d[-1], "mite mite")
    # D5 — records/chapel fragment
    squad(b, R[(1, 1)], "spitter spitter")
    squad(b, P[(1, 1)], "brute")
    cache(b, R[(0, 2)], "ammo_shell ammo_9mm", wall=0)
    cache(b, WE, "ammo_9mm", wall=3)
    cache(b, P[(2, 0)], "medkit ammo_cell", wall=2)
    # D6 — threshold otherworld + the antechamber guard
    squad(b, O4[(1, 0)], "husk spitter")
    squad(b, O4[(0, 1)], "husk")
    squad(b, ANTE, "brute")
    cache(b, ANTE, "medkit ammo_9mm ammo_cell", off=(0.0, 70.0))

    # geometry-only references (bays/halls/grid coords), kept for clarity
    _ = (PL, PV, W2, W4, W5, W6, W7, W8, WB, WC, WD, WF, WG, WH,
         WI, WK, WL, C1, C5, C5b, C7, C8, HC, ML, N1, LP, AL, B, APR,
         ARQ, AR, P3, PP,
         ax, ay, bx, by, pux, puy, o1x, o1y, o3x, o3y, obx, oby,
         rx, ry, px_, py_, mx_, my_, qx, qy, o4x, o4y)
    return b


def build() -> dict:
    """Resolved level dict, compatible with campaign.py's save flow:
    save_level(build(), path)."""
    return l09().to_dict()


if __name__ == "__main__":
    bb = l09()
    d = bb.to_dict()
    print(f"rooms={len(d['rooms'])} connects={len(d['connects'])} "
          f"doors={len(d['doors'])}")
