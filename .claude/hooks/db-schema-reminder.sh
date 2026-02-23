#!/usr/bin/env bash
# Remind Claude to run migrations when schema or auth config is modified.
# Outputs JSON additionalContext so Claude sees the reminder inline.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[[ -z "$FILE_PATH" ]] && exit 0

# Drizzle schema modified → remind to generate migration
if [[ "$FILE_PATH" =~ /db/schema\.ts$ ]]; then
	jq -n '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "Database schema was modified. Remember to run: bun db:generate && bun db:migrate"}}'
	exit 0
fi

# better-auth config modified → remind to regenerate auth schema
if [[ "$FILE_PATH" =~ /server/auth\.ts$ ]]; then
	jq -n '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "better-auth config was modified. If you added/removed plugins, run: bun db:auth && bun db:generate && bun db:migrate"}}'
	exit 0
fi

# Zod validators modified → remind to check tRPC routers match
if [[ "$FILE_PATH" =~ /lib/validators/.*\.ts$ ]]; then
	jq -n '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "Zod validator was modified. Verify that tRPC routers using this schema still type-check: bun typecheck"}}'
	exit 0
fi

exit 0
