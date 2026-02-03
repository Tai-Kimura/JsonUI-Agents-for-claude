---
name: jsonui-requirements-gather
description: Gathers detailed app requirements through friendly dialogue and creates structured requirement documents.
tools: Read, Write, Glob, Grep
---

# JsonUI Requirements Gather Skill

## Purpose

Gather detailed requirements from users (including non-engineers) through friendly dialogue and create structured requirement documents.

## Input Variables

- `platforms` - Target platforms (iOS, Android, Web)
- `app_concept` - Basic app idea from user
- `project_directory` - Where to save requirement documents

## Workflow

### Phase 1: Understand the Core Purpose

Ask about the main goal:

```
Tell me more about "{app_concept}".

Who will use this app?
For example: "store staff", "customers", "company employees", etc.
```

Then ask:

```
What is the most important feature of this app?
What's the one thing it absolutely must do?
```

### Phase 2: Identify Users (Actors)

Ask about different types of users:

```
What types of people will use this app?

For example, for a cafe reservation app:
- Customers (people making reservations)
- Staff (people managing reservations)
- Manager (people viewing sales)

What types of users does your app have?
```

### Phase 3: List Main Features

For each user type, ask:

```
What does {user_type} need to be able to do in this app?

Please list the actions. For example:
- Check available times
- Make a reservation
- Cancel a reservation
```

### Phase 4: Screen Flow

Ask about the journey:

```
Walk me through what {user_type} does from opening the app to completing their goal.

For example:
1. Open the app
2. Log in
3. Select a date
4. Select a time
5. Confirm the reservation
```

### Phase 5: Data Requirements

Ask about important information:

```
What information does this app need to manage?

For example (cafe reservation app):
- Customer info (name, phone, email)
- Reservation info (date/time, party size, table type)
- Store info (business hours, number of seats)
```

### Phase 6: Special Requirements

Ask about any special needs:

```
Any other requirements?

For example:
- Is login required? (email, social, phone number)
- Are notifications needed? (reservation reminders, etc.)
- Should it work offline?
- Multiple language support needed?
```

### Phase 7: Confirm and Create Documents

Summarize and confirm:

```
Here's what I've gathered. Please review:

**App Overview**
{summary}

**Users**
{user_types}

**Main Features**
{features}

**Screen Flow**
{screen_flow}

Is this correct? Let me know if anything needs to be changed.
```

After confirmation, create the documents.

---

## Output Documents

### 1. requirements.md

Location: `{project_directory}/docs/requirements/requirements.md`

```markdown
# {App Name} Requirements Document

## Overview
- App Name: {name}
- Platforms: {platforms}
- Description: {description}

## User Types
| User | Description |
|------|-------------|
| {user1} | {description1} |

## Functional Requirements
### {User Type 1}
- [ ] {feature1}
- [ ] {feature2}

## Non-Functional Requirements
- Authentication: {login_method}
- Notifications: {notifications}
- Languages: {languages}

## Constraints
- {constraints}
```

### 2. screens.md

Location: `{project_directory}/docs/requirements/screens.md`

```markdown
# Screen List

## Screens for {User Type 1}

| Screen | Description | Main Features |
|--------|-------------|---------------|
| {screen1} | {desc} | {features} |

## Screen Transitions

{User Type 1}:
1. {screen1} → {screen2} ({action})
2. {screen2} → {screen3} ({action})
```

### 3. features.md

Location: `{project_directory}/docs/requirements/features.md`

```markdown
# Feature List

## Required Features (MVP)
| Feature | Description | Priority |
|---------|-------------|----------|
| {feature1} | {desc} | High |

## Future Features
| Feature | Description | Priority |
|---------|-------------|----------|
| {feature2} | {desc} | Medium |
```

---

## Important Rules

- **One question at a time** - Never ask multiple questions together
- **Simple language** - Avoid technical jargon
- **Use examples** - Always provide concrete examples
- **Confirm understanding** - Summarize and confirm before proceeding
- **User's language** - Respond in the language the user uses
- **Be patient** - Allow users to think and respond at their pace
- **Be flexible** - If user doesn't know, suggest options

---

## If User Doesn't Know

When user is unsure, provide suggestions:

```
No problem! Here are some common patterns:

1. {option1}
2. {option2}
3. {option3}

Which one sounds closest? Or feel free to say "I'm not sure" - that's okay too.
```

---

## Completion

After creating all documents:

```
Requirements documents created!

Files created:
- docs/requirements/requirements.md (Requirements document)
- docs/requirements/screens.md (Screen list)
- docs/requirements/features.md (Feature list)

Next steps:
Based on this, we'll move on to detailed screen design.
Go back to the orchestrator and say "requirements complete".
```
