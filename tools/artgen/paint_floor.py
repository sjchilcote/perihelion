"""Painted floor textures for one level, seam-free across portals.

A painted *material* is a square, tileable canvas (a claude-paint oil
painting, see art/oil/) that covers TILE_UNITS world units. Every polygon's
texture (`assets/textures/<level_id>/polygon_<i>.png`, the format
texture_geom.py fixes) is cut from that material in a shared plane: the
polygons are laid out by gluing each one to its BFS parent along their
portal edge, so two polygons joined by a tree portal sample the material
continuously across it. A portal off the tree whose two sides land on the
same place in that plane is seamless too; only the level's genuinely
non-Euclidean loops can show a seam, and the tool reports them.

    uv run python tools/artgen/paint_floor.py --level levels/gauntlet4.json \
        --material deck=/tmp/cp/mat_deck/final.png \
        --material bronze=/tmp/cp/mat_bronze/final.png
"""

from __future__ import annotations

import argparse
import math
import sys
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

from perihelion import texture_geom  # noqa: E402
from perihelion.levels import load_level  # noqa: E402

TEXTURE_DIR = ROOT / "game" / "perihelion" / "assets" / "textures"
TILE_UNITS = 500.0  # world units one material canvas covers
# polygon kind -> material name; kinds absent here keep the flat fill
# (otherworld polygons deform their verts at runtime: no texture, per render.py)
KIND_MATERIAL = {
    "corridor": "deck", "storage": "grate", "quarters": "deck", "medbay": "deck",
    "transit": "deck", "pump": "deck", "dock": "deck", "lab": "deck",
    "hall": "bronze", "chapel": "bronze", "core": "bronze",
}
# a material name with no painting given falls back along this chain
FALLBACK = {"grate": "deck"}


def _rigid(theta, tx, ty):
    return (math.cos(theta), math.sin(theta), tx, ty)


def _apply(t, p):
    c, s, tx, ty = t
    return (c * p[0] - s * p[1] + tx, s * p[0] + c * p[1] + ty)


def _glue(a0, a1, b0, b1):
    """The rigid map sending edge b (b0->b1) onto edge a reversed (b1->a0, b0->a1)."""
    theta = math.atan2(a0[1] - a1[1], a0[0] - a1[0]) - math.atan2(b1[1] - b0[1], b1[0] - b0[0])
    c, s = math.cos(theta), math.sin(theta)
    r = (c * b1[0] - s * b1[1], s * b1[0] + c * b1[1])
    return (c, s, a0[0] - r[0], a0[1] - r[1])


def layout(level):
    """Plane placement of every reachable polygon, by BFS from the player's
    polygon, and the list of portals whose two sides disagree (seams)."""
    verts = level.polygon_verts
    adj: dict[int, list] = {}
    for pa, ea, pb, eb in level.connects:
        adj.setdefault(pa, []).append((ea, pb, eb))
        adj.setdefault(pb, []).append((eb, pa, ea))
    root = level.player_polygon
    place = {root: (1.0, 0.0, 0.0, 0.0)}
    seams = []
    seen = set()
    q = deque([root])
    while q:
        a = q.popleft()
        for ea, b, eb in adj.get(a, []):
            va, vb = verts[a], verts[b]
            a0 = _apply(place[a], va[ea])
            a1 = _apply(place[a], va[(ea + 1) % len(va)])
            t = _glue(a0, a1, vb[eb], vb[(eb + 1) % len(vb)])
            if b not in place:
                place[b] = t
                q.append(b)
            else:
                # both endpoints: a placement can agree at one and be turned about it
                off = max(math.dist(_apply(place[b], v), _apply(t, v))
                          for v in (vb[eb], vb[(eb + 1) % len(vb)]))
                key = frozenset(((a, ea), (b, eb)))
                if off > 0.5 and key not in seen:
                    seams.append((a, ea, b, eb, round(off, 1)))
                seen.add(key)
    return place, seams


def tileable(img: np.ndarray, band: float = 0.08) -> np.ndarray:
    """Hide residual paint variation at a periodic canvas's wrap: blend in the
    half-offset copy near the edges (its structure lines coincide when the
    painting keeps to its periodic grid)."""
    h, w, _ = img.shape
    shifted = np.roll(img, (h // 2, w // 2), axis=(0, 1)).astype(np.float32)
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.minimum.reduce([xx, w - 1 - xx, yy, h - 1 - yy]).astype(np.float32)
    m = np.clip(1.0 - d / (band * min(h, w)), 0.0, 1.0)[..., None]
    m = m * m * (3 - 2 * m)
    return np.rint(img.astype(np.float32) * (1 - m) + shifted * m).astype(np.uint8)


def load_material(path: str) -> np.ndarray:
    im = Image.open(path).convert("RGB")
    if im.size[0] != im.size[1]:
        raise SystemExit(f"{path}: a material must be square, got {im.size}")
    arr = tileable(np.asarray(im))
    # resample with wrap padding so the filter sees the periodic neighbours
    n = arr.shape[0]
    px = int(round(TILE_UNITS * texture_geom.DENSITY))
    pad = n // 16
    big = np.pad(arr, ((pad, pad), (pad, pad), (0, 0)), mode="wrap")
    scale = px / n
    big = np.asarray(Image.fromarray(big).resize(
        (round(big.shape[1] * scale), round(big.shape[0] * scale)), Image.LANCZOS))
    o = round(pad * scale)
    return np.ascontiguousarray(big[o:o + px, o:o + px])


def polygon_texture(verts, place, mat: np.ndarray) -> np.ndarray:
    w, h = texture_geom.texture_size_for_polygon(verts)
    bx, by, _, _ = texture_geom.polygon_bbox(verts)
    d = texture_geom.DENSITY
    ty, tx = np.mgrid[0:h, 0:w].astype(np.float64)
    lx = bx + (tx + 0.5) / d
    ly = by + (ty + 0.5) / d
    c, s, ox, oy = place
    wx = c * lx - s * ly + ox
    wy = s * lx + c * ly + oy
    n = mat.shape[0]
    u = (wx * d) % n
    v = (wy * d) % n
    # bilinear, wrapping
    u0 = np.floor(u).astype(int); v0 = np.floor(v).astype(int)
    fu = (u - u0)[..., None]; fv = (v - v0)[..., None]
    u0 %= n; v0 %= n; u1 = (u0 + 1) % n; v1 = (v0 + 1) % n
    m = mat.astype(np.float32)
    top = m[v0, u0] * (1 - fu) + m[v0, u1] * fu
    bot = m[v1, u0] * (1 - fu) + m[v1, u1] * fu
    return (top * (1 - fv) + bot * fv).clip(0, 255).astype(np.uint8)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--level", required=True)
    ap.add_argument("--material", action="append", default=[], metavar="NAME=PNG")
    ap.add_argument("--out", help="texture dir (default assets/textures/<level_id>)")
    a = ap.parse_args(argv)
    level = load_level(a.level)
    mats = {}
    known = set(KIND_MATERIAL.values()) | set(FALLBACK)
    for spec in a.material:
        name, path = spec.split("=", 1)
        if name not in known:
            raise SystemExit(f"unknown material {name!r}; known: {sorted(known)}")
        mats[name] = load_material(path)
    place, seams = layout(level)
    out = Path(a.out) if a.out else TEXTURE_DIR / level.level_id
    out.mkdir(parents=True, exist_ok=True)
    made = 0
    flat: dict[str, list[int]] = {}
    for i, verts in enumerate(level.polygon_verts):
        kind = level.polygon_kinds[i]
        mname = KIND_MATERIAL.get(kind)
        while mname not in mats and mname in FALLBACK:
            mname = FALLBACK[mname]
        if i not in place:
            flat.setdefault("unreachable from the player", []).append(i)
            continue
        if mname not in mats:
            why = (f"kind {kind!r} has no material" if mname is None
                   else f"material {mname!r} not supplied")
            flat.setdefault(why, []).append(i)
            continue
        tex = polygon_texture(verts, place[i], mats[mname])
        Image.fromarray(tex).save(out / f"polygon_{i}.png")
        made += 1
    print(f"{made} textures written to {out}")
    for why, ids in flat.items():
        print(f"left flat ({why}): polygons {ids}")
    print(f"{len(seams)} non-Euclidean portal seams (polyA, edgeA, polyB, edgeB, offset): {seams}")
    print("material changes at doorways are intended edges, not listed as seams")


if __name__ == "__main__":
    main()
