"""tools/artgen/verify_in_situ.py

THE IN-SITU GATE (director's ruling, property 4 -- "the heart of the
director's order"): render CONNECTED ROOM PAIRS with the REAL Renderer
(game/perihelion/render.py, pygame backend, SDL_VIDEODRIVER=dummy -- same
class the live game uses, same GameSession, same texture-loading path) at
gameplay zoom AND a zoomed-out overview, and judge each doorway boundary
with Gemini: does the floor read as one continuous physical surface, or
two mismatched plates? A texture ships only when EVERY doorway boundary
it participates in (to another textured pilot room) passes.

Never a synthetic composite -- these are literal frames from
Renderer.draw() with the real camera and the real multi-room portal
traversal (session.visible() / necore's visible_set), so texture drift,
palette clash, and negative-space-at-the-seam all show up exactly as a
player would see them.

Usage:
    uv run python -m tools.artgen.verify_in_situ [--limit N]
"""
from __future__ import annotations

import argparse
import base64
import json
import math
import os
import sys
import time
import traceback
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import pygame  # noqa: E402

from perihelion.levels import load_level  # noqa: E402
from perihelion.render import Renderer  # noqa: E402
from perihelion.sim import GameSession  # noqa: E402

from tools.artgen.gen import API_URL, _load_key, record_cost  # noqa: E402
from tools.artgen.pilot_texture_lib import load_pilot  # noqa: E402

SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/insitu_shots"
)
OUT_PATH = Path(__file__).resolve().parent / "insitu_verify.json"
VERIFY_MODEL = "google/gemini-3.5-flash"

GAMEPLAY_SCREEN = (480, 270)
GAMEPLAY_ZOOM = 1.35
OVERVIEW_SCREEN = (960, 540)
OVERVIEW_ZOOM = 0.55


def _textured_rooms() -> set[tuple[str, int]]:
    from tools.artgen.pilot_texture_lib import texture_out_path
    pilot = load_pilot()
    out = set()
    for r in pilot["rooms"]:
        if texture_out_path(r["level"], r["room_index"]).is_file():
            out.add((r["level"], r["room_index"]))
    return out


def _edge_midpoint(verts: list[tuple[float, float]], edge: int) -> tuple[float, float]:
    n = len(verts)
    a = verts[edge % n]
    b = verts[(edge + 1) % n]
    return (a[0] + b[0]) / 2.0, (a[1] + b[1]) / 2.0


def _room_centroid(verts: list[tuple[float, float]]) -> tuple[float, float]:
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    return sum(xs) / len(xs), sum(ys) / len(ys)


def _find_boundary_pairs(level, textured: set[tuple[str, int]], stem: str):
    """Yield (a, ea, b, eb, is_door, key) for every doorway/connection
    between two textured pilot rooms in this level."""
    seen = set()
    for a, ea, b, eb in level.connects:
        if (stem, a) in textured and (stem, b) in textured:
            k = tuple(sorted([(a, ea), (b, eb)]))
            if k not in seen:
                seen.add(k)
                yield a, ea, b, eb, False, None
    for a, ea, b, eb, _m9 in level.connects_x:
        if (stem, a) in textured and (stem, b) in textured:
            k = tuple(sorted([(a, ea), (b, eb)]))
            if k not in seen:
                seen.add(k)
                yield a, ea, b, eb, False, None
    for d in level.doors:
        if (stem, d.a) in textured and (stem, d.b) in textured:
            k = tuple(sorted([(d.a, d.ea), (d.b, d.eb)]))
            if k not in seen:
                seen.add(k)
                yield d.a, d.ea, d.b, d.eb, True, d.key


def _render_shot(stem: str, room: int, aim_pt: tuple[float, float],
                  screen: tuple[int, int], zoom: float,
                  open_door: tuple[int, int, int, int] | None) -> "pygame.Surface":
    level = load_level(ROOT / "levels" / f"{stem}.json")
    level.player_room = room
    level.player_pos = aim_pt
    session = GameSession(level, screen=screen, zoom=zoom)
    if open_door is not None:
        a, ea, b, eb = open_door
        for d in session.doors:
            if (d["a"], d["ea"]) == (a, ea) and (d["b"], d["eb"]) == (b, eb):
                d["open"] = True
                session.sim.connect(d["a"], d["ea"], d["b"], d["eb"])
    renderer = Renderer(session, backend="pygame")
    surf = pygame.Surface(screen)
    renderer.draw(surf)
    return surf


def render_pair(stem: str, a: int, ea: int, b: int, eb: int,
                 is_door: bool, key: str | None) -> dict:
    level = load_level(ROOT / "levels" / f"{stem}.json")
    verts_a = level.room_verts[a]
    mid = _edge_midpoint(verts_a, ea)
    cen = _room_centroid(verts_a)
    # nudge the apex 20% of the way from the doorway toward room a's own
    # centroid, so the camera sits safely inside room a (not exactly on
    # the wall line) while still framing the doorway prominently.
    aim = (mid[0] + 0.20 * (cen[0] - mid[0]), mid[1] + 0.20 * (cen[1] - mid[1]))
    open_door = (a, ea, b, eb) if is_door else None

    pair_id = f"{stem}:{a}-{b}" if not is_door else f"{stem}:{a}-{b}(door:{key})"
    safe_id = pair_id.replace("/", "_").replace(":", "_").replace(" ", "")
    SCRATCH.mkdir(parents=True, exist_ok=True)

    gp = _render_shot(stem, a, aim, GAMEPLAY_SCREEN, GAMEPLAY_ZOOM, open_door)
    ov = _render_shot(stem, a, aim, OVERVIEW_SCREEN, OVERVIEW_ZOOM, open_door)
    gp_path = SCRATCH / f"{safe_id}_gameplay.png"
    ov_path = SCRATCH / f"{safe_id}_overview.png"
    pygame.image.save(gp, str(gp_path))
    pygame.image.save(ov, str(ov_path))
    return dict(pair_id=pair_id, level=stem, room_a=a, room_b=b, is_door=is_door,
                key=key, gameplay_shot=str(gp_path), overview_shot=str(ov_path))


JUDGE_PROMPT = """You are the in-situ art-QA reviewer for a game's floor-texture pipeline. Two adjacent rooms of a space station share a doorway; their floor textures were generated independently and must read, in actual gameplay framing, as ONE continuous physical floor surface -- not as two mismatched plates glued together at the doorway.

Image 1: GAMEPLAY-ZOOM shot -- the actual in-game camera framing, standing near the doorway looking toward/through it.
Image 2: ZOOMED-OUT OVERVIEW shot -- the same doorway from further back, showing more of both rooms' floors at once.

Judge on three checks:
1. continuous_floor: at the doorway boundary, does the floor material read as ONE continuous physical surface crossing from one room into the other (consistent tone, consistent material logic, no visible seam/edge/color-jump exactly at the threshold)? Some material variation between differently-purposed rooms is fine IF it reads as a deliberate transition (e.g. a threshold strip, a change in deck section) rather than an error -- but if the two floors just look like a bad Photoshop stitch, this is false.
2. no_negative_space: does either room's floor show a painted border, picture-frame vignette, darkened margin, or a raised conduit/pipe/trim strip running along a wall -- i.e. does either floor look like a bounded framed plate rather than a floor surface that runs to its actual walls? This defect is especially visible right at the doorway threshold, where a framed room's floor visibly "stops" before the wall instead of running flush to it.
3. geometry_consistent: do props/walls visible in-frame look structurally sane for a real station corridor/room (nothing floating, no obviously broken silhouette)?

Respond with ONLY a JSON object, no other text:
{"continuous_floor": bool, "no_negative_space": bool, "geometry_consistent": bool, "verdict": "pass"|"fail", "notes": "one or two sentences, specific about what you see at the doorway"}

verdict is "pass" only if continuous_floor is true AND no_negative_space is true."""


def _b64(path: str | Path) -> str:
    return base64.b64encode(Path(path).read_bytes()).decode()


def judge_pair(shot: dict, max_retries: int = 3) -> dict:
    key = _load_key()
    content = [{"type": "text", "text": JUDGE_PROMPT}]
    for p in (shot["gameplay_shot"], shot["overview_shot"]):
        content.append({"type": "image_url",
                        "image_url": {"url": f"data:image/png;base64,{_b64(p)}"}})
    payload = {"model": VERIFY_MODEL, "messages": [{"role": "user", "content": content}]}
    body = json.dumps(payload).encode()

    data = None
    last_err = None
    for attempt in range(1, max_retries + 1):
        req = urllib.request.Request(
            API_URL, data=body,
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            method="POST")
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
        raise RuntimeError(f"judge_pair failed after {max_retries} attempts: {last_err}")

    msg = data["choices"][0]["message"]
    raw = msg.get("content", "")
    if isinstance(raw, list):
        raw = "".join(c.get("text", "") for c in raw if isinstance(c, dict))
    usage = data.get("usage", {})
    cost = float(usage.get("cost", 0.0))
    record_cost(cost, {
        "model": VERIFY_MODEL, "out": f"insitu:{shot['pair_id']}", "cost": cost,
        "prompt_tokens": usage.get("prompt_tokens"),
        "completion_tokens": usage.get("completion_tokens"), "ts": time.time()})

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
    return result


def process_pair(stem: str, a: int, ea: int, b: int, eb: int, is_door: bool, key: str | None) -> dict:
    shot = render_pair(stem, a, ea, b, eb, is_door, key)
    verdict = judge_pair(shot)
    shot.update(verdict)
    return shot


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--workers", type=int, default=6)
    ap.add_argument("--levels", type=str, default=None)
    args = ap.parse_args()

    textured = _textured_rooms()
    pilot = load_pilot()
    stems = sorted({r["level"] for r in pilot["rooms"]})
    if args.levels:
        stems = [s for s in stems if s in args.levels.split(",")]

    all_pairs = []
    for stem in stems:
        level = load_level(ROOT / "levels" / f"{stem}.json")
        for a, ea, b, eb, is_door, key in _find_boundary_pairs(level, textured, stem):
            all_pairs.append((stem, a, ea, b, eb, is_door, key))

    if args.limit:
        all_pairs = all_pairs[:args.limit]

    print(f"{len(all_pairs)} textured-textured doorway boundaries to judge")

    results = {}
    if OUT_PATH.exists():
        results = json.loads(OUT_PATH.read_text())

    todo = [p for p in all_pairs if
            (f"{p[0]}:{p[1]}-{p[3]}" if not p[5] else f"{p[0]}:{p[1]}-{p[3]}(door:{p[6]})")
            not in results]
    print(f"{len(all_pairs) - len(todo)} already judged, {len(todo)} to do")

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {ex.submit(process_pair, *p): p for p in todo}
        done = 0
        for fut in as_completed(futs):
            p = futs[fut]
            done += 1
            try:
                r = fut.result()
                results[r["pair_id"]] = r
                print(f"[{done}/{len(todo)}] {r['pair_id']:30s} {r['verdict']:5s} {r.get('notes','')[:80]}")
            except Exception as exc:  # noqa: BLE001
                pid = f"{p[0]}:{p[1]}-{p[3]}"
                print(f"[{done}/{len(todo)}] {pid} CRASHED: {exc}")
                traceback.print_exc()
                results[pid] = dict(pair_id=pid, verdict="error", notes=str(exc))
            OUT_PATH.write_text(json.dumps(results, indent=2))

    n_pass = sum(1 for r in results.values() if r.get("verdict") == "pass")
    n_fail = sum(1 for r in results.values() if r.get("verdict") == "fail")
    n_err = sum(1 for r in results.values() if r.get("verdict") not in ("pass", "fail"))
    print(f"TOTAL: {len(results)} boundaries, pass={n_pass} fail={n_fail} error={n_err}")
    print(f"Wrote {OUT_PATH}")


if __name__ == "__main__":
    main()
