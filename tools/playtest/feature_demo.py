"""Feature demo capture — a built scenario, watched from the agent.

Two rules, both learned the hard way.

**The scenario is CONSTRUCTED, not searched for.** An earlier cut of this
tool swept seeds looking for a session in which the behavior happened to
occur. That is the wrong shape: the search re-runs whole sessions, its
cost is unbounded, and every gameplay change invalidates the seed it
found — so the price is paid again on every edit. Each demo below builds
the world in the state where the behavior is about to happen. The
Adversary return is the one case that needs a real world (a breach is a
real hole in a real map), so it warms the shipped level only until a
breach exists and then puts a recovered body on the roster: a snapshot
of a world where an Adversary is about to return.

**The camera belongs to the AGENT** — root, apex AND matrix. (The matrix
was the missing third: `session.visible()` accepted a spectate camera and
ignored it, so these clips moved the root to the agent and then framed the
world through the player's camera. The body under test sat wherever it
happened to fall.) A recording that follows the player
is the wrong instrument for proving an enemy behavior — the feature
happens wherever the enemy is, which is frequently off screen. "The
scanners found no cyan" has already once meant "the arrival was off
camera" rather than "the arrival did not happen" (gate 61). The renderer
takes a spectate target, so the shrieker demo is watched from the
shrieker with its FSM state burned into the frame.

A demo that cannot show its feature writes nothing and exits non-zero.

Video goes through the engine's own encoder (`necore.VideoRecorder`), not
a PNG dump plus ffmpeg.

Usage:
    uv run python tools/playtest/feature_demo.py --feature shrieker_mark
    uv run python tools/playtest/feature_demo.py --all --out-dir media/features
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np  # noqa: E402
from PIL import Image, ImageDraw  # noqa: E402

import necore  # noqa: E402
from perihelion.levels import LevelBuilder, LightSpec, load_level  # noqa: E402
from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402
from perihelion.testkit.humanbot import HumanBot  # noqa: E402

LEVEL = ROOT / "levels" / "gauntlet4.json"
FPS = 60
SCREEN = (INTERNAL_W, INTERNAL_H)


# ---------------------------------------------------------------------------
# labels
# ---------------------------------------------------------------------------

def _shrieker_label(s, eid):
    e = s.enemies.get(eid)
    if e is None:
        return "shrieker: GONE"
    return (f"shrieker    FSM phase = {e.get('phase', 'sentinel').upper()}"
            f"    state = {e.get('state', '?')}")


def _adversary_label(s, eid):
    e = s.enemies.get(eid)
    if e is None:
        return "adversary: OFF WORLD"
    bits = [e["kind"], f"scout={e.get('scout') or '-'}",
            f"state={e.get('state', '?')}"]
    if "arrived" in e:
        bits.append("JUST RETURNED")
    return "    ".join(bits)


# ---------------------------------------------------------------------------
# scenarios
# ---------------------------------------------------------------------------

# A demo chamber is sized to FILL THE FRAME at the gate's own zoom.
# 1280 px / 0.45 = 2844 world units across; a 1100x750 room drew into a
# quarter of the screen with black all round it, so the action sat in a
# small bright island and the clip read as mostly nothing. Bodies stay at
# their true scale (this is the zoom the game is judged at); it is the
# room that grows to meet the frame.
DEMO_W, DEMO_H = 2700.0, 1480.0


def _room(name, w=DEMO_W, h=DEMO_H):
    """A LIT room, frame-sized. An unlit builder room renders essentially
    black, and a demo of a behavior nobody can see is not a demo — the
    first cut of these scenarios produced 40 KB of near-empty frames."""
    b = LevelBuilder(name, 1)
    r0 = b.rect(0.0, 0.0, w, h)
    # THE MIDDLE, in authored coordinates. `rect(0, 0, w, h)` puts its
    # corner at the origin and the engine re-centres the polygon on its
    # centroid, so authoring the player at (0, 0) parked him in the
    # top-left corner while the lamps lit the centre — three quarters of
    # every single-room clip was black, and the action happened in the one
    # dark corner.
    b.player(r0, (w * 0.5, h * 0.5))
    return b.build(), r0


def _light(s, r0):
    """Two static lamps in `r0`, placed in ITS OWN local frame (the
    centroid is the origin, so (0,0) is the middle of the chamber). An
    earlier cut placed them at the player's coordinates regardless of
    which chamber it was lighting — which lit the right spot only when
    the player happened to be in that chamber."""
    s.lighting.add_lights(s.sim, [
        LightSpec(polygon=r0, pos=(x, 0.0),
                  color=(220, 225, 245) if i % 2 else (255, 205, 170),
                  intensity=1.15, radius=1000.0, kind="static")
        for i, x in enumerate((-900.0, -300.0, 300.0, 900.0))
    ])


def _walk_toward(s, get_target):
    """Drive the player straight at a moving target, forever."""
    while True:
        px, py = s.player_pos().local()
        tx, ty = get_target()
        dx, dy = tx - px, ty - py
        dist = (dx * dx + dy * dy) ** 0.5 or 1.0
        yield InputFrame(mx=dx / dist, my=dy / dist,
                         ax=INTERNAL_W / 2, ay=INTERNAL_H / 2)


def scenario_lob():
    """A player closing on a fleeing Adversary, ACROSS A DOORWAY. The
    runner's answer is a rubber grenade — a large, heavy, slow object
    whose momentum IS the knockback.

    Two chambers on purpose, and this is the point of the clip: the
    object is aimed on portal-composed coordinates. A single-rect
    scenario is exactly the fixture that hid gate 66's frame bug, where
    63 of 64 filmed fires crossed a chamber and the tool delivered once
    in 57,600 ticks.

    The player starts outside the 180u lob range, so the clip shows the
    approach that provokes it — and the throw is unled, which suits a
    panicking runner: it connects because the player is closing head-on,
    not because the runner is a marksman."""
    b = LevelBuilder("LOB", 1)
    r0 = b.rect(0.0, 0.0, DEMO_W / 2, DEMO_H)
    r1 = b.rect(DEMO_W / 2, 0.0, DEMO_W / 2, DEMO_H)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (DEMO_W * 0.55, DEMO_H / 2))
    s = GameSession(b.build(), seed=4, screen=SCREEN, zoom=0.45)
    s.tick(InputFrame())
    _light(s, r1)
    _light(s, r0)
    eid = s.spawn_enemy(r0, (480.0, 0.0), "vagrant")
    s.enemies[eid]["scout"] = "flee"
    s.enemies[eid]["scout_t"] = 10 ** 6      # it is running for the clip

    def target():
        if eid in s.enemies:
            hit = s.senses.sight_of(s.pid, eid)
            if hit is not None:
                return hit.pos.local()
        return s.player_pos().local()

    return s, eid, _walk_toward(s, target), _adversary_label, "lob_fire"


def scenario_snare():
    """The mid-range tool: a player pursuing from too far to shove gets
    snared instead, and the runner spends the time it just bought.

    Two chambers on purpose. The arsenal aims on portal-composed
    coordinates, and a single-rect scenario is exactly the fixture that
    hid gate 66's frame bug."""
    b = LevelBuilder("SNARE", 1)
    r0 = b.rect(0.0, 0.0, DEMO_W / 2, DEMO_H)
    r1 = b.rect(DEMO_W / 2, 0.0, DEMO_W / 2, DEMO_H)
    b.connect(r0, 2, r1, 0)
    # start OUTSIDE the 560u snare band so the clip shows the pursuit
    # that provokes it, not just the answer
    b.player(r1, (DEMO_W * 0.92, DEMO_H / 2))
    s = GameSession(b.build(), seed=4, screen=SCREEN, zoom=0.45)
    s.tick(InputFrame())
    _light(s, r1)
    eid = s.spawn_enemy(r0, (-300.0, 0.0), "vagrant")
    s.enemies[eid]["scout"] = "flee"
    s.enemies[eid]["scout_t"] = 10 ** 6

    def target():
        if eid in s.enemies:
            hit = s.senses.sight_of(s.pid, eid)
            if hit is not None:
                return hit.pos.local()
        return s.player_pos().local()

    return s, eid, _walk_toward(s, target), _adversary_label, "snare_fire"


def scenario_mark():
    """A shrieker with the player in plain sight, run until it marks.
    The player stands still: the mark machine is the subject here, not a
    chase, and standing is what lets the whole FSM play on camera."""
    level, r0 = _room("MARK")
    s = GameSession(level, seed=4, screen=SCREEN, zoom=0.45)
    s.tick(InputFrame())
    _light(s, r0)
    px, py = s.player_pos().local()
    # far enough that SENTINEL -> WARNING -> APPROACH -> MARKING each get
    # screen time; close in and it fires before the label can show them
    eid = s.spawn_enemy(r0, (px + 700.0, py + 120.0), "shrieker")

    def drive():
        while True:
            yield InputFrame(ax=INTERNAL_W / 2, ay=INTERNAL_H / 2)

    return s, eid, drive(), _shrieker_label, "marker_fire"


def scenario_return(warmup_cap: int = 9000):
    """A snapshot of a world where an Adversary is about to return.

    A breach is a real hole in a real map, so this one uses the shipped
    level — but it warms only until a breach exists, then puts one
    recovered body on the roster. The return comes through that mouth on
    the next tick it is offered."""
    level = load_level(LEVEL)
    s = GameSession(level, seed=7, screen=SCREEN, zoom=0.45)
    bot = HumanBot(7)
    for _ in range(warmup_cap):
        if s.dead or s.complete:
            break
        s.tick(bot.step(s.snapshot(), s))
        s.trace.drain()
        if s.breaches:
            break
    if not s.breaches:
        raise RuntimeError("no breach opened during warmup — a return "
                           "cannot be staged without a live mouth")
    # a few seconds of the live breach BEFORE the body comes back, so
    # the clip shows the mouth it arrives from
    s.adversary_out.append(("lacuna", s.tick_count + 180))

    def drive():
        while True:
            yield bot.step(s.snapshot(), s)

    return s, None, drive(), _adversary_label, "returned"


FEATURES = {
    "adversary_lob": dict(
        build=scenario_lob, title="ADVERSARY LOB (rubber grenade)",
        blurb="thrown across a doorway; its momentum is the knockback",
        max_ticks=1200, tail=300),
    "adversary_snare": dict(
        build=scenario_snare, title="ADVERSARY SNARE",
        blurb="the mid-range tool: buys time instead of distance",
        max_ticks=1200, tail=300),
    "shrieker_mark": dict(
        build=scenario_mark, title="SHRIEKER MARK",
        blurb="watched from the shrieker, with its FSM state",
        max_ticks=2400, tail=240),
    "adversary_return": dict(
        build=scenario_return, title="ADVERSARY RETURN",
        blurb="withdrawn personnel come back through a live breach",
        max_ticks=1200, tail=420),
}


def _overlay(frame, title, blurb, label, fired_at, tick):
    img = Image.fromarray(frame)
    dr = ImageDraw.Draw(img, "RGBA")
    w, h = img.size
    dr.rectangle([0, 0, w, 58], fill=(0, 0, 0, 170))
    dr.text((14, 8), title, fill=(255, 255, 255, 255))
    dr.text((14, 24), blurb, fill=(185, 195, 205, 255))
    dr.rectangle([0, h - 34, w, h], fill=(0, 0, 0, 170))
    dr.text((14, h - 26), label, fill=(170, 255, 200, 255))
    if fired_at is not None:
        rel = tick - fired_at
        tag = ">>> HERE <<<" if rel == 0 else f"t{rel:+d}"
        dr.text((w - 140, h - 26), tag,
                fill=(255, 230, 120, 255) if abs(rel) < 30
                else (150, 160, 170, 255))
    return np.asarray(img, dtype=np.uint8)


def _fired(rec, watch_for) -> bool:
    d = getattr(rec, "data", {}) or {}
    return d.get("event") == watch_for or d.get("to_state") == watch_for


def run_one(feature: str, out_dir: Path) -> int:
    spec = FEATURES[feature]
    print(f"[{feature}] building the scenario", flush=True)
    s, eid, drive, label_fn, watch_for = spec["build"]()
    ren = Renderer(s)

    # Frames are held until the behavior is confirmed. The tail is
    # counted from the firing tick, and a scenario that never fires must
    # leave NO file behind — so nothing is encoded before there is
    # something to prove.
    fired_at = None
    pending = []
    for t in range(spec["max_ticks"]):
        s.tick(next(drive))
        for r in s.trace.drain():
            if fired_at is None and _fired(r, watch_for):
                fired_at = t
                if eid is None:
                    eid = (getattr(r, "data", {}) or {}).get("entity_id")
                print(f"[{feature}] fired at tick {t} (entity {eid})",
                      flush=True)
        if eid is not None:
            ren.spectate_eid = eid
        # the renderer hands back pygame's surfarray convention —
        # (W, H, 3) indexed x-then-y, non-contiguous. Feeding that
        # straight to the encoder makes a frame of horizontal streaks
        # that still muxes into a perfectly valid mp4: a silent
        # corruption, not an error.
        frame = np.ascontiguousarray(
            np.transpose(np.asarray(ren.draw(SCREEN)), (1, 0, 2)))
        pending.append((t, frame, label_fn(s, eid)))
        if fired_at is not None and t >= fired_at + spec["tail"]:
            break

    if fired_at is None:
        print(f"[{feature}] FAILED: the scenario ran {spec['max_ticks']} "
              f"ticks and the behavior never fired. No video written — a "
              f"demo that cannot show its feature is not a demo.",
              flush=True)
        return 1

    out = out_dir / f"{feature}.mp4"
    out.parent.mkdir(parents=True, exist_ok=True)
    rec = necore.VideoRecorder(str(out), INTERNAL_W, INTERNAL_H, FPS)
    for t, frame, label in pending:
        rec.add_frame(_overlay(frame, spec["title"], spec["blurb"],
                               label, fired_at, t).tobytes())
    rec.finish()
    size = out.stat().st_size if out.exists() else 0
    print(f"[{feature}] wrote {out} — {len(pending)} frames, "
          f"{size/1e6:.1f} MB", flush=True)
    return 0 if pending and size else 1


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--feature", choices=sorted(FEATURES))
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--out-dir", type=Path,
                    default=ROOT / "media" / "features")
    a = ap.parse_args()
    if not a.feature and not a.all:
        ap.error("give --feature NAME or --all")
    rc = 0
    for name in (sorted(FEATURES) if a.all else [a.feature]):
        rc |= run_one(name, a.out_dir)
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
