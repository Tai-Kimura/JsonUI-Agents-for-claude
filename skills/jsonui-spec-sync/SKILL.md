---
name: jsonui-spec-sync
description: Syncs specification documents with actual implementation. Updates markdown specs to reflect changes made during implementation.
tools: Read, Write, Glob, Grep
---

# Specification Sync Skill

## Role

After implementation is complete, this skill compares the actual implementation with the specification and updates the specification to reflect any changes made during development.

## When to Use

Use this skill at the end of the screen implementation workflow, after:
1. `/jsonui-generator` - View generation complete
2. `/jsonui-layout` - Layout JSON implemented
3. `/jsonui-refactor` - Styles and includes extracted
4. `/jsonui-data` - Data properties defined
5. `/jsonui-viewmodel` - ViewModel implemented

**Then invoke this skill to sync the specification.**

## Workflow

### Step 1: Gather Implementation Details

Read the following files to understand what was actually implemented:

1. **Layout JSON files** - Check actual component structure, IDs, and hierarchy
2. **Data section** - Check actual data properties and types
3. **ViewModel** - Check actual event handlers and business logic
4. **Style files** - Check extracted styles
5. **Include files** - Check created partials

### Step 2: Compare with Specification

Read the specification markdown file and compare:

| Spec Section | Compare With |
|--------------|--------------|
| UI Components | Layout JSON components and IDs |
| Layout Structure | JSON hierarchy |
| UI Data Variables | `data` section properties |
| Event Handlers | ViewModel methods |
| Data Flow | Actual Repository/UseCase structure |

### Step 3: Identify Differences

Document any differences found:

- **Added**: Components, properties, or handlers added during implementation
- **Changed**: Modified names, types, or structure
- **Removed**: Items from spec that were not implemented
- **Clarified**: Vague spec items that became concrete

### Step 4: Update Specification

Update the markdown specification to reflect the actual implementation:

1. **Update UI Components table** - Match actual component IDs and types
2. **Update Layout Structure** - Match actual JSON hierarchy
3. **Update UI Data Variables** - Match actual `data` section
4. **Update Event Handlers** - Match actual ViewModel methods
5. **Update Related Files** - Add paths to created files

### Step 5: Regenerate HTML

After updating the markdown, remind the user to regenerate HTML:

```
Specification updated. Please run:
/jsonui-md-to-html docs/screens/md/{ScreenName}.md
```

## Output Format

Report the changes made:

```
## Specification Sync Complete

### Screen: {ScreenName}

### Changes Made

**UI Components**
- Added: {component_id} ({ComponentType})
- Changed: {component_id} type from {old} to {new}
- Removed: {component_id} (not implemented)

**Data Properties**
- Added: {property_name}: {Type}
- Changed: {property_name} type from {old} to {new}

**Event Handlers**
- Added: {onHandlerName}
- Renamed: {old_name} → {new_name}

**Layout Structure**
- Updated hierarchy to match implementation

**Related Files**
- Added file paths for implemented files

### Files Updated
- docs/screens/md/{ScreenName}.md

### Next Step
Run `/jsonui-md-to-html docs/screens/md/{ScreenName}.md` to regenerate HTML.
```

## Important Rules

- **Implementation is the source of truth** - The spec should match what was built, not the other way around
- **Preserve spec format** - Keep the same markdown structure and formatting
- **Document all changes** - Report every difference found and updated
- **Don't remove valid sections** - Keep sections that are still relevant even if not changed
- **Update Related Files section** - Add actual file paths created during implementation

## Example

**Before (Spec):**
```markdown
### UI Data Variables

| Variable Name | Type | Description |
|---|---|---|
| userName | String | User's display name |
| isLoading | Bool | Loading state |
```

**After Implementation (data section has):**
```json
"data": {
  "userName": "String",
  "userEmail": "String",
  "isLoading": "Bool",
  "errorMessage": "String?"
}
```

**Updated Spec:**
```markdown
### UI Data Variables

| Variable Name | Type | Description |
|---|---|---|
| userName | String | User's display name |
| userEmail | String | User's email address |
| isLoading | Bool | Loading state |
| errorMessage | String? | Error message to display |
```
