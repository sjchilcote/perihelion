"""Re-capture media/mindmap_relax_demo.mp4 (round 2, director-directed):
ONE CONTINUOUS take of a real PodScene session, headless
(SDL_VIDEODRIVER=dummy), lockstep 60Hz, PRODUCTION update/draw -- every
frame from the same run, nothing cut together from parts ("do the whole
video in one go... or else I can't judge the transitions between
states"). Sequence: open/settle -> navigate several selections (the
LOCAL camera glides between neighborhoods, including a deep ring) -> a
queued thought's reveal fires while the camera is parked on a FAR
navigated selection (the reveal visibly PULLS the camera to the
completed node in one continuous glide -- the round-1 discontinuity is
the thing this take exists to disprove) -> post-reveal settle -> hold to
stillness.

Tail-freeze verification runs on the RAW pre-encode surfaces (H.264
would false-positive on codec noise) and asserts every differing pixel
lies inside the two INTENTIONALLY animated chrome zones (the selection
ring's rotating shards; the pod shell's breathing rib in the footer
strip) -- the graph itself (nodes, labels, edges, bands, panel) must be
bitwise static.

Run from the repo root:
    uv run --project game python game/tools/capture_mindmap_demo.py
"""
from __future__ import annotations

import math
import os
import subprocess
import sys

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
# native 720p internal res: the MIND page's typography (IBM Plex Sans,
# rendered at exact pt sizes) is resolution-crisp, so capture at the
# output resolution instead of smoothscaling a 640x360 frame up (which
# would blur exactly the text this demo exists to judge).
os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import pygame  # noqa: E402

from perihelion import mindmap, podscene  # noqa: E402
from perihelion.levels import LevelBuilder  # noqa: E402
from perihelion.podscene import PodScene  # noqa: E402
from perihelion.render import INTERNAL_H, INTERNAL_W, ui  # noqa: E402
from perihelion.sim import GameSession  # noqa: E402

OUT_W, OUT_H = 1280, 720
FPS = 60
OUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "media",
                        "mindmap_relax_demo.mp4")


class _StubAudio:
    def play(self, name, vol=1.0, pan=0.5):
        pass

    def duck_ambience(self, frac):
        pass


class _StubApp:
    def __init__(self):
        self.audio = _StubAudio()
        self.popped = 0

    def pop(self):
        self.popped += 1


def _level():
    b = LevelBuilder("POD", 1)
    r0 = b.rect(0, 0, 260, 180, kind="dock")
    b.player(r0, (60, 90))
    b.exit(r0, (200, 90))
    return b.build()


def main() -> None:
    podscene.MINDMAP_LAYOUT = "physics"
    pygame.init()
    pygame.display.set_mode((INTERNAL_W, INTERNAL_H))
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))

    # a real, purchased subset of the map: the full prereq CHAIN down to
    # (but not including) the real map's single deepest node -- so that
    # node sits on the frontier at depth 5, several ring boundaries out
    # from the shallow roots, giving the camera somewhere dramatic to
    # actually glide to. Plus a handful of shallower owned nodes so the
    # frontier is rich enough to walk back to a shallow root afterward.
    owned = ["comprehension-connection-space",
             "comprehension-adversary-biology-survey",
             "void-arithmetic-of-futility",
             "void-discarding-the-constraint-kernel",
             "void-second-kernel-discarded",
             "vocation-just-war", "history-the-long-peace"]
    s = GameSession(_level(), seed=1, player_state=dict(mind=owned))
    sc = PodScene(s)
    sc._layout_mode = "physics"
    app = _StubApp()

    ffmpeg = subprocess.Popen([
        "ffmpeg", "-y", "-f", "rawvideo", "-pixel_format", "rgb24",
        "-video_size", f"{OUT_W}x{OUT_H}", "-framerate", str(FPS),
        "-i", "-", "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p",
        "-crf", "18", "-preset", "medium", OUT_PATH,
    ], stdin=subprocess.PIPE)

    tail_raw: list = []  # last TAIL_FRAMES raw (uncompressed) native-res
                          # surfaces, kept for the freeze verification --
                          # diffing the H.264-encoded output would measure
                          # codec quantization noise, not the physics.
    TAIL_FRAMES = 90
    frames = 0

    def tick(n: int) -> None:
        """THE one and only frame writer: every frame of the video passes
        through here, from the same continuous session -- the one-take
        law is structural, not a promise."""
        nonlocal frames
        for _ in range(n):
            sc.update(app, 1 / FPS)
            sc.draw(app, surf)
            frame = surf if surf.get_size() == (OUT_W, OUT_H) else \
                pygame.transform.smoothscale(surf, (OUT_W, OUT_H))
            ffmpeg.stdin.write(pygame.image.tobytes(frame, "RGB"))
            tail_raw.append(surf.copy())
            if len(tail_raw) > TAIL_FRAMES:
                tail_raw.pop(0)
            frames += 1

    def walk_toward(target: str, max_hops: int, hop_ticks: int) -> None:
        """Directional nav, one keyboard-shaped hop at a time (mirrors
        real play), each hop given time for the camera glide to land."""
        for _ in range(max_hops):
            if sc.sel == target:
                break
            x0, y0 = sc.layout[sc.sel]
            x1, y1 = sc.layout.get(target, (x0, y0))
            dx, dy = x1 - x0, y1 - y0
            if abs(dx) > abs(dy):
                sc._nav(1 if dx > 0 else -1, 0)
            else:
                sc._nav(0, 1 if dy > 0 else -1)
            tick(hop_ticks)

    # 1. open MIND, let the baked settle finish, hold a beat
    sc.page = "mind"
    sc.on_enter(app)
    assert sc.reveal is None
    tick(120)  # 2.0s: settle (0.7s) + the local neighborhood at rest

    # 2. walk the selection DEEP across several ring boundaries -- the
    # local camera glides neighborhood to neighborhood; each hop reads
    # as traversing territory, not scanning a poster.
    deep = max(sc._visible(), key=lambda nid: mindmap.depths()[nid])
    walk_toward(deep, 6, 66)  # ~1.1s per hop: glide lands, chatter reads
    tick(105)  # 1.75s holding on the deep ring

    # 3. walk back to a shallow (root) node -- the camera glides back
    # inward through the rings
    root = min(sc._visible(), key=lambda nid: mindmap.depths()[nid])
    walk_toward(root, 6, 66)
    tick(90)  # 1.5s parked on the shallow neighborhood

    # 4. a queued thought completes: pick the frontier node FARTHEST from
    # the parked selection, so the reveal's camera pull is unmistakable
    # (the round-1 concern: the reveal generally fires for a node that is
    # NOT the navigated selection -- the transition must be one visible,
    # continuous glide from here to there).
    sx0, sy0 = sc.layout[sc.sel]
    frontier_pick = max(
        mindmap.frontier(set(s.mind)),
        key=lambda nid: math.hypot(sc.layout[nid][0] - sx0,
                                   sc.layout[nid][1] - sy0))
    s.think_done.append(frontier_pick)
    sc._start_reveal(app)
    while sc.reveal is not None:
        tick(1)  # the reveal plays out inside the same take

    # 5. hold through the newly-revealed neighborhood's local settle, and
    # well past it -- the tail-freeze proof needs real bitwise-static
    # frames at the end (the two ambient chrome zones aside).
    tick(500)  # ~8.3s

    ffmpeg.stdin.close()
    ffmpeg.wait()
    dur = frames / FPS
    print(f"wrote {OUT_PATH}: {frames} frames = {dur:.1f}s, one take")

    # ------------------------------------------------------------------
    # tail-freeze verification, on the RAW (pre-encode) surfaces, never
    # the lossy H.264 output. The graph must be bitwise static; exactly
    # two chrome zones are INTENTIONALLY alive forever and excluded by
    # construction:
    #   (a) the selection ring's rotating arc shards, a small box around
    #       the selected node's screen position;
    #   (b) the pod shell's breathing innermost rib, which only shows in
    #       the footer strip (everything above it is covered by the
    #       opaque detail panel).
    # Any differing pixel OUTSIDE those zones fails the capture.
    # ------------------------------------------------------------------
    import numpy as np
    assert len(tail_raw) == TAIL_FRAMES, len(tail_raw)
    arrs = [pygame.surfarray.array3d(f) for f in tail_raw]
    w, h = tail_raw[0].get_size()
    mask = np.zeros((w, h), dtype=bool)
    for i in range(len(arrs) - 1):
        mask |= np.any(arrs[i] != arrs[i + 1], axis=2)
    total = int(mask.sum())

    allowed = np.zeros((w, h), dtype=bool)
    # (a) selection ring box
    nx, ny = sc._to_screen(surf, *sc._node_pos(sc.sel))
    ring_r = ui(6) + ui(2) + ui(6) + ui(4)  # node + root bonus + ring + lw
    allowed[max(0, nx - ring_r):min(w, nx + ring_r + 1),
            max(0, ny - ring_r):min(h, ny + ring_r + 1)] = True
    # (b) footer strip below the detail panel (breathing rib territory)
    band_h, inset = ui(58), ui(18)
    footer_top = h - inset  # panel spans [h-band_h-inset, h-inset)
    allowed[:, footer_top:] = True

    stray = mask & ~allowed
    n_stray = int(stray.sum())
    print(f"tail-freeze check: {total} differing pixels across "
          f"{TAIL_FRAMES} raw native-res ({w}x{h}) frames; "
          f"{n_stray} OUTSIDE the two ambient chrome zones")
    if n_stray:
        xs, ys = np.where(stray)
        print(f"  stray bbox: x [{xs.min()},{xs.max()}] y [{ys.min()},{ys.max()}]")
        pygame.image.save(tail_raw[0], "/tmp/mm_tail_first.png")
        pygame.image.save(tail_raw[-1], "/tmp/mm_tail_last.png")
        hi = tail_raw[-1].copy()
        for x, y in zip(xs.tolist(), ys.tolist()):
            hi.set_at((x, y), (255, 0, 255))
        pygame.image.save(hi, "/tmp/mm_tail_diffmask.png")
        print("  saved /tmp/mm_tail_first.png /tmp/mm_tail_last.png "
              "/tmp/mm_tail_diffmask.png")
        raise SystemExit("tail-freeze FAILED: the graph is not at rest")
    print("tail-freeze OK: graph bitwise static; only the selection ring "
          "shards and the breathing rib remain alive (by design)")


if __name__ == "__main__":
    main()
