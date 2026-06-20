# TCA Guide: Settings Screen (Form + Bindings)

I'll trace how the Settings tab works in TCA — **without stack navigation**.

Settings does **not** push child screens. There is no `StackState`, no `path.append`, and no `$store.scope(state: \.path, ...)`. This guide covers **form bindings**, **sync persistence**, and **`.none` effects** instead.

---

## Big picture (what happens when you change a setting)

1. User changes a control (picker, text field, stepper, toggle)
2. Manual `Binding` calls `store.send(.someAction(newValue))`
3. `SettingsFeature` reducer updates `state`
4. Reducer saves to `UserDefaults` via `SettingsStorage`
5. Returns `.none` (no async effect)
6. SwiftUI re-renders from `@ObservableState`

**TCA rule of thumb:**  
View sends an **Action** → **Reducer** updates **State** → View re-renders.

Every settings action uses **`.none`** — persistence runs synchronously inside the reducer, not in `.run`.

---

## Step 0 — How `SettingsScreen` gets its store (`AppView`)

```swift
// TCA: Scope = slice the root store down to SettingsFeature only.
//      Reads AppFeature.State.settings, sends actions as AppFeature.Action.settings(...).
store: store.scope(state: \.settings, action: \.settings)
```

`SettingsScreen` only sees `SettingsFeature.State` and `SettingsFeature.Action`.

Other tabs read settings **without** sending settings actions — e.g. `store.settings.itemsPerPage` in `AppView` for list pagination.

---

## Step 1 — `SettingsFeature.State`

```swift
// TCA: @ObservableState = SwiftUI observes changes to these fields.
@ObservableState
struct State: Equatable {
    var appearanceTheme: AppearanceTheme = .system
    var username: String = ""
    var itemsPerPage: Int = 20
    var notificationsEnabled: Bool = true
}
```

No navigation state — just form fields.

---

## Step 2 — `SettingsFeature.Action`

```swift
enum Action: Equatable {
    // TCA: Load saved values when screen appears.
    case onAppear

    // TCA: One action per form control change.
    case appearanceThemeChanged(AppearanceTheme)
    case usernameChanged(String)
    case itemsPerPageChanged(Int)
    case notificationsEnabledChanged(Bool)
    case resetDefaults
}
```

---

## Step 3 — Manual bindings (`SettingsScreen`)

TCA form controls use **manual `Binding(get:set:)`** — not `@BindingState`:

```swift
// TCA: @Bindable store = read state; bindings send Actions on change.
@Bindable var store: StoreOf<SettingsFeature>

private var appearanceThemeBinding: Binding<AppearanceTheme> {
    Binding(
        get: { store.appearanceTheme },
        set: { store.send(.appearanceThemeChanged($0)) }
    )
}
```

Same pattern for username, items per page, and notifications toggle.

```swift
Picker("Appearance", selection: appearanceThemeBinding) { ... }
TextField("Username", text: usernameBinding)
Stepper(..., value: itemsPerPageBinding, ...)
Toggle("Enable notifications", isOn: notificationsEnabledBinding)
```

**Why not `@BindingState`?** This app uses explicit actions per field — easy to test and clear in the reducer.

---

## Step 4 — Load on appear

```swift
.task {
    // TCA: Screen appeared — load persisted settings into state.
    store.send(.onAppear)
}
```

In the reducer:

```swift
case .onAppear:
    // TCA: Replace state from UserDefaults; effect is .none.
    state = SettingsStorage.load()
    return .none
```

`AppFeature` also loads settings on app launch and sends `.settings(.onAppear)`.

---

## Step 5 — Save on every change (`SettingsFeature`)

```swift
case let .appearanceThemeChanged(theme):
    state.appearanceTheme = theme
    SettingsStorage.save(state)
    return .none

case let .itemsPerPageChanged(itemsPerPage):
    state.itemsPerPage = itemsPerPage
    SettingsStorage.save(state)
    return .none

case .resetDefaults:
    state = SettingsStorage.reset()
    return .none
```

**Important:** All settings effects are **`.none`**. Saving to `UserDefaults` happens **inside** the reducer synchronously.

---

## Step 6 — Plain `NavigationStack` (not stack navigation)

```swift
NavigationStack {
    Form { ... }
    .navigationTitle("Settings")
}
```

This `NavigationStack` has **no path binding**. It only provides a navigation bar title — not TCA-driven push/pop.

Do **not** confuse this with `NavigationStack(path: $store.scope(...))` used on Movies/Favorites/Search tabs.

---

## Step 7 — Settings used by other tabs

`AppView` passes pagination from root store state:

```swift
FilmsScreen(
    store: store.scope(state: \.films, action: \.films),
    itemsPerPage: store.settings.itemsPerPage
)
```

When user changes **Items per page** in Settings, `SettingsFeature` updates `AppFeature.State.settings` via `Scope`. Other tabs read the new value on next render — no separate sync action needed.

---

## Step 8 — Appearance theme (outside reducer)

Theme is applied at app level via `@AppStorage` in `AppearanceThemeViewModifier`:

```swift
.setAppearanceTheme()  // on TabView in AppView
```

The reducer saves theme to `UserDefaults`; the modifier reads it for `preferredColorScheme`. Two reads of the same key — reducer owns writes, modifier owns UI application.

---

## What is an **Effect** in TCA? (Settings)

| Effect | Used in Settings? |
|--------|-------------------|
| **`.none`** | Yes — every action (load, save, reset) |
| **`.run`** | No |
| **`.cancel`** | No |
| **`.merge`** | No (in `SettingsFeature`; `AppFeature.onAppear` uses `.merge` for app startup) |

**Simple mental model:**

```
User changes control → store.send(.appearanceThemeChanged) → state update → SettingsStorage.save → .none
```

---

## Full timeline for one setting change

| Step | What happens | TCA piece |
|------|----------------|-----------|
| 1 | User picks Dark theme | Picker calls binding `set` |
| 2 | Action dispatched | `store.send(.appearanceThemeChanged(.dark))` |
| 3 | Reducer updates state | `state.appearanceTheme = .dark` |
| 4 | Persist | `SettingsStorage.save(state)` |
| 5 | Effect returned | `.none` |
| 6 | UI updates | `@ObservableState` + `@Bindable` |
| 7 | App theme | `AppearanceThemeViewModifier` reads `@AppStorage` |

---

## Settings vs navigation tabs (summary)

| | Movies / Favorites / Search | Settings |
|---|------------------------------|----------|
| `StackState` / `path` | Yes | No |
| Push child screens | Yes | No |
| Form bindings | No | Yes (manual `Binding`) |
| Effects | `.run`, `.none`, `.cancel` | `.none` only |
| Persistence | Favorites via `AppFeature` | `SettingsStorage` / UserDefaults |

---

## Related guides

| Topic | Guide |
|-------|-------|
| Stack navigation (list → detail) | [FILMS_NAVIGATION_TCA_GUIDE.md](FILMS_NAVIGATION_TCA_GUIDE.md) |
| Detail → person | [PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md](PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md) |
| Favorites list → detail | [FAVORITES_NAVIGATION_TCA_GUIDE.md](FAVORITES_NAVIGATION_TCA_GUIDE.md) |
| Search results → detail | [SEARCH_NAVIGATION_TCA_GUIDE.md](SEARCH_NAVIGATION_TCA_GUIDE.md) |
| Settings form + bindings | This file |
