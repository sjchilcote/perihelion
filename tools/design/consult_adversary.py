#!/usr/bin/env python3
"""tools/design/consult_adversary.py

The final synthesis pass on the Adversary enemy set: hand Sol the whole
translated research packet and the game's own canon, and ask for ONE
proposed roster.

The director's brief, 2026-07-28 (verbatim in THE ASK below): replace the
two placeholder Adversary enemies with final designs; they are the actual
interdimensional invaders, precious personnel who cannot stay in ordinary
space and must withdraw into a breach; the ordinary enemies are Testators
the Adversary repurposed and treats as somewhere between equipment and
wildlife; some coordination roles belong to Testators.

The research packet is produced by the research workflow and is already
translated out of its source domain — nothing biomedical survives into it.
This script REFUSES to send a packet that fails that check.

    uv run python tools/design/consult_adversary.py --dry-run
    uv run python tools/design/consult_adversary.py --effort max
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO / "tools" / "musicgen"))
import consult_machinery as cm  # noqa: E402

PACKET = REPO / "docs" / "consults" / "adversary_enemies_20260728" / "PACKET.md"
LEXICON = REPO / "out" / "adversary_research" / "LEXICON.md"
KEY_PATHS = [
    REPO / ".openrouter_key",
    Path.home() / "Documents" / "youtube" / "autoclipping" / ".openrouter_key",
]

PRODUCT_CONTEXT = """
PERIHELION is a non-Euclidean, Teleglitch-like top-down survival shooter with a
strict Catholic register. The map is not a grid: it is a set of convex polygons
("chambers") joined by two-way portals in continuous space, so space folds --
a chamber can be adjacent to a chamber that is nowhere near it in world
coordinates, and everything (sight, sound, pathing, the coordination signals)
travels the PORTAL GRAPH, never euclidean distance.

The player is an outnumbered, undergunned Commando. Every enemy kind is faster,
heavier, and turns worse than he does, so escape is never outrunning -- it is
fighting backward while giving ground. He prepares the battlespace (pods that
fabricate kits, carried one at a time at reduced speed, assembled into sentries
and repair stations in situ), bites off what he can chew, and falls back when
he cannot. Death does not reset the world: he reprints at a seed pod with the
world exactly as he left it, and what he loses is the walk back.

The enemy is a decentralized, non-conscious defensive swarm: no chain of
command, no commander to kill, no unit whose death ends the response. It
coordinates through nine per-chamber scalar signal fields that spread hop by
hop across the portal graph and decay by half-life, and every agent samples
only its own chamber and one portal away. Reinforcements come from an off-map
reserve -- THE MARROW, a corrupted cathedral -- through BREACHES that a scout
must physically travel to and stand still to open.
"""

ASK = """
================================================================================
THE ASK -- ONE PROPOSED ROSTER
================================================================================
THE DIRECTOR'S BRIEF, VERBATIM (2026-07-28):

  "We want to replace the two placeholder Adversary enemies with final designs,
  bearing in mind that these are the actual interdimensional invaders
  themselves. I like the idea that existing in zero-Otherworldness environments
  is difficult for them, so they need to retreat in to breaches after a while.
  The ordinary enemies are Testators repurposed by the Adversaries; the
  Adversaries see them as something between equipment and wildlife, utterly
  disposable, while the Adversaries themselves are precious personnel. [...]
  Some immune roles should go to Testators instead, e.g. the guy who drags your
  dead chassis to the 'control center.'"

You have been given the game's ratified design spec, its Adversary constitution
(the nine signal fields and the coordination behaviours), the current enemy
table, and a research packet: a catalogue of distributed-strategic-response
roles and unit behaviours, already translated out of its source domain into
tactics and game-design language by the research process. Weigh the packet --
it is raw material, not a decision.

CRUNCH IT DOWN. We want ONE roster, not a menu.

1. THE ADVERSARY ROSTER. How many distinct Adversary units should exist, and
   what is each one FOR? For each: its job in the distributed response (the
   query it answers that no other unit can), what it samples locally and what
   it then does, its abilities, its tells, how it dies, and what the player
   learns to do about it. Two placeholders exist today (named "vagrant" and
   "lacuna", differing only in hit points and broadcast duration) -- say
   exactly what each becomes or that it is deleted.

2. THE WITHDRAWAL RULE. Ordinary space is zero-Otherworldness and it wears on
   them. Give the exact rule: what accumulates, how fast, what the player SEES
   as it accumulates, what the unit does when it must go, what happens if its
   breach is gone or sealed, and what the player can do to hasten or exploit
   it. This must read in play as a threat with a clock, not as an anticlimax
   where the interesting enemy walks away. Say how you avoid that failure.

3. THE TWO-LANE RELATIONSHIP. The Adversary treats Testators as somewhere
   between equipment and wildlife -- utterly disposable -- and treats itself as
   precious. Make that legible in BEHAVIOUR, not in text: how does an Adversary
   unit spend Testators, and how does it protect itself? What does the player
   notice that tells him these are not the same kind of thing? What does the
   swarm do differently when an Adversary unit is present versus absent?

4. THE ROLE SPLIT. Walk the roles in the packet and assign each one to the
   Adversary lane or the Testator lane, with the reason. The director has
   already ruled that the courier who drags the wrecked chassis to the control
   centre is a Testator -- design that unit as part of your roster. Say which
   existing Testator kinds (mite, husk, spitter, brute, warden, shrieker,
   flicker) absorb which roles, and whether any should be replaced.

5. THE FINITE PERSONNEL POOL. The Adversary census is finite and non-renewing.
   Say how many of each unit a world should start with, how their loss should
   feel over a long session, and what changes in the swarm's behaviour as the
   pool is spent. Name the number you would ship and the reasoning that sets
   its order of magnitude.

6. WHAT TO BUILD FIRST. Order the roster into landing stages, each of which is
   a playable, filmable increment. Every gameplay change here has to pass a
   filmed playtest gate, so a stage that cannot be judged on film is wrong.

FOR EVERY RECOMMENDATION: state what it PREDICTS on film (an observation we
could make in a real recorded session that would show it working) and what it
FORBIDS (an observation that would show it is not). If nothing could
disconfirm it, mark it speculation rather than recommendation. Give your odds
it survives contact with a real playtest and the single strongest reason you
might be wrong.

HARD CONSTRAINTS (a proposal that violates one of these is wrong):
  - Agents sample ONLY their own chamber and chambers one portal away. No
    global view, no commander, no unit whose death ends the response.
  - Coordination happens through the existing signal fields where possible.
    Justify any NEW field as strictly necessary; nine is already a lot.
  - No feature flags, no off-by-default, no compatibility shims. Behaviours
    ship hardwired and always-on.
  - One symbol means exactly one thing. Rings are aggro and nothing else; body
    events draw on the body; the marker glob is the scent tag. Every on-screen
    mechanic must read at 0.45 zoom in a 640x360 internal frame.
  - No unit may freeze in an active state, and nothing may require
    far-simulation of agents outside the player's active window.
  - Keep the register: this is a Catholic-inflected industrial horror, not a
    science lecture. Name units in the game's voice.

WRITE IN THE GAME'S VOCABULARY. The research was deliberately translated out
of its source domain before it reached you; do not translate it back. If a
mechanism needs naming, name it in tactics or design terms.
"""


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


def banned_terms() -> list[str]:
    """The research lexicon's banned list -- the terms that must not have
    survived translation. Read from the internal lexicon (gitignored)."""
    if not LEXICON.exists():
        return []
    terms = []
    for line in LEXICON.read_text().splitlines():
        m = re.match(r"\s*[-*|]\s*`?([A-Za-z][A-Za-z0-9 '\-]{2,40})`?\s*[|:]", line)
        if m:
            terms.append(m.group(1).strip().lower())
    return terms


def check_packet(text: str) -> list[str]:
    """Refuse to send a packet that leaked its source domain. Returns the
    offending terms (empty = clean)."""
    low = text.lower()
    hits = []
    for t in set(banned_terms()):
        if len(t) < 4:
            continue
        if re.search(r"\b" + re.escape(t) + r"\b", low):
            hits.append(t)
    return sorted(hits)


def build_prompt() -> str:
    if not PACKET.exists():
        raise FileNotFoundError(
            f"research packet missing: {PACKET}. It is produced by the "
            f"adversary-immune-research workflow; this script inlines the REAL "
            f"packet and will not substitute a placeholder.")
    packet = PACKET.read_text()
    leaks = check_packet(packet)
    if leaks:
        raise SystemExit(
            "REFUSING to send: the packet still contains source-domain "
            "terminology the director required translated out of the research "
            f"process ({len(leaks)} terms: {', '.join(leaks[:12])}). Fix the "
            "packet, then re-run.")
    parts = [
        "EXTERNAL CONSULT: PERIHELION -- the final Adversary enemy roster.\n\n"
        "You are being asked to crunch a research catalogue and a ratified\n"
        "design spec down into ONE proposed set of enemies. The full ask is in\n"
        "the final section ('THE ASK'). Everything before it is real and\n"
        "inlined verbatim, not summarized.\n",
        cm.section("0. PRODUCT CONTEXT", PRODUCT_CONTEXT.strip()),
        cm.section(
            "1. THE BAYESCRAFT FRAMEWORK (verbatim, our internal engineering "
            "standard -- reason this way, especially about your own confidence)",
            cm.extract_bayescraft(cm.GLOBAL_CLAUDE_MD)),
        cm.section(
            "2. THE RATIFIED SPEC (DESIGN_7_25.md, verbatim). The director's "
            "rulings here are AUTHORITATIVE -- where your opinion differs, say "
            "so, but treat these as the constraints you design within.",
            (REPO / "DESIGN_7_25.md").read_text()),
        cm.section(
            "3. THE VISUAL CONSTITUTION (TESTATOR_DESIGN_LANGUAGE.md, verbatim) "
            "-- the four authorship lanes. The Adversary lane's look is law.",
            (REPO / "TESTATOR_DESIGN_LANGUAGE.md").read_text()),
        cm.section(
            "4. THE ENEMY TABLE AS BUILT (game/perihelion/sim.py excerpt) -- "
            "the seven Testator kinds, the two Adversary placeholders being "
            "replaced, and the organ parts.",
            _enemy_table()),
        cm.section(
            "5. THE SIGNAL FIELDS AS BUILT (game/perihelion/signals.py "
            "excerpt) -- the nine fields, their half-lives and spread.",
            _signal_table()),
        cm.section(
            "6. THE RESEARCH PACKET (verbatim) -- the translated catalogue of "
            "distributed-response roles and unit behaviours, with the critics' "
            "rejections and the open questions.",
            packet),
        ASK.strip(),
    ]
    return "\n\n".join(parts)


def _excerpt(path: Path, start: str, end: str) -> str:
    text = path.read_text()
    i = text.index(start)
    j = text.index(end, i)
    return text[i:j]


def _enemy_table() -> str:
    return _excerpt(REPO / "game/perihelion/sim.py",
                    "ENEMIES: dict[str, dict]", "SENTRIES: dict[str, dict]")


def _signal_table() -> str:
    return _excerpt(REPO / "game/perihelion/signals.py",
                    "class SignalKind", "class SignalNeighborhood")


def main() -> int:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--model", default=cm.DEFAULT_MODEL)
    ap.add_argument("--effort", default="max",
                    help="the director asked for max thinking")
    ap.add_argument("--max-tokens", type=int, default=cm.DEFAULT_MAX_TOKENS)
    ap.add_argument("--out-root",
                    default=str(REPO / "out" / "consult" / "adversary"))
    args = ap.parse_args()

    api_key = load_api_key()
    if not args.dry_run and not api_key:
        print("FATAL: no OpenRouter key; use --dry-run.", file=sys.stderr)
        return 2

    prompt = build_prompt()
    out_root = Path(args.out_root)
    out_root.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = out_root / stamp
    out_dir.mkdir(parents=True, exist_ok=False)
    (out_dir / "prompt.txt").write_text(prompt)

    print(f"Wrote {out_dir / 'prompt.txt'}")
    print(f"Prompt: {len(prompt):,} chars (~{cm.tokenish_size(prompt):,} tokens)")
    print(f"Packet clean against {len(set(banned_terms()))} banned terms.")
    for m in re.finditer(r"^={10,}\n(.+)\n={10,}$", prompt, re.MULTILINE):
        print(f"  - {m.group(1)}")
    if args.dry_run:
        print("\n--dry-run: no API call made.")
        return 0

    print(f"\nCalling OpenRouter (Responses skin): model={args.model} "
          f"effort={args.effort}\nStreaming to {out_dir}.", file=sys.stderr)
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
