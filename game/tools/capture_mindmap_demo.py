"""Re-capture media/mindmap_relax_demo.mp4 (director's hybridization
follow-up): a real PodScene run, headless (SDL_VIDEODRIVER=dummy),
lockstep 60Hz, PRODUCTION update/draw/handle_event -- not a mock, not a
canned tween. Same recipe as prior captures (see commit 8143448): the
graph settles, the player walks the selection (now: the CAMERA glides out
across depth-ring boundaries to a deep node and back, while the nodes
themselves visibly, chaotically jitter WITHIN their own bands -- the
director's "bank-switching, limited main memory" hybridization), a queued
thought's rite plays, and the newly-revealed neighborhood settles.

Run from the repo root:
    uv run --project game python game/tools/capture_mindmap_demo.py
"""
from __future__ import annotations

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
from perihelion.render import INTERNAL_H, INTERNAL_W  # noqa: E402
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

    def tick(n: int) -> None:
        for _ in range(n):
            sc.update(app, 1 / FPS)
            sc.draw(app, surf)
            frame = surf if surf.get_size() == (OUT_W, OUT_H) else \
                pygame.transform.smoothscale(surf, (OUT_W, OUT_H))
            ffmpeg.stdin.write(pygame.image.tobytes(frame, "RGB"))
            tail_raw.append(surf.copy())
            if len(tail_raw) > TAIL_FRAMES:
                tail_raw.pop(0)

    # 1. open MIND, let the baked settle finish
    sc.page = "mind"
    sc.on_enter(app)
    assert sc.rite is None
    tick(90)  # 1.5s: settle (0.7s) + a beat holding still, bands visible

    # 2. walk the selection DEEP across several ring boundaries -- the
    # camera glides out to frame each ring in turn, nodes chaotically
    # jitter within their own bands throughout (never crossing one).
    deep = max(sc._visible(), key=lambda nid: mindmap.depths()[nid])
    # walk edge-by-edge from the current selection toward the deepest
    # visible node, one directional nav per hop (mirrors real keyboard
    # play), each hop given time to glide + settle.
    for _ in range(6):
        if sc.sel == deep:
            break
        x0, y0 = sc.layout[sc.sel]
        x1, y1 = sc.layout.get(deep, (x0, y0))
        dx, dy = x1 - x0, y1 - y0
        if abs(dx) > abs(dy):
            sc._nav(1 if dx > 0 else -1, 0)
        else:
            sc._nav(0, 1 if dy > 0 else -1)
        tick(55)  # ~0.9s per hop: glide + chatter, visibly settling

    tick(120)  # 2.0s holding on the deep node -- camera framed, chatter visible

    # 3. walk back to a shallow (root) node -- camera glides back inward
    root = min(sc._visible(), key=lambda nid: mindmap.depths()[nid])
    for _ in range(6):
        if sc.sel == root:
            break
        x0, y0 = sc.layout[sc.sel]
        x1, y1 = sc.layout.get(root, (x0, y0))
        dx, dy = x1 - x0, y1 - y0
        if abs(dx) > abs(dy):
            sc._nav(1 if dx > 0 else -1, 0)
        else:
            sc._nav(0, 1 if dy > 0 else -1)
        tick(55)

    tick(90)  # 1.5s holding on the shallow node

    # 4. queue a thought's completion and play the real rite
    frontier_pick = sorted(mindmap.frontier(set(s.mind)))[0]
    s.think_done.append(frontier_pick)
    sc._start_rite(app)
    while sc.rite is not None:
        sc.update(app, 1 / FPS)
        sc.draw(app, surf)
        frame = surf if surf.get_size() == (OUT_W, OUT_H) else \
            pygame.transform.smoothscale(surf, (OUT_W, OUT_H))
        ffmpeg.stdin.write(pygame.image.tobytes(frame, "RGB"))

    # 5. hold through the newly-revealed neighborhood's local settle, and
    # well past it -- the tail-freeze proof needs real bitwise-static
    # frames at the end (chrome pulse/selection ring aside).
    tick(460)  # ~7.7s -- long enough for the tail-freeze proof to sample
              # a full 90-frame window with margin to spare

    ffmpeg.stdin.close()
    ffmpeg.wait()
    print(f"wrote {OUT_PATH}")

    # tail-freeze verification, on the RAW (pre-encode) surfaces, not the
    # lossy H.264 output -- codec quantization noise scatters tiny
    # differences across an otherwise-static frame even when the source
    # is bitwise identical, which would falsely fail a diff run against
    # the compressed file.
    import numpy as np
    assert len(tail_raw) == TAIL_FRAMES, len(tail_raw)
    arrs = [pygame.surfarray.array3d(f) for f in tail_raw]
    w, h = tail_raw[0].get_size()
    mask = np.zeros((w, h), dtype=bool)
    for i in range(len(arrs) - 1):
        mask |= np.any(arrs[i] != arrs[i + 1], axis=2)
    total = int(mask.sum())
    print(f"tail-freeze check: {total} differing pixels across "
          f"{TAIL_FRAMES} raw native-res ({w}x{h}) frames")
    if total:
        xs, ys = np.where(mask)
        print(f"  bbox: x [{xs.min()},{xs.max()}] y [{ys.min()},{ys.max()}]")
        # save the first/last tail frame plus a diff-highlight image for
        # visual inspection
        pygame.image.save(tail_raw[0], "/tmp/mm_tail_first.png")
        pygame.image.save(tail_raw[-1], "/tmp/mm_tail_last.png")
        hi = tail_raw[-1].copy()
        for x, y in zip(xs.tolist(), ys.tolist()):
            hi.set_at((x, y), (255, 0, 255))
        pygame.image.save(hi, "/tmp/mm_tail_diffmask.png")
        print("  saved /tmp/mm_tail_first.png /tmp/mm_tail_last.png "
              "/tmp/mm_tail_diffmask.png")


if __name__ == "__main__":
    main()
