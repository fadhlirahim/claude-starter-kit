#!/usr/bin/env bash
# Inject current git state into every prompt so Claude always knows:
# - what branch it's on
# - what's already been committed this session
# - what files are changed but not yet committed
#
# Stdout from UserPromptSubmit hooks is added directly to Claude's context.

BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" branch --show-current 2>/dev/null)
[[ -z "$BRANCH" ]] && exit 0

# Recent commits on this branch vs main (max 8)
RECENT=$(git -C "$CLAUDE_PROJECT_DIR" log main..HEAD --oneline 2>/dev/null | head -8)

# Uncommitted changes
UNCOMMITTED=$(git -C "$CLAUDE_PROJECT_DIR" diff --name-only HEAD 2>/dev/null)
UNCOMMITTED_COUNT=$(echo "$UNCOMMITTED" | grep -c '.' 2>/dev/null || echo 0)
[[ -z "$UNCOMMITTED" ]] && UNCOMMITTED_COUNT=0

# Only output if there's something useful to show
if [[ -z "$RECENT" && "$UNCOMMITTED_COUNT" -eq 0 ]]; then
	exit 0
fi

echo "### Git context"
echo "Branch: $BRANCH"

if [[ -n "$RECENT" ]]; then
	echo "Commits on this branch:"
	echo "$RECENT" | sed 's/^/  /'
fi

if [[ "$UNCOMMITTED_COUNT" -gt 0 ]]; then
	echo "Uncommitted ($UNCOMMITTED_COUNT files): $(echo "$UNCOMMITTED" | tr '\n' ' ' | sed 's/ $//')"
fi
