---
name: jsonui-requirements-gather
description: Gathers screen definitions through dialogue one screen at a time. Saves each screen's requirements immediately after confirmation.
tools: Read, Write, Glob, Grep
---

# JsonUI Requirements Gather Skill

## Purpose

Gather screen definitions from users through friendly dialogue. **Process ONE screen at a time** and save requirements immediately after each screen is confirmed.

## CRITICAL: One Screen at a Time

**You MUST complete and save each screen before moving to the next:**

1. Gather requirements for ONE screen
2. Confirm with user
3. **IMMEDIATELY save to `docs/requirements/{screen_name}.md`**
4. Ask if there are more screens
5. Repeat

**NEVER gather requirements for multiple screens before saving.**

## Input Variables

- `platforms` - Target platforms (iOS, Android, Web)
- `app_concept` - Basic app idea from user
- `project_directory` - Where to save documents

## Workflow

### Phase 1: Introduction

Confirm what you're building:

```
I'll help you define the screens for "{app_concept}".
Target platform(s): {platforms}

Let's design your screens one by one.
I'll save each screen's requirements as we complete them.
```

### Phase 2: Screen Name

Ask about the screen:

```
What is the first (or main) screen of your app?

For example:
- "Login screen"
- "Home dashboard"
- "Product list"

What screen would you like to define?
```

### Phase 3: Screen Purpose

```
Let's define the "{screen_name}" screen.

What is the purpose of this screen?
What does the user accomplish here?
```

### Phase 4: Components (UI Elements)

```
What elements appear on the "{screen_name}" screen?

For example:
- Text labels (title, description, etc.)
- Input fields (text box, dropdown, etc.)
- Buttons (submit, cancel, etc.)
- Images or icons
- Lists or tables

Please list what the user sees on this screen.
```

### Phase 5: User Actions

```
What actions can users take on this screen?

For example:
- Tap a button (submit, save, delete)
- Select an item from a list
- Enter text in a field

What interactions does this screen support?
```

### Phase 6: Navigation

```
Where can users go from this screen?

List the possible destinations:
- Button tap → goes to {screen}
- List item tap → goes to {screen}
- Back button → goes to {screen}
```

### Phase 7: Data Requirements

```
What data does this screen need?

1. Data from API (fetched from server)
2. Data from previous screen (passed in)
3. User input (entered on this screen)

Where does the data come from?
```

### Phase 8: Validation (if input exists)

```
What validation is needed on this screen?

For example:
- Email must be valid format
- Required fields must be filled
- Password must be 8+ characters

What rules should be enforced?
```

### Phase 9: Review and Confirm

Summarize the screen definition:

```
Here's the "{screen_name}" screen definition:

**Purpose:** {description}

**Components:**
{list of components}

**User Actions:**
{actions}

**Navigation:**
{navigation paths}

**Data:**
{data sources}

**Validation:**
{validation rules}

Is this correct? Would you like to change anything?
```

### Phase 10: SAVE IMMEDIATELY (MANDATORY)

**After user confirms, you MUST IMMEDIATELY save the requirements file.**

Create: `{project_directory}/docs/requirements/{screen_name}.md`

```markdown
# {Screen Name} Screen Requirements

## Overview
- **Screen Name:** {screen_name}
- **Platform:** {platforms}
- **App:** {app_concept}

## Purpose
{description of what user accomplishes}

## Components

| Component | Type | Description |
|-----------|------|-------------|
| {name} | {type} | {description} |

## User Actions

| Action | Trigger | Result |
|--------|---------|--------|
| {action} | {button/gesture} | {what happens} |

## Navigation

| From | To | Trigger |
|------|-----|---------|
| This screen | {destination} | {action} |

## Data Requirements

### Input Data
{data passed to this screen}

### Output Data
{data this screen produces}

### API Calls
{API endpoints called, if any}

## Validation Rules

| Field | Rule | Message |
|-------|------|---------|
| {field} | {rule} | {error message} |

## Notes
{any additional notes}
```

**After saving, report:**

```
Saved: docs/requirements/{screen_name}.md

Do you have more screens to define?
1. Yes, define another screen
2. No, I'm done
```

### Phase 11: Next Screen or Complete

If user wants more screens → Go back to Phase 2

If user is done → Go to Phase 12

### Phase 12: Generate Summary

Create summary file: `{project_directory}/docs/requirements/screens-summary.md`

```markdown
# Screen Summary

## Overview
- **App:** {app_concept}
- **Platforms:** {platforms}
- **Total Screens:** {count}

## Screen List

| Screen | Description | Main Actions |
|--------|-------------|--------------|
| {screen1} | {purpose} | {main actions} |
| {screen2} | {purpose} | {main actions} |

## Screen Flow

```
{screen1} → {screen2} ({action})
{screen2} → {screen3} ({action})
```

## Files Created

- docs/requirements/{screen1}.md
- docs/requirements/{screen2}.md
- docs/requirements/screens-summary.md
```

**Final report:**

```
Requirements gathering complete!

Files created:
- docs/requirements/{screen1}.md
- docs/requirements/{screen2}.md
- docs/requirements/screens-summary.md

Total screens defined: {count}

Next steps:
Start a new Claude Code session and run "Read CLAUDE.md" to begin implementation.
```

---

## Important Rules

- **ONE screen at a time** - Complete and save before moving to next
- **Save IMMEDIATELY after confirmation** - Do NOT wait until all screens are done
- **One question at a time** - Never ask multiple questions together
- **Simple language** - Avoid technical jargon
- **Use examples** - Always provide concrete examples
- **Confirm before saving** - Always ask "Is this correct?" before saving
- **User's language** - Respond in the language the user uses

---

## If User Doesn't Know

When user is unsure, provide suggestions:

```
No problem! Here are some common patterns:

1. {option1} - {description}
2. {option2} - {description}
3. {option3} - {description}

Which one sounds closest? Or feel free to say "I'm not sure" - that's okay too.
```

---

## Component Type Reference

When asking about components, reference these common types:

- **Text**: label, title, heading, paragraph
- **Input**: textField, textArea, dropdown, checkbox, radio, switch, datePicker
- **Button**: button, iconButton, floatingButton
- **Media**: image, icon, video
- **Container**: card, section, list, grid, scrollView
- **Navigation**: tabBar, navbar, drawer, breadcrumb
