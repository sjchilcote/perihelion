"""tools/artgen/texture_checks.py

Programmatic (non-LLM) gates for the rebuilt floor-texture pipeline. Pure
PIL/numpy, no necore -- cheap to run on every candidate BEFORE any
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

Also: per-kind mean-luminance/chroma "windows" so adjacent same-kind polygons
can be graded toward one shared tone family (style continuity).
"""
from __future__ import annotations

import math

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


def _dilate_mask(mask: np.ndarray, px: int) -> np.ndarray:
    """Grow a boolean mask by `px` pixels (max-filter dilation)."""
    if px <= 0:
        return mask
    h, w = mask.shape
    pad = px + 1
    padded = np.zeros((h + 2 * pad, w + 2 * pad), dtype=bool)
    padded[pad:pad + h, pad:pad + w] = mask
    im = Image.fromarray((padded.astype(np.uint8) * 255), mode="L")
    im = im.filter(ImageFilter.MaxFilter(2 * px + 1))
    out = np.asarray(im) > 127
    return out[pad:pad + h, pad:pad + w]


def verify_fullbleed(im: Image.Image, mask: np.ndarray | None = None,
                      band_px: int = 12, darken_thresh: float = 1.30,
                      struct_thresh: float = 1.7,
                      boxes: list | None = None) -> dict:
    """Compare a band near the polygon boundary (or image edge, if
    mask=None) to the polygon interior. `ok=False` means a painted
    frame/vignette/wall-band was detected: reject before Gemini judging.

    `boxes` (optional, list of dicts with pixel-space `box` = (x0,y0,x1,y1),
    same convention as verify_detail_budget) excludes the box-conditioning
    item footprints from the edge band before judging. Root-caused
    2026-07-13: nearly every KIND_ITEM_TEMPLATE entry is a wall-hugging
    strip (PIPE RUN, HAZARD LANE, COT BAY, CABINET ROW, WALL TROUGH, ...)
    that spans a full edge right where this gate samples -- legitimate
    requested equipment there is geometrically identical to the painted
    "frame/vignette" this gate exists to catch, so box-conditioned polygons
    were programmatically full-bleed-rejected at a high rate for content
    the pipeline itself asked for. Excluding box footprints (dilated a
    few px) restores the gate's original intent: catch borders that run
    the WHOLE boundary uninvited, not requested equipment in a labeled
    zone."""
    gray = np.asarray(im.convert("L")).astype(np.float32)
    h, w = gray.shape
    if mask is None:
        mask = np.ones((h, w), dtype=bool)
    if mask.shape != (h, w):
        raise ValueError(f"mask shape {mask.shape} != image shape {(h, w)}")

    inner = _erode_mask(mask, band_px)
    edge_band = mask & ~inner
    center = _erode_mask(mask, band_px * 3)

    if boxes:
        excl = np.zeros((h, w), dtype=bool)
        for b in boxes:
            x0, y0, x1, y1 = b["box"]
            x0, y0 = max(0, x0), max(0, y0)
            x1, y1 = min(w, x1), min(h, y1)
            if x1 > x0 and y1 > y0:
                excl[y0:y1, x0:x1] = True
        if excl.any():
            excl = _dilate_mask(excl, 4)
            edge_band = edge_band & ~excl

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
    octagonal polygon silhouette (solid near-black wedges, usually at corners)
    over a base truth whose true polygon (per level geometry) has no such
    notch there. verify_fullbleed's edge-band-vs-center comparison misses
    this because a localized corner wedge is diluted by the rest of a
    uniform edge band; this check instead measures what fraction of the
    pixels the ANALYTIC MASK says are real floor are painted near-black --
    real floor material is never more than a few percent near-black even
    with heavy grime/shadow, whereas an invented void wedge pushes this
    well past frac_thresh (measured: ~4% on a caught real defect vs
    0.2-0.9% on clean accepted polygons). `mask` must be the true polygon
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
# outer-black-margin normalization
# ---------------------------------------------------------------------------

def crop_outer_black_margin(im: Image.Image, black_thresh: float = 14.0,
                             row_frac: float = 0.985,
                             max_margin_frac: float = 0.08) -> Image.Image:
    """The image model systematically renders the polygon inset by a few
    pixels-to-percent of pure-black margin even when told the floor runs
    flush to the crop (observed on most attempts of the 2026-07-11 sample
    run: correct polygon, correct material, killed by a uniform black gutter).
    Crop any FULLY-black outer rows/cols (>= row_frac of the row/col below
    black_thresh), capped at max_margin_frac of each dimension per side --
    a margin bigger than that is a real layout failure (e.g. the model
    painted the whole neighbor composite) and must NOT be rescued; the
    image is returned unchanged and the downstream full-bleed gate fails
    it honestly. NOTE: polygons whose polygon does not fill its bounding box
    (oblique silhouettes) legitimately have black in the corner regions of
    outer rows/cols -- row_frac only trips on rows/cols that are black
    virtually edge-to-edge, which a diagonal silhouette's bounding rows
    are not."""
    gray = np.asarray(im.convert("L")).astype(np.float32)
    h, w = gray.shape
    dark_row = (gray < black_thresh).mean(axis=1) >= row_frac
    dark_col = (gray < black_thresh).mean(axis=0) >= row_frac

    def run_len(flags) -> int:
        n = 0
        for f in flags:
            if not f:
                break
            n += 1
        return n

    top, bottom = run_len(dark_row), run_len(dark_row[::-1])
    left, right = run_len(dark_col), run_len(dark_col[::-1])
    max_h, max_w = int(h * max_margin_frac), int(w * max_margin_frac)
    if top > max_h or bottom > max_h or left > max_w or right > max_w:
        return im  # too big to be a gutter -- genuine layout failure
    if top == 0 and bottom == 0 and left == 0 and right == 0:
        return im
    return im.crop((left, top, w - right, h - bottom))


# ---------------------------------------------------------------------------
# repetition gate (director's ruling, 2026-07-11: "tiles repeat visibly
# in-polygon" -- the 2x2 seam check above only proves the tile edges match,
# it says nothing about whether a distinctive feature inside the tile
# recurs obviously at the tile period once the material is laid across a
# whole polygon). Autocorrelation of the finished texture: a strong off-center
# peak at a lag other than (0,0) means the image correlates strongly with
# a shifted copy of itself -- i.e. it looks like a stamped repeat.
# ---------------------------------------------------------------------------

def verify_no_repetition(im: Image.Image, mask: np.ndarray | None = None,
                          min_lag_frac: float = 0.12,
                          peak_ratio_thresh: float = 0.28) -> dict:
    """Detect visible in-polygon tiling repetition via 2D autocorrelation.
    `min_lag_frac` excludes a central disk (self-similarity at near-zero
    lag is trivial/expected) of that fraction of the smaller image
    dimension; any autocorrelation peak OUTSIDE that disk, normalized to
    the zero-lag peak, above `peak_ratio_thresh` means a distinctive
    feature recurs periodically -- exactly what 'the arrow repeats every
    tile' looks like mathematically. Runs on grayscale, optionally
    restricted to `mask` (mean-subtracted only over the masked region;
    outside-mask pixels are zeroed so the analytic void doesn't
    self-correlate as a giant fake peak)."""
    gray = np.asarray(im.convert("L")).astype(np.float64)
    h, w = gray.shape
    if mask is not None:
        if mask.shape != gray.shape:
            raise ValueError(f"mask shape {mask.shape} != image shape {gray.shape}")
        vals = gray[mask]
        mean = float(vals.mean()) if vals.size else 0.0
        centered = np.zeros_like(gray)
        centered[mask] = gray[mask] - mean
    else:
        centered = gray - gray.mean()

    # FFT-based autocorrelation (Wiener-Khinchin), zero-padded to avoid
    # circular wraparound contaminating the "off-center peak" reading with
    # a spurious wrap-seam correlation.
    ph, pw = 2 * h, 2 * w
    F = np.fft.rfft2(centered, s=(ph, pw))
    ac = np.fft.irfft2(F * np.conj(F), s=(ph, pw))
    ac = np.fft.fftshift(ac)
    cy, cx = ph // 2, pw // 2
    zero_lag = ac[cy, cx]
    if zero_lag <= 1e-6:
        return dict(ok=True, reason="flat/empty region, nothing to correlate",
                    peak_ratio=None)

    min_lag_px = int(min_lag_frac * min(h, w))
    yy, xx = np.mgrid[0:ph, 0:pw]
    dist = np.sqrt((yy - cy) ** 2 + (xx - cx) ** 2)
    search = dist > min_lag_px
    if not search.any():
        return dict(ok=True, reason="region too small to judge", peak_ratio=None)

    peak = float(ac[search].max())
    peak_ratio = peak / float(zero_lag)
    peak_idx = np.unravel_index(np.argmax(np.where(search, ac, -np.inf)), ac.shape)
    peak_lag = (int(peak_idx[1] - cx), int(peak_idx[0] - cy))
    ok = peak_ratio < peak_ratio_thresh
    return dict(ok=ok, peak_ratio=peak_ratio, peak_lag=peak_lag,
                min_lag_px=min_lag_px, thresh=peak_ratio_thresh)


# ---------------------------------------------------------------------------
# shape-conformance gate (director's ruling, 2026-07-11: "it still doesn't
# match the shape of the polygons" -- confirmed on l03/polygon_0, a true
# quadrilateral with no right angles, whose shipped texture has a dead
# axis-aligned plate grid). Sobel gradient-orientation histogram in a band
# near each wall edge; the dominant structure orientation in that band
# should track the wall's own angle, not stay locked to 0/90 degrees.
# ---------------------------------------------------------------------------

def _sobel(gray: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    kx = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.float64)
    ky = kx.T
    pad = np.pad(gray, 1, mode="edge")
    gx = np.zeros_like(gray)
    gy = np.zeros_like(gray)
    for dy in range(3):
        for dx in range(3):
            if kx[dy, dx]:
                gx += kx[dy, dx] * pad[dy:dy + gray.shape[0], dx:dx + gray.shape[1]]
            if ky[dy, dx]:
                gy += ky[dy, dx] * pad[dy:dy + gray.shape[0], dx:dx + gray.shape[1]]
    return gx, gy


def _band_mask_for_edge(shape, a, b, band_px: int) -> np.ndarray:
    """Boolean mask of pixels within `band_px` of segment a-b."""
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float64)
    ax, ay = a
    bx, by = b
    dx, dy = bx - ax, by - ay
    seg_len2 = dx * dx + dy * dy
    if seg_len2 < 1e-6:
        return np.zeros(shape, dtype=bool)
    t = ((xx - ax) * dx + (yy - ay) * dy) / seg_len2
    t = np.clip(t, 0.0, 1.0)
    projx, projy = ax + t * dx, ay + t * dy
    dist = np.sqrt((xx - projx) ** 2 + (yy - projy) ** 2)
    return dist <= band_px


def verify_shape_conformance(im: Image.Image, mask: np.ndarray,
                              wall_edges: list[tuple[tuple[float, float], tuple[float, float]]],
                              band_px: int = 40, angle_tol_deg: float = 12.0,
                              min_grad_px: int = 60,
                              boxes: list | None = None) -> dict:
    """For each wall edge segment (pixel-space endpoints), measure whether
    the texture's DOMINANT linear structure in a `band_px` band along that
    wall aligns with the wall, mod 90 degrees: a rectilinear plate install
    against a wall legitimately shows BOTH wall-parallel seams and
    wall-perpendicular plate joints, so conforming structure is anything
    at 0 or 90 degrees to the wall, and NON-conforming structure is
    oblique to it (a horizontal/vertical grid stamped over a 15-degree
    wall reads as 15-degree error, mod 90). Per edge: build a smoothed
    energy-weighted orientation histogram (90 one-degree bins, circular
    mod 90) of strong-gradient pixels and take the PEAK bin's folded
    angular distance from the wall angle. Overall ok if the energy-
    weighted mean of per-edge peak errors is within `angle_tol_deg`.

    REBUILT 2026-07-11 (fix round): the previous per-pixel energy-weighted
    MEAN of min(d, 90-d) conflated "lots of isotropic micro-texture" with
    "oblique grid" -- it only worked while baked props contributed extra
    hard 0/90 edges near the walls, and once the base truth became floor-
    only (props removed per the director's texture-concept correction) it
    rejected personally-verified clean axis-aligned candidates at 16-20
    deg purely because treadplate diamonds/scratches dominate the top-20%
    gradient energy (a uniform angle spread means ~22.5 deg no matter how
    perfect the seams are). The histogram PEAK measures where structure
    CONCENTRATES, which micro-texture (spread over all angles) cannot
    shift. CALIBRATED 2026-07-11 on known-answer fixtures: old shipped
    l07/polygon_7 (director-photographed f52 shape defect -- must FAIL,
    measures 25.2) vs personally-reviewed clean candidates
    l01_polygon117_p1_a3 / l05_polygon004_p1_a1 / l01_polygon002_p2_a1 (must PASS,
    measure 0.5-1.0). tol 12 splits with margin on both sides. The mod-90
    fold (kept from the previous version) is what makes the metric
    measure obliqueness rather than which of the two legitimate seam
    families dominates."""
    gray = np.asarray(im.convert("L")).astype(np.float64)
    if mask.shape != gray.shape:
        raise ValueError(f"mask shape {mask.shape} != image shape {gray.shape}")
    gx, gy = _sobel(gray)
    mag = np.sqrt(gx ** 2 + gy ** 2)

    # Box-aware (2026-07-13, same family as verify_fullbleed's fix):
    # requested equipment/marking content inside a wall-hugging item box is
    # legitimately oblique -- a HAZARD LANE's 45-degree stripes along the
    # bottom wall measured 17-21 deg "wall angle error" on stage-2 outputs
    # whose underlying floor (stage 1) PASSED this same gate. Exclude the
    # (dilated) item footprints from every edge band before measuring.
    eff_mask = mask
    if boxes:
        h_, w_ = mask.shape
        excl = np.zeros((h_, w_), dtype=bool)
        for bx in boxes:
            x0, y0, x1, y1 = bx["box"]
            x0, y0 = max(0, int(x0)), max(0, int(y0))
            x1, y1 = min(w_, int(x1)), min(h_, int(y1))
            if x1 > x0 and y1 > y0:
                excl[y0:y1, x0:x1] = True
        if excl.any():
            eff_mask = mask & ~_dilate_mask(excl, 4)

    per_edge = []
    errs = []
    weights = []
    for a, b in wall_edges:
        wall_ang = math.degrees(math.atan2(b[1] - a[1], b[0] - a[0])) % 90.0
        band = _band_mask_for_edge(gray.shape, a, b, band_px) & eff_mask
        if band.sum() < min_grad_px:
            per_edge.append(dict(wall_angle=wall_ang, err=None, reason="band too small"))
            continue
        band_mag = mag[band]
        thresh = np.percentile(band_mag, 80)
        strong = band_mag > thresh
        if strong.sum() < 8:
            per_edge.append(dict(wall_angle=wall_ang, err=None, reason="too little structure"))
            continue
        gxs, gys = gx[band][strong], gy[band][strong]
        w = band_mag[strong]
        # seam orientation = gradient direction + 90, folded mod 90
        seam_ang = (np.degrees(np.arctan2(gys, gxs)) + 90.0) % 90.0
        hist, _ = np.histogram(seam_ang, bins=90, range=(0.0, 90.0), weights=w)
        # circular smoothing (mod 90), +-2 deg triangular kernel
        kern = np.array([1, 2, 3, 2, 1], dtype=np.float64)
        pad = np.concatenate([hist[-2:], hist, hist[:2]])
        smooth = np.convolve(pad, kern, mode="same")[2:-2]
        peak_ang = float(np.argmax(smooth)) + 0.5
        d = abs(peak_ang - wall_ang)
        err = min(d, 90.0 - d)
        per_edge.append(dict(wall_angle=wall_ang, peak_angle=peak_ang,
                             err=err, n=int(strong.sum())))
        errs.append(err)
        weights.append(float(w.sum()))

    if not errs:
        return dict(ok=True, reason="no wall edges had enough structure to judge",
                    mean_err=None, per_edge=per_edge)
    mean_err = float(np.average(errs, weights=weights))
    ok = mean_err <= angle_tol_deg
    return dict(ok=ok, mean_err=mean_err, angle_tol_deg=angle_tol_deg,
                per_edge=per_edge)


def verify_no_guide_ink(im: Image.Image, mask: np.ndarray,
                         frac_thresh: float = 0.0015) -> dict:
    """Catch the geometry guide's annotation colors leaking into the
    output: the model occasionally renders the guide's saturated CYAN wall
    lines / MAGENTA doorway marks as literal paint on the floor (caught
    2026-07-11: pink doorway rectangles rendered into l05/polygon_4). Also
    catches the labeled-box conditioning's MIRIAD/TESTATOR box outlines
    leaking the same way -- confirmed 2026-07-13 on the box-conditioning
    calibration batch (tools/artgen/calibrate_v3.py): l03/polygon_0's texture
    shipped with a literal box outline painted around the requested
    center-trough box.

    Gate-sanity finding (2026-07-13): the ORIGINAL annotation colors
    (MIRIAD orange, TESTATOR bronze-verdigris) were deliberately chosen to
    MATCH the game's own material palette (hazard-stripe orange, Testator
    verdigris corrosion) "so the annotation itself signals lane at a
    glance" -- which made leaked ink indistinguishable from legitimate
    material. Verified false-positive on OLD, already-shipped,
    human/Gemini-accepted textures with zero box conditioning (l01/polygon_0,
    l01/polygon_2, pre-51d09a7): the orange channel fired at 0.28%/0.46%
    (thresh 0.15%) on ordinary rust/hazard staining. box_conditioning.py's
    LANE_COLOR now uses hot magenta (MIRIAD) / neon green (TESTATOR),
    colors that occur nowhere in this game's deliberately desaturated
    palette (STYLE_LANGUAGE), so any detected pixel is unambiguous
    annotation leakage rather than a collision with real material. The
    orange channel is retained at a stricter (rarer, more saturated)
    threshold only as a legacy backstop for any pre-existing orange-boxed
    assets still in flight; it is not used for new annotation."""
    rgb = np.asarray(im.convert("RGB")).astype(np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mx = rgb.max(axis=2)
    mn = rgb.min(axis=2)
    sat = (mx - mn) / np.maximum(mx, 1e-6)
    cyan = (sat > 0.45) & (mx > 90) & (b > r * 1.25) & (g > r * 1.25)
    magenta = (sat > 0.45) & (mx > 90) & (r > g * 1.3) & (b > g * 1.3)
    # neon-green (box_conditioning.LANE_COLOR TESTATOR = (0,255,90)):
    # G dominant, both R and B far below G -- does not match muted
    # bronze-verdigris corrosion (which has G and B close together).
    neon_green = (sat > 0.55) & (mx > 90) & (g > r * 1.8) & (g > b * 1.8)
    leak = (cyan | magenta | neon_green) & mask
    frac = float(leak.mean() if mask.any() else 0.0)
    in_frac = float(leak[mask].mean()) if mask.any() else 0.0
    ok = in_frac <= frac_thresh
    return dict(ok=ok, leak_frac=in_frac, frac_thresh=frac_thresh, _frac_of_image=frac)


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


# ---------------------------------------------------------------------------
# detail-budget gate (director's ruling, 2026-07-11 fix round: shipped
# polygons read "a little visually noisy"). Instrument findings on the 8
# then-accepted polygons + their approved kind material swatches: intensity
# ENTROPY does not discriminate (polygons 5.2-6.8 bits vs swatches 5.4-6.8 --
# the style itself is entropy-rich), but mean Sobel gradient energy
# RELATIVE TO THE KIND'S OWN APPROVED SWATCH does: most polygons sat at
# 0.95-1.16x their swatch while the one polygon that visibly read as noisy
# (l07/polygon_2, otherworld) measured 1.43x. A polygon floor lives UNDER the
# game's live props/decals/lighting and should be QUIETER than its raw
# swatch, never busier -- the swatch shows the material at its most
# weathered. Threshold 1.25x: passes the 7 personally-verified calm polygons
# with margin, fails the visibly noisy one. Entropy is still measured and
# reported for the record.
#
# RECALIBRATED 2026-07-13 (director's order: final texture pass). The v2
# gate above was floor-only -- it never saw painted equipment. Once the
# box-conditioning pipeline (commit 51d09a7) started painting real
# equipment INSIDE labeled item boxes, the uniform whole-mask ratio started
# routinely failing legitimate polygons: the two v3 calibration polygons
# (l01/polygon_000 dock, l03/polygon_000 hydro) measured whole-polygon ratios of
# 1.45x and 1.38x against the SAME 1.25x threshold that used to pass calm
# floor-only polygons with margin. Diagnosis (not a blind widen): equipment
# footprint legitimately reads busier than bare material -- crates, troughs,
# mooring rings all have real edges. Measuring gradient energy separately
# inside vs. outside the labeled boxes on those same two polygons found the
# BACKGROUND (outside any box) ratio is 1.25 and 1.20 respectively -- i.e.
# still under the original 1.25x threshold, unchanged -- while the
# EQUIPMENT (inside boxes) ratio is 1.98 and 1.85x. So the fix is not a
# looser number, it's measuring the right region: background noise (floor
# the model invented busyness on, unrelated to any requested item) is
# gated at the original 1.25x; equipment footprint is gated separately at a
# looser but still real ceiling (2.5x, informed by the two calibration
# equipment ratios of 1.85-1.98x, leaving headpolygon for legitimately
# detailed props while still catching a genuinely degenerate/noisy
# equipment render). A polygon with no boxes falls back to the original
# whole-mask behavior unchanged.
# ---------------------------------------------------------------------------

def verify_detail_budget(im: Image.Image, mask: np.ndarray,
                          material_im: Image.Image,
                          ratio_thresh: float = 1.25,
                          boxes: list | None = None,
                          equipment_ratio_thresh: float | None = 2.5) -> dict:
    """Mean Sobel gradient magnitude inside `mask`, relative to the kind's
    approved material swatch. If `boxes` (list of dicts with a pixel-space
    `box` = (x0,y0,x1,y1), in the SAME pixel frame as `im`/`mask`) is given,
    the mask is split into background (outside every box) and equipment
    (inside a box) regions, gated independently -- background must stay
    under `ratio_thresh` (unchanged from the v2 floor-only calibration),
    equipment is allowed up to `equipment_ratio_thresh` (real props read
    busier than bare material). Overall `ok` requires BOTH sub-gates to
    pass, or -- if there are no boxes, or a region is empty -- falls back
    to the original whole-mask ratio vs `ratio_thresh`. Also reports the
    Shannon entropy of the masked intensity histogram (informational --
    see block comment)."""
    gray = np.asarray(im.convert("L")).astype(np.float64)
    if mask.shape != gray.shape:
        raise ValueError(f"mask shape {mask.shape} != image shape {gray.shape}")
    gx, gy = _sobel(gray)
    grad = np.sqrt(gx ** 2 + gy ** 2)
    polygon_grad = float(grad[mask].mean())

    mgray = np.asarray(material_im.convert("L")).astype(np.float64)
    mgx, mgy = _sobel(mgray)
    mat_grad = float(np.sqrt(mgx ** 2 + mgy ** 2).mean())

    vals = gray[mask].astype(int)
    hist = np.bincount(vals, minlength=256).astype(np.float64)
    hist /= max(1.0, hist.sum())
    nz = hist[hist > 0]
    entropy = float(-(nz * np.log2(nz)).sum()) if nz.size else 0.0

    ratio = polygon_grad / max(1e-6, mat_grad)
    result = dict(grad_ratio_vs_material=ratio,
                  polygon_grad=polygon_grad, material_grad=mat_grad,
                  entropy_bits=entropy, ratio_thresh=ratio_thresh)

    if not boxes:
        result["ok"] = ratio <= ratio_thresh
        return result

    box_mask = np.zeros_like(mask, dtype=bool)
    h, w = mask.shape
    for b in boxes:
        x0, y0, x1, y1 = b["box"]
        x0, x1 = max(0, int(x0)), min(w, int(x1))
        y0, y1 = max(0, int(y0)), min(h, int(y1))
        if x1 > x0 and y1 > y0:
            box_mask[y0:y1, x0:x1] = True

    bg_mask = mask & ~box_mask
    eq_mask = mask & box_mask

    if not bg_mask.any() and not eq_mask.any():
        result["ok"] = ratio <= ratio_thresh
        return result

    bg_grad = float(grad[bg_mask].mean()) if bg_mask.any() else 0.0
    eq_grad = float(grad[eq_mask].mean()) if eq_mask.any() else 0.0
    bg_ratio = bg_grad / max(1e-6, mat_grad) if bg_mask.any() else None
    eq_ratio = eq_grad / max(1e-6, mat_grad) if eq_mask.any() else None

    bg_ok = True if bg_ratio is None else bg_ratio <= ratio_thresh
    # equipment_ratio_thresh=None: skip the numeric equipment sub-gate.
    # Measured 2026-07-13 (composite stage-2 mode): structured equipment
    # (pipe runs) reads 3.2x on a personally-verified GOOD render -- above
    # the 2.75-2.81x synthetic-noise negative control, so the numeric
    # ratio cannot discriminate good structured equipment from noise.
    # In composite mode the semantic check (verify_item_placement vision
    # gate) owns equipment quality; the ratio is still reported.
    eq_ok = True if (eq_ratio is None or equipment_ratio_thresh is None)         else eq_ratio <= equipment_ratio_thresh

    result.update(
        background_grad_ratio=bg_ratio, equipment_grad_ratio=eq_ratio,
        equipment_ratio_thresh=equipment_ratio_thresh,
        background_ok=bg_ok, equipment_ok=eq_ok,
    )
    result["ok"] = bg_ok and eq_ok
    return result
