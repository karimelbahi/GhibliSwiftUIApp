//
//  DefaultFavoritesRepositoryTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct DefaultFavoritesRepositoryTests {

    private func makeRepository(storage: MockFavoriteStorage) -> DefaultFavoritesRepository {
        DefaultFavoritesRepository(storage: storage)
    }

    @MainActor
    @Test("Load delegates to storage")
    func loadDelegatesToStorage() {
        let storage = MockFavoriteStorage(storedFavorites: ["1", "2"])
        let repository = makeRepository(storage: storage)

        let favorites = repository.load()

        #expect(favorites == ["1", "2"])
        #expect(storage.loadCallCount == 1)
    }

    @MainActor
    @Test("Save delegates to storage")
    func saveDelegatesToStorage() {
        let storage = MockFavoriteStorage()
        let repository = makeRepository(storage: storage)

        repository.save(favoriteIDs: ["1", "3"])

        #expect(storage.saveCallCount == 1)
        #expect(storage.lastSavedFavorites == ["1", "3"])
        #expect(storage.storedFavorites == ["1", "3"])
    }
}
