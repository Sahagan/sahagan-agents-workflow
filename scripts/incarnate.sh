#!/usr/bin/env bash
# incarnate.sh
#
# Clone the base agent template into a new agent at a target path.
# Creates a fresh repo with placeholders ready for customization.
#
# Usage:
#   ./scripts/incarnate.sh <agent-name> [target-path]
#
# Examples:
#   ./scripts/incarnate.sh oracle-coding                    # -> ../agent-oracle-coding/
#   ./scripts/incarnate.sh qa ~/agents/agent-qa             # -> ~/agents/agent-qa/
#   ./scripts/incarnate.sh research ./agents/agent-research # -> ./agents/agent-research/

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# --- Parse arguments ---

if [ $# -lt 1 ]; then
  echo -e "${RED}Usage:${NC} ./scripts/incarnate.sh <agent-name> [target-path]"
  echo ""
  echo "  agent-name    Name for the new agent (e.g., oracle-coding, qa, research)"
  echo "  target-path   Where to create the agent (default: ../agent-<name>/)"
  echo ""
  echo "Examples:"
  echo "  ./scripts/incarnate.sh oracle-coding"
  echo "  ./scripts/incarnate.sh qa ~/agents/agent-qa"
  exit 1
fi

AGENT_NAME="$1"
AGENT_ID="agent-${AGENT_NAME}"

if [ $# -ge 2 ]; then
  TARGET_DIR="$2"
else
  TARGET_DIR="$(dirname "$TEMPLATE_DIR")/${AGENT_ID}"
fi

# --- Preflight checks ---

if [ -d "$TARGET_DIR" ]; then
  echo -e "${RED}Error:${NC} Target directory already exists: $TARGET_DIR"
  echo "  Remove it first or choose a different path."
  exit 1
fi

echo ""
echo -e "${CYAN}Incarnating new agent${NC}"
echo "  Name:     ${AGENT_NAME}"
echo "  Agent ID: ${AGENT_ID}"
echo "  From:     ${TEMPLATE_DIR}"
echo "  To:       ${TARGET_DIR}"
echo ""

# --- Step 1: Copy template ---

echo -e "${GREEN}[1/6]${NC} Copying template..."
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"

# Remove the template's own git history
rm -rf "$TARGET_DIR/.git"

# --- Step 2: Initialize new repo ---

echo -e "${GREEN}[2/6]${NC} Initializing git repo..."
cd "$TARGET_DIR"
git init -q
git checkout -q -b main

# --- Step 3: Set up CLAUDE.md as symlink ---

echo -e "${GREEN}[3/6]${NC} Setting up backend symlinks..."

# In the cloned agent, CLAUDE.md should symlink to AGENTS.md (not be standalone)
rm -f CLAUDE.md
ln -s AGENTS.md CLAUDE.md

# Verify all symlinks
for backend in CLAUDE.md GEMINI.md CODEX.md KIMI.md; do
  if [ -L "$backend" ]; then
    target=$(readlink "$backend")
    if [ "$target" = "AGENTS.md" ]; then
      echo -e "  ${GREEN}OK${NC}  $backend -> AGENTS.md"
    else
      echo -e "  ${RED}ERR${NC} $backend -> $target (expected AGENTS.md)"
    fi
  else
    echo -e "  ${YELLOW}WARN${NC} $backend is not a symlink, recreating..."
    rm -f "$backend"
    ln -s AGENTS.md "$backend"
  fi
done

# --- Step 4: Create config manifest ---

echo -e "${GREEN}[4/6]${NC} Creating config.manifest.json..."
cat > config.manifest.json << EOF
{
  "agentId": "${AGENT_ID}",
  "requiredConfig": {
    "primaryModel": { "type": "model-id", "description": "LLM model identifier", "required": true },
    "fallbackModel": { "type": "model-id", "description": "Fallback model", "required": false },
    "deepMemoryCmd": { "type": "command", "description": "Tier 2 memory CLI command", "required": false },
    "memoryPath": { "type": "path", "description": "File-based memory directory", "required": true },
    "sessionsPath": { "type": "path", "description": "Session data directory", "required": false }
  }
}
EOF

# --- Step 5: Validate neutrality ---

echo -e "${GREEN}[5/6]${NC} Validating neutrality..."
echo ""
if bash scripts/check-agent-neutrality.sh 2>&1 | tail -3; then
  echo ""
else
  echo ""
  echo -e "${YELLOW}Note:${NC} Warnings are expected. Fix any violations before committing."
fi

# --- Step 6: Summary ---

echo -e "${GREEN}[6/6]${NC} Done!"
echo ""
echo -e "${CYAN}New agent created at:${NC} $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Edit AGENTS.md -- replace {{placeholders}} with agent-specific values"
echo "  3. Edit persona/README.md -- set agent identity and role"
echo "  4. Add project repos: git submodule add <url> projects/{name}"
echo "  5. Run: bash scripts/check-agent-neutrality.sh"
echo "  6. git add -A && git commit -m 'Init: ${AGENT_ID} from base template'"
echo ""
