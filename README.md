# Claude Starter Kit

A Claude Code configuration kit for building fullstack TypeScript applications with tanstack start. Drop these files into any project to get a pre-configured AI development environment with opinionated conventions, automated quality gates, and productivity workflows.

This is **not** an app template with source code. It's the `.claude/` directory, `CLAUDE.md`, and `biome.json` that teach Claude Code how to build correctly in this stack.

## The Stack

| Layer | Technology |
|-------|-----------|
| Framework | [TanStack Start](https://tanstack.com/start) (Vite + Nitro SSR) |
| Routing | [TanStack Router](https://tanstack.com/router) (file-based, type-safe) |
| Data | [TanStack Query](https://tanstack.com/query) + [tRPC](https://trpc.io) |
| Forms | [TanStack Form](https://tanstack.com/form) + [Zod 4](https://zod.dev) |
| Auth | [better-auth](https://better-auth.com) |
| Database | [Drizzle ORM](https://orm.drizzle.team) + PostgreSQL |
| Validation | [Zod 4](https://zod.dev) |
| Linting/Formatting | [Biome](https://biomejs.dev) |

## What's Included

```
CLAUDE.md                          # Project conventions, patterns, anti-patterns
biome.json                         # Formatting + linting config
package.json                       # Script definitions
.env.example                       # Environment variable template
.gitignore                         # Standard ignores
.claude/
  settings.json                    # Permissions, hooks, MCP servers
  hooks/                           # 7 lifecycle hook scripts
    auto-format.sh                 #   Biome format on every file edit
    protect-sensitive.sh            #   Block writes to .env, migrations, generated files
    db-schema-reminder.sh          #   Remind to migrate after schema/auth changes
    git-context.sh                 #   Inject git branch + changes into every prompt
    session-context.sh             #   Re-inject stack patterns after context compaction
    post-implement-review.sh       #   Force review when 3+ files changed
    notify-macos.sh                #   Desktop notification (permission/idle)
    stop-notify.sh                 #   Desktop notification when Claude finishes
  skills/                          # 15 slash commands
    setup/SKILL.md                 #   /setup — bootstrap the TanStack Start app from zero
    push/SKILL.md                  #   /push — commit, push, and create PR
    commit/SKILL.md                #   /commit — auto-generate commit message
    clean-branches/SKILL.md        #   /clean-branches — prune stale local branches
    review/SKILL.md                #   /review — code review
    simplify/SKILL.md              #   /simplify — reduce complexity
    scaffold/SKILL.md              #   /scaffold — fullstack feature generation
    add-feature/SKILL.md           #   /add-feature — guided feature workflow
    add-trpc-router/SKILL.md       #   /add-trpc-router — CRUD router generation
    debug/SKILL.md                 #   /debug — systematic debugging
    test/SKILL.md                  #   /test — write or run tests
    docs/SKILL.md                  #   /docs — Context7 doc lookup
    migrate/SKILL.md               #   /migrate — database migration workflow
    refactor/SKILL.md              #   /refactor — safe refactoring
    compound/SKILL.md              #   /compound — extract session learnings
  agents/                          # 4 specialist subagents
    code-reviewer.md               #   Senior code reviewer
    code-simplifier.md             #   Complexity reducer
    test-writer.md                 #   Test generator
    fullstack-builder.md           #   End-to-end feature builder
```

## How It Works

The kit operates on three layers that reinforce each other:

### 1. CLAUDE.md — The Brain

A comprehensive instruction file that teaches Claude Code the project's conventions. It covers:

- **Project structure** — where every file type belongs
- **Stack-specific patterns** — the correct way to use each library, including version-specific API details (Zod 4's `.extend()` over `.merge()`, tRPC's new `useTRPC()` hook, better-auth's `tanstackStartCookies()` ordering)
- **Anti-patterns** — 16 explicit "don't do this" rules with explanations
- **Code examples** — copy-paste patterns for routes, queries, mutations, auth guards, and schemas

### 2. Hooks — Automated Quality Gates

Shell scripts in `.claude/hooks/` wired to lifecycle events in `settings.json`. Unlike CLAUDE.md instructions (which are advisory), hooks are **deterministic** — they run every time, guaranteed.

| Event | Hook | What It Does |
|-------|------|-------------|
| **UserPromptSubmit** | `git-context.sh` | Injects current branch, recent commits, and uncommitted files into every prompt. Claude always knows where it is. |
| **PreToolUse** (Write\|Edit) | `protect-sensitive.sh` | **Blocks** writes to `.env` files, Drizzle migration SQL, and `routeTree.gen.ts`. Exit code 2 = action denied. |
| **PostToolUse** (Write\|Edit) | `auto-format.sh` | Runs `bunx biome check --write` on every file Claude edits. Skips generated files, node_modules, build output. |
| **PostToolUse** (Write\|Edit) | `db-schema-reminder.sh` | When `schema.ts`, `auth.ts`, or a Zod validator is modified, injects a reminder to run migrations/typecheck via `additionalContext`. |
| **SessionStart** (compact) | `session-context.sh` | After context compaction in long sessions, re-injects critical stack patterns (TanStack Start pitfalls, Zod 4 changes, better-auth rules) so Claude doesn't lose them. |
| **Stop** | `post-implement-review.sh` | When 3+ TypeScript source files are modified, **blocks** Claude from finishing and asks it to run the code-simplifier, then code-reviewer, then typecheck. Loop-safe via `stop_hook_active`. |
| **Stop** | `stop-notify.sh` | macOS desktop notification with sound when Claude finishes. |
| **Notification** | `notify-macos.sh` | Different notification sounds for permission prompts vs idle prompts. |

### 3. Skills & Agents — Workflows on Demand

**Skills** are slash commands you invoke during a session:

| Command | What It Does |
|---------|-------------|
| `/setup` | Bootstraps the project from zero: installs deps, wires Drizzle + better-auth + tRPC + TanStack Router, scaffolds the root/auth layouts, and verifies with a login round-trip. Run this once, right after `install.sh`. |
| `/push` | Commits, pushes, and creates a PR with comprehensive description — analyzes all branch commits, groups changes by area, includes test plan |
| `/commit` | Stages and commits with an auto-generated message matching your repo's conventional commit style |
| `/clean-branches` | Prunes local branches deleted from remote (fetches, finds `[gone]`, removes worktrees, deletes) |
| `/review` | Forks a subagent to review your changes against a 9-point checklist (type safety, auth, server/client boundary, performance, etc.) |
| `/simplify` | Analyzes code and reduces complexity without changing behavior |
| `/scaffold posts` | Generates a complete feature: Zod validators, Drizzle schema, tRPC router, route page, and components |
| `/add-trpc-router comments` | Creates a CRUD tRPC router with proper middleware and validation |
| `/debug "login returns 401"` | Traces the issue through the fullstack data flow with a common-causes checklist |
| `/test src/server/trpc/routers/user.ts` | Writes vitest tests using project patterns |
| `/docs tanstack-router search-params` | Fetches current docs from Context7 |
| `/migrate "add posts table"` | Walks through the Drizzle migration workflow |
| `/refactor src/components/dashboard` | Plans and executes a refactor with verification at each step |
| `/compound` | Extracts learnings from the current session and updates CLAUDE.md |
| `/add-feature "user profile page"` | Guided fullstack feature implementation |

**Agents** are specialist subagents Claude delegates to:

| Agent | When It's Used |
|-------|---------------|
| `code-reviewer` | Reviews changes for security, types, conventions. Outputs structured findings with APPROVE/REQUEST CHANGES verdict. |
| `code-simplifier` | Reduces nesting, removes dead code, leverages framework patterns. Never changes behavior. |
| `test-writer` | Generates vitest tests for tRPC routers, Zod schemas, and React components. |
| `fullstack-builder` | Builds complete features in the correct order: schema, migration, validators, router, route, components. |

## Install

The fastest way is the install script. It works for both fresh projects and existing repos. Run it from the directory you want the kit applied to:

```bash
curl -fsSL https://raw.githubusercontent.com/fadhlirahim/claude-starter-kit/main/install.sh | bash
```

Or pass a target directory:

```bash
curl -fsSL https://raw.githubusercontent.com/fadhlirahim/claude-starter-kit/main/install.sh | bash -s -- /path/to/your-project
```

Prefer to inspect first? Clone and run locally:

```bash
git clone https://github.com/fadhlirahim/claude-starter-kit.git
cd /path/to/your-project
bash /path/to/claude-starter-kit/install.sh
```

### What the installer does

- **Kit-owned files** (`CLAUDE.md`, `biome.json`, `.claude/**`) are written into your project. If a file already exists with different content, the existing file is renamed to `<file>.bak` first — nothing is silently clobbered.
- **User-owned files** (`package.json`, `.gitignore`) are **never** overwritten. If they already exist, the installer prints suggested additions for you to merge by hand.
- `.env.example` is copied only if you don't already have one.
- Hook scripts under `.claude/hooks/` are made executable.
- Re-running the installer is safe — files identical to the kit are reported as unchanged, no duplicate `.bak` files are created.

After install:

1. Open `CLAUDE.md` and replace `[App Name]` with your project name.
2. Copy `.env.example` to `.env` and fill in values.
3. Restart Claude Code so it picks up the new settings and hooks.
4. **Fresh project?** Run `/setup` — it bootstraps the TanStack Start app (deps, Drizzle, better-auth, tRPC, root/auth layouts) and verifies with a login round-trip. Skip this if you're adding the kit to a project that already has `src/`.

### Manual install (fallback)

If you can't run the script, copy by hand:

```bash
cp -r .claude/ /path/to/your-project/.claude/
cp CLAUDE.md /path/to/your-project/
cp biome.json /path/to/your-project/
chmod +x /path/to/your-project/.claude/hooks/*.sh
```

### Daily Workflow

```
You: /scaffold blog-posts
  → Claude creates validators, schema, migration, router, route, components

You: /review
  → Forked agent reviews all changes against the checklist

You: /simplify src/components/blog-posts
  → Reduces complexity while preserving behavior

You: /push
  → Commits, pushes, creates PR with grouped changes and test plan
  → Returns PR URL for review

You: /compound
  → Extracts patterns discovered during the session into CLAUDE.md

You: /clean-branches
  → Prunes merged branches after PR is merged
```

## Biome Configuration

The included `biome.json` enforces:

- **No `any`** — `noExplicitAny: error`
- **No unused imports** — auto-removed
- **No default exports** — with overrides for route files and config files
- **No floating promises** — `noFloatingPromises: error`
- **Cognitive complexity limit** — warns at 15
- **Sorted CSS classes** — (for Tailwind)
- **Import organization** — automatic sorting and grouping
- **Formatting** — tabs, single quotes, no semicolons, trailing commas, 100 char width

## Permissions

The settings pre-approve common safe operations so Claude doesn't ask permission repeatedly:

**Allowed**: `bun run *`, `bun test`, `bun add`, `bunx biome`, `bunx drizzle-kit`, `bunx @better-auth/cli`, standard git operations (status, diff, log, add, commit, branch, checkout, stash), Context7 doc lookups

**Denied**: `rm -rf /`, `git push --force`, `git reset --hard`, reading `.env` files

## Customization

### Adjusting Conventions

Edit `CLAUDE.md` directly. The file is structured with clear sections — modify the patterns, add new anti-patterns, or change the project structure to match your needs.

### Adding Skills

Create `.claude/skills/your-skill/SKILL.md`:

```yaml
---
name: your-skill
description: When to use this skill
user-invocable: true
---

Instructions for Claude when this skill is invoked.
Use $ARGUMENTS to reference user input.
```

### Adding Agents

Create `.claude/agents/your-agent.md`:

```yaml
---
name: your-agent
description: When Claude should delegate to this agent
tools: Read, Grep, Glob, Bash, Edit, Write
model: inherit
---

System prompt for the agent.
```

### Adding Hooks

Create a script in `.claude/hooks/` and wire it in `settings.json`:

```bash
#!/usr/bin/env bash
# .claude/hooks/my-hook.sh
INPUT=$(cat)  # JSON from stdin with tool_input, session_id, etc.
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit 0 = proceed, Exit 2 = BLOCK the action (stderr shown to Claude)
echo "Blocked: reason" >&2 && exit 2

# Output additionalContext to inject a reminder into Claude's context
jq -n '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "Your reminder here"}}'
```

```json
// settings.json
"PostToolUse": [{ "matcher": "Write", "hooks": [{ "type": "command", "command": ".claude/hooks/my-hook.sh" }] }]
```

### Modular Rules

For complex projects, create topic-specific rules in `.claude/rules/`:

```
.claude/rules/
  frontend.md      # React/component patterns
  api.md           # tRPC/API conventions
  database.md      # Drizzle/migration rules
  security.md      # Auth/security requirements
```

## Key Design Decisions

**Why skills over commands?** Skills support frontmatter (context forking, tool restrictions, agent type selection) and are the newer, recommended approach. The `/review` skill forks into a separate agent context so the review doesn't bias the main session.

**Why Biome over ESLint + Prettier?** Single binary, single config file, 10-25x faster, built-in import sorting and React hooks rules. No plugin ecosystem to manage.

**Why hooks as scripts instead of inline commands?** Scripts can filter by file type, skip generated directories, output structured `additionalContext` JSON, and use exit code 2 to block actions. Inline one-liners can't do any of that. The scripts are also easier to read, test, and customize.

**Why a Stop hook for review?** Without it, Claude finishes after implementing and you manually remember to review. The `post-implement-review.sh` hook blocks Claude when 3+ source files changed and forces a simplify + review pass before wrapping up. This creates a built-in quality gate.

**Why Zod 4 specifics?** Zod 4 has significant breaking changes from v3 (`.merge()` removed, `.format()` deprecated, `z.record()` requires 2 args). Without explicit instructions, Claude will generate Zod 3 patterns that fail at runtime.

**Why so many anti-patterns?** Each one represents a real mistake that AI assistants commonly make with this stack. The anti-patterns list is the highest-leverage section of CLAUDE.md — it prevents the most common errors before they happen.

## Requirements

- [Bun](https://bun.sh) (package manager and runtime)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh`) — for `/push` and `/clean-branches` skills
- [Context7 MCP server](https://github.com/upstash/context7) (optional, for `/docs` skill)
