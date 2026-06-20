# TCA Navigation: Favorites List → Film Detail

I'll trace the full favorites list → film detail navigation path and annotate each TCA-related line.

Here is the full favorites list → detail flow, file by file, with TCA notes on each important line. I also explain effects at the end.

This tab uses the **same** `FilmTabNavigation` stack, `FilmTabPathDestinationView`, `FilmDetailScreen`, and `FilmDetailFeature` as the Movies tab after `.filmDetail` is pushed. See [NAVIGATION_TCA_GUIDE.md](NAVIGATION_TCA_GUIDE.md) from Step 5 onward for those shared pieces.

For detail → person on this tab, see [PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md](PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md) — only the **parent feature** name changes (`FavoritesFeature` instead of `FilmsFeature`).

---

## Big picture (what happens when you tap a favorite)

1. Tap film row on **Favorites** tab
2. `store.send(.filmTapped(film))`
3. `FavoritesFeature` reducer appends to `state.path`
4. Same `NavigationStack` reads `path`
5. Shows `FilmDetailScreen`
6. `store.send(.onAppear)`
7. `.run` effect fetches people
8. `store.receive(.fetchPeopleResponse)`
9. UI updates characters

**TCA rule of thumb:**  
View sends an **Action** → **Reducer** updates **State** → View re-renders.

Navigation to detail is a **state change** (`.none` effect). Loading characters on the detail screen uses a **`.run` effect** — same as the Movies tab.

**What's different from Movies tab?** Only the **root screen** and **tab feature** (`FavoritesFeature` / `FavoritesScreen`). The stack type, destination view, and detail reducer are shared.

---

## Step 0 — How `FavoritesScreen` gets its store (`AppView`)

```swift
// TCA: Scope = slice the root store down to FavoritesFeature only.
//      Reads AppFeature.State.favorites, sends actions as AppFeature.Action.favorites(...).
store: store.scope(state: \.favorites, action: \.favorites)
```

`FavoritesScreen` does not own the whole app state. It only sees `FavoritesFeature.State` and can only send `FavoritesFeature.Action`.

Shared `favoriteIDs` are synced from `AppFeature` into `FavoritesFeature.State` when favorites load or toggle.

---

## Step 1 — `FavoritesFeature.State` (navigation lives in state)

```swift
// TCA: @ObservableState = SwiftUI can observe changes to this struct automatically.
@ObservableState
struct State: Equatable {
    var filmsState: LoadingState<[Film]> = .idle
    var favoriteIDs: Set<String> = []

    // TCA: StackState = navigation stack owned by THIS tab (independent from Movies tab path).
    var path = StackState<FilmTabNavigation.State>()
}
```

Each tab has its **own** `path`. Navigating on Favorites does not affect the Movies tab stack.

---

## Step 2 — `FavoritesFeature.Action` (what can happen)

```swift
// TCA: @CasePathable = lets TCA extract nested actions like .path(...) for Scope/forEach.
@CasePathable
enum Action: Equatable {
    case onAppear
    case fetchFilmsResponse(Result<[Film], DomainError>)
    case favoriteButtonTapped(String)

    // TCA: User tapped a favorite film — this action starts navigation.
    case filmTapped(Film)

    // TCA: Actions from screens already ON the navigation stack (detail, person, etc.).
    case path(StackActionOf<FilmTabNavigation>)
}
```

---

## Step 3 — Favorites list UI (`FavoritesScreen`)

Unlike Movies, the list is **filtered** to favorite IDs in the view:

```swift
// TCA: @Bindable store = read state + bind navigation path to NavigationStack.
@Bindable var store: StoreOf<FavoritesFeature>

// View-only: filter loaded films to favorites (not stored separately in reducer state).
private var favoriteFilms: [Film] {
    guard let films = store.filmsState.data else { return [] }
    return films.filter { store.favoriteIDs.contains($0.id) }
}
```

User taps a row via shared `FilmListView`:

```swift
// UI only: FilmListView calls closure; parent connects to TCA.
FilmListView(
    films: favoriteFilms,
    onFilmTapped: { store.send(.filmTapped($0)) },
    onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
)
```

So: tap → `.filmTapped(film)` action goes into `FavoritesFeature`.

---

## Step 4 — Reducer handles navigation (`FavoritesFeature`)

```swift
// TCA: Reduce = handles every Action and returns an Effect.
var body: some Reducer<State, Action> {
    Reduce { state, action in
        switch action {

        case let .filmTapped(film):
            // TCA: Pure navigation — append detail to THIS tab's path.
            state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))

            // TCA: .none = no Effect; NavigationStack reacts to path change.
            return .none

        case .favoriteButtonTapped, .path:
            return .none
        }
    }

    // TCA: .forEach = run FilmTabNavigation reducer for each item in state.path.
    .forEach(\.path, action: \.path) {
        FilmTabNavigation(ghibliClient: ghibliClient)
    }
}
```

**Important:**

- `.filmTapped` → **state change only** → effect is `.none`
- Same append pattern as `FilmsFeature` — only the owning feature differs

---

## Step 5 — SwiftUI binds to the stack (`FavoritesScreen`)

```swift
// TCA: Two-way bind NavigationStack to FavoritesFeature.State.path.
NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
    // ... favorites list root ...
} destination: { pathStore in
    // TCA: Shared destination view — same as Movies and Search tabs.
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

## What is an **Effect** in TCA? (this flow)

| Effect | Meaning | Used in favorites → detail? |
|--------|---------|----------------------------|
| **`.none`** | Do nothing async. State already updated. | Yes — `.filmTapped` (navigation) |
| **`.run { send in ... }`** | Run async work, then `send` new actions | Yes — load all films on tab appear; load people on detail |
| **`.send(.otherAction)`** | Immediately send another action | Yes — favorite toggle via `AppFeature` |
| **`.merge(...)`** | Run multiple effects together | No in this tap flow |
| **`.cancel(id:)`** | Cancel a running effect | No in this tap flow |

**Navigation:** Action → `state.path.append` → `.none`  
**Detail data:** Action → `.onAppear` → `.run` → `.fetchPeopleResponse` → `.none`

---

## Full timeline for one tap (Favorites tab)

| Step | What happens | TCA piece |
|------|----------------|-----------|
| 1 | User taps favorite film row | `store.send(.filmTapped(film))` |
| 2 | Reducer appends to stack | `state.path.append(.filmDetail(...))` |
| 3 | Effect returned | `.none` (no async work for navigation) |
| 4 | SwiftUI sees `path` change | `NavigationStack` binding on `FavoritesScreen` |
| 5 | Destination built | `FilmTabPathDestinationView` → `FilmDetailScreen` |
| 6 | Detail appears | `.task` → `store.send(.onAppear)` |
| 7 | Reducer starts fetch | `return .run { ... }` in `FilmDetailFeature` |
| 8 | Network completes | `send(.fetchPeopleResponse(.success))` |
| 9 | UI shows characters | `@ObservableState` triggers re-render |

---

## Favorites vs Movies (summary)

| | Movies tab | Favorites tab |
|---|------------|---------------|
| Tab feature | `FilmsFeature` | `FavoritesFeature` |
| Root view | `FilmsScreen` | `FavoritesScreen` |
| List source | All loaded films | Filtered by `favoriteIDs` |
| `StackState` | Own `path` | Own `path` (separate stack) |
| After `.filmTapped` | Same | Same shared path + detail flow |

---

## Navigation guides (complete set)

| Flow | Guide |
|------|-------|
| Movies list → detail | [NAVIGATION_TCA_GUIDE.md](NAVIGATION_TCA_GUIDE.md) |
| Detail → person | [PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md](PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md) |
| Favorites list → detail | [FAVORITES_NAVIGATION_TCA_GUIDE.md](FAVORITES_NAVIGATION_TCA_GUIDE.md) |
| Search results → detail | [SEARCH_NAVIGATION_TCA_GUIDE.md](SEARCH_NAVIGATION_TCA_GUIDE.md) |
