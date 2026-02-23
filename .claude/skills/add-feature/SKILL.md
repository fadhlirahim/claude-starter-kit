---
name: add-feature
description: Add a new feature following the project's fullstack conventions
user-invocable: true
argument-hint: feature description
---

Add a new feature to the application: $ARGUMENTS

## Steps

1. **Understand**: Read CLAUDE.md conventions and explore related existing code
2. **Schema first**: Define Zod 4 validators in `src/lib/validators/` (use `zod/v4`, prefer `z.email()`, `z.uuid()` etc)
3. **Database** (if needed): Add Drizzle schema in `src/server/db/schema.ts`, run `bun db:generate && bun db:migrate`
4. **Backend**: Create tRPC router in `src/server/trpc/routers/`, wire into root router
5. **Frontend**: Create route file(s) in `src/routes/`, components in `src/components/`
6. **Validate**: `bun typecheck && bun check && bun test`

## Conventions Reminder

- Named exports only (exception: route files)
- Validate all inputs with Zod 4 (`zod/v4`)
- Use `protectedProcedure` for authenticated endpoints
- Use `useTRPC()` + `useQuery()`/`useMutation()` for data fetching
- Invalidate queries after mutations
- Keep components under 150 lines
- Use `createServerFn` for server-only operations (never access `process.env` in loaders)
