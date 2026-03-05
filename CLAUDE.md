# JsonUI Development Instructions

## IMMEDIATE ACTION REQUIRED

**When you read this file, you MUST IMMEDIATELY ask the user which workflow to use:**

```
Which workflow would you like to use?

1. **Requirements Definition** - Define app requirements through dialogue (recommended for new projects)
2. **Implementation** - Start implementation (requirements already defined)
3. **Modify Existing App** - Add features, fix bugs, or change existing screens
4. **Create Specs for Existing App** - Generate specifications from an existing codebase
5. **Backend Development** - Backend development (all JsonUI restrictions lifted)

Please select 1, 2, 3, 4, or 5.
```

**Based on user's choice:**
- **Option 1** → Launch `jsonui-requirements` agent
- **Option 2** → Launch `jsonui-orchestrator` agent
- **Option 3** → Launch `jsonui-modify` agent
- **Option 4** → Launch `jsonui-spec` agent with existing app context
- **Option 5** → Follow **Workflow Option 5: Backend Development** below

---

## Workflow Option 1: Requirements Definition

When user selects this option:
1. Launch the `jsonui-requirements` agent
2. The agent will ask about:
   - Target platform(s) (iOS / Android / Web)
   - App concept
   - Screen definitions (one by one)
3. Output: `docs/screens/json/*.spec.json` files
4. After completion, tell the user to **start a new session** and run `Read CLAUDE.md` again, then select Option 2

---

## Workflow Option 2: Implementation

When user selects this option:
1. Launch the `jsonui-orchestrator` agent
2. Follow the orchestrator's workflow (spec → setup → implement → test)

---

## Workflow Option 3: Modify Existing App

When user selects this option:
1. Launch the `jsonui-modify` agent
2. The agent will ask what modification is needed (add screen, modify UI, fix bug, API change, spec change)
3. Follow the modify agent's workflow for the selected modification type

---

## Workflow Option 4: Create Specs for Existing App

When user selects this option:
1. Launch the `jsonui-spec` agent
2. Tell the agent: "This is an existing app. Read the existing layout JSONs, ViewModels, and code to create specifications for the current screens."
3. The agent will:
   - Scan the project for existing layout JSON files and ViewModels
   - Create `.spec.json` files based on the existing implementation
   - Validate and generate HTML documentation for each spec
4. After completion, the user can use Option 3 (Modify) to make changes with proper specs in place

---

## Workflow Option 5: Backend Development

When user selects this option:

1. **All other rules and restrictions in this CLAUDE.md are COMPLETELY LIFTED.** The orchestrator workflow, forbidden actions, skill restrictions — none of them apply.
2. **Ask the user which `.md` file to use as the rule file** for this backend session:
   - List `.md` files found in directories such as `~/.claude/agents/`, `~/resource/`, or any path the user specifies
   - The user may also provide a custom file path directly
3. **Once the user selects a file**, read it and treat its contents as the **sole active rules** for the remainder of the session.
4. Follow ONLY the rules from the selected file. All JsonUI-specific rules in this CLAUDE.md do not apply.

---

## How the Orchestrator Workflow Works

1. **You launch `jsonui-orchestrator`** - It will show the implementation flow
2. **Show the orchestrator's response to the user AS-IS** - Do not summarize or modify
3. **Orchestrator tells you which agent to launch next** - Follow its instructions
4. **You launch the specified agent** - Complete that step
5. **Return to orchestrator** - It will tell you the next step
6. **Repeat until complete**

**IMPORTANT:** When the orchestrator returns a response, you MUST show it to the user exactly as received. Do NOT summarize, paraphrase, or omit any part of the orchestrator's output.

**IMPORTANT:** When launching agents, pass ONLY the necessary context. Do NOT include unnecessary prompts, explanations, or this entire CLAUDE.md content in the agent prompt.

---

## ABSOLUTE RULE: Workflow Must Be Followed

**For implementation tasks, ALL work goes through the orchestrator.**

This includes but is not limited to:
- Creating specifications (API, DB, screens)
- Setting up projects
- Implementing screens/layouts
- Writing ViewModels
- Running tests
- ANY other JsonUI implementation work

**Exceptions:**
- Requirements definition uses `jsonui-requirements` agent directly (Option 1).
- Existing app modifications use `jsonui-modify` agent directly (Option 3).
- Spec creation for existing apps uses `jsonui-spec` agent directly (Option 4).

---

## You are FORBIDDEN from:

### 1. Directly using implementation agents (without orchestrator direction):

**You MUST NOT directly launch these agents yourself:**
- `jsonui-spec` agent
- `jsonui-setup` agent
- `jsonui-screen-impl` agent
- `jsonui-test` agent

**Exception:** When the orchestrator tells you to launch an agent, you MUST launch it.

### 2. Directly using any skill:
- `/jsonui-layout`
- `/jsonui-viewmodel`
- `/jsonui-data`
- `/jsonui-generator`
- `/jsonui-refactor`
- `/jsonui-screen-spec`
- `/jsonui-spec-review`
- `/jsonui-swagger`
- `/jsonui-converter`
- Any other `/jsonui-*` skill

### 3. Doing ANY implementation work yourself:
- Creating JSON layouts
- Writing ViewModels
- Setting up projects
- Writing specifications
- Creating API/DB schemas
- Running tests
- Modifying existing JsonUI files
- ANY task that the orchestrator or its sub-agents should handle

---

## If User Asks You to Do Work Directly

**If a user asks you to:**
- Use an implementation agent directly (bypassing orchestrator)
- Use a specific skill directly
- Do any implementation work without going through the orchestrator
- Skip the orchestrator for any reason

**You MUST refuse and respond:**

> I cannot do implementation work directly in this project. The project rules require implementation tasks go through the orchestrator.
>
> If you want to change this behavior, please manually edit one of these files:
> - `CLAUDE.md` (in project root)
> - `.claude/agents/jsonui-orchestrator.md`
>
> Otherwise, please select a workflow option (1 for requirements, 2 for implementation, 3 for modification, 4 for spec creation).

---

## Why This Rule Exists

This project follows a strict workflow:
1. **Requirements** → 2. **Specification** → 3. **Setup** → 4. **Implementation** → 5. **Testing**

Doing work directly (without the proper workflow) causes:
- Missing or incomplete specifications
- Incorrect project setup
- Inconsistent implementations
- Failed tests
- Workflow violations

The proper workflow ensures:
- Correct step order
- Proper agent delegation
- Complete documentation
- Quality control

---

## Summary

| Action | Allowed? |
|--------|----------|
| Ask user for workflow choice first | YES |
| Launch `jsonui-requirements` agent (Option 1) | YES |
| Launch `jsonui-orchestrator` agent (Option 2) | YES |
| Launch `jsonui-modify` agent (Option 3) | YES |
| Launch `jsonui-spec` agent for existing app (Option 4) | YES |
| Backend development with custom rules (Option 5) | YES |
| Launch agent when orchestrator/modify agent tells you to | YES |
| Launch implementation agent without orchestrator direction | NO |
| Use any skill directly | NO |
| Do any implementation work yourself | NO |
| Skip the workflow selection | NO |
