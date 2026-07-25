#!/usr/bin/env python3
"""tools/design/consult_marrow_r2.py

Round 2 of the marrow consult. Round 1 (see docs/consults/marrow_20260725/)
answered nine open questions and produced a first implementation draft. A
second research wave then covered the angles round 1's critic found missing --
wave composition, quorum proper, spacing/repulsion, the learning layer,
allocation across simultaneous demand sites, legibility of an off-screen
system, emergent focal points, and defended-home-site architecture.

Several wave-2 findings directly challenge either the ratified spec or round
1's own draft. This round hands the model its OWN previous answer plus the new
research and asks it to revise where the evidence goes against it, then to
design the parts it could not reach the first time -- above all the hub, which
the director has named as an open unit ("an entire game area unto itself").

Usage:
    uv run python tools/design/consult_marrow_r2.py --dry-run
    uv run python tools/design/consult_marrow_r2.py
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO / "tools" / "musicgen"))
sys.path.insert(0, str(REPO / "tools" / "design"))
import consult_machinery as cm  # noqa: E402
from consult_marrow import PRODUCT_CONTEXT, load_api_key  # noqa: E402

SPEC = REPO / "DESIGN_7_25.md"
ROUND1 = REPO / "docs" / "consults" / "marrow_20260725" / "sol_answer.md"
PACKET2 = REPO / "tools" / "design" / "MARROW_PACKET_WAVE2.md"

ASK = """\
================================================================================
THE ASK -- ROUND 2
================================================================================
You have been given: the ratified spec, YOUR OWN round-1 answer verbatim, and a
second research wave covering the angles a critic found missing from round 1.
The wave-2 critic independently re-fetched 16 cited pages across all six lanes
and confirmed every quoted figure, so this material is better sourced than
round 1's -- but it also carries flagged defects, marked inline, which you must
not lean on without saying that you are.

--------------------------------------------------------------------------------
PART 1 -- REVISE YOUR OWN DRAFT WHERE THE NEW EVIDENCE GOES AGAINST IT
--------------------------------------------------------------------------------
Several wave-2 findings bear directly on decisions you already made. For each of
the following, state whether you CHANGE your round-1 position or KEEP it, and
why. Changing your mind on good evidence is the point of this round; so is
refusing to change it on bad evidence. Be explicit about which you are doing.

  1. QUORUM. Your draft, and the ratified spec, wake an idle agent when an
     absolute signal level crosses a per-agent threshold. Wave-2 lane H reports
     a verified result that decisions of this kind key on the ACTIVE FRACTION an
     agent can sense -- a denominator, not a level -- and that this beats the
     absolute-count model. If that is right, our spec's own quorum rule is
     wrong. Adjudicate, and if you adopt a fraction rule, define exactly what
     the denominator is for an agent that samples only its own chamber and one
     hop away.

  2. THE KIN FIELD. Your draft adds Kin as the one new signal. Wave-2 lane I
     reports a verified mechanism where an agent counts CONTACTS with friendlies
     and turns DOWN its own recruitment emission -- achieving spread-out
     behaviour with no new field at all. If that works, we should not add a
     signal. Which do you ship?

  3. FLOCKING. The spec says "keep-apart weighted above bunch-together". Wave-2
     lane I reports the primary source arguing that weighted averaging FAILS
     when steering requests oppose, and that a priority budget with a 1/d^2
     falloff is correct. If so, the spec's literal wording produces the doorway
     jitter we do not want. Do you correct it?

  4. DECAY LAW ERROR. Two wave-2 lanes prescribe giving one signal ~2x the
     amplitude of another so it "outlasts it by ~2.4x". The critic showed that
     ratio comes from a source fitting LINEAR decay, while our fields decay
     EXPONENTIALLY from a stored tick delta -- under which 2x amplitude buys
     exactly one extra half-life, an additive offset, not a multiplier. Restate
     how Danger, Trail, and Patrol should be separated in TIME given exponential
     decay, in concrete decay constants, so the intended ordering actually holds.

  5. WAVE COMPOSITION. Round 1 gave a fixed percentage mix. Wave-2 lane G
     reports that the roster at the depot is NOT the roster that shows up at
     contact -- the mix inverts at the point of fighting -- and separately that a
     large fraction of a depot's population is permanently idle and, once
     removed, is never replaced. Both bear on our finite-scout rule and on what
     a breach should pour. Revise your composition model.

  6. ANYTHING ELSE in your round-1 draft that this wave contradicts. Name it
     yourself; do not wait to be asked.

--------------------------------------------------------------------------------
PART 2 -- DESIGN THE HUB AS A GAME AREA
--------------------------------------------------------------------------------
This is the director's largest named open unit: the hub is "an entire extremely
difficult game area unto itself", a Testator construction the Adversary
corrupted to its own ends, reachable ONLY through a live breach. Round 1 gave an
eight-chamber graph; that is a start, not a level. Design it properly:

  - SPATIAL GRAMMAR: how many chambers, their depth ordering from the arrival
    point, what sits deepest and why, the geometry of the approach, where the
    guardian force lives relative to the arrival point, and how traffic routes
    internally. Wave-2 lane L has sourced material on defended-home-site
    architecture -- chamber counts, depth distributions, entrance necks, guard
    fractions. Use what is real and say when you are inventing.
  - THE ARRIVAL PROBLEM: the player crosses a breach mid-fight and lands in the
    hub. What does he see in the first three seconds that tells him where he is,
    what is dangerous, and which way is deeper? Legibility on arrival, with no
    HUD and no objective marker.
  - THE RAID ARC: what the first, middle, and last minute of a hub raid feel
    like, and how the guardian force being simultaneously the dispatch shelf
    (your round-1 unification) makes timing the raid the actual skill.
  - THE WAY OUT: the player arrived through a portal that seals. What are his
    honest options, and what does the design teach a player who did not plan?
  - WHAT MAKES IT DIEGETICALLY TESTATOR: it is corrupted architecture, not an
    organic nest. Give the visual and structural grammar that reads as
    "something built, then infested".

--------------------------------------------------------------------------------
PART 3 -- THE PARTS ROUND 1 COULD NOT REACH
--------------------------------------------------------------------------------
  - LEGIBILITY OF AN OFF-SCREEN SYSTEM. The whole hub raid is gated on the
    player NOTICING a process that happens out of sight. Wave-2 lane K proposes
    that gate latency is itself the reserve gauge -- an observable generated by
    the same arithmetic it reports on, so it cannot lie. What is the full set of
    honest tells, ranked by how much they tell an attentive player, and what is
    the first one a new player is likely to notice?
  - MULTI-BREACH ALLOCATION. The spec says simultaneous breaches "split enemies
    evenly"; round 1 implemented strict round-robin. Wave-2 lane K researched how
    a distributed supplier actually allocates finite output across competing
    demand sites. Keep round-robin or replace it?
  - THE LEARNING LAYER. Adaptive counter-biasing, evidence relay, and counterplay
    reward are three ratified items nothing has yet implemented. Wave-2 lane J
    covers distributed memory and, importantly, FORGETTING -- which is what makes
    switching tactics pay. Propose the smallest version that produces the
    intended feel: repeating one tactic makes the counter increasingly effective,
    switching measurably slips it. Note that lane J is flagged for loose
    transplants and invented timing constants; treat its numbers with suspicion.
  - EMERGENT FOCAL POINTS. Your round-1 garrison keeps the leader oblivious via a
    follower dwell timer. Wave-2 lane L researched how a focal point forms around
    an individual that emits nothing intentional. Does anything there improve
    your rule?

--------------------------------------------------------------------------------
CONSTRAINTS (unchanged, and a proposal that violates one is wrong)
--------------------------------------------------------------------------------
  - Agents sample ONLY their own chamber and chambers one portal away.
  - Scouts must not know the hub exists; breaches must not know about each other.
    Perception goes through the shared find/senses API.
  - A breach's portal connection carries NO SCALING FACTOR -- a scale mismatch
    between hub interior and world is the real bug that previously made
    reinforcements unable to fit through the gate.
  - No special-casing around breach entry; the aperture is simply wide enough
    that agents walk through on normal AI.
  - No feature flags, nothing off-by-default.
  - Far-simulation of agents outside the active window is DEFERRED and out of
    scope. Design within that limit and say where it bites.
  - Do not impose a determinism requirement.

Keep every number you give tied to the reasoning that sets its order of
magnitude, and keep telling us which ones you expect to be wrong. Where you
disagree with the ratified spec, say so plainly and argue it -- the director
would rather hear a good objection than a compliant design.
"""


def build_prompt() -> str:
    for path, what in ((SPEC, "spec"), (ROUND1, "round-1 answer"), (PACKET2, "wave-2 packet")):
        if not path.exists():
            raise FileNotFoundError(f"{what} missing: {path}")
    parts = [
        "EXTERNAL CONSULT, ROUND 2: PERIHELION -- revising the marrow draft against new\n"
        "research, and designing the hub as a game area.\n\n"
        "You answered round 1 of this consult. Your own answer is inlined below, along\n"
        "with a second research wave that covers what round 1 missed. The full ask is in\n"
        "the final section.\n",
        cm.section("0. PRODUCT CONTEXT", PRODUCT_CONTEXT.strip()),
        cm.section("1. THE BAYESCRAFT FRAMEWORK (verbatim; reason this way, especially "
                    "about whether to change your own mind)",
                    cm.extract_bayescraft(cm.GLOBAL_CLAUDE_MD)),
        cm.section("2. THE RATIFIED SPEC (DESIGN_7_25.md, verbatim). Authoritative -- but "
                    "if the new evidence shows a specific rule in it is wrong, say so and "
                    "argue the correction.", SPEC.read_text()),
        cm.section("3. YOUR ROUND-1 ANSWER (verbatim). This is the draft you are revising.",
                    ROUND1.read_text()),
        cm.section("4. RESEARCH WAVE 2 (verbatim) -- the angles round 1's critic found "
                    "missing, with a critic's verification pass and inline flags.",
                    PACKET2.read_text()),
        ASK.strip(),
    ]
    return "\n\n".join(parts)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--model", default=cm.DEFAULT_MODEL)
    ap.add_argument("--effort", default="high")
    ap.add_argument("--max-tokens", type=int, default=cm.DEFAULT_MAX_TOKENS)
    ap.add_argument("--out-root", default=str(REPO / "out" / "consult" / "marrow_r2"))
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
