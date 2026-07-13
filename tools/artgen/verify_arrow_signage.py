"""tools/artgen/verify_arrow_signage.py

Director-ordered remediation audit (2026-07-13): "run the arrow-vs-decal
audit across the legacy set" -- distinguish a BAKED arrow/chevron/directional
guide mark or legible text painted into a floor texture (a real generation
defect; the only legitimate decal kinds the live game ever draws are
"blood", "splat", "chip", "scorch", "corpse_*" per game/perihelion/render.py
_draw_decal -- none of which are directional signage) from ordinary
wear/staining/rivet-plate structure.

Single-image Gemini judge (no base truth needed -- this is a defect scan
over already-shipped textures, not a generation-time geometry check).
Same OpenRouter call pattern / cost logging as verify_gemini.py.
"""
from __future__ import annotations

import base64
import json
import time
import urllib.error
import urllib.request
from pathlib import Path

from tools.artgen.gen import API_URL, _load_key, record_cost

VERIFY_MODEL = "google/gemini-3.5-flash"

PROMPT = """You are the art-QA reviewer for a game floor-texture pipeline.

You are looking at ONE shipped floor texture (an image-generation output,
tiled/masked to a room's polygon). The game draws these gameplay decal
kinds live on TOP of the floor at runtime -- NOT baked into this image:
"blood" (small red blob), "splat" (blood splat blob), "chip" (small X-shaped
scuff), "scorch" (circular scorch mark), "corpse_*" (dead-body silhouette).
None of those are directional arrows, chevrons, or legible text/signage.

Look at the floor texture and answer: does it contain any BAKED-IN arrow
shape, chevron (>, <, ^, v pointer shape used as a directional wayfinding
mark), directional stripe with an arrowhead, or legible/half-legible painted
text/lettering/stencil/serial-number/placard? Ordinary hazard-stripe
diagonal banding with NO arrowhead or point is fine (floor marking paint,
not a directional sign) -- only flag it if it has a point/arrowhead or is
actual lettering.

Respond with ONLY a JSON object, no other text:
{"has_arrow_or_signage": bool, "confidence": "low"|"medium"|"high", "notes": "one sentence, specific, cite the location in the image (e.g. 'upper-left corner') if flagged"}"""


def _b64_image(path: str | Path) -> str:
    return base64.b64encode(Path(path).read_bytes()).decode()


def verify_no_arrow_signage(texture_path: str | Path, max_retries: int = 3) -> dict:
    key = _load_key()
    content: list[dict] = [{"type": "text", "text": PROMPT}]
    content.append({
        "type": "image_url",
        "image_url": {"url": f"data:image/png;base64,{_b64_image(texture_path)}"},
    })
    payload = {"model": VERIFY_MODEL, "messages": [{"role": "user", "content": content}]}
    body = json.dumps(payload).encode()

    data = None
    last_err = None
    for attempt in range(1, max_retries + 1):
        req = urllib.request.Request(
            API_URL, data=body,
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                data = json.load(resp)
            break
        except urllib.error.HTTPError as e:
            last_err = f"HTTP {e.code}: {e.read().decode(errors='replace')[:500]}"
        except (urllib.error.URLError, TimeoutError) as e:
            last_err = str(e)
        if attempt < max_retries:
            time.sleep(3.0 * attempt)
    if data is None:
        raise RuntimeError(f"verify_no_arrow_signage failed after {max_retries} attempts: {last_err}")

    msg = data["choices"][0]["message"]
    raw = msg.get("content", "")
    if isinstance(raw, list):
        raw = "".join(c.get("text", "") for c in raw if isinstance(c, dict))

    usage = data.get("usage", {})
    cost = float(usage.get("cost", 0.0))
    record_cost(cost, {
        "model": VERIFY_MODEL, "out": f"arrow_audit:{texture_path}", "cost": cost,
        "prompt_tokens": usage.get("prompt_tokens"),
        "completion_tokens": usage.get("completion_tokens"), "ts": time.time(),
    })

    text_clean = raw.strip()
    if text_clean.startswith("```"):
        text_clean = text_clean.strip("`")
        if text_clean.startswith("json"):
            text_clean = text_clean[4:]
    try:
        start = text_clean.index("{")
        end = text_clean.rindex("}") + 1
        result = json.loads(text_clean[start:end])
    except (ValueError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"could not parse verdict JSON from: {raw!r}") from exc

    result["_cost"] = cost
    result["_raw"] = raw
    return result
