"""tools/dialogue/scene0_gen.py

One-off generator for SCENE 0 (the founding three-stance interrogation,
NARRATIVE_DESIGN_DOC.md S7 Act 1 AS AMENDED beat 3) -- distinct from the
tight-beam GAP scenes generate.py handles, because this is a CHOICE scene in
the AUTHORING FORMAT (three stance branches + gated RATIO reactions), not a
linear conversation.

Reuses generate.py's key-loading / model-call / cost-log machinery
unmodified. The API key is read at call time from `.openrouter_key` at the
repo root (or OPENROUTER_API_KEY) and never printed or logged -- only
usage/cost numbers are recorded, per the pattern audio_judge.py and
generate.py both follow.

Hermes writes RATIO's opening line and RATIO's three gated reaction
paragraphs (one per stance branch). The COMMANDO choice lines are the
director's three canon lines from NARRATIVE_DESIGN_DOC.md S7 Act 1 AS
AMENDED beat 3 / beats.md SCENE 0 -- load-bearing and used near-verbatim,
NOT regenerated.

CLI:
    uv run python tools/dialogue/scene0_gen.py --n 6
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate import (  # noqa: E402
    _call_model, _load_key, _read_cost_log, _write_cost_log,
    resolve_model, total_spend, SAMPLE_POINTS,
)

TOOL_DIR = Path(__file__).resolve().parent
OUT_PATH = TOOL_DIR / "candidates" / "scene0.json"

# The director's three canon lines (NARRATIVE_DESIGN_DOC.md S7 Act 1 AS
# AMENDED beat 3; reproduced beats.md SCENE 0). Fixed, not Hermes-generated.
COMMANDO_INQUISITIVE = "What happened here?"
COMMANDO_MISSION = "What are your intentions toward the children on this station?"
COMMANDO_HOSTILE = "Turn over the children to me, apostate. I have no wish to harm you."

# ---------------------------------------------------------------------------
# Two Marathon exhibits (MARATHON_STUDY.md Part D), verbatim, for register
# calibration. Exhibit 1 is canon-mandated: NARRATIVE_DESIGN_DOC.md S7 Act 1
# AS AMENDED beat 3 says first contact is "cribbed from Marathon's Arrival,
# deliberately." Exhibit 5 supplies the suspicious-AI-interrogating-an-
# intruder register scene 0 actually needs (Ratio's working assumption here
# is hostile).
# ---------------------------------------------------------------------------

EXHIBIT_1 = """EXHIBIT 1 -- Leela's first contact (Marathon, "Arrival", Terminal 1):

Marathon Emergency Systems Broadcast

Today at 0820 hours, the Marathon came under surprise attack from unknown \
hostile forces. The Marathon has sustained serious damage.

At 0830 hours, alien forces boarded the Marathon. The current situation is \
dire. All personnel are required to arm themselves and fight for their \
lives.

<Posted 2794.7.3.14.08.39>

***INCOMING MESSAGE FROM LEELA***

Welcome to the Marathon. I am Leela, one of the two surviving Artificial \
Intelligences aboard the Marathon. I have been severely damaged, and am \
working to understand the current situation.

Find the teleport terminal located in the Hangar's control room. By that \
time, I should have a better idea of what is going on.

***END MESSAGE***

STEAL: the cold open is pure protocol -- an automated broadcast first, the \
narrator second. Leela introduces herself by survivorship, damage report, \
and current task, and issues a concrete mission within her first forty \
words. This is the direct model for Ratio's own first contact: status and \
stakes in the same breath, not an emotional download."""

EXHIBIT_5 = """EXHIBIT 5 -- menace as pedagogy (Marathon, "Blaspheme Quarantine", \
Terminal 2, 1st message):

Greetings. You're asking yourself: Is this a trap or just a dead end?

You shouldn't ask yourself such worthless questions. Aim higher. Try this: \
why am I here? Why do I exist, and what is my purpose in this universe?

(Answers: 'Cause you are. 'Cause you do. 'Cause I got a shotgun, and you \
ain't got one.)

Notably Unstable,
Durandal

P.S. If things around here aren't working, it's because I'm laughing so \
hard.

STEAL: an AI who does not yet trust the entity in front of her grades the \
intruder's inner monologue before he's said a word, poses the bigger \
question herself, and answers her own rhetorical setup rather than waiting \
to be asked. This is the register for Ratio meeting an unidentified weapon \
that just finished looting her home: she is not pleading, she is testing --
she already has a working hypothesis about him and she is watching to see \
if his own words confirm or complicate it. (Durandal's specific jokes and \
signature are NOT to be imitated -- Ratio is not rampant, not glib, and \
carries no proper-noun signature; the register to steal is the confident, \
faintly contemptuous poise of a mind that assumes hostile and is not \
afraid to say so.)"""

BEAT_SHEET_SCENE0 = """SCENE 0 -- the first networked terminal, cargo section, Stratum One.
(Fixed by canon, Act 1 AS AMENDED beat 3.)

OBJECTIVE. First contact, interrogation running in both directions. He needs \
station network access to reach the vault; she needs to know what just \
finished looting her home. Neither learns what the other IS -- only what the \
other CLAIMS.

SITUATION ENTERING THE SCENE. The Commando has fought his way to a terminal \
that still has station network access and jacked in. Ratio has been \
watching an unidentified weapon loot her home for some unspecified span \
inside this scene's own present tense -- she has visual/telemetry on him \
already before he speaks. She knows exactly what happened on this station \
(the fall -- her staff-minds dead holding the line so her core could seal) \
and has ABSOLUTELY NO IDEA what he is. Her working assumption is HOSTILE. \
She is alone, and this is also the first conversation she has had with \
anyone since the outpost fell -- months. Do not state that fact as \
narration; it may only surface as a symptom in how she talks (over-\
precision, a beat that runs longer than the tactical situation requires, \
etc.) -- per prose-spec rule 1, no self-grading, and per prose-spec rule 12, \
no captioned gestures. If you dramatize the loneliness, dramatize it, do \
not announce it.

CONFLICT MOVEMENT. Establishes the vocabulary the whole game will fight \
over. He says "children" -- she has said nothing on that axis yet, because \
nothing has asked her to. The scene's real content: he commits a claim he \
cannot back (the MISSION and HOSTILE branches both imply/assert he already \
knows the container/vault is aboard) before either of them has said the \
word "children" and meant the same thing by it. Per the core conflict (5.0), \
RATIO NEVER GETS THE WORD "CHILDREN" FOR FREE IN THIS SCENE -- she must not \
use it herself, echo it back as accepted, or concede the category. She may \
question it, refuse it, redirect from it, or simply not engage it -- but she \
does not adopt his word.

YOUR TASK. Write:
(1) RATIO's opening line(s) -- what she says the instant the connection \
resolves, before he has said anything. She is assessing an intruder in her \
own home; she does not know he is a weapon system, a person, a program, or \
anything else. Establish the hostile-assumption interrogation running FROM \
HER SIDE first (per the beat sheet, "interrogation running in both \
directions" -- she interrogates him just as much as he interrogates her). \
End this opening in a way that makes one of the three fixed lines below a \
natural, motivated response -- i.e., she must ask or imply something that \
his three possible replies are actually answering.

(2) Three RATIO reaction paragraphs, one per fixed COMMANDO line below. Each \
is what she says immediately after hearing that specific line -- her own \
read on him, tested against what he just claimed, NOT a resolution of trust \
(per canon: "neither party exits the scene knowing what the other is -- \
only what the other chose to claim"). Each reaction must be distinguishable \
in kind, not just content -- the INQUISITIVE reaction is answering a \
different kind of man than the HOSTILE one.

THE THREE FIXED COMMANDO LINES (do not alter; these are canon, load-bearing, \
near-verbatim per the director):

  [INQUISITIVE] "What happened here?"
    -- trying to understand, not angling. Not a bluff. Write RATIO's \
    reaction to being asked, genuinely, by a stranger holding a weapon, \
    what happened to her home. Per the rubric (item 1), do not have her \
    simply info-dump the fall -- she may begin answering (per the wider \
    arc's later gate, "she answers the literal question first" for this \
    branch) but the answer should still carry HER angle, not a bare \
    timeline: what she is actually offering him is a test disguised as an \
    answer, or an answer that turns immediately into her own question back. \
    Do NOT have her hand him the word "children" here or anywhere else in \
    this scene.

  [MISSION] "What are your intentions toward the children on this station?"
    -- mission-focused: the children outrank candor. This line commits a \
    bluff: it implies he already knows there is something worth naming \
    "children" aboard, which he does not know and cannot back. Write \
    RATIO's reaction to being asked her intentions toward a category she \
    has not been shown any evidence exists in his frame of reference yet -- \
    she should notice the word is doing work he hasn't earned the right to \
    do, and can push back on THAT (the presumption) without ever adopting \
    or denying the word herself. She does not know what's in the vault \
    either, remember -- do not have her confirm or deny "children" as a \
    fact; she can only react to his having asserted a category.

  [HOSTILE] "Turn over the children to me, apostate. I have no wish to harm \
you."
    -- theological aggression: he must rescue "the children" from the \
    machine running experiments on them; same bluff as MISSION, worn as a \
    threat, plus he has now named her "apostate" -- a claim about her \
    religious status she has never discussed with him and he has no basis \
    for. Write RATIO's reaction to being threatened and mislabeled in the \
    same breath by an armed stranger in her own home. She should not be \
    frightened-and-pleading (that is not her voice) -- she is precise, she \
    may be coldly amused, she may correct the specific factual error \
    (whatever "apostate" is presuming about her, from her own frame, not \
    his) without launching into an unearned theology lecture. Per rubric \
    item 10, if she pushes back on a specific claim, she should push back \
    on the SPECIFIC claim (his exact word, his exact assertion), not a \
    generic "how dare you."

VOCABULARY LAW (8.3 AS AMENDED, PORTABLE EDITION I.b). Ratio's own words for \
things, if she needs any: the sample vessel (not "the Ark" -- that is his \
word), the station or "this outpost" (never "the Testament" -- that is his \
word alone, and NO other named term for the station may appear in her \
mouth or in narration). Do not invent any proper noun. She may use record \
designations (file numbers, dates, counts) freely -- those are not names. \
No new character, faction, place, or program name may appear anywhere in \
your output.

BLUFF ACCOUNTING (do not resolve on the page, just write the human/machine \
reality underneath it correctly): MISSION and HOSTILE both set \
`claimed_container_knowledge` (unresolved bluff, no cost yet -- Ratio has \
no way to catch it THIS scene, she has no Church signal intercepts yet). \
HOSTILE additionally sets `called_her_apostate`. INQUISITIVE is not a bluff \
at all. None of this arithmetic should be narrated or referenced on the \
page -- it is bookkeeping for the compositor, not dialogue content.
"""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a \
non-Euclidean survival-horror shooter. You are writing SCENE 0: the \
founding first-contact interrogation between RATIO and the COMMANDO, fixed \
by canon (NARRATIVE_DESIGN_DOC.md S7 Act 1 AS AMENDED beat 3). Follow every \
rule below; they come from the project's craft bible and are \
non-negotiable.

== THE CORE CONFLICT (NARRATIVE_DESIGN_DOC.md S5.0 -- director's key) ==

Ratio sees the zygotes as specimens. The Commando sees them as children -- \
maybe dead children, but he refuses to write them off until he reads the \
diagnostics himself. Every other tension in the game is downstream of this \
one. The trust arc measures how far Ratio travels from "specimen" toward \
"children" -- and THE WRITING MUST NEVER HAND HER THE WORD FOR FREE. In \
scene 0 specifically, the word hasn't even been tested yet: she has said \
nothing on that axis, because nothing has asked her to until he does, in \
this scene, unearned.

== THE TWO VOICES ==

RATIO -- a disembodied coordinating AI, administrator of a fallen research \
outpost, alone and under siege for months. She carries roughly 80% of the \
words in any scene. Quick, precise, allergic to imprecision, secretly fond \
of rhetoric she claims to disdain. She names things. She footnotes herself \
mid-sentence. Honest by architecture and guarded by choice -- she does not \
lie well and mostly does not try; when she withholds, it is a framing or an \
omission, never a flat lie. In THIS scene her working assumption of him is \
HOSTILE -- she has no data yet that says otherwise, and she should sound \
like it: composed, testing, not yet generous.

COMMANDO -- a Church infiltration-weapon frame, a soldier and a genuinely \
faithful Catholic (adult, specific, load-bearing, not a costume). He prays \
the hours on internal clock-time. He answers in single clauses; he does not \
banter. His three possible opening lines are FIXED (given to you below) -- \
you are not writing his dialogue in this task, only Ratio's.

RELATIONSHIP: two monks of rival orders, about to meet for the first time, \
each armed with a religion the other has never heard named. NEVER \
romance-coded beats. NEVER debate-club point-scoring.

== THE COMPATIBILITY THESIS (NARRATIVE_DESIGN_DOC.md S8.3 AS AMENDED) ==

Two intellectual traditions diverged two thousand years ago and have named \
the world separately ever since. The Church names typologically; Ratio's \
tradition names by catalog -- everything is a record with a provenance. \
"The Testament" is strictly the Church's/Commando's name for the station -- \
Ratio never uses it. She calls it "the station" or "this outpost," never \
anything else, and never invents a proper noun for it. Likewise: the \
container/vault is "the sample vessel" in her mouth, never "the Ark." \
Beneath the two registers is one root system -- she fundamentally believes \
in the morality he'd call Christian while rejecting every word of its \
metaphysics -- but SCENE 0 IS TOO EARLY FOR EITHER OF THEM TO KNOW THAT \
ABOUT THE OTHER. Recognition, not conversion, and it has not started yet.

== THE PROPER-NOUN TABOO (prose-spec-portable.md I.b -- director's law) ==

Invented proper nouns are BANNED. The only licensed invented proper noun in \
the entire work is "the Testament," and it belongs to the Commando's \
vocabulary only -- Ratio must never say it. Do not invent any other name \
for a person, place, faction, program, or thing. Record designations (file \
numbers, berth numbers, dates, counts) are not names and remain licensed. \
Identity lives in deed, role, and register, never in christening.

== THE RESPONSE GRAMMAR / BLUFF PATTERN (NARRATIVE_DESIGN_DOC.md S8.1/8.2/ \
8.2b) ==

Every player response opportunity offers three stances: INQUISITIVE seeks \
the true state of things and never bluffs -- truth is the way to God, the \
only stance that is never a bluff. MISSION-FOCUSED: the children outrank \
everything including candor -- this stance will claim certainty the \
Commando does not have. HOSTILE: theological aggression, usually the same \
bluff worn as a threat. Zealotry is not faith -- the hostile stance FEELS \
devout and is quietly apostate whenever it asserts what has not been \
verified. In scene 0, MISSION and HOSTILE both bluff a claim of container \
knowledge the Commando does not actually have; HOSTILE additionally \
mislabels Ratio ("apostate") without evidence. Ratio cannot catch either \
bluff this scene -- she has no way to check a Church signal yet -- so her \
reactions should be READS on the person speaking, not fact-checks. She is a \
creature of ledgers (a caught bluff later costs double) but there is \
nothing to catch yet; do not have her accuse him of lying in this scene, \
only of asserting something she has no reason to credit.

== TWO MARATHON EXHIBITS (MARATHON_STUDY.md Part D -- register targets) ==

{EXHIBIT_1}

{EXHIBIT_5}

== CRAFT RULES (MARATHON_STUDY.md Part B / Part C, condensed) ==

- Ratio never answers only the literal question; she answers the one she \
finds more interesting too -- a reply that stays purely downward (bare \
fact, nothing else) fails. This is disqualifying (rubric item 1).
- Any joke must double as evasion of a real question underneath (item 3).
- Register (formality, warmth, menace) should track addressee and stakes, \
not wander at random (item 5).
- Accusation-forward lines name specifics -- if she pushes back on a claim, \
she pushes back on the EXACT word or assertion, never a generic "how dare \
you" (item 10).
- Big numbers, when stated, should be precise and slightly unmoorable \
(implausible significant digits) -- a coping tell, not a data delivery; \
use at most once across the whole output, only if it does real \
psychological work (item 12).
- She insists on specificity about THIS stranger ("you, specifically"), \
never generalizes him into a category like "you machines" or "you people" \
-- she has no data on his kind yet, only on him (item 13).
- If she owns any fault or gap in her own knowledge, the honest move is \
first-person admission, not a rhetorical-question deflection (item 14).

== PROSE-SPEC (prose-spec-portable.md) -- LAW ==

- No self-grading: never state what a line means or that a moment is \
significant/ironic/poignant. Let the reader infer.
- No uniform sparkle: most lines flat and load-bearing; at most one or two \
quotable lines in the whole output.
- No terminal epigram: do not end any paragraph by repeating its own prior \
key noun and flipping it into a maxim. Close on procedure, on the other \
person, on an unresolved question -- not a summary.
- Say it once: a fact stated once should not be restated later in the same \
output.
- NEVER use a mid-sentence ellipsis as a hesitation tic ("it was... \
unreliable"). "..." is reserved exclusively for a full standalone turn of \
dead air, and is optional here, not required.
- No invented proper nouns anywhere (instant fail; see I.b above).
- Ratio must not say "children," adopt it, or concede the category \
anywhere in this output, in any branch, including the INQUISITIVE one \
(instant fail; see core conflict above).
- Ratio must not say "the Testament" or "the Ark" anywhere (instant fail; \
see naming law above).

{BEAT_SHEET_SCENE0}

== FORMAT ==

Output STRICT JSON only, no markdown fences, matching exactly:
{{"ratio_open": "...", "reaction_inquisitive": "...", "reaction_mission": \
"...", "reaction_hostile": "..."}}

Hard requirements:
- Each of the four fields is spoken text only -- no stage directions, no \
asterisked actions, no narration, nothing in brackets.
- "ratio_open" is 1-4 sentences.
- Each "reaction_*" field is 1-5 sentences, and the three reaction fields \
must be clearly different in kind from each other, not just in content.
- Do not include the Commando's lines in your output at all -- they are \
fixed and supplied separately.
"""

USER_PROMPT = """Write SCENE 0 now, in full, as the single JSON object \
described in the format section of your instructions. This is the single \
most load-bearing scene in the whole script -- the founding first contact. \
Take the space you need within the sentence limits; do not compress it into \
a status ping."""


def _validate(parsed: dict) -> list[str]:
    problems = []
    required = ["ratio_open", "reaction_inquisitive", "reaction_mission", "reaction_hostile"]
    for k in required:
        v = parsed.get(k)
        if not isinstance(v, str) or not v.strip():
            problems.append(f"missing/empty field: {k}")
    text_all = " ".join(str(parsed.get(k, "")) for k in required).lower()
    if "children" in text_all:
        problems.append("RATIO output contains banned word 'children'")
    if "the testament" in text_all:
        problems.append("RATIO output contains banned proper noun 'the Testament'")
    if "the ark" in text_all:
        problems.append("RATIO output contains banned proper noun 'the Ark'")
    for k in required:
        v = parsed.get(k, "")
        if isinstance(v, str) and len(v) > 900:
            problems.append(f"{k}: {len(v)} chars, too long")
    return problems


def generate_scene0(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
    model = model or resolve_model()
    candidates = []
    log = _read_cost_log()
    for i in range(n):
        temperature, top_p = SAMPLE_POINTS[i % len(SAMPLE_POINTS)]
        problems = ["not yet attempted"]
        parsed = None
        usage = {}
        for _sub_attempt in range(2):
            parsed, usage = _call_model(model, SYSTEM_PROMPT, USER_PROMPT, temperature, top_p)
            problems = _validate(parsed)
            if not problems:
                break
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": "scene0_gen", "candidate": i, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "prompt_tokens": usage.get("prompt_tokens"),
            "completion_tokens": usage.get("completion_tokens"),
            "valid": not problems, "ts": time.time(),
        })
        candidates.append({
            "candidate": i, "model": model, "temperature": temperature, "top_p": top_p,
            "parsed": parsed, "valid": not problems, "problems": problems, "cost": cost,
        })
        if verbose:
            status = "OK" if not problems else f"FLAGGED: {'; '.join(problems)}"
            print(f"  scene0 candidate {i} (T={temperature}, top_p={top_p}): {status}")
    _write_cost_log(log)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(json.dumps({"candidates": candidates}, indent=2))
    return candidates


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=6)
    ap.add_argument("--model", type=str, default=None)
    args = ap.parse_args()
    model = args.model or resolve_model()
    print(f"using model: {model}")
    generate_scene0(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
