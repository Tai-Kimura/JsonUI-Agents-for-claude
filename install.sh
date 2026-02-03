#!/bin/bash

# JsonUI Agents Installer for Claude Code
# This script installs JsonUI agents and skills to Claude Code's directories
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
RULES_DIR=".claude/rules"

# Agent files (in agents/ directory)
AGENT_FILES="jsonui-orchestrator.md jsonui-screen-impl.md jsonui-setup.md jsonui-spec.md jsonui-test.md"

# Skill directories (each contains SKILL.md and optionally examples/)
SKILL_DIRS="jsonui-converter jsonui-data jsonui-flow-test-implement jsonui-generator jsonui-layout jsonui-refactor jsonui-screen-spec jsonui-screen-test-implement jsonui-spec-review jsonui-swagger jsonui-test-cli jsonui-test-document jsonui-test-setup-android jsonui-test-setup-ios jsonui-test-setup-web jsonui-viewmodel kotlinjsonui-compose-setup kotlinjsonui-xml-setup reactjsonui-setup swiftjsonui-swiftui-setup swiftjsonui-uikit-setup"

# Rule files (in rules/ directory)
RULE_FILES="design-philosophy.md file-locations.md skill-workflow.md specification-rules.md"

# Function to get examples for a skill (Bash 3.2 compatible - no associative arrays)
get_skill_examples() {
    case "$1" in
        jsonui-data)
            echo "binding-missing-data.json binding-with-data.json collection-data-definition.json collection-items.json collection-legacy.json data-section-basic.json data-with-callbacks.json platform-specific-type.json twoway-binding-correct.json twoway-binding-wrong.json"
            ;;
        jsonui-layout)
            echo "binding-correct.json binding-wrong.json collection-swiftui-basic.json collection-swiftui-full.json collection-uikit.json collection-wrong.json color-correct.json color-wrong.json id-naming-correct.json id-naming-wrong.json include-correct.json include-wrong.json screen-root-structure.json screen-root-wrong.json strings-json.json"
            ;;
        jsonui-refactor)
            echo "collection-swiftui.json collection-uikit.json include-header.json include-usage.json include-wrong.json padding-correct.json padding-wrong.json style-apply.json style-card.json style-primary-button.json tabview.json"
            ;;
        jsonui-screen-spec)
            echo "component.json data-flow.json layout.json state-management.json transitions.json user-actions.json validation.json"
            ;;
        jsonui-swagger)
            echo "db-extensions.json db-model-template.json property-types.json"
            ;;
        jsonui-viewmodel)
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
for dir in "$AGENTS_DIR" "$SKILLS_DIR" "$RULES_DIR"; do
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
    echo "  - agents/$file"
    if ! curl -sLf "$REPO_URL/agents/$file" -o "$AGENTS_DIR/$file"; then
        echo "Error: Failed to download agents/$file" >&2
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

    # Download examples if they exist for this skill
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
    echo "  - rules/$file"
    if ! curl -sLf "$REPO_URL/rules/$file" -o "$RULES_DIR/$file"; then
        echo "Error: Failed to download rules/$file" >&2
        echo "Please check if the $REF_TYPE '$REF' exists." >&2
        exit 1
    fi
    rule_count=$((rule_count + 1))
done

# Download CLAUDE.md to project root
echo ""
echo "Downloading CLAUDE.md..."
if ! curl -sLf "$REPO_URL/CLAUDE.md" -o "CLAUDE.md"; then
    echo "Warning: Failed to download CLAUDE.md (optional)" >&2
else
    echo "  - CLAUDE.md (project root)"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Installed:"
echo "  Agents: $agent_count"
echo "  Skills: $skill_count"
echo "  Rules: $rule_count"
echo ""
echo "Files installed to:"
echo "  - $AGENTS_DIR"
echo "  - $SKILLS_DIR"
echo "  - $RULES_DIR"
echo ""
echo "You can now use JsonUI agents in Claude Code."
echo "Start with: \"Use the jsonui-orchestrator agent\""
echo ""
echo "----------------------------------------"
echo "IMPORTANT: Please restart your Claude Code session"
echo "to load the newly installed agents and skills."
echo "----------------------------------------"
