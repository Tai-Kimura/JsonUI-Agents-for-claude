#!/bin/bash

# JsonUI Agents Installer for Claude Code
# This script installs JsonUI agents to Claude Code's agents directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.claude/agents"

echo "Installing JsonUI Agents for Claude Code..."

# Create agents directory if it doesn't exist
if [ ! -d "$AGENTS_DIR" ]; then
    echo "Creating agents directory: $AGENTS_DIR"
    mkdir -p "$AGENTS_DIR"
fi

# Copy all agent markdown files
echo "Copying agent files..."
cp "$SCRIPT_DIR"/*.md "$AGENTS_DIR/" 2>/dev/null || true

# Remove README.md from agents directory (it's not an agent)
rm -f "$AGENTS_DIR/README.md"

echo ""
echo "✓ Installation complete!"
echo ""
echo "Installed agents:"
ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | xargs -I {} basename {} .md | sed 's/^/  - /'
echo ""
echo "You can now use JsonUI agents in Claude Code."
echo "Example: \"Use the jsonui-layout agent to create a login screen\""
