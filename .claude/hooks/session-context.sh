#!/usr/bin/env bash
# Re-anchor git state after context compaction. The compaction summary is
# model-written under token pressure and can paraphrase commit messages,
# drop SHAs, or hallucinate work Claude "intended" to commit. `git` is
# ground truth — surface it so Claude doesn't pile new work on unsaved
# changes or redo code that's already shipped.
#
# We deliberately do NOT re-inject CLAUDE.md content here. CLAUDE.md is in
# the system reminder block and survives compaction; duplicating it costs
# tokens for content that was never lost. Put project-specific reminders
# in CLAUDE.md, not in this hook.

set -u

BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" branch --show-current 2>/dev/null)
[[ -z "$BRANCH" ]] && exit 0

# Pick a sensible base for "what's on this branch" — main, master, or
# fall back to the previous commit if neither exists.
for CANDIDATE in main master; do
	if git -C "$CLAUDE_PROJECT_DIR" rev-parse --verify --quiet "$CANDIDATE" >/dev/null; then
		BASE="$CANDIDATE"
		break
	fi
done
BASE="${BASE:-HEAD~1}"

RECENT=$(git -C "$CLAUDE_PROJECT_DIR" log "$BASE..HEAD" --oneline 2>/dev/null | head -10)
BRANCH_STAT=$(git -C "$CLAUDE_PROJECT_DIR" diff --stat "$BASE..HEAD" 2>/dev/null)
UNSTAGED_STAT=$(git -C "$CLAUDE_PROJECT_DIR" diff --stat 2>/dev/null)
STAGED_STAT=$(git -C "$CLAUDE_PROJECT_DIR" diff --stat --cached 2>/dev/null)
UNTRACKED=$(git -C "$CLAUDE_PROJECT_DIR" ls-files --others --exclude-standard 2>/dev/null)

echo "### Git state at compaction"
echo "Branch: $BRANCH (base: $BASE)"

if [[ -n "$RECENT" ]]; then
	echo ""
	echo "Commits on this branch:"
	echo "$RECENT" | sed 's/^/  /'
fi

if [[ -n "$BRANCH_STAT" ]]; then
	echo ""
	echo "Files changed on this branch (vs $BASE):"
	echo "$BRANCH_STAT" | sed 's/^/  /'
fi

if [[ -n "$STAGED_STAT" ]]; then
	echo ""
	echo "Staged but not committed:"
	echo "$STAGED_STAT" | sed 's/^/  /'
fi

if [[ -n "$UNSTAGED_STAT" ]]; then
	echo ""
	echo "Uncommitted edits (unstaged):"
	echo "$UNSTAGED_STAT" | sed 's/^/  /'
fi

if [[ -n "$UNTRACKED" ]]; then
	echo ""
	echo "Untracked files:"
	echo "$UNTRACKED" | sed 's/^/  /'
fi

echo ""
echo "If any of this is news to you, the compaction summary may have drifted — trust git here."

exit 0
