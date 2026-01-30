# JsonUI Development Instructions

## CRITICAL: Always Use the Orchestrator

**For ALL JsonUI-related tasks, you MUST use the `jsonui-orchestrator` agent.**

Do NOT directly use:
- `jsonui-spec` agent
- `jsonui-setup` agent
- `jsonui-screen-impl` agent
- `jsonui-test` agent
- Any `/jsonui-*` skills

**Instead, always start with:**
```
Use the jsonui-orchestrator agent
```

The orchestrator will:
1. Show the implementation flow
2. Launch the appropriate agents in order
3. Ensure all steps are completed correctly

## Why?

JsonUI follows a strict workflow:
1. **Specification** → 2. **Setup** → 3. **Implementation** → 4. **Testing**

Skipping steps or running agents out of order causes problems. The orchestrator ensures the correct order is always followed.

## Quick Start

When the user wants to build something with JsonUI, respond:

"I'll use the JsonUI orchestrator to manage this project."

Then launch the `jsonui-orchestrator` agent.
