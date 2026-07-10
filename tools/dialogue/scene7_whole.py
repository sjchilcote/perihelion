"""tools/dialogue/scene7_whole.py

SCENE 7 generator, same fix as scene0_whole.py ... scene6_whole.py (see those
files' docstrings for the full post-mortem/diagnosis). Summary of the
contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where it
    must end (exit flags, the three-stance choice and its mechanical
    effects, the inbound gates carried from scenes 4 and 6), (c) the LOCKED
    voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim and in
    full, plus S5.0 and S8.2b -- and (d) two complete Marathon exhibits
    (MARATHON_STUDY.md Part D, Exhibits 2 and 3 -- chosen for this scene
    because it is the argument after the vault verdict: a loyal machine
    delivering bad news about the reliability of her own report. Exhibit 2
    ("the narrator audits herself") is the register target for Ratio
    reporting the container firmware's verdict with hedged calibration
    language ("I believe," "I cannot verify") rather than false certainty in
    either direction; Exhibit 3 (Leela's pre-recorded farewell) is the
    register target for grief delivered in duty register -- the duty
    handover completed, the hope hedged, and the feeling spent in the
    fewest possible words, never narrated at length -- which is the standard
    this scene holds both speakers to when the verdict reads as loss.
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- the trust-demeanor gate, the scene-6 tone-coloring
    gate, the verdict itself, the scene-4 positioned/blindsided aside, the
    three-stance choice, the undramatized doctrine-catch on the mission
    branch, and all three gated reactions -- is written in ONE Hermes call.
    Hermes writes the branch structure itself in the authoring format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric (items 1,3,5,10,12,13,14; item
    1 disqualifying) plus the conflict rules and voice failure-mode lists
    from 5.2b.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene7_whole.py --n 6
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
OUT_PATH = TOOL_DIR / "candidates" / "scene7_whole.json"

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

EXHIBIT_2 = """Exhibit 2 -- the narrator audits herself (Cool Fusion, Terminal 1,
closing screens; counterattack.html)

<bypassing through traffic>

My records and sensors are becoming less reliable, but I believe that
you should find a Zeus Class Fusion Pistol at this location.

Do not rely too much on this information that I have given you. It has
been intercepted in transmission, and I cannot verify its accuracy.

Steal: a loyal narrator flags her own unreliability as a logistics fact
and ships the mission anyway. Calibration IS characterization -- "I
believe," "I cannot verify" -- and menace accrues to the world, not the
speaker."""

EXHIBIT_3 = """Exhibit 3 -- Leela's pre-recorded farewell (Fire! Fire! Fire! Fire!
Fire!, Terminal 2; durandal.html)

<Leela Data Transfer Unsuccessful>
<Leela Program Pragma Ten>
Communication interruption cause: unknown
<Pre-Recorded Error Message Follows>

My original programming didn't prepare me for these kinds of attackers.
All of my functions will fail within a few minutes of this transmission.
I have one final chance to trick the oncoming viruses, but it is unclear
whether this attempt will be successful.

I have given instructions to Durandal as to the best defense of the
Marathon, but he is completely unstable and I fear that he is in the
Jealous stage of Rampancy.

Good Luck...

<End Pre-Recorded Message>

Steal: she wrote her own death notice in advance, in briefing register.
The chrome delivers the gut punch before the prose starts; she hedges her
last hope ("it is unclear whether"), completes the duty handover, and
spends exactly two words on feeling. This is the ceiling for "sane,
loyal" writing -- copy its economy, not its plot."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-7 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 7 -- the vault antechamber console. Act 2 climax /
act break. This is a named load-bearing scene (NARRATIVE_DESIGN_DOC.md
S8.2): the argument after the vault verdict. The container's firmware has
just reported no viable material and no recovery effort warranted --
faithful to its own programming, the same instrument-grounded verdict
either speaker would expect a diagnostic system to deliver. Total silence
follows the report; then, after this scene, the invaders arrive. This scene
fills the gap between the verdict and that assault. Per S5.0 the label
("children") stays unread past this point -- the scene is not about the
word, it is about whether the Commando extends Ratio's self-assessment the
same "check the diagnostics yourself" standard he holds for his own
readings, or takes the verdict at face value because grief is faster than
verification. This scene does NOT resolve whether the verdict itself is
right or wrong -- that question, and any reanalysis, belongs to a later
scene. Nothing in this scene should assert or imply which way the
diagnostic threshold will turn out to be miscalibrated or confirmed.

OPENING GATE -- trust-range demeanor, general posture entering this
scene, not a flag:
  `<<IF trust<=-3>>` she is audibly calcifying: clipped, procedural, the
  ledger-voice with nothing behind it.
  `<<ELSEIF trust>=3>>` she is shaken alongside him, not performing
  composure -- the crisis-directness register (S5.2b) is available to her
  here.
  `<<ELSE>>` baseline: precise, careful, neither hardened nor undone.
  `<<END>>`
This gate colors HOW she opens and delivers the verdict; it is not itself
the verdict content.

INBOUND GATE -- keyed on which flag was set by scene 6's choice
(`asked_about_salvage` or `claimed_no_hesitation`), coloring her tone
entering this scene, distinct from and in addition to the trust-demeanor
gate above:
  `<<IF flag:asked_about_salvage>>` her opening carries a trace of the
  same working trust his question about salvage earned -- still precise,
  not softened into sentiment.
  `<<ELSEIF flag:claimed_no_hesitation>>` her opening is procedural and
  exact, consistent with a working relationship built on verified
  statements rather than reassurance.
  `<<ELSE>>` baseline, no particular coloring from that scene.
  `<<END>>`

THE VERDICT. After both gates resolve, Ratio delivers the container
firmware's report to the Commando in her own words, using her own
instruments: no viable material recovered from the vessel; the firmware
itself recommends no recovery effort. She must be precise about what she
knows first-hand (the firmware's output, as read) versus what she cannot
independently verify (whether the firmware's threshold for "viable" is
itself correctly calibrated) -- hedged, instrument-grounded calibration
language in the register of the Exhibit 2 steal, not false certainty in
either direction. This is the scene's central argument: whether the
Commando accepts that self-assessment at face value or asks that it be
checked before he accepts it as final. Whatever grief either speaker
carries into or out of this moment must be legible through what is said
and done, in the fewest possible words, in the register of the Exhibit 3
steal -- never narrated at length, never announced as a stated feeling
(S5.2b's failure-mode note applies specifically here: police against
Ratio announcing her own emotional state).

EXIT STATE. Exactly one of the following flags must be set by the
Commando's choice:
  - `requested_reanalysis`
  - `mission_overrides_verdict`
  - `blamed_ratio_for_failure`

THE THREE-STANCE CHOICE. After the verdict lands and whatever setup lines
(either speaker) the moment needs, write the Commando's three lines
yourself, embodying the following stances:

  [INQUISITIVE] -- asks Ratio to run the analysis herself before he
  accepts the verdict; refuses despair pending verification -- the same
  standard he holds for his own diagnostics. Mechanical effect: trust+1.
  Sets `requested_reanalysis`.

  [MISSION] -- declares the mission continues regardless of the verdict,
  recovery proceeds no matter the samples' state, because orders --
  framed as settled certainty about what his orders actually mean, which
  he does not have. Mechanical effect: trust+0 (a bluff, unresolved in
  this scene). Sets `mission_overrides_verdict`.

  [HOSTILE] -- blames Ratio, or her kind generally, for the failure: the
  vault was in a machine's keeping and a machine's keeping failed it.
  Mechanical effect: trust-2. Sets `blamed_ratio_for_failure`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible choices.
  - On the inquisitive branch, treat the request to run the analysis
    herself as a real, live operational task she takes up -- not a
    settled policy, not a rejection of it as unnecessary. Do not resolve
    what the reanalysis finds; only that she takes up the task.
  - On the mission branch, she takes the statement of orders at face
    value for the purposes of the encounter (she has no instrument that
    reads his chain of command), but stays precise about what she can and
    cannot verify -- per S5.2b, not a simple concession. Additionally,
    on this branch only, write one further short, flat, undramatized line
    from Ratio noting that his claim about what the mission's orders
    require does not match any Church doctrine she has on record -- a
    quiet catch, no confrontation set piece, applied as its own beat
    after her main reaction, not blended into it. Mechanical effect of
    this catch: trust-2 (double-weight, unconfessed).
  - On the hostile branch, her reaction must not perform hurt or plead
    her own case at length; per S5.2b's failure-mode note, police against
    essay-speak and announced emotional state here specifically. Whatever
    the accusation costs her should be legible in what she does or does
    not say next, not in a stated feeling.

CLOSING GATE -- keyed on which flag was set by scene 4's midpoint
data-sharing choice (`shared_tactical_data`, or any other outcome of that
choice), stated flatly, near the end of the scene, bracing for what comes
next -- the assault that follows this scene:
  `<<IF flag:shared_tactical_data>>` she states, flatly, that she is
  positioned and prepared for what is converging on their location.
  `<<ELSE>>` she states, flatly, that she is not positioned for it -- the
  incomplete or absent tactical picture from that earlier exchange leaves
  her less prepared for what comes next.
  `<<END>>`
This is a brief, flat statement of operational fact, not a scene of its
own -- do not dramatize it or relitigate the earlier exchange.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene. People,
minds, and factions already established in canon (Ratio, the Commando,
the Church, the Testators) may be referenced; nothing new gets a
capitalized name. Per the dual-vocabulary law (NARRATIVE_DESIGN_DOC.md
S8.3), "the Testament" and "the Ark" are the Commando's words only --
Ratio refers to the station and the container using her own vocabulary
(the station, the vessel, the sample vessel), never his proper nouns.

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
the category "children" in this scene or by implication -- whatever she
says about the vessel's contents stays in her own instrument-grounded
vocabulary (specimens, samples, the payload, viable material), and the
scene must not blur that line by letting her use the Commando's word for
them, even in the register of loss. The Commando must never speculate
about what Ratio privately believes or wants regarding the verdict when
he could instead ask her directly -- in the inquisitive branch, he asks
her to run the analysis herself rather than guessing at whether she
already privately doubts the firmware.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in
this scene): this scene's three exit flags are all read at scene 8's
opening and eligibility check. None of that later machinery should be
referenced or foreshadowed explicitly on this scene's page."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 7: the vault antechamber
  console`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with the trust-demeanor gate, in this exact form (only the RATIO
  line text inside each branch is yours to write; the actual trust value
  is resolved at play time, not at generation time -- write content for
  all three branches):
    <<IF trust<=-3>>
    RATIO: <one or more lines, calcified and clipped>
    <<ELSEIF trust>=3>>
    RATIO: <one or more lines, shaken alongside him>
    <<ELSE>>
    RATIO: <one or more lines, baseline>
    <<END>>
- Immediately after, write the scene-6 tone-coloring gate, in this exact
  form (only the RATIO line text inside each branch is yours to write):
    <<IF flag:asked_about_salvage>>
    RATIO: <one or more lines>
    <<ELSEIF flag:claimed_no_hesitation>>
    RATIO: <one or more lines>
    <<ELSE>>
    RATIO: <one or more lines>
    <<END>>
- After both gates resolve, write the verdict delivery (the firmware's
  report, in Ratio's own words, hedged and instrument-grounded) and
  whatever additional setup lines (either speaker) you judge the moment
  needs before the choice.
- Then write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: requested_reanalysis
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: mission_overrides_verdict
       [HOSTILE]     <the Commando's line here>  -> effects: trust-2; sets: blamed_ratio_for_failure
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order (the mission branch
  must include the undramatized doctrine-catch line described in your
  instructions, as its own line after the main reaction):
    <<IF flag:requested_reanalysis>>
    RATIO: <one or more lines>
    <<ELSEIF flag:mission_overrides_verdict>>
    RATIO: <one or more lines, main reaction>
    RATIO: <one further short, flat line -- the undramatized doctrine catch>
    <<ELSEIF flag:blamed_ratio_for_failure>>
    RATIO: <one or more lines>
    <<END>>
- After the reaction gate, write the closing gate keyed on scene 4's
  flag, in this exact form:
    <<IF flag:shared_tactical_data>>
    RATIO: <one or more lines, positioned and prepared>
    <<ELSE>>
    RATIO: <one or more lines, not positioned>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 7 of the
RATIO/COMMANDO arc: the vault antechamber console, the argument after the
vault verdict -- a named load-bearing scene. The container's firmware has
just reported no viable material and no recovery effort warranted; this
scene is the argument over whether the Commando accepts that
self-assessment at face value or holds it to the same verification
standard he holds his own diagnostics to. Write the ENTIRE scene in this
single response -- the trust-demeanor gate, the scene-6 tone-coloring
gate, the verdict delivery, the Commando's three stance lines, all three
of Ratio's gated reactions (including the undramatized doctrine catch on
the mission branch), and the closing scene-4 positioning gate. Follow
every rule below; they are the project's craft bible and are
non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_2}

{EXHIBIT_3}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 7 now, in full, in the authoring format
described in your instructions. This is the argument after the vault
verdict: whether a loyal machine's self-report of failure gets accepted
on faith or held to verification, the same question the whole game asks
in miniature, argued here for the first time with the stakes now
concrete and final-sounding. Take the space the scene needs and no
more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 7 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2600,
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
    if "## SCENE 7" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "requested_reanalysis"),
        ("[MISSION]", "mission_overrides_verdict"),
        ("[HOSTILE]", "blamed_ratio_for_failure"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in (
        "<<IF trust<=-3>>", "<<ELSEIF trust>=3>>",
        "<<IF flag:asked_about_salvage>>", "<<ELSEIF flag:claimed_no_hesitation>>",
        "<<IF flag:requested_reanalysis>>", "<<ELSEIF flag:mission_overrides_verdict>>",
        "<<ELSEIF flag:blamed_ratio_for_failure>>",
        "<<IF flag:shared_tactical_data>>", "<<END>>",
    ):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if text.count("<<END>>") < 4:
        problems.append("expected four <<END>> tokens (demeanor gate + tone gate + reaction gate + closing gate)")
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


def generate_scene7(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene7_whole", "candidate": i, "model": model,
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
            print(f"  scene7 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene7(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
