#!/usr/bin/env python3
"""Walk the marrow from a receiving apse down to a source cell and film
it, so the corruption gradient can be judged as a continuous descent
rather than as a set of stills.

This is a VISUAL PREVIEW, not a playtest: the player is reseated chamber
by chamber along the depth chain and the camera glides between, because
the cathedral is unreachable in ordinary play until a breach opens and
no bot walks it end to end. Every pixel is the shipped renderer on the
shipped geometry — nothing here is mocked.

    uv run python tools/design/marrow_tour.py out/marrow_tour
    uv run python tools/playtest/mkvideo.py out/marrow_tour out/marrow_tour.mp4
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

# the descent chain: one apse to one source cell, every band on the way
CHAIN = ["A1", "G1", "T1", "T2", "R", "N1", "N2", "N3", "N4", "L", "V", "S1"]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("--seed", type=int, default=2)
    ap.add_argument("--hold", type=int, default=48,
                    help="frames held in each chamber")
    ap.add_argument("--zoom", type=float, default=0.45,
                    help="0.45 is THE zoom")
    a = ap.parse_args()

    import numpy as np

    import necore

    from perihelion.hub import chamber_depths
    from perihelion.levels import load_level
    from perihelion.render import Renderer
    from perihelion.sim import GameSession, InputFrame
    from perihelion.testkit.loadouts import FULL_LOADOUT

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)

    state = dict(FULL_LOADOUT)
    state["max_hp"] = state["hp"] = FULL_LOADOUT["max_hp"]
    level = load_level(ROOT / "levels" / "gauntlet4.json")
    s = GameSession(level, seed=a.seed, player_state=state,
                    screen=(640, 360), zoom=a.zoom)
    r = Renderer(s)
    depths = chamber_depths()

    frame_no = 0
    for name in CHAIN:
        polygon = s.hub.chambers[name]
        kind, descent = s.hub_polygon_meta[polygon]
        s.reseat_player(polygon, (0.0, 0.0))
        for i in range(a.hold):
            # drift slowly so the light and the props move against the
            # camera — a still frame hides how the chamber reads in play
            ang = 6.2831 * i / a.hold
            s.tick(InputFrame(mx=0.22 * float(np.cos(ang)),
                              my=0.22 * float(np.sin(ang))))
            r.consume_fx(s.fx)
            frame = r.draw((640, 360))
            necore.write_png(
                str(out / f"frame_{frame_no:06d}.png"), 640, 360,
                np.ascontiguousarray(frame.transpose(1, 0, 2)).tobytes())
            frame_no += 1
        print(f"{name:>3}  depth {depths[name]:>2}  {kind:<10} "
              f"descent {descent:.2f}  -> {a.hold} frames", flush=True)

    print(f"\n{frame_no} frames in {out}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
