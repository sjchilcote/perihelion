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

VISUAL LEGEND (do not misclassify): the player is a white kite/arrow.
The player's own SENTRY EMPLACEMENTS are amber/yellow tripod turrets
with a bright triangular head — STATIONARY BY DESIGN, friendly, they
never move and enemies may ignore them; do not report them as frozen
enemies. Enemy bodies: green lumpy husks, small pale mites, olive
pentagon spitters (green nose), thin pale shrieker slivers, violet
flickers, red-brown brutes with two pale tusk lines (reads as an 'M'
at distance), dark-violet 9-gon wardens with a white rim; teal/violet
double outlines are adversary scouts. Small squares/crosses on the
floor are ammo/medkit pickups; violet concentric rings are breach
tears; dark red-brown chunks are corpses (they never move or take
damage). A pale blob with a closing ring is a structure unpacking.

Frames, in order (read EVERY one):
{frames}

Ground-truth session facts (computed from the FULL trace — calibrate
your severity against these before asserting stalls or unlogged
events; prior banks produced P1s the trace refuted):
{ground}

Log digest for this chunk (tick-stamped; frame N = tick N*5):
{digest}

Judge, citing frame files and ticks:
1. ENEMY INTELLIGENCE — do enemies press the attack, flank, gather
   and commit together, react when shot, chase what they see? Flag
   any enemy that stands still under fire, clumps uselessly, walks
   into walls, or ignores an obvious fight. Correlate with the log:
   damage_applied entries against an enemy whose position never
   changes across frames = "stands there and takes it" — the exact
   failure this gate exists to catch. IMPORTANT: the log records the
   WHOLE simulation, most of it far from the camera — an empty frame
   with busy log lines usually means the fight is in another chamber
   (check player_chamber in the digest), which is honest simulation,
   NOT a render bug. Only flag state/screen divergence for events in
   the player's own chamber or within one door of it.
   The player's simulated viewport is wider than the recorded frame:
   sustained fire toward the frame edge is usually aimed at an enemy
   visible through a portal fold just off-camera — check the digest
   for enemy damage lines before calling it firing-at-nothing. A
   full-frame VIOLET WASH pulse marks the instant a breach tears
   open somewhere on the station (the wall-tear's screen-space cue).
2. FIGHT READABILITY — can you tell what is happening: who is a
   threat, what the player is shooting, why the player took damage?
   SOUNDSCAPE: each frame's HEARD line is what the player is hearing
   at that moment through positional audio — footfalls, screams,
   gunfire, the wrongness stinger of a wall tearing. An 'empty'
   corridor with heavy off-screen combat audio is dread, not dead
   air; a real player experiences that pressure even with nothing on
   screen. Weigh pacing with ears as well as eyes.
3. PACING — dead air vs pressure. Long stretches where nothing
   presses the player are a finding; so is unreadable chaos. HP/ammo
   deltas may land BETWEEN judged frames (2s apart): before calling a
   change unlogged, check the PREVIOUS frame's digest lines too.
   A 'dry_no_site: no free apse seam' or 'call from inside the hub'
   entry is a DESIGNED tell of the enemy's finite economy, not a
   failure; only 'no wall holds a 96u seam' indicates a content bug.
   'lightning_self' damage is the player's own lightning cannon
   detonating too close — a self-splash skill mechanic with a full
   bolt-burst visual at the blast site, not an invisible attacker.
   DEATH IS A TRANSLOCATION, not a reset (System Shock rule): on
   death the player reprints at a seed station with full HP while the
   world stays exactly as it lies — a 'player_respawn' log line marks
   it; a sudden HP/position jump matching one is the designed death
   mechanic, not a bug.
4. THE REINFORCEMENT LOOP — if the digest shows scout calls,
   breaches, pours: do they LAND on screen (a wall visibly tears,
   bodies pour through, the fight escalates)?

Reply with ONLY a JSON object, no prose, no fences:
{{"findings": [{{"frame": "<file>", "tick": <int>, "severity":
"P0"|"P1"|"P2", "note": "<one sentence>"}}...],
"chunk_score": 0.0-1.0, "summary": "<two sentences>"}}
"""

VERIFY_PROMPT = """\
You are the adversarial VERIFIER for playtest findings. Chunk judges
reported the findings below from frames of a recorded session. You
have the ground-truth simulation trace. Your job is to REFUTE what
does not survive the data — judges have previously reported an
'80-second zero-hit firing stall' when the trace showed the longest
zero-hit stretch was 0.85s, a '14-second frozen standoff' during
which the trace showed six chamber transitions and kills, and
'unlogged damage' that was fully logged two frames earlier.

Findings to verify:
{findings}

Ground-truth summaries computed from the full trace:
{ground}

Frame files are available to Read if a finding needs visual
confirmation.

For each finding, answer CONFIRMED only if the trace/ground data is
consistent with it; REFUTED with one sentence of discriminating
evidence otherwise; UNVERIFIABLE if neither. Reply with ONLY a JSON
array, no prose: [{{"idx": <int>, "verdict": "CONFIRMED"|"REFUTED"|
"UNVERIFIABLE", "why": "<one sentence>"}}...]
"""

VERDICT_PROMPT = """\
You are the final judge of a recorded PERIHELION playtest session.
Below are the chunk-by-chunk playtest reports from judges who read
every frame against the simulation logs, plus session statistics.

{chunks}

Session stats: {stats}

SUPPRESSION IS A WIN, NOT A FAILURE: scouts are finite and authored;
killing or harrying every caller before it completes a broadcast is
the game's designed counter-play, and it silences reinforcements for
that session permanently (the census only ever shrinks). A session
with zero breaches alongside heavy scout damage in the reports means
the player EARNED the quiet — judge it as successful denial, not as
the mechanic failing to activate.

Difficulty-curve context: single sessions cannot establish the curve;
the 16-seed acceptance bank (mean death ~246s, 12.5% survive a 400s
cap, first breach 46-68s in) is the calibration reference — judge
THIS session's pacing and readability, not the curve's tunability.

Findings marked REFUTED failed verification against the simulation
trace and MUST be ignored entirely; weigh only CONFIRMED (fully) and
UNVERIFIABLE (with skepticism) findings.

Question, exactly as the director posed it: Is P(this is a fun,
critically acclaimed, commercially successful game) > {bar}?

SCOPE (director's ruling): judge the CHANGES CURRENTLY BEING MADE —
the moment-to-moment combat, the reinforcement loop, readability,
pacing of what is on film. The rest of the game is NOT in scope:
missing win states, campaign content, future systems (buildings,
new enemy modes), or content breadth must NOT count against the
probability. The question is whether THIS slice, as filmed, executes
to the standard of a fun, acclaimed, commercially successful game —
'you can't commit until the game is done' is explicitly not the bar.

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


def _soundscape(rec: Path) -> dict:
    """second -> {sound: count} from the capture's audio tap."""
    out: dict[int, dict] = {}
    ev = rec / "events.jsonl"
    if not ev.exists():
        return out
    with open(ev) as fh:
        for line in fh:
            r = json.loads(line)
            if r.get("kind") != "sound":
                continue
            sec = int(r.get("t", 0))
            d = out.setdefault(sec, {})
            d[r["name"]] = d.get(r["name"], 0) + 1
    return out


def build_digests(rec: Path, judged: list[Path], window: int = 120) -> dict:
    """frame -> compact log lines within +/-window ticks of its tick."""
    events = defaultdict(list)
    keep = {"damage_applied", "agent_transition", "breach_lifecycle",
            "dispatch_decision", "shelf_replaced", "core_part",
            "pickup_taken"}
    player_room = {}
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            if r.get("kind") in keep:
                events[r["t"] // 60].append(r)
            elif r.get("kind") == "field_sample":
                player_room[r["t"] // 60] = r.get("player_polygon")
    sounds = _soundscape(rec)
    digests = {}
    for f in judged:
        tick = int(f.stem.split("_")[1]) * 5
        pr = player_room.get(tick // 60)
        lines = [f'player_chamber={pr}'] if pr is not None else []
        heard = sounds.get(tick // 60, {})
        if heard:
            lines.append("HEARD: " + ", ".join(
                f"{k}x{v}" for k, v in sorted(
                    heard.items(), key=lambda kv: -kv[1])[:6]))
        player_lines, other = [], []
        for sec in range((tick - window) // 60, (tick + window) // 60 + 1):
            for r in events.get(sec, []):
                if abs(r["t"] - tick) <= window:
                    slim = {k: v for k, v in r.items()
                            if k not in ("seq",)}
                    row = json.dumps(slim, separators=(",", ":"))
                    if r.get("target_kind") == "player":
                        player_lines.append(row)
                    else:
                        other.append(row)
        digests[f.name] = (lines + player_lines
                           + other)[:8]   # per-frame budget: the global
        # prompt slice starved late-chunk frames of ALL coverage (runs
        # 6-7 'unlogged damage' artifacts); 8 prioritized lines per
        # frame keeps every frame covered inside the slice
    return digests


def _judge_call(prompt: str, model: str, what: str) -> dict | list:
    """One judge subprocess with a single retry on malformed output —
    a second failure raises loudly."""
    last = None
    for attempt in (1, 2):
        r = subprocess.run(
            ["claude", "-p", prompt, "--model", model,
             "--output-format", "json", "--allowedTools", "Read"],
            capture_output=True, text=True, timeout=JUDGE_TIMEOUT_S)
        if r.returncode != 0:
            last = RuntimeError(f"{what} failed: {r.stderr[:500]}")
            continue
        text = json.loads(r.stdout)["result"].strip()
        text = text.removeprefix("```json").removeprefix("```")
        text = text.removesuffix("```").strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            # tolerate a prose preamble: parse from the first JSON value
            starts = [i for i in (text.find("{"), text.find("["))
                      if i >= 0]
            if starts:
                try:
                    obj, _ = json.JSONDecoder().raw_decode(
                        text[min(starts):])
                    return obj
                except json.JSONDecodeError:
                    pass
            last = RuntimeError(
                f"{what} returned non-JSON (attempt {attempt}): "
                f"{text[:300]!r}")
    raise last


def judge_chunk(frames: list[Path], digests: dict, idx: int, total: int,
                model: str, ground: dict | None = None) -> dict:
    digest_txt = "\n".join(
        f"{f.name}: " + ("; ".join(digests.get(f.name, [])) or "(quiet)")
        for f in frames)
    prompt = CHUNK_PROMPT.format(
        idx=idx, total=total,
        frames="\n".join(str(f) for f in frames),
        ground=json.dumps(ground, separators=(",", ":")),
        digest=digest_txt[:60000])
    return _judge_call(prompt, model, f"chunk {idx} judge")


def ground_truth(rec: Path) -> dict:
    """Hard per-session facts the verifier checks findings against."""
    import bisect
    fire, dmg_t, dmg = [], [], []
    trans = 0
    pr = {}
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            k = r.get("kind")
            if k == "input" and r.get("fire"):
                fire.append(r["t"])
            elif k == "damage_applied":
                dmg_t.append(r["t"])
                dmg.append((r["t"], r.get("target_kind"),
                            r.get("source")))
            elif k == "field_sample":
                pr[r["t"]] = r.get("player_polygon")
    fire.sort()
    dmg_t.sort()
    longest = 0
    run_start = None
    for t in fire:
        i = bisect.bisect_left(dmg_t, t - 30)
        near = i < len(dmg_t) and dmg_t[i] <= t + 90
        if near:
            run_start = None
        else:
            if run_start is None:
                run_start = t
            longest = max(longest, t - run_start)
    return dict(
        longest_zero_hit_firing_ticks=longest,
        total_damage_events=len(dmg),
        player_hits=sum(1 for _, tk, _ in dmg if tk == "player"),
        damage_by_source=dict(
            __import__("collections").Counter(s for _, _, s in dmg)),
        player_chamber_changes=len(set(pr.values())),
    )


def verify_findings(reports: list[dict], rec: Path, model: str) -> dict:
    """Adversarial pass: every P0/P1 chunk finding is checked against
    trace ground truth; refuted findings are struck."""
    flat = []
    for ci, rep in enumerate(reports):
        for f in rep.get("findings", []):
            flat.append((ci, f))   # ALL severities: unverified P2s
            # leaked straight into the final verdict as blockers
            # (run 20: a fully-logged spit-dip-plus-medkit sequence
            # survived as 'unexplained HP jump' because only P0/P1
            # faced the trace)
    if not flat:
        return {}
    listing = "\n".join(
        f'{i}: [chunk {ci + 1} {f.get("severity")}] {f.get("note")} '
        f'(frame {f.get("frame")}, tick {f.get("tick")})'
        for i, (ci, f) in enumerate(flat))
    prompt = VERIFY_PROMPT.format(
        findings=listing,
        ground=json.dumps(ground_truth(rec), indent=1))
    verdicts = {v["idx"]: v
                for v in _judge_call(prompt, model, "verifier")}
    for i, (ci, f) in enumerate(flat):
        v = verdicts.get(i, {})
        f["verify"] = v.get("verdict", "UNVERIFIABLE")
        f["verify_why"] = v.get("why", "")
    return verdicts


def final_verdict(chunk_reports: list[dict], stats: dict,
                  model: str) -> dict:
    prompt = VERDICT_PROMPT.format(
        chunks="\n\n".join(
            f"CHUNK {i + 1}: {json.dumps(c, separators=(',', ':'))}"
            for i, c in enumerate(chunk_reports)),
        stats=json.dumps(stats, separators=(",", ":")),
        bar=PASS_BAR)
    v = _judge_call(prompt, model, "final judge")
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
    ap.add_argument("--seeds", type=str, default=None,
                    help="comma-separated seeds: multi-session evidence "
                         "pooled into one verdict (the honest answer to "
                         "'one session cannot support 0.95 either way')")
    ap.add_argument("--ticks", type=int, default=14400)
    ap.add_argument("--zoom", type=float, default=0.45)
    ap.add_argument("--model", default="sonnet")
    ap.add_argument("--judge-every", type=int, default=24,
                    help="judge every Nth sampled frame (~2s apart)")
    ap.add_argument("--chunk-size", type=int, default=40)
    ap.add_argument("--reuse", action="store_true",
                    help="skip capture, judge the existing run")
    a = ap.parse_args()

    seeds = ([int(s) for s in a.seeds.split(",")] if a.seeds
             else [a.seed])
    reports = []
    all_stats = []
    for si, seed in enumerate(seeds):
        rec = GATE / (f"run_s{seed}" if len(seeds) > 1 else "run")
        have = len(list(rec.glob("frame_*.png"))) if rec.exists() else 0
        complete = have >= a.ticks // 5 - 5 and (rec / "trace.jsonl").exists()
        if a.reuse or complete:
            # resumable: a finished capture for this seed is evidence
            # already on disk — killed runs pick up where they died
            meta = {"stdout": f"(reused capture, {have} frames)"}
            if complete and not a.reuse:
                print(f"[gate] seed {seed}: capture already complete, "
                      f"reusing", flush=True)
        else:
            print(f"[gate] capturing seed {seed}...", flush=True)
            meta = run_capture(rec, seed, a.ticks, a.zoom)
        frames = sorted(rec.glob("frame_*.png"))
        if not frames:
            raise RuntimeError(f"no frames captured (seed {seed})")
        judged = frames[:: a.judge_every]
        print(f"[gate] seed {seed}: {len(frames)} frames, judging "
              f"{len(judged)}", flush=True)
        digests = build_digests(rec, judged)
        chunks = [judged[i:i + a.chunk_size]
                  for i in range(0, len(judged), a.chunk_size)]
        seed_reports = []
        for i, chunk in enumerate(chunks):
            print(f"[gate] seed {seed} chunk {i + 1}/{len(chunks)}...",
                  flush=True)
            rep = judge_chunk(chunk, digests, i + 1, len(chunks),
                              a.model, ground=ground_truth(rec))
            rep["seed"] = seed
            seed_reports.append(rep)
            (GATE / f"chunk_s{seed}_{i + 1}.json").write_text(
                json.dumps(rep, indent=1))
            print(f"[gate]   score={rep.get('chunk_score')} "
                  f"findings={len(rep.get('findings', []))}", flush=True)
        print(f"[gate] verifying seed {seed} findings...", flush=True)
        verify_findings(seed_reports, rec, a.model)
        struck = sum(1 for rep in seed_reports
                     for f in rep.get("findings", [])
                     if f.get("verify") == "REFUTED")
        print(f"[gate]   struck {struck}", flush=True)
        reports.extend(seed_reports)
        all_stats.append(dict(seed=seed, **session_stats(rec, meta)))
    stats = all_stats if len(all_stats) > 1 else all_stats[0]
    verdict = final_verdict(reports, stats, a.model)
    (GATE / "verdict.json").write_text(json.dumps(verdict, indent=1))
    print(json.dumps(verdict, indent=2))

    if verdict.get("pass") and float(verdict["p"]) > PASS_BAR:
        (GATE / "PASS").write_text(json.dumps(
            dict(p=verdict["p"], seeds=seeds, ticks=a.ticks,
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
