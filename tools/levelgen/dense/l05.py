"""L5 — TWO WINGS, rebuilt to Marathon density (MARATHON_LEVEL_STANDARDS.md).

Standalone rebuild of campaign.py's l05(): the nine skeleton rooms (lobby,
w1-w3, e1-e3, chapel, bunk_f), every terminal/radio/key/cache/squad of the
original, and the paradox construct (two wings occupying one volume: the
lobby's impossible east door into e1's far wall, and the chapel's two doors
that cannot share a wall) are preserved verbatim — same creation order, so
room indices in radio triggers still point at the same rooms.

Around that skeleton, each wing grows an IDENTICAL ~50-cell service district
(translation by +1360, the same offset that separates the authored wings —
identical districts are the fiction: the wing is drawn twice), and the lobby
grows a ~33-cell deck-services district. Cell grammar per the standards:
90 u median cells, corridor chains that bend every 2-3 cells, 80 u doors /
40-60 u slots / 130+ u subdivision seams, ~10% dead-end alcoves, quads
throughout, kinds assigned in coherent districts (bunk rows = quarters,
service spine = corridor, laundry = pump, deck office = records, linen and
luggage alcoves = storage, infirmary nook = medbay).

Paradox-safety rules obeyed here (LEVEL_DESIGN_PLAYBOOK.md §11):
  - no new geometry touches any wall carrying an explicit connect point
    (lobby east x=220, e1 east x=1360, w3 south y=170, e3 west x=820,
    chapel north/east) nor their west-wing mirror twins (w3 west x=-540,
    w1 east x=0), nor w1/e1 north (the bunk_f shoot-door wall and its twin);
  - the east district attaches ONLY to e2/e3 — never to the lobby district —
    so the east wing stays reachable only through the impossible east door;
  - the chapel gains no connections at all: its west wall (160 u) and south
    wall (220 u) stay carvable for the streamer, as does the lobby's north
    wall (220 u) beside the spawn.

The one deliberate mirror-break: the west spine's last cell opens into the
lobby annex; the east twin of that cell dead-ends. Silent, per standards §8.

Usage:  build() -> resolved level dict (what campaign.py feeds save_level);
        l05()  -> the LevelBuilder (same contract as campaign.l05).
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "game"))

from perihelion.levels import LevelBuilder  # noqa: E402

# ---------------------------------------------------------------------------
# helpers copied from tools/levelgen/campaign.py (this module is standalone)
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
# the wing service district: stamped once per wing at x-offset dx.
# dx=0 -> west wing (w1/w2/w3); dx=1360 -> east wing (e1/e2/e3), the exact
# translation between the two authored wings, so both districts are the same
# rooms drawn twice — which is the level's whole complaint.
# ---------------------------------------------------------------------------

DX_EAST = 1360.0


def _wing_district(b: LevelBuilder, dx: float) -> dict:
    def R(x, y, w, h, kind):
        return b.rect(x + dx, y, w, h, kind=kind)

    d: dict = {}

    # --- south antechamber off the wing room's own south wall (y=170 is
    # NOT one of the reserved paradox walls -- only w3's south/west and
    # w1/e1's north are reserved). A 30 s AggroBot walk from spawn spends
    # most of its time fighting the squad in w1/e1 itself, so this is the
    # room that actually moves this level's median (rule 1): a real 180 u
    # doorway straight off the wing room, not a detour through the deck
    # junction slot. ---
    d["ws1"] = R(-180, 170, 180, 90, "quarters")
    d["ws2"] = R(-180, 260, 90, 90, "storage")
    d["ws3"] = R(-90, 260, 90, 90, "storage")
    d["ws4"] = R(-180, 350, 90, 80, "storage")
    d["ws5"] = R(-90, 350, 90, 80, "storage")

    # --- north maintenance band (attaches to w2's north wall only; w1's
    # north wall is the bunk_f secret and w3's carries e3's twin terminal) --
    d["nt2"] = R(-300, -30, 80, 40, "corridor")     # 80u door out of w2
    d["nc1"] = R(-300, -110, 80, 80, "transit")     # junction under bunk row
    d["nc2"] = R(-390, -110, 90, 80, "corridor")
    d["nc3"] = R(-480, -110, 90, 80, "corridor")
    d["nc4"] = R(-570, -110, 90, 80, "corridor")
    d["cb5"] = R(-650, -110, 80, 80, "transit")     # west elbow, 3 doors
    # bunks 10/11/13 off the corridor (bunk 12 is the wing room itself)
    d["cb1"] = R(-568, -190, 86, 80, "quarters")
    d["cb2"] = R(-478, -190, 86, 80, "quarters")
    d["cb3"] = R(-388, -190, 86, 80, "quarters")
    # footlocker niches (40-60u slot register) and a luggage alcove
    d["fl1"] = R(-470, -30, 50, 36, "storage")
    d["fl2"] = R(-360, -30, 50, 36, "storage")
    d["a_n1"] = R(-220, -96, 50, 52, "storage")
    # overhead service crawl looping the bunk row (two shafts, one cabin)
    d["mc0"] = R(-640, -260, 80, 60, "corridor")
    d["mc1a"] = R(-560, -260, 60, 60, "corridor")
    d["mc1b"] = R(-500, -260, 60, 60, "corridor")
    d["mc2a"] = R(-440, -260, 60, 60, "corridor")
    d["mc2b"] = R(-380, -260, 60, 60, "corridor")
    d["mc3"] = R(-320, -260, 110, 60, "corridor")
    d["sh1"] = R(-640, -200, 60, 90, "corridor")    # down-shaft to cb5
    d["sh2"] = R(-270, -200, 50, 90, "corridor")    # down-shaft to nc1
    d["cb4"] = R(-210, -260, 90, 60, "quarters")    # bunk 14, off the crawl

    # --- west wrap: around the wing's far end, north band -> south spine
    # (chained ~55-65u cells: corridors are chains, not rectangles) ---
    d["wr1a"] = R(-650, -30, 80, 55, "corridor")
    d["wr1b"] = R(-650, 25, 80, 55, "corridor")
    d["wr2a"] = R(-650, 80, 80, 65, "corridor")
    d["wr2b"] = R(-650, 145, 80, 65, "corridor")
    d["wr3"] = R(-650, 210, 80, 80, "corridor")

    # --- service spine, y 210..290, a dead 40u structural strip between it
    # and the wing rooms (their south walls stay solid: terminals live there)
    d["s1a"] = R(-570, 210, 50, 80, "corridor")
    d["s1b"] = R(-520, 210, 60, 80, "corridor")
    d["s2"] = R(-460, 210, 110, 80, "corridor")
    d["s3"] = R(-350, 210, 90, 80, "corridor")
    d["s4"] = R(-260, 210, 110, 80, "corridor")
    d["s5"] = R(-150, 210, 110, 80, "corridor")
    d["s6"] = R(-40, 210, 80, 80, "corridor")  # west: opens to lobby annex;
    #                                            east twin: sealed. the tell.
    d["al4"] = R(-240, 174, 60, 36, "storage")      # strip alcoves (4u shy
    d["al5"] = R(-520, 174, 60, 36, "storage")      # of the wing walls)

    # --- deck office / laundry / bunk annex off the spine ---
    d["o1"] = R(-650, 290, 80, 80, "records")
    d["o2"] = R(-650, 370, 80, 80, "records")
    d["q1"] = R(-455, 290, 80, 80, "quarters")      # bunk 15, off-spine pair
    d["q2"] = R(-455, 370, 80, 70, "quarters")
    d["p1"] = R(-255, 290, 80, 50, "pump")          # water reclaim pair
    d["p2"] = R(-335, 290, 80, 50, "pump")

    # --- south block: common room + washrooms ---
    d["dn"] = R(-150, 290, 80, 50, "corridor")
    d["sc1"] = R(-150, 340, 80, 80, "corridor")
    d["sc2"] = R(-230, 340, 80, 80, "corridor")
    d["sc3"] = R(-70, 340, 110, 80, "corridor")
    d["sc0"] = R(-310, 340, 80, 80, "corridor")
    d["wb1"] = R(-310, 420, 80, 60, "pump")         # washroom
    d["aw"] = R(-360, 354, 50, 52, "storage")
    d["al2"] = R(-30, 296, 50, 44, "storage")       # linen closet
    d["cm1"] = R(-240, 420, 130, 130, "quarters")   # common room: 2x2
    d["cm2"] = R(-110, 420, 130, 130, "quarters")   # chamber, 130u seams,
    d["cm3"] = R(-240, 550, 130, 130, "quarters")   # one 80u door via sc2
    d["cm4"] = R(-110, 550, 130, 130, "quarters")
    d["cp"] = R(-240, 680, 60, 50, "storage")       # common-room pantry
    return d


# ---------------------------------------------------------------------------
# the lobby deck-services district (west side only: the east wing's only way
# in must stay the lobby's impossible east door)
# ---------------------------------------------------------------------------


def _lobby_district(b: LevelBuilder) -> dict:
    d: dict = {}
    d["lt"] = b.rect(70, 180, 80, 40, kind="corridor")   # 80u door, lobby S
    d["h1"] = b.rect(40, 220, 150, 70, kind="transit")   # deck junction
    d["hc"] = b.rect(190, 220, 40, 70, kind="corridor")
    # mess hall: 2x3 chamber of 80x120 quads
    d["m11"] = b.rect(230, 200, 80, 120, kind="quarters")
    d["m21"] = b.rect(310, 200, 80, 120, kind="quarters")
    d["m31"] = b.rect(390, 200, 80, 120, kind="quarters")
    d["m12"] = b.rect(230, 320, 80, 120, kind="quarters")
    d["m22"] = b.rect(310, 320, 80, 120, kind="quarters")
    d["m32"] = b.rect(390, 320, 80, 120, kind="quarters")
    d["st2"] = b.rect(470, 230, 70, 60, kind="storage")  # pantry slot
    d["mt"] = b.rect(230, 440, 80, 30, kind="corridor")  # mess back stair
    # service corridor loop
    d["v1"] = b.rect(70, 290, 80, 90, kind="corridor")
    d["v2"] = b.rect(70, 380, 80, 90, kind="corridor")
    d["v3"] = b.rect(70, 470, 80, 80, kind="corridor")
    d["v4"] = b.rect(150, 470, 80, 80, kind="corridor")
    d["v5"] = b.rect(230, 470, 80, 80, kind="corridor")
    d["v6"] = b.rect(310, 470, 90, 80, kind="corridor")
    d["v6b"] = b.rect(400, 470, 100, 80, kind="corridor")
    d["v_s"] = b.rect(70, 550, 80, 90, kind="corridor")
    d["mb1"] = b.rect(150, 300, 80, 80, kind="medbay")   # infirmary nook
    d["mb2"] = b.rect(150, 380, 80, 60, kind="medbay")
    d["av1"] = b.rect(20, 380, 50, 60, kind="storage")
    d["rc1"] = b.rect(-10, 290, 50, 60, kind="records")  # mail slots
    # laundry block + quartermaster's corner (a loop)
    d["pl1"] = b.rect(500, 470, 90, 80, kind="pump")
    d["pl2"] = b.rect(500, 390, 90, 80, kind="pump")
    d["qm1"] = b.rect(590, 390, 80, 80, kind="records")
    d["qm2"] = b.rect(590, 470, 80, 80, kind="storage")
    # stores run along the south edge
    d["g1"] = b.rect(150, 550, 120, 90, kind="corridor")
    d["g2"] = b.rect(270, 550, 120, 90, kind="corridor")
    d["g3"] = b.rect(390, 550, 110, 90, kind="corridor")
    d["sr1"] = b.rect(170, 640, 80, 80, kind="storage")
    d["sr2"] = b.rect(290, 640, 80, 80, kind="storage")
    d["sr3"] = b.rect(410, 640, 80, 80, kind="storage")
    return d


# ---------------------------------------------------------------------------
# L5 — TWO WINGS. Two wings, one volume. Rail gun.
# ---------------------------------------------------------------------------


def l05() -> LevelBuilder:
    b = LevelBuilder("TWO WINGS", 3, "amb_drone_mid")
    # --- skeleton: identical rooms, identical creation order, identical
    # connections to campaign.l05 (room indices feed the radio triggers) ---
    lobby = b.rect(0, 0, 220, 180, kind="corridor")
    w1 = b.rect(-180, 10, 180, 160, kind="quarters")
    w2 = b.rect(-360, 10, 180, 160, kind="quarters")
    w3 = b.rect(-540, 10, 180, 160, kind="quarters")
    e1 = b.rect(1180, 10, 180, 160, kind="quarters")
    e2 = b.rect(1000, 10, 180, 160, kind="quarters")
    e3 = b.rect(820, 10, 180, 160, kind="quarters")
    chapel = b.rect(-540, 300, 220, 160, kind="chapel")

    bunk_f = b.rect(-160, -110, 140, 120, kind="quarters")  # the third twelve, flush above w1
    b.door_pts(w1, (-90, 10), bunk_f, (-90, 10), "shoot")
    b.no_connect(w1, bunk_f)
    b.connect_pts(lobby, (220, 90), e1, (1360, 90))   # east door, impossible
    b.connect_pts(w3, (-450, 170), chapel, (-430, 300))
    b.connect_pts(e3, (820, 90), chapel, (-320, 380))  # east wall of chapel
    # the "gold key" is the deck steward's hatch key; the chapel doubles as
    # the deck's pressure refuge and the way out is its aft refuge hatch.
    # The steward bunks in 12 — and bunk 12, like everything on this deck,
    # exists twice (directory terminal below; both wings hold the key).
    b.key_meta("gold", "STEWARD'S KEY", "REFUGE HATCH",
               "REFUGE HATCH SEALED - STEWARD'S KEY REQUIRED",
               "ACQUIRED: STEWARD'S KEY")

    # --- the mesh: one wing district stamped twice, one lobby district ---
    west = _wing_district(b, 0.0)
    east = _wing_district(b, DX_EAST)
    deck = _lobby_district(b)

    b.player(lobby, (110, 90))
    b.intro("Crew quarters. West wing and east wing.\n"
            "The station schematic shows one wing.\nIt is drawn twice, in two colors.")
    b.terminal(w1, wall_pos(b, w1, 1, 0.5, 15.0),
               "BUNK 12-W\nDear M — the man in 12-E snores. I hear him\n"
               "through the wall. 12-E is on the other side of\nthe station. — R")
    b.terminal(e1, wall_pos(b, e1, 1, 0.5, 15.0),
               "BUNK 12-E\nDear R — I do not snore. And I hear your\n"
               "radio through the wall. Fix your wall. — M")
    b.terminal(e2, wall_pos(b, e2, 1, 0.5, 15.0),
               "DRAFT 41 — TO: MIRIAD PRIME [UNSENT]\n"
               "Progress report. I have written this report\n"
               "forty times. Each time, the numbers describing\n"
               "this place come out different. I cannot send my\n"
               "parent a report that lies, and I cannot make the\n"
               "numbers stop lying. Draft 42 tomorrow. — R")
    b.terminal(bunk_f, (-110, -100),
               "BUNK 12-F\nThere is no bunk 12-F on the manifest.\n"
               "Dear R, dear M — you are both right.\n"
               "I hear you both through my walls,\n"
               "and my walls touch neither of yours.\n"
               "I stopped filing complaints. Enjoy the cache. — F")
    cache(b, bunk_f, "ammo_cell ammo_cell medkit ammo_shell")
    b.terminal(lobby, wall_pos(b, lobby, 3, 0.5, 15.0),
               "WING DIRECTORY, POSTED AT THE LOBBY DOOR\n"
               "WEST WING: bunks 10 through 15, common room,\n"
               "chapel access.\n"
               "EAST WING: bunks 10 through 15, common room,\n"
               "chapel access.\n"
               "PRESSURE REFUGE: the chapel, aft hatch. Hatch\n"
               "key held by the deck steward, bunk 12.\n"
               "Directory printed once. Read twice by mistake,\n"
               "corrected, read twice again. Facilities notified.\n"
               "Facilities printed a second copy, identical, and\n"
               "hung it under the first.")
    # LLM-generated verbatim (Hermes-4-405B via OpenRouter; see
    # tools/dialogue/generate.py for the call pattern this one-off script
    # copied) -- content-normalized similarity to the raw candidate: 1.0000.
    # Seed beat 1/3 of the docent-voice arc (l05-l07): a scheduling
    # coincidence nobody escalates.
    b.terminal(lobby, wall_pos(b, lobby, 1, 0.85, 15.0),
               "FACILITIES LOG AUDIT\n"
               "Cross-referenced reconfiguration events with\n"
               "duty rosters. No maintenance shifts or\n"
               "staffing changes correspond. Events occur at\n"
               "fixed intervals, 14 hours apart. No\n"
               "equipment cycles or procedures match this\n"
               "interval. Filed as scheduling irregularity.\n"
               "No further action required.")
    b.terminal(e3, wall_pos(b, e3, 3, 0.5, 15.0),
               "FACILITIES WORK ORDER, BUNK REASSIGNMENT\n"
               "Complaint: resident of 12-E reports resident of\n"
               "12-W audible through shared wall. Wings do not\n"
               "share a wall.\n"
               "Complaint: resident of 12-W reports the same,\n"
               "reversed.\n"
               "Action taken: swapped both residents to bunk 14.\n"
               "Follow-up, six days later: same complaint, new\n"
               "bunk numbers. Action taken: closed the ticket.\n"
               "Recommend residents adjust.")
    squad(b, w1, "husk husk")
    squad(b, w2, "husk mite mite mite")
    squad(b, w3, "brute")
    cache(b, w1, "medkit")
    squad(b, e1, "spitter husk")
    squad(b, e2, "husk husk")
    squad(b, e3, "spitter husk")
    squad(b, chapel, "spitter husk")
    cache(b, w2, "ammo_9mm ammo_shell")
    cache(b, e2, "medkit ammo_9mm")
    cache(b, w3, "ammo_shell")
    # chapel has two independent entries (north from w3, east from e3) and
    # the run only ever walks ONE wing before the gold key it needs -- a
    # single cache can sit unreached on the wing not taken, so the rail and
    # the hole are each racked at both doorways rather than once at center.
    cache(b, chapel, "weapon_rail ammo_cell medkit portable_hole", off=(0, -70))
    cache(b, chapel, "weapon_rail ammo_cell portable_hole", off=(105, 0))
    b.terminal(chapel, wall_pos(b, chapel, 0, 0.35, 15.0),
               "FIELD NOTE, TAPED TO A DEVICE\n"
               "Ad-hoc connection applicator, unit 3 of 3.\n"
               "Mark a wall. Mark another wall. Walk through.\n"
               "Units 1 and 2 are why the east wing has a\n"
               "draft. Do not tell facilities.")
    # two identical steward's keys, in the same bunk, in both wings
    b.entity(w1, "key_gold", (-90, 40))
    b.entity(e1, "key_gold", (1270, 40))
    b.exit(chapel, (-430, 420), key="gold")

    # --- district population: pacing off the critical path (lobby -> w1
    # key -> w2 -> w3 -> chapel), quiet beats left quiet on the east copy ---
    squad(b, west["nc3"], "husk husk")            # bunk-row loiterers
    squad(b, west["cm2"], "husk mite mite")       # west common room
    squad(b, deck["m22"], "mite mite mite")       # mess infestation
    squad(b, deck["g2"], "spitter")               # stores run
    squad(b, east["cm2"], "husk husk")            # the same room, again
    cache(b, deck["sr2"], "ammo_9mm ammo_shell", wall=1)
    cache(b, west["a_n1"], "ammo_9mm", wall=2)
    cache(b, east["a_n1"], "medkit", wall=2)      # identical alcove, other
    cache(b, east["cp"], "ammo_shell", wall=1)    # contents: the tell again
    return b


def build() -> dict:
    """Resolved level dict — feed straight to perihelion.levels.save_level,
    exactly as campaign.py does with b.to_dict()."""
    return l05().to_dict()


if __name__ == "__main__":
    d = build()
    print(f"rooms={len(d['rooms'])} connects={len(d['connects'])} "
          f"doors={len(d['doors'])}")
