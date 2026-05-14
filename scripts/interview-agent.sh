#!/usr/bin/env bash
# interview-agent.sh — Structured interview to flesh out a project page
#
# Usage: ./scripts/interview-agent.sh "<Project Name>"
#   e.g.: ./scripts/interview-agent.sh "NV SCO"
#         ./scripts/interview-agent.sh "Back Office"
#
# Runs a multi-turn interview loop: Copilot asks one question at a time,
# you answer in the terminal, and the conversation grows until the agent
# has enough to write a complete project page.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

PROJECT="${1:-}"
[[ -n "$PROJECT" ]] || { echo "Usage: $0 \"<Project Name>\""; exit 1; }

log "Gathering existing vault content for: $PROJECT"
CONTEXT=$(bash "$SCRIPTS_DIR/lib/gather-project.sh" "$PROJECT")

# Write the static context (system prompt + vault content + interview instructions)
# to a persistent temp file. Each turn prompt references it by path rather than
# embedding the full text, keeping per-turn prompts small.
CONTEXT_FILE=$(mktemp "${TMPDIR:-/tmp}/gtd-interview-context-XXXXXX.md")
trap "rm -f '$CONTEXT_FILE'" EXIT

{
  cat "$PROMPTS_DIR/system.md"
  printf '\n\n---\n\n## Existing Vault Content for: %s\n\n%s\n\n---\n\n' "$PROJECT" "$CONTEXT"
  cat "$PROMPTS_DIR/interview-agent.md"
} > "$CONTEXT_FILE"

CONVERSATION=""
TURN=0
MAX_TURNS=10

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
printf "║  Interview Agent — %-42s ║\n" "$PROJECT"
echo "║  Answer each question. Type 'done' to skip to synthesis.    ║"
echo "║  Press Ctrl-C to abort without saving.                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# --- Interview loop ---
while [[ $TURN -lt $MAX_TURNS ]]; do
  TURN=$((TURN + 1))

  if [[ $TURN -eq 1 ]]; then
    TURN_INSTRUCTIONS="You are beginning the interview. Briefly summarize what you already know about
\"$PROJECT\" from the vault content (2-3 sentences), then ask your first question.

Output format: summary paragraph, blank line, then the question.
End your output with exactly: [QUESTION $TURN]"
  else
    TURN_INSTRUCTIONS="Based on the conversation above, ask the next question. If you have covered all
topics and have enough to write a solid project page, instead output exactly:
[READY TO SYNTHESIZE]

Otherwise ask your next question and end with: [QUESTION $TURN]"
  fi

  TURN_PROMPT="Read the file $CONTEXT_FILE for the full background context and interview instructions.

## Interview So Far

${CONVERSATION:-_(no answers yet)_}

---

$TURN_INSTRUCTIONS"

  # capture_prompt returns text to stdout; run_prompt opens a browser tab
  AGENT_OUTPUT=$(capture_prompt "$TURN_PROMPT")

  # Check if interview is complete
  if echo "$AGENT_OUTPUT" | grep -q "\[READY TO SYNTHESIZE\]"; then
    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "${AGENT_OUTPUT//\[READY TO SYNTHESIZE\]/}" | sed '/^[[:space:]]*$/d' | tail -5
    echo "─────────────────────────────────────────────────────────────"
    break
  fi

  # Print the question (strip the signal token)
  QUESTION_TEXT="${AGENT_OUTPUT//\[QUESTION $TURN\]/}"
  echo ""
  echo "$QUESTION_TEXT"
  echo ""

  # Get user's answer
  printf "Your answer (or 'done' to proceed to synthesis): "
  read -r USER_ANSWER

  if [[ "$USER_ANSWER" == "done" ]]; then
    echo ""
    echo "Skipping to synthesis..."
    break
  fi

  CONVERSATION="$CONVERSATION
---
Q$TURN: $QUESTION_TEXT
A$TURN: $USER_ANSWER"
done

# --- Synthesis ---
echo ""
echo "Synthesizing project page..."
echo ""

SYNTH_PROMPT="Read the file $CONTEXT_FILE for the full background context and interview instructions.

## Completed Interview

$CONVERSATION

---

The interview is complete. Now synthesize everything you know — from both the vault
content and the interview above — into a complete project page for \"$PROJECT\".

Use the format defined in prompts/project-page-format.md (read it from the filesystem).
Write the result to the project page file in the vault:
  - If the file exists, replace its contents entirely.
  - If not, create it at: obsidian-vault/Work/${PROJECT}.md
  - Set the updated: frontmatter field to today's date.
  - Any new tasks in the ## Next Actions section must include #unreviewed so they
    are picked up for triage (e.g. `#task #mine #unreviewed`).

After writing the file, print a brief summary of what was added or changed."

run_prompt "$SYNTH_PROMPT" "Interview: $PROJECT"
