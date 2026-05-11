#!/usr/bin/env bash
# project-sync.sh — Update a project page from recent meeting notes
#
# Usage: ./scripts/project-sync.sh "<Project Name>"
#   e.g.: ./scripts/project-sync.sh "NV SCO"
#         ./scripts/project-sync.sh "BP Poland"
#
# Gathers all vault content related to the project, then asks Copilot
# to synthesize and write an updated project page back to the vault.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

PROJECT="${1:-}"
[[ -n "$PROJECT" ]] || { echo "Usage: $0 \"<Project Name>\""; exit 1; }

log "Gathering project content for: $PROJECT"
CONTEXT=$(bash "$SCRIPTS_DIR/lib/gather-project.sh" "$PROJECT")

log "Running project sync..."
PROMPT=$(build_prompt "project-sync.md" "$CONTEXT")
run_prompt "$PROMPT" "Project Sync: $PROJECT"
