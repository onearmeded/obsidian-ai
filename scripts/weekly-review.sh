#!/usr/bin/env bash
# weekly-review.sh — Interactive GTD weekly review via interview
#
# Usage: ./scripts/weekly-review.sh
#
# Conducts a structured interview about the past week — what went well,
# what didn't, and what's weighing on you — before generating the full
# GTD weekly review report and saving it to the vault.

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

log "Gathering all tasks..."
ALL_TASKS=$(bash "$SCRIPTS_DIR/lib/gather-tasks.sh" all)

log "Gathering meeting notes (last 14 days)..."
MEETINGS=$(bash "$SCRIPTS_DIR/lib/gather-meetings.sh" 14)

CONTEXT="$ALL_TASKS

$MEETINGS"

# Write static context to a temp file so per-turn prompts stay small.
CONTEXT_FILE=$(mktemp "${TMPDIR:-/tmp}/gtd-weekly-review-context-XXXXXX.md")
trap "rm -f '$CONTEXT_FILE'" EXIT

{
  cat "$PROMPTS_DIR/system.md"
  printf '\n\n---\n\n## Vault Context\n\n%s\n\n---\n\n' "$CONTEXT"
  cat "$PROMPTS_DIR/weekly-review-interview.md"
} > "$CONTEXT_FILE"

CONVERSATION=""
TURN=0
MAX_TURNS=8

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Weekly Review — Interview Mode                              ║"
echo "║  Answer each question. Type 'done' to skip to synthesis.    ║"
echo "║  Press Ctrl-C to abort without saving.                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# --- Interview loop ---
while [[ $TURN -lt $MAX_TURNS ]]; do
  TURN=$((TURN + 1))

  if [[ $TURN -eq 1 ]]; then
    TURN_INSTRUCTIONS="You are beginning the weekly review interview. Based on the vault content,
briefly highlight 2–3 observations from the past week (open loops, overdue items,
patterns worth noting), then suggest 2–3 areas the person might want to brainstorm
on. After the suggestions, ask your first interview question about what went well.

Output format: observations paragraph, blank line, brainstorm suggestions as a short
bulleted list, blank line, then the question.
End your output with exactly: [QUESTION $TURN]"
  else
    TURN_INSTRUCTIONS="Based on the conversation above, ask the next question. If you have covered
enough topics and have enough context to write a thorough weekly review, instead
output exactly:
[READY TO SYNTHESIZE]

Otherwise ask your next question and end with: [QUESTION $TURN]"
  fi

  TURN_PROMPT="Read the file $CONTEXT_FILE for the full background context and interview instructions.

## Interview So Far

${CONVERSATION:-_(no answers yet)_}

---

$TURN_INSTRUCTIONS"

  AGENT_OUTPUT=$(capture_prompt "$TURN_PROMPT")

  if echo "$AGENT_OUTPUT" | grep -q "\[READY TO SYNTHESIZE\]"; then
    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "${AGENT_OUTPUT//\[READY TO SYNTHESIZE\]/}" | sed '/^[[:space:]]*$/d' | tail -5
    echo "─────────────────────────────────────────────────────────────"
    break
  fi

  QUESTION_TEXT="${AGENT_OUTPUT//\[QUESTION $TURN\]/}"
  echo ""
  echo "$QUESTION_TEXT"
  echo ""

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
echo "Synthesizing weekly review..."
echo ""

SYNTH_PROMPT="Read the file $CONTEXT_FILE for the full vault context.

## Completed Interview

$CONVERSATION

---

The interview is complete. Now produce a full GTD weekly review that incorporates
both the vault analysis and the interview conversation above.

Read prompts/weekly-review.md from the filesystem for the output format and phases.

Save the review note to the vault as:
  obsidian-vault/Work/Meetings/Notes/$(date +%Y-%m-%d) Weekly Review.md

After writing the file, print a brief summary of key themes and top priorities."

run_prompt "$SYNTH_PROMPT" "Weekly Review"
