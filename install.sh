#!/bin/bash

# JsonUI Agents Installer for Claude Code
# This script installs JsonUI agents to Claude Code's agents directory
#
# Usage:
#   ./install.sh                    # Install from main branch
#   ./install.sh -b develop         # Install from specific branch
#   ./install.sh -c abc123          # Install from specific commit
#   ./install.sh -v 1.0.0           # Install from specific version tag

set -e

# Default values
REF="main"
REF_TYPE="branch"

# Parse arguments
while getopts "b:c:v:h" opt; do
    case $opt in
        b)
            REF="$OPTARG"
            REF_TYPE="branch"
            ;;
        c)
            REF="$OPTARG"
            REF_TYPE="commit"
            ;;
        v)
            REF="$OPTARG"
            REF_TYPE="tag"
            ;;
        h)
            echo "Usage: $0 [-b branch] [-c commit] [-v version]"
            echo ""
            echo "Options:"
            echo "  -b BRANCH   Install from specific branch (default: main)"
            echo "  -c COMMIT   Install from specific commit hash"
            echo "  -v VERSION  Install from specific version tag"
            echo "  -h          Show this help message"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

REPO_URL="https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/$REF"
AGENTS_DIR=".claude/agents"

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
echo "  Source: $REF_TYPE '$REF'"

# Create agents directory if it doesn't exist
if [ ! -d "$AGENTS_DIR" ]; then
    echo "Creating agents directory: $AGENTS_DIR"
    mkdir -p "$AGENTS_DIR"
fi

# Download agent files
echo "Downloading agent files..."
for file in "${AGENT_FILES[@]}"; do
    echo "  - $file"
    if ! curl -sLf "$REPO_URL/$file" -o "$AGENTS_DIR/$file"; then
        echo "Error: Failed to download $file" >&2
        echo "Please check if the $REF_TYPE '$REF' exists." >&2
        exit 1
    fi
done

echo ""
echo "Installation complete!"
echo ""
echo "Installed agents:"
for file in "${AGENT_FILES[@]}"; do
    echo "  - ${file%.md}"
done
echo ""
echo "You can now use JsonUI agents in Claude Code."
echo "Example: \"Use the jsonui-layout agent to create a login screen\""
