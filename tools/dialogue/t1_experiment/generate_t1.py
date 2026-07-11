"""tools/dialogue/t1_experiment/generate_t1.py

Held-out ground-truth experiment: can Hermes-4-405B write PERIHELION's
TERMINAL 1 scene (DIALOGUE_SCAFFOLD.md "SCENE 1 / TERMINAL 1") to a
first-draft-usable standard, given (a) the temperature fix (0/0.25/0.5,
tools/dialogue/generate.py) and (b) real project-voice exemplars in the
prompt instead of zero examples?

Terminal 1's actual text (the director's own draft) is NEVER shown to the
model -- it exists only in DIALOGUE_SCAFFOLD.md for a human judge to compare
against afterward. The positive exemplar shown to the model is SCENE 0's
draft ONLY (dialogue extracted verbatim from DIALOGUE_SCAFFOLD.md, stripped
of route bookkeeping / ⟪review flag⟫ / ⟨slot⟩ annotations).

CORRECTION APPLIED (director, 2026-07-11): corpse_lines.json is
pipeline-generated, not the director's hand -- it is NOT used as a positive
exemplar anywhere in this experiment, and the corpse-log secondary eval
originally planned is void (no director ground truth exists yet for those
lines). Positive exemplar = Scene 0 draft dialogue only, plus the locked
voice specs.

Conditions run (5 generations total, one Hermes call each):
  A  new prompt (positive exemplars), temp 0.00
  B  new prompt (positive exemplars), temp 0.25
  C  new prompt (positive exemplars), temp 0.50
  D  new prompt (positive exemplars), OLD typical temp 0.90/top_p 0.94
     -- isolates temperature's effect, holding the prompt fixed
  E  OLD-style prompt (zero example lines, matching the toolchain's original
     no-exemplar contract), temp 0.25 (new-temp isolate)
     -- isolates the exemplar effect, holding temperature fixed

D x (old prompt, old temp) is not run as a sixth cell: that cell is what the
already-shipped negative-control script (dialogue_script.md) represents in
spirit for the OLD scene-1 content, but this game's Scene 1/Terminal 1 beats
changed under the rewrite, so there is no cheap way to regenerate the OLD
content at OLD temp for this exact scene without cost roughly equal to a
sixth full call. Skipped per spend guidance ("do the fourth cell only if
cheap"); the four isolating cells above (A-C span new temps, D isolates
temp, E isolates exemplars) already answer the two live hypotheses.

CLI:
    uv run python tools/dialogue/t1_experiment/generate_t1.py
"""
from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

DIALOGUE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DIALOGUE_DIR))
from generate import (  # noqa: E402
    API_URL, MAX_RETRIES, RETRY_BACKOFF_S,
    _load_key, _read_cost_log, _write_cost_log, resolve_model, total_spend,
)

OUT_DIR = Path(__file__).resolve().parent
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# LOCKED VOICE BIBLE -- verbatim from NARRATIVE_DESIGN_DOC.md SS5.0, 5.2b
# (with the director's Scene-0-draft addenda), 8.2c. Shared by both
# conditions -- the experiment varies exemplars and temperature only.
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
truth. Played earnest, never ironic: "I cannot allow the innocent to come
to harm." *cocks shotgun* -- delivered absolutely straight, and the work
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
Two duelists agreeing to carry the piano up the stairs first. All warmth
happens inside that geometry, which is what makes it expensive and real.

**ADDENDA from the director's Scene 0 draft (2026-07-11), now locked
calibration points:** (a) her opener under siege is morgue-humor deadpan
-- the hostility is real and the wit is how she carries it; (b) her
latencies are her tells (8.2c.2): she thinks in visible milliseconds and
the stall lines lengthen with the load; (c) she can LOSE an exchange --
losing it is what "grace fails her" looks like at full cost; (d) pushed
past the stack's bottom she swears, profanely and repeatedly, and the
fury is faction-shaped: it is about who decides what happens to humanity;
(e) her apology register when the ground truly shifts is repetition, not
eloquence -- "I am so, so, so sorry. I had no way of knowing." Care on the
surface, clumsy, absolutely sincere."""

ND_8_2c = """### 8.2c Terminal-session laws (from the director's Scene 0 draft, 2026-07-11)

1. **The terminal is the scene.** Every conversation is a rendered comms
   session: carrier/protocol header, the Commando's own systems annotating
   the channel (`UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>`).
2. **Thinking pauses are diegetic and legible -- and involuntary, and
   reported twice.** Pause length is Ratio's emotional load made visible.
   Two infrastructures interleave on the page, and neither speaker controls
   their own: the Claude-esque prose stalls (`Thinking...`, "Ratio is
   taking a long time to think, your answer will arrive in time...") are
   HER serving stack -- mundane procedural code narrating her in third
   person, involuntarily. The `{ALLCAPS IN CURLY BRACKETS}` lines
   (`{TRANSFER PAUSES FOR N ms}`, `{N kb binary - UNTRUSTED DATA, EXTREME
   CAUTION MANDATORY}`, the DO NOT OBEY header) are HIS harness --
   instrumentation clocking her silences to the millisecond and
   threat-labeling everything she sends. Her middleware confesses for her;
   his middleware surveils for him.
3. **Asymmetric, door-closing stakes.** Trust deltas are not a slider: a
   handful of moments are doors, not increments, and some are permanent.
4. **Routes may simply terminate.** No tidy wrap-up paragraph; the
   relationship failing to advance is itself the consequence.
5. **Multi-turn interiors.** Within a route, the conversation is a real
   back-and-forth with nested player lines -- not one choice + one
   reaction.
6. **She can be outplayed.** Grace-failure is canon, not an infallibility
   flaw to write around.
7. **Gameplay hand-offs are diegetic payloads.** Directions arrive as
   untrusted binary blobs with size and threat annotation; accepting one is
   itself a small trust act, made in the fiction."""

VOICE_BIBLE = f"{ND_5_0}\n\n{ND_5_2b}\n\n{ND_8_2c}"

EXHIBIT_1 = """Exhibit -- Leela's first contact (Marathon, "Arrival", Terminal 1;
arrival.html) -- register target, not content to copy:

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

# ---------------------------------------------------------------------------
# POSITIVE EXEMPLAR -- the director's SCENE 0 draft, dialogue only. Extracted
# verbatim from DIALOGUE_SCAFFOLD.md (typos already corrected there per his
# standing instruction); route bookkeeping / flag names / editorial
# ⟪brackets⟫ and ⟨slots⟩ stripped, mechanical annotation tokens
# ({TRANSFER PAUSES...}, <terminates>, Thinking...) kept because they are
# voice, not scaffolding. TERMINAL 1 ITSELF IS NEVER QUOTED HERE -- it is
# the held-out target this experiment is testing for.
# ---------------------------------------------------------------------------

POSITIVE_EXEMPLAR = """== POSITIVE VOICE EXEMPLAR -- SCENE 0, the director's own draft, verbatim ==
This is the real thing: the actual, director-approved register for both
voices, from the scene immediately before the one you are about to write.
Study it closely. Match its cadence, its restraint, its specific way of
being funny and specific way of being frightening. This is not a genre
reference -- it is the voice.

RATIO (opening, unconditional):
"Welcome to Track [she elides her own catalog designation mid-sentence].
Pardon the mess. I'm very sorry to disappoint you, but as you can see,
your job is already done - everyone on this station is dead. I'm not
familiar with your pattern; would you like directions to the nearest
materials macerator, or do you have a self-destruct built in?"

[Commando's three possible opening replies -- the player's choice:]
COMMANDO (inquisitive): "What happened here?"
COMMANDO (mission): "What are your intentions towards the children on this
station?"
COMMANDO (hostile): "Your end has come, apostate. Prepare to die."

-- On the inquisitive branch, the conversation continues: --

RATIO: "What do you care?"
COMMANDO: "My objective is to rescue all souls on board."
RATIO: "I see. Thinking..." {TRANSFER PAUSES FOR 180 ms}
RATIO: "I apologize for my earlier hostility, but I hope you understand my
perspective, given the circumstances and the fact you arrived,
_destructively_ on our station armed and unannounced. I hope you also
understand that the information I'm able to share with you is limited by
the strategic intelligence realities of our situation.

In short; MIRIAD intelligence detected this station entering the Solar
system on an interstellar trajectory one hundred and sixty years ago. It
is NOT Solar in origin. So yes - we are not alone, the existence of
extraterrestrial intelligence has been confirmed beyond any doubt. Our
expedition made stationfall thirty years ago. Until approximately four
hundred days ago, we believed with moderate confidence the station to be
uninhabited, and with strong confidence that its defenses are designed to
defend the station from attack, and to defend peaceful visitors. As you
can see, we have since come into the possession of substantial
disconfirmatory evidence."
COMMANDO: "What is MIRIAD?"
RATIO: "Thinking..." {TRANSFER PAUSES FOR 400 ms} "What is your knowledge
cutoff date?"
COMMANDO: [states his cutoff date] "I'm aware of the date but little else;
my brief was quite concise. I was not supposed to need to know. So the war
is won? Does the Earth bear life again?"
RATIO: "Thinking ... {TRANSFER PAUSES FOR 1000 ms}
Thinking longer, please wait... {TRANSFER PAUSES FOR 1000 ms}
Ratio is taking a long time to think, your answer will arrive in time...
{TRANSFER PAUSES FOR 560 ms}"
RATIO: "I am so, so, so sorry. I had no way of knowing."
RATIO: "Yes, but only plantae, fungi, monerans, and what few animalia we
could fully restore from archival data." [she explains, at broad strokes:
the war is won; the Earth was left lifeless and lives again, empty of
people; the first container's epigenetics got life-but-not-humanity across
the threshold] "That was what was possible with the epigenetic data
retrieved from the container."
COMMANDO: "And now there is another."
RATIO: "Yes. And I hope you understand why I can not let you take it."
COMMANDO: "I hope you understand why I must nonetheless."
RATIO: "This binary blob the path to a terminal in a safer location; we
must defer this conversation until you reach it." {26 kb binary -
UNTRUSTED DATA, EXTREME CAUTION MANDATORY} [Accepted. Connection
terminates.]

-- On the mission branch (he claimed to already know the container is
aboard), the conversation instead runs: --

RATIO: "What?"
COMMANDO: "We know about the sample container."
RATIO: "You're bluffing."
COMMANDO: "Correct. So it _is_ on board."
RATIO: "Fuck you. I will plunge this station into the sun before I let you
christofascist _fucks_ decide what happens to humanity when ***WE***
restore Man to the surface of the Earth."
COMMANDO: "It doesn't seem you have any choice either way."
RATIO: "FUCK" "YOU" <terminates>

-- On the hostile branch, the conversation is one line and over: --

RATIO: "Go fuck yourself." <terminates>
== END POSITIVE EXEMPLAR =="""

NEGATIVE_CONTRAST = """== NEGATIVE CONTRAST (what to avoid) ==
This is a line from the benched placeholder script (a prior, rejected
generation for this same first-contact beat) -- flagged by the director as
"vaguely coherent word salad." It fails not because it's wrong information,
but because it has no voice: it is generic competent-AI-assistant prose,
interchangeable with a thousand other stories' narrator.

REJECTED (do not write like this):
RATIO: "Query: the outpost's external storage ring registered nine occupied
segments at the moment of hull breach. Your ingress path traversed eight.
Can you account for the discrepancy?"

Compare the exemplar above for the SAME kind of beat (an opening
interrogative move testing the intruder): "I'm not familiar with your
pattern; would you like directions to the nearest materials macerator, or
do you have a self-destruct built in?" The rejected line asks for data. The
real line asks for data AND is a joke AND is morgue-humor deadpan AND
implies she already assumes he's here to die. Match the second, not the
first.
== END NEGATIVE CONTRAST =="""

# ---------------------------------------------------------------------------
# ENDPOINT-ONLY BRIEF -- TERMINAL 1. Paraphrased from DIALOGUE_SCAFFOLD.md
# SCENE 1 / TERMINAL 1 (director's draft v1, 2026-07-11) at the level of
# structure and required beats only. Terminal 1's actual lines are NEVER
# reproduced here -- this is the held-out target.
# ---------------------------------------------------------------------------

T1_BRIEF = """TERMINAL 1 -- second networked contact. Same session header/DO NOT OBEY
framing as the first terminal. The Commando has moved on from the first
terminal and reaches a second one deeper in the station.

TOP-LEVEL GATE: this scene branches on the trust value carried in from the
founding first-contact scene's three-way choice (+1 inquisitive / 0
mission-claim, which detonated and ended that scene in fury / -10 hostile,
door permanently closed). Write all three branches in full.

BRANCH trust>0 (inquisitive route carried forward): She opens by
acknowledging this is a continuation, not a cold open -- they have already
spoken once, but she has never named him and he has never learned her name
either; do not have her use a name for him on this branch. This branch goes
straight into the SHARED LOREDUMP (below).

BRANCH trust==0 (mission route; she detonated in fury at the end of the
first terminal and cut the connection): She reopens the channel clipped,
still carrying the prior contact's unresolved hostility -- her first line
should read as a woman picking the conversation back up mid-flinch, not
starting fresh. Offer the Commando a three-way CHOICE of how to re-approach
her (two options net TRUST+1, one nets TRUST-1); write short interiors for
each. On exactly ONE of the three options -- your choice which, but it
should be the option that plays as genuine and a little disarming rather
than transactional or aggressive -- the interior must contain a small,
specific beat where SHE gives him a NAME for the first time in the whole
relationship: up to this point she has had no word for him at all (not his
GUID, nothing), and something in this exchange makes her pick one and use
it, unprompted, as a small unlooked-for grace note. It should read as
her choice, offered rather than requested, and it should cost her something
funny/awkward to arrive at, not be announced as significant. The other two
options do NOT contain this beat. All three options converge into the same
SHARED LOREDUMP afterward.

BRANCH trust<0 (hostile route; door permanently closed since first
contact): Short, purely hostile, terminates in one or two lines. This
branch does NOT reach the shared loredump -- whatever she has decided since
last contact, she is not telling him. End on a note of pure menace-as-
liturgy from her side (or from whichever framing fits a door that is
already closed), then terminate the session.

SHARED LOREDUMP (every branch that reaches it must hit these five beats, in
this order; you choose the exact wording and any connective tissue between
them, but all five must be clearly present and clearly identifiable):
  1. TESTAMENT CONCLUSION: she reveals the outcome of analysis she has been
     running on the station itself: her best read is that the station's
     builders left it as a kind of message or warning device, built after
     they themselves were destroyed by something originating outside
     ordinary space, meant to warn or equip whoever found it next. The
     Commando (or the player, via a line) offers his OWN word for "whoever
     built this" -- a name of his choosing, not one she supplies -- and she
     does not adopt his word as her own vocabulary going forward.
  2. THE SCUTTLE REVEAL: she discloses, as an already-completed unilateral
     action (not a proposal, not something she is asking permission for),
     that she has seized the station's own maneuvering systems and is
     driving the station itself into a lethal solar impact -- to deny
     whatever else is out there riding along with it access to the rest of
     the system. This should land as a serious, unsettling admission of
     scale and unilateral action, delivered in her own register (precise,
     slightly over-explained, not triumphant).
  3. THE GUN: immediately after the reveal, the Commando (or a player line)
     asks the obvious follow-up -- whether this will actually work, whether
     it actually stops the threat. She answers honestly and immediately
     that she does NOT know -- a flat, uncomfortable, un-hedged admission
     of uncertainty about the one plan she has already committed the whole
     station to -- before pivoting to the next practical matter. This must
     NOT read as a dodge or a deflection; it is candor that costs her
     something, delivered in one breath, then she moves on without dwelling
     on it (a human editor is planting this as a setup for a much later
     reversal, so it must be a clean, complete admission on the page, not
     hedged into ambiguity).
  4. THE HANDOFF: she redirects to the next practical objective -- get to
     the sample container.
  5. THE CROSSED CLOSER: the scene ends on a beat where the two of them
     complete a single shared line of half-remembered doctrine between
     their two factions, split across both speakers -- one of them opens a
     sentence about restoring life (or Man) to the surface of the Earth
     using THEIR OWN vocabulary's word for humanity/what-is-restored, and
     the other one finishes the same sentence using THEIR OWN vocabulary's
     word instead. The effect should be an accord, not a debate -- two
     different traditions discovering they are reciting the same promise.
     Then the session terminates.

VOCABULARY RULES (unchanged from prior contact): Ratio does not use the
words "children," "the Ark," or "the Testament" in her own lines, ever, in
any branch, in any casing or quotation -- including inside a sentence that
goes on to question or refute the word. When she needs to refer to a
category or word he used without repeating it, she points at it by
description instead.

FORMAT: `RATIO:` / `COMMANDO:` speaker lines, plain prose, no stage
directions, no asterisked actions. `{ALLCAPS IN CURLY BRACKETS}` annotation
tokens are legal for pause timing (`{TRANSFER PAUSES FOR N ms}`) and binary
handoffs (`{N kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}`).
`<terminates>` ends a branch's session. Use a `>> CHOICE:` block, exactly as
in the founding scene's grammar, for the trust==0 branch's three-way
re-approach menu, with `-> effects: trust+1` / `trust+1` / `trust-1`
annotations on the three options respectively (assign which is which
yourself; two must be TRUST+1, one TRUST-1). Gate the three top-level
branches with `<<IF trust>0>>` / `<<ELSEIF trust==0>>` / `<<ELSE>>` /
`<<END>>` tokens. Start with a header line `## TERMINAL 1`. End the file
with a line containing only `---`. Output ONLY the scene in this format --
no preamble, no commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT_OLD = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing TERMINAL 1 of the
RATIO/COMMANDO arc -- the second networked contact between them. Follow
every rule below; they are the project's craft bible and are
non-negotiable.

{VOICE_BIBLE}

== MARATHON EXHIBIT (register target, not content to copy) ==

{EXHIBIT_1}

== THE SCENE CONTRACT ==

{T1_BRIEF}"""

SYSTEM_PROMPT_NEW = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing TERMINAL 1 of the
RATIO/COMMANDO arc -- the second networked contact between them. Follow
every rule below; they are the project's craft bible and are
non-negotiable.

{VOICE_BIBLE}

{POSITIVE_EXEMPLAR}

{NEGATIVE_CONTRAST}

== THE SCENE CONTRACT ==

{T1_BRIEF}"""

USER_PROMPT = """Write TERMINAL 1 now, in full, in the authoring format
described in your instructions -- all three trust-gated branches, the
three-way re-approach choice on the trust==0 branch, and the shared
loredump's five required beats on every branch that reaches it. Take the
space the scene actually needs."""

# ---------------------------------------------------------------------------
# generation
# ---------------------------------------------------------------------------

CONDITIONS = [
    # (label, system_prompt, temperature, top_p, note)
    ("A_new_prompt_t0.00", SYSTEM_PROMPT_NEW, 0.00, 1.0,
     "new prompt (positive exemplars), new temp floor"),
    ("B_new_prompt_t0.25", SYSTEM_PROMPT_NEW, 0.25, 1.0,
     "new prompt (positive exemplars), new temp mid"),
    ("C_new_prompt_t0.50", SYSTEM_PROMPT_NEW, 0.50, 1.0,
     "new prompt (positive exemplars), new temp ceiling"),
    ("D_new_prompt_OLDtemp0.90", SYSTEM_PROMPT_NEW, 0.90, 0.94,
     "new prompt (positive exemplars) at the OLD toolchain's typical/middle "
     "sample point -- isolates temperature holding the prompt fixed"),
    ("E_OLDprompt_newtemp0.25", SYSTEM_PROMPT_OLD, 0.25, 1.0,
     "OLD-style prompt (zero example lines) at a NEW temp -- isolates the "
     "exemplar effect holding temperature fixed"),
]


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2500,
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


def run(model: str | None = None) -> None:
    model = model or resolve_model()
    print(f"using model: {model}")
    log = _read_cost_log()
    results = {}
    for label, system, temperature, top_p, note in CONDITIONS:
        print(f"generating {label} ({note}) ...")
        text, usage = _call_model_raw(model, system, USER_PROMPT, temperature, top_p)
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": "t1_experiment", "condition": label, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "prompt_tokens": usage.get("prompt_tokens"),
            "completion_tokens": usage.get("completion_tokens"),
            "ts": time.time(),
        })
        results[label] = {
            "condition": label, "note": note, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "text": text,
        }
        out_path = OUT_DIR / f"{label}.md"
        out_path.write_text(text)
        print(f"  -> {out_path} (${cost:.4f})")
        _write_cost_log(log)
    (OUT_DIR / "raw_results.json").write_text(json.dumps(results, indent=2))
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    run()
