# Bot Realism Design — the marketing playthrough bot

Goal (director, 2026-07-13): a full playthrough video, fresh install → victory on the
hardest difficulty, that **looks and plays like a competent human player — not a
perfect machine**. This doc is the policy inventory; implementation follows once the
lurker work frees `sim.py`.

The organizing principle: **every inhuman tell comes from the bot knowing or acting
outside human channels.** Fix the channels and most tells disappear at the source,
instead of sprinkling noise on top of machine behavior.

## 1. Perception: the bot sees the screen, not the sim

- Input is restricted to what a player has: entities inside the rendered viewport /
  sensor traces, the visible lightmap (a lurker's dimmed flicker is *hard to notice*,
  as designed), HUD state, and audio events. No reads of off-screen enemy positions,
  no exact HP of un-inspected enemies, no world map beyond what's been explored.
- **Reaction latency**: nothing is acted on until ~180–280 ms after it first becomes
  perceptible (sampled per event; faster when pre-aimed at the spot — that's what
  anticipation buys, see §3). Surprise events (spawn behind, lurker pounce) get the
  slow tail plus a flinch (§5).
- **Attention is single-threaded**: one focus target at a time, peripheral events
  need salience (muzzle flash, damage taken, loud audio) to preempt. A flanker the
  bot "hasn't looked at" gets reacted to late — that's a feature; humans tunnel.

## 2. Mouse: trajectories, not teleports

- All aim movement is a smoothed trajectory (Fitts's law timing: far/small targets
  take longer), with **overshoot-and-correct** on fast flicks and slight undershoot
  on cautious tracking. Never a lerp with constant velocity — velocity profiles are
  bell-curved.
- Persistent micro-jitter and drift when "resting"; idle mouse settles near screen
  center or last point of interest, not frozen on a pixel.
- Tracking a moving target lags behind and periodically re-corrects; misses cluster
  the way human misses do (behind the target's motion, worse at speed).

## 3. Anticipation (the director's seed, generalized)

- The cursor **lives where danger is expected**: hovering doorways before entering,
  sweeping to the next corner while moving, pre-aiming the direction a sensor trace
  suggests. Danger expectation comes from a cheap heuristic map (unexplored doorways,
  known spawn sites already seen this run, direction of recent damage/audio).
- Pre-aimed threats get fast reactions; unanticipated ones get slow reactions. This
  asymmetry is the single most human-looking property the bot can have.
- **Room-entry protocol**: pause at thresholds, lamp-sweep dark rooms from the
  doorway (zero-ambient makes this read beautifully on video), enter along a wall,
  not through the centerline.

## 4. Movement: paths a hand would steer

- No polyline-perfect routes: corners cut slightly or overshot, small heading wobble,
  speed drops while aiming carefully or turning hard.
- Combat footwork: strafe-jockeying rather than optimal orbiting, use of terrain
  (new walk-mask cover!) and doorways as chokes, backpedal-while-firing when charged,
  disengage to lit/cleared ground when hurt.
- Occasional benign imperfection: clipping a corner of terrain and correcting,
  briefly picking the wrong door when backtracking, a beat of hesitation before
  committing into darkness. Rate-limited so it reads as human, never as drunk.

## 5. Error, stress, and recovery — competent, not flawless

- **Flinch**: taking damage jerks aim off-target for ~100 ms before recovery.
- **Pressure degrades accuracy**: more enemies on screen / low HP widens effective
  aim error and shortens patience (earlier retreats, spammier fire).
- Panic behavior at critical HP: break contact, kite, heal/resupply if the game
  offers it, re-engage deliberately. Marketing-wise, *recoveries* are the money
  shots — a run that shows danger and skill beats a run that shows dominance.
- Losing a fight is allowed. The playthrough is assembled from real attempts on the
  hardest difficulty; deaths before the final cut are acceptable footage (and some
  may be worth keeping — the game over screen is part of the game).

## 6. Humanity between fights (marketing surface)

- **Curiosity beats**: entering a new distinctive room draws a look-around sweep;
  the bot reads terminals (dwell time scaled to text length — the story is a selling
  point and the video should linger on it); pauses on vistas/reveals.
- Pickup behavior with human priorities: detours for visible ammo/health, but not
  pixel-perfect vacuuming of every item.
- Variable tempo: bursts of confident speed through cleared ground, slow care in new
  territory, a breather after hard fights (check HUD, reload, sweep the lamp).
- Idle tells: small aim wanders, weapon checks — never statue-stillness.

## 7. The Sonnet tactical layer (pause-and-think)

The bot may pause the game and consult Sonnet — the diegetic equivalent of a player
stopping to think. Consults are **rate-limited and event-driven** (entering a major
new area, HP below threshold after a fight, repeated deaths at the same spot, stuck
progress timer), not per-tick.

Sonnet receives a compact tactical digest (explored map summary, known threats and
their kinds, HP/ammo/weapons, current chapter/objective, recent deaths and causes)
and sets **policies, not keystrokes**:

- **Movement policy**: `explore` / `advance-carefully` / `hold-choke` / `kite` /
  `retreat-and-resupply` / `rush-objective`.
- **Weapon policy**: preferred weapon per range band + ammo conservation rule
  (e.g. "pistol for singles, save the heavy for clusters").
- **Target priority**: ordered threat classes (e.g. lurkers before grunts once
  discovered; shooters over melee while kiting).
- **Risk posture**: engagement range, retreat HP threshold, willingness to push
  darkness — this modulates §4/§5 parameters.
- **One-shot intent**, e.g. "clear left wing before the hub" — the reactive layer
  executes it; Sonnet is never in the reflex loop.

Between consults the reactive layer runs the last policy set. Policy changes are
logged with the tactical digest that produced them (post-hoc narration material for
marketing: the bot's "thought process" is real).

## 8. Honesty rules

- The bot plays the real game binary through the real input path (synthetic mouse/
  key events), on the real hardest difficulty. No sim-state cheats, no difficulty
  shims, no scripted sequences — the video is genuine gameplay or it's worthless.
- All humanization is sampled from the run's seeded RNG streams: runs stay
  reproducible, determinism properties stay green.
- Tunables (latencies, error rates, consult cadence) live in one config block with
  the human-baseline citations/reasoning inline, so the director can dial "how good
  is this player" as one knob.

## Verification

- A/B video review: same segment with realism on/off; the on-version must read human
  to a fresh judge (Sonnet judging "human or bot?" on video clips is cheap; the
  director's eye is final).
- Determinism PBT: same seed + same policy log ⇒ identical run.
- Perception honesty test: assert the bot never acts on an entity before it has been
  perceptible for its sampled latency (fail-first against the current omniscient bot).
- Playthrough integrity: the final video's input log replays to the same outcome.
