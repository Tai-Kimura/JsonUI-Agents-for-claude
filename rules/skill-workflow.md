# JsonUI Skill Workflow

## Skill Execution Order

For screen implementation, execute skills in this order:

```
jsonui-generator → jsonui-layout → jsonui-refactor → jsonui-data
    → BUILD (jui build) → jsonui-viewmodel → jsonui-localize
    → BUILD (jui build) → jsonui-spec-review (jui verify)
```

### 1. jsonui-generator
- Generates view files (`g view`, `g collection`, `g partial`)
- If custom converter needed → switch to `jsonui-converter` → return here
- Does NOT edit JSON layouts
- For new screens, `jui generate project --file <spec>` can generate initial Layout JSON + ViewModel scaffolding

### 2. jsonui-layout
- Edits Layout JSON in the **shared `layouts_directory`** (NOT in platform directories)
- Adds bindings (`@{propertyName}`)
- Supports `platform` key for platform-specific overrides
- If new files needed → switch back to `jsonui-generator`

### 3. jsonui-refactor
- Extracts styles and includes
- Removes duplicates
- Checks for missing cell files

### 4. jsonui-data
- Defines `data` section with types
- Validates against type_converter.rb

### BUILD (jui build)
- Distributes shared Layout JSON to all platforms (with PlatformResolver)
- Runs each platform's build tool (sjui build / kjui build / rjui build)
- **ZERO WARNINGS required** before proceeding

### 5. jsonui-viewmodel
- Implements business logic
- Wires up event handlers

### 6. jsonui-localize
- Localizes strings via StringManager

### BUILD (jui build)
- Final build verification
- **ZERO WARNINGS required**

### 7. jsonui-spec-review (jui verify)
- Run `jui verify --file <spec> --detail` to compare spec vs Layout JSON
- If differences found, fix layout or update spec accordingly

## Build Command

Use `jui build` instead of individual platform build commands. It handles:
1. Copy Layout JSON from shared `layouts_directory` to each platform
2. Resolve `platform` overrides (remove `platform` key, merge target attributes)
3. Run each platform's build tool

```bash
# ✅ CORRECT - Single command for all platforms
jui build

# ❌ AVOID - Individual platform builds (layouts won't be distributed)
./sjui_tools/bin/sjui build
```

**Exception:** When debugging a single platform's build errors, you may run the platform tool directly after `jui build` has distributed layouts.

## Skill Switching Rules

| From | To | When |
|------|-----|------|
| `jsonui-generator` | `jsonui-converter` | Custom native component needed |
| `jsonui-converter` | `jsonui-generator` | After converter generation |
| `jsonui-layout` | `jsonui-generator` | New file needed |
| `jsonui-refactor` | `jsonui-generator` | Missing cell files detected |

## Parameters to Pass

All skills receive:
- `<tools_directory>`: Path to tools (sjui_tools/kjui_tools/rjui_tools)
- `<layouts_directory>`: Path to shared Layout JSON directory

Additional parameters:
- `jsonui-layout`: `<specification>` (screen spec)
- `jsonui-viewmodel`: `<specification>` (screen spec)
