//
//  MockClients.swift
//  GhibliSwiftUIAppTests
//
//  DI layer: Test doubles — build fake GhibliClient / FavoritesClient for TestStore.withDependencies.
//

import Foundation
@testable import GhibliSwiftUIApp

// DI: Tracks how many times mock client methods were called (for assertions in tests).
final class MockGhibliClientState: @unchecked Sendable {
    private let lock = NSLock()
    var fetchFilmsCallCount = 0
    var searchFilmsCallCount = 0
    var fetchPeopleCallCount = 0
    var lastSearchTerm: String?

    func incrementFetchFilms() {
        lock.withLock { fetchFilmsCallCount += 1 }
    }

    func incrementSearchFilms(term: String) {
        lock.withLock {
            searchFilmsCallCount += 1
            lastSearchTerm = term
        }
    }

    func incrementFetchPeople() {
        lock.withLock { fetchPeopleCallCount += 1 }
    }

    func fetchFilmsCount() -> Int {
        lock.withLock { fetchFilmsCallCount }
    }
}

// DI: Returns a GhibliClient with fake closures — assign to $0.ghibliClient in TestStore.withDependencies.
func makeMockGhibliClient(
    mockFilms: [Film] = TestFixtures.films,
    mockPeople: [Person] = TestFixtures.people,
    shouldThrowOnFetchFilms: Bool = false,
    shouldThrowOnSearch: Bool = false,
    shouldThrowOnFetchPeople: Bool = false,
    fetchFilmsError: Error = DomainError.networkUnavailable,
    searchError: Error = DomainError.networkUnavailable,
    fetchPeopleError: Error = DomainError.networkUnavailable,
    fetchFilmsDelay: Duration = .zero,
    searchDelay: Duration = .zero,
    failuresBeforeSuccess: Int = 0,
    state: MockGhibliClientState = MockGhibliClientState()
) -> GhibliClient {
    // DI: Same struct type as production — reducers cannot tell mock from live client.
    GhibliClient(
        fetchFilms: {
            state.incrementFetchFilms()
            if fetchFilmsDelay > .zero {
                try await Task.sleep(for: fetchFilmsDelay)
            }
            if state.fetchFilmsCount() <= failuresBeforeSuccess || shouldThrowOnFetchFilms {
                throw fetchFilmsError
            }
            return mockFilms
        },
        searchFilms: { searchTerm in
            state.incrementSearchFilms(term: searchTerm)
            if searchDelay > .zero {
                try await Task.sleep(for: searchDelay)
            }
            if shouldThrowOnSearch {
                throw searchError
            }
            try Task.checkCancellation()
            return mockFilms.filter {
                $0.title.localizedCaseInsensitiveContains(searchTerm)
            }
        },
        fetchPeople: { _ in
            state.incrementFetchPeople()
            if shouldThrowOnFetchPeople {
                throw fetchPeopleError
            }
            return mockPeople
        }
    )
}

// DI: Tracks save/load calls for favorites persistence tests.
final class MockFavoritesClientState: @unchecked Sendable {
    private let lock = NSLock()
    var savedFavoriteIDs: Set<String> = []
    var loadCallCount = 0
    var saveCallCount = 0

    func recordLoad(initialFavoriteIDs: Set<String>) -> Set<String> {
        lock.withLock {
            loadCallCount += 1
            return savedFavoriteIDs.isEmpty ? initialFavoriteIDs : savedFavoriteIDs
        }
    }

    func recordSave(_ ids: Set<String>) {
        lock.withLock {
            saveCallCount += 1
            savedFavoriteIDs = ids
        }
    }
}

// DI: Returns fake FavoritesClient — assign to $0.favoritesClient in TestStore.withDependencies.
func makeMockFavoritesClient(
    initialFavoriteIDs: Set<String> = [],
    state: MockFavoritesClientState = MockFavoritesClientState()
) -> FavoritesClient {
    FavoritesClient(
        loadFavoriteIDs: {
            state.recordLoad(initialFavoriteIDs: initialFavoriteIDs)
        },
        saveFavoriteIDs: { ids in
            state.recordSave(ids)
        }
    )
}
