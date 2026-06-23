//
//  AppFeature.swift
//

import ComposableArchitecture
import Foundation

struct AppFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var favoriteIDs: Set<String> = []
        var films = FilmsFeature.State()
        var favorites = FavoritesFeature.State()
        var search = SearchFeature.State()
        var settings = SettingsFeature.State()
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case favoriteIDsLoaded(Set<String>)
        case toggleFavorite(String)
        case films(FilmsFeature.Action)
        case favorites(FavoritesFeature.Action)
        case search(SearchFeature.Action)
        case settings(SettingsFeature.Action)
    }

    // DI: Read FavoritesClient from Store's DependencyValues (registered in ContentView.withDependencies).
    @Dependency(\.favoritesClient) var favoritesClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // DI: SettingsStorage is NOT @Dependency — direct static UserDefaults access.
                state.settings = SettingsStorage.load()
                return .merge(
                    // DI: Effect uses favoritesClient from @Dependency (load persisted favorite IDs).
                    .run { send in
                        await send(.favoriteIDsLoaded(favoritesClient.loadFavoriteIDs()))
                    },
                    .send(.settings(.onAppear))
                )

            case let .favoriteIDsLoaded(ids):
                state.favoriteIDs = ids
                syncFavoriteIDs(into: &state)
                return .merge(
                    .send(.films(.onAppear)),
                    .send(.favorites(.onAppear))
                )

            case let .toggleFavorite(id):
                if state.favoriteIDs.contains(id) {
                    state.favoriteIDs.remove(id)
                } else {
                    state.favoriteIDs.insert(id)
                }
                syncFavoriteIDs(into: &state)
                let favoriteIDs = state.favoriteIDs
                // DI: Side effect persists to UserDefaults via FavoritesClient (no reducer state change after).
                return .run { _ in
                    favoritesClient.saveFavoriteIDs(favoriteIDs)
                }

            case let .films(.favoriteButtonTapped(id)),
                 let .favorites(.favoriteButtonTapped(id)),
                 let .search(.favoriteButtonTapped(id)):
                return .send(.toggleFavorite(id))

            case .films, .favorites, .search, .settings:
                return .none
            }
        }
        Scope(state: \.films, action: \.films) {
            FilmsFeature()  // DI: Child inherits ghibliClient + favoritesClient from parent Store context.
        }
        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()  // DI: Same inherited DependencyValues — no client passed in init.
        }
        Scope(state: \.search, action: \.search) {
            SearchFeature()  // DI: Also inherits continuousClock default unless overridden in tests.
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()  // DI: No @Dependency — uses SettingsStorage static methods.
        }
    }

    private func syncFavoriteIDs(into state: inout State) {
        state.films.favoriteIDs = state.favoriteIDs
        state.favorites.favoriteIDs = state.favoriteIDs
        state.search.favoriteIDs = state.favoriteIDs
    }
}
