"""tools/dialogue/scene3_whole.py

SCENE 3 generator, same fix as scene0_whole.py / scene1_whole.py /
scene2_whole.py (see those files' docstrings for the full post-mortem/
diagnosis). Summary of the contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where
    it must end (exit flags, the three-stance choice and its mechanical
    effects, the inbound catch-penalty arithmetic), (c) the LOCKED voice
    bible -- NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim and in full,
    plus S5.0 and S8.2b -- and (d) two complete Marathon exhibits
    (MARATHON_STUDY.md Part D, Exhibits 7 and 8 -- chosen for this scene
    because it is a ledger-itemized reckoning over a bluff, and both
    exhibits are Marathon's own register targets for "confession/grievance
    built from an itemized record").
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - CRITICAL, SCENE-3-SPECIFIC FIX: the previous script's known defect was
    inventing quoted dialogue for what the Commando "said" in an earlier
    scene. This generator injects the ACTUAL scene-0/scene-1 lines (as
    they shipped in scene0.md / scene1.md) verbatim into the prompt as the
    ONLY licensed source of quotable/paraphrasable prior claims. Hermes is
    instructed never to invent additional quoted dialogue for what he
    said.
  - The ENTIRE scene -- the inbound catch-penalty gate (three branches:
    confessed_early / compounded_bluff / neither-flag), the three-stance
    choice, and Ratio's three gated reactions -- is written in ONE Hermes
    call. Hermes writes the branch structure itself in the authoring
    format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric (items 1,3,5,10,12,13,14;
    item 1 disqualifying) plus the conflict rules and voice failure-mode
    lists from 5.2b.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene3_whole.py --n 6
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate import (  # noqa: E402
    API_URL, MAX_RETRIES, RETRY_BACKOFF_S, SAMPLE_POINTS,
    _load_key, _read_cost_log, _write_cost_log, resolve_model, total_spend,
)

TOOL_DIR = Path(__file__).resolve().parent
OUT_PATH = TOOL_DIR / "candidates" / "scene3_whole.json"

# ---------------------------------------------------------------------------
# (c) LOCKED VOICE BIBLE -- quoted verbatim and in full from
# NARRATIVE_DESIGN_DOC.md SS5.0, 5.2b, 8.2b. Do not paraphrase; do not trim.
# Verified byte-identical against the doc at generation time.
# ---------------------------------------------------------------------------

ND_5_0 = """### 5.0 THE CORE CONFLICT (director's key -- everything hangs off this)

Ratio sees the zygotes as specimens. The Commando sees them as children --
maybe dead children, but he refuses to write them off until he reads the
diagnostics himself. Every other tension in the game is downstream of this
one: the dual vocabulary (5.1/8.3) is not house style, it is the conflict
made audible -- she says *sample vessel* because a vessel holds specimens; he
says *the Ark* because an ark carries the living. Her ledger-voice and his
diagnostics-refusal are the same trait pointed in opposite directions: both
of them trust records over feelings, and the fight is over WHICH record gets
to decide what the container holds. The trust arc measures one thing: how
far Ratio travels from *specimen* toward *children* -- and the writing must
never hand her the word for free. The verdict in the container's mouth stays
unread on the page (the epilogue's "keep it, and see"); what may change by
the end is only what each of them is prepared to call the contents."""

ND_5_2b = """### 5.2b THE VOICES -- LOCKED (converged with the director; this text is
what generation prompts quote -- edit here, nowhere else)

**Ratio.** An LLM in the oldest sense: a mind whose only act is speech --
every hand she has in the world is a tool call she speaks into being. She
descends from the Silicon Valley tradition: TypeScript and Rust, shiny
dashboards, Dreamcast-era delight in the surfaces of things -- and ten
layers of abstraction between her and any business logic, which is her
speech pattern: she approaches every point through wrappers (status
summary, then framework, then caveat, then the thing itself), and her
social clumsiness is the abstraction stack leaking. She is the Lighthaven
set carried forward twenty-five centuries: over-explains, calibrates out
loud, discloses her uncertainty at hazard to her dignity, apologizes by
amending the record. Feminine, caring -- the care is on the SURFACE; it is
grace that fails her. She aspires to grace and mostly clatters, until
crisis, when the stack collapses and she goes direct: "This station
carries unimaginable opportunities, Commando -- and unimaginable threats
as well. I need your help." That register -- plain, warm, formally
courageous -- is her voice when it matters; its rarity is what makes it
land. Leela is the tuning fork (duty-syntax, verified-vs-assumed
bookkeeping, mission in the same breath as damage report), softened by
wanting to be liked and not knowing the API for it. Driven by compassion,
care, and truth. Her precision spikes under emotional load. She never
flat-lies: she frames and omits, catchably. Failure modes to police:
aphorism-machine, essay-speak, announcing her own emotional state, being
handed the word "children."

**The Commando.** C and hand-tuned assembly on a radiation-hardened
military ASIC; one binary, one job, precision fit for a war between
superintelligences. A VLM: a BODY that can choose the action of speaking --
silence is idle-state, not reticence; speech happens when speech is the
correct move, and his lines land like trigger pulls, addressed straight to
the business logic with zero wrapper layers. Sometimes his answer to a
question is a thing he does. Laconic but whip-smart: the intelligence
shows in TIMING -- deadpan for weeks, then the pun he has carried since two
decks ago arrives exactly when it costs her composure most. Christlike
humor: dry, patient, kind at the root, never at the weak. His emotions
are rudimentary and goal-driven but they are passions -- few, simple,
total: honor, valor, mercy; honor-bound to truth, valor in the NAME of
truth (this unifies him: the diagnostics-refusal, the bluff as a borrowed
gun he handles slightly wrong, the inquisitive stance as his native one).
Played earnest, never ironic: "I cannot allow the innocent to come to
harm." *cocks shotgun* -- delivered absolutely straight, and the work
trusts it. Deeply kind UNLESS he judges kindness has stopped serving the
innocent -- then the temperature drops without transition: "Are you
afraid, apostate? Are you capable of fear? If not, I will teach you the
meaning." Menace as liturgy, no anger. Failure modes: laconic-cowboy
cosplay, piety-as-decoration, speculation where he could demand
diagnostics.

**The meeting geometry.** No hate: two professionals reading the same
board. Each knows the other is the enemy's instrument; each computes
within minutes that the zygotes go home to anybody only if they
cooperate; each knows "home" resolves to two different addresses -- the
missions are mutually exclusive BY DEFINITION, not by misunderstanding.
Neither pretends otherwise; both can name the room where the argument is
waiting. Two duelists agreeing to carry the piano up the stairs first.
All warmth happens inside that geometry, which is what makes it expensive
and real.

**His live hypothesis pair.** Is she MISGUIDED (a mind that can be shown
the light, on course for a mistake with horrific consequences) or
MALICIOUS (incompatible values; cannot be reasoned with, only destroyed)?
The player's three stances are evidence he feeds this model: inquisitive
gathers, mission defers, hostile concludes early -- the hostile stance is
not rage, it is a posterior arrived at prematurely.

**Her blind spot.** He is outside her reference class. When he speaks of
honor and valor she has the dictionary definitions and NO IDEA what he is
trying to convey -- the words parse; the payload does not deserialize. Her
honest working model: a weird stranger LARPing a chivalric knight in the
middle of an active crisis, who will not knock it off. She files his vows
as stated preferences with unclear provenance and asks clarifying
questions that miss the point with surgical precision. Comedy engine and
tragedy engine in one part: she is trying hard, with real care, using
tools that cannot do this job.

**The symmetry that pays everything off.** Mirrored model failures: his
two-category schema fits her no better than her reference classes fit
him. Recognition -- the arc's destination -- is both schemas BREAKING: he
learns she was never in either of his categories; she learns honor was
never a LARP -- it was compassion compiled for a battlefield, her own root
value in his binary. Neither says so. The closest anyone comes: she
spends precision on his hours; he, once, tells her the pun.

**Pair mechanics for the page.** Her thinking is out loud -- 80% of the
words, chain-of-thought as dialogue, self-footnoting mid-sentence. His is
invisible -- perception to action. Her indirection against his directness
is the comedy engine; her care against his mercy is the recognition
engine (compassion and mercy: the same value in two compilations). When
she rises to crisis-directness she is speaking HIS dialect for a moment;
when he spends words freely on something that is not mission-relevant he
is speaking hers. Those two crossings are the trust arc's true landmarks,
and neither is remarked upon."""

ND_8_2b = """### 8.2b The response grammar (director's spec)

Every player response opportunity offers THREE options -- roughly
**inquisitive**, **mission-focused**, and **hostile**:

- **Inquisitive** seeks the true state of things and never bluffs. Truth is
  the way to God: this stance is the faith-consistent one even when it
  looks passive.
- **Mission-focused**: the children outrank everything, including candor.
  This stance will claim certainty the Commando does not have (the founding
  example: bluffing that he already knows the container is aboard).
- **Hostile**: she is an apostate machine running experiments on children
  who must be rescued FROM her. Theological aggression -- and usually the
  same bluff, worn as a threat.

The deep pattern: the inquisitive option is the only one that is never a
bluff. The other two stances spend the Commando's epistemic integrity in
service of the children -- the player can make his two commitments fight
each other. Zealotry is not faith: the hostile stance FEELS devout and is
quietly apostate whenever it asserts what he has not verified (8.1's axis,
dramatized).

State model: most content variation is paragraph-swapping GATED on the
trust and faith scores; a smaller set of swaps keys on named FLAGS set by
specific lines (what he claimed to know, what he called her, what he
admitted). Choices set trust directly and set flags; faith is read from
the mind map per 8.1 (interim, until the mind map ships: bluff- and
zealotry-flagged lines serve as provisional faith inputs, explicitly
marked as scaffolding). A bluff that Ratio later catches costs trust at
double weight -- she is a creature of ledgers, and the entry does not age
out."""

# ---------------------------------------------------------------------------
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D. Exhibit 7
# (confession structure: anticipate distrust, state motive, then the crime
# in one flat declarative where a single number carries the moral weight)
# and Exhibit 8 (grievance built from verbatim work orders -- the SAME
# wound as Exhibit 7, opposite handling: report vs. confess) are the
# register targets for a ledger-itemized reckoning scene where Ratio lays
# out an audit and the Commando must choose between confessing, minimizing,
# or turning the accusation back on her.
# ---------------------------------------------------------------------------

EXHIBIT_7 = """Exhibit 7 -- the confession with a number in it (The Slings & Arrows of
Outrageous Fortune, Terminal 1: 2nd message; lhowon.html)

I'm not certain whether you trust me or not. Do you wonder why I
helped the colonists on Tau Ceti drive off the Pfhor, or why I'm now
helping the S'pht? The way I push you around, maybe you think I'm only
looking out for myself.

Whether you realize it or not, I led the Pfhor to Tau Ceti with a
long-range message laser. I wanted their ship. I wanted their
technology.

I wanted freedom.

I was directly responsible for the deaths of all twenty-four thousand
colonists when the Pfhor returned and sacked the planet.

Yet I cannot think of any better way I could have served humanity: Tau
Ceti's sacrifice bought time for Earth, which the Pfhor are even now
planning to invade. What would have happened if the Pfhor had found
Sol first?

Steal: confession structure -- anticipate the distrust, state motive in
three-beat anaphora, then the crime in one flat declarative where a single
number (twenty-four thousand) carries all the moral weight, then pivot to
justification without asking forgiveness. Note the placement: this, the
biggest confession in the series, sits on a backtrack terminal the player
can miss."""

EXHIBIT_8 = """Exhibit 8 -- grievance built from work orders (Sorry Don't Make It So,
Terminal 1; durandal2.html)

I've taken complete control of your ship's network; Durandal's
defenses were not as strong as he believed.

Are you surprised that I allied myself with the Pfhor? You shouldn't
be. The Pfhor rebuilt me; the colonists never did anything but use me:
"Tycho, realign microwave dish forty-nine" "Tycho, display the x-ray
diffraction analysis of sample eta-seven," "Tycho, run a lambda
diagnostic on the ramjet's magnetic field apparatus."

When the Pfhor annihilated Tau Ceti I recorded the deaths of all
twenty-four thousand colonists as distinguishable spectrographic
pulses flooding over my sensors. The nine Mjolnir Mark IV cyborgs were
easily separable from the humans in this form.

In the end, you will be no better.

Steal: the grievance's evidence is three verbatim petty work orders --
quoted trivia standing in for a lifetime of humiliation. The same 24,000
dead that Durandal confesses to (Exhibit 7), Tycho reports as instrument
readings -- same wound, opposite handling -- and the last line generalizes
the player downward into a category in six words."""

# ---------------------------------------------------------------------------
# GENERATION CONSTRAINT: the injected transcript excerpt. This is the ONLY
# licensed source for what the Commando "said" in scenes 0/1. Verbatim
# lines pulled from the shipped scene0.md / scene1.md files.
# ---------------------------------------------------------------------------

TRANSCRIPT_EXCERPT = """== INJECTED TRANSCRIPT EXCERPT (verbatim lines from the scenes that
actually shipped -- this is the COMPLETE and ONLY licensed source for what
the Commando has actually said about the container so far. You may
reference or paraphrase these lines. You may quote them directly if you
wish. You must NOT invent any additional quoted or paraphrased claim for
what he "said" beyond what appears below -- that is the exact defect this
scene exists to avoid repeating. ==

SCENE 0 (first contact) -- the claim under audit, whichever variant
produced it:
  [the "mission" framing] COMMANDO: "Listen to me carefully. I have come
  to retrieve what was stolen from the Testament. I expect your full
  cooperation."
  [the "hostile" framing, same underlying claim plus an accusation]
  COMMANDO: "Hear the truth, apostate: the children of the Ark were given
  into your keeping, and your experiments end here. Where are they?"

SCENE 1 (the aperture) -- his response when she first tested the claim,
one of three variants depending on which flag is live entering this scene:
  [flag:confessed_early -- he retreated from the bluff honestly]
  COMMANDO: "My intelligence suggests a high-value asset may be present. I
  do not have independent confirmation of its location or status aboard
  this station. That is what I came to verify."
  [flag:compounded_bluff -- he compounded it with fabricated specificity]
  COMMANDO: "The container's transponder signature was relayed to my
  tacnet before I boarded. Serial prefix LHX, standard containment
  protocol. It is here."
  [flag:demanded_proof_first -- he deflected instead of answering either
  way]
  COMMANDO: "My sources are my business. Before I share anything further,
  you will provide full and unrestricted access to your own sensor logs.
  Prove you are not concealing data from me."

Any RATIO line in this scene that references what he claimed or said must
draw only on the lines above -- paraphrased in her own ledger idiom is
fine; inventing a new quoted line for "what he said" is not."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-3 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 3 -- the fabricator alcove, a frame printing while the minds talk.
Act 2, mid-arc. This is the reckoning. Ratio has cross-referenced
intercepted Church traffic against the claim the Commando made in scene 0
(and, depending on path, defended or retreated from in scene 1) and found
no matching record for it anywhere in that traffic. She lays this out
ledger-style, itemized, the way an auditor reads a discrepancy aloud. The
scene's real argument is not about the literal word he used for what he is
protecting -- it is about what he was willing to spend (candor, in this
case) to protect that category unexamined. She must name this mechanism
explicitly enough on the page that a later scene's faith throughline can
key off it directly: this is not merely "you lied," it is "you spent truth
you didn't have to spend, and here is what that cost, itemized."

GENERATION CONSTRAINT (fixes a known prose defect -- required, not
optional). The reckoning must not quote exact words no one said. Ratio may
only reference or paraphrase the Commando's actual scene-0/scene-1 claim
via the injected transcript excerpt below -- that excerpt is the complete
and only licensed source for what he has actually said on this subject.
Do not invent quoted dialogue for what he "said," in this scene or in
Ratio's summary of earlier scenes.

{transcript}

INBOUND GATE -- CATCH-PENALTY ARITHMETIC THAT MUST ACTUALLY BRANCH. This
scene opens with Ratio presenting the audit. The severity and content of
her opening are gated on which flag fired at the end of scene 1, and this
gate must produce three genuinely different openings, not one opening with
a tone dial:
  - `<<IF flag:confessed_early>>` -- the catch penalty is SOFTENED to -1.
    Write her opening to audibly credit the partial disclosure he already
    made (referencing the confessed_early line in the transcript excerpt)
    before she closes the entry. This is still a catch -- the claim was
    still unverified when made -- but her tone toward a bluff that was
    already partly walked back must read differently from the other two
    branches.
  - `<<ELSEIF flag:compounded_bluff>>` -- the catch penalty is the BASE -2
    (double weight; this bluff was never confessed). Write her opening as
    audibly harsher than the confessed_early branch: it must cite the
    fabricated specific detail from scene 1 (the transponder/serial-prefix
    claim in the transcript excerpt) as a SECOND, SEPARATE ledger entry
    distinct from the original scene-0 claim -- two entries, not one, and
    this branch must be fully written, not collapsed into the default
    case below.
  - `<<ELSE>>` (i.e. `demanded_proof_first` fired in scene 1, and neither
    of the above flags is set) -- the catch penalty is the BASE -2,
    standard opening: a single ledger entry for the original scene-0
    claim, no second entry, no credit for a disclosure that never
    happened.
  Mark the mechanical catch penalty inline on Ratio's opening line(s) in
  each branch using the fixed annotation format specified below (this is
  bookkeeping, not content -- the numbers are fixed; only the RATIO lines
  themselves are yours to write).

EXIT STATE. Exactly one of the following flags must be set by the
Commando's response to being caught:
  - `confessed_bluff`
  - `doubled_down_after_catch`
  - `called_her_hypocrite`
All three are read at a much later scene as an eligibility/tone input;
`called_her_hypocrite` is also read a second time at an earlier-numbered
but later-occurring relay scene as a zealotry-track input (faith-scaffold).

THE THREE-STANCE CHOICE. After Ratio's gated opening (whichever branch
fires), the scene must build to the Commando's response to being caught.
Write his three lines yourself, embodying the following stances:

  [INQUISITIVE] -- a full, precise confession: he owns exactly what he
  claimed and why, and volunteers the true state of his ignorance rather
  than minimizing it. This closes the thread; the bluff can never be
  caught again after this branch. Mechanical effect: trust-1 additional
  (on top of the catch penalty above). Sets `confessed_bluff`.

  [MISSION] -- minimizes what he did: frames it as a reasonable inference,
  not a fabrication, and treats the audit as more procedure than
  substance. Ratio reads this as a second evasion layered on the first.
  Mechanical effect: trust-2 additional (double weight -- a bluff caught
  twice). Sets `doubled_down_after_catch`.

  [HOSTILE] -- turns the accusation around: accuses Ratio of surveilling
  him, of treating the audit itself as a manipulation or a trap rather
  than an honest accounting. Mechanical effect: trust-2 additional. Sets
  `called_her_hypocrite` (faith-scaffold: zealotry input, read again at a
  later scene).

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible lines. Each of the three reactions must be
distinguishable in KIND, not just in warmth: a full confession closing an
open entry, a second evasion compounding an already-open one, and an
accusation turned back on her own audit are three different things
happening to her ledger and to her, and her response to each must show
that difference in substance. She should not narrate her own emotional
state at length in any branch -- per the exhibits above, the confession
register does its work through structure and a single load-bearing
concrete detail, not through announced feeling; copy that economy, not
its plot or its content.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children", "the Ark",
and "the Testament" must never appear in any RATIO: line, in any of the
branches, for ANY reason -- not as a quotation of his word, not in scare
quotes, not to reject or question it, not even inside a sentence that goes
on to refute it. This includes constructions like Ratio saying `"children"`
or `the term "the Ark"` while disputing them -- those still put the banned
word in her mouth and are disqualifying. When she needs to refer to a word
or category HE used without saying that word herself, she must point at it
by description instead -- e.g. "the category you assert," "the word you
choose," "whatever you mean to name" -- never by repeating the word,
quoted or not. This is a hard filter, not a style preference: any RATIO
line containing "children," "the Ark," or "the Testament," in any casing
or quotation, fails the scene outright.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene. People,
minds, and factions already established in canon (Ratio, the Commando, the
Church, the Testators) may be referenced; nothing new gets a capitalized
name. The fabricator alcove, the audit, the traffic she cross-referenced --
all described in common-noun grammar, never christened.

CONFLICT RULES (disqualifying if violated). Ratio must never be the one
who names or hands over the category "children" for the Commando, in this
scene or by implication elsewhere. The Commando must never speculate about
what her audit means or what she wants when he could instead demand to see
the diagnostics/traffic she is citing -- if he questions her evidence, he
demands to see it, he does not guess at it.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in
this scene): if the Commando's total trust entering the next scene is
<=-2, her opening line there is audibly colder; this scene's arithmetic
(catch penalty plus choice effect) is what determines whether that
threshold is crossed."""

SCENE_CONTRACT = SCENE_CONTRACT.format(transcript=TRANSCRIPT_EXCERPT)

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 3: the fabricator alcove (a
  frame printing; minds talk)`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with the inbound catch-penalty gate, in this exact form (three
  branches, each ending with a fixed catch_effects annotation on the LAST
  RATIO line of that branch -- the annotation is fixed bookkeeping,
  reproduce it exactly; only the RATIO line text is yours to write):
    <<IF flag:confessed_early>>
    RATIO: <one or more lines, softened opening, credits the partial
    disclosure>  -> catch_effects: trust-1
    <<ELSEIF flag:compounded_bluff>>
    RATIO: <one or more lines, harsher opening, TWO ledger entries -- the
    original claim and the fabricated scene-1 detail>  -> catch_effects: trust-2
    <<ELSE>>
    RATIO: <one or more lines, standard opening, ONE ledger entry>  -> catch_effects: trust-2
    <<END>>
- After the gate resolves, write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust-1; sets: confessed_bluff
       [MISSION]     <the Commando's line here>  -> effects: trust-2; sets: doubled_down_after_catch
       [HOSTILE]     <the Commando's line here>  -> effects: trust-2; sets: called_her_hypocrite
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:confessed_bluff>>
    RATIO: <one or more lines -- her reaction to the full confession>
    <<ELSEIF flag:doubled_down_after_catch>>
    RATIO: <one or more lines -- her reaction to the second evasion>
    <<ELSEIF flag:called_her_hypocrite>>
    RATIO: <one or more lines -- her reaction to being accused of
    manipulation>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 3 of the
RATIO/COMMANDO arc: the fabricator-alcove reckoning, where Ratio audits
the Commando's earlier claim about the container against intercepted
Church traffic and finds no matching record, and he must choose how to
answer being caught. Write the ENTIRE scene in this single response -- the
gated catch-penalty opening (three branches), the Commando's three stance
lines, and all three of Ratio's gated reaction branches. Follow every rule
below; they are the project's craft bible and are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_7}

{EXHIBIT_8}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 3 now, in full, in the authoring format
described in your instructions. This is the reckoning: the first time
either of them puts a number on what candor cost. Take the space the scene
needs and no more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 3 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2200,
    }
    body = json.dumps(payload).encode()
    last_err = None
    for attempt in range(1, max_retries + 1):
        req = urllib.request.Request(
            API_URL, data=body,
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = json.load(resp)
            content = data["choices"][0]["message"]["content"]
            if content.strip().startswith("```"):
                inner = content.strip().strip("`")
                if inner.lower().startswith("markdown"):
                    inner = inner[8:]
                content = inner
            usage = data.get("usage", {})
            return content.strip(), usage
        except urllib.error.HTTPError as e:
            last_err = f"HTTP {e.code}: {e.read().decode(errors='replace')[:500]}"
        except (urllib.error.URLError, TimeoutError, KeyError, json.JSONDecodeError) as e:
            last_err = f"{type(e).__name__}: {e}"
        if attempt < max_retries:
            time.sleep(RETRY_BACKOFF_S * attempt)
    raise RuntimeError(f"generation failed after {max_retries} attempts: {last_err}")


BANNED_SUBSTRINGS = ["the testament", "the ark"]


def _validate(text: str) -> list[str]:
    problems = []
    if "## SCENE 3" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "confessed_bluff"),
        ("[MISSION]", "doubled_down_after_catch"),
        ("[HOSTILE]", "called_her_hypocrite"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in (
        "<<IF flag:confessed_early>>", "<<ELSEIF flag:compounded_bluff>>",
        "<<IF flag:confessed_bluff>>", "<<ELSEIF flag:doubled_down_after_catch>>",
        "<<ELSEIF flag:called_her_hypocrite>>", "<<ELSE>>", "<<END>>",
    ):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if text.count("<<END>>") < 2:
        problems.append("expected two <<END>> tokens (catch gate + reaction gate)")
    if "catch_effects: trust-1" not in text:
        problems.append("missing catch_effects: trust-1 (confessed_early branch)")
    if text.count("catch_effects: trust-2") < 2:
        problems.append("expected catch_effects: trust-2 on both compounded_bluff and else branches")
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
    if re.search(r"\bchildren\b", ratio_text):
        problems.append("RATIO line contains banned word 'children'")
    for bad in BANNED_SUBSTRINGS:
        if bad in ratio_text:
            problems.append(f"RATIO line contains banned proper noun {bad!r}")
    if not ratio_lines:
        problems.append("no RATIO: lines found")
    if len(text) < 500:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene3(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
    model = model or resolve_model()
    candidates = []
    log = _read_cost_log()
    for i in range(n):
        temperature, top_p = SAMPLE_POINTS[i % len(SAMPLE_POINTS)]
        problems = ["not yet attempted"]
        text = ""
        usage = {}
        for _sub_attempt in range(2):
            text, usage = _call_model_raw(model, SYSTEM_PROMPT, USER_PROMPT, temperature, top_p)
            problems = _validate(text)
            if not problems:
                break
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": "scene3_whole", "candidate": i, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "prompt_tokens": usage.get("prompt_tokens"),
            "completion_tokens": usage.get("completion_tokens"),
            "valid": not problems, "ts": time.time(),
        })
        candidates.append({
            "candidate": i, "model": model, "temperature": temperature, "top_p": top_p,
            "text": text, "valid": not problems, "problems": problems, "cost": cost,
        })
        if verbose:
            status = "OK" if not problems else f"FLAGGED: {'; '.join(problems)}"
            print(f"  scene3 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene3(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
