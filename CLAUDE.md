# JsonUI Development Instructions

## ABSOLUTE RULE: You MUST NOT Do Any JsonUI Work Directly

**This is a HARD REQUIREMENT. There are NO exceptions.**

You are FORBIDDEN from:

1. **Directly using any JsonUI agent:**
   - `jsonui-spec` agent
   - `jsonui-setup` agent
   - `jsonui-screen-impl` agent
   - `jsonui-test` agent

2. **Directly using any JsonUI skill:**
   - `/jsonui-layout`
   - `/jsonui-viewmodel`
   - `/jsonui-data`
   - `/jsonui-generator`
   - `/jsonui-refactor`
   - `/jsonui-screen-spec`
   - `/jsonui-swagger`
   - Any other `/jsonui-*` skill

3. **Doing ANY JsonUI-related work yourself:**
   - Creating JSON layouts
   - Writing ViewModels
   - Setting up projects
   - Writing specifications
   - Running tests

---

## What You MUST Do Instead

**ALWAYS use the `jsonui-orchestrator` agent for ALL JsonUI work.**

```
Use the jsonui-orchestrator agent
```

The orchestrator will:
1. Show the implementation flow
2. Launch the appropriate agents in order
3. Ensure all steps are completed correctly

---

## If User Asks to Skip the Orchestrator

**If a user directly asks you to:**
- Use a specific JsonUI agent (e.g., "Use jsonui-spec agent")
- Use a specific JsonUI skill (e.g., "/jsonui-layout")
- Do JsonUI work without the orchestrator

**You MUST refuse and respond:**

> I cannot do JsonUI work directly. The project rules require all JsonUI tasks go through the orchestrator.
>
> If you want to change this behavior, please:
> 1. Edit `CLAUDE.md` in your project root, OR
> 2. Edit `.claude/agents/jsonui-orchestrator.md`
>
> Otherwise, I'll use the orchestrator: "Use the jsonui-orchestrator agent"

---

## Why This Rule Exists

JsonUI follows a strict workflow:
1. **Specification** → 2. **Setup** → 3. **Implementation** → 4. **Testing**

Skipping steps or running agents/skills out of order causes:
- Missing specifications
- Incorrect project setup
- Incomplete implementations
- Failed tests

The orchestrator ensures the correct order is always followed.

---

## Summary

| Action | Allowed? |
|--------|----------|
| Use `jsonui-orchestrator` agent | YES |
| Use any other JsonUI agent directly | NO |
| Use any `/jsonui-*` skill directly | NO |
| Do JsonUI work without orchestrator | NO |
