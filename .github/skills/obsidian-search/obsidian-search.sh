#!/usr/bin/env bash
# Wraps the Obsidian CLI search for use in WSL.
# The Windows exe writes CRLF output; tr strips the carriage returns.
#
# Usage: obsidian-search.sh <query>
# Returns: one vault-relative file path per line (e.g. Work/Project.md)

if [[ -z "$1" ]]; then
  echo "Usage: obsidian-search.sh <query>" >&2
  exit 1
fi

obsidian.exe search query="$1" 2>/dev/null | tr -d '\r'
