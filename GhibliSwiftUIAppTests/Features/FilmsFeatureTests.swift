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

    @Test("Film tapped appends detail to navigation path")
    func filmTappedAppendsDetailToPath() async {
        let film = TestFixtures.films[0]
        let store = TestStore(
            initialState: FilmsFeature.State(filmsState: .loaded(TestFixtures.films))
        ) {
            FilmsFeature(ghibliClient: makeMockGhibliClient())
        }

        await store.send(.filmTapped(film)) {
            $0.path.append(.filmDetail(FilmDetailFeature.State(film: film)))
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
