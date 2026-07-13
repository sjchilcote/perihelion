"""tools/musiccal/build_gauntlet.py — assembles levels/gauntlet_cal.json.

The director's calibration design (verbatim, 2026-07-13): "take a subset of
mid-game segments and assemble them together, with rest and recharge
lootrooms in the middle of long, safe corridors dividing them."

Six combat clusters are copied (geometry + enemy spawns, never referenced)
from the shipped mid-game levels l04-l07, chosen by connected-component
clustering over each level's room graph (a cluster = enemy-bearing rooms
within 2 hops of each other via plain `connects`, excluding connects_x/
keyed-door edges so the copy is a plain, robust Euclidean patch):

  B: l06 rooms [18,19,20]              3 enemies  (husk/mite/spitter)  — light
  A: l04 rooms [4,55,56]               7 enemies  (husk x4/mite x2/spitter) — trash+1
  C: l07 rooms [2,214]                 4 enemies  (spitter x2/husk x2) — ranged
  D: l07 rooms [13,16,17,18,20,21,22]  7 enemies  (husk x4/flicker x2/mite) — dread
  E: l05 rooms [1,2,3,4,5,6,7]         15 enemies (husk x8/mite x3/brute/spitter x3) — big
  F: l06 rooms [170,171,172]           7 enemies  (husk x4/spitter/brute/shrieker) — elite

Ordered B,A,C,D,E,F (roughly increasing difficulty) and joined by seven
identical stub-loot-stub corridors (start -> seg0, between each pair, and
segN -> exit) — each corridor's middle room carries 2 medkits + one stack
of each ammo type (health + ammo per the brief; no weapons, since a
mid-game *loadout* is a run_farm.py `player_state` concern, not a level-
content one — see run_farm.py's docstring).

Geometry: each segment/corridor occupies its own, far-apart canvas band
(20000 units per segment slot; corridors live in a disjoint y>=60000
band). This is the "mind the autoconnect no_connect gate" trap the brief
calls out — LevelBuilder.resolve() autoconnects any exactly-coincident
edge pair in the WHOLE level, not just intentionally-adjacent rooms; two
unrelated pieces that happen to land on top of each other would get
silently wired together. Every intentional connection here is explicit
(`b.connect(room, edge, room, edge)`, using edge indices this script
verified by hand against each source level's raw JSON — see
`tools/musiccal/` scratch analysis in the commit log), so nothing relies
on coincidence-autoconnect at all; the large spacing is pure defense in
depth, and `main()` asserts the resolved connects count matches what was
explicitly authored (fails loudly if an unwanted autoconnect sneaks in).

Density: `--density` scales the gauntlet's enemy COUNT (never stats) down
from the source rosters (43 enemies total at density=1.0) — the director's
tuning knob ("keep adjusting it so the total clear rate is maybe 50%").
Enemies are dropped via a proportional-fair global ordering (`_fair_order`)
rather than independent per-room `round()`: an earlier version rounded
each room's `count * density` independently, and with ~20 rooms holding
just 1-4 enemies apiece, most of their rounding thresholds coincided at
density=0.25, so total enemy count (and clear rate) jumped discontinuously
there instead of scaling smoothly — see the docstring on `_fair_order` for
the fix and FITTING_REPORT.md's caveats section for the measured v1
numbers. The level's own content-generation seed is fixed (LEVEL_SEED) and
independent of
run_farm.py's per-run bot seeds: gauntlet_cal.json is static content,
rebuilt only when re-tuning density.

Run: uv run python tools/musiccal/build_gauntlet.py --density 1.0
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

from perihelion.levels import LevelBuilder, save_level  # noqa: E402

ENEMY_KINDS = {"husk", "mite", "spitter", "brute", "shrieker", "warden", "flicker"}

# (tag, source level stem, room indices to copy, entry (room,edge), exit (room,edge))
# entry/exit edges are hand-verified "usable" edges (not used by any connect
# internal to the chosen room set) from the source level's raw JSON.
SEGMENTS = [
    dict(tag="B", src="l06", rooms=[18, 19, 20], entry=(18, 0), exit=(20, 1)),
    dict(tag="A", src="l04", rooms=[4, 55, 56], entry=(4, 5), exit=(56, 1)),
    dict(tag="C", src="l07", rooms=[2, 214], entry=(2, 2), exit=(214, 7)),
    dict(tag="D", src="l07", rooms=[13, 16, 17, 18, 20, 21, 22],
         entry=(22, 2), exit=(20, 0)),
    dict(tag="E", src="l05", rooms=[1, 2, 3, 4, 5, 6, 7], entry=(1, 2), exit=(4, 2)),
    dict(tag="F", src="l06", rooms=[170, 171, 172], entry=(170, 1), exit=(172, 3)),
]

SEG_X_SPACING = 20000.0
CORR_Y_BASE = 60000.0
CORR_Y_SPACING = 2000.0
CORRIDOR_STUB_LEN = 320.0
CORRIDOR_WIDTH = 90.0
LOOT_SIZE = 220.0

LEVEL_SEED = 20260713  # fixed content seed; independent of run_farm bot seeds
OUT_DEFAULT = ROOT / "levels" / "gauntlet_cal.json"


def _load_raw(stem: str) -> dict:
    return json.loads((ROOT / "levels" / f"{stem}.json").read_text())


def _collect_enemy_pool(segments: list[dict]) -> list[dict]:
    """Every enemy entity across every segment, in a fixed global order,
    tagged with its room-local rank/room-size for `_fair_order`."""
    pool = []
    for si, seg in enumerate(segments):
        data = _load_raw(seg["src"])
        rooms = data["rooms"]
        for old_idx in seg["rooms"]:
            ents = [e for e in rooms[old_idx].get("entities", [])
                    if e["type"] in ENEMY_KINDS]
            for j, e in enumerate(ents):
                pool.append(dict(seg_idx=si, old_room=old_idx, entity=e,
                                 room_pos=j, room_size=len(ents)))
    return pool


def _fair_order(pool: list[dict]) -> list[dict]:
    """Sort key (room_pos+0.5)/room_size spreads each room's own entities
    evenly across (0,1) regardless of that room's size, so ANY prefix of
    the globally-sorted sequence is a proportionally fair sample across all
    rooms/segments -- no single room or segment drains first.

    This replaced an earlier per-room `round(count * density)` design: with
    ~20 rooms holding just 1-4 enemies each, independent per-room rounding
    put many rooms' rounding thresholds on the SAME density value (e.g.
    round(2*x): 0->1 for every 2-enemy room lands at x=0.25), so a 0.7%
    change in density (0.2489->0.2507) jumped total enemy count 5->15 and
    clear rate 100%->10% -- not a usable knob (see FITTING_REPORT.md's
    caveats section for the measured v1 numbers). The fair global order
    makes each unit of density add exactly one enemy, spread across the
    gauntlet, so clear rate moves smoothly instead."""
    keyed = [((it["room_pos"] + 0.5) / it["room_size"], idx)
             for idx, it in enumerate(pool)]
    keyed.sort(key=lambda p: p[0])
    return [pool[idx] for _, idx in keyed]


def room_center(b: LevelBuilder, room: int) -> tuple[float, float]:
    vs = b.data["rooms"][room]["verts"]
    return (sum(v[0] for v in vs) / len(vs), sum(v[1] for v in vs) / len(vs))


def add_segment(b: LevelBuilder, seg: dict, dx: float, dy: float,
                 keep: set[int], seg_idx: int) -> dict:
    """Copies seg's rooms + enemy entities (only those `room_pos` indices
    named in `keep`, per room) + room lights into `b`, translated by
    (dx, dy). Returns dict(entry=(new_room,edge), exit=(new_room,edge),
    n_enemies=int, n_connects=int) — n_connects lets the caller cross-check
    the final resolved connects count (the no_connect/autoconnect defense).
    """
    data = _load_raw(seg["src"])
    rooms = data["rooms"]
    room_set = set(seg["rooms"])
    old_to_new: dict[int, int] = {}
    n_enemies = 0
    kinds_present: set[str] = set()

    for old_idx in seg["rooms"]:
        r = rooms[old_idx]
        verts = [(x + dx, y + dy) for x, y in r["verts"]]
        new_idx = b.room(verts, detail_seed=LEVEL_SEED + old_idx,
                          kind=r.get("kind", "generic"))
        old_to_new[old_idx] = new_idx
        enemy_ents = [e for e in r.get("entities", []) if e["type"] in ENEMY_KINDS]
        kept_ents = [e for j, e in enumerate(enemy_ents)
                     if (seg_idx, old_idx, j) in keep]
        for e in kept_ents:
            ex, ey = e["pos"][0] + dx, e["pos"][1] + dy
            b.entity(new_idx, e["type"], (ex, ey), **dict(e.get("props", {})))
            n_enemies += 1
            kinds_present.add(e["type"])

    for lt in data.get("lights", []):
        if lt["room"] in room_set:
            b.light(old_to_new[lt["room"]],
                     (lt["pos"][0] + dx, lt["pos"][1] + dy),
                     color=tuple(lt.get("color", (255, 220, 170))),
                     intensity=float(lt.get("intensity", 1.0)),
                     radius=float(lt.get("radius", 140.0)),
                     kind=lt.get("kind", "static"))

    n_connects = 0
    for a, ea, bb, eb in data.get("connects", []):
        if a in room_set and bb in room_set:
            b.connect(old_to_new[a], ea, old_to_new[bb], eb)
            n_connects += 1

    er, ee = seg["entry"]
    xr, xe = seg["exit"]
    return dict(entry=(old_to_new[er], ee), exit=(old_to_new[xr], xe),
                n_enemies=n_enemies, n_connects=n_connects,
                rooms=sorted(old_to_new.values()), kinds_present=sorted(kinds_present))


def add_corridor(b: LevelBuilder, idx: int, start_attach, end_attach) -> dict:
    """A straight stub-loot-stub corridor (3 rooms) in its own dedicated
    canvas band (y = CORR_Y_BASE + idx*CORR_Y_SPACING, x from 0), connected
    to `start_attach`/`end_attach` = (room, edge) or None at either end (the
    open end is where the caller places the player spawn / level exit).
    Returns dict(first_room,first_pos,last_room,last_pos,n_connects)."""
    band_y = CORR_Y_BASE + idx * CORR_Y_SPACING
    lens = [CORRIDOR_STUB_LEN, LOOT_SIZE, CORRIDOR_STUB_LEN]
    widths = [CORRIDOR_WIDTH, LOOT_SIZE, CORRIDOR_WIDTH]
    x = 0.0
    pieces = []
    n_connects = 0
    for i, (length, width) in enumerate(zip(lens, widths)):
        yoff = -(width - CORRIDOR_WIDTH) / 2.0  # keep the centerline aligned
        kind = "storage" if width > CORRIDOR_WIDTH else "corridor"
        r = b.rect(x, band_y + yoff, length, width,
                   seed=LEVEL_SEED + idx * 97 + i, kind=kind)
        pieces.append(r)
        if i > 0:
            b.connect(pieces[i - 1], 2, r, 0)  # prev east <-> this west
            n_connects += 1
        x += length

    if start_attach is not None:
        b.connect(start_attach[0], start_attach[1], pieces[0], 0)
        n_connects += 1
    if end_attach is not None:
        b.connect(pieces[-1], 2, end_attach[0], end_attach[1])
        n_connects += 1

    loot_room = pieces[1]
    cx, cy = room_center(b, loot_room)
    b.entity(loot_room, "medkit", (cx - 40, cy - 30))
    b.entity(loot_room, "medkit", (cx + 40, cy - 30))
    b.entity(loot_room, "ammo_9mm", (cx - 40, cy + 30))
    b.entity(loot_room, "ammo_shell", (cx, cy + 30))
    b.entity(loot_room, "ammo_cell", (cx + 40, cy + 30))
    b.light(loot_room, (cx, cy), color=(210, 230, 255), intensity=1.1, radius=170.0)

    return dict(first_room=pieces[0], first_pos=room_center(b, pieces[0]),
                last_room=pieces[-1], last_pos=room_center(b, pieces[-1]),
                n_connects=n_connects, rooms=pieces, loot_room=loot_room)


# Segments whose kept roster includes at least one of these read as "heavy"
# (elite/boss-adjacent) for the CONTEMPT trash-vs-heavy sanity check;
# everything else (husk/mite/spitter/flicker-only) reads as "trash".
HEAVY_KINDS = {"brute", "shrieker", "warden"}


def build(density: float = 1.0) -> tuple[LevelBuilder, dict]:
    b = LevelBuilder("GAUNTLET — CALIBRATION RUN", tier=3, ambience="amb_drone_mid")
    b.data["alert_hops"] = 2

    pool = _collect_enemy_pool(SEGMENTS)
    order = _fair_order(pool)
    total_original = len(order)
    target_total = max(0, min(round(total_original * density), total_original))
    # Upsampling past the source levels' own roster is never needed here:
    # clear rate is already 0% at density=1.0 (the unscaled roster), so the
    # tuning range only ever needs to shrink it; target_total is clamped to
    # [0, total_original] rather than carrying unused duplicate-spawn code.
    keep = {(it["seg_idx"], it["old_room"], it["room_pos"])
            for it in order[:target_total]}

    seg_results = []
    expected_connects = 0
    for i, seg in enumerate(SEGMENTS):
        res = add_segment(b, seg, i * SEG_X_SPACING, 0.0, keep, i)
        seg_results.append(res)
        expected_connects += res["n_connects"]

    corridor_results = []
    start = add_corridor(b, 0, None, seg_results[0]["entry"])
    expected_connects += start["n_connects"]
    corridor_results.append(start)
    b.player(start["first_room"], start["first_pos"])

    for i in range(len(SEGMENTS) - 1):
        c = add_corridor(b, i + 1, seg_results[i]["exit"], seg_results[i + 1]["entry"])
        expected_connects += c["n_connects"]
        corridor_results.append(c)

    end = add_corridor(b, len(SEGMENTS), seg_results[-1]["exit"], None)
    expected_connects += end["n_connects"]
    corridor_results.append(end)
    b.exit(end["last_room"], end["last_pos"])

    b.intro("CALIBRATION GAUNTLET — instrumented mid-game combat run "
            "(tools/musiccal, not shipped campaign content).")

    # room_id -> zone metadata, for fit_factors.py / tests to classify each
    # tick's room without re-deriving this build's index assignment.
    zones: dict[int, dict] = {}
    for s, r in zip(SEGMENTS, seg_results):
        is_heavy = bool(set(r["kinds_present"]) & HEAVY_KINDS)
        for room in r["rooms"]:
            zones[room] = dict(zone="combat", segment=s["tag"],
                               kinds_present=r["kinds_present"], is_heavy=is_heavy)
    for ci, c in enumerate(corridor_results):
        for room in c["rooms"]:
            zones[room] = dict(zone="loot" if room == c["loot_room"] else "corridor",
                               corridor_idx=ci)

    total_enemies = sum(r["n_enemies"] for r in seg_results)
    stats = dict(density=density, total_enemies=total_enemies,
                 per_segment={s["tag"]: r["n_enemies"]
                              for s, r in zip(SEGMENTS, seg_results)},
                 expected_connects=expected_connects,
                 n_rooms=len(b.data["rooms"]), zones=zones,
                 player_room=start["first_room"], exit_room=end["last_room"])
    return b, stats


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--density", type=float, default=1.0,
                     help="enemy-count scale factor applied per segment")
    ap.add_argument("--out", type=Path, default=OUT_DEFAULT)
    args = ap.parse_args(argv)

    b, stats = build(args.density)
    final = b.to_dict()
    actual_connects = len(final["connects"])
    if actual_connects != stats["expected_connects"]:
        raise RuntimeError(
            f"connects mismatch: expected {stats['expected_connects']} "
            f"(everything explicit) but resolve() produced {actual_connects} "
            "-- an unwanted autoconnect coincidence slipped in; widen spacing")
    lvl = b.build()  # validates winding/schema/spawn/exit

    args.out.parent.mkdir(parents=True, exist_ok=True)
    save_level(final, args.out)

    meta_path = Path(__file__).resolve().parent / "gauntlet_meta.json"
    meta = dict(density=stats["density"], total_enemies=stats["total_enemies"],
               per_segment=stats["per_segment"], n_rooms=stats["n_rooms"],
               player_room=stats["player_room"], exit_room=stats["exit_room"],
               level_path=str(args.out.relative_to(ROOT)) if args.out.is_absolute()
               else str(args.out),
               zones={str(k): v for k, v in stats["zones"].items()})
    meta_path.write_text(json.dumps(meta, indent=1))

    print(f"{args.out}: {lvl.name!r} rooms={len(lvl.room_verts)} "
          f"connects={len(lvl.connects)} enemies={stats['total_enemies']} "
          f"(density={args.density})")
    for tag, n in stats["per_segment"].items():
        print(f"  segment {tag}: {n} enemies")
    print(f"{meta_path}: wrote room-zone metadata")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
