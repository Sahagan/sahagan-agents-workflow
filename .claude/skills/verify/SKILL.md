---
name: verify
description: Run the neutrality check to validate the agent template
when_to_use: After editing any documentation file, before committing
allowed-tools: Bash(bash scripts/*)
argument-hint: ""
---

# Verify Template Neutrality

Run the automated neutrality and format validation:

```bash
bash scripts/check-agent-neutrality.sh
```

After running:
1. If **0 violations**: template is clean, safe to commit
2. If **violations found**: fix each one before committing
3. **Warnings** in documentation context are acceptable -- verify they are descriptive, not prescriptive

Common violations:
- Hardcoded model IDs in AGENTS.md (use `{{primaryModel}}` placeholder)
- Hardcoded tool names (use `{{deepMemoryCmd}}` placeholder)
- Backend-specific language ("Claude will..." outside documentation)
- AGENTS.md has YAML frontmatter, wikilinks, or Obsidian callouts
- Missing YAML frontmatter in documentation files
- Non-standard callout types (approved: abstract, tip, warning, example, note, danger)
