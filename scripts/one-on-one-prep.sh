#!/usr/bin/env bash
# one-on-one-prep.sh — Prepare for a 1-1 meeting
#
# Usage:
#   ./scripts/one-on-one-prep.sh              # Pick from list of known 1-1 participants
#   ./scripts/one-on-one-prep.sh "Chris"      # Prep for a specific person
#
# Finds all past 1-1 notes matching "YYYY-MM-DD <Name> 1-1 ..." and produces
# a prep sheet with follow-ups and suggested discussion topics.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

NOTES_DIR="$VAULT_DIR/Meetings/Notes"
NAME="${1:-}"

# --- Discover known 1-1 participants from file names ---
get_participants() {
  find "$NOTES_DIR" -name "* 1-1 *" -o -name "*1-1.md" 2>/dev/null \
    | xargs -I{} basename "{}" \
    | grep -oP '^\d{4}-\d{2}-\d{2} \K[^1-]+(?= 1-1)' \
    | sort -u
}

# If no name given, list participants and prompt
if [[ -z "$NAME" ]]; then
  log "Known 1-1 participants:"
  PARTICIPANTS=$(get_participants)
  if [[ -z "$PARTICIPANTS" ]]; then
    die "No 1-1 meeting notes found in $NOTES_DIR"
  fi
  echo "" >&2
  nl -w2 -s'. ' <<< "$PARTICIPANTS" >&2
  echo "" >&2
  printf "Enter name (or number): " >&2
  read -r SELECTION
  # Allow selecting by number
  if [[ "$SELECTION" =~ ^[0-9]+$ ]]; then
    NAME=$(sed -n "${SELECTION}p" <<< "$PARTICIPANTS")
  else
    NAME="$SELECTION"
  fi
  [[ -n "$NAME" ]] || die "No name selected"
fi

log "Gathering 1-1 history for: $NAME"

# --- Collect all matching 1-1 notes (case-insensitive) ---
CONTEXT=""
COUNT=0
while IFS= read -r -d '' file; do
  fname=$(basename "$file")
  # Case-insensitive match on the name portion
  if echo "$fname" | grep -qi "^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} ${NAME} 1-1"; then
    COUNT=$((COUNT + 1))
    CONTEXT="$CONTEXT
---
## $(basename "$file" .md)

$(grep -v "^\[\[Transcripts/" "$file" | head -120)
"
  fi
done < <(find "$NOTES_DIR" -name "*.md" -print0 | sort -z)

if [[ $COUNT -eq 0 ]]; then
  die "No 1-1 notes found for \"$NAME\". Check the name matches the file prefix."
fi

log "Found $COUNT 1-1 note(s) for $NAME"

# --- Open tasks that explicitly mention this person (entire vault) ---
TASKS=$(grep -r --include="*.md" --exclude-dir="Transcripts" -h \
  "^[*-] \[ \]" "$VAULT_DIR" 2>/dev/null \
  | grep "#task" \
  | grep -i "$NAME" || true)

if [[ -n "$TASKS" ]]; then
  CONTEXT="$CONTEXT
---
## Open Tasks Mentioning $NAME

$TASKS
"
fi

# --- Other vault references: non-task lines mentioning this person ---
# Include project pages, notes, and email — skip meeting notes (already gathered above)
# and transcripts. Show the matching line plus its file for context.
OTHER_REFS=$(grep -r --include="*.md" \
  --exclude-dir="Transcripts" --exclude-dir="Notes" \
  -i "$NAME" "$VAULT_DIR" 2>/dev/null \
  | grep -v "^Binary" \
  | grep -iv "^[*-] \[.\]" \
  | sed 's|'"$VAULT_DIR"'/||' || true)

if [[ -n "$OTHER_REFS" ]]; then
  CONTEXT="$CONTEXT
---
## Other Vault References to $NAME

$OTHER_REFS
"
fi

PROMPT=$(build_prompt "one-on-one-prep.md" "$CONTEXT")
run_prompt "$PROMPT" "1-1 Prep: $NAME"
