#!/usr/bin/env python3
"""tools/design/consult_marrow_r3.py

Round 3 — the FINAL design consult before implementation. Rounds 1 and 2
settled the design (DESIGN_7_25.md §1b is the ratified shape). This round is
different in kind: Sol has never seen the codebase, and the ask is no longer
"what should exist" but "in what order do we build it against THIS code, and
what gate makes each unit unshippable while invalid."

New input this round: a codebase survey of the reverted base (module
inventory, GameSession tick pipeline, enemy AI, the portal/connect engine
surface, worldgen, economy state, verification infrastructure, and an
inventory of the discarded-but-minable 07-20→07-25 code).

Usage:
    uv run python tools/design/consult_marrow_r3.py --dry-run
    uv run python tools/design/consult_marrow_r3.py
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO.parent / "noneuclideantopdownshooter" / "tools" / "musicgen"))
sys.path.insert(0, str(REPO / "tools" / "design"))
import consult_machinery as cm  # noqa: E402
from consult_marrow import PRODUCT_CONTEXT, load_api_key  # noqa: E402

SPEC = REPO / "DESIGN_7_25.md"
ROUND2 = REPO / "docs" / "consults" / "marrow_20260725" / "sol_answer_round2.md"
SURVEY = REPO / "tools" / "design" / "CODEBASE_SURVEY_R3.md"

ASK = """\
================================================================================
THE ASK -- ROUND 3 (FINAL): THE IMPLEMENTATION AND VERIFICATION PLAN
================================================================================
The design is settled. DESIGN_7_25.md now contains the ratified shape (§1b),
including the director's rulings that overrode parts of your round-2 answer
(the Kin field STANDS as a diffusing scalar; the blackout is a ~90s placeholder
derived from reserve arithmetic, never a timer). Where the spec and your
round-2 answer disagree, THE SPEC WINS. Do not re-litigate the design.

What changes this round: you have the CODEBASE SURVEY — the real code this
must land in. An autonomous AI agent will execute your plan starting tonight,
working in multi-hour unattended stretches, committing per unit. The agent is
competent but will be operating without human review between commits. Your
plan is therefore not advice — it is a control system. Its job is to make it
STRUCTURALLY IMPOSSIBLE for that agent to ship an invalid result: a unit must
either land green through its gate or fail loudly and not land at all. History
shows the failure mode is real: a previous build shipped "reinforcements" that
could not physically fit through their own breach (a portal scale factor no
test ever checked), and the error survived for days because every check that
existed was a check the code could pass while wrong.

--------------------------------------------------------------------------------
PART 1 -- THE IMPLEMENTATION PLAN (dependency-ordered units)
--------------------------------------------------------------------------------
Produce an ordered list of implementation units. The order must respect real
dependencies (substrate before consumers) and front-load the instrumentation
that later gates need. For EACH unit give:

  - GOAL: one sentence, what exists after this unit that did not before.
  - FILES: exact modules to create or modify, against the survey. Respect the
    architecture: what belongs in Rust (engine/necore) vs Python
    (game/perihelion). Flag any unit that requires touching the Rust engine
    (runtime disconnect? dynamic room addition?) — those are the long poles,
    and the survey tells you what the engine can and cannot do today.
  - API: the public surface (signatures) this unit adds, and which later units
    consume it. Where the spec mandates decoupling (spotter never reads hub
    state; breaches never read each other; the reserve never reads player
    state), say how the MODULE BOUNDARY enforces it — not a comment, a
    structure: what the module is physically unable to import or see.
  - SIZE: order-of-magnitude (S/M/L) and what makes it L.
  - MINE: which discarded code from the 94b3397b range (survey section H) to
    lift, partially salvage, or ignore — and why.

Cover at minimum, in whatever order YOU determine is correct:
  the find/senses API; the signal-field substrate (all nine fields, stored
  tick-delta decay, hop spread); universal mass-scaled knockback + the
  kinematics rebalance + the weapon arithmetic changes (Tau 84, Warden 168);
  the coordination behaviors (fractional quorum, priority-budget flocking,
  chemotaxis, relay-recruit, stand-down, trails, raid fan); the marrow (hub
  area generation, reserve economy, dispatch queue, breach open/close at
  runtime, call-medium lease + imprints); scouts (vagrant, lacuna,
  weakest-in-room selection, garrison expansion); the Warden engulf; buildings
  (carry-one-kit, 30s unpack, sentry, repair station, scrubber, cleaning
  robot, pod roots); the CORE organ + hub interior; HUD strip + lighting; and
  the gauntlet4 integration of all of it.

Then draw the cut line: which prefix of the unit list is achievable in the
first overnight session by a fast, capable agent, such that the branch is
GREEN AND MEANINGFUL at every commit boundary (no half-wired substrate left
dangling)?

--------------------------------------------------------------------------------
PART 2 -- THE VERIFICATION PLAN (the gates)
--------------------------------------------------------------------------------
For EACH unit from Part 1, design the gate that makes an invalid result
unshippable. A gate has four layers; give all four wherever they apply:

  1. CONSTRUCTION ASSERTS / UNREPRESENTABLE STATES. What the code refuses to
     construct. Example already ratified: breach construction asserts the
     derived portal scale is 1±ε — the scale bug becomes a crash at build
     time, not a silent misbehavior. Find the equivalent for every unit:
     where can wrongness be made a type error, an import impossibility, or a
     constructor exception rather than a behavior?
  2. ISOLATED TEST VECTOR. A purpose-built minimal level + scripted scenario
     + a SPECIFIC machine-checkable expected outcome (numbers, not "it
     works"). The survey shows how tests build tiny levels today. State the
     assertion literally: "after N ticks, field value in chamber B is in
     [x, y]", "the agent's chamber sequence is exactly A,C,D", "all 8
     dispatched units are inside the world polygon set within 30s".
  3. LIVE-RUN EVIDENCE. What must be observed in a real gauntlet4 run, and
     HOW it is observed mechanically: which instrumentation (event logs,
     field dumps) the run produces and what an automated checker greps/judges
     from them. Where the claim is VISUAL (renderer, tells, animations), the
     project law is: a full run with a vision model checking every 5th frame
     — specify the rubric question the frames must answer.
  4. WHAT THIS GATE MAKES IMPOSSIBLE. Name the specific invalid result each
     layer catches, so a reviewer can check the gate is aimed at something.

Also design, as first-class units:
  - THE INSTRUMENTATION SPINE, built FIRST: a structured event/state log the
    sim emits (dispatch decisions, reserve levels, field snapshots, breach
    lifecycle, scout state transitions) that every later gate reads.
    Constraint: decoupled from the audio system, no coupling into render, and
    it must not impose determinism.
  - THE GLOBAL ACCEPTANCE HARNESS: the end-state definition of "the marrow
    unit is DONE" — the full checklist a final run must pass, including the
    behaviors that must be VISIBLE in a real run (a scout transmits → a wall
    opens → agents walk through on normal AI → the stream fights → the
    breach seals when starved), each tied to its mechanical check.
  - THE KILLBOX MEASUREMENT (open unit in the spec): the experiment design
    that answers whether fighting at the breach mouth strictly dominates,
    with the metrics named.

Numbers discipline, unchanged: tie every number to the reasoning that sets
its order of magnitude, and mark the ones you expect to be wrong.

--------------------------------------------------------------------------------
PART 3 -- RISKS AND LONG POLES
--------------------------------------------------------------------------------
  - Which engine gaps are the critical path, and the fallback shape for each
    that does NOT violate the constraints (e.g. if runtime disconnect does
    not exist in the engine: what is the honest breach-seal mechanism that
    is not a hack and not a feature flag?).
  - The three most likely ways the autonomous agent misbuilds this even WITH
    your gates, and what additional structure would catch each.
  - Anything in the survey that contradicts an assumption the ratified spec
    makes — say so plainly now, while it is cheap.

--------------------------------------------------------------------------------
CONSTRAINTS (unchanged, and a plan that violates one is wrong)
--------------------------------------------------------------------------------
  - Agents sample ONLY their own chamber and chambers one portal away.
  - Scouts must not know the hub exists; breaches must not know about each
    other; the reserve economy never reads player/fight state. Perception
    goes through the shared find/senses API.
  - A breach's portal connection carries NO SCALING FACTOR — carve both
    sides at the same width, assert derived scale == 1.
  - No special-casing around breach entry; the aperture is simply wide
    enough that agents walk through on normal AI.
  - No feature flags, nothing off-by-default, no parallel pathways where an
    existing system already covers the behavior — extend it.
  - One canonical version of any file; the game launches simply.
  - Far-simulation outside the active window is DEFERRED; design within that
    limit and say where it bites.
  - Do not impose a determinism requirement on the new systems.
  - Logging/instrumentation must not be coupled to the audio system.
"""


def build_prompt() -> str:
    for path, what in ((SPEC, "spec"), (ROUND2, "round-2 answer"), (SURVEY, "codebase survey")):
        if not path.exists():
            raise FileNotFoundError(f"{what} missing: {path}")
    parts = [
        "EXTERNAL CONSULT, ROUND 3 (FINAL): PERIHELION -- the implementation and\n"
        "verification plan for the ratified marrow design, against the real codebase.\n\n"
        "You answered rounds 1 and 2 of this consult; the design they produced is now\n"
        "ratified into the spec. This round you receive the CODEBASE SURVEY for the\n"
        "first time and produce the build plan. The full ask is in the final section.\n",
        cm.section("0. PRODUCT CONTEXT", PRODUCT_CONTEXT.strip()),
        cm.section("1. THE BAYESCRAFT FRAMEWORK (verbatim; reason this way)",
                   cm.extract_bayescraft(cm.GLOBAL_CLAUDE_MD)),
        cm.section("2. THE RATIFIED SPEC (DESIGN_7_25.md, verbatim). AUTHORITATIVE — "
                   "including §1b, which already folds in the accepted parts of your "
                   "round-2 answer and the director's overriding rulings.",
                   SPEC.read_text()),
        cm.section("3. YOUR ROUND-2 ANSWER (verbatim, for reference). Where it "
                   "disagrees with the spec, the spec wins.", ROUND2.read_text()),
        cm.section("4. THE CODEBASE SURVEY (new this round) — the real code the plan "
                   "must land in, surveyed today from the reverted base.",
                   SURVEY.read_text()),
        ASK.strip(),
    ]
    return "\n\n".join(parts)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--model", default=cm.DEFAULT_MODEL)
    ap.add_argument("--effort", default="high")
    ap.add_argument("--max-tokens", type=int, default=cm.DEFAULT_MAX_TOKENS)
    ap.add_argument("--out-root", default=str(REPO / "out" / "consult" / "marrow_r3"))
    args = ap.parse_args()

    api_key = load_api_key()
    if not args.dry_run and not api_key:
        print("FATAL: no OpenRouter key found.", file=sys.stderr)
        return 2

    prompt = build_prompt()
    out_root = Path(args.out_root)
    out_root.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = out_root / stamp
    out_dir.mkdir(parents=True, exist_ok=False)
    (out_dir / "prompt.txt").write_text(prompt)

    print(f"Wrote {out_dir / 'prompt.txt'}")
    print(f"Prompt size: {len(prompt):,} chars (~{cm.tokenish_size(prompt):,} tokens)")
    for m in re.finditer(r"^={10,}\n(.+)\n={10,}$", prompt, re.MULTILINE):
        print(f"  - {m.group(1)}")

    if args.dry_run:
        print("\n--dry-run: no API call made.")
        return 0

    print(f"\nCalling OpenRouter (Responses skin): model={args.model} effort={args.effort}\n"
          f"Streaming to {out_dir}", file=sys.stderr)
    return cm.stream_consult_responses(
        prompt=prompt,
        api_key=api_key,
        model=args.model,
        effort=args.effort,
        max_tokens=args.max_tokens,
        connect_timeout_s=30.0,
        out_dir=out_dir,
        provider_prefs={"order": ["openai"], "allow_fallbacks": False},
    )


if __name__ == "__main__":
    raise SystemExit(main())
