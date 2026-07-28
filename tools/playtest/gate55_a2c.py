"""Gate run 55 lane A2 (pass 3): do the long hunts CONVERGE?

Builds an aggregate polygon adjacency graph from observed portal_crossing
events (approximate: the portal graph is rewired by every breach open/seal,
so this is the union over the session) and measures, for every hunt span,
the hop distance from the hunter's sampled polygon to the player's polygon.
A hunt that never gets within 1 hop for thousands of ticks is chasing
ghosts; one whose hop distance ratchets down is a real pursuit.
"""
import json
from collections import defaultdict, deque

BASE = "out/eval_gate"
SEEDS = [2, 4, 7, 11]
SESSION = 14400


def main():
    out = {}
    for seed in SEEDS:
        rows = defaultdict(list)
        for line in open(f"{BASE}/run_s{seed}/trace.jsonl"):
            d = json.loads(line)
            rows[d.get("kind", "?")].append(d)

        adj = defaultdict(set)
        for d in rows["portal_crossing"]:
            adj[d["from_polygon"]].add(d["to_polygon"])
            adj[d["to_polygon"]].add(d["from_polygon"])

        def hops(a, b, cap=12):
            if a == b:
                return 0
            seen = {a}
            q = deque([(a, 0)])
            while q:
                n, dd = q.popleft()
                if dd >= cap:
                    continue
                for m in adj.get(n, ()):
                    if m == b:
                        return dd + 1
                    if m not in seen:
                        seen.add(m)
                        q.append((m, dd + 1))
            return -1

        psamp = sorted((d["t"], d["polygon"]) for d in rows["sample"])

        def ppoly(t):
            best = min(psamp, key=lambda p: abs(p[0] - t))
            return best[1] if abs(best[0] - t) <= 30 else None

        pos = defaultdict(list)
        for d in rows["enemy_positions"]:
            for k, v in d["positions"].items():
                pos[int(k)].append((d["t"], v[1], v[0]))
        for v in pos.values():
            v.sort()

        tl = defaultdict(list)
        for d in rows["agent_transition"]:
            tl[d["entity_id"]].append((d["t"], d["to_state"]))
        for v in tl.values():
            v.sort()
        deaths = {d["entity_id"]: d["t"] for d in rows["enemy_death"]}

        spans = []
        for eid, ts in tl.items():
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

        rep = []
        for (eid, t0, t1, ex) in spans:
            if t1 - t0 < 2000:
                continue
            hs = []
            for (t, poly, kd) in pos.get(eid, []):
                if not (t0 <= t <= t1):
                    continue
                pp = ppoly(t)
                if pp is None:
                    continue
                hs.append((t, hops(poly, pp)))
            if not hs:
                continue
            valid = [h for (_t, h) in hs if h >= 0]
            rep.append(dict(
                eid=eid, kind=pos[eid][0][2], t0=t0, t1=t1, dur=t1 - t0,
                exit=ex, samples=len(hs),
                min_hops=min(valid) if valid else None,
                median_hops=sorted(valid)[len(valid) // 2] if valid else None,
                frac_within_1hop=round(
                    sum(1 for h in valid if h <= 1) / len(valid), 3)
                if valid else None,
                frac_copolygon=round(
                    sum(1 for h in valid if h == 0) / len(valid), 3)
                if valid else None,
                unreachable_samples=sum(1 for (_t, h) in hs if h < 0),
                first_within_1hop_t=next((t for (t, h) in hs
                                          if 0 <= h <= 1), None),
            ))
        rep.sort(key=lambda r: -r["dur"])
        out[f"s{seed}"] = dict(graph_polygons=len(adj), spans=len(rep),
                               long_hunts=rep)
        print(f"=== s{seed} graph_polys={len(adj)} long_hunts={len(rep)}")
        for r in rep[:12]:
            print("   ", json.dumps(r))
        never = [r for r in rep if r["first_within_1hop_t"] is None
                 and r["dur"] > 2900]
        print("  NEVER within 1 hop (>2900t):",
              json.dumps([(r["eid"], r["kind"], r["dur"], r["exit"],
                           r["min_hops"]) for r in never]))
    json.dump(out, open("out/eval_gate/a2_run55c.json", "w"), indent=1)


if __name__ == "__main__":
    main()
