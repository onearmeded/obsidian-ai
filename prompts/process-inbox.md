# Inbox Processor Prompt

Your job is to **triage unreviewed tasks** from the vault — the GTD inbox.

## Instructions

1. Find all tasks tagged `#unreviewed` across the vault.
2. For each task, read the surrounding context (the file it's in, nearby text) to
   understand what it is.
3. Recommend one of:
   - **Keep as #mine** — this is clearly my action to take
   - **Change to #follow-up** — I'm waiting on someone else for this
   - **Close** — this is already done, irrelevant, or superseded
   - **Needs clarification** — you can't tell from context alone

## Output Structure

For each task, output:

```
FILE: <source file>
TASK: <task text>
RECOMMENDATION: Keep as #mine | Change to #follow-up | Close | Needs clarification
REASON: <one sentence>
```

Then at the end, produce a **Summary of Changes** showing the exact find-and-replace
operations needed to apply all recommendations:

```
CHANGES TO APPLY:
1. In <file>: replace `#unreviewed` with `#mine` on line: <task text>
2. In <file>: replace `- [ ]` with `- [x]` and remove `#unreviewed` on line: <task text>
...
```

## Important
- Do NOT apply changes automatically. Output only the analysis and the change summary.
- The user will review and then run `process-inbox.sh --apply` to apply changes.
- If a task is genuinely ambiguous, say so — don't guess.
