# JsonUI Agents for Claude Code

A curated set of 9 specialized agents and 11 authoring skills for Claude Code, driving JsonUI framework development across iOS (SwiftUI/UIKit), Android (Compose/XML), and Web (React/Next.js).

## Installation

### One-shot (recommended): agents + CLI + MCP in one go

```bash
curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/installer/bootstrap.sh | bash
```

This installs three things:

| Piece | Where | What |
|---|---|---|
| `jsonui-cli` | `~/.jsonui-cli/` | `jui` / `sjui` / `kjui` / `rjui` / `jsonui-test` / `jsonui-doc` |
| `jsonui-mcp-server` | `~/.jsonui-mcp-server/` + registered in `~/.claude.json` | 29 MCP tools |
| Agents / skills / rules | `./.claude/` (current project) | this repo's contents + `CLAUDE.md` |

The CLI lives at `~/.jsonui-cli/`, which is exactly where the MCP's 4-layer fallback looks, so the MCP automatically picks up the fresh attribute definitions.

Partial install (e.g. agents only, when CLI + MCP already exist):

```bash
curl -fsSL https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/installer/bootstrap.sh | \
  JSONUI_BOOTSTRAP_STEPS="agents" bash
```

Supported `JSONUI_BOOTSTRAP_STEPS` values: any comma-separated subset of `cli,mcp,agents`.

### Agents only (legacy)

If you already manage `jsonui-cli` and `jsonui-mcp-server` some other way, use the agents-only installer:

```bash
# Install from main branch
curl -H "Cache-Control: no-cache" -sL "https://raw.githubusercontent.com/Tai-Kimura/JsonUI-Agents-for-claude/main/install.sh?$(date +%s)" | bash

# Install from a branch / commit / tag
curl -H "Cache-Control: no-cache" -sL "...install.sh?$(date +%s)" | bash -s -- -b develop
curl -H "Cache-Control: no-cache" -sL "...install.sh?$(date +%s)" | bash -s -- -c abc123
curl -H "Cache-Control: no-cache" -sL "...install.sh?$(date +%s)" | bash -s -- -v 1.0.0
```

### Post-install

1. Add the CLI tools to your `PATH` (the bootstrap prints the exact lines).
2. **Restart Claude Code** so it picks up the new `jui-tools` MCP server.
3. In Claude Code, say:

   ```
   Read CLAUDE.md
   ```

You'll be asked to pick a workflow. Three of the four route through the `conductor` agent, which inspects the repo via MCP and tells you which specialized agent to launch next.

## Directory layout

```
.
├── CLAUDE.md             # Entry point
├── agents/               # 9 agents (markdown + frontmatter)
├── skills/               # 11 authoring skills
├── rules/                # 5 rule files
└── docs/plans/           # Design docs (agent-redesign.md)
```

## Agents (9)

| Agent | R/W | Responsibility |
|---|---|---|
| `conductor` | R | Entry point — reads repo state via MCP and routes to the right sub-agent |
| `define` | W | Spec authoring (screen / component / API/DB / doc-rules), validate, HTML docs |
| `ground` | W | `jui init`, platform scaffolding, test runner setup |
| `implement` | W | Layout / Styles / VM body + localize + `jui build` (0 warnings) + `jui verify` (no drift) |
| `navigation-ios` | W | SwiftUI NavigationStack / UIKit UINavigationController |
| `navigation-android` | W | Compose Navigation / XML NavGraph |
| `navigation-web` | W | React Router / Next.js App Router |
| `test` | W | Screen / flow test authoring + validation + HTML docs |
| `debug` | R | READ-ONLY spec-first bug trace, behavior walks, code archaeology |

All agents are MCP-first — they call the `jsonui-mcp-server` for spec / layout reads, lookups, generation, build, verify. Bash shell-outs to the `jui` CLI are reserved for the four commands without MCP wrappers (`jui g screen`, `jui migrate-layouts`, `jui lint-generated`, `jui g converter`).

## Skills (11)

Authoring guides that agents invoke for specific tasks.

| Skill | Used by | Purpose |
|---|---|---|
| `jsonui-screen-spec` | `define` | Screen `.spec.json` authoring |
| `jsonui-component-spec` | `define` | Reusable component spec |
| `jsonui-swagger` | `define` | API / DB OpenAPI |
| `jsonui-dataflow` | `define`, `implement`, `debug` | `dataFlow.{viewModel,repositories,useCases,apiEndpoints}` + Mermaid linkage |
| `jsonui-layout` | `implement` | Layout JSON + Styles + includes |
| `jsonui-viewmodel-impl` | `implement` | VM / Repository / UseCase method body implementation (signatures stay in spec) |
| `jsonui-localize` | `implement` | user-visible string extraction + `strings.json` registration |
| `jsonui-platform-setup` | `ground` | Consolidated platform + test runner setup (iOS SwiftUI/UIKit, Android Compose/XML, Web React/Next.js) |
| `jsonui-screen-test` | `test` | Screen test JSON authoring |
| `jsonui-flow-test` | `test` | Flow test JSON (multi-screen journey) |
| `jsonui-test-doc` | `test` | Description JSON + HTML documentation |

## Rules (4 invariants)

Detailed rules in [`rules/`](rules/). The 4 project-wide invariants:

1. **`jui build` must pass with zero warnings.**
2. **`jui verify --fail-on-diff` must pass with no drift.**
3. **`@generated` files are never edited by hand.** Edit the spec; `jui build` regenerates.
4. **`jsonui-localize` must run before a screen is declared done.** (`jui build` does not detect unlocalized strings.)

See [`rules/invariants.md`](rules/invariants.md) and [`rules/mcp-policy.md`](rules/mcp-policy.md).

## Typical flow

```
Read CLAUDE.md
  ↓ (workflow 1-3)
conductor   — inspects repo via MCP
  ↓
┌──────────┬──────────┬──────────┬────────┬────────┐
│ ground   │ define   │ implement│ test   │ debug  │
│ (setup)  │ (spec)   │ (code)   │ (test) │ (R/O)  │
└──────────┴──────────┴──────────┴────────┴────────┘
                               │
                               ├→ navigation-ios / android / web
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

### Test runners
- [jsonui-test-runner](https://github.com/Tai-Kimura/jsonui-test-runner) — CLI + HTML doc generator
- [jsonui-test-runner-ios](https://github.com/Tai-Kimura/jsonui-test-runner-ios) — XCUITest driver
- [jsonui-test-runner-android](https://github.com/Tai-Kimura/jsonui-test-runner-android) — UIAutomator driver
- [jsonui-test-runner-web](https://github.com/Tai-Kimura/jsonui-test-runner-web) — Playwright driver

### Codex variant
- [JsonUI-Agents-for-Codex](https://github.com/Tai-Kimura/JsonUI-Agents-for-Codex) — same design, Codex CLI flavor (`.toml` agents, `/agent` switching, `$skill` invocation)

## License

MIT
