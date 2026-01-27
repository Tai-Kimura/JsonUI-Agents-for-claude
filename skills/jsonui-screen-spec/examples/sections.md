# Screen Specification Examples

## UI Components Table Example

| Component | ID | Description | Initial State |
|---|---|---|---|
| View | root_view | Root container | Background: white |
| ScrollView | scroll_view | Scrollable area | SafeArea enabled |
| TextField | email_field | Email input field | Keyboard: email |
| Button | submit_btn | Submit button | Dark green, 68×36pt |
| Label | error_label | Error message | Hidden |

## Layout Structure Example

```
root_view (View)
├── navi (NavigationBar - include)
└── scroll_view (ScrollView)
    └── main_view (SafeAreaView)
        ├── header_section
        │   ├── title_label
        │   └── subtitle_label
        ├── form_section
        │   ├── email_field
        │   └── password_field
        └── button_section
            ├── submit_btn
            └── cancel_btn
```

## Collection Structure Example

```
items_collection (Collection)
├── header
│   └── header_label (Label) - "Items"
├── cell
│   └── item_cell (View)
│       ├── item_image (Image)
│       ├── item_title (Label)
│       └── item_price (Label)
└── footer
    └── load_more_btn (Button) - "Load More"
```

## TabView Structure Example

```
main_tab (TabView)
├── Tab 0: "Home" (icon: house) → HomeTab
├── Tab 1: "Search" (icon: magnifyingglass) → SearchTab
├── Tab 2: "Profile" (icon: person) → ProfileTab
└── Tab 3: "Settings" (icon: gear) → SettingsTab
```

## UI Data Variables Example

| Variable Name | Type | Description |
|---|---|---|
| isLoading | Bool | Loading indicator state |
| errorMessage | String? | Error message to display |
| submitButtonEnabled | Bool | Submit button enabled state |
| formVisibility | Visibility | Form section visibility |

## Example Dialogue Flow

**Agent:** "I'll create a screen specification document. Please provide the functional requirements for this screen. Any format is fine - PDF, Figma, bullet points, etc."

**User:** [Provides PDF or description]

**Agent:** "Thank you. I extracted the following information:
- Screen Name: Login
- Overview: User login screen
- UI Components: [extracted list]

I need to confirm a few things:
1. What is the localized screen name?
2. There was no mention of validation rules. What validation rules apply?"

**User:** [Provides answers]

**Agent:** [Continues until all information is gathered, then generates the document]
