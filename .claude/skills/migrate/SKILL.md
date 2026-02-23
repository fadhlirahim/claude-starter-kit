---
name: migrate
description: Create and apply a database migration for schema changes
user-invocable: true
argument-hint: description of schema change
---

Create a database migration for: $ARGUMENTS

## Process

1. **Read** current schema at `src/server/db/schema.ts`
2. **Modify** the schema as needed (add table, add column, modify relation)
3. **Generate** migration: `bun db:generate`
4. **Review** the generated SQL in `drizzle/` folder
5. **Apply**: `bun db:migrate`
6. **Update** Zod validators in `src/lib/validators/` to match schema changes
7. **Update** tRPC routers if the schema change affects API surface
8. **Typecheck**: `bun typecheck`

## Drizzle Schema Conventions

- Table names: plural, snake_case (`users`, `blog_posts`)
- Column names: snake_case (`created_at`, `user_id`)
- Always include `id`, `createdAt`, `updatedAt` columns
- Use `pgTable` for PostgreSQL
- Define relations separately with `relations()`
- Export both the table and its relations

## If Adding better-auth Plugin Tables

Run `bun db:auth` first to regenerate the better-auth schema, then `bun db:generate && bun db:migrate`.
