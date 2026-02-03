---
name: jsonui-requirements-gather
description: Gathers screen definitions through dialogue to create spec.json files. Reads template from examples to ask structured questions.
tools: Read, Write, Glob, Grep
---

# JsonUI Requirements Gather Skill

## Purpose

Gather screen definitions from users through friendly dialogue to create structured spec.json files. This skill reads the spec template and asks questions to fill each section.

## CRITICAL: First Action

**Before asking any questions, you MUST:**

1. Read the template file: `{skill_directory}/examples/screen-spec-template.json`
2. Understand the structure you need to fill
3. Use the template to guide your questions

## Input Variables

- `platforms` - Target platforms (iOS, Android, Web)
- `app_concept` - Basic app idea from user
- `project_directory` - Where to save spec documents
- `skill_directory` - Path to this skill (for reading template)

## Workflow

### Phase 1: Load Template and Understand Context

First, read the template:

```
Reading spec template to understand what information I need to gather...
```

Then confirm what you're building:

```
I'll help you define the screens for "{app_concept}".
Target platform(s): {platforms}

Let's start designing your screens one by one.
```

### Phase 2: Screen Overview

Ask about the first screen:

```
What is the first (or main) screen of your app?

For example:
- "Login screen"
- "Home dashboard"
- "Product list"

What screen would you like to define?
```

### Phase 3: Screen Metadata

For each screen, gather metadata:

```
Let's define the "{screen_name}" screen.

What is the purpose of this screen?
What does the user accomplish here?
```

### Phase 4: Components (UI Elements)

Ask about UI elements on the screen:

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

For each component, ask:

```
For the "{component}" element:
- What data does it display or collect?
- Is it required or optional?
- Are there any constraints (max length, format, etc.)?
```

### Phase 5: Layout Structure

Ask about how elements are arranged:

```
How are these elements arranged on the screen?

1. Vertical stack (top to bottom)
2. Horizontal row
3. Grid layout
4. Card-based layout

Which layout feels right for this screen?
```

Ask about sections:

```
Should this screen be divided into sections?

For example:
- Header section (logo, navigation)
- Main content section
- Footer section (buttons, links)

What sections does your screen have?
```

### Phase 6: Data and State

Ask about data requirements:

```
What data does this screen need?

1. Data from API (fetched from server)
2. Data from previous screen (passed in)
3. User input (entered on this screen)
4. Local storage (saved on device)

Where does the data come from?
```

For API data:

```
What API does this screen call?

- Endpoint name or URL
- What data does it return?
- What happens if the API fails?
```

For user input:

```
What information does the user enter on this screen?

For each input field:
- Field name
- Type (text, number, date, email, etc.)
- Required or optional?
- Any validation rules?
```

### Phase 7: User Actions

Ask about what users can do:

```
What actions can users take on this screen?

For example:
- Tap a button (submit, save, delete)
- Select an item from a list
- Swipe to refresh
- Pull down to load more

What interactions does this screen support?
```

For each action:

```
When the user "{action}":
- What happens next?
- Where does the user go?
- What data is sent or saved?
```

### Phase 8: Navigation

Ask about screen transitions:

```
Where can users go from this screen?

List the possible destinations:
- Button tap → goes to {screen}
- List item tap → goes to {screen}
- Back button → goes to {screen}
```

### Phase 9: Validation Rules

Ask about validation:

```
What validation is needed on this screen?

For example:
- Email must be valid format
- Password must be 8+ characters
- Required fields must be filled
- Date must be in the future

What rules should be enforced?
```

### Phase 10: Review and Confirm

Summarize the screen definition:

```
Here's the "{screen_name}" screen definition:

**Purpose:** {description}

**Components:**
{list of components}

**Layout:** {layout_type}
- {sections}

**Data Sources:**
{data sources}

**User Actions:**
{actions and their effects}

**Navigation:**
{navigation paths}

**Validation:**
{validation rules}

Is this correct? Would you like to change anything?
```

### Phase 11: Additional Screens

After confirming one screen:

```
Great! "{screen_name}" is defined.

Do you have more screens to define?
1. Yes, define another screen
2. No, I'm done

Which one?
```

If yes, repeat from Phase 2.

### Phase 12: Generate Spec Files

After all screens are defined, create the spec.json files:

For each screen, create `{project_directory}/docs/screens/json/{screen_id}.spec.json`

---

## Output Documents

### spec.json for each screen

Location: `{project_directory}/docs/screens/json/{screen_id}.spec.json`

Use the template structure and fill with gathered information:

```json
{
  "$schema": "screen-spec-schema.json",
  "metadata": {
    "screenName": "{from Phase 3}",
    "screenId": "{auto-generated from name}",
    "version": "1.0.0",
    "lastUpdated": "{current date}",
    "author": "",
    "description": "{from Phase 3}",
    "platform": "{from input}",
    "tags": []
  },
  "components": [
    // {from Phase 4}
  ],
  "layout": {
    // {from Phase 5}
  },
  "dataFlow": {
    // {from Phase 6}
  },
  "stateManagement": {
    // {from Phase 6}
  },
  "userActions": [
    // {from Phase 7}
  ],
  "validation": {
    // {from Phase 9}
  },
  "transitions": {
    // {from Phase 8}
  }
}
```

### screens-summary.md

Location: `{project_directory}/docs/requirements/screens-summary.md`

```markdown
# Screen Summary

## Overview
- App: {app_concept}
- Platforms: {platforms}
- Total Screens: {count}

## Screen List

| Screen | Description | Main Components |
|--------|-------------|-----------------|
| {screen1} | {desc} | {components} |

## Screen Flow

```
{screen1} → {screen2} ({action})
{screen2} → {screen3} ({action})
```

## Files Created

- docs/screens/json/{screen1}.spec.json
- docs/screens/json/{screen2}.spec.json
```

---

## Important Rules

- **Read template first** - Always read the template before asking questions
- **One question at a time** - Never ask multiple questions together
- **Simple language** - Avoid technical jargon
- **Use examples** - Always provide concrete examples
- **Confirm understanding** - Summarize and confirm before creating files
- **User's language** - Respond in the language the user uses
- **Be patient** - Allow users to think and respond at their pace
- **Map to template** - Every question should map to a template field

---

## If User Doesn't Know

When user is unsure, provide suggestions based on common patterns:

```
No problem! Here are some common patterns for {topic}:

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

---

## Completion

After creating all spec files:

```
Screen specifications created!

Files created:
{list of .spec.json files}

Summary:
- docs/requirements/screens-summary.md

Next steps:
You can now proceed to screen implementation.
Tell the orchestrator "specifications complete" to continue.
```
