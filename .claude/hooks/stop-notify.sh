#!/usr/bin/env bash
# Send macOS notification when Claude finishes responding.
# Guards against infinite loops via stop_hook_active check.

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loops — if we're already in a stop hook continuation, skip
[[ "$STOP_HOOK_ACTIVE" == "true" ]] && exit 0

command -v osascript &>/dev/null || exit 0

osascript -e 'display notification "Claude has finished" with title "Claude Code" sound name "Glass"' 2>/dev/null || true

exit 0
