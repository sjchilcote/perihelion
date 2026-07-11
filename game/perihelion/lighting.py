"""World lights: real objects the visibility engine casts light from --
NOT a screen-space glow. Per the director: "lighting is literally just
running our visibility engine again but from the perspective of the light
and applying color to the areas visible to the light, with realistic
falloff." See ENGINE_DESIGN.md's Lighting section for the full design.

Static-light caching exploits ROOT-FRAME INVARIANCE (ENGINE_INVARIANTS
R1: re-rooting the portal-chain anchor has zero pixel consequence): a
room's own local geometry -- and therefore any wedge cast into it -- looks
identical no matter which portal chain reached it. So a static light's lit
polygon in room R, computed once from the light's own visibility pass, is
valid for ANY camera instance of room R forever; no camera-relative or
chain-relative keying is needed. This is the "per-ROOM caching" fallback
the design brief allows for when chain-keying is intractable -- here it is
*exact*, not an approximation, precisely because R1 already guarantees it.

No engine (rust) changes were needed to build this: `necore.visible_set`
already returns everything required (each reached room's screen-space clip
polygon plus the room-local -> screen transform); the room's OWN local
polygon and the light's virtual local position are recovered by inverting
that transform. See `compute_light_instances` below.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import necore

from .levels import LightSpec

__all__ = ["LightInstance", "compute_light_instances", "LightingSystem"]


@dataclass(frozen=True)
class LightInstance:
    """One wedge a light casts into one room, expressed entirely in that
    ROOM's OWN local frame (chain-independent -- see module docstring)."""
    room: int
    clip_local: tuple[tuple[float, float], ...]
    apex_local: tuple[float, float]  # the light's virtual position, R-local units
    radius_local: float              # light.radius converted to R-local units


def compute_light_instances(sim, light: LightSpec, max_depth: int = 6,
                             max_instances: int = 12) -> list[LightInstance]:
    """Run the engine's own visibility pass from the light's apex -- exactly
    the camera code path, with the light standing in as the "camera" -- and
    recover each reached room's own local lit polygon plus the light's
    virtual local position there, purely by inverting the returned
    transforms.

    `cam` here is a pure translation (linear_scale 1) that centers the
    query window on the light so a light anywhere in its room's local
    coordinates gets a correctly-sized frustum; because it carries no
    rotation/scale, inverting the RETURNED per-instance transform and
    composing it against `cam`'s own inverse cleanly separates "where is
    this point in room R's own frame" from "how zoomed is my query window."
    """
    radius = max(1.0, light.radius)
    pad = radius * 0.15
    win = 2.0 * (radius + pad)
    lx, ly = light.pos
    cam = necore.mat_translate(radius + pad - lx, radius + pad - ly)
    apex_screen = necore.mat_apply(cam, lx, ly)
    raw = sim.visible_set(light.room, cam, lx, ly, win, win,
                           max_depth, max_instances)
    out: list[LightInstance] = []
    for room, xform, _depth, clip_screen, _walls, _entry, _ents in raw:
        if len(clip_screen) < 3:
            continue
        try:
            inv = necore.mat_inv(xform)
        except ValueError:
            continue  # degenerate instance (zero-area chain) -- skip, not fatal
        scale = math.hypot(xform[0], xform[3])
        if scale <= 1e-9:
            continue
        clip_local = tuple(necore.mat_apply(inv, px, py) for px, py in clip_screen)
        apex_local = necore.mat_apply(inv, apex_screen[0], apex_screen[1])
        out.append(LightInstance(room, clip_local, apex_local, radius / scale))
    return out


class LightingSystem:
    """Owns the static-light cache for a session's (possibly streamed-in)
    level and the per-frame lookup used by the renderer. One instance per
    GameSession."""

    def __init__(self, sim, level=None):
        self.lights: list[LightSpec] = []
        self._by_room: dict[int, list[tuple[int, LightInstance]]] = {}
        if level is not None:
            self.add_lights(sim, level.lights)

    def add_lights(self, sim, lights: list[LightSpec]) -> None:
        """Register new lights (fresh level load, or a streamed chunk whose
        room indices are already offset). Static lights are cached now;
        attached lights are recomputed every frame in `frame_lookup`."""
        base = len(self.lights)
        self.lights.extend(lights)
        for j, lt in enumerate(lights):
            if lt.kind != "static":
                continue
            i = base + j
            for inst in compute_light_instances(sim, lt):
                self._by_room.setdefault(inst.room, []).append((i, inst))

    def attached_lights(self) -> list[tuple[int, LightSpec]]:
        return [(i, lt) for i, lt in enumerate(self.lights) if lt.kind == "attached"]

    def frame_lookup(self, sim) -> dict[int, list[tuple[int, LightInstance]]]:
        """Call once per frame: static cache plus freshly recomputed
        attached lights (e.g. the player's own light), merged into a
        room -> [(light_index, instance)] map for that frame's compositing
        pass."""
        by_room: dict[int, list[tuple[int, LightInstance]]] = {
            room: list(insts) for room, insts in self._by_room.items()
        }
        for i, lt in self.attached_lights():
            for inst in compute_light_instances(sim, lt, max_instances=24):
                by_room.setdefault(inst.room, []).append((i, inst))
        return by_room

    def cache_count(self) -> int:
        return sum(len(v) for v in self._by_room.values())
