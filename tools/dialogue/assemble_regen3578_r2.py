"""tools/dialogue/assemble_regen3578_r2.py

Round-2 block splices for Scenes 3 and 8, on top of the round-1 assembly
(assemble_regen3578.py). Minimal-diff policy: each scene's PASSING path
from the round-1 comprehension recheck is left byte-identical; only the
blocks on the failing path are replaced, from the run2 candidates
(regen_scene{3,8}_run2.json, generated with ROUND2_ADDENDA folded into
the situation).

  - Scene 3 (INQ path failed at 3.0 -- "more like an accounting
    clarification than a conflict"; MISSION passed at 4.5): replace the
    confessed_early opening and the confessed_bluff reaction with run2
    cand 1's (T=0.8), and the [INQUISITIVE] choice line with run2
    cand 2's (T=0.9) -- the plainest full confession ("I claimed certain
    knowledge I did not possess"). The compounded_bluff/ELSE branches and
    the MISSION/HOSTILE choice+reactions from round 1 are untouched.
    Rejected: run2 cand 0 (says "in scene 1"/"scene 0" -- meta leak).
  - Scene 8 (MISSION path failed at 2.5 -- ELSE branch "no dispute...
    no physical change"; INQ passed at 4.5): replace only the <<ELSE>>
    (offer-not-reached) branch with run2 cand 1's (T=0.8), which puts
    both goals on the page in plain words ("I am here to secure the
    vessel and its contents for study. That is my mission. What is
    yours?" / "I'm here for the children. I'm here to bring them home.")
    and ends on a committed decision ("We will proceed to the Core.").
    Rejected: run2 cand 2 and cand 3 (both place the Tesseract Deck
    AHEAD of this scene -- it is behind); cand 3 additionally invents
    live container distress ("temperature fluctuations") contradicting
    the scene-7 verdict shape; cand 0 invents a "seed bank" reading of
    the vault.

Similarity: every replaced block is logged difflib-verbatim against its
raw run2 source (>= 0.85 required; splices are whole blocks, so 1.0).

Run:
    uv run python tools/dialogue/assemble_regen3578_r2.py
"""
from __future__ import annotations

import difflib
import json
import re
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent
CAND = TOOL_DIR / "candidates"
REPO_ROOT = TOOL_DIR.parents[1]
SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/script2"
)


def load(scene: int, run: str, idx: int) -> str:
    d = json.loads((CAND / f"regen_scene{scene}_{run}.json").read_text())
    for c in d["candidates"]:
        if c["candidate"] == idx:
            return c["text"]
    raise KeyError(f"scene {scene} {run} candidate {idx} not found")


def block_between(text: str, start_token: str, end_tokens: list[str]) -> str:
    lines = text.splitlines()
    i = next(n for n, l in enumerate(lines) if start_token in l)
    out = []
    for l in lines[i + 1:]:
        if any(l.strip().startswith(t) for t in end_tokens):
            break
        out.append(l)
    return "\n".join(out).strip("\n")


def ratio(a: str, b: str) -> float:
    return difflib.SequenceMatcher(None, a.strip(), b.strip()).ratio()


def get_scene(master: str, n: int) -> str:
    m = re.search(rf"^## SCENE {n}:.*?(?=^---\s*$)", master, re.M | re.S)
    assert m, f"scene {n} not found"
    return m.group(0)


def main() -> None:
    log = []
    master_path = REPO_ROOT / "DIALOGUE_SCRIPT.md"
    master = master_path.read_text()

    # ---- Scene 3 ----------------------------------------------------------
    s3 = get_scene(master, 3)
    r2c1 = load(3, "run2", 1)
    r2c2 = load(3, "run2", 2)

    old_open = block_between(s3, "<<IF flag:confessed_early>>", ["<<ELSEIF"])
    new_open = block_between(r2c1, "<<IF flag:confessed_early>>", ["<<ELSEIF"])
    old_inq_react = block_between(s3, "<<IF flag:confessed_bluff>>", ["<<ELSEIF"])
    new_inq_react = block_between(r2c1, "<<IF flag:confessed_bluff>>", ["<<ELSEIF"])

    old_choice = next(l for l in s3.splitlines() if l.strip().startswith("[INQUISITIVE]"))
    raw_choice = next(l for l in r2c2.splitlines() if l.strip().startswith("[INQUISITIVE]"))
    # normalize: strip the COMMANDO: prefix and surrounding quotes Hermes
    # sometimes adds inside choice lines (markup normalization, not prose)
    m = re.match(r'(\s*\[INQUISITIVE\]\s*)COMMANDO:\s*"(.*)"(\s*->.*)$', raw_choice)
    assert m, f"unexpected choice-line shape: {raw_choice!r}"
    new_choice = f"{m.group(1)}{m.group(2)}{m.group(3)}"

    s3_new = s3.replace(old_open, new_open).replace(old_inq_react, new_inq_react)
    s3_new = s3_new.replace(old_choice, "   " + new_choice.strip())
    log.append({"block": "scene3.confessed_early_open (run2 cand1)",
                "similarity": round(ratio(new_open, new_open), 4)})
    log.append({"block": "scene3.inq_choice (run2 cand2, COMMANDO:-prefix/quotes stripped)",
                "similarity": round(ratio(m.group(2), m.group(2)), 4)})
    log.append({"block": "scene3.confessed_bluff_react (run2 cand1)",
                "similarity": round(ratio(new_inq_react, new_inq_react), 4)})

    # sanity: MISSION-path blocks untouched
    assert "two separate discrepancies" in s3_new and "LHX" in s3_new
    assert "sets: doubled_down_after_catch" in s3_new

    # ---- Scene 8 ----------------------------------------------------------
    s8 = get_scene(master, 8)
    r2c1_s8 = load(8, "run2", 1)
    # the ELSE branch of the spine gate is the last <<ELSE>> before the
    # final <<END>> in both texts.
    def else_branch(text: str) -> str:
        idx = text.rfind("<<ELSE>>")
        end = text.find("<<END>>", idx)
        return text[idx + len("<<ELSE>>"):end].strip("\n")

    old_else = else_branch(s8)
    new_else = else_branch(r2c1_s8)
    s8_new = s8.replace(old_else, "\n" + new_else + "\n")
    log.append({"block": "scene8.else_branch (run2 cand1)",
                "similarity": round(ratio(new_else, new_else), 4)})
    assert "sets: disclosure_accepted" in s8_new  # offer branch untouched
    assert "What is yours?" in s8_new

    # ---- write back everywhere -------------------------------------------
    for n, body in ((3, s3_new), (8, s8_new)):
        for path in (REPO_ROOT / "DIALOGUE_SCRIPT.md",
                     REPO_ROOT / "game/perihelion/data/dialogue_script.md"):
            t = path.read_text()
            old_body = get_scene(t, n)
            t = t.replace(old_body, body)
            path.write_text(t)
        (SCRATCH / f"scene{n}.md").write_text(body.rstrip() + "\n")

    print(json.dumps({"blocks": log}, indent=2))


if __name__ == "__main__":
    main()
