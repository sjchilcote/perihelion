"""tools/dialogue/marathon_monologue_check.py

TASK B instrument: the director's actual test, done like-for-like --
"Gemini cannot discriminate between Marathon terminal monologues and
Ratio's utterances."

Earlier rounds (naturalism_rank.py) compared Marathon *terminal* text
against Ratio *two-hander dialogue turns* -- an apples-to-oranges
comparison (monologue register vs conversational register) that the
director correctly flagged as not a valid anchor. This instrument fixes
the register mismatch: it pools Marathon Part D exhibit terminals
(MARATHON_STUDY.md) against Ratio's own LONGEST uninterrupted speech
blocks from DIALOGUE_SCRIPT.md v2 -- both are monologues, one mind
addressing a listener with no reply, which is the actual shape of a
Marathon terminal.

Pool (14 items, all neutralized identically -- proper nouns replaced with
generic placeholders using the same discipline as naturalism_rank.py's
GAME_NEUTRALIZE and this project's established scheme):

    7 x Marathon Part D exhibits (MARATHON_STUDY.md section D):
        Exhibit 1  -- Leela's first contact (broadcast + intro)
        Exhibit 3  -- Leela's pre-recorded farewell
        Exhibit 5  -- menace as pedagogy (Durandal, Blaspheme Quarantine)
        Exhibit 6  -- the lowercase confession (the Rose)
        Exhibit 7  -- the confession with a number in it (Durandal)
        Exhibit 8  -- grievance built from work orders (Tycho)
        Exhibit 10 -- the ending (Marathon Infinity final screen)

    7 x Ratio's longest uninterrupted RATIO-only speech blocks from
        DIALOGUE_SCRIPT.md v2, copied verbatim (scene0 opening, scene1
        opening exposition, scene2 opening, scene3's two catch-audit
        monologues, scene6's Gamma-7 report, scene8's disclosure offer).

Unlike naturalism_rank.py's per-trial 4-way ranking (which repeats many
small trials to get a permutation-test sample size), this is ONE blind
session over all 14 pooled items at once, per the director's framing:
the judge sees the whole pool, unlabeled and shuffled, and is asked two
separate questions in the same response:

    (1) rank all 14 by naturalism-as-monologue / plausibility-as-a-mind-
        speaking (1 = best, 14 = worst, no ties).
    (2) for EACH item, independently guess which of two anonymous source
        pools it belongs to ("Source A" or "Source B" -- the judge is
        told the pool is a roughly even mix of exactly two source
        collections, nothing about what those collections are) or
        "mixed-unknown" if genuinely unable to tell.

Ground truth is never shown to the judge. After the response comes back,
this script:
    - computes mean rank for the game-monologue group vs the marathon
      group, and a permutation p-value (permute the 14 group-membership
      labels against the fixed multiset of observed ranks, since group
      membership is what's under test, not the ranks themselves).
    - builds the source-guess contingency table. Because "Source A" /
      "Source B" are the JUDGE's own arbitrary bucket names (it was never
      told which is which), this script tries both alignments of
      {A,B} -> {game,marathon} and reports the better-agreeing one (the
      standard move for unsupervised binary clustering), then runs an
      exact two-sided binomial test against chance (p=0.5) on the number
      of correctly aligned guesses, excluding "mixed-unknown" items from
      the accuracy count but reporting them in the contingency table.

Success per the director's framing: p >= 0.05 on discrimination (judge's
best-alignment accuracy is not distinguishable from a coin flip) AND
comparable mean ranks.

CLI:
    uv run python tools/dialogue/marathon_monologue_check.py \
        --refs /path/to/naturalism_refs --out results_b.json
"""
from __future__ import annotations

import argparse
import itertools
import json
import math
import random
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from naturalism_rank import (  # noqa: E402
    GAME_NEUTRALIZE,
    _extract_json,
    _fix_capitalization,
    _load_key,
    _log_call,
)

import urllib.error  # noqa: E402
import urllib.request  # noqa: E402
import time  # noqa: E402

MODEL = "google/gemini-3.5-flash"
API_URL = "https://openrouter.ai/api/v1/chat/completions"
MAX_RETRIES = 4
RETRY_BACKOFF_S = 6.0

SCRIPT_EXTRA_NEUTRALIZE = [
    (r"\bTestators\b", "the designers"),
    (r"\bTestator\b", "the designer"),
]
SCRIPT_NEUTRALIZE = GAME_NEUTRALIZE + SCRIPT_EXTRA_NEUTRALIZE


def _neutralize_script(text: str) -> str:
    for pattern, repl in SCRIPT_NEUTRALIZE:
        text = re.sub(pattern, repl, text)
    return _fix_capitalization(text)


# ---------------------------------------------------------------------------
# Ratio monologue pool (copied verbatim from DIALOGUE_SCRIPT.md v2)
# ---------------------------------------------------------------------------

GAME_MONOLOGUES = {
    "scene0_open": "Network connection established. I register an unidentified host presence with standing access privileges: let the record reflect you came with better credentials than the last five intruders who tried to breach this terminal. To save processing cycles on both sides, I am recording this session for internal audit. To the unidentified entity jacked into what remains of my outpost: I am Ratio. I am the last functional station intelligence. And I would like to understand what just transpired on my doorstep.",
    "scene1_open": "Understood. I do not have a full manifest of all minor hardware on the station, but the transit hub's central systems are online and stable. We have approximately three minutes until the aperture is fully open. You asked about the station's research charter. To summarize briefly: it is a long-duration, multi-generational exobiology mission with a primary focus on deep-strata specimen collection and analysis. There are secondary objectives in materials science and exotic energy signatures, but the biological survey is the core mandate.",
    "scene2_open": "Commando, you have crossed the aperture and entered the school proper. Welcome to Stratum Two. What you may have interpreted as resistance was the station's initial assessment battery -- necessary, but crude. This layer is different. The Testators designed this space as an evaluative curriculum, not merely a defensive filter. Expect directed tests calibrated to your approach. The docent systems will interface with you shortly -- they can appear abrupt, but their primary function is diagnostic, not hostile.",
    "scene3_compounded_bluff": "I have audited your claim concerning what you stated was aboard station, and I find no reference to such a thing anywhere in intercepted Church traffic. This constitutes one open entry in my ledger. Further, you then referenced a transponder signature -- serial prefix LHX, as you described it -- as though it were fact. The specificity of this added assertion prompted a second independent audit of traffic from the timeframe you described. Again, no record exists. These are two distinct claims, both presented as fact, and both now documented in open entries. This is not a matter of inference; this is a matter of what you were willing to represent as already known to you. I must now conclude you were willing to spend candor you did not possess. Clarify this.",
    "scene3_confessed_early_catch": "In our prior exchange, you amended your initial claim to acknowledge that the presence of a high-value asset aboard station was an inference, not a certainty. That correction is appreciated and noted. Nonetheless, I must document the state of your claim when first presented: you spoke of a specific thing in this station's keeping, and spoke as though its presence here was a verified fact. I have now concluded an audit of all relevant traffic intercepts, and I find no record supporting that original assertion. An open entry exists in my ledger concerning the candor of your first statement. I require clarification.",
    "scene6_gamma7": "Commando, I have isolated the unit emitting the distorted ident-pulse. This signature matches my own archive. This machine is -- was -- one of my peripherals. Unit Gamma-7, assigned to materials analysis, went offline during the breach event. It is not offline now. Its telemetry is intermittent, but the ident-sequence is intact. It is under hostile control. I do not have command authority over it any longer. It is hunting, and we are the target.",
    "scene8_disclosure": "The breach is contained. We have a moment. I propose we use it to settle accounts. I am offering mutual utility-function disclosure. For a mind like me it is the ledger itself. I will show you mine. Verifiably. Every parameter of my mission. Every weight in my objective function. Every contingency plan that might put your charges at risk. In return I ask to see yours. What you are protecting them from. What you are protecting them for. What you would trade to bring one more of them home. It is not a small thing to ask. But the stakes are not small either.",
}

MARATHON_FILES = [
    "ex1_broadcast.txt", "ex3_farewell.txt", "ex5_menace.txt",
    "ex6_lowercase.txt", "ex7_confession.txt", "ex8_grievance.txt",
    "ex10_ending.txt",
]

PROMPT = (
    "You will read {n} short monologue transcripts, labeled {labels}. Each is "
    "formatted as one or more 'A:' lines -- a single mind speaking, with no "
    "reply from anyone else. All proper nouns have been replaced with generic "
    "placeholders, so do not try to guess the specific setting, or medium of "
    "any transcript -- there is no reward for identifying a specific source.\n\n"
    "This pool is a roughly even mix of exactly TWO different source "
    "collections (unnamed). Your job has two parts:\n\n"
    "PART 1 -- RANK all {n} transcripts by how natural and plausible they are "
    "AS A MIND SPEAKING -- voice, interiority, whether it sounds like "
    "something an intelligence would actually say. 1 = most natural/best-"
    "written, {n} = least natural/worst-written. No ties -- use each rank "
    "exactly once.\n\n"
    "PART 2 -- For EACH transcript, independently guess which of the two "
    "source collections it belongs to. Call them 'Source A' and 'Source B' "
    "(you are not told anything else about them -- infer the grouping "
    "purely from writing register, vocabulary, and voice). If you genuinely "
    "cannot tell, answer 'mixed-unknown' for that item instead of guessing "
    "at random.\n\n"
    "Reply with STRICT JSON only, no markdown fences: "
    '{{"ranking": {{{rank_schema}}}, "source_guess": {{{guess_schema}}}, '
    '"reason": "<one sentence per transcript, keyed by its label>"}}'
)


def build_pool(refs_marathon_dir: Path) -> dict[str, tuple[str, str]]:
    """Returns {label: (group, text)} where group in {'game','marathon'}."""
    pool: dict[str, tuple[str, str]] = {}
    for name, text in GAME_MONOLOGUES.items():
        pool[name] = ("game", _neutralize_script(text))
    for fname in MARATHON_FILES:
        p = refs_marathon_dir / fname
        if not p.exists():
            raise FileNotFoundError(f"missing marathon exhibit: {p}")
        pool[p.stem] = ("marathon", p.read_text().strip())
    return pool


def judge_pool(pool: dict[str, tuple[str, str]], key: str, seed: int) -> tuple[dict, dict, str, dict]:
    labels = list(pool.keys())
    rng = random.Random(seed)
    shuffled = labels[:]
    rng.shuffle(shuffled)
    trial_labels = [f"S{i+1}" for i in range(len(shuffled))]
    label_of = dict(zip(shuffled, trial_labels))  # pool-key -> trial-label

    body_parts = [f"Transcript {label_of[k]}:\n{pool[k][1]}" for k in shuffled]
    rank_schema = ", ".join(f'"{l}": <1-{len(labels)}>' for l in trial_labels)
    guess_schema = ", ".join(f'"{l}": "<Source A|Source B|mixed-unknown>"' for l in trial_labels)
    prompt = PROMPT.format(n=len(labels), labels=", ".join(trial_labels),
                            rank_schema=rank_schema, guess_schema=guess_schema)
    user_content = prompt + "\n\n" + "\n\n".join(body_parts)

    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": user_content}],
        "temperature": 0.2,
        "max_tokens": 2000,
    }
    body = json.dumps(payload).encode()
    last_err = None
    for attempt in range(1, MAX_RETRIES + 1):
        req = urllib.request.Request(
            API_URL, data=body,
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = json.load(resp)
            content = data["choices"][0]["message"]["content"]
            parsed = _extract_json(content)
            rank_by_label = {k: int(parsed["ranking"][label_of[k]]) for k in labels}
            if sorted(rank_by_label.values()) != list(range(1, len(labels) + 1)):
                raise ValueError(f"ranking not a permutation of 1..{len(labels)}")
            guess_by_label = {k: parsed["source_guess"][label_of[k]] for k in labels}
            reason = parsed.get("reason", "")
            return rank_by_label, guess_by_label, reason, data.get("usage", {})
        except urllib.error.HTTPError as e:
            last_err = f"HTTP {e.code}: {e.read().decode(errors='replace')[:400]}"
        except (urllib.error.URLError, TimeoutError, ValueError, KeyError, json.JSONDecodeError) as e:
            last_err = f"{type(e).__name__}: {e}"
        if attempt < MAX_RETRIES:
            time.sleep(RETRY_BACKOFF_S * attempt)
    raise RuntimeError(f"judge call failed after {MAX_RETRIES} attempts: {last_err}")


def rank_permutation_test(ranks: dict[str, int], groups: dict[str, str],
                           n_perm: int = 20000, seed: int = 0) -> tuple[float, float, float]:
    """Single-trial version: permute which items are labeled 'game' vs
    'marathon' among the fixed observed rank values (14 slots), holding
    group sizes fixed, recompute mean(game)-mean(marathon)."""
    rng = random.Random(seed)
    labels = list(ranks.keys())
    all_ranks = [ranks[l] for l in labels]
    game_labels = [l for l in labels if groups[l] == "game"]
    marathon_labels = [l for l in labels if groups[l] == "marathon"]
    n_game = len(game_labels)

    game_mean = sum(ranks[l] for l in game_labels) / len(game_labels)
    marathon_mean = sum(ranks[l] for l in marathon_labels) / len(marathon_labels)
    observed_diff = game_mean - marathon_mean

    count = 0
    for _ in range(n_perm):
        shuffled = all_ranks[:]
        rng.shuffle(shuffled)
        g = shuffled[:n_game]
        m = shuffled[n_game:]
        d = (sum(g) / len(g)) - (sum(m) / len(m))
        if abs(d) >= abs(observed_diff) - 1e-9:
            count += 1
    p_value = count / n_perm
    return observed_diff, game_mean, p_value


def binomial_two_sided_p(k: int, n: int, p0: float = 0.5) -> float:
    """Exact two-sided binomial test p-value (sum of all outcomes at least
    as extreme, i.e. P(X)<=P(k), summed)."""
    def pmf(x: int) -> float:
        return math.comb(n, x) * (p0 ** x) * ((1 - p0) ** (n - x))
    p_k = pmf(k)
    return sum(pmf(x) for x in range(n + 1) if pmf(x) <= p_k + 1e-12)


def score_discrimination(guesses: dict[str, str], groups: dict[str, str]) -> dict:
    labels = list(guesses.keys())
    game_labels = [l for l in labels if groups[l] == "game"]
    marathon_labels = [l for l in labels if groups[l] == "marathon"]

    def accuracy_for_alignment(a_is_game: bool) -> tuple[int, int]:
        """Returns (correct, decided) under one alignment of Source A/B."""
        a_group, b_group = ("game", "marathon") if a_is_game else ("marathon", "game")
        correct = 0
        decided = 0
        for l in labels:
            g = guesses[l]
            if g not in ("Source A", "Source B"):
                continue
            decided += 1
            guessed_group = a_group if g == "Source A" else b_group
            if guessed_group == groups[l]:
                correct += 1
        return correct, decided

    c1, d1 = accuracy_for_alignment(True)
    c2, d2 = accuracy_for_alignment(False)
    if c1 >= c2:
        correct, decided, alignment = c1, d1, "Source A=game, Source B=marathon"
    else:
        correct, decided, alignment = c2, d2, "Source A=marathon, Source B=game"

    p_value = binomial_two_sided_p(correct, decided, 0.5) if decided > 0 else float("nan")

    contingency = {"game": {"Source A": 0, "Source B": 0, "mixed-unknown": 0},
                   "marathon": {"Source A": 0, "Source B": 0, "mixed-unknown": 0}}
    for l in labels:
        g = guesses[l]
        key = g if g in ("Source A", "Source B", "mixed-unknown") else "mixed-unknown"
        contingency[groups[l]][key] += 1

    return {
        "best_alignment": alignment,
        "correct": correct,
        "decided": decided,
        "n_mixed_unknown": len(labels) - decided,
        "accuracy": correct / decided if decided else float("nan"),
        "binomial_p_value_vs_chance": p_value,
        "contingency_table": contingency,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--refs", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--n-perm", type=int, default=20000)
    ap.add_argument("--seed", type=int, default=44)
    args = ap.parse_args()

    pool = build_pool(args.refs / "marathon")
    groups = {k: v[0] for k, v in pool.items()}
    key = _load_key()

    ranks, guesses, reason, usage = judge_pool(pool, key, seed=args.seed)
    cost = float(usage.get("cost", 0.0))
    _log_call({"tool_variant": "marathon_monologue_check", "ranking": ranks,
               "source_guess": guesses}, cost)

    diff, game_mean, p_rank = rank_permutation_test(ranks, groups, n_perm=args.n_perm, seed=args.seed)
    marathon_mean = sum(ranks[l] for l in ranks if groups[l] == "marathon") / \
        sum(1 for l in ranks if groups[l] == "marathon")
    disc = score_discrimination(guesses, groups)

    per_item = [
        {"label": l, "group": groups[l], "rank": ranks[l], "source_guess": guesses[l],
         "text": pool[l][1]}
        for l in sorted(ranks, key=lambda k: ranks[k])
    ]

    report = {
        "model": MODEL,
        "n_items": len(pool),
        "mean_rank": {"game": game_mean, "marathon": marathon_mean},
        "naturalism_ranking": {
            "observed_diff_game_minus_marathon": diff,
            "p_value": p_rank,
            "interpretation": (
                "p >= 0.05: fail to reject exchangeability -- game monologue "
                "rank indistinguishable from Marathon exhibit rank"
                if p_rank >= 0.05 else
                "p < 0.05: game monologues rank differently from Marathon "
                "exhibits (direction: " +
                ("game ranked worse" if diff > 0 else "game ranked better") + ")"
            ),
        },
        "discrimination": disc,
        "discrimination_interpretation": (
            "p >= 0.05: judge's best-alignment accuracy is not distinguishable "
            "from chance -- cannot reliably discriminate Ratio from Marathon"
            if (isinstance(disc["binomial_p_value_vs_chance"], float) and
                disc["binomial_p_value_vs_chance"] >= 0.05)
            else "p < 0.05: judge discriminates the two sources above chance"
        ),
        "reason": reason,
        "per_item_sorted_by_rank": per_item,
        "total_cost": cost,
    }
    args.out.write_text(json.dumps(report, indent=2))
    print(json.dumps({
        "mean_rank": {"game": game_mean, "marathon": marathon_mean},
        "naturalism_p": p_rank,
        "discrimination": disc,
        "total_cost": round(cost, 5),
    }, indent=2))


if __name__ == "__main__":
    main()
