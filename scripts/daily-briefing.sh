#!/usr/bin/env bash
# daily-briefing.sh — "What should I focus on today?"
#
# Usage: ./scripts/daily-briefing.sh
#
# Reads open tasks and recent meeting notes, then asks Copilot to
# produce a prioritized daily briefing.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

log "Gathering tasks..."
TASKS=$(bash "$SCRIPTS_DIR/lib/gather-tasks.sh" mine)

log "Gathering follow-ups..."
FOLLOWUPS=$(bash "$SCRIPTS_DIR/lib/gather-tasks.sh" follow-up)

log "Gathering recent meeting notes (last 7 days)..."
MEETINGS=$(bash "$SCRIPTS_DIR/lib/gather-meetings.sh" 7)

CONTEXT="$TASKS

$FOLLOWUPS

$MEETINGS"

log "Running briefing..."
TODAY=$(date +%Y-%m-%d)
FRONTMATTER="---
date: $TODAY
tags: [daily-note]
---"
PROMPT=$(build_prompt "daily-briefing.md" "$CONTEXT")
run_prompt_and_save "$PROMPT" "Daily Briefing" "$FRONTMATTER" "Daily Notes/$TODAY.md"
