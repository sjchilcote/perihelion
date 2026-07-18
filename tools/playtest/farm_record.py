"""farm_record — record a FARM-EXACT run as frames + audio taps.

The app's record mode injects inputs the farm sim never sees (terminal
auto-read `inp.interact`, streamer ticks, overlay pushes), so a seed
that clears in `tune_pass_rate.one()` can die in an app capture (seed
7095: farm full-clear, app 4 deaths). This tool replays one()'s EXACT
loop — same GameSession construction, same bot, nothing else touching
the sim — while rendering frames via Renderer and logging audio taps
(SFX via Audio.handle_sounds, music via a tick_clock MusicSystem), so
mkvideo can assemble the true run.

    uv run python tools/playtest/farm_record.py SEED OUT_DIR \
        [--level levels/gauntlet_cal3.json] [--every 4] [--max-ticks N]
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("seed", type=int)
    ap.add_argument("out")
    ap.add_argument("--level", default="levels/gauntlet_cal3.json")
    ap.add_argument("--every", type=int, default=4)
    ap.add_argument("--max-ticks", type=int, default=64800)
    ap.add_argument("--skill", type=float, default=None)
    a = ap.parse_args()

    import os
    os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
    os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
    import pygame
    pygame.init()
    pygame.display.set_mode((640, 360))

    from perihelion.audio import Audio
    from perihelion.hud import HUD
    from perihelion.levels import load_level
    from perihelion.music import MUSIC_ROOT, MusicSystem
    from perihelion.render import Renderer
    from perihelion.sim import GameSession
    from perihelion.testkit.humanbot import DEFAULT_SKILL, HumanBot
    from perihelion.testkit.loadouts import FULL_LOADOUT

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    events = open(out / "events.jsonl", "w")
    frames = 0

    def tap(kind, name, vol, pan):
        events.write(json.dumps(dict(t=frames / 60.0, kind=kind,
                                     name=name, vol=round(vol, 4),
                                     pan=round(pan, 4))) + "\n")

    # EXACTLY one()'s session (camera parity, loadout, difficulty)
    state = dict(FULL_LOADOUT)
    state["max_hp"] = state["hp"] = FULL_LOADOUT["max_hp"]
    state["dmg_taken_mul"] = 1.0
    level = load_level(Path(a.level))
    session = GameSession(level, seed=a.seed, player_state=state,
                          screen=(640, 360), zoom=0.45)
    # GameScene sets this for the music's bed selection; it reads sim
    # state only, so it cannot perturb the farm trajectory
    session.music_tier = getattr(level, "tier", 1)
    bot = HumanBot(a.seed, skill=a.skill if a.skill is not None
                   else DEFAULT_SKILL)

    audio = Audio(mute=True)
    audio.tap = tap
    banks = sorted(p for p in MUSIC_ROOT.glob("album_*")
                   if (p / "bank.json").exists())
    music = MusicSystem(audio, enabled=True, bank_dirs=banks or None,
                        tick_clock=True)
    renderer = Renderer(session)
    hud = HUD()
    surf = pygame.Surface((640, 360))

    saved = 0
    t = 0
    while t < a.max_ticks and not session.dead and not session.complete:
        snap = session.snapshot()
        inp = bot.step(snap, session)
        session.tick(inp)
        fx = session.fx
        renderer.consume_fx(fx)
        audio.handle_sounds(session, fx)
        music.update(session)
        if t % a.every == 0:
            renderer.draw(surf)
            hud.draw(surf, session)
            pygame.image.save(surf,
                              str(out / f"frame_{saved:06d}.png"))
            saved += 1
        frames += 1
        t += 1
    events.close()
    print(f"[farm_record] {t} ticks, {saved} frames, "
          f"outcome={'complete' if session.complete else 'death' if session.dead else 'timeout'}, "
          f"kills={session.snapshot().get('kills', '?')} -> {out}",
          flush=True)


if __name__ == "__main__":
    main()
