//
//  DefaultFavoritesRepository.swift
//  GhibliSwiftUIApp
//

import Foundation

nonisolated
struct DefaultFavoritesRepository: FavoritesRepository {

    private let storage: FavoriteStorage

    init(storage: FavoriteStorage) {
        self.storage = storage
    }

    func load() -> Set<String> {
        storage.load()
    }

    func save(favoriteIDs: Set<String>) {
        storage.save(favoriteIDs: favoriteIDs)
    }
}
