#!/usr/bin/env bash
# lib/gather-project.sh — collect all vault content related to a project
#
# Usage: gather-project.sh "<Project Name>"
#   e.g.: gather-project.sh "NV SCO"
#         gather-project.sh "BP Poland"
#
# Outputs: the project page + any meeting notes mentioning the project name.

source "$(dirname "$0")/common.sh"

PROJECT="${1:-}"
[[ -n "$PROJECT" ]] || die "Usage: gather-project.sh \"<Project Name>\""

echo "# Vault Content for Project: $PROJECT"
echo "_Gathered: $(date '+%Y-%m-%d %H:%M')_"
echo ""

# --- Project page ---
# Look for an exact filename match, then a fuzzy match
PROJECT_FILE=""
exact="$VAULT_DIR/${PROJECT}.md"
if [[ -f "$exact" ]]; then
  PROJECT_FILE="$exact"
else
  # Case-insensitive partial match among top-level Work files
  PROJECT_FILE=$(find "$VAULT_DIR" -maxdepth 1 -name "*.md" -iname "*${PROJECT}*" | head -1)
fi

echo "## Project Page"
echo ""
if [[ -n "$PROJECT_FILE" && -f "$PROJECT_FILE" ]]; then
  echo "_Source: ${PROJECT_FILE#$VAULT_DIR/}_"
  echo ""
  cat "$PROJECT_FILE"
else
  echo "_No project page found for \"$PROJECT\". A new one should be created._"
fi
echo ""

# --- Meeting notes mentioning the project ---
echo "## Meeting Notes Mentioning \"$PROJECT\""
echo ""

found=0
while IFS= read -r -d '' file; do
  if grep -qi "$PROJECT" "$file" 2>/dev/null; then
    found=$((found + 1))
    fname=$(basename "$file")
    echo "### $fname"
    echo ""
    # Print file content, skipping raw transcript links
    grep -v "^\[\[Transcripts/" "$file" | head -80
    echo ""
  fi
done < <(find "$VAULT_DIR/Meetings/Notes" -name "*.md" -print0 2>/dev/null | sort -z)

if [[ $found -eq 0 ]]; then
  echo "_No meeting notes found mentioning \"$PROJECT\"._"
fi

# --- Tasks mentioning the project ---
echo "## Tasks Mentioning \"$PROJECT\""
echo ""

task_results=$(grep -r --include="*.md" -l "$PROJECT" "$VAULT_DIR" \
  --exclude-path="*/Transcripts/*" 2>/dev/null \
  | xargs grep -l "^- \[ \]" 2>/dev/null)

if [[ -z "$task_results" ]]; then
  echo "_No open tasks found in files mentioning \"$PROJECT\"._"
else
  while IFS= read -r taskfile; do
    short="${taskfile#$VAULT_DIR/}"
    tasks=$(grep "^- \[ \]" "$taskfile" 2>/dev/null)
    if [[ -n "$tasks" ]]; then
      echo "**$short**"
      echo "$tasks"
      echo ""
    fi
  done <<< "$task_results"
fi
