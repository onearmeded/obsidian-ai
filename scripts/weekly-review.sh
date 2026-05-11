#!/usr/bin/env bash
# weekly-review.sh — Full GTD weekly review
#
# Usage: ./scripts/weekly-review.sh
#
# Runs a comprehensive weekly review: inbox triage, open actions, project
# health, horizon check, and housekeeping. Saves a review note to the vault.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

log "Gathering all tasks..."
ALL_TASKS=$(bash "$SCRIPTS_DIR/lib/gather-tasks.sh" all)

log "Gathering meeting notes (last 14 days)..."
MEETINGS=$(bash "$SCRIPTS_DIR/lib/gather-meetings.sh" 14)

CONTEXT="$ALL_TASKS

$MEETINGS"

log "Running weekly review..."
PROMPT=$(build_prompt "weekly-review.md" "$CONTEXT")
run_prompt "$PROMPT" "Weekly Review"
