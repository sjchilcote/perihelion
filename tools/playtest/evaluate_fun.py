#!/usr/bin/env python3
"""The commit gate (director, 2026-07-26 pre-dawn): every gameplay
change must be PLAYTESTED ON FILM before it lands. This script runs a
real bot session, records every 5th frame plus the full trace, hands a
Sonnet judge the frames CORRELATED against the logs chunk by chunk,
and asks the one question that matters:

    Is P(this is a fun, critically acclaimed, commercially
    successful game) > 0.95?

The pre-commit hook blocks any commit touching game/perihelion/,
engine/, or levels/ until a run of this script has passed AFTER the
latest change to those trees. No bypass: iterate on the game, not on
the gate.

    uv run python tools/playtest/evaluate_fun.py [--seed 4]
        [--ticks 14400] [--zoom 0.45] [--model sonnet]

Artifacts land in out/eval_gate/: the capture, per-chunk judge
reports, the final verdict JSON, and (only on a pass) the PASS marker
the hook checks.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
GATE = REPO / "out" / "eval_gate"
JUDGE_TIMEOUT_S = 600
PASS_BAR = 0.95

CHUNK_PROMPT = """\
You are playtesting PERIHELION, a top-down shooter in a continuous
portal space, by reading recorded frames correlated against the
simulation's own logs. This is chunk {idx}/{total} of one session
(frames ~2s apart, chronological). You judge like a demanding player
and a game critic at once, not like a QA scripter.

Frames, in order (read EVERY one):
{frames}

Log digest for this chunk (tick-stamped; frame N = tick N*5):
{digest}

Judge, citing frame files and ticks:
1. ENEMY INTELLIGENCE — do enemies press the attack, flank, gather
   and commit together, react when shot, chase what they see? Flag
   any enemy that stands still under fire, clumps uselessly, walks
   into walls, or ignores an obvious fight. Correlate with the log:
   damage_applied entries against an enemy whose position never
   changes across frames = "stands there and takes it" — the exact
   failure this gate exists to catch.
2. FIGHT READABILITY — can you tell what is happening: who is a
   threat, what the player is shooting, why the player took damage?
3. PACING — dead air vs pressure. Long stretches where nothing
   presses the player are a finding; so is unreadable chaos.
4. THE REINFORCEMENT LOOP — if the digest shows scout calls,
   breaches, pours: do they LAND on screen (a wall visibly tears,
   bodies pour through, the fight escalates)?

Reply with ONLY a JSON object, no prose, no fences:
{{"findings": [{{"frame": "<file>", "tick": <int>, "severity":
"P0"|"P1"|"P2", "note": "<one sentence>"}}...],
"chunk_score": 0.0-1.0, "summary": "<two sentences>"}}
"""

VERDICT_PROMPT = """\
You are the final judge of a recorded PERIHELION playtest session.
Below are the chunk-by-chunk playtest reports from judges who read
every frame against the simulation logs, plus session statistics.

{chunks}

Session stats: {stats}

Question, exactly as the director posed it: Is P(this is a fun,
critically acclaimed, commercially successful game) > {bar}?

Be honest and calibrated. A game where enemies stand still under
fire, where nothing presses the player, or where the signature
reinforcement mechanic never lands on screen cannot pass. List the
blockers that keep the probability down, ranked, concrete enough to
act on.

Reply with ONLY a JSON object, no prose, no fences:
{{"p": 0.0-1.0, "pass": true|false, "blockers": ["<ranked, concrete,
actionable>"...], "strengths": ["..."], "summary": "<three
sentences>"}}
"""


def run_capture(out: Path, seed: int, ticks: int, zoom: float) -> dict:
    out.mkdir(parents=True, exist_ok=True)
    r = subprocess.run(
        ["uv", "run", "python", "tools/playtest/marrow_demo.py",
         str(out), "--ticks", str(ticks), "--zoom", str(zoom),
         "--seed", str(seed)],
        cwd=REPO, capture_output=True, text=True, timeout=1800)
    if r.returncode != 0:
        raise RuntimeError(f"capture failed:\n{r.stderr[-2000:]}")
    return {"stdout": r.stdout[-2000:]}


def build_digests(rec: Path, judged: list[Path], window: int = 120) -> dict:
    """frame -> compact log lines within +/-window ticks of its tick."""
    events = defaultdict(list)
    keep = {"damage_applied", "agent_transition", "breach_lifecycle",
            "dispatch_decision", "shelf_replaced", "core_part"}
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            if r.get("kind") in keep:
                events[r["t"] // 60].append(r)
    digests = {}
    for f in judged:
        tick = int(f.stem.split("_")[1]) * 5
        lines = []
        for sec in range((tick - window) // 60, (tick + window) // 60 + 1):
            for r in events.get(sec, []):
                if abs(r["t"] - tick) <= window:
                    slim = {k: v for k, v in r.items()
                            if k not in ("seq",)}
                    lines.append(json.dumps(slim, separators=(",", ":")))
        digests[f.name] = lines[:40]
    return digests


def judge_chunk(frames: list[Path], digests: dict, idx: int, total: int,
                model: str) -> dict:
    digest_txt = "\n".join(
        f"{f.name}: " + ("; ".join(digests.get(f.name, [])) or "(quiet)")
        for f in frames)
    prompt = CHUNK_PROMPT.format(
        idx=idx, total=total,
        frames="\n".join(str(f) for f in frames),
        digest=digest_txt[:24000])
    r = subprocess.run(
        ["claude", "-p", prompt, "--model", model,
         "--output-format", "json", "--allowedTools", "Read"],
        capture_output=True, text=True, timeout=JUDGE_TIMEOUT_S)
    if r.returncode != 0:
        raise RuntimeError(f"chunk judge failed: {r.stderr[:500]}")
    text = json.loads(r.stdout)["result"].strip()
    text = text.removeprefix("```json").removeprefix("```")
    text = text.removesuffix("```").strip()
    return json.loads(text)


def final_verdict(chunk_reports: list[dict], stats: dict,
                  model: str) -> dict:
    prompt = VERDICT_PROMPT.format(
        chunks="\n\n".join(
            f"CHUNK {i + 1}: {json.dumps(c, separators=(',', ':'))}"
            for i, c in enumerate(chunk_reports)),
        stats=json.dumps(stats, separators=(",", ":")),
        bar=PASS_BAR)
    r = subprocess.run(
        ["claude", "-p", prompt, "--model", model,
         "--output-format", "json", "--allowedTools", "Read"],
        capture_output=True, text=True, timeout=JUDGE_TIMEOUT_S)
    if r.returncode != 0:
        raise RuntimeError(f"final judge failed: {r.stderr[:500]}")
    text = json.loads(r.stdout)["result"].strip()
    text = text.removeprefix("```json").removeprefix("```")
    text = text.removesuffix("```").strip()
    v = json.loads(text)
    if not isinstance(v.get("p"), (int, float)):
        raise RuntimeError(f"malformed verdict: {v!r}")
    return v


def session_stats(rec: Path, capture_meta: dict) -> dict:
    opened = dry = sealed = dispatches = 0
    dmg_to_player = kills = 0
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
                else:
                    kills += 0  # kill counting lives in demo stdout
    return dict(breaches_opened=opened, dry_calls=dry, sealed=sealed,
                dispatches=dispatches, player_hits_taken=dmg_to_player,
                capture=capture_meta.get("stdout", "")[-600:])


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=4)
    ap.add_argument("--ticks", type=int, default=14400)
    ap.add_argument("--zoom", type=float, default=0.45)
    ap.add_argument("--model", default="sonnet")
    ap.add_argument("--judge-every", type=int, default=24,
                    help="judge every Nth sampled frame (~2s apart)")
    ap.add_argument("--chunk-size", type=int, default=40)
    ap.add_argument("--reuse", action="store_true",
                    help="skip capture, judge the existing run")
    a = ap.parse_args()

    rec = GATE / "run"
    if not a.reuse:
        print("[gate] capturing...", flush=True)
        meta = run_capture(rec, a.seed, a.ticks, a.zoom)
    else:
        meta = {"stdout": "(reused capture)"}
    frames = sorted(rec.glob("frame_*.png"))
    if not frames:
        raise RuntimeError("no frames captured")
    judged = frames[:: a.judge_every]
    print(f"[gate] {len(frames)} frames, judging {len(judged)}", flush=True)
    digests = build_digests(rec, judged)

    chunks = [judged[i:i + a.chunk_size]
              for i in range(0, len(judged), a.chunk_size)]
    reports = []
    for i, chunk in enumerate(chunks):
        print(f"[gate] judging chunk {i + 1}/{len(chunks)} "
              f"({len(chunk)} frames)...", flush=True)
        rep = judge_chunk(chunk, digests, i + 1, len(chunks), a.model)
        reports.append(rep)
        (GATE / f"chunk_{i + 1}.json").write_text(json.dumps(rep, indent=1))
        print(f"[gate]   score={rep.get('chunk_score')} "
              f"findings={len(rep.get('findings', []))}", flush=True)

    stats = session_stats(rec, meta)
    verdict = final_verdict(reports, stats, a.model)
    (GATE / "verdict.json").write_text(json.dumps(verdict, indent=1))
    print(json.dumps(verdict, indent=2))

    if verdict.get("pass") and float(verdict["p"]) > PASS_BAR:
        (GATE / "PASS").write_text(json.dumps(
            dict(p=verdict["p"], seed=a.seed, ticks=a.ticks,
                 zoom=a.zoom), indent=1))
        print(f"[gate] PASS (p={verdict['p']})")
        return 0
    (GATE / "PASS").unlink(missing_ok=True)
    print(f"[gate] BLOCKED (p={verdict.get('p')}) — top blockers:")
    for b in verdict.get("blockers", [])[:5]:
        print(f"  - {b}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
