---
name: jsonui-viewmodel
description: Expert in implementing ViewModel business logic for JsonUI frameworks. Handles state management, API integration, event handlers, and testability across SwiftJsonUI, KotlinJsonUI, and ReactJsonUI.
---

# JsonUI ViewModel

## Design Philosophy

See `rules/design-philosophy.md` for core principles.

## Role

Implement ViewModel business logic and event handlers.

## Workflow

1. Read the screen specification
2. Implement data properties
3. Implement callback methods
4. Add business logic
5. Integrate with APIs if needed
6. Test the ViewModel

## ViewModel Structure

### iOS (Swift)
```swift
class ScreenNameViewModel: SJUIViewModel {
    @Published var propertyName: String = ""

    func onButtonTap() {
        // Implementation
    }
}
```

### Android (Kotlin)
```kotlin
class ScreenNameViewModel : KJUIViewModel() {
    var propertyName by mutableStateOf("")

    fun onButtonTap() {
        // Implementation
    }
}
```

### Web (React)
```typescript
const useScreenNameViewModel = () => {
    const [propertyName, setPropertyName] = useState("");

    const onButtonTap = () => {
        // Implementation
    };

    return { propertyName, onButtonTap };
};
```

## Important Rules

- **Follow the specification exactly** - Do not add features not in the spec
- Implement all callbacks defined in data section
- Handle errors appropriately
- Keep ViewModels testable
