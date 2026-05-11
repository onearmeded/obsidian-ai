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

SYSTEM=$(cat "$PROMPTS_DIR/system.md")
INTERVIEW_INSTRUCTIONS=$(cat "$PROMPTS_DIR/interview-agent.md")

# Shared preamble injected into every turn
PREAMBLE="$SYSTEM

---

## Existing Vault Content for: $PROJECT

$CONTEXT

---

$INTERVIEW_INSTRUCTIONS"

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
    TURN_PROMPT="$PREAMBLE

You are beginning the interview. Briefly summarize what you already know about
\"$PROJECT\" from the vault content above (2-3 sentences), then ask your first question.

Output format: summary paragraph, blank line, then the question.
End your output with exactly: [QUESTION $TURN]"
  else
    TURN_PROMPT="$PREAMBLE

## Interview So Far

$CONVERSATION

---

Based on the conversation above, ask the next question. If you have covered all
topics and have enough to write a solid project page, instead output exactly:
[READY TO SYNTHESIZE]

Otherwise ask your next question and end with: [QUESTION $TURN]"
  fi

  # Get next question from the agent
  AGENT_OUTPUT=$(run_prompt "$TURN_PROMPT")

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

SYNTH_PROMPT="$PREAMBLE

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

After writing the file, print a brief summary of what was added or changed."

run_prompt "$SYNTH_PROMPT"
