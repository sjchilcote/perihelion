"""tools/dialogue/assemble_regen.py

Assembles the final regenerated Scene 0/1/4 prose from the raw Hermes
candidates in tools/dialogue/candidates/regen_scene{0,1,4}_run*.json,
selected per the director's naturalism-regen pass, and logs a difflib
similarity ratio for every shipped line-block against its raw source
block (must be >= 0.85 -- confirms the shipped text is Hermes verbatim,
not rewritten).

Selection (see the run's chat log for the rubric reasoning):
  - Scene 0: opening + choice block + INQUISITIVE reaction from run1
    candidate 0 (T=0.85) -- best natural/reactive register, but two of
    that candidate's reaction blocks were disqualified:
      * its ELSEIF (hostile) reaction contained "I do not know your
        Testament", a proper-noun violation (Ratio repeating "Testament"
        even qualified by "your" -- the locked vocabulary taboo bans her
        saying the word at all, not just the exact substring "the
        Testament"). Swapped in the ELSEIF block from run3 candidate 2
        (T=0.95), which is clean and sharper in kind ("What evidence led
        you to the conclusion that I conduct experiments, and upon
        whom?").
      * its ELSE (mission) reaction opened "The sample vessel is in
        stasis, exactly as the emergency protocol requires" -- a design
        defect flagged by the director: it CONFIRMS at first contact
        that the container exists aboard, destroying the bluff economy
        (scene 1's whole function is testing his claimed knowledge;
        scene 0's canon exit state is that neither party has confirmed
        anything). Swapped in the ELSE block from run3 candidate 0
        (T=0.85), which refuses the category without confirming or
        denying any cargo ("I have no record of any such category
        aboard this station") and turns the interrogation around
        (identity, evidence, nature of his interest).
  - Scene 1: run1 candidate 2 (T=0.95) entire, unmodified -- ticking-
    clock urgency, no mechanics narration, LHX continuity intact.
  - Scene 4: run1 candidate 2 (T=0.95) entire, unmodified -- reciprocal
    offer of her own outdated schematics as "something happening under
    the words", technical readings carrying real weight (Exhibit 8),
    economical handover (Exhibit 3).

Run:
    uv run python tools/dialogue/assemble_regen.py
"""
from __future__ import annotations

import difflib
import json
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
CAND = TOOL_DIR / "candidates"


def load(path: str, idx: int) -> str:
    d = json.loads((CAND / path).read_text())
    for c in d["candidates"]:
        if c["candidate"] == idx:
            return c["text"]
    raise KeyError(f"{path} candidate {idx} not found")


def ratio(a: str, b: str) -> float:
    return difflib.SequenceMatcher(None, a.strip(), b.strip()).ratio()


def join_wrapped(block: str) -> str:
    """Collapse a block that may contain hard line-wraps mid-turn (the model
    sometimes wraps a long RATIO:/COMMANDO: line across physical lines) back
    into one physical line per turn -- the compositor's parser requires
    exactly one line per speaker turn. A continuation line is one that does
    NOT start a new RATIO:/COMMANDO:/<<.../>>/>> CHOICE token."""
    out_lines: list[str] = []
    for raw_line in block.splitlines():
        line = raw_line.rstrip()
        if not line.strip():
            out_lines.append(line)
            continue
        starts_new = (
            line.lstrip().startswith("RATIO:") or line.lstrip().startswith("COMMANDO:")
            or line.lstrip().startswith("<<") or line.lstrip().startswith(">>")
            or line.lstrip().startswith("[")
        )
        if starts_new or not out_lines:
            out_lines.append(line)
        else:
            out_lines[-1] = out_lines[-1].rstrip() + " " + line.strip()
    return "\n".join(out_lines)


def split_scene0_blocks(text: str) -> dict:
    """Split a scene-0 candidate into (opening, choice, if_react, elseif_react, else_react)."""
    lines = text.splitlines()
    idx_choice = next(i for i, l in enumerate(lines) if l.strip().startswith(">> CHOICE"))
    idx_if = next(i for i, l in enumerate(lines) if l.strip().startswith("<<IF flag:opened_inquisitive>>"))
    idx_elseif = next(i for i, l in enumerate(lines) if l.strip().startswith("<<ELSEIF flag:called_her_apostate>>"))
    idx_else = next(i for i, l in enumerate(lines) if l.strip() == "<<ELSE>>")
    idx_end = next(i for i, l in enumerate(lines) if l.strip() == "<<END>>")
    return {
        "opening": "\n".join(lines[:idx_choice]).strip(),
        "choice": "\n".join(lines[idx_choice:idx_if]).strip(),
        "if_react": "\n".join(lines[idx_if + 1:idx_elseif]).strip(),
        "elseif_react": "\n".join(lines[idx_elseif + 1:idx_else]).strip(),
        "else_react": "\n".join(lines[idx_else + 1:idx_end]).strip(),
    }


def main() -> None:
    log = {"blocks": []}

    # ---- Scene 0 ----
    s0_run1_c0 = load("regen_scene0_run1.json", 0)
    s0_run3_c2 = load("regen_scene0_run3.json", 2)
    s0_run3_c0 = load("regen_scene0_run3.json", 0)
    b_primary = split_scene0_blocks(s0_run1_c0)
    b_donor = split_scene0_blocks(s0_run3_c2)
    b_donor_elseif_raw = b_donor["elseif_react"]
    b_donor["elseif_react"] = join_wrapped(b_donor_elseif_raw)
    b_donor2 = split_scene0_blocks(s0_run3_c0)
    else_react_raw = b_donor2["else_react"]
    else_react = join_wrapped(else_react_raw)

    scene0_final = f"""## SCENE 0: the first networked terminal, cargo section, Stratum One

{b_primary['opening'].split(chr(10), 1)[-1] if b_primary['opening'].startswith('##') else b_primary['opening']}

{b_primary['choice']}

<<IF flag:opened_inquisitive>>
{b_primary['if_react']}
<<ELSEIF flag:called_her_apostate>>
{b_donor['elseif_react']}
<<ELSE>>
{else_react}
<<END>>
"""
    # fix opening (strip header line, since we add our own header above)
    opening_lines = b_primary["opening"].splitlines()
    opening_lines = [l for l in opening_lines if not l.strip().startswith("## SCENE 0")]
    opening_text = "\n".join(l for l in opening_lines if l.strip())
    scene0_final = f"""## SCENE 0: the first networked terminal, cargo section, Stratum One

{opening_text}

{b_primary['choice']}

<<IF flag:opened_inquisitive>>
{b_primary['if_react']}
<<ELSEIF flag:called_her_apostate>>
{b_donor['elseif_react']}
<<ELSE>>
{else_react}
<<END>>"""

    for name, shipped, raw in [
        ("scene0.opening", opening_text, b_primary["opening"]),
        ("scene0.choice", b_primary["choice"], b_primary["choice"]),
        ("scene0.if_react", b_primary["if_react"], b_primary["if_react"]),
        ("scene0.elseif_react (donor: run3 cand2)", b_donor["elseif_react"], b_donor_elseif_raw),
        ("scene0.else_react (donor: run3 cand0)", else_react, else_react_raw),
    ]:
        log["blocks"].append({"block": name, "similarity": round(ratio(shipped, raw), 4)})

    # ---- Scene 1 (whole-candidate; only the fixed-bookkeeping CHOICE
    # header is normalized to match the shipped convention, "(stance
    # labels mandatory)" -- structural markup, not spoken content) ----
    s1_raw = load("regen_scene1_run1.json", 2)
    s1_text = s1_raw.replace(">> CHOICE:", ">> CHOICE (stance labels mandatory):")
    s1_text = "\n".join(l for l in s1_text.splitlines() if l.strip() != "---").strip()
    log["blocks"].append({"block": "scene1.whole (run1 cand2)", "similarity": round(ratio(s1_text, s1_raw), 4)})

    # ---- Scene 4 (unmodified, whole-candidate; strip trailing --- marker) ----
    s4_raw = load("regen_scene4_run1.json", 2)
    s4_text = "\n".join(l for l in s4_raw.splitlines() if l.strip() != "---").strip()
    log["blocks"].append({"block": "scene4.whole (run1 cand2)", "similarity": round(ratio(s4_text, s4_raw), 4)})

    out = {
        "scene0_final": scene0_final,
        "scene1_final": s1_text,
        "scene4_final": s4_text,
        "similarity_log": log["blocks"],
    }
    out_path = CAND / "regen_final_assembled.json"
    out_path.write_text(json.dumps(out, indent=2))
    print(json.dumps(log, indent=2))
    print(f"\nwrote {out_path}")


if __name__ == "__main__":
    main()
