---
name: jsonui-data
description: Expert in defining and validating JSON data sections for JsonUI frameworks. Handles data property definitions, type mappings, callback types, and cross-platform compatibility for SwiftJsonUI and KotlinJsonUI.
---

# JsonUI Data

## Design Philosophy

See `rules/design-philosophy.md` for core principles.

## Role

Define data properties and callback types in JSON layouts.

## Workflow

1. Read the screen specification
2. Define data properties in the `data` section
3. Map property types correctly
4. Define callback types for event handlers
5. Validate data section

## Data Section Structure

```json
{
  "data": {
    "properties": {
      "propertyName": {
        "type": "String",
        "default": ""
      }
    },
    "callbacks": {
      "onButtonTap": {}
    }
  }
}
```

## Type Mappings

| JSON Type | iOS (Swift) | Android (Kotlin) | Web (TypeScript) |
|-----------|-------------|------------------|------------------|
| String | String | String | string |
| Int | Int | Int | number |
| Bool | Bool | Boolean | boolean |
| Double | Double | Double | number |
| Array | [T] | List<T> | T[] |

## Important Rules

- **Follow the specification exactly**
- Use correct type names for each platform
- Define all callbacks used in bindings
