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

DANGER_HOLD_LINE = 0.35    # a chamber this deadly is not entered alone
DANGER_CROSS_PEERS = 2     # visible committed peers that make a push
DANGER_CROSS_MUSTER = 0.60 # or enough Muster gathered at the door

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
                muster_here: float) -> bool:
    """The collective's threshold-holding rule: a lone agent does not
    walk into a chamber that has kept killing its kind — it stands at
    the doorway and calls (Muster) until a push has gathered."""
    if danger_next <= DANGER_HOLD_LINE:
        return False
    if committed_visible >= DANGER_CROSS_PEERS:
        return False
    return muster_here < DANGER_CROSS_MUSTER


def choose_route(best_edge: int, second_edge: int, raid_member: bool) -> int:
    """The multi-approach fan: ~1/3 of committed searchers take their
    second-best route so a push arrives from more than one direction."""
    if raid_member and second_edge >= 0:
        return second_edge
    return best_edge
