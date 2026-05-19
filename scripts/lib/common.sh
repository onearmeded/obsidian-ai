#!/usr/bin/env bash
# lib/common.sh — shared utilities for GTD workflow scripts
# Source this file from other scripts: source "$(dirname "$0")/lib/common.sh"

# Resolve PROJECT_ROOT as two directories up from this file (scripts/lib/ -> scripts/ -> project root)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
VAULT_DIR="$PROJECT_ROOT/obsidian-vault/Work"
PROMPTS_DIR="$PROJECT_ROOT/prompts"

# Print to stderr so it doesn't pollute captured output
log() { echo "[gtd] $*" >&2; }

die() { echo "[gtd] ERROR: $*" >&2; exit 1; }

# Run a non-interactive copilot prompt and return output to stdout.
# Writes the prompt to a temp file to avoid kernel ARG_MAX limits on large contexts.
# Usage: capture_prompt "prompt text"
# Respects COPILOT_EFFORT (default: medium)
capture_prompt() {
  local prompt="$1"
  local effort="${COPILOT_EFFORT:-medium}"

  local tmpfile
  tmpfile=$(mktemp "${TMPDIR:-/tmp}/gtd-prompt-XXXXXX.md")
  trap "rm -f '$tmpfile'" EXIT

  printf '%s' "$prompt" > "$tmpfile"

  copilot \
    --allow-all-paths \
    --allow-all-tools \
    --reasoning-effort "$effort" \
    --silent \
    -C "$PROJECT_ROOT" \
    -p "Read the file $tmpfile — it contains your full context and instructions. Execute those instructions."
}

# Run a non-interactive copilot prompt, render output as HTML, and open in browser.
# Writes the prompt to a temp file to avoid kernel ARG_MAX limits on large contexts.
# Usage: run_prompt "prompt text" ["Page Title"]
# Respects COPILOT_EFFORT (default: medium)
run_prompt() {
  local prompt="$1"
  local title="${2:-GTD Output}"
  local effort="${COPILOT_EFFORT:-medium}"

  # Write full prompt to a temp file; pass a short -p that instructs Copilot to read it
  local tmpfile
  tmpfile=$(mktemp "${TMPDIR:-/tmp}/gtd-prompt-XXXXXX.md")
  trap "rm -f '$tmpfile'" EXIT

  printf '%s' "$prompt" > "$tmpfile"

  log "Opening results in browser..."
  copilot \
    --allow-all-paths \
    --allow-all-tools \
    --reasoning-effort "$effort" \
    --silent \
    -C "$PROJECT_ROOT" \
    -p "Read the file $tmpfile — it contains your full context and instructions. Execute those instructions." \
  | bash "$SCRIPTS_DIR/lib/open-in-browser.sh" "$title"
}

# Save markdown content to the vault. Prepends a frontmatter block and overwrites
# any existing file. Creates parent directories as needed.
# Usage: save_to_vault "frontmatter-with-delimiters" "markdown-body" "path/relative/to/VAULT_DIR.md"
save_to_vault() {
  local frontmatter="$1"
  local body="$2"
  local rel_path="$3"
  local full_path="$VAULT_DIR/$rel_path"
  mkdir -p "$(dirname "$full_path")"
  printf '%s\n\n%s\n' "$frontmatter" "$body" > "$full_path"
  log "Saved: $rel_path"
}

# Run a prompt, save output to the vault with frontmatter, and open in browser.
# The AI produces clean markdown body; the shell owns all file I/O.
# Usage: run_prompt_and_save "prompt" "title" "frontmatter-with-delimiters" "vault-relative-path"
# Respects COPILOT_EFFORT (default: medium)
run_prompt_and_save() {
  local prompt="$1"
  local title="${2:-GTD Output}"
  local frontmatter="$3"
  local rel_path="$4"
  local effort="${COPILOT_EFFORT:-medium}"

  local tmpfile
  tmpfile=$(mktemp "${TMPDIR:-/tmp}/gtd-prompt-XXXXXX.md")
  trap "rm -f '$tmpfile'" EXIT

  printf '%s' "$prompt" > "$tmpfile"

  log "Running prompt..."
  local output
  output=$(copilot \
    --allow-all-paths \
    --allow-all-tools \
    --reasoning-effort "$effort" \
    --silent \
    -C "$PROJECT_ROOT" \
    -p "Read the file $tmpfile — it contains your full context and instructions. Execute those instructions.")

  save_to_vault "$frontmatter" "$output" "$rel_path"
  log "Opening results in browser..."
  printf '%s' "$output" | bash "$SCRIPTS_DIR/lib/open-in-browser.sh" "$title"
}

# Build the standard prompt header: system context + optional extra files
# Usage: build_prompt "task-prompt-file.md" [extra-context-string]
build_prompt() {
  local task_file="$PROMPTS_DIR/$1"
  local extra="${2:-}"
  [[ -f "$task_file" ]] || die "Prompt file not found: $task_file"
  printf '%s\n\n' "$(cat "$PROMPTS_DIR/system.md")"
  if [[ -n "$extra" ]]; then
    printf '%s\n\n' "$extra"
  fi
  cat "$task_file"
}
