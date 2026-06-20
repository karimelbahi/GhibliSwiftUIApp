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

    let ghibliClient: GhibliClient
    let favoritesClient: FavoritesClient

    init(ghibliClient: GhibliClient, favoritesClient: FavoritesClient) {
        self.ghibliClient = ghibliClient
        self.favoritesClient = favoritesClient
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.settings = SettingsStorage.load()
                return .merge(
                    .run { [favoritesClient] send in
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
                return .run { [favoritesClient] _ in
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
            FilmsFeature(ghibliClient: ghibliClient)
        }
        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature(ghibliClient: ghibliClient)
        }
        Scope(state: \.search, action: \.search) {
            SearchFeature(ghibliClient: ghibliClient)
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
    }

    private func syncFavoriteIDs(into state: inout State) {
        state.films.favoriteIDs = state.favoriteIDs
        state.favorites.favoriteIDs = state.favoriteIDs
        state.search.favoriteIDs = state.favoriteIDs
    }
}
