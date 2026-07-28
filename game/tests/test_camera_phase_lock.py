"""Camera pixel-snap regression suite (2026-07-12): the "half-pixel polygon
crossing" flicker.

Symptom (director report, seed-7 aggro l01, tick 226->227): the whole
frame translates by exactly (0, +3.5) internal-screen pixels for one
tick, then snaps back. Under nearest-neighbor sampling, a half-pixel pan
re-rounds every 1px seam/grate line frame-wide for that one tick --
world-wide texture-line color flicker.

Root cause: `_set_cam` snapped the RENDERED camera's translation to the
nearest whole pixel independently every tick, re-derived from
`_cam_smooth` (float). At a portal transfer, the smooth matrix is
re-based through the transfer's rigid transform `m9` (exact, "zero
visible change by construction" -- true for the smooth copy). But
re-rounding the re-based translation from scratch can disagree with the
ROUNDING the previous frame already committed to by up to 0.5px (a
zoom-scaled world offset lands on a different side of a rounding
boundary), stepping the rendered mapping by a fractional pixel for
exactly that one tick.

Fix: the rendered camera (`GameSession.cam`) is now a STATEFUL
integer-pixel-stepping follower of the smooth camera: `_cam_step_follow`
steps by round(t_smooth - t_cam), with the sub-pixel remainder carried
by `cam` itself -- deliberately NO separate accumulator (an accumulator
added to that error double-counts the lag and turns smooth-camera
micro-oscillation into a +/-1px per-tick dither; see the
`_cam_step_follow` docstring). Portal transfers re-base BOTH matrices by
an EXACT right-multiplication with no rounding at all (`_cam_rebase`).

`test_transfer_rebase_is_exact` is fail-first: against the pre-fix
`_set_cam`-only implementation it raises `AttributeError` (no
`_cam_rebase` -- the fix's re-base mechanism doesn't exist yet). The other tests pin the mechanism's invariants (integer whole-pixel steps,
bounded drift, exact re-base algebra), and the two director-correction
tests (transitive span phase lock; world-aligned frame comparison) are
fail-first too now that the polygon side is 141 (see the note at `S` --
the old bug's lattice shift is frac(zoom * m9-translation), and a
zoom-integer side like 140 hides it by coincidence; pre-fix, S=141
yields a persistent -0.35px M-delta fraction across the first
transfer).

Empirical reproduction against the real campaign level:
`tools/playtest/camera_phase_check.py` on a `--record` capture of
seed-7 aggro l01. Consecutive mode, pre-fix: tick 226->227 is a
half-integer frame shift (dx=-3.50, dy=-0.50) with residual 3.2x the
neighbor median; post-fix: integer, in-family. Span mode (the
director's persistent form), pre-fix: ticks 220->232 total shift
(-37.50, -0.25), integer-constrained fit 1.52x worse -- the +0.50 dx
phase offset persists after the crossing; post-fix: dx exactly 0.00
fractional. (Matrix-level ground truth post-fix: every span 1->299
across all six transfers has fractional part +0.0000.)
"""
from __future__ import annotations

import math
import os
import random

import numpy as np

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pytest

import necore
from perihelion.levels import LevelBuilder
from perihelion.render import INTERNAL_W, INTERNAL_H
from perihelion.sim import GameSession, InputFrame

EPS = 1e-6


def _lin(m):
    return (m[0], m[1], m[3], m[4], m[6], m[7], m[8])


def _is_identity_linear(m) -> bool:
    a, b, c, d, e, f, g = _lin(m)
    return (abs(a - 1) < 1e-9 and abs(b) < 1e-9 and abs(c) < 1e-9
            and abs(d - 1) < 1e-9 and abs(e) < 1e-9 and abs(f) < 1e-9
            and abs(g - 1) < 1e-9)


def _is_integer(v: float, eps: float = EPS) -> bool:
    return abs(v - round(v)) < eps


# ---------------------------------------------------------------------
# world: two full-open-edge quad polygons connected on MISMATCHED compass
# sides (A's east edge to B's north edge) -- forces the engine to solve
# a genuinely ROTATED m9, plus a third polygon attached in the ordinary
# (unrotated) way for mixed coverage.
# ---------------------------------------------------------------------

# Polygon side chosen ADVERSARIALLY for the pixel-snap defect: the old
# code's lattice shift at a re-base is frac(zoom * m9-translation
# components), so a side length whose zoom-multiple is integer (140 *
# 1.35 = 189) makes the old bug invisible by coincidence -- an early
# version of this file used 140 and its from-scratch reproduction
# attempts failed for exactly that reason. 141 * 1.35 = 190.35 keeps the
# fractional part alive, matching the irregular polygon offsets of the real
# campaign levels where the director saw the defect.
S = 141.0


def _quad(b: LevelBuilder, x: float, y: float) -> int:
    # engine-canonical winding is negative shoelace (author y-down
    # visual-CCW, per LevelBuilder.ngon's comment) -- (x,y) -> (x,y+S) ->
    # (x+S,y+S) -> (x+S,y) satisfies that for a plain square.
    return b.polygon([(x, y), (x, y + S), (x + S, y + S), (x + S, y)],
                  detail_seed=int(x * 3 + y * 5) & 0xFFFF, kind="corridor")


def build_rotated_world():
    """A (start) --[A.east <-> B.north, ROTATED]--> B --[B.south <->
    C.north, plain]--> C. Full-open edges (whole side is the crossing
    zone), so a straight push reliably crosses without needing to aim at
    a narrow door."""
    b = LevelBuilder("camera-phase-lock", tier=1, ambience="amb_drone_early")
    ra = _quad(b, 0, 0)
    rb = _quad(b, 1000, 0)
    rc = _quad(b, 2000, 0)
    # A's east edge midpoint <-> B's north edge midpoint: perpendicular
    # edge directions, so resolve() must rotate m9 to align them.
    # (polygons are placed at independent absolute offsets on the authoring
    # canvas -- connect_pts matches by nearest edge to each polygon's OWN
    # absolute verts, so points must be given in each polygon's placement.)
    b.connect_pts(ra, (S, S / 2), rb, (1000 + S / 2, 0))
    # B's south edge <-> C's north edge: matching orientation, plain
    # translation transfer.
    b.connect_pts(rb, (1000 + S / 2, S), rc, (2000 + S / 2, 0))
    b.player(ra, (S / 2, S / 2))
    b.exit(rc, (S / 2, S / 2))
    # static (world-anchored) lights in every polygon: the world is
    # zero-ambient and the player's attached lamp moves with them, so
    # the world-aligned frame test needs illumination that is rigid in
    # world space -- lit static texture is what carries the rounding-
    # lattice evidence
    for (r_, (ox, oy)) in ((ra, (0, 0)), (rb, (1000, 0)), (rc, (2000, 0))):
        b.light(r_, (ox + S / 2, oy + S / 2), intensity=1.0, radius=260.0,
                kind="static")
    return b.build()


def _run(level, ticks: int, seed: int = 7):
    """Drive a real GameSession with a constant screen-space push (like
    tools/playtest/flicker_cross.py's movement()), recording per-tick
    camera state, transfer events, and the accumulated portal base
    B_t (root-polygon coords -> current-polygon coords, composed from every
    transfer's m9), so tests can form the base-independent mapping
    M_t = cam_t . B_t (root frame -> screen)."""
    session = GameSession(level, seed=seed, screen=(INTERNAL_W, INTERNAL_H))

    # spy on the portal re-base to capture each transfer's m9 (test-side
    # observation only; the wrapped method is called through unchanged)
    m9_log = []
    orig_rebase = session._cam_rebase

    def spying_rebase(m9):
        m9_log.append(m9)
        orig_rebase(m9)

    session._cam_rebase = spying_rebase

    base = necore.mat_identity()
    rows = []
    for t in range(1, ticks + 1):
        cam_before = session.cam
        smooth_before = session._cam_smooth
        inp = InputFrame(mx=1.0, my=0.15 * math.sin(t * 0.05),
                         ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                         fire=False, alt=False, interact=False, weapon=0)
        transfers_before = session.metrics["transfers"]
        n_m9 = len(m9_log)
        session.tick(inp)
        transferred = session.metrics["transfers"] != transfers_before
        for m9 in m9_log[n_m9:]:
            # cam_new = cam_old . inv(m9), so B_new = m9 . B_old keeps
            # M = cam . B continuous across the re-base
            base = necore.mat_mul(m9, base)
        rows.append(dict(tick=t, cam_before=cam_before,
                         smooth_before=smooth_before, cam=session.cam,
                         cam_smooth=session._cam_smooth,
                         transferred=transferred,
                         M=necore.mat_mul(session.cam, base)))
    return session, rows


@pytest.fixture(scope="module")
def rotated_run():
    level = build_rotated_world()
    session, rows = _run(level, 500)
    n_transfers = sum(1 for r in rows if r["transferred"])
    assert n_transfers >= 2, (
        f"world didn't produce enough transfers to test ({n_transfers}); "
        "geometry needs adjusting, not a camera-fix regression")
    return session, rows


# ---------------------------------------------------------------------
# 1. phase-lock property: every consecutive NON-transfer tick pair steps
#    the rendered camera by an identity-linear, INTEGER-translation
#    transform. Transfer ticks are checked separately (see
#    test_transfer_rebase_is_exact) because comparing cam_t against
#    cam_{t-1} raw is not meaningful across a polygon-frame change: the
#    re-based matrix legitimately carries the PORTAL's rotation/offset,
#    not a screen-space camera pan. That's not a loophole -- it's
#    exactly what makes _cam_rebase's "zero visible change by
#    construction" claim true (see test_transfer_rebase_is_exact, which
#    verifies the actual claim: the world->screen MAPPING of a shared
#    point is unchanged to float precision across the transfer).
# ---------------------------------------------------------------------

def test_phase_lock_non_transfer_ticks(rotated_run):
    session, rows = rotated_run
    checked = 0
    for r in rows:
        if r["transferred"]:
            continue
        step = necore.mat_mul(r["cam"], necore.mat_inv(r["cam_before"]))
        assert _is_identity_linear(step), (
            f"tick {r['tick']}: non-transfer camera step has a non-identity "
            f"linear part {_lin(step)}")
        assert _is_integer(step[2]) and _is_integer(step[5]), (
            f"tick {r['tick']}: non-transfer camera step translation "
            f"({step[2]}, {step[5]}) is not whole-pixel -- the half-pixel "
            f"bug")
        checked += 1
    assert checked > 400  # sanity: we actually exercised plenty of ticks


def test_phase_lock_transfer_ticks_follow_step_is_integer(rotated_run):
    """The FOLLOW contribution of a transfer tick (after removing the
    exact portal re-base) must still be a whole-pixel step -- the point
    of the fix: transfer ticks are not special-cased into a re-round."""
    session, rows = rotated_run
    checked = 0
    for r in rows:
        if not r["transferred"]:
            continue
        # cam and cam_smooth must share a linear part at every tick,
        # transfer ticks included: _cam_rebase right-multiplies BOTH
        # matrices by the same inv(m9), and _cam_step_follow's whole-
        # pixel translation step never touches the linear part either.
        # (The drift-bound test below is the quantitative half of this
        # same claim: bounded translation-only residual.)
        assert _is_identity_linear(
            necore.mat_mul(r["cam"], necore.mat_inv(r["cam_smooth"]))), (
            f"tick {r['tick']}: rendered/smooth linear parts diverged "
            f"across a transfer")
        checked += 1
    assert checked >= 2


# ---------------------------------------------------------------------
# 2. drift bound: rendered translation never wanders far from smooth.
# ---------------------------------------------------------------------

def test_drift_bound_over_long_wander():
    """|t_cam - t_smooth| <= 0.5px after every follow step (a rebase
    mid-tick leaves the lag unchanged, and the follow runs after it, so
    the end-of-tick lag is always a fresh round() remainder)."""
    level = build_rotated_world()
    session, rows = _run(level, 1000)
    worst = 0.0
    for r in rows:
        dx = abs(r["cam"][2] - r["cam_smooth"][2])
        dy = abs(r["cam"][5] - r["cam_smooth"][5])
        worst = max(worst, dx, dy)
        assert dx <= 0.5 + 1e-9 and dy <= 0.5 + 1e-9, (
            f"tick {r['tick']}: rendered cam drifted {dx:.3f},{dy:.3f}px "
            f"from smooth")
    assert worst <= 0.5 + 1e-9


# ---------------------------------------------------------------------
# 3. transfer-mapping exactness: the composed world->screen mapping of a
#    point carried across the portal is unchanged to float precision --
#    the actual content of "zero visible change by construction".
# ---------------------------------------------------------------------

def test_transfer_rebase_is_exact():
    """Direct algebraic check of `_cam_rebase` against a real session's
    live camera matrices, with a synthetic ROTATED m9 (68 degrees) so
    the rotation-commutes-with-zoom argument is actually exercised, not
    just the identity-rotation case a real level might happen to hit."""
    level = build_rotated_world()
    session = GameSession(level, seed=7, screen=(INTERNAL_W, INTERNAL_H))
    # advance a bit so cam/cam_smooth aren't both fresh identical copies
    for t in range(1, 40):
        session.tick(InputFrame(mx=0.6, my=0.3, ax=INTERNAL_W / 2,
                                ay=INTERNAL_H / 2))

    cam_before = session.cam
    smooth_before = session._cam_smooth
    lag_before = (cam_before[2] - smooth_before[2],
                  cam_before[5] - smooth_before[5])

    theta = math.radians(68.0)
    m9 = necore.mat_mul(necore.mat_translate(37.0, -19.0),
                        necore.mat_rotate(theta))

    session._cam_rebase(m9)

    # (a) linear parts still match between cam and cam_smooth
    assert _is_identity_linear(
        necore.mat_mul(session.cam, necore.mat_inv(session._cam_smooth)))

    # (b) the rendered-vs-smooth sub-pixel lag carries across unchanged
    # (translation difference is invariant under a shared right-multiply
    # when the linear parts are equal)
    lag_after = (session.cam[2] - session._cam_smooth[2],
                 session.cam[5] - session._cam_smooth[5])
    assert math.isclose(lag_after[0], lag_before[0], abs_tol=1e-9)
    assert math.isclose(lag_after[1], lag_before[1], abs_tol=1e-9)

    # (c) the actual claim: rendered_new(m9(p)) == rendered_old(p) for
    # an arbitrary world point p, to float precision.
    for p in [(0.0, 0.0), (37.0, -12.0), (-500.0, 220.0), (S / 2, S / 2)]:
        left = necore.mat_apply(session.cam, *necore.mat_apply(m9, *p))
        right = necore.mat_apply(cam_before, *p)
        assert math.isclose(left[0], right[0], abs_tol=1e-6), (p, left, right)
        assert math.isclose(left[1], right[1], abs_tol=1e-6), (p, left, right)

    # (d) same exactness for the smooth copy
    for p in [(0.0, 0.0), (37.0, -12.0)]:
        left = necore.mat_apply(session._cam_smooth, *necore.mat_apply(m9, *p))
        right = necore.mat_apply(smooth_before, *p)
        assert math.isclose(left[0], right[0], abs_tol=1e-6)
        assert math.isclose(left[1], right[1], abs_tol=1e-6)


# ---------------------------------------------------------------------
# 4. the reported defect signature, at the matrix level: a snap-every-
#    tick-from-absolute implementation (the OLD `_set_cam`-only design)
#    disagrees with the new stateful follower by up to 0.5px specifically
#    at a transfer tick. This test pins the NEW behavior directly
#    (doesn't need image capture) and documents the old formula inline
#    so the regression is legible without re-reading git history.
# ---------------------------------------------------------------------

def test_no_half_pixel_step_at_transfer():
    level = build_rotated_world()
    session, rows = _run(level, 500)
    transfer_ticks = [r["tick"] for r in rows if r["transferred"]]
    assert transfer_ticks
    for r in rows:
        if not r["transferred"]:
            continue
        # Under the OLD design the transfer tick re-rounded the re-based
        # absolute translation, letting the rendered mapping step by a
        # half-integer tied to the zoom-scaled polygon offset; under the
        # fix every tick -- transfer or not -- decomposes into (exact
        # rebase) + (whole-pixel follow), so the end-of-tick rendered-
        # vs-smooth lag at a transfer tick obeys the same 0.5px bound
        # as every other tick instead of jumping by a polygon-offset
        # fraction.
        dx = abs(r["cam"][2] - r["cam_smooth"][2])
        dy = abs(r["cam"][5] - r["cam_smooth"][5])
        assert dx <= 0.5 + 1e-9 and dy <= 0.5 + 1e-9, r["tick"]


# ---------------------------------------------------------------------
# 5. transitive phase lock across ARBITRARY spans (director correction,
#    2026-07-12): the defect's dominant visible form is not the one-tick
#    transition flash but a PERSISTENT phase shift -- after a bad
#    re-base, integer stepping resumes in the new lattice phase, so
#    consecutive-tick diffs go quiet while every thin line in the world
#    stays re-rounded until the next transfer. A pairwise consecutive
#    check can in principle be fooled by compensating errors; this test
#    asserts the invariant in its world-side, transitive form: for ANY
#    two ticks t1 < t2 -- spanning any number of transfers, rotated ones
#    included -- the root-frame mappings M_t = cam_t . B_t satisfy
#    M_t2 . inv(M_t1) = T(integer dx, integer dy). Fail-first: under the
#    OLD re-round-at-transfer code the fractional part jumps to a
#    polygon-offset fraction the moment a span crosses a transfer, and
#    STAYS there for every later t2 (the persistent form, seen at
#    matrix level).
# ---------------------------------------------------------------------

def test_phase_lock_transitive_across_spans(rotated_run):
    session, rows = rotated_run
    M = {r["tick"]: r["M"] for r in rows}
    transfer_ticks = [r["tick"] for r in rows if r["transferred"]]
    assert len(transfer_ticks) >= 2
    first, last = rows[0]["tick"], rows[-1]["tick"]
    # deliberate span choices: whole run, across one transfer, across
    # all transfers, tight around each transfer, and a no-transfer
    # control
    pairs = [(first, last),
             (first, transfer_ticks[0] + 5),
             (transfer_ticks[0] - 5, transfer_ticks[-1] + 5),
             (transfer_ticks[0] + 1, transfer_ticks[1] + 1),
             (first, transfer_ticks[0] - 1)]
    for tt in transfer_ticks:
        pairs.append((max(first, tt - 10), min(last, tt + 10)))
    for t1, t2 in pairs:
        D = necore.mat_mul(M[t2], necore.mat_inv(M[t1]))
        assert _is_identity_linear(D), (
            f"span {t1}->{t2}: root-frame camera delta has non-identity "
            f"linear part {_lin(D)}")
        assert _is_integer(D[2]) and _is_integer(D[5]), (
            f"span {t1}->{t2}: persistent phase offset "
            f"({D[2] - round(D[2]):+.4f}, {D[5] - round(D[5]):+.4f}) -- "
            f"the world's rounding lattice shifted across this span")


# ---------------------------------------------------------------------
# 6. world-aligned FRAME comparison across a crossing (the instrument
#    that matches what the director actually sees): render real frames
#    well before and well after a transfer, align them by the total
#    integer camera motion (from the matrix-level M mappings), and
#    demand the overlapping world region is pixel-identical outside a
#    small exclusion box around the player. Consecutive-frame diffs are
#    blind to the persistent phase offset; THIS comparison is not: under
#    the old code the whole aligned overlap re-rounds (thin lines move/
#    recolor relative to world features) and the identical-pixel
#    fraction collapses.
# ---------------------------------------------------------------------

def test_world_aligned_frames_across_crossing():
    from perihelion.render import Renderer
    level = build_rotated_world()
    # zoom pinned: this vector's lit-pixel instrument guard was
    # authored at 1.35; the phase-lock property itself is zoom-free
    session = GameSession(level, seed=7, screen=(INTERNAL_W, INTERNAL_H),
                          zoom=1.35)

    m9_log = []
    orig_rebase = session._cam_rebase
    session._cam_rebase = lambda m9: (m9_log.append(m9), orig_rebase(m9))

    ren = Renderer(session)
    surf = (INTERNAL_W, INTERNAL_H)

    base = necore.mat_identity()
    frames = {}   # tick -> (ndarray HxW rgb, M)
    transfer_ticks = []
    for t in range(1, 140):
        n_m9 = len(m9_log)
        before = session.metrics["transfers"]
        session.tick(InputFrame(mx=1.0, my=0.0, ax=INTERNAL_W / 2,
                                ay=INTERNAL_H / 2))
        if session.metrics["transfers"] != before:
            transfer_ticks.append(t)
        for m9 in m9_log[n_m9:]:
            base = necore.mat_mul(m9, base)
        ren.consume_fx(session.fx)
        arr = np.transpose(ren.draw(surf), (1, 0, 2)).copy()
        frames[t] = (arr, necore.mat_mul(session.cam, base))
    assert transfer_ticks, "no transfer happened; world drive broken"
    tt = transfer_ticks[0]
    t1, t2 = tt - 10, tt + 10
    (a, M1), (b, M2) = frames[t1], frames[t2]

    D = necore.mat_mul(M2, necore.mat_inv(M1))
    assert _is_identity_linear(D)
    dx, dy = round(D[2]), round(D[5])
    assert abs(D[2] - dx) < 1e-6 and abs(D[5] - dy) < 1e-6

    # shift frame a by (dx, dy) and intersect with b
    h, w, _ = a.shape
    ax0, ax1 = max(0, -dx), min(w, w - dx)
    ay0, ay1 = max(0, -dy), min(h, h - dy)
    a_ov = a[ay0:ay1, ax0:ax1]
    b_ov = b[ay0 + dy:ay1 + dy, ax0 + dx:ax1 + dx]
    assert a_ov.size > 0.2 * a.size, "overlap too small to be meaningful"

    same = np.all(a_ov == b_ov, axis=2)
    # Score only pixels that carry world texture (lit by the STATIC
    # polygon lights) -- the world is zero-ambient, so black-on-black
    # matches outside the lit wedges are trivially identical and would
    # dilute the metric. And exclude the player's own attached-lamp
    # pool (radius 85wu ~ 115px at zoom 1.35, centered on the player at
    # screen center): it moves with the player, so its falloff
    # gradient legitimately differs between the two world positions.
    lit = (a_ov.max(axis=2) > 8) | (b_ov.max(axis=2) > 8)
    cy, cx = h // 2 - ay0, w // 2 - ax0
    lit[max(0, cy - 140):cy + 140, max(0, cx - 140):cx + 140] = False
    n_lit = int(lit.sum())
    assert n_lit > 5000, (
        f"only {n_lit} static-lit pixels in the overlap; the test world's "
        "lights are wrong, not the camera")
    frac_same = float(np.mean(same[lit]))
    # Measured calibration (2026-07-12): post-fix 0.9985 identical;
    # pre-fix 0.9148 (the -0.35px persistent lattice shift for S=141
    # re-rounds the texel columns whose fraction crosses the rounding
    # boundary -- roughly a third of thin-line pixels). 0.97 splits the
    # two with margin on both sides.
    assert frac_same >= 0.97, (
        f"world-aligned static-lit overlap only {frac_same:.3f} identical "
        f"across the crossing at ticks {t1}->{t2} (shift {dx},{dy}): "
        f"persistent camera phase shift or renderer instability")
