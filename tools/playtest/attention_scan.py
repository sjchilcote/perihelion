#!/usr/bin/env python3
"""An attention instrument: score every moment of a capture for how
UNUSUAL it is, without being told what to look for.

WHY. Every instrument in this project so far could only find what
someone thought to look for. A reviewer given a checklist finds
checklist items; a reviewer given no checklist reports whatever it
happens to recognise, and a reviewer who does not know the game (me)
recognises nothing and manufactures defects out of unfamiliarity.

This does not attempt to judge. It NOMINATES. Two independent signals,
neither of which needs to know what a bug is:

  gate    Mage-VL's StreamMind cognition gate — a head trained to decide
          whether a segment is worth speaking about. Its own notion of
          "response-worthy", applied to our footage.

  novelty distance of a window's visual embedding from the session's own
          median. A defect is, almost by definition, not what the rest
          of the session looks like. This needs no training and no
          notion of correctness — only that the anomaly is rare.

Both produce a ranking. A ranking is a place to look, never a verdict:
a muzzle flash is unusual and correct. Scoring the ranking against known
defect windows is what says whether the instrument sees anything.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np


def sample_window(framedir: Path, lo: int, hi: int, n: int):
    from PIL import Image
    idxs = np.linspace(lo, hi, n, dtype=int)
    out = []
    for i in idxs:
        p = framedir / f"frame_{int(i):06d}.png"
        if p.exists():
            out.append(Image.open(p).convert("RGB"))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("framedir", type=Path)
    ap.add_argument("--model", default=None, help="Mage-VL snapshot dir")
    ap.add_argument("--fps", type=float, default=20.0)
    ap.add_argument("--window", type=float, default=5.0, help="seconds")
    ap.add_argument("--frames-per-window", type=int, default=8)
    ap.add_argument("--limit", type=int, default=0, help="first N windows only")
    ap.add_argument("-o", "--out", type=Path, required=True)
    a = ap.parse_args()

    import torch
    from transformers import AutoModelForCausalLM, AutoProcessor

    model_path = a.model
    if model_path is None:
        import glob
        hits = glob.glob(str(Path.home() / ".cache/huggingface/hub/"
                             "models--microsoft--Mage-VL/snapshots/*/"))
        if not hits:
            raise SystemExit("Mage-VL not found; pass --model")
        model_path = hits[0]

    proc = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(
        model_path, trust_remote_code=True, torch_dtype="auto",
        device_map="auto").eval()

    n_frames = len(list(a.framedir.glob("frame_*.png")))
    step = int(a.window * a.fps)
    starts = list(range(0, n_frames - step, step))
    if a.limit:
        starts = starts[:a.limit]
    print(f"{n_frames} frames, {len(starts)} windows of {a.window}s", flush=True)

    inner = model.model if hasattr(model, "model") else model
    rows = []
    for k, lo in enumerate(starts):
        frames = sample_window(a.framedir, lo, lo + step - 1, a.frames_per_window)
        if not frames:
            continue
        # the processor expands a chat template into the <|video_pad|>
        # placeholders it then counts; hand-writing "<video>" does not
        msgs = [{"role": "user", "content": [{"type": "video"},
                                             {"type": "text", "text": "."}]}]
        chat = proc.apply_chat_template(msgs, tokenize=False,
                                        add_generation_prompt=True)
        inputs = proc(text=[chat], videos=[frames], return_tensors="pt",
                      padding=True)
        # this processor hands frames over as IMAGES and supplies the 3D
        # rope coordinates separately; the vision tower needs them
        pv = inputs["pixel_values"].to(model.device).to(model.dtype)
        thw = inputs["image_grid_thw"].to(model.device)
        pp = inputs["patch_positions"].to(model.device)
        with torch.inference_mode():
            emb = None
            try:
                feats = inner.get_image_features(pv, thw, patch_positions=pp)
                if isinstance(feats, (list, tuple)):
                    feats = torch.cat([f.reshape(-1, f.shape[-1]) for f in feats])
                emb = feats.float().reshape(-1, feats.shape[-1]).mean(0).cpu().numpy()
            except Exception as exc:
                if k == 0:
                    print(f"  features unavailable: {type(exc).__name__}: {exc}",
                          flush=True)
            gate = None
            try:
                g = inner.streammind_gate_forward(pv, thw, patch_positions=pp)
                gate = float(np.asarray(g.float().cpu()).reshape(-1).mean())
            except Exception as exc:  # gate optional; novelty still works
                if k == 0:
                    print(f"  gate unavailable: {type(exc).__name__}: {exc}",
                          flush=True)
        rows.append(dict(window=k, frame_lo=lo, frame_hi=lo + step - 1,
                         t=lo / a.fps, gate=gate,
                         emb=None if emb is None else emb.tolist()))
        if k % 20 == 0:
            print(f"  window {k}/{len(starts)}  t={lo/a.fps:6.1f}s  gate={gate}",
                  flush=True)

    embs = np.array([r["emb"] for r in rows if r["emb"] is not None],
                    dtype=np.float32)
    if len(embs):
        med = np.median(embs, axis=0)
        d = np.linalg.norm(embs - med, axis=1)
        d = (d - d.mean()) / (d.std() + 1e-9)
        j = 0
        for r in rows:
            if r["emb"] is not None:
                r["novelty"] = float(d[j]); j += 1
            r.pop("emb", None)
    a.out.write_text(json.dumps(rows, indent=1))
    print(f"wrote {a.out} ({len(rows)} windows)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
