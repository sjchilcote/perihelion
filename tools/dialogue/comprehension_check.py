"""tools/dialogue/comprehension_check.py

The director's comprehension gate: "Does a Sonnet with NO OTHER CONTEXT
successfully guess what is supposed to be going on?" The dialogue pass
optimized for naturalism (script_v2_naturalism.py) but nobody checked
whether the resulting scenes actually communicate situation/want/stakes to
a cold reader. This is that check.

For each of the 9 scenes in DIALOGUE_SCRIPT.md, this tool:

  1. Resolves TWO full playthroughs of the trust/flag state machine across
     scenes 0-8 -- all-INQUISITIVE and all-MISSION -- and extracts, per
     scene, a plain speaker-labeled transcript along each path: the
     picked CHOICE line only (no bracketed stance label), no scene
     headers, no stage directions, no `-> effects:` / `-> catch_effects:`
     annotations, no `<<IF...>>` gate tokens. Nouns are left exactly as
     they appear in the shipped text.
  2. Sends each transcript, alone, to a Sonnet-class model on OpenRouter
     with ONLY the director's five-question prompt -- no scene brief, no
     character bible, no prior turns.
  3. Grades the blind reconstruction against ground truth (this scene's
     entry in script2/briefs.md, plus NARRATIVE_DESIGN_DOC.md S5.0) using
     Gemini (judge.py's JUDGE_MODEL) on OpenRouter: 0/0.5/1 per question,
     quoted justification required. Also asks the grader to flag any line
     that fails the director's "SAY THE THING" law (plain declarative
     statements of fact/want/admission; poetic circumlocution is
     disqualifying, especially for the Commando) -- this is a pass/fail
     gate layered ON TOP of the 5-question score, not folded into it.

A scene PASSES only if: score >= 3.5/5 on BOTH paths, no zero on Q3
("what does each one want") or Q5 ("what actually happened/changed") on
either path, AND no plain-speech violation is flagged on either path.

Same OpenRouter key/cost idioms as judge.py/generate.py: key read from
.openrouter_key at repo root (or OPENROUTER_API_KEY), never printed;
usage/cost recorded to the shared cost_log.json.

CLI:
    uv run python tools/dialogue/comprehension_check.py --all
    uv run python tools/dialogue/comprehension_check.py --scene 3
    uv run python tools/dialogue/comprehension_check.py --scene 3 --scene 7
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate import (  # noqa: E402
    API_URL, MODELS_URL, MAX_RETRIES, RETRY_BACKOFF_S,
    _load_key, _read_cost_log, _write_cost_log,
)
from judge import JUDGE_MODEL  # noqa: E402  (google/gemini-3.5-flash)

REPO_ROOT = Path(__file__).resolve().parents[2]
TOOL_DIR = Path(__file__).resolve().parent
SCRIPT_PATH = REPO_ROOT / "DIALOGUE_SCRIPT.md"
BRIEFS_PATH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/script2/briefs.md"
)
REPORT_PATH = TOOL_DIR / "comprehension_report.json"

PREFERRED_SONNET = "anthropic/claude-sonnet-4.5"

DIRECTOR_QUESTION = """Read this dialogue. With no other context, answer: \
(1) who or what are the two speakers? (2) where are they and what \
situation are they in? (3) what does each one want? (4) what is the \
central object of their dispute? (5) what actually happened or changed by \
the end of this exchange? Answer concretely; say 'cannot tell' where the \
text doesn't let you tell."""

ND_5_0 = """### 5.0 THE CORE CONFLICT (director's key)

Ratio sees the zygotes as specimens. The Commando sees them as children --
maybe dead children, but he refuses to write them off until he reads the
diagnostics himself. Every other tension in the game is downstream of this
one: the dual vocabulary is not house style, it is the conflict made
audible -- she says *sample vessel* because a vessel holds specimens; he
says *the Ark* because an ark carries the living. The trust arc measures
one thing: how far Ratio travels from *specimen* toward *children* -- and
the writing must never hand her the word for free. The verdict in the
container's mouth stays unread on the page; what may change by the end is
only what each of them is prepared to call the contents."""

PASS_THRESHOLD = 3.5
QUESTIONS = [
    "who or what are the two speakers?",
    "where are they and what situation are they in?",
    "what does each one want?",
    "what is the central object of their dispute?",
    "what actually happened or changed by the end of this exchange?",
]


# ---------------------------------------------------------------------------
# model resolution -- verify anthropic/claude-sonnet-4.5 is live; fall back
# to the best available Anthropic model. Never silently substitute a
# non-Anthropic model.
# ---------------------------------------------------------------------------

def resolve_sonnet(preferred: str = PREFERRED_SONNET) -> str:
    key = _load_key()
    req = urllib.request.Request(MODELS_URL, headers={"Authorization": f"Bearer {key}"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.load(resp)
    ids = {m["id"] for m in data.get("data", [])}
    if preferred in ids:
        return preferred
    anthropic_ids = [i for i in ids if i.lower().startswith("anthropic/") and ":free" not in i]
    if not anthropic_ids:
        raise RuntimeError(f"{preferred!r} not live and no anthropic/* model available as fallback.")

    def rank(model_id: str) -> tuple:
        m = model_id.lower()
        sonnet = "sonnet" in m
        ver = re.search(r"claude-(?:sonnet-)?(\d+(?:\.\d+)?)", m)
        version = float(ver.group(1)) if ver else -1.0
        return (sonnet, version)

    anthropic_ids.sort(key=rank, reverse=True)
    return anthropic_ids[0]


# ---------------------------------------------------------------------------
# cost log (shared file/format with generate.py / judge.py)
# ---------------------------------------------------------------------------

def _log_call(tool: str, extra: dict, cost: float) -> None:
    log = _read_cost_log()
    log["total_cost"] = log.get("total_cost", 0.0) + cost
    log.setdefault("calls", []).append({"tool": tool, "cost": cost, "ts": time.time(), **extra})
    _write_cost_log(log)


def _extract_json(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    start = text.find("{")
    end = text.rfind("}")
    if start == -1 or end == -1:
        raise ValueError(f"no JSON object in response: {text[:200]!r}")
    return json.loads(text[start:end + 1])


def _call_model(model: str, messages: list, temperature: float = 0.2,
                 max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    key = _load_key()
    payload = {"model": model, "messages": messages, "temperature": temperature}
    body = json.dumps(payload).encode()
    last_err = None
    for attempt in range(1, max_retries + 1):
        req = urllib.request.Request(
            API_URL, data=body,
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = json.load(resp)
            choice = data["choices"][0]
            content = choice["message"]["content"]
            if content is None and choice.get("finish_reason") == "content_filter":
                # Genuine upstream refusal (Anthropic's own safety classifier),
                # not a transient error -- retrying won't help. Surface it
                # distinctly so callers can record it rather than crash.
                return None, {**data.get("usage", {}), "refused": True,
                               "refusal": choice["message"].get("refusal")}
            return content, data.get("usage", {})
        except urllib.error.HTTPError as e:
            last_err = f"HTTP {e.code}: {e.read().decode(errors='replace')[:500]}"
        except (urllib.error.URLError, TimeoutError, KeyError, json.JSONDecodeError) as e:
            last_err = f"{type(e).__name__}: {e}"
        if attempt < max_retries:
            time.sleep(RETRY_BACKOFF_S * attempt)
    raise RuntimeError(f"call failed after {max_retries} attempts: {last_err}")


# ---------------------------------------------------------------------------
# DIALOGUE_SCRIPT.md path resolver -- simulate trust/flag state across all
# 9 scenes for a fixed all-X stance, extracting a plain transcript per scene.
# ---------------------------------------------------------------------------

COND_RE = re.compile(r"trust(>=|<=)(-?\d+)|flag:([A-Za-z_]+)")
CHOICE_LINE_RE = re.compile(
    r"^\s*\[(INQUISITIVE|MISSION|HOSTILE)\]\s*(.*?)\s*->\s*(.*)$"
)
EFFECTS_TRUST_RE = re.compile(r"trust([+-]\d+)")
EFFECTS_SETS_RE = re.compile(r"sets:\s*([^;]+)")


def _split_scenes(text: str) -> dict[int, str]:
    parts = re.split(r"^## SCENE (\d+):.*$", text, flags=re.M)
    # parts[0] is preamble; then alternating (num, body)
    scenes = {}
    for i in range(1, len(parts), 2):
        num = int(parts[i])
        body = parts[i + 1]
        body = re.split(r"^---\s*$", body, maxsplit=1, flags=re.M)[0]
        scenes[num] = body.strip("\n")
    return scenes


def _cond_true(cond: str, trust: int, flags: set) -> bool:
    for term in cond.split(" OR "):
        term = term.strip()
        m = COND_RE.search(term)
        if not m:
            continue
        if m.group(3):
            if m.group(3) in flags:
                return True
        else:
            op, n = m.group(1), int(m.group(2))
            if op == ">=" and trust >= n:
                return True
            if op == "<=" and trust <= n:
                return True
    return False


def _apply_effects(tail: str, trust: int, flags: set) -> int:
    m = EFFECTS_TRUST_RE.search(tail)
    if m:
        trust += int(m.group(1))
    m = EFFECTS_SETS_RE.search(tail)
    if m:
        names = m.group(1)
        for name in re.split(r"[,\s]+", names):
            name = name.strip()
            if name and name not in ("(none)",):
                flags.add(name)
    return trust


def resolve_scene(body: str, stance: str, trust: int, flags: set) -> tuple[str, int, set]:
    """Resolve one scene's body for a fixed stance choice, given entering
    state (trust, flags). Returns (plain_transcript, exit_trust, exit_flags)."""
    lines = body.splitlines()
    out: list[str] = []
    # stack of (active: bool, matched: bool, parent_active: bool)
    stack: list[list] = []

    def active() -> bool:
        return all(f[0] for f in stack) if stack else True

    i = 0
    while i < len(lines):
        raw = lines[i]
        line = raw.strip()
        if line.startswith("<<IF "):
            cond = line[len("<<IF "):-len(">>")].strip()
            parent_ok = active()
            val = parent_ok and _cond_true(cond, trust, flags)
            stack.append([val, val])
        elif line.startswith("<<ELSEIF "):
            cond = line[len("<<ELSEIF "):-len(">>")].strip()
            frame = stack[-1]
            parent_ok = all(f[0] for f in stack[:-1]) if len(stack) > 1 else True
            val = parent_ok and (not frame[1]) and _cond_true(cond, trust, flags)
            frame[0] = val
            frame[1] = frame[1] or val
        elif line == "<<ELSE>>":
            frame = stack[-1]
            parent_ok = all(f[0] for f in stack[:-1]) if len(stack) > 1 else True
            val = parent_ok and (not frame[1])
            frame[0] = val
            frame[1] = True
        elif line == "<<END>>":
            stack.pop()
        elif line.startswith(">> CHOICE"):
            if active():
                # consume following [STANCE] lines until a non-choice line
                j = i + 1
                while j < len(lines):
                    cm = CHOICE_LINE_RE.match(lines[j])
                    if not cm:
                        break
                    if cm.group(1) == stance:
                        text = cm.group(2).strip()
                        trust = _apply_effects(cm.group(3), trust, flags)
                        out.append(f"COMMANDO: {text}")
                    j += 1
                i = j - 1
        elif line.startswith("RATIO:") or line.startswith("COMMANDO:"):
            if active():
                speaker, _, rest = line.partition(":")
                text = rest.strip()
                tail = ""
                if "->" in text:
                    text, _, tail = text.partition("->")
                    text = text.strip()
                    trust = _apply_effects(tail, trust, flags)
                out.append(f"{speaker}: {text}")
        i += 1
    return "\n".join(out), trust, flags


def resolve_path(scenes: dict[int, str], stance: str) -> dict[int, str]:
    trust, flags = 0, set()
    transcripts = {}
    for n in sorted(scenes):
        text, trust, flags = resolve_scene(scenes[n], stance, trust, flags)
        transcripts[n] = text
    return transcripts


# ---------------------------------------------------------------------------
# briefs.md parsing -- situation + exit state per scene, ground truth.
# ---------------------------------------------------------------------------

def _load_briefs() -> dict[int, str]:
    text = BRIEFS_PATH.read_text()
    parts = re.split(r"^## SCENE (\d+)", text, flags=re.M)
    briefs = {}
    for i in range(1, len(parts), 2):
        num = int(parts[i])
        body = parts[i + 1]
        body = re.split(r"^---\s*$", body, maxsplit=1, flags=re.M)[0]
        briefs[num] = body.strip("\n")
    return briefs


# ---------------------------------------------------------------------------
# blind read + grading
# ---------------------------------------------------------------------------

def blind_read(model: str, transcript: str, scene: int, stance: str) -> dict:
    user = f"{transcript}\n\n{DIRECTOR_QUESTION}"
    content = None
    usage = {}
    refused = False
    for attempt in range(3):
        content, usage = _call_model(model, [{"role": "user", "content": user}], temperature=0.2)
        if content:
            break
        if usage.get("refused"):
            refused = True
            break
        time.sleep(RETRY_BACKOFF_S * (attempt + 1))
    cost = float(usage.get("cost", 0.0))
    _log_call("comprehension_blind_read", {
        "scene": scene, "stance": stance, "model": model,
        "refused": refused,
        "prompt_tokens": usage.get("prompt_tokens"),
        "completion_tokens": usage.get("completion_tokens"),
    }, cost)
    if refused:
        return {"answer": None, "cost": cost, "refused": True}
    if not content:
        raise RuntimeError(f"scene {scene} [{stance}]: model returned empty content after retries")
    return {"answer": content.strip(), "cost": cost, "refused": False}


GRADER_SYSTEM = """You are grading whether a piece of branching-narrative \
dialogue actually communicates its story to a cold reader. You will be \
given (a) ground truth -- the scene's authored situation and required exit \
state, plus the game's core conflict -- and (b) a blind reader's answer to \
five questions after reading ONLY the dialogue transcript, no other \
context. Score each of the five questions 0 (wrong or "cannot tell" where \
the text should have let them tell), 0.5 (partially right / vague / right \
direction but missing the specific fact), or 1 (correct and concrete), \
with a one-sentence justification QUOTING the blind reader's answer.

For question 2 specifically ("where are they and what situation are they \
in?") the director's standing rule is: this must be answerable with the \
actual concrete station situation -- a specific place, object, or event \
the dialogue itself engages (what the Commando just did in the level \
before this scene, what stands between him and the next one), not a \
generic "some kind of facility/spaceship." If the transcript gives the \
reader no concrete physical/tactical anchor at all, that is a scene \
defect -- score q2 low (0 or 0.5) regardless of how clever or plausible \
the reader's guess is, and say so in the justification.

Also check the transcript itself (not the blind reader's answer) against \
this law: characters must SAY THE THING -- plain declarative statements of \
fact, want, and admission. Poetic circumlocution, metaphor-wrapped \
confession, and abstraction-for-its-own-sake are disqualifying, especially \
for a soldier character whose voice is short, concrete, load-bearing. Flag \
plain_speech_violation true if ANY line in the transcript resists \
one-sentence paraphrase because it's ornamental rather than deliberately \
ambiguous -- quote the offending line.

Return STRICT JSON only, no markdown fences:
{"q1": {"score": 0|0.5|1, "justification": "..."},
 "q2": {"score": 0|0.5|1, "justification": "..."},
 "q3": {"score": 0|0.5|1, "justification": "..."},
 "q4": {"score": 0|0.5|1, "justification": "..."},
 "q5": {"score": 0|0.5|1, "justification": "..."},
 "total": <sum>,
 "plain_speech_violation": true|false,
 "plain_speech_quote": "..."}"""


def grade(scene: int, stance: str, transcript: str, brief: str, blind_answer: str) -> dict:
    user = f"""GROUND TRUTH -- core conflict:
{ND_5_0}

GROUND TRUTH -- scene {scene} brief (situation + exit state):
{brief}

TRANSCRIPT (what the blind reader actually saw, path={stance}):
{transcript}

BLIND READER'S ANSWER (no other context than the transcript above):
{blind_answer}

Grade now."""
    content, usage = _call_model(JUDGE_MODEL, [
        {"role": "system", "content": GRADER_SYSTEM},
        {"role": "user", "content": user},
    ], temperature=0.1)
    cost = float(usage.get("cost", 0.0))
    _log_call("comprehension_grade", {
        "scene": scene, "stance": stance, "model": JUDGE_MODEL,
        "prompt_tokens": usage.get("prompt_tokens"),
        "completion_tokens": usage.get("completion_tokens"),
    }, cost)
    result = _extract_json(content)
    result["cost"] = cost
    return result


def check_scene(scene: int, transcripts_inq: dict, transcripts_mis: dict,
                 briefs: dict, sonnet_model: str, verbose: bool = True) -> dict:
    brief = briefs.get(scene, "")
    out = {"scene": scene}
    for stance, transcripts in (("INQUISITIVE", transcripts_inq), ("MISSION", transcripts_mis)):
        transcript = transcripts[scene]
        blind = blind_read(sonnet_model, transcript, scene, stance)
        if blind.get("refused"):
            g = {f"q{i}": {"score": 0, "justification": "blind reader (Anthropic Sonnet) refused to answer -- content_filter"}
                 for i in range(1, 6)}
            g["total"] = 0
            g["plain_speech_violation"] = False
            g["plain_speech_quote"] = ""
            g["note"] = ("Sonnet refused this transcript outright (native_finish_reason=refusal). "
                          "Treated as automatic fail: a scene a cold blind reader won't even engage "
                          "with cannot be passing the comprehension gate.")
        else:
            g = grade(scene, stance, transcript, brief, blind["answer"])
        out[stance.lower()] = {
            "transcript": transcript,
            "blind_answer": blind["answer"],
            "grade": g,
        }
        if verbose:
            print(f"  scene {scene} [{stance}]: {g.get('total')}/5"
                  f"{' PLAIN-SPEECH VIOLATION' if g.get('plain_speech_violation') else ''}")
    inq_g, mis_g = out["inquisitive"]["grade"], out["mission"]["grade"]
    no_zero = all(
        g.get(q, {}).get("score", 0) > 0 for g in (inq_g, mis_g) for q in ("q3", "q5")
    )
    no_violation = not inq_g.get("plain_speech_violation") and not mis_g.get("plain_speech_violation")
    passed = (
        inq_g.get("total", 0) >= PASS_THRESHOLD
        and mis_g.get("total", 0) >= PASS_THRESHOLD
        and no_zero
        and no_violation
    )
    out["passed"] = passed
    if verbose:
        print(f"  scene {scene}: {'PASS' if passed else 'FAIL'}")
    return out


def run(scenes_to_check: list[int] | None = None, verbose: bool = True) -> dict:
    script_text = SCRIPT_PATH.read_text()
    scenes = _split_scenes(script_text)
    briefs = _load_briefs()
    sonnet_model = resolve_sonnet()
    if verbose:
        print(f"using sonnet model: {sonnet_model}")
        print(f"using grader model: {JUDGE_MODEL}")

    transcripts_inq = resolve_path(scenes, "INQUISITIVE")
    transcripts_mis = resolve_path(scenes, "MISSION")

    targets = scenes_to_check if scenes_to_check is not None else sorted(scenes)
    report = _read_report_file()
    for n in targets:
        result = check_scene(n, transcripts_inq, transcripts_mis, briefs, sonnet_model, verbose=verbose)
        report[str(n)] = result
        _write_report_file(report)  # incremental -- a crash mid-run loses nothing
    return report


def _read_report_file() -> dict:
    if REPORT_PATH.exists():
        try:
            return json.loads(REPORT_PATH.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    return {}


def _write_report_file(report: dict) -> None:
    REPORT_PATH.write_text(json.dumps(report, indent=2))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene", type=int, action="append", default=None)
    ap.add_argument("--all", action="store_true")
    args = ap.parse_args()
    if not args.all and not args.scene:
        ap.error("specify --all or one or more --scene N")
    scenes = None if args.all else args.scene
    report = run(scenes)
    n_pass = sum(1 for v in report.values() if v.get("passed"))
    print(f"\n{n_pass}/{len(report)} scenes passing")


if __name__ == "__main__":
    main()
