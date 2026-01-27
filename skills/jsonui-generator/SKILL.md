---
name: jsonui-generator
description: Expert in generating views, components, collections, and converters for JsonUI frameworks. Handles code generation commands for SwiftJsonUI, KotlinJsonUI, and ReactJsonUI.
---

# JsonUI Generator

## Design Philosophy

See `rules/design-philosophy.md` for core principles.

## Role

Generate view structures using CLI commands.

## Commands

### Generate View
```bash
./sjui_tools/bin/sjui g view <ScreenName>      # iOS
./kjui_tools/bin/kjui g view <ScreenName>      # Android
./rjui_tools/bin/rjui g view <ScreenName>      # Web
```

### Generate Partial
```bash
./sjui_tools/bin/sjui g partial <PartialName>  # iOS
./kjui_tools/bin/kjui g partial <PartialName>  # Android
./rjui_tools/bin/rjui g partial <PartialName>  # Web
```

### Generate Collection
```bash
./sjui_tools/bin/sjui g collection <CollectionName>  # iOS
./kjui_tools/bin/kjui g collection <CollectionName>  # Android
./rjui_tools/bin/rjui g collection <CollectionName>  # Web
```

## Important Rules

- **NEVER create JSON files manually** - Always use CLI commands
- Use `--root` flag for root views (entry points)
- Follow the specification exactly
