# TCA Navigation: Film Detail → Person Detail

I'll trace the full film detail → person detail navigation path and annotate each TCA-related line.

Here is the full film detail → person detail flow, file by file, with TCA notes on each important line. I also explain effects at the end.

---

## Big picture (what happens when you tap a character)

1. Tap character row on `FilmDetailScreen`
2. `store.send(.personTapped(person))`
3. `FilmDetailFeature` reducer returns `.none` (no local navigation)
4. Action bubbles up via `.path` as `.filmDetail(.personTapped(person))`
5. Parent `FilmsFeature` intercepts the stack action
6. Reducer appends `.personDetail(...)` to `state.path`
7. Same `NavigationStack` reads the longer `path`
8. Shows `PersonDetailScreen`
9. UI reads `store.person` from `PersonDetailFeature` state

**TCA rule of thumb:**  
View sends an **Action** → **Reducer** updates **State** → View re-renders.

Navigation here is **just a state change** (`.none` effect). The person screen is **display-only** — no network call, no `.run` effect.

**Important pattern:** The **child** (`FilmDetailFeature`) emits intent. The **parent** (`FilmsFeature`) owns the navigation stack and decides to push. This keeps **one `NavigationStack`** per tab.

---

## Step 0 — Where we start (already on the stack)

Before tapping a character, `state.path` already has one item from the list → detail flow:

```swift
// TCA: Stack already contains the film detail screen.
state.path = [
    .filmDetail(FilmDetailFeature.State(film: film, peopleState: .loaded(people)))
]
```

The same `NavigationStack` binding from `FilmsScreen` is still active — we only **append** another item; we do not create a new stack.

---

## Step 1 — `FilmDetailFeature.Action` (person tap intent)

```swift
enum Action: Equatable {
    case onAppear
    case fetchPeopleResponse(Result<[Person], DomainError>)

    // TCA: User tapped a character — child emits intent; parent handles navigation.
    case personTapped(Person)
}
```

This action does **not** push a screen inside `FilmDetailFeature`. It only describes what the user did.

---

## Step 2 — User taps a character (`FilmDetailScreen`)

```swift
// TCA: Store scoped to FilmDetailFeature on the navigation stack.
@Bindable var store: StoreOf<FilmDetailFeature>

// TCA: Characters come from state loaded by .onAppear / .run effect earlier.
switch store.peopleState {
case .loaded(let people):
    ForEach(people) { person in
        Button {
            // TCA: store.send = dispatch Action into FilmDetailFeature reducer.
            store.send(.personTapped(person))
        } label: {
            Text(person.name)
        }
    }
}
```

The detail screen **does not** call `state.path.append` itself. It only sends `.personTapped(person)`.

---

## Step 3 — Child reducer receives the tap (`FilmDetailFeature`)

```swift
case .personTapped:
    // TCA: No local state change and no navigation here.
    //      Action bubbles up to parent via .path (StackActionOf).
    return .none
```

**Why `.none`?**  
`FilmDetailFeature` does not own `StackState`. It cannot push `PersonDetailScreen`. It only reports the tap; the parent decides what happens next.

---

## Step 4 — How the action reaches the parent (`.path` / `StackActionOf`)

In `FilmsFeature`, stack actions are modeled like this:

```swift
// TCA: Actions from screens already ON the navigation stack.
case path(StackActionOf<FilmTabNavigation>)
```

When the child on the stack sends `.personTapped(person)`, TCA wraps it as:

```swift
// TCA: StackAction routes child action through the path element that owns FilmDetailFeature.
.path(.element(id: _, action: .filmDetail(.personTapped(person))))
```

- `.path` = action for the navigation stack
- `.element(id:action:)` = which stack item sent it
- `.filmDetail(.personTapped(person))` = the child feature and its action

This is handled by `.forEach(\.path, action: \.path)` composing `FilmTabNavigation` into `FilmsFeature`.

---

## Step 5 — Parent intercepts and pushes (`FilmsFeature`)

```swift
// TCA: Parent watches stack child actions and performs navigation itself.
case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
    // TCA: Append person screen to the SAME stack (no nested NavigationStack).
    state.path.append(.personDetail(PersonDetailFeature.State(person: person)))

    // TCA: .none = pure navigation state change, no async work.
    return .none

case .favoriteButtonTapped, .path:
    // TCA: Other .path actions fall through to child reducers via .forEach below.
    return .none
```

**Important:**

- `.personTapped` in child → effect is `.none`
- Parent append → effect is `.none`
- SwiftUI sees `path` grow → pushes `PersonDetailScreen` on the **same** stack

---

## Step 6 — Same `NavigationStack`, longer `path` (`FilmsScreen`)

No new `NavigationStack` is added. The binding from the list screen still drives everything:

```swift
// TCA: Same binding as list → detail; path now has two items (detail + person).
NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
    // ... film list root ...
} destination: { pathStore in
    FilmTabPathDestinationView(store: pathStore, ...)
}
```

| Stack depth | What user sees |
|-------------|----------------|
| `path.count == 1` | Film detail only |
| `path.count == 2` | Film detail → person detail (pushed) |

Back button pops one item from `path` at a time.

---

## Step 7 — Person case on the stack (`FilmTabNavigation`)

```swift
@Reducer
enum Path {
    case filmDetail(FilmDetailFeature)
    case personDetail(PersonDetailFeature)  // person screen reducer + state
}

// TCA: ifCaseLet = run PersonDetailFeature only when stack item is .personDetail(...).
.ifCaseLet(\State.Cases.personDetail, action: \Action.Cases.personDetail) {
    PersonDetailFeature()
}
```

When the parent appends `.personDetail(PersonDetailFeature.State(person: person))`, TCA creates:

- stack item **state** = the tapped `Person`
- child **reducer** = `PersonDetailFeature` (`EmptyReducer` — no logic)

---

## Step 8 — Destination view picks person screen (`FilmTabPathDestinationView`)

```swift
// TCA: switch store.case = match enum path state and get a child Store.
switch store.case {

case let .filmDetail(detailStore):
    FilmDetailScreen(store: detailStore, ...)

case let .personDetail(personStore):
    // TCA: personStore = StoreOf<PersonDetailFeature> for THIS stack item only.
    PersonDetailScreen(store: personStore)
}
```

For detail → person, we land in `.personDetail(personStore)`.

---

## Step 9 — Person screen appears (`PersonDetailFeature` + `PersonDetailScreen`)

### Reducer (display-only)

```swift
// TCA: State for one person screen on the navigation stack.
@ObservableState
struct State: Equatable {
    var person: Person
}

// TCA: No actions — this screen only displays data passed at navigation time.
enum Action: Equatable {}

var body: some Reducer<State, Action> {
    // TCA: EmptyReducer = no reducer logic, no effects.
    EmptyReducer()
}
```

### View

```swift
// TCA: Store scoped to PersonDetailFeature — read-only person profile.
let store: StoreOf<PersonDetailFeature>

// TCA: Read state from store; UI updates if state changes.
LabeledContent("Name", value: store.person.name)
LabeledContent("Gender", value: store.person.gender)

.navigationTitle(store.person.name)
```

No `.task`, no `store.send` — everything needed was passed in `PersonDetailFeature.State(person: person)` when the parent appended to `path`.

---

## What is an **Effect** in TCA? (this flow)

An **effect** is anything the reducer returns that happens **outside** the immediate state update:

| Effect | Meaning | Used in detail → person flow? |
|--------|---------|------------------------------|
| **`.none`** | Do nothing async. State already updated. | Yes — entire navigation flow |
| **`.run { send in ... }`** | Run async work, then `send` new actions | No |
| **`.send(.otherAction)`** | Immediately send another action | No |
| **`.merge(...)`** | Run multiple effects together | No |
| **`.cancel(id:)`** | Cancel a running effect | No |

**Simple mental model for this flow:**

```
Character tap  →  .personTapped  →  FilmDetailFeature returns .none
                                          ↓
                    Action bubbles as .path(.element(..., .filmDetail(.personTapped)))
                                          ↓
                    FilmsFeature appends .personDetail  →  returns .none
                                          ↓
                    NavigationStack pushes PersonDetailScreen
```

Unlike list → detail (which may trigger `.onAppear` + `.run` on the detail screen), **detail → person is navigation only** — all `.none`.

---

## Full timeline for one character tap

| Step | What happens | TCA piece |
|------|----------------|-----------|
| 1 | User taps character row | `store.send(.personTapped(person))` |
| 2 | Child reducer runs | `FilmDetailFeature` → `return .none` |
| 3 | Action bubbles to parent | `.path(.element(..., .filmDetail(.personTapped)))` |
| 4 | Parent appends to stack | `state.path.append(.personDetail(...))` |
| 5 | Effect returned | `.none` (no async work) |
| 6 | SwiftUI sees `path` change | Same `NavigationStack` binding |
| 7 | Destination built | `switch store.case` → `.personDetail` |
| 8 | Person screen shown | `PersonDetailScreen(store: personStore)` |
| 9 | UI renders profile | Read `store.person` from state |
| 10 | Back button | `path` pops → returns to film detail |

---

## Why child does not navigate itself

```swift
// ❌ FilmDetailFeature does NOT do this:
state.path.append(.personDetail(...))  // no path in FilmDetailFeature.State

// ✅ Instead:
// 1. Child sends intent
store.send(.personTapped(person))

// 2. Parent owns StackState and pushes
case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
    state.path.append(.personDetail(PersonDetailFeature.State(person: person)))
```

Child emits intent → parent owns the navigation stack. That keeps **one `NavigationStack`** and avoids SwiftUI `comparisonTypeMismatch` crashes from nested stacks.

---

## Same pattern in other tabs

**Favorites** and **Search** use the same `FilmTabNavigation` path and the same parent intercept:

```swift
case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
    state.path.append(.personDetail(PersonDetailFeature.State(person: person)))
    return .none
```

See also: [FILMS_NAVIGATION_TCA_GUIDE.md](FILMS_NAVIGATION_TCA_GUIDE.md) for the list → detail flow that happens before this one.
