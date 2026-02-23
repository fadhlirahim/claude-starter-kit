---
name: docs
description: Look up current documentation for any library in the stack using Context7
user-invocable: true
argument-hint: library-name topic
---

Look up documentation for: $ARGUMENTS

## Process

1. Resolve the library ID with `mcp__context7__resolve-library-id` using the library name
2. Query docs with `mcp__context7__query-docs` for the specified topic
3. Present the relevant documentation clearly with code examples

## Stack Libraries

| Library | Notes |
|---------|-------|
| tanstack-start | SSR framework, server functions, deployment |
| tanstack-router | File-based routing, search params, loaders |
| tanstack-query | Queries, mutations, suspense, prefetching |
| tanstack-form | Form state, validation, field arrays |
| trpc | Routers, procedures, middleware |
| better-auth | Auth setup, providers, sessions, plugins |
| drizzle-orm | Schema, queries, migrations, relations |
| zod | Schemas, validation (use v4 docs) |
| biome | Linting, formatting, configuration |
| vitest | Test runner, assertions, mocking |
