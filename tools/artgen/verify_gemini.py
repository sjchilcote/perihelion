"""tools/artgen/verify_gemini.py

Gemini in-context vision verification for pilot room textures. Follows the
pattern of verify_in_context.py but judges generated textures against their
base-truth geometry prior and (when available) the kind's style anchor,
via a single OpenRouter chat-completion call with images attached.

Logs cost to the SAME tools/artgen/cost_log.json gen.py uses, so
`gen.py --report` reflects total pilot spend (generation + verification).
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

PROMPT_TEMPLATE = """You are the art-QA reviewer for a game texture pipeline.

Room kind: {kind}
Image 1: BASE TRUTH -- the flat vector render defining exact required geometry (room silhouette, wall lines only). Deliberately shows NO crates, consoles, pipes, vents, chevrons, or any other prop/object -- those are separate physical objects the live game draws on top of the floor every frame, not part of the floor texture. Pixels outside the room polygon are pure black.
{anchor_line}
Image {gen_idx}: GENERATED TEXTURE -- candidate bespoke texture for this exact room, meant to be a same-geometry high-fidelity re-render of image 1's floor material only.

Judge the GENERATED TEXTURE against BASE TRUTH (and the style anchor, if given) on five checks:
1. geometry_ok: does the room silhouette and every wall line match BASE TRUTH almost exactly, AND is the generated texture free of any invented crate, console, pipe, vent, arrow/chevron, valve wheel, sign, or other discrete object/prop illustration (irregular wear/staining/grime is fine and expected; a painted OBJECT is not)? This is the critical check -- if walls have moved/resized, or if ANY prop-like object appears anywhere (even one that plausibly "belongs" in this room kind), this is false.
2. style_ok: is the material treatment consistent with the style anchor's family (same texture logic, same era, similar level of grime/detail)? If no anchor was given, judge internal consistency instead (true unless obviously broken).
3. palette_ok: is the palette a muted, desaturated, industrial-horror family (cold grays, rust ochre, dull teal, near-black) -- NOT blown out bright, NOT saturated/cartoonish, NOT pre-darkened to near-black mud?
4. fidelity_ok: is this genuinely higher visual fidelity than the flat base truth (real material detail, not just a blurry/soft recolor of the same flat shapes)?
5. fullbleed_ok: is this a piece of continuous floor SURFACE that runs flush to every edge/wall line, with NO painted border, NO picture-frame vignette, NO darkened margin, and NO raised conduit/pipe/duct trim or rivet strip running along the perimeter just inside the walls? A room that reads as "a floor plate sitting inside a frame" rather than "the room's actual floor extending to its walls" fails this check even if geometry is otherwise correct. This is the single most common failure mode -- inspect the full perimeter carefully.

Respond with ONLY a JSON object, no other text:
{{"geometry_ok": bool, "style_ok": bool, "palette_ok": bool, "fidelity_ok": bool, "fullbleed_ok": bool, "verdict": "pass"|"fail", "notes": "one or two sentences, specific, mention any geometry drift or negative-space/border defect precisely"}}

verdict is "pass" only if geometry_ok is true AND fullbleed_ok is true AND at least three of the five checks are true overall."""


def _b64_image(path: str | Path) -> str:
    return base64.b64encode(Path(path).read_bytes()).decode()


def verify_texture(base_truth_path: str | Path, generated_path: str | Path,
                    kind: str, anchor_path: str | Path | None = None,
                    max_retries: int = 3) -> dict:
    key = _load_key()
    content: list[dict] = []
    images = [(str(base_truth_path), "BASE TRUTH")]
    anchor_line = "(no separate style anchor given -- this generation IS the anchor)"
    gen_idx = 2
    if anchor_path is not None:
        images.append((str(anchor_path), "STYLE ANCHOR"))
        anchor_line = "Image 2: STYLE ANCHOR -- the approved material treatment for this room kind, to match."
        gen_idx = 3
    images.append((str(generated_path), "GENERATED"))

    text = PROMPT_TEMPLATE.format(kind=kind, anchor_line=anchor_line, gen_idx=gen_idx)
    content.append({"type": "text", "text": text})
    for path, _label in images:
        content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/png;base64,{_b64_image(path)}"},
        })

    payload = {
        "model": VERIFY_MODEL,
        "messages": [{"role": "user", "content": content}],
    }
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
        raise RuntimeError(f"verify_texture failed after {max_retries} attempts: {last_err}")

    msg = data["choices"][0]["message"]
    raw = msg.get("content", "")
    if isinstance(raw, list):
        raw = "".join(c.get("text", "") for c in raw if isinstance(c, dict))

    usage = data.get("usage", {})
    cost = float(usage.get("cost", 0.0))
    record_cost(cost, {
        "model": VERIFY_MODEL, "out": f"verify:{generated_path}", "cost": cost,
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
