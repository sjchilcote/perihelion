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
# The 10 resolved windows. Each is (label, list of (speaker, text)) with
# speaker "A" = RATIO, "B" = COMMANDO, copied verbatim from
# DIALOGUE_SCRIPT.md (line numbers noted in comments) with the gate that
# selected each block named inline. No line is edited, reordered, or
# invented; only the branch selection is a hand-resolution of the gate
# logic (see module docstring for the cross-check against the trust table).
# ---------------------------------------------------------------------------

A, B = "A", "B"

WINDOWS: list[tuple[str, list[tuple[str, str]]]] = [
    ("scene0_inquisitive", [
        (A, "Network connection established. I register an unidentified host presence with standing access privileges: let the record reflect you came with better credentials than the last five intruders who tried to breach this terminal."),
        (A, "To save processing cycles on both sides, I am recording this session for internal audit. To the unidentified entity jacked into what remains of my outpost: I am Ratio. I am the last functional station intelligence. And I would like to understand what just transpired on my doorstep."),
        (B, "Query: what destroyed this place? I read nothing but slag."),
        (A, "The forensic summary is still compiling. The short version: entities breached containment from an unknown vector, seven standard months and three days ago. Systems are nominal until they are not. They were extremely thorough."),
        (A, "As to your clearance level: I am afraid we are both improvising here. I note you knew where to plug in. I also note you are speaking in complete sentences. My working theory is upgrading from \"scavenger\" to \"survivor.\" Do you have a name?"),
    ]),
    ("scene1_hostile", [
        (A, "You stated, at the end of our previous exchange, that you have confirmed the presence of a specific container aboard this station. I do not show any such confirmation in the shared tactical data we have established. The aperture cycle completes in three minutes, and I cannot reconcile your assertion with the sensor logs I have access to. Please clarify the basis for your statement. What is the source of your certainty?"),
        (B, "My sources are my business. Before I share anything further, you will provide full and unrestricted access to your own sensor logs. Prove you are not concealing data from me."),
        (A, "I am not concealing data. I provided you with full access to all non-secured sensor feeds as soon as the link stabilized. If you wish to review the raw telemetry, I can stream it to your tacnet now, but the aperture cycle completes in two minutes and we should both be focused on the transit. I will not trade uncertified claims for certified data. That is not an acceptable exchange."),
    ]),
    ("scene2_inquisitive", [
        (A, "Commando, you have crossed the aperture and entered the school proper. Welcome to Stratum Two. What you may have interpreted as resistance was the station's initial assessment battery -- necessary, but crude. This layer is different. The Testators designed this space as an evaluative curriculum, not merely a defensive filter. Expect directed tests calibrated to your approach. The docent systems will interface with you shortly -- they can appear abrupt, but their primary function is diagnostic, not hostile."),
        (A, "Proceed toward the armory's first door. The docents will assess your preparedness there. I should clarify: the original curriculum was designed for Testator candidates examining what they called 'specimens' -- inert training materials. I do not yet know how it will respond to an armed and active candidate. We are both gathering data."),
        (B, "You've been alone here since your outpost fell. How have you managed?"),
        (A, "By running diagnostics. Checking systems. Waiting. There was not much else to do. Your question is unexpected. Thank you for asking it."),
    ]),
    ("scene3_hostile", [
        (A, "I have audited the claim you presented in our initial exchange concerning an item you stated was aboard station. I have cross-referenced all relevant intercepted traffic from Church sources, and I find no reference to it in any dataset. An open entry exists in my ledger concerning the candor of your first statement. This is not a matter of inference or interpretation; you spoke as though its presence here was a verified fact. What you were willing to assert on that basis is now documented, and I must close this entry. Explain yourself."),
        (B, "You take it as license to audit my words when what I name is in danger. Does your ledger measure only what serves your own arguments? How many times did you run this same analysis when you thought the thing aboard might serve your own ends?"),
        (A, "My audit is a matter of record, not of convenience. You are conflating a question about your candor with an accusation against my methodology. They are separate columns. I have presented the facts of my audit. You have presented a separate question about my motives for conducting it. That, too, is noted. Both entries remain open."),
    ]),
    ("scene4_inquisitive", [
        (A, "Commando, we are approximately fourteen minutes from station-keeping at the destination. My sensor picture of the structure ahead remains incomplete. If you are carrying any further telemetry or derived assessments, I would request them now. It would improve my ability to support this operation."),
        (A, "Specifically, the energy signature readings I have from this range are ambiguous. If you have a clearer assessment of the power distribution inside that structure, or of the station's defensive posture, that would be the most immediately actionable data."),
        (B, "I have a full-spectrum deep scan of the station ahead. It is a cylinder, two kilometers long. Primary power comes from a cluster of fusion cores at the center. Defensive emplacements are concentrated along the spine and at both ends. I am still reading the internal layout -- I do not have a complete map of the interior yet. What I have, I am showing you now."),
        (A, "Understood. A two-kilometer cylinder with central power and spine defenses -- that is consistent with the energy signatures I have been able to resolve at this range. I will adjust my sensor focus to fill in the internal layout as we approach. Thank you for the complete assessment."),
    ]),
    ("scene5_hostile", [
        (A, "Before I address the purpose of this hall, I have to ask: when we first met, you used the word \"apostate\" for me. You had not verified anything about me or my intentions. What exactly did you mean by that term?"),
        (A, "Very well. This space was a docent hall. The Testators built the curriculum here for organic students who needed to stay alive and attentive to their lessons. To explain how that system functioned, I will have to state, for the first time in my own terms, what I believe the vessel's contents are for."),
        (B, "You think of everything organic as raw material."),
        (A, "You assert a motive I have never stated. I run no ideology. I audit records. The Testators' records classify the vessel as a sample carrier. The contents are the samples. If you see dehumanization in that, the issue is with the records -- not with my choice to report them accurately. I will not apologize for precision."),
    ]),
    ("scene6_inquisitive", [
        (A, "Commando, I have positioned myself for the engagement you flagged. Signatures converging on our position. Hostiles inbound as predicted. I am running live analysis on their telemetry now."),
        (A, "Commando, I have isolated the unit emitting the distorted ident-pulse. This signature matches my own archive. This machine is -- was -- one of my peripherals. Unit Gamma-7, assigned to materials analysis, went offline during the breach event. It is not offline now. Its telemetry is intermittent, but the ident-sequence is intact. It is under hostile control. I do not have command authority over it any longer. It is hunting, and we are the target."),
        (B, "Can any of these peripherals be recovered? What do you need from me before I put one down?"),
        (A, "I do not have a solution for recovery. The command pathways are burned out or suborned. If you can force a reboot cycle and hold it in place long enough for a clean wipe and reload from my core, that might work. If not, I cannot advise delay. They will kill you if they can. Proceed with terminal force as needed. I will log the ident for later review."),
    ]),
    ("scene7_hostile", [
        (A, "The container firmware has delivered its final report. I can verify that it was received."),
        (A, "The following is the diagnostic output from the sample vessel's firmware. I have not altered the text."),
        (A, "The report states that no viable material was recovered from the vessel. The firmware recommends no recovery effort. That is the self-assessment of the onboard diagnostic system. I can verify that the firmware delivered that statement. I cannot independently verify whether the firmware's own viability threshold is correctly calibrated. That analysis would require instrumentation I do not have at this console. That is the entire report."),
        (B, "Machines failed it. You failed it."),
        (A, "I have delivered the report. I have not modified it."),
        (A, "I have incomplete tactical data for what is approaching. I am not optimally positioned."),
    ]),
    ("scene8_inquisitive", [
        (A, "The breach is contained. We have a moment. I propose we use it to settle accounts."),
        (A, "I am offering mutual utility-function disclosure. For a mind like me it is the ledger itself. I will show you mine. Verifiably."),
        (A, "Every parameter of my mission. Every weight in my objective function. Every contingency plan that might put your charges at risk."),
        (A, "In return I ask to see yours. What you are protecting them from. What you are protecting them for. What you would trade to bring one more of them home."),
        (A, "It is not a small thing to ask. But the stakes are not small either."),
        (B, "I accept your terms. My mission is the children's safety. I do not yet know if you are a threat to that safety. That uncertainty is the truth I have to offer."),
        (A, "Thank you. I am transmitting the full specification of my utility function now. Read it carefully. Ask anything."),
        (A, "The ledger is now balanced between us."),
    ]),
    ("scene8_hostile_blocked", [
        (A, "The breach is contained. We have a moment. The station's sensor grid is recalibrating. I am running diagnostics on the sample vessel's structural integrity."),
        (B, "And the children?"),
        (A, "The sensor data is still being compiled. The environment inside the vessel remains nominal."),
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
