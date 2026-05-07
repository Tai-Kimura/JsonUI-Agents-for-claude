#!/bin/bash
#
# JsonUI All-in-One Bootstrap
#
# Installs the three pieces you need to use JsonUI agents end-to-end:
#
#   1. jsonui-cli        -> $HOME/.jsonui-cli/           (sjui / kjui / rjui / jui / jsonui-test / jsonui-doc)
#   2. jsonui-mcp-server -> $HOME/.jsonui-mcp-server/    (29 MCP tools, registered in ~/.claude.json)
#   3. Agents + skills   -> ./.claude/                   (project-local: agents / skills / rules / SessionStart hook / /jsonui command — your CLAUDE.md is NOT touched)
#
# The CLI location matches jsonui-mcp-server's 3rd fallback layer, so the MCP
# auto-picks up the fresh attribute_definitions.json / component_metadata.json
# without any env vars. Re-run this script to update everything.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/installer/bootstrap.sh | bash
#
# Partial install (skip some steps):
#   curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/installer/bootstrap.sh | \
#     JSONUI_BOOTSTRAP_STEPS="cli,agents" bash
#
# Options (env vars):
#   JSONUI_BOOTSTRAP_REF        Branch/tag/commit for the agents repo (default: main).
#   JSONUI_BOOTSTRAP_STEPS      Comma-separated list of steps to run: cli, mcp, agents (default: all).
#   JSONUI_CLI_DIR              Override CLI install dir (default: $HOME/.jsonui-cli).
#   JSONUI_MCP_DIR              Override MCP install dir (default: $HOME/.jsonui-mcp-server).
#

set -e

# --- Config -----------------------------------------------------------------

AGENTS_RAW_BASE="https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude"
CLI_RAW_BASE="https://raw.githubusercontent.com/Tai-Kimura/jsonui-cli"
MCP_RAW_BASE="https://raw.githubusercontent.com/Tai-Kimura/jsonui-mcp-server"

AGENTS_REF="${JSONUI_BOOTSTRAP_REF:-main}"
STEPS="${JSONUI_BOOTSTRAP_STEPS:-cli,mcp,agents}"

export JSONUI_CLI_DIR="${JSONUI_CLI_DIR:-$HOME/.jsonui-cli}"
export JSONUI_MCP_DIR="${JSONUI_MCP_DIR:-$HOME/.jsonui-mcp-server}"

# --- Output helpers --------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}==>${NC} $*"; }
success() { echo -e "${GREEN}✓${NC}  $*"; }
warning() { echo -e "${YELLOW}!${NC}  $*"; }
error()   { echo -e "${RED}✗${NC}  $*" >&2; exit 1; }
banner() {
  echo ""
  echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${BLUE}║  $1${NC}"
  echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${NC}"
  echo ""
}

step_enabled() {
  echo ",$STEPS," | grep -q ",$1,"
}

# --- Prerequisites ---------------------------------------------------------

banner "JsonUI All-in-One Bootstrap                "

info "Checking prerequisites..."

command -v git  >/dev/null 2>&1 || error "git is required."
success "git"

command -v curl >/dev/null 2>&1 || error "curl is required."
success "curl"

if command -v node >/dev/null 2>&1; then
  success "node $(node --version)"
else
  error "node is required (the MCP server is a Node.js app)."
fi

if command -v npm >/dev/null 2>&1; then
  success "npm $(npm --version)"
else
  error "npm is required."
fi

if command -v ruby >/dev/null 2>&1; then
  success "ruby $(ruby -v | awk '{print $2}')"
else
  warning "ruby not found — sjui / kjui / rjui tools will not run."
fi

if command -v python3 >/dev/null 2>&1; then
  success "python3 $(python3 --version | awk '{print $2}')"
else
  warning "python3 not found — jui / jsonui-test / jsonui-doc tools will not run."
fi

echo ""
info "Steps to run: ${BOLD}$STEPS${NC}"
info "CLI dir:      ${BOLD}$JSONUI_CLI_DIR${NC}"
info "MCP dir:      ${BOLD}$JSONUI_MCP_DIR${NC}"
info "Agents ref:   ${BOLD}$AGENTS_REF${NC}"

# --- Step 1: jsonui-cli ----------------------------------------------------

if step_enabled cli; then
  banner "Step 1/3 — jsonui-cli → $JSONUI_CLI_DIR  "
  curl -fsSL "$CLI_RAW_BASE/main/installer/bootstrap.sh" | \
    JSONUI_CLI_DIR="$JSONUI_CLI_DIR" bash || error "jsonui-cli install failed."
else
  warning "Skipping step 1 (cli)."
fi

# --- Step 2: jsonui-mcp-server --------------------------------------------

if step_enabled mcp; then
  banner "Step 2/3 — jsonui-mcp-server → $JSONUI_MCP_DIR"
  curl -fsSL "$MCP_RAW_BASE/main/install.sh" | \
    JSONUI_MCP_DIR="$JSONUI_MCP_DIR" bash || error "jsonui-mcp-server install failed."
else
  warning "Skipping step 2 (mcp)."
fi

# --- Step 3: Agents + skills + rules --------------------------------------

if step_enabled agents; then
  banner "Step 3/3 — Agents + skills + rules → $(pwd)/.claude"
  curl -fsSL "$AGENTS_RAW_BASE/$AGENTS_REF/install.sh" | bash -s -- -b "$AGENTS_REF" || \
    error "Agents install failed."
else
  warning "Skipping step 3 (agents)."
fi

# --- Wrap up ---------------------------------------------------------------

banner "All done.                                  "

# Detect shell for PATH instructions.
SHELL_NAME=$(basename "${SHELL:-bash}")
case "$SHELL_NAME" in
  zsh)  SHELL_RC="$HOME/.zshrc" ;;
  bash) SHELL_RC="$HOME/.bashrc" ;;
  *)    SHELL_RC="$HOME/.profile" ;;
esac

echo "Next steps:"
echo ""
echo -e "  ${BOLD}1. Add the CLI tools to your PATH${NC} (once):"
echo ""
echo -e "     ${YELLOW}cat >> $SHELL_RC <<'EOF'"
echo -e "# JsonUI CLI Tools"
echo -e "export PATH=\"\$HOME/.jsonui-cli/jui_tools/bin:\$PATH\""
echo -e "export PATH=\"\$HOME/.jsonui-cli/document_tools:\$PATH\""
echo -e "export PATH=\"\$HOME/.jsonui-cli/test_tools:\$PATH\""
echo -e "export PATH=\"\$HOME/.jsonui-cli/sjui_tools/bin:\$PATH\""
echo -e "export PATH=\"\$HOME/.jsonui-cli/kjui_tools/bin:\$PATH\""
echo -e "export PATH=\"\$HOME/.jsonui-cli/rjui_tools/bin:\$PATH\""
echo -e "EOF${NC}"
echo ""
echo -e "     then: ${BLUE}source $SHELL_RC${NC}"
echo ""
echo -e "  ${BOLD}2. Restart Claude Code${NC} so it picks up the new MCP server"
echo -e "     (\`jui-tools\` was registered in ~/.claude.json)."
echo ""
echo -e "  ${BOLD}3. Start a new Claude Code session${NC} — the workflow menu appears"
echo -e "     automatically via the SessionStart hook. Or invoke ${BLUE}/jsonui${NC}"
echo -e "     manually at any time."
echo ""
echo -e "     Your CLAUDE.md is never touched — everything lives under ${BLUE}.claude/${NC}."
echo ""
