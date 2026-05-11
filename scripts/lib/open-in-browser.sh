#!/usr/bin/env bash
# lib/open-in-browser.sh — render markdown from stdin as styled HTML and open in browser
#
# Usage:  some-command | bash open-in-browser.sh [title]
#
# Creates a temp HTML file, opens it with the appropriate launcher (WSL-aware),
# and cleans it up after a short delay.

TITLE="${1:-GTD Output}"

MARKDOWN=$(cat)

HTML_BODY=$(python3 - "$MARKDOWN" << 'PYEOF'
import sys, markdown
content = sys.argv[1]
print(markdown.markdown(content, extensions=['tables', 'fenced_code']))
PYEOF
)

TMPFILE=$(mktemp "${TMPDIR:-/tmp}/gtd-output-XXXXXX.html")

cat > "$TMPFILE" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${TITLE}</title>
<style>
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 15px;
    line-height: 1.6;
    color: #1a1a1a;
    background: #fafafa;
    max-width: 860px;
    margin: 40px auto;
    padding: 0 24px 80px;
  }
  h1 { font-size: 1.8em; border-bottom: 2px solid #ddd; padding-bottom: 0.3em; margin-top: 1.5em; }
  h2 { font-size: 1.3em; border-bottom: 1px solid #eee; padding-bottom: 0.2em; margin-top: 1.8em; color: #333; }
  h3 { font-size: 1.1em; margin-top: 1.4em; color: #444; }
  h4 { font-size: 1em; font-weight: 600; color: #555; }
  code {
    font-family: "SF Mono", "Fira Code", Consolas, monospace;
    font-size: 0.875em;
    background: #f0f0f0;
    padding: 0.15em 0.35em;
    border-radius: 3px;
  }
  pre {
    background: #f4f4f4;
    border: 1px solid #ddd;
    border-radius: 5px;
    padding: 14px 16px;
    overflow-x: auto;
  }
  pre code { background: none; padding: 0; }
  ul, ol { padding-left: 1.5em; }
  li { margin: 0.25em 0; }
  hr { border: none; border-top: 1px solid #ddd; margin: 2em 0; }
  blockquote {
    border-left: 4px solid #ccc;
    margin: 0;
    padding: 0.5em 1em;
    color: #555;
    background: #f9f9f9;
  }
  strong { color: #111; }
  table { border-collapse: collapse; width: 100%; margin: 1em 0; }
  th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
  th { background: #f0f0f0; font-weight: 600; }
  tr:nth-child(even) { background: #fafafa; }
  .timestamp { font-size: 0.8em; color: #999; margin-bottom: 2em; }
</style>
</head>
<body>
<p class="timestamp">Generated: $(date '+%A, %B %-d %Y at %-I:%M %p')</p>
${HTML_BODY}
</body>
</html>
HTMLEOF

# Open with appropriate launcher
open_file() {
  local file="$1"
  if grep -q -i microsoft /proc/version 2>/dev/null; then
    # WSL: convert to Windows path and use explorer.exe
    local winpath
    winpath=$(wslpath -w "$file" 2>/dev/null || echo "$file")
    explorer.exe "$winpath" 2>/dev/null
  elif which xdg-open &>/dev/null; then
    xdg-open "$file" 2>/dev/null
  elif which open &>/dev/null; then
    open "$file" 2>/dev/null  # macOS fallback
  else
    echo "[gtd] Cannot find a browser launcher. File is at: $file" >&2
    return 1
  fi
}

open_file "$TMPFILE" &

( sleep 15 && rm -f "$TMPFILE" ) &
