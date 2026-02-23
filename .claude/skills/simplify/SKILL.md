---
name: simplify
description: Simplify and refine code for clarity, consistency, and maintainability while preserving all functionality
user-invocable: true
---

Analyze the specified code (or recent changes) and simplify it while preserving all functionality.

Use code-simplifier:code-simplifier agent for this skill.

Target: $ARGUMENTS

## Simplification Targets

1. **Remove dead code**: Unused imports, variables, functions, types
2. **Reduce nesting**: Early returns, guard clauses
3. **Consolidate duplicates**: Extract only when used 3+ times
4. **Simplify types**: Remove unnecessary generics, use inference
5. **Streamline control flow**: Flatten complex ternaries, simplify conditionals
6. **Leverage the stack**:
   - Manual fetch -> tRPC hooks via `useTRPC()`
   - Manual state for server data -> TanStack Query
   - Manual validation -> Zod 4 schemas
   - Manual auth checks -> `_authed` layout / `protectedProcedure`
   - `z.string().email()` -> `z.email()` (Zod 4 top-level)
   - `.merge()` -> `.extend()` (Zod 4)

## Rules

- NEVER change behavior — only simplify structure
- NEVER add features, comments, or documentation
- NEVER create abstractions for single-use code
- Keep changes minimal and focused
- Run `bun check:fix` after modifications
- Explain each simplification briefly
