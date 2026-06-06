//
//  MockStorage.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

final class MockFavoriteStorage: FavoriteStorage, @unchecked Sendable {

    var storedFavorites: Set<String>
    private(set) var loadCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var lastSavedFavorites: Set<String>?

    init(storedFavorites: Set<String> = []) {
        self.storedFavorites = storedFavorites
    }

    func load() -> Set<String> {
        loadCallCount += 1
        return storedFavorites
    }

    func save(favoriteIDs: Set<String>) {
        saveCallCount += 1
        lastSavedFavorites = favoriteIDs
        storedFavorites = favoriteIDs
    }
}
