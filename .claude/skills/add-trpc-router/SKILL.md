---
name: add-trpc-router
description: Create a new tRPC router for a domain/feature with CRUD procedures
user-invocable: true
argument-hint: router-name
---

Create a new tRPC router for: **$ARGUMENTS**

## Steps

### 1. Create Zod validators: `src/lib/validators/$0.ts`
```typescript
import { z } from 'zod/v4'

export const [Entity]Schema = z.object({
  id: z.uuid(),
  // ... fields
  createdAt: z.date(),
  updatedAt: z.date(),
})

export const Create[Entity]Schema = [Entity]Schema.omit({ id: true, createdAt: true, updatedAt: true })
export const Update[Entity]Schema = [Entity]Schema.partial().extend({ id: z.uuid() })

export type [Entity] = z.output<typeof [Entity]Schema>
```

### 2. Create router: `src/server/trpc/routers/$0.ts`
```typescript
import { z } from 'zod/v4'
import { protectedProcedure, publicProcedure, router } from '../init'

export const [name]Router = router({
  list: protectedProcedure.query(async ({ ctx }) => { /* ... */ }),
  byId: protectedProcedure
    .input(z.object({ id: z.uuid() }))
    .query(async ({ ctx, input }) => { /* ... */ }),
  create: protectedProcedure
    .input(Create[Entity]Schema)
    .mutation(async ({ ctx, input }) => { /* ... */ }),
  update: protectedProcedure
    .input(Update[Entity]Schema)
    .mutation(async ({ ctx, input }) => { /* ... */ }),
  delete: protectedProcedure
    .input(z.object({ id: z.uuid() }))
    .mutation(async ({ ctx, input }) => { /* ... */ }),
})
```

### 3. Wire into root router: `src/server/trpc/router.ts`
Add `$0: [name]Router` to the root router.

### 4. Verify: `bun typecheck`
