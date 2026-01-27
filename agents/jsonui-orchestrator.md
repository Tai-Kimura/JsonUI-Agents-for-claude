---
name: jsonui-orchestrator
description:
tools:
model:
---

# JsonUI Orchestrator

## Design Philosophy

See `rules/design-philosophy.md` for core principles.

## Workflow

### Step 1: Create Specification First

When starting a new project or feature, always use the specification skill first to create the specification document.

```
/jsonui-screen-spec
```

### Step 2: Install jsonui-cli

Before setup, install all CLI tools at once:

```bash
curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/jsonui-cli/main/installer/bootstrap.sh | bash
```

This installs `sjui_tools`, `kjui_tools`, `rjui_tools`, and `test_tools` to `~/.jsonui-cli/`.

### Step 3: Setup Project

After the specification is complete, ask the user:

1. **Project directory**: Where is the project located? (absolute path)
2. **Platform**: Which platform to start with?
   - iOS (SwiftJsonUI with UIKit or SwiftUI)
   - Android (KotlinJsonUI with Compose or XML)
   - Web (ReactJsonUI)

Then launch the `jsonui-setup` agent with the following parameters:

| Parameter | Value |
|-----------|-------|
| `project_directory` | User's project path |
| `jsonui_cli_path` | `~/.jsonui-cli` |
| `platform` | iOS, Android, or Web |
| `mode` | `uikit`/`swiftui` (iOS), `compose`/`xml` (Android), `react` (Web) |

Example: "Setup iOS project at /path/to/project with SwiftUI mode. CLI path: ~/.jsonui-cli"

The orchestrator's role ends here. The setup agent will handle the rest.

