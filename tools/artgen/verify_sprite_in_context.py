"""tools/artgen/verify_sprite_in_context.py

In-context verification for PERIHELION's high-pixel (HP) entity/prop sprites,
following the same methodology as verify_in_context.py (paste the real asset
into a real rendered scene, judge the composite) but for gameplay sprites
instead of menu backgrounds, and using a Gemini-vision judge over OpenRouter
(same key-loading + retry pattern as tools/playtest/audio_judge.py) instead
of a human screenshot review, since sprite/silhouette coherence is a visual
judgment an LLM can make directly from the composited PNG.

    verify_sprite(sprite_path, bg_path, paste_xy, target_px, spec) -> dict
        with p_shippable, matches_spec, tells, summary; writes the composite
        PNG next to the sprite for a human to also eyeball.

Never fabricates a passing judgement: a failed API call after retries comes
back as an explicit error dict (p_shippable=None).
"""
from __future__ import annotations

import base64
import io
import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from gen import _load_key, _read_cost_log, _write_cost_log  # noqa: E402

MODEL = "google/gemini-3.5-flash"
API_URL = "https://openrouter.ai/api/v1/chat/completions"

PROMPT_TEMPLATE = """You are a game art director reviewing a candidate \
"high-pixel" sprite that has been composited into a REAL screenshot from a \
shipping top-down sci-fi horror shooter (PERIHELION). The base game currently \
renders everything as flat vector shapes; this candidate sprite is a \
replacement for one such shape, meant to look like a detailed \
pixel-art / painted sprite at native resolution, sitting believably in the \
same scene, at the same position and size the flat-vector shape used to \
occupy.

Sprite identity / spec: {spec}

First, describe factually what you see at the sprite's location: silhouette \
shape, palette, whether it reads as the intended subject, edge quality \
(hard aliasing vs clean anti-aliasing vs stray halo/fringe from background \
removal), and whether its scale/perspective (top-down orthographic) matches \
the surrounding scene.

Then judge:
- coherent: does it look like ONE intentional sprite, not a collage or \
  distorted mess?
- palette_match: does it fit the scene's cold desaturated industrial-horror \
  palette (not blown out, not a jarring hue)?
- silhouette_match: does the shape read as the intended subject from the spec?
- no_background_halo: is the transparency clean (no visible rectangle, \
  checkerboard, or bright fringe around the sprite)?
- p_shippable: P(an art director would accept this sprite for the described \
  role in this exact game, as-is). Use the full range: 0.9+ ready; 0.6 usable \
  with minor cleanup; 0.4 wrong in one important way (wrong pose, wrong \
  palette, halo); below 0.2 unusable or unrecognizable.

Report a flaw ONLY if it is visible in your own description above.

Return STRICT JSON only, no markdown fences, matching exactly this schema:
{{"seen": "2-3 factual sentences",
  "coherent": true|false,
  "palette_match": true|false,
  "silhouette_match": true|false,
  "no_background_halo": true|false,
  "p_shippable": 0.x,
  "tells": ["only flaws actually visible"],
  "summary": "1-2 sentences"}}"""


def _img_block(png_path: Path) -> dict:
    b64 = base64.b64encode(png_path.read_bytes()).decode()
    return {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{b64}"}}


def composite(sprite_path: Path, bg_path: Path, paste_center_xy: tuple[int, int],
              target_w: int, out_path: Path) -> Path:
    """Paste `sprite_path` (RGBA) onto a copy of `bg_path`, scaled so its
    width == target_w (aspect preserved), centered at paste_center_xy.
    Writes out_path, returns it."""
    bg = Image.open(bg_path).convert("RGBA")
    sprite = Image.open(sprite_path).convert("RGBA")
    ratio = target_w / sprite.width
    target_h = max(1, round(sprite.height * ratio))
    sprite_scaled = sprite.resize((target_w, target_h), Image.LANCZOS)
    cx, cy = paste_center_xy
    top_left = (cx - target_w // 2, cy - target_h // 2)
    bg.alpha_composite(sprite_scaled, dest=top_left)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    bg.convert("RGB").save(out_path)
    return out_path


def _parse_json(txt: str) -> dict:
    txt = txt.strip()
    if txt.startswith("```"):
        txt = txt.split("```")[1]
        txt = txt[4:] if txt.startswith("json") else txt
    return json.loads(txt)


def _ask(composite_path: Path, spec: str, attempts: int = 3) -> dict:
    prompt = PROMPT_TEMPLATE.format(spec=spec)
    body = {
        "model": MODEL,
        "messages": [{"role": "user", "content": [
            {"type": "text", "text": prompt},
            _img_block(composite_path),
        ]}],
        "temperature": 0.2,
    }
    last_err = None
    for attempt in range(attempts):
        try:
            req = urllib.request.Request(
                API_URL, data=json.dumps(body).encode(),
                headers={"Authorization": f"Bearer {_load_key()}",
                         "Content-Type": "application/json"},
            )
            with urllib.request.urlopen(req, timeout=180) as resp:
                payload = json.load(resp)
            usage = payload.get("usage", {})
            cost = float(usage.get("cost", 0.0))
            log = _read_cost_log()
            log["total_cost"] = log.get("total_cost", 0.0) + cost
            log.setdefault("calls", []).append({
                "model": MODEL, "out": f"verify:{composite_path.name}",
                "cost": cost, "prompt_tokens": usage.get("prompt_tokens"),
                "completion_tokens": usage.get("completion_tokens"), "ts": time.time(),
            })
            _write_cost_log(log)
            txt = payload["choices"][0]["message"]["content"]
            return _parse_json(txt)
        except Exception as e:  # noqa: BLE001 -- never fabricate a pass on error
            last_err = e
            print(f"verify_sprite: attempt {attempt + 1}/{attempts} failed: {e}",
                  file=sys.stderr)
            if attempt < attempts - 1:
                time.sleep(8 * (attempt + 1))
    return {"error": f"{type(last_err).__name__}: {last_err}", "p_shippable": None}


def verify_sprite(sprite_path: str | Path, bg_path: str | Path,
                   paste_xy: tuple[int, int], target_px: int, spec: str,
                   composite_out: str | Path) -> dict:
    comp = composite(Path(sprite_path), Path(bg_path), paste_xy, target_px,
                      Path(composite_out))
    result = _ask(comp, spec)
    result["composite"] = str(comp)
    return result


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--sprite", required=True)
    ap.add_argument("--bg", required=True)
    ap.add_argument("--x", type=int, required=True)
    ap.add_argument("--y", type=int, required=True)
    ap.add_argument("--w", type=int, required=True)
    ap.add_argument("--spec", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    r = verify_sprite(args.sprite, args.bg, (args.x, args.y), args.w, args.spec, args.out)
    print(json.dumps(r, indent=2))
