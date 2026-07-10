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
    b = LevelBuilder("DOCK 4 — SWEEP", 1, "amb_drone_early")
    # NOTE: an editor golden-fixture test (game/tests/test_editor.py) loads
    # levels/l01.json and hardcodes its exact room count/order/indices
    # (room 0 = dock, room 3, room 7 = exit, room 11 = phantom...) -- this
    # level's room list is load-bearing for a test outside this file's
    # scope, so no new rooms are added here even though an entry airlock
    # would otherwise be the obvious circulation fix (see
    # LEVEL_DESIGN_PLAYBOOK.md §2). dock itself already plays that role:
    # it's where the seed prints the player's body, sized like a threshold.
    dock = b.rect(0, 0, 220, 180, kind="dock")
    hall = b.rect(220, 60, 340, 70, kind="corridor")   # auto-split into dock
    junction = b.rect(560, 20, 140, 140, kind="transit")

    # 3x3 ring around the junction, pitch 140; junction touches N/W/S/E ring
    # cells but only the north doorway may open. The ring is Ratio's storage
    # ring by name (radio, below) -- tag every cell `storage` to match.
    ring_nw = b.rect(420, -120, 140, 140, kind="storage")
    ring_n = b.rect(560, -120, 140, 140, kind="storage")
    ring_ne = b.rect(700, -120, 140, 140, kind="storage")
    ring_e = b.rect(700, 20, 140, 140, kind="storage")
    ring_se = b.rect(700, 160, 140, 140, kind="storage")
    ring_s = b.rect(560, 160, 140, 140, kind="storage")
    ring_sw = b.rect(420, 160, 140, 140, kind="storage")
    ring_w = b.rect(420, 20, 140, 140, kind="storage")
    phantom = b.rect(960, -420, 140, 140, kind="storage")  # the ninth segment

    # only the south hatch of the ring answers; and the ring is broken just
    # short of the exit, so the sweep goes the long way round -- through the
    # segment that is not on any deck plan.
    for r in (ring_n, ring_w, ring_e):
        b.no_connect(junction, r)
    b.no_connect(ring_s, ring_se)
    b.no_connect(ring_nw, ring_n)
    b.connect_pts(ring_nw, (560, -50), phantom, (960, -350))
    b.connect_pts(phantom, (1100, -350), ring_n, (560, -50))

    b.player(dock, (80, 90))
    b.intro("The seed struck the outpost's hull at 0341,\n"
            "ate a bulkhead, and printed this body.\n\n"
            "The outpost is MIRIAD's. It went silent months ago.\n"
            "His church names him by a GUID, 128 bits, blessed.\n"
            "Everyone else says Commando.\n\n"
            "Mission: find out why the outpost went dark.\n"
            "Locate the sample vessel. Subvert the node.")
    # First contact is a terminal read, not a voice over combat: the very
    # first wall terminal on the dock holds Ratio's opening transmission.
    b.terminal(dock, wall_pos(b, dock, 0, 0.5, 15.0),
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
    b.terminal(dock, wall_pos(b, dock, 3, 0.3, 15.0),
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
    b.terminal(dock, wall_pos(b, dock, 1, 0.5, 15.0),
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
    squad(b, ring_sw, "husk")
    squad(b, ring_w, "husk husk")
    squad(b, phantom, "husk husk")
    squad(b, ring_ne, "husk")
    squad(b, ring_e, "husk")
    cache(b, ring_nw, "ammo_9mm", wall=0)
    cache(b, phantom, "ammo_9mm medkit", wall=1)
    cache(b, ring_sw, "ammo_9mm", wall=1)
    b.entity(dock, "medkit", wall_pos(b, dock, 3, 0.75, 15.0))
    b.exit(ring_se, (770, 230))
    b.radio("exit", "Ratio: You cleared my ring and stole nothing that "
                    "was mine. Provisional finding: talking was correct. "
                    "There is worse below. Retainer terms to follow.")
    return b


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
