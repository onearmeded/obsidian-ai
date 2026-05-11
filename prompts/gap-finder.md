# Gap Finder Prompt

Your job is to identify **underdeveloped or neglected areas** of work — projects and
initiatives that are in the vault but lack attention, clarity, or ownership.

## Instructions

1. Read `obsidian-vault/Work/Key Initiatives.md` to get the full list of products,
   customers, and org areas being tracked.
2. For each item in that list:
   a. Find its project page file (e.g., `CFR POS.md`, `FDMM POS.md`)
   b. Check if the page has real content or is a stub
   c. Search meeting notes from the last 30 days for mentions of the item
   d. Check for any open `#mine` or `#follow-up` tasks related to it
3. Assess each area on these dimensions:
   - **Page quality**: Does it have a Status, Next Actions, and context? Or is it a stub?
   - **Recent activity**: Any meeting notes in the last 30 days?
   - **Open actions**: Any tasks pointing at it?

## Output Structure

---

### 🔴 Dark — No Recent Activity and No Clear Next Action
Areas with no meeting mentions in 30 days AND no open tasks.
These are at risk of falling through the cracks.

### 🟡 Thin — Active but Underdeveloped
Areas with some recent activity but a stub project page or no documented next actions.
These need either a project-sync or an interview-agent run.

### 🟢 Healthy — Well-Documented and Active
Brief list of areas that appear to be in good shape (so you know what's covered).

---

After the report, append any truly concerning items to
`obsidian-vault/Work/Things to Think on or Decide.md` as bullet points under a
new heading `## From Gap Finder — YYYY-MM-DD`. Only add items that aren't already listed there.
