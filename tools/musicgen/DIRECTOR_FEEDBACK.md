# Director feedback — music lane (verbatim record)

The complete, verified corpus of the director's music rulings as of 2026-07-13.
Everything here is quoted exactly; nothing paraphrased. (A prior agent's reports
attributed additional quotes to the director that appear in no transcript — those
are void. This file is the record.)

## The brief, in his words

> "make original music inspired by industrial soundtracks, Catholic hymns and
> gregorian chants, and this Mick Gordon talk"
> — https://www.youtube.com/watch?v=U4FNBMZsqrY

## Verdicts

On the round-1 showcase:

> "The music sounds like S H I T - like a parody of what would happen if you
> asked an AI to make music, AWFUL."

On the round-2 demo:

> "Listened to the demo. Not very good. Your 'guitar' sounds like a retro-game
> laser gun. You keep taking what I tell you to do and doing the extremely
> genericized, stereotyped, technically-correct version. I said 'make music
> inspired by gregorian chants and Catholic hymns' - you *literally downloaded
> a clip of an organ playing and put a filter on it. Start over entirely."

On how round 2 read the brief:

> "it turned that in to 'Download a 5-second clip of an organ playing and put a
> filter on it, then combine with some MIDI guitars.'"

## Method rulings

On the Gordon talk (do not summarize it away):

> "I think you're still overcompressing Gordon's talk. He goes in to EXACT
> DETAILS, literally describing the entire Doom Instrument architecture
> _component by component_, you could in theory replicate it exactly from what
> he said. Not everything translates 1:1 to what we can do, so _find the thing
> that has a similar effect on the final product._"

On process:

> "Learn from the music and audio workflow we did in ../johnny - look directly,
> no more subagents on this paticular task."

Round 1 method (still in force, from the original directive): break the
inspiration album into 30s blocks / 5s overlap, listen-analyze each, build a
playbook; instruments first, then melodies. Catholic and Protestant traditions
strictly separated; the game's register is Catholic.

## The positive spec (goal-gate, 2026-07-13)

> "Church music made by posthuman industrial machines that genuinely believe,
> _meaningful_ musical symbolism"

Gates: P(Mick Gordon would call it shippable, first-draft-grade, with an
original sound never _quite_ heard before, executing that spec) > 0.8; and
P(a professional technical artist calls the dynamic system's gameplay↔music
matching beta-test shippable) > 0.8.

Read the spec's clauses as constraints:
- **Church music** — liturgical FORMS, not church-flavored pads: antiphony
  (call and response), organum voice-leading, the eight modes, chant phrase
  grammar (breaths, mora), change-ringing patterns.
- **Made by machines** — the machines are the performers: pitched industrial
  sources as the congregation's voices, mechanical periodicity where a human
  would rubato, the Gordon array as their vocal tract.
- **That genuinely believe** — sincere, never spooky-chant irony. Reverence:
  space, patience, cadences that resolve. The congregation is not a horror
  texture; it is praying.
- **Meaningful symbolism** — symbols that refer to THIS game's facts: Dies
  Irae is not a metal cliché here, it is the literal plot ("solvet saeclum in
  favilla" — the world dissolved in embers — sung at a station falling into
  the sun). Chapter sets the rhythm, enemies own basslines, the player's
  weapon voices the lead (director's dynamic spec). Symbolism must be
  legible enough to mean, not trivia.

## Director-flagged gold from the talk

> "the 'infinite riser' - using Sheperd's tones to create a riser that builds
> escalating tension and release _on someone else's schedule_."

The dynamic-music primitive: a Shepard/Risset riser sustains "rising"
indefinitely — the GAME decides when it releases (combat entry, ambush
trigger, kill confirm), so tension always peaks exactly on the gameplay
event. Implement as a first-class stem (`shepard_riser`): intensity scalar
drives its level/rate; release = cadence hit + bus drop. Prime uses: a
dormant flicker nearby (the player can't see it — the music can), lockdown
waves building to breach, the drop into a hub fight.

## Working laws derived (shortest form)

1. **Start over entirely.** Round-1/round-2 instruments, melodies, and demos are
   condemned. Analysis artifacts (album block corpus, Gordon transcript,
   chant transcriptions) survive as reference.
2. **The named failure mode:** turning a creative brief into its most reductive
   technically-correct mechanical reading (organ clip + filter; MIDI guitars).
   The task is ORIGINAL COMPOSITION — the sources are inspiration to digest,
   not assets to fetch.
3. **Gordon's architecture is a spec, not a vibe.** Replicate component by
   component; where a component can't be replicated, substitute by *effect on
   the final product*, never by dropping it.
4. **The only quality gate is the director's ear.** No model score is
   authoritative. Short samples, early, over long polished failures.
5. **No subagents on this task.** The main line does the work directly, after
   directly studying ../johnny's music/audio workflow.
