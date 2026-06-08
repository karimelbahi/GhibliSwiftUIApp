//
//  FilmDetailFeatureTests.swift
//  GhibliSwiftUIAppTests
//

import ComposableArchitecture
import Foundation
import Testing
@testable import GhibliSwiftUIApp

@MainActor
struct FilmDetailFeatureTests {

    @Test("On appear loads people successfully")
    func onAppearLoadsPeople() async {
        let store = TestStore(
            initialState: FilmDetailFeature.State(film: TestFixtures.filmWithPeople)
        ) {
            FilmDetailFeature(ghibliClient: makeMockGhibliClient())
        }

        await store.send(.onAppear) {
            $0.peopleState = .loading
        }

        await store.receive(.fetchPeopleResponse(.success(TestFixtures.people))) {
            $0.peopleState = .loaded(TestFixtures.people)
        }
    }

    @Test("On appear sets domain error message")
    func onAppearSetsDomainError() async {
        let store = TestStore(
            initialState: FilmDetailFeature.State(film: TestFixtures.filmWithPeople)
        ) {
            FilmDetailFeature(
                ghibliClient: makeMockGhibliClient(
                    shouldThrowOnFetchPeople: true,
                    fetchPeopleError: DomainError.networkUnavailable
                )
            )
        }

        await store.send(.onAppear) {
            $0.peopleState = .loading
        }

        await store.receive(.fetchPeopleResponse(.failure(DomainError.networkUnavailable))) {
            $0.peopleState = .error(DomainError.networkUnavailable.userMessage)
        }
    }
}
