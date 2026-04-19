# JsonUI Design Philosophy

## Core Principle

**The specification is the single source of truth.**

1. **Specification-First**: The specification document is the only rule. All implementation must strictly follow it.
2. **Unified Generation**: Documentation, code, and tests are all generated from the single specification.
3. **Shared Layout JSON**: Layout JSON files live in a single shared directory (`layouts_directory`) and are distributed to each platform by `jui build`. Each platform never has its own copy as the source — the shared directory IS the source.

```
Specification (Single Source of Truth)
    │
    ├── Documentation (HTML/Markdown)
    ├── Layout JSON (shared layouts_directory)
    │       │
    │       ├── jui build → iOS Layouts/
    │       ├── jui build → Android assets/Layouts/
    │       └── jui build → Web src/Layouts/
    ├── ViewModel / Repository (per platform)
    └── Tests
```

## Platform-Specific vs Runtime Attributes

Layout JSON supports two attribute override mechanisms. Do not confuse them:

| Key | Resolution | Purpose |
|-----|-----------|---------|
| `platform` (dict) | `jui build` time (static) | iOS/Android/Web differences (e.g., height, maxWidth) |
| `responsive` | App runtime (dynamic) | Screen size class switching (compact/regular/landscape) |

Both can coexist on the same node. `platform` is stripped at build time; `responsive` is left for the framework.

## Rules

- Never add features not defined in the specification
- Never modify generated code directly — update the specification instead
- All agents and skills must follow the specification exactly
- When in doubt, refer to the specification
- Never edit Layout JSON in platform directories — always edit in the shared `layouts_directory` and run `jui build`
