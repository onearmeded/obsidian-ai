#!/usr/bin/env bash
# horizon-scan.sh — "What's coming up that needs thinking?"
#
# Usage: ./scripts/horizon-scan.sh
#
# Reads follow-up tasks, recent meeting notes, and the "Things to Think on"
# list to surface upcoming decisions and potential stuck items.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

log "Gathering follow-up tasks..."
FOLLOWUPS=$(bash "$SCRIPTS_DIR/lib/gather-tasks.sh" follow-up)

log "Gathering recent meeting notes (last 14 days)..."
MEETINGS=$(bash "$SCRIPTS_DIR/lib/gather-meetings.sh" 14)

CONTEXT="$FOLLOWUPS

$MEETINGS"

log "Running horizon scan..."
PROMPT=$(build_prompt "horizon-scan.md" "$CONTEXT")
run_prompt "$PROMPT" "Horizon Scan"
