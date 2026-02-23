#!/usr/bin/env bash
# Re-inject critical stack patterns and git state after context compaction.
# Without this, Claude loses awareness of key conventions when the context
# window is compressed in long sessions.

# Inject current git state so Claude knows where it left off
BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" branch --show-current 2>/dev/null)
if [[ -n "$BRANCH" ]]; then
	RECENT=$(git -C "$CLAUDE_PROJECT_DIR" log main..HEAD --oneline 2>/dev/null | head -8)
	UNCOMMITTED=$(git -C "$CLAUDE_PROJECT_DIR" diff --name-only HEAD 2>/dev/null)
	UNCOMMITTED_COUNT=$(echo "$UNCOMMITTED" | grep -c '.' 2>/dev/null || echo 0)
	[[ -z "$UNCOMMITTED" ]] && UNCOMMITTED_COUNT=0

	echo "### Git state at compaction"
	echo "Branch: $BRANCH"
	if [[ -n "$RECENT" ]]; then
		echo "Commits on this branch:"
		echo "$RECENT" | sed 's/^/  /'
	fi
	if [[ "$UNCOMMITTED_COUNT" -gt 0 ]]; then
		echo "Uncommitted ($UNCOMMITTED_COUNT files): $(echo "$UNCOMMITTED" | tr '\n' ' ' | sed 's/ $//')"
	fi
	echo ""
fi

cat <<'EOF'
## Stack — Critical Patterns Reminder

### TanStack Start
- `getRouter()` must return a NEW instance each call (SSR isolation)
- Route loaders run on BOTH client and server — use `createServerFn` for server-only ops
- `viteReact()` MUST come AFTER `tanstackStart()` in Vite plugins
- Never edit `routeTree.gen.ts` — it is auto-generated

### tRPC (new client API)
- Use `useTRPC()` hook → `trpc.procedure.queryOptions()` with `useQuery()`
- Use `trpc.procedure.mutationOptions()` with `useMutation()`
- Only `useSuspenseQuery` participates in SSR — plain `useQuery` does NOT

### better-auth
- `tanstackStartCookies()` MUST be the LAST plugin
- Always pass `getRequestHeaders()` to `auth.api.getSession()` in server functions
- Use client SDK for auth actions, server functions for session checks

### Zod 4 (import from zod/v4)
- Use `.extend()` not `.merge()`
- Use `z.email()`, `z.uuid()` (top-level) not `z.string().email()`
- Use `z.treeifyError()` not `.format()` or `.flatten()`

### Code Style (Biome enforced)
- Named exports only (no default exports, except route/config files)
- `import type {}` for type-only imports
- Run `bun check:fix` before committing
EOF

exit 0
