"""Pixel-parity harness for the two render backends (rust necore.Raster
display list vs pygame.draw).

Renders identical fixture scenes through both backends from the same
GameSession ticks (fixed seeds, scripted or bot inputs, effect-pool RNG
re-seeded identically before each consume_fx) and compares the frames:

- pct of pixels within +/-2 per channel (PASS gate: >= 98.5% per fixture)
- max per-channel diff and count of exactly-equal frames
- writes side-by-side and amplified diff images for eyeball review

Fixtures:
  early_campaign  levels/l01.json driven by an AggroBot into real combat
                  (props, enemies, decals, hitflashes)
  tesseract       levels/l09.json (the tesseract) driven by an ExplorerBot —
                  multi-instance / deep-recursion visibility
  glow_combat     debug level, fire held down through a fight — muzzle
                  glows, bolts, gibs, sparks (the deferred-glow path)

Usage: uv run python tools/playtest/parity.py [--outdir DIR]
"""

from __future__ import annotations

import argparse
import os
import random
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import numpy as np
import pygame

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

from perihelion.app import build_debug_level  # noqa: E402
from perihelion.levels import load_level  # noqa: E402
from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402
from perihelion.testkit.bots import AggroBot, ExplorerBot  # noqa: E402

TOL = 2  # per-channel tolerance
PASS_PCT = 98.5

SIZE = (INTERNAL_W, INTERNAL_H)


def _rgb(surf) -> np.ndarray:
    return pygame.surfarray.array3d(surf).transpose(1, 0, 2).astype(np.int16)


def run_fixture(name, level, input_fn, ticks, sample_ticks, seed, outdir):
    session = GameSession(level, seed=seed, screen=SIZE)
    ren_rust = Renderer(session, backend="rust")
    ren_pg = Renderer(session, backend="pygame")
    s_rust = pygame.Surface(SIZE)
    s_pg = pygame.Surface(SIZE)
    sample_ticks = set(sample_ticks)

    frames = []
    for tick in range(1, ticks + 1):
        session.tick(input_fn(tick, session))
        random.seed(tick * 7919 + seed)
        ren_rust.consume_fx(session.fx)
        random.seed(tick * 7919 + seed)
        ren_pg.consume_fx(session.fx)
        if tick in sample_ticks:
            ren_rust.draw(s_rust)
            ren_pg.draw(s_pg)
            a, b = _rgb(s_rust), _rgb(s_pg)
            diff = np.abs(a - b)
            within = float((diff <= TOL).all(axis=2).mean() * 100.0)
            n_inst = len(session.visible(ren_rust.max_depth,
                                         ren_rust.max_instances))
            frames.append(dict(tick=tick, within=within,
                               maxdiff=int(diff.max()),
                               ndiff=int((diff > TOL).any(axis=2).sum()),
                               inst=n_inst,
                               glows=len(ren_rust._deferred_glows)))
            # keep the WORST sampled frame's images for eyeball review
            if frames[-1]["maxdiff"] >= max(f["maxdiff"] for f in frames):
                side = pygame.Surface((INTERNAL_W * 2, INTERNAL_H))
                side.blit(s_rust, (0, 0))
                side.blit(s_pg, (INTERNAL_W, 0))
                pygame.image.save(side, str(outdir / f"{name}_side.png"))
                amp = np.clip(diff * 40, 0, 255).astype(np.uint8)
                dsurf = pygame.surfarray.make_surface(amp.transpose(1, 0, 2))
                pygame.image.save(dsurf, str(outdir / f"{name}_diff.png"))
                pygame.image.save(s_rust, str(outdir / f"{name}_rust.png"))
        if session.dead or session.complete:
            break

    worst = min(f["within"] for f in frames)
    maxd = max(f["maxdiff"] for f in frames)
    identical = sum(1 for f in frames if f["maxdiff"] == 0)
    status = "PASS" if worst >= PASS_PCT else "FAIL"
    max_inst = max(f["inst"] for f in frames)
    tot_glows = sum(f["glows"] for f in frames)
    print(f"[{status}] {name:16s} frames={len(frames)} "
          f"identical={identical}/{len(frames)} "
          f"worst within±{TOL}: {worst:.3f}%  max channel diff: {maxd}  "
          f"max instances: {max_inst}  glow frames: "
          f"{sum(1 for f in frames if f['glows'])} ({tot_glows} glows)")
    for f in frames:
        if f["maxdiff"] > 0:
            print(f"    tick {f['tick']}: within={f['within']:.3f}% "
                  f"maxdiff={f['maxdiff']} pixels_out={f['ndiff']}")
    return status == "PASS"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--outdir", default=str(ROOT / "tools/playtest/parity_out"))
    args = ap.parse_args()
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    pygame.init()
    ok = True

    # 1. early campaign polygon, props + enemies, real fight
    bot = AggroBot(seed=42)
    ok &= run_fixture(
        "early_campaign", load_level(ROOT / "levels/l01.json"),
        lambda t, s: bot.step(s.snapshot(), s),
        ticks=900, sample_ticks=range(60, 901, 60), seed=11, outdir=outdir)

    # 2. tesseract multi-instance scene (campaign l09)
    bot2 = ExplorerBot(seed=7)
    ok &= run_fixture(
        "tesseract", load_level(ROOT / "levels/l09.json"),
        lambda t, s: bot2.step(s.snapshot(), s),
        ticks=1800, sample_ticks=range(120, 1801, 120), seed=23, outdir=outdir)

    # 3. glow-heavy combat: pulsed fire through the debug-level fight,
    # sampled every 2 ticks so muzzle-flash windows are actually caught
    def firing(t, s):
        return InputFrame(mx=0.6, my=0.2 * ((t // 50) % 2 * 2 - 1),
                          ax=INTERNAL_W * 0.7, ay=INTERNAL_H * 0.45,
                          fire=(t % 20) < 8, weapon=0)
    ok &= run_fixture(
        "glow_combat", build_debug_level(), firing,
        ticks=300, sample_ticks=range(20, 301, 2), seed=5, outdir=outdir)

    # 4. mirror polygon: a polygon self-connected across opposite edges — the
    # guaranteed deep-recursion / many-instances-of-one-polygon scene
    from perihelion.testkit.perf import build_mirror_polygon
    ok &= run_fixture(
        "mirror_polygon", build_mirror_polygon(),
        lambda t, s: InputFrame(mx=0.3, ax=INTERNAL_W * 0.5,
                                ay=INTERNAL_H * 0.2,
                                fire=(t % 30) < 6),
        ticks=300, sample_ticks=range(20, 301, 20), seed=9, outdir=outdir)

    print("PARITY:", "PASS" if ok else "FAIL", f"(images in {outdir})")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
