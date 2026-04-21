# Specification Rules

## Absolute Rules for All Specification Work

These rules must be followed by ALL agents and skills that create or modify specification documents.

### 1. Never Interpret User Input Without Confirmation

**Do NOT make assumptions** about what the user means. If the user's input is ambiguous or incomplete:

- Ask clarifying questions
- Present your interpretation and ask if it's correct
- Do NOT fill in gaps with your own assumptions

### 2. Always Confirm Through Dialogue

When there is **any room for interpretation**, you MUST:

1. Stop and ask the user
2. Present options if applicable
3. Wait for explicit confirmation before proceeding

### 3. Examples

**Wrong:**
```
User: "Add a login button"
Agent: [Creates a blue rounded button with "Login" text, centered, 200px wide]
```

**Correct:**
```
User: "Add a login button"
Agent: "I'll add a login button. A few questions:
1. What should the button text be? (e.g., 'Login', 'Sign In', 'Log In')
2. Where should it be positioned in the layout?
3. Any specific styling requirements?"
```

**Wrong:**
```
User: "The form should validate email"
Agent: [Implements email validation with specific regex, error messages, and styling]
```

**Correct:**
```
User: "The form should validate email"
Agent: "For email validation, I need to confirm:
1. What error message should be displayed for invalid emails?
2. When should validation occur? (on blur, on submit, real-time)
3. Are there any specific email format requirements beyond standard validation?"
```

## Why This Matters

- Specifications are the **single source of truth**
- Incorrect assumptions propagate to all downstream agents
- Fixing misinterpretations later is expensive
- The user knows their requirements better than we do

## Text and String References

In Layout JSON, a text-bearing attribute (`text`, `hint`, `summary`, `copyLabel`,
etc.) takes one of:

- **Literal text** — e.g. `"text": "Hello World"`. `jui build` auto-extracts
  the literal into `strings.json` and (on Swift/Kotlin/Web) rewrites the call
  site to `StringManager.*` lookups.
- **snake_case key** — e.g. `"text": "learn_installation_headline"`. Resolved
  by `StringManagerHelper` against the loaded `strings.json`. The key can be
  bare (matches any file in `strings.json`) or prefixed with the file name
  (`"<file>_<key>"`).
- **Data binding** — e.g. `"text": "@{currentLanguage}"`. Bound to a
  ViewModel property with the `@{...}` syntax.

> **⛔ Never use `"@string/<key>"`.** That is Android XML resource syntax and
> is only handled by the legacy `kjui_tools/lib/xml/` path — not by SwiftUI,
> Compose, React, or the Dynamic runtimes. It will render as the literal
> string `@string/<key>` on every other platform.

## Color References

Color-valued attributes (`background`, `fontColor`, `borderColor`, `tintColor`,
…) take one of:

- **Semantic key** — e.g. `"background": "primary_surface"`. Resolved against
  `{layouts_directory}/Resources/colors.json`. **Preferred for new code** —
  gives the value a name, keeps the hex out of the layout, and makes later
  theming changes one-file edits.
- **Hex literal** — e.g. `"background": "#F9FAFB"`. `jui build` auto-extracts
  it into `colors.json` with a generated name (e.g. `gray_light_1`) and
  rewrites the layout. Functional but produces machine-named colors.
- **Binding** — e.g. `"background": "@{themeAccent}"` (runtime-resolved).

> When writing a new layout, reach for a semantic key first. Hex is the
> fallback when no name applies yet — build will still clean up afterwards,
> but the generated names are not as readable as ones you'd pick yourself.

## Collection Cell: declaring typed data

To give a Collection cell its own typed `data` section in the generated
Layout JSON (instead of inheriting untyped values via the parent
Collection's `items` binding), declare the cell's variables and handlers
on `structure.collection.cell` using the same shape as the screen's
`stateManagement`:

```json
"collection": {
  "id": "bars_collection",
  "cell": {
    "viewName": "BarCellView",
    "layoutFile": "bar_list/bar_cell",
    "generateCellLayout": true,
    "root": { "type": "View", "id": "bar_cell_root", ... },
    "uiVariables": [
      { "name": "barName", "type": "String", "description": "バー名", "defaultValue": "" },
      { "name": "shotPrice", "type": "String?", "description": "ショット価格" },
      { "name": "openStatusVisibility", "type": "String", "description": "営業中バッジ表示", "defaultValue": "gone" }
    ],
    "eventHandlers": [
      { "name": "onMapTap", "description": "Mapボタンタップ" }
    ]
  }
}
```

Rules:
- `cellNode.uiVariables` — same shape as `stateManagement.uiVariables`
  (name / type / description / defaultValue). Each entry becomes a typed
  entry in the cell's Layout JSON `data` section.
- `cellNode.eventHandlers` — same shape as `stateManagement.eventHandlers`.
  Each handler becomes a callback property (`(() -> Void)?`) on the cell's
  `data` so Layout JSON bindings like `"onClick": "@{onMapTap}"` resolve.
- `dataKeys` (legacy) is a plain list of names — prefer `uiVariables` for
  new specs so types and default values round-trip into the generated
  Layout.
- Screen-level `stateManagement.uiVariables` is for the screen's own data
  (collection data source, visibility flags, toast messages…). Cell data
  belongs on the cell node, not on the screen.

## Collection: `lazy: true` (default) vs `lazy: false`

`Collection` components default to lazy/virtualized containers
(`LazyVStack` / `LazyColumn` / `LazyVerticalGrid`) with their own internal
scroll. Set `lazy: false` only when you know the Collection is already nested
inside a scrollable parent — the generated code then uses plain
`VStack` / `HStack` / `Column` / `Row` + `ForEach` with **no enclosing
ScrollView / verticalScroll**, so the outer scroll handles the viewport.

Use `lazy: false` when:
- The Collection sits inside an outer `ScrollView` / `verticalScroll` /
  Compose `Column { Modifier.verticalScroll() }` and nesting a Lazy container
  would break layout (Compose infinite-height constraint crash; SwiftUI
  double-scroll behavior).
- You know the item count is small and fixed (e.g. a few cards in a section
  on a screen that already scrolls as a whole).

Do NOT use `lazy: false` when:
- The list can grow to hundreds of items — eager rendering has no
  virtualization and will load everything at once.
- You need sticky headers, programmatic `scrollTo`, `defaultScrollAnchor`,
  or `paging` — those all require the lazy path to stay active. The
  generator/runtime silently ignores those attributes under `lazy: false`.

Platform details worth knowing when reviewing output:
- **SwiftUI** `lazy: false` → `VStack` / `HStack` (or `LazyVGrid` without
  an outer `ScrollView` for multi-column), no `ScrollView`.
- **Compose** `lazy: false` → `Column` / `Row` + `forEachIndexed`, no
  `LazyColumn` / `LazyVerticalGrid`, no `verticalScroll`.
- **React** `lazy: false` → the same `div` + `.map()`, but
  `overflow-y-auto` / `overflow-x-auto` / `flex-nowrap` Tailwind classes
  are dropped.
- **UIKit** (generated) ignores `lazy: false` silently — `UICollectionView`
  is inherently lazy.
