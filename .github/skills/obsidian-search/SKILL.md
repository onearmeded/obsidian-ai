---
name: obsidian-search
description: Search the Obsidian Work vault by content, tags, or path. Use this whenever you need to find which vault files contain specific text, tags, people, or project names — instead of using grep.
allowed-tools: shell
---

## Overview

Use `obsidian-search.sh` (in this skill's directory) to search the Obsidian vault. It wraps the Obsidian CLI and handles the WSL/Windows output encoding automatically, returning clean file paths one per line.

## Usage

```bash
bash <skill-dir>/obsidian-search.sh "<query>"
```

Each result is a vault-relative path, e.g. `Work/Project.md`. To read a result, prepend `~/projects/obsidian-ai/obsidian-vault/`:

```bash
cat ~/projects/obsidian-ai/obsidian-vault/Work/Project.md
```

## Query Syntax

Obsidian search supports a rich query language:

| Query | Finds |
|---|---|
| `some text` | Files containing all those words |
| `tag:#task` | Files containing the tag `#task` |
| `tag:#task tag:#mine` | Files with both tags |
| `path:"Meetings/Notes"` | Files whose path contains that string |
| `path:"Meetings/Notes" tag:#task` | Combine operators freely |
| `"exact phrase"` | Files containing the exact phrase |

## Common Patterns

**Find all files with open tasks I own:**
```bash
bash <skill-dir>/obsidian-search.sh "tag:#task tag:#mine"
```

**Find files mentioning a person or project by name:**
```bash
bash <skill-dir>/obsidian-search.sh "Barrett Francis"
bash <skill-dir>/obsidian-search.sh "Customer-Specific Driver"
```

**Find recent meeting notes (then filter by date in your reasoning):**
```bash
bash <skill-dir>/obsidian-search.sh 'path:"Meetings/Notes"'
```

**Find files with unreviewed tasks:**
```bash
bash <skill-dir>/obsidian-search.sh "tag:#task tag:#unreviewed"
```

## When to Use This vs. grep

- **Use this skill** when you want to find *which files* contain something — content search, tag search, path filtering.
- **Use grep** when you need to extract specific lines or text *within* files you've already identified (e.g., pulling task lines from a known file).

A common pattern is: search with this skill to get a file list, then read those files directly or use grep to extract specific lines.
