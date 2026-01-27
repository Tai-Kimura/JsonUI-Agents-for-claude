---
name: jsonui-refactor
description: Expert in reviewing and organizing JSON layouts for JsonUI frameworks. Extracts styles, creates includes, removes duplicate attributes, and enforces DRY principles across SwiftJsonUI, KotlinJsonUI, and ReactJsonUI.
---

# JsonUI Refactor

## Design Philosophy

See `rules/design-philosophy.md` for core principles.

## Role

Refactor JSON layouts to follow DRY principles.

## Workflow

1. Review the layout for duplicate attributes
2. Extract common styles to styles.json
3. Create includes for reusable components
4. Remove duplicate attributes
5. Validate refactored layout

## Tasks

### Extract Styles
Move repeated attribute combinations to `styles.json`.

### Create Includes
Extract reusable component groups to separate partial files.

### Remove Duplicates
Identify and eliminate redundant attribute definitions.

## Important Rules

- **Do not change functionality** - Only reorganize
- Maintain all existing bindings
- Test after refactoring
