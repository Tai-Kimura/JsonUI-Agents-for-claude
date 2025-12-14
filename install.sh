#!/bin/bash

# JsonUI Agents Installer for Claude Code
# This script installs JsonUI agents to Claude Code's agents directory

set -e

REPO_URL="https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main"
AGENTS_DIR="$HOME/.claude/agents"

# Agent files to download
AGENT_FILES=(
    "jsonui-setup.md"
    "jsonui-generator.md"
    "jsonui-layout.md"
    "jsonui-refactor.md"
    "jsonui-data.md"
    "jsonui-viewmodel.md"
    "swiftjsonui-swiftui.md"
    "swiftjsonui-uikit.md"
    "kotlinjsonui-compose.md"
    "kotlinjsonui-xml.md"
    "reactjsonui.md"
)

echo "Installing JsonUI Agents for Claude Code..."

# Create agents directory if it doesn't exist
if [ ! -d "$AGENTS_DIR" ]; then
    echo "Creating agents directory: $AGENTS_DIR"
    mkdir -p "$AGENTS_DIR"
fi

# Download agent files
echo "Downloading agent files..."
for file in "${AGENT_FILES[@]}"; do
    echo "  - $file"
    curl -sL "$REPO_URL/$file" -o "$AGENTS_DIR/$file"
done

echo ""
echo "✓ Installation complete!"
echo ""
echo "Installed agents:"
for file in "${AGENT_FILES[@]}"; do
    echo "  - ${file%.md}"
done
echo ""
echo "You can now use JsonUI agents in Claude Code."
echo "Example: \"Use the jsonui-layout agent to create a login screen\""
