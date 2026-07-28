"""Gate run 55 lane A2: population-level certification from trace/events."""
import json
import math
import os
import sys
from collections import defaultdict

BASE = "out/eval_gate"
SEEDS = [2, 4, 7, 11]
SESSION = 14400
ACTIVE = {"hunt", "waking"}
FIRE = {"smg_fire", "shotgun_fire", "rail_fire", "lightning_fire",
        "pistol_fire", "gun_fire", "player_fire"}


def load(seed):
    rows = defaultdict(list)
    for line in open(f"{BASE}/run_s{seed}/trace.jsonl"):
        d = json.loads(line)
        rows[d.get("kind", "?")].append(d)
    return rows


def hunt_spans(rows):
    """Per-entity state timeline -> continuous hunt spans."""
    tr = defaultdict(list)
    for d in rows["agent_transition"]:
        tr[d["entity_id"]].append(d)
    deaths = {d["entity_id"]: d["t"] for d in rows["enemy_death"]}
    spans = []
    for eid, ts in tr.items():
        ts.sort(key=lambda d: (d["t"], d["seq"]))
        cur = None
        for d in ts:
            if d["to_state"] == "hunt" and cur is None:
                cur = (d["t"], d["agent_kind"])
            elif d["from_state"] == "hunt" and cur is not None:
                spans.append(dict(eid=eid, kind=cur[1], t0=cur[0], t1=d["t"],
                                  dur=d["t"] - cur[0], exit=d["to_state"]))
                cur = None
        if cur is not None:
            end = deaths.get(eid, SESSION)
            spans.append(dict(eid=eid, kind=cur[1], t0=cur[0], t1=end,
                              dur=end - cur[0],
                              exit="death" if eid in deaths else "session_end"))
    return spans


def positions(rows):
    """eid -> list of (t, polygon, x, y) from enemy_positions samples."""
    p = defaultdict(list)
    for d in rows["enemy_positions"]:
        for k, v in d["positions"].items():
            p[int(k)].append((d["t"], v[1], v[2], v[3], v[0]))
    for v in p.values():
        v.sort()
    return p


def player_poly(rows):
    return [(d["t"], d["polygon"]) for d in rows["sample"]]


def main():
    out = {"regressions": [], "hunt_tenure_table": {}, "freeze_violations": {},
           "samples_counts": {}, "death_source_table": {},
           "warning_durations": {}, "distress_latch_verdict": {}}

    for seed in SEEDS:
        rows = load(seed)
        spans = hunt_spans(rows)
        pos = positions(rows)
        ppoly = player_poly(rows)
        dispatched = {d["entity_id"] for d in rows["dispatch_decision"]}
        standdowns = defaultdict(list)
        for d in rows["coord_event"]:
            if d["event"] in ("shrieker_stand_down", "hunt_stall_stand_down"):
                standdowns[d["entity_id"]].append((d["t"], d["event"],
                                                   d.get("detail")))

        # ---- 3. sample counts
        out["samples_counts"][f"s{seed}"] = {
            "enemy_positions": len(rows["enemy_positions"]),
            "field_sample": len(rows["field_sample"]),
            "reserve_sample": len(rows["reserve_sample"]),
            "player_sample": len(rows["sample"]),
        }

        # ---- 1. hunt tenure
        def cosight(sp):
            """ticks at which enemy shared player's polygon during span"""
            hits = []
            for (t, poly, x, y, kd) in pos.get(sp["eid"], []):
                if sp["t0"] <= t <= sp["t1"]:
                    # nearest player sample
                    best = min(ppoly, key=lambda pp: abs(pp[0] - t))
                    if abs(best[0] - t) <= 30 and best[1] == poly:
                        hits.append(t)
            return hits

        spans.sort(key=lambda s: -s["dur"])
        table = []
        for sp in spans[:10]:
            hits = cosight(sp)
            sd = [x for x in standdowns.get(sp["eid"], [])
                  if sp["t0"] <= x[0] <= sp["t1"] + 2]
            res = sp["exit"]
            if sd:
                res = f"stand_down({sd[-1][1]}:{sd[-1][2]})"
            elif res == "idle":
                res = "stand_down(generic)"
            table.append(dict(eid=sp["eid"], kind=sp["kind"], t0=sp["t0"],
                              t1=sp["t1"], dur=sp["dur"], resolution=res,
                              dispatched=sp["eid"] in dispatched,
                              copolygon_sample_ticks=len(hits),
                              first_copoly=hits[0] if hits else None,
                              last_copoly=hits[-1] if hits else None))
        out["hunt_tenure_table"][f"s{seed}"] = table

        # violations: non-dispatched, >2900t, zero co-polygon sighting samples
        viol = []
        for sp in spans:
            if sp["dur"] > 2900 and sp["eid"] not in dispatched:
                hits = cosight(sp)
                if not hits:
                    viol.append(dict(eid=sp["eid"], kind=sp["kind"],
                                     t0=sp["t0"], t1=sp["t1"], dur=sp["dur"],
                                     exit=sp["exit"]))
        if viol:
            out["regressions"].append(dict(
                lane="A2/Q1", seed=seed, kind="hunt_over_2900t_no_sighting",
                items=viol, severity="high"))

        # ---- 2. freeze / wall-pin
        # state timeline per entity for active-state test
        tl = defaultdict(list)
        for d in rows["agent_transition"]:
            tl[d["entity_id"]].append((d["t"], d["to_state"]))
        for v in tl.values():
            v.sort()

        def state_at(eid, t):
            st = None
            for (tt, s) in tl.get(eid, []):
                if tt <= t:
                    st = s
                else:
                    break
            return st

        frz = []
        for eid, pts in pos.items():
            n = len(pts)
            i = 0
            while i < n:
                j = i
                acc = 0.0
                while j + 1 < n:
                    d = math.hypot(pts[j + 1][2] - pts[j][2],
                                   pts[j + 1][3] - pts[j][3])
                    if pts[j + 1][1] != pts[j][1]:
                        d = 999.0  # polygon change = movement
                    if acc + d >= 5.0:
                        break
                    acc += d
                    j += 1
                span = pts[j][0] - pts[i][0]
                if span > 1200:
                    states = {state_at(eid, t) for (t, *_r) in pts[i:j + 1]}
                    act = states & ACTIVE
                    if act:
                        frz.append(dict(eid=eid, kind=pts[i][4],
                                        t0=pts[i][0], t1=pts[j][0],
                                        ticks=span, moved_u=round(acc, 2),
                                        states=sorted(x for x in states if x),
                                        polygon=pts[i][1]))
                    i = j
                else:
                    i += 1
        # dedupe overlapping windows per eid, keep longest
        best = {}
        for f in frz:
            if f["eid"] not in best or f["ticks"] > best[f["eid"]]["ticks"]:
                best[f["eid"]] = f
        frz = sorted(best.values(), key=lambda f: -f["ticks"])
        out["freeze_violations"][f"s{seed}"] = frz
        if frz:
            out["regressions"].append(dict(
                lane="A2/Q2", seed=seed, kind="active_state_freeze",
                items=frz[:10], severity="medium"))

        # ---- 4. death sources
        deaths = []
        dmg = sorted(rows["damage_applied"], key=lambda d: d["t"])
        for d in rows["player_death"]:
            pre = [x for x in dmg if x.get("target_kind") == "player"
                   and d["t"] - 240 <= x["t"] <= d["t"]]
            deaths.append(dict(t=d["t"], polygon=d["polygon"],
                               source=d["source"],
                               chassis_left=d.get("chassis_left"),
                               last_damage_sources=[x["source"] for x in pre[-6:]],
                               final_damage_source=pre[-1]["source"] if pre else None,
                               final_damage_t=pre[-1]["t"] if pre else None))
        out["death_source_table"][f"s{seed}"] = deaths
        for dd in deaths:
            if dd["final_damage_source"] and dd["source"] != dd["final_damage_source"]:
                out["regressions"].append(dict(
                    lane="A2/Q4", seed=seed, kind="death_source_mismatch",
                    t=dd["t"], claimed=dd["source"],
                    actual_final_damage=dd["final_damage_source"],
                    severity="high"))

        # ---- 5. warning durations + patience arithmetic
        ph = defaultdict(list)
        for d in rows["coord_event"]:
            if d["event"] == "shrieker_phase":
                a, b = d["detail"].split("->")
                ph[d["entity_id"]].append((d["t"], a, b))
        warns = []
        approach_starts = defaultdict(list)
        for eid, seq in ph.items():
            seq.sort()
            for i, (t, a, b) in enumerate(seq):
                if b == "warning":
                    end = None
                    for (t2, a2, b2) in seq[i + 1:]:
                        if a2 == "warning":
                            end = t2
                            break
                    warns.append(dict(eid=eid, t_in=t, t_out=end,
                                      dur=(end - t) if end else
                                      (SESSION - t),
                                      open_at_session_end=end is None,
                                      to=next((b2 for (t2, a2, b2)
                                               in seq[i + 1:] if a2 ==
                                               "warning"), None)))
                if b == "approach":
                    approach_starts[eid].append(t)
        warns.sort(key=lambda w: w["t_in"])
        durs = sorted(w["dur"] for w in warns)
        med = durs[len(durs) // 2] if durs else None
        # patience: each shrieker_stand_down with detail 'patience spent'
        # must sit exactly SHRIEK_APPROACH_PATIENCE+1 = 2701t after the
        # approach_t that started it.
        sd_check = []
        for d in rows["coord_event"]:
            if d["event"] != "shrieker_stand_down":
                continue
            eid = d["entity_id"]
            prior = [t for t in approach_starts.get(eid, []) if t <= d["t"]]
            gap = (d["t"] - prior[-1]) if prior else None
            sd_check.append(dict(eid=eid, t=d["t"], detail=d.get("detail"),
                                 last_approach_entry=prior[-1] if prior else None,
                                 ticks_since_approach=gap,
                                 expected=2701 if "patience" in
                                 (d.get("detail") or "") else "n/a (nothing calls)",
                                 ok=(gap == 2701) if "patience" in
                                 (d.get("detail") or "") else True))
        out["warning_durations"][f"s{seed}"] = dict(
            n=len(warns), median=med, min=durs[0] if durs else None,
            max=durs[-1] if durs else None, all=warns,
            one_tick_count=sum(1 for x in durs if x <= 1),
            stand_downs=sd_check)
        for c in sd_check:
            if not c["ok"]:
                out["regressions"].append(dict(
                    lane="A2/Q5", seed=seed, kind="patience_arithmetic_off",
                    eid=c["eid"], t=c["t"], observed=c["ticks_since_approach"],
                    expected=2701, severity="medium"))
        if durs and med is not None and med <= 1:
            out["regressions"].append(dict(
                lane="A2/Q5", seed=seed, kind="warning_phase_1tick_median",
                median=med, severity="high"))

        # ---- 6. ambient distress latch
        fires = sorted(round(json.loads(l)["t"] * 60)
                       for l in open(f"{BASE}/run_s{seed}/events.jsonl")
                       if (lambda d: d.get("kind") == "sfx" and
                           d.get("name") in FIRE)(json.loads(l)))
        latch = []
        for sp in spans:
            if sp["dur"] <= 3000 or sp["kind"] == "shrieker":
                continue
            # longest gap between player weapon fires inside the span
            inside = [t for t in fires if sp["t0"] <= t <= sp["t1"]]
            bounds = [sp["t0"]] + inside + [sp["t1"]]
            gaps = [(bounds[i + 1] - bounds[i], bounds[i], bounds[i + 1])
                    for i in range(len(bounds) - 1)]
            gaps.sort(reverse=True)
            hits = cosight(sp)
            latch.append(dict(eid=sp["eid"], kind=sp["kind"], t0=sp["t0"],
                              t1=sp["t1"], dur=sp["dur"], exit=sp["exit"],
                              dispatched=sp["eid"] in dispatched,
                              longest_quiet_gap=gaps[0][0] if gaps else None,
                              quiet_window=[gaps[0][1], gaps[0][2]] if gaps
                              else None,
                              copolygon_sample_ticks=len(hits)))
        out["distress_latch_verdict"][f"s{seed}"] = dict(
            player_fire_events=len(fires),
            hunts_over_3000t_nonshrieker=latch)
        for L in latch:
            if L["longest_quiet_gap"] and L["longest_quiet_gap"] >= 1000 \
                    and L["copolygon_sample_ticks"] == 0:
                out["regressions"].append(dict(
                    lane="A2/Q6", seed=seed, kind="ambient_distress_latch",
                    eid=L["eid"], entity_kind=L["kind"], dur=L["dur"],
                    quiet_gap=L["longest_quiet_gap"],
                    window=L["quiet_window"], severity="high"))

        # distribution stats for context
        out["hunt_tenure_table"][f"s{seed}_stats"] = dict(
            n_spans=len(spans),
            n_over_1000=sum(1 for s in spans if s["dur"] > 1000),
            n_over_2900=sum(1 for s in spans if s["dur"] > 2900),
            n_over_3000_nonshrieker=sum(1 for s in spans if s["dur"] > 3000
                                        and s["kind"] != "shrieker"),
            max=max((s["dur"] for s in spans), default=0),
            exits=dict(sorted(
                {e: sum(1 for s in spans if s["exit"] == e)
                 for e in {s["exit"] for s in spans}}.items())),
            open_at_session_end=sum(1 for s in spans
                                    if s["exit"] == "session_end"),
        )

    json.dump(out, open("out/eval_gate/a2_run55.json", "w"), indent=1)
    print(json.dumps(out["regressions"], indent=1))
    print("samples:", json.dumps(out["samples_counts"]))


if __name__ == "__main__":
    os.chdir(sys.argv[1] if len(sys.argv) > 1 else ".")
    main()
