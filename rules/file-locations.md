# JsonUI File Placement Rules

## JSON Layout Files

Place in `layouts_directory` from config (default: `Layouts`).

Subdirectories allowed:
```
{layouts_directory}/
├── home.json
├── settings.json
├── cells/
│   └── item_cell.json
├── popups/
│   └── confirm.json
└── includes/
    └── header.json
```

### Prohibited Locations

- Project root
- `Resources/` (for strings.json, colors.json)
- `View/` (for generated Swift/Kotlin files)

## Style Files

Place in `styles_directory` from config (default: `Styles`).

```
{styles_directory}/
├── card_style.json
├── primary_button_style.json
└── section_header_style.json
```

**Always check config** - Do not assume `Layouts/Styles/`.

## Resource Files

Place in `Resources/` directory:
- `strings.json` - String resources
- `colors.json` - Color definitions

## Generated Files (Do Not Edit)

The following are auto-generated and must not be edited:
- `*GeneratedView.swift` / `*GeneratedView.kt`
- `*Data.swift` / `*Data.kt`
- `*Binding.swift` / `*Binding.kt`

## Tools Directories (Do Not Edit)

The following are framework tools and must not be edited:
- `sjui_tools/`
- `kjui_tools/`
- `rjui_tools/`
