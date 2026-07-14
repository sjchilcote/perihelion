"""Full validation battery over the album-build tracks — the gate-1 evidence.

Per track, ON FINAL AUDIO: Gordon-persona craft panel anchored to the SAME
original track's blocks (order-swapped), spec panel, artifacts probe,
melodia voiced (already computed), census lanes vs the original's own
blocks. Writes analysis/album_battery.json + a table.

    uv run python tools/musicgen/album_battery.py
"""
from __future__ import annotations

import json
import statistics
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import anchored_critic as ac                      # noqa: E402
from album_build import CURVES                    # noqa: E402

S = ac.SCRATCH
BUILD = S / "album_build"

TRACK_BLOCKS = {
    1: "01_rejoice__for_we_were_once_blessed__chant_of_remembrance",
    2: "02_fleshgrinder", 3: "03_trash_planet_mining_rig",
    4: "04_not_a_heart__but_an_engine", 5: "05_styx_floods_with_souls",
    7: "07_i_swear_to_protect__chant_of_trust", 8: "08_populist",
    10: "10_on_the_edge_of_my_ability__chant_of_focus",
}


def main():
    work = Path(tempfile.mkdtemp(prefix="battery_", dir=str(S)))
    fx = json.loads((Path(__file__).parent /
                     "analysis/critic_fixtures.json").read_text())
    assert fx.get("pass"), "critic fixtures not passed — battery void"
    melodia = json.loads((Path(__file__).parent /
                          "analysis/album_battery_melodia.json").read_text()) \
        if (Path(__file__).parent /
            "analysis/album_battery_melodia.json").exists() else \
        json.loads((Path(__file__).parent /
                    "analysis/album_build_melodia.json").read_text())

    out = {}
    for tid, cfg in sorted(CURVES.items()):
        name = cfg["name"]
        wav = BUILD / f"{name}.wav"
        stem = TRACK_BLOCKS[tid]
        anchors = sorted(ac.BLOCKS.glob(f"{stem}_blk*.wav"))[:3]
        crafts = []
        for k, anchor in enumerate(anchors[:2]):
            for swap in (False, True):
                try:
                    r = ac.anchored_once(wav, anchor, work, swap=swap)
                    crafts.append(r)
                except Exception as e:  # noqa: BLE001
                    print(f"{name} craft call failed: {e}", file=sys.stderr)
        ps = [r.get("p_ship_first_draft", 0.0) for r in crafts]
        origs = [r.get("originality", 0.0) for r in crafts]
        spec = ac.run_spec_panel(wav, 2, work)
        arts = []
        for _ in range(2):
            try:
                arts.append(ac._call(
                    [{"type": "text", "text": ac.ARTIFACTS},
                     ac._snd(ac._mp3(wav, work, max_s=60.0))],
                    "musicgen.album_battery.artifacts"))
            except Exception as e:  # noqa: BLE001
                print(f"{name} artifacts failed: {e}", file=sys.stderr)
        broken = [a.get("broken_voices") for a in arts
                  if a.get("broken_voices")]
        out[name] = dict(
            craft_p_median=statistics.median(ps) if ps else None,
            originality_median=statistics.median(origs) if origs else None,
            verdicts=[r.get("better_or_worse") for r in crafts],
            spec=dict(church=spec.get("church_forms_audible"),
                      machines=spec.get("machine_performers"),
                      sincere=spec.get("sincere_not_ironic"),
                      pastiche=spec.get("template_pastiche")),
            artifacts_broken_voices=broken or None,
            finished_music=[a.get("sounds_like_finished_music")
                            for a in arts],
            biggest_fixes=[r.get("biggest_fix") for r in crafts][:2],
            melodia_voiced=melodia.get(name),
        )
        print(f"{name:18s} craft {out[name]['craft_p_median']} "
              f"orig {out[name]['originality_median']} "
              f"spec {out[name]['spec']} "
              f"finished {out[name]['finished_music']}")
    (Path(__file__).parent / "analysis/album_battery.json").write_text(
        json.dumps(out, indent=1))
    cps = [v["craft_p_median"] for v in out.values()
           if v["craft_p_median"] is not None]
    print(f"\ncraft medians: {sorted(cps)}")
    print(f"album-wide craft median: {statistics.median(cps):.2f}")


if __name__ == "__main__":
    main()
