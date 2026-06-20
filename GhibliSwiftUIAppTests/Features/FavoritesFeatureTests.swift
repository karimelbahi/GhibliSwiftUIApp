//
//  FavoritesFeatureTests.swift
//  GhibliSwiftUIAppTests
//

import ComposableArchitecture
import Foundation
import Testing
@testable import GhibliSwiftUIApp

@MainActor
struct FavoritesFeatureTests {

    @Test("Fetch loads films successfully")
    func fetchLoadsFilms() async {
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        } withDependencies: {
            $0.ghibliClient = makeMockGhibliClient()
        }

        await store.send(.onAppear) {
            $0.filmsState = .loading
        }

        await store.receive(.fetchFilmsResponse(.success(TestFixtures.films))) {
            $0.filmsState = .loaded(TestFixtures.films)
        }
    }

    @Test("Fetch sets domain error message")
    func fetchSetsDomainError() async {
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        } withDependencies: {
            $0.ghibliClient = makeMockGhibliClient(
                shouldThrowOnFetchFilms: true,
                fetchFilmsError: DomainError.networkUnavailable
            )
        }

        await store.send(.onAppear) {
            $0.filmsState = .loading
        }

        await store.receive(.fetchFilmsResponse(.failure(DomainError.networkUnavailable))) {
            $0.filmsState = .error(DomainError.networkUnavailable.userMessage)
        }
    }
}
