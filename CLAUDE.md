# JsonUI Development Instructions

## IMMEDIATE ACTION REQUIRED

**When you read this file, you MUST IMMEDIATELY ask the user which workflow to use:**

```
Which workflow?

1. **New work / feature addition** — build new screens or features from the spec
2. **Modify existing** — bug fix or feature change
3. **Investigate only** — read-only analysis of current behavior / structure
4. **Backend** — work outside JsonUI's rules

Select 1, 2, 3, or 4.
```

Based on the choice:

| # | Choice | Launch |
|---|---|---|
| 1, 2, 3 | (any of the first three) | `conductor` agent — reads repo state via MCP and routes to the right sub-agent |
| 4 | Backend | Follow **Workflow 4: Backend** below |

The `conductor` is the entry point for all JsonUI work. It inspects the repo (`jui.config.json`, spec count, layout count), asks a short follow-up, then tells you which of the 8 specialized agents to launch next: `define` / `ground` / `implement` / `navigation-{ios,android,web}` / `test` / `debug`.

The full agent and skill inventory lives in `docs/plans/agent-redesign.md` and the `rules/` directory.

---

## The 4 Invariants

Every task must satisfy all four of these. Details in `rules/invariants.md`.

1. **`jui build` must pass with zero warnings.**
2. **`jui verify --fail-on-diff` must pass with no drift.**
3. **`@generated` files are never edited by hand.** To change generated signatures, edit the spec.
4. **`jsonui-localize` must run before a screen is considered done.**

These gates apply to every agent. "Zero warnings" means zero — do not silence, do not ignore.

---

## MCP-first

Agents call the `jsonui-mcp-server` for spec reads, layout reads, component lookups, builds, and verification. Bash shell-outs to the `jui` CLI are reserved for the four commands that have no MCP equivalent: `jui g screen`, `jui migrate-layouts`, `jui lint-generated`, `jui g converter`.

See `rules/mcp-policy.md` for the full tool inventory and per-agent declaration pattern.

---

## Workflow 1-3: Any JsonUI work

Launch `conductor`. It will:

1. Read repo state via MCP (`jui.config.json`, screen specs, layouts, component specs)
2. Ask 1-2 follow-up questions
3. Tell you which agent to launch next

The conductor handles all of:

- **New work / feature addition** — routes to `ground` (setup, if fresh) → `define` (spec) → `implement` → `test`, one screen at a time
- **Modify existing** — for bugs, run `debug` (READ-ONLY) first to locate the root cause from the spec, then route to `define` / `implement` / `navigation-*` as the report indicates. For a feature change, go directly to the relevant agent.
- **Investigate only** — `debug` (READ-ONLY) walks the structure starting from the spec

**Spec-first bug tracing** — when investigating a bug, always start from the spec, not the stack trace:

The investigate agent must start from the spec (not the stack trace). Symptom → spec-section mapping:

| Symptom | Spec section to inspect first |
|---|---|
| UI rendering wrong / missing | `structure.components` → Layout JSON |
| Button does nothing | `stateManagement.eventHandlers` + `dataFlow.viewModel.methods` |
| Data missing / stale | `dataFlow.viewModel.vars` + `dataFlow.repositories/useCases` |
| Visibility not toggling | `stateManagement.displayLogic` |
| API error | `dataFlow.apiEndpoints` + `repositories[].methods[].endpoint` |
| Navigation broken | `userActions` / `transitions` + native navigation code |

Always run the three gate commands as diagnostics: `jui verify --detail`, `jui build`, `doc_validate_spec`.

---

## Workflow 4: Backend

1. **All other rules in this CLAUDE.md are completely lifted** — the orchestrator flow, forbidden actions, skill restrictions, the 4 invariants. None of them apply.
2. **Ask the user which `.md` file to use as the rule file** for this backend session:
   - List `.md` files found in `~/.claude/agents/`, `~/resource/`, or any path the user specifies
   - The user may also provide a custom file path directly
3. **Once the user selects a file**, read it and treat its contents as the sole active rules for the remainder of the session.
4. Follow ONLY the rules from the selected file.

---

## Orchestration protocol

When you launch an agent that delegates to other agents (e.g. `conductor`):

1. **Show the agent's response to the user AS-IS.** Do not summarize or paraphrase.
2. When the agent tells you to launch another agent, launch it.
3. Return to the parent agent between steps.
4. Pass only the necessary context to sub-agents. Do not forward the entire CLAUDE.md.

---

## What you MUST NOT do

1. **Edit `@generated` files by hand.** Edit the spec.
2. **Commit work that produces `jui build` warnings.** Fix them first.
3. **Skip `jsonui-localize` "just this once".** It's a gate.
4. **Silently fall back to Bash when an MCP call fails.** Surface the failure.
5. **Bypass `jsonui-investigate` for bug fixes in Workflow 2.** The spec-first trace dramatically improves accuracy.
6. **Invent behavior that is not in the spec.** Ask the user, or update the spec first.

---

## Rule files

This CLAUDE.md is the entry point. Detailed rules live in `rules/`:

- [`rules/invariants.md`](rules/invariants.md) — the 4 gates
- [`rules/mcp-policy.md`](rules/mcp-policy.md) — MCP tool usage and agent `tools:` declaration pattern
- [`rules/design-philosophy.md`](rules/design-philosophy.md) — spec + Layout JSON SSoT, what's hand-written vs generated
- [`rules/file-locations.md`](rules/file-locations.md) — directory structure, never-edit zones
- [`rules/specification-rules.md`](rules/specification-rules.md) — ask-before-assuming when authoring specs

---

## Summary

| Action | Allowed? |
|--------|----------|
| Ask user for workflow choice first | YES |
| Launch `conductor` (Workflow 1, 2, 3) | YES |
| Backend with custom rules (Workflow 4) | YES |
| Launch a sub-agent when conductor (or any parent) tells you to | YES |
| Skip workflow selection | NO |
| Edit `@generated` files by hand | NO |
| Accept `jui build` warnings | NO |
| Skip `jsonui-localize` | NO |
