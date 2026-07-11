"""tools/artgen/texture_checks.py

Programmatic (non-LLM) gates for the rebuilt floor-texture pipeline. Pure
PIL/numpy, no pygame/necore -- cheap to run on every candidate BEFORE any
paid Gemini judging call, per the director's ruling ("reject those before
any expensive judging").

Two independent defects this catches:

1. NEGATIVE SPACE (full-bleed law): the model painted a frame, wall band,
   or vignette INSIDE the floor polygon instead of letting the material
   run to every edge. Detected as a systematic luminance drop and/or
   elevated local structure (a drawn border line) in a band near the
   polygon boundary vs. the polygon interior.
2. NON-TILEABILITY: a per-kind base material that does not tile cleanly.
   Detected by tiling 2x2 and comparing gradient magnitude across the
   seam lines to the interior average.

Also: per-kind mean-luminance/chroma "windows" so adjacent same-kind rooms
can be graded toward one shared tone family (style continuity).
"""
from __future__ import annotations

import numpy as np
from PIL import Image, ImageFilter


# ---------------------------------------------------------------------------
# full-bleed / negative-space check
# ---------------------------------------------------------------------------

def _erode_mask(mask: np.ndarray, px: int) -> np.ndarray:
    """Shrink a boolean mask by `px` pixels (min-filter erosion). Pads with
    False first: PIL's MinFilter replicates edge pixels rather than
    treating the array boundary as background, so an un-padded full-canvas
    mask (e.g. a material swatch with no polygon) would never erode at the
    image border -- exactly the case we most need to catch a vignette in."""
    if px <= 0:
        return mask
    h, w = mask.shape
    pad = px + 1
    padded = np.zeros((h + 2 * pad, w + 2 * pad), dtype=bool)
    padded[pad:pad + h, pad:pad + w] = mask
    im = Image.fromarray((padded.astype(np.uint8) * 255), mode="L")
    im = im.filter(ImageFilter.MinFilter(2 * px + 1))
    out = np.asarray(im) > 127
    return out[pad:pad + h, pad:pad + w]


def verify_fullbleed(im: Image.Image, mask: np.ndarray | None = None,
                      band_px: int = 12, darken_thresh: float = 1.30,
                      struct_thresh: float = 1.7) -> dict:
    """Compare a band near the polygon boundary (or image edge, if
    mask=None) to the polygon interior. `ok=False` means a painted
    frame/vignette/wall-band was detected: reject before Gemini judging.
    """
    gray = np.asarray(im.convert("L")).astype(np.float32)
    h, w = gray.shape
    if mask is None:
        mask = np.ones((h, w), dtype=bool)
    if mask.shape != (h, w):
        raise ValueError(f"mask shape {mask.shape} != image shape {(h, w)}")

    inner = _erode_mask(mask, band_px)
    edge_band = mask & ~inner
    center = _erode_mask(mask, band_px * 3)

    if edge_band.sum() < 40 or center.sum() < 40:
        return dict(ok=True, reason="region too small to judge (thin polygon)",
                    edge_mean=None, center_mean=None)

    edge_mean = float(gray[edge_band].mean())
    center_mean = float(gray[center].mean())
    gy, gx = np.gradient(gray)
    grad = np.sqrt(gx ** 2 + gy ** 2)
    edge_grad = float(grad[edge_band].mean())
    center_grad = float(grad[center].mean())

    darken_ratio = center_mean / max(edge_mean, 1e-6)
    grad_ratio = edge_grad / max(center_grad, 1e-6)
    border_darkening = darken_ratio > darken_thresh
    border_structure = grad_ratio > struct_thresh
    ok = not (border_darkening or border_structure)
    return dict(ok=ok, edge_mean=edge_mean, center_mean=center_mean,
                darken_ratio=darken_ratio, edge_grad=edge_grad,
                center_grad=center_grad, grad_ratio=grad_ratio,
                border_darkening=border_darkening,
                border_structure=border_structure)


def verify_no_interior_void(im: Image.Image, mask: np.ndarray,
                             black_thresh: float = 12.0,
                             frac_thresh: float = 0.02) -> dict:
    """Catch INVENTED CORNER/INTERIOR VOID: the model paints a chamfered or
    octagonal room silhouette (solid near-black wedges, usually at corners)
    over a base truth whose true polygon (per level geometry) has no such
    notch there. verify_fullbleed's edge-band-vs-center comparison misses
    this because a localized corner wedge is diluted by the rest of a
    uniform edge band; this check instead measures what fraction of the
    pixels the ANALYTIC MASK says are real floor are painted near-black --
    real floor material is never more than a few percent near-black even
    with heavy grime/shadow, whereas an invented void wedge pushes this
    well past frac_thresh (measured: ~4% on a caught real defect vs
    0.2-0.9% on clean accepted rooms). `mask` must be the true polygon
    mask, resized to `im`'s pixel size, True = real floor.
    """
    gray = np.asarray(im.convert("L")).astype(np.float32)
    if mask.shape != gray.shape:
        raise ValueError(f"mask shape {mask.shape} != image shape {gray.shape}")
    in_mask = gray[mask]
    if in_mask.size < 40:
        return dict(ok=True, reason="region too small to judge (thin polygon)",
                    black_frac=None)
    black_frac = float((in_mask < black_thresh).mean())
    ok = black_frac <= frac_thresh
    return dict(ok=ok, black_frac=black_frac, frac_thresh=frac_thresh)


# ---------------------------------------------------------------------------
# tileable base material: offset-wrap + mirror-feather seam repair, verified
# by tiling 2x2 and measuring the seam
# ---------------------------------------------------------------------------

def make_tileable(im: Image.Image, band_frac: float = 0.13) -> Image.Image:
    """Offset-wrap `im` by half its size (moves the seam to the middle),
    then feathers a band across each seam by cross-fading mirrored content
    cloned from just outside the band on either side. Keeps ~35% of the
    original wrapped content in the band so the repair doesn't read as a
    flat smear."""
    arr = np.asarray(im.convert("RGB")).astype(np.float32)
    h, w, _ = arr.shape
    arr = np.roll(arr, shift=w // 2, axis=1)
    arr = np.roll(arr, shift=h // 2, axis=0)

    band_w = max(4, int(w * band_frac))
    band_h = max(4, int(h * band_frac))

    x0 = max(band_w, w // 2 - band_w // 2)
    x1 = min(w - band_w, x0 + band_w)
    if x1 > x0:
        left_src = arr[:, x0 - band_w:x0][:, ::-1, :]
        right_src = arr[:, x1:x1 + band_w][:, ::-1, :]
        n = x1 - x0
        ramp = np.linspace(0, 1, n, dtype=np.float32)[None, :, None]
        blend = left_src[:, :n] * (1 - ramp) + right_src[:, :n] * ramp
        arr[:, x0:x1] = arr[:, x0:x1] * 0.15 + blend * 0.85

    y0 = max(band_h, h // 2 - band_h // 2)
    y1 = min(h - band_h, y0 + band_h)
    if y1 > y0:
        top_src = arr[y0 - band_h:y0, :][::-1, :, :]
        bot_src = arr[y1:y1 + band_h, :][::-1, :, :]
        n = y1 - y0
        ramp = np.linspace(0, 1, n, dtype=np.float32)[:, None, None]
        blend = top_src[:n] * (1 - ramp) + bot_src[:n] * ramp
        arr[y0:y1, :] = arr[y0:y1, :] * 0.15 + blend * 0.85

    out = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), mode="RGB")
    # a light blur confined to the seam bands mops up any residual
    # structure the mirror-feather blend didn't fully hide (this is what
    # made horizontal seams fail more often than vertical -- rivet-line
    # material has strong horizontal edges the linear feather alone
    # doesn't erase). Stronger on the y band to match its wider band.
    blurred = out.filter(ImageFilter.GaussianBlur(radius=max(2, band_w // 6)))
    arr_out = np.asarray(out).astype(np.float32)
    arr_blur = np.asarray(blurred).astype(np.float32)
    if x1 > x0:
        arr_out[:, x0:x1] = arr_blur[:, x0:x1]
    if y1 > y0:
        arr_out[y0:y1, :] = arr_blur[y0:y1, :]
    return Image.fromarray(np.clip(arr_out, 0, 255).astype(np.uint8), mode="RGB")


def verify_tiling(im: Image.Image, band_px: int = 6,
                   ratio_thresh: float = 1.6) -> dict:
    """Tile `im` 2x2 and compare gradient magnitude across the internal
    seam lines to the interior average. High ratio = visible seam."""
    gray = np.asarray(im.convert("L")).astype(np.float32)
    h, w = gray.shape
    tiled = np.tile(gray, (2, 2))
    gy, gx = np.gradient(tiled)
    grad = np.sqrt(gx ** 2 + gy ** 2)
    interior_mean = float(grad.mean())
    seam_v = float(grad[:, w - band_px:w + band_px].mean())
    seam_h = float(grad[h - band_px:h + band_px, :].mean())
    ratio_v = seam_v / max(interior_mean, 1e-6)
    ratio_h = seam_h / max(interior_mean, 1e-6)
    ok = ratio_v < ratio_thresh and ratio_h < ratio_thresh
    return dict(ok=ok, ratio_v=ratio_v, ratio_h=ratio_h,
                interior_mean=interior_mean, seam_v=seam_v, seam_h=seam_h)


# ---------------------------------------------------------------------------
# per-kind luminance/chroma window (style continuity, property 2)
# ---------------------------------------------------------------------------

def region_tone(im: Image.Image, mask: np.ndarray | None = None) -> dict:
    """Mean L (luminance 0..255) and mean R,G,B over `mask` (or whole
    image)."""
    rgb = np.asarray(im.convert("RGB")).astype(np.float32)
    h, w, _ = rgb.shape
    if mask is None:
        mask = np.ones((h, w), dtype=bool)
    px = rgb[mask]
    if px.size == 0:
        return dict(mean_l=0.0, mean_r=0.0, mean_g=0.0, mean_b=0.0)
    mean_rgb = px.mean(axis=0)
    mean_l = 0.2126 * mean_rgb[0] + 0.7152 * mean_rgb[1] + 0.0722 * mean_rgb[2]
    return dict(mean_l=float(mean_l), mean_r=float(mean_rgb[0]),
                mean_g=float(mean_rgb[1]), mean_b=float(mean_rgb[2]))


def in_window(tone: dict, window: dict, l_tol: float = 14.0,
              chroma_tol: float = 16.0) -> bool:
    if abs(tone["mean_l"] - window["mean_l"]) > l_tol:
        return False
    for ch in ("mean_r", "mean_g", "mean_b"):
        if abs(tone[ch] - window[ch]) > chroma_tol:
            return False
    return True


def grade_toward(im: Image.Image, mask: np.ndarray, window: dict,
                  strength: float = 0.6) -> Image.Image:
    """Nudge `im`'s masked-region mean R/G/B a fraction `strength` of the
    way toward `window`'s target means -- a per-channel gain, not a full
    recolor, so material detail survives. Unmasked (void) pixels are left
    untouched."""
    arr = np.asarray(im.convert("RGB")).astype(np.float32)
    tone = region_tone(im, mask)
    out = arr.copy()
    for i, ch in enumerate(("mean_r", "mean_g", "mean_b")):
        cur = max(tone[ch], 1e-3)
        target = tone[ch] + strength * (window[ch] - tone[ch])
        gain = target / cur
        gain = float(np.clip(gain, 0.6, 1.6))
        out[..., i][mask] = arr[..., i][mask] * gain
    out = np.clip(out, 0, 255).astype(np.uint8)
    return Image.fromarray(out, mode="RGB")
