#!/usr/bin/env bash
# lib/gather-tasks.sh — extract open tasks from the vault by tag
#
# Usage: gather-tasks.sh [tag]
#   tag: mine | follow-up | unreviewed | parked | all  (default: all)
#
# Only tasks tagged with BOTH #task AND the secondary tag are included.
# Task lines without #task (e.g. AI-generated "Owner:" lines) are ignored.

source "$(dirname "$0")/common.sh"

TAG="${1:-all}"

print_tasks_for_tag() {
  local tag="$1"
  local label="$2"
  local found=0

  echo "## $label"
  echo ""

  while IFS= read -r -d '' file; do
    local short_file="${file#$VAULT_DIR/}"
    local tasks

    if [[ "$tag" == "all" ]]; then
      # All tagged tasks: must have #task plus at least one secondary tag
      tasks=$(grep -n "^- \[ \]" "$file" 2>/dev/null \
        | grep "#task" || true)
    else
      # Require both #task and the specific secondary tag (any order)
      tasks=$(grep -n "^- \[ \]" "$file" 2>/dev/null \
        | grep "#task" \
        | grep "#${tag}" || true)
    fi

    [[ -z "$tasks" ]] && continue

    found=1
    echo "**$short_file**"
    while IFS= read -r taskline; do
      echo "${taskline#*:}"
    done <<< "$tasks"
    echo ""
  done < <(find "$VAULT_DIR" -name "*.md" -not -path "*/Transcripts/*" -print0 | sort -z)

  if [[ $found -eq 0 ]]; then
    echo "_No open tasks found${tag:+ for #task + #${tag}}_"
    echo ""
  fi
}

echo "# Open Tasks from Vault"
echo "_Gathered: $(date '+%Y-%m-%d %H:%M')_"
echo ""

case "$TAG" in
  mine)       print_tasks_for_tag "mine"       "My Next Actions (#task #mine)" ;;
  follow-up)  print_tasks_for_tag "follow-up"  "Waiting For (#task #follow-up)" ;;
  unreviewed) print_tasks_for_tag "unreviewed" "Inbox — Needs Review (#task #unreviewed)" ;;
  parked)     print_tasks_for_tag "parked"     "Someday/Maybe (#task #parked)" ;;
  all)
    print_tasks_for_tag "mine"       "My Next Actions (#task #mine)"
    print_tasks_for_tag "follow-up"  "Waiting For (#task #follow-up)"
    print_tasks_for_tag "unreviewed" "Inbox — Needs Review (#task #unreviewed)"
    print_tasks_for_tag "parked"     "Someday/Maybe (#task #parked)"
    ;;
  *)
    die "Unknown tag '$TAG'. Use: mine | follow-up | unreviewed | parked | all"
    ;;
esac
