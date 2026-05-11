# Project Sync Prompt

The following content has been gathered from the vault for a specific project.
Your job is to **update the project page** with a current, synthesized view.

## Instructions

1. Review all the gathered content below: the existing project page, meeting notes
   that mention the project, and any open tasks.
2. Synthesize a updated project page using the format defined in
   `prompts/project-page-format.md`.
3. For each section of the project page:
   - **Status**: Update to reflect the most recent state. Set "As of" to today's date.
   - **Stakeholders**: Add any names/roles that appear in recent meeting notes.
   - **Open Decisions**: Add any unresolved decisions from meeting notes. Remove any
     that have been resolved.
   - **Blockers**: Add new blockers. Remove resolved ones.
   - **Next Actions**: Carry forward any open `- [ ]` tasks. Add new ones that are
     clearly implied by meeting notes but not yet written down.
   - **Key Decisions Made**: Append any decisions confirmed in recent meeting notes.
   - **Notes & Context**: Add links to key meeting notes (use `[[filename]]` format).
4. Write the updated project page back to the vault file, replacing it completely.
   Preserve the YAML frontmatter and update the `updated:` field to today's date.

## Important
- Do not invent information. Only write what is supported by the gathered content.
- If a section has nothing new, leave it as-is.
- If the project page doesn't exist yet, create it from scratch using the template.
- Keep the tone factual and brief within each section.
