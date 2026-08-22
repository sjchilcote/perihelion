#!/usr/bin/env python3
"""tools/design/consult_marrow.py

Consult an external model (GPT Sol, via consult_machinery.py's reusable
streaming engine) about THE MARROW -- the Adversary's off-map reserve depot,
its production organ, and the reinforcement layer built on top of them.

Input is assembled from real files on disk, never summarized:
  - DESIGN_7_25.md              the director-ratified spec (authoritative)
  - MARROW_CONSULT_PACKET.md    the research packet: sourced transplant
                                candidates from a deep-research fleet, plus a
                                critic's honest assessment of that research
  - the Bayescraft framework    our internal standard for evidence reasoning

We take Sol's answer with a grain of salt: it is one outside opinion with no
stake in our design, to be weighed against the director's rulings (which win)
and verified in a real run. This script only produces the consult; it
implements nothing.

Usage:
    uv run python tools/design/consult_marrow.py --dry-run   # build prompt only
    uv run python tools/design/consult_marrow.py             # the real consult

The API key is read from $OPENROUTER_API_KEY, else the gitignored key file at
the repo root, else the older shared key. The key is never printed.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO.parent / "noneuclideantopdownshooter" / "tools" / "musicgen"))
import consult_machinery as cm  # noqa: E402

SPEC = REPO / "DESIGN_7_25.md"
PACKET = REPO / "tools" / "design" / "MARROW_CONSULT_PACKET.md"
KEY_PATHS = [
    REPO / ".openrouter_key",
    Path.home() / "Documents" / "youtube" / "autoclipping" / ".openrouter_key",
]


def load_api_key() -> str | None:
    key = os.environ.get("OPENROUTER_API_KEY")
    if key and key.strip():
        return key.strip()
    for path in KEY_PATHS:
        if path.exists():
            text = path.read_text().strip()
            if text:
                return text
    return None


PRODUCT_CONTEXT = """
PERIHELION is a non-Euclidean, Teleglitch-like top-down survival shooter with a
strict Catholic register. The map is not a grid: it is a set of convex polygons
("chambers") joined by two-way portals in continuous space, so space folds --
a chamber can be adjacent to a chamber that is nowhere near it in world
coordinates, and everything (sight, sound, pathing, the coordination signals
described below) travels the PORTAL GRAPH, never euclidean distance.

The player is an outnumbered, undergunned Commando. Every enemy kind is faster,
heavier, and turns worse than he does, so escape is never outrunning -- it is
fighting backward while giving ground. The intended loop is: prepare the
battlespace (plant pods that fabricate assembly kits, carry ONE kit at a time
on your back at reduced speed, assemble sentries and repair stations in situ),
bite off what you can chew, and fall back when you cannot -- with the fallback
itself fought for, never free. Death does not reset the world: you revive at a
seed pod with the world exactly as you left it, and what you lose is the walk
back.

The enemy has two lanes. The corrupted-Testator agents (mite, husk, spitter,
brute, warden, shrieker, flicker) only fight. The ADVERSARY agents (classes
"vagrant" and "lacuna", both still to be designed) are the scouts: only they
can summon reinforcements, and their population is finite and non-renewing.
"""

ASK = """
================================================================================
THE ASK
================================================================================
You have been given, verbatim: our ratified design spec (DESIGN_7_25.md), and a
research packet of sourced mechanism candidates harvested from real literature
by a research fleet, with a critic's honest notes on which of that research is
thin or suspect.

We want two things from you.

--------------------------------------------------------------------------------
PART 1 -- YOUR OPINION ON THE OPEN QUESTIONS
--------------------------------------------------------------------------------
The packet ends with a numbered list of open design questions. Answer each one
with a RECOMMENDATION, not a menu. For each:

  - State the rule you would ship, concretely enough to implement.
  - Give the mechanism: why this produces the intended player experience, in
    terms of the actual systems described (signal fields on a portal graph,
    agents sampling only their own chamber and one hop away, a finite reserve,
    scouts that must physically travel and then stand still to transmit).
  - Name what it PREDICTS and what it FORBIDS -- an observation we could make
    in a real playtest that would show the rule is working, and one that would
    show it is not. If no observation could disconfirm it, say so and mark the
    idea as speculation rather than a recommendation.
  - Give your odds that it survives contact with a real playtest, and the
    single strongest reason you might be wrong.

Where the research packet and your own judgment disagree, say so explicitly and
back yourself or the packet with reasons. Where the packet's finding is flagged
suspect by the critic, do not lean on it without saying that you are.

--------------------------------------------------------------------------------
PART 2 -- A FIRST DRAFT OF THE MARROW
--------------------------------------------------------------------------------
Propose a concrete first implementation draft, at a level a senior engineer
could build from without inventing the design themselves:

  1. AGENT AND ENTITY INVENTORY -- what exists in the hub and in the world:
     the CORE as a SYSTEM of agents (tiers, support structures, regeneration,
     a DELAYED response to being damaged, self-defense), the guardian ring,
     the two scout classes, and what a breach actually is as an object.
  2. STATE -- every field each system reads and writes. Signals are per-chamber
     scalars spreading hop-by-hop and fading; each chamber stores the tick it
     was last updated so decay is computed from the delta. Say which existing
     signals you use and justify any NEW signal as strictly necessary.
  3. STATE MACHINES -- for the scout (infiltrate -> transmit -> pour, plus the
     garrison-expansion cycle), for the reserve/dispatch economy, and for the
     CORE's own tiers. Give transition conditions in terms of quantities an
     agent can actually sample locally.
  4. NUMBERS -- a first-pass value for every constant you introduce, with the
     reasoning that sets its order of magnitude, and which ones you expect to
     be wrong and want measured first.
  5. THE UPDATE LOOP -- what runs per tick, in what order, and what the cost
     scales with.
  6. THE FAILURE MODES YOU EXPECT -- for each, the cheapest instrument that
     would catch it in a real run.

--------------------------------------------------------------------------------
HARD CONSTRAINTS (a proposal that violates one of these is wrong)
--------------------------------------------------------------------------------
  - Agents sample ONLY their own chamber and chambers one portal away. There is
    no global view, no commander, and no unit whose death ends the response.
  - Scouts must not know the hub exists or read its state; breaches must not
    know about each other. Perception happens through a shared find/senses API
    -- agents ARE allowed to see things, they just may not reach into another
    system's internals.
  - A breach's portal connection must carry NO SCALING FACTOR. A scale mismatch
    between the hub interior and the world is the real bug that made a previous
    implementation's reinforcements physically unable to fit through the gate,
    and it is why the aperture rule is "simply wide enough that agents walk
    through on normal AI" with NO special-casing around entry.
  - No feature flags, no off-by-default, no compatibility shims. Behaviors ship
    hardwired and always-on; this is an unreleased game.
  - Far-simulation of agents outside the player's active window is planned but
    DEFERRED. Do not propose it or lean on it; design within a world where
    distant agents are not richly simulated, and note where that bites.
  - Do not impose a determinism requirement. It is a video game.

Be concrete and specific to OUR systems, referencing the spec's own vocabulary,
not a generic essay on swarm AI. Name the strongest reasons your own
recommendations might be wrong -- we will test the testable pieces, not defer
to you uncritically.
"""


def build_prompt() -> str:
    if not SPEC.exists():
        raise FileNotFoundError(f"spec missing: {SPEC}")
    if not PACKET.exists():
        raise FileNotFoundError(
            f"research packet missing: {PACKET}. It is produced by the research "
            f"fleet; this script inlines the REAL packet and will not substitute "
            f"a placeholder."
        )
    parts = [
        "EXTERNAL CONSULT: PERIHELION -- the Adversary's reserve depot ('the marrow'),\n"
        "its production organ, and the reinforcement layer.\n\n"
        "You are being asked for an outside opinion on a set of open design questions\n"
        "and for a concrete first implementation draft. The full ask is in the final\n"
        "section ('THE ASK'). Read the spec and the research packet first -- they are\n"
        "real and inlined verbatim, not summarized.\n",
        cm.section("0. PRODUCT CONTEXT", PRODUCT_CONTEXT.strip()),
        cm.section(
            "1. THE BAYESCRAFT FRAMEWORK (verbatim, our internal engineering "
            "standard -- reason this way, especially about your own confidence)",
            cm.extract_bayescraft(cm.GLOBAL_CLAUDE_MD),
        ),
        cm.section(
            "2. THE RATIFIED SPEC (DESIGN_7_25.md, verbatim). The director's "
            "rulings here are AUTHORITATIVE -- where your opinion differs, say so, "
            "but treat these as the constraints you are designing within.",
            SPEC.read_text(),
        ),
        cm.section(
            "3. RESEARCH PACKET (verbatim) -- sourced mechanism candidates from a "
            "deep-research fleet, with a critic's assessment of which findings are "
            "thin or suspect, and the open questions at the end.",
            PACKET.read_text(),
        ),
        ASK.strip(),
    ]
    return "\n\n".join(parts)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true",
                    help="Assemble and write prompt.txt, print its size, and exit WITHOUT calling the API.")
    ap.add_argument("--model", default=cm.DEFAULT_MODEL)
    ap.add_argument("--effort", default="high",
                    help="OpenRouter reasoning effort: max/xhigh/high/medium/low/minimal.")
    ap.add_argument("--max-tokens", type=int, default=cm.DEFAULT_MAX_TOKENS,
                    help="Ceiling, not a reservation -- do not shrink it (see consult_machinery.py).")
    ap.add_argument("--out-root", default=str(REPO / "out" / "consult" / "marrow"))
    args = ap.parse_args()

    api_key = load_api_key()
    if not args.dry_run and not api_key:
        print(
            "FATAL: no OpenRouter key. Checked $OPENROUTER_API_KEY and "
            + ", ".join(str(p) for p in KEY_PATHS)
            + ". Refusing to proceed; use --dry-run to build the prompt only.",
            file=sys.stderr,
        )
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
    print("Sections:")
    for m in re.finditer(r"^={10,}\n(.+)\n={10,}$", prompt, re.MULTILINE):
        print(f"  - {m.group(1)}")

    if args.dry_run:
        print("\n--dry-run: no API call made.")
        return 0

    print(
        f"\nCalling OpenRouter (Responses skin -- the one that survives a long "
        f"think): model={args.model} effort={args.effort} "
        f"max_output_tokens={args.max_tokens}\nStreaming to {out_dir} "
        f"(every chunk fsync'd on arrival; no read timeout).",
        file=sys.stderr,
    )
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
