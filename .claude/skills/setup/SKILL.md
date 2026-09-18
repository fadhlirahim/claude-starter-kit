---
name: setup
description: Bootstrap a TanStack Start project from scratch with the full kit stack (Drizzle, tRPC, better-auth, Zod 4, Biome)
user-invocable: true
argument-hint: (none)
---

Bootstrap this project from zero. The starter kit installed config files; this skill creates the actual source tree wired to the conventions in `CLAUDE.md`.

Run only when `src/` does not yet exist. If it does, **stop and ask** before overwriting — the user probably wants `/add-feature` or `/scaffold` instead.

## Preflight

1. Verify tools: `bun --version`, `git --version`, and PostgreSQL reachable (`psql --version` or a remote URL).
2. Confirm with the user:
   - App name (replaces `[App Name]` in `CLAUDE.md`).
   - Database URL (or accept the `.env.example` default and assume local Postgres).
   - Auth providers wanted now: email/password only, or also GitHub/Google OAuth.
3. Read `CLAUDE.md` once for the exact conventions. Do not duplicate its rules here — follow them.

## Step 1 — Dependencies

Install in two groups so failures are easy to diagnose:

```bash
# runtime
bun add \
  @tanstack/react-router @tanstack/react-router-devtools \
  @tanstack/react-start \
  @tanstack/react-query @tanstack/react-query-devtools \
  @tanstack/react-form @tanstack/zod-adapter \
  @trpc/server @trpc/client @trpc/tanstack-react-query \
  better-auth \
  drizzle-orm postgres \
  zod superjson \
  react react-dom

# dev
bun add -d \
  typescript @types/react @types/react-dom \
  vite @vitejs/plugin-react nitro \
  @biomejs/biome \
  drizzle-kit \
  vitest @testing-library/react @testing-library/jest-dom jsdom
```

If `package.json` already exists with the kit's scripts, don't overwrite — just run the installs above; bun will merge into `dependencies`/`devDependencies`.

## Step 2 — Environment

`.env` is **blocked from writes** by `protect-sensitive.sh` — instruct the user to copy it themselves:

```bash
cp .env.example .env
# then edit .env: set DATABASE_URL and a real BETTER_AUTH_SECRET
# generate a secret: openssl rand -base64 32
```

Do not attempt to write `.env` yourself.

## Step 3 — Vite config

Create `vite.config.ts`. Order matters: `tanstackStart()` **before** `viteReact()`. No Vinxi, no `app.config.ts` — TanStack Start is a plain Vite plugin now, and `nitro()` produces the deployable server in `.output/`.

```ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  server: { port: 3000 },
  resolve: { tsconfigPaths: true },
  plugins: [tanstackStart(), nitro(), viteReact()],
})
```

`resolve.tsconfigPaths` is built into Vite 7+, so `vite-tsconfig-paths` is not needed. The router code-gen plugin is bundled into `tanstackStart()`, so `@tanstack/router-plugin` is not needed either.

Create `tsconfig.json` with `"strict": true`, `"jsx": "react-jsx"`, `"moduleResolution": "bundler"`, and a `@/*` path alias to `src/*`.

## Step 4 — Drizzle

1. `src/server/db/schema.ts` — start with the better-auth tables only (auth `db:auth` will append the rest in step 5). Leave a comment marking where domain tables go.
2. `src/server/db/index.ts` — Drizzle client using `postgres` driver and `process.env.DATABASE_URL`. This file is server-only; never import it from a route component.
3. `drizzle.config.ts` at the repo root pointing to `src/server/db/schema.ts` and `src/server/db/migrations/`.

Don't run migrations yet — wait until after better-auth generates its schema (step 5).

## Step 5 — better-auth

1. `src/server/auth.ts` — `betterAuth({...})` instance. Plugin order is critical: **`tanstackStartCookies()` must be LAST** in the `plugins` array.
2. `src/lib/auth-client.ts` — `createAuthClient` from `better-auth/react` with `inferAdditionalFields<typeof auth>()`.
3. `src/server/auth.server.ts` — `createServerFn` wrappers `getSession()` and `ensureSession()`. Both must pass `getRequestHeaders()` to `auth.api.getSession()`.
4. `src/routes/api/auth/$.ts` — catch-all that mounts `auth.handler`.

Then generate and apply the schema:

```bash
bun db:auth         # appends auth tables to schema.ts
bun db:generate     # creates migration SQL
bun db:migrate      # applies to the database
```

If `bun db:auth` overwrites the file, re-add any domain tables underneath the auth block.

## Step 6 — tRPC

1. `src/server/trpc/init.ts` — `initTRPC.context<Context>().create({ transformer: superjson })`, export `router`, `publicProcedure`, `protectedProcedure` (with `isAuthed` middleware that throws `TRPCError({ code: 'UNAUTHORIZED' })` when `ctx.session` is missing).
2. `src/server/trpc/router.ts` — empty `appRouter = router({})` with a `// merge sub-routers here` marker. Export `type AppRouter`.
3. `src/server/trpc/client.ts` — `createTRPCContext<AppRouter>()`; export `TRPCProvider` and `useTRPC`.
4. `src/routes/api/trpc/$.ts` — `fetchRequestHandler` catch-all; build `createContext` from the request headers (call `auth.api.getSession({ headers })`).

## Step 7 — Router and root layout

1. `src/router.tsx` — export `getRouter()` that **returns a NEW router instance per call** (SSR isolation). Wire `setupRouterSsrQueryIntegration` and pass a fresh `QueryClient` per call. Use `createRootRouteWithContext<{ queryClient: QueryClient }>()`.
2. `src/routes/__root.tsx` — html/head/body shell, `<TRPCProvider>` + `<QueryClientProvider>` wrapping `<Outlet />`, devtools in dev only.
3. `src/routes/_public.tsx` — pathless layout for public pages (`<Outlet />`).
4. `src/routes/_authed.tsx` — pathless layout that runs `getSession()` in `beforeLoad` and `throw redirect({ to: '/login', search: { redirect: location.href } })` when missing.
5. `src/routes/index.tsx` — minimal home page so the dev server has something to render.
6. `src/routes/_public/login.tsx` and `signup.tsx` — minimal forms wired to `authClient.signIn` / `signUp`. TanStack Form + Zod 4 (`z.email()`, `z.string().min(8)`); call **both** `e.preventDefault()` and `e.stopPropagation()` in `onSubmit`.
7. `src/routes/_authed/dashboard.tsx` — placeholder showing `useSession()` data.

`routeTree.gen.ts` is generated by Vite on first dev run. Do **not** create it manually — `protect-sensitive.sh` blocks edits to it.

## Step 8 — Styles

1. `src/styles/app.css` — minimal reset + a single `body` rule. Imported from `__root.tsx` via `?url` and linked in `head`.
2. Do **not** create `src/client.tsx`, `src/ssr.tsx`, or `src/server.ts`. TanStack Start supplies default client and server entries; custom entries are only for advanced cases (`createServerEntry` in `src/server.ts`, `hydrateRoot` in `src/client.tsx`).

## Step 9 — Verify

Run in order; stop at the first failure:

```bash
bun typecheck        # zero errors expected
bun check            # Biome lint+format
bun dev              # boots on http://localhost:3000
```

Then in the browser:
- `/` renders.
- `/signup` creates a user (check Drizzle Studio: `bun db:studio`).
- `/login` issues a session cookie.
- `/dashboard` is reachable when logged in, redirects to `/login` when not.

Do not claim success on typecheck alone — the auth round-trip is the real smoke test.

## Step 10 — Hand-off

Tell the user, concisely:
- What was created (count of files, not a list).
- That `.env` was not written; they must populate it before `bun dev` works.
- The next natural step: `/scaffold <feature>` or `/add-feature` to add the first domain.

## Guardrails

- **Don't** add Tailwind, shadcn/ui, Sentry, analytics, or any library not in `CLAUDE.md`'s stack table. The kit is opinionated; ask the user before deviating.
- **Don't** write `.env`, migration SQL, or `routeTree.gen.ts` — hooks block it and that's intentional.
- **Don't** use `useEffect` for data fetching, default exports outside route files, or bare `zod` imports. If you catch yourself doing it, you're not following `CLAUDE.md`.
- **Don't** create a `README.md` unless the user asks.
- If a step fails (network, DB connection, version conflict), stop and surface the error — don't paper over it with `try/catch` or fallbacks.
