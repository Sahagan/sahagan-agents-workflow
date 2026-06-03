#!/usr/bin/env bash
# check-agent-neutrality.sh
#
# Validates that agent profiles maintain backend neutrality.
# Checks base template for hardcoded model IDs, tool names, and backend-specific
# instructions. Checks specialized agents for symlink correctness.
#
# Usage:
#   ./scripts/check-agent-neutrality.sh                    # validate all
#   ./scripts/check-agent-neutrality.sh agents/agent-foo   # validate one agent
#
# Exit codes:
#   0 = all checks passed
#   1 = violations found

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/agents"
BASE_DIR="$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

violations=0
warnings=0

log_violation() {
  echo -e "${RED}FAIL${NC}  $1"
  violations=$((violations + 1))
}

log_warning() {
  echo -e "${YELLOW}WARN${NC}  $1"
  warnings=$((warnings + 1))
}

log_pass() {
  echo -e "${GREEN}PASS${NC}  $1"
}

# --- Hardcoded model IDs ---
# These should never appear in base template files (only in agent-specific configs)
HARDCODED_MODELS=(
  "claude-opus"
  "claude-sonnet"
  "claude-haiku"
  "claude-3"
  "claude-4"
  "gemini-2"
  "gemini-1"
  "gemini-pro"
  "gemini-flash"
  "gemini-ultra"
  "gpt-4"
  "gpt-3"
  "o1-"
  "o3-"
  "o4-"
  "codex-"
  "kimi-k2"
)

# --- Hardcoded tool/CLI names ---
# These should use {{placeholder}} in base template files
HARDCODED_TOOLS=(
  "mempalace"
  "chromadb"
  "pinecone"
  "pgvector"
  "weaviate"
)

# --- Backend-specific language ---
# References to specific backends as if they are THE backend
BACKEND_SPECIFIC_PHRASES=(
  "Claude will"
  "Claude can"
  "Claude does"
  "Gemini will"
  "Gemini can"
  "Gemini does"
  "GPT will"
  "GPT can"
  "Codex will"
  "Codex can"
  "Kimi will"
  "Kimi can"
)

check_base_neutrality() {
  echo ""
  echo "=== Checking base template for neutrality violations ==="
  echo ""

  if [ ! -d "$BASE_DIR" ]; then
    log_violation "Base template directory not found at $BASE_DIR"
    return
  fi

  # Check for hardcoded model IDs
  local model_violations=0
  for model in "${HARDCODED_MODELS[@]}"; do
    matches=$(grep -rli "$model" "$BASE_DIR" --include="*.md" 2>/dev/null || true)
    if [ -n "$matches" ]; then
      for file in $matches; do
        rel_path="${file#$REPO_ROOT/}"
        # Skip scripts, neutrality doc, and .claude/ config files
        if [[ "$rel_path" == *"check-agent-neutrality"* ]] || [[ "$rel_path" == *"neutrality.md"* ]] || [[ "$rel_path" == *".claude/"* ]]; then
          continue
        fi
        # Check each matching line -- allow in tables (|), backtick examples, or doc context
        while IFS= read -r line; do
          if echo "$line" | grep -qE '\|.*\||`.*'"$model"'.*`|example|e\.g\.|such as|supported|Backend'; then
            log_warning "$rel_path references '$model' (in documentation context -- verify it's descriptive, not prescriptive)"
          else
            log_violation "$rel_path contains hardcoded model ID '$model': $line"
            model_violations=$((model_violations + 1))
          fi
        done < <(grep "$model" "$file" 2>/dev/null)
      done
    fi
  done
  [ $model_violations -eq 0 ] && log_pass "No hardcoded model IDs in base template (outside documentation)"

  # Check for hardcoded tool names
  local tool_violations=0
  for tool in "${HARDCODED_TOOLS[@]}"; do
    matches=$(grep -rli "$tool" "$BASE_DIR" --include="*.md" 2>/dev/null || true)
    if [ -n "$matches" ]; then
      for file in $matches; do
        rel_path="${file#$REPO_ROOT/}"
        if [[ "$rel_path" == *"check-agent-neutrality"* ]] || [[ "$rel_path" == *"neutrality.md"* ]] || [[ "$rel_path" == *".claude/"* ]]; then
          continue
        fi
        while IFS= read -r line; do
          if echo "$line" | grep -qEi '\|.*\||`.*'"$tool"'.*`|example|e\.g\.|such as|like|^>|^-\s'; then
            log_warning "$rel_path mentions '$tool' (in documentation context -- verify it uses placeholder for actual config)"
          else
            log_violation "$rel_path contains hardcoded tool name '$tool'"
            tool_violations=$((tool_violations + 1))
          fi
        done < <(grep "$tool" "$file" 2>/dev/null)
      done
    fi
  done
  [ $tool_violations -eq 0 ] && log_pass "No hardcoded tool names in base template (outside documentation)"

  # Check for backend-specific language
  local lang_violations=0
  for phrase in "${BACKEND_SPECIFIC_PHRASES[@]}"; do
    matches=$(grep -rli "$phrase" "$BASE_DIR" --include="*.md" 2>/dev/null || true)
    if [ -n "$matches" ]; then
      for file in $matches; do
        rel_path="${file#$REPO_ROOT/}"
        if [[ "$rel_path" == *"check-agent-neutrality"* ]] || [[ "$rel_path" == *"neutrality.md"* ]] || [[ "$rel_path" == *"trust-model.md"* ]] || [[ "$rel_path" == *".claude/"* ]]; then
          continue
        fi
        # Check if the phrase appears in a documentation/example context (checklist, quoted, table)
        local is_doc_context=false
        while IFS= read -r line; do
          if echo "$line" | grep -qE '^\s*-\s*\[|".*'"$phrase"'.*"|`.*'"$phrase"'.*`|\|.*\|'; then
            is_doc_context=true
          fi
        done < <(grep "$phrase" "$file" 2>/dev/null)
        if [ "$is_doc_context" = true ]; then
          log_warning "$rel_path mentions '$phrase' (in documentation context)"
        else
          log_violation "$rel_path contains backend-specific phrase '$phrase'"
          lang_violations=$((lang_violations + 1))
        fi
      done
    fi
  done
  [ $lang_violations -eq 0 ] && log_pass "No backend-specific language in base template"

  # Check that AGENTS.md exists and is the canonical source
  if [ ! -f "$BASE_DIR/AGENTS.md" ]; then
    log_violation "AGENTS.md not found -- this is the canonical instruction file"
  else
    log_pass "AGENTS.md exists"
  fi

  # Check CLAUDE.md -- can be a symlink to AGENTS.md or a standalone guidance file
  if [ -L "$BASE_DIR/CLAUDE.md" ]; then
    target=$(readlink "$BASE_DIR/CLAUDE.md")
    if [ "$target" = "AGENTS.md" ]; then
      log_pass "CLAUDE.md -> AGENTS.md (correct symlink)"
    else
      log_violation "CLAUDE.md points to '$target' instead of AGENTS.md"
    fi
  elif [ -f "$BASE_DIR/CLAUDE.md" ]; then
    log_pass "CLAUDE.md exists (standalone guidance file)"
  fi

  check_placeholder_presence "$BASE_DIR"
}

check_placeholder_presence() {
  local dir="$1"
  local dir_name
  dir_name=$(basename "$dir")
  local agents_file="$dir/AGENTS.md"

  if [ ! -f "$agents_file" ]; then
    return
  fi

  local rel_path="${agents_file#$REPO_ROOT/}"

  # Required placeholders -- log_violation if missing
  if grep -qF '{{memoryPath}}' "$agents_file" 2>/dev/null; then
    log_pass "$rel_path contains {{memoryPath}}"
  else
    log_violation "$rel_path missing required placeholder {{memoryPath}} (memory system needs this)"
  fi

  local agent_identity_found=false
  for placeholder in '{{agentId}}' '{{agentName}}' '{{name}}'; do
    if grep -qF "$placeholder" "$agents_file" 2>/dev/null; then
      agent_identity_found=true
      break
    fi
  done
  if [ "$agent_identity_found" = true ]; then
    log_pass "$rel_path contains agent identity placeholder ({{agentId}}, {{agentName}}, or {{name}})"
  else
    log_violation "$rel_path missing required agent identity placeholder ({{agentId}}, {{agentName}}, or {{name}})"
  fi

  # Recommended placeholders -- log_warning if missing
  if grep -qF '{{deepMemoryCmd}}' "$agents_file" 2>/dev/null; then
    log_pass "$rel_path contains {{deepMemoryCmd}}"
  else
    log_warning "$rel_path missing recommended placeholder {{deepMemoryCmd}} (Tier 2 memory)"
  fi

  if grep -qF '{{sessionsPath}}' "$agents_file" 2>/dev/null; then
    log_pass "$rel_path contains {{sessionsPath}}"
  else
    log_warning "$rel_path missing recommended placeholder {{sessionsPath}} (session mining)"
  fi

  if grep -qF '{{taskId}}' "$agents_file" 2>/dev/null; then
    log_pass "$rel_path contains {{taskId}}"
  else
    log_warning "$rel_path missing recommended placeholder {{taskId}} (task tracking)"
  fi

  # Config manifest -- log_warning if missing
  if [ -f "$dir/config.manifest.json" ]; then
    log_pass "$dir_name/config.manifest.json exists (cloning readiness)"
  else
    log_warning "$dir_name/config.manifest.json missing (recommended for cloning readiness)"
  fi
}

check_agent_neutrality() {
  local agent_dir="$1"
  local agent_name
  agent_name=$(basename "$agent_dir")

  echo ""
  echo "=== Checking $agent_name ==="
  echo ""

  if [ ! -d "$agent_dir" ]; then
    log_violation "$agent_name directory not found"
    return
  fi

  # Check AGENTS.md exists
  if [ ! -f "$agent_dir/AGENTS.md" ]; then
    log_violation "$agent_name/AGENTS.md not found"
  else
    log_pass "$agent_name/AGENTS.md exists"
  fi

  # Check CLAUDE.md symlink
  if [ -L "$agent_dir/CLAUDE.md" ]; then
    target=$(readlink "$agent_dir/CLAUDE.md")
    if [ "$target" = "AGENTS.md" ]; then
      log_pass "$agent_name/CLAUDE.md -> AGENTS.md (correct symlink)"
    else
      log_violation "$agent_name/CLAUDE.md points to '$target' instead of AGENTS.md"
    fi
  elif [ -f "$agent_dir/CLAUDE.md" ]; then
    log_violation "$agent_name/CLAUDE.md is a regular file, not a symlink to AGENTS.md"
  else
    log_warning "$agent_name/CLAUDE.md missing (create symlink: ln -s AGENTS.md CLAUDE.md)"
  fi

  # Check for other backend symlinks (optional, just report)
  for backend in GEMINI.md CODEX.md KIMI.md; do
    if [ -L "$agent_dir/$backend" ]; then
      target=$(readlink "$agent_dir/$backend")
      if [ "$target" = "AGENTS.md" ]; then
        log_pass "$agent_name/$backend -> AGENTS.md"
      else
        log_violation "$agent_name/$backend points to '$target' instead of AGENTS.md"
      fi
    fi
  done

  # Check that AGENTS.md references the base profile
  if [ -f "$agent_dir/AGENTS.md" ]; then
    if grep -qi "extends.*_base\|inherit.*base" "$agent_dir/AGENTS.md" 2>/dev/null; then
      log_pass "$agent_name/AGENTS.md references base profile"
    else
      log_warning "$agent_name/AGENTS.md does not explicitly reference base template (recommended: add 'Extends: base template AGENTS.md')"
    fi
  fi

  # Check directory structure matches base
  for subdir in persona memories skills mindsets projects; do
    if [ -d "$agent_dir/$subdir" ]; then
      log_pass "$agent_name/$subdir/ exists"
    else
      log_warning "$agent_name/$subdir/ missing (optional but recommended)"
    fi
  done

  check_placeholder_presence "$agent_dir"
}

# --- Obsidian Format Validation ---
# Documentation files must have YAML frontmatter.
# AGENTS.md files must NOT have Obsidian-specific syntax.

APPROVED_CALLOUTS="abstract|tip|warning|example|note|danger"

check_format_doc_file() {
  local file="$1"
  local rel_path="${file#$REPO_ROOT/}"
  local basename
  basename=$(basename "$file")

  # Skip instruction/guidance files and root README (GitHub-style, no frontmatter)
  if [ "$basename" = "AGENTS.md" ] || [ "$basename" = "CLAUDE.md" ]; then
    return
  fi
  if [ "$basename" = "README.md" ] && [ "$(dirname "$file")" = "$REPO_ROOT" ]; then
    return
  fi

  # Skip symlinks (GEMINI.md, CODEX.md, KIMI.md, etc.)
  if [ -L "$file" ]; then
    return
  fi

  # Check for YAML frontmatter (first line should be ---)
  local first_line
  first_line=$(head -1 "$file" 2>/dev/null)
  if [ "$first_line" != "---" ]; then
    log_violation "$rel_path missing YAML frontmatter (documentation files require it)"
    return
  fi

  # Check for required frontmatter fields (extract between first and second ---)
  local frontmatter
  frontmatter=$(awk 'NR==1 && /^---$/{found=1; next} found && /^---$/{exit} found{print}' "$file" 2>/dev/null)

  if ! echo "$frontmatter" | grep -q "^title:"; then
    log_warning "$rel_path frontmatter missing 'title' field"
  fi
  if ! echo "$frontmatter" | grep -q "^tags:"; then
    log_warning "$rel_path frontmatter missing 'tags' field"
  fi

  # Check for unapproved callout types (skip lines with backtick-quoted examples)
  local bad_callouts
  bad_callouts=$(grep -nE '> \[!' "$file" 2>/dev/null | grep -vE "\[!(${APPROVED_CALLOUTS})\]" | grep -v '`' || true)
  if [ -n "$bad_callouts" ]; then
    while IFS= read -r callout_line; do
      log_warning "$rel_path uses non-standard callout: $callout_line (approved: $APPROVED_CALLOUTS)"
    done <<< "$bad_callouts"
  fi
}

check_format_instruction_file() {
  local file="$1"
  local rel_path="${file#$REPO_ROOT/}"

  if [ ! -f "$file" ]; then
    return
  fi

  # AGENTS.md should NOT have YAML frontmatter
  local first_line
  first_line=$(head -1 "$file" 2>/dev/null)
  if [ "$first_line" = "---" ]; then
    log_violation "$rel_path has YAML frontmatter (instruction files must use plain Markdown)"
  fi

  # AGENTS.md should NOT have wikilinks
  if grep -qE '\[\[.*\]\]' "$file" 2>/dev/null; then
    log_violation "$rel_path contains wikilinks (instruction files must use plain Markdown)"
  fi

  # AGENTS.md should NOT have Obsidian callouts
  if grep -qE '> \[!' "$file" 2>/dev/null; then
    log_violation "$rel_path contains Obsidian callouts (instruction files must use plain Markdown)"
  fi
}

check_format() {
  local dir="$1"
  local dir_name
  dir_name=$(basename "$dir")

  echo ""
  echo "=== Format validation: $dir_name ==="
  echo ""

  # Check all .md documentation files
  local doc_count=0
  while IFS= read -r -d '' mdfile; do
    check_format_doc_file "$mdfile"
    doc_count=$((doc_count + 1))
  done < <(find "$dir" -name "*.md" -not -name "AGENTS.md" -not -name "CLAUDE.md" -not -type l -not -path "*/.claude/*" -print0 2>/dev/null)

  # Check AGENTS.md instruction file
  if [ -f "$dir/AGENTS.md" ]; then
    check_format_instruction_file "$dir/AGENTS.md"
  fi

  log_pass "$dir_name: $doc_count documentation file(s) checked"
}

# --- Main ---

echo ""
echo "Agent Neutrality & Format Check"
echo "================================"

if [ $# -gt 0 ]; then
  # Check specific agent
  target="$1"
  if [[ "$target" != /* ]]; then
    target="$REPO_ROOT/$target"
  fi
  check_agent_neutrality "$target"
  check_format "$target"
else
  # Check base template first
  check_base_neutrality

  # Check all agents
  for agent_dir in "$AGENTS_DIR"/agent-*/; do
    if [ -d "$agent_dir" ]; then
      check_agent_neutrality "$agent_dir"
    fi
  done

  # Format validation for base template and all agents
  check_format "$BASE_DIR"
  for agent_dir in "$AGENTS_DIR"/agent-*/; do
    if [ -d "$agent_dir" ]; then
      check_format "$agent_dir"
    fi
  done
fi

# --- Summary ---

echo ""
echo "======================"
if [ $violations -gt 0 ]; then
  echo -e "${RED}$violations violation(s)${NC}, ${YELLOW}$warnings warning(s)${NC}"
  echo "Fix violations before merging."
  exit 1
else
  echo -e "${GREEN}0 violations${NC}, ${YELLOW}$warnings warning(s)${NC}"
  echo "Neutrality checks passed."
  exit 0
fi
