# GTD AI Assistant

## Primary Interface: `gtd.sh`

Everything is driven through `gtd.sh`, which launches an interactive Copilot session
with the vault and domain glossary loaded, using the `gtd-assistant` agent:

```bash
# Open an interactive session
./gtd.sh

# Start with an initial prompt
./gtd.sh "Give me a daily briefing"
./gtd.sh --prompt "Weekly review"
```

The agent has access to the full vault and can do everything the old scripts did —
briefings, weekly reviews, project syncs, 1-1 prep, inbox processing, and more — all
in a conversational interface.

---

## Legacy Scripts (Deprecated)

The scripts below are no longer the recommended way to use this system. They remain
in `scripts/` for reference but `gtd.sh` supersedes them all.

**Optional environment variable** (applies to all scripts):

| Variable | Default | Effect |
|---|---|---|
| `COPILOT_EFFORT` | `medium` | Sets `--reasoning-effort` passed to `copilot`. Use `low` or `high` to trade speed for quality. |

---

## Entry-point Scripts

### `daily-briefing.sh`

**Purpose:** "What should I focus on today?" — generates a prioritized daily briefing.

Gathers your open `#task #mine` items, `#task #follow-up` items, and meeting notes
from the last 7 days, then asks Copilot to synthesize a focused daily plan. Output
opens in a browser tab.

```bash
./scripts/daily-briefing.sh
```

No parameters.

---

### `weekly-review.sh`

**Purpose:** Full GTD weekly review — inbox triage, open actions, project health,
horizon check, and housekeeping.

Gathers all open tasks (all tags) and meeting notes from the last 14 days. Output
opens in a browser tab.

```bash
./scripts/weekly-review.sh
```

No parameters.

---

### `project-sync.sh`

**Purpose:** Update a project page from recent meeting notes.

Collects all vault content related to the named project (project page + meeting notes
+ tasks mentioning the project), then asks Copilot to synthesize an updated project
page and write it back to the vault. Output opens in a browser tab.

```bash
./scripts/project-sync.sh "<Project Name>"

# Examples:
./scripts/project-sync.sh "NV SCO"
./scripts/project-sync.sh "BP Poland"
```

| Argument | Required | Description |
|---|---|---|
| `<Project Name>` | Yes | Name of the project. Must match (or partially match) the vault page filename. |

---

### `interview-agent.sh`

**Purpose:** Structured multi-turn interview to flesh out a project page from scratch.

Runs an interactive loop in the terminal: Copilot summarizes what it already knows
about the project, then asks one question at a time. You answer in the terminal.
After up to 10 questions (or when you type `done`), Copilot synthesizes all gathered
information into a complete project page and writes it to the vault.

```bash
./scripts/interview-agent.sh "<Project Name>"

# Examples:
./scripts/interview-agent.sh "NV SCO"
./scripts/interview-agent.sh "Back Office"
```

| Argument | Required | Description |
|---|---|---|
| `<Project Name>` | Yes | Name of the project to interview about. |

**Interactive prompts:**

- Answer each question at the terminal prompt.
- Type `done` at any question to skip straight to synthesis.
- Press `Ctrl-C` to abort without saving.

---

### `gap-finder.sh`

**Purpose:** "Which areas are underdeveloped or going dark?"

Scans all projects in Key Initiatives against recent meeting activity and task
coverage to surface neglected areas. Optionally appends concerning items to the
"Things to Think on or Decide" parking lot. Output opens in a browser tab.

```bash
./scripts/gap-finder.sh
```

No parameters. Context is read directly from the vault by Copilot.

---

### `horizon-scan.sh`

**Purpose:** "What's coming up that needs thinking?"

Gathers `#task #follow-up` items and meeting notes from the last 14 days to surface
upcoming decisions, potential blockers, and items at risk of going stale. Output
opens in a browser tab.

```bash
./scripts/horizon-scan.sh
```

No parameters.

---

### `one-on-one-prep.sh`

**Purpose:** Prepare a prep sheet for a 1-1 meeting.

Finds all past 1-1 meeting notes for the named person (matching files named
`YYYY-MM-DD <Name> 1-1 ...`), plus any open tasks across the vault that mention
them. Produces a prep sheet with follow-ups and suggested discussion topics.
Output opens in a browser tab.

```bash
# Interactive — pick from a numbered list of known participants:
./scripts/one-on-one-prep.sh

# Or pass a name directly:
./scripts/one-on-one-prep.sh "Chris"
```

| Argument | Required | Description |
|---|---|---|
| `<Name>` | No | Name of the person. If omitted, a numbered list of known 1-1 participants is shown and you can select by name or number. |

---

### `process-inbox.sh`

**Purpose:** Triage unreviewed tasks (`#task #unreviewed`).

Reads all inbox tasks and asks Copilot to recommend a classification for each:
keep as `#mine`, change to `#follow-up`, or close. Runs in two modes:

```bash
# Analysis mode (default) — prints recommendations, makes no changes:
./scripts/process-inbox.sh

# Apply mode — writes recommended changes directly to vault files:
./scripts/process-inbox.sh --apply
```

| Argument | Required | Description |
|---|---|---|
| `--apply` | No | Re-runs analysis and applies all changes to vault files in place. Review analysis output first before using this flag. |

---

## Library Scripts (`lib/`)

These are not meant to be run directly. They are sourced or invoked by the
entry-point scripts above.

### `lib/common.sh`

Sourced by every entry-point script. Sets shared variables and defines core helpers.

**Variables set:**

| Variable | Value |
|---|---|
| `PROJECT_ROOT` | Repo root (two levels up from `lib/`) |
| `SCRIPTS_DIR` | `$PROJECT_ROOT/scripts` |
| `VAULT_DIR` | `$PROJECT_ROOT/obsidian-vault/Work` |
| `PROMPTS_DIR` | `$PROJECT_ROOT/prompts` |

**Functions:**

| Function | Signature | Description |
|---|---|---|
| `log` | `log "message"` | Prints a `[gtd]`-prefixed message to stderr. |
| `die` | `die "message"` | Prints error to stderr and exits with code 1. |
| `build_prompt` | `build_prompt "task-file.md" [extra-context]` | Prepends `system.md` to the named prompt file, with optional extra context string inserted between them. Returns the combined prompt string. |
| `capture_prompt` | `capture_prompt "prompt text"` | Runs `copilot` non-interactively and returns output to stdout. Writes prompt to a temp file to avoid `ARG_MAX` limits. |
| `run_prompt` | `run_prompt "prompt text" ["Page Title"]` | Like `capture_prompt`, but pipes output through `open-in-browser.sh` to render as HTML and open in a browser tab. |

---

### `lib/gather-tasks.sh`

Extracts open tasks from the vault, filtered by tag.

```bash
bash scripts/lib/gather-tasks.sh [tag]
```

| Argument | Default | Description |
|---|---|---|
| `tag` | `all` | Which task category to return: `mine`, `follow-up`, `unreviewed`, or `all`. |

Only tasks tagged with **both** `#task` and the secondary tag are included.
Transcript files are excluded. Output is markdown, printed to stdout.

---

### `lib/gather-meetings.sh`

Collects recent meeting note content from `Work/Meetings/Notes/`.

```bash
bash scripts/lib/gather-meetings.sh [days]
```

| Argument | Default | Description |
|---|---|---|
| `days` | `7` | How many days back to include. Meeting notes must be named with a `YYYY-MM-DD` prefix to be matched. |

Raw transcript wikilinks are stripped. Output is markdown, printed to stdout.

---

### `lib/gather-project.sh`

Assembles all vault content for a named project: the project page, meeting notes
mentioning the project, and open tasks from files mentioning the project.

```bash
bash scripts/lib/gather-project.sh "<Project Name>"
```

| Argument | Required | Description |
|---|---|---|
| `<Project Name>` | Yes | Project name. Matches exactly against `Work/<Name>.md`, then falls back to a case-insensitive partial match. Meeting notes are searched case-insensitively. |

Output is markdown, printed to stdout.

---

### `lib/open-in-browser.sh`

Renders markdown from stdin as styled HTML and opens it in the default browser.

```bash
some-command | bash scripts/lib/open-in-browser.sh [title]
```

| Argument | Default | Description |
|---|---|---|
| `title` | `GTD Output` | The `<title>` and browser tab title for the generated page. |

Writes a temp HTML file, opens it (WSL, `xdg-open`, and `open` are all supported),
then deletes the file after 15 seconds.

Requires Python 3 with the `markdown` package installed.
