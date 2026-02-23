---
name: clean-branches
description: Clean up local git branches that have been deleted from the remote
user-invocable: true
allowed-tools: ["Bash"]
---

## Your Task

Clean up stale local branches that have been deleted from the remote repository.

1. **List branches** to identify any with `[gone]` status:
   ```bash
   git fetch --prune && git branch -v
   ```

2. **List worktrees** that may need removal:
   ```bash
   git worktree list
   ```

3. **Remove worktrees and delete [gone] branches**:
   ```bash
   git branch -v | grep '\[gone\]' | sed 's/^[+* ]//' | awk '{print $1}' | while read branch; do
     echo "Processing branch: $branch"
     worktree=$(git worktree list | grep "\\[$branch\\]" | awk '{print $1}')
     if [ ! -z "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
       echo "  Removing worktree: $worktree"
       git worktree remove --force "$worktree"
     fi
     echo "  Deleting branch: $branch"
     git branch -D "$branch"
   done
   ```

4. Report which branches and worktrees were removed, or that no cleanup was needed.
