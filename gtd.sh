#!/usr/bin/env bash
# Usage: ./gtd.sh ["prompt text"]
#   or:  ./gtd.sh --prompt "prompt text"
PROMPT_ARG=()
if [[ "$1" == "--prompt" && -n "$2" ]]; then
  PROMPT_ARG=(--interactive "$2")
elif [[ -n "$1" && "$1" != --* ]]; then
  PROMPT_ARG=(--interactive "$1")
fi
copilot --add-dir ~/projects/obsidian-ai/obsidian-vault/Work \
  --allow-all-tools --agent gtd-assistant  \
  --add-dir ~/projects/obsidian-ai/domain-glossary.txt \
  "${PROMPT_ARG[@]}"
