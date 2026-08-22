#!/usr/bin/env python3
"""Find pixels that OSCILLATE, which no reviewer can see in stills.

Two things change a pixel across a capture: the camera moving over it
(monotonic, smooth) and something switching on and off (alternating). A
reviewer looking at sampled frames cannot tell these apart — at 20fps a
thing that blinks every other tick just looks present in one frame and
absent in the next, indistinguishable from it having moved.

So count SIGN CHANGES in each pixel's intensity over the window. A pan
produces few; a flicker produces one per frame. This finds a class of
defect by its signature rather than by someone recognising it, which
matters because the reviewer who does not know what the game should
look like — me — cannot recognise anything. It reports where and how
strongly, and says nothing about whether it is a bug: a muzzle flash
oscillates too. It is a place to look, not a verdict.
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image


def load_window(framedir: Path, lo: int, hi: int, stride: int = 1):
    frames, idxs = [], []
    for i in range(lo, hi + 1, stride):
        p = framedir / f"frame_{i:06d}.png"
        if p.exists():
            frames.append(np.asarray(Image.open(p).convert("L"), dtype=np.int16))
            idxs.append(i)
    if len(frames) < 5:
        raise SystemExit(f"need >=5 frames in [{lo},{hi}], got {len(frames)}")
    return np.stack(frames), idxs


def oscillation(stack: np.ndarray, thresh: int = 18) -> np.ndarray:
    """Sign changes per pixel in the temporal difference."""
    d = np.diff(stack.astype(np.int16), axis=0)
    sig = np.zeros_like(d, dtype=np.int8)
    sig[d > thresh] = 1
    sig[d < -thresh] = -1
    # a sign change is where consecutive NON-ZERO signs differ
    changes = np.zeros(stack.shape[1:], dtype=np.int16)
    last = np.zeros(stack.shape[1:], dtype=np.int8)
    for k in range(sig.shape[0]):
        s = sig[k]
        flip = (s != 0) & (last != 0) & (s != last)
        changes += flip.astype(np.int16)
        last = np.where(s != 0, s, last)
    return changes


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("framedir", type=Path)
    ap.add_argument("--range", required=True, help="FROM:TO[:STRIDE]")
    ap.add_argument("--min-flips", type=int, default=4)
    ap.add_argument("-o", "--out", type=Path, default=None)
    a = ap.parse_args()

    parts = [int(v) for v in a.range.split(":")]
    lo, hi = parts[0], parts[1]
    stride = parts[2] if len(parts) > 2 else 1
    stack, idxs = load_window(a.framedir, lo, hi, stride)
    ch = oscillation(stack)

    hot = ch >= a.min_flips
    print(f"frames {idxs[0]}..{idxs[-1]} ({len(idxs)})  "
          f"pixels flipping >={a.min_flips}x: {int(hot.sum())}")
    if hot.any():
        ys, xs = np.where(hot)
        print(f"  bbox rows {ys.min()}-{ys.max()} cols {xs.min()}-{xs.max()}")
        # cluster roughly, report the densest spots
        from collections import Counter
        cells = Counter((int(y) // 24, int(x) // 24) for y, x in zip(ys, xs))
        for (cy, cx), n in cells.most_common(6):
            print(f"  ~row {cy*24:3d} col {cx*24:3d}: {n} px  "
                  f"(max flips {int(ch[cy*24:cy*24+24, cx*24:cx*24+24].max())})")
    if a.out:
        vis = np.zeros((*ch.shape, 3), dtype=np.uint8)
        base = (stack[len(stack) // 2]).astype(np.uint8)
        vis[..., 0] = vis[..., 1] = vis[..., 2] = base
        strength = np.clip(ch * 40, 0, 255).astype(np.uint8)
        vis[..., 0] = np.maximum(vis[..., 0], strength)
        vis[..., 2] = np.where(strength > 0, 0, vis[..., 2])
        Image.fromarray(vis).save(a.out)
        print(f"  wrote {a.out} (red = oscillating)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
