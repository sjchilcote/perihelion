"""L03 — HYDROPONICS TORUS, rebuilt to Marathon density (standalone module).

The sacred core of campaign.py's l03() survives verbatim: the six-sector
half-ring with its mobius glue (ring[5] end face welded to ring[0] start
face — the paradox construct, LEVEL_DESIGN_PLAYBOOK.md §11), the entry
poly, the seed garden behind the blue (scrubber-cartridge) airlock, the
storeroom detour, every terminal text, every radio trigger, the key_meta,
the namesake shotgun at ring[0]'s threshold, and the exit pad in the
garden. Their room indices are identical to campaign.py's (ring 0-5,
entry 6, garden 7, storeroom 8) because the core is built first, in the
same order.

Around that skeleton this module authors the approach the station always
implied but never drew, as a cell mesh per MARATHON_LEVEL_STANDARDS.md:
~120 cells, median ~90x90 u, corridor chains that bend every 2-3 cells,
chambers as welded rect grids (the doorway-splitter's exact-coincidence
autoconnect is the subdivision tool), ~12% dead-end alcoves, three width
registers (80 u contained doors, full-cell seams, 50-60 u slots).

Districts (kinds assigned coherently so the mesh reads as place):
  A (east)  — transit dock (spawn) -> service corridors -> storage hall,
              medbay annex, pump plant, lab bench galleries, quarters.
  C (west)  — records annex + the maintenance drop that reaches the
              storeroom from behind (a loop, not a shortcut: the mobius
              glue remains the fast way round the ring).
  B (far W) — drum stores, records hall, secondary pump room past the
              storeroom (the inventory the storeroom terminal argues with).

Streaming: the spawn cell (dock NE) keeps two free 110 u walls; the garden
keeps its whole 166 u south wall free for the exit-side carve.

No otherworld cells: tier-2 level (the otherworld starts at l07).

Usage:
    import l03 as dense_l03           # with tools/levelgen/dense on path
    save_level(dense_l03.build(), "levels/l03.json")

`l03()` mirrors campaign.py's l03() contract exactly: no args, returns the
LevelBuilder. `build()` returns the resolved dict save_level expects.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

_REPO = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(_REPO / "game"))
sys.path.insert(0, str(_REPO / "tools" / "levelgen"))

from perihelion.levels import LevelBuilder  # noqa: E402

from campaign import arc_mid, cache, sector_ring, squad, wall_pos  # noqa: E402


def _grid(b: LevelBuilder, x0: float, y0: float, nx: int, ny: int,
          cw: float, ch: float, kind: str) -> list[list[int]]:
    """ny rows x nx cols of touching rect cells; interior seams weld by
    exact coincidence in resolve(). rows[j][i]: j grows toward +y."""
    return [[b.rect(x0 + i * cw, y0 + j * ch, cw, ch, kind=kind)
             for i in range(nx)] for j in range(ny)]


def _chain(b: LevelBuilder, x: float, y: float, w: float, h: float,
           n: int, kind: str = "corridor") -> list[int]:
    """A corridor RUN as n chained cells along its long axis (rule 3 of
    MARATHON_LEVEL_STANDARDS.md: a corridor is a chain, not a rectangle).
    Cells share exact full edges, so autoconnect welds the chain."""
    cells = []
    if w >= h:
        cw = w / n
        for i in range(n):
            cells.append(b.rect(x + i * cw, y, cw, h, kind=kind))
    else:
        ch = h / n
        for i in range(n):
            cells.append(b.rect(x, y + i * ch, w, ch, kind=kind))
    return cells


def l03() -> LevelBuilder:
    b = LevelBuilder("HYDROPONICS TORUS", 2, "amb_drone_mid")

    # ------------------------------------------------------------------
    # SACRED CORE — verbatim from campaign.py l03(); indices 0..8.
    # ------------------------------------------------------------------
    ring = sector_ring(b, 0, 0, 180, 320, 6,
                       math.radians(-90), math.radians(90))
    for r in ring:
        b.set_kind(r, "hydro")   # hydroponics benches, the ring's own function
    # entry room sized to the outer chord (165.6) to keep portals rigid
    entry = b.poly([(-83, -440), (-83, -320), (83, -320), (83, -440)])
    b.set_kind(entry, "corridor")
    garden = b.rect(400, -80, 166, 160, kind="hydro")
    storeroom = b.rect(-420, 40, 166, 140, kind="storage")

    b.connect_pts(entry, (0, -320), ring[0],
                  arc_mid(0, 0, 320, math.radians(-75)))
    # the mobius glue: end face to start face
    b.connect_pts(ring[5], arc_mid(0, 0, 250, math.radians(90)),
                  ring[0], arc_mid(0, 0, 250, math.radians(-90)))
    b.door_pts(ring[2], arc_mid(0, 0, 320, math.radians(-15)),
               garden, (400, 0), "blue")
    b.connect_pts(ring[3], arc_mid(0, 0, 320, math.radians(15)),
                  storeroom, (-254, 110))
    # the "blue key" is a fresh air-scrubber cartridge off the end-cap
    # environmentals rack; the seed garden's airlock refuses to cycle on a
    # spent scrubber (entry-procedure terminal at the door, below).
    b.key_meta("blue", "SCRUBBER CARTRIDGE", "GARDEN AIRLOCK",
               "AIRLOCK INERT - SCRUBBER CARTRIDGE REQUIRED",
               "ACQUIRED: SCRUBBER CARTRIDGE")

    # ------------------------------------------------------------------
    # DISTRICT A — the eastern approach: dock -> service net -> entry.
    # Spine gallery along the entry band (y -425..-345, register 80);
    # every run is a chain of ~45-53 u cells (three width registers:
    # 80 u contained doors, full-cell seams, one 50-60 u slot).
    # ------------------------------------------------------------------
    p1 = _chain(b, 83, -425, 90, 80, 2)      # welds into entry E wall
    p2 = _chain(b, 173, -425, 90, 80, 2)
    p3 = _chain(b, 263, -425, 90, 80, 2)
    p4 = _chain(b, 353, -425, 90, 80, 2)
    ja = b.rect(443, -425, 90, 80, kind="transit")     # spine junction
    p5 = _chain(b, 533, -425, 90, 80, 2)
    p6 = _chain(b, 623, -425, 90, 80, 2)

    # lab annex: a 3x3 chamber cluster opening south onto the whole spine.
    # Sight-line break: sever the center cell's N/S interior seams (it
    # keeps its E/W seams, so the grid stays fully connected via the
    # middle row) -- this cluster sits right on the spine approach a 30 s
    # AggroBot walk actually samples, and a fully-open 3x3 grid welded onto
    # an already-open spine is a real contributor to this level's measured
    # over-flood (med 18, target 8-16).
    ch2 = _grid(b, 173, -695, 3, 3, 90, 90, "lab")
    b.no_connect(ch2[1][1], ch2[0][1])
    b.no_connect(ch2[1][1], ch2[2][1])
    # dead-end tool alcove off the annex's north face (chamfered)
    alc_ch2 = b.poly([(283, -755), (323, -755), (343, -735),
                      (343, -695), (283, -695)])
    b.set_kind(alc_ch2, "storage")

    # bench galleries: five bays hanging south off the spine
    g = [b.rect(263 + 90 * k, -345, 90, 90, kind="lab") for k in range(5)]
    for k in range(4):
        b.no_connect(g[k], g[k + 1])   # each bay is its own dead end
    # (g[4] stays open into the pump plant's SW cell — the one crawl-through)

    # north riser off the spine junction
    nb1 = b.rect(448, -505, 80, 80, kind="corridor")
    nb2 = b.rect(448, -585, 80, 80, kind="corridor")
    jb = b.rect(448, -675, 90, 90, kind="transit")

    # medbay annex north of jb (the botany clinic)
    nn = _chain(b, 458, -855, 80, 180, 4)
    nn_niche = b.rect(538, -855, 80, 85, kind="medbay")  # gurney bay
    ch11 = _grid(b, 368, -1035, 3, 2, 90, 90, "medbay")
    alc_ch11 = b.rect(308, -1020, 60, 60, kind="medbay")

    # east run to the mid junction, with a bench gallery running beside it
    y3 = _chain(b, 538, -670, 270, 80, 6)
    y3g = _grid(b, 538, -770, 2, 1, 90, 100, "lab")[0]   # parallel gallery
    # the gallery reaches the clinic riser through the gurney bay only;
    # the riser's own east wall stays a wall (keeps the gallery cell a
    # gallery, not a five-way hub)
    b.no_connect(nn[2], y3g[0])
    b.no_connect(nn[3], y3g[0])
    jc = b.rect(808, -680, 100, 100, kind="transit")

    # storage hall north of jc, staging lane beside the riser
    nc = _chain(b, 818, -860, 80, 180, 4)
    ncg = _grid(b, 738, -860, 1, 2, 80, 90, "storage")   # staging cells
    ch3 = _grid(b, 718, -1060, 3, 2, 100, 100, "storage")
    alc_ch3 = b.rect(848, -1120, 60, 60, kind="storage")
    slot = b.rect(1018, -1030, 50, 60, kind="corridor")  # 60 u crawl slot

    # east to the dock junction, widened by a south gallery
    ec = _chain(b, 908, -670, 180, 80, 4)
    ecg = _grid(b, 908, -590, 2, 1, 90, 80, "corridor")[0]
    jd = b.rect(1088, -680, 100, 100, kind="transit")

    # dock (spawn) at the far east end
    ed = _chain(b, 1188, -670, 180, 80, 4)
    dock = _grid(b, 1368, -690, 2, 2, 110, 110, "dock")

    # quarters block south of jd (botanist bunks — the quiet beat)
    sd = _chain(b, 1103, -580, 80, 180, 4)
    ch4 = _grid(b, 1073, -400, 2, 2, 110, 110, "quarters")
    alc_ch4 = b.poly([(1293, -280), (1333, -280), (1353, -260),
                      (1353, -220), (1293, -220)])
    b.set_kind(alc_ch4, "quarters")

    # service loop: storage hall east face -> down -> back to the dock run
    jec = _chain(b, 1018, -950, 180, 80, 4)
    je = b.poly([(1198, -960), (1273, -960), (1298, -935),
                 (1298, -860), (1198, -860)])
    b.set_kind(je, "transit")
    jes = _chain(b, 1198, -860, 80, 90, 2) + _chain(b, 1198, -770, 80, 100, 2)

    # pump plant east of the spine's end (nutrient feed)
    ch6 = _grid(b, 713, -445, 2, 2, 100, 100, "pump")
    alc_ch6 = b.poly([(913, -415), (973, -415), (973, -375),
                      (953, -355), (913, -355)])
    b.set_kind(alc_ch6, "storage")

    # ------------------------------------------------------------------
    # DISTRICT C — west of the entry: records annex + maintenance drop
    # that reaches the storeroom from behind (loop; ring stays fastest).
    # ------------------------------------------------------------------
    c = _chain(b, -370, -425, 287, 80, 6)   # welds into entry W wall
    cg = _grid(b, -370, -505, 3, 1, 287.0 / 3.0, 80, "records")[0]
    jw = b.rect(-490, -435, 120, 100, kind="transit")
    rec1 = b.rect(-650, -435, 80, 100, kind="records")
    rec2 = b.rect(-570, -435, 80, 100, kind="records")
    sc = _chain(b, -450, -335, 80, 180, 4)
    scg = _grid(b, -370, -335, 1, 2, 80, 90, "storage")  # shelving lane
    jsc = b.poly([(-450, -155), (-365, -155), (-340, -130),
                  (-340, -65), (-450, -65)])
    b.set_kind(jsc, "transit")
    sc3 = _chain(b, -420, -65, 80, 105, 2)  # welds into storeroom N
    alc_jsc = b.rect(-510, -145, 60, 60, kind="storage")

    # ------------------------------------------------------------------
    # DISTRICT B — past the storeroom's west wall: the drum stores the
    # inventory terminal argues with, a records hall, a second pump room.
    # ------------------------------------------------------------------
    yb = _chain(b, -600, 70, 180, 80, 4)     # welds into storeroom W
    ybg = _grid(b, -600, 150, 2, 1, 90, 80, "storage")[0]  # pallet lane
    jb2 = b.rect(-710, 60, 110, 100, kind="transit")
    ch8 = _grid(b, -930, 50, 2, 2, 110, 110, "storage")
    alc_ch8 = b.poly([(-990, 80), (-930, 80), (-930, 140),
                      (-970, 140), (-990, 120)])
    b.set_kind(alc_ch8, "storage")
    bs12 = _chain(b, -690, 160, 80, 180, 4)
    jb3 = b.rect(-700, 340, 100, 100, kind="transit")
    be = _chain(b, -600, 355, 270, 80, 6)
    beg = _grid(b, -600, 435, 3, 1, 90, 80, "records")[0]  # reading gallery
    ch7 = _grid(b, -330, 345, 3, 2, 90, 90, "records")
    alc_ch7 = b.rect(-235, 285, 60, 60, kind="records")
    bs34 = _chain(b, -690, 440, 80, 180, 4)
    ch10 = _grid(b, -790, 620, 2, 2, 100, 100, "pump")
    alc_ch10 = b.rect(-590, 640, 60, 60, kind="pump")

    # ------------------------------------------------------------------
    # SPAWN — the dock's NE berth (two free 110 u walls for the streamer).
    # ------------------------------------------------------------------
    b.player(dock[0][1], (1533, -635))

    # ------------------------------------------------------------------
    # LORE — verbatim from campaign.py l03().
    # ------------------------------------------------------------------
    b.intro("Hydroponics. The torus keeps the greens\nalive. The greens are dying in a spiral.")
    b.terminal(garden, wall_pos(b, garden, 2, 0.5, 15.0),
               "BOTANY NOTE\nThe cucumbers grow clockwise here.\n"
               "In the seed manual they grow counterclockwise.\n"
               "Same seeds. Same water.\nI stopped writing this up.")
    b.terminal(storeroom, wall_pos(b, storeroom, 1, 0.5, 15.0),
               "INVENTORY\n2x fertilizer drum — MISSING.\n"
               "Found both drums in the room I was standing in.\n"
               "Behind me. I had checked behind me.")
    b.terminal(ring[1], tuple(arc_mid(0, 0, 195, math.radians(-45))),
               "DIRECTIVE 0007 — MIRIAD PRIME\n"
               "RE: survey of gravitational anomaly, Site One\n"
               "\n"
               "RETRIEVAL SUPERSEDES SURVEY.\n"
               "\n"
               "[appended, local, unsigned]\n"
               "Four months of careful science, inverted overnight\n"
               "by three words. We cut the aperture Tuesday.\n"
               "God help whoever reads this log in order.")
    b.terminal(ring[4], tuple(arc_mid(0, 0, 195, math.radians(35))),
               "FEEDER SCHEDULE, SECTOR 5\n"
               "0400 nutrient, 0900 mist, 1400 nutrient,\n"
               "1900 mist, 0000 dark cycle.\n"
               "The dying trays spiral inward, sunwise.\n"
               "The healthy trays spiral the other way.\n"
               "Botany says plants do not have a 'way'.")
    b.terminal(entry, wall_pos(b, entry, 3, 0.5, 15.0),
               "SURVEY LOG — WEEK SIXTEEN\n"
               "Nutrient uptake within tolerance. Torus rotation\n"
               "nominal. Site One's gravitational signature\n"
               "remains the whole of this posting's interest, and\n"
               "it has not changed in sixteen weeks.\n"
               "Request denied: additional survey time. Reason\n"
               "given: 'the anomaly does not need more looking\n"
               "at. It needs a name.' We have not been told what\n"
               "name.")
    b.terminal(ring[0], wall_pos(b, ring[0], 0, 0.5, 15.0),
               "BENCH TAG, SECTOR ONE\n"
               "Control group. No treatment applied. For\n"
               "comparison only. Yield tracked weekly, entered by\n"
               "hand because the automatic logger keeps entering\n"
               "yields for a sector two rows over. Someone keeps\n"
               "correcting the logger. The correction keeps\n"
               "needing to happen again.")
    b.terminal(ring[2], tuple(arc_mid(0, 0, 294, math.radians(-15))),
               "GARDEN AIRLOCK — ENTRY PROCEDURE\n"
               "The lock will not cycle on a spent scrubber.\n"
               "Fresh cartridges are racked at the end cap,\n"
               "sector six, past the feeders. Slot the\n"
               "cartridge, wait for the green, return the spent\n"
               "unit to the rack. Do not prop the inner door.\n"
               "Not after last time.")
    b.terminal(ring[3], wall_pos(b, ring[3], 0, 0.5, 15.0),
               "SHIPPING TAG, ZIP-TIED TO A FERTILIZER DRUM\n"
               "Contents: fertilizer, 1 of 2.\n"
               "Second tag, zip-tied to the same drum, underneath\n"
               "the first:\n"
               "Contents: fertilizer, 1 of 2.\n"
               "Both tags are dated the same day. Neither one is\n"
               "wrong.")

    # ------------------------------------------------------------------
    # ROSTER — the core squads verbatim, plus a modest approach garrison
    # paced per LEVEL_DESIGN_PLAYBOOK.md (quiet dock, contested middle).
    # ------------------------------------------------------------------
    squad(b, ring[1], "husk husk")
    squad(b, ring[2], "mite mite mite husk")
    squad(b, ring[4], "spitter husk")
    squad(b, ring[5], "brute")
    squad(b, garden, "mite mite mite")
    # approach garrison
    squad(b, ed[1], "husk")
    squad(b, jc, "spitter")
    squad(b, ch3[1][1], "mite mite husk")
    squad(b, ch11[0][1], "husk")
    squad(b, ch2[1][1], "mite mite")
    squad(b, ch6[1][0], "husk husk")
    squad(b, je, "husk")
    # west garrisons
    squad(b, sc[2], "husk")
    squad(b, jb2, "husk")
    squad(b, ch7[0][1], "mite mite")
    squad(b, ch10[1][0], "spitter")

    # the environmentals rack rides the end cap's outer wall (mid-sector,
    # clear of both radial portal faces)
    b.entity(ring[5], "key_blue",
             tuple(arc_mid(0, 0, 296, math.radians(75))))
    # ring[0] is the ring's sole doorway from the entry -- unlike every
    # later cell, the mobius glue offers no shortcut around it, so the
    # level's namesake shotgun goes here rather than in the storeroom
    # detour (which a shortest-path walk of the ring can skip entirely).
    # placed at the entry threshold (just inside ring[0]'s outer arc, where
    # the player necessarily first stands) rather than the wedge's middle
    # or its far inner wall -- both routing choices out of ring[0] (the
    # chain or the mobius glue) start from this exact point, so the pickup
    # doesn't depend on which way the walk goes.
    cache(b, ring[0], "weapon_shotgun ammo_shell", off=(16.4, -61.3))
    cache(b, ring[1], "ammo_9mm", off=(-32.9, 32.9))
    cache(b, ring[3], "medkit", off=(-44.9, -12.0))
    cache(b, ring[4], "medkit ammo_9mm", off=(-32.9, -32.9))
    cache(b, storeroom, "ammo_shell ammo_shell", wall=1, t=0.2, inset=16.0)
    # approach caches, racked where a quartermaster would rack them
    cache(b, dock[1][0], "ammo_9mm", wall=1)          # dock south berth rack
    cache(b, ch3[0][0], "ammo_9mm ammo_9mm", wall=3)  # storage hall shelf
    cache(b, alc_ch3, "ammo_shell")                   # crate niche
    cache(b, alc_ch2, "medkit")                       # lab annex first-aid
    cache(b, alc_ch11, "medkit")                      # medbay cabinet
    cache(b, alc_ch8, "ammo_9mm")                     # drum store niche
    cache(b, alc_ch6, "ammo_shell")                   # pump plant locker

    b.exit(garden, (483, 40))
    return b


def build() -> dict:
    """Resolved level dict, ready for perihelion.levels.save_level."""
    return l03().to_dict()


if __name__ == "__main__":
    bb = l03()
    lvl = bb.build()
    print(f"rooms={len(lvl.room_verts)} connects={len(lvl.connects)} "
          f"doors={len(lvl.doors)} enemies="
          f"{sum(1 for _, e in lvl.entities if e.type in ('husk', 'mite', 'spitter', 'brute', 'shrieker', 'warden'))}")
