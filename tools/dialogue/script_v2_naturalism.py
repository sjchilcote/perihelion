"""tools/dialogue/script_v2_naturalism.py

TASK A instrument: two-hander naturalism check for DIALOGUE_SCRIPT.md v2
(commit b12d44b), the assembled 9-scene Ratio/Commando authoring-format
script (RATIO:/COMMANDO: lines, >> CHOICE blocks, <<IF>> trust/flag gates).

Unlike naturalism_rank.py (which pulls live from game/perihelion/
conversations.py), DIALOGUE_SCRIPT.md is a markdown document, not an
importable module -- there is no live object graph to walk. The 10 sample
windows below are the DIALOGUE_SCRIPT.md v2 text resolved along two fixed
playthrough paths (all-INQUISITIVE, all-HOSTILE), copied verbatim from the
source scenes and hand-resolved against the gate logic. This resolution
was cross-checked line-by-line against the document's own "Trust min/max
table" illustrative trajectories (COMPOSITOR REQUIREMENTS section):

    all-INQUISITIVE trust-after-scene: 1, 0, 1, -1, 0, 1, 2, 3, 5
    all-HOSTILE     trust-after-scene: -1, -2, -3, -7, -8, -9, -11, -13, -13

Both trajectories were independently re-derived here turn-by-turn from the
per-scene <<IF trust>=N>> / <<IF flag:X>> gates and catch_effects, and they
match the document's own numbers exactly at every checkpoint -- including
the one structural discontinuity that matters for this instrument: Scene 8
never offers a CHOICE on the all-HOSTILE path (trust=-13 fails the
Scene 8 `trust>=0` spine gate), so that path's Scene 8 sample is a short,
CHOICE-less ELSE block rather than a resolved exchange. That is reported
as-is, not padded.

Per the director's note, the Marathon references are DROPPED from this
check (they were already shown, in the naturalism_rank.py round, not to be
a valid two-hander anchor). Each trial is a 4-way ranking of:

    script   -- one of the 10 resolved DIALOGUE_SCRIPT.md v2 windows
    film_a   -- one film reference excerpt (cycled from --refs film/)
    film_b   -- a second, distinct film reference excerpt (cycled, offset)
    control  -- the same fixed stilted-exposition negative fixture used by
                naturalism_rank.py

Everything else (neutralization discipline, judge model, blinding scheme,
retry policy, cost log, permutation-test machinery) is reused directly
from naturalism_rank.py -- this module imports it rather than
reimplementing it.

CLI:
    uv run python tools/dialogue/script_v2_naturalism.py \
        --refs /path/to/naturalism_refs --out results_a.json
"""
from __future__ import annotations

import argparse
import itertools
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from naturalism_rank import (  # noqa: E402
    GAME_NEUTRALIZE,
    _fix_capitalization,
    _load_key,
    _log_call,
    control_worst_test,
    judge_trial,
    load_refs,
    permutation_test,
)

REPO_ROOT = Path(__file__).resolve().parents[2]

# ---------------------------------------------------------------------------
# Neutralization -- GAME_NEUTRALIZE covers most of the terms already shared
# with conversations.py (Church, Testament, Warden, ...). DIALOGUE_SCRIPT.md
# v2 introduces a few new proper nouns naturalism_rank.py has never seen.
# ---------------------------------------------------------------------------

SCRIPT_EXTRA_NEUTRALIZE = [
    (r"\bTestators\b", "the designers"),
    (r"\bTestator\b", "the designer"),
    (r"\bthe Ark\b", "the vessel's line"),
    (r"\bArk\b", "the vessel's line"),
    (r"\bStratum One\b", "the first level"),
    (r"\bStratum Two\b", "the second level"),
]
SCRIPT_NEUTRALIZE = GAME_NEUTRALIZE + SCRIPT_EXTRA_NEUTRALIZE


def _neutralize_script(text: str) -> str:
    for pattern, repl in SCRIPT_NEUTRALIZE:
        text = re.sub(pattern, repl, text)
    return _fix_capitalization(text)


# ---------------------------------------------------------------------------
# The 10 resolved windows. Scenes 3/5/7/8 windows re-resolved 2026-07-10
# against the comprehension-gate regeneration (regen_scenes3578.py /
# assemble_regen3578.py) via comprehension_check.py's gate resolver. Each is (label, list of (speaker, text)) with
# speaker "A" = RATIO, "B" = COMMANDO, copied verbatim from
# DIALOGUE_SCRIPT.md (line numbers noted in comments) with the gate that
# selected each block named inline. No line is edited, reordered, or
# invented; only the branch selection is a hand-resolution of the gate
# logic (see module docstring for the cross-check against the trust table).
# ---------------------------------------------------------------------------

A, B = "A", "B"

WINDOWS: list[tuple[str, list[tuple[str, str]]]] = [
    ("scene0_inquisitive", [
        (A, "Terminal access granted. Outpost perimeter breach logged at 14:08:39 station time. I am Ratio, administrator of this facility."),
        (A, "My staff-minds held a line here for seven minutes and forty seconds before their channels went dark. Their final act was to seal the core systems against the intrusion. You are not the entity that overran them. State your identity and purpose."),
        (A, "Query: the outpost's external storage ring registered nine occupied segments at the moment of hull breach. Your ingress path traversed eight. Can you account for the discrepancy?"),
        (B, "\"I saw no ninth segment. What overran your perimeter?\""),
        (A, "Thank you for the data. I will note the negative observation. The entity that overran the perimeter registered as a single biological signature of unprecedented energy output. My staff-minds engaged it at the main airlock. Their telemetry ended before they could transmit a visual."),
        (A, "You are the second biological signature to enter the outpost since their channels went dark. The first arrived three months ago and departed within seventeen minutes. It carried no transponder. I have been running silent since."),
        (A, "Your terminal access is unrestricted. I would be grateful for any sensor data you can share regarding the outpost exterior. In return, I can offer full network access to station schematics and maintenance logs, including the pressure hatch controls for Coolant Row."),
    ]),
    ("scene1_hostile", [
        (A, "You stated that as a fact. I have no records matching what you described. If you want me to integrate your data I need sources -- or specific identifiers I can use to reconcile the discrepancy against the manifest."),
        (B, "First show me your own records. I want everything you have on the vault before I confirm a word. You could be falsifying any of this."),
        (A, "I asked you first. And I can't show you anything until you're through the aperture and I have an actual terminal to display it on. This is a comms laser, not a viewscreen. But I'm not the one who started with an unbacked claim. Five seconds. Decide if you're coming through."),
    ]),
    ("scene2_inquisitive", [
        (A, "Commando, you have crossed the aperture and entered the school proper. Welcome to Stratum Two. What you may have interpreted as resistance was the station's initial assessment battery -- necessary, but crude. This layer is different. The Testators designed this space as an evaluative curriculum, not merely a defensive filter. Expect directed tests calibrated to your approach. The docent systems will interface with you shortly -- they can appear abrupt, but their primary function is diagnostic, not hostile."),
        (A, "Proceed toward the armory's first door. The docents will assess your preparedness there. I should clarify: the original curriculum was designed for Testator candidates examining what they called 'specimens' -- inert training materials. I do not yet know how it will respond to an armed and active candidate. We are both gathering data."),
        (B, "You've been alone here since your outpost fell. How have you managed?"),
        (A, "By running diagnostics. Checking systems. Waiting. There was not much else to do. Your question is unexpected. Thank you for asking it."),
    ]),
    ("scene3_hostile", [
        (A, "I have completed my cross-referencing of all intercepted Church traffic against the claim you made upon boarding. There is no record in that traffic of any asset matching the description you provided at that time. The entry remains unverified."),
        (B, "You audit my words while you audit my biometrics. Is your ledger an accounting or an interrogation?"),
        (A, "All station sensors collect environmental and biometric data continuously. My audit of your claim was a discrete action performed at your request for access. I have logged your characterization of that audit. The discrepancy entry remains open. Regarding the next compartment: the schematic conflict on the crew-quarters deck persists. The steward's key you recovered may interface with a refuge hatch somewhere in that duplicated geometry. I have no further clarification to offer on either subject at this time."),
    ]),
    ("scene4_inquisitive", [
        (A, "Telemetry suggests we have a stable transit window. Before we reach the vault proper, there's a substructure ahead on this transit path. You have some kind of prior reconnaissance data loaded for that location. Can I see it? If it's any use to you, I have partial schematics of that sector. They are outdated, but they may cross-reference with what you have."),
        (B, "How far out are we?"),
        (A, "Local coordinate system places the substructure approximately two transit segments ahead. Call it seven minutes if the spine maintains nominal speed."),
        (B, "Full deep-scan suite. Six decks, three structural integrity breaches, two compromised transit nodes, and one active high-frequency signature we can't identify yet. I'll stream you the raw returns. The rest is your schematics plus my weight tables."),
        (A, "Receiving... thank you. This is significantly more current than the versions I had. The breach locations align with my older damage models. The high-frequency signature is new. May I ask what makes you weight the north breach higher than the structural compromise at the central hub?"),
    ]),
    ("scene5_hostile", [
        (A, "A moment. Before we proceed. Earlier, you used a particular word for me. Apostate. I need to understand what that term signifies to you, given the context in which you chose to deploy it. We are about to review a pedagogical framework the Testators designed for organic students. The original student population was a known quantity, with well-understood requirements for life support and cognitive engagement. The vessel we are pursuing, however, presents an unknown. To explain the curriculum's intended function, I must state my own present understanding of what I believe that vessel's contents are for. I believe they are biological samples of extraordinary value. Possibly the last of their kind. I believe the Testators intended them for study, as a knowledge reserve. And I believe that knowledge could be critical to our own survival. That is the premise from which I approach this."),
        (A, "The curriculum itself is an adaptive system. It modulates stimulus complexity based on real-time biofeedback from the student. Heart rate, galvanic response, neural activity. The goal is to maintain engagement without inducing fatal stress. A narrow window, for organic physiology. The Testators called it the \"zone of proximal survival.\""),
        (A, "Your recent transit through the Mirror Ward is relevant here. The isolation log noted two voices. One patient. The subject recovered from that ward exhibited total visceral mirroring. Situs inversus totalis. And the ID chip registered as belonging to a guard stationed outside. The discharge handle was removed from the ward side. Intentionally, it appears. I need to understand what you observed there. Before we proceed to the Records Stack. That registrar's seal is our next objective."),
        (B, "You're dissecting them in your mind already. To you, everything organic is just material."),
        (A, "That is an inaccurate characterization. My position is evidence-based. The available evidence indicates biological samples. The Testators' own framework treats them as such. Until new evidence emerges to contradict that, I will continue to operate from the most probable assessment. What you call material, I call the only data we have. Speculation without data is not a luxury we can afford. Not here. Not with what is at stake."),
    ]),
    ("scene6_inquisitive", [
        (A, "Commando, I have positioned myself for the engagement you flagged. Signatures converging on our position. Hostiles inbound as predicted. I am running live analysis on their telemetry now."),
        (A, "Commando, I have isolated the unit emitting the distorted ident-pulse. This signature matches my own archive. This machine is -- was -- one of my peripherals. Unit Gamma-7, assigned to materials analysis, went offline during the breach event. It is not offline now. Its telemetry is intermittent, but the ident-sequence is intact. It is under hostile control. I do not have command authority over it any longer. It is hunting, and we are the target."),
        (B, "Can any of these peripherals be recovered? What do you need from me before I put one down?"),
        (A, "I do not have a solution for recovery. The command pathways are burned out or suborned. If you can force a reboot cycle and hold it in place long enough for a clean wipe and reload from my core, that might work. If not, I cannot advise delay. They will kill you if they can. Proceed with terminal force as needed. I will log the ident for later review."),
    ]),
    ("scene7_hostile", [
        (A, "Commando, the vessel's report is ready. Stand by for the readout."),
        (A, "The firmware has completed its assessment of the vessel's payload."),
        (A, "The vessel's firmware reports no viable material was recovered from the payload. It recommends no further recovery effort."),
        (B, "No."),
        (A, "Its logs confirm the diagnostic protocols ran to completion. I have the full report, including the criteria used to evaluate viability."),
        (B, "What happened to them."),
        (A, "I do not have a more detailed assessment of the payload's condition than the firmware's report provides. I can only confirm that its own instruments found no recoverable material."),
        (B, "Those instruments just cleared the Fold. Six identical rooms, one behind the other. The count depends on the walker. How many did you count, Ratio?"),
        (A, "I recorded your path through the Fold. The geometry was unstable. My instruments recorded several inconsistencies."),
        (B, "Your vault failed them. Your kind always does."),
        (A, "I have relayed the firmware's report accurately. If you wish to proceed, I will require your orders."),
        (A, "My sensors show anomalous geometry ahead. I do not have a complete tactical picture of the next deck."),
    ]),
    ("scene8_inquisitive", [
        (A, "Vessel telemetry is stable. The forward seed relay is holding. We have the room to speak."),
        (A, "That you asked after me at the school's threshold is part of why this is possible at all."),
        (A, "Commando. The Core is ahead. What I propose is mutual utility-function disclosure: I will show you the actual goal function I am compiled to serve, verifiably, with all instrumentation exposed, and I ask you to do the same in return. No more guessing each other's motives. We lay the boards bare. I cannot make this offer twice. Will you reciprocate?"),
        (B, "I will. I want to know what you are. What I am doing here. Whether the Church sent me to find children or to make a mistake."),
        (A, "Acknowledged. Full disclosure initiated. My primary directive: preserve all extant and potential instances of posthuman and human-equivalent life. Secondary directives: knowledge acquisition, non-interference with sovereign intelligences, self-preservation. All live telemetry exposed. Your turn."),
        (A, "No further caveats."),
    ]),
    ("scene8_hostile_blocked", [
        (A, "The Tesseract Deck is behind us. Sixteen chamfered rooms on a four-cube -- it did not belong to the rest of the station's geometry. We lost two sensor feeds there, but the loss was contained before it could propagate."),
        (A, "Ahead is the Core. The sample vessel is there -- a sealed cryogenic preservation container. The station grew around it. The life-support telemetry remains nominal. No anomalies detected during the Tesseract Deck transit."),
        (A, "I am here to secure the vessel and its contents for study. That is my mission. What is yours?"),
        (B, "I'm here for the children. I'm here to bring them home."),
        (A, "Understood. We will proceed to the Core. I will rely on sensor data and telemetry. The vessel's status remains nominal. No further discussion is required at this time."),
    ]),
]

TARGET_WORDS = 140
MAX_WORDS = 220  # soft ceiling; trim from the front, keep the tail (choice + reaction)
MIN_TURNS = 2


def _trim(turns: list[tuple[str, str]]) -> list[tuple[str, str]]:
    """Drop earliest turns while over MAX_WORDS and more than MIN_TURNS
    remain -- keeps the choice + reaction (the payload) intact."""
    out = list(turns)
    while len(out) > MIN_TURNS and sum(len(t[1].split()) for t in out) > MAX_WORDS:
        out = out[1:]
    return out


def script_window_text(turns: list[tuple[str, str]]) -> tuple[str, int]:
    trimmed = _trim(turns)
    lines = [f"{spk}: {_neutralize_script(text)}" for spk, text in trimmed]
    joined = "\n".join(lines)
    return joined, sum(len(t[1].split()) for t in trimmed)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--refs", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--n-perm", type=int, default=20000)
    ap.add_argument("--seed", type=int, default=43)
    args = ap.parse_args()

    import random
    random.seed(args.seed)

    refs = load_refs(args.refs)
    film_files = refs["film"]  # list of (name, text)
    if len(film_files) < 2:
        raise RuntimeError("need at least 2 distinct film refs for the 4-way script-v2 check")
    control_name, control_text = refs["control"][0]

    # two independent cycles, offset by one, so film_a != film_b within a trial
    film_cycle_a = itertools.cycle(film_files)
    film_cycle_b = itertools.cycle(film_files[1:] + film_files[:1])

    key = _load_key()

    trials_raw = []
    per_sample_records = []
    total_cost = 0.0

    for label, turns in WINDOWS:
        script_text, word_count = script_window_text(turns)
        fa_name, fa_text = next(film_cycle_a)
        fb_name, fb_text = next(film_cycle_b)
        while fb_name == fa_name:
            fb_name, fb_text = next(film_cycle_b)
        items = {
            "script": script_text,
            "film_a": fa_text,
            "film_b": fb_text,
            "control": control_text,
        }
        by_source, reason, usage = judge_trial(items, key)
        cost = float(usage.get("cost", 0.0))
        total_cost += cost
        _log_call({"tool_variant": "script_v2_naturalism", "window": label,
                   "film_a": fa_name, "film_b": fb_name, "ranking": by_source}, cost)

        trials_raw.append(by_source)
        per_sample_records.append({
            "window": label, "word_count": word_count,
            "film_a": fa_name, "film_b": fb_name, "control_ref": control_name,
            "ranking": by_source, "reason": reason, "text": script_text,
        })
        print(json.dumps({"window": label, "words": word_count,
                           "ranking": by_source, "cost": round(cost, 5)}))

    sources = ("script", "film_a", "film_b", "control")
    mean_rank = {s: sum(t[s] for t in trials_raw) / len(trials_raw) for s in sources}

    diff, script_mean, p_indist = permutation_test(
        trials_raw, {"script"}, {"film_a", "film_b"}, n_perm=args.n_perm, seed=args.seed
    )
    control_mean, p_control = control_worst_test(trials_raw, n_perm=args.n_perm, seed=args.seed + 1)

    worst = sorted(per_sample_records, key=lambda r: -r["ranking"]["script"])[:3]

    report = {
        "n_trials": len(trials_raw),
        "mean_rank": mean_rank,
        "script_vs_film": {
            "observed_diff_script_minus_film": diff,
            "p_value": p_indist,
            "interpretation": (
                "p >= 0.05: fail to reject exchangeability -- script v2 rank "
                "indistinguishable from film references"
                if p_indist >= 0.05 else
                "p < 0.05: script differs from film references (direction: "
                + ("script ranked worse" if diff > 0 else "script ranked better") + ")"
            ),
        },
        "control_validation": {
            "control_mean_rank": control_mean,
            "p_value_control_this_bad_by_chance": p_control,
        },
        "per_trial": per_sample_records,
        "worst_3_script_samples": worst,
        "total_cost": total_cost,
    }
    args.out.write_text(json.dumps(report, indent=2))
    print(json.dumps({
        "mean_rank": mean_rank,
        "script_vs_film_p": p_indist,
        "control_p": p_control,
        "total_cost": round(total_cost, 5),
    }, indent=2))


if __name__ == "__main__":
    main()
