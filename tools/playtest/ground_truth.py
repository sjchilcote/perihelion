#!/usr/bin/env python3
"""Hard per-session facts from a gate capture's trace — the judge's
ground-truth helper. Usage: ground_truth.py <capture_dir>"""
from __future__ import annotations

import json
import sys
from pathlib import Path


def ground_truth(rec: Path) -> dict:
    """Hard per-session facts, computed from the full trace."""
    import bisect
    from collections import Counter
    fire, dmg_t, dmg = [], [], []
    dmg_full = []
    hp_samples = {}
    pr = {}
    dead_spans = []
    death_at = None
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            k = r.get("kind")
            if k == "breach_lifecycle" and r.get("event") == "player_respawn":
                if death_at is not None:
                    dead_spans.append((death_at, r["t"] + 300))
                    death_at = None
            if k == "damage_applied" and r.get("target_kind") == "player":
                pass
            if k == "sample" and r.get("hp") is not None                     and float(r["hp"]) <= 0 and death_at is None:
                death_at = r["t"]
            if k == "input" and r.get("fire"):
                fire.append(r["t"])
            elif k == "damage_applied":
                dmg_t.append(r["t"])
                dmg.append((r["t"], r.get("target_kind"),
                            r.get("source")))
                dmg_full.append((r["t"], r.get("target_kind"),
                                 r.get("source"),
                                 float(r.get("amount", 0.0))))
            elif k == "field_sample":
                pr[r["t"]] = r.get("player_polygon")
            elif k == "sample":
                if r.get("hp") is not None:
                    hp_samples[r["t"]] = float(r["hp"])
    fire.sort()
    dmg_t.sort()
    # exclude dead/respawn/walk-back spans: the judge's ledger proved
    # the headline 'stall' was the player being dead (run 37)
    def _in_dead_span(t):
        return any(a <= t <= b for a, b in dead_spans)
    fire = [t for t in fire if not _in_dead_span(t)]
    longest = 0
    run_start = None
    prev_t = None
    for t in fire:
        # a stretch is CONTIGUOUS firing: any half-second pause in the
        # trigger ends it (run 42b: the old accumulator bridged idle
        # walking between fights and reported 889 ticks where the real
        # dry burst was 88)
        if prev_t is not None and t - prev_t > 30:
            run_start = None
        prev_t = t
        i = bisect.bisect_left(dmg_t, t - 30)
        near = i < len(dmg_t) and dmg_t[i] <= t + 90
        if near:
            run_start = None
        else:
            if run_start is None:
                run_start = t
            longest = max(longest, t - run_start)
    samples = sorted(hp_samples.items())
    matched = unmatched = 0
    for t, tk, _src, amt in dmg_full:
        if tk != "player":
            continue
        before = after = None
        for ts, v in samples:
            if ts <= t:
                before = v
            elif after is None:
                after = v
                break
        if before is None or after is None:
            continue
        if before - after >= 0.8 * amt - 0.5:
            matched += 1
        else:
            unmatched += 1
    # path INTEGRAL per enemy, not a bounding-box diagonal — the old span
    # under-read patrolling wardens by up to 9.7x (run 51). Portal space
    # makes cross-chamber deltas meaningless in world coordinates, so
    # same-chamber legs are summed and each chamber change counts as one
    # crossing instead of a euclidean jump.
    moved = {}          # eid -> [path_u, chambers set, last (poly,x,y), kind]
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            if r.get("kind") == "enemy_positions":
                for eid, (ekind, poly, x, y) in r["positions"].items():
                    m = moved.get(eid)
                    if m is None:
                        moved[eid] = [0.0, {poly}, (poly, x, y), ekind]
                        continue
                    lp, lx, ly = m[2]
                    if poly == lp:
                        m[0] += ((x - lx) ** 2 + (y - ly) ** 2) ** 0.5
                    m[1].add(poly)
                    m[2] = (poly, x, y)
    warden_span = {
        eid: f"pathed {round(p)}u, {len(ch)} chambers"
        for eid, (p, ch, _, ekind) in moved.items() if ekind == "warden"}
    enemy_static = sum(1 for p, ch, _, _k in moved.values()
                       if p < 1.0 and len(ch) == 1)
    return dict(
        camera="the camera zoom is CONSTANT for the whole session; "
               "no zoom snap, kill-cam, or close-up exists in the "
               "engine",
        player_hp_drops_match_logged_damage=(
            f"{matched} of {matched + unmatched} player hits moved the "
            f"HP bar by their logged amount"),
        longest_zero_hit_firing_ticks=longest,
        total_damage_events=len(dmg),
        player_hits=sum(1 for _, tk, _s in dmg if tk == "player"),
        damage_by_source=dict(Counter(s for _, _, s in dmg)),
        player_chamber_changes=len(set(pr.values())),
        warden_movement_spans=warden_span,
        enemies_tracked=len(moved),
        enemies_never_moving=enemy_static,
    )



def session_stats(rec: Path, capture_meta: dict) -> dict:
    opened = dry = sealed = dispatches = 0
    dmg_to_player = 0
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            k = r.get("kind")
            if k == "breach_lifecycle":
                ev = r["event"]
                opened += ev == "opened"
                dry += ev.startswith("dry")
                sealed += ev == "sealed"
            elif k == "dispatch_decision":
                dispatches += 1
            elif k == "damage_applied":
                if r.get("target_kind") == "player":
                    dmg_to_player += 1
    return dict(breaches_opened=opened, dry_calls=dry, sealed=sealed,
                dispatches=dispatches, player_hits_taken=dmg_to_player,
                capture=capture_meta.get("stdout", "")[-600:])



if __name__ == "__main__":
    rec = Path(sys.argv[1])
    gt = ground_truth(rec)
    gt["session_stats"] = session_stats(rec, {})
    out = rec / "ground_truth.json"
    out.write_text(json.dumps(gt, indent=1))
    print(json.dumps(gt, indent=1))
