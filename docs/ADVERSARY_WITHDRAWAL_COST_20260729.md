# Ruling needed: what does withdrawal actually cost?

Date: 2026-07-29
Status: **open — needs a director ruling.** The measurement half is
already built and shipped (`adversary_lost` / `adversary_withdrawn`,
landed with gate 57). This document is the design half.

## The contradiction

Two ratified statements, both in force:

1. Adversaries are finite personnel, authored at world build, never
   produced by the CORE. **The census permanently decrements.**
2. *"Existing in zero-Otherworldness environments is difficult for them,
   so they need to retreat into breaches after a while."* From which:
   **withdrawal is the Adversary's normal outcome, death is the
   exceptional one.**

The shipped code makes both exits identical. A scout that crosses into
the marrow's own house is reabsorbed and gone for the session, exactly
as if the player had killed it.

Put those together and the faction annihilates itself. If the normal
outcome removes personnel as permanently as the exceptional one, then
over a campaign the census drains on a schedule the player has no
influence over, and killing an Adversary buys nothing that waiting
would not also have bought. The player's win condition and the enemy's
routine behaviour produce the same number.

That cannot be what "death is the exceptional one" means. Withdrawal has
to be survivable, or it is just a slower death with better manners.

## What is already true in the tree

- `adversary_census` is the standing count: how many are in the world now.
- `adversary_lost` counts kills. `adversary_withdrawn` counts departures.
  They are separate as of gate 57.
- **Nothing in the sim reads any of the three.** They are consumed only
  by tests and by `marrow_farm`, which until gate 57 computed
  `scouts_killed` as `census0 - census_end` and therefore reported every
  voluntary departure as a player kill.
- There is no path that puts an Adversary into the world after world
  build. Authoring is the only source.

So today the answer to "what does withdrawal cost?" is: exactly what
death costs, and no instrument could see the difference until this week.

## The ruling

**Do withdrawn personnel come back?**

### Option A — withdrawal is recoverable (implied by the ratified law)

A withdrawn Adversary rejoins a roster and can re-enter the world later.
Death is then the only permanent removal, and the player's kill is the
only thing that shortens the campaign.

Costs: needs a return path, which does not exist. The natural carrier is
the breach — they arrive through breaches, so they could return through
one. That means a new trigger, a rate, and a decision about whether a
returning Adversary is the *same* person (same class, same census slot)
or merely the same class.

Risk: this is a difficulty change. Gate 57 just certified the seal and
delivery economy; a new body source pointed at breaches lands directly
on top of it.

### Option B — withdrawal is permanent, and the law changes

Keep the current behaviour and retire "death is the exceptional one" as
the governing phrase. Withdrawal becomes flavour — the reason a body
leaves the screen — with no economic difference from dying.

Costs: cheap, already built. But it makes the dwell clock the real
enemy-attrition mechanism and the player a spectator to it, and it makes
the finite-personnel framing mostly decorative.

### Option C — withdrawal is partial

A withdrawn Adversary returns, but degraded, or only a fraction of them
do, or only while a breach it can reach stays open. Preserves the
"withdrawal is normal" law while keeping a permanent drain so the
campaign still ends.

Costs: the most machinery and the most tuning of the three.

## Recommendation

**Option A**, with the return path deliberately narrow: a withdrawn
Adversary may re-enter only through a live breach, and only into a
chamber that already has non-zero Otherworldness, so returning is
something the player can prevent by sealing and by denying ground. That
keeps the counterplay in systems that already exist and already have
tells, rather than adding a hidden respawn timer.

This is not implemented and should not be until it is ruled on. Building
a new body source into the breach economy is a balance decision and a
difficulty change, and inventing it unasked is how the last adversary
pass went wrong.

## What is safe to do meanwhile

Nothing further is needed for the books to be honest — they already are.
`marrow_farm` now reports `scouts_killed` and `scouts_withdrawn`
separately, so the next farm bank will show, for the first time, what
fraction of adversary attrition the player is actually responsible for.
**That number should be read before the ruling is made.** If it turns
out the player already causes most of it, Option B is defensible; if
withdrawal dominates, Option A or C is close to mandatory.
