"""Layer order (director's standing order, 2026-07-21):

    1. rooms
    2. entities and decals, on their own layer, NEVER cut by a room boundary
    3. the LOS shadow, on top of both, so a body at the edge of sight is
       OCCLUDED rather than sliced

These are TEST VECTORS: isolated worlds built to disprove the property,
not screenshots of a real level. Each renders a frame with the subject and
an identical frame without it, and counts the pixels that differ — a
silhouette measurement that cannot be fooled by floor colour.
"""
from __future__ import annotations

import numpy as np
import pygame

from perihelion.levels import LevelBuilder
from perihelion.render import Renderer
from perihelion.sim import GameSession, InputFrame


def _render(level, spawn=None, setup=None):
    s = GameSession(level, seed=3, screen=(640, 360), zoom=1.0)
    s.douse_player_lights()          # only authored light, no player lamp
    # structure lamps would smear a light halo into the diff and hide a cut
    # sprite behind a big lit-floor silhouette; the vectors measure the ART
    s._structure_light = lambda *a, **k: None
    if spawn is not None:
        polygon, off, kind = spawn
        vs = s.level.polygon_verts[polygon]
        cx = sum(v[0] for v in vs) / len(vs)
        cy = sum(v[1] for v in vs) / len(vs)
        s.spawn_enemy(polygon, (cx + off[0], cy + off[1]), kind)
    if setup is not None:
        setup(s)
    r = Renderer(s)
    surf = pygame.Surface((640, 360))
    for _ in range(2):
        s.tick(InputFrame())
    r.consume_fx(s.fx)
    return r.draw(surf).astype(np.int32)


def _silhouette(level, spawn, setup=None) -> int:
    base = _render(level, None)
    with_it = _render(level, spawn, setup)
    return int((np.abs(with_it - base).sum(axis=2) > 12).sum())


def _two_rooms(side=0):
    """Two lit rooms sharing a full-width portal: the seam between them is
    INSIDE the line of sight, so nothing may be cut there. `side` picks the
    room the player starts in — instance draw order follows the player, and
    a cut caused by a later instance overpainting an earlier one only shows
    from one side, so every seam vector is asserted from BOTH."""
    b = LevelBuilder("SEAM", 1)
    r0 = b.rect(0, 0, 160, 160, kind="dock")
    r1 = b.rect(160, 0, 160, 160, kind="dock")
    b.connect(r0, 2, r1, 0)
    b.player(r1 if side else r0, (280, 80) if side else (40, 80))
    b.exit(r1, (300, 80))
    b.light(r0, (80, 80), color=(255, 240, 220), intensity=1.0, radius=260.0)
    b.light(r1, (240, 80), color=(255, 240, 220), intensity=1.0, radius=260.0)
    return b.build()


def _corner():
    """A slot corridor and a room around the corner: the far room is out of
    the line of sight from the player's room."""
    b = LevelBuilder("LOS", 1)
    r0 = b.rect(0, 0, 160, 160, kind="dock")
    r1 = b.rect(160, 60, 150, 40, kind="corridor")
    r2 = b.rect(310, -60, 120, 160, kind="dock")
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 2, r2, 3)
    b.player(r0, (60, 80))
    b.exit(r2, (370, -20))
    for polygon, pos in ((r0, (80, 80)), (r1, (235, 80)), (r2, (370, 20))):
        b.light(polygon, pos, color=(255, 240, 220), intensity=1.0,
                radius=260.0)
    return b.build()


def test_a_body_on_a_room_seam_is_not_cut():
    """LAYER 2: a body standing exactly on the boundary between two VISIBLE
    rooms draws whole. Before the layer split, the entity plane was masked
    by the per-instance coverage union and bodies were sliced at seams."""
    level = _two_rooms()
    verts = level.polygon_verts[0]
    seam_x = max(v[0] for v in verts)          # the shared wall, in r0's frame
    open_px = _silhouette(level, (0, (0.0, 0.0), "husk"))
    seam_px = _silhouette(level, (0, (seam_x, 0.0), "husk"))
    assert open_px > 150, f"the reference body did not draw ({open_px}px)"
    # a body ON the seam keeps essentially all of its pixels
    assert seam_px >= open_px * 0.9, (
        f"body cut at a room boundary: {seam_px}px on the seam vs "
        f"{open_px}px in open floor")


def test_a_body_past_the_corner_is_not_drawn():
    """LAYER 3: out of the line of sight is out of the picture."""
    hidden = _silhouette(_corner(), (2, (0.0, -50.0), "husk"))
    assert hidden == 0, f"a body around the corner drew {hidden}px"


def test_a_body_at_the_edge_of_sight_is_partly_occluded():
    """LAYER 3: at the boundary a body is PARTLY shadowed — neither fully
    drawn (which would show it through a wall) nor fully erased."""
    level = _corner()
    full = _silhouette(level, (1, (0.0, 0.0), "husk"))
    edge = _silhouette(level, (1, (60.0, 0.0), "husk"))
    assert full > 150, f"the reference body did not draw ({full}px)"
    assert 0 < edge < full * 0.75, (
        f"body at the edge of sight drew {edge}px against {full}px in the "
        "open — expected partial occlusion by the LOS shadow")


# (the two-backend parametrization died with the pygame renderer; the seam
# property itself is covered per element type below)


def _bbox(level, spawn) -> tuple[int, int]:
    """Width and height in pixels of the subject's silhouette."""
    base = _render(level, None)
    with_it = _render(level, spawn)
    diff = np.abs(with_it - base).sum(axis=2) > 12
    xs, ys = np.where(diff)
    if len(xs) == 0:
        return (0, 0)
    return (int(xs.max() - xs.min() + 1), int(ys.max() - ys.min() + 1))


def test_the_adversary_trace_reads_larger_than_an_ordinary_body():
    """The Adversary is not a body with an outline, it is a return the
    instrument cannot resolve — and something unresolvable must be BIGGER
    on screen than the things that resolve fine, or all its structure
    lands inside a speck and it reads as one more small blob (which is
    exactly how the director read the first cut).

    A vagrant's hitbox (9.5u) is only fractionally larger than a husk's
    (8.0u), so this asserts on the DRAWN silhouette, which is the thing
    the director actually sees.
    """
    level = _two_rooms()
    husk_w, husk_h = _bbox(level, (0, (0, 0), "husk"))
    adv_w, adv_h = _bbox(level, (0, (0, 0), "vagrant"))
    assert husk_w > 0 and adv_w > 0, "a subject failed to draw at all"
    assert adv_w >= husk_w * 1.6 and adv_h >= husk_h * 1.6, (
        f"the Adversary reads no bigger than a husk: "
        f"vagrant {adv_w}x{adv_h}px vs husk {husk_w}x{husk_h}px")


def test_the_adversary_is_still_occluded_like_everything_else():
    """Drawing the trace oversized must not exempt it from layer 3 — a
    vagrant around the corner is still not visible."""
    level = _corner()
    assert _silhouette(level, (2, (0.0, -50.0), "vagrant")) == 0


# ---------------------------------------------------------------------------
# WORLD-LAYER sprites on a seam (director, fifth telling, 2026-07-22: "draw
# the floors, then everything else on top"). Entities got their own plane
# long ago; stations, repair cabinets and decals still draw interleaved with
# the floors, so a later instance's floor fill can overpaint the half of a
# sprite that overhangs the boundary. These vectors FORCE a sprite across
# the seam — the bot's own placement gap keeps buildings off seams, which is
# exactly why recorded-game frames never showed the bug and a test vector is
# the only honest instrument.
# ---------------------------------------------------------------------------

def _seam_x(level):
    return max(v[0] for v in level.polygon_verts[0])


def _station_at(pos):
    def setup(s):
        s.add_station(0, pos)
    return setup


def _repair_at(x, y):
    """The exact record `place_repair` builds (same fields, same entity
    spawn), injected directly: the real call can only plant in the player's
    own polygon and floats fx text that would contaminate the silhouette."""
    def setup(s):
        from perihelion.sim import GROUP_PICKUP
        bid = s.sim.spawn(0, x, y, 6.5, 100.0, GROUP_PICKUP)
        s.sim.set_props(bid, transfers=False)
        s.boosters.append(dict(polygon=0, pos=(x, y),
                               charge=s.BOOSTER_CHARGE, hp=s.REPAIR_HP,
                               eid=bid, light=None))
    return setup


def _decal_at(pos):
    def setup(s):
        s.decals.setdefault(0, []).append(("blood", pos[0], pos[1], 14.0, 0.7))
    return setup


def test_a_station_on_a_seam_is_not_cut_from_either_side():
    for side in (0, 1):
        level = _two_rooms(side)
        sx = _seam_x(level)
        open_px = _silhouette(level, None, _station_at((0.0, 40.0)))
        seam_px = _silhouette(level, None, _station_at((sx - 4.0, 40.0)))
        assert open_px > 150, f"side {side}: reference station drew {open_px}px"
        assert seam_px >= open_px * 0.85, (
            f"side {side}: station cut at the seam — {seam_px}px vs "
            f"{open_px}px in open floor")


def test_a_repair_station_on_a_seam_is_not_cut_from_either_side():
    for side in (0, 1):
        level = _two_rooms(side)
        sx = _seam_x(level)
        open_px = _silhouette(level, None, _repair_at(30.0, 40.0))
        seam_px = _silhouette(level, None, _repair_at(sx - 4.0, 40.0))
        assert open_px > 100, f"side {side}: reference cabinet drew {open_px}px"
        assert seam_px >= open_px * 0.85, (
            f"side {side}: repair cabinet cut at the seam — {seam_px}px vs "
            f"{open_px}px in open floor")


def test_a_decal_on_a_seam_is_not_cut_from_either_side():
    for side in (0, 1):
        level = _two_rooms(side)
        sx = _seam_x(level)
        open_px = _silhouette(level, None, _decal_at((0.0, 40.0)))
        seam_px = _silhouette(level, None, _decal_at((sx - 2.0, 40.0)))
        assert open_px > 40, f"side {side}: reference decal drew {open_px}px"
        assert seam_px >= open_px * 0.80, (
            f"side {side}: decal cut at the seam — {seam_px}px vs "
            f"{open_px}px in open floor")


def test_a_station_around_the_corner_is_not_visible():
    """LOS still wins: an unlit, out-of-sight room's station draws nothing —
    drawing world sprites whole must not leak them through walls."""
    level = _corner()
    hidden = _silhouette(level, None, lambda s: s.add_station(2, (0.0, -50.0)))
    assert hidden == 0, f"a station around the corner drew {hidden}px"
