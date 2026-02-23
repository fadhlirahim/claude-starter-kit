---
name: compound
description: Extract and persist learnings from the current session into CLAUDE.md and project rules
user-invocable: true
---

Review the work done in this session and extract learnings that compound future productivity.

## Process

1. **Review changes**: Run `git diff` and `git log` to see what was done this session
2. **Identify patterns**: Look for:
   - Architectural decisions made
   - New conventions established
   - Gotchas or non-obvious behaviors discovered
   - Common mistakes that were fixed
   - Stack-specific quirks (TanStack, tRPC, better-auth, Drizzle, Zod 4)
3. **Update CLAUDE.md**: Add new conventions or anti-patterns if broadly applicable
4. **Update .claude/rules/**: Create topic-specific rule files for detailed patterns
5. **Verify**: Ensure updates are accurate and not duplicating existing instructions

## What to Compound

- New file patterns or naming conventions
- New integration patterns between stack layers
- Debugging insights specific to the stack
- Performance patterns discovered
- Auth/security patterns

## What NOT to Compound

- One-off task-specific details
- Things Claude already does correctly without instruction
- Speculative conclusions from a single case
