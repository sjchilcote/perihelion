"""Walk-mask terrain (director's directive): `<texture>_walkmask.png`
(white=walkable, black=terrain) loads into polygon-local collision rects that
block movement/projectiles exactly like a wall, absence means fully
walkable, and the PNG decoder in `terrain.py` (stdlib-only, kept out of
`sim.py`'s dependency-free lane) must read exactly what a reference PNG
library (PIL) wrote.
"""

from __future__ import annotations

import numpy as np
import pytest
from PIL import Image, ImageDraw

from perihelion.app import build_debug_level
from perihelion.sim import GameSession
from perihelion import terrain, texture_geom


def _write_mask(root, level_id: str, polygon_index: int, w: int, h: int,
                 black_rect=None, mode="RGB") -> None:
    """A `w`x`h` walk-mask PNG, white everywhere except `black_rect`
    (tx0, ty0, tx1, ty1) in texel coordinates, if given."""
    (root / level_id).mkdir(parents=True, exist_ok=True)
    img = Image.new("RGB", (w, h), (255, 255, 255))
    if black_rect is not None:
        tx0, ty0, tx1, ty1 = black_rect
        ImageDraw.Draw(img).rectangle((tx0, ty0, tx1 - 1, ty1 - 1),
                                      fill=(0, 0, 0))
    if mode == "gray8":
        img = img.convert("L")  # already 0 or 255 everywhere -> lossless
    path = terrain.texture_geom.texture_path(root, level_id, polygon_index)
    path = path.with_name(path.stem + "_walkmask" + path.suffix)
    img.save(path)


def _tex_root_and_level(tmp_path, level_id="walkmasktest"):
    level = build_debug_level()
    level.level_id = level_id
    return level, tmp_path


# ---------------------------------------------------------------------
# Decoder correctness: our stdlib-only PNG reader vs. PIL ground truth.
# ---------------------------------------------------------------------

@pytest.mark.parametrize("mode", ["RGB", "gray8"])
def test_decoder_matches_pil_reference(tmp_path, mode):
    w, h = 37, 23  # deliberately not a DOWNSAMPLE multiple
    img = Image.new("RGB", (w, h), (10, 10, 10))
    d = ImageDraw.Draw(img)
    d.rectangle((5, 5, 24, 14), fill=(250, 250, 250))
    d.ellipse((26, 11, 34, 19), fill=(128, 128, 128))
    if mode == "gray8":
        img = img.convert("L")
    path = tmp_path / "ref.png"
    img.save(path)

    dw, dh, luma = terrain.decode_png_luminance(path.read_bytes())
    assert (dw, dh) == (w, h)

    ref = np.asarray(img.convert("RGB")).astype(np.int64)  # (h, w, 3)
    expect_luma = (ref[:, :, 0] * 299 + ref[:, :, 1] * 587 + ref[:, :, 2] * 114) // 1000
    got = np.frombuffer(luma, dtype=np.uint8).reshape(h, w)  # row-major
    # Off-by-one luma rounding at a few edge pixels is fine; must match
    # everywhere to within 1.
    assert np.abs(got.astype(int) - expect_luma).max() <= 1


def test_decoder_rejects_bad_signature():
    with pytest.raises(terrain.WalkMaskError):
        terrain.decode_png_luminance(b"not a png")


# ---------------------------------------------------------------------
# Absence = fully walkable.
# ---------------------------------------------------------------------

def test_absence_of_mask_file_means_fully_walkable(tmp_path, monkeypatch):
    level, root = _tex_root_and_level(tmp_path)
    monkeypatch.setattr(terrain, "TEXTURE_DIR", root)
    session = GameSession(level, seed=1)
    assert session.sim.polygon_terrain(0) == []


def test_level_with_no_level_id_never_touches_disk(tmp_path, monkeypatch):
    level = build_debug_level()
    assert level.level_id == ""
    monkeypatch.setattr(terrain, "TEXTURE_DIR", tmp_path)  # empty dir
    session = GameSession(level, seed=1)  # must not raise, must load no terrain
    for r in range(session.sim.num_polygons()):
        assert session.sim.polygon_terrain(r) == []


# ---------------------------------------------------------------------
# A real mask blocks movement and projectiles, matching the floor
# texture's own coordinate mapping.
# ---------------------------------------------------------------------

def _polygon0_mask_session(tmp_path, monkeypatch, black_rect_texels):
    level, root = _tex_root_and_level(tmp_path)
    w, h = texture_geom.texture_size_for_polygon(level.polygon_verts[0])
    _write_mask(root, level.level_id, 0, w, h, black_rect_texels)
    monkeypatch.setattr(terrain, "TEXTURE_DIR", root)
    return GameSession(level, seed=1), w, h


def test_walk_mask_installs_matching_polygon_local_rect(tmp_path, monkeypatch):
    # Polygon 0's local bbox is (-80,-60)-(80,60) (rect 160x120, LevelBuilder
    # centers it): a black block at texel (200,150)-(280,210) maps to
    # local (-13.33,-10)-(13.33,10) via the texel law.
    session, w, h = _polygon0_mask_session(tmp_path, monkeypatch, (200, 150, 280, 210))
    rects = session.sim.polygon_terrain(0)
    assert len(rects) >= 1
    lo_x = min(r[0] for r in rects)
    lo_y = min(r[1] for r in rects)
    hi_x = max(r[2] for r in rects)
    hi_y = max(r[3] for r in rects)
    assert abs(lo_x - (-80 + 200 / texture_geom.DENSITY)) < 1.0
    assert abs(hi_x - (-80 + 280 / texture_geom.DENSITY)) < 1.0
    assert abs(lo_y - (-60 + 150 / texture_geom.DENSITY)) < 1.0
    assert abs(hi_y - (-60 + 210 / texture_geom.DENSITY)) < 1.0


def test_walk_mask_blocks_player_movement(tmp_path, monkeypatch):
    # A black block centered in the polygon (texel (200,150)-(280,210) ->
    # local x in roughly [-13, 13]); starting well to its left and walking
    # straight along +x, the player must be stopped at its face, never
    # tunnel through.
    session, w, h = _polygon0_mask_session(tmp_path, monkeypatch, (200, 150, 280, 210))
    sim = session.sim
    sim.set_pos(session.pid, sim.place(sim.get_polygon(session.pid), -60.0, 0.0))
    sim.set_vel(session.pid, sim.get(session.pid).pos.offset(150.0, 0.0))
    for _ in range(120):
        sim.step(1.0 / 60.0)
    px, py = sim.get(session.pid).pos.local()
    assert px < -13.0 + 1.0, f"player tunneled through walk-mask terrain: pos ({px},{py})"


def test_walk_mask_blocks_projectiles(tmp_path, monkeypatch):
    session, w, h = _polygon0_mask_session(tmp_path, monkeypatch, (200, 150, 280, 210))
    sim = session.sim
    bid = sim.spawn(sim.place(0, -60.0, 0.0), 1.5, 0.01, 2)  # GROUP_PBULLET
    sim.set_props(bid, rest_wall=0.0, max_substep=3.0)
    sim.set_vel(bid, sim.get(bid).pos.offset(2000.0, 0.0))
    for _ in range(30):
        sim.step(1.0 / 60.0)
    bx, by = sim.get(bid).pos.local()
    assert bx < -13.0 + 1.0, f"projectile passed through walk-mask terrain: pos ({bx},{by})"


def test_walk_mask_size_mismatch_fails_loudly(tmp_path, monkeypatch):
    level, root = _tex_root_and_level(tmp_path)
    w, h = texture_geom.texture_size_for_polygon(level.polygon_verts[0])
    _write_mask(root, level.level_id, 0, w + 10, h, None)  # wrong size, no fallback
    monkeypatch.setattr(terrain, "TEXTURE_DIR", root)
    with pytest.raises(terrain.WalkMaskError):
        GameSession(level, seed=1)


# ---------------------------------------------------------------------
# Streamed chunks: append_chunk must load the appended polygon's own mask.
# ---------------------------------------------------------------------

def test_append_chunk_loads_its_own_walk_mask(tmp_path, monkeypatch):
    level, root = _tex_root_and_level(tmp_path, level_id="chunkA")
    monkeypatch.setattr(terrain, "TEXTURE_DIR", root)
    session = GameSession(level, seed=1)
    offset = session.sim.num_polygons()

    chunk = build_debug_level()
    chunk.level_id = "chunkB"
    w, h = texture_geom.texture_size_for_polygon(chunk.polygon_verts[0])
    _write_mask(root, chunk.level_id, 0, w, h, (200, 150, 280, 210))

    session.append_chunk(chunk)
    assert session.sim.polygon_terrain(offset) != []
    # the original session's own polygons are untouched (no mask authored)
    assert session.sim.polygon_terrain(0) == []
