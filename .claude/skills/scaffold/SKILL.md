---
name: scaffold
description: Scaffold a complete fullstack feature with database schema, API, and UI
user-invocable: true
argument-hint: feature-name
---

Scaffold a new fullstack feature: **$ARGUMENTS**

## Files to Create (in order)

### 1. Zod Validators: `src/lib/validators/$0.ts`
```
import { z } from 'zod/v4'
- Base schema, CreateSchema, UpdateSchema
- Export inferred types
- Use z.email(), z.uuid() etc (top-level Zod 4 validators)
```

### 2. Drizzle Schema: Update `src/server/db/schema.ts`
- Add table with `pgTable` (plural snake_case name)
- Include `id`, `createdAt`, `updatedAt` columns
- Add relations with `relations()`
- Run `bun db:generate && bun db:migrate`

### 3. tRPC Router: `src/server/trpc/routers/$0.ts`
- CRUD procedures: list, byId, create, update, delete
- Use `protectedProcedure` for authenticated features
- Validate inputs with the Zod schemas from step 1
- Wire into root router at `src/server/trpc/router.ts`

### 4. Route Page: `src/routes/_authed/$0.tsx` (or `src/routes/_public/$0.tsx`)
- File route with `createFileRoute`
- Loader using `queryClient.ensureQueryData()` with tRPC queryOptions
- Component using `useTRPC()` + `useQuery()`/`useMutation()`

### 5. Components: `src/components/$0/`
- List component with query
- Form component using TanStack Form + Zod validation
- Both: `e.preventDefault()` AND `e.stopPropagation()` in form submit

### 6. Verify
- `bun typecheck`
- `bun check`
- `bun test` (if tests exist)
