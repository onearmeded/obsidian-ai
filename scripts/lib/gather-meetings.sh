#!/usr/bin/env bash
# lib/gather-meetings.sh — collect recent meeting note content from the vault
#
# Usage: gather-meetings.sh [days]
#   days: how many days back to include (default: 7)
#
# Outputs meeting summaries and action items (skips full transcript links).

source "$(dirname "$0")/common.sh"

DAYS="${1:-7}"
NOTES_DIR="$VAULT_DIR/Meetings/Notes"

[[ -d "$NOTES_DIR" ]] || die "Meeting notes directory not found: $NOTES_DIR"

# Cutoff date in YYYY-MM-DD format
CUTOFF=$(date -d "-${DAYS} days" '+%Y-%m-%d' 2>/dev/null \
  || date -v "-${DAYS}d" '+%Y-%m-%d')  # macOS fallback

echo "# Recent Meeting Notes (last ${DAYS} days)"
echo "_Gathered: $(date '+%Y-%m-%d %H:%M'), cutoff: ${CUTOFF}_"
echo ""

found=0
while IFS= read -r -d '' file; do
  # Extract date from filename prefix (YYYY-MM-DD ...)
  fname=$(basename "$file")
  fdate="${fname:0:10}"

  # Skip files older than cutoff
  [[ "$fdate" < "$CUTOFF" ]] && continue
  [[ "$fdate" > "$(date '+%Y-%m-%d')" ]] && continue  # skip future dates

  found=$((found + 1))
  echo "---"
  echo "## $fname"
  echo ""

  # Extract just the useful sections (skip raw transcript links at bottom)
  # Print everything except lines that are just transcript wikilinks
  grep -v "^\[\[Transcripts/" "$file" | grep -v "^$" | head -100
  echo ""

done < <(find "$NOTES_DIR" -name "*.md" -print0 | sort -z)

if [[ $found -eq 0 ]]; then
  echo "_No meeting notes found in the last ${DAYS} days (cutoff: ${CUTOFF})._"
fi
