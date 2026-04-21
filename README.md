# JsonUI Agents for Claude Code

A curated set of 9 specialized agents and 11 authoring skills for Claude Code, driving JsonUI framework development across iOS (SwiftUI/UIKit), Android (Compose/XML), and Web (React/Next.js).

Installed entirely under **`.claude/`** — **your `CLAUDE.md` is never touched**.

## Installation

### One-shot: agents + CLI + MCP in one go

```bash
curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/installer/bootstrap.sh | bash
```

This installs three things:

| Piece | Where | What |
|---|---|---|
| `jsonui-cli` | `~/.jsonui-cli/` | `jui` / `sjui` / `kjui` / `rjui` / `jsonui-test` / `jsonui-doc` |
| `jsonui-mcp-server` | `~/.jsonui-mcp-server/` + registered in `~/.claude.json` | 29 MCP tools |
| Agents / skills / rules / hook | `./.claude/` (current project) | see layout below |

Partial install (e.g. agents only):

```bash
curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/installer/bootstrap.sh | \
  JSONUI_BOOTSTRAP_STEPS="agents" bash
```

Supported `JSONUI_BOOTSTRAP_STEPS` values: any comma-separated subset of `cli,mcp,agents`.

### Post-install

1. Add the CLI tools to your `PATH` (the bootstrap prints the exact lines).
2. **Restart Claude Code** so it picks up the `jui-tools` MCP server and the new SessionStart hook.
3. Start a new session in the project — the workflow menu appears **automatically** (via the SessionStart hook).

If the hook doesn't fire for some reason (e.g. you disabled it), invoke the slash command manually:

```
/jsonui
```

## How it works

- **`.claude/settings.json`** defines a `SessionStart` hook that `cat`s `.claude/jsonui-workflow.md` into the session's additional context. This makes the workflow menu appear at the start of every session.
- **`.claude/jsonui-workflow.md`** contains the menu and routing table (which agent to launch for each choice).
- **`.claude/commands/jsonui.md`** is the `/jsonui` slash command — same workflow menu, re-triggerable mid-session.
- **`.claude/agents/jsonui-*.md`** are the 9 specialized sub-agents (auto-loaded by Claude Code).
- **`.claude/jsonui-rules/*.md`** are the 5 rule files agents `Read` on demand.

Your project's `CLAUDE.md` is **not created, not overwritten, not touched**. Add whatever you want to it; this system does not depend on it.

## Directory layout (installed under `.claude/`)

```
.claude/
├── settings.json                       # SessionStart hook + permissions
├── jsonui-workflow.md                  # Menu + routing (injected at session start)
├── commands/
│   └── jsonui.md                       # /jsonui slash command
├── agents/                             # 9 sub-agents (auto-loaded by Claude Code)
│   ├── jsonui-conductor.md
│   ├── jsonui-define.md
│   ├── jsonui-ground.md
│   ├── jsonui-implement.md
│   ├── jsonui-navigation-ios.md
│   ├── jsonui-navigation-android.md
│   ├── jsonui-navigation-web.md
│   ├── jsonui-test.md
│   └── jsonui-debug.md
└── jsonui-rules/                       # Read on demand
    ├── invariants.md
    ├── mcp-policy.md
    ├── design-philosophy.md
    ├── file-locations.md
    └── specification-rules.md
```

## Agents (9)

| Agent | R/W | Responsibility |
|---|---|---|
| `jsonui-conductor` | R | Entry point — reads repo state via MCP and routes to the right sub-agent |
| `jsonui-define` | W | Spec authoring (screen / component / API/DB / doc-rules), validate, HTML docs |
| `jsonui-ground` | W | `jui init`, platform scaffolding, test runner setup |
| `jsonui-implement` | W | Layout / Styles / VM body + localize + `jui build` (0 warnings) + `jui verify` (no drift) |
| `jsonui-navigation-ios` | W | SwiftUI NavigationStack / UIKit UINavigationController |
| `jsonui-navigation-android` | W | Compose Navigation / XML NavGraph |
| `jsonui-navigation-web` | W | React Router / Next.js App Router |
| `jsonui-test` | W | Screen / flow test authoring + validation + HTML docs |
| `jsonui-debug` | R | READ-ONLY spec-first bug trace, behavior walks, code archaeology |

All agents are MCP-first — they call the `jsonui-mcp-server` for spec / layout reads, lookups, generation, build, verify. Bash shell-outs to `jui` are reserved for commands without MCP wrappers.

## Skills (11)

Authoring guides that agents invoke for specific tasks.

| Skill | Used by | Purpose |
|---|---|---|
| `jsonui-screen-spec` | `jsonui-define` | Screen `.spec.json` authoring |
| `jsonui-component-spec` | `jsonui-define` | Reusable component spec |
| `jsonui-swagger` | `jsonui-define` | API / DB OpenAPI |
| `jsonui-dataflow` | `jsonui-define`, `jsonui-implement`, `jsonui-debug` | `dataFlow.{viewModel,repositories,useCases,apiEndpoints}` + Mermaid linkage |
| `jsonui-layout` | `jsonui-implement` | Layout JSON + Styles + includes |
| `jsonui-viewmodel-impl` | `jsonui-implement` | VM / Repository / UseCase method body implementation (signatures stay in spec) |
| `jsonui-localize` | `jsonui-implement` | user-visible string extraction + `strings.json` registration |
| `jsonui-platform-setup` | `jsonui-ground` | Consolidated platform + test runner setup (iOS SwiftUI/UIKit, Android Compose/XML, Web React/Next.js) |
| `jsonui-screen-test` | `jsonui-test` | Screen test JSON authoring |
| `jsonui-flow-test` | `jsonui-test` | Flow test JSON (multi-screen journey) |
| `jsonui-test-doc` | `jsonui-test` | Description JSON + HTML documentation |

## Rules — 4 project-wide invariants

Detailed rules in [`.claude/jsonui-rules/`](.claude/jsonui-rules/). The 4 invariants:

1. **`jui build` must pass with zero warnings.**
2. **`jui verify --fail-on-diff` must pass with no drift.**
3. **`@generated` files are never edited by hand.** Edit the spec; `jui build` regenerates.
4. **`jsonui-localize` must run before a screen is declared done.** (`jui build` does not detect unlocalized strings.)

## Typical flow

```
(Claude Code session starts)
  ↓ SessionStart hook shows the workflow menu
  ↓ (user picks 1-3)
jsonui-conductor   — inspects repo via MCP
  ↓
┌──────────────┬──────────────┬──────────────┬─────────────┬────────────┐
│ jsonui-      │ jsonui-      │ jsonui-      │ jsonui-     │ jsonui-    │
│ ground       │ define       │ implement    │ test        │ debug      │
│ (setup)      │ (spec)       │ (code)       │ (test)      │ (R/O)      │
└──────────────┴──────────────┴──────────────┴─────────────┴────────────┘
                                  │
                                  ├→ jsonui-navigation-{ios,android,web}
                                  │  (when screen transitions needed)
                                  │
                                  └→ jui build (0 warnings) → jui verify (no drift)
```

One screen at a time. No batching.

## Design principle

**Spec is the single source of truth for intent + contract. Layout JSON is the SSoT for UI structure. Everything else is generated, checked, or gated.**

The 4 invariants keep the system honest. Agents can't edit `@generated` files, can't bypass `jui build` warnings, can't skip localization, can't accept `jui verify` drift. Every correction flows back to the correct source of truth.

See [`docs/plans/agent-redesign.md`](docs/plans/agent-redesign.md) for the full design rationale.

## Related repos

### Frameworks
- [SwiftJsonUI](https://github.com/Tai-Kimura/SwiftJsonUI) — iOS (SwiftUI / UIKit)
- [KotlinJsonUI](https://github.com/Tai-Kimura/KotlinJsonUI) — Android (Compose / XML Views)
- [ReactJsonUI](https://github.com/Tai-Kimura/ReactJsonUI) — Web (React / Tailwind CSS)

### CLI tooling
- [jsonui-cli](https://github.com/Tai-Kimura/jsonui-cli) — `jui`, `sjui_tools`, `kjui_tools`, `rjui_tools`, `jsonui-doc`
- [jsonui-mcp-server](https://github.com/Tai-Kimura/jsonui-mcp-server) — MCP wrapper around `jui` and related tools
- [jsonui-helper](https://github.com/Tai-Kimura/jsonui-helper) — VSCode editing support (Layout JSON, Screen Spec, Component Spec)

### Test runners
- [jsonui-test-runner](https://github.com/Tai-Kimura/jsonui-test-runner) — CLI + HTML doc generator
- [jsonui-test-runner-ios](https://github.com/Tai-Kimura/jsonui-test-runner-ios) — XCUITest driver
- [jsonui-test-runner-android](https://github.com/Tai-Kimura/jsonui-test-runner-android) — UIAutomator driver
- [jsonui-test-runner-web](https://github.com/Tai-Kimura/jsonui-test-runner-web) — Playwright driver

### Codex variant
- [JsonUI-Agents-for-Codex](https://github.com/Tai-Kimura/JsonUI-Agents-for-Codex) — same design, Codex CLI flavor (`.toml` agents, `/agent` switching, `$skill` invocation)

## License

MIT
