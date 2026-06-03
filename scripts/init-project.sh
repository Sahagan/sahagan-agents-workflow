#!/usr/bin/env bash
# init-project.sh
# Init a new project workspace from the Sahagan Agent Template
#
# Usage:
#   bash scripts/init-project.sh my-project
#   bash scripts/init-project.sh my-project https://github.com/user/repo.git
#   bash scripts/init-project.sh my-project https://github.com/user/repo.git ~/projects

set -euo pipefail

# ─── Args ─────────────────────────────────────────────────────────────────────

PROJECT_NAME="${1:-}"
REPO_URL="${2:-}"
OUTPUT_DIR="${3:-}"
TEMPLATE_REPO="https://github.com/Sahagan/sahagan_agent_template.git"

if [[ -z "$PROJECT_NAME" ]]; then
    echo ""
    echo "  Usage: bash scripts/init-project.sh <project-name> [repo-url] [output-dir]"
    echo ""
    echo "  Examples:"
    echo "    bash scripts/init-project.sh my-project"
    echo "    bash scripts/init-project.sh my-project https://github.com/user/repo.git"
    echo "    bash scripts/init-project.sh my-project https://github.com/user/repo.git ~/projects"
    echo ""
    exit 1
fi

# Resolve output directory
if [[ -z "$OUTPUT_DIR" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    OUTPUT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
fi

PROJECT_DIR="$OUTPUT_DIR/$PROJECT_NAME"

# ─── Banner ───────────────────────────────────────────────────────────────────

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   ARIA Agent Template — Project Init     ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
echo "  Project  : $PROJECT_NAME"
echo "  Location : $PROJECT_DIR"
[[ -n "$REPO_URL" ]] && echo "  Repo     : $REPO_URL"
echo ""

# ─── Preflight ────────────────────────────────────────────────────────────────

if [[ -d "$PROJECT_DIR" ]]; then
    echo "  [ERROR] Directory already exists: $PROJECT_DIR"
    echo "  Delete it first or choose a different name."
    exit 1
fi

if ! command -v git &>/dev/null; then
    echo "  [ERROR] git not found. Install git and retry."
    exit 1
fi

# ─── Step 1: Clone agent template ─────────────────────────────────────────────

echo "  [1/4] Cloning agent template..."
git clone --quiet "$TEMPLATE_REPO" "$PROJECT_DIR"

# Remove .git so project starts fresh
rm -rf "$PROJECT_DIR/.git"
echo "  [1/4] Template ready (git history removed) ✓"

# ─── Step 2: Initialize project git ───────────────────────────────────────────

echo "  [2/4] Initializing project git..."
cd "$PROJECT_DIR"
git init -q
git add -A
git commit -q -m "Init: $PROJECT_NAME from sahagan_agent_template"
echo "  [2/4] Git initialized (clean slate) ✓"

# ─── Step 3: Clone project repo ───────────────────────────────────────────────

PROJECTS_DIR="$PROJECT_DIR/projects"
mkdir -p "$PROJECTS_DIR"

if [[ -n "$REPO_URL" ]]; then
    echo "  [3/4] Cloning project repo..."
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_PATH="$PROJECTS_DIR/$REPO_NAME"

    if git clone --quiet "$REPO_URL" "$REPO_PATH"; then
        echo "  [3/4] Project repo cloned to projects/$REPO_NAME ✓"
    else
        echo "  [WARN] Failed to clone $REPO_URL — continuing without it"
    fi
else
    echo "  [3/4] No repo URL provided — empty projects/ folder created"
    cat > "$PROJECTS_DIR/README.md" << 'PROJEOF'
# Projects

Add your project repos here.

```bash
# Clone a repo manually
cd projects/
git clone <your-repo-url>
```
PROJEOF
fi

# ─── Step 4: Patch CLAUDE.md with project name ────────────────────────────────

echo "  [4/4] Configuring workspace..."

# Inject project name at top of CLAUDE.md
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]]; then
    ORIGINAL=$(cat "$CLAUDE_MD")
    printf "<!-- Project: %s -->\n%s" "$PROJECT_NAME" "$ORIGINAL" > "$CLAUDE_MD"
fi

# Write project info file
TODAY=$(date +%Y-%m-%d)
cat > "$PROJECT_DIR/PROJECT.md" << PROJEOF
# Project: $PROJECT_NAME

**Initialized:** $TODAY
**Template:** sahagan_agent_template

## Project Repo
$(if [[ -n "$REPO_URL" ]]; then echo "- $REPO_URL"; else echo "- (not set — add to projects/)"; fi)

## Quick Start

\`\`\`
Open this folder in VS Code → Claude Code → /session-start
\`\`\`

## Structure

\`\`\`
$PROJECT_NAME/
├── CLAUDE.md               ← ARIA entry point
├── .claude/
│   ├── agents/             ← Kai (BE), Nova (FE), Sage (QA) definitions
│   └── skills/             ← /session-start, /assign, /new-session, UI/UX Pro Max
├── agents/                 ← Persona + memories per agent
├── _shared/                ← Session state, task log, decisions
└── projects/               ← Project code lives here
    └── $PROJECT_NAME/
\`\`\`
PROJEOF

echo "  [4/4] Workspace configured ✓"

# ─── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Project ready!                  ✓      ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
echo "  Location : $PROJECT_DIR"
echo ""
echo "  Next steps:"
echo "  1. code \"$PROJECT_DIR\""
echo "  2. Start Claude Code in that folder"
echo "  3. Type: /session-start"
echo "  4. ARIA will load up and you're ready to work"
echo ""

# Auto-open VS Code if available
if command -v code &>/dev/null; then
    echo "  Opening VS Code..."
    code "$PROJECT_DIR"
fi
