#!/usr/bin/env python3
"""Farm-exact capture of the FIRST live marrow loop in gauntlet4.

gauntlet4 authors no Adversary scouts until the U15 content pass, so
this demo seeds a handful behind the bot's opening route — everything
else is the shipped game: the scout creeps, calls, the wall opens, the
shelf pours, the stream fights, the breach starves and seals.

    uv run python tools/playtest/marrow_demo.py out/marrow_pour --ticks 12000
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("--seed", type=int, default=2200)
    ap.add_argument("--ticks", type=int, default=12000)
    ap.add_argument("--every", type=int, default=5)
    ap.add_argument("--zoom", type=float, default=0.45,
                    help="0.45 = farm-exact; 1.35 = play zoom (feel/visual "
                         "captures only — visibility-driven bot behavior "
                         "diverges from the farm at play zoom)")
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
    from perihelion.telemetry import TraceWriter
    from perihelion.testkit.humanbot import DEFAULT_SKILL, HumanBot
    from perihelion.testkit.loadouts import FULL_LOADOUT

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    events = open(out / "events.jsonl", "w")
    frames = 0

    def tap(kind, name, vol, pan):
        events.write(json.dumps(dict(t=frames / 60.0, kind=kind, name=name,
                                     vol=round(vol, 4),
                                     pan=round(pan, 4))) + "\n")

    state = dict(FULL_LOADOUT)
    state["max_hp"] = state["hp"] = FULL_LOADOUT["max_hp"]
    state["dmg_taken_mul"] = 1.0
    state["chassis"] = 3    # the starting pod grants reprints (canon);
    #                         without them the filmed translocation
    #                         never fires and every film ends at the
    #                         first death
    level = load_level(ROOT / "levels" / "gauntlet4.json")
    session = GameSession(level, seed=a.seed, player_state=state,
                          screen=(640, 360), zoom=a.zoom)
    session.music_tier = getattr(level, "tier", 1)
    bot = HumanBot(a.seed, skill=DEFAULT_SKILL)
    trace = TraceWriter(out / "trace.jsonl",
                        header=dict(level="gauntlet4", seed=a.seed))

    # the Adversary lane is authored into the level itself (U15a) —
    # this demo records an ORDINARY session, no seeding
    print(f"[demo] authored census: {session.adversary_census}", flush=True)

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
    lifecycle = []
    linger = 0
    for t in range(a.ticks):
        if session.complete:
            break
        if session.dead:
            # the death rule IS a translocation: linger through the
            # fade, then reprint at the nearest seed station ON FILM
            # and keep playing — sessions end at the tick budget or
            # when the chassis run out, like the real game
            linger += 1
            if linger == 90 and session.respawn_at_station():
                linger = 0
            elif linger > 180:
                break
        snap = session.snapshot()
        inp = bot.step(snap, session)
        session.tick(inp)
        fx = session.fx
        renderer.consume_fx(fx)
        audio.handle_sounds(session, fx,
                            visible_instances=session.visible(3, 24))
        music.update(session)
        trace.drain_from(session.trace)
        if t % a.every == 0:
            frame = renderer.draw(surf)
            hud.draw(frame, session)
            pygame.surfarray.blit_array(surf, frame)
            pygame.image.save(surf, str(out / f"frame_{saved:06d}.png"))
            saved += 1
        frames += 1
    trace.close()
    events.close()
    for line in open(out / "trace.jsonl", encoding="utf-8"):
        r = json.loads(line)
        if r.get("kind") == "breach_lifecycle":
            lifecycle.append((r["t"], r["event"], r.get("detail", "")))
    print(f"[demo] {frames} ticks, {saved} frames, "
          f"outcome={'complete' if session.complete else 'death' if session.dead else 'timeout'}",
          flush=True)
    print(f"[demo] breach lifecycle: {lifecycle}", flush=True)
    print(f"[demo] adversary census: {session.adversary_census}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
