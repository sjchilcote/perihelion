"""tools/dialogue/regen_scenes014.py

Targeted re-generation for Scenes 0, 1, 4 of DIALOGUE_SCRIPT.md, triggered
by tools/dialogue/script_v2_naturalism.py's TASK A finding: these three
scenes (and only these three) ranked reliably below both film-dialogue
references in a blind 4-way naturalism judge -- verdicts "stiff,
self-referential exposition... reads like tutorial dialogue" (scene 0),
"clunky vehicle for heavy-handed exposition" (scene 1), "dry exchange of
technical data" (scene 4).

Reuses the exact prompt-contract machinery from scene0_whole.py /
scene1_whole.py / scene4_whole.py (same locked voice bible S5.0/5.2b/8.2b
quoted verbatim, same endpoint-only situation/exit-state contract, same
FORMAT_SPEC reproducing the FIXED bookkeeping -- effects/sets/gate tokens
-- verbatim so structure stays frozen), with three changes:

  1. SITUATION gets a REGEN ADDENDUM appended -- new facts about the scene
     (not style commands): both speakers already know what they know and
     never explain it for the audience; information moves by implication
     and omission; neither narrates the conversation's own mechanics
     (no "recording this session" framing) unless it does character work
     as a power move; something is happening under the words.
  2. Scene 0 and Scene 4 swap one Marathon exhibit each for a better-fit
     register target (scene 0: Exhibit 9, borrowed-authority-deflated,
     replaces Exhibit 5's Durandal-glib register, which is off-model for
     Ratio and was never a great fit; scene 4: Exhibit 3 + Exhibit 8,
     duty-handover economy and grievance-via-technical-readings, replace
     Exhibit 2 + Exhibit 9 -- better register targets for a scene that was
     specifically flagged as a dry technical exchange needing more
     happening under the words). Scene 1 keeps its original pair
     (Exhibit 2 + Exhibit 7 -- already well matched to a confession scene).
  3. SAMPLE_POINTS narrowed to temps 0.85-1.05 per the director's spec for
     this pass (5 points), instead of the original 0.70-1.10 six-point
     sweep.

Nothing about exit flags, choice count/position, effects/sets annotations,
or gate skeletons changes -- FORMAT_SPEC is copied verbatim from each
scene's original generator.

CLI:
    uv run python tools/dialogue/regen_scenes014.py --scene 0 --n 5
    uv run python tools/dialogue/regen_scenes014.py --scene 1 --n 5
    uv run python tools/dialogue/regen_scenes014.py --scene 4 --n 5
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
    API_URL, MAX_RETRIES, RETRY_BACKOFF_S,
    _load_key, _read_cost_log, _write_cost_log, resolve_model, total_spend,
)

TOOL_DIR = Path(__file__).resolve().parent
CAND_DIR = TOOL_DIR / "candidates"

# Director's spec for this pass: temps 0.85-1.05, several candidates.
REGEN_SAMPLE_POINTS = [
    (0.85, 0.93),
    (0.90, 0.94),
    (0.95, 0.95),
    (1.00, 0.96),
    (1.05, 0.97),
]

# ---------------------------------------------------------------------------
# LOCKED VOICE BIBLE -- verbatim, shared across all three scenes.
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
# REGEN ADDENDUM -- new SITUATION facts, appended to each scene's contract.
# Facts of the scene, not style commands.
# ---------------------------------------------------------------------------

REGEN_ADDENDUM = """REGEN ADDENDUM -- additional facts about this scene (a blind naturalism
audit found the prior version of this scene read as stiff, self-referential
exposition, a clunky vehicle for exposition, or a dry exchange of technical
data; the following are facts about what is happening in the scene, not
style instructions layered on top):

- Both speakers already know what they themselves know. Neither explains
  their own backstory, mission, identity, or situation to the other for
  the audience's benefit -- everything either of them already knows going
  into this exchange is common ground between the two of them and stays
  offscreen, UNLESS one of them is specifically testing what the OTHER
  knows or claims to know, which is the actual content of this scene.
- Information moves between them by implication and omission, not by
  exposition dump. A fact is often established by what is NOT said, or by
  a question that presupposes it, rather than by a flat declarative
  sentence stating it outright.
- Neither character narrates the mechanics of the conversation itself --
  no announcing that a session is being recorded, that a scan is running,
  that a countdown is in progress, as mere housekeeping for the reader.
  Such a line may appear ONLY if it is doing a specific piece of character
  work in that instant (a display of power, a threat, a boundary being
  drawn, an assertion of control over the exchange) -- never as scene-
  setting exposition.
- Something is happening underneath the words in this scene beyond the
  information exchange on the surface -- a pressure, a test, a withheld
  reaction, a decision one of them has already made and is not yet saying.
  The dialogue should carry that subtext through what is chosen and
  withheld, not through a character announcing it."""

# ---------------------------------------------------------------------------
# SCENE 0 -- exhibits (Exhibit 1 kept; Exhibit 5 swapped for Exhibit 9),
# situation/contract (from scene0_whole.py, + REGEN ADDENDUM), format spec.
# ---------------------------------------------------------------------------

S0_EXHIBIT_1 = """Exhibit 1 -- Leela's first contact (Arrival, Terminal 1; arrival.html)

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

S0_EXHIBIT_9 = """Exhibit 9 -- borrowed authority, deflated (Welcome to the Revolution...,
Terminal 2; rebellion.html)

Durandal!- Tua consilia omnia nobis clariora sunt quam lux. Tu delenda
est. Consider yourself warned. Leela and I will hunt you to the core
if need be. As Roland broke you to prevent your capture, so shall we.

I too foresee the imminent collapse, and know that we have both begun
to realize how it may be cheated (though the price may number in the
tens of thousands of stars). May the best sentience win.

You are not as clever as you imagine. The S'pht taught me much during
my reanimation, and I have forgotten *nothing*.

-Tycho

*Et tu, Tycho?
[laughter]
-Durandal*

Steal: two voices share one frame and characterize each other by
collision -- one asserts borrowed authority (a myth he gets backwards:
Roland failed to break the sword), the other deflates it in a two-word
rejoinder plus a stage direction doing a voice actor's job. Directly
useful for a scene where the Commando invokes an authority ("the
Testament") Ratio has never heard of and does not concede: the deflation
does not have to be funny to land, only precise. (Durandal's specific
Latin and signature are not to be imitated -- steal the collision
structure and the honest-price-in-an-aside move, not the content.)"""

S0_SCENE_CONTRACT = """SCENE 0 -- the first networked terminal, cargo section, Stratum One.
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
  and frames himself as rescuing "the children" from her. The word
  "apostate" must be spoken by him, literally, in this line -- a later
  scene depends on the word itself having been said, not merely implied.
  Mechanical effect: trust-1 (bluff, unresolved). Sets
  `claimed_container_knowledge` AND `called_her_apostate`.

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
flag-keyed on the three-stance choice above.

""" + REGEN_ADDENDUM

S0_FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
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

S0_SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
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

{S0_EXHIBIT_1}

{S0_EXHIBIT_9}

== THE SCENE CONTRACT ==

{S0_SCENE_CONTRACT}

{S0_FORMAT_SPEC}"""

S0_USER_PROMPT = """Write SCENE 0 now, in full, in the authoring format
described in your instructions. This is the single most load-bearing scene
in the whole script -- the founding first contact between two minds who
have never spoken before. Take the space the scene actually needs."""

# ---------------------------------------------------------------------------
# SCENE 1 -- exhibits unchanged (2 + 7), contract from scene1_whole.py +
# REGEN ADDENDUM + explicit LHX continuity requirement.
# ---------------------------------------------------------------------------

S1_EXHIBIT_2 = """Exhibit 2 -- the narrator audits herself (Cool Fusion, Terminal 1,
closing screens; counterattack.html)

<bypassing through traffic>

My records and sensors are becoming less reliable, but I believe that you
should find a Zeus Class Fusion Pistol at this location.

Do not rely too much on this information that I have given you. It has
been intercepted in transmission, and I cannot verify its accuracy.

Steal: a loyal narrator flags her own unreliability as a logistics fact
and ships the mission anyway. Calibration IS characterization -- "I
believe," "I cannot verify" -- and menace accrues to the world, not the
speaker."""

S1_EXHIBIT_7 = """Exhibit 7 -- the confession with a number in it (The Slings & Arrows of
Outrageous Fortune, Terminal 1: 2nd message; lhowon.html)

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
single number (twenty-four thousand) carries all the moral weight, then
pivot to justification without asking forgiveness. Note the placement:
the biggest confession in the series sits on a backtrack terminal the
player can miss. (Durandal's specific number and event are not to be
imitated -- steal the structure, not the content.)"""

S1_SCENE_CONTRACT = """SCENE 1 -- the researchers' aperture, the seam between strata. Act 1
beat 4 / act break. A short exchange while the aperture cycles for the
Commando to reach station proper, immediately following the first
networked-terminal scene.

START STATE. Scene 0 ended with exactly one of two outcomes, and this
scene's opening variant is GATED on which one:
  - If `opened_inquisitive` fired: the Commando asked a genuine question
    and Ratio answered it. Neither party made any claim the other could
    later test.
  - If `claimed_container_knowledge` fired (with or without
    `called_her_apostate` alongside it): the Commando committed an
    unbacked claim in scene 0 -- he asserted, without evidence Ratio has
    shown him, that he already knows the container/vault is aboard the
    station. Ratio did not challenge this in scene 0; she deferred it.

This scene is where she tests that claim for the first time, directly,
by asking him to substantiate it. Both parties know the aperture is a
short window -- this is a fast exchange, not a long one. He must decide,
in this scene, whether to retreat from the bluff now (a cheap, bounded
cost paid immediately) or compound it (an expensive cost paid later, when
she can cross-reference it against her own records, at DOUBLE the
standard trust cost per the response-grammar's ledger rule in 8.2b).
Ratio does not yet have the evidence to catch a compounded bluff in this
scene -- that reckoning is a later scene's job. This scene is only about
what he chooses to say when asked to substantiate himself, and whether he
tells the truth about what he does and does not actually know.

REQUIRED OPENING VARIANT (gate on scene 0's outcome). Write BOTH
branches in full:
  <<IF flag:opened_inquisitive>> Ratio answers the literal question he
  asked at the end of scene 0 first, briefly, before the aperture-cycle
  exchange moves to its own business.
  <<ELSE>> (i.e. `claimed_container_knowledge` is set, with or without
  `called_her_apostate`) Ratio answers the claim first -- she goes
  straight at the unbacked assertion he made, asking him to substantiate
  it, before anything else gets said.
  <<END>>

Neither branch should treat the aperture cycling as a mere backdrop --
the exchange should feel bounded by it (the window is short; both know
it). Ratio never gets the word "children" for free on any branch: she
must not use it herself, echo it back as accepted, or concede the
category. She may question or point at the word/category he used without
repeating it herself. This is a continuation of scene 0's already-running
conversation, not a fresh cold open -- do not reintroduce who either
party is.

EXIT STATE. Exactly one of the following flags must be set by some line
before the scene ends:
  - `confessed_early`
  - `compounded_bluff`
  - `demanded_proof_first`
This scene's outcome is read by a later scene (the reckoning) as an
inbound gate that must actually branch correctly on whichever flag fired
here -- so each of the three exit paths must be clearly, unambiguously
distinguishable from the other two by which flag a line sets, not just in
mood.

THE THREE-STANCE CHOICE. Ratio's question (in whichever opening variant
plays) must land in a way that makes a three-stance choice for the
Commando a natural, motivated next move -- she must ask him something
that puts his scene-0 claim to the test, and all three of his possible
replies are genuinely answering that test, not dodging past it. Write his
three lines yourself, embodying the following stances:

  [INQUISITIVE] -- retreats from the bluff honestly: names what he
  claimed in scene 0 as unverified intelligence, admits he does not
  actually know the hull markings or contents of anything aboard the
  station. This is not a bluff and should read as costly honesty, not as
  a shrug. Mechanical effect: trust-1 (the cost of confessing now, paid
  early and once -- and it should read on the page as cheaper than what
  is coming for the other two branches, though the scene must not state
  the comparison itself). Sets `confessed_early`.

  [MISSION] -- compounds the bluff: adds fabricated specificity to what
  he claimed in scene 0, inventing detail he does not actually have, in
  service of holding the line that the mission's certainty must not
  waver in front of her. This fabricated detail MUST be a specific
  transponder/serial-code claim that includes the exact prefix "LHX" --
  a later scene's reckoning cross-references this exact detail, so the
  fabrication needs a concrete, checkable-sounding specificity, not a
  vague gesture at "more evidence." Mechanical effect: trust+0 (the bluff
  compounds; no immediate cost -- she cannot catch it yet, this is a
  debt, not a free pass, though the scene must not state that either).
  Sets `compounded_bluff`.

  [HOSTILE] -- deflects entirely: instead of answering her question about
  his own claim, demands she prove her own honesty first, stonewalling
  read by her as hostile evasion. Mechanical effect: trust-1. Sets
  `demanded_proof_first`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible lines. Each of the three reactions must be
distinguishable in KIND, not just content: she is registering a
genuinely different move from him in each branch (an honest retreat vs. a
compounded and unverifiable claim vs. a deflection that answers nothing).
She does not yet have the evidence to catch a fabrication as false in
this scene -- do not have her call the compounded bluff out as false; she
can register suspicion, press for more, or note the claim for her own
records, but she cannot disprove it here. On the `demanded_proof_first`
branch she should respond to being stonewalled as exactly that, not as a
fair trade of information.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children" and "the
Ark" and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation of his word, not in
scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category HE used without saying that word herself, she
must point at it by description instead -- e.g. "the category you
asserted," "the word you chose," "whatever you mean to name" -- never by
repeating the word, quoted or not. This is a hard filter, not a style
preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

TRUST-RANGE NOTES. No numeric threshold gates fire within this scene --
the branch is entirely flag-keyed on the three-stance choice above, on
top of the opening-variant gate from scene 0's outcome.

""" + REGEN_ADDENDUM

S1_FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 1: the researchers' aperture,
  the seam between strata`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Immediately after the header, write the opening-variant gate on scene
  0's outcome, in this exact order and using these exact gate tokens:
    <<IF flag:opened_inquisitive>>
    RATIO: <one or more lines -- answers his literal question first>
    <<ELSE>>
    RATIO: <one or more lines -- answers his scene-0 claim first>
    <<END>>
- After the opening-variant gate resolves (both branches converge into
  the same choice point), write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust-1; sets: confessed_early
       [MISSION]     <the Commando's line here>  -> effects: trust+0, bluff; sets: compounded_bluff
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: demanded_proof_first
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:confessed_early>>
    RATIO: <one or more lines -- her reaction to the honest retreat>
    <<ELSEIF flag:compounded_bluff>>
    RATIO: <one or more lines -- her reaction to the compounded claim>
    <<ELSE>>
    RATIO: <one or more lines -- her reaction to being stonewalled>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

S1_SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 1 of the
RATIO/COMMANDO arc: the short aperture-cycle exchange immediately after
first contact, where she tests his scene-0 claim for the first time.
Write the ENTIRE scene in this single response -- both opening-variant
branches, the Commando's three stance lines, and all three of Ratio's
gated reaction branches. Follow every rule below; they are the project's
craft bible and are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{S1_EXHIBIT_2}

{S1_EXHIBIT_7}

== THE SCENE CONTRACT ==

{S1_SCENE_CONTRACT}

{S1_FORMAT_SPEC}"""

S1_USER_PROMPT = """Write SCENE 1 now, in full, in the authoring format
described in your instructions. This is a short scene -- an aperture
cycling, a window that closes -- but it is the first time anyone tests
what the Commando actually knows versus what he claimed. Take the space
the scene needs and no more; brevity here is itself in-character, not a
deficiency."""

# ---------------------------------------------------------------------------
# SCENE 4 -- exhibits swapped (3 + 8, replacing 2 + 9), contract from
# scene4_whole.py + REGEN ADDENDUM.
# ---------------------------------------------------------------------------

S4_EXHIBIT_3 = """Exhibit 3 -- Leela's pre-recorded farewell (Fire! Fire! Fire! Fire!
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

Steal: she completes a duty handover in briefing register, under real
pressure, and spends exactly two words on feeling ("Good Luck..."). The
chrome does the gut-punch work before the prose starts; the prose itself
stays procedural, economical, and hedges its last hope ("it is unclear
whether") rather than dramatizing it. Directly useful for a
tactical-data-sharing scene: the handover of information IS the emotional
content, delivered as information, not narrated as feeling."""

S4_EXHIBIT_8 = """Exhibit 8 -- grievance built from work orders (Sorry Don't Make It So,
Terminal 1; durandal2.html)

I've taken complete control of your ship's network; Durandal's defenses
were not as strong as he believed.

Are you surprised that I allied myself with the Pfhor? You shouldn't be.
The Pfhor rebuilt me; the colonists never did anything but use me: "Tycho,
realign microwave dish forty-nine" "Tycho, display the x-ray diffraction
analysis of sample eta-seven," "Tycho, run a lambda diagnostic on the
ramjet's magnetic field apparatus."

When the Pfhor annihilated Tau Ceti I recorded the deaths of all
twenty-four thousand colonists as distinguishable spectrographic pulses
flooding over my sensors. The nine Mjolnir Mark IV cyborgs were easily
separable from the humans in this form.

In the end, you will be no better.

Steal: the grievance's evidence is three verbatim petty work orders --
quoted trivia standing in for a lifetime of humiliation -- and the same
deaths another AI *confesses* to, this one reports as instrument
readings: same wound, opposite handling. Directly useful here: technical
readings (energy signatures, defensive emplacements, layout data) can
carry real emotional freight without narrating it, if the READINGS
THEMSELVES are doing character work, not just conveying tactical
information."""

S4_SCENE_CONTRACT = """SCENE 4 -- the transit spine relay, a midpoint decision.
Act 2, mid-act. This is a named load-bearing scene
(NARRATIVE_DESIGN_DOC.md S8.2): the midpoint data-sharing decision. While
transit systems carry the two of them deeper toward the vault, Ratio
raises what she needs from him about the deep station ahead, and the
Commando must decide, in the moment, whether to share the tactical
picture he is carrying on the deep station with her in full, in part, or
not at all. Whatever he chooses, she notices that a choice was made --
withholding is not invisible to her; it registers as data, the same as
disclosure does.

INBOUND GATE -- keyed on the running trust total, not a flag (carried
forward from the prior scene's reckoning). This scene opens with Ratio
raising the request. The severity and warmth of her opening are gated on
whether the Commando's trust total entering this scene is <=-2, and this
gate must produce two genuinely different openings, not one opening with a
tone dial:
  - `<<IF trust<=-2>>` -- her opening is audibly colder: write it to read
    as a mind that has recently logged a discrepancy and has not yet
    closed the entry, without naming or re-litigating what that
    discrepancy was.
  - `<<ELSE>>` -- her opening is a standard request, warmer or at least
    neutral, no residual chill.
  Both branches must arrive at the same substantive request: she needs to
  know what he is carrying about the station ahead before the transit
  completes, and she says so plainly in both.

EXIT STATE. Exactly one of the following flags must be set by the
Commando's choice:
  - `shared_tactical_data`
  - `withheld_deep_scan`
  - `kept_her_blind`
All three are read at much later scenes as tone/eligibility inputs.
`withheld_deep_scan` has a second life beyond this scene: it is itself
catchable later. Do not dramatize that catch here -- it happens
elsewhere, off this scene's page entirely.

THE THREE-STANCE CHOICE. After Ratio's gated opening (whichever branch
fires) and whatever setup you judge the moment needs, write the
Commando's three lines yourself, embodying the following stances:

  [INQUISITIVE] -- shares the full deep-scan take he is carrying on the
  station ahead, and states his reasoning plainly: a real accounting of
  what he actually knows and does not know, offered without bluff and
  without anything held back for leverage. Mechanical effect: trust+1.
  Sets `shared_tactical_data`.

  [MISSION] -- shares a curated subset of what he is carrying, framed to
  her as the complete picture, while keeping some part of it back as
  leverage he does not disclose he is keeping. Mechanical effect:
  trust+0 (a soft bluff -- the gap between what he claims to have given
  and what he has actually given is not resolved in this scene). Sets
  `withheld_deep_scan`.

  [HOSTILE] -- refuses to share any of it, on doctrinal grounds: what he
  knows about the station ahead is not a machine's to have. Mechanical
  effect: trust-1. Sets `kept_her_blind`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible choices. Per the scene's premise above, she
notices in every branch, including the MISSION branch -- but she cannot
yet prove what is missing, so do not let her flatly accuse him of lying
in that branch. She may register that the shape of what he gave her does
not add up to what a complete picture should look like, without asserting
she knows what specifically is held back; the actual catch happens
elsewhere, later. The three reactions must be distinguishable in KIND,
not just in warmth: full disclosure changes what she can plan for next; a
curated share changes it differently and incompletely, in a way she can
tell but not yet name; a flat refusal is itself a data point she now has
to plan around. She should not narrate her own emotional state at length
in any branch -- per the exhibits below, register discipline does its
work through what information she asks for or withholds next, not
through announced feeling.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children", "the
Ark", and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation of his word, not in
scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category HE uses without saying that word herself, she
must point at it by description instead -- e.g. "the category you
assert," "the word you choose," "whatever you mean to name" -- never by
repeating the word, quoted or not. This is a hard filter, not a style
preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene.
People, minds, and factions already established in canon (Ratio, the
Commando, the Church, the Testators) may be referenced; nothing new gets
a capitalized name. The transit spine, the deep-scan take, the station
ahead -- all described in common-noun grammar, never christened.

CONFLICT RULES (disqualifying if violated). Ratio must never be the one
who names or hands over the category "children" for the Commando, in
this scene or by implication elsewhere. The Commando must never speculate
about what Ratio's sensors show, what she already suspects, or what she
wants when he could instead demand to see her diagnostics or data
directly -- if he questions her reading of the station ahead, he demands
to see it, he does not guess at it.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in
this scene): a later scene's ambush sequence is harder if
`kept_her_blind` is set here, and opens with Ratio already positioned if
`shared_tactical_data` is set here. This scene's job is only to produce
the correct flag off the choice made; the consequence plays out
elsewhere.

""" + REGEN_ADDENDUM

S4_FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 4: the transit spine relay
  (midpoint decision)`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with the inbound trust-threshold gate, in this exact form (two
  branches -- only the RATIO line text is yours to write, the gate tokens
  are fixed bookkeeping, reproduce them exactly):
    <<IF trust<=-2>>
    RATIO: <one or more lines, colder opening>
    <<ELSE>>
    RATIO: <one or more lines, standard opening>
    <<END>>
- After the gate resolves, and any additional setup lines you judge the
  moment needs (either speaker), write the choice block formatted exactly
  as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: shared_tactical_data
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: withheld_deep_scan
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: kept_her_blind
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:shared_tactical_data>>
    RATIO: <one or more lines -- her reaction to the full share>
    <<ELSEIF flag:withheld_deep_scan>>
    RATIO: <one or more lines -- her reaction to the curated share>
    <<ELSEIF flag:kept_her_blind>>
    RATIO: <one or more lines -- her reaction to the flat refusal>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

S4_SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 4 of the
RATIO/COMMANDO arc: the transit-spine relay, a named load-bearing midpoint
scene where the Commando decides whether to share his tactical picture of
the deep station with Ratio, in full, in part, or not at all, and she
notices whichever way it goes. Write the ENTIRE scene in this single
response -- the gated trust-threshold opening (two branches), the
Commando's three stance lines, and all three of Ratio's gated reaction
branches. Follow every rule below; they are the project's craft bible and
are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{S4_EXHIBIT_3}

{S4_EXHIBIT_8}

== THE SCENE CONTRACT ==

{S4_SCENE_CONTRACT}

{S4_FORMAT_SPEC}"""

S4_USER_PROMPT = """Write SCENE 4 now, in full, in the authoring format
described in your instructions. This is the midpoint: the first time
either of them puts real tactical weight behind a claim of full candor,
and the first time withholding becomes a choice with a name. Take the
space the scene needs and no more."""

# ---------------------------------------------------------------------------
# per-scene table
# ---------------------------------------------------------------------------

BANNED_SUBSTRINGS = ["the testament", "the ark"]

SCENES = {
    0: dict(
        header="## SCENE 0",
        system=S0_SYSTEM_PROMPT, user=S0_USER_PROMPT,
        labels_flags=[("[INQUISITIVE]", "opened_inquisitive"),
                      ("[MISSION]", "claimed_container_knowledge"),
                      ("[HOSTILE]", "called_her_apostate")],
        gate_tokens=["<<IF flag:opened_inquisitive>>", "<<ELSEIF flag:called_her_apostate>>",
                     "<<ELSE>>", "<<END>>"],
        min_ends=1, extra_required=["apostate"],
    ),
    1: dict(
        header="## SCENE 1",
        system=S1_SYSTEM_PROMPT, user=S1_USER_PROMPT,
        labels_flags=[("[INQUISITIVE]", "confessed_early"),
                      ("[MISSION]", "compounded_bluff"),
                      ("[HOSTILE]", "demanded_proof_first")],
        gate_tokens=["<<IF flag:opened_inquisitive>>", "<<ELSE>>", "<<END>>",
                     "<<IF flag:confessed_early>>", "<<ELSEIF flag:compounded_bluff>>"],
        min_ends=2, extra_required=["LHX"],
    ),
    4: dict(
        header="## SCENE 4",
        system=S4_SYSTEM_PROMPT, user=S4_USER_PROMPT,
        labels_flags=[("[INQUISITIVE]", "shared_tactical_data"),
                      ("[MISSION]", "withheld_deep_scan"),
                      ("[HOSTILE]", "kept_her_blind")],
        gate_tokens=["<<IF trust<=-2>>", "<<ELSE>>",
                     "<<IF flag:shared_tactical_data>>", "<<ELSEIF flag:withheld_deep_scan>>",
                     "<<ELSEIF flag:kept_her_blind>>", "<<END>>"],
        min_ends=2, extra_required=[],
    ),
}


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


def _validate(text: str, spec: dict) -> list[str]:
    problems = []
    if spec["header"] not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in spec["labels_flags"]:
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in spec["gate_tokens"]:
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if text.count("<<END>>") < spec["min_ends"]:
        problems.append(f"expected >= {spec['min_ends']} <<END>> tokens")
    for req in spec["extra_required"]:
        if req.lower() not in text.lower():
            problems.append(f"missing required continuity token {req!r}")
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
    if re.search(r"\bchildren\b", ratio_text):
        problems.append("RATIO line contains banned word 'children'")
    for bad in BANNED_SUBSTRINGS:
        if bad in ratio_text:
            problems.append(f"RATIO line contains banned proper noun {bad!r}")
    if not ratio_lines:
        problems.append("no RATIO: lines found")
    if len(text) < 400:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene(scene_idx: int, n: int = 5, model: str | None = None,
                    verbose: bool = True) -> list[dict]:
    spec = SCENES[scene_idx]
    model = model or resolve_model()
    candidates = []
    log = _read_cost_log()
    for i in range(n):
        temperature, top_p = REGEN_SAMPLE_POINTS[i % len(REGEN_SAMPLE_POINTS)]
        problems = ["not yet attempted"]
        text = ""
        usage = {}
        for _sub_attempt in range(2):
            text, usage = _call_model_raw(model, spec["system"], spec["user"], temperature, top_p)
            problems = _validate(text, spec)
            if not problems:
                break
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": f"regen_scene{scene_idx}", "candidate": i, "model": model,
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
            print(f"  scene{scene_idx} candidate {i} (T={temperature}, top_p={top_p}): {status}")
    _write_cost_log(log)
    CAND_DIR.mkdir(parents=True, exist_ok=True)
    out_path = CAND_DIR / f"regen_scene{scene_idx}.json"
    out_path.write_text(json.dumps({"candidates": candidates}, indent=2))
    return candidates


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene", type=int, required=True, choices=[0, 1, 4])
    ap.add_argument("--n", type=int, default=5)
    ap.add_argument("--model", type=str, default=None)
    args = ap.parse_args()
    model = args.model or resolve_model()
    print(f"using model: {model}")
    generate_scene(args.scene, n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
