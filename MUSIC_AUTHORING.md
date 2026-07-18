# PERIHELION Music — The Brief, Expanded

For the composer. No game-dev or code knowledge is assumed; music theory
is. This reads top-down like a tree walk: the job, then what the job
requires, then what *those* require, until it bottoms out in exactly which
audio goes in which file. Exact numbers in here are the real constants
the machine enforces; anything marked "~" is a creative target, not a
check.

---

## 0. The brief

**Write a track the game can perform.** PERIHELION's music is not a
looping soundtrack — the game holds your track on a rack of faders
driven by three continuously-computed state values, plus an arranger (a
piece of software, not a person — it re-orders your form live), and
*plays* it, following the fight. Concretely, the game:

- runs your stems on **one shared sample-accurate transport** (every
  stem stays phase-aligned forever) and rides their levels
  continuously. Not every file sounds at once — families like the ten
  leads or seven basses are *variants*, with one (sometimes two)
  selected at a time; what's always true is that whatever sounds is
  locked to the same grid. Game audio calls the level-riding *vertical
  remixing*: the piece gets more or less intense by re-balancing
  simultaneous layers of itself, never by switching tracks;
- **rearranges the form** on bar lines — loops your calm section while the
  player explores, loops your development section through ordinary fights,
  jumps to your peak for bosses. That one is *horizontal resequencing*:
  intensity by re-ordering sections of one piece in time. This system
  does both at once;
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
           instrument.py — you drive the three values by hand
      │  overwrite a stem file → the tools re-mix in ~1s → listen again
      ▼
deliver (the folder is the deliverable)
```

### 0.1 Logistics and scope (what is NOT in this document)

- **The director is your point of contact** for everything creative that
  this document defers ("a conversation with the director"): the source
  melody pick, sonic references, sign-off. Contact details, deadline,
  rate, and revision rounds are in your engagement terms, not here —
  this is the technical and musical brief only.
- **Sonic reference**: the seven shipped banks *are* the production
  reference — tone, drum character, mix density. For a faders-up first
  listen before you dig into raw stems: watch
  `out/gauntlet_winning_session_v1.mp4` (a full 11-minute playthrough
  with the shipped soundtrack performing), or run the session DAW with
  no arguments (§5.2) and just press play. Ask the director for
  external reference tracks if you want a second bearing; don't guess
  one from the phrase "industrial metal."
- **The job is one bank at a time.** The soundtrack is an ongoing set;
  each bank is a self-contained deliverable.
- **Setup**: you work inside a project checkout that arrives ready to
  run. The tools need the `uv` launcher on your PATH
  (https://docs.astral.sh/uv/ — one installer, no Python knowledge
  needed); every command in this doc is copy-paste from the project
  root, and the first run installs everything itself. If a tool prints
  an error you can't read, paste it to the director — that's our bug or
  our doc gap, not your problem.
- **Delivery** = your bank folder inside that checkout (§5.4); nothing
  to upload anywhere else.

---

## 1. COMPOSE — one piece that plays in zones

### 1.1 One form, four zones

Your piece is one continuous form (the shipped banks are 32–36 bars,
~70–80 seconds) divided into typed **sections**. The game's arranger
treats each type differently, so each has a job:

| Section type | Job in the game | Composition requirements |
|---|---|---|
| `vigil` or `ritual` | The calm home. Loops during exploration; the music "comes home" to it after every fight. (`ritual` is a second accepted name for the same behavior — two of the shipped banks use it, purely as a label; the rules are identical.) | Must loop seamlessly (end flows into own start). Will be heard a lot, quietly. |
| `entry` | Combat on-ramp. | Counts as fight material; transitional writing is fine — *unless* the bank has no `develop`, in which case `entry` becomes the fight loop and inherits every `develop` requirement below. Just write a `develop`. |
| `develop` | **The fight loop.** Every ordinary fight loops this section, start to end, over and over. | The most-heard bars you'll write. Needs internal variety AND a seamless loop. No cadence at the end that begs continuation — the end *is* the pickup to its own start. |
| `peak` | Boss material. The arranger jumps here (led by your riser) when a boss engages, and loops it while the boss lives. | Your heaviest writing. Same no-cadence loop rule as `develop` — the *arrival* weight comes from the riser landing on its first downbeat (§3); the loop-back from its last bar to its first must simply flow. |
| anything else (`outro`, …) | Connective tissue. The arranger passes through it in calm, never parks a fight there. | Free. |

Two structural rules, because the arranger cuts on bar lines:

- **Every section must work as a loop** — including connective ones:
  while the mix is exhaling after a fight, the arranger holds position
  by looping whatever section it happens to be in.
- **Every section-start bar must work as a cold arrival** from anywhere in
  the form. Section starts are the only landing points of jumps.

**Effects are part of the seam.** Your stems are continuous renders, so
every bar carries whatever baked reverb, delay, distortion ring-out, and
compressor state the *original* previous bar produced. At a jump, the
destination bar arrives with that printed context but without its
cause; at a loop, the outgoing bar's tail is simply cut (drums) or
crossed (sustained material). So: don't let a section-start bar lean on
a distinctive tail from the bar that precedes it in the linear render,
keep baked tails harmonically neutral enough to survive any legal
arrival, and avoid exposed delay patterns that give away the original
predecessor. The audition tools (§5.2–5.3), not a linear DAW
playthrough, are the authority on every seam — audition each section's
self-loop and each section-start as a cold arrival, with your wettest
stems soloed.

### 1.2 The grid

- **A "bar" to the machine is `240 / bpm` seconds** — four quarter-notes
  at your stated tempo. All slicing, looping, and jumping happens on this
  grid. Other meters are fine as long as one constant bar duration holds
  for the whole piece and you declare the bpm that makes `240/bpm` equal
  your bar length (a 3/4 bar at ♩=120 is 1.5 s → declare bpm 160). Be
  aware that for non-4/4 meters the declared bpm is a **grid-fitting
  number, not your musical tempo** — your DAW session, click, and any
  players keep the real tempo; only `bank.json` carries the fiction.
  Note it in both places so nobody re-renders at the wrong tempo later.
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
works**. The game plays changing vertical subsets of your stems at
changing balances, and every subset it can produce must still sound
like the piece. Deriving every part from common material is the known
way to get that property. To be precise about what "every subset"
means — you do NOT have to make mutually exclusive variants stack (all
four beds, all seven basses); the combinations the runtime can actually
produce are:

- chant + one bed: the permanent foundation, alone in deep calm;
- wall (`stalwart`) and groove (`contempt`), separately or together, at
  any levels, over that foundation;
- one drum kit (ordinary *or* boss) with any of the above;
- one weapon lead — or two overlapping during a weapon switch;
- one enemy bass at a time;
- `overlay_boss` joining the full pile at boss tier, chant at war-chant
  force on top;
- any of §3's one-shots over the matching context.

Audit those reachable combinations in your DAW at low, medium, and high
relative levels — and the full boss pile for density. The M/S buttons
in the session DAW (§5.2) replay the *actual* combinations from a real
run, which is the final word.

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
  The whole ensemble jumps together (one transport), but the seam
  machinery lets the voice's outgoing phrase ring across a jump into
  the destination's harmony — and a phrase written at bar 8 will be
  *arrived at* from many different predecessors. Its counterpoint must
  survive every legal arrival.
- **The war chant**: at maximum danger the chant comes back *in full
  force over the boss mix* — a defiant, equal voice against your own peak
  section (capped just below the band; it rides with, never over). To be
  clear about who does what: the **game's fader** produces the "full
  force" — you still print `prayer.wav` at steady level like every other
  stem (§1.5). Your job is that the *writing* can stand as foreground
  against the `peak` bars — register, contour, character — so that when
  the fader lifts it, it reads as defiance, not as a pad turned up.

A note on the singer: the shipped chants are **synthesized voices**
(built in-house), not recordings of a live monk — there is no sample
library to match, and you are not expected to clone the existing
timbre. A new bank may establish its own vocal color, provided it sits
in the same register and liturgical character; the director's ear is
the arbiter — match the register you hear in `album_dies_irae`'s
`prayer.wav`, don't guess one. A sample-library or synthesized choir is
a fully acceptable delivery; a real singer is welcome but not expected.
Decide with the director before budgeting session time, and **send a
short vocal proof (eight bars is plenty) for approval before building
the whole bank around a voice** — vocal color is the most salient
choice in the piece and the cheapest one to re-decide early. On
**text**: the
shipped voices sing vowel streams shaped by the source chant's own
syllabification — intelligible Latin is not required. Setting the
source's liturgical text (public domain) or writing wordless vocalise
are both acceptable; agree on it with the director when the melody is
picked.

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
  (Appendix A lists the fader *positions* the game typically uses per
  situation — those are automation values applied to whatever levels you
  printed, not targets for you to hit. Your printed balance IS the mix
  at faders-up; mix it by ear against the reference bank and let the
  game's automation do its thing on top.)

---

## 2. PRINT — the stems

A stem here = one **full-length render of the entire form** with only one
material group sounding. Not a section bounce: the game may open any
stem's fader at any bar — a skirmish can break out while the arranger is
parked in your calm bars, and the wall/drums/bass faders open right
there — so every stem must carry its material at every bar (exceptions
below are marked). Yes, that means your wall-of-guitars stem has riffs
running through the calm bars. "Carry its material" means it must *work
as that material* if the fader opens there: it can thin out with the
form's mood (the rule floor is §2.3's −15 dB), but a fight breaking out
at bar 3 must still get a credible wall at bar 3, not a placeholder.

To be explicit about scope: this applies to **every form stem including
`drums_boss` and `overlay_boss`** — the "Heard when" column in the
track sheet describes when the game opens the fader, never permission
to leave bars empty (a boss can engage at any bar of the form). The
single exemption in this document is the leads' phrase rests (§2.3).

### 2.1 The track sheet

Every file, its musical role, and when the game opens its fader.
**Bold** = the bank won't load without it.

| File | Role | Heard when |
|---|---|---|
| **`prayer.wav`** | The chant: voice + choir + bells + light halo (§1.4). | Always. Full in calm, carried as counterpoint through fights, full-force war chant at peak danger. |
| `bed_t1.wav` … `bed_t4.wav` | Drone/atmosphere spine, one per game act (the campaign's four difficulty tiers; each level belongs to one — t1 opening levels, t4 endgame). The *level data* picks the tier, outside your bank — your only job is the four files. Identical files are fine if the piece has one texture; if you differentiate, think t1 sparse → t4 oppressive. | Always, moderately; swells with calm. |
| **`stalwart.wav`** | The danger material: the wall — riff wall, low reinforcement. "Things are hunting you." | Rises with danger. ≈ full in any serious fight. |
| **`contempt.wav`** | The swagger: driving machine groove, flourishes. "You're winning." | Rises with the player's damage output. |
| `drums.wav` | The kit, full form. | Any combat. Drums cut *clean* on bar lines when fights end — never faded. |
| `drums_boss.wav` | The serious kit: denser subdivision, crash grid. | Swaps in for `drums.wav` during boss-grade danger. |
| `lead_pistol.wav` `lead_smg.wav` `lead_shotgun.wav` `lead_rail.wav` `lead_scrap.wav` `lead_knife.wav` `lead_lightning.wav` `lead_gland.wav` `lead_hole.wav` `lead_tau.wav` | One lead line, re-voiced per weapon (same line, ten timbres — the player's weapon picks the color; character table below). | Combat. Weapon swaps crossfade two of these *against each other* (equal-power), and alternating weapons parks the pair at the 50/50 point — each about −3 dB, both clearly audible. The layering constraint is easier than it sounds: all ten renders play the *same notes*, so a sounding pair is one line in two colors, never two colliding lines — you're choosing ten timbres that blend, not composing 45 duets. Any two of the ten can pair (weapon switching is unconstrained), which is exactly why they share one line. |
| `bass_mite.wav` `bass_husk.wav` `bass_spitter.wav` `bass_shrieker.wav` `bass_brute.wav` `bass_warden.wav` `bass_flicker.wav` | A short bass ostinato cell per enemy species, tiled over the form's harmony. The dominant enemy in the fight picks which one plays. | Enemies engaged. Must genuinely live in the bass register (§2.3). |
| `overlay_boss.wav` | Register expansion for bosses only: sub-octave roots, octave pedal. | Boss engagements only. |
| The five one-shots | §3. | Scheduled moments. |
| **`bank.json`** | §4. | — |

**Runtime optionality is not delivery optionality.** The game *loads* a
bank with files missing — a missing stem's fader just opens onto
silence (no `lead_rail.wav` = no lead during rail fights) — but the
complete contracted deliverable is the full sheet: **27 form stems
(1 prayer + 4 beds + stalwart + contempt + 2 kits + 10 leads + 7 basses
+ overlay_boss), the 5 one-shots of §3, and `bank.json`** — 33 files.
Anything short of that needs the director's OK in writing, or it's an
incomplete delivery that happens to load.

**Who and what these names are** (so the re-voicings and cells have
character to aim at, not bare nouns):

The ten weapons, for the lead timbres —

| Weapon | Character |
|---|---|
| `knife` | Silent melee blade. Close, intimate, no gunfire. |
| `pistol` | Precise, deliberate sidearm. |
| `smg` | Fast, loose spray — the highest fire rate, widest scatter. |
| `shotgun` | Eight-pellet close-range blast. Percussive, brutal. |
| `rail` | The heavy precision shot — massive single hits that punch through three bodies in a line. |
| `lightning` | Arc discharge. Electric, crackling, mid-heavy hits. |
| `tau` | Rapid, tight energy repeater — clean and clinical. |
| `hole` | The PORTABLE HOLE: tears a traversable hole in space. A utility, not a gun — its lead can be the strange one (eerie, hollow, abstract). |
| `scrap` | Improvised three-pellet junk-thrower. Crude, rattling. |
| `gland` | Bio-launcher firing wet organic rounds. Sickly, fleshy. |

The seven enemy species, for the bass cells —

| Species | Character |
|---|---|
| `mite` | Tiny, fastest thing in the game, dies to a breath, comes in swarms. Skittering. |
| `husk` | The standard shambler. Baseline fodder menace. |
| `spitter` | Ranged acid-lobber that keeps its distance and pelts you. |
| `shrieker` | Fragile screamer — never touches you; it flees and *wakes the room*. Panic, not weight. |
| `brute` | Slow heavy charger; hits like a truck. |
| `warden` | The boss. A 300-hp sentinel that lives only in boss rooms — crushing melee plus ranged fire. Its cell is boss-fight bass. |
| `flicker` | Ambush predator: near-invisible lurker that explodes into a burst-lunge at close range. Dread, then violence. |

The ten leads and seven basses re-render two musical ideas (one line,
seven cells) seventeen times — mechanical as *notes*, though designing
seventeen weapon/species timbres that blend is real sound-design work;
budget for it either way. If rendering them all yourself is a poor use
of your time, there is an **alternative handoff route (director-approved
first)**: deliver full-form standard MIDI at the declared bpm (one
track per target filename; note the real tempo in `NOTES.md` if you
used a grid-fiction bpm, §1.2), one rendered full-form reference per
idea, and patch/articulation notes for each timbre you designed — we
batch the seventeen renders and return them **for your musical
approval**. Either way the bank is complete only when the rendered
WAVs are in the folder and it passes the checker; MIDI alone is not a
deliverable.

### 2.2 Rules for every stem

These are enforced by the pre-flight checker (§5.1); numbers are exact.

- **Format**: WAV, 44,100 Hz, 16- or 24-bit **integer PCM**, interleaved
  stereo (no floating-point WAVs). We transcode for shipping; you never
  deliver lossy.
- **Length — one number for the whole bank**: every form stem is
  delivered at **exactly the same sample length: the form's duration**,
  `bars × (240/bpm) × 44100` samples (round to the nearest sample; a
  few samples of rounding slack are tolerated, whole bars are not). Run
  the checker (§5.1) on your first bounce — it prints the exact count
  it expects for your bpm/bars, and rejects any other length.
- **Loop-fold your own tails.** Render each stem one bar past the form
  end in your DAW *project* so the final release/ring exists — then
  **fold that overhang into bar 0 yourself** (the classic loopable-render
  bounce: sum the overhang bar onto the first bar, trim to form length).
  The fold is what makes form-wraps ring instead of chopping. Two rules
  for folded material: it must be **release/ring only** — no new note
  onsets, drum hits, or rhythmic delay repeats, because bar 0 also
  plays at cold starts and jump landings where that "tail" had no
  cause — and keep it subtle (bar 0 at most ~1 dB louder than the
  stem's typical bar). **Exception: `prayer` — never fold the vocal.**
  Its wrap release ships separately as `prayer_tail.wav` (§3), because
  a baked vocal tail plays a phantom second singer on every jump home.
  A doubled pad release is inaudible; a doubled monk is not.
- **No DC offset**: high-pass at 10 Hz if your chain emits any (some FM
  patches do). The machine steps faders on bar lines, and a DC pedestal
  turns every step into an audible click. Residual DC above 0.003
  (full-scale = 1) fails the check. 10 Hz leaves 40 Hz sub untouched.
- **Levels**: peak below full scale, and **never peak-normalize
  individual stems** — relative balance between stems is the
  composition (§1.5) and normalization destroys it. There is no output
  limiter in the game: the safety test is the densest boss moment in
  the session DAW (§5.2), which lights a red CLIP indicator if the
  summed mix exceeds full scale. Bounce with plugin delay compensation
  on, so nothing lands late against the grid.
- **Stereo image**: no hard rule; match the reference bank's widths by
  ear per role (beds/walls wide, voice and bass centered, kit natural).
  The game does no panning of its own — what you print is the image.

### 2.3 Rules for specific stems

- **The 2-bar silence rule** (texture stems: `prayer`, `bed_*`,
  `stalwart`, `contempt`, `drums*`, `bass_*`): the stem may not sit below
  **−15 dB relative to its own median bar** for 2+ consecutive bars.
  (Measured as plain full-band RMS per bar, each bar against the stem's
  median bar RMS — nothing psychoacoustic; the checker prints the exact
  bar numbers if you trip it.) One
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
- And yes: the bass cells (like the wall and groove) run under the calm
  bars too, where they may never be heard — the form-wide rule of §2's
  intro. They're one- or two-bar ostinati tiled over the form's harmony,
  so the extra bars are tiling, not new composition.

---

## 3. PRINT — the five one-shots

These are the game's punctuation, and the standing law is: **punctuation
must sound like part of the song, never like a sound effect laid over
it.** Each is cut from your own palette. Own lengths (they're not on the
form grid), and only §2.2's *format* rules apply (WAV/44.1k/stereo, no
DC, peak headroom) — the fold mechanism does not: a one-shot's
natural release simply lives inside its own file (your sting rings out
to silence within `sting.wav`).

**Timing convention** — the engine schedules these by fixed offsets
from the START of the file, so no leading silence, ever, and bounce
with delay compensation on:

- `riser.wav`: the strike lands **exactly 2 machine bars** after sample
  0 — the engine starts it, holds the boss jump for two bars, and lands
  the jump on that instant. Audio may ring on after the strike; total
  file length is not the sync point, the 2-bar mark is. Verify in the
  session DAW: the strike must sit on the ▲ marker's downbeat.
- `riser_half.wav`: a **self-contained ~half-bar swell**, played the
  instant an ambush is detected; the full mix then slams in on the
  next bar line — up to half a bar later. It bridges the gap rather
  than sample-locking to it, so shape it to peak at its end and still
  work if the wall arrives slightly after.
- `sting.wav` / `stab.wav`: the attack begins **at sample 0** (they're
  placed at their moment, not pre-rolled).
- `prayer_tail.wav`: total length exactly one machine bar.

| File | Length | What it is | When the game fires it |
|---|---|---|---|
| `riser.wav` | ~2 bars | A swell that resolves into its own strike — ours is a big chapel bell *reversed into its forward strike*. The strike instant is the file's climax. | Leading every boss entrance: the game decides to jump to `peak`, holds the jump for your riser's 2-bar swell, and lands the jump **as the strike hits**. Your riser's strike = the peak section's downbeat. Compose them as one gesture. If the threat dies mid-swell the riser is faded early — make sure it survives an early fade. |
| `riser_half.wav` | ~½ bar | A micro version of the same swell gesture. | Only on a true ambush (a heavy hitting from real silence) — the event this doc calls **the slam**: a half-bar swell into an instant full mix. The swell is what makes the cliff read as intent. |
| `sting.wav` | a few seconds | The release cadence. Ours: the track's own choir singing a plagal ("Amen") cadence — subdominant sonority resolving to the home triad, in the hall. Won blind listening against every percussive/bell variant precisely because it *resolves* the fight in the piece's own voice. | The moment a boss dies. Heavy faders take a one-bar comedown underneath it. |
| `stab.wav` | ~1.5 bars | A percussive exclamation — crash + kick + low tom in the shipped banks. Keep it unpitched or harmonically neutral; if it does carry pitch, that pitch must sit inside `peak`'s harmony, because it will repeat there. | Every 4 bars while a boss lives, on the grid, over your looping peak. |
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
- Alongside it, drop a **`NOTES.md`** in the bank folder for the musical
  facts the JSON can't carry: your real tempo/meter if the bpm is a
  grid fiction (§1.2), the final/mode (for rotation compatibility,
  Appendix A), the vocal text choice, and anything the next person
  touching the bank should know.

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
- **Automation lane**: the three game values (PRAYER / CONTEMPT /
  STALWART — calm / winning / danger) as curves. Where they move is
  where your mix will move.
- **Track strips**: one per stem track, showing each bar's clip and fader
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
fight. Pick your bank from the list, then drive it — the three values
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
  everything, transcodes) and render real recorded
  gameplay with it; final sign-off is the director's ear on those
  sessions. Expect timestamped feedback against the same winning run
  you auditioned.
- **Licensing**: every sample, instrument, and preset in your renders
  must be cleared for commercial redistribution *in rendered form*, and
  each source gets a line in the source ledger — a text file in the
  checkout at `tools/musicgen/SOURCES_LICENSES.md`; add your lines there
  (name, origin, license) or send them with the delivery and we'll merge.
  "Free to use in commercial renders, instrument itself not
  redistributable" is fine — we ship renders. "Non-commercial" is not.
  Public-domain source melodies (plainchant, 18th-century hymnody) are
  safe; modern *editions and arrangements* of them are copyrighted —
  work from the tune, not from someone's engraving.

---

## Appendix A — the playback rules

What the machine actually does to your audio. You don't implement any of
this; you write music that stays musical under it.

**Vocabulary, precisely.** Each stem (or stem family, like the ten
leads) plays on one **track**; each track has a **fader** the game
rides. The **three values** — PRAYER, CONTEMPT, STALWART — are not
faders themselves: they're the game's continuous reading of the fight,
each 0–1, and every track's fader position is a formula of them.
**PRAYER** = calm/contemplation (never fully zero), **CONTEMPT** = the
player dealing damage, **STALWART** = the player being hunted. They are
independent axes and blends are the normal case: a boss fight is
contempt AND stalwart high at once. There are no discrete "modes." So:
the *chant* track's fader mostly follows PRAYER (plus the combat floor
and war-chant terms), the *bed* track's fader follows PRAYER too
(0.55 + 0.35·prayer — always on, swelling with calm), the *groove*
follows CONTEMPT, the *wall* follows STALWART, drums/leads follow
whichever of the two fight values is higher.

**The bar grid is absolute.** All stems play sample-locked in parallel;
every change — fader steps, form jumps, variant swaps — lands exactly on
bar lines. One consequence you'll hear: anything that must survive a cut
needs to make sense at a bar boundary.

**Fader laws.** Rises are shaped (max ~+0.35/bar — a natural 2–3-bar
build; sudden real threats can wall in within a bar; big rises get a
half-bar come-up). Falls glide (×0.65 per bar, then a one-bar farewell
fade). Percussion never fades out — drums exit clean on the bar line.
The chant moves slowest of all (≤0.12/bar up, ≤0.08/bar down once
established): swells and diminuendos, never lurches. Active tracks are
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
arrival fade on the combat tracks only — never on the chant or the bed.
On the riser-led boss jump these compose into one gesture: the combat
tracks swell in *under* your riser's climax and the strike masks the
splice — the chant and bed simply continue across it. (Hear it in the
session DAW: scrub to any ▲ marker.)

**Punctuation is scheduled, never reactive.** The game fires your
one-shots only where it knows the future (its own scheduled jumps, a
boss's death, a genuine ambush) — a reactive hit would always land
after the moment it should have led. Details per one-shot: §3.

**Bank rotation.** During long calm stretches the game hands off between
banks (~every 95 s) with a 2-bar crossfade, calm material into calm
material. This is why a shared tempo across banks matters (§1.2). On
key: there is no enforced common key — the overlap is two calm bars of
chant-and-drone, and the shipped banks all live in dark modal space
(their chant sources are church modes), which is what keeps handoffs
from clashing. Write in that harmonic neighborhood and tell the
director your final/mode; if you want to write somewhere further out,
that's a director conversation before you print.

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
| bank | One piece's folder: stems + one-shots + bank.json. The deliverable. |
| stem | A full-form render of one material group (one file). |
| track / lane | The runtime channel a stem plays on. ("Lane" in older docs = "track" here; same thing.) |
| fader | A track's level, ridden by the game as a formula of the three values. |
| section | A typed span of bars in your form (`vigil`, `develop`, `peak`…). |
| arranger / steering | The game relocating the playhead between sections on bar lines. |
| PRAYER / CONTEMPT / STALWART | The three state values (calm / dealing damage / being hunted) that drive every fader. |
| through-line | Material that never stops: the chant and the bed. |
| riser · sting · stab | The punctuation one-shots (§3). |
| the slam | Not a file: the ambush *event* — a half-bar `riser_half.wav` swell into an instant full mix (§3). |
| war chant | The chant at full force over the boss mix at peak danger. |
| the 2-bar rule | No texture stem below −15 dB (rel. its median bar) for 2+ bars (§2.3). |
| bar-pair rule | A voice audibly singing in every 2-bar window of `prayer` (§1.4). |
| loop-fold | Summing the form's one-bar overhang of ring into bar 0 before trimming — you do this in your DAW for every stem except `prayer` (§2.2). |

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
