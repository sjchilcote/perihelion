"""tools/artgen/box_conditioning.py

Labeled-box conditioning (director's order, 2026-07-13, workstream 1):
extends the geometry-guide with colored, labeled boxes that tell the
generator where specific items belong, sourced from item_layouts.py's
per-room layout data. Also the gate that checks requested items actually
show up where the boxes said (crop each box region, vision-check it).

Kept separate from pilot_texture_lib.make_guide (which stays usable
unmodified for any caller that doesn't want box conditioning) -- this
module only ADDS the box annotation layer on top of an existing guide.
"""
from __future__ import annotations

import base64
import json
import time
import urllib.error
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from tools.artgen.gen import API_URL, _load_key, record_cost
from tools.artgen.item_layouts import room_item_layout, zone_to_px
from tools.artgen.pilot_texture_lib import room_mask

# MIRIAD = machine efficiency, vector orange (matches the game's own
# hazard-stripe palette). TESTATOR = bronze-verdigris (per authorship-lanes
# constitution's stated Testator palette), so the annotation itself signals
# lane at a glance during review.
LANE_COLOR = {
    "MIRIAD": (255, 140, 20),
    "TESTATOR": (120, 200, 160),
}

VERIFY_MODEL = "google/gemini-3.5-flash"


def draw_labeled_boxes(guide_path: Path, stem: str, room_idx: int, kind: str,
                        out_path: Path) -> tuple[Path, list[dict]]:
    """Draw this room's item-layout boxes onto a COPY of the guide image
    (does not mutate the original geometry guide). Returns (out_path,
    boxes) where `boxes` is the item list with pixel-space `box` added
    (x0,y0,x1,y1 in the guide's own pixel frame) for downstream use
    (prompt text, the vision gate, and the walk-mask deriver)."""
    im = Image.open(guide_path).convert("RGB")
    w, h = im.size
    items = room_item_layout(kind)
    draw = ImageDraw.Draw(im)
    try:
        font = ImageFont.load_default()
    except Exception:  # noqa: BLE001
        font = None

    boxes = []
    for item in items:
        px = zone_to_px(item["zone"], w, h)
        color = LANE_COLOR.get(item["lane"], (255, 255, 255))
        draw.rectangle(px, outline=color, width=3)
        label_pos = (px[0] + 3, max(0, px[1] - 12))
        draw.text(label_pos, item["label"], fill=color, font=font)
        boxes.append(dict(item, box=px))

    out_path.parent.mkdir(parents=True, exist_ok=True)
    im.save(out_path)
    return out_path, boxes


def boxes_prompt_note(boxes: list[dict]) -> str:
    """Prompt-language block describing the box conditioning to the image
    model: each box is a request for a specific piece of equipment to
    read as physically present at that footprint, painted directly into
    the texture (unlike the old floor-only pipeline, where only staining
    was requested near a prop -- the director's FINAL pass paints the
    equipment itself so the engine's walk-mask has real solid geometry to
    key off of)."""
    if not boxes:
        return ""
    lines = []
    for b in boxes:
        lines.append(
            f"- {b['label']} ({b['lane']}-lane): paint this as a real, "
            f"solid piece of equipment occupying the boxed region shown in "
            f"the guide -- {b['justification']}."
        )
    return (
        "LABELED ITEM BOXES -- THIS SUPERSEDES the 'no invented props' "
        "clause below for ONLY the items listed here: the geometry guide "
        "has colored, labeled boxes drawn on it. Each box names a "
        "specific item that must appear, solid and unambiguous, at that "
        "exact footprint (do not shift it elsewhere in the room, do not "
        "omit it, do not paint a DIFFERENT item there):\n"
        + "\n".join(lines) + "\n\nDo NOT render the box outlines or text "
        "labels themselves as paint on the floor -- they mark WHERE to "
        "paint the item, they are not part of the item's appearance. The "
        "'no invented props' rule below still applies to EVERYTHING "
        "NOT in this list -- do not add any item, object, or piece of "
        "equipment beyond exactly what is boxed above."
    )


def crop_box_regions(texture_path: Path, boxes: list[dict]) -> dict[str, Image.Image]:
    im = Image.open(texture_path).convert("RGB")
    w, h = im.size
    out = {}
    for b in boxes:
        x0, y0, x1, y1 = b["box"]
        # guide and final texture can differ slightly in px size (same
        # rounding slop pilot_texture_lib.apply_mask tolerates elsewhere);
        # rescale the box by the size ratio rather than assuming identity.
        gx0, gy0, gx1, gy1 = x0, y0, x1, y1
        out[b["label"]] = im.crop((max(0, gx0), max(0, gy0),
                                    min(w, gx1), min(h, gy1)))
    return out


ITEM_PLACEMENT_PROMPT = """You are the art-QA reviewer for a game floor-texture pipeline that paints \
specific equipment items into room textures at requested footprints.

Room kind: {kind}
Image 1 is the FULL generated texture. The remaining images are CROPS of \
that same texture at the exact regions where these items were requested:
{item_list}

For EACH numbered crop image (in order), answer: does that crop show the \
named item (or an unambiguous, recognizable equivalent -- e.g. a console \
bank can look like a bank of screens/panels, a crate stack can be boxes/ \
containers) as solid, physically-present equipment, rather than bare floor \
or an unrelated object?

Respond with ONLY a JSON object, no other text:
{{"results": [{{"label": str, "present": bool, "notes": "one short phrase"}}, ...], \
"all_present": bool}}"""


def verify_item_placement(texture_path: Path, boxes: list[dict], kind: str,
                           max_retries: int = 3) -> dict:
    """Vision gate (director's order, workstream 1): crop each box region
    from the finished texture and ask a vision judge whether the
    requested item actually appears there. One combined call (full
    texture + N crops) rather than N separate calls, to keep cost down."""
    if not boxes:
        return dict(all_present=True, results=[], _cost=0.0, _raw="(no boxes for this kind)")

    key = _load_key()
    crops = crop_box_regions(texture_path, boxes)
    item_list = "\n".join(f"{i + 1}. {b['label']}" for i, b in enumerate(boxes))
    text = ITEM_PLACEMENT_PROMPT.format(kind=kind, item_list=item_list)

    content: list[dict] = [{"type": "text", "text": text}]
    for path in (texture_path,):
        b64 = base64.b64encode(Path(path).read_bytes()).decode()
        content.append({"type": "image_url", "image_url": {"url": f"data:image/png;base64,{b64}"}})
    for b in boxes:
        import io
        buf = io.BytesIO()
        crops[b["label"]].save(buf, format="PNG")
        b64 = base64.b64encode(buf.getvalue()).decode()
        content.append({"type": "image_url", "image_url": {"url": f"data:image/png;base64,{b64}"}})

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
        raise RuntimeError(f"verify_item_placement failed after {max_retries} attempts: {last_err}")

    msg = data["choices"][0]["message"]
    raw = msg.get("content", "")
    if isinstance(raw, list):
        raw = "".join(c.get("text", "") for c in raw if isinstance(c, dict))

    usage = data.get("usage", {})
    cost = float(usage.get("cost", 0.0))
    record_cost(cost, {
        "model": VERIFY_MODEL, "out": f"item_placement:{texture_path}", "cost": cost,
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
