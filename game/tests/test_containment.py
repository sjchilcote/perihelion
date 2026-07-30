"""Containment: the ENGINE now enforces center-in-registered-polygon at the
end of every step (contain_in_polygon, physics.rs), so escapes are corrected
within one tick and the game-level sweep is a silent backstop that never
fires in practice."""

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame


def _level():
    b = LevelBuilder("CONTAIN", 1)
    r0 = b.rect(0, 0, 200, 140)
    b.player(r0, (40, 70))
    b.entity(r0, "husk", (150, 70))
    b.exit(r0, (180, 70))
    return b.build()


def test_escaped_enemy_is_recovered():
    """Teleported far outside, the entity is back inside its registered
    polygon within a tick or two -- by the ENGINE invariant, before the
    game-level sweep (6 consecutive 30-tick strikes) can even arm."""
    s = GameSession(_level(), seed=1)
    eid = next(iter(s.enemies))
    s.sim.set_pos(eid, s.sim.place(s.sim.get_polygon(eid), 4000.0, -4000.0))  # far outside the polygon polygon
    for _ in range(3):
        s.tick(InputFrame())
    x, y = s.sim.get(eid).pos.local()
    assert GameSession._outside_by(x, y, s.level.polygon_verts[0]) <= 1e-6
    # the sweep stayed silent: the engine fixed it first
    for _ in range(200):
        s.tick(InputFrame())
    assert s.metrics.get("containment_recoveries", 0) == 0


def test_normal_play_never_triggers_recovery():
    s = GameSession(_level(), seed=2)
    for _ in range(60 * 5):
        s.tick(InputFrame(mx=1.0))
    assert s.metrics.get("containment_recoveries", 0) == 0
