#!/usr/bin/env python3
"""tools/design/consult_marrow_visual.py

Consult Sol on a VISUAL PASS for the marrow (the Adversary's hub cathedral
and the corruption gradient leading into it).

The director's brief, 2026-07-28, verbatim:

    "I explored it a little, and its _structure_ is pretty good; it feels
    like invading an alien hive, but it doens't _look_ like it. Remember
    polygons are just that - individual polygons. This engine is not
    contrained to square rooms by any means. It should transition to the
    otherworld room type as you get deeper in."

Inputs are real files inlined verbatim, plus REAL RENDERED FRAMES
(Responses-API image parts): the hub as built today, the otherworld
register the marrow should transition into, and an ordinary combat chamber
for the baseline the gradient departs from.

Usage:
    uv run python tools/design/consult_marrow_visual.py --dry-run
    uv run python tools/design/consult_marrow_visual.py
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO.parent / "noneuclideantopdownshooter" / "tools" / "musicgen"))
import consult_machinery as cm  # noqa: E402

KEY_PATHS = [
    REPO / ".openrouter_key",
    Path.home() / "Documents" / "youtube" / "autoclipping" / ".openrouter_key",
]

IMAGES = [
    # (path, caption)
    (REPO / "out/organ_visual/organ_AN1.png",
     "HUB AS BUILT: apse court AN1 — a production court of the hub "
     "cathedral, violet reliquary light, organ part bodies (purple)."),
    (REPO / "out/organ_visual/organ_C1.png",
     "HUB AS BUILT: collar chamber C1."),
    (REPO / "out/organ_visual/organ_SC.png",
     "HUB AS BUILT: the Scriptorium."),
    (REPO / "out/organ_visual/organ_V.png",
     "HUB AS BUILT: processional transept V."),
    (REPO / "out/authored_session/frame_000899.png",
     "ORDINARY WORLD BASELINE: a gauntlet4 combat chamber mid-session — "
     "textured floor, corpses and decals, the player's warm light. This "
     "is the register the corruption gradient departs FROM."),
    (REPO / "out/consult_visual_refs/ow_ref.png",
     "OTHERWORLD REGISTER, irregular polygon: a six-sided convex chamber "
     "of kind 'otherworld' — self-luminous cold floor, engine-composed "
     "darkness field. Rendered by the shipped renderer; proof the engine "
     "does not require square rooms."),
    (REPO / "out/consult_visual_refs/ow_rect.png",
     "OTHERWORLD REGISTER, plain rectangle, for comparison."),
    (REPO / "out/consult_visual_refs/world_ref.png",
     "Ordinary 'dock' kind chamber, same size/lighting rig as the "
     "rectangle above — the mundane register side by side."),
]

DIRECTOR_BRIEF = """
The director explored the marrow on 2026-07-28 and ruled, verbatim:

    "its _structure_ is pretty good; it feels like invading an alien hive,
    but it doesn't _look_ like it. Remember polygons are just that -
    individual polygons. This engine is not constrained to square rooms by
    any means. It should transition to the otherworld room type as you get
    deeper in."

Facts on the ground backing that reading:
  - hub.py builds all 24 hub chambers with b.rect(...) — every apse,
    court, and transept is an axis-aligned rectangle.
  - The hub chambers use mundane room kinds; gauntlet4's census is
    storage/corridor/hall/chapel/etc. with ZERO 'otherworld' chambers.
    The alienness currently comes ONLY from the light plan (violet/brass)
    and the organ part bodies.
  - The renderer has a fully working 'otherworld' room kind: self-luminous
    cold floor (OW_FLOOR), an engine-composed inverse darkness field
    (mark_otherworld / compose step 6), its own prop generator
    (_props_otherworld, which takes a `descent` 0..1 parameter), used
    today only by late campaign levels (l07-l10).
  - LevelBuilder.polygon(verts) accepts arbitrary convex polygons
    (y-down visual-CCW winding). connect() glues any two edges; the
    scale-1 law (connect_equal: carve both sides the same width) is a
    construction rule, not a shape constraint.
"""

ASK = """
================================================================================
THE ASK — A VISUAL PASS PLAN FOR THE MARROW
================================================================================
Design the pass that makes invading the marrow LOOK like invading an alien
hive, implementable by a senior engineer against the systems above. We want
RECOMMENDATIONS, not menus. Cover:

1. GEOMETRY LANGUAGE. A shape grammar for the hub's 24 chambers (apses,
   courts, transept, trunk, source cells) using arbitrary convex polygons:
   what silhouettes read "grown, not built" at zoom 0.45 in a 640x360
   internal frame, while staying convex and keeping every glued seam
   width-equal (scale-1 law). Be concrete: for each chamber ROLE, give a
   vertex-count range, aspect/irregularity guidance, and how the 96u door
   carves survive the reshape. Say what the reshape must NOT break:
   settlement anchors, organ part placement, the shelf, resident posts,
   light positions.

2. THE CORRUPTION GRADIENT. The director's ruling: transition to the
   otherworld room kind as you get deeper in. Propose the exact mapping —
   which depth band (the hub is 10-11 crossings deep; breach chambers
   surface anywhere in the world) switches kind, whether the transition is
   a hard kind swap per chamber or a staged use of _props_otherworld's
   `descent` parameter plus lighting, and how the gradient reads in the
   world OUTSIDE the hub (a breach mouth should look infected before you
   ever cross). Respect that the otherworld kind changes the LIGHTING
   MODEL (self-luminous floor, inverse darkness) — say how that interacts
   with the hub light plan (HUB_LIGHT_PLAN's violet apses / brass courts /
   trunk ramp) and with the player's own lights.

3. LEGIBILITY UNDER THE LAWS. The visual vocabulary law: one symbol = one
   meaning; rings = aggro only; body events on the body; enemies keep
   tiered minimum pixel sizes; on-screen mechanics must be readable at
   0.45. The organ parts are violet; the otherworld register is cold
   green-blue. Resolve the palette so organ parts, enemies, decals, and
   the player's warm light stay instantly separable in the new register —
   name the specific color lanes.

4. WHAT TO BUILD. The concrete change list: hub.py construction (which
   rects become which polygons, staged how), level JSON / authoring
   changes if any, render/prop changes if any (e.g. new prop vocabulary
   for hive walls — note the walls-breathe law and the handcraft law from
   the constitution), and the order to land them in given every gameplay
   commit must pass a filmed playtest gate.

5. FOR EACH RECOMMENDATION: what it PREDICTS on film and what it FORBIDS
   (an observation that would show it failed), your odds it survives the
   director's eye, and the single strongest reason you might be wrong.

HARD CONSTRAINTS:
  - Convex polygons only; portal glue is edge-to-edge with equal widths.
  - No feature flags, no alternate modes; ship hardwired.
  - Gameplay geometry is live: the hub is fought through — chamber
    reshapes change combat sightlines, and that is acceptable but must be
    called out where it changes a ratified behavior (shelf pour order,
    one-door stall hazards — do NOT create more one-door chambers).
  - 0.45 zoom is THE zoom. 640x360 internal resolution.
  - The organ, residents, shelf, and light plan are landed systems —
    reshape around them, do not redesign them.
Be specific to OUR systems and vocabulary. The frames attached are real
renders from the shipped build, not mockups.
"""


def load_api_key() -> str | None:
    key = os.environ.get("OPENROUTER_API_KEY")
    if key and key.strip():
        return key.strip()
    for path in KEY_PATHS:
        if path.exists():
            text = path.read_text().strip()
            if text:
                return text
    return None


def _file(p: Path) -> str:
    if not p.exists():
        raise FileNotFoundError(p)
    return p.read_text()


def _excerpt_render() -> str:
    src = (REPO / "game/perihelion/render.py").read_text().splitlines()
    pal = "\n".join(src[118:146])
    props = "\n".join(src[1410:1495])
    return ("# palette constants (render.py)\n" + pal +
            "\n\n# the otherworld prop generator + kind registry (render.py)\n"
            + props)


def build_text() -> str:
    from consult_marrow import PRODUCT_CONTEXT
    parts = [
        "EXTERNAL CONSULT: PERIHELION — a VISUAL PASS on the marrow (the "
        "Adversary hub cathedral and the corruption gradient into it).\n"
        "Rendered frames from the shipped build are attached as images; "
        "captions identify each. The full ask is the final section.\n",
        cm.section("0. PRODUCT CONTEXT", PRODUCT_CONTEXT.strip()),
        cm.section("1. THE DIRECTOR'S BRIEF (authoritative)",
                   DIRECTOR_BRIEF.strip()),
        cm.section(
            "2. THE BAYESCRAFT FRAMEWORK (verbatim — reason this way, "
            "especially about your own confidence)",
            cm.extract_bayescraft(cm.GLOBAL_CLAUDE_MD),
        ),
        cm.section("3. ART DIRECTION (ARTSTYLE_DIRECTION.md, verbatim)",
                   _file(REPO / "ARTSTYLE_DIRECTION.md")),
        cm.section(
            "4. THE VISUAL CONSTITUTION "
            "(TESTATOR_DESIGN_LANGUAGE.md, verbatim — the four authorship "
            "lanes; the walls-breathe and handcraft laws bind this pass)",
            _file(REPO / "TESTATOR_DESIGN_LANGUAGE.md")),
        cm.section("5. THE RATIFIED SPEC (DESIGN_7_25.md, verbatim)",
                   _file(REPO / "DESIGN_7_25.md")),
        cm.section(
            "6. THE HUB AS BUILT (game/perihelion/hub.py, verbatim — the "
            "24-chamber construction AND the HUB_LIGHT_PLAN this pass "
            "reshapes around)",
            _file(REPO / "game/perihelion/hub.py")),
        cm.section("7. RENDERER FACTS (excerpts)", _excerpt_render()),
        ASK.strip(),
    ]
    return "\n\n".join(parts)


def build_input(text: str) -> list:
    content: list[dict] = [{"type": "input_text", "text": text}]
    for path, caption in IMAGES:
        if not path.exists():
            raise FileNotFoundError(path)
        b64 = base64.b64encode(path.read_bytes()).decode()
        content.append({"type": "input_text", "text": f"[IMAGE] {caption}"})
        content.append({"type": "input_image",
                        "image_url": f"data:image/png;base64,{b64}"})
    return [{"role": "user", "content": content}]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--model", default=cm.DEFAULT_MODEL)
    ap.add_argument("--effort", default="high")
    ap.add_argument("--max-tokens", type=int, default=cm.DEFAULT_MAX_TOKENS)
    ap.add_argument("--out-root",
                    default=str(REPO / "out" / "consult" / "marrow_visual"))
    args = ap.parse_args()

    api_key = load_api_key()
    if not args.dry_run and not api_key:
        print("FATAL: no OpenRouter key; use --dry-run.", file=sys.stderr)
        return 2

    text = build_text()
    full_input = build_input(text)

    out_root = Path(args.out_root)
    out_root.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = out_root / stamp
    out_dir.mkdir(parents=True, exist_ok=False)
    (out_dir / "prompt.txt").write_text(text)
    (out_dir / "images.json").write_text(json.dumps(
        [{"path": str(p), "caption": c} for p, c in IMAGES], indent=2))

    n_img = len(IMAGES)
    print(f"Wrote {out_dir / 'prompt.txt'}")
    print(f"Text: {len(text):,} chars (~{cm.tokenish_size(text):,} tokens); "
          f"{n_img} images attached")

    if args.dry_run:
        print("--dry-run: no API call made.")
        return 0

    print(f"Calling OpenRouter Responses: model={args.model} "
          f"effort={args.effort}", file=sys.stderr)
    return cm.stream_consult_responses(
        prompt=full_input,
        api_key=api_key,
        model=args.model,
        effort=args.effort,
        max_tokens=args.max_tokens,
        connect_timeout_s=30.0,
        out_dir=out_dir,
        provider_prefs={"order": ["openai"], "allow_fallbacks": False},
    )


if __name__ == "__main__":
    raise SystemExit(main())
