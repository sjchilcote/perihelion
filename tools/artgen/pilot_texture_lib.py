"""tools/artgen/pilot_texture_lib.py

Shared helpers for the floor-texture pilot: exact polygon polygon masks (same
local frame as polygon_basetruth.py), prompt templates per polygon kind, and
small path helpers. No network calls here.
"""
from __future__ import annotations

import json
import math
import os
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np  # noqa: E402
import necore  # noqa: E402

from perihelion import fb2d  # noqa: E402

from perihelion.levels import load_level  # noqa: E402

SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad"
)
BASETRUTH_DIR = SCRATCH / "basetruth"
PILOT_JSON = ROOT / "tools" / "artgen" / "pilot_polygons.json"
TEXTURES_ROOT = ROOT / "game" / "perihelion" / "assets" / "textures"

_level_cache: dict[str, object] = {}


def get_level(stem: str):
    if stem not in _level_cache:
        _level_cache[stem] = load_level(ROOT / "levels" / f"{stem}.json")
    return _level_cache[stem]


def polygon_mask(stem: str, polygon_idx: int, px_per_unit: float = 3) -> np.ndarray:
    """Boolean (H, W) mask, True = inside the polygon polygon, in the exact
    same local frame polygon_basetruth.py rendered into (min-bound offset,
    ceil(w*ppu) x ceil(h*ppu))."""
    level = get_level(stem)
    verts = level.polygon_verts[polygon_idx]
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    x0, x1 = min(xs), max(xs)
    y0, y1 = min(ys), max(ys)
    w_px = max(1, math.ceil((x1 - x0) * px_per_unit))
    h_px = max(1, math.ceil((y1 - y0) * px_per_unit))

    xform = necore.mat_mul(necore.mat_scale(px_per_unit, px_per_unit),
                            necore.mat_translate(-x0, -y0))
    poly = [necore.mat_apply(xform, x, y) for x, y in verts]

    buf = np.zeros((w_px, h_px, 3), dtype=np.uint8)
    fb2d.polygon(buf, (255, 255, 255), poly)  # same rasterizer basetruth fills with
    return buf[..., 0].T.astype(bool)  # (H, W)


def apply_mask(im, mask: np.ndarray):
    """im: PIL.Image RGB, mask: (H, W) bool, True=keep. Returns PIL.Image
    RGB with masked-out pixels forced to black. The mask is nearest-resized
    to im's size first if they differ by the sub-pixel rounding slop
    between pilot_polygons.json's tex_w/tex_h and polygon_mask's own
    ceil(w*ppu)/ceil(h*ppu) computation (off by <=1px on either axis)."""
    from PIL import Image
    arr = np.asarray(im.convert("RGB")).copy()
    h, w = arr.shape[:2]
    if mask.shape != (h, w):
        mask_im = Image.fromarray((mask.astype(np.uint8) * 255), mode="L")
        mask_im = mask_im.resize((w, h), Image.NEAREST)
        mask = np.asarray(mask_im) > 127
    arr[~mask] = 0
    return Image.fromarray(arr, mode="RGB")


def polygon_doorway_edges(stem: str, polygon_idx: int) -> set[int]:
    """Edge indices of `polygon_idx` (in level.polygon_verts[polygon_idx] winding
    order) that are a doorway/connection to another polygon, per
    level.connects / level.connects_x / level.doors."""
    level = get_level(stem)
    out: set[int] = set()
    for a, ea, b, eb in level.connects:
        if a == polygon_idx:
            out.add(ea)
        if b == polygon_idx:
            out.add(eb)
    for a, ea, b, eb, _m9 in level.connects_x:
        if a == polygon_idx:
            out.add(ea)
        if b == polygon_idx:
            out.add(eb)
    for d in level.doors:
        if d.a == polygon_idx:
            out.add(d.ea)
        if d.b == polygon_idx:
            out.add(d.eb)
    return out


def _polygon_xform(stem: str, polygon_idx: int, px_per_unit: float = 3):
    level = get_level(stem)
    verts = level.polygon_verts[polygon_idx]
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    x0, y0 = min(xs), min(ys)
    xform = necore.mat_mul(necore.mat_scale(px_per_unit, px_per_unit),
                            necore.mat_translate(-x0, -y0))
    return xform, verts


def make_guide(stem: str, polygon_idx: int, out_path: Path) -> Path:
    """Build the geometry-guide reference sent to the image model: the polygon's
    base truth with the in-polygon floor region brightened (so near-black
    floor fill can never be confused with the pure-black outside-hull void)
    and the void forced to exact black. Props/details keep their relative
    contrast; only the interior is lifted.

    Also draws the polygon's WALL LINES explicitly (bright cyan) with a gap at
    every doorway edge (director's ruling, 2026-07-11: the model must be
    told where the walls actually run, not just shown a brightened blob --
    a rectilinear grid stamped over an oblique polygon was shipping because
    nothing in the guide called out the wall angles). See SHAPE_LAW."""
    from PIL import Image, ImageDraw
    bt = Image.open(basetruth_path(stem, polygon_idx)).convert("RGB")
    arr = np.asarray(bt).astype(np.int16)
    mask = polygon_mask(stem, polygon_idx, 3)
    if arr.shape[:2] != mask.shape:
        raise RuntimeError(
            f"guide size mismatch {arr.shape[:2]} vs mask {mask.shape} for {stem}/{polygon_idx}")
    lifted = np.clip(arr + 70, 0, 255)
    out = np.where(mask[..., None], lifted, 0).astype(np.uint8)
    im = Image.fromarray(out, "RGB")

    xform, verts = _polygon_xform(stem, polygon_idx)
    door_edges = polygon_doorway_edges(stem, polygon_idx)
    n = len(verts)
    px = [necore.mat_apply(xform, x, y) for x, y in verts]
    draw = ImageDraw.Draw(im)
    # ONE uniform cyan outline for every edge, doorway or not (an earlier
    # version drew magenta doorway stubs / gaps; the model rendered them as
    # literal pink paint and flat gray "door insert" boxes -- caught
    # 2026-07-11 on l05/polygon_4 and l01/polygon_55. Doorway-continuity info now
    # travels exclusively via the neighbor composite, not via guide
    # annotations the model can mistake for floor content.)
    _ = door_edges  # doorway info intentionally NOT drawn; see above
    # Wall lines are drawn OFFSET OUTWARD ~3px from the true boundary
    # (2026-07-13 accept-rate fix #2, mechanism confirmed by reading
    # rejected frames: l04/polygon_059 attempt 3 shipped-to-review with the
    # guide's cyan outline painted literally into the floor as a full
    # perimeter border, and its attempt 2 failed guide-ink at 2.64%
    # saturated cyan -- the model copies the strongest visual feature of
    # the conditioning image, and no prompt text overrides that. With the
    # line sitting just OUTSIDE the polygon, a faithful copy lands in the
    # void that apply_mask() zeroes at ship time, so copying becomes
    # harmless while the line still communicates the wall's position and
    # angle. On bbox-flush edges the offset line clips out of frame --
    # acceptable: there the crop edge itself is the wall signal (the
    # CRITICAL FRAMING RULE in the prompt), and the cyan line matters for
    # interior diagonal/notched edges, which always have in-frame void
    # beyond them.
    h_m, w_m = mask.shape
    for i in range(n):
        ax, ay = px[i]
        bx, by = px[(i + 1) % n]
        ex, ey = bx - ax, by - ay
        elen = max(1e-6, (ex ** 2 + ey ** 2) ** 0.5)
        # unit normal; pick the sign whose sample point at the edge
        # midpoint lands OUTSIDE the polygon mask (robust for non-convex
        # polygons where "away from centroid" lies).
        nx_, ny_ = -ey / elen, ex / elen
        mx_, my_ = (ax + bx) / 2.0, (ay + by) / 2.0
        sx_, sy_ = int(round(mx_ + nx_ * 4)), int(round(my_ + ny_ * 4))
        inside = (0 <= sy_ < h_m and 0 <= sx_ < w_m and mask[sy_, sx_])
        if inside:
            nx_, ny_ = -nx_, -ny_
        off = 3.0
        draw.line([(ax + nx_ * off, ay + ny_ * off),
                   (bx + nx_ * off, by + ny_ * off)],
                  fill=(60, 230, 255), width=2)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    im.save(out_path)
    return out_path


def build_neighbor_composite(stem: str, polygon_idx: int, out_path: Path) -> Path | None:
    """Reference composite for doorway-continuity conditioning (director's
    ruling, 2026-07-11: "show the model the floor texture of all the polygons
    it'll be connected to, oriented as they'll be connected"). For every
    doorway edge of `polygon_idx` whose OTHER side already has a shipped
    texture (texture_out_path exists), paste a strip of that neighbor's
    real texture, sampled from the region of the neighbor adjacent to the
    shared edge and rotated to the shared edge's world angle, just OUTSIDE
    this polygon's polygon at that edge -- i.e. literally what continues past
    the threshold in-game. Uses the same polygon_mask/_polygon_xform geometry
    polygon_basetruth.py and texture_geom.py rely on (not hand-rolled portal
    math). Returns None if this polygon has no already-textured neighbor
    (nothing to condition on)."""
    from PIL import Image, ImageDraw
    level = get_level(stem)
    xform, verts = _polygon_xform(stem, polygon_idx)
    n = len(verts)
    mask = polygon_mask(stem, polygon_idx, 3)
    h, w = mask.shape
    pad = max(40, int(0.15 * max(h, w)))
    canvas = Image.new("RGB", (w + 2 * pad, h + 2 * pad), (0, 0, 0))
    guide_mask = np.zeros((h + 2 * pad, w + 2 * pad), dtype=bool)
    guide_mask[pad:pad + h, pad:pad + w] = mask
    canvas_arr = np.zeros((h + 2 * pad, w + 2 * pad, 3), dtype=np.uint8)

    def edge_pairs(a_idx, connects_list, is_x=False):
        for tup in connects_list:
            a, ea, b, eb = tup[0], tup[1], tup[2], tup[3]
            if a == a_idx:
                yield ea, b, eb
            elif b == a_idx:
                yield eb, a, ea

    pairs = list(edge_pairs(polygon_idx, level.connects))
    pairs += list(edge_pairs(polygon_idx, [(c[0], c[1], c[2], c[3]) for c in level.connects_x]))
    pairs += list(edge_pairs(polygon_idx, [(d.a, d.ea, d.b, d.eb) for d in level.doors]))

    found_any = False
    for my_edge, other_polygon, other_edge in pairs:
        tex_path = texture_out_path(stem, other_polygon)
        if not tex_path.is_file():
            continue
        try:
            other_im = Image.open(tex_path).convert("RGB")
        except Exception:  # noqa: BLE001
            continue
        found_any = True
        a, b = verts[my_edge], verts[(my_edge + 1) % n]
        ax, ay = necore.mat_apply(xform, *a)
        bx, by = necore.mat_apply(xform, *b)
        edge_len = max(1.0, ((bx - ax) ** 2 + (by - ay) ** 2) ** 0.5)
        ang = math.degrees(math.atan2(by - ay, bx - ax))
        # strip of the neighbor's texture, oriented so its own shared-edge
        # runs along the same line: crop a band the length of the shared
        # edge out of the neighbor texture, then rotate it to this edge's
        # world angle and paste just outside the polygon on this edge's
        # outward normal side.
        band = other_im.resize((max(8, int(edge_len)), max(8, int(edge_len * 0.35))))
        rotated = band.rotate(-ang, expand=True)
        mx, my = (ax + bx) / 2.0, (ay + by) / 2.0
        # outward normal: perpendicular to edge, pointing away from this
        # polygon's own centroid in pixel space
        cx = sum(p[0] for p in verts) / n
        cy = sum(p[1] for p in verts) / n
        ccx, ccy = necore.mat_apply(xform, cx, cy)
        nx, ny = -(by - ay), (bx - ax)
        nlen = max(1e-6, (nx ** 2 + ny ** 2) ** 0.5)
        nx, ny = nx / nlen, ny / nlen
        if (nx * (mx - ccx) + ny * (my - ccy)) < 0:
            nx, ny = -nx, -ny
        px_c = int(pad + mx + nx * rotated.height * 0.5)
        py_c = int(pad + my + ny * rotated.height * 0.5)
        canvas.paste(rotated, (px_c - rotated.width // 2, py_c - rotated.height // 2))

    if not found_any:
        return None
    # paste this polygon's own polygon outline on top so the composite reads
    # as "here is the target shape, here is what borders it"
    canvas_arr = np.asarray(canvas).copy()
    canvas = Image.fromarray(canvas_arr, "RGB")
    draw = ImageDraw.Draw(canvas)
    door_edges = polygon_doorway_edges(stem, polygon_idx)
    px = [necore.mat_apply(xform, x, y) for x, y in verts]
    for i in range(n):
        a = (px[i][0] + pad, px[i][1] + pad)
        b = (px[(i + 1) % n][0] + pad, px[(i + 1) % n][1] + pad)
        # cyan only -- magenta was rendered as literal pink paint by the
        # model (see make_guide); a doorway is identified by the neighbor
        # strip lying just outside it.
        draw.line([a, b], fill=(60, 230, 255), width=2)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path)
    return out_path


def wall_edges_px(stem: str, polygon_idx: int, walls_only: bool = False
                   ) -> list[tuple[tuple[float, float], tuple[float, float]]]:
    """Pixel-space (a, b) endpoints of every polygon edge of this polygon, in
    the same local frame polygon_mask/make_guide use. Used by
    texture_checks.verify_shape_conformance.

    `walls_only=True` restricts to non-doorway edges. Default False (ALL
    edges, including doorway thresholds): calibration against l03/polygon_0
    (a true quadrilateral where 3 of its 4 edges are doorways -- a
    corridor-junction polygon, not unusual in this level graph) found that
    restricting to the single true wall edge passed cleanly even though
    the shipped texture visibly fails to track the polygon's shape --  the
    defect (an axis-aligned grid ignoring the polygon's actual oblique
    silhouette) is a property of the WHOLE polygon's geometry, and a
    doorway edge is still real polygon-boundary geometry the material grid
    should respect (a threshold has a direction too), so judging against
    every edge is the calibration that actually catches the confirmed-bad
    case."""
    xform, verts = _polygon_xform(stem, polygon_idx)
    door_edges = polygon_doorway_edges(stem, polygon_idx)
    n = len(verts)
    px = [necore.mat_apply(xform, x, y) for x, y in verts]
    idxs = range(n)
    if walls_only:
        idxs = [i for i in idxs if i not in door_edges]
    return [(px[i], px[(i + 1) % n]) for i in idxs]


def save_review_overlay(stem: str, polygon_idx: int, texture_path: Path, out_path: Path) -> Path:
    """Auditable review artifact (director's ruling, 2026-07-11: "actually
    look at what you're doing" must be checkable). Draws the shipped
    texture with the polygon's real polygon outline (cyan = wall, magenta =
    doorway gap) overlaid, at the texture's own pixel size, so a wall-
    angle or doorway-truncation defect is visible at 1:1 without needing
    to cross-reference the base truth separately."""
    from PIL import Image, ImageDraw
    im = Image.open(texture_path).convert("RGB")
    xform, verts = _polygon_xform(stem, polygon_idx)
    n = len(verts)
    px = [necore.mat_apply(xform, x, y) for x, y in verts]
    # scale polygon points from the 3px/unit polygon_mask frame to this
    # texture's actual pixel size (pilot tex_w/tex_h can differ slightly).
    mask = polygon_mask(stem, polygon_idx, 3)
    mh, mw = mask.shape
    sx, sy = im.width / max(1, mw), im.height / max(1, mh)
    door_edges = polygon_doorway_edges(stem, polygon_idx)
    draw = ImageDraw.Draw(im)
    for i in range(n):
        a = (px[i][0] * sx, px[i][1] * sy)
        b = (px[(i + 1) % n][0] * sx, px[(i + 1) % n][1] * sy)
        color = (255, 60, 220) if i in door_edges else (60, 230, 255)
        draw.line([a, b], fill=color, width=3)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    im.save(out_path)
    return out_path


def load_pilot():
    return json.loads(PILOT_JSON.read_text())


def basetruth_path(stem: str, polygon_idx: int) -> Path:
    return BASETRUTH_DIR / stem / f"polygon_{polygon_idx:03d}.png"


def texture_out_path(stem: str, polygon_idx: int) -> Path:
    # MUST match game/perihelion/texture_geom.py::texture_path (unpadded).
    return TEXTURES_ROOT / stem / f"polygon_{polygon_idx}.png"


# ---------------------------------------------------------------------------
# authorship flavor
# ---------------------------------------------------------------------------

TESTATOR_KINDS = {"otherworld", "chapel", "core"}

KIND_MATERIAL = {
    "dock": "heavy anti-slip deck plating, cargo tie-down rings, worn "
            "diamond-tread panels, oil and rust streaking along seams, "
            "scuffed from loader traffic",
    "corridor": "modular utility deck plating with regular rivet seams, "
                "recessed conduit runs along the base of the walls, worn "
                "traffic paths down the center, occasional grime and rust "
                "bleeding from panel joints",
    "transit": "wide utilitarian transit-deck plating, worn scuff-polish "
               "high-traffic wear, handrail mounting stubs",
    "storage": "stacked utility shelving brackets, crate outlines, "
               "chained-down container marks, dust and grime in low-traffic "
               "corners, plain structural plating",
    "pump": "wet-service textured deck grating, pipe-flange mounts, mineral "
            "staining and condensation streaks",
    "lab": "clean-polygon composite flooring gone slightly grimy, embedded "
           "cable trays, faint chemical staining, precise MIRIAD-era "
           "geometric panel seams",
    "hydro": "damp organic-stained deck plating, mineral/algae bloom "
             "creeping from drainage grates, condensation streaking, humid "
             "grime",
    "quarters": "worn residential deck composite, personal-space wear "
                "patterns, scuffed threshold strips, faint human-era "
                "domestic detail gone derelict",
    "chapel": "Testator-altered ceremonial flooring: non-human geometric "
              "inlay, asymmetric radiating grooves, old dark stains in "
              "ritual patterns, worn non-alphabetic surface markings, "
              "unsettling non-orthogonal proportions",
    "medbay": "clinical composite flooring, drainage grates, disinfectant "
              "stains gone dull, precise MIRIAD panel seams -- STRICTLY "
              "man-made hospital materials only: linoleum-like composite "
              "tile, metal cabinet fronts, plastic trim, dried blood/rust "
              "stains ON TOP of clinical flooring. This is emphatically "
              "NOT organic, NOT fleshy, NOT alien tissue -- no veins, no "
              "growths, no biological texture of any kind, even though the "
              "palette may be dark reddish-brown from old blood stains and "
              "low light.",
    "records": "archive-deck flooring, static-dissipative panel texture, "
               "cable-run seams, dust settled in undisturbed patterns, "
               "utilitarian data-hall wear",
    "core": "Testator-corrupted reactor/core deck: human plating still "
            "legible underneath but overtaken by alien growth-like "
            "geometry, asymmetric fused seams, dark radial scarring, "
            "bioluminescent-cold residue in the grooves",
    "generic": "plain modular utility deck plating, regular rivet seams, "
               "light wear, unremarkable MIRIAD-era maintenance space",
    "otherworld": "Testator native surface: non-Euclidean organic-geometric "
                  "growth patterning, asymmetric ridges, old alien "
                  "resin-like sheen gone matte and cold, no human right "
                  "angles anywhere, faint bioluminescent-dead veining",
}

# NO-SIGNAGE LAW (root-caused 2026-07-11, director's ruling): a polygon-KIND
# tileable base material previously baked in readable stenciled text
# ("BAY 7", "LOAD LIMIT: 50", "DOCKMD-G7") and hazard-stripe arrow/chevron
# glyphs directly into the shared material swatch, sourced from
# KIND_MATERIAL prompt language like "stenciled bay-number markings" and
# "directional floor striping" -- NOT from any game-render reference (this
# generator has never attached reference_images; verified against full git
# history). Because the material tiles across every polygon of that kind, the
# exact same baked text/arrow reproduced verbatim, at tile period, in every
# shipped polygon of that kind (confirmed: l01/polygon_0.png shows "BAY 7" twice
# and "LOAD LIMIT: 50" twice, byte-identical to the dock.png material
# swatch). Any per-polygon floor decal (blood, scorch) is separate, later,
# gameplay-only state and was never the source of this defect -- see the
# decal-off verification in RUN_2026-07-11.md. This law is a hard negative
# constraint applied to EVERY material and per-polygon prompt, on top of the
# now-cleaned KIND_MATERIAL language above (belt and suspenders: strip the
# inviting language AND forbid the failure mode explicitly).
NO_SIGNAGE_LAW = (
    "HARD CONSTRAINT, no exceptions: this material/floor must contain ZERO "
    "readable text, letters, numerals, alphanumeric codes, stencil "
    "lettering, or word-like glyphs of any kind -- no bay numbers, no "
    "load-limit callouts, no ID codes, no signage, not even blurred or "
    "'half-legible' text. It must also contain ZERO arrow shapes, chevrons, "
    "directional pointers, or hazard-stripe wayfinding graphics (diagonal "
    "black/yellow stripe pairs that read as caution tape are fine ONLY if "
    "they form a plain repeating diagonal stripe field with no arrowhead, "
    "no chevron point, and no directional intent -- when in doubt, leave "
    "hazard striping out entirely and rely on grime/rust/wear instead). "
    "Every recurring graphic mark you paint will repeat at the material's "
    "tile period across an entire polygon and into every other polygon of this "
    "kind, so avoid ANY large distinctive one-off feature (a big unique "
    "stain, a singular mark, a logo-like shape) near an edge or anywhere "
    "conspicuous -- keep marks small, irregular, and organic (rust bloom, "
    "scuffing, grime) so repetition is not visually obvious."
)

STYLE_LANGUAGE = (
    "Photoreal-leaning painterly sci-fi horror environment texture, top-down "
    "orthographic view, muted desaturated industrial palette (cold grays, "
    "rust ochres, dull teals) -- NOT bright, NOT "
    "saturated, NOT colorful; this is a derelict deep-space station lit by "
    "failing utility lighting. Overhead/flat lighting only, no strong "
    "directional shadows or highlights (the in-game darkness/lighting pass "
    "is applied later -- render this at a NEUTRAL flat exposure, do not "
    "pre-darken or pre-brighten). MODERATE detail, LOW visual noise: this "
    "floor sits UNDER the game's own props, decals, and lighting, so it "
    "must read as a calm background surface -- large quiet plate areas "
    "with sparse, localized wear (a scuff here, a rust bleed there), not "
    "an even carpet of scratches/grime/corrosion over every panel. When "
    "in doubt, render a panel PLAINER than the reference swatch, never "
    "busier. Wear/marking density should be clearly LOWER than the "
    "material swatch, which shows the material at its most weathered.\n"
    "BLACK LAW: pure black in the geometry guide means VOID OUTSIDE THE "
    "HULL and appears in your output ONLY exactly where the guide shows "
    "it (outside the polygon's silhouette). Never paint black or near-black "
    "patches, bars, notches, or shadows ON the floor itself -- every "
    "pixel inside the polygon silhouette is lit floor material."
)

# FULL-BLEED FLOOR LAW (director's ruling): a polygon texture is a piece of
# floor SURFACE, not a framed object. Defined positively so the model has
# something to aim at, not just a list of prohibitions.
FULLBLEED_LAW = (
    "This is a continuous section of the station's floor plating, cropped "
    "from a much larger floor -- imagine the camera is a rectangular "
    "cutout hovering over an infinite floor plane; the material must run "
    "flush to every edge of the crop as if it keeps going past the frame "
    "in all directions. Material detail (seams, grime, wear, staining) "
    "may vary across the surface, but there is no border, no frame, no "
    "picture-edge vignette, no darkened margin, and no wall/baseboard "
    "painted along any edge. The floor is not a plate sitting inside a "
    "polygon shot from above -- it IS the polygon's actual walkable surface, "
    "edge to edge. Exposure and lighting must be UNIFORM corner to corner "
    "and edge to edge -- no corner shading, no soft dark falloff toward "
    "any edge, no photographic vignette. If the material has directional "
    "markings (stripes, seams, cable runs), let them run OFF the crop on "
    "at least one side rather than terminating/framing near an edge, so "
    "they read as continuing past the frame, not as a border.\n\n"
    "SPECIFIC RECURRING FAILURE TO AVOID: do not draw a raised conduit/"
    "pipe/duct trim, a rivet strip, a darker structural band, or any kind "
    "of continuous border running along the perimeter just inside the "
    "polygon's wall line -- that reads as a picture frame around the floor, "
    "not as floor. The area right up against the wall line is ORDINARY "
    "FLOOR MATERIAL, same family as the center, at most with wear/dirt "
    "accumulation (which is a soft, irregular gradient, never a crisp "
    "straight-edged strip or bar running parallel to the wall)."
)

# Diagnosis (2026-07-13, FINAL-pass accept-rate economics, director's order
# workstream 2): full-bleed/border rejects were the single largest reject
# class in the shipped l01-l03 run (fullbleed = the LAST verdict on 121/316
# bare polygons, 38% -- larger than detail_budget or interior_void). The
# instruction was already present (FULLBLEED_LAW above) but buried in the
# middle of a long multi-paragraph prompt behind the reference-image
# descriptions and neighbor-continuity note; the model was still painting a
# border/trim band at a high rate. Root-caused as a PLACEMENT problem, not a
# missing-instruction problem: this is the identical rule restated as a
# short, standalone final line, so it is the LAST thing read regardless of
# which optional notes (box_note/decal_note) are present -- recency in a
# long conditioning prompt is the cheap, low-risk lever (no threshold or
# gate math changed, so this cannot mask a real border that the gate would
# otherwise have correctly caught).
FULLBLEED_FINAL_REMINDER = (
    "FINAL CHECK BEFORE YOU RENDER: is there ANY band, strip, trim, "
    "baseboard, rivet line, darker margin, or vignette running along one "
    "or more edges of the image, even a subtle one? If so, that is the "
    "single most common failure for this task -- remove it. The floor "
    "material must run flush and uniformly lit all the way to every edge "
    "of the crop, exactly like the rest of the surface, with nothing "
    "framing it."
)

GEOMETRY_LOCK = (
    "CRITICAL geometry constraint: this must be the SAME polygon, at the SAME "
    "pixel dimensions as the base-truth reference image, viewed from "
    "directly above (top-down orthographic, no perspective tilt). Preserve "
    "EXACTLY: the polygon's outer silhouette/polygon boundary, every wall "
    "line position, and the position/footprint of every prop/object visible "
    "in the base truth. Do not add, remove, resize, or move any wall or "
    "prop. Do not rotate, crop, or reframe. Area outside the polygon polygon "
    "(pure black in the reference) must stay pure black. This is a texture "
    "re-render of the identical geometry at 4x visual fidelity -- not a "
    "reinterpretation, not a new polygon.\n\n"
    "MOST COMMON FAILURE TO AVOID: inventing new interior walls, "
    "partitions, machinery consoles, crates, hatches, or clutter that are "
    "NOT present in the base truth, especially in large open/empty floor "
    "areas. If the base truth shows bare open floor with few or no props "
    "in a region, that region MUST stay open bare floor in the output -- "
    "render only material detail (plating seams, grime, wear, staining) "
    "there, never new furniture, walls, or objects. Only the props that "
    "literally appear as shapes in the base truth reference may be "
    "rendered as props; everything else is floor surface.\n\n"
    "SECOND MOST COMMON FAILURE TO AVOID: silhouette drift, in EITHER "
    "direction. The guide's outline is exact ground truth: if it is a "
    "plain rectangle, your output is a plain rectangle -- do NOT add "
    "chamfered corners, notches, bites, or bevels that are not in the "
    "guide (inventing 'interesting' corner cuts on a rectangular polygon is "
    "the single most frequent defect). If the outline IS irregular, copy "
    "its notches and jogs exactly -- do not square it off. The pure-black "
    "pixels are VOID: outside the ship hull entirely, not a dark unlit "
    "polygon and not a wall to be textured. Do NOT invent a wall or polygon "
    "boundary inside the black void area, and do NOT fill the black void "
    "with floor, structure, or any rendered content -- it must stay "
    "literally pure black RGB(0,0,0)."
)

# SHAPE-CONFORMANCE LAW (director's ruling, 2026-07-11: "it still doesn't
# match the shape of the polygons"): a rectilinear plate/seam grid rendered
# axis-aligned regardless of the polygon's actual wall angles, cropped by
# the mask, was confirmed on l03/polygon_0 and l03/polygon_2 (both true
# quadrilaterals with no right angles) -- the panel grid runs dead
# horizontal/vertical/45-degree while every wall runs at its own oblique
# angle, so seams slice diagonally through the middle of plates at the
# boundary instead of meeting the wall cleanly. GEOMETRY_LOCK's guide image
# now explicitly draws the wall lines and doorway gaps (see make_guide) --
# this law tells the model what to DO with that boundary, not just what to
# preserve.
SHAPE_LAW = (
    "The geometry guide draws the polygon's wall lines directly (bright thin "
    "lines on the floor) and marks each doorway as a gap in that outline. "
    "Construct the plating/panel grid, seams, cable runs, and any "
    "directional wear pattern so they run PARALLEL to the wall segment "
    "they are nearest to -- for an oblique/angled wall, the adjacent plate "
    "row must be angled to match, not forced into a horizontal/vertical "
    "grid. At each real corner (where two wall lines meet, including "
    "shallow chamfers and notches), plates should meet that corner the way "
    "physical flooring is actually installed: mitred or trimmed to the "
    "corner, never sliced off mid-plate by an unrelated axis-aligned grid. "
    "At each doorway gap, the plating should read as a clean threshold, "
    "not a stripe truncated mid-pattern. If the polygon is an irregular "
    "polygon (most polygons are), the material grid must visibly bend/rotate "
    "to track the actual wall angles across the polygon -- a single uniform "
    "axis-aligned grid stamped over an oblique polygon and cropped by the "
    "silhouette is the exact failure mode to avoid."
)


def build_material_prompt(kind: str) -> str:
    """Per-kind TILEABLE BASE MATERIAL swatch (style continuity, property
    2): generated ONCE per polygon kind, square, no geometry -- just the
    material every polygon of this kind will share as its dominant tone/
    material family."""
    material = KIND_MATERIAL[kind]
    flavor = (
        "This surface is Testator-made: alien, older, non-human geometry, "
        "asymmetric, unsettling."
        if kind in TESTATOR_KINDS else
        "This surface is MIRIAD-era human infrastructure: utilitarian, "
        "regular, maintained, at most creeping corruption at the edges."
    )
    return (
        f"{STYLE_LANGUAGE}\n\n"
        f"Polygon kind: {kind}. {flavor} Material language: {material}.\n\n"
        "This is a MATERIAL SWATCH, not a polygon: a flat, square, "
        "seamlessly-tileable sample of this floor material, photographed "
        "top-down with no perspective, no polygon walls, no furniture, no "
        "props, no doorway, nothing that reads as a bounded space -- just "
        "the continuous plating surface itself, as if cut from an "
        "infinite floor. The four edges of this square must be able to "
        "tile edge-to-edge with copies of itself with no visible seam: "
        "do not let any large distinctive feature (a big stain, a unique "
        "mark) sit near an edge in a way that would repeat obviously.\n\n"
        f"{FULLBLEED_LAW}\n\n"
        f"{NO_SIGNAGE_LAW}\n\n"
        "This is the STYLE ANCHOR MATERIAL for this polygon kind: every polygon "
        "of this kind will share this exact material identity as its "
        "dominant tone and surface language, so make it clear and "
        "distinctive but generic enough to read as 'more of this same "
        "floor' anywhere."
    )


# Per-kind DIEGETIC FLOORPLAN notes (director's ruling, property 3): where
# people walk vs where equipment sits, and how wear/staining should follow
# that plan rather than an invented decorative pattern. See FLOORPLANS.md
# for the full polygon-by-polygon rationale this is distilled from.
FLOORPLAN_NOTE = {
    "hydro": (
        "FLOORPLAN (described in words -- the geometry guide deliberately "
        "shows floor only, no trough shapes): wall-mounted troughs run as "
        "growing-bed rows along the walls; there is also ONE island trough "
        "near the polygon's center. Do NOT paint any trough/tray/planter "
        "shape, grid line, or row yourself -- the troughs are separate "
        "physical objects the game draws live on top of your texture; "
        "your job is only to bias where floor STAINING concentrates. "
        "These troughs leave the rest of the floor open as walk aisles -- "
        "especially the paths from the doorway to the center trough and "
        "around it to each wall trough. Concentrate damp/algae/mineral "
        "staining along the wall band and around the polygon's center (near "
        "where those troughs actually sit -- condensation and overflow "
        "drip naturally pool right next to a planter, not evenly across "
        "the whole polygon) -- do NOT paint an even all-over damp/organic "
        "pattern across the entire floor. The walk aisles between the "
        "wall band and the center must read as comparatively clean, "
        "scuffed-but-dry plating -- a worker can cross this polygon without "
        "stepping over anything."
    ),
    "dock": (
        "FLOORPLAN: crates cluster in the two polygon corners farthest from "
        "the door (out of the way); a loader's working lane runs along one "
        "wall; the path from the doorway to the mooring-ring wall is the "
        "main tow/walk lane. Show a visibly worn, slightly lighter travel "
        "path along that line (a soft polish gradient, not a painted "
        "stripe or arrow); let the crate corners read grimier (low "
        "traffic)."
    ),
    "corridor": (
        "FLOORPLAN: this is a through-corridor. Show worn traffic polish "
        "(lighter, smoother-looking plating) down the center walk lane, "
        "fading to grimier plating at the wall edges under the pipe runs "
        "-- a gradual polish gradient, never a painted stripe, chevron, or "
        "arrow marking the lane."
    ),
    "storage": (
        "FLOORPLAN: the crate rows already leave a walkable aisle between "
        "them for cart traffic. Show the aisle as polished/worn plating; "
        "show dust and undisturbed grime specifically in the shadow under "
        "and between the crate rows, away from the aisle."
    ),
    "lab": (
        "FLOORPLAN: the specimen table (a separate physical object the "
        "game draws live -- do not paint it) sits as the polygon's "
        "workstation near the wall opposite the doorway; screens are "
        "wall-mounted. Concentrate faint chemical staining as irregular "
        "floor grime near that area only (no painted line, cable, tray, "
        "or conduit shape); keep the rest of the open floor plain, "
        "unstained."
    ),
    "quarters": (
        "FLOORPLAN: cot bays ring the walls with open floor in the "
        "middle. Concentrate scuff/wear at the foot of each bunk (where a "
        "person stands to use the footlocker) and along doorway-to-bunk "
        "paths; keep the open center floor lightly worn but plain."
    ),
    "chapel": (
        "FLOORPLAN: pews face the dais along the front wall; the center "
        "aisle (perpendicular to the pew rows) and the area around the "
        "dais are where bodies moved. Let old dark ritual staining follow "
        "those paths specifically, not an even wash across the polygon."
    ),
}


def build_polygon_prompt(kind: str, has_neighbor_composite: bool = False,
                       box_note: str = "", decal_note: str = "") -> str:
    material = KIND_MATERIAL[kind]
    flavor = (
        "Testator-made: alien, older, non-human geometry, asymmetric, "
        "unsettling."
        if kind in TESTATOR_KINDS else
        "MIRIAD-era human infrastructure: utilitarian, regular, maintained."
    )
    floorplan = FLOORPLAN_NOTE.get(kind, "")
    neighbor_note = (
        "Third reference image: a NEIGHBOR-CONTINUITY COMPOSITE -- your "
        "target polygon's outline (cyan lines) with "
        "each ALREADY-BUILT adjacent polygon's real floor texture pasted just "
        "outside the matching doorway edge, at the actual world angle that "
        "doorway connects at. This image is INFORMATION ONLY -- do NOT "
        "reproduce its layout: your output must show ONLY the target polygon, "
        "framed exactly as in the FIRST reference image (same crop, same "
        "aspect ratio), with NO neighbor floor strips, NO cyan/magenta "
        "lines, and NO extra black padding around the polygon. What the "
        "composite tells you: the floor visible just past each doorway gap "
        "is the physical floor that continues through that threshold "
        "in-game -- so at each doorway, continue that material seamlessly: "
        "matching tone, matching seam/plate direction, matching wear "
        "level, so a player walking through sees one unbroken floor, not "
        "two mismatched plates meeting at the threshold. A threshold is "
        "OPEN FLOOR: never paint a door, hatch, dark recessed inset, "
        "frame, sill, or threshold plate where a neighbor strip touches "
        "your polygon -- just the same continuous floor plating running "
        "straight out of frame.\n\n"
        if has_neighbor_composite else ""
    )
    return (
        f"{STYLE_LANGUAGE}\n\n"
        f"Polygon kind: {kind}. {flavor} Material language: {material}.\n\n"
        + (f"{floorplan}\n\n" if floorplan else "") +
        "First reference image: this polygon's GEOMETRY GUIDE -- a flat "
        "vector render of THIS polygon's exact layout (floor region shown "
        "brightened for clarity, pure "
        "black = void outside the hull, thin CYAN lines = the polygon's real "
        "wall lines at their real angles). This guide is FLOOR MATERIAL "
        "ONLY -- it deliberately shows NO crates, consoles, pipes, vents, "
        "chevrons, or any other prop/object. Those are separate physical "
        "objects the game draws live on top of your texture every frame; "
        "your job is the bare floor plating underneath them, not an "
        "illustration of them. Do NOT invent or paint any crate, console, "
        "pipe, vent, arrow/chevron, valve wheel, sign, or any other "
        "discrete object anywhere in your output -- floor material and "
        "irregular wear/staining/grime only. Re-render THIS image: its floor "
        "region, silhouette, wall angles, doorway positions, and aspect "
        "ratio are binding; your output must have the same "
        "aspect ratio and layout as this guide, and must NOT render the "
        "cyan guide lines themselves -- they mark where the walls are, "
        "they are not paint on the floor; render ordinary floor material "
        "running under where the line is drawn. CRITICAL FRAMING "
        "RULE: in the guide, the floor polygon runs flush against the "
        "image crop edges (the crop is the polygon's tight bounding box). "
        "Your output must do the same -- wherever the guide's floor "
        "touches the image edge, your floor must touch the image edge "
        "too. Never shrink the polygon inward, never leave a black margin, "
        "gutter, or frame between the floor and the crop edge, and never "
        "draw a dark wall band inside the boundary. Second reference "
        "image: the TILEABLE BASE MATERIAL for this polygon kind -- this is a "
        "swatch of the SAME physical floor plating every polygon of this kind "
        "is made of. Use it as the dominant material/tone/palette "
        "reference for the open floor areas of this polygon (it shows no "
        "polygon, no props -- do not copy any shape from it, only its "
        "material). Keep the strongest per-polygon wear/staining/markings "
        "AWAY from the polygon's outer edges/walls so adjacent polygons of this "
        "kind read as one continuous physical floor at the boundary. Note "
        "the guide's floor has been artificially brightened so you can "
        "see the polygon shape -- your OUTPUT palette should match the base "
        "material's tone, not the guide's brightness.\n\n"
        f"{neighbor_note}"
        f"{FULLBLEED_LAW}\n\n"
        f"{GEOMETRY_LOCK}\n\n"
        f"{SHAPE_LAW}\n\n"
        + (f"{box_note}\n\n" if box_note else "")
        + f"{NO_SIGNAGE_LAW}\n\n"
        + (f"{decal_note}\n\n" if decal_note else "")
        + f"{FULLBLEED_FINAL_REMINDER}"
    )
