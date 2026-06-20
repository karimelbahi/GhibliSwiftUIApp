//
//  SearchFeatureTests.swift
//  GhibliSwiftUIAppTests
//

import Clocks
import ComposableArchitecture
import Foundation
import Testing
@testable import GhibliSwiftUIApp

@MainActor
struct SearchFeatureTests {

    @Test("Empty search resets to idle")
    func emptySearchResetsToIdle() async {
        let store = TestStore(
            initialState: SearchFeature.State(searchState: .loaded(TestFixtures.films))
        ) {
            SearchFeature()
        } withDependencies: {
            $0.ghibliClient = makeMockGhibliClient()
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.searchTextChanged("")) {
            $0.searchText = ""
            $0.searchState = .idle
        }
    }

    @Test("Search loads matching films")
    func searchLoadsMatchingFilms() async {
        let clientState = MockGhibliClientState()
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.ghibliClient = makeMockGhibliClient(state: clientState)
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.searchTextChanged("Totoro")) {
            $0.searchText = "Totoro"
            $0.searchState = .loading
        }

        let expectedFilms = TestFixtures.films.filter {
            $0.title.localizedCaseInsensitiveContains("Totoro")
        }

        await store.receive(.searchResponse(.success(expectedFilms), searchTerm: "Totoro")) {
            $0.searchState = .loaded(expectedFilms)
        }
    }
}
