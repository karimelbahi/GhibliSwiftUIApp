//
//  DefaultFavoritesRepository.swift
//

import Foundation

nonisolated
public struct DefaultFavoritesRepository: FavoritesRepository {

    private let storage: FavoriteStorage

    public init(storage: FavoriteStorage) {
        self.storage = storage
    }

    public nonisolated func load() -> Set<String> {
        storage.load()
    }

    public nonisolated func save(favoriteIDs: Set<String>) {
        storage.save(favoriteIDs: favoriteIDs)
    }
}
