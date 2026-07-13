# Gordon Method — distilled from "DOOM: Behind the Music" (GDC 2017)

Source: Mick Gordon's GDC talk, verified as GDC Festival of Gaming's upload
titled "DOOM: Behind the Music" (uploaded 2017-08-22, 61 min,
https://www.youtube.com/watch?v=U4FNBMZsqrY). Transcript source: YouTube
auto-generated captions (`.vtt`), deduped from rolling-caption overlap into
continuous prose. Full talk + ~10 min Q&A captured, ~9,780 words.

Round 1 of this project's music was judged "AWFUL... a parody of what an
AI thinks music sounds like" by the human director. The automated judge
that scored round 1 highly is known broken. This doc is written for round 2:
concrete changes to how `tools/musicgen/instruments.py` and its siblings
build synthesized/sampled instrument chains, each tied to something Gordon
actually said or demonstrated.

---

## 1. The process is the instrument, not the patch

Gordon's core thesis, repeated three times verbatim ("change the process,
change the outcome"): handing the same brief to a piano player, a dubstep
producer, or a composer with stock Kontakt patches produces three different
genres but the *same failure* — each person ran their default process and
got a result "inspired by the brief" but not "an execution of it." The fix
isn't a better preset, it's a different signal chain built for this brief.

**Concretely for us:** `instruments.py`'s existing pattern of "class change,
not re-tune" (see the `kick()` and `snare()` docstrings, which explicitly
reject iterating on the same synthesis approach and instead swap the whole
technique — e.g. FM-growl → Karplus-Strong for `rhythm_chug`) is already
the right instinct. Keep doing that for round 2: when a judged instrument
is wrong, don't nudge its filter cutoffs — replace the generating process
entirely (different oscillator topology, different physical model, a
whole new signal path), the way Gordon replaced "run a sine through a
distortion pedal" with the entire four-chain pedal array.

## 2. Build a literal custom signal-chain "instrument," feed it only pitch/amplitude

Gordon's actual DOOM instrument: a sine wave split into four parallel
hardware chains (fuzz/tube-distortion/bitcrusher pedals, phasers + an old
tape echo, an overdriven reel-to-reel machine into a spring reverb, a
mini-amp pushed 40dB hot with a controlled feedback loop back into itself),
recombined through a mixer, EQ (cut 30-60Hz by ~4-5dB, boost ~8-10dB
around 8-10Hz shelf, "smiley face" curve), and a hard-pinned compressor
(~20dB gain reduction, 30ms attack, 12:1-20:1 ratio) whose release he tuned
to tempo. He fed this array *only* a sine wave and varied *only* pitch and
amplitude — "everything sending through it was a sine wave... any
interesting thing happening within this array was being imparted onto that
sine wave in the purest form possible."

**Concretely for us:** this is exactly the shape of `rhythm_chug()` and
`fm_bass()` already (excitation → nonlinear stage → cab-sim comb filters →
mid-scoop EQ), but Gordon's version has more *parallel* paths recombined
with side-chain interaction, not one serial chain. When building the next
instrument, consider running 2-4 parallel `numpy` DSP chains (distortion
flavor A, distortion flavor B, echo/reverb-heavy path, feedback-loop path)
off the same source oscillator and mixing them, rather than one linear
chain — that parallelism is what gave his array its density and is
reproducible in code (multiple `sy.soft_clip`/`sy.bitcrush`/`sy.comb_filter`
branches summed, not chained).

## 3. Side-chain compression as *dynamic mix*, not static balance

The splitter on Gordon's array fed the parallel distortion chains' output
back as a side-chain trigger into each other's compressors, so "based on
whatever the input was doing, it could dynamically change the mix of...
each chain." His mini-amp feedback loop is the same idea at audio rate:
the feedback was small enough that any signal coming through the amp
would choke it out, and when the signal died the feedback swelled back in.

**Concretely for us:** none of the current `instruments.py` functions do
inter-layer side-chaining — layers are just gain-mixed
(`sy.mix_layers(..., gains=[...])`). A worthwhile new primitive: an
envelope-follower/ducking utility in `synth.py` so one layer's amplitude
modulates another's gain in real time (e.g. grit/noise layer swells only
when the tonal body decays), matching Gordon's "compressor releases when
the loud stuff goes away and lets the interesting stuff underneath poke
through" description of both the sub+white-noise ring-mod trick and the
amp-feedback loop.

## 4. Ring-modulate a sub with gated white noise to make it audible/aggressive

His literal recipe for getting a ~36.7Hz sub to read on consumer speakers:
white noise turned on/off (ring-modulated) at the sub's own fundamental
rate, mixed back with the sub, then driven through distortion together so
the two interact and generate new harmonics. He explicitly frames this as
ring modulation "at the audio frequency."

**Concretely for us:** this is a specific, cheap DSP recipe we don't have
yet. `kick()`'s "grit" layer (bandpassed noise soft-clipped and enveloped)
is adjacent but is *shaped by envelope*, not *ring-modulated by the sub's
own frequency*. Worth adding as an explicit `ring_mod(carrier, mod_freq)`
utility for sub-heavy layers (kick body, `fm_bass`) — literally
`noise * square(mod_freq)` before the shared distortion stage, per Gordon's
description.

## 5. Real acoustic/tape/hardware nonlinearity, not just DSP saturation math

Gordon's chunky guitar tone came from a real technique (Sean Beavan/Marilyn
Manson): record the guitar part an octave up and double speed onto tape at
30 ips, then play back at 15 ips through an overdriven preamp. His drone
layer was literally bowed guitar strings (detuned between C and C#) across
four octaves, multi-tracked and layered — "using guitars in an interesting
way to get that horror thing across," not a synth pad. His reel-to-reel
trick (feed it 40dB hotter than it can handle, record off it simultaneously)
is analog tape saturation, not a `soft_clip()` call.

**Concretely for us:** we're numpy/scipy-only (per `instruments.py`'s house
style — "same house style as the SFX bank -- pure numpy, offline rendering,
no external audio deps"), so we can't literally use tape or pedals. But the
lesson generalizes: model the *specific nonlinear physical process*, not a
generic waveshaper. `_karplus_strong()` already does this correctly (models
a struck/plucked string's physical decay rather than filtering noise) — the
`kick()`/`snare()` docstrings' repeated complaint that judges heard "808-style"
or "sterile drum-machine" from generic envelope+noise recipes is the same
failure mode Gordon is describing when he calls his first sine+distortion
attempt "not really amazing... I'm a guitar player, they've been doing that
exact thing for ten years" — i.e., recognize when a recipe is a cliché of
its genre and swap the generating model, not just the parameters.

## 6. Tune shared sound-design elements to the same root note as the music

Gordon's specific mix-philosophy claim, stated as something to plan for
*from the start*, not fix later: DOOM's triple chain-gun produces an
audible tone from its fire rate, so they deliberately tuned that rate to
land on D, matching the music's root. "If you can carve your sounds and
your music with that stuff in mind to begin with, you're going to end up
with a much tighter mix... it's not something you can fix in [Wwise] or
whatever you're using later on."

**Concretely for us:** if SFX (footsteps, weapon fire, enemy tells) in
`tools/soundgen` have an audible fundamental, that fundamental should be
chosen to match whatever key/root the current `melodies.py` material is in
for that scene, decided at design time — not EQ'd to avoid clashing after
the fact. Worth a shared "current key/root" convention passed between
`soundgen` and `musicgen` if one doesn't exist yet.

## 7. Punchy game-mix transients come from a *fast* attack into a *hard*
   compressor, tuned per-tempo — not from limiting

Gordon's answer to "how did you get such a punchy attack": side-chain
compressors set to a ~30ms attack (deliberately let the transient through
uncompressed), then a slow, heavily-pinned compressor at the end (~20dB
gain reduction) whose *release* he manually tuned to the track's tempo.
He adds: "transients are really the key to getting a really punchy
sounding game mix... if you've got just a solidly limited thing sitting in
the background it doesn't come through... those dynamics going
[transient]-then-gone... tricks the player's ear into believing there's
more solid music happening."

**Concretely for us:** current envelopes in `instruments.py` (e.g.
`kick()`'s final `soft_clip(x * 3.5)` → `lowpass`) don't have an explicit
transient-preserving compression stage tuned to a target tempo/release.
Worth adding a `sidechain_compress(signal, attack_ms=30, release_tempo_bpm=...)`
utility to `synth.py` so instrument layers keep sharp attacks instead of
getting smeared by whatever gain-staging/normalize step runs last.

## 8. Use the DSP process to hide intentional Easter eggs (image-to-audio,
   mono-fold phase tricks) — craft as narrative device, not just texture

Gordon loaded literal images (a "6" and a star) into a spectral synth
(Image-Line's Harmor) to imprint their shapes onto a bass part's spectrum,
visible only via spectrogram; and used a mid-side phase trick (info panned
hard to one channel, phase-flipped copy on the other) so a hidden sound only
resolves when a listener sums the track to mono. These aren't sound-design
flourishes, they're deliberate secrets ("Doom fans... [it's] the most
easily and cultic thing") consistent with the game's Satanic-imagery
storyline.

**Concretely for us:** this project's Catholic theme has an equivalent
opportunity — spectral/phase tricks that only reveal a hidden image, verse,
or motif under specific playback conditions (mono fold, spectrogram, or a
reversed-audio Easter egg) could be a genuinely on-brand craft technique,
not scope creep, if the director wants a hidden-liturgical-symbol layer
analogous to Gordon's hidden pentagram/star.

## 9. Guitars were reintroduced gradually and *validated against the game*,
   not the brief, once the process proved the brief wrong

The brief explicitly banned guitars ("no guitars, we hate guitars"). Gordon
kept the ban until the finished game *felt* like DOOM (movement, pacing)
but didn't *sound* like DOOM, diagnosed the gap as "no guitars," and only
then reintroduced them incrementally ("5% here, 10% there") using
non-standard guitar processing (octave-up/half-speed tape trick, 9-string
extended range, morphing guitar tone into the original chainsaw sample via
Synplant/Morph) specifically to avoid the "generic metal" sound the brief
was trying to avoid. He states explicitly: "sometimes you cannot do
everything [in a brief]... change the brief if it makes the project
better."

**Concretely for us:** treat the director's round-1 verdict ("parody of
what an AI thinks music sounds like") the same way Gordon treated "game
felt like DOOM but didn't sound like DOOM" — as a diagnosis to trace to a
missing *specific* element (as he traced it to "no harsh aggressive
guitar-like sound"), then reintroduce that element gradually and audition
it in the actual game context each step, rather than reworking the whole
palette from scratch or trusting an automated re-score.

## 10. A team culture of "comfortable in failure" is what let any of this
    happen — the encouraging note over the rejection

When Gordon sent id Software his first (ultimately-scrapped) sine+distortion
experiment, audio director Chris Hite's reply — "I feel you've taken the
first step on a journey toward the perfect destination, keep going, you're
almost there" — is what let him keep experimenting instead of reverting to
a safe default. Gordon's own framing: "confidence comes from doing the same
thing over and over again, it takes courage to change that." He also
describes id's "Weird Wednesday" jam sessions explicitly as a mechanism
for removing creative inhibition, with no tempo/key constraint, whose
purpose was building comfort with dead ends, not usable material.

**Concretely for us:** this is a process note, not a DSP one, but it's
actionable — round 2 should budget for visibly-failed intermediate
renders (the equivalent of Gordon's "GDC-speakers-can't-even-play-this sub
tone" demo) reviewed with the director without needing each one to be a
finished candidate, rather than only presenting fully mixed/normalized
candidates for pass/fail judgment.

---

### Not used / out of scope

Gordon spent real time on DOOM-specific integration (glory-kill music
ducking, "endless riser" Shepard-tone loops for indeterminate-length
events, killer-instinct-style combo-triggered remixing) that's a runtime
middleware/Wwise concern, not an offline-instrument-synthesis concern, so
it's omitted here — it belongs in `DYNAMIC_MUSIC_DESIGN.md` if this
project ever adds intensity-driven live remixing, not in
`instruments.py`.
