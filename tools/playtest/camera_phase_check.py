"""Fractional camera-shift analysis for a `--record` capture.

Two instruments for the same defect (the transfer-tick pixel-snap
disagreement), matching its two visible forms:

CONSECUTIVE mode (--start/--end): fits a per-tick-pair translation
between consecutive recorded frames by a 0.25px-step brute-force search
on an interior crop (avoids HUD/edge artifacts), scoring by mean squared
difference after bilinear resampling. A HALF-integer shift with an
outlier-elevated residual relative to neighbors is the TRANSITION
signature: the tick at which the camera's rounding lattice jumps,
re-rasterizing every 1px seam/grate line at once.

SPAN mode (--span T1 T2): world-aligned comparison of two frames far
apart -- one before and one after a polygon crossing. Coarse-aligns by FFT
phase correlation, then refines at 0.25px steps around the coarse peak.
This is the instrument for the PERSISTENT form of the defect: after a
bad re-base the rounding lattice shifts and STAYS shifted -- integer
stepping resumes in the new phase, so consecutive-tick diffs go quiet
again while every thin line in the world remains re-rounded relative to
its pre-crossing appearance until the next transfer re-rolls the phase.
A healthy camera gives an INTEGER total shift across any span, transfers
included (the per-tick integer steps compose transitively and an exact
re-base contributes zero); a fractional best-fit total shift, with the
integer-constrained fit measurably worse, is the persistent phase offset
seen as "the texture lines changed and stayed changed".

Lesson encoded here: consecutive-frame diffs are blind to persistent
phase offsets; world-aligned comparisons are the instrument for those.

Instrument limits (measured on seed-7 aggro l01 pre/post the 2026-07-12
camera fix): with combat/enemies/aim-light churn in frame the sub-pixel
fit carries ~+/-0.25px content noise even when the camera lattice is
provably integer-locked (matrix-level check), so read SPAN results as:
fractional part >= ~0.4 on an axis = real phase offset (the defect's
quantum is 0.5); <= 0.25 = re-run over a quieter window before
concluding. Quiet-window controls read exact 0.00. The authoritative
zero-noise check is matrix-level: game/tests/test_camera_phase_lock.py
::test_phase_lock_transitive_across_spans tracks the accumulated portal
bases and asserts cam_t2 . B . inv(cam_t1) is an integer translation for
arbitrary tick pairs.

Usage:
    uv run python tools/playtest/camera_phase_check.py --rec DIR \
        --start 220 --end 233 [--record-every 1]
    uv run python tools/playtest/camera_phase_check.py --rec DIR \
        --span 220 232 [--record-every 1]
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image


def load_gray(path: Path) -> np.ndarray:
    im = Image.open(path).convert("L")
    return np.asarray(im, dtype=np.float64)


def highpass(img: np.ndarray, k: int = 5) -> np.ndarray:
    """Subtract a k x k box blur: keeps the 1px seam/grate lines the
    phase analysis cares about, discards low-frequency content (the
    player's light pool, polygon shading) whose smooth motion otherwise
    biases the sub-pixel fit by fractions of a pixel."""
    kern = np.ones(k) / k
    blur = np.apply_along_axis(
        lambda r: np.convolve(r, kern, mode="same"), 1, img)
    blur = np.apply_along_axis(
        lambda c: np.convolve(c, kern, mode="same"), 0, blur)
    return img - blur


def bilinear_shift(img: np.ndarray, dx: float, dy: float) -> np.ndarray:
    """Shift `img` by (dx, dy) (new = old shifted so that new[y,x] ==
    old[y - dy, x - dx]) via bilinear interpolation, cropping to the
    region where both source and destination are in-bounds."""
    h, w = img.shape
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float64)
    sx = xs - dx
    sy = ys - dy
    x0 = np.floor(sx).astype(int)
    y0 = np.floor(sy).astype(int)
    fx = sx - x0
    fy = sy - y0
    x1 = x0 + 1
    y1 = y0 + 1
    valid = (x0 >= 0) & (x1 < w) & (y0 >= 0) & (y1 < h)
    x0c = np.clip(x0, 0, w - 1)
    x1c = np.clip(x1, 0, w - 1)
    y0c = np.clip(y0, 0, h - 1)
    y1c = np.clip(y1, 0, h - 1)
    v00 = img[y0c, x0c]
    v01 = img[y0c, x1c]
    v10 = img[y1c, x0c]
    v11 = img[y1c, x1c]
    out = (v00 * (1 - fx) * (1 - fy) + v01 * fx * (1 - fy)
           + v10 * (1 - fx) * fy + v11 * fx * fy)
    return out, valid


def best_shift(a: np.ndarray, b: np.ndarray, search: float = 6.0,
                step: float = 0.25):
    """Find (dx, dy) minimizing SSD(b, shift(a, dx, dy)) over integer and
    quarter-pixel candidates in [-search, search]^2. Returns
    (dx, dy, residual_per_px, residual_at_nearest_half)."""
    best = None
    n = int(round(search / step))
    offsets = [(-search + i * step) for i in range(2 * n + 1)]
    for dy in offsets:
        for dx in offsets:
            shifted, valid = bilinear_shift(a, dx, dy)
            diff = (shifted - b)[valid]
            if diff.size == 0:
                continue
            ssd = float(np.mean(diff * diff))
            if best is None or ssd < best[2]:
                best = (dx, dy, ssd)
    return best


def frac(v: float) -> float:
    return v - round(v)


def coarse_shift_fft(a: np.ndarray, b: np.ndarray) -> tuple[int, int]:
    """Integer (dx, dy) aligning a -> b by FFT phase correlation
    (handles large pans that the brute-force refine can't afford)."""
    fa = np.fft.fft2(a - a.mean())
    fb = np.fft.fft2(b - b.mean())
    cross = fa * np.conj(fb)
    denom = np.abs(cross)
    denom[denom == 0] = 1.0
    corr = np.fft.ifft2(cross / denom).real
    py, px = np.unravel_index(np.argmax(corr), corr.shape)
    h, w = a.shape
    dy = -(py if py <= h // 2 else py - h)
    dx = -(px if px <= w // 2 else px - w)
    return int(dx), int(dy)


def span_shift(a: np.ndarray, b: np.ndarray, refine: float = 2.0,
               step: float = 0.25, mask: np.ndarray | None = None):
    """World-aligned total shift a -> b: coarse FFT phase correlation,
    then 0.25px brute-force refinement around the coarse peak. `mask`
    (True = include) excludes regions with moving content -- the player
    and combat effects sit at screen center in a `--record` capture and
    bias the sub-pixel fit if left in. Returns
    (dx, dy, residual, residual_at_nearest_integer)."""
    cx, cy = coarse_shift_fft(a, b)
    if mask is None:
        mask = np.ones_like(a, dtype=bool)
    best = None
    n = int(round(refine / step))
    offs = [(-refine + i * step) for i in range(2 * n + 1)]

    def score(dx, dy):
        shifted, valid = bilinear_shift(a, dx, dy)
        sel = valid & mask
        diff = (shifted - b)[sel]
        if diff.size == 0:
            return None
        return float(np.mean(diff * diff))

    for oy in offs:
        for ox in offs:
            dx, dy = cx + ox, cy + oy
            ssd = score(dx, dy)
            if ssd is not None and (best is None or ssd < best[2]):
                best = (dx, dy, ssd)
    dx, dy, ssd = best
    int_ssd = score(float(round(dx)), float(round(dy)))
    return dx, dy, ssd, int_ssd


def main(argv=None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--rec", required=True)
    p.add_argument("--start", type=int, default=None,
                   help="first tick (inclusive) of the consecutive range")
    p.add_argument("--end", type=int, default=None,
                   help="last tick (inclusive)")
    p.add_argument("--span", type=int, nargs=2, metavar=("T1", "T2"),
                   default=None,
                   help="world-aligned comparison of two far-apart ticks")
    p.add_argument("--record-every", type=int, default=1)
    p.add_argument("--crop", default="80,80,-80,-80",
                   help="top,left,-bottom,-right margins to trim (avoid HUD)")
    args = p.parse_args(argv)
    if args.span is None and (args.start is None or args.end is None):
        p.error("either --span T1 T2 or --start/--end is required")

    rec = Path(args.rec)
    top, left, negbot, negright = (int(x) for x in args.crop.split(","))

    def frame_path(tick: int) -> Path:
        idx = tick // args.record_every
        return rec / f"frame_{idx:06d}.png"

    if args.span is not None:
        t1, t2 = args.span
        a = highpass(load_gray(frame_path(t1)))[top:negbot, left:negright]
        b = highpass(load_gray(frame_path(t2)))[top:negbot, left:negright]
        # exclude the screen-center box: the player (and their muzzle
        # flashes / hit sparks) live there in a bot capture and drag the
        # sub-pixel fit toward their own motion
        mask = np.ones_like(a, dtype=bool)
        h, w = a.shape
        mask[h // 2 - 70:h // 2 + 70, w // 2 - 100:w // 2 + 100] = False
        dx, dy, ssd, int_ssd = span_shift(a, b, mask=mask)
        fx, fy = abs(frac(dx)), abs(frac(dy))
        fractional = fx > 0.2 or fy > 0.2
        print(f"span {t1}->{t2}: total shift ({dx:.2f}, {dy:.2f})  "
              f"residual {ssd:.4f}  integer-constrained {int_ssd:.4f}")
        if fractional:
            print(f"  PERSISTENT PHASE OFFSET: fractional part "
                  f"({frac(dx):+.2f}, {frac(dy):+.2f}); the world's thin "
                  f"lines are re-rounded relative to tick {t1} and stay "
                  f"that way (integer fit is "
                  f"{int_ssd / max(ssd, 1e-9):.2f}x worse)")
        else:
            print("  integer total shift: rounding lattice preserved "
                  "across the span (no persistent phase offset)")
        return 1 if fractional else 0

    print(f"{'tick pair':<14}{'dx':>7}{'dy':>7}{'residual':>12}{'half-int?':>11}")
    residuals = []
    rows = []
    for t in range(args.start, args.end):
        fa, fb = frame_path(t), frame_path(t + 1)
        if not fa.exists() or not fb.exists():
            print(f"{t}->{t+1}: missing frame ({fa.name} or {fb.name})")
            continue
        a = load_gray(fa)[top:negbot, left:negright]
        b = load_gray(fb)[top:negbot, left:negright]
        dx, dy, ssd = best_shift(a, b)
        half = (abs(frac(dx * 2) ) < 1e-9 and abs(dx - round(dx)) > 0.2) or \
               (abs(frac(dy * 2)) < 1e-9 and abs(dy - round(dy)) > 0.2)
        residuals.append(ssd)
        rows.append((t, dx, dy, ssd, half))
        print(f"{t}->{t+1:<8}{dx:>7.2f}{dy:>7.2f}{ssd:>12.4f}{'  <-- HALF' if half else '':>11}")

    if residuals:
        med = float(np.median(residuals))
        print(f"\nmedian residual: {med:.4f}")
        for t, dx, dy, ssd, half in rows:
            if half or ssd > 3 * med:
                print(f"  outlier: tick {t}->{t+1} dx={dx:.2f} dy={dy:.2f} "
                      f"residual={ssd:.4f} ({ssd/med:.1f}x median)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
