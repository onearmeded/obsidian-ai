# Project Page Format

All project pages in the vault use the following structure. When creating or updating
a project page, preserve any existing content within each section and update or add
only what the new information supports.

---

## Template

```markdown
---
tags: [project]
updated: YYYY-MM-DD
---

# <Project Name>

> One-sentence description of what this is and why it matters to the business.

## Status

**Current**: Active | On Hold | Blocked | Completed | Unknown
**As of**: YYYY-MM-DD

[One paragraph: where things stand right now, key recent developments.]

## Stakeholders

- **Name** — Role / what they care about

## Open Decisions

Items that need a decision before this project can move forward. Remove items once decided.

- Decision or question that is open

## Blockers

Active impediments. Remove items once resolved.

- What is blocking progress

## Next Actions

Tasks in Obsidian Tasks format. These appear in the Action Items dashboard automatically.

- [ ] Specific next action #task #mine
- [ ] Something waiting on someone #task #follow-up

## Key Decisions Made

Decisions that have been made and should be remembered (keep this as a log).

- Decision made (YYYY-MM-DD): brief description

## Notes & Context

Background information, links to related resources, anything useful for understanding
the project that does not fit the above sections.

- [[Relevant Meeting Note]] — brief description

## Task Dashboard

### My Actions
```tasks
not done
tags include #mine
(path includes <Project Name>) OR (description includes [[<Project Name>]])
```

### Waiting For
```tasks
not done
tags include #follow-up
(path includes <Project Name>) OR (description includes [[<Project Name>]])
```

### Inbox
```tasks
not done
tags include #unreviewed
(path includes <Project Name>) OR (description includes [[<Project Name>]])
```

### Someday / Maybe
```tasks
not done
tags include #parked
(path includes <Project Name>) OR (description includes [[<Project Name>]])
```

---

## Rules for Updating

1. **Always update the `updated:` frontmatter field** to today's date when editing.
2. **Do not remove sections** — if a section is empty, leave it with a placeholder comment.
3. **Next Actions** must use valid Obsidian Tasks format so the dashboard picks them up.
4. **Open Decisions** and **Blockers** are living lists — remove items when resolved.
5. **Key Decisions Made** is append-only — never remove past decisions.
6. The one-line description after `>` should remain stable unless fundamentally wrong.
7. **Task Dashboard** queries must use the exact project name in `path includes` and `[[...]]` — replace `<Project Name>` with the actual file name (without `.md`).
