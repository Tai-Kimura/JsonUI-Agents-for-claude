#!/bin/bash

# JsonUI Agents Installer for Claude Code
# Installs agents, skills, rules, workflow hook, and the /jsonui slash command
# under .claude/ — your CLAUDE.md is never touched.
#
# The pack is fetched as a single tarball and its contents are enumerated
# from disk, so new files (agents, skills, examples, rules) ship without
# touching this script.
#
# Usage:
#   ./install.sh                    # Install from main branch
#   ./install.sh -b develop         # Install from specific branch
#   ./install.sh -c abc123          # Install from specific commit
#   ./install.sh -v 1.0.0           # Install from specific version tag
#
# Testing: set JSONUI_AGENTS_TARBALL_URL to any curl-able tarball URL
# (e.g. file:///tmp/pack.tar.gz built with `git archive --prefix=x/ HEAD`).

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

TARBALL_URL="${JSONUI_AGENTS_TARBALL_URL:-https://codeload.github.com/Tai-Kimura/JsonUI-Agents-for-claude/tar.gz/$REF}"
AGENTS_DIR=".claude/agents"
SKILLS_DIR=".claude/skills"
RULES_DIR=".claude/jsonui-rules"
COMMANDS_DIR=".claude/commands"
CLAUDE_DIR=".claude"

echo "Installing JsonUI Agents for Claude Code..."
echo "  Source: $REF_TYPE '$REF'"

# Fetch the pack once
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
echo ""
echo "Fetching the pack tarball..."
if ! curl -sLf "$TARBALL_URL" -o "$TMP_DIR/pack.tar.gz"; then
    echo "Error: Failed to download the pack ($TARBALL_URL)." >&2
    echo "Please check if the $REF_TYPE '$REF' exists." >&2
    exit 1
fi
mkdir "$TMP_DIR/src"
if ! tar -xzf "$TMP_DIR/pack.tar.gz" -C "$TMP_DIR/src" --strip-components=1; then
    echo "Error: Failed to extract the pack tarball." >&2
    exit 1
fi
SRC="$TMP_DIR/src"

# Sanity-check the pack layout before writing anything
for d in "$SRC/.claude/agents" "$SRC/skills" "$SRC/.claude/jsonui-rules" "$SRC/.claude/commands"; do
    if [ ! -d "$d" ]; then
        echo "Error: unexpected pack layout — missing ${d#"$SRC"/}" >&2
        exit 1
    fi
done
for f in "$SRC/.claude/jsonui-workflow.md" "$SRC/.claude/commands/jsonui.md"; do
    if [ ! -f "$f" ]; then
        echo "Error: unexpected pack layout — missing ${f#"$SRC"/}" >&2
        exit 1
    fi
done

# Create directories
for dir in "$AGENTS_DIR" "$SKILLS_DIR" "$RULES_DIR" "$COMMANDS_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

# Count items
agent_count=0
skill_count=0
example_count=0
rule_count=0

# Install agent files (enumerated from the pack)
echo ""
echo "Installing agents..."
for file in "$SRC"/.claude/agents/jsonui-*.md; do
    name=$(basename "$file")
    echo "  - $AGENTS_DIR/$name"
    cp "$file" "$AGENTS_DIR/$name"
    agent_count=$((agent_count + 1))
done

# Install skills (each skill directory ships wholesale — SKILL.md, examples/,
# and whatever the pack adds later)
echo ""
echo "Installing skills..."
for sdir in "$SRC"/skills/*/; do
    skill=$(basename "$sdir")
    echo "  - skills/$skill/"
    mkdir -p "$SKILLS_DIR/$skill"
    cp -R "${sdir}." "$SKILLS_DIR/$skill/"
    skill_count=$((skill_count + 1))
    if [ -d "${sdir}examples" ]; then
        n=$(find "${sdir}examples" -type f | wc -l | tr -d ' ')
        example_count=$((example_count + n))
    fi
done

# Install rule files (enumerated from the pack)
echo ""
echo "Installing rules..."
for file in "$SRC"/.claude/jsonui-rules/*.md; do
    name=$(basename "$file")
    echo "  - $RULES_DIR/$name"
    cp "$file" "$RULES_DIR/$name"
    rule_count=$((rule_count + 1))
done

# Install the workflow menu and slash command
echo ""
echo "Installing workflow menu and slash command..."
cp "$SRC/.claude/jsonui-workflow.md" "$CLAUDE_DIR/jsonui-workflow.md"
echo "  - $CLAUDE_DIR/jsonui-workflow.md"
cp "$SRC/.claude/commands/jsonui.md" "$COMMANDS_DIR/jsonui.md"
echo "  - $COMMANDS_DIR/jsonui.md"

# Merge SessionStart hook into .claude/settings.json (idempotent, preserves user's existing settings)
echo ""
echo "Merging SessionStart hook into $CLAUDE_DIR/settings.json..."
python3 - <<'PY'
import json, os
path = ".claude/settings.json"
if os.path.exists(path):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
else:
    data = {}

hook_cmd = "cat .claude/jsonui-workflow.md 2>/dev/null || true"
hooks = data.setdefault("hooks", {})
session_start = hooks.setdefault("SessionStart", [])

def has_our_hook(entries):
    for entry in entries:
        for inner in (entry.get("hooks") if isinstance(entry, dict) else None) or []:
            if isinstance(inner, dict) and inner.get("command") == hook_cmd:
                return True
    return False

if not has_our_hook(session_start):
    session_start.append({
        "hooks": [{"type": "command", "command": hook_cmd}],
    })
    print("  added SessionStart hook")
else:
    print("  SessionStart hook already present — skipped")

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

echo ""
echo "Installation complete!"
echo ""
echo "Installed:"
echo "  Agents: $agent_count"
echo "  Skills: $skill_count (with $example_count example files)"
echo "  Rules: $rule_count"
echo "  Workflow menu: 1 ($CLAUDE_DIR/jsonui-workflow.md)"
echo "  Slash command: 1 ($COMMANDS_DIR/jsonui.md)"
echo "  SessionStart hook: merged into $CLAUDE_DIR/settings.json"
echo ""
echo "========================================"
echo "          HOW TO GET STARTED"
echo "========================================"
echo ""
echo "Your CLAUDE.md is untouched. Everything lives under $CLAUDE_DIR/."
echo ""
echo "1. Restart your Claude Code session (required for the hook and new agents)."
echo "2. Start a new session — the workflow menu appears automatically."
echo "   If the hook doesn't fire, invoke the slash command: /jsonui"
echo ""
echo "You'll be asked to pick a workflow (1: new work, 2: modify, 3: investigate,"
echo "4: backend). The first three route to jsonui-conductor, which inspects the"
echo "repo via MCP and tells you which sub-agent to launch next."
echo ""
echo "========================================"
