"""L10 — PERIHELION CORE, rebuilt at Marathon density. Standalone module.

The diegetic skeleton of campaign.py's l10() survives intact and first (room
indices 0-8 unchanged: airlock, hexes 0-5, sanctum, alcove): the Cayley-graph
hex core (the paradox construct — its r/s generator wiring is untouched), the
vault door + WATCH SIGNET key logic, every terminal verbatim, the warden gate,
all radio lines including the inert kills:20 (now actually reachable), intro
and exit text.

Around it: a ~190-cell Marathon-grammar mesh per MARATHON_LEVEL_STANDARDS.md —
corridor chains of 80 u width bending every 2-3 cells, chamber grids of
touching rects welded by the doorway-splitter (seams at cell width; one
set-piece checkpoint at the 160 u seam register), ~10% dead-end alcoves at the
40-60 u slot register, quads dominant with chamfered turn cells, and one
radial octagon rotunda. The mesh replaces the old single airlock->hex hop as
the approach: airlock -> entry run -> checkpoint -> concourse -> the walk ->
hexes[0] edge 2, the exact edge the airlock used to weld to (approach
re-dressed; construct topology untouched).

THE OTHERWORLD at l10 dosage: the ordinary cells are the exceptions. The
entry run, the checkpoint, three small pockets (records / storage / quarters)
and the three-cell core antechamber before the hexes are the only normal mesh
cells; everything else is kind="otherworld" (soft mass-spring walls, inverted
light). No otherworld cell holds a door, key, terminal, or the exit — they
are connective and ambush tissue only. The paradox construct stays normal.

Streaming: airlock walls 0/1/3 (120-160 u) stay solid near the spawn; the
sanctum keeps free 120 u octagon walls at the exit — both carvable for the
WorldStreamer's 70 u spine doors.

Usage (mirrors campaign.py's save flow):
    from l10 import build, l10
    b = l10()                 # LevelBuilder, same contract as campaign.l10()
    save_level(b.to_dict(), path)
    # or: build() -> the resolved level dict directly
"""

from __future__ import annotations

import math
import sys
from pathlib import Path
from random import Random

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402

# --------------------------------------------------------------------------
# placement helpers (same conventions as tools/levelgen/campaign.py)
# --------------------------------------------------------------------------


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


# --------------------------------------------------------------------------
# mesh authoring: cursor walk + chamber grids (coincident-edge welding is the
# construction method here — touching rects become the portal mesh)
# --------------------------------------------------------------------------

DIRS = {"E": (1, 0), "S": (0, 1), "W": (-1, 0), "N": (0, -1)}
# free corner of a turn square: the corner on neither the entry nor exit edge.
# keyed by (d_in, d_out) -> corner name
_FREE_CORNER = {
    ("E", "S"): "NE", ("E", "N"): "SE",
    ("W", "S"): "NW", ("W", "N"): "SW",
    ("S", "E"): "SW", ("S", "W"): "SE",
    ("N", "E"): "NW", ("N", "W"): "NE",
}


class Walk:
    """Cursor-based corridor-chain author. The cursor is the midpoint of the
    next cell's entry edge; consecutive cells touch exactly, so resolve()'s
    autoconnect welds them. Width changes ride the doorway-splitter (the
    narrower edge is contained in the wider wall)."""

    def __init__(self, b: LevelBuilder, x: float, y: float, d: str,
                 w: float = 80.0, kind: str = "otherworld", rng: Random | None = None):
        self.b = b
        self.x, self.y, self.d, self.w, self.kind = x, y, d, w, kind
        self.rng = rng or Random(0)
        self.cells: list[int] = []
        self.rects: dict[int, tuple[float, float, float, float]] = {}

    def _seed(self) -> int:
        return self.rng.randrange(1 << 30)

    def _rect_for(self, length: float, w: float):
        x, y, d = self.x, self.y, self.d
        if d == "E":
            return (x, y - w / 2, length, w)
        if d == "W":
            return (x - length, y - w / 2, length, w)
        if d == "S":
            return (x - w / 2, y, w, length)
        return (x - w / 2, y - length, w, length)  # N

    def cell(self, length: float, kind: str | None = None) -> int:
        rx, ry, rw, rh = self._rect_for(length, self.w)
        rid = self.b.rect(rx, ry, rw, rh, seed=self._seed(),
                          kind=kind or self.kind)
        self.rects[rid] = (rx, ry, rw, rh)
        self.cells.append(rid)
        dx, dy = DIRS[self.d]
        self.x += dx * length
        self.y += dy * length
        return rid

    def turn(self, nd: str, chamfer: bool = False, kind: str | None = None) -> int:
        w = self.w
        rx, ry, rw, rh = self._rect_for(w, w)
        corner = _FREE_CORNER[(self.d, nd)]
        verts = [(rx, ry), (rx, ry + rh), (rx + rw, ry + rh), (rx + rw, ry)]
        if chamfer:
            c = min(24.0, w * 0.3)
            cpt = {"NW": (rx, ry), "SW": (rx, ry + rh),
                   "SE": (rx + rw, ry + rh), "NE": (rx + rw, ry)}[corner]
            i = verts.index(cpt)
            prev = verts[(i - 1) % 4]
            nxt = verts[(i + 1) % 4]

            def toward(p, q):
                dx, dy = q[0] - p[0], q[1] - p[1]
                l = math.hypot(dx, dy)
                return (p[0] + dx / l * c, p[1] + dy / l * c)

            verts[i:i + 1] = [toward(cpt, prev), toward(cpt, nxt)]
        rid = self.b.room(verts, detail_seed=self._seed(),
                          kind=kind or self.kind)
        self.rects[rid] = (rx, ry, rw, rh)
        self.cells.append(rid)
        dx, dy = DIRS[self.d]
        cx, cy = self.x + dx * w / 2, self.y + dy * w / 2
        ndx, ndy = DIRS[nd]
        self.x, self.y = cx + ndx * w / 2, cy + ndy * w / 2
        self.d = nd
        return rid

    def set_width(self, w: float):
        self.w = w

    def alcove(self, side: str, mouth: float = 56.0, depth: float = 48.0,
               kind: str | None = None, t: float = 0.5) -> int:
        """Dead-end niche welded onto the given absolute side of the last
        cell (slot register: mouth 40-60 u)."""
        rx, ry, rw, rh = self.rects[self.cells[-1]]
        if side in ("N", "S"):
            mx = rx + t * rw
            mx = min(max(mx, rx + mouth / 2 + 4), rx + rw - mouth / 2 - 4)
            if side == "S":
                r = (mx - mouth / 2, ry + rh, mouth, depth)
            else:
                r = (mx - mouth / 2, ry - depth, mouth, depth)
        else:
            my = ry + t * rh
            my = min(max(my, ry + mouth / 2 + 4), ry + rh - mouth / 2 - 4)
            if side == "E":
                r = (rx + rw, my - mouth / 2, depth, mouth)
            else:
                r = (rx - depth, my - mouth / 2, depth, mouth)
        rid = self.b.rect(*r, seed=self._seed(), kind=kind or self.kind)
        self.rects[rid] = r
        return rid


def wall_mid(rect: tuple[float, float, float, float], side: str,
             t: float = 0.5) -> tuple[float, float]:
    x, y, w, h = rect
    return {
        "N": (x + t * w, y), "S": (x + t * w, y + h),
        "W": (x, y + t * h), "E": (x + w, y + t * h),
    }[side]


def siderow(b: LevelBuilder, walk: Walk, cells: list[int], side: str,
            depth: float = 72.0, kind: str | None = None) -> list[int]:
    """Parallel row of cells flanking a straight run: each row cell shares
    its host cell's full wall (seam register — the corridor widens into a
    hall), and adjacent row cells weld to each other too."""
    ids = []
    for cid in cells:
        x, y, w, h = walk.rects[cid]
        r = {"S": (x, y + h, w, depth), "N": (x, y - depth, w, depth),
             "E": (x + w, y, depth, h), "W": (x - depth, y, depth, h)}[side]
        rid = b.rect(*r, seed=walk.rng.randrange(1 << 30),
                     kind=kind or walk.kind)
        walk.rects[rid] = r
        ids.append(rid)
    return ids


class Chamber:
    """cols x rows grid of touching rect cells — interior seams weld to
    full-width portals (rooms-as-cell-clusters, standards rule 2). `holes`
    is a set of (col, row) left solid: a pillared hall, corridors bending
    around mass."""

    def __init__(self, b: LevelBuilder, x: float, y: float, cols: int,
                 rows: int, cs: float, kind: str, rng: Random,
                 holes: set | None = None):
        holes = holes or set()
        self.x, self.y, self.cols, self.rows, self.cs = x, y, cols, rows, cs
        self.ids = [[(None if (i, j) in holes else
                      b.rect(x + i * cs, y + j * cs, cs, cs,
                             seed=rng.randrange(1 << 30), kind=kind))
                     for i in range(cols)] for j in range(rows)]

    def rect(self, i: int, j: int):
        return (self.x + i * self.cs, self.y + j * self.cs, self.cs, self.cs)

    def door_cursor(self, i: int, j: int, side: str, t: float = 0.5):
        """Cursor point on the outer wall of grid cell (i, j) — start a Walk
        here heading outward and its first cell welds an 80 u door."""
        return wall_mid(self.rect(i, j), side, t)


def chamber_at_cursor(b: LevelBuilder, walk: Walk, cols: int, rows: int,
                      cs: float, kind: str, rng: Random, enter: int = 0,
                      holes: set | None = None) -> Chamber:
    """Place a chamber so the walk's cursor edge lands centered on perimeter
    cell `enter` (row index for E/W approach, column index for N/S)."""
    x, y, d = walk.x, walk.y, walk.d
    if d == "E":
        return Chamber(b, x, y - (enter + 0.5) * cs, cols, rows, cs, kind,
                       rng, holes)
    if d == "W":
        return Chamber(b, x - cols * cs, y - (enter + 0.5) * cs, cols, rows,
                       cs, kind, rng, holes)
    if d == "S":
        return Chamber(b, x - (enter + 0.5) * cs, y, cols, rows, cs, kind,
                       rng, holes)
    return Chamber(b, x - (enter + 0.5) * cs, y - rows * cs, cols, rows, cs,
                   kind, rng, holes)


def octagon_edge_mid(cx: float, cy: float, r: float, n: int, phase: float,
                     edge: int) -> tuple[float, float]:
    a0 = phase - edge * 2.0 * math.pi / n
    a1 = phase - (edge + 1) * 2.0 * math.pi / n
    return ((cx + r * math.cos(a0) + cx + r * math.cos(a1)) / 2.0,
            (cy + r * math.sin(a0) + cy + r * math.sin(a1)) / 2.0)


# --------------------------------------------------------------------------
# the level
# --------------------------------------------------------------------------


def l10() -> LevelBuilder:
    b = LevelBuilder("PERIHELION CORE", 4, "amb_drone_finale")
    b.data["alert_hops"] = 1  # sound folds strangely between identical rooms

    # ---- skeleton: rooms 0-8 exactly as campaign.l10() authors them ------
    airlock = b.rect(0, 10, 160, 120, kind="corridor")
    hexes = []
    for i in range(6):
        x, y = 400 + (i % 3) * 360, (i // 3) * 360
        hexes.append(b.ngon(x, y, 120, 6, phase=math.radians(30),
                            seed=2000 + i, kind="core"))
    # edge 0 faces east, edge 3 west (phase 30): r-generator chains 0->3;
    # s-generator uses edges 1 and 4. Edge 2 is claimed by the alcove/
    # sanctum doors below on hexes[1]/[3] specifically -- edge 5 is the one
    # wall every hex has in common and free, so fixtures rack there.
    HEX_FREE = 5
    for i in range(6):
        b.connect(hexes[i], 0, hexes[(i + 1) % 6], 3)
    for i in range(6):
        b.connect(hexes[i], 1, hexes[(i + 2) % 6], 4)
    sanctum = b.ngon(1600, 180, 157, 8, phase=math.radians(22.5), seed=3000,
                     kind="core")

    # hex edges 0/1/3/4 belong to the Cayley wiring; edge 2 (up-left) is free
    alcove = b.rect(1240, 560, 120, 100, kind="quarters")  # first watcher's post
    b.door_pts(hexes[1], (812, 90), alcove, (1300, 560), "shoot")
    # NOTE: the old direct airlock->hexes[0] connect is replaced by the mesh
    # below; the mesh's last core cell welds to the SAME hex edge (348,-90).
    b.door(a=hexes[3], ea=2, b=sanctum, eb=4, key="void")
    b.key_meta("void", "WATCH SIGNET", "VAULT SEAL",
               "VAULT SEALED - WATCH SIGNET REQUIRED",
               "ACQUIRED: WATCH SIGNET")

    b.player(airlock, (80, 70))
    b.intro("The Core. The vault is here.\n"
            "The Congregation briefing calls the cargo the Ark.\n"
            "Ratio calls it the sample vessel.\n"
            "It was here before the station. The station\n"
            "grew around it, like scar tissue.\n\n"
            "Ratio is quiet for the first time.")
    b.terminal(hexes[1], wall_pos(b, hexes[1], HEX_FREE, 0.5, 15.0),
               "SITE ONE — FINAL PROTOCOL\n"
               "1. Do not bargain with the door.\n"
               "2. There is no rule two.\n\n"
               "The vault holds our cargo.\n"
               "The thing beneath the vault holds the door.")
    b.terminal(sanctum, wall_pos(b, sanctum, 0, 0.5, 15.0),
               "[SAMPLE VESSEL — EXTERNAL DIAGNOSTIC PORT]\n"
               "HULL BREACH: +214y INTO TRANSIT\n"
               "CRYOSTASIS: FAILED / RESTORED\n"
               "PAYLOAD: NO VIABLE MATERIAL.\n"
               "MAKE NO EFFORT AT RECOVERY.")
    b.terminal(sanctum, wall_pos(b, sanctum, 2, 0.5, 15.0),
               "[The door beneath the vault does not\n"
               "speak in words. It rearranges the room\n"
               "until the room is a sentence.\n"
               "The sentence is an offer.]\n\n"
               "GUARD / ACCEPT / KNEEL / BURN\n\n"
               "[You think of Ratio. You guard.]")
    b.terminal(alcove, wall_pos(b, alcove, 1, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 22%]\n"
               "this alcove held the first watcher.\n"
               "it stood here four hundred / thousand /\n"
               "[number does not translate] years.\n"
               "it is permitted to sit.")
    b.terminal(hexes[0], wall_pos(b, hexes[0], HEX_FREE, 0.5, 15.0),
               "MIRIAD PRIME ARCHIVE OFFICE — NEVER TRANSMITTED\n"
               "Site One was not discovered in survey month four.\n"
               "Site One has been a line item since before this\n"
               "outpost's own founding charter. The charter\n"
               "authorized study of a 'previously catalogued\n"
               "anomaly.'\n"
               "Nobody assigned to the outpost was shown the\n"
               "earlier entry. We are not shown it either. Close\n"
               "this file; do not forward the question upward\n"
               "again.")
    b.terminal(hexes[3], wall_pos(b, hexes[3], HEX_FREE, 0.5, 15.0),
               "SCRATCHED, LOW ON THE WALL, EASY TO MISS\n"
               "tape measure, one (1), still on its reel, no\n"
               "tape drawn out.\n"
               "Someone set it down gently.")
    cache(b, alcove, "medkit ammo_cell", wall=0, t=0.5, inset=14.0)
    # the streamer respawns a chunk-9 death right back at this airlock at
    # floor-40 hp (stream.py's entry-snapshot restore) -- a small emergency
    # kit at the threshold keeps a hard respawn from spiraling immediately.
    cache(b, airlock, "medkit ammo_9mm", wall=1, t=0.5, inset=14.0)
    squad(b, hexes[1], "husk husk husk")
    squad(b, hexes[2], "spitter brute")
    squad(b, hexes[4], "brute mite")
    squad(b, hexes[5], "husk husk spitter")
    squad(b, hexes[3], "brute")
    squad(b, sanctum, "warden")
    for _e in b.data["rooms"][sanctum]["entities"]:
        if _e["type"] == "warden":
            _e["props"] = {"tether": 1}
    cache(b, hexes[2], "ammo_cell ammo_shell medkit medkit", wall=HEX_FREE)
    cache(b, hexes[4], "ammo_9mm ammo_9mm ammo_shell", wall=HEX_FREE)
    cache(b, hexes[5], "medkit medkit ammo_cell medkit", wall=HEX_FREE)
    # the signet rests at the far coset's watch post
    b.entity(hexes[5], "key_void",
             (center(b, hexes[5])[0], center(b, hexes[5])[1] - 60))
    b.terminal(hexes[5], wall_pos(b, hexes[5], 2, 0.5, 15.0),
               "[TRANSLATION CONFIDENCE 17%]\n"
               "the last watcher set its signet down here,\n"
               "at the far post, where the walk ends twice.\n"
               "the vault seal answers the signet, not the\n"
               "hand. whoever carries it stands a watch,\n"
               "knowing or not.")
    cache(b, sanctum, "medkit ammo_cell ammo_shell", wall=6)
    # dressings left at the vault-door post (mesh-rebuild addition, playbook
    # §5.1 threshold logic: hexes[3] is the one room every route to the
    # vault crosses; walkover medkits only consume when actually hurt)
    cache(b, hexes[3], "medkit medkit", off=(0.0, 46.0))
    # the guard's own stations: dressings racked on the sanctum's free
    # walls (1/5 — 0/2 hold terminals, 4 is the vault seal, 6 the kit).
    # Walkover medkits consume only under 70 integrity: they are the
    # watch's margin against the Warden, not free loot.
    cache(b, sanctum, "medkit", wall=1, inset=16.0)
    cache(b, sanctum, "medkit", wall=5, inset=16.0)
    b.exit(sanctum, (1600, 180), gate_kind="warden")

    # ---- the mesh -------------------------------------------------------
    # Authored entirely in fresh canvas space (y >= 720) so no skeleton wall
    # is ever collinear-touching with mesh geometry: the doorway-splitter
    # can't disturb the construct or the terminal walls. Districts link to
    # the skeleton (and across canvas gaps) with connect_pts — pure-graph
    # tier license, playbook §8.
    rng = Random(1010)

    # ENTRY RUN (the last ordinary hallway; normal kinds, spawn-side
    # carvable walls stay on the airlock itself)
    vest = b.rect(-40, 740, 120, 120, seed=rng.randrange(1 << 30),
                  kind="corridor")
    b.connect_pts(airlock, (160, 70), vest, (-40, 800))
    w1 = Walk(b, 80, 800, "E", w=80, kind="corridor", rng=rng)
    ew1 = w1.cell(96)
    ew2 = w1.cell(88)
    siderow(b, w1, [ew1, ew2], "N", depth=72)
    siderow(b, w1, [ew1], "S", depth=72)
    w1.turn("S", chamfer=True)
    ent_a = w1.cell(96)
    w1.alcove("E", mouth=56, depth=72, kind="storage")
    alc_entry = list(w1.rects)[-1]
    cache(b, alc_entry, "ammo_9mm ammo_9mm medkit")
    # the checkpoint's riot gun, dropped at the post's threshold. Standalone
    # l10 starts at the standard pistol loadout; the district beyond is not
    # a pistol fight. Playbook §5.1: the unique reward sits within a few
    # units of the ENTRY threshold (the north doorway every route through
    # this cell crosses) — a centered cache was missed by bot walk lines.
    _tx, _ty = wall_mid(w1.rects[ent_a], "N")
    b.entity(ent_a, "weapon_shotgun", (_tx, _ty + 16.0))
    cache(b, ent_a, "ammo_shell ammo_shell")
    w1.cell(88)
    w1.turn("E")
    w1.cell(96)
    w1.alcove("S", mouth=56, depth=48)
    # CHECKPOINT — set-piece 2x2 at the 160 u seam register, kind transit
    cp = chamber_at_cursor(b, w1, 2, 3, 160, "transit", rng, enter=0)
    squad(b, cp.ids[1][0], "husk")
    cache(b, cp.ids[0][1], "ammo_9mm medkit", off=(0.0, 0.0))

    # CONCOURSE (otherworld): strand s1 east out of the checkpoint
    s1 = Walk(b, *cp.door_cursor(1, 0, "E"), "E", w=96, kind="otherworld",
              rng=rng)
    c1a = s1.cell(88)
    c1b = s1.cell(96)
    siderow(b, s1, [c1a, c1b], "N", depth=72)
    siderow(b, s1, [c1a, c1b], "S", depth=76)
    s1.turn("S", chamfer=True)
    s1.cell(88)
    s1.alcove("E", mouth=48, depth=48)
    amb1 = s1.cell(96)
    squad(b, amb1, "husk")
    c1c = s1.cell(96)
    s1.alcove("E", mouth=56, depth=48)
    siderow(b, s1, [amb1, c1c], "W", depth=72)
    s1.turn("E")
    s1.cell(88)
    fng1 = Walk(b, *wall_mid(s1.rects[s1.cells[-1]], "S"), "S", w=64,
                kind="otherworld", rng=rng)
    fng1.cell(72)
    fng1.cell(64)  # two-deep closet finger off the concourse spine
    s1.cell(96)
    # CHAMBER A: 3x3 x 96 otherworld
    cha = chamber_at_cursor(b, s1, 4, 3, 96, "otherworld", rng, enter=1)
    squad(b, cha.ids[1][1], "mite spitter")

    # strand s2: chamber A east -> rotunda approach
    s2 = Walk(b, *cha.door_cursor(3, 0, "E"), "E", w=96, kind="otherworld",
              rng=rng)
    c2a = s2.cell(96)
    c2b = s2.cell(88)
    siderow(b, s2, [c2a, c2b], "S", depth=76)
    siderow(b, s2, [c2a, c2b], "N", depth=76)
    s2.turn("N", chamfer=True)
    c2c = s2.cell(88)
    c2d = s2.cell(96)
    siderow(b, s2, [c2c, c2d], "E", depth=72)
    siderow(b, s2, [c2d], "W", depth=72)
    s2.turn("E")
    s2_end = s2.cell(96)

    # ROTUNDA: the one radial space (standards rule 7), otherworld
    ROT_C, ROT_R, ROT_N, ROT_PH = (2400.0, 900.0), 115.0, 8, math.radians(22.5)
    rot = b.ngon(*ROT_C, ROT_R, ROT_N, phase=ROT_PH,
                 seed=rng.randrange(1 << 30), kind="otherworld")
    squad(b, rot, "mite")

    def rot_mid(edge):
        return octagon_edge_mid(*ROT_C, ROT_R, ROT_N, ROT_PH, edge)

    b.connect_pts(s2_end, wall_mid(s2.rects[s2_end], "E"), rot, rot_mid(4))

    # strand s3: rotunda -> chamber B (the deep concourse hall)
    s3 = Walk(b, 2700, 900, "E", w=96, kind="otherworld", rng=rng)
    s3_first = s3.cell(96)
    b.connect_pts(rot, rot_mid(0), s3_first, wall_mid(s3.rects[s3_first], "W"))
    c3b = s3.cell(88)
    siderow(b, s3, [s3_first, c3b], "S", depth=76)
    siderow(b, s3, [s3_first, c3b], "N", depth=72)
    s3.turn("S", chamfer=True)
    c3c = s3.cell(88)
    c3d = s3.cell(96)
    siderow(b, s3, [c3c, c3d], "E", depth=72)
    s3.turn("E")
    s3.cell(96)
    chb = chamber_at_cursor(b, s3, 4, 4, 104, "otherworld", rng, enter=1)
    squad(b, chb.ids[2][0], "husk spitter")

    # strand s4: rotunda north wall -> records pocket (normal island; a
    # filed place the otherworld hasn't digested). The first cell's south
    # edge sits ON the octagon's north edge: the splitter welds it.
    s4 = Walk(b, *rot_mid(2), "N", w=92, kind="otherworld", rng=rng)
    c4a = s4.cell(96)
    c4b = s4.cell(88)
    siderow(b, s4, [c4a], "E", depth=72)
    siderow(b, s4, [c4a, c4b], "W", depth=72)
    s4.turn("W")
    s4.cell(96)
    s4.alcove("N", mouth=56, depth=48)
    rec1 = s4.cell(120, kind="records")
    rec2 = s4.cell(120, kind="records")
    siderow(b, s4, [rec1, rec2], "S", depth=80, kind="records")
    cache(b, rec2, "medkit ammo_shell")
    s4d = Walk(b, s4.x, s4.y, "W", w=56, kind="otherworld", rng=rng)
    s4d.cell(72)  # crawl slot out the far end of the records stack
    s4d.cell(96)
    s4d.alcove("N", mouth=48, depth=48)

    # CHAMBER C hangs off the rotunda's south wall (same weld trick), with
    # a dead finger west — the otherworld pooling below the concourse
    sc = Walk(b, *rot_mid(6), "S", w=92, kind="otherworld", rng=rng)
    cca = sc.cell(88)
    ccb = sc.cell(96)
    siderow(b, sc, [cca, ccb], "E", depth=72)
    siderow(b, sc, [cca, ccb], "W", depth=72)
    chc = chamber_at_cursor(b, sc, 3, 3, 96, "otherworld", rng, enter=1)
    squad(b, chc.ids[1][1], "mite")
    scx = Walk(b, *chc.door_cursor(0, 1, "W"), "W", w=92, kind="otherworld",
               rng=rng)
    scx.cell(96)
    scx.alcove("N", mouth=48, depth=48)
    scd = scx.cell(88)  # dead end
    cache(b, scd, "ammo_shell ammo_shell medkit")

    # strand s5: service loop, chamber A south -> pillared hall P1 -> the
    # walk. P1 is a 5x4 grid with three solid pillar cells: corridors
    # bending around mass, the highest local flood in the district.
    s5 = Walk(b, *cha.door_cursor(1, 2, "S"), "S", w=92, kind="otherworld",
              rng=rng)
    c5p = s5.cell(88)
    c5q = s5.cell(96)
    s5.alcove("E", mouth=56, depth=48)
    siderow(b, s5, [c5p], "E", depth=72)
    s5.turn("W", chamfer=True)
    c5a = s5.cell(96)
    siderow(b, s5, [c5a], "S", depth=72)
    amb5 = s5.cell(88)
    squad(b, amb5, "husk")
    cache(b, c5a, "medkit ammo_9mm")  # walked over mid-loop
    s5.turn("S")
    c5b = s5.cell(88)
    siderow(b, s5, [c5b], "E", depth=72)
    s5_end = s5.cell(96)
    s5.alcove("W", mouth=56, depth=72, kind="storage")
    alc_s5 = list(s5.rects)[-1]
    cache(b, alc_s5, "ammo_cell ammo_9mm")
    s5.set_width(80)
    p1 = chamber_at_cursor(b, s5, 6, 4, 88, "otherworld", rng, enter=2,
                           holes={(1, 1), (3, 1), (2, 2), (4, 2)})
    squad(b, p1.ids[3][4], "mite")
    s5x = Walk(b, *p1.door_cursor(1, 3, "S"), "S", w=92, kind="otherworld",
               rng=rng)
    s5x.cell(88)
    s5x.turn("W", chamfer=True)
    s5x_end = s5x.cell(96)
    s5x.alcove("S", mouth=56, depth=48)

    # strand s6: chamber B south -> quarters pocket + dead fingers
    s6 = Walk(b, *chb.door_cursor(1, 3, "S"), "S", w=92, kind="otherworld",
              rng=rng)
    s6.cell(96)
    s6.alcove("W", mouth=56, depth=48)
    s6.turn("E", chamfer=True)
    c6a = s6.cell(88)
    siderow(b, s6, [c6a], "S", depth=76)
    qtr = s6.cell(128, kind="quarters")  # someone slept here, once
    cache(b, qtr, "medkit medkit")
    s6.turn("S")
    s6.cell(88)
    s6.alcove("E", mouth=56, depth=48)
    c6b = s6.cell(96)
    siderow(b, s6, [c6b], "W", depth=72)
    siderow(b, s6, [c6b], "E", depth=72)
    s6.cell(80)  # dead end: the corridor just stops

    # THE WALK: chamber B west -> long braided approach to the hex core
    # (row 2, not row 1: s3 already welds into (0,1)'s west wall)
    s7 = Walk(b, *chb.door_cursor(0, 2, "W"), "W", w=92, kind="otherworld",
              rng=rng)
    c7a = s7.cell(96)
    c7b = s7.cell(88)
    siderow(b, s7, [c7a, c7b], "N", depth=72)
    siderow(b, s7, [c7a, c7b], "S", depth=72)
    s7.turn("S", chamfer=True)
    s7.cell(88)
    s7.alcove("W", mouth=56, depth=48)
    c7d = s7.cell(96)
    siderow(b, s7, [c7d], "W", depth=72)
    s7.turn("W")
    s7.cell(96)
    amb7 = s7.cell(88)
    squad(b, amb7, "husk")
    s7_loop = s7.cell(96)
    s7.turn("S", chamfer=True)
    s7.set_width(56)
    s7.cell(88)   # the crawl: the otherworld pinches
    s7.cell(88)
    s7.set_width(80)
    s7.turn("W")
    s7_post = s7.cell(96)
    s7.alcove("S", mouth=56, depth=48)
    cache(b, s7_post, "medkit ammo_9mm")  # walked over on the way out
    c7c = s7.cell(88)
    s7.cell(96)
    siderow(b, s7, [c7c, s7_post], "N", depth=72)
    siderow(b, s7, [c7c], "S", depth=72)
    # ...and the ordinary reasserts itself: three core-kind cells, the
    # last ordinary rooms before the construct (otherworld never touches
    # the paradox approach threshold)
    s7.turn("N", kind="core")
    ante1 = s7.cell(96, kind="core")
    squad(b, ante1, "husk")
    s7.alcove("E", mouth=56, depth=48, kind="core")
    ante2 = s7.cell(88, kind="core")
    siderow(b, s7, [ante1, ante2], "W", depth=72, kind="core")
    # the watch post's kit: the last watcher's arms and dressings, set down
    # at the post the way the signet was — the last resupply before the
    # construct. The smg covers the 60-140 u strafe band the pistol can't
    # carry against the Warden; it sits ON the doorway threshold into
    # hexes[0] (§5.1 — every route to the construct crosses that line).
    _wx, _wy = wall_mid(s7.rects[ante2], "N")
    b.entity(ante2, "weapon_smg", (_wx, _wy + 16.0))
    cache(b, ante2, "medkit medkit ammo_9mm ammo_shell")
    b.connect_pts(ante2, wall_mid(s7.rects[ante2], "N"), hexes[0], (348, -90))

    # P2: a second pillared hall hanging south of the walk — bypass loop
    # around the crawl (take the pinch or take the hall)
    post2 = s7.cells[s7.cells.index(s7_post) + 2]  # the 88 u cell after it
    s7b = Walk(b, *wall_mid(s7.rects[post2], "S"), "S", w=80,
               kind="otherworld", rng=rng)
    s7b.cell(88)
    p2 = chamber_at_cursor(b, s7b, 4, 4, 96, "otherworld", rng, enter=1,
                           holes={(1, 1), (2, 1), (1, 2), (2, 2)})
    squad(b, p2.ids[0][2], "husk")
    s7c = Walk(b, *p2.door_cursor(0, 0, "W"), "W", w=92, kind="otherworld",
               rng=rng)
    s7c.cell(88)
    s7c.turn("N", chamfer=True)
    s7c_end = s7c.cell(96)
    b.connect_pts(s7c_end, wall_mid(s7c.rects[s7c_end], "N"),
                  amb7, wall_mid(s7.rects[amb7], "N"))

    # service loop closure: s5/P1 rejoins the walk mid-strand (graph link,
    # not canvas adjacency — pure-graph tier tissue)
    b.connect_pts(s5x_end, wall_mid(s5x.rects[s5x_end], "W"),
                  s7_loop, wall_mid(s7.rects[s7_loop], "N"))

    # concourse cross-link: chamber A north edge back to the entry strand —
    # the mesh reads as a district, not a tree
    s8 = Walk(b, *cha.door_cursor(0, 0, "N"), "N", w=92, kind="otherworld",
              rng=rng)
    c8a = s8.cell(88)
    c8b = s8.cell(96)
    s8.cell(96)
    siderow(b, s8, [c8a, c8b], "E", depth=72)
    siderow(b, s8, [c8b], "W", depth=72)
    s8.turn("W", chamfer=True)
    s8.cell(96)
    s8.alcove("N", mouth=48, depth=48)
    s8_end = s8.cell(88)
    b.connect_pts(s8_end, wall_mid(s8.rects[s8_end], "W"),
                  ent_a, wall_mid(w1.rects[ent_a], "W"))

    return b


def build() -> dict:
    """Resolved level dict, ready for save_level (campaign.py save flow)."""
    return l10().to_dict()


if __name__ == "__main__":
    import json
    from collections import Counter

    d = build()
    n = len(d["rooms"])
    deg = Counter()
    for a, ea, bb, eb in d["connects"]:
        deg[a] += 1
        deg[bb] += 1
    for dr in d["doors"]:
        deg[dr["a"]] += 1
        deg[dr["b"]] += 1
    hist = Counter(deg.get(i, 0) for i in range(n))
    vhist = Counter(len(r["verts"]) for r in d["rooms"])
    kinds = Counter(r.get("kind", "generic") for r in d["rooms"])
    print(f"cells={n} connects={len(d['connects'])} doors={len(d['doors'])}")
    print("degree:", dict(sorted(hist.items())))
    print("verts:", dict(sorted(vhist.items())))
    print("kinds:", dict(sorted(kinds.items())))
    if len(sys.argv) > 1:
        Path(sys.argv[1]).write_text(json.dumps(d, indent=1))
        print("wrote", sys.argv[1])
