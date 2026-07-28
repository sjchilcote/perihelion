#!/bin/bash
# Wait for the gate and report the verdict. Watches gate.sh's OWN
# lifecycle markers (gate.pid / gate.exit), never process patterns —
# `pgrep -f gate.sh` from a watcher matches the watcher's own command
# line and waits on itself forever (learned 2026-07-28, run 51).
#
#   tools/playtest/gate_wait.sh [timeout_seconds]
#
# Exit: 0 gate PASS, 1 gate FAIL, 2 gate died without finishing,
#       3 timeout, 4 no gate ever started.
set -u
cd "$(git rev-parse --show-toplevel)"
G=out/eval_gate
TIMEOUT="${1:-5400}"
START=$(date +%s)

[ -f "$G/gate.pid" ] || { echo "no $G/gate.pid — no gate running"; exit 4; }

report() {
    python3 - <<'EOF'
import json
v = json.load(open("out/eval_gate/verdict.json"))
print(f"p = {v.get('p')}  pass = {v.get('pass')}  "
      f"blockers = {len(v.get('blockers', []))}")
for b in v.get("blockers", []):
    t = b.get("title", b) if isinstance(b, dict) else b
    print(f"  BLOCKER: {t}")
EOF
    [ -f "$G/PASS" ] && echo "PASS marker present" || echo "no PASS marker"
}

while true; do
    if [ -f "$G/gate.exit" ] && [ "$G/gate.exit" -nt "$G/gate.pid" ]; then
        code=$(cat "$G/gate.exit")
        echo "gate finished (exit $code)"
        [ -f "$G/verdict.json" ] && report
        [ "$code" = 0 ] && exit 0 || exit 1
    fi
    pid=$(cat "$G/gate.pid")
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "gate (pid $pid) died without writing gate.exit — OOM-kill?"
        tail -5 "$G"/gate_run*.log 2>/dev/null | tail -8
        exit 2
    fi
    if [ $(( $(date +%s) - START )) -ge "$TIMEOUT" ]; then
        echo "still running after ${TIMEOUT}s (pid $pid)"
        exit 3
    fi
    sleep 30
done
