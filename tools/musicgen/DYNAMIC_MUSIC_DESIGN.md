# Dynamic music system — design doc

Director's spec (his words, paraphrased into requirements):

1. Music gets more intense based on how intense the game is.
2. Different enemies produce different **basslines**.
3. The player's weapon determines the **lead**.
4. The chapter of the game sets the **rhythm** everything else builds on.
5. Keep the runtime mechanism as simple as his own pyweek-28 implementation.
6. Stretch goal (design only, not build): SFX quantized to the music.

This doc proposes a concrete design against each point, grounded in three
things built this session: the album playbook (`PLAYBOOK.md`), the
pyweek-28 prior-art mechanism, and what Phase C's judged instrument/demo
results actually revealed about what our synthesis can and can't do yet.

## 1. The runtime mechanism — honor pyweek-28's simplicity

pyweek-28's `DoubleLayerMusicPlayer` (`musicplayer/__init__.py` in the
cloned repo, scratchpad `pyweek-28/`) is the model to extend, not replace:

- Two (or more) full-length **looping stems**, all always playing.
- A background thread linearly ramps each stem's volume toward 0 or 1 at a
  fixed rate (his: 0.01 per 10ms) based on a **single boolean flag** read
  from game state every tick: `self.levelmusic.b_should_be_playing =
  (self.battle is not None)` (`gamestate/__init__.py:153`).
- No FSM, no curve tuning beyond the fixed linear rate, no per-encounter
  cue logic.

PERIHELION's version generalizes this to **N stems, each gated by one
scalar (0..1) instead of one boolean**, still with a single fixed-rate
linear fader per stem, still one thread (or one per-frame `lerp`) — no new
complexity class introduced:

```
class LayerPlayer:
    stems: dict[str, Sound]       # e.g. "rhythm", "bass", "lead"
    target: dict[str, float]      # what each stem's volume should ramp toward
    current: dict[str, float]     # ramps toward target at FADE_RATE/tick

    def tick(dt):
        for name in stems:
            current[name] = move_toward(current[name], target[name], FADE_RATE * dt)
            stems[name].set_volume(current[name])
```

Game code just writes `target["lead"] = 1.0 if player_in_combat else 0.0` —
exactly pyweek-28's pattern, generalized from a bool to a float and from 2
stems to however many the chapter needs. This is the entire runtime
mechanism. Everything below is about *what* sets `target[...]`, and *which*
audio plays in each stem slot — not about making the fader smarter.

## 2. Intensity → overall song energy

Candidate intensity metrics (to calibrate via a GPT Sol consult — see
`tools/musicgen/consult_machinery.py`, not yet run; this is a proposal list,
not a ruling):

- **Threat density**: count of active hostile entities within N tiles/LOS.
- **DPS in/out**: rolling window of damage dealt vs. taken (both matter —
  a player steamrolling a room reads differently than one barely surviving
  it, and the album's own `intensity_level` tags in the playbook distinguish
  "high" from "peak" partly on this kind of push/pull).
- **Health trend**: derivative of player HP over the last few seconds, not
  just current HP — a sharp drop should spike intensity even above a high
  static threat count.
- **Room lockdown state**: binary/tiered (unlocked / locked-in-combat /
  cleared) — maps cleanly onto the album's own structural_role tags
  (buildup / drop-climax / breakdown) found in the playbook.
- **Lurker proximity**: distance to nearest not-yet-aggroed threat — this
  is the one metric that should raise intensity *before* combat starts
  (dread, not just DPS), matching the album's dormant/low/building blocks
  which build tension with no drums yet.

Combine into a single 0..1 `intensity` scalar (simple weighted sum to
start, per pyweek-28's own preference for simple over clever), which then
maps to a **layer count**, not a continuous DSP parameter — e.g.
`intensity < 0.2` → rhythm bed only, `0.2-0.5` → + bass, `0.5-0.8` → + one
lead layer, `> 0.8` → + a second/harder lead or drone layer. This directly
reuses the playbook's own "what enters/exits between intensity levels"
findings (see PLAYBOOK.md's layering-grammar section) rather than inventing
a new intensity taxonomy from scratch.

**Calibration step**: once real telemetry exists (room clear times, damage
logs), consult GPT Sol via `consult_machinery.py` on the weighting — this
is exactly the kind of "outside model, no stake in our abstractions"
question `consult_planner_diagnostics.py` was written for in diet_app.
Not run yet (no real telemetry to calibrate against); a musicgen-specific
`build_prompt()` still needs writing (see that file's header for the
reusable-vs-diet_app-specific split).

## 3. Enemy → bassline

Each enemy *type* (not instance) owns a bass pattern + register, keyed the
same way `melodies.py`'s `BASS_PATTERN`/`render_bass` already parameterize
root note/octave. When an enemy type is present/aggroed, its bass motif
gets mixed into the `bass` stem (crossfaded per pyweek-28's linear-fader
rule when the enemy set changes — no special-case transition logic).
Concretely: a small `ENEMY_BASS_TABLE: dict[enemy_type, BassMotif]`, where
`BassMotif` is exactly the `(root_note, root_octave, pattern)` triple
`melodies.py` already takes. Multiple simultaneous enemy types = the
loudest/highest-priority one wins the bass slot (again: simple, not a
mixer) unless director wants true layering, which is a stretch.

## 4. Weapon → lead

Same pattern, mirrored onto `render_lead`: each *weapon* (not each shot)
owns a lead motif/register, active in the `lead` stem while that weapon is
equipped, gated by the intensity layer-count rule above (lead only sounds
during combat-tier intensity, matching what the playbook found: the lead
enters late, at/near the drop, never during dormant/low blocks). A
`WEAPON_LEAD_TABLE` mirrors `ENEMY_BASS_TABLE`'s shape.

## 5. Chapter → rhythm (the shared foundation)

The rhythm stem is the one thing that does NOT change per-encounter — it's
set once per chapter/area (a `CHAPTER_RHYTHM_TABLE: dict[chapter_id,
RhythmPattern]`), and the bass/lead motifs above are written to be
harmonically/rhythmically compatible with whichever chapter rhythm is
active (same BPM/meter — the playbook found the album overwhelmingly
converges on one tempo/grid, so chapters differing in *feel* should differ
in instrumentation/pattern-density, not tempo, to keep bass/lead drop-in
compatible without a re-tempo step).

## 6. Stretch: SFX quantized to the music (design only)

Not built this pass. Proposed mechanism, still honoring "simple":

- The music system already knows the current beat clock (a single running
  phase counter derived from `STEP_S`/`BAR_STEPS` in `melodies.py`'s grid).
  Expose it as a read-only `beats.current_phase_16th()` the SFX layer can
  poll.
- Weapon fire sounds get a **quantize-to-grid class**: heavy weapons
  (shotgun, rail) snap to the nearest downbeat/quarter; light/fast weapons
  (SMG) snap to 8th/16th subdivisions instead, so they can still feel
  responsive at high fire rates without becoming arrhythmic against the
  beat.
- Pitch variation: SFX take their pitch-shift *cents* offset from the
  currently active chord/mode (from the chapter rhythm's key), the same
  way `melodies.py`'s `BASS_PATTERN`/`LEAD_PATTERN_HIGH` already express
  motion as semitone offsets from a root.
- Success metric: Gemini judges a mixed clip (music + quantized SFX) with a
  prompt that must permit "reads as separate/off-beat" as a valid answer —
  same fail-first discipline used in `judge_instruments.py`/
  `compare_demo.py` this session (see PLAYBOOK.md/report for two real bugs
  that discipline caught).

## What Phase C's judged results imply for the artist handoff

- Bass and lead timbres are the easiest to nail with synthesis alone —
  `fm_bass`/`lead_saw` reached p_match 0.85/0.75 against the album after
  one iteration (see `tools/musicgen/instruments.py` docstrings for the
  before/after). The artist can treat these as a legitimate starting point,
  not just a placeholder to throw away.
- Percussion (kick/snare/hihat) and the rhythm-guitar chug stayed at
  p_match 0.1-0.4 even after a second iteration pass — they read as
  "electronic/synthetic" against the album's acoustic-metallic kit. This is
  a **real gap for the artist to close**, not a bug in our pipeline: pure
  noise+filter subtractive synthesis can't cross into "sounds like a
  live-miked kit and a distorted guitar cabinet" without either sampled
  transients or modal/physical resonator modeling. Flag this explicitly so
  the artist doesn't assume our drum/guitar placeholders are close.
- The full assembled demo, judged side-by-side against the album, scored
  p_same_family=0.1 ("reads like 8-bit chiptune, not industrial metal") —
  consistent with the above: individual pitched-instrument matches don't
  add up to a genre match once the drums/guitar (the two elements that
  carry the album's *aggression*) are still weak. The artist's real job is
  exactly those two elements.
