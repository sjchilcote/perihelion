"""Coordination decisions (U5, DESIGN_7_25 appendix) — pure functions.

Every rule here consumes immutable observations (sense frames, signal
neighborhoods, scalars) and returns a decision. Nothing in this module
can reach into the session, the marrow, audio, or render — the sim
composes these against what its agents legitimately perceive.

The ratified corrections live here:
- QUORUM is fractional: an idle agent commits on the fraction of the
  peers it can actually SEE that are already committed. Calm visible
  peers are a denominator that inhibits; the fields contribute one
  bounded virtual supporter, so a loud disturbance still wakes a lone
  picket while barely perturbing a twelve-agent hall.
- FLOCKING is a priority BUDGET, not a weighted average: separation
  claims acceleration first and only the remainder chases the target —
  the average of "left" and "right" is "straight into the doorframe",
  and that is exactly the doorway jitter this replaces.
"""
from __future__ import annotations

import math
from typing import Sequence

# per-agent commit threshold is sampled ONCE at spawn from this band —
# killing habitual low-threshold initiators measurably thins cascades
QUORUM_THRESHOLD_BAND = (0.25, 0.45)
QUORUM_HILL_N = 4          # steepness of the commit hazard
QUORUM_GAIN = 0.22         # per-decision-tick hazard scale
EXCITE_NORM = 0.60         # (Noise + Distress) / this, clamped to [0,1]

STAND_DOWN_TICKS = 300     # ~5s of faint signal and no sighting
STAND_DOWN_FLOOR = 0.05    # "faint": every local field below this

# One kill emits 0.40 Danger with a 180s half-life: at 0.35 the line,
# every room in a fighting player's WAKE gated pursuit for minutes and
# the chase died at every door (filmed gate runs 1-6: 'no pressure
# ever lands'). The hold is for chambers that KEEP killing — repeat
# kills stack past 0.7 fast; one skirmish three minutes ago does not.
DANGER_HOLD_LINE = 0.70
DANGER_CROSS_PEERS = 2     # visible committed peers that make a push
DANGER_CROSS_MUSTER = 0.60 # or enough Muster gathered at the door

# THE ALARM (director 2026-07-31). Measured on a real session before
# this landed: agents spent 61,446 of 87,662 ticks HOLDING at doorways,
# 1,159 separate stints, because the player's chamber sat over the
# Danger line 47% of the time and Muster — the only other way in —
# reached its 0.60 crossing threshold in 0 of 1,461 samples. Holding was
# a terminal state, so a room the player had fought in became a room
# nothing would enter, and the game read as enemies that did not care
# that you were there.
#
# The rule that replaces it is stigmergic, not a threshold tweak:
#
#   seeing the intruder DUMPS Distress          -- the alarm is a smell
#   smelling Distress commits you, and you climb it  -- toward the fight
# A third leg — sending a lone agent up the KIN gradient to fetch help —
# was written, measured, and REMOVED. It halved hunt commitments (31.8/min
# against a 56.7 baseline) because an errand walks a body away from the
# fight, and the Distress it laid never recruited enough to pay for the
# leaving. Standing at the door is a worse behaviour that costs less. The
# doorway-hold pathology is therefore still open; it wants a different
# answer, not this one.
SIGHT_DISTRESS = 0.50      # dumped where an agent sights the player
ALARM_DISTRESS_LINE = 0.45 # smell this much and you go, whatever you were doing
# GUNFIRE IS THE LOUDEST THING THE PLAYER DOES, and until this line
# existed almost nothing heard it. Firing already emitted Noise 0.8, but
# its only consumer was the quorum — which caps the whole field
# contribution at ONE bounded virtual supporter, so a shot fired in the
# next room barely moved anybody's commit probability. That is the
# mechanism behind the pattern every reviewer of the director's session
# described independently: rooms activating one at a time, enemies
# "only beginning to move after the player fires at them", a conga line
# instead of a response. Noise has a 3s half-life and spreads fast, so
# this reads as "they heard that" and not as clairvoyance.
ALARM_NOISE_LINE = 0.40


def alarmed(distress: float, noise: float = 0.0,
            line: float = ALARM_DISTRESS_LINE,
            noise_line: float = ALARM_NOISE_LINE) -> bool:
    """Has something loud enough happened here to commit an idle agent?

    This is deliberately NOT the quorum: the quorum asks what your
    neighbours are doing, and a hall of calm neighbours inhibits it. An
    alarm is a fact about the world, and a fact does not need a vote."""
    return distress >= line or noise >= noise_line


# THE TWO-STAGE TRACK. Distress is a 45s field that SPREADS: it says
# "something is happening over there" from far away. Trail is a 12s
# field that does NOT spread and cannot accumulate past its cap: it says
# "he went THIS WAY, seconds ago", and only to someone already standing
# next to where he walked. They are a beacon and a scent, and they want
# to be read in that order — beacon until you cut the scent, then scent
# the rest of the way.
#
# They used to be SUMMED, which is why a tracker could lose you while
# standing in your footprints: measured on a real session, Distress by a
# busy fight reached 4.55 and enters that sum at 0.6x = 2.73, while
# Trail is capped at 0.80 by construction. The diffuse smell outvoted
# the fresh one better than three to one, so hunters drifted toward the
# general commotion instead of running down the body that made it.
TRAIL_LOCK = 0.30          # ~21s old: fresher than this and the scent WINS

# TURRET DREAD (director 2026-08-01: "give the Testator enemies more fear
# of turrets; they can simply dump Danger and run away when they even see
# one unless they feel they have the numbers to take it on").
#
# Measured cause: emplaced guns took 56% of every killing blow in a real
# session, and 74% of those kills happened 3+ hops from the player. Each
# death dumps Danger where it happened, so the guns were pre-poisoning
# the chambers the player was about to walk into, and the survivors then
# refused to enter them. The swarm was feeding itself to the emplacements
# and souring the map on its way down.
#
# A body that RECOGNISES a gun and backs off does three things at once:
# it stops dying for nothing, it stops manufacturing Danger the player
# never sees, and — because backing off dumps Danger AT the gun — it
# teaches the rest of the swarm to route around the emplacement instead
# of discovering it one corpse at a time. Numbers override dread: a
# push with the bodies to spend still goes in.
TURRET_DREAD = 0.55        # Danger dumped where a gun is seen
TURRET_DREAD_PEERS = 3     # committed peers that make a gun worth rushing
TURRET_DREAD_TICKS = 90    # ~1.5s of backing off bought per sighting
# ...and then it may not be bought again for this long. Without a floor
# on the gap, a body that flees while still able to see the gun re-arms
# on its very next scan and never stops: measured at 746 continuous
# ticks of flight with the body's whole AI suspended behind it.
TURRET_DREAD_COOLDOWN = 600   # ~10s: flee at most ~1.5s in every 11.5s


def dread_turret(peers_committed: int,
                 needed: int = TURRET_DREAD_PEERS) -> bool:
    """Does this body back away from a gun it can see?

    Fear here is arithmetic, not cowardice: one body against an
    emplacement is a corpse and a wasted Danger mark, and the same body
    with a push around it is an assault."""
    return peers_committed < needed


def scent_lock(trails) -> bool:
    """Is any doorway carrying a trail fresh enough to lock onto?"""
    return max(trails, default=0.0) >= TRAIL_LOCK


def hunt_attraction(trail: float, noise: float, distress: float,
                    muster: float, doorway: float, locked: bool) -> float:
    """How loudly one doorway calls a hunter.

    `locked` (some doorway has a fresh scent) collapses this to the
    scent alone: once you have the track you follow the track, and the
    beacon that brought you here stops being able to pull you off it."""
    if locked:
        return trail + 0.15 * doorway
    return (noise + trail + 0.6 * distress + 0.4 * muster + 0.15 * doorway)

RAID_FRACTION = 1.0 / 3.0  # committed searchers taking the second route


def quorum_excitation(noise: float, distress: float) -> float:
    """The fields' bounded virtual supporter: 0..1, never more."""
    return max(0.0, min(1.0, (noise + distress) / EXCITE_NORM))


def quorum_fraction(committed_visible: int, all_visible: int,
                    excitation: float) -> float:
    """f = (committed + e) / (all + 1). Calm peers inhibit; the +1 keeps
    a lone agent from being its own quorum."""
    return (committed_visible + excitation) / (all_visible + 1)


def commit_hazard(f: float, threshold: float) -> float:
    """Hill curve against the agent's spawn-time threshold: a smooth
    hazard in [0,1), steep around the threshold."""
    if f <= 0.0:
        return 0.0
    fn = f ** QUORUM_HILL_N
    return fn / (fn + threshold ** QUORUM_HILL_N)


def commit_probability(f: float, threshold: float) -> float:
    """Per-decision-tick commitment probability. Cascades START at sparse
    edges (small denominator -> big f) and propagate inward over a
    second or two rather than snapping a whole hall at once."""
    return QUORUM_GAIN * commit_hazard(f, threshold)


def allocate_acceleration(
        budget: float,
        requests: Sequence[tuple[int, float, float]]) -> tuple[float, float]:
    """Priority-budget steering. `requests` = (priority, ax, ay), lower
    priority number claims first (separation=0, objective=1, ...). Each
    request is granted up to what remains of the budget; opposed requests
    therefore never average into the doorframe — the winner wins and the
    loser gets what's left."""
    remaining = budget
    out_x = out_y = 0.0
    for _, ax, ay in sorted(requests, key=lambda r: r[0]):
        if remaining <= 1e-9:
            break
        mag = math.hypot(ax, ay)
        if mag <= 1e-9:
            continue
        take = min(mag, remaining)
        out_x += ax / mag * take
        out_y += ay / mag * take
        remaining -= take
    return out_x, out_y


def separation_request(me_xy, me_radius, peers) -> tuple[float, float]:
    """Keep-apart demand from same-chamber peers, 1/d^2 falloff, scaled
    to body size so the formation stays loose with visible gaps.
    `peers` = iterable of (x, y, radius)."""
    mx, my = me_xy
    ax = ay = 0.0
    for (ox, oy, orad) in peers:
        dx, dy = mx - ox, my - oy
        d = math.hypot(dx, dy)
        gap = me_radius + orad + 12.0
        if d < 1e-6:
            ax += 1.0     # perfectly stacked: any direction beats none
            continue
        if d >= gap * 2.0:
            continue
        push = (gap / d) ** 2
        ax += dx / d * push
        ay += dy / d * push
    return ax, ay


def wants_stand_down(has_sighting: bool, local_peak: float,
                     quiet_ticks: int) -> bool:
    """A hunter whose neighborhood stayed faint ~5s and who sees nothing
    exits the combat state. (An agent sharing the intruder's chamber
    always has a sighting — chambers are convex — so this never reads
    the player's position.)"""
    if has_sighting:
        return False
    return local_peak < STAND_DOWN_FLOOR and quiet_ticks >= STAND_DOWN_TICKS


def danger_hold(danger_next: float, committed_visible: int,
                muster_here: float,
                cross_peers: int = DANGER_CROSS_PEERS) -> bool:
    """The collective's threshold-holding rule: a LONE agent does not
    walk into a chamber that has kept killing its kind — it waits at
    the doorway and calls (Muster) until a push has gathered. The rule
    is about loneliness, not cowardice: a SIGHTED chase passes
    cross_peers=1 (two who can see the killer go in together — Danger
    holds a 180s memory, and requiring a trio everywhere the player
    has fought turned every pair into a perpetual shadow, the filmed
    'trailing at fixed distance' blocker)."""
    if danger_next <= DANGER_HOLD_LINE:
        return False
    if committed_visible >= cross_peers:
        return False
    return muster_here < DANGER_CROSS_MUSTER


# garrison settlement (U10): a follower settles where a Warden stands,
# nothing hostile is visible, the ground is quiet, and it has HELD that
# ground continuously — the leader is completely oblivious (no follower
# count, no base id, no command state ever touches the Warden)
SETTLE_NOISE_CEIL = 0.20
SETTLE_DANGER_CEIL = 0.35
SETTLE_HOLD_TICKS = 12 * 60


def may_settle(warden_present: bool, hostile_visible: bool,
               noise: float, danger: float, held_ticks: int) -> bool:
    if not warden_present or hostile_visible:
        return False
    if noise >= SETTLE_NOISE_CEIL or danger >= SETTLE_DANGER_CEIL:
        return False
    return held_ticks >= SETTLE_HOLD_TICKS


def choose_route(best_edge: int, second_edge: int, raid_member: bool) -> int:
    """The multi-approach fan: ~1/3 of committed searchers take their
    second-best route so a push arrives from more than one direction."""
    if raid_member and second_edge >= 0:
        return second_edge
    return best_edge
