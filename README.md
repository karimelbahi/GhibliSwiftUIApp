# GhibliSwiftUIApp

A SwiftUI reference app for the [Studio Ghibli API](https://ghibliapi.vercel.app/), built with **Clean Architecture + TCA (The Composable Architecture)**, constructor-injected clients, and **offline-first** caching via **SwiftData**.

## Tech Stack

- iOS 17+
- SwiftUI with TCA `@ObservableState` and `@Bindable` stores
- [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) 1.25+
- URLSession with async/await
- **SwiftData** for offline-first local caching (films catalog + film people)
- Clean Architecture (Domain, Data, Features, Presentation, App) + TCA
- **SwiftUI `NavigationStack`** with shared `FilmNavigationRoute` destinations
- Swift Testing with `TestStore`, mocks, and constructor injection

## API

- Base URL: `https://ghibliapi.vercel.app/`
- Endpoints used: `/films`, `/people`
- No authentication required

## Architecture

The app is organized into logical layers inside the `GhibliSwiftUIApp` target. **Features** (TCA reducers) talk to **clients** (`GhibliClient`, `FavoritesClient`). **Clients** call **repository protocols**. **Repository implementations** coordinate **network services**, **SwiftData cache**, and **local storage** (UserDefaults for favorites and settings).

```mermaid
flowchart TB
    subgraph Presentation
        Views
        Stores["StoreOf Feature"]
        LoadingState
    end

    subgraph Features
        AppFeature
        FilmsFeature
        FavoritesFeature
        SearchFeature
        SettingsFeature
        FilmDetailFeature
        PersonDetailFeature
    end

    subgraph Clients
        GhibliClient
        FavoritesClient
        SettingsStorage
    end

    subgraph Domain
        Entities["Entities (Film, Person)"]
        RepoProtocols
        DomainError
    end

    subgraph Data
        OfflineRepo["OfflineFirstGhibliRepository"]
        RemoteRepo["DefaultGhibliRepository"]
        FavoritesRepo["DefaultFavoritesRepository"]
        CacheStore["GhibliCacheStore / SwiftData"]
        SwiftDataModels["CachedFilm, CachedPerson, CachedFilmPeople"]
        Services["GhibliService"]
        DTOs
        Mappers
        FavoriteStorage["FavoriteStorage (UserDefaults)"]
        APIError
    end

    subgraph App
        AppEntry["GhibliSwiftUIAppApp"]
        CacheContainer["GhibliCacheContainer"]
        LiveDependencies
        AppView
        ContentView
    end

    Views --> Stores
    Stores --> AppFeature
    AppFeature --> FilmsFeature & FavoritesFeature & SearchFeature & SettingsFeature
    FilmsFeature & FavoritesFeature & SearchFeature & FilmDetailFeature --> GhibliClient
    AppFeature --> FavoritesClient
    SettingsFeature --> SettingsStorage
    GhibliClient --> RepoProtocols
    FavoritesClient --> FavoritesRepo
    RepoProtocols -.-> OfflineRepo
    RepoProtocols -.-> FavoritesRepo
    OfflineRepo --> CacheStore
    OfflineRepo --> RemoteRepo
    CacheStore --> SwiftDataModels
    RemoteRepo --> Services
    FavoritesRepo --> FavoriteStorage
    Services --> DTOs
    DTOs --> Mappers
    Mappers --> Entities
    AppEntry --> CacheContainer
    AppEntry --> ContentView
    ContentView --> LiveDependencies
    ContentView --> AppFeature
    AppView --> Views
    LiveDependencies --> GhibliClient
    LiveDependencies --> FavoritesClient
    CacheContainer --> CacheStore
```

### Layer responsibilities

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **App** | `App/` | Composition root (`LiveDependencies`, `GhibliCacheContainer`), `ContentView`, `AppView`, app entry, `.modelContainer` |
| **Features** | `Features/` | TCA reducers (`AppFeature`, tab features, detail features), shared navigation routes |
| **Clients** | `Clients/` | `GhibliClient`, `FavoritesClient`, `LiveDependencies`, `SettingsStorage` — boundary between features and data |
| **Presentation** | `Presentation/` | SwiftUI views bound to `StoreOf<Feature>`, `LoadingState` |
| **Domain** | `Domain/` | Pure Swift entities, repository **protocols**, `DomainError` |
| **Data** | `Data/` | Repository implementations, SwiftData cache, network/local services, DTOs, mappers, `APIError` |

**Dependency rule:** Features, Presentation, and Data depend on Domain. Domain does not import Presentation, Features, or Data.

### Composition root (`LiveDependencies`)

`LiveDependencies` is the **only** place that wires concrete types into clients:

| Production (`live`) | Preview (`preview`) |
|---------------------|---------------------|
| `GhibliCacheContainer` + SwiftData | `NullGhibliCacheStore` (no disk cache) |
| `OfflineFirstGhibliRepository` → `DefaultGhibliRepository` + cache | Same stack with `MockGhibliService` |
| `DefaultFavoriteStorage` | `MockFavoriteStorage` |

`ContentView` calls `LiveDependencies.make(...)`, creates the root `Store<AppFeature>`, and passes `ghibliClient` to `AppView` for navigation destinations.

### Offline-first data flow

```mermaid
sequenceDiagram
    participant Feature as TCA Feature
    participant Client as GhibliClient
    participant OF as OfflineFirstGhibliRepository
    participant Cache as SwiftData Cache
    participant Remote as DefaultGhibliRepository
    participant API as Ghibli API

    Feature->>Client: fetchFilms() / search / fetchPeople
    Client->>OF: repository call
    OF->>Cache: load cached data
    alt cache hit
        Cache-->>OF: domain models
        OF-->>Client: return cache immediately
        Client-->>Feature: success response
        OF->>Remote: background refresh
        Remote->>API: network request
        API-->>Remote: DTOs
        Remote-->>OF: domain models
        OF->>Cache: save updated cache
    else cache miss
        OF->>Remote: fetch from network
        Remote->>API: network request
        API-->>Remote: DTOs
        Remote-->>OF: domain models
        OF->>Cache: save cache
        OF-->>Client: return fresh data
        Client-->>Feature: success response
    end
    Feature->>Feature: update observable state
```

**Policies:**

1. **Read** — return SwiftData cache when available (stale-while-revalidate).
2. **Refresh** — when cache exists, update from the API in a background `Task`.
3. **Fallback** — on network errors, return cache when possible instead of failing the screen.
4. **Search offline** — filter cached films locally when the catalog is already stored.

Favorites use **UserDefaults** via `FavoritesClient` / `FavoriteStorage` (not SwiftData). Settings use **UserDefaults** via `SettingsStorage`.

**Character loading note:** some films (e.g. *Arrietty*) return placeholder people URLs like `.../people/` instead of `.../people/{id}`. `DefaultGhibliRepository` filters those invalid collection URLs, skips per-person decode failures, and returns an empty list instead of surfacing a screen error.

### Navigation (TCA + SwiftUI)

Navigation is handled by **SwiftUI `NavigationStack`** and shared routes in `Features/Shared/FilmNavigationDestination.swift`. Views render UI; tab screens own their `NavigationStack` and push `FilmNavigationRoute` values.

```mermaid
flowchart TB
    AppView --> FilmsScreen
    AppView --> FavoritesScreen
    AppView --> SearchScreen
    AppView --> SettingsScreen

    FilmsScreen --> FilmDetailScreen
    FavoritesScreen --> FilmDetailScreen
    SearchScreen --> FilmDetailScreen

    FilmDetailScreen --> PersonDetailScreen
```

**Flows:**

1. **Film list → detail** — user taps a film in `FilmListView` → `FilmNavigationRoute.filmDetail(film)` is pushed → `filmNavigationDestinations` presents `FilmDetailScreen` with a scoped `FilmDetailFeature` store.
2. **Film detail → person detail** — user taps a character → `FilmNavigationRoute.personDetail(person)` is pushed → `personNavigationDestination` presents `PersonDetailScreen`.

**Responsibilities:**

1. **`AppFeature`** — owns shared `favoriteIDs`, coordinates tab child features, loads favorites on appear, persists favorite toggles.
2. **`AppView`** — owns the `TabView`, scopes child stores (`films`, `favorites`, `search`, `settings`), passes `ghibliClient` to data-driven tabs.
3. **`FilmNavigationRoute`** — shared route enum (`.filmDetail(Film)`, `.personDetail(Person)`).
4. **`filmNavigationDestinations`** — maps film-list routes to `FilmDetailScreen` / `PersonDetailScreen`, injects `ghibliClient`, and reads live `favoriteIDs` from the parent tab store.
5. **Views** — bind to `StoreOf<Feature>`; list screens push routes via `NavigationLink(value:)`.

#### Adding a new screen

| Step | Action | Example |
|------|--------|---------|
| 1 | Add a route case | `case personDetail(Person)` in `FilmNavigationRoute` |
| 2 | Create the feature + view | `PersonDetailFeature.swift`, `PersonDetailScreen.swift` |
| 3a | Map route → screen | `case .personDetail(let person):` in `FilmNavigationDestinationModifier` |
| 3b | Add navigation modifier (if nested) | `personNavigationDestination()` on `FilmDetailScreen` |
| 4 | Trigger navigation | `NavigationLink(value: FilmNavigationRoute.personDetail(person))` |

**Why a shared route enum and navigation modifier?**

- `FilmNavigationRoute` — **types** pushed destinations so film lists and detail screens use the same navigation contract.
- `filmNavigationDestinations(...)` — **builds** destination views (and ephemeral detail stores) when a route is active, wiring `ghibliClient` and live favorite state from the parent tab.

If you only navigate from one screen, you can use a local `navigationDestination` instead of the shared modifier.

## Project Structure

```
GhibliSwiftUIApp/
├── App/
│   ├── GhibliSwiftUIAppApp.swift      # ModelContainer + ContentView
│   ├── ContentView.swift              # root Store<AppFeature>
│   └── DI/
│       └── GhibliCacheContainer.swift
├── Clients/
│   ├── GhibliClient.swift             # fetchFilms, searchFilms, fetchPeople
│   ├── FavoritesClient.swift          # load/save favorite IDs
│   ├── LiveDependencies.swift         # live() / preview() wiring
│   └── SettingsStorage.swift          # UserDefaults persistence for settings
├── Features/
│   ├── App/                           AppFeature, AppView
│   ├── Films/                         FilmsFeature
│   ├── Favorites/                     FavoritesFeature
│   ├── Search/                        SearchFeature
│   ├── Settings/                      SettingsFeature
│   ├── FilmDetail/                    FilmDetailFeature
│   ├── PersonDetail/                  PersonDetailFeature
│   └── Shared/                        FilmNavigationDestination
├── Domain/
│   ├── Entities/                      Film, Person
│   ├── Errors/                        DomainError
│   └── Repositories/                  GhibliRepository, FavoritesRepository (protocols)
├── Data/
│   ├── DTOs/                          FilmDTO, PersonDTO
│   ├── Mappers/                       FilmMapper, PersonMapper, CacheEntityMapper, APIError+DomainError
│   ├── Network/                       GhibliService, Default/MockGhibliService
│   ├── Local/                         FavoriteStorage, Default/MockFavoriteStorage
│   ├── SwiftData/
│   │   ├── Models/                    CachedFilm, CachedPerson, CachedFilmPeople
│   │   ├── GhibliCacheStore.swift     # protocol + NullGhibliCacheStore
│   │   ├── GhibliSwiftDataStack.swift
│   │   ├── SwiftDataGhibliCacheStore.swift
│   │   └── SwiftDataGhibliCacheStoreBridge.swift
│   └── Repositories/
│       ├── DefaultGhibliRepository.swift      # network-only
│       ├── OfflineFirstGhibliRepository.swift # cache + network
│       └── DefaultFavoritesRepository.swift
├── Presentation/
│   ├── Common/                        LoadingState
│   ├── Films/                         Views (Films, FilmDetail, PersonDetail, FilmList)
│   ├── Search/
│   ├── Favorites/
│   └── Settings/
├── PreviewSupport/
├── Preview Assets/
└── Assets.xcassets/

GhibliSwiftUIAppTests/
├── Features/                          App, Films, Favorites, Search, FilmDetail, Settings
├── Repositories/                      DefaultGhibli, OfflineFirst, DefaultFavorites
├── Services/                          DefaultGhibliService
├── Mocks/                             MockClients, services, repos, cache, storage, URLProtocol
└── Support/                           TestFixtures, NetworkTestFixtures
```

## Features

- TabView with per-tab TCA stores scoped from `AppFeature`
- **Movies** — offline-first film list (cache first, background refresh, network fallback); paginated via `itemsPerPage` from Settings
- **Detail** — film info, async image loading, cached characters with network refresh; tap a character to open person detail
- **Person detail** — character profile screen pushed via `FilmNavigationRoute.personDetail`
- **Favorites** — filtered list with loading/error states; local persistence via UserDefaults
- **Search** — client-side filter with 500ms debounce (works offline when films are cached)
- **Settings** — appearance theme and preferences stored in UserDefaults via `SettingsFeature`

<p float="left">
  <img src="images/ghibli_movie_list.jpeg" width="33%" />
  <img src="/images/ghibli_movie_detail.jpeg" width="33%" />
  <img src="/images/ghibli_person_details.jpeg" width="33%" />
</p>

<p float="left">
  <img src="/images/ghibli_favorites.jpeg" width="33%" />
  <img src="/images/ghibli_search.jpeg" width="33%" />
  <img src="/images/ghibli_settings.jpeg" width="33%">
</p>

## Testing

Unit tests live in `GhibliSwiftUIAppTests/` and are split **by layer**, each mocking only its direct dependency:

| Layer | Test location | Mock boundary |
|-------|---------------|---------------|
| **Features** | `Features/` | `MockClients` via constructor injection into reducers (`TestStore`) |
| **Repositories** | `Repositories/` | Services, cache store, storage, remote repository |
| **Services** | `Services/` | `URLSession` via `MockURLProtocol` |

Shared fixtures live in `Support/TestFixtures.swift` and `Support/NetworkTestFixtures.swift`.

**Run tests:** `Cmd+U` in Xcode, or:

```bash
xcodebuild test -scheme GhibliSwiftUIApp \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -skipMacroValidation -skipPackagePluginValidation
```

`DefaultGhibliServiceTests` uses `@Suite(.serialized)` because the `URLProtocol` handler is shared static state.
