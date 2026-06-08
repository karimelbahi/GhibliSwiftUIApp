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
            let filmsReducer = FilmsFeature(ghibliClient: ghibliClient)
            let favoritesReducer = FavoritesFeature(ghibliClient: ghibliClient)
            let searchReducer = SearchFeature(ghibliClient: ghibliClient)
            let settingsReducer = SettingsFeature()

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

            case let .films(filmsAction):
                if case let .favoriteButtonTapped(id) = filmsAction {
                    return .send(.toggleFavorite(id))
                }
                return filmsReducer.reduce(into: &state.films, action: filmsAction).map(Action.films)

            case let .favorites(favoritesAction):
                if case let .favoriteButtonTapped(id) = favoritesAction {
                    return .send(.toggleFavorite(id))
                }
                return favoritesReducer.reduce(into: &state.favorites, action: favoritesAction).map(Action.favorites)

            case let .search(searchAction):
                if case let .favoriteButtonTapped(id) = searchAction {
                    return .send(.toggleFavorite(id))
                }
                return searchReducer.reduce(into: &state.search, action: searchAction).map(Action.search)

            case let .settings(settingsAction):
                return settingsReducer.reduce(into: &state.settings, action: settingsAction).map(Action.settings)
            }
        }
    }

    private func syncFavoriteIDs(into state: inout State) {
        state.films.favoriteIDs = state.favoriteIDs
        state.favorites.favoriteIDs = state.favoriteIDs
        state.search.favoriteIDs = state.favoriteIDs
    }
}
