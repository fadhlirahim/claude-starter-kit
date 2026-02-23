---
name: refactor
description: Refactor code while maintaining identical behavior
user-invocable: true
argument-hint: target code or area
---

Refactor the specified code area while maintaining identical behavior: $ARGUMENTS

## Process

1. **Read** the target code and its tests (if any)
2. **Identify** the refactoring target:
   - Extract component/function
   - Move file to better location
   - Rename for clarity
   - Split large file
   - Consolidate scattered related code
3. **Plan** the refactoring steps (share with user before executing)
4. **Execute** incrementally — one change at a time
5. **Verify** after each step: `bun typecheck && bun check && bun test`

## Rules

- Behavior must be IDENTICAL after refactoring
- If tests exist, they must pass without changes (unless the test itself is being refactored)
- Update all imports/references when moving or renaming
- If no tests exist for the refactored code, write basic regression tests first
