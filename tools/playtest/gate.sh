#!/bin/bash
# The commit gate. The prompt IS the gate; everything else is a
# supporting tool the judge invokes itself through the CLI.
set -e
cd "$(git rev-parse --show-toplevel)"
# lifecycle markers for gate_wait.sh: pid at start, exit code at the
# end (trap covers judge failure too). A missing gate.exit with a dead
# pid means the gate was killed (OOM) — the waiter reports that as such.
mkdir -p out/eval_gate
rm -f out/eval_gate/gate.exit
echo $$ > out/eval_gate/gate.pid
trap 'echo $? > out/eval_gate/gate.exit' EXIT
claude -p "$(cat tools/playtest/GATE_PROMPT.md)" --model fable \
    --output-format json \
    --allowedTools "Read,Grep,Glob,Bash,Agent,Task,Write" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['result'])"
test -f out/eval_gate/PASS
