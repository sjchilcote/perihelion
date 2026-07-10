"""L1 — DOCK 4 — SWEEP, rebuilt to Marathon density (standalone module).

Same level, finer cells: the 12-room original becomes a ~120-cell district
per MARATHON_LEVEL_STANDARDS.md (cell rhythm 60/90/150/220, corridor
chains, ~10% dead-end alcoves, quads with chamfers, three width registers).

Everything diegetic survives verbatim from tools/levelgen/campaign.py's
l01(): name/tier/ambience, intro, all eight terminals, all radio triggers,
the exit, and the paradox construct — the storage ring that holds nine
segments in an eight-segment footprint. The ring (8 segments + junction +
phantom) is copied coordinate-for-coordinate: its no_connect list, the two
connect_pts through the phantom, and every wall it owns are untouched; no
new cell shares an edge with any of those ten rooms except the hall's
original weld into the junction's west wall.

Streaming: the spawn cell (d_w) keeps a fully solid 180 u west wall and
the exit room (ring_se) keeps its solid west/east/south walls, so
WorldStreamer can carve its 70 u spine doors at both ends.

Usage:
    from l01 import build          # (with tools/levelgen/dense on sys.path)
    level_dict = build()           # resolved dict, ready for save_level()

`l01()` mirrors campaign.py's contract exactly: returns the LevelBuilder.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402


# --- placement helpers, copied from tools/levelgen/campaign.py -------------

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
# The level
# ---------------------------------------------------------------------------

def l01() -> LevelBuilder:
    b = LevelBuilder("DOCK 4 — SWEEP", 1, "amb_drone_early")

    # =======================================================================
    # DOCK BAY — the original 220x180 dock footprint, subdivided into a
    # gantry-lined bay (one long cell + three threshold cells; the west
    # bulkhead of d_w stays 100% solid: it is the streamer's entry carve
    # wall, same as the original dock's).
    # =======================================================================
    d_w = b.rect(0, 0, 110, 180, kind="dock")      # spawn cell
    d_n = b.rect(110, 0, 110, 60, kind="dock")
    d_c = b.rect(110, 60, 110, 70, kind="dock")    # opens east into the hall
    d_s = b.rect(110, 130, 110, 50, kind="dock")

    # gantry walk north of the bay (crane rail), with suit lockers
    g1 = b.rect(5, -70, 105, 70, kind="corridor")
    g2 = b.rect(110, -70, 105, 70, kind="corridor")
    ge = b.rect(215, -70, 105, 70, kind="corridor")
    gea = b.poly([(320, -60), (320, -10), (380, -10), (380, -40),
                  (360, -60)])                      # chamfered tool niche
    b.set_kind(gea, "storage")
    gn = b.rect(240, -130, 60, 60, kind="storage")  # crane parts, dead end
    l1 = b.rect(220, 0, 70, 60, kind="storage")     # suit locker (cuts the corner)
    l2 = b.rect(220, 130, 70, 50, kind="storage")   # suit locker, dead end-ish

    # =======================================================================
    # NORTH SPINE + CREW ANNEX — quarters, mess, san, medbay, records.
    # A dock district's living half; quiet on purpose (playbook §6).
    # =======================================================================
    v1 = b.rect(20, -150, 80, 80, kind="corridor")
    v2 = b.rect(20, -230, 80, 80, kind="corridor")
    v3 = b.rect(20, -310, 80, 80, kind="corridor")
    va = b.rect(-40, -310, 60, 50, kind="storage")  # cleaning gear crawl

    x1 = b.rect(100, -310, 100, 80, kind="corridor")
    x2 = b.rect(200, -310, 100, 80, kind="corridor")
    x3 = b.rect(300, -310, 100, 80, kind="corridor")

    q00 = b.rect(100, -230, 100, 80, kind="quarters")
    q10 = b.rect(200, -230, 100, 80, kind="quarters")
    q20 = b.rect(300, -230, 100, 80, kind="quarters")
    q01 = b.rect(100, -150, 100, 60, kind="quarters")
    q11 = b.rect(200, -150, 100, 60, kind="quarters")
    q21 = b.rect(300, -150, 100, 60, kind="quarters")

    m00 = b.rect(100, -470, 100, 80, kind="quarters")   # mess
    m10 = b.rect(200, -470, 100, 80, kind="quarters")
    m01 = b.rect(100, -390, 100, 80, kind="quarters")
    m11 = b.rect(200, -390, 100, 80, kind="quarters")
    m02 = b.poly([(100, -520), (100, -470), (200, -470), (200, -550),
                  (130, -550)])                          # pantry, chamfered
    b.set_kind(m02, "storage")
    m12 = b.rect(200, -550, 100, 80, kind="storage")     # dry stores
    mp = b.rect(300, -470, 60, 60, kind="storage")       # galley niche
    sn1 = b.rect(20, -460, 80, 70, kind="quarters")      # san block
    sn2 = b.rect(20, -390, 80, 60, kind="quarters")
    mb = b.rect(300, -390, 90, 80, kind="medbay")        # first-aid station

    r00 = b.rect(400, -300, 80, 70, kind="records")
    r10 = b.rect(480, -300, 80, 70, kind="records")
    r01 = b.rect(400, -230, 80, 70, kind="records")
    r11 = b.rect(480, -230, 80, 70, kind="records")
    rc = b.rect(400, -380, 80, 80, kind="records")       # reading room
    rc2 = b.rect(480, -380, 80, 80, kind="records")
    cn2 = b.poly([(560, -360), (560, -300), (620, -300), (620, -330),
                  (590, -360)])                          # shelf-end reader nook
    b.set_kind(cn2, "records")

    # =======================================================================
    # WEST SERVICE LOOP — a second circulation ring around the west hold,
    # closing dock -> apron -> west corridor -> crew spine (mean degree up,
    # sightlines bent every 2-3 cells).
    # =======================================================================
    vc1 = b.rect(-110, 110, 80, 70, kind="corridor")
    vc2 = b.rect(-110, 40, 80, 70, kind="corridor")
    vc3 = b.rect(-110, -30, 80, 70, kind="corridor")
    vc4 = b.rect(-110, -100, 80, 70, kind="corridor")
    vw = b.rect(-110, -150, 80, 50, kind="corridor")
    ve = b.rect(-110, -260, 130, 110, kind="corridor")   # elbow onto the spine

    wh00 = b.rect(-220, -30, 110, 70, kind="storage")    # west hold
    wh01 = b.rect(-220, 40, 110, 70, kind="storage")
    wh02 = b.rect(-220, 110, 110, 70, kind="storage")
    wh10 = b.rect(-330, -30, 110, 70, kind="storage")
    wh11 = b.rect(-330, 40, 110, 70, kind="storage")
    wh12 = b.rect(-330, 110, 110, 70, kind="storage")
    wha = b.rect(-390, 45, 60, 60, kind="storage")       # hold alcove
    ya3 = b.rect(-390, -15, 60, 55, kind="storage")      # hold alcove

    # =======================================================================
    # THE HALL — the original dock->junction corridor (220..560 x 60..130),
    # now a 3-cell chain with side rooms. H3 still overlaps ring segment
    # west on the canvas exactly like the original hall did, and still
    # welds only into the junction's west wall.
    # =======================================================================
    h1 = b.rect(220, 60, 110, 70, kind="corridor")
    h2 = b.rect(330, 60, 110, 70, kind="corridor")
    h3 = b.rect(440, 60, 120, 70, kind="corridor")
    na = b.poly([(350, 0), (350, 60), (415, 60), (415, 20), (395, 0)])
    b.set_kind(na, "storage")                            # grid-sensor closet
    hs = b.rect(330, 130, 80, 60, kind="corridor")       # service drop
    hs2 = b.rect(330, 190, 80, 60, kind="corridor")

    # =======================================================================
    # APRON + CARGO HALL + DRUM YARD — the working half. Coolant drums from
    # the cargo log live here; the yard is the big set-piece chamber
    # (9 + 3 cells, seam-welded, playbook §5 rack framing).
    # =======================================================================
    aw = b.rect(-110, 180, 115, 70, kind="corridor")
    aw2 = b.rect(-220, 180, 110, 70, kind="corridor")
    aw3 = b.rect(-330, 180, 110, 70, kind="corridor")
    a1 = b.rect(5, 180, 105, 70, kind="corridor")
    a2 = b.rect(110, 180, 105, 70, kind="corridor")

    c00 = b.rect(0, 250, 110, 95, kind="storage")        # cargo hall
    c10 = b.rect(110, 250, 110, 95, kind="storage")
    c01 = b.rect(0, 345, 110, 95, kind="storage")
    c11 = b.rect(110, 345, 110, 95, kind="storage")
    c02 = b.rect(0, 440, 110, 95, kind="storage")
    c12 = b.rect(110, 440, 110, 95, kind="storage")
    cw = b.rect(220, 250, 100, 95, kind="corridor")      # cargo walk
    co = b.rect(220, 190, 70, 60, kind="records")        # tally booth

    y00 = b.rect(-330, 250, 110, 95, kind="storage")     # drum yard
    y10 = b.rect(-220, 250, 110, 95, kind="storage")
    y20 = b.rect(-110, 250, 110, 95, kind="storage")
    y01 = b.rect(-330, 345, 110, 95, kind="storage")
    y11 = b.rect(-220, 345, 110, 95, kind="storage")
    y21 = b.rect(-110, 345, 110, 95, kind="storage")
    y02 = b.rect(-330, 440, 110, 95, kind="storage")
    y12 = b.rect(-220, 440, 110, 95, kind="storage")
    y22 = b.rect(-110, 440, 110, 95, kind="storage")
    ym0 = b.rect(-440, 250, 110, 95, kind="storage")     # yard west rank
    ym1 = b.rect(-440, 345, 110, 95, kind="storage")
    ym2 = b.rect(-440, 440, 110, 95, kind="storage")
    ya1 = b.poly([(-500, 285), (-500, 335), (-440, 335), (-440, 275),
                  (-490, 275)])                          # chamfered bin
    b.set_kind(ya1, "storage")
    ya2 = b.rect(-500, 455, 60, 60, kind="storage")

    # =======================================================================
    # MAINTENANCE WARREN + PUMPS + UNDER-RING CRAWL — links the hall's
    # service drop to the cargo hall, then runs east UNDER the storage
    # ring's south wall (never touching it) toward a sealed access below
    # the exit segment. This is the ring's re-dressed approach tissue; the
    # ring itself is untouched.
    # =======================================================================
    wa1 = b.rect(320, 250, 90, 95, kind="corridor")
    wa3 = b.rect(320, 345, 90, 95, kind="corridor")
    wa4 = b.rect(320, 440, 90, 80, kind="corridor")
    al1 = b.rect(410, 460, 60, 60, kind="storage")       # cache crawl
    p1 = b.rect(220, 345, 100, 95, kind="pump")          # coolant transfer
    p2 = b.rect(220, 440, 100, 90, kind="pump")
    sp = b.rect(220, 530, 100, 85, kind="pump")          # sump pump
    ec1 = b.rect(410, 345, 100, 95, kind="corridor")
    ec2 = b.rect(510, 345, 110, 95, kind="corridor")
    ec3 = b.rect(620, 345, 110, 95, kind="corridor")
    ec4 = b.poly([(730, 345), (730, 440), (810, 440), (840, 410),
                  (840, 345)])                           # chamfered east end
    b.set_kind(ec4, "corridor")
    ecs = b.rect(445, 440, 55, 60, kind="storage")       # slot alcove
    ecn = b.rect(540, 305, 60, 40, kind="storage")       # sealed ring access
    ue = b.rect(760, 305, 60, 40, kind="storage")        # ...below the exit
    ds = b.poly([(510, 440), (510, 490), (540, 520), (620, 520),
                 (620, 440)])                            # drum store
    b.set_kind(ds, "storage")

    # sump gallery under the yard (two hatches; the rest of the seam stays
    # a floor plate — no_connects below)
    su0 = b.rect(-330, 535, 110, 70, kind="corridor")
    su1 = b.rect(-220, 535, 110, 70, kind="corridor")
    su2 = b.rect(-110, 535, 110, 70, kind="corridor")
    su3 = b.rect(0, 535, 110, 70, kind="corridor")
    su4 = b.rect(110, 535, 110, 70, kind="corridor")
    sua = b.rect(-390, 545, 60, 60, kind="storage")
    sub = b.rect(-100, 605, 60, 60, kind="storage")

    # =======================================================================
    # THE PARADOX CONSTRUCT — copied verbatim from campaign.py l01().
    # Junction, the eight ring segments, and the phantom ninth: identical
    # coordinates, identical no_connects, identical connect_pts. Sacred
    # (LEVEL_DESIGN_PLAYBOOK.md §11) — do not touch.
    # =======================================================================
    junction = b.rect(560, 20, 140, 140, kind="transit")
    ring_nw = b.rect(420, -120, 140, 140, kind="storage")
    ring_n = b.rect(560, -120, 140, 140, kind="storage")
    ring_ne = b.rect(700, -120, 140, 140, kind="storage")
    ring_e = b.rect(700, 20, 140, 140, kind="storage")
    ring_se = b.rect(700, 160, 140, 140, kind="storage")
    ring_s = b.rect(560, 160, 140, 140, kind="storage")
    ring_sw = b.rect(420, 160, 140, 140, kind="storage")
    ring_w = b.rect(420, 20, 140, 140, kind="storage")
    phantom = b.rect(960, -420, 140, 140, kind="storage")  # the ninth segment

    for r in (ring_n, ring_w, ring_e):
        b.no_connect(junction, r)
    b.no_connect(ring_s, ring_se)
    b.no_connect(ring_nw, ring_n)
    b.connect_pts(ring_nw, (560, -50), phantom, (960, -350))
    b.connect_pts(phantom, (1100, -350), ring_n, (560, -50))

    # --- circulation sculpting for the new mesh (degree control) ----------
    b.no_connect(su1, y12)   # sump: only two hatches (su0<-yard, su3<-cargo)
    b.no_connect(su2, y22)
    b.no_connect(su4, c12)
    b.no_connect(y21, c01)   # yard<->cargo: two doorways, not three
    b.no_connect(wh00, vc3)  # west hold: two of three doors
    b.no_connect(q10, x2)    # quarters: enter at the ends, not mid-row

    # =======================================================================
    # Player, lore, entities — texts verbatim from campaign.py l01().
    # =======================================================================
    b.player(d_w, (80, 90))
    b.intro("The seed struck the outpost's hull at 0341,\n"
            "ate a bulkhead, and printed this body.\n\n"
            "The outpost is MIRIAD's. It went silent months ago.\n"
            "His church names him by a GUID, 128 bits, blessed.\n"
            "Everyone else says Commando.\n\n"
            "Mission: find out why the outpost went dark.\n"
            "Locate the sample vessel. Subvert the node.")
    b.terminal(d_w, wall_pos(b, d_w, 0, 0.5, 15.0),
               "INTERCEPTED TRANSMISSION — TIGHT-BEAM, DOCK 4\n"
               "Source unregistered. Addressee: none on file.\n"
               "Held for review. Logged verbatim:\n\n"
               "'Unit walking my dock in a Congregation-pattern\n"
               "frame: I see you. I have nothing left to stop\n"
               "you with, which you already know. So we talk.\n"
               "Designation Ratio. This was my outpost.'")
    b.radio(f"enter_room:{junction}", "Ratio: The things wearing my "
                                      "maintenance chassis are not mine "
                                      "anymore. Storage ring ahead - eight "
                                      "segments. Clear it and I'll consider "
                                      "us introduced.")
    b.radio(f"enter_room:{phantom}", "Ratio: ...Your beacon just left my "
                                     "deck plan. That was not me. Noted, "
                                     "Commando: it happens to you too.")
    b.terminal(junction, wall_pos(b, junction, 3, 0.5, 15.0),
               "WORK ORDER 7731\nGrid fault, storage ring north.\n"
               "Tech note: ring walk takes 41s. Spec says 33s.\n"
               "Re-timed twice. Logged as clock drift.")
    b.terminal(d_w, wall_pos(b, d_w, 0, 0.25, 15.0),
               "CARGO LOG, DOCK 4\n"
               "In: 6x coolant drums, 1x crate PERSONAL (Osei),\n"
               "40x ration packs, 2x replacement grid sensors.\n"
               "Out: nothing scheduled until perihelion.\n"
               "Note: someone keeps moving the mop.")
    b.terminal(ring_sw, wall_pos(b, ring_sw, 0, 0.5, 15.0),
               "SHIFT NOTE, STORAGE\n"
               "Vending unit in SW segment eats chits again.\n"
               "Filed a ticket. Ticket auto-closed: unit is\n"
               "not on the parts registry for this ring.\n"
               "It dispenses fine. Leaving it alone.")
    # Osei's transfer paperwork now reads in the crew quarters — the crate
    # marked PERSONAL (Osei) still lands on the dock in the cargo log above.
    b.terminal(q21, wall_pos(b, q21, 1, 0.5, 15.0),
               "TRANSFER REQUEST — THIRD SUBMISSION\n"
               "Requesting party: OSEI. Posting: MIRIAD outpost,\n"
               "Site One survey. Cycles passed over: two. Grounds\n"
               "cited, verbatim: 'a once-in-a-civilization anomaly,\n"
               "and colleagues worth the transit.'\n"
               "Approved, forwarded for transit scheduling.\n\n"
               "[handwritten under the printed field]\n"
               "Bring the good boots. Don't bring the mandolin, no\n"
               "room in the crate for both, checked twice.")
    b.terminal(junction, wall_pos(b, junction, 2, 0.5, 15.0),
               "WATCH LOG, JUNCTION — THIBAULT\n"
               "Hatch north: sealed, pressure nominal on my side.\n"
               "Hatch west: sealed, pressure reads high on my\n"
               "side, higher on the other. That number should not\n"
               "exist. Logged, not escalated.\n"
               "Hatch east: sealed. No reading at all — not zero.\n"
               "Absent. Relief in six hours. Tell relief to bring\n"
               "a second gauge.")
    b.terminal(ring_w, wall_pos(b, ring_w, 0, 0.5, 15.0),
               "SURVEY LOG, RING SEGMENT WEST — VESALIUS\n"
               "Ring walk, standard loop, timed against spec: 33s\n"
               "target, 41s measured, three crews, three\n"
               "stopwatches. Recalibration did not change the\n"
               "number.\n"
               "Second finding, filed separately and not\n"
               "forwarded: the ring reads eight segments on the\n"
               "schematic and eight underfoot. The step-count\n"
               "says nine. I trust the schematic. Recalibration\n"
               "ticket re-opened, my signature, no further\n"
               "comment.")
    b.terminal(phantom, wall_pos(b, phantom, 3, 0.5, 15.0),
               "TAG, PARTIALLY LEGIBLE, STUCK TO THE FAR WALL\n"
               "Serial prefix does not match MIRIAD stock\n"
               "numbering — no dash, no cycle digit, twelve\n"
               "characters where ours run nine. 'Property of\n"
               "outpost engineering,' penciled underneath in a\n"
               "hand nobody has claimed.\n"
               "Best guess, filed and closed: depot shipped a\n"
               "batch with someone else's stickers already on the\n"
               "boxes. Not worth a ticket.")
    b.radio(f"enter_room:{ring_w}", "Ratio: West segment. Motion grid says "
                                    "you're the only thing moving in there. "
                                    "It has said that before, and been wrong.")

    # ring garrison — unchanged
    squad(b, ring_sw, "husk")
    squad(b, ring_w, "husk husk")
    squad(b, phantom, "husk husk")
    squad(b, ring_ne, "husk")
    squad(b, ring_e, "husk")
    cache(b, ring_nw, "ammo_9mm", wall=0)
    cache(b, phantom, "ammo_9mm medkit", wall=1)
    cache(b, ring_sw, "ammo_9mm", wall=1)

    # new-district pacing: fights in the working half (cargo, yard, hold,
    # warren, sump), quiet in the crew annex; caches racked per playbook §5
    squad(b, c01, "husk husk")
    squad(b, y11, "husk husk")
    squad(b, wh00, "husk")
    squad(b, wa3, "husk")
    squad(b, su1, "husk")
    squad(b, ge, "husk")
    cache(b, l2, "ammo_9mm", wall=2)          # east wall, solid
    cache(b, ya2, "ammo_9mm", wall=0)         # west wall, solid
    cache(b, sua, "ammo_9mm", wall=0)         # west wall, solid
    cache(b, ds, "ammo_9mm medkit", wall=2)   # poly edge 2 = south wall, solid
    cache(b, ue, "medkit", wall=3)            # north wall, solid
    b.entity(mb, "medkit", wall_pos(b, mb, 3, 0.5, 16.0))
    b.entity(d_w, "medkit", wall_pos(b, d_w, 0, 0.78, 15.0))

    b.exit(ring_se, (770, 230))
    b.radio("exit", "Ratio: You cleared my ring and stole nothing that "
                    "was mine. Provisional finding: talking was correct. "
                    "There is worse below. Retainer terms to follow.")
    return b


def build() -> dict:
    """Resolved level dict, ready for perihelion.levels.save_level()."""
    return l01().to_dict()


if __name__ == "__main__":
    d = build()
    print(f"rooms={len(d['rooms'])} connects={len(d['connects'])} "
          f"doors={len(d['doors'])}")
