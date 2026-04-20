# JsonUI Development Instructions

## IMMEDIATE ACTION REQUIRED

**When you read this file, you MUST IMMEDIATELY ask the user which workflow to use:**

```
Which workflow?

1. **新規に作る／機能追加** — spec から画面や機能を新しく作る
2. **既存を直す** — バグ修正 or 機能改修
3. **調査だけ** — 読み取り専用で仕組み・挙動を調べる
4. **Backend** — JsonUI のルール外で作業する

Select 1, 2, 3, or 4.
```

Based on the choice:

| # | Choice | Launch |
|---|---|---|
| 1 | 新規に作る／機能追加 | `jsonui-orchestrator` agent |
| 2 | 既存を直す | First ask: "バグ? 機能改修?" → バグなら `jsonui-investigate` (READ-ONLY 調査)、その結果から `jsonui-modify` へ。機能改修なら直接 `jsonui-modify` |
| 3 | 調査だけ | `jsonui-investigate` agent (READ-ONLY) |
| 4 | Backend | Follow **Workflow 4: Backend** below |

> **Transitional note (Phase 1):** The agent system is being redesigned toward a 9-agent layout (`conductor` / `define` / `ground` / `implement` / `navigation-{ios,android,web}` / `test` / `debug`). Until Phase 3 lands, routing uses the current agents (`jsonui-orchestrator`, `jsonui-modify`, `jsonui-investigate`, etc.). See `docs/plans/agent-redesign.md`.

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

## Workflow 1: 新規に作る／機能追加

1. Launch `jsonui-orchestrator`
2. If `docs/app-config/` exists, pass `app_config_path: docs/app-config/`; otherwise ask the user or use the default location
3. Follow the orchestrator's flow (spec → setup → implement → test)

---

## Workflow 2: 既存を直す

Ask what kind of change:

- **バグ修正** — first launch `jsonui-investigate` (READ-ONLY) to trace the bug from the spec. Then route the findings to `jsonui-modify` for the fix.
- **機能改修** — launch `jsonui-modify` directly.
- **spec 修正だけ** — launch `jsonui-modify`; it will delegate to the spec agent.

The investigate agent must start from the spec (not the stack trace). Symptom → spec-section mapping:

| Symptom | Spec section to inspect first |
|---|---|
| UI 表示異常 | `structure.components` → Layout JSON |
| ボタン無反応 | `stateManagement.eventHandlers` + `dataFlow.viewModel.methods` |
| データ未表示/古い | `dataFlow.viewModel.vars` + `dataFlow.repositories/useCases` |
| 表示/非表示切り替え不良 | `stateManagement.displayLogic` |
| API エラー | `dataFlow.apiEndpoints` + `repositories[].methods[].endpoint` |
| 画面遷移不良 | `userActions` / `transitions` + native navigation code |

Always run the three gate commands as diagnostics: `jui verify --detail`, `jui build`, `doc_validate_spec`.

---

## Workflow 3: 調査だけ

Launch `jsonui-investigate`. This agent is strictly READ-ONLY — it never writes files. It reports findings and suggests which agent to route to for any follow-up fix.

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

When you launch an agent that delegates to other agents (e.g. `jsonui-orchestrator`):

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
| Launch `jsonui-orchestrator` (Workflow 1) | YES |
| Launch `jsonui-modify` (Workflow 2: 機能改修) | YES |
| Launch `jsonui-investigate` (Workflow 2: バグ / Workflow 3) | YES |
| Backend with custom rules (Workflow 4) | YES |
| Launch an agent when the parent agent tells you to | YES |
| Skip workflow selection | NO |
| Edit `@generated` files by hand | NO |
| Accept `jui build` warnings | NO |
| Skip `jsonui-localize` | NO |
