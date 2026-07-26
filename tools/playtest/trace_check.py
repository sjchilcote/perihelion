#!/usr/bin/env python3
"""Verify a session/bot trace JSONL (the U1 instrumentation spine).

Structural checks every later gate builds on:
  - first line is a header; every line parses as JSON
  - `seq` strictly increases; `t` (tick) never decreases
  - every record kind is in the known vocabulary
  - no gameplay fact rides on an audio event (there are no audio events
    in the trace at all — that is the point)

Prints a kind census and exits nonzero on any violation, so shell gates
can `&&` on it.

Usage:
    uv run python tools/playtest/trace_check.py out/sessions/<file>.jsonl
    uv run python tools/playtest/trace_check.py --require damage_applied=1 \
        --require portal_crossing=1 <file>.jsonl
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path

KNOWN_KINDS = {
    "header", "input", "sample", "agent_transition", "portal_crossing",
    "damage_applied", "impulse_applied", "topology_changed",
    # reserved by the vocabulary (U4-U11); present here so their arrival
    # does not break older checkers:
    "field_sample", "call_lease", "call_imprint", "breach_lifecycle",
    "reserve_sample", "dispatch_decision", "core_part", "structure_event",
}


def check(path: Path, require: dict[str, int]) -> int:
    census: Counter[str] = Counter()
    errors: list[str] = []
    last_seq = 0
    last_tick = -1
    with open(path, encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            line = line.strip()
            if not line:
                errors.append(f"line {lineno}: empty line")
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError as e:
                errors.append(f"line {lineno}: unparseable ({e})")
                continue
            kind = rec.get("kind")
            if lineno == 1:
                if kind != "header":
                    errors.append("line 1: first record is not the header")
                census[kind] += 1
                continue
            if kind not in KNOWN_KINDS:
                errors.append(f"line {lineno}: unknown kind {kind!r}")
            census[kind] += 1
            seq = rec.get("seq")
            t = rec.get("t")
            if not isinstance(seq, int) or seq <= last_seq:
                errors.append(
                    f"line {lineno}: seq {seq!r} not strictly after {last_seq}")
            else:
                last_seq = seq
            if not isinstance(t, int) or t < last_tick:
                errors.append(
                    f"line {lineno}: tick {t!r} went backwards from {last_tick}")
            else:
                last_tick = t

    for kind, n in sorted(census.items()):
        print(f"{kind:>20}: {n}")
    for kind, minimum in require.items():
        if census.get(kind, 0) < minimum:
            errors.append(
                f"required at least {minimum} {kind!r}, saw {census.get(kind, 0)}")
    for e in errors[:40]:
        print("VIOLATION:", e, file=sys.stderr)
    if len(errors) > 40:
        print(f"... and {len(errors) - 40} more", file=sys.stderr)
    return 1 if errors else 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("trace", type=Path)
    ap.add_argument("--require", action="append", default=[],
                    metavar="KIND=N", help="fail unless >= N records of KIND")
    args = ap.parse_args()
    require: dict[str, int] = {}
    for spec in args.require:
        kind, _, n = spec.partition("=")
        require[kind] = int(n or 1)
    return check(args.trace, require)


if __name__ == "__main__":
    raise SystemExit(main())
