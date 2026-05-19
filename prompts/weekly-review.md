# Weekly Review Prompt

Your job is to guide a **GTD Weekly Review** of the vault. This is a structured
check-in to close open loops, update the system, and set up the coming week.

## Instructions

Work through each phase in order. Be thorough but concise in your output.

---

## Phase 1 — Inbox Triage
1. Read all `#unreviewed` tasks from the vault.
2. For each, recommend: keep as `#mine`, change to `#follow-up`, or close (already done/irrelevant).
3. Read `obsidian-vault/Work/Random Notes.md` — flag any items that should become tasks
   or be moved to a project page.

## Phase 2 — Open Actions Review
1. List all open `#mine` tasks. Flag any that are overdue or have been open an unusually long time.
2. List all open `#follow-up` tasks. Flag any open longer than 14 days.
3. Note any tasks that seem unclear or don't map to an active project.

## Phase 3 — Project Health Check
1. For each project in `Key Initiatives.md`, report:
   - Page quality (stub vs. fleshed out)
   - Any open tasks
   - Last meeting mention (within 30 days?)
2. Flag projects that need a `project-sync` or `interview-agent` run.

## Phase 4 — Horizon Check
1. Review `obsidian-vault/Work/Things to Think on or Decide.md`.
2. Flag any items that need a decision this week.
3. Note any commitments from recent meetings that don't have tasks yet.

## Phase 5 — Housekeeping
1. Are there any completed tasks that weren't marked done?
2. Are there meeting notes from this week with unprocessed action items?

---

## Output

Produce the full weekly review covering all five phases above. Include a
**Top 5 Priorities for the Coming Week** section based on what you've found.

Do **not** write any files — the shell will handle saving the output.

At the very end of your response, append a daily-note summary block using exactly
this delimiter format (replace the placeholder content with the actual week link
and 2–3 key themes):

```
<!-- DAILY_SUMMARY -->
## Weekly Review

[[WEEK_LINK]] — [one-sentence summary of the week's key themes]

**Heading into next week:**
- [top priority 1]
- [top priority 2]
- [top priority 3]
<!-- /DAILY_SUMMARY -->
```

Where `WEEK_LINK` is the ISO week identifier (e.g. `2026-W20`).
