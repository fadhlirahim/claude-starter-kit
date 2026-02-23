---
name: commit
description: Create a git commit with an auto-generated message matching the repo's style
user-invocable: true
argument-hint: [optional commit message hint]
allowed-tools: ["Bash"]
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your Task

Create a single git commit based on the above changes.

1. Review the diff to understand what changed and why
2. Check recent commit messages to match the repository's style
3. Stage relevant files (prefer specific files over `git add -A`)
4. NEVER stage `.env`, credentials, or secrets
5. Create the commit with a message that:
   - Follows conventional commits (`feat:`, `fix:`, `refactor:`, `chore:`)
   - Focuses on the WHY, not the WHAT
   - Is concise (1-2 sentences)
   - Ends with `Co-Authored-By: Claude <noreply@anthropic.com>`
6. Use a HEREDOC for the commit message
7. Run `git status` after to verify

If user provided $ARGUMENTS, use it to inform the commit message.

You MUST do all of the above in a single message. Do not send any other text besides the tool calls.
