# PERIHELION Music — The Brief, Expanded

For the composer. No game-dev or code knowledge is assumed; music theory
is. This reads top-down like a tree walk: the job, then what the job
requires, then what *those* require, until it bottoms out in exactly which
audio goes in which file. Numbers in here are the real constants the
machine enforces, not vibes.

---

## 0. The brief

**Write a track the game can perform.** PERIHELION's music is not a
looping soundtrack — the game holds your track on three invisible faders
and an arranger, and *plays* it, live, following the fight. Concretely,
the game:

- runs **all your stems at once**, sample-locked, and rides their levels
  continuously (think vertical stem mixing, automated by gameplay);
- **rearranges the form** on bar lines — loops your calm section while the
  player explores, loops your development section through ordinary fights,
  jumps to your peak for bosses (horizontal resequencing);
- drops your composed **punctuation one-shots** (riser, sting, stab) at
  moments it schedules itself.

What you deliver is a **bank**: one folder containing one piece of music,
printed as isolated full-length stems, five one-shots, and one small
metadata file. The soundtrack today is seven banks of industrial metal
built on plainchant and hymn tunes at 110 BPM (*Dies irae*, *L'homme
armé*, *Idumea*…). Open one — every stem is a plain WAV/OGG on the same
grid, and Appendix B walks you through it.

**The job, as a tree** (each node is a section below):

```
Deliver a bank  —  out/banks/album_<yourtrack>/
├── 1. COMPOSE  one piece that plays in zones
│     ├── 1.1  one form, four zones (calm / fight / boss / connective)
│     ├── 1.2  the grid: tempo, meter, bar count
│     ├── 1.3  one melody at every time-scale (why remixing works)
│     ├── 1.4  the voice: the chant's special rules
│     └── 1.5  write density, not dynamics
├── 2. PRINT    the stems (isolated full-form renders)
│     ├── 2.1  the track sheet: every file, its role, when it's heard
│     ├── 2.2  rules for every stem (format, length, tail, DC)
│     └── 2.3  rules for specific stems (silence, register, coverage)
├── 3. PRINT    five one-shots (riser, riser_half, sting, stab, prayer_tail)
├── 4. WRITE    bank.json (the form, on paper)
└── 5. VERIFY   check it, hear it in context, deliver it
      ├── 5.1  check_bank — the pre-flight checklist
      ├── 5.2  the session DAW — scrub a real winning run of the game
      ├── 5.3  the live rig — perform the engine by hand
      └── 5.4  delivery + licensing

Appendix A — the playback rules (what the machine does to your audio)
Appendix B — guided tour of a shipped bank
Appendix C — glossary + reading
```

**Your working loop** — the whole gig in one cycle:

```
compose/edit in your DAW
      │  bounce stems
      ▼
out/banks/album_<yourtrack>/            (your bank folder)
      │
      ▼
uv run python tools/musicgen/check_bank.py out/banks/album_<yourtrack>
      │  errors? fix and re-bounce (each error names the file + bars)
      ▼
audition:  daw.py   — your bank driven by a real full playthrough
           instrument.py — you drive the three faders by hand
      │  overwrite a stem file → the tools re-mix in ~1s → listen again
      ▼
deliver (the folder is the deliverable)
```

---

## 1. COMPOSE — one piece that plays in zones

### 1.1 One form, four zones

Your piece is one continuous form (the shipped banks are 32–36 bars,
~70–80 seconds) divided into typed **sections**. The game's arranger
treats each type differently, so each has a job:

| Section type | Job in the game | Composition requirements |
|---|---|---|
| `vigil` or `ritual` | The calm home. Loops during exploration; the music "comes home" to it after every fight. | Must loop seamlessly (end flows into own start). Will be heard a lot, quietly. |
| `entry` | Combat on-ramp. | Counts as fight material; transitional writing is fine. |
| `develop` | **The fight loop.** Every ordinary fight loops this section, start to end, over and over. | The most-heard bars you'll write. Needs internal variety AND a seamless loop. No cadence at the end that begs continuation — the end *is* the pickup to its own start. |
| `peak` | Boss material. The arranger jumps here (led by your riser) when a boss engages, and loops it while the boss lives. | Your heaviest writing. Must loop; must land like a downbeat arrival (see §3, riser). |
| anything else (`outro`, …) | Connective tissue. The arranger passes through it in calm, never parks a fight there. | Free. |

Two structural rules, because the arranger cuts on bar lines:

- **Every section must work as a loop** — the arranger will repeat any of
  them indefinitely.
- **Every section-start bar must work as a cold arrival** from anywhere in
  the form. Section starts are the only landing points of jumps.

### 1.2 The grid

- **A "bar" to the machine is `240 / bpm` seconds** — four quarter-notes
  at your stated tempo. All slicing, looping, and jumping happens on this
  grid. Other meters are fine as long as one constant bar duration holds
  for the whole piece and you declare the bpm that makes `240/bpm` equal
  your bar length (a 3/4 bar at ♩=120 is 1.5 s → declare bpm 160).
- **Keep new banks at 110 BPM** unless we agree otherwise. The game
  rotates between banks mid-level with a crossfade that is not
  tempo-matched; a shared tempo keeps every handoff musical.
- 32–36 bars is the proven size. Longer is legal; nothing under ~24 bars
  will give the arranger enough room.

### 1.3 One melody at every time-scale

Every shipped bank derives **all** of its material from a single source
melody treated as a cantus firmus: the monk sings it at chant pace, the
riffs are its 16th-note diminutions, the leads its augmentations, the
choir states the head, the bass cells its incipit. This is the
Renaissance cantus-firmus mass technique (Josquin's *Missa L'homme armé*
is literally our reference class) applied to industrial metal.

This is not a style handcuff — it is **the reason the dynamic mixing
works**. The game will play arbitrary vertical subsets of your stems at
arbitrary balances, and any subset must still sound like the piece.
Deriving every part from common material is the known way to get that
property. However you achieve it: **any combination of your stems, at any
levels, must be coherent.** Audit your own mix in your DAW by soloing
random subsets — that's precisely what the game will do to it.

Source melodies so far are public-domain plainchant and hymnody, which
also keeps licensing trivial (§5.4). Picking the next melody is a
conversation with the director, not a unilateral choice.

### 1.4 The voice — the chant's special rules

The chant (`prayer` stem: solo voice + choir + bells + a light halo) is
the game's through-line. It plays from level start to level end — the
*only* thing that ever silences it is the player's death. That standing
exposure earns it the strictest rules in this document:

- **Start a vocal phrase on every section-start bar.** Jumps land there;
  a phrase-beginning means a jump lands on a natural entrance instead of
  mid-melisma. (The engine has seam machinery — it finishes a cut phrase
  under the landing as a fading tail — but machinery softens seams; your
  phrasing prevents them.)
- **Never straddle a loop point with a phrase**: the end of `develop`
  wraps to its own start, and the end of the form wraps to bar 0.
- **The voice may rest at most one bar at a time, anywhere in the form**
  (the "bar-pair rule", checked mechanically: audible foreground vocal
  presence in every 2-bar window — pad wash and bell halo don't count).
  Why: the arranger revisits the same bars every 25–50 s, so a 3-bar rest
  becomes a *periodic* "the singer died" defect in-game. This was
  historically our worst bug class. Ways to satisfy it musically:
  antiphony (a distant second voice answering in the rests — the shipped
  banks do this), overlapping phrase entries, choir sustains under the
  soloist's breaths.
- **Write the stresses onto chord tones of every harmony they can meet.**
  The form gets reordered under the voice; its counterpoint must survive
  the reordering.
- **The war chant**: at maximum danger the chant comes back *in full
  force over the boss mix* — a defiant, equal voice against your own peak
  section (capped just below the band; it rides with, never over). Write
  the voice so it works as foreground counterpoint against the `peak`
  bars, not only against the calm bed.

### 1.5 Write density, not dynamics

The game owns loudness: it rides every fader continuously (the actual
laws are in Appendix A). If you print a big composed crescendo into a
stem, it will fight the game's own automation. So:

- Keep each stem's **level** roughly steady across the form (composed
  quiet is fine down to the limits in §2.3).
- Put the drama in **density and register**: the `peak` bars of a stem
  should be busier/thicker than its `vigil` bars, not just louder. That's
  what makes the steered sections feel different while the faders stay
  honest.
- **Balance between stems is composition**: the game applies no loudness
  compensation. Solo the shipped `album_dies_irae` stems at unity in your
  DAW and match your stems' perceived levels role-for-role against them.

---

## 2. PRINT — the stems

A stem here = one **full-length render of the entire form** with only one
material group sounding. Not a section bounce: the game may open any
stem's fader at any bar, so every stem must carry its material at every
bar (exceptions below are marked). Yes, that means your wall-of-guitars
stem has riffs running through the calm bars — the game just won't open
that fader until there's a fight.

### 2.1 The track sheet

Every file, its musical role, and when the game opens its fader.
**Bold** = the bank won't load without it.

| File | Role | Heard when |
|---|---|---|
| **`prayer.wav`** | The chant: voice + choir + bells + light halo (§1.4). | Always. Full in calm, carried as counterpoint through fights, full-force war chant at peak danger. |
| `bed_t1.wav` … `bed_t4.wav` | Drone/atmosphere spine, one per game act (1 = early, 4 = late). Identical files are fine if the piece has one texture. | Always, moderately; swells with calm. |
| **`stalwart.wav`** | The danger material: the wall — riff wall, low reinforcement. "Things are hunting you." | Rises with danger. ≈ full in any serious fight. |
| **`contempt.wav`** | The swagger: driving machine groove, flourishes. "You're winning." | Rises with the player's damage output. |
| `drums.wav` | The kit, full form. | Any combat. Drums cut *clean* on bar lines when fights end — never faded. |
| `drums_boss.wav` | The serious kit: denser subdivision, crash grid. | Swaps in for `drums.wav` during boss-grade danger. |
| `lead_pistol.wav` `lead_smg.wav` `lead_shotgun.wav` `lead_rail.wav` `lead_scrap.wav` `lead_knife.wav` `lead_lightning.wav` `lead_gland.wav` `lead_hole.wav` `lead_tau.wav` | One lead line, re-voiced per weapon (same line, ten timbres — the player's weapon picks the color). | Combat. Weapon swaps crossfade two of these *against each other*, and alternating weapons parks **both** on at half power — the re-voicings must sound good layered. |
| `bass_mite.wav` `bass_husk.wav` `bass_spitter.wav` `bass_shrieker.wav` `bass_brute.wav` `bass_warden.wav` `bass_flicker.wav` | A short bass ostinato cell per enemy species, tiled over the form's harmony. The dominant enemy in the fight picks which one plays. | Enemies engaged. Must genuinely live in the bass register (§2.3). |
| `overlay_boss.wav` | Register expansion for bosses only: sub-octave roots, octave pedal. | Boss engagements only. |
| The five one-shots | §3. | Scheduled moments. |
| **`bank.json`** | §4. | — |

A missing optional stem doesn't break anything — its fader just opens
onto silence (a missing `lead_rail.wav` = no lead during rail fights).
Treat the full sheet as the deliverable.

The ten leads and seven basses are seventeen mechanical re-renders of two
musical ideas (one line, seven cells). Author the ideas; if re-voicing
seventeen renders by hand is a poor use of your time, deliver the lead
line and bass cells as MIDI + one reference render each and we'll batch
the rest — your call.

### 2.2 Rules for every stem

These are enforced by the pre-flight checker (§5.1); numbers are exact.

- **Format**: WAV, 44,100 Hz, 16- or 24-bit, stereo. (We transcode for
  shipping; you never deliver lossy.)
- **Length**: every form stem in the bank must be *sample-identical* in
  length: `bars × (240/bpm) × 44100` samples. The slicer cuts all stems
  on one shared grid; a stem one bar short gets sliced wrong, not
  rejected.
- **The tail bar** (recommended): render each form stem **one bar past
  the form end** so the final release/ring exists, and deliver that
  form+1-bar file. The build folds the extra bar into bar 0 (level-capped
  so bar 0 doesn't bloat), which is what makes loop-wraps ring instead of
  chopping. Deliver exactly form-length and it still works, just drier at
  the wrap. Exception: `prayer` — never bake its tail; it ships
  separately as `prayer_tail.wav` (§3), because a baked vocal tail plays
  a phantom second singer whenever the arranger jumps to bar 0 mid-form.
  A doubled pad release is inaudible; a doubled monk is not.
- **No DC offset**: high-pass at 10 Hz if your chain emits any (some FM
  patches do). The machine steps faders on bar lines, and a DC pedestal
  turns every step into an audible click. Residual DC above 0.003
  (full-scale = 1) fails the check. 10 Hz leaves 40 Hz sub untouched.
- Peak below full scale; exact peak level is not critical (relative
  balance is — §1.5).

### 2.3 Rules for specific stems

- **The 2-bar silence rule** (texture stems: `prayer`, `bed_*`,
  `stalwart`, `contempt`, `drums*`, `bass_*`): the stem may not sit below
  **−15 dB relative to its own median bar** for 2+ consecutive bars. One
  quiet bar reads as a breath; two reads as the music breaking, because
  the game may be holding that fader open. Composed pianissimo above the
  threshold is fine and deliberately protected — the check flags
  dropouts, not soft bars.
- **Leads are exempt from that rule**: the lead is phrase material and
  may rest between phrases (the shipped leads rest 2 bars of every 4-bar
  cycle; drums/wall/groove carry underneath). The checker flags lead
  rests as warnings for your ear, not errors.
- **`prayer` is stricter than the 2-bar rule**: the bar-pair vocal
  coverage rule of §1.4. The mechanical check runs on the composite stem
  and can be fooled by a loud halo — the real test is your ear on the
  isolated stem: *is a voice singing in every 2-bar window?*
- **`bass_*` must measure bassy**: energy 40–180 Hz at least **3×** the
  energy 180–1200 Hz, measured on the render. The patch decides the
  sounding octave, not the MIDI note — if a cell reads mid-forward,
  drop it an octave or low-pass it until it measures right.

---

## 3. PRINT — the five one-shots

These are the game's punctuation, and the standing law is: **punctuation
must sound like part of the song, never like a sound effect laid over
it.** Each is cut from your own palette. Own lengths (they're not on the
form grid), same format rules as §2.2.

| File | Length | What it is | When the game fires it |
|---|---|---|---|
| `riser.wav` | ~2 bars | A swell that resolves into its own strike — ours is a big chapel bell *reversed into its forward strike*. The strike instant is the file's climax. | Leading every boss entrance: the game decides to jump to `peak`, holds the jump for your riser's 2-bar swell, and lands the jump **as the strike hits**. Your riser's strike = the peak section's downbeat. Compose them as one gesture. If the threat dies mid-swell the riser is faded early — make sure it survives an early fade. |
| `riser_half.wav` | ~½ bar | A micro version of the same swell gesture. | Only on a true ambush (a heavy hitting from real silence): a half-bar swell into an instant full mix. The swell is what makes the cliff read as intent. |
| `sting.wav` | a few seconds | The release cadence. Ours: the track's own choir singing a plagal ("Amen") cadence — subdominant sonority resolving to the home triad, in the hall. Won blind listening against every percussive/bell variant precisely because it *resolves* the fight in the piece's own voice. | The moment a boss dies. Heavy faders take a one-bar comedown underneath it. |
| `stab.wav` | ~1.5 bars | A percussive exclamation — crash + kick + low tom in the shipped banks. Unpitched or harmonically neutral: it repeats, so any pitch must sit inside `peak`'s harmony. | Every 4 bars while a boss lives, on the grid, over your looping peak. |
| `prayer_tail.wav` | exactly 1 bar | The chant's final-bar release: what would ring out if the last bar were allowed to decay. Print it by letting your `prayer` render run one bar past the end and bouncing that overhang bar alone. | Overlaid whenever the form genuinely wraps last-bar → bar 0, so the chant's loop breathes instead of cutting. |

---

## 4. WRITE — bank.json

One small JSON file describing the form. Real example, shipped:

```json
{"melody": "dies_irae",
 "title": "Day of Wrath, Day of Rust",
 "bpm": 110.0,
 "bars": 36,
 "sections": [["vigil", 0, 8], ["entry", 8, 16], ["develop", 16, 24],
              ["peak", 24, 32], ["outro", 32, 36]]}
```

- `bpm`, `bars`, `sections` are required — the game refuses a bank
  without them, on purpose (no silent defaults anywhere in this system).
- `bpm` defines the bar grid: bar seconds = `240 / bpm` (§1.2).
- Sections are `[type, first_bar, end_bar)` — counting from 0, end
  exclusive, like DAW locators. Cover the whole form. Section types and
  their obligations: §1.1. A useful bank has at least one calm section,
  one `develop` (or `entry`), and one `peak`.
- `melody` and `title` are labels (the title shows in our tools).

---

## 5. VERIFY — check it, hear it in context, deliver it

Your bank folder is `out/banks/album_<yourtrack>/` in the project
checkout you've been given. All three tools below read it in place —
edit, bounce, re-run, no import step. All are run from the project root.

### 5.1 Pre-flight: check_bank

```
uv run python tools/musicgen/check_bank.py out/banks/album_<yourtrack>
```

Runs every mechanical rule in §2–§4 against your folder and prints a
per-file report — errors name the file, the bars, and the rule. Errors
mean the game will misbehave; warnings are judgment calls flagged for
your ear. The seven shipped banks pass with zero errors; yours should
too before you send it.

### 5.2 Hear it in the game: the session DAW

```
uv run python tools/musicgen/daw.py --use album_<yourtrack>
```

This opens a DAW-style project window on a **real, complete winning run
of the game** (10:50, all four bosses, recorded decision-by-decision) —
with *your bank* as the score. Everything you'd expect from a project
window:

- **Transport**: SPACE plays/pauses; click or drag anywhere in the
  timeline to seek/scrub; arrow keys nudge by a bar (shift = 10 s).
- **Video monitor**: the actual gameplay frame at the playhead, so you
  hear your music against what the player was doing.
- **Ruler**: section colors and bank-change flags along the top.
- **Automation lane**: the three game faders (PRAYER / CONTEMPT /
  STALWART — calm / winning / danger) as curves. Where they move is
  where your mix will move.
- **Track strips**: one per stem lane, showing each bar's clip and fader
  level. **M/S** boxes mute/solo tracks — the remix takes about a
  second.
- **Markers**: boss risers ▲, ambush slams, stings ●, form jumps, and
  (in recordings where the player dies) red death-halt lines.

**The replace-and-hear loop**: the window watches your bank folder.
Overwrite any stem file — bounce a new `prayer.wav` straight from your
DAW onto the old one — and the session re-mixes in ~1–2 s *at the same
playhead*. Scrub back, listen, bounce again. A WAV dropped next to an
OGG of the same name wins, so you can audition a replacement without
deleting anything. (If you change a file and hear nothing change, check
the status line — it warns if the file you touched is shadowed by
another copy the game reads first.)

Run it with no arguments to hear the current shipped soundtrack in the
same window.

### 5.3 Play the engine yourself: the live rig

```
uv run python tools/musicgen/instrument.py
```

The performance view: the real in-game engine, live, with you as the
fight. Pick your bank from the list, then drive it — the three faders
by hand (press **M** for manual), or set up an actual encounter (add
enemies, pick the player's weapon, fire on the beat) and let the game's
own logic move the faders. This is the fastest way to *feel* the rules
in Appendix A: push STALWART past boss level and hear your riser lead
the peak jump; drop it and hear your sting resolve the fight; press
**R** after replacing a stem file to hear the new render in place.

### 5.4 Delivery + licensing

- The folder is the deliverable: all stems + one-shots + `bank.json`,
  passing check_bank, auditioned by you in the session DAW.
- After delivery we run it through the build (which re-verifies
  everything, folds tails, transcodes) and render real recorded
  gameplay with it; final sign-off is the director's ear on those
  sessions. Expect timestamped feedback against the same winning run
  you auditioned.
- **Licensing**: every sample, instrument, and preset in your renders
  must be cleared for commercial redistribution *in rendered form*, and
  each source gets a line in our source ledger (name, origin, license).
  "Free to use in commercial renders, instrument itself not
  redistributable" is fine — we ship renders. "Non-commercial" is not.
  Public-domain source melodies (plainchant, 18th-century hymnody) are
  safe; modern *editions and arrangements* of them are copyrighted —
  work from the tune, not from someone's engraving.

---

## Appendix A — the playback rules

What the machine actually does to your audio. You don't implement any of
this; you write music that stays musical under it.

**The three faders.** The game continuously computes three values from
what the player is experiencing, each 0–1, and every mix move follows
them: **PRAYER** (calm/contemplation — the through-line, never fully
zero), **CONTEMPT** (the player dealing damage — the groove rides it),
**STALWART** (the player being hunted — the wall rides it). They are
independent axes and blends are the normal case: a boss fight is
contempt AND stalwart high at once. There are no discrete "modes."

**The bar grid is absolute.** All stems play sample-locked in parallel;
every change — fader steps, form jumps, variant swaps — lands exactly on
bar lines. One consequence you'll hear: anything that must survive a cut
needs to make sense at a bar boundary.

**Fader laws.** Rises are shaped (max ~+0.35/bar — a natural 2–3-bar
build; sudden real threats can wall in within a bar; big rises get a
half-bar come-up). Falls glide (×0.65 per bar, then a one-bar farewell
fade). Percussion never fades out — drums exit clean on the bar line.
The chant moves slowest of all (≤0.12/bar up, ≤0.08/bar down once
established): swells and diminuendos, never lurches. Active lanes are
floored around 0.4–0.5 — a live threat is never subliminal. Approximate
targets, for calibration: drums/lead ≈ 0.9·√fight, groove ≈ √contempt,
wall ≈ √stalwart, bed ≈ 0.55 + 0.35·prayer, chant ≈ max(√prayer,
0.7·√fight, war-chant) capped at 0.85 — deliberately an *equal* voice,
never riding over the band.

**The arranger.** At bar lines the playhead may steer: loop `develop`
through ordinary fights (never wandering into calm or `peak` material
mid-fight), pull to `peak` for bosses — always led by your 2-bar riser,
landing on the strike — loop `peak` while the boss lives (your stab on
the 4-bar grid), and come home to `vigil` only after the fight has
audibly exhaled. Loop steers are seamless; true jumps get a short
arrival fade on the combat lanes only — never on the chant or the bed.

**Punctuation is scheduled, never reactive.** The game fires your
one-shots only where it knows the future (its own scheduled jumps, a
boss's death, a genuine ambush) — a reactive hit would always land
after the moment it should have led. Details per one-shot: §3.

**Bank rotation.** During long calm stretches the game hands off between
banks (~every 95 s) with a 2-bar crossfade, calm material into calm
material. This is why a shared tempo across banks matters (§1.2).

**Death.** Player dies → every channel halts instantly. No fade,
including the chant — the music is the player character's mind, and it
dies with him. Respawn restarts the performance from bar 0. If you hear
a hard cut to silence in a session: that one's the law, not a bug.

**Nothing is added.** No runtime reverb, EQ, tempo-stretch, or
humanizing. Stems play verbatim at the levels above. Bake everything.

## Appendix B — guided tour of a shipped bank

Open `out/banks/album_dies_irae/` (WAVs) in your DAW; line everything up
at 0:00, 110 BPM. It's *Day of Wrath, Day of Rust* — 36 bars: vigil
0–8, entry 8–16, develop 16–24, peak 24–32, outro 32–36.

Things worth soloing:

- `prayer.wav` — hear the bar-pair rule in practice: the solo voice
  phrases, and where it breathes for more than a bar, a distant answer
  or choir covers. Note phrase entrances at bars 0, 8, 16, 24.
- `stalwart.wav` vs `contempt.wav` — the same melodic DNA as wall and as
  swagger; play them together at various balances (the game will).
- `drums.wav` through the vigil bars — the kit is *there* (form-wide
  rule) even though the game keeps its fader shut in calm.
- Two or three `lead_*.wav` files layered — this is what a weapon-switch
  fight sounds like; the re-voicings are designed to stack.
- `bass_warden.wav` vs `bass_mite.wav` — same harmonic slots, different
  menace per species.
- `riser.wav` into bar 24 of the full mix — the reversed bell resolving
  onto the peak downbeat. That splice is exactly what the game performs
  at every boss entrance.

## Appendix C — glossary + reading

| Term | Here it means |
|---|---|
| bank | One track's folder: stems + one-shots + bank.json. The deliverable. |
| stem | A full-form render of one material group. |
| lane / fader | The runtime channel a stem plays on, and its game-ridden level. |
| section | A typed span of bars in your form (`vigil`, `develop`, `peak`…). |
| arranger / steering | The game relocating the playhead between sections on bar lines. |
| PRAYER / CONTEMPT / STALWART | The three game faders: calm / dealing damage / being hunted. |
| through-line | Material that never stops: the chant and the bed. |
| riser · sting · stab · slam | The punctuation gestures (§3). |
| war chant | The chant at full force over the boss mix at peak danger. |
| the 2-bar rule | No texture stem below −15 dB (rel. its median bar) for 2+ bars (§2.3). |
| bar-pair rule | A voice audibly singing in every 2-bar window of `prayer` (§1.4). |
| tail bar / fold | The extra rendered bar of ring, folded into bar 0 (§2.2). |

Reading, if any of the concepts above are new:

- Vertical remixing / horizontal resequencing: Michael Sweet, *Writing
  Interactive Music for Video Games* (Addison-Wesley 2014); Winifred
  Phillips, *A Composer's Guide to Game Music* (MIT Press 2014); the
  ancestor system is LucasArts' iMUSE —
  https://en.wikipedia.org/wiki/IMUSE
- Cantus firmus / paraphrase technique: any counterpoint text (Fux,
  *Gradus ad Parnassum*); https://en.wikipedia.org/wiki/L%27homme_arm%C3%A9
  for the mass tradition we're riffing on.
- The shipped melodies: *Dies irae*, *Idumea* (Sacred Harp 47b), *Media
  vita*, *Pange lingua*, *Vexilla regis*, Old 100th — Wikipedia and
  hymnary.org have sources and tunes.
- Plagal ("Amen") cadence:
  https://en.wikipedia.org/wiki/Cadence#Plagal_cadence
- DC offset (why it clicks): https://en.wikipedia.org/wiki/DC_bias
