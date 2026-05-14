#!/usr/bin/env bash
# project-sync.sh — Update a project page from recent meeting notes
#
# Usage: ./scripts/project-sync.sh "<Project Name>"
#   e.g.: ./scripts/project-sync.sh "NV SCO"
#         ./scripts/project-sync.sh "BP Poland"
#
# Runs an iterative review loop: Copilot first proposes what changes it would
# make (which meeting notes it's using, what new tasks it would add), you review
# and provide feedback, then it writes the final project page.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

PROJECT="${1:-}"
[[ -n "$PROJECT" ]] || { echo "Usage: $0 \"<Project Name>\""; exit 1; }

log "Gathering project content for: $PROJECT"
CONTEXT=$(bash "$SCRIPTS_DIR/lib/gather-project.sh" "$PROJECT")

# Write static context (system prompt + vault content + sync instructions)
# to a persistent temp file so per-turn prompts stay small.
CONTEXT_FILE=$(mktemp "${TMPDIR:-/tmp}/gtd-sync-context-XXXXXX.md")
trap "rm -f '$CONTEXT_FILE'" EXIT

{
  cat "$PROMPTS_DIR/system.md"
  printf '\n\n---\n\n## Gathered Vault Content for: %s\n\n%s\n\n---\n\n' "$PROJECT" "$CONTEXT"
  cat "$PROMPTS_DIR/project-sync.md"
} > "$CONTEXT_FILE"

FEEDBACK=""
TURN=0
MAX_TURNS=5

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
printf "║  Project Sync — %-44s ║\n" "$PROJECT"
echo "║  Review proposed changes. Provide feedback or type 'done'.  ║"
echo "║  Press Ctrl-C to abort without saving.                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# --- Review loop ---
while [[ $TURN -lt $MAX_TURNS ]]; do
  TURN=$((TURN + 1))

  if [[ $TURN -eq 1 ]]; then
    TURN_INSTRUCTIONS="You are reviewing gathered vault content to plan an update for the project page.

Do NOT write the project page yet. Instead, produce a structured **Proposed Changes Report**:

1. **Meeting Notes Reviewed**: List each meeting note found, with a one-line assessment of
   how relevant it is to \"$PROJECT\" (High / Medium / Low relevance, and why if Low).
2. **Existing Tasks**: List the open tasks already in the vault for this project.
3. **Proposed New Tasks**: List ONLY tasks implied by meeting notes that do NOT already
   exist anywhere in the vault. For each, cite the meeting note it came from.
4. **Other Proposed Changes**: Any status updates, new blockers, new decisions, new
   stakeholders, or Notes & Context links to add.

Be explicit so the user can see exactly what would change and approve or correct it.
End your output with exactly: [PROPOSED CHANGES $TURN]"
  else
    TURN_INSTRUCTIONS="The user has reviewed your proposed changes and provided feedback.
Revise your Proposed Changes Report to incorporate their feedback.

If the user's feedback indicates approval (e.g. 'looks good', 'go ahead', 'done'),
output exactly: [READY TO APPLY]

Otherwise update the report and end with: [PROPOSED CHANGES $TURN]"
  fi

  TURN_PROMPT="Read the file $CONTEXT_FILE for the full background context and instructions.

## Feedback So Far

${FEEDBACK:-_(no feedback yet — this is the first review)_}

---

$TURN_INSTRUCTIONS"

  AGENT_OUTPUT=$(capture_prompt "$TURN_PROMPT")

  # AI signaled it's ready to apply (after feedback turn)
  if echo "$AGENT_OUTPUT" | grep -q "\[READY TO APPLY\]"; then
    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "${AGENT_OUTPUT//\[READY TO APPLY\]/}" | sed '/^[[:space:]]*$/d' | tail -5
    echo "─────────────────────────────────────────────────────────────"
    break
  fi

  # Strip signal token and display the proposed changes report
  REPORT_TEXT="${AGENT_OUTPUT//\[PROPOSED CHANGES $TURN\]/}"
  echo ""
  echo "$REPORT_TEXT"
  echo ""

  # Get user feedback
  printf "Feedback (or 'done' to apply changes as proposed): "
  read -r USER_FEEDBACK

  if [[ "$USER_FEEDBACK" == "done" ]]; then
    echo ""
    echo "Applying changes..."
    break
  fi

  FEEDBACK="${FEEDBACK}
---
After turn $TURN, user provided this feedback: $USER_FEEDBACK"
done

# --- Apply ---
echo ""
echo "Writing updated project page..."
echo ""

APPLY_PROMPT="Read the file $CONTEXT_FILE for the full background context and instructions.

## Review Feedback Incorporated

${FEEDBACK:-_(user approved the proposed changes without modification)_}

---

The review is complete. Now write the updated project page for \"$PROJECT\":

1. Write the file to the vault, replacing existing content entirely.
   - If the file exists, replace its contents (preserve YAML frontmatter, update \`updated:\` to today's date).
   - If not, create it at: obsidian-vault/Work/${PROJECT}.md
2. Only include changes that were approved — skip anything the user flagged as irrelevant or incorrect.
3. Do NOT add tasks that already exist anywhere in the vault (existing tasks were listed in the review).
4. Any new tasks in ## Next Actions must include #unreviewed (e.g. \`- [ ] Do thing #task #mine #unreviewed\`).
5. Use the format defined in prompts/project-page-format.md (read it from the filesystem).

After writing the file, print a brief summary of what was added or changed."

run_prompt "$APPLY_PROMPT" "Project Sync: $PROJECT"
