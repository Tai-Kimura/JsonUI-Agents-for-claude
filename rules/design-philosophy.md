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

## Rules

- Never add features not defined in the specification
- Never modify generated code directly - update the specification instead
- All agents and skills must follow the specification exactly
- When in doubt, refer to the specification
