"""tools/artgen/pilot_texture_lib.py

Shared helpers for the floor-texture pilot: exact room polygon masks (same
local frame as room_basetruth.py), prompt templates per room kind, and
small path helpers. No network calls here.
"""
from __future__ import annotations

import json
import math
import os
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np  # noqa: E402
import pygame  # noqa: E402
import necore  # noqa: E402

from perihelion.levels import load_level  # noqa: E402

SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad"
)
BASETRUTH_DIR = SCRATCH / "basetruth"
PILOT_JSON = ROOT / "tools" / "artgen" / "pilot_rooms.json"
TEXTURES_ROOT = ROOT / "game" / "perihelion" / "assets" / "textures"

_level_cache: dict[str, object] = {}


def get_level(stem: str):
    if stem not in _level_cache:
        _level_cache[stem] = load_level(ROOT / "levels" / f"{stem}.json")
    return _level_cache[stem]


def room_mask(stem: str, room_idx: int, px_per_unit: float = 3) -> np.ndarray:
    """Boolean (H, W) mask, True = inside the room polygon, in the exact
    same local frame room_basetruth.py rendered into (min-bound offset,
    ceil(w*ppu) x ceil(h*ppu))."""
    level = get_level(stem)
    verts = level.room_verts[room_idx]
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    x0, x1 = min(xs), max(xs)
    y0, y1 = min(ys), max(ys)
    w_px = max(1, math.ceil((x1 - x0) * px_per_unit))
    h_px = max(1, math.ceil((y1 - y0) * px_per_unit))

    xform = necore.mat_mul(necore.mat_scale(px_per_unit, px_per_unit),
                            necore.mat_translate(-x0, -y0))
    poly = [necore.mat_apply(xform, x, y) for x, y in verts]

    surf = pygame.Surface((w_px, h_px), depth=8)
    surf.fill(0)
    pygame.draw.polygon(surf, 1, poly)
    mask = pygame.surfarray.pixels2d(surf).T.copy()  # (H, W)
    return mask.astype(bool)


def apply_mask(im, mask: np.ndarray):
    """im: PIL.Image RGB, mask: (H, W) bool, True=keep. Returns PIL.Image
    RGB with masked-out pixels forced to black. The mask is nearest-resized
    to im's size first if they differ by the sub-pixel rounding slop
    between pilot_rooms.json's tex_w/tex_h and room_mask's own
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


def make_guide(stem: str, room_idx: int, out_path: Path) -> Path:
    """Build the geometry-guide reference sent to the image model: the room's
    base truth with the in-polygon floor region brightened (so near-black
    floor fill can never be confused with the pure-black outside-hull void)
    and the void forced to exact black. Props/details keep their relative
    contrast; only the interior is lifted."""
    from PIL import Image
    bt = Image.open(basetruth_path(stem, room_idx)).convert("RGB")
    arr = np.asarray(bt).astype(np.int16)
    mask = room_mask(stem, room_idx, 3)
    if arr.shape[:2] != mask.shape:
        raise RuntimeError(
            f"guide size mismatch {arr.shape[:2]} vs mask {mask.shape} for {stem}/{room_idx}")
    lifted = np.clip(arr + 70, 0, 255)
    out = np.where(mask[..., None], lifted, 0).astype(np.uint8)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(out, "RGB").save(out_path)
    return out_path


def load_pilot():
    return json.loads(PILOT_JSON.read_text())


def basetruth_path(stem: str, room_idx: int) -> Path:
    return BASETRUTH_DIR / stem / f"room_{room_idx:03d}.png"


def texture_out_path(stem: str, room_idx: int) -> Path:
    # MUST match game/perihelion/texture_geom.py::texture_path (unpadded).
    return TEXTURES_ROOT / stem / f"room_{room_idx}.png"


# ---------------------------------------------------------------------------
# authorship flavor
# ---------------------------------------------------------------------------

TESTATOR_KINDS = {"otherworld", "chapel", "core"}

KIND_MATERIAL = {
    "dock": "heavy anti-slip deck plating, cargo tie-down rings, faded "
            "stenciled bay-number markings, oil and rust streaking along "
            "seams, scuffed from loader traffic",
    "corridor": "modular utility deck plating with regular rivet seams, "
                "recessed conduit runs along the base of the walls, worn "
                "traffic paths down the center, occasional grime and rust "
                "bleeding from panel joints",
    "transit": "wide utilitarian transit-deck plating, directional floor "
               "striping (worn, half-legible), handrail mounting stubs, "
               "scuffed high-traffic wear",
    "storage": "stacked utility shelving brackets, crate outlines, "
               "chained-down container marks, dust and grime in low-traffic "
               "corners, plain structural plating",
    "pump": "wet-service textured deck grating, pipe-flange mounts, mineral "
            "staining and condensation streaks, utilitarian maintenance "
            "signage",
    "lab": "clean-room composite flooring gone slightly grimy, embedded "
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
              "ritual patterns, alien symbol fragments worn into the "
              "surface, unsettling non-orthogonal proportions",
    "medbay": "clinical composite flooring, drainage grates, faded triage "
              "markings, disinfectant stains gone dull, precise MIRIAD "
              "panel seams -- STRICTLY man-made hospital materials only: "
              "linoleum-like composite tile, metal cabinet fronts, plastic "
              "trim, dried blood/rust stains ON TOP of clinical flooring. "
              "This is emphatically NOT organic, NOT fleshy, NOT alien "
              "tissue -- no veins, no growths, no biological texture of "
              "any kind, even though the palette may be dark reddish-brown "
              "from old blood stains and low light.",
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

STYLE_LANGUAGE = (
    "Photoreal-leaning painterly sci-fi horror environment texture, top-down "
    "orthographic view, muted desaturated industrial palette (cold grays, "
    "rust ochres, dull teals, near-black shadow) -- NOT bright, NOT "
    "saturated, NOT colorful; this is a derelict deep-space station lit by "
    "failing utility lighting. Overhead/flat lighting only, no strong "
    "directional shadows or highlights (the in-game darkness/lighting pass "
    "is applied later -- render this at a NEUTRAL flat exposure, do not "
    "pre-darken or pre-brighten). Hyper-detailed surface material: real "
    "wear, scuffing, grime, corrosion, panel seams, exactly matching the "
    "reference layout."
)

GEOMETRY_LOCK = (
    "CRITICAL geometry constraint: this must be the SAME room, at the SAME "
    "pixel dimensions as the base-truth reference image, viewed from "
    "directly above (top-down orthographic, no perspective tilt). Preserve "
    "EXACTLY: the room's outer silhouette/polygon boundary, every wall "
    "line position, and the position/footprint of every prop/object visible "
    "in the base truth. Do not add, remove, resize, or move any wall or "
    "prop. Do not rotate, crop, or reframe. Area outside the room polygon "
    "(pure black in the reference) must stay pure black. This is a texture "
    "re-render of the identical geometry at 4x visual fidelity -- not a "
    "reinterpretation, not a new room.\n\n"
    "MOST COMMON FAILURE TO AVOID: inventing new interior walls, "
    "partitions, machinery consoles, crates, hatches, or clutter that are "
    "NOT present in the base truth, especially in large open/empty floor "
    "areas. If the base truth shows bare open floor with few or no props "
    "in a region, that region MUST stay open bare floor in the output -- "
    "render only material detail (plating seams, grime, wear, staining) "
    "there, never new furniture, walls, or objects. Only the props that "
    "literally appear as shapes in the base truth reference may be "
    "rendered as props; everything else is floor surface.\n\n"
    "SECOND MOST COMMON FAILURE TO AVOID: the room silhouette in the base "
    "truth is almost always IRREGULAR, not a plain rectangle -- it has "
    "notches, jogs, and an uneven boundary matching the actual room "
    "polygon. The pure-black pixels are VOID: outside the ship hull "
    "entirely, not a dark unlit room and not a wall to be textured. Copy "
    "the base truth's exact irregular outline; do NOT square it off into a "
    "rectangle, do NOT invent a wall or room boundary inside the black "
    "void area, and do NOT fill the black void with floor, structure, or "
    "any rendered content -- it must stay literally pure black RGB(0,0,0)."
)


def build_anchor_prompt(kind: str) -> str:
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
        f"Room kind: {kind}. {flavor} Material language: {material}.\n\n"
        "First reference image: the room's current flat vector base-truth "
        "render (floor fill + simple prop shapes) -- treat this as the "
        "exact layout prior. Second reference image: an in-game mood "
        "screenshot showing the real darkness/palette this will be seen "
        "through in play -- match that palette family (do not copy its "
        "darkness level, match its hue/material family).\n\n"
        f"{GEOMETRY_LOCK}\n\n"
        "This is the STYLE ANCHOR for this room kind: every other room of "
        "this kind will be generated to match this exact material "
        "treatment, so make the material identity clear and distinctive."
    )


def build_room_prompt(kind: str) -> str:
    material = KIND_MATERIAL[kind]
    flavor = (
        "Testator-made: alien, older, non-human geometry, asymmetric, "
        "unsettling."
        if kind in TESTATOR_KINDS else
        "MIRIAD-era human infrastructure: utilitarian, regular, maintained."
    )
    return (
        f"{STYLE_LANGUAGE}\n\n"
        f"Room kind: {kind}. {flavor} Material language: {material}.\n\n"
        "First reference image: this room's GEOMETRY GUIDE -- a flat "
        "vector render of THIS room's exact layout (floor region shown "
        "brightened for clarity, simple prop shapes drawn on it, pure "
        "black = void outside the hull). Re-render THIS image: its floor "
        "region, silhouette, aspect ratio, and prop positions are "
        "binding; your output must have the same aspect ratio and layout "
        "as this guide. Second reference image: the STYLE ANCHOR for "
        "this room kind -- take ONLY the material treatment, palette, "
        "and level of detail from it (it shows a DIFFERENT room; do not "
        "copy its layout, its props, its markings, or its aspect ratio). "
        "Note the guide's floor has been artificially brightened so you "
        "can see the room shape -- your OUTPUT palette should match the "
        "style anchor, not the guide's brightness.\n\n"
        f"{GEOMETRY_LOCK}"
    )
