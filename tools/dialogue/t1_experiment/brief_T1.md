TERMINAL 1 -- second networked contact. Same session header/DO NOT OBEY
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
no preamble, no commentary, no JSON, no markdown code fences.