# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2026-07-04

### Added
- **Dev Lead skills for Phayu** — `api-and-interface-design` and `debugging-and-error-recovery` (addyosmani/agent-skills), injected per task type: API/interface design work gets `api-and-interface-design`, bug/debugging work gets `debugging-and-error-recovery`, general implementation gets neither. Never inject both at once.

### Removed
- **Ponytail skill** — removed entirely. It was written for interactive Claude Code sessions (slash commands, session state) and never worked once injected into one-shot `claude -p` / `codex` subprocess spawns. Replaced by the two task-specific skills above.

[1.4.0]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.3.3...v1.4.0

## [1.3.3] - 2026-06-26

### Fixed
- **Smart upgrade diff** — `aw upgrade` now walks the entire template directory and compares every file's content against the installed version, instead of overwriting a hardcoded list
- `interconnect/coordination.md` and any future template files are now correctly detected and updated
- Backup only contains files that actually changed (not a fixed set)
- Final summary shows exactly which files were `+` added or `~` changed
- Preserved user data is now explicit: `memories/`, `projects/`, `PROJECT.md`, `context/session-state.json`

[1.3.3]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.3.2...v1.3.3

## [1.3.2] - 2026-06-26

### Fixed
- **Full English support** — English-speaking users can now use the workflow without friction
- `applyLanguageDirective()` now covers `interconnect/coordination.md` + all 3 bundled skills (`session-start`, `session-end`, `initproject`) so English directive propagates to routing rules and session protocols
- Default language changed to **English** (press Enter or 2); Thai requires explicit `[1]`; `langPrompt` updated to show `English (default — press Enter)`
- `session-start` skill: greeting is now language-neutral (no hardcoded Thai); summary template in English; memory-absent message in English
- `session-end` skill: session summary template headings in English; closing message language-neutral
- `initproject` skill: PROJECT.md team section bilingual (English + Thai); report output in English; tech stack TODO comment in English

[1.3.2]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.3.1...v1.3.2

## [1.3.1] - 2026-06-26

### Fixed
- **coordination.md** — add Bonus (โบนัส) to Roles table; add explicit Routing Decision Rules with trigger scenarios per agent; add mandatory Planning Gate (Angpao must declare agent map before every spawn); add `Research → Implement` pattern (Bonus → Phayu); Angpao forbidden from WebSearch/WebFetch directly
- **session-start skill** — scan `persona/` and `interconnect/coordination.md` on every session start so Angpao auto-discovers new team members and refreshes routing rules without relying on memory alone

[1.3.1]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.3.0...v1.3.1

## [1.3.0] - 2026-06-26

### Added
- **Bonus (โบนัส)** — new Research Specialist agent; 5th family member; calm and methodical younger brother of Phayu; tools: Read/Write/Bash/Glob/Grep/WebSearch/WebFetch; skill: planning-and-task-breakdown; output: structured markdown reports with sources
- **Git Worktrees pattern** — parallel agents run in isolated branches to prevent file conflicts; documented in CLAUDE.md
- **Shared Session State** — context/session-state.template.json; all agents read shared state before starting; Angpao writes task assignments; eliminates agents operating in isolation
- **Error Recovery** — spawn_agent() bash wrapper with configurable retry count; workflow survives agent failures
- **Structured Agent Output** — JSON summary block standard; every agent closes with { agent, taskId, status, filesChanged, summary, nextSteps }
- **Context Engineering** — dynamic prompt assembly injects session-state.json into each agent's prompt for cross-agent awareness
- **MCP per Role** — documented --mcp-config pattern; mcp-researcher.json.example for Bonus's web research tools
- **aw upgrade: self-update** — checks npm for newer package version and auto-updates before applying template

### Changed
- aw upgrade now self-updates the CLI package first (npm install -g), then applies the latest bundled template
- All team announcements and help text updated to include Bonus (5-member family)
- applyLanguageDirective now includes persona/researcher.md

[1.3.0]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.2.3...v1.3.0

## [1.2.3] - 2026-06-19

### Added
- GitHub Actions CI/CD — auto-publish to npm and GitHub Packages on tag push
- GitHub Release created automatically with release notes on each version tag
- PIXEL AGENTS VS Code extension demo screenshot in README
- CHANGELOG.md, `homepage`, and `bugs` fields in package.json

## [1.2.2] - 2024-12-19

### Fixed
- Add star count for `ui-ux-pro-max` skill (93k stars) in README skill table

## [1.2.1] - 2024-12-18

### Fixed
- Rename agent `Taitoon` → `Taifoon` (ใต้ฝุ่น) throughout all files
- Add MIT `LICENSE` file to repository

## [1.2.0] - 2024-12-17

### Added
- **OpenAI Codex support** — `AGENTS.md` for Codex, `CLAUDE.md` for Claude Code, or both
- **Language selection** — English directive prepended to all instruction files when chosen
- **`aw upgrade` command** — upgrade existing workspace to latest template version with backup
- **Agent skills** — auto-install from top open-source skill repos at init time:
  - `planning-and-task-breakdown` (addyosmani/agent-skills)
  - `code-review-and-quality` (addyosmani/agent-skills)
  - `security-and-hardening` (addyosmani/agent-skills)
  - `ponytail` + `ponytail-review` + `ponytail-audit` (DietrichGebert/ponytail)
  - `ui-ux-pro-max` (nextlevelbuilder/ui-ux-pro-max-skill)
- **`aw help` command** — full help page with commands, prompts, and skills

## [1.0.1] - 2024-12-10

### Changed
- README updated to npm-only usage (no GitHub clone required)
- Template uses `claude -p` spawn pattern for real OS subprocess visibility

## [1.0.0] - 2024-12-01

### Added
- Initial release of `sahagan-agents-workflow` npm package
- Bundle template inside npm package (no internet required at init)
- Four-cat agent family: Angpao (Orchestrator), Phayu (Dev Lead), Taifoon (QA Lead), Timsum (UX/UI)
- `aw init <project-name>` CLI command
- VS Code `.code-workspace` file generation
- Local git repo initialization

[1.2.3]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.0.1...v1.2.0
[1.0.1]: https://github.com/Sahagan/sahagan-agents-workflow/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Sahagan/sahagan-agents-workflow/releases/tag/v1.0.0
