#!/usr/bin/env bash
# Auto-format TypeScript/JavaScript files with Biome after Claude edits them.
# Runs synchronously so the formatted file is ready for Claude's next read.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[[ -z "$FILE_PATH" ]] && exit 0

# Only process TypeScript/JavaScript/JSON/CSS files
[[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx|mts|cts|json|css)$ ]] && exit 0

# Skip generated and build directories
[[ "$FILE_PATH" =~ /(node_modules|\.output|\.vinxi|dist|build)/ ]] && exit 0

# Skip auto-generated route tree
[[ "$FILE_PATH" =~ routeTree\.gen\.ts$ ]] && exit 0

# Skip migration files (managed by drizzle-kit)
[[ "$FILE_PATH" =~ /drizzle/.*\.(sql|meta)$ ]] && exit 0

cd "$CLAUDE_PROJECT_DIR"
bunx biome check --write "$FILE_PATH" 2>/dev/null || true

exit 0
