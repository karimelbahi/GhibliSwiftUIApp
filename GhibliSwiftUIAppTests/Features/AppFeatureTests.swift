//
//  AppFeatureTests.swift
//  GhibliSwiftUIAppTests
//

import ComposableArchitecture
import Foundation
import Testing
@testable import GhibliSwiftUIApp

@MainActor
struct AppFeatureTests {

    @Test("On appear loads favorite IDs")
    func onAppearLoadsFavoriteIDs() async {
        let favoritesState = MockFavoritesClientState()

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.ghibliClient = makeMockGhibliClient()
            $0.favoritesClient = makeMockFavoritesClient(
                initialFavoriteIDs: ["film-1"],
                state: favoritesState
            )
        }
        store.exhaustivity = .off

        await store.send(.onAppear)

        await store.receive(.favoriteIDsLoaded(["film-1"])) {
            $0.favoriteIDs = ["film-1"]
            $0.films.favoriteIDs = ["film-1"]
            $0.favorites.favoriteIDs = ["film-1"]
            $0.search.favoriteIDs = ["film-1"]
        }
    }

    @Test("Toggle favorite updates all tabs and persists")
    func toggleFavoriteUpdatesAllTabs() async {
        let favoritesState = MockFavoritesClientState()

        let store = TestStore(
            initialState: AppFeature.State(favoriteIDs: [])
        ) {
            AppFeature()
        } withDependencies: {
            $0.ghibliClient = makeMockGhibliClient()
            $0.favoritesClient = makeMockFavoritesClient(state: favoritesState)
        }

        await store.send(.toggleFavorite("film-1")) {
            $0.favoriteIDs = ["film-1"]
            $0.films.favoriteIDs = ["film-1"]
            $0.favorites.favoriteIDs = ["film-1"]
            $0.search.favoriteIDs = ["film-1"]
        }

        #expect(favoritesState.savedFavoriteIDs == ["film-1"])
    }
}
