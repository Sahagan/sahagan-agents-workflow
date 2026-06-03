# Create a New Agent from This Template

Clone this template and customize it for a new agent.

## Steps

1. **Copy the template**
   ```bash
   cp -r . ../agent-$ARGUMENTS
   cd ../agent-$ARGUMENTS
   ```

2. **Initialize as new repo**
   ```bash
   rm -rf .git
   git init
   ```

3. **Replace placeholders** in `AGENTS.md` and `persona/README.md`:
   - `{{name}}` -> agent name
   - `{{agentId}}` -> `agent-{name}`
   - `{{primaryModel}}` -> target model ID
   - `{{memoryPath}}` -> memory directory path

4. **Create config manifest**
   ```bash
   # Edit config.manifest.json with required placeholder values
   ```

5. **Verify backend symlinks**
   ```bash
   ls -la CLAUDE.md GEMINI.md CODEX.md KIMI.md
   # All should point to AGENTS.md
   ```

6. **Add project repos**
   ```bash
   git submodule add <project-repo-url> projects/{project-name}
   ```

7. **Validate neutrality**
   ```bash
   bash scripts/check-agent-neutrality.sh
   ```

8. **Initial commit**
   ```bash
   git add -A
   git commit -m "Init: agent-$ARGUMENTS from base template"
   ```
