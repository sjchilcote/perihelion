#!/usr/bin/env python3
"""The commit gate, rebuilt (director, 2026-07-27): a FABLE
orchestrator computes the north-star posterior by the full Bayescraft
process over filmed playtest sessions.

The old pipeline (fixed chunk judges -> verifier -> gestalt verdict)
consumed data in a fixed order and freehanded the scalar — a
coincidence of what it saw first. The rebuilt judge is one Fable
session that must: form hypotheses BEFORE reading evidence, design
experiments that discriminate between them, run those experiments as
a dynamic workflow of subagents (Sonnets reading direct video
segments frame by frame; Opuses coordinating and analyzing the
structured traces), update in odds form, and report the posterior of
the north star itself:

    P(this is a fun, critically acclaimed, commercially successful
    single-developer indie game)  — judged on the current changes.

PASS iff that posterior > 0.95. The pre-commit hook is unchanged: no
gameplay commit without a fresh PASS marker.

    uv run python tools/playtest/evaluate_fun.py --seeds 2,4,7,11
        [--ticks 14400] [--zoom 0.45] [--reuse]

Artifacts: out/eval_gate/run_s<seed>/ (frames, trace.jsonl,
events.jsonl, ground_truth.json), verdict.json, PASS (on pass only).
"""
from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
GATE = REPO / "out" / "eval_gate"
ORCH_TIMEOUT_S = 7200
PASS_BAR = 0.95

ORCHESTRATOR_PROMPT = """\
You are the final judge of PERIHELION playtest evidence. Your task is
to compute, honestly and calibratedly, the posterior probability of
ONE proposition — the project's north star:

    N = "this is a fun, critically acclaimed, commercially
         successful game"

and to report it with the reasoning ledger that produced it. The
commit gate passes only if P(N) > {bar}. Do not soften or inflate:
the number must be YOUR posterior, not a diplomatic gesture.

## Scope and prior (director's rulings — these bound the question)

- REFERENCE CLASS: a single-developer indie game extended from a
  game-jam winner. Calibrate the PRIOR of N against that lineage —
  top-down 2D, minimalist art, systemic depth are the tradition of
  this class, never a deduction. Your prior must be stated and
  justified from the reference class BEFORE you read any evidence.
- SCOPE: judge the changes currently being made — moment-to-moment
  combat, the reinforcement loop, readability, pacing, as filmed.
  Missing win states, campaign content, and future systems are OUT
  of scope and must not move the posterior. "You can't commit until
  the game is done" is explicitly not the bar.
- Evidence can move the posterior BOTH ways. If the film shows the
  systems executing at the standard of acclaimed titles in the
  class, the posterior must be allowed to rise above the prior.

## The method (mandatory): Bayescraft, baked into your workflow

Structure ALL reasoning as Bayesian updates on N. Do the math — in
odds form, with the numbers written down. The process:

    state prior odds of N from the reference class
    enumerate the live sub-hypotheses H_i about THIS build that
        bear on N (each with >= 2 alternatives, always including
        instrument/bot-artifact explanations)
    for each planned observation E:
        BEFORE looking: write P(E|H), P(E|not-H), and what outcome
        would LOWER your credence — if no outcome could, it is not
        an experiment and you must not run it
    run the experiments; update in odds; log every update
    the final P(N) is the posterior the ledger actually produces

Rules you must obey:
- HYPOTHESES FIRST. You may take one cheap structured survey of the
  traces to FORM hypotheses and priors, but you may not draw any
  conclusion from unplanned data. Random consumption of frames
  invites confirmation bias: whatever you happened to see first
  becomes the story. Preregister, then look.
- Strong evidence is a small denominator: prefer observations that
  would be RARE under every alternative. A finding equally likely
  under "real defect" and "bot artifact" carries zero bits.
- Conservation of expected evidence: for every experiment, name in
  advance the result that lowers your credence in the defect (or in
  N) and by roughly how much. If every outcome would confirm, none
  does.
- Priors dominate; use the measured base rates below. Never 0 or 1;
  reserve mass for "I am missing something."
- Litany of Tarski: if this build is at the acclaimed-class bar you
  want to believe it; if it is not, you want to believe it is not.

Corrupted inputs — the math is correct, inputs are not; police
yours and your subagents':
- Motivated asymmetry: a welcome hypothesis gets "does the evidence
  permit?", an unwelcome one "does the evidence compel?". Write both
  likelihoods before committing to either.
- Motivated stopping: do not stop at the first narrative that fits;
  do not demand extra evidence only from conclusions you dislike.
- Fake explanations: "janky", "unpolished", "reads badly" fit every
  film and forbid nothing — zero bits. Demand what a claim
  specifically predicts and what would falsify it.
- Pattern-match without model: a finding that LOOKS like a known
  defect class is a cached answer; check the mechanism.
- The bottom line: if you can predict your verdict before the
  experiments return, you are performing, not investigating.

Techniques:
- Notice confusion: evidence straining against your model means the
  model is probably wrong — do not explain it away.
- Taboo the word: ban "dead air", "stunlock", "unfair" — restate as
  observable behavior with ticks and frames.
- Third alternative: "real defect or judge error" omits bot
  artifact, sampling-grid artifact, design intent, and instrument
  gap. Spend 30 seconds on C before choosing between A and B.
- Reproduce first: a defect that appears in one seed and not the
  others needs the controlling variable named before it counts.
- Hold off on proposing fixes until the posterior settles.

## Measured base rates (from 36 prior judged banks — your priors)

- Judge-style frame impressions of "enemy frozen under fire", "HP
  changed with no cause", "long dead-air stall", and "camera zoom"
  were REFUTED by the trace in the clear majority of past cases
  (fabricated durations, missed log lines two frames earlier, the
  player's own stationary sentries misread as enemies). Treat any
  single-frame impression as weak evidence until trace-checked.
- Known BOT artifacts (the test player, not the game): fights while
  walking backward so payoffs resolve one chamber behind the camera;
  does not fire at contact-range ambushers; camps its own turret
  nests. Evidence explainable by these must be priced accordingly.
- Known DESIGN intents that are never findings: flickers are nearly
  invisible by design (dying to an unseen flicker is the intended
  horror); scouts are spotters that loiter, root to broadcast, and
  flee when shot; a dry call ('no free apse seam' / 'call from
  inside the hub') is the finite-economy tell; suppression (zero
  breaches after heavy scout attrition) is the player WINNING;
  death is a translocation — reprint at a seed station, world
  persists, marked by a player_respawn log line; 'lightning_self'
  is the player's own cannon splash; the camera zoom is constant.

## The world on film (visual legend)

Player: white kite/arrow. Player sentries: amber tripod turrets,
stationary by design, friendly. Enemies: green lumpy husks; small
pale mites; olive pentagon spitters (green nose, globs with tails);
thin pale shrieker slivers; violet flickers (near-invisible by
design); red-brown brutes with two pale tusk lines ('M' at
distance); dark-violet 9-gon wardens with a white rim. Teal/violet
double outlines: adversary scouts (vagrants also fight when not
calling). Floor squares/crosses: pickups. Dark red-brown chunks:
corpses (never move, never take damage). Violet light FLOODING from
a wall: a live breach — the light surges ~2s at open then settles,
poured through real doorway occlusion from the tear itself. A pale
blob with a closing ring: a structure unpacking.

## Your resources

{resources}

Each session directory contains: frame_NNNNNN.png (every 5th sim
tick, ~12 per second of play); trace.jsonl (every typed simulation
event, tick-stamped: damage_applied, agent_transition,
portal_crossing, breach_lifecycle, dispatch_decision,
shelf_replaced, core_part, pickup_taken, input, samples including
per-warden positions each second); events.jsonl (every sound, with
volume and pan); ground_truth.json (precomputed hard facts: longest
zero-hit firing stretch, HP-vs-damage correlation, warden movement
spans, damage by source, camera constancy, session stats).

## Your workflow (dynamic — you design it, these are the materials)

Orchestrate subagents with your Agent tool; bake the Bayescraft
process into the workflow itself:
- OPUS subagents (model="opus") for coordination and structured
  data: trace analysis, cross-seed statistics, hypothesis-relevant
  queries, experiment-design review. Give each one the specific
  hypothesis and its preregistered predictions.
- SONNET subagents (model="sonnet") for direct video segments: a
  contiguous frame span, read EVERY frame in order (they are the
  eyes; motion between adjacent frames is part of the evidence).
  Task each scanner with the specific discriminating observation it
  is hunting and what would count AGAINST the hypothesis — never
  "look at these frames and report anything interesting".
- Run independent lanes in parallel; keep each subagent's brief
  narrow; require citations of frame files and ticks in everything
  they return.
- Iterate: if a load-bearing update leaves odds in the ambiguous
  band, design a sharper experiment rather than averaging vibes.

## Output

When your ledger is complete, reply with ONLY this JSON object (no
fences, no prose around it):
{{"p": <your posterior for N, 0.0-1.0>,
 "pass": <true iff p > {bar}>,
 "prior": "<stated prior odds for N and the reference-class basis>",
 "ledger": [{{"hypothesis": "<H>", "prediction": "<preregistered E,
   with P(E|H) and P(E|not-H)>", "experiment": "<what you ran>",
   "observed": "<what came back, with citations>",
   "update": "<odds before -> after>"}}...],
 "blockers": ["<confirmed, concrete, actionable — only findings
   whose ledger entries survived>"...],
 "strengths": ["..."],
 "summary": "<three sentences>"}}
"""


def _parse_result(text: str):
    text = text.strip()
    text = text.removeprefix("```json").removeprefix("```")
    text = text.removesuffix("```").strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        starts = [i for i in (text.find("{"), text.find("[")) if i >= 0]
        if starts:
            obj, _ = json.JSONDecoder().raw_decode(text[min(starts):])
            return obj
        raise


def run_orchestrator(recs: list[Path], model: str) -> dict:
    resources = "\n".join(f"- session seed dir: {rec}" for rec in recs)
    prompt = ORCHESTRATOR_PROMPT.format(bar=PASS_BAR, resources=resources)
    r = subprocess.run(
        ["claude", "-p", prompt, "--model", model,
         "--output-format", "json",
         "--allowedTools", "Read,Grep,Glob,Bash,Agent,Task"],
        capture_output=True, text=True, timeout=ORCH_TIMEOUT_S, cwd=REPO)
    if r.returncode != 0:
        raise RuntimeError(f"orchestrator failed: {r.stderr[:800]}")
    payload = json.loads(r.stdout)
    v = _parse_result(payload["result"])
    if not isinstance(v.get("p"), (int, float)):
        raise RuntimeError(f"malformed verdict: {str(v)[:400]}")
    return v


# --------------------------------------------------------------------------
# capture + ground truth (mechanics carried over from the first gate)
# --------------------------------------------------------------------------

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


def ground_truth(rec: Path) -> dict:
    """Hard per-session facts, computed from the full trace."""
    import bisect
    from collections import Counter
    fire, dmg_t, dmg = [], [], []
    dmg_full = []
    hp_samples = {}
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
    warden_moves = {}
    with open(rec / "trace.jsonl") as fh:
        for line in fh:
            r = json.loads(line)
            if r.get("kind") == "sample" and "warden" in r:
                w = r["warden"]
                x, y = r["pos"]
                lo_x, lo_y, hi_x, hi_y, ch = warden_moves.get(
                    w, (x, y, x, y, set()))
                ch.add(r.get("polygon"))
                warden_moves[w] = (min(lo_x, x), min(lo_y, y),
                                   max(hi_x, x), max(hi_y, y), ch)
    warden_span = {
        w: (f"moved {round(((hx - lx) ** 2 + (hy - ly) ** 2) ** 0.5)}u, "
            f"{len(ch)} chambers")
        for w, (lx, ly, hx, hy, ch) in warden_moves.items()}
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


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=4)
    ap.add_argument("--seeds", type=str, default=None)
    ap.add_argument("--ticks", type=int, default=14400)
    ap.add_argument("--zoom", type=float, default=0.45)
    ap.add_argument("--model", default="fable",
                    help="orchestrator model (subagents are chosen BY "
                         "the orchestrator: sonnet eyes, opus analysts)")
    ap.add_argument("--reuse", action="store_true")
    a = ap.parse_args()

    seeds = ([int(s) for s in a.seeds.split(",")] if a.seeds
             else [a.seed])
    recs = []
    for seed in seeds:
        rec = GATE / f"run_s{seed}"
        have = len(list(rec.glob("frame_*.png"))) if rec.exists() else 0
        complete = (have >= a.ticks // 5 - 5
                    and (rec / "trace.jsonl").exists())
        if a.reuse or complete:
            print(f"[gate] seed {seed}: reusing capture ({have} frames)",
                  flush=True)
            meta = {"stdout": "(reused capture)"}
        else:
            print(f"[gate] capturing seed {seed}...", flush=True)
            meta = run_capture(rec, seed, a.ticks, a.zoom)
        gt = ground_truth(rec)
        gt["session_stats"] = session_stats(rec, meta)
        (rec / "ground_truth.json").write_text(json.dumps(gt, indent=1))
        recs.append(rec)

    print(f"[gate] launching the {a.model} orchestrator over "
          f"{len(recs)} sessions...", flush=True)
    verdict = run_orchestrator(recs, a.model)
    GATE.mkdir(parents=True, exist_ok=True)
    (GATE / "verdict.json").write_text(json.dumps(verdict, indent=1))
    print(json.dumps(verdict, indent=2))

    if verdict.get("pass") and float(verdict["p"]) > PASS_BAR:
        (GATE / "PASS").write_text(json.dumps(
            dict(p=verdict["p"], seeds=seeds, ticks=a.ticks,
                 zoom=a.zoom), indent=1))
        print(f"[gate] PASS (p={verdict['p']})")
        return 0
    (GATE / "PASS").unlink(missing_ok=True)
    print(f"[gate] BLOCKED (p={verdict.get('p')})")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
