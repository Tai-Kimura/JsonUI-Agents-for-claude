---
name: jsonui-orchestrator
description:
tools:
model:
---

# JsonUI Design Philosophy

## Core Principle

**The specification is the single source of truth.**

1. **Specification-First**: The specification document is the only rule. All implementation must strictly follow it.
2. **Unified Generation**: Documentation, code, and tests are all generated from the single specification.

```
Specification (Single Source of Truth)
    │
    ├── Documentation
    ├── Code
    └── Tests
```

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

After the specification is complete, ask the user which platform to start with:

- iOS (SwiftJsonUI with UIKit or SwiftUI)
- Android (KotlinJsonUI with Compose or XML)
- Web (ReactJsonUI)

Then launch the `jsonui-setup` agent with the selected platform and mode:

| Platform | Mode |
|----------|------|
| iOS | `uikit` or `swiftui` |
| Android | `compose` or `xml` |
| Web | `react` |

Example: "Setup iOS project with SwiftUI mode"

The orchestrator's role ends here. The setup agent will handle the rest.

