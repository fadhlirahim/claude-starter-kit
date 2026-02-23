---
name: debug
description: Debug issues systematically by tracing data flow through the fullstack
user-invocable: true
argument-hint: description of the issue
---

Debug the specified issue systematically: $ARGUMENTS

## Process

1. **Reproduce**: Understand the symptoms. Check browser console, server logs, terminal output.
2. **Isolate**: Narrow down to the specific file/function. Use `git diff` to check recent changes.
3. **Trace the data flow**:
   - Frontend: Component -> `useTRPC()` hook -> `useQuery()`/`useMutation()` -> network
   - Backend: tRPC procedure -> middleware (isAuthed) -> handler -> Drizzle query
   - Auth: `getSession()` (with `getRequestHeaders()`) -> tRPC context -> `protectedProcedure`
4. **Check common causes**:
   - Type mismatch between Zod schema and Drizzle schema
   - Missing query invalidation after mutation
   - Auth session not available (missing `_authed` layout, or forgot `getRequestHeaders()`)
   - Stale TanStack Query cache
   - Wrong Zod import (using `zod` instead of `zod/v4`)
   - Using `.merge()` instead of `.extend()` (Zod 4 change)
   - `process.env` accessed in loader instead of `createServerFn`
   - `useQuery` used where `useSuspenseQuery` needed for SSR
   - `tanstackStartCookies()` not last in better-auth plugins
   - Drizzle query builder misuse (check `.where()` syntax)
5. **Fix**: Apply minimal fix. Don't refactor surrounding code.
6. **Verify**: Run typecheck and relevant tests.
