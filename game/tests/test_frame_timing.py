"""The frame meter: where the loop's wall clock actually went.

"Unplayably slow" was for a long time a report nothing in the game could
answer. The fps meter showed one number, and from outside a heavy sim tick,
an expensive draw and a recording stealing the main thread all look the
same. FrameTiming splits the frame so the next such report is a lookup, and
rides the session bus so a human run leaves the same evidence a bot run
does.
"""

from __future__ import annotations

import json

from perihelion.telemetry import FrameMeter, FrameTiming, TraceBus, to_json_line


def test_a_window_publishes_exactly_one_record():
    m = FrameMeter(window=4)
    out = [m_ for m_ in (_frame(m, i) for i in range(4)) if m_ is not None]
    assert len(out) == 1
    assert out[0].frames == 4


def test_nothing_is_published_before_the_window_closes():
    m = FrameMeter(window=10)
    assert all(_frame(m, i) is None for i in range(9))


def _frame(m: FrameMeter, tick: int, sim_ticks: int = 1) -> FrameTiming | None:
    m.begin()
    for phase in FrameMeter.PHASES:
        m.mark(phase)
    return m.end(tick, sim_ticks)


def test_a_phase_that_burns_time_is_the_phase_that_reports_it():
    """The whole point: the breakdown must name the right culprit."""
    m = FrameMeter(window=2)
    rec = None
    for _ in range(2):
        m.begin()
        _spin(0.01)
        m.mark("sim")
        m.mark("draw")
        m.mark("present")
        m.mark("record")
        m.mark("wait")
        rec = m.end(0, 1)
    assert rec is not None
    assert rec.ms_sim >= 9.0, rec
    assert rec.ms_draw < 5.0 and rec.ms_record < 5.0, rec


def test_worst_is_the_worst_frame_not_the_mean():
    m = FrameMeter(window=3)
    rec = None
    for i in range(3):
        m.begin()
        _spin(0.02 if i == 1 else 0.0)
        m.mark("sim")
        rec = m.end(0, 1)
    assert rec is not None
    assert rec.ms_worst >= 19.0, rec
    assert rec.ms_frame < rec.ms_worst, "a mean cannot equal its own maximum here"


def test_voluntary_idle_is_not_counted_as_work():
    """ms_frame is WORK: a loop sleeping out its 60Hz budget is healthy and
    must not read as an expensive frame."""
    m = FrameMeter(window=2)
    rec = None
    for _ in range(2):
        m.begin()
        m.mark("sim")
        m.mark("draw")
        m.mark("present")
        m.mark("record")
        _spin(0.01)
        m.mark("wait")
        rec = m.end(0, 1)
    assert rec is not None
    assert rec.ms_wait >= 9.0, rec
    assert rec.ms_frame < 5.0, f"idle leaked into the work total: {rec}"


def test_sim_ticks_expose_a_loop_falling_behind_the_clock():
    """sim_ticks/frames is the slow-motion tell: the loop's catch-up cap
    means 4.0 is a game whose clock the frame can no longer keep."""
    m = FrameMeter(window=2)
    rec = None
    for _ in range(2):
        rec = _frame(m, 0, sim_ticks=4)
    assert rec is not None
    assert rec.sim_ticks / rec.frames == 4.0


def test_an_unknown_phase_is_refused_at_the_mark():
    m = FrameMeter(window=2)
    m.begin()
    try:
        m.mark("gpu")
    except KeyError as exc:
        assert "gpu" in str(exc)
    else:
        raise AssertionError("a typo'd phase silently vanished into nothing")


def test_it_serializes_onto_the_session_bus_like_every_other_record():
    bus = TraceBus()
    m = FrameMeter(window=1)
    rec = _frame(m, 120)
    assert rec is not None
    bus.emit(rec)
    (got,) = bus.drain()
    assert got.kind == "frame_timing"
    row = json.loads(to_json_line(got))
    assert row["t"] == 120
    for field in ("fps", "ms_frame", "ms_worst", "ms_sim", "ms_draw",
                  "ms_present", "ms_record", "ms_wait", "sim_ticks", "frames"):
        assert field in row, f"{field} missing from the serialized record"


def test_a_window_of_zero_is_refused():
    try:
        FrameMeter(window=0)
    except ValueError:
        return
    raise AssertionError("a zero window would divide by zero every frame")


def _spin(seconds: float) -> None:
    """Busy-wait: sleep() would be measured as wall time either way, but a
    spin keeps these tests honest about CPU-bound phases."""
    import time
    end = time.perf_counter() + seconds
    while time.perf_counter() < end:
        pass
