"""Make fast things visible to a reviewer who can only look at stills.

A reviewer sampling a capture every N frames cannot see a projectile: it
crosses the screen between two looks. Absence from the sample then gets
reported as absence from the game, and a defect gets manufactured out of
an instrument's blind spot. That happened here — a round the player had
fired, returning through a portal loop and hitting him in the back, was
written up as "damage with no visible threat" and very nearly turned
into a fix for a mechanic that was working.

Two ways to put motion into one still:

  ghost   blend a span of consecutive frames into one image, so anything
          that moved leaves a trail. MAX-blend for a bright object on a
          dark field (a tracer keeps its full brightness at every point
          it occupied); MEAN dims each position by 1/span but is truer
          to what the eye would integrate.

  sheet   a contact sheet: the span as labelled comic panels. Reading
          TIME off panels is far easier than off separate stills — with
          one image at a time a reader compares from memory and usually
          concludes nothing moved. This is the default.

And a way to look closely at the moment that matters:

  patch   crop around a point and magnify it. Driven off the trace, the
          point is where the event happened, so "was there anything on
          screen when he was hit" becomes a question you can answer by
          looking instead of by inference.
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


def _load(framedir: Path, idx: int) -> np.ndarray | None:
    p = framedir / f"frame_{idx:06d}.png"
    if not p.exists():
        return None
    return np.asarray(Image.open(p).convert("RGB"), dtype=np.float32)


def span_frames(framedir: Path, end: int, span: int) -> list[np.ndarray]:
    """The `span` frames ending at `end` (inclusive), oldest first."""
    out = []
    for i in range(end - span + 1, end + 1):
        a = _load(framedir, i)
        if a is not None:
            out.append(a)
    if not out:
        raise SystemExit(f"no frames in [{end - span + 1}, {end}] under {framedir}")
    return out


def ghost(frames: list[np.ndarray], how: str = "max") -> np.ndarray:
    stack = np.stack(frames)
    if how == "max":
        return stack.max(axis=0)
    if how == "mean":
        return stack.mean(axis=0)
    raise SystemExit(f"unknown blend {how!r}")


def sheet(frames: list[np.ndarray], first_idx: int, cols: int = 0,
          fps: float = 20.0, step: int = 1) -> np.ndarray:
    """A contact sheet: the span as labelled comic panels, in order.

    Panels beat separate images for reading TIME. Given one still at a
    time a reader compares from memory and mostly concludes nothing
    moved; given the same frames side by side, direction, order and
    speed are just visible. Every panel carries its own frame index and
    clock so a finding can be cited exactly.
    """
    n = len(frames)
    cols = cols or min(n, 5)
    rows = (n + cols - 1) // cols
    h, w, _ = frames[0].shape
    gap, bar = 3, 13
    ph = h + bar
    out = np.zeros((rows * ph + (rows - 1) * gap,
                    cols * w + (cols - 1) * gap, 3), dtype=np.float32)
    for i, f in enumerate(frames):
        r, c = divmod(i, cols)
        y0, x0 = r * (ph + gap) + bar, c * (w + gap)
        out[y0:y0 + h, x0:x0 + w] = f
    img = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8))
    draw = ImageDraw.Draw(img)
    for i in range(n):
        r, c = divmod(i, cols)
        idx = first_idx + i * step
        t = idx / fps
        draw.text((c * (w + gap) + 3, r * (ph + gap) + 1),
                  f"#{idx}  {int(t // 60):02d}:{t % 60:05.2f}",
                  fill=(255, 220, 90))
    return np.asarray(img, dtype=np.float32)


def patch(img: np.ndarray, cx: int, cy: int, size: int, zoom: int) -> np.ndarray:
    h, w, _ = img.shape
    half = size // 2
    x0, y0 = max(0, cx - half), max(0, cy - half)
    x1, y1 = min(w, x0 + size), min(h, y0 + size)
    x0, y0 = max(0, x1 - size), max(0, y1 - size)
    crop = img[y0:y1, x0:x1]
    return np.kron(crop, np.ones((zoom, zoom, 1), dtype=np.float32))


def save(img: np.ndarray, path: Path) -> None:
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(path)
    print(f"wrote {path}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("framedir", type=Path)
    ap.add_argument("--at", type=int, default=None,
                    help="frame index the span ENDS on (the event frame)")
    ap.add_argument("--span", type=int, default=5)
    ap.add_argument("--range", default=None,
                    help="FROM:TO[:STRIDE] — sheet a whole window instead "
                         "of one consecutive span")
    ap.add_argument("--mode", default="all",
                    choices=["ghost", "mean", "sheet", "all"])
    ap.add_argument("--at-xy", type=str, default=None,
                    help="X,Y screen point to crop a magnified patch around")
    ap.add_argument("--patch-size", type=int, default=120)
    ap.add_argument("--zoom", type=int, default=4)
    ap.add_argument("-o", "--out", type=Path, required=True,
                    help="output path; mode=all appends a suffix per artifact")
    a = ap.parse_args()

    if a.range:
        parts = [int(v) for v in a.range.split(":")]
        lo, hi = parts[0], parts[1]
        stride = parts[2] if len(parts) > 2 else max(1, (hi - lo) // 11)
        idxs = list(range(lo, hi + 1, stride))
        frames = [f for f in (_load(a.framedir, i) for i in idxs) if f is not None]
        if not frames:
            raise SystemExit(f"no frames in {a.range}")
        a.at = idxs[-1]
        first_idx, step = idxs[0], stride
    else:
        if a.at is None:
            raise SystemExit("need --at or --range")
        frames = span_frames(a.framedir, a.at, a.span)
        first_idx, step = a.at - len(frames) + 1, 1
    made: list[tuple[str, np.ndarray]] = []
    if a.mode in ("ghost", "all"):
        made.append(("ghost", ghost(frames, "max")))
    if a.mode in ("mean", "all"):
        made.append(("mean", ghost(frames, "mean")))
    if a.mode in ("sheet", "all"):
        made.append(("sheet", sheet(frames, first_idx, step=step)))

    for name, img in made:
        out = a.out if a.mode != "all" else \
            a.out.with_name(f"{a.out.stem}_{name}{a.out.suffix}")
        if a.at_xy and name != "sheet":
            cx, cy = (int(v) for v in a.at_xy.split(","))
            img = patch(img, cx, cy, a.patch_size, a.zoom)
        save(img, out)


if __name__ == "__main__":
    main()
