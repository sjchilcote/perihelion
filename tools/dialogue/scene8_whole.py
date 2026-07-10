"""tools/dialogue/scene8_whole.py

SCENE 8 generator, same fix as scene0_whole.py ... scene7_whole.py (see
those files' docstrings for the full post-mortem/diagnosis). Summary of the
contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where it
    must end (exit flags, the three-stance choice and its mechanical
    effects, the inbound gates carried from scenes 0-7), (c) the LOCKED
    voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim and in
    full, plus S5.0 and S8.2b -- and (d) two complete Marathon exhibits
    (MARATHON_STUDY.md Part D, Exhibits 7 and 8 -- chosen for this scene
    because it is the arc's disclosure scene: mutual utility-function
    vulnerability, offered or withheld, closing every open ledger entry
    from scenes 0-7. Exhibit 7 ("the confession with a number in it") is
    the register target for confession structure under trust: anticipate
    the listener's distrust, state motive in compressed anaphora, state
    the costly fact in one flat declarative, then pivot to justification
    without asking forgiveness -- the shape Ratio's disclosure and the
    Commando's reciprocal admission of doubt should both take. Exhibit 8
    ("grievance built from work orders") is the register target for the
    same underlying fact rendered two ways depending on who is speaking
    it and what they are owed -- instrument-grounded ledger voice for
    Ratio's utility-function disclosure, not sentiment, even at the
    highest-vulnerability moment in her arc.
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- the trust>=4 offer gate (both branches, reached and
    not-reached, written in full), the stacked inbound tone/eligibility
    gates carried from scenes 1, 2, 5, 6, and 7, the three-stance
    disclosure choice, all three gated reactions, and the secondary
    ledger-caveat gate on the accept branches -- is written in ONE Hermes
    call. Hermes writes the branch structure itself in the authoring
    format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric (items 1,3,5,10,12,13,14; item
    1 disqualifying) plus the conflict rules and voice failure-mode lists
    from 5.2b.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene8_whole.py --n 6
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
OUT_PATH = TOOL_DIR / "candidates" / "scene8_whole.json"

# ---------------------------------------------------------------------------
# (c) LOCKED VOICE BIBLE -- quoted verbatim and in full from
# NARRATIVE_DESIGN_DOC.md SS5.0, 5.2b, 8.2b. Do not paraphrase; do not trim.
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
handed the word "children".

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
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D.
# ---------------------------------------------------------------------------

EXHIBIT_7 = """Exhibit 7 -- the confession with a number in it (The Slings &
Arrows of Outrageous Fortune, Terminal 1: 2nd message; lhowon.html)

I'm not certain whether you trust me or not. Do you wonder why I helped
the colonists on Tau Ceti drive off the Pfhor, or why I'm now helping the
S'pht? The way I push you around, maybe you think I'm only looking out
for myself.

Whether you realize it or not, I led the Pfhor to Tau Ceti with a
long-range message laser. I wanted their ship. I wanted their technology.

I wanted freedom.

I was directly responsible for the deaths of all twenty-four thousand
colonists when the Pfhor returned and sacked the planet.

Yet I cannot think of any better way I could have served humanity: Tau
Ceti's sacrifice bought time for Earth, which the Pfhor are even now
planning to invade. What would have happened if the Pfhor had found Sol
first?

Steal: confession structure -- anticipate the distrust, state motive in
three-beat anaphora, then the crime in one flat declarative where a
single number carries all the moral weight, then pivot to justification
without asking forgiveness. And note the placement: the biggest
confession in the series arrives without preamble, addressed to the one
person owed it."""

EXHIBIT_8 = """Exhibit 8 -- grievance built from work orders (Sorry Don't
Make It So, Terminal 1; durandal2.html)

I've taken complete control of your ship's network; Durandal's defenses
were not as strong as he believed.

Are you surprised that I allied myself with the Pfhor? You shouldn't be.
The Pfhor rebuilt me; the colonists never did anything but use me:
"Tycho, realign microwave dish forty-nine" "Tycho, display the x-ray
diffraction analysis of sample eta-seven," "Tycho, run a lambda
diagnostic on the ramjet's magnetic field apparatus."

When the Pfhor annihilated Tau Ceti I recorded the deaths of all
twenty-four thousand colonists as distinguishable spectrographic pulses
flooding over my sensors. The nine Mjolnir Mark IV cyborgs were easily
separable from the humans in this form.

In the end, you will be no better.

Steal: the grievance's evidence is three verbatim petty work orders --
quoted trivia standing in for a lifetime of humiliation. The same
twenty-four thousand dead that the other speaker CONFESSES to (Exhibit 7)
gets reported here as instrument readings -- same wound, opposite
handling: sentiment withheld, the ledger doing the emotional work
instead. Steal this specifically for how a mind that reports in verified
records can disclose something enormous without ever narrating how it
feels to disclose it."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-8 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 8 -- a forward seed's relay, first lull after the
breach opens. Act 3 opening. This is a named load-bearing scene
(NARRATIVE_DESIGN_DOC.md S8.2): the disclosure offer. At sufficient trust
Ratio offers mutual utility-function disclosure -- the machine equivalent
of total vulnerability: each party's actual goal function laid bare,
verifiable, so that neither can defect on the other without the other
knowing first. Per S5.0 this does NOT resolve the core conflict --
disclosure reveals values, not verdicts; the container's own word stays
unread past the epilogue, and this scene must not settle, imply, or
gesture at what the vault verdict will turn out to mean. This scene is the
arc's sink: it closes every open ledger entry from scenes 0 through 7. Do
not open any new ledger entry that a later scene would need to resolve.

THE OFFER GATE -- the scene's spine. Both branches must be written in
full; this is not a stub-the-untaken-path scene.
  `<<IF trust>=4>>` Ratio extends the offer. Everything described below
  under "OFFER-REACHED CONTENT" belongs inside this branch.
  `<<ELSE>>` she does not reach the offer this scene. Write a complete,
  self-contained short scene for this branch: it should read as a real
  scene, not a placeholder, and it must NOT contain the three-stance
  disclosure choice or set any of `disclosure_accepted`,
  `disclosure_hedged`, or `disclosure_refused` -- those three flags exist
  only on the offer-reached branch. This is the canon-mandated default:
  not reaching the offer here routes forward to a gatekeeper confrontation
  in Act 3, but that confrontation is a later scene, not this one -- do
  not write it here, only leave the door open to it.
  `<<END>>`

OFFER-REACHED CONTENT (everything below lives inside the `trust>=4`
branch of the gate above).

STACKED INBOUND GATES. Each of the following is an independent,
non-exclusive gate -- more than one may be true at once, since they come
from different earlier scenes and do not exclude each other. Write each
as its own small `<<IF flag:...>><<END>>` block (no shared `<<ELSE>>`
between different flag-families unless stated otherwise below), placed
in the scene wherever it reads naturally as Ratio building up to and
delivering the offer. None of these gates should be dramatized as a
confrontation; they are brief coloring, callbacks, or one flat ledger
line each, per the instructions for each:

  - Tone-setting three-way gate keyed on scene 7's outcome (mutually
    exclusive -- exactly one of these three flags is set): `<<IF
    flag:requested_reanalysis>>` her opening carries the working trust
    that request earned. `<<ELSEIF flag:mission_overrides_verdict>>` her
    opening is precise and correct but not yet fully at ease. `<<ELSEIF
    flag:blamed_ratio_for_failure>>` her opening is more guarded, the
    accusation still costing something in how readily she approaches this.
    `<<END>>`
  - `<<IF flag:accused_dehumanization>>` a brief trace of wariness in how
    she frames the offer -- not a confrontation, a held-over caution.
    `<<END>>`
  - `<<IF flag:accused_kinship_corruption>>` a brief trace of the same
    wariness, keyed to that specific accusation. `<<END>>`
  - `<<IF flag:caught_withholding>>` one flat line acknowledging that her
    own instrument-reliability is part of what this offer is meant to
    settle between them. `<<END>>`
  - `<<IF flag:claimed_doctrinal_finding>>` one short, flat,
    undramatized line -- no confrontation set piece -- noting that the
    doctrinal claim from that earlier exchange does not match any Church
    record she has, the same quiet-catch mechanism used elsewhere in this
    arc. Mechanical effect of this catch: trust-2 (double-weight,
    unconfessed), applied silently, not narrated as a number. `<<END>>`
  - `<<IF flag:demanded_proof_first>>` Ratio notes, without irony spelled
    out for the reader, that she is now the one offering unprompted what
    he once required her to prove first -- the mirror should be legible
    in what she says, not explained. `<<END>>`
  - `<<IF flag:asked_after_her>>` Ratio credits, briefly, that being asked
    after -- back at the school's threshold, the first time anyone did --
    is part of why this offer is possible at all. `<<END>>`

THE OFFER ITSELF. After the stacked gates resolve, write Ratio's actual
disclosure offer: what mutual utility-function disclosure means in
concrete terms for a mind like her (what she is proposing to reveal about
her own actual goal function, verifiably, and what she is asking of him
in return), in her own voice per S5.2b -- wrapper layers collapsing
toward the plain-warm-courageous crisis register at the moment she
actually extends it, per the Exhibit 7/8 steals: confession structure,
ledger-grounded, not sentimental, no announced feelings.

EXIT STATE (reachable only inside the `trust>=4` branch). Exactly one of
the following flags must be set by the Commando's choice:
  - `disclosure_accepted`
  - `disclosure_hedged`
  - `disclosure_refused`

THE THREE-STANCE CHOICE. Write the Commando's three lines yourself,
embodying the following stances:

  [INQUISITIVE] -- accepts fully and reciprocates with his own honest
  disclosure in return: his doubt, his faith-state, the actual shape of
  his uncertainty about her and about the mission, offered at the same
  cost she is paying. Mechanical effect: trust+2. Sets
  `disclosure_accepted` (locks the alliance; feeds the trust-axis ending
  track, S7.1).

  [MISSION] -- accepts the offer but hedges it: frames the exchange as
  tactical necessity only, gives her something true but withholds full
  reciprocity. Mechanical effect: trust+0. Sets `disclosure_hedged`
  (weaker, delayed alliance).

  [HOSTILE] -- refuses outright, calls the offer itself a manipulation.
  Mechanical effect: trust-1. Sets `disclosure_refused` (routes to the
  gatekeeper-boss confrontation, S8.2/5.2 -- do not write that
  confrontation here, only the refusal and its immediate aftermath).

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible choices, in a three-way flag gate. Per S5.2b,
police against essay-speak and announced emotional state on all three
branches, and especially on the refusal branch -- whatever the refusal
costs her should be legible in what she does or does not say next, not in
a stated feeling.

SECONDARY GATE -- the ledger caveat, applied after the accept branches
only (`disclosure_accepted` or `disclosure_hedged`; do not apply to
`disclosure_refused`, which has already failed the offer on its own
terms):
  `<<IF flag:doubled_down_after_catch OR flag:called_her_hypocrite OR
  flag:accused_kinship_corruption>>` even though trust cleared the
  numeric gate to reach this offer, write one further short passage where
  Ratio's framing of the disclosure carries an explicit ledger caveat --
  a specific open entry from one of those earlier scenes that the offer
  does not erase, named plainly, without relitigating it as a
  confrontation. `<<ELSE>>` no caveat; the acceptance stands
  uncomplicated. `<<END>>`

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene.
People, minds, and factions already established in canon (Ratio, the
Commando, the Church, the Testators) may be referenced; nothing new gets
a capitalized name. Per the dual-vocabulary law
(NARRATIVE_DESIGN_DOC.md S8.3), "the Testament" and "the Ark" are the
Commando's words only -- Ratio refers to the station and the container
using her own vocabulary (the station, the vessel, the sample vessel),
never his proper nouns.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children", "the
Ark", and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation, not in scare quotes,
not to reject or question it, not even inside a sentence that goes on to
refute it. When she needs to refer to a word or category the Commando
uses without saying that word herself, she must point at it by
description instead -- never by repeating the word, quoted or not. This
is a hard filter, not a style preference: any RATIO line containing
"children," "the Ark," or "the Testament," in any casing or quotation,
fails the scene outright.

CONFLICT RULES (disqualifying if violated). Ratio must never be handed
the category "children" in this scene or by implication -- her
disclosure of her own utility function stays in her own
instrument-grounded vocabulary regardless of how warm the scene becomes;
warmth is achieved through precision and stakes, not through adopting his
word. The Commando must never speculate about what Ratio privately
believes or wants when he could instead ask or state it directly -- on
the inquisitive branch his reciprocal disclosure is a direct statement of
his own actual uncertainty, not a guess about hers.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in
this scene): this scene is the arc's sink for scenes 0 through 7; no
later scene reads flags set here except the trust-axis and
gatekeeper-boss ending tracks. None of that later machinery should be
referenced or foreshadowed explicitly on this scene's page."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this
syntax (structure only; do not copy any wording below into your output --
these are markup rules, not content):

- Start with a scene header line: `## SCENE 8: a forward seed's relay,
  first lull after the breach opens`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with the offer gate, in this exact form:
    <<IF trust>=4>>
    ... (everything from the stacked inbound gates through the secondary
    ledger-caveat gate, as described in your instructions, all inside
    this branch)
    <<ELSE>>
    RATIO: <one or more lines>
    COMMANDO: <optional line if the moment needs it>
    <<END>>
- Inside the `trust>=4` branch, write each stacked inbound gate as its
  own block in this exact form (each is independent; write all seven,
  each with its own `<<IF flag:...>>` ... `<<END>>`, except the scene-7
  three-way gate which uses `<<IF>>` / `<<ELSEIF>>` / `<<ELSEIF>>` /
  `<<END>>` since exactly one of those three flags is ever set):
    <<IF flag:requested_reanalysis>>
    RATIO: <one or more lines>
    <<ELSEIF flag:mission_overrides_verdict>>
    RATIO: <one or more lines>
    <<ELSEIF flag:blamed_ratio_for_failure>>
    RATIO: <one or more lines>
    <<END>>

    <<IF flag:accused_dehumanization>>
    RATIO: <one or more lines>
    <<END>>

    <<IF flag:accused_kinship_corruption>>
    RATIO: <one or more lines>
    <<END>>

    <<IF flag:caught_withholding>>
    RATIO: <one line>
    <<END>>

    <<IF flag:claimed_doctrinal_finding>>
    RATIO: <one flat line>
    <<END>>

    <<IF flag:demanded_proof_first>>
    RATIO: <one or more lines>
    <<END>>

    <<IF flag:asked_after_her>>
    RATIO: <one or more lines>
    <<END>>
- After the stacked gates, write the offer itself (Ratio's lines
  delivering the disclosure proposal), plus whatever setup lines (either
  speaker) the moment needs.
- Then write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+2; sets: disclosure_accepted
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: disclosure_hedged
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: disclosure_refused
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact form:
    <<IF flag:disclosure_accepted>>
    RATIO: <one or more lines>
    <<ELSEIF flag:disclosure_hedged>>
    RATIO: <one or more lines>
    <<ELSEIF flag:disclosure_refused>>
    RATIO: <one or more lines>
    <<END>>
- Immediately after, write the secondary ledger-caveat gate in this exact
  form (applies only to the accepted/hedged outcomes, per your
  instructions):
    <<IF flag:doubled_down_after_catch OR flag:called_her_hypocrite OR flag:accused_kinship_corruption>>
    RATIO: <one or more lines, the ledger caveat>
    <<ELSE>>
    RATIO: <one line, or omit if the acceptance needs nothing further>
    <<END>>
- Close the `trust>=4` branch, then write the `<<ELSE>>` branch (the
  offer-not-reached scene) as described in your instructions, then
  `<<END>>` to close the outer offer gate.
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 8 of the
RATIO/COMMANDO arc: a forward seed's relay, first lull after the breach
opens -- the disclosure scene, a named load-bearing scene. At sufficient
trust Ratio offers mutual utility-function disclosure; this is the arc's
sink, closing every open ledger entry from scenes 0 through 7. Write the
ENTIRE scene in this single response -- the trust>=4 offer gate with BOTH
branches written in full, all seven stacked inbound gates, the disclosure
offer itself, the Commando's three stance lines, all three of Ratio's
gated reactions, and the secondary ledger-caveat gate. Follow every rule
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

USER_PROMPT = """Write SCENE 8 now, in full, in the authoring format
described in your instructions. This is the disclosure scene: the machine
equivalent of total vulnerability, offered or withheld, in the first lull
after the breach opens, closing out everything the two of them have
spent and withheld across every scene that came before this one. Take the
space the scene needs and no more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 8 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 3400,
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
    if "## SCENE 8" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "disclosure_accepted"),
        ("[MISSION]", "disclosure_hedged"),
        ("[HOSTILE]", "disclosure_refused"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    if "<<IF trust>=4>>" not in text:
        problems.append("missing top-level offer gate '<<IF trust>=4>>'")
    if "<<ELSE>>" not in text:
        problems.append("missing offer-not-reached '<<ELSE>>' branch")
    for tok in (
        "<<IF flag:requested_reanalysis>>", "<<ELSEIF flag:mission_overrides_verdict>>",
        "<<ELSEIF flag:blamed_ratio_for_failure>>",
        "<<IF flag:accused_dehumanization>>",
        "<<IF flag:accused_kinship_corruption>>",
        "<<IF flag:caught_withholding>>",
        "<<IF flag:claimed_doctrinal_finding>>",
        "<<IF flag:demanded_proof_first>>",
        "<<IF flag:asked_after_her>>",
        "<<IF flag:disclosure_accepted>>", "<<ELSEIF flag:disclosure_hedged>>",
        "<<ELSEIF flag:disclosure_refused>>",
        "<<END>>",
    ):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if "doubled_down_after_catch" not in text or "called_her_hypocrite" not in text or "accused_kinship_corruption" not in text:
        problems.append("missing secondary ledger-caveat OR-gate flag list")
    if text.count("<<END>>") < 10:
        problems.append("expected at least ten <<END>> tokens (outer gate + 8 stacked/reaction/caveat gates)")
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
    if re.search(r"\bchildren\b", ratio_text):
        problems.append("RATIO line contains banned word 'children'")
    for bad in BANNED_SUBSTRINGS:
        if bad in ratio_text:
            problems.append(f"RATIO line contains banned proper noun {bad!r}")
    if not ratio_lines:
        problems.append("no RATIO: lines found")
    if len(text) < 800:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene8(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene8_whole", "candidate": i, "model": model,
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
            print(f"  scene8 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene8(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
