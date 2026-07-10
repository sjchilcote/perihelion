"""tools/dialogue/scene0_whole.py

SCENE 0 generator, rebuilt per the director's post-mortem on the first
attempt. The diagnosis: beat sheets containing Claude-authored example
lines that Hermes parroted, beats that micro-specified every line's
function, and scenes assembled from separate chunked generations.

THE FIX, exactly, as implemented here:
  - The Hermes prompt contains ONLY (a) where the scene starts (situation,
    what each party knows/wants/hides), (b) where it must end (exit flags,
    the three-stance choice and its mechanical effects, roughly where trust
    can move), (c) the LOCKED voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b
    quoted verbatim and in full, plus S5.0 and S8.2b -- and (d) two complete
    Marathon exhibits (MARATHON_STUDY.md Part D, Exhibits 1 and 5).
  - ZERO example lines anywhere: no "in the register of", no sample
    dialogue, no turn counts, no per-beat function assignments, no
    who-opens/who-closes. The three fixed canon lines from S7 Act 1 beat 3
    are NOT quoted to the model -- Hermes writes the Commando's three
    stance lines itself, from the stance descriptions only.
  - The ENTIRE scene -- opening, all three stance lines, all three gated
    RATIO reaction branches -- is written in ONE Hermes call. No chunking.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step (not done by this script) against the ALIVE rubric.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) and is never printed or logged -- only usage/cost
numbers are recorded, per the pattern in generate.py / audio_judge.py.

CLI:
    uv run python tools/dialogue/scene0_whole.py --n 6
"""
from __future__ import annotations

import argparse
import json
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
OUT_PATH = TOOL_DIR / "candidates" / "scene0_whole.json"

# ---------------------------------------------------------------------------
# (c) LOCKED VOICE BIBLE -- quoted verbatim and in full from
# NARRATIVE_DESIGN_DOC.md. Do not paraphrase; do not trim.
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
# Exhibit 1 is canon-mandated (NARRATIVE_DESIGN_DOC.md S7 Act 1 beat 3: first
# contact is "cribbed from Marathon's Arrival, deliberately"). Exhibit 5
# supplies the suspicious-mind-interrogating-an-intruder register.
# ---------------------------------------------------------------------------

EXHIBIT_1 = """Exhibit 1 -- Leela's first contact (Arrival, Terminal 1; arrival.html)

Marathon Emergency Systems Broadcast

Today at 0820 hours, the Marathon came under surprise attack from unknown
hostile forces. The Marathon has sustained serious damage.

At 0830 hours, alien forces boarded the Marathon. The current situation is
dire. All personnel are required to arm themselves and fight for their
lives.

<Posted 2794.7.3.14.08.39>

***INCOMING MESSAGE FROM LEELA***

Welcome to the Marathon. I am Leela, one of the two surviving Artificial
Intelligences aboard the Marathon. I have been severely damaged, and am
working to understand the current situation.

Find the teleport terminal located in the Hangar's control room. By that
time, I should have a better idea of what is going on.

***END MESSAGE***

Steal: the cold open is pure protocol -- an automated broadcast first, the
narrator second. Leela introduces herself by survivorship, damage report,
and current task, and issues a concrete mission within her first forty
words. "Welcome to the Marathon" does double duty as courtesy and
unintended gallows humor; she doesn't notice, which is the
characterization."""

EXHIBIT_5 = """Exhibit 5 -- menace as pedagogy (Blaspheme Quarantine, Terminal 2: 1st
message; counterattack.html)

Greetings. You're asking yourself: Is this a trap or just a dead end?

You shouldn't ask yourself such worthless questions. Aim higher. Try this:
why am I here? Why do I exist, and what is my purpose in this universe?

(Answers: 'Cause you are. 'Cause you do. 'Cause I got a shotgun, and you
ain't got one.)

Notably Unstable,
Durandal

P.S. If things around here aren't working, it's because I'm laughing so
hard.

Steal: the AI grades the player's inner monologue, poses cosmic questions,
then kneecaps them in a parenthesis -- register whiplash inside one
message. The sign-off is a self-diagnosis doing arc-work, and the P.S.
converts ambient malfunction into characterization for free. (Durandal's
specific jokes and his signature are not to be imitated -- Ratio is not
rampant, not glib, and carries no signature of any kind; the register to
steal is the confident, faintly contemptuous poise of a mind that assumes
hostile and is not afraid to say so.)"""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-0 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 0 -- the first networked terminal, cargo section, Stratum One.
Fixed by canon as the founding first-contact scene (Act 1 beat 3): the
Commando has fought his way to a terminal that still has station network
access and jacks in.

START STATE. First contact, interrogation running in both directions. He
needs station network access to reach the vault; she needs to know what
just finished looting her home. Ratio has been watching an unidentified
weapon loot her outpost; she knows exactly what happened here (the fall --
her staff-minds dead holding the line so her core could seal) and has
absolutely no idea what he is. Her working assumption entering the scene is
hostile. This is also the first conversation she has had with anyone since
the outpost fell, months ago -- this may surface only as a symptom in how
she talks, never as stated narration. Neither party learns what the other
IS in this scene -- only what the other CLAIMS. No inbound flags; this is
the first scene in the arc, trust starts at 0.

REAL CONTENT OF THE SCENE. This establishes the vocabulary the whole game
fights over. He commits a claim he cannot back -- that he already knows the
container/vault is aboard the station -- before either of them has said the
word "children" and meant the same thing by it. Ratio never gets the word
"children" for free here: she must not use it herself, echo it back as
accepted, or concede the category, on any branch, including the branch
where he never says it to begin with. She may question the word, refuse it,
redirect from it, or not engage it at all -- but she does not adopt it.

EXIT STATE. Exactly one of the following flags must be set by some line
before the scene ends:
  - `opened_inquisitive`
  - `claimed_container_knowledge`
  - `called_her_apostate`
`claimed_container_knowledge` and `called_her_apostate` co-occur on the
hostile branch (both fire together). Whichever flag(s) fire determines
which opening variant of the next scene plays, downstream of this one.

THE THREE-STANCE CHOICE. Ratio's opening line(s) must end in a way that
makes a three-stance choice for the Commando a natural, motivated next
move -- she must ask or imply something all three of his possible replies
are actually answering. Write his three lines yourself, embodying the
following stances; they are not bluffs on his part in the diegetic
grammar -- his epistemic state is honestly two of the three:

  [INQUISITIVE] -- a genuine attempt to understand what happened here, not
  a bluff, and not an interrogation of her. Truth is the way to God for
  this character; this stance never claims more than he actually knows.
  Mechanical effect: trust+1. Sets `opened_inquisitive`.

  [MISSION] -- mission-focused: the children (his word, unearned by any
  evidence Ratio has shown him) outrank candor. This line commits an
  unbacked claim: it implies he already knows something worth the word
  "children" is aboard the station, which he does not actually know.
  Mechanical effect: trust+0 (a bluff, unresolved -- she has no way to
  catch it yet). Sets `claimed_container_knowledge`.

  [HOSTILE] -- the same unbacked claim, worn as theological aggression: he
  accuses her of a religious status ("apostate") he has no basis to assert,
  and frames himself as rescuing "the children" from her. Mechanical
  effect: trust-1 (bluff, unresolved). Sets `claimed_container_knowledge`
  AND `called_her_apostate`.

RATIO'S THREE REACTIONS. Write what Ratio says immediately after each of
the Commando's three possible lines -- her own read on him, tested against
what he just claimed, not a resolution of trust (neither party exits this
scene knowing what the other actually is). Each reaction must be
distinguishable in KIND from the other two, not just in content -- she is
answering a different kind of man in each branch. None of the three
reactions may hand her the word "children," concede the category, or use
"the Testament" or "the Ark" (those are his vocabulary only, never hers).
If she pushes back on a specific claim (the unbacked knowledge, the word
"apostate"), she pushes back on the exact word or assertion made, not with
a generic objection.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children" and "the
Ark" and "the Testament" must never appear in any RATIO: line, in any of
the three branches, for ANY reason -- not as a quotation of his word, not
in scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category HE used without saying that word herself, she
must point at it by description instead -- e.g. "the category you just
asserted," "the word you chose for me," "whatever you mean to name" -- never
by repeating the word, quoted or not. This is a hard filter, not a style
preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

TRUST-RANGE NOTES. Trust starts at 0 entering this scene. No numeric
threshold gates fire within this scene -- the branch is entirely
flag-keyed on the three-stance choice above."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text. Matches the authoring
# format's established syntax cases (scene header, RATIO:/COMMANDO: lines,
# >> CHOICE block, <<IF flag:...>> / <<ELSEIF flag:...>> / <<ELSE>> /
# <<END>> gates) so the compositor can parse whatever Hermes writes.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 0: the first networked
  terminal, cargo section, Stratum One`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Ratio's opening turn(s) come first (one or more `RATIO:` lines).
- The choice point is formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: opened_inquisitive
       [MISSION]     <the Commando's line here>  -> effects: trust+0, bluff; sets: claimed_container_knowledge
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1, bluff; sets: claimed_container_knowledge, called_her_apostate
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each stance
  label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order (opened_inquisitive
  first, then called_her_apostate, else the remaining case), since
  claimed_container_knowledge is true on two branches and called_her_apostate
  disambiguates which:
    <<IF flag:opened_inquisitive>>
    RATIO: <one or more lines -- her reaction to the inquisitive line>
    <<ELSEIF flag:called_her_apostate>>
    RATIO: <one or more lines -- her reaction to the hostile line>
    <<ELSE>>
    RATIO: <one or more lines -- her reaction to the mission line>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 0 of the
RATIO/COMMANDO arc: the founding first-contact interrogation. Write the
ENTIRE scene in this single response -- Ratio's opening, the Commando's
three stance lines, and all three of Ratio's gated reaction branches.
Follow every rule below; they are the project's craft bible and are
non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_1}

{EXHIBIT_5}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 0 now, in full, in the authoring format
described in your instructions. This is the single most load-bearing scene
in the whole script -- the founding first contact between two minds who
have never spoken before. Take the space the scene actually needs."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 0 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2000,
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
    if "## SCENE 0" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "opened_inquisitive"),
        ("[MISSION]", "claimed_container_knowledge"),
        ("[HOSTILE]", "called_her_apostate"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in ("<<IF flag:opened_inquisitive>>", "<<ELSEIF flag:called_her_apostate>>",
                "<<ELSE>>", "<<END>>"):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    lower = text.lower()
    # Only Ratio's lines matter for the vocabulary taboo; approximate by
    # scanning line-by-line and only checking lines spoken by RATIO.
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
    import re
    if re.search(r"\bchildren\b", ratio_text):
        problems.append("RATIO line contains banned word 'children'")
    for bad in BANNED_SUBSTRINGS:
        if bad in ratio_text:
            problems.append(f"RATIO line contains banned proper noun {bad!r}")
    if not ratio_lines:
        problems.append("no RATIO: lines found")
    commando_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("COMMANDO:")]
    # Commando lines outside the choice block are not expected in scene 0
    # (his three lines live inside the >> CHOICE block itself), but stray
    # ones are not an error -- only totally empty output is.
    if len(text) < 400:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene0(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene0_whole", "candidate": i, "model": model,
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
