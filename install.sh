#!/bin/bash

# JsonUI Agents Installer for Claude Code
# Installs agents, skills, rules, workflow hook, and the /jsonui slash command
# under .claude/ — your CLAUDE.md is never touched.
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
SKILLS_DIR=".claude/skills"
RULES_DIR=".claude/jsonui-rules"
COMMANDS_DIR=".claude/commands"
CLAUDE_DIR=".claude"

# Agent files (jsonui- prefixed to avoid collision with user agents)
AGENT_FILES="jsonui-conductor.md jsonui-debug.md jsonui-define.md jsonui-ground.md jsonui-implement.md jsonui-navigation-android.md jsonui-navigation-ios.md jsonui-navigation-web.md jsonui-test.md"

# Skill directories (11 skills; each contains SKILL.md and optionally examples/)
SKILL_DIRS="jsonui-component-spec jsonui-dataflow jsonui-flow-test jsonui-layout jsonui-localize jsonui-platform-setup jsonui-screen-spec jsonui-screen-test jsonui-swagger jsonui-test-doc jsonui-viewmodel-impl"

# Rule files (5 invariants / policy / philosophy / placement / spec authoring)
RULE_FILES="invariants.md mcp-policy.md design-philosophy.md file-locations.md specification-rules.md"

# Function to get examples for a skill (Bash 3.2 compatible - no associative arrays)
get_skill_examples() {
    case "$1" in
        jsonui-layout)
            echo "binding-correct.json binding-wrong.json collection-swiftui-basic.json collection-swiftui-full.json collection-uikit.json collection-wrong.json color-correct.json color-wrong.json id-naming-correct.json id-naming-wrong.json include-correct.json include-wrong.json screen-root-structure.json screen-root-wrong.json strings-json.json tabview.json tabview-wrong.json"
            ;;
        jsonui-screen-spec)
            echo "component.json data-flow.json layout.json state-management.json transitions.json user-actions.json validation.json"
            ;;
        jsonui-swagger)
            echo "db-extensions.json db-model-template.json property-types.json"
            ;;
        jsonui-viewmodel-impl)
            echo "collection-kotlin.kt collection-swift.swift colormanager-kotlin.kt colormanager-swift.swift event-handler-kotlin.kt event-handler-swift.swift hardcode-correct.kt hardcode-correct.swift hardcode-wrong.kt hardcode-wrong.swift logger-correct.swift logger-wrong.swift repository-pattern.swift stringmanager-swift.swift strings-kotlin.kt viewmodel-kotlin.kt viewmodel-swift.swift"
            ;;
        *)
            echo ""
            ;;
    esac
}

echo "Installing JsonUI Agents for Claude Code..."
echo "  Source: $REF_TYPE '$REF'"

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
rule_count=0

# Download agent files
echo ""
echo "Downloading agents..."
for file in $AGENT_FILES; do
    echo "  - $AGENTS_DIR/$file"
    if ! curl -sLf "$REPO_URL/.claude/agents/$file" -o "$AGENTS_DIR/$file"; then
        echo "Error: Failed to download $file" >&2
        echo "Please check if the $REF_TYPE '$REF' exists." >&2
        exit 1
    fi
    agent_count=$((agent_count + 1))
done

# Download skill files
echo ""
echo "Downloading skills..."
for skill in $SKILL_DIRS; do
    echo "  - skills/$skill/SKILL.md"
    mkdir -p "$SKILLS_DIR/$skill"
    if ! curl -sLf "$REPO_URL/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md"; then
        echo "Error: Failed to download skills/$skill/SKILL.md" >&2
        echo "Please check if the $REF_TYPE '$REF' exists." >&2
        exit 1
    fi
    skill_count=$((skill_count + 1))

    examples=$(get_skill_examples "$skill")
    if [ -n "$examples" ]; then
        mkdir -p "$SKILLS_DIR/$skill/examples"
        for example in $examples; do
            echo "    - examples/$example"
            if ! curl -sLf "$REPO_URL/skills/$skill/examples/$example" -o "$SKILLS_DIR/$skill/examples/$example" 2>/dev/null; then
                echo "    (skipped - not found)"
            fi
        done
    fi
done

# Download rule files
echo ""
echo "Downloading rules..."
for file in $RULE_FILES; do
    echo "  - $RULES_DIR/$file"
    if ! curl -sLf "$REPO_URL/.claude/jsonui-rules/$file" -o "$RULES_DIR/$file"; then
        echo "Error: Failed to download $file" >&2
        echo "Please check if the $REF_TYPE '$REF' exists." >&2
        exit 1
    fi
    rule_count=$((rule_count + 1))
done

# Download the workflow menu and slash command
echo ""
echo "Downloading workflow menu and slash command..."
if ! curl -sLf "$REPO_URL/.claude/jsonui-workflow.md" -o "$CLAUDE_DIR/jsonui-workflow.md"; then
    echo "Error: Failed to download jsonui-workflow.md" >&2
    exit 1
fi
echo "  - $CLAUDE_DIR/jsonui-workflow.md"
if ! curl -sLf "$REPO_URL/.claude/commands/jsonui.md" -o "$COMMANDS_DIR/jsonui.md"; then
    echo "Error: Failed to download commands/jsonui.md" >&2
    exit 1
fi
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
echo "  Skills: $skill_count"
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
