"""Withdrawal is not death, and the books are not the only place that
has to say so.

Ratified: the census decrements permanently on a DEATH, and withdrawal
is the Adversary's NORMAL outcome. Both cannot be true while going home
removes a body as permanently as being killed does — and measurement
said it mattered, not taste: across 8 farm seeds the player caused 14
of 47 adversary losses. The other 33 walked home, and never came back.

So a recovered Adversary re-enters the world through a live breach.
The breach is the entire gate: seal them and nobody returns. A kill is
still permanent, which is the whole point.
"""
from __future__ import annotations

from perihelion.levels import LevelBuilder, load_level
from perihelion.sim import (ADVERSARY_RECOVERY_TICKS, GameSession,
                            InputFrame)
from perihelion.testkit.humanbot import HumanBot


def test_withdrawn_adversary_returns_through_a_live_breach():
    """The positive path, on the real level: a recovered body walks
    back out of a tear."""
    level = load_level("../levels/gauntlet4.json")
    s = GameSession(level, seed=4, screen=(640, 360), zoom=0.45)
    bot = HumanBot(4)
    before = sum(s.adversary_census.values())
    s.adversary_out.append(("lacuna", 0))     # already recovered
    for _ in range(12000):
        s.tick(bot.step(s.snapshot(), s))
        if sum(s.adversary_returned.values()):
            break
    assert s.breaches, (
        "no breach ever opened in 12000 ticks — the scene cannot test "
        "a breach-gated return")
    assert s.adversary_returned["lacuna"] == 1, (
        "a recovered Adversary must re-enter through a live breach")
    assert not s.adversary_out, "the returned body left the waiting list"
    assert sum(s.adversary_census.values()) > before - 1, (
        "the returned body is standing in the world again")


def test_return_needs_a_live_breach():
    """No breach, no return. This is the counterplay: sealing is what
    stops them, so a world with no tear must hold the line forever."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (100, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    assert not s.breaches, "this level has no marrow and no breaches"
    s.adversary_out.append(("lacuna", 0))
    for _ in range(600):
        s.tick(InputFrame())
    assert sum(s.adversary_returned.values()) == 0, (
        "with no live breach nothing may come back")
    assert len(s.adversary_out) == 1, "it is still waiting, not lost"


def test_recovery_is_not_instant():
    """A withdrawal is a real absence. A body that has not recovered
    does not come back even with a breach standing open.

    Asserted against one specific never-due body rather than against a
    zero return count, because scouts withdraw and recover on their own
    during a live session — the first cut of this test assumed an idle
    world and caught an organic return instead of a bug."""
    level = load_level("../levels/gauntlet4.json")
    s = GameSession(level, seed=4, screen=(640, 360), zoom=0.45)
    bot = HumanBot(4)
    sentinel = ("vagrant", 10_000_000)          # never due
    s.adversary_out.append(sentinel)
    for _ in range(6000):
        s.tick(bot.step(s.snapshot(), s))
    assert s.breaches, "a breach did open, so the gate was available"
    assert sentinel in s.adversary_out, (
        "an unrecovered body must still be waiting, breach or no breach")
    assert s.adversary_returned["vagrant"] == 0, (
        "and it must not have been the one that came back")


def test_a_kill_is_permanent():
    """The one exit that never comes back. If a kill queued a return
    too, the player's win would buy nothing at all."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (-100.0, 0.0), "lacuna")
    s._damage_enemy(eid, 9999.0, (1.0, 0.0), 0.0, source="test")
    assert s.adversary_lost["lacuna"] == 1
    assert s.adversary_out == [], (
        "a killed Adversary must never queue a return — death is the "
        "permanent exit and the only one")


def test_recovery_constant_is_a_real_delay():
    """Guards the constant against being zeroed into a revolving door
    by a future tuning pass without anybody noticing."""
    assert ADVERSARY_RECOVERY_TICKS >= 1800, (
        "a withdrawal shorter than 30s stops reading as an absence")
