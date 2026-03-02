#!/usr/bin/env bash
# After substantial TypeScript changes, block Claude from finishing and ask it to
# run /simplify then code-reviewer before wrapping up.
#
# Threshold: 3+ modified TypeScript source files (excludes tests and generated files).
# Loop protection: stop_hook_active prevents re-triggering after review completes.

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loop — skip when Claude is already in a stop hook continuation
[[ "$STOP_HOOK_ACTIVE" == "true" ]] && exit 0

# Find changed TypeScript source files (src/ only, no tests/generated)
CHANGED_FILES=$(git -C "$CLAUDE_PROJECT_DIR" diff --name-only HEAD 2>/dev/null \
	| grep -E '^src/.+\.(ts|tsx)$' \
	| grep -vE '(\.test\.|\.spec\.|routeTree\.gen\.ts|/drizzle/)' \
	| head -20)

[[ -z "$CHANGED_FILES" ]] && exit 0

COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
[[ "$COUNT" -lt 3 ]] && exit 0

# Build a short file list for the message (max 5 shown)
FILE_LIST=$(echo "$CHANGED_FILES" | head -5 | tr '\n' ' ' | sed 's/ $//')
[[ "$COUNT" -gt 5 ]] && FILE_LIST="$FILE_LIST ..."

jq -n \
	--argjson count "$COUNT" \
	--arg files "$FILE_LIST" \
	'{
    decision: "block",
    reason: ("Implementation complete: " + ($count | tostring) + " TypeScript files modified (" + $files + "). Before finishing, please:\n1. Run /simplify on the changed files to clean up.\n2. Run the code-reviewer agent to verify conventions (auth guards, Zod 4 patterns, tRPC usage, type safety).\n3. Run `bun typecheck && bun check` to verify everything passes.")
  }'
