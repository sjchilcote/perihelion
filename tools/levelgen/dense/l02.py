"""COOLANT ROW (l02) rebuilt to Marathon density — standalone module.

Mirrors tools/levelgen/campaign.py's l02() contract exactly: `l02()` returns
a LevelBuilder, and campaign's save flow (`b = l02(); final = b.to_dict();
lvl = b.build(); save_level(final, path)`) works unchanged. `build()` returns
the resolved level dict directly. Nothing here touches campaign.py or
levels/*.json.

Preserved from campaign.l02, verbatim where it is text and topologically
where it is geometry:
  - name/tier/ambience, intro, all seven terminal texts, all six radio
    lines (enter_room triggers re-pointed at the equivalent district cells),
    key_meta red = VALVE WHEEL / PRESSURE HATCH.
  - THE PARADOX (sacred, playbook §11): pump bay A's NORTH wall opens into
    pump bay B's NORTH wall — you emerge walking the way you came. Same
    connect_pts north-edge-to-north-edge topology as the original; only the
    approach (the bays are now subdivided cell clusters with antechambers
    off the row) is re-dressed.
  - HATCH SIX: the Arrival east-maze graft (arrival_maze.build_maze at
    origin (1300, 500), scale 80.0) plus its vault, byte-for-byte the same
    calls as campaign.l02. Its 30-pair no_connect list guards the 5D
    crossings; the graft now hangs off the filter district's east wall.
  - the red armory door (door_pts + no_connect so the door is the only
    opening), exit in the armory, smg cache racked just inside the door.

Density per MARATHON_LEVEL_STANDARDS.md (the eight authoring rules),
measured, not vibed — random-position visible(depth 22) sampling scores
this mesh median 8, the same figure levels/marathon_arrival.json scores
under the identical sampler:
  - 143 cells (76 authored + 66 maze cells + vault; early-level end of the
    120-250 band). Median cell 80x80 u; degree-2 share 46%.
  - the Row is a chain of degree-2 corridor cells, 80 u wide, 60-120 u
    long, bending every 2-3 cells (west run -> north jog -> east run ->
    south jog -> tail), rule 3.
  - chambers are convex-cell grids welded by full-edge autoconnect: pump
    bays A and B are 4x4 clusters of 80x90 cells, the filter room a 4x2
    grid of ~85 u cells — every seam an 80-90 u portal, per rule 5's
    registers (80 door / 40-60 slot; no 120 u uncanny-middle portals).
  - ~10-14 percent dead-end alcoves (60 u niches off corridors holding a
    cache, a terminal's chalk, or nothing), rule 4.
  - quads dominate (78%); a handful of 5-vert chamfered cells where the
    corridor bends or an alcove's outer corner is cut, rule 7.
  - streaming (playbook §10): the entry vestibule keeps its whole 140 u
    west wall solid for the previous chunk's carved spine door, and the
    armory keeps 140 u north/south walls and its 80 u east wall solid for
    the next one.

Kinds stay inside the original vocabulary: corridor/transit/pump/storage
(+ the maze's own corridor/transit tags).
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

_REPO = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(_REPO / "game"))
sys.path.insert(0, str(_REPO / "tools" / "levelgen"))

from perihelion.levels import LevelBuilder, save_level  # noqa: E402
from arrival_maze import build_maze  # noqa: E402


# --- helpers copied from tools/levelgen/campaign.py (kept standalone) -------

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
    """(mx, my, tx, ty, nx, ny) for edge `wall` of `room`; rect edge order is
    stable: 0=west, 1=south, 2=east, 3=north."""
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


def _grid(b: LevelBuilder, x0: float, y0: float, cw: float, ch: float,
          cols: int, rows: int, kind: str) -> list[list[int]]:
    """cols x rows lattice of touching rect cells; autoconnect welds every
    shared edge into a full-width seam (the coincident-edge hazard used ON
    PURPOSE, per INTEGRATION.md). cells[row][col], row 0 northmost."""
    return [[b.rect(x0 + c * cw, y0 + r * ch, cw, ch, kind=kind)
             for c in range(cols)] for r in range(rows)]


# ---------------------------------------------------------------------------
# L2 — COOLANT ROW at Marathon density. Deniable-going-on-odd: a pump bay
# whose north hatch drops you back into a different pump bay facing the
# other way. Mites. Red key, SMG. Hatch Six behind the filters.
# ---------------------------------------------------------------------------

def l02() -> LevelBuilder:
    b = LevelBuilder("COOLANT ROW", 1, "amb_drone_early")

    # -- entry vestibule (west; spawn). West wall stays fully solid: the
    # streamer carves the previous chunk's 70 u spine door here.
    e0 = b.rect(0, 0, 140, 140, kind="corridor")
    e1 = b.rect(140, 30, 80, 80, kind="corridor")
    e2 = b.rect(220, 30, 100, 80, kind="corridor")
    # empty niche off the entry hall, NW corner chamfered (rule 7)
    a1 = b.poly([(240, -10), (240, 30), (300, 30), (300, -30), (260, -30)])
    b.set_kind(a1, "corridor")

    # -- the Row: a corridor CHAIN, not a rectangle (standards rule 3).
    # West run at y 30..110, jog north at R4/R5, east run at y -130..-50,
    # jog south at R8..R10, tail at y 30..110. All 80 u wide.
    r1 = b.rect(320, 30, 120, 80, kind="transit")    # row head junction
    r2 = b.rect(440, 30, 120, 80, kind="corridor")
    r3 = b.rect(560, 30, 100, 80, kind="corridor")
    # bend cell, SE corner chamfered (its east/south walls are free)
    r4 = b.poly([(660, -50), (660, 110), (710, 110), (740, 80), (740, -50)])
    b.set_kind(r4, "corridor")
    r5 = b.rect(660, -130, 80, 80, kind="corridor")
    r6a = b.rect(740, -130, 60, 80, kind="corridor")
    r6b = b.rect(800, -130, 60, 80, kind="corridor")
    r7 = b.rect(860, -130, 120, 80, kind="corridor")
    r8 = b.rect(980, -130, 80, 80, kind="corridor")
    r9 = b.rect(980, -50, 80, 80, kind="corridor")
    r10 = b.rect(980, 30, 80, 80, kind="transit")    # tail/sump junction

    # tail chain to the armory
    t1 = b.rect(1060, 30, 80, 80, kind="corridor")
    t2 = b.rect(1140, 30, 80, 80, kind="corridor")
    t3 = b.rect(1220, 30, 80, 80, kind="corridor")

    # row alcoves (rule 4: one dead end per ~10 cells; caches or nothing)
    a2 = b.rect(800, -50, 60, 60, kind="corridor")           # empty niche
    a4 = b.poly([(740, -190), (740, -130), (800, -130),      # chamfered niche
                 (800, -170), (780, -190)])
    b.set_kind(a4, "corridor")
    a3 = b.rect(1060, -120, 60, 60, kind="storage")          # the find
    a5 = b.rect(1070, -30, 60, 60, kind="storage")           # the find

    # -- pump bay A (north, off the row head): 4x4 cell cluster of 80x90
    # cells — a Marathon set-piece room is a cluster of small convex cells,
    # every seam an 80-90 u portal (standards rule 2's calibrated read:
    # subdivide until a screen holds 8-16 cells).
    pa = _grid(b, 280, -430, 80, 90, 4, 4, "pump")
    pa_ante = b.rect(360, -70, 80, 100, kind="corridor")     # bay threshold
    a10 = b.rect(600, -320, 60, 60, kind="storage")          # bay-side locker

    # -- pump bay B (north, over the tail): 4x4 cluster, same grammar.
    pb = _grid(b, 780, -590, 80, 90, 4, 4, "pump")
    pb_ante = b.rect(860, -230, 80, 100, kind="corridor")

    # THE IMPOSSIBLE HATCH (paradox construct, topology untouched): out
    # pump bay A's north wall, in through pump bay B's north wall — you
    # emerge walking the way you came.
    b.connect_pts(pa[0][3], (560, -430), pb[0][0], (820, -590))

    # -- filter district (south of the row): 4x2 grid of ~85 u pump cells;
    # the row reaches it twice (stub crawl + connector door: a loop).
    k = [[b.rect(x, y, w, 85, kind="pump")
          for x, w in ((300, 80), (380, 90), (470, 90), (560, 80))]
         for y in (210, 295)]
    stub = b.rect(320, 110, 60, 100, kind="corridor")        # 60 u crawl
    connector = b.rect(480, 110, 80, 100, kind="corridor")   # 80 u door
    a7 = b.poly([(240, 300), (240, 340), (260, 360), (300, 360), (300, 300)])
    b.set_kind(a7, "corridor")                               # empty niche
    keyroom = k[0][0]   # the filter room proper: manifold wall, key, posted procedure

    # -- valve store off the west run (quartermaster shelf, dead end)
    s1 = b.rect(580, 110, 80, 90, kind="storage")

    # -- sump chain south of the tail junction: quiet corridor cells
    # stepping down to a wet machine room (pacing beat, playbook §6).
    c1a = b.rect(980, 110, 80, 50, kind="corridor")
    c1b = b.rect(980, 160, 80, 50, kind="corridor")
    c2a = b.rect(980, 210, 80, 50, kind="corridor")
    c2b = b.rect(980, 260, 80, 50, kind="corridor")
    s3 = b.rect(940, 310, 160, 100, kind="pump")
    a9 = b.rect(920, 110, 60, 50, kind="corridor")           # empty niche

    # -- armory annex (east end). The red door IS the only opening; the
    # armory's other three walls stay solid so the streamer can carve the
    # next chunk's spine door (playbook §10).
    armory = b.rect(1300, 30, 140, 80, kind="storage")
    b.door_pts(t3, (1300, 70), armory, (1300, 70), "red")
    b.no_connect(t3, armory)
    # the "red key" is the row's one loose valve handwheel, racked in the
    # filter room; the armory annex hides behind a pressure hatch whose
    # undogging spindle takes the same square drive (terminal below).
    b.key_meta("red", "VALVE WHEEL", "PRESSURE HATCH",
               "PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED",
               "ACQUIRED: VALVE WHEEL")

    # HATCH SIX — the homage, grafted exactly as in campaign.l02: Arrival's
    # east maze (Marathon 1) as the row's unfiled maintenance warren behind
    # the filters. The maze keeps its genuine 5D overlaps (its no_connect
    # list guards the crossings); it is optional, silent, and holds a cache
    # at the far end.
    maze = build_maze(b, origin=(1300.0, 500.0), scale=80.0)
    b.connect_pts(k[1][3], (640.0, 337.5), maze["entry"][0], maze["entry"][1])
    vault = b.rect(2300, 500, 120, 90, kind="storage")
    b.connect_pts(maze["exit"][0], maze["exit"][1], vault, (2360, 500))
    b.entity(vault, "husk", (2340, 545))
    b.entity(vault, "ammo_9mm", (2320, 570))
    b.entity(vault, "ammo_shell", (2350, 570))
    b.entity(vault, "medkit", (2390, 570))
    b.terminal(vault, wall_pos(b, vault, 2, 0.5, 15.0),
               "SURVEY ADDENDUM, UNFILED\n"
               "The row has five hatches. The count says six.\n"
               "The sixth is behind the filters. Walked it once,\n"
               "drew a map. Walked it again against the map.\n"
               "The map was wrong in a way I could not mark:\n"
               "every corridor was where I drew it, and two of\n"
               "them cross where neither has a junction.\n"
               "Recommend: do not draw another map.")

    b.player(e0, (60, 70))
    b.intro("Coolant Row. The pumps have been louder\nlately. Nobody says so on record.")
    b.radio("start", "Ratio: Terms: you clear my decks, I open my doors, "
                     "and we both pretend that's all this is. Pressure's "
                     "uneven in the row. Don't stand in front of a line "
                     "when it pops.")
    b.radio(f"enter_room:{pb[0][0]}", "Ratio: That's pump bay two. Except you "
                                      "went in through bay one. I'm marking a "
                                      "relay fault. Again.")
    b.radio("pickup:red", "Ratio: The row's valve wheel. The armory annex "
                          "pressure hatch takes it — east end, and the "
                          "lift out is inside.")
    b.radio(f"enter_room:{pa[3][1]}", "Ratio: If you're going to loot my "
                                      "pump bays anyway, bay two holds sealed "
                                      "supplies. Consider it a retainer. I "
                                      "want to know what you see down there.")
    b.terminal(pb[1][0], wall_pos(b, pb[1][0], 0, 0.5, 15.0),
               "MAINT LOG 2280.11\nCrewman Osei walked Coolant Row end to end.\n"
               "Counted five hatches going. Counted six coming back.\n"
               "Recommend rest rotation for Osei.")
    b.radio(f"enter_room:{keyroom}", "Ratio: That's the filter room. The "
                                     "things nesting in it used to be my "
                                     "cleaning swarm. Mind the floor.")
    b.terminal(t2, wall_pos(b, t2, 1, 0.4, 15.0),
               "MAINT TICKET 4471\n"
               "Coolant flow, east tail: 210 l/min rated,\n"
               "212 measured, 209 after the bend.\n"
               "Where do three liters a minute GO?\n"
               "Status: closed. Reason: rounding.")
    b.terminal(pa[2][0], wall_pos(b, pa[2][0], 0, 0.5, 15.0),
               "MAINT LOG, PUMP BAY ONE\n"
               "Coolant pressure holds steady at spec, checked\n"
               "at the gauge. Flow rate does not match the\n"
               "pressure. It should. The math connecting the two\n"
               "numbers has not changed since the pumps were\n"
               "rated. Checked that too.\n"
               "Filed under: recalibrate flow sensor. Sensor\n"
               "recalibrated. Numbers held.")
    b.terminal(pb[2][0], wall_pos(b, pb[2][0], 0, 0.85, 15.0),
               "MAINT TICKET 4488 — FOLLOW-UP TO OSEI'S LOG\n"
               "Re-walked Coolant Row end to end, count taken\n"
               "twice. Five hatches, both times, both directions.\n"
               "Schematic on file: five hatches. Schematic\n"
               "checksum does not match the schematic filed\n"
               "eleven months ago. Nobody has edited this file.\n"
               "Status: closed, no fault found. Recommend against\n"
               "opening it again.")
    b.terminal(stub, wall_pos(b, stub, 0, 0.5, 15.0),
               "SCRATCHED NEAR THE FLOOR VENT\n"
               "tally marks, forty-one of them, then nothing\n"
               "someone was counting seconds. or minutes. or\n"
               "hatches. whoever it was stopped at forty-one and\n"
               "left the chalk on the ledge.")
    b.terminal(keyroom, wall_pos(b, keyroom, 0, 0.5, 15.0),
               "FILTER SWAP PROCEDURE, POSTED\n"
               "Isolate the loop before pulling a filter: the\n"
               "isolation valve takes the loose handwheel racked\n"
               "by the manifold. One wheel serves the row — the\n"
               "same square drive runs the armory annex pressure\n"
               "hatch at the east tail. Engineering never issued\n"
               "a second wheel. Asked twice. Bring it back.")

    # -- opposition. The original roster (4 row mites; husk+2 mites in bay
    # A; 2 husks in bay B; 5 mites + spitter in the filter room; spitter +
    # husk in the tail; vault husk) survives cell-for-cell, plus a modest
    # growth pass to pace the larger mesh (one contact every few cells,
    # quiet entry and sump approach kept quiet).
    squad(b, r2, "mite mite")
    squad(b, r7, "mite mite")
    b.entity(r5, "mite", center(b, r5))
    b.entity(r9, "mite", center(b, r9))
    b.entity(connector, "mite", center(b, connector))
    squad(b, pa[2][0], "husk mite mite")
    b.entity(pa[1][1], "mite", center(b, pa[1][1]))
    squad(b, pb[1][0], "husk")
    squad(b, pb[2][1], "husk")
    squad(b, pb[0][1], "husk")
    squad(b, keyroom, "mite mite spitter")
    squad(b, k[1][1], "mite mite mite")
    squad(b, t1, "husk")
    squad(b, t2, "spitter")
    b.entity(s1, "mite", center(b, s1))
    squad(b, s3, "spitter mite")

    # the handwheel hangs on the manifold wall, under the posted procedure
    b.entity(keyroom, "key_red", wall_pos(b, keyroom, 0, 0.72, 16.0))
    cache(b, a10, "ammo_9mm", wall=2)               # bay A's wall locker
    cache(b, pb[0][3], "medkit ammo_9mm", wall=2)   # bay B sealed supplies
    cache(b, r7, "medkit", wall=1)                  # the row medkit
    cache(b, a3, "ammo_9mm", wall=2)                # someone's stash
    cache(b, a5, "ammo_9mm", wall=3)
    cache(b, s1, "ammo_9mm", wall=2)                # the valve store shelf
    cache(b, s3, "medkit ammo_9mm", wall=1)         # sump supplies
    # racked just inside the only door into the armory (the red door from
    # the tail) -- the doorway is the one point every route through this
    # room shares (playbook §5.1).
    cache(b, armory, "weapon_smg ammo_9mm ammo_9mm", wall=0, t=0.5, inset=12.0)
    b.exit(armory, (1370, 70))
    b.radio("exit", "Ratio: Row's clear. The count in Osei's log... "
                    "forget it. Clock drift.")
    return b


def build() -> dict:
    """Resolved level dict, ready for perihelion.levels.save_level."""
    return l02().to_dict()


if __name__ == "__main__":
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else \
        Path(__file__).with_name("l02_dense.json")
    b = l02()
    final = b.to_dict()
    lvl = b.build()  # validates winding/schema/spawn
    save_level(final, out)
    print(f"{out}: {lvl.name!r} rooms={len(lvl.room_verts)} "
          f"connects={len(lvl.connects)} doors={len(lvl.doors)} "
          f"enemies={sum(1 for _, e in lvl.entities if e.type in ('husk', 'mite', 'spitter', 'brute', 'shrieker', 'warden'))}")
