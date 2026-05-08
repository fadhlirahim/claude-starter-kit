#!/usr/bin/env bash
# Install the Claude Starter Kit into the current (or specified) project directory.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fadhlirahim/claude-starter-kit/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- /path/to/project
#   bash install.sh [target-dir]
#
# Behavior:
#   - Kit-owned files (CLAUDE.md, biome.json, .claude/**) are installed.
#     If a destination file already exists with different content, the existing
#     file is renamed to <file>.bak before the kit version is written.
#   - User-owned files (package.json, .gitignore) are NEVER overwritten. If they
#     exist, the script prints suggested additions for you to merge manually.
#   - .env.example is copied only if absent.
#   - Re-running the installer is safe: identical files are skipped.

set -euo pipefail

REPO_URL="https://github.com/fadhlirahim/claude-starter-kit.git"
REPO_BRANCH="main"

# ---- helpers ----------------------------------------------------------------

log()  { printf '%s\n' "$*"; }
warn() { printf 'warn: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

INSTALLED=()
BACKED_UP=()
SKIPPED=()
TMP_SOURCE=""

cleanup() {
  if [[ -n "$TMP_SOURCE" && -d "$TMP_SOURCE" ]]; then
    rm -rf "$TMP_SOURCE"
  fi
}
trap cleanup EXIT

# Copy a single kit-owned file.
#   $1 source path (absolute)
#   $2 destination path (absolute)
install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      SKIPPED+=("${dst#"$TARGET/"}")
      return 0
    fi
    mv "$dst" "$dst.bak"
    BACKED_UP+=("${dst#"$TARGET/"}")
  fi
  cp "$src" "$dst"
  INSTALLED+=("${dst#"$TARGET/"}")
}

# ---- resolve target ---------------------------------------------------------

TARGET="${1:-$PWD}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

log "Installing Claude Starter Kit into: $TARGET"

# ---- resolve source ---------------------------------------------------------
#
# Local mode: the script lives next to the kit files (we can detect this by
# checking for a sibling CLAUDE.md). Otherwise (e.g., piped from curl), shallow
# clone the repo into a temp dir.

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/CLAUDE.md" && -d "$SCRIPT_DIR/.claude" ]]; then
  SOURCE="$SCRIPT_DIR"
  log "Using local kit source: $SOURCE"
else
  command -v git >/dev/null 2>&1 || die "git is required to fetch the kit (not found in PATH)"
  TMP_SOURCE="$(mktemp -d)"
  log "Fetching kit from $REPO_URL ($REPO_BRANCH)…"
  git clone --depth 1 --branch "$REPO_BRANCH" --quiet "$REPO_URL" "$TMP_SOURCE"
  SOURCE="$TMP_SOURCE"
fi

[[ "$SOURCE" != "$TARGET" ]] || die "source and target are the same directory; nothing to do"

# ---- install kit-owned files -----------------------------------------------

install_file "$SOURCE/CLAUDE.md"  "$TARGET/CLAUDE.md"
install_file "$SOURCE/biome.json" "$TARGET/biome.json"

# .claude/ subtree, but skip settings.local.json (user-specific overrides)
if [[ -d "$SOURCE/.claude" ]]; then
  while IFS= read -r -d '' src; do
    rel="${src#"$SOURCE"/}"
    [[ "$rel" == ".claude/settings.local.json" ]] && continue
    install_file "$src" "$TARGET/$rel"
  done < <(find "$SOURCE/.claude" -type f -print0)
fi

# Make hook scripts executable (idempotent; safe even if already executable).
if [[ -d "$TARGET/.claude/hooks" ]]; then
  find "$TARGET/.claude/hooks" -type f -name '*.sh' -exec chmod +x {} +
fi

# ---- user-owned files: copy if absent, otherwise suggest merges ------------

PKG_SUGGESTION=""
if [[ ! -e "$TARGET/package.json" ]]; then
  install_file "$SOURCE/package.json" "$TARGET/package.json"
elif command -v jq >/dev/null 2>&1; then
  # List script names present in kit but missing in user's package.json.
  missing="$(jq -r --slurpfile user "$TARGET/package.json" '
    ($user[0].scripts // {}) as $have
    | (.scripts // {}) | to_entries
    | map(select(.key as $k | $have | has($k) | not))
    | map("  \"\(.key)\": \"\(.value)\",") | .[]
  ' "$SOURCE/package.json" || true)"
  if [[ -n "$missing" ]]; then
    PKG_SUGGESTION="$missing"
  fi
else
  PKG_SUGGESTION="(install jq for a precise diff; for now, see kit's package.json scripts)"
fi

GITIGNORE_SUGGESTION=""
if [[ ! -e "$TARGET/.gitignore" ]]; then
  install_file "$SOURCE/.gitignore" "$TARGET/.gitignore"
else
  # Lines from kit's .gitignore that aren't already in the user's (ignoring blank/comments for matching).
  missing="$(awk '
    NR==FNR { if ($0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*#/) have[$0]=1; next }
    { if ($0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*#/ && !($0 in have)) print "  " $0 }
  ' "$TARGET/.gitignore" "$SOURCE/.gitignore" || true)"
  if [[ -n "$missing" ]]; then
    GITIGNORE_SUGGESTION="$missing"
  fi
fi

# .env.example: copy only if absent
if [[ ! -e "$TARGET/.env.example" ]]; then
  install_file "$SOURCE/.env.example" "$TARGET/.env.example"
fi

# ---- summary ---------------------------------------------------------------

log ""
log "Summary:"
log "  installed:  ${#INSTALLED[@]}"
log "  backed up:  ${#BACKED_UP[@]}"
log "  unchanged:  ${#SKIPPED[@]}"

if (( ${#BACKED_UP[@]} > 0 )); then
  log ""
  log "Backed up (review and merge if needed):"
  for f in "${BACKED_UP[@]}"; do
    log "  $f.bak"
  done
fi

if [[ -n "$PKG_SUGGESTION" ]]; then
  log ""
  log "Suggested scripts to add to package.json:"
  printf '%s\n' "$PKG_SUGGESTION"
fi

if [[ -n "$GITIGNORE_SUGGESTION" ]]; then
  log ""
  log "Suggested .gitignore entries:"
  printf '%s\n' "$GITIGNORE_SUGGESTION"
fi

log ""
log "Next steps:"
log "  1. Open CLAUDE.md and replace [App Name] with your project name."
log "  2. If you don't have one yet, copy .env.example to .env and fill it in."
log "  3. Restart Claude Code so it picks up the new settings and hooks."
