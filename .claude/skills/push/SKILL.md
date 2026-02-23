---
name: push
description: Commit all changes, push to remote, and create a pull request with a comprehensive description
user-invocable: true
argument-hint: [optional PR title or description]
allowed-tools: ["Bash", "Read", "Glob", "Grep"]
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD --stat`
- Current branch: !`git branch --show-current`
- Recent commits on branch: !`git log main..HEAD --oneline 2>/dev/null || git log --oneline -5`
- Remote tracking: !`git rev-parse --abbrev-ref @{u} 2>/dev/null || echo "no upstream"`

## Your Task

Create a commit, push, and open a PR for the current changes. Follow these steps precisely:

### 1. Analyze Changes

- Run `git status` to see all untracked and modified files
- Run `git diff HEAD` to see the full diff of what will be committed
- Run `git log main..HEAD --oneline` to see all commits on this branch
- Understand the full scope of changes (not just the latest commit — ALL commits on the branch)

### 2. Create Branch (if needed)

If currently on `main` or `master`:
- Create a descriptive branch: `git checkout -b <type>/<short-description>`
- Types: `feat/`, `fix/`, `refactor/`, `chore/`, `docs/`

### 3. Stage and Commit

- Stage relevant files (prefer specific files over `git add -A`)
- NEVER stage `.env`, credentials, or secrets
- Draft a commit message that:
  - Follows conventional commits (`feat:`, `fix:`, `refactor:`, `chore:`)
  - Matches the repository's existing commit style
  - Focuses on WHY, not WHAT
  - Ends with `Co-Authored-By: Claude <noreply@anthropic.com>`
- Use a HEREDOC for the commit message

### 4. Push

- Push with upstream tracking: `git push -u origin <branch-name>`
- If push fails due to divergence, inform the user — do NOT force push

### 5. Create Pull Request

Use `gh pr create` with a comprehensive description:

```bash
gh pr create --title "<concise title under 70 chars>" --body "$(cat <<'EOF'
## Summary

<1-3 bullet points describing what this PR does and why>

## Changes

<grouped list of notable changes by area — e.g., API, UI, Database, Auth>

## Test Plan

- [ ] <specific verification steps>
- [ ] Types pass (`bun typecheck`)
- [ ] Lint passes (`bun check`)
- [ ] Tests pass (`bun test`)

---
Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 6. Report

Output the PR URL so the user can review it.

## Rules

- Analyze ALL commits on the branch for the PR description, not just the latest
- Keep PR title under 70 chars — use the body for details
- Group changes by area (API, UI, Database, Auth, Config) in the description
- Include specific test plan items, not just "test it"
- NEVER force push
- NEVER push to main/master directly
- If user provided $ARGUMENTS, use it to inform the PR title/description
