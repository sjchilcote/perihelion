#!/usr/bin/env python3
"""Score an attention instrument against known defect windows.

An anomaly detector that has never been scored is a mood, not an
instrument. This asks the only question that matters: do the windows it
ranks highest contain the defects a human actually found?

The labels are timestamp ranges from a real playtest, given WITHOUT
explanation, so nothing here can be tuned toward the answers — the
scorer does not know what any defect is, only when.

Reported:
  recall@k     fraction of labelled defects whose window makes the top k
  precision@k  fraction of the top k that land inside a labelled window
  lift         precision@k divided by the base rate (labelled seconds /
               total seconds). 1.0 is chance. Below 1.0 means the
               instrument is worse than picking moments at random, which
               is a result worth reporting rather than hiding.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

# director's playtest, 2026-08-01 — ranges in seconds, no descriptions
LABELS = {
    "D1":  [(15, 21)],
    "D2":  [(37, 48), (148.35, 148.40)],
    "D3":  [(165, 168), (178, 185)],
    "D4":  [(178, 179), (538, 541), (1030, 1031)],
    "D5":  [(202, 204), (240, 244), (372, 380), (399, 408), (1358, 1360)],
    "D6":  [(240, 244)],
    "D7":  [(555, 556)],
    "D8":  [(590, 706)],
    "D9":  [(1001, 1015)],
    "D10": [(1020, 1021)],
    "D11": [(1265, 1273)],
}


def overlaps(t0: float, t1: float, lo: float, hi: float) -> bool:
    return t0 < hi and lo < t1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("scan", type=Path)
    ap.add_argument("--key", default="novelty")
    ap.add_argument("--window", type=float, default=5.0)
    ap.add_argument("--ks", default="10,20,30,50")
    a = ap.parse_args()

    rows = [r for r in json.loads(a.scan.read_text())
            if r.get(a.key) is not None]
    if not rows:
        raise SystemExit(f"no windows carry '{a.key}'")
    rows.sort(key=lambda r: -r[a.key])
    total_s = max(r["t"] for r in rows) + a.window
    labelled_s = sum(hi - lo for spans in LABELS.values() for lo, hi in spans)
    base = labelled_s / total_s

    def hits(row):
        return [d for d, spans in LABELS.items()
                if any(overlaps(row["t"], row["t"] + a.window, lo, hi)
                       for lo, hi in spans)]

    print(f"{len(rows)} windows of {a.window}s over {total_s:.0f}s")
    print(f"labelled: {len(LABELS)} defects, {labelled_s:.0f}s "
          f"=> base rate {base*100:.1f}%\n")
    for k in (int(v) for v in a.ks.split(",")):
        top = rows[:k]
        found = set()
        n_in = 0
        for r in top:
            h = hits(r)
            if h:
                n_in += 1
                found |= set(h)
        prec = n_in / k
        print(f"  top {k:3d}: recall {len(found):2d}/{len(LABELS)} "
              f"({100*len(found)//len(LABELS):3d}%)  precision {prec*100:5.1f}%  "
              f"lift {prec/base if base else 0:4.2f}x   found {sorted(found)}")
    print("\n  highest-ranked windows:")
    for r in rows[:12]:
        h = hits(r)
        mark = ("<-- " + ",".join(h)) if h else ""
        m, s = divmod(r["t"], 60)
        print(f"    {int(m):02d}:{s:05.2f}  {a.key}={r[a.key]:+.2f}  {mark}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
