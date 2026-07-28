"""Gate run 55 lane A2 (pass 2): corrected freeze test + long-hunt forensics.

Corrections over pass 1:
  * an entity before its first logged agent_transition is at its authored
    post = idle, NOT unknown/active. Counting the pre-transition period as
    active made every hub-shelf resident (eids 400-419 in polygons 166-168)
    look wall-pinned.
  * a freeze window must be active for its WHOLE duration, not "any sample".
  * co-polygon 60t sampling is far too coarse to certify "no sighting";
    long hunts are instead forensically resolved (death / stand-down /
    open-at-session-end) and their actual path length measured.
"""
import json
import math
from collections import defaultdict

BASE = "out/eval_gate"
SEEDS = [2, 4, 7, 11]
SESSION = 14400
ACTIVE = {"hunt", "waking"}
FIRE = {"smg_fire", "shotgun_fire", "rail_fire", "lightning_fire",
        "pistol_fire"}


def load(seed):
    rows = defaultdict(list)
    for line in open(f"{BASE}/run_s{seed}/trace.jsonl"):
        d = json.loads(line)
        rows[d.get("kind", "?")].append(d)
    return rows


def main():
    out = {}
    for seed in SEEDS:
        rows = load(seed)
        tl = defaultdict(list)
        for d in rows["agent_transition"]:
            tl[d["entity_id"]].append((d["t"], d["to_state"]))
        for v in tl.values():
            v.sort()

        def state_at(eid, t):
            st = "idle"
            for (tt, s) in tl.get(eid, []):
                if tt <= t:
                    st = s
                else:
                    break
            return st

        pos = defaultdict(list)
        for d in rows["enemy_positions"]:
            for k, v in d["positions"].items():
                pos[int(k)].append((d["t"], v[1], v[2], v[3], v[0]))
        for v in pos.values():
            v.sort()

        deaths = {d["entity_id"]: d["t"] for d in rows["enemy_death"]}
        dispatched = {d["entity_id"]: d["t"]
                      for d in rows["dispatch_decision"]}
        sd = defaultdict(list)
        for d in rows["coord_event"]:
            if d["event"] in ("shrieker_stand_down", "hunt_stall_stand_down"):
                sd[d["entity_id"]].append((d["t"], d["event"], d["detail"]))

        # ---- hunt spans
        spans = []
        for eid, ts in sorted(tl.items()):
            cur = None
            for (t, s) in ts:
                if s == "hunt" and cur is None:
                    cur = t
                elif s != "hunt" and cur is not None:
                    spans.append((eid, cur, t, s))
                    cur = None
            if cur is not None:
                end = deaths.get(eid, SESSION)
                spans.append((eid, cur, end,
                              "death" if eid in deaths else "session_end"))

        def path_between(eid, a, b):
            pts = [p for p in pos.get(eid, []) if a <= p[0] <= b]
            d = 0.0
            hops = 0
            for i in range(len(pts) - 1):
                if pts[i + 1][1] != pts[i][1]:
                    hops += 1
                    continue
                d += math.hypot(pts[i + 1][2] - pts[i][2],
                                pts[i + 1][3] - pts[i][3])
            return round(d, 1), hops, len(pts), (pts[0][1] if pts else None), \
                (pts[-1][1] if pts else None)

        long_h = []
        for (eid, t0, t1, ex) in spans:
            if t1 - t0 < 2000:
                continue
            kd = next((p[4] for p in pos.get(eid, [])), "?")
            pd, hops, n, p_first, p_last = path_between(eid, t0, t1)
            mysd = [x for x in sd.get(eid, []) if t0 <= x[0] <= t1 + 2]
            res = ex
            if mysd:
                res = f"stand_down:{mysd[-1][1]}:{mysd[-1][2]}"
            elif ex == "idle":
                res = "stand_down:generic"
            long_h.append(dict(eid=eid, kind=kd, t0=t0, t1=t1, dur=t1 - t0,
                               resolution=res,
                               dispatched_t=dispatched.get(eid),
                               pathed_u=pd, chamber_changes=hops,
                               samples=n, poly_first=p_first,
                               poly_last=p_last))
        long_h.sort(key=lambda x: -x["dur"])

        # ---- corrected freeze
        frz = []
        for eid, pts in pos.items():
            n = len(pts)
            i = 0
            while i < n - 1:
                j = i
                acc = 0.0
                while j + 1 < n:
                    if pts[j + 1][1] != pts[j][1]:
                        break
                    d = math.hypot(pts[j + 1][2] - pts[j][2],
                                   pts[j + 1][3] - pts[j][3])
                    if acc + d >= 5.0:
                        break
                    if state_at(eid, pts[j + 1][0]) not in ACTIVE:
                        break
                    acc += d
                    j += 1
                span = pts[j][0] - pts[i][0]
                if span > 1200 and state_at(eid, pts[i][0]) in ACTIVE:
                    frz.append(dict(eid=eid, kind=pts[i][4], t0=pts[i][0],
                                    t1=pts[j][0], ticks=span,
                                    moved_u=round(acc, 2), polygon=pts[i][1],
                                    states=sorted({state_at(eid, t)
                                                   for (t, *_r)
                                                   in pts[i:j + 1]})))
                    i = j
                else:
                    i += 1
        best = {}
        for f in frz:
            if f["eid"] not in best or f["ticks"] > best[f["eid"]]["ticks"]:
                best[f["eid"]] = f
        out[f"s{seed}"] = dict(
            long_hunts=long_h,
            freeze=sorted(best.values(), key=lambda f: -f["ticks"]),
            n_spans=len(spans),
            exits=dict(sorted({e: sum(1 for s in spans if s[3] == e)
                               for e in {s[3] for s in spans}}.items())),
        )

        # field distress decay
        fs = [(d["t"], d["totals"]["distress"], d["player_own"]["distress"],
               d["totals"]["noise"], d["totals"]["muster"])
              for d in rows["field_sample"]]
        out[f"s{seed}"]["distress"] = dict(
            max_total=max(x[1] for x in fs),
            min_total=min(x[1] for x in fs),
            final_total=fs[-1][1],
            max_player_own=max(x[2] for x in fs),
            min_player_own=min(x[2] for x in fs),
            samples_player_own_below_floor=sum(1 for x in fs if x[2] < 0.05),
            samples_player_own_above_floor=sum(1 for x in fs if x[2] >= 0.05),
            series_every_600t=[(x[0], round(x[1], 3), round(x[2], 3))
                               for x in fs if x[0] % 600 == 0],
        )

        fires = []
        for line in open(f"{BASE}/run_s{seed}/events.jsonl"):
            d = json.loads(line)
            if d.get("kind") == "sfx" and d.get("name") in FIRE:
                fires.append(round(d["t"] * 60))
        fires.sort()
        gaps = sorted(((fires[i + 1] - fires[i], fires[i], fires[i + 1])
                       for i in range(len(fires) - 1)), reverse=True)
        out[f"s{seed}"]["player_fire"] = dict(n=len(fires), first=fires[0],
                                              last=fires[-1],
                                              top_gaps=gaps[:3])

    json.dump(out, open("out/eval_gate/a2_run55b.json", "w"), indent=1)
    for s in SEEDS:
        o = out[f"s{s}"]
        print(f"=== s{s} spans={o['n_spans']} exits={o['exits']}")
        print("  freeze:", json.dumps(o["freeze"]))
        print("  distress:", json.dumps({k: v for k, v in
                                         o["distress"].items()
                                         if k != "series_every_600t"}))
        for h in o["long_hunts"][:12]:
            print("   ", json.dumps(h))


if __name__ == "__main__":
    main()
