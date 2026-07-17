# PERIHELION Music Authoring Guide

**Audience:** the composer/audio artist authoring new music for PERIHELION's
dynamic music system. This document assumes solid music theory and no
familiarity with game-audio middleware or this codebase. Sibling document
`MUSIC_DESIGN.md` is the engine's internal design spec; this one is the
*authoring contract* — what you deliver, what the machine will do to it, and
which rules are enforced by build-time validators that reject non-conforming
audio.

Everything in here is extracted from the working engine
(`game/perihelion/music.py`), the bank builder (`tools/musicgen/tutti_bank.py`),
and seven shipped reference banks (`game/assets/music/album_*`). Numbers are
the actual constants in the code, not approximations.

---

## 1. The one-paragraph version

The music is the player character's inner state, rendered continuously. You
deliver a **bank**: one composition, cut into parallel **stems** (isolated
instrument-group renders of the *entire* piece), plus a small JSON file
describing the tempo and formal sections. At runtime the engine plays all
stems simultaneously, sample-locked, in one-bar chunks, and re-balances them
every bar according to three continuously-computed emotional values. It also
*steers the form* — looping the calm section during exploration, looping the
development section during ordinary fights, and pulling the playhead to the
peak section (led by a composed riser) when a boss engages. Your job is to
write music that remains musical under every combination of those gains and
every legal jump between sections.

If you know adaptive-audio terminology: this is simultaneous **vertical
remixing** (stem layers re-weighted continuously) and **horizontal
resequencing** (bar-quantized form jumps), in the lineage of LucasArts' iMUSE
— see §11 for references if these terms are new.

## 2. How the engine thinks: three values, not states

There is no "combat mode" or "explore mode." The engine computes three
continuous values in [0, 1] every tick from what the player character (the
Commando) is experiencing, and every mix decision is a function of them:

- **PRAYER** — contemplation, processing, the faith. The through-line. It has
  a floor (0.12) and *never stops*: the chant lane plays from level start to
  level end. Exactly one thing interrupts it: death (see §7).
- **CONTEMPT** — damage *output*. Driven by the player's trigger duty and
  kill flow. "Ass-kicking music": the dismissive groove.
- **STALWART** — danger *input*. Driven by what hunts the player: how many,
  what kind, how close, how fast they're arriving. "Boss music": doomed odds,
  hold the line.

These are **independent axes, and blends are the normal case**. A boss fight
is CONTEMPT *and* STALWART both high. Mowing trash is contempt alone. Being
hunted while unable to fight back is stalwart alone. Quiet exploration is
prayer near 1.0 with the other two near zero. Compose every stem knowing it
will be heard in blends, not solos.

The values are low-passed with a one-bar time constant so the music doesn't
wake for a two-second skirmish; genuine ambushes bypass the filter (§6,
"the slam").

## 3. How the engine plays audio: the mechanics that shape your writing

Understanding four mechanical facts will save you rework:

**1. Everything is one-bar chunks on a shared grid.** Every stem is sliced
into equal one-bar chunks. Each *lane* (see §4.1) is an audio channel playing
its stem's chunks back-to-back, sample-exact; the audio device itself is the
clock. All musical change — a different variant, a formal jump, silence — is
"which chunk gets queued for the next bar." Consequence: **every musical
event in your stems must be intelligible on a one-bar grid**, and anything
that must survive a cut (a sustained chord, a vocal phrase) needs the
protections described in §5 and §8.3.

**2. Gains change only at bar lines, per composed laws.** Lane volumes step
at heard bar boundaries. Rises are capped at +0.35/bar (a natural 2–3 bar
build) unless a genuine spike lands the full level in one bar; ordinary large
rises get a half-bar come-up ramp. Falls glide at ×0.65/bar, then one
farewell bar fading to zero — with one exception: **percussion exits clean on
the bar line**, no fade (an amplitude-fade on an active drum loop reads as a
DJ fader, not composition). The chant is slower still: once established it
rises ≤0.12/bar and falls ≤0.08/bar — swells and diminuendos, never lurches.
You do not author any of this; you author stems that sound good *under* it.

**3. The form is steered.** Your bank.json declares typed sections (§4.2).
At bar lines the engine may jump the playhead: loop the vigil in calm, loop
the develop band in ordinary fights, pull to the peak for bosses, come home
to the vigil after the mix has settled. All jumps land on section-start bars;
steering decisions are made only at bar lines and only from even bar
positions (half-phrase grain). Consequence: **every section must work as a
loop, and every section start must work as an arrival from anywhere.**

**4. The engine adds no processing.** No runtime reverb, no tempo-stretch,
no EQ. Stems play verbatim at the gains described. Bake every effect into
the render.

## 4. What you deliver: the bank

A bank is one folder:

```
album_<name>/
    bank.json          form metadata (required)
    prayer.wav         + ~30 stem renders (see table)
    ...
```

You author and deliver **WAV**; the build pipeline encodes to Ogg Vorbis for
shipping. Reference banks you can open right now:
`game/assets/music/album_dies_irae/` (shipped oggs) and `out/banks/album_dies_irae/`
(build wavs).

### 4.1 The stem list

Each stem feeds one **lane** — a named channel with its own gain law. Stems
marked *form-wide* must be full-length renders of the entire form (§5.1);
*one-shots* are short standalone files with their own lengths.

| File | Lane | Content | Sounds when |
|---|---|---|---|
| `prayer.wav` | holy | The chant: solo voice + choir + bells + a light drone halo. The through-line. | **Always.** Gain from PRAYER, floored by combat (§8.2), full-force "war chant" at peak danger. |
| `bed_t1..t4.wav` | bed | Drone/atmosphere spine, one per level tier (1 = early game … 4 = late). May be identical if the piece has one texture. | Always (gain 0.55–0.9, tracks prayer). |
| `stalwart.wav` | wall | The danger material: wall-of-sound guitars/riffs + low reinforcement. | STALWART > 0.03; gain ≈ √stalwart. |
| `contempt.wav` | groove | The swagger: driving bass machinery + flourishes. | CONTEMPT > 0.03; gain ≈ √contempt. |
| `drums.wav` | drums | The kit, full form. | Any combat; clean bar-line exit. |
| `drums_boss.wav` | drums | The *serious* kit (denser subdivision, crash grid). | Replaces `drums.wav` at stalwart ≥ 0.8 (hysteresis: reverts < 0.7). |
| `lead_<weapon>.wav` × 10 | lead/lead2 | The lead voice re-timbred per weapon: `pistol, smg, shotgun, rail, scrap, knife, lightning, gland, hole, tau`. Same line, different instrument/color. | Combat; weapon switches equal-power-crossfade two leads at 0.25/bar with a sticky 50/50 point — **two leads will sound together**, so re-voicings must be self-compatible. |
| `bass_<kind>.wav` × 7 | bass | A short ostinato cell per enemy kind, tiled over the form's harmony: `mite, husk, spitter, shrieker, brute, warden, flicker`. The dominant enemy kind selects which one plays. | Enemies engaged. Must live in the 40–180 Hz band (§5.4). |
| `overlay_boss.wav` | boss | Register expansion for bosses: sub-octave roots + octave pedal. | stalwart ≥ 0.88 only. |
| `riser.wav` | one-shot | ~2 bars: a large bell **reversed**, swelling into its own forward strike. Leads the boss peak-jump; the strike lands exactly on the peak downbeat. | Engine-scheduled (§6). |
| `riser_half.wav` | one-shot | Half-bar micro-version of the riser. The ambush slam's lead-in. | Engine-scheduled (§6). |
| `sting.wav` | one-shot | The boss-release cadence: the track's own choir singing a plagal ("Amen") cadence — subdominant sonority resolving to the home triad, through the hall. Must sound like the piece resolving itself, **never** like a sound effect. | Boss death. |
| `stab.wav` | one-shot | ~1.5 bars: a percussive boss hit (crash + kick + low tom in the reference banks). Unpitched or harmonically neutral — it repeats on the 4-bar grid over the peak, so any pitch content must sit in the peak's harmony. | Every 4 bars while a boss lives. |
| `prayer_tail.wav` | one-shot | Exactly 1 bar: the ringing release of the chant's final bar (what would sound if bar *n* were allowed to decay). Overlaid when the form wraps last-bar → bar 0. | Form wrap. |

**Hard-required:** `bank.json`, `prayer.wav`, `contempt.wav`, `stalwart.wav`
— the engine refuses to load a bank without them. Every other missing stem
silently degrades to silence in its slot (a missing `lead_rail.wav` means no
lead during rail fights), so treat the full table as the deliverable.

The pipeline can assist with the ×10 / ×7 mechanical renders: if you deliver
the lead line and bass cells as MIDI + a reference render, we can batch the
re-voicings, or you can render them yourself. Either way the *musical*
content (one lead line, seven cells) is authored once.

### 4.2 bank.json

One JSON object. Real example (`album_dies_irae`):

```json
{"melody": "dies_irae",
 "title": "Day of Wrath, Day of Rust",
 "bpm": 110.0,
 "bars": 36,
 "sections": [["vigil", 0, 8], ["entry", 8, 16], ["develop", 16, 24],
              ["peak", 24, 32], ["outro", 32, 36]]}
```

- `bpm`, `bars`, `sections` are **required**; the loader crashes on a bank
  without them (no defaults, by design).
- The bar length is defined as `240 / bpm` seconds — i.e. four quarter-notes
  at the stated tempo. Other meters are legal as long as every stem shares
  one constant bar duration and you state the `bpm` that makes
  `240/bpm` equal your bar length (e.g. a 3/4 bar at ♩=120 is 1.5 s, so
  declare `bpm: 160`). The engine only ever sees the bar grid.
- Sections are `[type, start_bar, end_bar)` — zero-indexed, half-open,
  inside `[0, bars)`. Cover the whole form; gaps are legal but inert.
- **Section types with engine meaning:**
  - `vigil` / `ritual` — the calm home. Looped while becalmed; the target of
    the post-fight homecoming.
  - `entry` — combat on-ramp; counts as combat material.
  - `develop` — the ordinary-fight loop. Any non-boss fight loops
    `[develop_start, develop_end)`. This section will be heard more than any
    other; give it internal variety and a seamless loop.
  - `peak` — boss material. The riser-led jump target; loops while the boss
    lives; the stab rides its 4-bar grid; `overlay_boss` and `drums_boss`
    sound here. "Save the really hard stuff for when it counts" — ordinary
    fights never walk into it.
  - Anything else (`outro`, `rebuild`, …) — legal labels, treated only as
    "not combat material": mid-fight the form will never stay there.
- A useful bank has at least one calm section, one `develop` (or `entry`),
  and one `peak`.

All seven shipped banks are 110 BPM, 32–36 bars (≈70–79 s of form).
**Recommendation: keep new banks at 110 BPM.** The engine rotates between
banks mid-level with a 2-bar crossfade that is not tempo-matched; a common
tempo keeps every handoff clean. (Rotation only happens at ~full PRAYER, so
it is the calm material of two banks that overlaps.)

### 4.3 Audio format

- WAV, **44,100 Hz**, 16-bit PCM (or 24-bit float source; the build writes
  16-bit), stereo. Mono is auto-duplicated but deliver stereo.
- Every form-wide stem in a bank must be **exactly the same sample length**:
  `bars × (240/bpm) × 44100` samples. The slicer builds one boundary table
  from the first file and applies it to all of them — a stem one bar short
  is sliced wrong, not rejected.
- One-shots (`riser`, `riser_half`, `sting`, `stab`, `prayer_tail`) are
  whatever length the gesture needs (`prayer_tail`: exactly one bar).
- Peak-normalize sensibly (the build normalizes anything over 0 dBFS), but
  **relative loudness between stems is part of the composition**: the engine
  applies the gain laws in §8.2 with no loudness compensation. Balance your
  stems against a reference bank — solo `out/banks/album_dies_irae/*.wav`
  in your DAW at equal fader and match perceived level per role.

## 5. The laws (build validators — these reject audio)

Each of these exists because its absence was heard, diagnosed, and ratified
as a rule. The delivery checker (`tools/musicgen/check_bank.py`, §9) runs
them all against a bank folder.

### 5.1 Form-wide stem law
The engine may raise any dynamic stem's gain at any bar of the form. So
every dynamic stem must carry content at **every** form position — the wall
stem needs its riffs through the vigil bars too, even though the album
arrangement would rest them there. (Think of stems not as "the album
multitrack" but as separate form-length renders of each material.) Sparse
content is legal only where the engine itself gates the lane: drums only
sound in combat, `overlay_boss` only at boss tier.

### 5.2 No silent stretches: the 2-bar rule
A texture stem (prayer, beds, wall, groove, drums, basses) may not sit
below **−15 dB relative to its own median bar RMS for 2 or more
consecutive bars**. One quiet bar is a breath; two is a dropout the engine
can't know about — it holds the lane "on" while nothing sounds, and
in-game that reads as the music breaking. A deliberate pianissimo above
the threshold is fine and protected (we learned not to "fix" composed
quiet). The **lead** stems are the exception: the lead is phrase material
and may rest between phrases (the reference leads rest 2 bars of every
4-bar cycle, with drums/wall/groove carrying underneath) — the checker
flags lead rests as warnings for a human ear, not errors.

### 5.3 Chant coverage: the bar-pair rule
Stricter, for `prayer.wav` only: **audible foreground vocal presence in
every 2-bar window of the form** — the sung voice, an answering distant
voice, or a choir statement; pad wash and bell halo do not count. Reason:
PRAYER never stops, and form loops revisit the same bars every ~25–50 s, so
a multi-bar vocal rest becomes a *periodic* "the chant died" defect. This
was the single worst bug class in the system's history. Compositional
techniques that satisfy it: antiphony (a distant second voice answering in
the rests — the reference banks do exactly this), overlapping phrase
entries, choir sustains under the soloist's breaths.

### 5.4 Register law (bass stems)
Each `bass_*` stem's energy must actually *sound* in the bass band: low
band (40–180 Hz) at least **3× the energy** of the lead band (180–1200 Hz).
The measurement is on the render, because the patch decides the sounding
octave, not the notation. (Percussive cells may need a steep lowpass to
comply; that's sound design, not cheating — the outcome is still measured.)

### 5.5 DC law
Every stem is high-passed at 10 Hz at build time and must show residual DC
offset ≤ 0.003 after it. A DC pedestal turns every bar-line gain step into
an audible click ("pops on every clip transition"). If your synth chain
emits DC (some FM patches do), high-pass before delivery. 10 Hz leaves
40 Hz sub-bass untouched.

### 5.6 Loop-tail law (the "FL trick")
Render every form-wide stem **one bar past the form end** so the
instruments' natural sustain exists, and deliver both: the build sums that
tail bar into bar 0 (level-capped at ~+1 dB over the stem's median bar), so
wraps and jumps landing on bar 0 carry the ringing release instead of a
hard cut. Exception: **prayer's tail is never baked** — it ships as the
separate `prayer_tail.wav`, because a baked tail plays a phantom second
voice whenever the form jumps to bar 0 from mid-form. A doubled pad release
is inaudible; a doubled monk is not. If you deliver exactly form-length
stems, the build simply skips the fold — legal, but bar-0 landings will be
drier.

### 5.7 Fail-fast philosophy
When any law is violated the build **crashes with the bar numbers**; nothing
warns-and-continues. A bank that builds is a bank that passed. This is
deliberate: silent degradation in this system historically shipped bugs the
instruments couldn't hear.

## 6. Punctuation is planned, never reactive

A causal engine cannot anticipate a fight, so a "play a hit when danger
spikes" design always lands its gesture *after* the moment it should have
led into. Punctuation therefore exists only where the engine knows the
future — and each piece of it is composed material from *your* palette, so
it sounds like the song, not like a sound effect:

- **The riser** fires in exactly one situation: the engine has decided to
  jump to the peak (boss engaged), holds the jump for the riser's 2-bar
  swell, and lands the jump as the reversed bell resolves into its forward
  strike — i.e. **your riser's strike is the peak section's downbeat**.
  Author them as one gesture. If the boss dies mid-swell the riser is
  fast-faded (a swell must never complete into nothing) — make sure it
  survives an early fade gracefully.
- **The slam** is the one exception to "rises are capped": a heavy enemy in
  contact after ≥2 s of true quiet, onto a calm mix — an ambush out of the
  dark, never a watched approach, never a normal fight. The engine plays
  `riser_half` (half-bar reversed-bell swell) into an instant full wall.
  The half-bar swell is what makes the cliff read as deliberate.
- **The sting** fires only at boss release (the moment the boss dies):
  heavy lanes take a one-bar comedown and the choir-amen cadence resolves
  the fight. Plagal motion in the track's own choir and hall won a blind
  ranking over every bell/impact variant precisely because it "resolves the
  tension using the track's own instrumentation."
- **The stab** rides the 4-bar grid while a boss lives — a recurring
  percussive exclamation over the peak loop.
- 8-bar cooldown between punctuations, as a backstop.

## 7. Death

HP ≤ 0 halts every channel **instantly**. No fade, no tail, no exception —
including the chant. The music is the Commando's mind; when he dies it
dies. Respawn starts a fresh performance from bar 0. (If you ever hear a
capture where the music hard-cuts to silence and later restarts from the
top: that is the law working, not a bug.)

## 8. Writing for the system: the craft notes

### 8.1 One melody, many time-scales
Every shipped bank derives all of its material from a single source melody
— old plainchant and hymnody, currently: *Dies irae*, *Idumea* (Sacred Harp
47b), *L'homme armé*, *Media vita*, Old 100th, *Pange lingua*, *Vexilla
regis* — treated as a cantus firmus: the monk sings it at chant pace, the
riffs are its diminutions at 16th-note speed, the leads its augmentations,
the choir states the head, the bass cells its incipit. This is the
Renaissance cantus-firmus/paraphrase-mass technique (Josquin's *Missa
L'homme armé* is literally the reference class) applied to industrial
metal. It is not a house style you must imitate — it is the *reason the
dynamic mixing works*: any subset of lanes at any gains is still "the
piece," because every lane is the same melody. Whatever material you write,
give the stems that property: **derive them from common material so that
arbitrary vertical subsets remain coherent.**

### 8.2 Dynamics belong to the engine; density belongs to you
The engine owns loudness dynamics (the gain laws). Your stems should be
relatively steady-state in *level* (within the §5.2 law) but can and should
vary in *density and register* across the form — that's what makes the
steered sections feel different. For calibration, the actual gain targets:
drums/lead `0.9·√combat`, groove `√contempt`, wall `√stalwart`, bed
`0.55 + 0.35·prayer`, bass `0.8·√(crowd)`, and the chant
`max(√prayer, 0.7·√combat, war-chant ramp)` capped at 0.85 — the chant as
"a defiant and *equal* voice" against the band, deliberately never riding
over it. Active lanes are floored around 0.4–0.5 so a live threat is never
subliminal.

### 8.3 The voice is sacred (material classes)
The hardest-won law in the system. Two classes of material:

- **Bar-sliceable**: drums, riffs, pads, basses, beds — anything that
  re-attacks at bar lines. The engine may cut, loop, and jump it freely.
- **Voices** (the monk; any legato solo performance): a recording of a
  human line cannot be entered mid-phrase, level-stepped mid-word, or
  spliced to itself. The engine has dedicated machinery for the chant —
  full-bar gain glides, a fading "tail voice" on every form jump (the bar
  the singer *would* have sung decays under the landing), the separate
  `prayer_tail` — but machinery only softens seams. You prevent them:
  - **Start a vocal phrase on every section-start bar.** Section starts are
    the only jump landings; a phrase-beginning there means a jump lands on
    a natural entrance instead of mid-melisma.
  - **Don't straddle section boundaries with a phrase**, especially the end
    of `develop` and the end of the form (both are loop points).
  - Compose the voice's stressed syllables onto chord tones of every
    harmony it can coincide with — the counterpoint must survive the form
    being reordered under it.
  - At peak STALWART the chant returns **in full force over the boss mix**
    (the "war chant" — the Commando's defiance made audible). Write the
    chant so it works as foreground counterpoint against your own peak
    section, not only against the calm bed.

### 8.4 Sections as loops and arrivals
Every section will loop (end → own start, seamlessly: no cadence at the
end that demands continuation, no pickup into the next section baked into
the last bar) and every section start will be arrived at cold from
anywhere in the form. Loop steers are seamless by design; genuine jumps get
a short arrival fade on the combat lanes — but never on the chant or the
bed, which must simply *work* across the cut.

### 8.5 Licensing
Every sample, instrument, and preset in a delivered stem must be cleared
for commercial redistribution in rendered form, and every source goes in
`tools/musicgen/SOURCES_LICENSES.md` (name, origin, license, what it's
allowed for). "Free for commercial use in renders, instrument itself not
redistributable" is fine (we ship renders); "non-commercial" is not.
Public-domain source melodies (plainchant, 18th-c. hymnody) are safe;
modern *arrangements* of them are copyrighted — work from the tune, not
from someone's edition.

## 9. Delivery and verification workflow

1. **Author** against a reference bank (open `out/banks/album_dies_irae/`
   in your DAW; every stem is a plain WAV on the same grid).
2. **Self-check**: `uv run python tools/musicgen/check_bank.py <folder>`
   runs every §5 validator plus the format contract and prints a per-stem
   report. Errors mean the engine will misbehave; fix before sending.
3. **We integrate**: the bank goes through the build (fold, encode, ship)
   and into a real recorded gameplay session.
4. **Verification is in-situ**: we render actual play — calm → skirmish →
   boss → release → death — and audition every state transition, plus
   blind A/B judging on specific moments. You'll get timestamped video
   with a debug overlay showing the live values and per-lane gains, so
   you can hear exactly what the engine did to your material and why.
5. The director's ear is the final instrument.

## 10. Glossary

| Term | Meaning here |
|---|---|
| **bank** | One composition's folder: stems + bank.json. The unit you deliver. |
| **stem** | A full-form render of one material group (one WAV). |
| **lane** | The runtime channel a stem plays on, with its own gain law. |
| **chunk** | One bar of one stem; the atomic unit of playback. |
| **form / section** | The bar timeline and its typed regions (vigil/entry/develop/peak/…). |
| **steering** | The engine relocating the playhead at bar lines (loops and jumps). |
| **value battery** | The heuristics computing PRAYER/CONTEMPT/STALWART from game state. |
| **through-line** | A lane that never stops (holy, bed). Exempt from arrival fades. |
| **riser / sting / stab / slam** | The four punctuation gestures (§6). |
| **war chant** | The chant at full force over the boss mix at peak danger. |
| **fold / loop tail** | The extra sustain bar summed into bar 0 (§5.6). |
| **vertical remixing** | Re-weighting simultaneous layers of one piece (what the gains do). |
| **horizontal resequencing** | Reordering sections of one piece in time (what steering does). |
| **dBFS / RMS / DC offset** | Digital level references — see §11 if unfamiliar. |

## 11. References

Adaptive game music (the field this system lives in):
- Michael Sweet, *Writing Interactive Music for Video Games: A Composer's
  Guide* (Addison-Wesley, 2014) — the standard text; ch. on vertical
  layering and horizontal resequencing map directly onto §3.
- Winifred Phillips, *A Composer's Guide to Game Music* (MIT Press, 2014).
- Karen Collins, *Game Sound* (MIT Press, 2008) — history and theory.
- iMUSE (LucasArts, 1991) — the ancestor of all form-steering engines:
  https://en.wikipedia.org/wiki/IMUSE

Source-melody and counterpoint background:
- Cantus firmus and paraphrase technique: any counterpoint text (Fux,
  *Gradus ad Parnassum*, 1725, for the species framework); for the mass
  tradition see https://en.wikipedia.org/wiki/L%27homme_arm%C3%A9
- The shipped melodies: *Dies irae* (plainchant sequence), *Idumea*
  (Charles Wesley / Ananias Davisson, Sacred Harp 47b), *Media vita in
  morte sumus* (antiphon), *Pange lingua gloriosi* (Aquinas), *Vexilla
  regis* (Venantius Fortunatus), Old 100th (Genevan Psalter) — all on
  Wikipedia and hymnary.org with sources.
- Plagal ("Amen") cadence: https://en.wikipedia.org/wiki/Cadence#Plagal_cadence

Digital-audio basics (if needed):
- dBFS: https://en.wikipedia.org/wiki/DBFS
- DC offset and why it clicks: https://en.wikipedia.org/wiki/DC_bias
- RMS level: https://en.wikipedia.org/wiki/Root_mean_square

Internal (for the curious): `MUSIC_DESIGN.md` (engine design + the reasons
behind every law), `game/perihelion/music.py` (the engine),
`tools/musicgen/tutti_bank.py` (the build and validators).
