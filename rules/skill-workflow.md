# JsonUI Skill Workflow

## Skill Execution Order

For screen implementation, execute skills in this order:

```
jsonui-generator → jsonui-layout → jsonui-refactor → jsonui-data → jsonui-viewmodel
```

### 1. jsonui-generator
- Generates view files (`g view`, `g collection`, `g partial`)
- If custom converter needed → switch to `jsonui-converter` → return here
- Does NOT edit JSON layouts

### 2. jsonui-layout
- Edits existing JSON layouts
- Adds bindings (`@{propertyName}`)
- If new files needed → switch back to `jsonui-generator`

### 3. jsonui-refactor
- Extracts styles and includes
- Removes duplicates
- Checks for missing cell files

### 4. jsonui-data
- Defines `data` section with types
- Validates against type_converter.rb

### 5. jsonui-viewmodel
- Implements business logic
- Wires up event handlers

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

Additional parameters:
- `jsonui-layout`: `<specification>` (screen spec)
- `jsonui-viewmodel`: `<specification>` (screen spec)
