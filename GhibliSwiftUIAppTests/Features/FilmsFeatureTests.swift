//
//  FilmsFeatureTests.swift
//  GhibliSwiftUIAppTests
//

import ComposableArchitecture
import Foundation
import Testing
@testable import GhibliSwiftUIApp

@MainActor
struct FilmsFeatureTests {

    @Test func initialStateIsIdle() async {
        let store = TestStore(initialState: FilmsFeature.State()) {
            FilmsFeature(ghibliClient: makeMockGhibliClient())
        }

        #expect(store.state.filmsState == .idle)
    }

    @Test("Fetch loads films successfully")
    func fetchLoadsFilms() async {
        let clientState = MockGhibliClientState()
        let store = TestStore(initialState: FilmsFeature.State()) {
            FilmsFeature(ghibliClient: makeMockGhibliClient(state: clientState))
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
        let store = TestStore(initialState: FilmsFeature.State()) {
            FilmsFeature(
                ghibliClient: makeMockGhibliClient(
                    shouldThrowOnFetchFilms: true,
                    fetchFilmsError: DomainError.networkUnavailable
                )
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
