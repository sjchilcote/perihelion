"""tools/dialogue/naturalism_rank.py

Blind ranking instrument for dialogue naturalism, hardened from the
scratchpad prototype (dlg3/blind/run_blind.py + dlg3/judge/rank.py).

CONTRACT (verbatim intent from the director): judge "naturalism and
plausibility as two people talking" -- NEVER "which is from a video game".
The earlier instrument round failed by leaking genre; this one blinds
provenance by (a) neutralizing every proper noun to a consistent generic
placeholder scheme, (b) formatting every sample identically as bare
"A: line" / "B: line" turns with no source markers, and (c) asking the
judge only to RANK writing quality/naturalism within a shuffled bundle, on
which it never learns which entry is which.

Judge = google/gemini-3.5-flash via OpenRouter, same model every other
judge in this repo uses (tools/dialogue/judge.py, tools/playtest/
audio_judge.py). Method is TEXT ranking, not audio: the earlier round used
TTS specifically to strip vocal-performance differences out of the signal,
but that adds a synthesizer as a second confound (TTS artifacts read as
"clunky writing") without buying anything text-only judging doesn't already
get by using one uniform "A:"/"B:" transcript format across every source.
Text is cheaper, faster, and removes a confound instead of trading one for
another.

SOURCES per trial (4-way ranking, no ties):
    game      -- one excerpt pulled live from game/perihelion/conversations.py
                 (always the current shipped text; CHOICE turns resolved to
                 the "warm" branch), neutralized.
    marathon  -- one exhibit from MARATHON_STUDY.md Part D, pre-neutralized
                 and stored under --refs (never committed to the repo --
                 Marathon terminal text is not this repo's content to ship).
    film      -- one two-hander excerpt from acclaimed film scripts (from-
                 memory approximations / prior dlg3 fetches), also under
                 --refs. Calibration texture only, never shipped.
    control   -- ONE fixed, deliberately stilted "as-you-know-Bob" exposition
                 dump, hand-written for this instrument as a negative
                 fixture (not shipped content) -- validates the instrument
                 actually discriminates bad writing at all.

Every trial's 4 items are shuffled to random letters before the judge sees
them, and the judge is never told there are exactly one of each source.

Success criterion: game's mean rank falls within the marathon/film band with
p >= 0.05 on a permutation test (source labels are exchangeable), AND the
control is ranked worst (highest numeral) with p < 0.05.

Key loading, cost logging: same idiom as tools/dialogue/judge.py --
_load_key() from generate.py (repo .openrouter_key / OPENROUTER_API_KEY,
never printed), cost appended to tools/dialogue/cost_log.json (shared
running total with generate.py/judge.py).

CLI:
    uv run python tools/dialogue/naturalism_rank.py --refs /path/to/naturalism_refs --out results.json
    uv run python tools/dialogue/naturalism_rank.py --refs ... --gaps 0,1,2 --out results.json
"""
from __future__ import annotations

import argparse
import itertools
import json
import random
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate import _load_key  # noqa: E402  (key loader; never prints)

REPO_ROOT = Path(__file__).resolve().parents[2]
TOOL_DIR = Path(__file__).resolve().parent
COST_LOG = TOOL_DIR / "cost_log.json"  # shared running total, see judge.py

sys.path.insert(0, str(REPO_ROOT))
from game.perihelion.conversations import CONVERSATIONS, RATIO, COMMANDO  # noqa: E402

MODEL = "google/gemini-3.5-flash"
API_URL = "https://openrouter.ai/api/v1/chat/completions"
MAX_RETRIES = 4
RETRY_BACKOFF_S = 6.0

TARGET_WORDS = 140          # window target for game excerpts, matches ref length band
MIN_TURNS = 4

LETTERS = ["W", "X", "Y", "Z"]  # per-trial shuffled labels; deliberately not A/B/C
                                  # (A/B are already used *inside* every sample as
                                  # the speaker tags, so trial labels must differ)

PROMPT = (
    "You will read four short two-voice dialogue transcripts, labeled {labels}. "
    "Each line is tagged only 'A:' or 'B:' for the two speakers -- ignore who "
    "'A' and 'B' are; some transcripts are monologues where only 'A' speaks. "
    "All proper nouns have been replaced with generic placeholders, so do not "
    "try to guess the source, setting, or medium of any transcript -- there is "
    "no reward for identifying a source, and guessing at genre or origin is "
    "off-task.\n\n"
    "Your ONLY job: rank the four transcripts by how natural and plausible "
    "they are AS TWO PEOPLE TALKING (or one person addressing another) -- "
    "rhythm, subtext, specificity, whether each line sounds like something a "
    "mind would actually say next. Do not reward or penalize a transcript for "
    "seeming to come from a game, a film, a broadcast, or any other medium; "
    "judge only the writing craft and conversational naturalism in front of "
    "you. 1 = most natural/best-written, 4 = least natural/worst-written. No "
    "ties -- use each rank exactly once.\n\n"
    "Reply with STRICT JSON only, no markdown fences: "
    '{{"ranking": {{{rank_schema}}}, "reason": "<one sentence per transcript, '
    'keyed by its label>"}}'
)


# ---------------------------------------------------------------------------
# cost log (shared file/format with generate.py / judge.py / audio_judge.py)
# ---------------------------------------------------------------------------


def _read_cost_log() -> dict:
    if COST_LOG.exists():
        try:
            return json.loads(COST_LOG.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    return {"total_cost": 0.0, "calls": []}


def _write_cost_log(log: dict) -> None:
    COST_LOG.write_text(json.dumps(log, indent=2))


def _log_call(extra: dict, cost: float) -> None:
    log = _read_cost_log()
    log["total_cost"] = log.get("total_cost", 0.0) + cost
    log.setdefault("calls", []).append(
        {"tool": "naturalism_rank", "cost": cost, "ts": time.time(), **extra}
    )
    _write_cost_log(log)


# ---------------------------------------------------------------------------
# game excerpt extraction + neutralization
#
# Game text is pulled live from conversations.py (never hardcoded here) so
# the instrument always measures the currently shipped script, not a stale
# copy. Neutralization replaces this game's own proper nouns (place names,
# person names, faction/doctrine terms) with generic placeholders using the
# SAME kind of scheme dlg3 already used for the Marathon/film references
# (specific -> generic, never "video game" flavored, never blank).
# ---------------------------------------------------------------------------

GAME_NEUTRALIZE = [
    (r"\bChurch-issue\b", "issue"),
    (r"\bthe Church\b", "the Order"),
    (r"\bChurch\b", "the Order"),
    (r"\bOsei\b", "Dara"),
    (r"\bWarden\b", "the Sentinel"),
    (r"\bAugustine\b", "a philosopher"),
    (r"\bMars\b", "home"),
    (r"\bCoolant Row\b", "the coolant deck"),
    (r"\bLong Gallery\b", "the gallery"),
    (r"\bTwo Wings\b", "the split wing"),
    (r"\bMirror Ward\b", "the ward"),
    (r"\bRecords Stack\b", "the archive"),
    (r"\bTesseract Deck\b", "the deck"),
    (r"\bThe Fold\b", "the passage"),
    (r"\bthe Adversary\b", "the enemy"),
    (r"\bTestament\b", "doctrine"),
    (r"\bSite One\b", "the specimen wing"),
    (r"\bDirective 0007\b", "the directive"),
    (r"\bGUID\b", "an ID"),
]


_SENTENCE_START = re.compile(r"(^|[.!?]\s+)([a-z])")


def _fix_capitalization(text: str) -> str:
    """Substitutions can land a lowercase placeholder at a sentence start
    (e.g. 'Coolant Row next.' -> 'the coolant deck next.'); recapitalize."""
    return _SENTENCE_START.sub(lambda m: m.group(1) + m.group(2).upper(), text)


def _neutralize_game(text: str) -> str:
    for pattern, repl in GAME_NEUTRALIZE:
        text = re.sub(pattern, repl, text)
    return _fix_capitalization(text)


def _resolve_choice(turn) -> list[tuple[str, str]]:
    """CHOICE turns are (posture, commando_line, *ratio_reply_lines) tuples;
    always resolve to the 'warm' branch so the excerpt is deterministic."""
    _, options = turn
    posture, commando_line, *ratio_lines = next(o for o in options if o[0] == "warm")
    out = [(COMMANDO, commando_line)]
    out.extend((RATIO, line) for line in ratio_lines)
    return out


def _flatten(turns: list) -> list[tuple[str, str]]:
    flat: list[tuple[str, str]] = []
    for turn in turns:
        if turn[0] == "CHOICE":
            flat.extend(_resolve_choice(turn))
        else:
            flat.append(turn)
    return flat


def _window(turns: list[tuple[str, str]], target_words: int = TARGET_WORDS,
            min_turns: int = MIN_TURNS) -> list[tuple[str, str]]:
    """Take a contiguous slice long enough to be voice-comparable to the
    marathon/film reference excerpts (roughly TARGET_WORDS), not the whole
    (often much longer) gap conversation."""
    out: list[tuple[str, str]] = []
    words = 0
    for t in turns:
        out.append(t)
        words += len(t[1].split())
        if words >= target_words and len(out) >= min_turns:
            break
    return out


def game_excerpt(gap: int) -> str:
    """Return one neutralized, windowed game excerpt as 'A:'/'B:' text,
    formatted exactly like the reference files (RATIO -> A, COMMANDO -> B)."""
    turns = CONVERSATIONS.get(gap)
    if turns is None:
        raise KeyError(f"no gap {gap} in CONVERSATIONS")
    flat = _window(_flatten(turns))
    tag = {RATIO: "A", COMMANDO: "B"}
    lines = [f"{tag[speaker]}: {_neutralize_game(text)}" for speaker, text in flat]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# reference loading
# ---------------------------------------------------------------------------


def load_refs(refs_dir: Path) -> dict[str, list[tuple[str, str]]]:
    """Load marathon/film/control reference files. Each returned as
    (name, text) pairs so per-sample identity is preserved for reporting."""
    out: dict[str, list[tuple[str, str]]] = {}
    for source in ("marathon", "film", "control"):
        d = refs_dir / source
        if not d.is_dir():
            raise FileNotFoundError(f"missing refs subdir: {d}")
        files = sorted(d.glob("*.txt"))
        if not files:
            raise FileNotFoundError(f"no .txt refs under {d}")
        out[source] = [(f.stem, f.read_text().strip()) for f in files]
    return out


# ---------------------------------------------------------------------------
# judge call
# ---------------------------------------------------------------------------


def _extract_json(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end == -1:
        raise ValueError(f"no JSON object in response: {text[:200]!r}")
    return json.loads(text[start : end + 1])


def judge_trial(items: dict[str, str], key: str) -> tuple[dict, str, dict]:
    """items: {source_name: text}, exactly 4 entries. Returns
    (ranking-by-source, reason, usage)."""
    sources = list(items.keys())
    rng_labels = LETTERS[: len(sources)]
    shuffled = sources[:]
    random.shuffle(shuffled)
    label_of = dict(zip(shuffled, rng_labels))  # source -> label

    body_parts = []
    for source in shuffled:
        label = label_of[source]
        body_parts.append(f"Transcript {label}:\n{items[source]}")
    rank_schema = ", ".join(f'"{l}": <1-4>' for l in rng_labels)
    prompt = PROMPT.format(labels=", ".join(rng_labels), rank_schema=rank_schema)
    user_content = prompt + "\n\n" + "\n\n".join(body_parts)

    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": user_content}],
        "temperature": 0.2,
        "max_tokens": 800,
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
            label_ranking = {k: int(v) for k, v in parsed["ranking"].items()}
            if sorted(label_ranking.values()) != list(range(1, len(sources) + 1)):
                raise ValueError(f"not a permutation of 1..{len(sources)}: {label_ranking}")
            by_source = {source: label_ranking[label_of[source]] for source in sources}
            reason = parsed.get("reason", "")
            return by_source, reason, data.get("usage", {})
        except urllib.error.HTTPError as e:
            last_err = f"HTTP {e.code}: {e.read().decode(errors='replace')[:400]}"
        except (urllib.error.URLError, TimeoutError, ValueError, KeyError, json.JSONDecodeError) as e:
            last_err = f"{type(e).__name__}: {e}"
        if attempt < MAX_RETRIES:
            time.sleep(RETRY_BACKOFF_S * attempt)
    raise RuntimeError(f"judge call failed after {MAX_RETRIES} attempts: {last_err}")


# ---------------------------------------------------------------------------
# stats: mean rank per source + permutation test
# ---------------------------------------------------------------------------


def permutation_test(trials: list[dict], group_a: set[str], group_b: set[str],
                      n_perm: int = 20000, seed: int = 0) -> tuple[float, float, float]:
    """Within each trial, the 4 ranks {1,2,3,4} are a fixed multiset assigned
    to 4 source labels. Under H0 (source labels exchangeable -- i.e. which
    source got which rank is arbitrary), permute the source<->rank mapping
    within each trial and recompute mean(group_a) - mean(group_b). Two-sided
    p-value = fraction of permuted |diff| >= observed |diff|.

    Returns (observed_diff, mean_a, p_value).
    """
    rng = random.Random(seed)
    sources = sorted(group_a | group_b)

    def group_means(assignment_per_trial: list[dict[str, int]]) -> tuple[float, float]:
        a_vals = [t[s] for t in assignment_per_trial for s in group_a if s in t]
        b_vals = [t[s] for t in assignment_per_trial for s in group_b if s in t]
        return (sum(a_vals) / len(a_vals) if a_vals else float("nan"),
                sum(b_vals) / len(b_vals) if b_vals else float("nan"))

    obs_a, obs_b = group_means(trials)
    observed_diff = obs_a - obs_b

    count = 0
    for _ in range(n_perm):
        perm_trials = []
        for t in trials:
            vals = list(t.values())
            rng.shuffle(vals)
            perm_trials.append(dict(zip(t.keys(), vals)))
        pa, pb = group_means(perm_trials)
        if abs(pa - pb) >= abs(observed_diff) - 1e-9:
            count += 1
    p_value = count / n_perm
    return observed_diff, obs_a, p_value


def control_worst_test(trials: list[dict], n_perm: int = 20000, seed: int = 1) -> tuple[float, float]:
    """P(control's mean rank this bad or worse | ranks assigned at random)."""
    rng = random.Random(seed)
    control_vals = [t["control"] for t in trials if "control" in t]
    if not control_vals:
        return float("nan"), float("nan")
    observed_mean = sum(control_vals) / len(control_vals)
    n = len(trials)
    count = 0
    for _ in range(n_perm):
        sim_vals = []
        for t in trials:
            vals = list(t.values())
            sim_vals.append(rng.choice(vals))
        sim_mean = sum(sim_vals) / len(sim_vals)
        if sim_mean >= observed_mean - 1e-9:
            count += 1
    p_value = count / n_perm
    return observed_mean, p_value


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--refs", required=True, type=Path,
                     help="dir with marathon/, film/, control/ subdirs of neutralized .txt refs")
    ap.add_argument("--gaps", default="0,1,2,3,4,5,6,7,8",
                     help="comma-separated CONVERSATIONS gap indices to sample as game excerpts")
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--n-perm", type=int, default=20000)
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    random.seed(args.seed)
    gaps = [int(g) for g in args.gaps.split(",") if g.strip() != ""]

    refs = load_refs(args.refs)
    marathon_cycle = itertools.cycle(refs["marathon"])
    film_cycle = itertools.cycle(refs["film"])
    control_name, control_text = refs["control"][0]  # one fixed control fixture

    key = _load_key()

    trials_raw = []       # per-trial {source: rank}
    per_sample_records = []  # for weak-scene reporting
    total_cost = 0.0

    for gap in gaps:
        game_text = game_excerpt(gap)
        m_name, m_text = next(marathon_cycle)
        f_name, f_text = next(film_cycle)
        items = {
            "game": game_text,
            "marathon": m_text,
            "film": f_text,
            "control": control_text,
        }
        by_source, reason, usage = judge_trial(items, key)
        cost = float(usage.get("cost", 0.0))
        total_cost += cost
        _log_call({"gap": gap, "marathon_ref": m_name, "film_ref": f_name,
                    "ranking": by_source}, cost)

        trials_raw.append(by_source)
        per_sample_records.append({
            "gap": gap, "marathon_ref": m_name, "film_ref": f_name,
            "control_ref": control_name, "ranking": by_source, "reason": reason,
        })
        print(json.dumps({"gap": gap, "ranking": by_source, "cost": round(cost, 5)}))

    # mean rank per source
    sources = ("game", "marathon", "film", "control")
    mean_rank = {
        s: sum(t[s] for t in trials_raw) / len(trials_raw) for s in sources
    }

    # success criterion 1: game indistinguishable from {marathon, film}
    diff, game_mean, p_indist = permutation_test(
        trials_raw, {"game"}, {"marathon", "film"}, n_perm=args.n_perm, seed=args.seed
    )
    # diagnostic: marathon vs film alone -- if this is significant on its
    # own, the instrument may be measuring monologue-vs-dialogue form, not
    # naturalism (see module docstring / director's note)
    diff_mf, _, p_marathon_vs_film = permutation_test(
        trials_raw, {"marathon"}, {"film"}, n_perm=args.n_perm, seed=args.seed + 1
    )
    # success criterion 2: control ranks clearly worst
    control_mean, p_control = control_worst_test(trials_raw, n_perm=args.n_perm, seed=args.seed + 2)

    worst = sorted(per_sample_records, key=lambda r: -r["ranking"]["game"])[:3]

    report = {
        "model": MODEL,
        "n_trials": len(trials_raw),
        "mean_rank": mean_rank,
        "game_vs_refs": {
            "observed_diff_game_minus_refs": diff,
            "p_value": p_indist,
            "interpretation": (
                "p >= 0.05: fail to reject exchangeability -- game rank "
                "indistinguishable from marathon+film references"
                if p_indist >= 0.05 else
                "p < 0.05: game rank differs from references (direction: "
                + ("game ranked worse" if diff > 0 else "game ranked better") + ")"
            ),
        },
        "marathon_vs_film": {
            "observed_diff": diff_mf,
            "p_value": p_marathon_vs_film,
            "interpretation": (
                "marathon and film interleave (no reliable rank gap) -- "
                "instrument is not confounding monologue-form with naturalism"
                if p_marathon_vs_film >= 0.05 else
                "marathon and film separate reliably -- possible "
                "monologue-vs-dialogue confound, treat game-vs-refs result "
                "with caution"
            ),
        },
        "control_validation": {
            "control_mean_rank": control_mean,
            "p_value_control_this_bad_by_chance": p_control,
            "interpretation": (
                "control (stilted exposition dump) ranks worst, reliably worse "
                "than chance -- instrument discriminates bad writing"
                if (control_mean == max(mean_rank.values()) and p_control < 0.05)
                else "control did NOT clearly rank worst -- instrument may not "
                     "be discriminating naturalism at all; do not trust the "
                     "game-vs-refs result above"
            ),
        },
        "per_trial": per_sample_records,
        "worst_3_game_samples": worst,
        "total_cost": total_cost,
    }
    args.out.write_text(json.dumps(report, indent=2))
    print(json.dumps({
        "mean_rank": mean_rank,
        "game_vs_refs_p": p_indist,
        "marathon_vs_film_p": p_marathon_vs_film,
        "control_p": p_control,
        "total_cost": round(total_cost, 5),
    }, indent=2))


if __name__ == "__main__":
    main()
