#!/usr/bin/env bash
# Send macOS desktop notifications when Claude needs attention.
# Differentiates between permission prompts and idle prompts with distinct sounds.

command -v osascript &>/dev/null || exit 0

INPUT=$(cat)
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')

case "$NOTIFICATION_TYPE" in
"permission_prompt")
	MESSAGE="Claude is requesting permission for an action"
	SOUND="Glass"
	;;
"idle_prompt")
	MESSAGE="Claude is waiting for your input"
	SOUND="Ping"
	;;
*)
	exit 0
	;;
esac

osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\" sound name \"$SOUND\"" 2>/dev/null || true

exit 0
