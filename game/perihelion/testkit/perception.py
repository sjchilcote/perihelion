"""Perception honesty layer for the human-realistic bot (BOT_REALISM_DESIGN.md §1).

`GameSession.snapshot()` is omniscient: every enemy in the level, anywhere,
with exact hp/pos, is present in `snapshot["enemies"]` regardless of the
player's room or line of sight. The existing bots (`AggroBot` et al.) use
that freely -- and are the deliberate baseline for the perception-honesty
test to fail against (BOT_REALISM_DESIGN.md "Verification").

`PerceptionModel` narrows that omniscient feed down to what a player could
plausibly react to:

  - an entity is perceivable at all only once it is either room-local, OR
    present in the caller's `visible_ids` -- the entities the renderer's
    own portal-visibility query (`session.visible()`, see
    `HumanBot._visible_enemy_screens`) currently has on screen. The engine
    is a seamless-portal design (design_document_2.md §11): a player sees
    into a neighboring room through an open doorway before ever crossing
    into it, so "on screen" is strictly wider than "room-local," and
    gating on room-membership alone made the bot blind to enemies plainly
    in frame -- the confirmed root cause of it running right past ones
    that hadn't crossed the room-index boundary yet (director's verdict,
    2026-07-13). Room-membership alone remains the default/fallback for
    callers that don't have a `session` to query (direct unit tests below).
  - a newly-perceivable entity is not acted on until a sampled reaction
    latency has elapsed since it first became perceivable -- ~180-280ms
    when the bot is already anticipating that spot (pre-aimed), ~280-450ms
    for a surprise appearance (design doc's "reaction latency" + "surprise
    events get the slow tail").

All latency samples are drawn from a `Random` seeded once at construction
(never a module-global or wall-clock source), so a `PerceptionModel` replays
identically given the same seed and the same sequence of snapshots -- the
determinism property in design doc §8.
"""

from __future__ import annotations

from random import Random

TICK_HZ = 60.0

# Reaction latency bounds, in seconds, sampled per newly-perceived entity.
# Anticipated (pre-aimed) spot: the fast tail an alert player gets from
# already looking at the right place. Surprise: the slow tail plus the
# flinch handled separately by the reactive executor.
ANTICIPATED_LATENCY_RANGE = (0.18, 0.28)
SURPRISE_LATENCY_RANGE = (0.28, 0.45)


class PerceptionModel:
    """Tracks, per enemy id, when it first became perceivable (room-local
    or on-screen via `visible_ids`) and the sampled latency before the bot
    may act on it."""

    def __init__(self, seed: int = 0):
        self.rng = Random(seed)
        self._first_seen: dict[int, int] = {}
        self._latency: dict[int, float] = {}

    def _forget(self, still_present: set[int]) -> None:
        gone = [eid for eid in self._first_seen if eid not in still_present]
        for eid in gone:
            del self._first_seen[eid]
            del self._latency[eid]

    def perceive(self, snapshot: dict, tick: int,
                 anticipated_ids: frozenset[int] = frozenset(),
                 visible_ids: frozenset[int] = frozenset()) -> list[dict]:
        """Return the subset of `snapshot["enemies"]` currently perceivable
        (room-local, OR present in `visible_ids`) that have been
        perceivable for at least their sampled latency.

        `anticipated_ids` names enemies the caller already had a pre-aim on
        (e.g. a doorway sweep landed on their spot) -- those draw from the
        fast latency tail; everything else is a surprise.

        `visible_ids` names entities the renderer's own visibility query
        currently has on screen, room-membership aside (a room-local
        entity is always implicitly visible, so this only ever WIDENS the
        candidate set -- callers with no `session` to query simply omit
        it and get the old room-only behavior). Positions for a returned
        entity that is NOT room-local are in THAT entity's own room-local
        frame, not the player's -- never diff them against the player's
        position; see `HumanBot._distant_threat_input`.
        """
        proom = snapshot["room"]
        candidates = [e for e in snapshot["enemies"]
                      if e["room"] == proom or e["id"] in visible_ids]
        present_ids = {e["id"] for e in candidates}
        self._forget(present_ids)

        visible = []
        for e in candidates:
            eid = e["id"]
            if eid not in self._first_seen:
                self._first_seen[eid] = tick
                lo, hi = (ANTICIPATED_LATENCY_RANGE if eid in anticipated_ids
                          else SURPRISE_LATENCY_RANGE)
                self._latency[eid] = self.rng.uniform(lo, hi)
            elapsed = (tick - self._first_seen[eid]) / TICK_HZ
            if elapsed >= self._latency[eid]:
                visible.append(e)
        return visible

    def ticks_perceivable(self, eid: int, tick: int) -> int:
        """How many ticks this entity has been a candidate (room-local or
        visible), for diagnostics/tests."""
        first = self._first_seen.get(eid)
        return -1 if first is None else tick - first
