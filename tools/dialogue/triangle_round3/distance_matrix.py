"""tools/dialogue/triangle_round3/distance_matrix.py

Round 3 fix #3 (decorrelate the pair): measure pairwise distance between
every candidate for a scene, including the truth, using both word-level
Jaccard distance and difflib.SequenceMatcher distance (1 - ratio). Round 2
failed its own bar here -- two of its four candidates per trial were close
enough to read as "the same template reskinned," which handed judges the
truth by elimination regardless of how good the truth-matching was.

Bar: at least 4 candidates per scene with pairwise gen-vs-gen distance
approaching gen-vs-truth distance (i.e. no candidate pair much closer to
each other than either is to the truth).

Operates on the LINTED candidates (post format_lint.py) since that is what
would actually be shown to a blind judge -- format tells are deliberately
removed before this measurement so what's left is content/register/word-
choice distance, not markup-fingerprint distance.

CLI:
    uv run python tools/dialogue/triangle_round3/distance_matrix.py
"""
from __future__ import annotations

import difflib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
CAND_DIR = HERE / "candidates"
SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad"
)
TRUTH = {
    "scene0": (SCRATCH / "truth_scene0.txt").read_text().strip(),
    "t1": (SCRATCH / "truth_terminal1.txt").read_text().strip(),
}


def _words(text: str) -> list[str]:
    return re.findall(r"[a-z0-9']+", text.lower())


def jaccard_distance(a: str, b: str) -> float:
    wa, wb = set(_words(a)), set(_words(b))
    if not wa and not wb:
        return 0.0
    union = wa | wb
    inter = wa & wb
    return 1.0 - len(inter) / len(union)


def difflib_distance(a: str, b: str) -> float:
    ratio = difflib.SequenceMatcher(None, a, b).ratio()
    return 1.0 - ratio


def build_matrix(scene: str) -> dict:
    entries = {"truth": TRUTH[scene]}
    for p in sorted(CAND_DIR.glob(f"{scene}_*.linted.txt")):
        label = p.stem.replace(".linted", "")
        entries[label] = p.read_text()

    names = list(entries.keys())
    jac = {}
    dif = {}
    for i, a in enumerate(names):
        for b in names[i + 1 :]:
            jac[f"{a}|{b}"] = round(jaccard_distance(entries[a], entries[b]), 4)
            dif[f"{a}|{b}"] = round(difflib_distance(entries[a], entries[b]), 4)
    return {"names": names, "jaccard": jac, "difflib": dif}


def render_table(scene: str, matrix: dict, metric: str) -> str:
    names = matrix["names"]
    d = matrix[metric]

    def get(a, b):
        if a == b:
            return 0.0
        key = f"{a}|{b}" if f"{a}|{b}" in d else f"{b}|{a}"
        return d[key]

    short = {n: (n if n == "truth" else n.split("_", 1)[1]) for n in names}
    header = "| |" + "|".join(short[n] for n in names) + "|"
    sep = "|---|" + "|".join("---" for _ in names) + "|"
    rows = [header, sep]
    for a in names:
        row = f"| **{short[a]}** |" + "|".join(f"{get(a, b):.2f}" for b in names) + "|"
        rows.append(row)
    return "\n".join(rows)


def check_decorrelation_bar(scene: str, matrix: dict, metric: str = "jaccard") -> list[str]:
    """Bar: for each candidate C, mean(gen-vs-gen distance to other gens)
    should not be dramatically smaller than mean(gen-vs-truth distance) --
    flag pairs where two gens are markedly closer to each other than either
    is to truth (candidate for "reads as the same template reskinned")."""
    names = matrix["names"]
    gens = [n for n in names if n != "truth"]
    d = matrix[metric]

    def get(a, b):
        if a == b:
            return 0.0
        key = f"{a}|{b}" if f"{a}|{b}" in d else f"{b}|{a}"
        return d[key]

    findings = []
    truth_dists = [get(g, "truth") for g in gens]
    mean_truth_dist = sum(truth_dists) / len(truth_dists)
    for i, a in enumerate(gens):
        for b in gens[i + 1 :]:
            gg = get(a, b)
            if gg < 0.6 * mean_truth_dist:
                findings.append(
                    f"{a} vs {b}: gen-vs-gen distance {gg:.2f} is < 60% of "
                    f"mean gen-vs-truth distance {mean_truth_dist:.2f} -- "
                    "these two read as near-clones."
                )
    if not findings:
        findings.append(
            f"PASS: no gen pair falls below 60% of mean gen-vs-truth "
            f"distance ({mean_truth_dist:.2f}) on {metric}."
        )
    return findings


def main() -> None:
    out = {}
    for scene in ("scene0", "t1"):
        matrix = build_matrix(scene)
        out[scene] = matrix
        print(f"\n=== {scene} -- Jaccard distance (word-level) ===")
        print(render_table(scene, matrix, "jaccard"))
        print(f"\n=== {scene} -- difflib distance (1 - SequenceMatcher ratio) ===")
        print(render_table(scene, matrix, "difflib"))
        print(f"\n--- decorrelation bar check ({scene}, jaccard) ---")
        for f in check_decorrelation_bar(scene, matrix, "jaccard"):
            print(f"  {f}")
    (HERE / "distance_matrix.json").write_text(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
