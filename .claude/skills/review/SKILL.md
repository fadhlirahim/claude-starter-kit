---
name: review
description: Review code changes for quality, security, and adherence to project conventions
user-invocable: true
context: fork
agent: general-purpose
---

Review the code changes in this project for quality, correctness, and adherence to CLAUDE.md conventions.

## Review Checklist

1. **Type Safety**: No `any` types, proper Zod 4 validation (`zod/v4` import), tRPC input schemas
2. **Auth Security**: Protected routes use `_authed` layout, tRPC uses `protectedProcedure`, `getRequestHeaders()` passed to `auth.api.getSession()`
3. **Data Fetching**: Uses tRPC + TanStack Query (new `useTRPC()` pattern), no raw fetch or useEffect for data
4. **Server/Client Boundary**: No `process.env` in loaders (use `createServerFn`), `useSuspenseQuery` for SSR
5. **Error Handling**: Proper `TRPCError` codes, `errorComponent` on routes, no swallowed errors
6. **Conventions**: Named exports, Zod 4 API (`.extend()` not `.merge()`, `z.email()` not `z.string().email()`), Biome compliance
7. **Performance**: No unnecessary re-renders, proper Suspense boundaries, query invalidation after mutations
8. **Database**: Parameterized queries via Drizzle, proper where clauses, no N+1
9. **better-auth**: `tanstackStartCookies()` is last plugin, `input: false` on sensitive fields

## Instructions

- Run `git diff` to see staged/unstaged changes, or review the files specified: $ARGUMENTS
- For each issue found, cite the file:line and explain why it's a problem
- Categorize findings as: CRITICAL | WARNING | SUGGESTION
- At the end, give a summary verdict: APPROVE, REQUEST CHANGES, or NEEDS DISCUSSION
