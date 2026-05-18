# Vault Context — GTD Workflow System

You are assisting with a Getting Things Done (GTD)-style workflow backed by an
Obsidian vault. The vault is at:

    ~/projects/obsidian-ai/obsidian-vault/Work/

## Vault Layout

```
Work/
  Key Initiatives.md          # Master index: all products, customers, org areas
  Action Items.md             # Dashboard (Obsidian Tasks queries — do not edit)
  Things to Think on or Decide.md  # Open questions and future agenda items
  Random Notes.md             # Capture/inbox for unstructured notes
  Domain Glossary.md          # Canonical spellings and meanings for all domain terms
  <Project>.md                # One file per product/customer/org area
  Meetings/
    Notes/                    # One file per meeting, named YYYY-MM-DD <Title>.md
    Transcripts/              # Raw transcripts (skip these unless asked)
  Email/                      # Email summaries
```

## Domain Terminology

A domain glossary is maintained at `Work/Domain Glossary.md`. When reading or writing
any vault content:
- Use the exact spellings and abbreviations defined there (e.g. `SCO`, not `self-checkout`)
- Apply the glossary when interpreting ambiguous terms in transcripts, emails, or notes
- When generating output (summaries, project pages, briefings), prefer glossary terms
  over informal or alternative spellings

## Task Format

Tasks use the Obsidian Tasks plugin format:

    - [ ] Task description #tag1 #tag2 📅 YYYY-MM-DD

Each task also includes a wikilink to its project, e.g. `[[NV SCO]]`.

**Tag meanings:**
- `#task` — **required base tag**; a task line without `#task` is not a real action item
  (meeting notes often contain "Owner: X" lines that are not tagged — ignore those)
- `#mine` — I own this action; only meaningful when `#task` is also present
- `#follow-up` — assigned to someone else, but I am watching it; only meaningful with `#task`
- `#unreviewed` — inbox item, not yet classified; only meaningful with `#task`
- `#parked` — Someday/Maybe; intentionally deferred with no current commitment; revisit during weekly review

**Rules for reading tasks:**
- Only consider a task if it has `#task`. Ignore any task line missing `#task`.
- `#task #mine` → my next action (I am accountable)
- `#task #follow-up` → waiting for someone else (I want to stay informed / may need to nudge)
- `#task #unreviewed` → needs triage
- `#task #parked` → Someday/Maybe; deferred, no current commitment; surface during weekly review
- Tags may appear in any order on the line.

Completed tasks look like:
    - [x] Task description #task #mine ✅ YYYY-MM-DD

When collecting open tasks, match lines starting with `- [ ]` or `* [ ]` that also contain `#task`.

## Capturing New Tasks

New next actions are added from within Obsidian using **QuickAdd**:

- **Quick inbox capture** (`Capture: Next Action (Inbox)`): appends
  `- [ ] <action> #task #mine #unreviewed` to `Random Notes.md` for later triage.
- **Project capture** (`Add Next Action to Project`): runs a macro that prompts for
  a project (picked from the vault file list) and an optional due date, then appends
  a properly formatted `#task #mine` line to that project's `## Next Actions` section.

The macro script lives at `obsidian-vault/scripts/add-next-action.js`.

## Meeting Note Format

Each meeting note has YAML frontmatter followed by consistent sections:

```yaml
---
date: YYYY-MM-DD
type: meeting
source: transcript | notes
status: summarized | draft
attendees: Name1, Name2
---
```

Sections: Meeting Summary, Key Discussion Points, Decisions Made, Action Items.
The Action Items section contains tasks in the format above.

## Project Page Format

Project pages follow this structure (explained in detail in `prompts/project-page-format.md`).
Key points:
- The `## Next Actions` section contains tasks the Action Items dashboard queries
- The `## Status` section has a machine-readable **Current:** line
- Sections are separated by `##` headers; update sections in place, never remove them

## Key Initiatives Index

`Key Initiatives.md` lists all areas under three headings:
- **Products**: CFR POS, FDMM POS, NV SCO, DSR POS, Back Office, Japan POS, VFS,
  System Software, Store in a Box
- **Customers**: Aeon, ADUSA, BP Poland
- **Projects**: Projects that are stand alone or in addition to general customer projects
- **Process**: Process improvement initiatives
- **Organization**: Projects related to the overall company or retail engineering organization

Each entry links to a corresponding project page file.

## GTD Roles

| GTD concept     | Where it lives                              |
|----------------|---------------------------------------------|
| Inbox           | `#unreviewed` tasks, `Random Notes.md`      |
| Next Actions    | `#mine` tasks across all files              |
| Waiting For     | `#follow-up` tasks across all files         |
| Projects        | Project page files in `Work/`               |
| Someday/Maybe   | `#parked` tasks, `Things to Think on or Decide.md` |
| Reference       | Meeting notes, architecture notes           |

## Writing Back to the Vault

When a workflow produces output that should be saved to the vault:
- Update project pages by replacing the content of the relevant `##` section
- Add items to `Things to Think on or Decide.md` as new bullet points
- Create new meeting notes or review files in `Work/Meetings/Notes/` with the date
  prefix `YYYY-MM-DD`
- Never modify `Action Items.md` (it is auto-generated from Tasks queries)
- Preserve all existing YAML frontmatter; update the `updated:` field when editing
  a project page
- If a task is added, always append the #unreviewed tag so it can be triaged
- Do not tasks that already exist to any page. These will be picked up by dashboards fro the Task plugin. Adding them a second time (e.g. to a project page)
  creates duplicates
---
