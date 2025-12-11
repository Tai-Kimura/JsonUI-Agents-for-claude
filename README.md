# JsonUI Agents for Claude Code

A collection of specialized agents for Claude Code to support JsonUI framework development across iOS (SwiftUI/UIKit), Android (Compose/XML), and Web (React/Next.js).

## Installation

```bash
# Copy agent files to Claude Code's agents directory
cp *.md ~/.claude/agents/
```

## Agents

### Core Agents

| Agent | Description |
|-------|-------------|
| `jsonui-setup` | Project initialization and configuration |
| `jsonui-generator` | Code generation for Views, Collections, Converters |
| `jsonui-layout` | JSON layout creation, editing, and validation |
| `jsonui-data` | Data section type definitions and bindings |
| `jsonui-viewmodel` | ViewModel and business logic implementation |

### Platform-Specific Agents

| Agent | Platform |
|-------|----------|
| `swiftjsonui-swiftui` | iOS (SwiftUI) |
| `swiftjsonui-uikit` | iOS (UIKit) |
| `kotlinjsonui-compose` | Android (Jetpack Compose) |
| `kotlinjsonui-xml` | Android (XML Views) |
| `reactjsonui` | Web (React/Next.js) |

## Workflow

Recommended sequence when creating new Views/features:

```
jsonui-generator → jsonui-layout → jsonui-data → jsonui-viewmodel
```

1. **jsonui-generator**: Generate scaffolding with `sjui g view` / `kjui g view`
2. **jsonui-layout**: Create JSON layout structure with `@{}` bindings
3. **jsonui-data**: Define types in the `data` section
4. **jsonui-viewmodel**: Implement business logic in ViewModel

## Usage

Invoke agents in Claude Code like this:

```
# Set up a new project
"Use the jsonui-setup agent to set up an iOS project"

# Generate a View
"Use the jsonui-generator agent to generate a LoginView"

# Edit JSON layout
"Use the jsonui-layout agent to create the login screen layout"

# Define data section
"Use the jsonui-data agent to set up data bindings"

# Implement business logic
"Use the jsonui-viewmodel agent to implement the LoginViewModel"
```

## JsonUI Philosophy

JsonUI is a **cross-platform UI framework**:

1. **JSON-Driven UI**: Define UI structure in JSON, generate native code
2. **Hot Reload**: Edit JSON and see changes instantly without rebuilding
3. **Cross-Platform**: Same JSON works on iOS, Android, and Web
4. **Separation of Concerns**: JSON handles layout, ViewModel handles business logic
5. **Auto-Generated Code**: Bindings are generated from JSON - never edit them manually

## Important Rules

- **Never edit auto-generated files**: `*GeneratedView.swift`, `*Data.swift`, `*Binding.kt`, etc.
- **Never hardcode strings or colors**: Use StringManager/ColorManager
- **No logic in bindings**: `@{selectedTab == 0 ? #FF0000 : #0000FF}` is forbidden
- **Validate with build**: Always run `sjui build` / `kjui build` after JSON changes

## Related Repositories

- [SwiftJsonUI](https://github.com/Tai-Kimura/SwiftJsonUI) - JsonUI framework for iOS
- [KotlinJsonUI](https://github.com/Tai-Kimura/KotlinJsonUI) - JsonUI framework for Android
- [ReactJsonUI](https://github.com/Tai-Kimura/ReactJsonUI) - JsonUI framework for Web

## License

MIT License
