"""tools/artgen/gen_kind_materials.py

STYLE CONTINUITY (property 2): generate ONE tileable base material per
room kind (14 kinds), make it tileable via offset-wrap + mirror-feather
seam repair, verify tiling programmatically (tile 2x2, measure the seam),
verify full-bleed (no painted border/vignette) programmatically, and
record each kind's mean-luminance/chroma window -- the shared tone family
every room of that kind is graded toward.

Retries once per kind if tiling or full-bleed fails; a kind that fails
twice keeps its best-scoring candidate (rooms of that kind still get the
programmatic per-room checks, so a marginal material doesn't sink them).

Usage:
    uv run python tools/artgen/gen_kind_materials.py [--kinds dock,corridor,...]
"""
from __future__ import annotations

import argparse
import json
import traceback
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from PIL import Image

from tools.artgen.gen import generate_image
from tools.artgen.pilot_texture_lib import KIND_MATERIAL, SCRATCH, build_material_prompt
from tools.artgen.texture_checks import make_tileable, region_tone, verify_fullbleed, verify_tiling

MATERIALS_DIR = SCRATCH / "materials"
WINDOWS_PATH = Path(__file__).resolve().parent / "kind_windows.json"
RAW_DIR = SCRATCH / "materials_raw"


def gen_one_kind(kind: str) -> dict:
    prompt = build_material_prompt(kind)
    MATERIALS_DIR.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    best = None
    for attempt in (1, 2):
        raw_out = RAW_DIR / f"{kind}_a{attempt}.png"
        this_prompt = prompt
        if attempt == 2 and best is not None:
            this_prompt += (
                f"\n\nPREVIOUS ATTEMPT FAILED THE TILING/FULL-BLEED CHECK: "
                f"{best['fail_reason']} Fix that specifically this time."
            )
        gr = generate_image(this_prompt, raw_out)
        im = Image.open(raw_out).convert("RGB")
        # square up (center-crop) before tiling repair -- non-square
        # swatches make the offset-wrap seam math asymmetric
        w, h = im.size
        s = min(w, h)
        im = im.crop(((w - s) // 2, (h - s) // 2, (w - s) // 2 + s, (h - s) // 2 + s))
        tiled_im = make_tileable(im)

        fb = verify_fullbleed(tiled_im)
        tv = verify_tiling(tiled_im)
        ok = fb["ok"] and tv["ok"]
        fail_reason = "" if ok else (
            (f"border/vignette detected (darken_ratio={fb.get('darken_ratio')}, "
             f"grad_ratio={fb.get('grad_ratio')}). " if not fb["ok"] else "")
            + (f"visible tile seam (ratio_v={tv['ratio_v']:.2f}, "
               f"ratio_h={tv['ratio_h']:.2f})." if not tv["ok"] else "")
        )
        out_path = MATERIALS_DIR / f"{kind}.png"
        # severity score: 0 if ok, else how far over threshold (lower is
        # better) -- used to keep the BETTER of two failing attempts
        # rather than always keeping attempt 1.
        severity = 0.0 if ok else (
            max(0.0, fb.get("darken_ratio") or 0 - 1.0)
            + max(0.0, fb.get("grad_ratio") or 0 - 1.0)
            + max(0.0, tv["ratio_v"] - 1.0) + max(0.0, tv["ratio_h"] - 1.0)
        )
        cand = dict(kind=kind, attempt=attempt, cost=gr["cost"], ok=ok,
                    fullbleed=fb, tiling=tv, fail_reason=fail_reason,
                    path=str(out_path), severity=severity)
        if best is None or ok and not best["ok"] or (
                ok == best["ok"] and severity < best["severity"]):
            tiled_im.save(out_path)
            best = cand
        if ok:
            break
    tone = region_tone(Image.open(best["path"]).convert("RGB"))
    best["tone"] = tone
    return best


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--kinds", default=None)
    args = ap.parse_args()

    kinds = args.kinds.split(",") if args.kinds else list(KIND_MATERIAL.keys())
    results = []
    errors = []
    with ThreadPoolExecutor(max_workers=7) as ex:
        futs = {ex.submit(gen_one_kind, k): k for k in kinds}
        for fut in as_completed(futs):
            k = futs[fut]
            try:
                r = fut.result()
                results.append(r)
                print(f"{'OK  ' if r['ok'] else 'WARN'} {k:12s} "
                      f"cost=${r['cost']:.4f} ok={r['ok']} attempt={r['attempt']}")
            except Exception as exc:  # noqa: BLE001
                errors.append((k, str(exc)))
                print(f"FAIL {k:12s} {exc}")
                traceback.print_exc()

    windows = {}
    if WINDOWS_PATH.exists():
        windows = json.loads(WINDOWS_PATH.read_text())
    for r in results:
        windows[r["kind"]] = r["tone"]
    WINDOWS_PATH.write_text(json.dumps(windows, indent=2))
    print(f"Wrote {WINDOWS_PATH}")
    if errors:
        print(f"{len(errors)} kind(s) failed generation entirely: {errors}")


if __name__ == "__main__":
    main()
