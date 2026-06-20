# TCA Navigation: Film List → Detail

I'll trace the full film list → detail navigation path and annotate each TCA-related line.

Here is the full film list → detail flow, file by file, with TCA notes on each important line. I also explain effects at the end.

---

## Big picture (what happens when you tap a film)

1. Tap film row
2. `store.send(.filmTapped(film))`
3. Reducer updates `state.path`
4. `NavigationStack` reads `path`
5. Shows `FilmDetailScreen`
6. `store.send(.onAppear)`
7. `.run` effect fetches people
8. `store.receive(.fetchPeopleResponse)`
9. UI updates characters

**TCA rule of thumb:**  
View sends an **Action** → **Reducer** updates **State** → View re-renders.

Navigation here is just a state change (no network call). Loading characters on the detail screen **does** use an effect.

---

## Step 0 — How `FilmsScreen` gets its store (`AppView`)

```swift
// TCA: Scope = take a slice of the big AppFeature store and focus it on FilmsFeature only.
//      Child actions become .films(...) on the parent automatically.
store: store.scope(state: \.films, action: \.films)
```

`FilmsScreen` does not own the whole app state. It only sees `FilmsFeature.State` and can only send `FilmsFeature.Action`.

---

## Step 1 — `FilmsFeature.State` (navigation lives in state)

```swift
// TCA: @ObservableState = SwiftUI can observe changes to this struct automatically.
@ObservableState
struct State: Equatable {
    // TCA: Normal feature data (list loading, favorites).
    var filmsState: LoadingState<[Film]> = .idle
    var favoriteIDs: Set<String> = []

    // TCA: StackState = the navigation stack stored IN reducer state (not in SwiftUI alone).
    //      Each item in path is one pushed screen.
    var path = StackState<FilmTabNavigation.State>()
}
```

Think of `path` as an array of screens currently pushed on the stack.  
Empty `path` = only the list is visible.

---

## Step 2 — `FilmsFeature.Action` (what can happen)

```swift
// TCA: @CasePathable = lets TCA extract nested actions like .path(...) and .films(...).
@CasePathable
enum Action: Equatable {
    case onAppear
    case fetchFilmsResponse(Result<[Film], DomainError>)
    case favoriteButtonTapped(String)

    // TCA: User tapped a film in the list → this action starts navigation.
    case filmTapped(Film)

    // TCA: Actions for screens already ON the navigation stack (detail, person, etc.).
    case path(StackActionOf<FilmTabNavigation>)
}
```

---

## Step 3 — User taps a row (`FilmListView` → `FilmsScreen`)

`FilmListView` is not TCA-aware. It only calls a callback:

```swift
// UI only: when user taps, call the closure passed from parent.
Button {
    onFilmTapped(film)
}
```

`FilmsScreen` connects that callback to TCA:

```swift
// TCA: @Bindable store = this view can read state AND bind to navigation path.
@Bindable var store: StoreOf<FilmsFeature>

// TCA: store.send(...) = send an Action into the reducer (like dispatching an event).
onFilmTapped: { store.send(.filmTapped($0)) }
```

So: tap → `.filmTapped(film)` action goes into `FilmsFeature`.

---

## Step 4 — Reducer handles navigation (`FilmsFeature`)

```swift
// TCA: Reduce = the function that handles every Action and returns an Effect.
var body: some Reducer<State, Action> {
    Reduce { state, action in
        switch action {
        // ... other cases ...

        // TCA: Pure navigation — only change state, no async work.
        case let .filmTapped(film):
            // TCA: Append a new screen to the stack.
            //      .filmDetail(...) is a case from FilmTabNavigation.Path enum.
            state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))

            // TCA: .none = "no side effect" (no network, no timer, nothing async).
            return .none

        // TCA: Other path actions (from detail screen) fall through here.
        case .favoriteButtonTapped, .path:
            return .none
        }
    }

    // TCA: .forEach = for EACH item in state.path, run the child reducer FilmTabNavigation.
    //      This wires detail/person reducers to stack items.
    .forEach(\.path, action: \.path) {
        FilmTabNavigation(ghibliClient: ghibliClient)
    }
}
```

**Important:**

- `.filmTapped` → **state change only** → effect is `.none`.
- SwiftUI sees `path` changed → pushes the next screen.

---

## Step 5 — What is on the stack? (`FilmTabNavigation`)

```swift
// TCA: @Reducer enum Path = one enum describes ALL possible pushed screens.
@Reducer
enum Path {
    case filmDetail(FilmDetailFeature)      // detail screen reducer + state
    case personDetail(PersonDetailFeature)  // person screen (used later)
}

// TCA: Shorthand so path state/action use this enum.
typealias State = Path.State
typealias Action = Path.Action

var body: some Reducer<State, Action> {
    // TCA: Parent reducer for path items — does nothing itself here.
    Reduce { _, _ in .none }

        // TCA: ifCaseLet = "only run FilmDetailFeature when state is .filmDetail(...)"
        .ifCaseLet(/State.filmDetail, action: /Action.filmDetail) {
            FilmDetailFeature(ghibliClient: ghibliClient)
        }
        .ifCaseLet(/State.personDetail, action: /Action.personDetail) {
            PersonDetailFeature()
        }
}
```

When you append `.filmDetail(FilmDetailFeature.State(film: film))`, TCA creates:

- stack item state = film + empty `peopleState`
- child reducer = `FilmDetailFeature`

---

## Step 6 — SwiftUI binds to the stack (`FilmsScreen`)

```swift
// TCA: NavigationStack path is TWO-WAY bound to state.path via a scoped store.
//      $store.scope(...) = Binding that reads/writes FilmsFeature.State.path
NavigationStack(path: $store.scope(state: \.path, action: \.path)) {

    // TCA: Read list state from store (filmsState, favoriteIDs).
    switch store.filmsState {
    case .loaded(let films):
        FilmListView(
            films: films,
            onFilmTapped: { store.send(.filmTapped($0)) },
            ...
        )
    ...
    }

// TCA: For each item in path, SwiftUI calls this closure with a scoped store
//      focused on THAT stack element (one detail or person screen).
} destination: { pathStore in
    FilmTabPathDestinationView(
        store: pathStore,
        favoriteIDs: store.favoriteIDs,
        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
    )
}
```

- Root of stack = film list
- `destination` = what to show for each pushed item
- Back button pop = TCA removes item from `path` automatically via the binding

---

## Step 7 — Pick the right destination view (`FilmTabPathDestinationView`)

```swift
// TCA: store.case = switch on enum state (.filmDetail vs .personDetail)
//      and get a Store scoped to that child feature.
switch store.case {

case let .filmDetail(detailStore):
    // TCA: detailStore = StoreOf<FilmDetailFeature> for THIS stack item only.
    FilmDetailScreen(
        store: detailStore,
        isFavorite: favoriteIDs.contains(detailStore.film.id),
        onFavoriteTapped: { onFavoriteTapped(detailStore.film.id) }
    )

case let .personDetail(personStore):
    PersonDetailScreen(store: personStore)
}
```

For list → detail, we land in `.filmDetail(detailStore)`.

---

## Step 8 — Detail screen appears (`FilmDetailScreen`)

```swift
// TCA: Store focused on FilmDetailFeature (one film on the stack).
@Bindable var store: StoreOf<FilmDetailFeature>

// TCA: Read state from store — UI updates when reducer changes state.
Text(store.film.title)
FilmImageView(urlPath: store.film.bannerImage)

// UI: favorite is handled by parent via closure (not FilmDetailFeature state).
FavoriteButton(isFavorite: isFavorite, action: onFavoriteTapped)

// TCA: When screen appears (or film id changes), send .onAppear action.
.task(id: store.film.id) {
    store.send(.onAppear)
}
```

`.task` triggers loading characters — that is where an **effect** starts.

---

## Step 9 — Detail reducer + effect (`FilmDetailFeature`)

```swift
@ObservableState
struct State: Equatable {
    var film: Film
    var peopleState: LoadingState<[Person]> = .idle
}

enum Action: Equatable {
    case onAppear
    case fetchPeopleResponse(Result<[Person], DomainError>)
    case personTapped(Person)
}

case .onAppear:
    guard !state.peopleState.isLoading else { return .none }
    if case .idle = state.peopleState {
        // TCA: Update UI to loading immediately.
        state.peopleState = .loading
    }
    let film = state.film

    // TCA: .run = async EFFECT (side effect). Runs outside the reducer synchronously.
    //      [ghibliClient] = capture dependency for the async closure.
    return .run { [ghibliClient] send in
        do {
            let people = try await ghibliClient.fetchPeople(film)

            // TCA: send(...) = dispatch a NEW action back into the store when done.
            await send(.fetchPeopleResponse(.success(people)))
        } catch let error as DomainError {
            await send(.fetchPeopleResponse(.failure(error)))
        } catch {
            await send(.fetchPeopleResponse(.failure(.unknown)))
        }
    }

case let .fetchPeopleResponse(.success(people)):
    // TCA: Effect finished → update state → UI shows characters.
    state.peopleState = .loaded(people)
    return .none

case let .fetchPeopleResponse(.failure(error)):
    state.peopleState = .error(error.userMessage)
    return .none
```

---

## What is an **Effect** in TCA?

An **effect** is anything the reducer returns that happens **outside** the immediate state update:

| Effect | Meaning | Used in navigation flow? |
|--------|---------|---------------------------|
| **`.none`** | Do nothing async. State already updated. | Yes — `.filmTapped` (navigation) |
| **`.run { send in ... }`** | Run async work, then `send` new actions | Yes — load characters on detail |
| **`.send(.otherAction)`** | Immediately send another action | Yes — in `AppFeature` (not in this tap flow) |
| **`.merge(...)`** | Run multiple effects together | Yes — app startup, not this tap |
| **`.cancel(id:)`** | Cancel a running effect | No in this flow (used in Search) |

**Simple mental model:**

```
Action in  →  Reducer changes state  →  returns Effect
                                              ↓
                                    .none → stop
                                    .run  → network/API → send new Action → reducer again
```

- **Navigation** = Action → `state.path.append` → `.none`
- **Loading detail data** = Action → `state.loading` → `.run` → `.fetchPeopleResponse` → `state.loaded`

---

## Full timeline for one tap

| Step | What happens | TCA piece |
|------|----------------|-----------|
| 1 | User taps film row | `store.send(.filmTapped(film))` |
| 2 | Reducer appends to stack | `state.path.append(.filmDetail(...))` |
| 3 | Effect returned | `.none` (no async work) |
| 4 | SwiftUI sees `path` change | `NavigationStack` binding |
| 5 | Destination built | `switch store.case` → `FilmDetailScreen` |
| 6 | Detail appears | `.task` → `store.send(.onAppear)` |
| 7 | Reducer starts fetch | `return .run { ... }` |
| 8 | Network completes | `send(.fetchPeopleResponse(.success))` |
| 9 | Reducer updates | `peopleState = .loaded(...)` |
| 10 | UI shows characters | `@ObservableState` triggers re-render |

---

## Bonus — person tap from detail (same stack, one level deeper)

If useful, this is the next step after detail:

```swift
// FilmDetailScreen — sends action from child feature
store.send(.personTapped(person))

// FilmDetailFeature — does NOT navigate itself
case .personTapped:
    return .none   // action bubbles up via .path

// FilmsFeature — PARENT decides to push person screen
case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
    state.path.append(.personDetail(PersonDetailFeature.State(person: person)))
    return .none
```

Child emits intent → parent owns the navigation stack. That keeps **one `NavigationStack`** and avoids SwiftUI `comparisonTypeMismatch` crashes from nested stacks.

See also: [PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md](PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md) for the full detail → person walkthrough.
