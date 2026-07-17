# PERIHELION Dynamic Music — The Arrived-At Design

Extracted 2026-07-16 from three days of directed iteration, per the director's
order: "once we get this debugged we need to extract the actual design we've
arrived at, delete all code and start over from the design." This documents
WHAT the system is and WHY each law exists. It is the specification for the
clean-room rewrite; the current implementation is the disposable prototype.

## 1. Philosophy

The music is the Commando's thinking and feeling. It is NOT a state machine:
PRAYER, CONTEMPT, STALWART are continuous values in [0,1] computed from what
the Commando experiences. Blends are native. When he dies, the music dies —
instantly, all of it. That is the only thing that ever stops PRAYER.

- **PRAYER** — contemplation/processing; the through-line. Floor 0.12; never
  reaches zero; never *stops* (gain moves, playback never halts).
- **CONTEMPT** — damage OUTPUT ("ass-kicking music"). Driven by the player's
  trigger duty and kill flow. Firing feeds ONLY this.
- **STALWART** — danger INPUT ("things just got serious"). Driven by what
  hunts him: kind-weighted aggro (co-room/adjacent), inverse-distance crowd
  pressure, aggro influx, damage taken. NOT by his own firing.
- A boss fight is BOTH high. Trash-mowing is contempt alone. Being hunted
  while unable to fight back is stalwart alone.

## 2. The value battery

- Corpus-fitted per-unit weights (ridge regression of sim observables against
  measured 5s-future damage / kill-flow / calm), with DESIGN OVERRIDES on
  top; overrides are explicit and commented (warden weights raised so
  stalwart>0.9 is boss-exclusive; FIRED_W forced to 0 by the
  firing→CONTEMPT law). Corpus surprises that became law: adjacent heavies
  ≈ 73% of co-room weight; screams are a confounder, not a source; being
  hurt does not amplify danger.
- Engine-side EMAs: influx/damage/kills at 3s tau, trigger duty at 1s.
- Nonlinear filter: values low-passed with a one-bar tau (no waking for
  sub-bar skirmishes) EXCEPT massive spikes (raw-vs-filtered stalwart gap
  ≥0.30, or influx ≥3/s) which snap through immediately.
- An unknown enemy kind is a missing design decision → KeyError, not a
  default weight.

## 3. The mixer: chunk-queue grammar

Every lane is a channel playing equal bar chunks back-to-back via queue();
the audio device is the clock. All musical change is WHICH chunk gets queued
next; a mid-bar re-selection replaces the pending chunk so changes land on
the next bar line. Gains step only at heard boundaries.

### Material classes (the hardest-won law in this document)

- **Bar-sliceable material**: drums, riffs, pads, basses, chordal beds —
  anything that re-attacks at bar lines. May be sliced, re-addressed,
  looped, jumped freely.
- **VOICES** (the monk; any legato performance): NEVER bar-addressed. You
  cannot swap between recordings of an instrument in the middle of its
  voice. A voice enters only at its own phrase start, placed on a form bar
  line, and exits only by fade. Silent stretches in a voice's coverage are
  filled by NEW phrase-aligned entrances (the distant monk drifting in),
  never by tiling, crossfading, or teleporting the performance.
- **Why the aligned voice works (music theory)**: every part in a track is
  derived from the same source melody at different time-scales (cantus
  firmus + diminutions: monk at chant pace, riffs as 16th diminutions,
  leads as augmentations, choir statements of the head). Counterpoint
  lives in ALIGNMENT — composed placements put the voice's stressed notes
  on chord tones of progressions the melody was written against, and each
  entrance re-anchors the chant's slower pulse to the band's bar line.
  Preserve the pitch material but displace the alignment and you get
  accented non-chord tones and permanent cross-tempo drift: "two unrelated
  recordings playing at once."

### Stems

- **FORM-WIDE STEM LAW**: the engine may gain any dynamic stem at any form
  position, so every dynamic stem (stalwart walls, contempt machinery,
  beds, leads, enemy basses) must carry content at EVERY position. The
  album arrangement is section-local; bank stems are separate form-wide
  renders of the same material. Sparse stems are legal only for content
  the engine itself gates (drums sound only in combat; choir/bell accents
  ride inside prayer).
- **Loopable-render law (FL trick, director)**: every stem render runs
  one chunk past the form end to catch the instruments' sustain, and
  that tail chunk is summed into chunk[0] -- wraps and jumps landing
  on bar 0 carry the ringing tail instead of a hard cut. (The rewrite
  should generalize this with an engine-side TAIL VOICE: on any
  discontinuous steer, play the head of the bar that WOULD have
  followed, faded, under the landing -- correct ring for arbitrary
  jump pairs, incl. landings that aren't bar 0.)
- Register law: each lane owns a frequency band. The build MEASURES the
  rendered output (the patch decides the sounding octave, not the MIDI
  note) and re-renders an octave down/up until the fundamental lands in
  band (bass lane: 40–120 Hz); it crashes if no octave lands.
- Build-time validators (crash, don't warn): no dynamic stem may be quiet
  for 2+ consecutive bars ("it doesn't need to be literally constant, it
  just needs to not suddenly go silent for multiple bars"); prayer holds
  the same rule after gap-fill; bank.json requires bpm/bars/sections,
  range-checked, sections within the form.

### Lanes

bed (tier drone), drums (kit; drums_boss ≥0.8 with 0.8/0.7 hysteresis),
holy (prayer stem: monk+choir+bells), groove (contempt), wall (stalwart),
lead + lead2 (weapon voices, equal-power crossfade at 0.25/bar with a
sticky 50/50 deadzone — alternating weapons park both leads on), bass
(dominant-enemy cells; selection by threat weight, co-room emphasized),
boss (overlay ≥0.88: sub-octave root + octave pedal; tritone rejected).

## 4. Form steering

Banks carry typed sections: vigil/ritual (calm), entry/develop (combat
band), peak (boss), outro. At bar lines the playhead may steer:

- **Boss (stalwart ≥0.88)**: pull to PEAK — the jump is LED by the riser
  (below) — and loop peak while the boss lives. Stabs on the 4-bar grid.
- **Combat floor (max(c,st) ≥0.35)**: the form never drifts into calm or
  outro material mid-fight; ordinary fights loop the develop band ("save
  the really hard stuff for when it counts").
- **Becalmed**: loop vigil; "come home" to it from elsewhere only after
  the mix has settled (all heavy lanes ≤0.25 AND 4 consecutive calm bars)
  — jumping mid-exhale reads as someone hitting NEXT.
- All steers land on composed section boundaries, on bar lines. Loop
  steers are seamless; only true jumps get arrival fades — and arrival
  fades NEVER touch the through-line lanes (holy/bed).

## 5. Transitions (judged grammar)

- Rises get walls: gains rise ≤0.35/bar normally; a spike lands the full
  wall in one bar. Presence floor ~0.4 while a value is live.
- Falls breathe: 0.65×/bar glide, then ONE farewell bar fading to zero.
- **Percussion exits CLEAN on the bar line** (amplitude-fading an active
  drum loop reads as a DJ fader); sustained material glides and farewells.
- Boss release: a latch (armed ≥0.75, fires <0.3 — a single-bar cliff test
  can never fire through the low-pass) → one-bar comedown on heavy lanes
  under the toll. PRAYER continues.
- Rotation: after ~44 bars the engine hands off to the next bank ON a bar
  line, but only at ~100% PRAYER (p≥0.95, c,s≤0.15). Through-line lanes
  enter the new bank at full gain.

## 6. Punctuation is PLANNED, never reactive

A causal engine cannot anticipate a fight; a spike-reactive riser always
finishes AFTER the drop it should lead into ("risers rise to nothing" by
construction) and a threat-spike bell lands on an arbitrary chord ("a
random bell"). Punctuation exists only where the engine knows the future:

- **Riser** = the same deep bell REVERSED (2 bars, swells into its own
  strike), fired one place only: leading the engine's own scheduled boss
  peak-jump. The jump is held two bars under the swell and lands as the
  bell strikes. If the boss dies mid-swell, the riser fades out fast — a
  swell must never complete into nothing.
- **Sting** = the boss-release toll only: one deep on-key chapel bell
  (Ylanne sample, strike ~D2, hum ~37Hz), zero leading silence.
- 8-bar cooldown as a backstop; the toll bypasses it.

## 7. Death

hp ≤ 0 halts every channel instantly (music_halt tap). No fade. Respawn
is a new performance.

## 8. Tooling contracts

- **Tap protocol**: the engine logs every decision (music_bar with
  per-lane content+gain+farewell marks, bank/jump[~s]/rel/int/riser/
  sting/stab/halt, 10Hz raw+filtered values and top-3 subfactors) such
  that an offline mixer reconstructs the exact mix — recordings never
  need a live mixer, and the debug video is built from taps.
- **DAW debug overlay**: frame counter, transport, pre/post-filter value
  meters with subfactor readouts, aggro census, per-lane waveform strips
  (temporally-consistent integer-bin scrolling, per-lane global-peak
  autoscale, label above strip), NOW/NEXT with specific clip identity
  (stem[bar]), NEXT flash only on queue OVERRIDE (key change, not bar
  advance), riser/sting/stab lanes, event ticker, death banner.
- **Judging**: comparative blind A/B with rationale-consistency is the
  only trustworthy Gemini instrument; absolute scoring is noise (verified
  repeatedly). Instruments outrank the judge; the director's ear outranks
  everything. Validate on known-answer fixtures before trusting.
- **Fail-fast law**: invalid states unrepresentable where possible (one
  validating loader, frozen meta, read-only properties, derived dicts);
  otherwise crash immediately, with tests that CONFIRM the crash. No
  .get() on keys that must exist. No blanket except around startup. A
  failing test is an alarm going off.

## 9. Known tensions for the rewrite

- Naming: the PRAYER *value* vs the "prayer" *stem* (monk+choir+bells) vs
  the holy *lane*. The rewrite should name material by what it is (voice,
  choir, bells) and reserve value names for values.
- The prototype accreted lane-name special-case lists (HEAVY_LANES,
  CLEAN_EXIT_LANES, through-line exemptions). The rewrite should make
  these properties OF the lane declaration (material class, exit style,
  through-line flag), not lists in the engine.
- Live path and tick(recording) path are parallel implementations of the
  same boundary logic; they drifted repeatedly. The rewrite should have
  ONE boundary function driven by either clock.
- Bank stems ship at ~110MB/7 banks (ogg q4). Fine for now.
- Rotation handoff could crossfade the through-line instead of bar-line
  swapping (judged 8/10, minor).
- The riser resolves to the peak jump's bar line, which is scheduled off
  the fight's phase, not the phrase grid; a future engine could align
  peak entries to 4-bar phrase boundaries.
- Gauntlet III design tension (separate program): 90%-fail bosses vs
  "winning session video" — needs a director ruling; numbers in memory.
