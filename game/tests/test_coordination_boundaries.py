import math

import pytest

from perihelion import coordination as coord


def test_alarm_and_dread_boundaries():
    assert not coord.alarmed(0.44, 0.39)
    assert coord.alarmed(0.45, 0.0)
    assert coord.alarmed(0.0, 0.40)
    assert coord.alarmed(0.2, 0.3, line=0.2, noise_line=0.9)
    assert coord.dread_turret(2)
    assert not coord.dread_turret(3)
    assert not coord.dread_turret(2, needed=2)


def test_scent_lock_boundaries():
    assert not coord.scent_lock([])
    assert not coord.scent_lock([0.0, coord.TRAIL_LOCK - 0.01])
    assert coord.scent_lock([0.0, coord.TRAIL_LOCK])


def test_hunt_attraction_exact_values():
    args = dict(trail=2.0, noise=3.0, distress=5.0,
                muster=7.0, doorway=11.0)
    assert coord.hunt_attraction(**args, locked=True) == pytest.approx(3.65)
    assert coord.hunt_attraction(**args, locked=False) == pytest.approx(12.45)


def test_quorum_excitation_and_hazard_boundaries():
    assert coord.quorum_excitation(-1.0, 0.0) == 0.0
    assert coord.quorum_excitation(0.15, 0.15) == pytest.approx(0.5)
    assert coord.quorum_excitation(1.0, 1.0) == 1.0
    assert coord.commit_hazard(-0.1, 0.35) == 0.0
    assert coord.commit_hazard(0.0, 0.35) == 0.0
    assert coord.commit_hazard(0.35, 0.35) == pytest.approx(0.5)


def test_acceleration_budget_uses_priority_magnitude_and_direction():
    requests = [(2, 0.0, 0.0), (1, 0.0, 4.0), (0, 3.0, 0.0)]
    assert coord.allocate_acceleration(5.0, requests) == pytest.approx((3.0, 2.0))
    assert coord.allocate_acceleration(0.0, requests) == (0.0, 0.0)
    assert coord.allocate_acceleration(2.5, [(0, -3.0, -4.0)]) \
        == pytest.approx((-1.5, -2.0))


def test_separation_request_exact_vectors():
    assert coord.separation_request((0.0, 0.0), 2.0, []) == (0.0, 0.0)
    assert coord.separation_request((0.0, 0.0), 2.0,
                                    [(0.0, 0.0, 3.0)]) == (1.0, 0.0)
    ax, ay = coord.separation_request((3.0, 4.0), 2.0,
                                      [(0.0, 0.0, 3.0)])
    expected = ((2.0 + 3.0 + 12.0) / 5.0) ** 2
    assert ax == pytest.approx(3.0 / 5.0 * expected)
    assert ay == pytest.approx(4.0 / 5.0 * expected)
    assert coord.separation_request((0.0, 0.0), 2.0,
                                    [(40.0, 0.0, 3.0)]) == (0.0, 0.0)


def test_stand_down_and_danger_hold_equalities():
    assert not coord.wants_stand_down(False, coord.STAND_DOWN_FLOOR,
                                      coord.STAND_DOWN_TICKS)
    assert coord.wants_stand_down(False, math.nextafter(
        coord.STAND_DOWN_FLOOR, -math.inf), coord.STAND_DOWN_TICKS)
    assert not coord.danger_hold(coord.DANGER_HOLD_LINE, 0, 0.0)
    assert coord.danger_hold(math.nextafter(coord.DANGER_HOLD_LINE, math.inf),
                             0, 0.0)
    assert not coord.danger_hold(coord.DANGER_HOLD_LINE + 0.1,
                                 coord.DANGER_CROSS_PEERS, 0.0)
    assert not coord.danger_hold(coord.DANGER_HOLD_LINE + 0.1, 0,
                                 coord.DANGER_CROSS_MUSTER)


@pytest.mark.parametrize(
    "warden,hostile,noise,danger,ticks,expected",
    [
        (True, False, 0.0, 0.0, coord.SETTLE_HOLD_TICKS, True),
        (False, False, 0.0, 0.0, coord.SETTLE_HOLD_TICKS, False),
        (True, True, 0.0, 0.0, coord.SETTLE_HOLD_TICKS, False),
        (True, False, coord.SETTLE_NOISE_CEIL, 0.0,
         coord.SETTLE_HOLD_TICKS, False),
        (True, False, 0.0, coord.SETTLE_DANGER_CEIL,
         coord.SETTLE_HOLD_TICKS, False),
        (True, False, 0.0, 0.0, coord.SETTLE_HOLD_TICKS - 1, False),
    ],
)
def test_settlement_truth_table(warden, hostile, noise, danger,
                                ticks, expected):
    assert coord.may_settle(warden, hostile, noise, danger, ticks) is expected


def test_route_choice_uses_only_a_valid_second_route_for_raid_members():
    assert coord.choose_route(4, 7, False) == 4
    assert coord.choose_route(4, 7, True) == 7
    assert coord.choose_route(4, -1, True) == 4
