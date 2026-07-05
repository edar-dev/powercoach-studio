#!/usr/bin/env bash
# Hook: afterFileEdit — remind the agent to run build_runner when Drift table files change.

set -euo pipefail

input_json="$(cat)"
file_path=""

if command -v python3 >/dev/null 2>&1; then
  file_path="$(printf '%s' "$input_json" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input') or {}
    print(tool_input.get('path') or '')
except Exception:
    print('')
" 2>/dev/null || true)"
fi

if [[ "$file_path" == *app_database.dart* ]] || [[ "$file_path" == *lib/core/storage/* ]]; then
  printf '%s\n' '{"additional_context":"IMPORTANT: You just edited a Drift database file. Remember to regenerate the code before running the app: dart run build_runner build --delete-conflicting-outputs"}'
else
  printf '%s\n' '{}'
fi

exit 0
