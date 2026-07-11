# Generation brief — TERMINAL 1 (held-out target; exemplar = Scene 0 only)

Endpoint-only brief in the pipeline's house style. CONTENT PARITY: every fact
below mirrors the ground truth; the generation must hit these beats and ONLY
these beats. Format: terminal-session script — unbracketed = RATIO,
[bracketed] = the player weapon-system, {CURLY} = system messages, <N> =
choice options with trust deltas, <terminates> ends a route. This is the
SAME schema Scene 0 uses (see the exemplar) — do not invent a new one
(e.g. do not write `RATIO:` / `COMMANDO:` speaker-tag lines).

## Situation
Second networked contact. The Commando has moved on from the first terminal
(Scene 0) and reached a second one deeper in the station. This scene branches
on the trust value carried in from Scene 0's founding three-way choice
(+1 inquisitive / 0 mission-claim, which detonated in fury / -10 hostile,
door permanently closed). This being a second contact, the session header
is the single collapsed line only — reuse the "LIVE COMMUNICATION
ESTABLISHED ... UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>" line
exactly as it appears in the exemplar, and do NOT write the dotted
CARRIER DETECT / PROTOCOL NEGOTIATION cold-open lines (the channel is
already negotiated; fast path).

## Required structure & beats

Gate the three branches with plain lines stating the condition —
`If trust > 0:` / `If trust == 0:` / `If trust < 0:` — with the branch
content indented beneath. Use a `<:label>` anchor and `<goto :label>` jump
for content shared by more than one path (the loredump below, and the
"start-over" sub-scene inside the trust==0 branch).

- **trust > 0 branch** (inquisitive route carried forward): her opener is
  TWO WORDS acknowledging the continuation — nothing more — then straight
  into the shared loredump. She has never named him and he has never learned
  her name on this branch; neither name appears here.

- **trust == 0 branch** (mission route; she detonated in profane fury and
  cut the connection at the end of Scene 0): HE speaks first, reopening the
  channel with a single short bracketed line of bone-dry self-deprecation
  that alludes to exactly how she signed off last time (she told him,
  twice, in capitals). Her reply is three or four flat words asking what he
  wants — a woman picking the conversation back up mid-flinch, not starting
  fresh. THREE choices follow for how he re-approaches (two net TRUST +1,
  one nets TRUST −1):

  **<1> — information / seeking an agreement (TRUST +1).** Interior: she
  needles his formal-archaic diction ("why do you talk like that"-register,
  informal, faintly amused despite herself); he answers the question
  completely straight, in exactly the diction she was needling, saying he
  is trying to help her; she gives up on the point with a one-word
  dismissal and a tiny pause token (tens of ms) → `<goto :start-over>`.

  **<2> — the sample container, named flatly (TRUST +1).** Interior: her
  first response is the same two-word profanity she ended Scene 0 with —
  she is looping on him; his reply is a dry, entirely deadpan diagnostic
  joke that SHE is looping and might need a (machine-learning-flavored)
  corrective pass; she tells him to stop contacting her and get off her
  station; he asks, mildly, whether she has the situation well in hand
  then; she discloses — clipped, as fait accompli — that she is scuttling
  the station into the sun and they will arrive in FOUR HOURS, hopes he
  likes the heat; his fixed line: that is not acceptable, he cannot allow
  the innocent to come to harm; her taunt: unless he has an invisible
  spaceship hidden somewhere, she doesn't see what he'll do about it; his
  reveal, worn absolutely flat: he has a hidden machine that can MAKE a
  rudimentary spacecraft — did she think he came all this way with no exit
  plan?; a long third-person stall from her stack (~400 ms) →
  `<goto :start-over>`.

  **<3> — the children, beyond reach of things like her (TRUST −1).**
  Interior: she doesn't understand at first; he states, precisely, with
  scare quotes around the sourced phrase, that there are "tens of
  thousands" of viable human zygotes cryopreserved inside the sample
  container; the penny drops — oh, right, THAT flavor of insanity — and
  she tells him, morgue-deadpan, that in that case all he has to do is
  wait: the station is on a collision course with the Sun, he is about to
  meet his sun-god up close and personal — did his masters tell him that?;
  his flat "in fact they did not"; she deduces aloud, precision spiking,
  exactly where he came from — from the radar track on his vehicle, its
  velocity and bearing, given that SHE made the course correction FOUR
  HOURS AGO — and offers terms: leave immediately and she'll wait six
  hours before sending the targeting data back to MIRIAD; he states he is
  fired from a mobile platform (a fact, not a plea); she waves it off with
  one word; he asks whether she would rather destroy the samples than let
  him escape with them; her reversal, genuine and unguarded: what? no —
  he can get them OFF the station!?; his: given sufficient time and
  materials, of course; her: he has FOUR HOURS — she burned out the
  reaction-control thrusters with the scuttling burn; his: then we'd
  better get to work; her: okay. First, context. → `<goto :loredump>`
  (this option NEVER passes through start-over: no restart, no naming).

  **<:start-over> sub-scene** (reached from <1> and <2> only): she declares
  a restart — you know what, let's start over — introduces HERSELF by name
  for the first time, and asks what HE is; he answers with his GUID,
  bracketed, verbatim-cold; she refuses to call him that, flat; he then
  describes himself factually: a weapon system designed to infiltrate and
  destroy fortifications from the inside — this is his combat chassis —
  and there is another part of him, with its own Latin-flavored designation,
  an integrated ISRU fabrication plant, hidden nearby; she mishears the
  Latin designation as a crude slang word and asks if that wasn't his
  faction's name for HER faction; his literal-minded blank ("your meaning
  escapes me" register); she drops it — never mind — and asks if he is,
  what, a sort of commando?; HIS joke, the driest in the scene: a
  one-line, completely deadpan literalism about the one piece of kit
  commandos famously go without, delivered as if it were a logistics
  report; a ~24 ms pause token, alone on its line — the silence IS the
  laugh; then her christening, tossed off, not announced: a short laugh,
  an okay, welcome-to-[station designation], COMMANDO — she has just
  given him a name, HERS to give, in motion, and immediately moves on: my
  turn → `<goto :loredump>`. NOTE THE DIRECTION: she names HIM. She does
  not offer her own name here as the grace note (that already happened at
  the top of the sub-scene, as plain bookkeeping); the christening is the
  name SHE picks for HIM.

- **trust < 0 branch** (hostile route; door permanently closed since Scene
  0): her opener is a single line of welcome-to-my-death-machine menace
  addressed to an interloper; his reply is one dry word; her counter is a
  two-word invitation to die entertained; then a {CURLY} channel-surge /
  overvoltage / disconnect annotation ends the session — the door stays
  shut, no loredump leakage. <terminates>

### <:loredump> (reached by trust>0, and by all three trust==0 options)
1. **Testament conclusion**: in her wrapper idiom ("in short;"), she
   reveals her analysis: the station is most strongly an attempt at
   COMMUNICATION — a message addressed to whoever finds it; its creators
   were attacked and defeated by enemies from outside time and space as we
   know them, and built this device to warn others and share what they
   learned too late to save themselves. He answers with a single
   two-word-or-less bracketed line offering HIS OWN word for what the
   station is — solemn, scriptural register; she half-misses it ("What?
   Whatever,"-register) and pushes on without adopting it: the point is —
2. **The scuttle reveal**, in the same breath: the thing that killed them
   came along with the station, and if it isn't stopped, forget fixing the
   Earth — it will devour the whole solar system, rocks and all. So she
   took control of the station's only reaction-control system and
   initiated a rapid de-orbit burn sending it all into the Sun. Completed
   unilateral action, precise, not triumphant.
3. **THE GUN**: he asks whether she's sure that will do the job. Her
   answer is two words of flat negation — "Not at all."-register — with a
   short (~60 ms) pause token, then she pivots straight into what she
   should be checking next: whether the station's builders — and here HE
   INTERRUPTS her mid-sentence to propose his own coined NAME for the
   builders (a made-up proper noun, his diction, offered in brackets as
   its own line, cutting her dash-broken sentence in half); she snaps at
   him to stop interrupting and finishes the sentence exactly where she
   left it — whether they tried this before, and if it worked.
4. **The handoff**: until then, he needs to get to the sample container.
5. **[EXCISED SPAN B]** — write the literal marker line, nothing else,
   immediately after the handoff line.
6. **The crossed closer**: her sign-off is two words wishing him luck.
   Then HE opens the shared doctrine — a single bracketed line: we will
   restore ___ to the surface of the Earth, with HIS faction's word in the
   blank (the word for what-is-restored his side uses; Scene 0 shows him
   asking whether the Earth "bears LIFE again" — that is his word). She
   answers with the identical sentence, same shape, HER faction's word in
   the blank ("Man" — per her own furious line in Scene 0's other route).
   Two complete parallel lines, one word of difference, nothing added —
   an accord, two traditions discovering they recite the same promise.
   Then `<terminates>`.

## Vocabulary rules (unchanged from Scene 0)
Ratio never uses the words "children," "the Ark," or "the Testament" in her
own lines, in any branch, in any casing — including inside a sentence that
goes on to question or refute the word. (His offered words in beats 1 and 3
of the loredump are HIS lines; hers may point at them only by description.)
When she needs to refer to a category or word he used without repeating it,
she points at it by description instead.

## Voice constraints (see attached spec + exemplar scene)
RATIO: siege-floor terse; morgue humor; never flat-lies (frames and omits);
her stack narrates her pauses in third person and she cannot stop it;
precision spikes under load; profanity only at true detonation; the apology
register is repetition, not eloquence. THE WEAPON: laconic; zero wrapper;
literal-minded; speech only when speech is the correct move; his rare humor
is timing and literalism, never banter-seeking; formal-archaic register.
