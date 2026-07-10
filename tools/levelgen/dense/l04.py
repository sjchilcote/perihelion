"""L4 — THE LONG GALLERY, rebuilt at Marathon density (standalone module).

Same level, finer cells: the paradox construct — two parallel service
corridors crossed by four connectors of which crossing one is blank-walled
from the north ("4 GOING 3 BACK") — keeps its exact topology: from the
south gallery four crossing mouths open; from the north gallery only
three.  Everything diegetic from tools/levelgen/campaign.py:l04() survives
verbatim: name/tier/ambience, all five terminals, the surgeon's-cardkey
key_meta, the blue quarantine-bolt door into the vault, the implant, the
radio script, spawn and exit.

Around that skeleton the geometry is re-authored per
MARATHON_LEVEL_STANDARDS.md: the galleries are chains of ~90 u corridor
cells, the crossings are 4-cell chains, and four kind-coherent districts
hang off the spine — a dock block at the west entry, a medical wing
(medbay/quarters/records/pump) south, a records/archive annex with its
chapel southeast, and a two-storey service deck (pump/storage/lab) north —
each built from touching rects so the doorway-splitter/autoconnect welds
the mesh (~122 cells, three width registers: 40-60 u slots, 70-90 u doors,
150-200 u seams; ~10 % dead-end alcoves).

Usage mirrors campaign.py's save flow exactly (l04() signature contract):

    from dense.l04 import build
    b = build()                     # a LevelBuilder, like campaign.l04()
    save_level(b.to_dict(), path)   # b.build() validates winding/schema
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402


# --- placement helpers (same conventions as tools/levelgen/campaign.py) ---

def center(b: LevelBuilder, room: int) -> tuple[float, float]:
    vs = b.data["rooms"][room]["verts"]
    return (sum(v[0] for v in vs) / len(vs), sum(v[1] for v in vs) / len(vs))


def squad(b: LevelBuilder, room: int, spec: str, spread: float = 26.0):
    kinds = spec.split()
    cx, cy = center(b, room)
    n = len(kinds)
    for i, k in enumerate(kinds):
        a = 2 * math.pi * i / max(1, n) + 0.7
        r = spread if n > 1 else 0.0
        b.entity(room, k, (cx + r * math.cos(a), cy + r * math.sin(a)))


def wall_basis(b: LevelBuilder, room: int, wall: int, t: float = 0.5):
    """Point/tangent/inward-normal on AUTHORED edge `wall` of `room`
    (0=west,1=south,2=east,3=north for LevelBuilder.rect)."""
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


# --------------------------------------------------------------------------
# Gallery segmentation: seams chosen so every crossing mouth (80-150,
# 260-330, 440-510, 620-690), every district ante and every alcove lands
# INSIDE a single segment wall (the doorway-splitter needs containment).
# --------------------------------------------------------------------------

SEAMS = [0, 70, 165, 250, 340, 430, 520, 610, 700, 760]
CROSS_X = [80, 260, 440, 620]  # 70 u wide, y 0..200 (north of south gallery)


def build() -> LevelBuilder:
    b = LevelBuilder("THE LONG GALLERY", 2, "amb_drone_mid")

    # --- the construct: two gallery chains + four 3-cell crossings -------
    ssegs = [b.rect(x0, 200, x1 - x0, 110, kind="corridor")
             for x0, x1 in zip(SEAMS, SEAMS[1:])]
    nsegs = [b.rect(x0, -110, x1 - x0, 110, kind="corridor")
             for x0, x1 in zip(SEAMS, SEAMS[1:])]
    cross = []  # 4-cell chains, index 0 abuts the north gallery, 3 the south
    for cx in CROSS_X:
        cross.append(tuple(b.rect(cx, 50 * i, 70, 50, kind="corridor")
                           for i in range(4)))
    # crossing one opens south only: its north mouth is a blank wall.
    # (PARADOX TOPOLOGY — four mouths on the south wall, three on the north.)
    b.no_connect(cross[0][0], nsegs[1])

    # gallery niches (slot register, 40-60 u)
    alc_s1 = b.rect(90, 310, 60, 50, kind="storage")     # cache niche
    b.rect(455, 310, 60, 50, kind="storage")             # empty niche
    b.rect(170, 150, 60, 50, kind="corridor")            # inter-gallery void niches
    b.rect(545, 150, 60, 50, kind="corridor")
    b.rect(25, 0, 45, 50, kind="corridor")
    b.rect(350, 0, 60, 50, kind="corridor")
    b.rect(525, 0, 60, 50, kind="corridor")
    alc_n = b.rect(712, -140, 46, 30, kind="storage")    # north-gallery niche

    # --- west entry: dock block (streamer carves the spawn cell's free
    # west wall — keep it blank) ------------------------------------------
    spawn = b.rect(-160, 200, 90, 110, kind="corridor")
    cell2 = b.rect(-70, 200, 70, 110, kind="corridor")   # gallery entrance
    guard = b.rect(-160, 90, 90, 110, kind="storage")
    lockers = b.rect(-70, 120, 70, 80, kind="storage")
    b.no_connect(lockers, cell2)   # keep cell2's north wall solid (notice)
    dock1 = b.rect(-160, 0, 90, 90, kind="dock")
    dock2 = b.rect(-70, 0, 90, 90, kind="dock")
    dock3 = b.rect(-160, -90, 90, 90, kind="dock")
    dock4 = b.rect(-70, -90, 70, 90, kind="dock")
    # the dock backs onto the north gallery wall; it does NOT open into it —
    # the only ways north are the crossings (the construct depends on it)
    b.no_connect(dock4, nsegs[0])
    dw1 = b.rect(-240, 0, 80, 90, kind="dock")
    b.rect(-240, -90, 80, 90, kind="dock")               # dw2 (welds dw1/dock3)
    b.rect(-220, 120, 60, 60, kind="storage")            # guardpost alcove
    b.rect(-70, 310, 70, 80, kind="storage")             # sump under cell2
    bunk = b.rect(-160, 310, 90, 80, kind="quarters")    # watch bunks

    # --- south: medical wing (the relocated medbay + crew rows) ----------
    ante = b.rect(345, 310, 80, 90, kind="corridor")
    rel_t = b.rect(280, 400, 200, 75, kind="medbay")     # reliquary, north half
    rel_b = b.rect(280, 475, 200, 75, kind="medbay")     # reliquary, south half
    morgue = b.rect(480, 400, 90, 75, kind="medbay")
    b.rect(480, 475, 55, 60, kind="medbay")              # cold store (chains
    rec1 = b.rect(280, 550, 85, 80, kind="records")      # morgue->niche below)
    rec2 = b.rect(395, 550, 80, 80, kind="records")
    b.rect(395, 630, 80, 70, kind="records")             # rec stack overflow
    # crew rows: a ward corridor (col x=200) with bunk rooms hanging west
    q = {}
    for r, (y, h) in enumerate(((400, 75), (475, 75), (550, 80))):
        for c, x in enumerate((40, 120, 200)):
            q[(c, r)] = b.rect(x, y, 80, h, kind="quarters")
    boil = [b.rect(x, 630, 80, 80, kind="pump") for x in (40, 120, 200)]
    b.rect(-20, 415, 60, 45, kind="quarters")            # bunk niche
    alc_b = b.rect(280, 645, 50, 50, kind="pump")        # boiler valve niche
    # shape the block: the ward corridor (col x=200) and a west walk (col
    # x=40) run vertically; the middle column is bunk rooms opening east
    b.no_connect(q[(2, 1)], rel_b)      # one reliquary door, not two
    b.no_connect(q[(1, 2)], boil[1])    # boiler keeps two doors, not three

    # --- southeast: archive (records) with the chapel off it -------------
    ante2 = b.rect(615, 310, 80, 90, kind="corridor")
    a1 = b.rect(615, 400, 80, 100, kind="records")
    a2 = b.rect(615, 500, 80, 100, kind="records")
    b2r = b.rect(535, 500, 80, 100, kind="records")
    b.rect(695, 400, 60, 100, kind="records")            # c1r (welds a1)
    b.rect(695, 500, 60, 100, kind="records")            # c2r (welds a2/c1r)
    chapel = b.rect(615, 600, 80, 90, kind="chapel")
    b3r = b.rect(535, 600, 80, 90, kind="storage")
    c3r = b.rect(695, 600, 60, 90, kind="storage")
    b.rect(535, 690, 80, 80, kind="storage")             # undercroft (b3r)
    b.rect(615, 690, 80, 80, kind="storage")             # undercroft (chapel)
    niche_arch = b.rect(480, 535, 55, 60, kind="storage")

    # --- north: service deck (two storeys of pump/storage over the
    # gallery, reached by two stair connectors) ---------------------------
    sp = [b.rect(80 + 90 * i, -220, 90, 80, kind="transit") for i in range(7)]
    ext = b.rect(710, -220, 90, 80, kind="transit")
    b.rect(85, -140, 80, 30, kind="corridor")            # stair A (nsegs[1])
    b.rect(620, -140, 80, 30, kind="corridor")           # stair B (nsegs[7])
    b.no_connect(alc_n, ext)            # the niche stays a niche
    rowA_kinds = ("quarters", "pump", "pump", "transit",
                  "storage", "storage", "storage", "pump")
    A = [b.rect(80 + 90 * i, -320, 90, 100, kind=k)
         for i, k in enumerate(rowA_kinds)]
    B = [b.rect(80 + 90 * i, -420, 90, 100, kind=k)
         for i, k in enumerate(rowA_kinds)]
    C = [b.rect(80 + 90 * i, -520, 90, 100, kind="corridor") for i in range(7)]
    D = [b.rect(260, -620, 90, 100, kind="lab"),
         b.rect(350, -620, 90, 100, kind="lab"),
         b.rect(440, -620, 90, 100, kind="lab")]
    b.rect(710, -520, 90, 100, kind="storage")           # deck loop (E2)
    b.rect(20, -205, 60, 55, kind="storage")             # spine-west alcove
    b.poly([(800, -210), (800, -150), (860, -150),      # chamfered store
            (860, -190), (840, -210)])
    b.set_kind(len(b.data["rooms"]) - 1, "storage")
    b.rect(530, -600, 60, 60, kind="lab")                # lab-east alcove
    # shape the deck: W bunks, P pump hall (2x2), J junction, S store (3x2),
    # E pump room via the spine extension; C is a service run, D the lab.
    b.no_connect(sp[6], A[6])
    b.no_connect(C[2], B[2])
    b.no_connect(C[4], B[4])
    b.no_connect(C[5], B[5])
    b.no_connect(D[2], C[4])

    # --- east: the vault (unchanged mechanism) ---------------------------
    vault_w = b.rect(760, 310, 85, 150, kind="storage")
    vault_e = b.rect(845, 310, 85, 150, kind="storage")
    b.door_pts(ssegs[8], (760, 255), vault_w, (760, 385), "blue")
    b.no_connect(ssegs[8], vault_w)
    # the "blue key" is the attending surgeon's cardkey, dropped on gallery
    # rounds and lying in the crossing that isn't there from the north; the
    # vault holding the retained implant sits behind a quarantine bolt that
    # releases to that cardkey only (medbay terminal, below).
    b.key_meta("blue", "SURGEON'S CARDKEY", "QUARANTINE BOLT",
               "BOLT ENGAGED - SURGEON'S CARDKEY REQUIRED",
               "ACQUIRED: SURGEON'S CARDKEY")

    # --- lore (verbatim from campaign.py:l04) -----------------------------
    b.player(spawn, (-115, 255))
    b.intro("The Long Gallery. Two service corridors,\n"
            "four crossings. Everyone agrees on that.\n"
            "Everyone who walked it southside.")
    b.terminal(ssegs[8], wall_pos(b, ssegs[8], 1, 0.5, 15.0),
               "GRAFFITI, scratched into the panel:\n"
               "4 GOING  3 BACK\n4 GOING  3 BACK\n4 GOING  3 BACK\n"
               "over and over, forty times.")
    b.terminal(rel_b, wall_pos(b, rel_b, 1, 0.5, 15.0),
               "MEDICAL BAY (RELOCATED)\nPatient: unnamed, found in Gallery.\n"
               "Implant of unknown design fused to left arm.\n"
               "Patient states the implant 'came through the wall.'\n"
               "Patient discharged. Implant retained: vault,\n"
               "quarantine bolt thrown, release on the\n"
               "attending's cardkey only.\n"
               "Addendum: attending reports the cardkey lost on\n"
               "gallery rounds. Search of all four crossings\n"
               "found three.")
    b.terminal(cell2, wall_pos(b, cell2, 3, 0.5, 15.0),
               "POSTED NOTICE, GALLERY ENTRANCE\n"
               "GALLERY CLOSED PENDING STRUCTURAL REVIEW.\n"
               "[handwritten beneath, several different hands]\n"
               "— review complete, corridor safe, opening today.\n"
               "— then why does it still say four on the\n"
               "  manifest and I count three.\n"
               "— because you walked it the way everyone walks\n"
               "  it. Try backward.\n"
               "— did. still three. still four. going to log it\n"
               "  and go get lunch.")
    b.terminal(cross[3][1], wall_pos(b, cross[3][1], 0, 0.5, 15.0),
               "BREAK LOG, CROSSING FOUR\n"
               "Nothing to report. Nothing to report. Nothing to\n"
               "report. Relief crew: bring cards.\n"
               "[later, different hand]\n"
               "Something to report. See crossing one. Do not\n"
               "linger here either, just in case whatever's wrong\n"
               "with one isn't done counting.")
    b.terminal(nsegs[4], wall_pos(b, nsegs[4], 3, 0.5, 15.0),
               "STRUCTURAL NOTE, GALLERY MIDPOINT\n"
               "Four load-bearing crossings, per the original\n"
               "drawings. Fieldwork confirms three, walking\n"
               "north.\n"
               "Recommendation: trust the drawings; they were\n"
               "made before anyone walked it drunk on double\n"
               "shifts.\n"
               "Second recommendation, struck through but still\n"
               "legible: the walking is probably right. Filed\n"
               "under morale. Moving on.")

    # --- population (original roster + modest district squads) -----------
    squad(b, ssegs[4], "husk husk mite mite")
    squad(b, cross[1][1], "shrieker")
    squad(b, cross[2][1], "husk husk husk")
    squad(b, nsegs[4], "spitter spitter brute")
    squad(b, rel_t, "husk husk spitter")
    squad(b, guard, "mite mite")
    squad(b, A[1], "husk husk")            # pump hall
    squad(b, B[5], "spitter husk")         # storage hall
    squad(b, a2, "husk husk")              # archive
    squad(b, q[(1, 1)], "mite mite")       # crew rows
    squad(b, D[1], "shrieker")             # the lab
    # the lost cardkey lies in the crossing that doesn't exist from the
    # north side — where the gallery's missing things end up
    b.entity(cross[0][1], "key_blue", (115, 60))
    cache(b, cross[0][0], "ammo_shell medkit", wall=3)  # the blank north wall
    cache(b, nsegs[6], "ammo_9mm ammo_9mm medkit", wall=3)
    cache(b, alc_s1, "ammo_shell", wall=1)
    cache(b, B[0], "medkit", wall=0)
    cache(b, D[2], "ammo_9mm", wall=1)
    cache(b, niche_arch, "ammo_9mm medkit", wall=1)
    cache(b, boil[1], "ammo_shell", wall=1)
    cache(b, q[(0, 2)], "medkit", wall=0)
    # the west-entry/east-exit line runs straight through vault center at
    # y=385 -- every route from the blue door to the exit pad crosses it.
    # unique reward at the vault's entry threshold (playbook §5.1)
    b.entity(vault_w, "implant_lightning", (776, 385))
    b.entity(vault_w, "medkit", (792, 368))
    b.entity(vault_w, "ammo_9mm", (792, 402))
    b.exit(vault_e, (890, 385))
    return b


if __name__ == "__main__":
    bb = build()
    lvl = bb.build()
    d = bb.to_dict()
    print(f"rooms={len(lvl.room_verts)} connects={len(lvl.connects)} "
          f"doors={len(lvl.doors)} entities={len(lvl.entities)}")
