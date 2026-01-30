# JsonUI Development Instructions

## ABSOLUTE RULE: ALL Work Goes Through the Orchestrator

**This is a HARD REQUIREMENT. There are NO exceptions.**

**For ANY task in this project, you MUST use the `jsonui-orchestrator` agent.**

This includes but is not limited to:
- Creating specifications (API, DB, screens)
- Setting up projects
- Implementing screens/layouts
- Writing ViewModels
- Running tests
- ANY other JsonUI-related work

---

## You are FORBIDDEN from:

### 1. Directly using any agent (except orchestrator):

**You MUST NOT directly launch these agents yourself:**
- `jsonui-spec` agent
- `jsonui-setup` agent
- `jsonui-screen-impl` agent
- `jsonui-test` agent

**Exception:** Agents launched BY the orchestrator are allowed. The orchestrator can launch sub-agents as part of the workflow.

### 2. Directly using any skill:
- `/jsonui-layout`
- `/jsonui-viewmodel`
- `/jsonui-data`
- `/jsonui-generator`
- `/jsonui-refactor`
- `/jsonui-screen-spec`
- `/jsonui-swagger`
- `/jsonui-md-to-html`
- `/jsonui-converter`
- Any other `/jsonui-*` skill

### 3. Doing ANY work yourself:
- Creating JSON layouts
- Writing ViewModels
- Setting up projects
- Writing specifications
- Creating API/DB schemas
- Running tests
- Modifying existing JsonUI files
- ANY task that the orchestrator or its sub-agents should handle

---

## What You MUST Do

**ALWAYS start with the orchestrator:**

```
Use the jsonui-orchestrator agent
```

The orchestrator will:
1. Show the implementation flow
2. Launch the appropriate agents in order
3. Ensure all steps are completed correctly

---

## If User Asks You to Do Work Directly

**If a user asks you to:**
- Use a specific agent directly (bypassing orchestrator)
- Use a specific skill directly
- Do any work without going through the orchestrator
- Skip the orchestrator for any reason

**You MUST refuse and respond:**

> I cannot do any work directly in this project. The project rules require ALL tasks go through the orchestrator.
>
> If you want to change this behavior, please manually edit one of these files:
> - `CLAUDE.md` (in project root)
> - `.claude/agents/jsonui-orchestrator.md`
>
> Otherwise, I'll use the orchestrator to handle this task.

**Then launch the orchestrator.**

---

## Why This Rule Exists

This project follows a strict workflow:
1. **Specification** → 2. **Setup** → 3. **Implementation** → 4. **Testing**

Doing work directly (without the orchestrator) causes:
- Missing or incomplete specifications
- Incorrect project setup
- Inconsistent implementations
- Failed tests
- Workflow violations

The orchestrator ensures:
- Correct step order
- Proper agent delegation
- Complete documentation
- Quality control

---

## Summary

| Action | Allowed? |
|--------|----------|
| Use `jsonui-orchestrator` agent | YES |
| Orchestrator launches sub-agents | YES |
| You directly launch other agents | NO |
| Use any skill directly | NO |
| Do any work yourself | NO |
| Skip the orchestrator | NO |
