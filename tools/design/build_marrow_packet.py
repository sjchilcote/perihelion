#!/usr/bin/env python3
"""tools/design/build_marrow_packet.py

Assemble MARROW_CONSULT_PACKET.md from the research fleet's journal.

The research portion is emitted MECHANICALLY from the fleet's structured
output -- no paraphrase, no summarizing pass -- so nothing is lost or
smoothed between what the researchers found and what the consult reads. The
framing and the open-question list are hand-written here.

The critic's findings are carried two ways: verbatim in its own section, and
INLINE as a warning on each candidate the critic named, so a reader cannot
encounter a suspect number without also seeing the objection to it.

Usage:
    uv run python tools/design/build_marrow_packet.py <journal.jsonl>
"""
from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
OUT = REPO / "tools" / "design" / "MARROW_CONSULT_PACKET.md"

FRAMING = """\
# Research packet: the marrow

Assembled for an external consult. Two things are inside:

1. **Sourced mechanism candidates** from a six-lane deep-research fleet. Each
   lane was required to actually fetch its sources (no writing from memory),
   walk links two hops deep, harvest quantitative detail, cite only what it
   fetched, and report dead ends. Every mechanism has been renamed into
   game-systems vocabulary; the source links are bare provenance.
2. **An adversarial critic's assessment of that research.** The critic
   independently re-fetched a sample of cited pages and checked the quoted
   figures against them. It confirmed most, and caught several real defects --
   a direct quotation attributed to a page that does not contain it, a rate
   derived by converting a stock fraction into a per-unit-time figure, a
   load-bearing ratio that is an uncited encyclopedia claim, and one lane that
   built its headline recommendation on an absence of evidence that a different
   lane had already filled with sources. Those are flagged INLINE below, on the
   candidates they indict.

**How to read this.** The candidates are inspiration, not authority. A flagged
number is not automatically wrong, but it must not be used as a tuning anchor
without saying that it is unverified. Where two lanes disagree on the same
quantity, both figures are given and neither has been adjudicated -- those
conflicts are listed at the end of the critic section and are open questions in
their own right.

The full game spec (`DESIGN_7_25.md`) is inlined separately in this consult and
is the authoritative document. Where a research candidate contradicts the spec,
the spec wins unless there is a compelling argument to change it -- and saying
so explicitly is more useful than quietly designing around it.
"""

OPEN_QUESTIONS = """\
# The open questions

Answer each with a recommendation you would ship, its mechanism, what it
predicts and forbids, and your odds it survives a real playtest.

1. **The CORE as a system of agents.** The spec says the CORE is "an organ, not
   a single static NPC" -- a system of agents, with regeneration, that is a real
   game area to fight through. What are its parts? What does the player attack,
   in what order, and what does each kill actually change? The research offers
   two attack surfaces with opposite time constants (producers deep inside
   versus the dispatch machinery at the hub's own mouth), an anchor lattice
   where destroying the structure displaces producers rather than killing them,
   and caretaker agents that rebuild it. Do you take that shape, and how does it
   avoid becoming a boss fight with extra steps?

2. **Reserve economy.** Size, regeneration, dispatch latency, and what happens
   when demand outruns supply. The research proposes a closed-loop governor
   driven by how empty the depot is (`regen = base * (1 + K*(1 - stock/cap))`)
   that never reads Distress, Noise, or kill counts -- which would satisfy our
   decoupling rule by construction. It also proposes that under sustained drain
   the marrow ships degraded "runt" agents, making the reserve state legible off
   the enemies' bodies instead of through a HUD. Do you endorse both? What are
   the numbers?

3. **Core-kill as a status effect.** The director has ruled that destroying the
   CORE takes the reinforcement layer offline for **a couple of minutes** and is
   a tactical tool the player applies before assaulting a fortified area -- not a
   run-ending event. Given your answer to (2), what values make a couple of
   minutes fall out of the economy rather than being hardcoded as a timer? What
   should the player observe during the blackout, and at its end?

4. **Dispatch and crossing.** Pour cadence, aperture, how the mouth's exact
   position is chosen, whether a used gate becomes self-amplifying, and what
   makes a gate stop being used. Hard constraints: the connection carries NO
   scaling factor, the aperture is simply wide enough that agents walk through on
   normal AI, and there is NO special-casing around entry. The research proposes
   the spotter transmits a *polygon* and the marrow resolves the seam by argmax
   over local agitation, drawn from a patch inventory precomputed at world build
   whose sites never grow in number, only in size. Does that hold up?

5. **The two scout classes, vagrant and lacuna.** They have only ever been
   placeholders. What differentiates them mechanically -- movement, sensing,
   where each is dangerous? The research suggests one that creeps along
   boundaries and can sense through a sealed portal without crossing it, versus
   one that moves in the open; and a transmit split into a cheap interruptible
   handshake and an expensive rooted broadcast. What is the exposure window
   during transmit, and how does the player learn to recognize it?

6. **Held ground and garrisons.** The director has ruled garrisons are emergent:
   agents settle around a leader (e.g. a Warden) who fortifies whatever room he
   is in, and leader AI is deferred -- for now leaders do not know they have
   followers. **One research lane argues the leader concept should be deleted
   entirely**, with any room converting whoever stands in it once its
   Distress-over-time integral crosses a threshold, and settled agents becoming
   weak fighters but very loud emitters (so the player who reads threat ratings
   ignores exactly the unit he should kill first). Adjudicate: leaderless
   conversion, the director's leader-anchored version, or both composed?

7. **Signal damping and cloaking.** The player's counterplay is a pheromone
   scrubber that severely damps all chemo-signals, and a pod-linked cleaning
   robot that clears splatter, piles corpses for the pod's roots, and emits a
   couple of components as salvage. Doctrine: an uncloaked base eventually gets
   found and purged, and that is intended. How should damping work numerically
   so cloaking is a real strategic choice rather than a mandatory tax? Does a
   scrubbed region read as suspiciously quiet to the enemy -- a hole in the
   signal field that is itself a signal?

8. **Where the reinforcement stream becomes the fight.** The spec's intent is
   that for most of a run, standing and fighting reinforcements is a better use
   of ammo and time than hunting the source, and that a competent player manages
   how much aggro he draws. What makes the stream fun to fight rather than a
   chore to grind? What is the pacing shape of a single breach's pour, and how
   should it feel different from a fight the player started himself?

9. **Anything we have not asked.** Name the load-bearing assumption in this
   design that you think is most likely wrong.
"""

ASK_NOTE = """\
---

*Note on the research above: it is inspiration harvested from real literature
and translated into game vocabulary. Treat a candidate as a proposal to weigh,
not a finding to implement. Several numbers are flagged unverified; do not build
a tuning anchor on one without saying so.*
"""


def load(journal: Path):
    """Read lane results and the critique, LAST-WINS per lane.

    A workflow resume re-runs the agents that failed and appends their fresh
    results after the first run's, so a lane can appear twice with different
    content. The critic ran in the resumed run and numbered its objections
    against THAT set, so keeping the last occurrence of each lane is what
    makes 'LANE D cand 10' point at the candidate the critic actually read.
    Keeping both copies would double-count the research and misalign every
    flag.
    """
    by_lane, critique = {}, None
    for line in journal.read_text().splitlines():
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        if ev.get("type") != "result":
            continue
        r = ev.get("result")
        if not isinstance(r, dict):
            continue
        if "candidates" in r:
            by_lane[lane_letter(r.get("lane", ""))] = r
        elif "thin_lanes" in r:
            critique = r
    return list(by_lane.values()), critique


def lane_letter(lane_name: str) -> str:
    """First letter of a lane label.

    Lanes label themselves inconsistently -- 'LANE G — ...' and bare
    'L — emergent focal points ...' both occur -- so accept either form.
    """
    m = re.match(r"\s*(?:LANE\s+)?([A-Z])\s*[—\-–:.]", lane_name or "")
    return m.group(1) if m else "?"


def build_flag_index(critique) -> dict:
    """Map (lane_letter, candidate_number) -> [critic objection strings].

    The critic writes objections as 'LANE B cand 4 — ...' or
    'LANE D cand 6 and cand 10 — ...'. Parse those into per-candidate flags so
    a suspect number can never be read without its objection.
    """
    flags = defaultdict(list)
    if not critique:
        return flags
    pool = (critique.get("unsourced_or_suspect_claims") or []) + (critique.get("thin_lanes") or [])
    for item in pool:
        m = re.match(r"\s*LANE\s+([A-Z])\b(.*)", item, re.DOTALL)
        if not m:
            continue
        letter, rest = m.group(1), m.group(2)
        nums = re.findall(r"cand(?:idate)?s?\s+(\d+)", rest[:200])
        for n in nums:
            flags[(letter, int(n))].append(item.strip())
        if not nums:
            flags[(letter, 0)].append(item.strip())
    return flags


def render_lane(lane, flags) -> str:
    letter = lane_letter(lane.get("lane", ""))
    out = [f"\n## {lane.get('lane', 'LANE ?')}\n"]

    lane_wide = flags.get((letter, 0), [])
    if lane_wide:
        out.append("> **CRITIC — lane-level warning.** " +
                   "\n>\n> ".join(w.replace("\n", "\n> ") for w in lane_wide) + "\n")

    for i, c in enumerate(lane.get("candidates") or [], start=1):
        out.append(f"\n### {letter}{i}. {c.get('mechanism_name', 'unnamed')}\n")
        for key, label in (
            ("what_the_source_actually_says", "What the source says"),
            ("numbers", "Numbers"),
            ("game_application", "Proposed game rule"),
            ("predicts_or_forbids", "Predicts / forbids"),
            ("beats_current_spec", "Beyond the current spec"),
            ("source_url", "Source"),
        ):
            val = (c.get(key) or "").strip()
            if val:
                out.append(f"**{label}.** {val}\n")
        for warn in flags.get((letter, i), []):
            out.append("> **CRITIC FLAG on this candidate.** " +
                       warn.replace("\n", "\n> ") + "\n")

    if lane.get("dead_ends"):
        out.append("\n**Dead ends reported by this lane** (absence of evidence is real output):\n")
        for d in lane["dead_ends"]:
            out.append(f"- {d}\n")
    if lane.get("walk_path"):
        out.append(f"\n**Link walk performed.** {lane['walk_path']}\n")
    if lane.get("sources"):
        out.append(f"\n**Sources fetched ({len(lane['sources'])}).**\n")
        for s in lane["sources"]:
            out.append(f"- {s}\n")
    return "".join(out)


def render_critique(critique) -> str:
    if not critique:
        return "\n# Critic assessment\n\n*(unavailable)*\n"
    out = ["\n# Critic assessment of the research (verbatim)\n",
           "\nAn adversarial critic independently re-fetched a sample of the cited "
           "sources and checked the quoted figures against them.\n"]
    for key, title in (
        ("thin_lanes", "Lane-level assessment"),
        ("unsourced_or_suspect_claims", "Unsourced or suspect claims"),
        ("missing_angles", "Angles the fleet did not cover"),
        ("vocabulary_violations", "Vocabulary violations"),
        ("strongest_candidates", "Strongest candidates, by the critic's judgment"),
    ):
        vals = critique.get(key) or []
        if not vals:
            continue
        out.append(f"\n## {title}\n\n")
        for v in vals:
            out.append(f"- {v}\n")
    return "".join(out)


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    journal = Path(sys.argv[1])
    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else OUT
    globals()["OUT"] = out_path
    if not journal.exists():
        print(f"FATAL: journal not found: {journal}", file=sys.stderr)
        return 2

    lanes, critique = load(journal)
    if not lanes:
        print(f"FATAL: no lane results in {journal}. Refusing to write an empty packet.",
              file=sys.stderr)
        return 1
    flags = build_flag_index(critique)

    lanes.sort(key=lambda l: lane_letter(l.get("lane", "")))
    n_cand = sum(len(l.get("candidates") or []) for l in lanes)
    n_src = sum(len(l.get("sources") or []) for l in lanes)

    parts = [FRAMING,
             f"\n*{len(lanes)} lanes, {n_cand} candidates, {n_src} sources fetched. "
             f"{len(flags)} candidate(s)/lane(s) carry a critic flag.*\n",
             "\n---\n\n# Research candidates\n"]
    parts += [render_lane(l, flags) for l in lanes]
    parts.append("\n---\n")
    parts.append(render_critique(critique))
    parts.append("\n---\n")
    parts.append(OPEN_QUESTIONS)
    parts.append(ASK_NOTE)

    text = "".join(parts)
    OUT.write_text(text)
    print(f"Wrote {OUT}")
    print(f"  {len(text):,} chars, ~{len(text.split()):,} words")
    print(f"  lanes={len(lanes)} candidates={n_cand} sources={n_src} flagged={len(flags)}")
    for l in lanes:
        letter = lane_letter(l.get("lane", ""))
        lf = sum(1 for (ll, _), v in flags.items() if ll == letter for _ in v)
        print(f"  - LANE {letter}: {len(l.get('candidates') or [])} candidates, "
              f"{len(l.get('sources') or [])} sources, {lf} flag(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
