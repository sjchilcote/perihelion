"""Generate style-anchor texture candidates for each of the 14 room kinds.

uv run python tools/artgen/gen_anchors.py [--kinds dock,corridor,...] [--cand 1]
"""
from __future__ import annotations

import argparse
import json
import sys
import traceback
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from tools.artgen.gen import generate_image
from tools.artgen.pilot_texture_lib import (
    ROOT, SCRATCH, basetruth_path, build_anchor_prompt,
)

ANCHOR_DIR = SCRATCH / "anchors"
ANCHOR_MAP = json.loads((SCRATCH / "anchor_map.json").read_text())


def gen_one(kind: str, cand: int) -> dict:
    info = ANCHOR_MAP[kind]
    bt = basetruth_path(info["level"], info["room_index"])
    ctx = info["context"]
    prompt = build_anchor_prompt(kind)
    out = ANCHOR_DIR / f"{kind}_c{cand}.png"
    refs = [str(bt), ctx]
    result = generate_image(prompt, out, reference_images=refs)
    result["kind"] = kind
    result["cand"] = cand
    return result


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--kinds", default=None)
    ap.add_argument("--cand", type=int, default=1)
    args = ap.parse_args()

    kinds = args.kinds.split(",") if args.kinds else list(ANCHOR_MAP.keys())
    ANCHOR_DIR.mkdir(parents=True, exist_ok=True)

    results = []
    errors = []
    with ThreadPoolExecutor(max_workers=7) as ex:
        futs = {ex.submit(gen_one, k, args.cand): k for k in kinds}
        for fut in as_completed(futs):
            k = futs[fut]
            try:
                r = fut.result()
                results.append(r)
                print(f"OK   {k:12s} cost=${r['cost']:.4f} -> {r['path']}")
            except Exception as exc:  # noqa: BLE001
                errors.append((k, str(exc)))
                print(f"FAIL {k:12s} {exc}")
                traceback.print_exc()

    print(json.dumps({"results": results, "errors": errors}, indent=2))


if __name__ == "__main__":
    main()
