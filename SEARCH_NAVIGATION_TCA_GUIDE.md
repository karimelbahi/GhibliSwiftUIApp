# TCA Navigation: Search Results → Film Detail

I'll trace the full search results → film detail navigation path and annotate each TCA-related line.

Here is the full search results → detail flow, file by file, with TCA notes on each important line. I also explain effects at the end.

This tab uses the **same** `FilmTabNavigation` stack, `FilmTabPathDestinationView`, `FilmDetailScreen`, and `FilmDetailFeature` as the Movies tab after `.filmDetail` is pushed. See [NAVIGATION_TCA_GUIDE.md](NAVIGATION_TCA_GUIDE.md) from Step 5 onward for those shared pieces.

For detail → person on this tab, see [PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md](PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md) — only the **parent feature** name changes (`SearchFeature` instead of `FilmsFeature`).

---

## Big picture (what happens when you tap a search result)

1. User types in search field → debounced `.run` loads results
2. Tap film row on **Search** tab
3. `store.send(.filmTapped(film))`
4. `SearchFeature` reducer appends to `state.path`
5. Same `NavigationStack` reads `path`
6. Shows `FilmDetailScreen`
7. `store.send(.onAppear)`
8. `.run` effect fetches people
9. UI updates characters

**TCA rule of thumb:**  
View sends an **Action** → **Reducer** updates **State** → View re-renders.

Navigation to detail is a **state change** (`.none` effect). Loading search results uses **`.run` + `.cancellable`**. Loading characters on detail uses another **`.run` effect**.

**What's different from Movies tab?** The **root screen** loads data via **debounced search** (`searchTextChanged`), not `onAppear` + full catalog fetch.

---

## Step 0 — How `SearchScreen` gets its store (`AppView`)

```swift
// TCA: Scope = slice the root store down to SearchFeature only.
//      Reads AppFeature.State.search, sends actions as AppFeature.Action.search(...).
store: store.scope(state: \.search, action: \.search)
```

`SearchScreen` does not own the whole app state. It only sees `SearchFeature.State` and can only send `SearchFeature.Action`.

Shared `favoriteIDs` are synced from `AppFeature` into `SearchFeature.State` when favorites load or toggle.

---

## Step 1 — `SearchFeature.State` (navigation lives in state)

```swift
// TCA: @ObservableState = SwiftUI can observe changes to this struct automatically.
@ObservableState
struct State: Equatable {
    var searchText: String = ""
    var searchState: LoadingState<[Film]> = .idle
    var favoriteIDs: Set<String> = []

    // TCA: StackState = navigation stack owned by THIS tab (independent from Movies/Favorites path).
    var path = StackState<FilmTabNavigation.State>()
}
```

Each tab has its **own** `path`. Navigating on Search does not affect other tabs.

---

## Step 2 — `SearchFeature.Action` (what can happen)

```swift
// TCA: @CasePathable = lets TCA extract nested actions like .path(...) for Scope/forEach.
@CasePathable
enum Action: Equatable {
    // TCA: User typed in search field — triggers debounced search effect.
    case searchTextChanged(String)
    case searchResponse(Result<[Film], DomainError>, searchTerm: String)
    case favoriteButtonTapped(String)

    // TCA: User tapped a search result — this action starts navigation.
    case filmTapped(Film)

    // TCA: Actions from screens already ON the navigation stack (detail, person, etc.).
    case path(StackActionOf<FilmTabNavigation>)
}
```

---

## Step 3 — Search UI + result tap (`SearchScreen`)

### Search field binding (not navigation, but feeds the list)

```swift
// TCA: Manual Binding — read state, send Action on change (no @BindingState here).
.searchable(text: Binding(
    get: { store.searchText },
    set: { store.send(.searchTextChanged($0)) }
))
```

Typing dispatches `.searchTextChanged` → reducer runs debounced `.run` → results appear in `searchState`.

### Tap a result

```swift
// TCA: @Bindable store = read state + bind this tab's navigation path.
@Bindable var store: StoreOf<SearchFeature>

FilmListView(
    films: films,
    onFilmTapped: { store.send(.filmTapped($0)) },
    onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
)
```

So: tap → `.filmTapped(film)` action goes into `SearchFeature`.

---

## Step 4 — Reducer handles navigation (`SearchFeature`)

```swift
case let .filmTapped(film):
    // TCA: Pure navigation — append detail to THIS tab's path.
    state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))

    // TCA: .none = no Effect; NavigationStack reacts to path change.
    return .none
```

**Important:**

- `.filmTapped` → **state change only** → effect is `.none`
- Same append pattern as `FilmsFeature` / `FavoritesFeature` — only the owning feature differs

---

## Step 5 — SwiftUI binds to the stack (`SearchScreen`)

```swift
// TCA: Two-way bind NavigationStack to SearchFeature.State.path.
NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
    // ... search results root ...
} destination: { pathStore in
    // TCA: Shared destination view — same as Movies and Favorites tabs.
    FilmTabPathDestinationView(
        store: pathStore,
        favoriteIDs: store.favoriteIDs,
        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
    )
}
```

---

## Steps 6–9 — Shared with Movies tab

After `.filmDetail` is appended, the flow is **identical** to the Movies tab:

| Step | Shared component | Guide |
|------|------------------|-------|
| Stack path enum | `FilmTabNavigation` | [NAVIGATION_TCA_GUIDE.md](NAVIGATION_TCA_GUIDE.md) Step 5 |
| Destination switch | `FilmTabPathDestinationView` | Step 7 |
| Detail screen | `FilmDetailScreen` | Step 8 |
| Detail reducer + `.run` | `FilmDetailFeature` | Step 9 |

---

## Bonus — Search-specific effects (before navigation)

These run when the user **types**, not when they tap a result:

```swift
case let .searchTextChanged(searchTerm):
    state.searchText = searchTerm

    guard !searchTerm.isEmpty else {
        state.searchState = .idle
        // TCA: .cancel = stop in-flight debounced search when field cleared.
        return .cancel(id: CancelID.search)
    }

    state.searchState = .loading

    // TCA: .run = debounce 500ms, then search API.
    return .run { [ghibliClient, clock] send in
        try await clock.sleep(for: .milliseconds(500))
        try Task.checkCancellation()
        let films = try await ghibliClient.searchFilms(searchTerm)
        await send(.searchResponse(.success(films), searchTerm: searchTerm))
    }
    // TCA: .cancellable = new keystroke cancels previous search task.
    .cancellable(id: CancelID.search, cancelInFlight: true)
```

---

## What is an **Effect** in TCA? (this flow)

| Effect | Meaning | Used in search → detail? |
|--------|---------|--------------------------|
| **`.none`** | Do nothing async. State already updated. | Yes — `.filmTapped` (navigation) |
| **`.run { send in ... }`** | Run async work, then `send` new actions | Yes — debounced search; people on detail |
| **`.cancel(id:)`** | Cancel a running effect | Yes — clear search text |
| **`.cancellable(id:cancelInFlight:)`** | Auto-cancel prior `.run` with same id | Yes — typing in search field |
| **`.send(.otherAction)`** | Immediately send another action | Yes — favorite toggle via `AppFeature` |
| **`.merge(...)`** | Run multiple effects together | No in this tap flow |

**Navigation tap:** Action → `state.path.append` → `.none`  
**Search typing:** Action → `.run` + `.cancellable` → `.searchResponse` → `.none`  
**Detail data:** Action → `.onAppear` → `.run` → `.fetchPeopleResponse` → `.none`

---

## Full timeline for one tap (Search tab)

| Step | What happens | TCA piece |
|------|----------------|-----------|
| 1 | User taps search result row | `store.send(.filmTapped(film))` |
| 2 | Reducer appends to stack | `state.path.append(.filmDetail(...))` |
| 3 | Effect returned | `.none` (no async work for navigation) |
| 4 | SwiftUI sees `path` change | `NavigationStack` binding on `SearchScreen` |
| 5 | Destination built | `FilmTabPathDestinationView` → `FilmDetailScreen` |
| 6 | Detail appears | `.task` → `store.send(.onAppear)` |
| 7 | Reducer starts fetch | `return .run { ... }` in `FilmDetailFeature` |
| 8 | Network completes | `send(.fetchPeopleResponse(.success))` |
| 9 | UI shows characters | `@ObservableState` triggers re-render |

---

## Search vs Movies vs Favorites (summary)

| | Movies | Favorites | Search |
|---|--------|-----------|--------|
| Tab feature | `FilmsFeature` | `FavoritesFeature` | `SearchFeature` |
| Root view | `FilmsScreen` | `FavoritesScreen` | `SearchScreen` |
| List source | Full catalog | Filtered favorites | Search results |
| Load list | `.onAppear` + `.run` | `.onAppear` + `.run` | `.searchTextChanged` + debounced `.run` |
| `StackState` | Own `path` | Own `path` | Own `path` |
| After `.filmTapped` | Same shared detail flow | Same | Same |

---

## Navigation guides (complete set)

| Flow | Guide |
|------|-------|
| Movies list → detail | [NAVIGATION_TCA_GUIDE.md](NAVIGATION_TCA_GUIDE.md) |
| Detail → person | [PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md](PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md) |
| Favorites list → detail | [FAVORITES_NAVIGATION_TCA_GUIDE.md](FAVORITES_NAVIGATION_TCA_GUIDE.md) |
| Search results → detail | This file |
| Settings form + bindings | [SETTINGS_TCA_GUIDE.md](SETTINGS_TCA_GUIDE.md) |
