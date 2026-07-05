#!/usr/bin/env bash
# Hook: beforeShellExecution — warn before destructive Flutter/Git commands.

set -euo pipefail

input_json="$(cat)"
command=""

if command -v python3 >/dev/null 2>&1; then
  command="$(printf '%s' "$input_json" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print((data.get('command') or '').lower())
except Exception:
    print('')
" 2>/dev/null || true)"
fi

patterns=(
  'flutter clean'
  'git reset --hard'
  'git push --force'
  'git push -f'
  'git rebase'
  'drop table'
  'truncate table'
  'rm -rf'
)

for pattern in "${patterns[@]}"; do
  if [[ "$command" == *"$pattern"* ]]; then
    printf '%s\n' "{\"permission\":\"ask\",\"user_message\":\"This command matches a potentially destructive pattern ('$pattern'). Review carefully before proceeding.\",\"agent_message\":\"Flagged as destructive command — user confirmation required.\"}"
    exit 0
  fi
done

printf '%s\n' '{"permission":"allow"}'
exit 0
