# Gauntlet IV bot program — honest-game report (2026-07-18)

**Goal as set:** iterate the bot — nothing else — until 50% full-clear
rate on `levels/gauntlet4.json`.
**Result:** ~1% true clear rate (holdout-validated). The residual gap
is attributed, with measurements, to four content facts listed at the
end. This report is the decision document.

## What happened to the game

The 50.8% clear rate of the morning was an artifact: enemy combat AI
ran only when co-polygon, so tethered wardens were inert statues farmed
through doorways (98% of warden damage dealt cross-polygon, broods never
hatched). The cross-polygon honesty fix (director's law: polygons are
polygons; cross-polygon functionality is never optional) plus
untethering made every fight real — and roughly 3x costlier. The
bot's measured baseline collapsed from 52% to 0/64, mean survival
80s.

## What the bot became

~55 measured iteration rounds (every change probed at n=64, ~15-20
min each; keepers audited on a held-out bank; negatives reverted and
recorded in code comments and commit messages):

- **Cross-polygon threat unification** — the bot had the sim's old
  disease: reflexes blind to enemies 25u away across a portal plane.
  Same cure as the sim: portal-transformed 1-hop hunters merge into
  the local threat frame.
- **NPC-internals purge** (director's ruling) — perception returns
  id/kind/polygon/pos/hops plus movement-INFERRED activity only. No
  state flags, no enemy hp. Mechanism-pinned in tests.
- **Siege doctrine** — first-sight recoil (one hard pull-withdrawal
  per new warden, capped at two), 10s fresh-pull latches that string
  a hatching brood into killable singles, listening holds at blind
  waists, finish-the-pull advance gating, provocation shots for
  parked bosses (the opening shot is the pull).
- **Kite war** — 350u warden standoff repulsion (wardens outrun the
  player 137 vs 133; range is the only safe place), rail lines
  through the anchor, pursuit-persistent withdrawal, pincer- and
  coffin-aware retreat routing, guns-runs that lead warden pairs
  into sentry fields.
- **Resource honesty** — the scrap driver converts the otherwise
  dead component/salvage economy (~300/run, no shops on this level)
  into the mid-range workhorse; tau vetoed in narrow polygons (its
  ricochets were self-inflicted wounds); geometric lightning
  discharge.

Trajectory: mean 80s → 325s (training) / 242s (holdout); median 96s
→ 212s/164s; warden kills 0 → ~200 per 64-run bank; the game's first
honest full clears (14/14 wardens, ~1200s runs).

## Why it stops at ~1%

Measured, not estimated:

1. **Pack lethality vs heal ceiling.** Fights with 1-2 enemies cost
   4.6hp; ANY engagement of 5+ costs ~100hp = death. Medkits do not
   consume above hp 70 (sim rule), so the bankable budget is 70 +
   scraps. Each warden brings a 10-add brood on engagement; each
   compound holds 3-4 wardens that converge (they never de-aggro and
   are faster than the player).
2. **The alert economy caps skill.** Gunfire/kills alert 1 hop.
   Sharper aim (skill 8/12/16) measured worse-to-collapse twice —
   faster kills advance the front faster than they thin it.
3. **The fold-return tax.** ~40% of all damage taken is the bot's own
   automatic fire wrapping the level's loops and returning from
   behind (~0.2s later, dead-opposite the aim). Five census-measured
   fire-discipline gates were no-ops: most targets are close, and any
   miss in loop geometry wraps. A human pays this tax too.
4. **No traversal shortcut exists.** The exit is ungated, but pure
   avoidance measured 60s mean (corridor blockers force fights at
   sprint pace), and pursuit uses the same shortest-path graph as the
   bot — folds included — so no pull-and-slip asymmetry exists.

Every macro family, doctrine constant, execution stance, and item
system now ends in an n=64 measurement or a geometric impossibility.
Full ledger: commit log (`git log --oneline 36ed735..`) and
`memory/gauntlet4-bot-program.md`.

## The fork (decision needed)

To reach 50%, one line of content, or a new number:

- brood 10 → ~5 per warden, and/or
- warden speed below the player's 133 u/s, and/or
- medkit consumption ceiling above 70, and/or
- a shooter-immunity window on fresh rounds (tunes the fold tax), or
- re-target the goal to what the honest game supports (e.g. median
  survival milestones, or clear rate at a chosen content level).

Also noted for the music program: honest clears produce ZERO full
boss-music triggers — the siege kills wardens at range, so STALWART
never crosses the boss lines. The demo pipeline needs its own
reconciliation whichever fork is chosen.
