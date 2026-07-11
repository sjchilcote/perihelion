"""tools/dialogue/triangle_round3/format_lint.py

Round-3 fix #1 (biggest leverage, 10/12 round-2 trials cited it): FORMAT
PARITY VIA CODE, not prompting. A generation's surface conventions (session
header, repeated-block idiom, trust-tag bracket style) are the cheapest,
most decisive tell a blind judge has -- round 2 proved the model will not
reliably reproduce them from instructions alone, so this module enforces
them mechanically, post-hoc, on any candidate text.

Three deterministic passes, in order:
  1. normalize_header   -- replace whatever session-open lines the
     generation wrote with the scene's exact truth convention (scene0: the
     3-line CARRIER DETECT / PROTOCOL NEGOTIATION / LIVE COMMUNICATION
     header; t1: the single collapsed LIVE COMMUNICATION line only, per
     the t1 brief's explicit "do NOT write the dotted cold-open lines").
  2. normalize_trust_tags -- rewrite any TRUST delta annotation, regardless
     of the bracket style the model chose, into the scene's own convention
     (scene0: `<TRUST +N>` angle brackets; t1: `[TRUST + N]` square
     brackets with spaces). Scenes differ on purpose -- this is per-scene
     parity, not global normalization.
  3. collapse_repeated_blocks -- detect a contiguous run of paragraphs
     (the "loredump" idiom) that appears more than once at >=80%
     similarity, keep the first occurrence (tagged `<:label>`), and
     replace every later occurrence with `<goto :label>`. This is what
     round 2's t1 candidates got wrong: they wrote the shared loredump out
     verbatim under every branch that reaches it (and tripled the
     [EXCISED SPAN B] marker along with it) instead of using the script's
     own goto/label macro.

Emphasis markup (underscores/asterisks) is deliberately left untouched --
round 2's brief already asked for it and over-inserting it is its own tell.

Every transformation is appended to a log list of strings; run twice on
the same input, the second run's log is empty (idempotent) because there
is nothing left to fix.

CLI:
    uv run python tools/dialogue/triangle_round3/format_lint.py <scene> <in.txt> [out.txt]
    uv run python tools/dialogue/triangle_round3/format_lint.py --all
        (lints every round2 candidate AND every round3 candidate on disk,
        writes linted copies alongside originals with a `.linted.txt`
        suffix, and prints a transformation-log summary)
"""
from __future__ import annotations

import difflib
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROUND2_DIR = HERE.parent / "triangle_round2" / "candidates"
ROUND3_CAND_DIR = HERE / "candidates"

LIVE_LINE = (
    "LIVE COMMUNICATION ESTABLISHED - UTF-8 / TCP / IPv8 / I2C 16000 BAUD - "
    "UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>"
)
CARRIER_LINE = "CARRIER DETECT . . . . . . . ."
NEGOTIATION_LINE = "ATTEMPTING PROTOCOL NEGOTIATION . . . . . . . . . . . ."

CANONICAL_HEADER = {
    "scene0": [CARRIER_LINE, NEGOTIATION_LINE, LIVE_LINE],
    "t1": [LIVE_LINE],
}

LIVE_RE = re.compile(r"^.*LIVE COMMUNICATION ESTABLISHED.*$", re.MULTILINE)

TRUST_RE = re.compile(
    r"[<\[]\s*TRUST\s*([+-])\s*(\d+)\s*[>\]]", re.IGNORECASE
)


def _fmt_trust(scene: str, sign: str, num: str) -> str:
    if scene == "scene0":
        return f"<TRUST {sign}{num}>"
    return f"[TRUST {sign} {num}]"


# ---------------------------------------------------------------------------
# Pass 1: session header
# ---------------------------------------------------------------------------


def normalize_header(text: str, scene: str, log: list[str]) -> str:
    m = LIVE_RE.search(text)
    canonical = CANONICAL_HEADER[scene]
    if not m:
        new_text = "\n".join(canonical) + "\n\n" + text.lstrip("\n")
        log.append(
            f"header: no LIVE COMMUNICATION line found; prepended canonical "
            f"{scene} header ({len(canonical)} line(s))"
        )
        return new_text

    before = text[: m.start()]
    after = text[m.end():]
    after = after.lstrip("\n")
    canonical_before = "\n".join(canonical[:-1]) + ("\n" if len(canonical) > 1 else "")
    old_header_block = text[: m.end()]
    new_header_block = "\n".join(canonical)
    if old_header_block.strip() == new_header_block.strip():
        return text  # already canonical -- idempotent no-op
    log.append(
        f"header: replaced {scene} session-open block "
        f"({old_header_block.count(chr(10)) + 1} line(s)) with canonical "
        f"{len(canonical)}-line header"
    )
    return new_header_block + "\n\n" + after


# ---------------------------------------------------------------------------
# Pass 2: trust-tag bracket style
# ---------------------------------------------------------------------------


def normalize_trust_tags(text: str, scene: str, log: list[str]) -> str:
    def repl(m: re.Match) -> str:
        sign, num = m.group(1), m.group(2)
        old = m.group(0)
        new = _fmt_trust(scene, sign, num)
        if old != new:
            log.append(f"trust-tag: {old!r} -> {new!r}")
        return new

    return TRUST_RE.sub(repl, text)


# ---------------------------------------------------------------------------
# Pass 3: repeated-block collapse -> <:label> / <goto :label>
# ---------------------------------------------------------------------------

MIN_RUN_WORDS = 30
MIN_PARA_CHARS = 20
SIM_THRESHOLD = 0.80


def _norm(p: str) -> str:
    return re.sub(r"\s+", " ", p.strip().lower())


def _ratio(a: str, b: str) -> float:
    na, nb = _norm(a), _norm(b)
    if not na and not nb:
        return 1.0  # two blank lines "match" -- lets a run's interior
        # blank-line spacing align across occurrences regardless of
        # whether the generation used blank-line-separated paragraphs or
        # single-newline-separated lines within a branch.
    if not na or not nb:
        return 0.0
    return difflib.SequenceMatcher(None, na, nb).ratio()


def collapse_repeated_blocks(text: str, log: list[str]) -> str:
    # Operate at LINE granularity, not blank-line-delimited paragraphs:
    # some generations separate every line with a blank line (paragraph
    # style), others write a whole branch as consecutive single-newline
    # lines with no interior blanks (F4's editor pass does this). Line-
    # level matching handles both uniformly; MIN_RUN_WORDS still guards
    # against collapsing short, coincidentally-repeated single lines.
    paras = text.splitlines()
    n = len(paras)

    def extend(i: int, j: int) -> int:
        length = 0
        while i + length < j and j + length < n and _ratio(
            paras[i + length], paras[j + length]
        ) >= SIM_THRESHOLD:
            length += 1
        return length

    # Anchor-based clustering: for each unused paragraph i (scanning in
    # order, so the FIRST occurrence in the document is always the anchor),
    # find every later unused j whose block matches i's block, using i as
    # the common reference point for all of them (not pairwise greedy --
    # pairwise greedy mis-handles 3+ occurrences of the same block, since
    # selecting the (1st,2nd) pair by score can starve the (1st,3rd) pair
    # of its shared anchor).
    used = [False] * n
    labels: dict[int, str] = {}
    replace_with_goto: dict[int, tuple[int, int]] = {}  # j -> (i, length)
    counter = 0
    for i in range(n):
        if used[i] or len(_norm(paras[i])) < MIN_PARA_CHARS:
            continue
        if paras[i].strip().startswith("<:") or paras[i].strip().startswith("<goto"):
            continue
        valid = []
        for j in range(i + 1, n):
            if used[j] or _ratio(paras[i], paras[j]) < SIM_THRESHOLD:
                continue
            length = extend(i, j)
            if length == 0:
                continue
            words = sum(len(paras[i + k].split()) for k in range(length))
            if words >= MIN_RUN_WORDS:
                valid.append((j, length))
        if not valid:
            continue
        first_line = paras[i].strip().splitlines()[0].lower()
        if "in short" in first_line or "loredump" in first_line:
            label = "loredump"
        else:
            counter += 1
            label = f"block{counter}"
        labels[i] = label
        max_len = max(length for _, length in valid)
        for k in range(max_len):
            if i + k < n:
                used[i + k] = True
        for j, length in valid:
            replace_with_goto[j] = (i, length)
            for k in range(length):
                used[j + k] = True

    if not labels:
        return text

    # build output paragraph list
    out_paras = []
    idx = 0
    j_to_i_len = replace_with_goto
    while idx < n:
        if idx in j_to_i_len:
            i0, length = j_to_i_len[idx]
            label = labels[i0]
            out_paras.append(f"<goto :{label}>")
            log.append(
                f"repeated-block: collapsed lines [{idx}:{idx + length}] "
                f"(dup of [{i0}:{i0 + length}]) -> <goto :{label}>"
            )
            idx += length
            continue
        if idx in labels:
            label = labels[idx]
            already_labeled = paras[idx].strip().startswith(f"<:{label}>")
            if not already_labeled:
                out_paras.append(f"<:{label}>\n{paras[idx]}")
                log.append(f"repeated-block: tagged first occurrence with <:{label}>")
            else:
                out_paras.append(paras[idx])
            idx += 1
            continue
        out_paras.append(paras[idx])
        idx += 1

    return "\n".join(out_paras)


# ---------------------------------------------------------------------------
# driver
# ---------------------------------------------------------------------------


def lint(text: str, scene: str) -> tuple[str, list[str]]:
    assert scene in ("scene0", "t1"), f"unknown scene {scene!r}"
    log: list[str] = []
    text = normalize_header(text, scene, log)
    text = normalize_trust_tags(text, scene, log)
    text = collapse_repeated_blocks(text, log)
    return text, log


def _scene_for_path(p: Path) -> str:
    return "scene0" if p.stem.startswith("scene0") else "t1"


def _lint_all() -> None:
    summary: dict[str, list[str]] = {}
    for d in (ROUND2_DIR, ROUND3_CAND_DIR):
        if not d.exists():
            continue
        for p in sorted(d.glob("*.txt")):
            if p.stem.endswith(".linted") or p.stem.endswith(".degenerate"):
                continue
            scene = _scene_for_path(p)
            text = p.read_text()
            linted, log = lint(text, scene)
            out_path = p.with_name(p.stem + ".linted.txt")
            out_path.write_text(linted)
            # idempotency check
            linted2, log2 = lint(linted, scene)
            assert linted2 == linted, f"NOT IDEMPOTENT: {p}"
            assert log2 == [], f"NOT IDEMPOTENT (log non-empty on 2nd pass): {p} -> {log2}"
            summary[str(p.relative_to(HERE.parent))] = log
            print(f"{p.name}: {len(log)} transformation(s)")
            for line in log:
                print(f"    {line}")
    n_transformed = sum(1 for v in summary.values() if v)
    print(f"\n{n_transformed}/{len(summary)} files had at least one transformation.")
    print("idempotency: verified on every file (2nd pass log always empty).")


if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "--all":
        _lint_all()
    elif len(sys.argv) >= 3:
        scene = sys.argv[1]
        in_path = Path(sys.argv[2])
        out_path = Path(sys.argv[3]) if len(sys.argv) > 3 else None
        text = in_path.read_text()
        linted, log = lint(text, scene)
        if out_path:
            out_path.write_text(linted)
        else:
            sys.stdout.write(linted)
        for line in log:
            print(f"  {line}", file=sys.stderr)
    else:
        print(__doc__)
        sys.exit(1)
