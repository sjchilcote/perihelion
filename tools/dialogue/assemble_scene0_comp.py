"""tools/dialogue/assemble_scene0_comp.py

Scene 0 splice for the comprehension-gate pass. Scene 0 failed the
tightened gate (INQ 3.0 -- "Cannot tell. There is no clear dispute";
MISSION q5=0 -- "The standoff remains unresolved") after passing the
looser round-1 grading. Two regen rounds were run
(regen_scene0_comp1.json, regen_scene0_comp2.json -- comp-prefixed
because the run2/run3 tags collide with the committed candidate files
from the earlier naturalism pass, which were restored from git).

Selection: comp2 cand 1 (T=0.8), whole.
  - Rejected comp2 cand 0: its [INQUISITIVE] line plays the Commando as
    an amnesiac ("I woke up in that dock. Something printed this body
    and put me in it") -- canon break; he was briefed in transit and
    fought through the dock sweep knowingly.
  - Rejected comp2 cand 3: its [MISSION] and [HOSTILE] choice lines are
    byte-identical.
  - Rejected comp1 cand 1 (only valid comp1 candidate): INQ branch ends
    on an unanswered question and its MISSION line drops the unbacked
    claim entirely.
Canon verified on the winner: "apostate" spoken on the hostile line;
MISSION/HOSTILE commit the unbacked claim ("The Ark is aboard this
station" / "The children in your keeping"); Ratio confirms/denies no
cargo (record-status statements only, same device the prior shipped
scene 0 used); INQ branch contains no container claim.

Mechanical normalization only: ">> CHOICE:" -> the shipped
"(stance labels mandatory)" header.

Run:
    uv run python tools/dialogue/assemble_scene0_comp.py
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


def main() -> None:
    d = json.loads((CAND / "regen_scene0_comp2.json").read_text())
    raw = next(c["text"] for c in d["candidates"] if c["candidate"] == 1)
    text = raw.replace(">> CHOICE:", ">> CHOICE (stance labels mandatory):")
    text = "\n".join(l for l in text.splitlines() if l.strip() != "---").strip()
    sim = difflib.SequenceMatcher(None, text, raw.strip()).ratio()
    assert sim >= 0.85, sim

    for path in (REPO_ROOT / "DIALOGUE_SCRIPT.md",
                 REPO_ROOT / "game/perihelion/data/dialogue_script.md"):
        t = path.read_text()
        m = re.search(r"^## SCENE 0:.*?(?=^---\s*$)", t, re.M | re.S)
        assert m, path
        t = t[:m.start()] + text + "\n\n" + t[m.end():]
        path.write_text(t)
    (SCRATCH / "scene0.md").write_text(text + "\n")
    print(json.dumps({"block": "scene0.whole (comp2 cand1)", "similarity": round(sim, 4)}))


if __name__ == "__main__":
    main()
