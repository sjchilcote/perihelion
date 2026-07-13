# Gordon Method — distilled from "DOOM: Behind the Music" (GDC 2017)

Source: Mick Gordon's GDC talk, verified as GDC Festival of Gaming's upload
titled "DOOM: Behind the Music" (uploaded 2017-08-22, 61 min,
https://www.youtube.com/watch?v=U4FNBMZsqrY). Transcript: YouTube
auto-generated captions, deduped into continuous prose, ~9,780 words.

**Revision note**: the first version of this doc was produced by a
research subagent that summarized the transcript into a flat 10-point
listicle of generic audio-production techniques (parallel chains,
sidechain compression, ring-mod, tuning to root, "punchy transients").
That shape is recognizable as the LLM default for "game composer talk
about layered distortion" — and it contained at least one substantive
error: it described the final compressor as a generic "transient-punch"
tool, when Gordon's own words describe something more specific and more
interesting (see Lesson 1 below). Directorial correction: don't
genericize the talk, read what it actually says. This version is
rewritten directly against the transcript, quoting Gordon's own words,
and restructured around the **three lessons Gordon himself states** at
the close of the talk, rather than an invented equal-weight bullet list.

---

## Gordon's own closing recap (his words, his structure — not mine)

He ends the talk by naming these explicitly, in this order, as "what we
learned":

1. **"If you want to get a different outcome, you must change the
   process... it takes courage to do so. I say courage, not confidence.
   Confidence comes from doing the same thing over and over and over
   again. It takes courage to change that."**
2. **"Change the brief if it makes the project better."** They violated
   the brief's own "no guitars, we hate guitars" clause, deliberately,
   because it was blocking a *different* clause of the same brief
   ("instantly loved by millions of fans") — a considered trade against
   the brief, not scope creep.
3. **"The most important [thing]: a team that encourages an environment
   where you feel comfortable in failure will enable you to thrive as a
   composer... your fear of rejection will often get in the way of you
   experimenting."** He calls this the most important lesson, full stop —
   not an aside.

Everything below is the concrete technical material that sits *under*
lesson 1 (what "changing the process" actually looked like, mechanically)
— but the doc is organized this way, matching his own emphasis, instead
of flattening his #3 into a random bullet among ten.

---

## Lesson 1: change the process — what that meant, mechanically

### The failure mode he names first

Given the brief ("Doom is about demons on Mars, no guitars, must be
loved by fans"), he describes three hypothetical composers — a piano
player, a dubstep producer, a composer running Kontakt "demon/hell/Mars"
patch templates — each of whom would produce something "inspired by the
brief... but not an execution of it," because each ran *their own default
process* regardless of the brief. **"You cannot expect to end up with a
different outcome without changing the process."** This is a warning
against pattern-matching a familiar recipe onto a new brief — which is
exactly the failure this project hit with the first `GORDON_METHOD.md`
draft itself (summarizing the talk via a familiar "audio production tips"
template instead of reading it).

His own first attempt at "the DOOM sound" (sub-bass sine + white noise +
distortion) was *also* this failure, by his own admission: **"I knew in
myself it wasn't correct. All I've done is taken some sounds and ran them
through distortion... I'm a guitar player, they've been doing that exact
thing for about ten years."** Recognizing a result as a genre cliché and
discarding the *whole recipe* (not tuning its parameters) is the actual
skill being demonstrated — not any single DSP trick.

### Where the array idea came from — not a distortion-chain lookup

He explicitly credits a different source for the array's *shape*: Tony
Visconti's gated-microphone technique on Bowie's "Heroes" (three mics at
increasing distance, gated open only as Bowie's voice got louder, so
reverb amount *scaled dynamically with input*). **"They designed a system
that dynamically added reverb based on the input, so I thought: what if I
designed a system that dynamically produced interesting and appropriate
musical bits based on the input?"** The array is not "four distortion
pedals in parallel" as a static recipe — it's *a dynamic system whose
output character changes with input dynamics*, modeled on Visconti's
gate-by-distance idea. This is the actual design principle: build a
signal chain whose *behavior* (not just its timbre) responds to what's
being fed into it.

### The actual array topology (his numbers, not rounded)

Sine wave → split into 4 chains:
- **Chain 1**: 4 pedals (RML 432K distortion, Metasonix kV100 tube
  distortion, a "Geiger counter"-style bitcrusher, a Dwarfcraft Devices
  pedal) → a **splitter**. This splitter's output is sent as a
  **sidechain trigger into chains 2 and 3's compressors** — "based on
  whatever the input was doing, it could dynamically change the mix of
  each chain." This is real cross-chain sidechaining, and chain 1
  specifically is the *driver*, not a peer being ducked.
- **Chain 2**: 4 pedals (another Geiger-counter bitcrusher, Metasonix
  TX-3, a Mutron Bi-Phase, a DOD 70s phaser) → a compressor (the sidechain
  target from chain 1).
- **Chain 3**: Watkins Copicat tape echo → a distortion box used "more for
  the compression aspect" than distortion → an Akai reel-to-reel fed
  **~40dB hotter than it can handle**, recorded back off simultaneously →
  spring reverb (wet/dry) → compressor (also a sidechain target).
- **Chain 4**: a small guitar-practice amp fed ~40dB hot, mic'd, with a
  **small feedback loop** (a little of the mic signal routed back into the
  amp) — small enough that "if a sound was actually coming through the amp
  it would choke out the feedback, and when that sound started to
  disappear, the feedback would come back up in the mix."

All 4 chains → mixer → EQ ("cut about 4-5dB around 30-60Hz, boost about
the same up around 8-10[kHz], a smiley-face curve") → **one shared final
compressor**: "absolutely pinned... knocking off about 20 decibels,"
30ms attack, ratio "twelve or twenty to one."

### The compressor's actual purpose (the point the first draft got wrong)

**Direct quote, this is the mechanism**: *"The reason I was hitting it
that hard was so when the loud noises would start to go away, the
compressor begin to open up and bring up all the interesting noise that
every single one of these pedals and bits of equipment was creating."*

This is **not** "punchy transients via fast attack" as a generic mix
trick (that's a *separate*, secondary point he makes in the Q&A about
game-mix transients in general — see below). It is specifically: hard gain
reduction on the loud part, **then makeup gain restores level**, which
means the makeup gain also lifts everything that *wasn't* being reduced —
the pedals' own idle noise, feedback-loop hum, tape hiss, spring-reverb
tail — up into audibility once the input note decays. He demonstrates this
directly: feeding the array 4 sine-wave "F" notes, *"at the end of those 4
F notes you'll hear another note creeping underneath it... that's coming
from some ground hum within the array."* The chain's own artifacts become
part of the instrument's voice, specifically in the silence after a note.

**`tools/musicgen/gordon_chain.py`'s `tempo_punch()` was rewritten to
match this**: hard threshold-based gain reduction on the transient, then
explicit makeup gain applied to the *whole* signal afterward (not just
the compressed part) — so a chain's own resonant tail (the comb-filter
"feedback loop" path, see below) becomes audible once the source note
decays, instead of just producing a punchy attack and nothing else.
`guitar_chain()` was also fixed to pad the source with trailing silence
before running the parallel paths, because truncating every path back to
`len(source)` (the original bug) silently cut off exactly the resonant
tail this mechanism depends on having room to ring into.

### The separate, secondary point about transients (Q&A, general game-mix advice)

Distinct from the above: asked in Q&A about punchy attacks, he separately
says *side-chain compressors with ~30ms attack* (lets the transient
through uncompressed) into *a slower final compressor, heavily pinned*,
whose release he'd manually tune to the track's tempo, because *"if
you've got just a solidly limited thing sitting in the background it
doesn't come through... those dynamics going [transient]-then-gone... 
tricks the player's ear into believing there's more solid music
happening."* This is real and does apply generally to game mixes, but
it's a secondary Q&A remark about mix translation, not the mechanism
behind the DOOM instrument's own compressor (which is the noise-reveal
effect above) — the first draft conflated the two into one bullet.

### Ring-modulating a sub with gated noise (a real, separate, concrete recipe)

Confirmed accurate from the transcript: a ~36.7Hz sub is nearly inaudible
on small speakers alone. His fix: take white noise, gate it on/off *at the
sub's own frequency* ("ring modulation, but at the audio frequency"), sum
it with the sub, then run both through distortion together so new
harmonics form from the interaction. `gordon_chain.py`'s `ring_mod_noise()`
implements this literally.

### Real physical nonlinearity over generic waveshaping (confirmed, refined)

- Guitar tone: Sean Beavan's (Marilyn Manson's engineer) technique —
  record the guitar part an octave up and double-speed to tape at 30ips,
  play back at 15ips through a hard-driven preamp.
- Drone layer: **literally bowed guitar strings**, detuned between C and
  C#/D, across four octaves, multi-tracked.
- Reel-to-reel and mini-amp both driven ~40dB past their rated input and
  recorded off simultaneously — real analog overload, not a `soft_clip()`
  call.
- We're numpy-only (no tape/pedals available), so this doesn't transfer
  literally, but the *lesson* — model a specific physical nonlinear
  process rather than a generic waveshaper cliché — is why
  `instruments.py`'s Karplus-Strong string model (a physical pluck/decay
  model) is the right shape of approach, and why round 2 pivoted to
  processing **real recorded samples** (freesound guitar/kick, see
  `SOURCES_LICENSES.md`) through the array rather than synthesizing a
  "guitar" from scratch.

### The chainsaw "Trojan horse" (a specific detail, not generic "guitar reintroduction")

The morph from a pure guitar tone into a chainsaw sample (via Image-Line's
Morph plugin, interpolating between the DOOM chainsaw SFX and a guitar
tone) was specifically how he got guitar-derived material *approved*
inside a "no guitars" brief — it read as a game-native texture first,
guitar second. Guitars were then reintroduced gradually ("5%... 10%...")
and validated against the actual game feel at each step, not against the
written brief — a direct enactment of Lesson 2 (change the brief when it
demonstrably improves the result).

### Tuning shared SFX to the music's root (confirmed accurate)

DOOM's triple chain-gun's fire-rate produces an audible tone; they tuned
it to D to match the music's root, deliberately, at design time: *"if you
can carve your sounds and your music with that stuff in mind to begin
with, you're going to end up with a much tighter mix... it's not
something you can fix in Wwise later on."*

### Easter eggs as narrative device (confirmed accurate)

An image of a "6" and an inverted star loaded into Image-Line's Harmor
(spectral synth) to imprint their shape onto a bass part's spectrum
(visible only via spectrogram), and a mid-side phase trick (info on one
channel, phase-flipped copy on the other, resolves only when summed to
mono) — both deliberate secrets tied to the game's imagery, not sound
design for its own sake. This project's Catholic-liturgical register has
an equivalent opportunity (a hidden chant fragment or verse revealed only
under specific playback conditions) if the director wants one — noted as
an idea, not built.

---

## Lesson 2 and 3, applied here

**Lesson 2 (change the brief)**: this project's round-1 rejection is the
brief-violation moment — the director's "AWFUL" verdict is exactly the
kind of result that should trigger reconsidering the *approach* (as this
round-2 rebuild does: real samples instead of pure synthesis for
guitar/kick, motif-based melody instead of a looped array, chant-derived
material), not defending round 1's design while tuning its parameters.

**Lesson 3 (team psychological safety)**: not directly actionable by a
solo pipeline, but the operative translation is: report failed
intermediate results honestly (this doc's own revision note above; the
listen-proxy checks in `SOURCES_LICENSES.md` that failed and are logged
as failures, not hidden) rather than presenting only the version that
looks finished.
