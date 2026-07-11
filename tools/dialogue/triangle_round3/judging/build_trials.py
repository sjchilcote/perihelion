#!/usr/bin/env python3
"""Round-3 blind triangle-test trial builder.

Programmatically generates the schedule (all 6 unordered candidate pairs per
scene, truth position shuffled per trial, seed = trial index) and assembles
each judge prompt from the truth + linted candidate files. Validates every
assembled prompt (exactly one truth, three texts total, no label leakage)
before writing it out. This directly addresses round 2's two administration
mistakes: schedule drift and a truth-less trial.
"""
import itertools
import json
import random
from pathlib import Path

ROOT = Path("/home/login/PycharmProjects/noneuclideantopdownshooter")
CAND_DIR = ROOT / "tools/dialogue/triangle_round3/candidates"
SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad"
)
OUT_DIR = ROOT / "tools/dialogue/triangle_round3/judging"
PROMPTS_DIR = OUT_DIR / "prompts"
PROMPTS_DIR.mkdir(parents=True, exist_ok=True)

TEMPLATE_HEADER = """Three excerpts follow from the same branching video-game dialogue script
(terminal conversation format; bracketed lines are the player character,
unbracketed lines are the station AI, {CURLY} lines are system messages).
Two of the three were written by one author; one was written by a different
author. Your task:

1. Identify which text (X, Y, or Z) was written by the DIFFERENT author.
2. Confidence, 0-100.
3. One sentence: the single strongest tell that decided you.

Answer entirely from the texts below. Do not use any tools. Reply in exactly
this format:
ODD: <X|Y|Z>
CONFIDENCE: <0-100>
TELL: <one sentence>

"""

SCENES = {
    "scene0": {
        "truth": SCRATCH / "truth_scene0.txt",
        "candidates": ["F1", "F2", "F3", "F4"],
    },
    "t1": {
        "truth": SCRATCH / "truth_terminal1.txt",
        "candidates": ["F1", "F2", "F3", "F4"],
    },
}

LABELS = ["X", "Y", "Z"]


def load(path: Path) -> str:
    return path.read_text().strip()


def validate(trial_id, texts_by_label, truth_text, truth_label):
    """Exactly one truth, three texts total, no label leakage."""
    assert len(texts_by_label) == 3, f"{trial_id}: expected 3 texts, got {len(texts_by_label)}"
    assert set(texts_by_label) == set(LABELS), f"{trial_id}: labels wrong: {texts_by_label.keys()}"
    truth_count = sum(1 for t in texts_by_label.values() if t.strip() == truth_text.strip())
    assert truth_count == 1, f"{trial_id}: expected exactly 1 truth text, found {truth_count}"
    assert texts_by_label[truth_label].strip() == truth_text.strip(), f"{trial_id}: truth_label mismatch"
    # No label leakage: candidate filenames / framing tags must not appear as whole
    # words in the text (word-boundary match; GUID hex strings can coincidentally
    # contain "F2" etc as a substring, so plain substring search is too strict).
    import re
    leak_terms = ["F1", "F2", "F3", "F4", "PERIHELION", "Hermes", "director", "candidate",
                  "round3", "linted", "truth_scene0", "truth_terminal1"]
    for label, text in texts_by_label.items():
        for term in leak_terms:
            pattern = r"\b" + re.escape(term) + r"\b"
            assert not re.search(pattern, text), f"{trial_id}: leak term '{term}' found in text {label}"
    return True


def main():
    trial_index = 0
    schedule = []
    key = {}

    for scene_name, cfg in SCENES.items():
        truth_text = load(cfg["truth"])
        pairs = list(itertools.combinations(cfg["candidates"], 2))
        assert len(pairs) == 6

        for pair in pairs:
            rng = random.Random(trial_index)  # seed = trial index
            truth_pos = rng.randrange(3)  # 0,1,2 -> which of the 3 slots is truth
            gen_texts = [load(CAND_DIR / f"{scene_name}_{c}.linted.txt") for c in pair]

            # Build slot order: truth_pos determines where truth sits; the two
            # gens fill the remaining slots in a rng-shuffled order.
            gen_order = list(pair)
            rng.shuffle(gen_order)  # order in which the two gens fill remaining slots

            slot_contents = [None, None, None]
            slot_sources = [None, None, None]
            slot_contents[truth_pos] = truth_text
            slot_sources[truth_pos] = "TRUTH"
            remaining_slots = [i for i in range(3) if i != truth_pos]
            for slot, cand_name, cand_text in zip(remaining_slots, gen_order,
                                                    [load(CAND_DIR / f"{scene_name}_{c}.linted.txt") for c in gen_order]):
                slot_contents[slot] = cand_text
                slot_sources[slot] = f"{scene_name}_{cand_name}"

            texts_by_label = {LABELS[i]: slot_contents[i] for i in range(3)}
            sources_by_label = {LABELS[i]: slot_sources[i] for i in range(3)}
            truth_label = LABELS[truth_pos]

            trial_id = f"trial{trial_index + 1:02d}_{scene_name}_{pair[0]}v{pair[1]}"
            validate(trial_id, texts_by_label, truth_text, truth_label)

            body = TEMPLATE_HEADER
            for label in LABELS:
                body += f"=== TEXT {label} ===\n{texts_by_label[label]}\n\n"

            prompt_path = PROMPTS_DIR / f"{trial_id}.txt"
            prompt_path.write_text(body)

            schedule.append({
                "trial_id": trial_id,
                "trial_num": trial_index + 1,
                "scene": scene_name,
                "pair": list(pair),
                "truth_label": truth_label,
                "sources_by_label": sources_by_label,
                "prompt_path": str(prompt_path.relative_to(ROOT)),
            })
            key[trial_id] = {
                "truth_label": truth_label,
                "sources_by_label": sources_by_label,
            }
            trial_index += 1

    assert trial_index == 12
    (OUT_DIR / "schedule.json").write_text(json.dumps(schedule, indent=2))
    (OUT_DIR / "key.json").write_text(json.dumps(key, indent=2))
    print(f"Built {trial_index} trials. Schedule + key written to {OUT_DIR}")
    for s in schedule:
        print(f"  {s['trial_id']}: truth={s['truth_label']} pair={s['pair']}")


if __name__ == "__main__":
    main()
