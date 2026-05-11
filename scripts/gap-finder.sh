#!/usr/bin/env bash
# gap-finder.sh — "Which areas are underdeveloped or going dark?"
#
# Usage: ./scripts/gap-finder.sh
#
# Scans all projects in Key Initiatives against recent meeting activity
# and task coverage. Optionally appends concerning items to the
# "Things to Think on or Decide" parking lot.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

log "Running gap finder..."
PROMPT=$(build_prompt "gap-finder.md")
run_prompt "$PROMPT"
