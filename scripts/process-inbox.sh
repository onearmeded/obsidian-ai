#!/usr/bin/env bash
# process-inbox.sh — Triage unreviewed tasks
#
# Usage:
#   ./scripts/process-inbox.sh           # Analyze and print recommendations
#   ./scripts/process-inbox.sh --apply   # Apply recommended changes (after review)
#
# In analysis mode (default): reads all #unreviewed tasks, asks Copilot to
# recommend classifications, and prints the results.
#
# In --apply mode: re-runs the analysis and uses Copilot to apply approved
# changes directly to vault files.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

APPLY=false
[[ "${1:-}" == "--apply" ]] && APPLY=true

log "Gathering unreviewed tasks..."
INBOX=$(bash "$SCRIPTS_DIR/lib/gather-tasks.sh" unreviewed)

if [[ "$APPLY" == "true" ]]; then
  log "Running inbox processor in APPLY mode (changes will be written to vault)..."
  APPLY_INSTRUCTION="

## Apply Mode
After producing your analysis, apply ALL recommended changes directly to the vault files.
For 'Keep as #mine': replace #unreviewed with #mine in the task line.
For 'Change to #follow-up': replace #unreviewed with #follow-up in the task line.
For 'Close': replace '- [ ]' with '- [x]' and remove #unreviewed and #task tags.
Edit each file in place. Report what you changed."
  PROMPT=$(build_prompt "process-inbox.md" "$INBOX")
  run_prompt "$PROMPT$APPLY_INSTRUCTION"
else
  log "Running inbox processor in ANALYSIS mode (no changes will be made)..."
  log "Review the output, then re-run with --apply to apply changes."
  PROMPT=$(build_prompt "process-inbox.md" "$INBOX")
  run_prompt "$PROMPT"
fi
