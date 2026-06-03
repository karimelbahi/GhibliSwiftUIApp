//
//  FavoritesRepository.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FavoritesRepository {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}

nonisolated
struct DefaultFavoritesRepository: FavoritesRepository {

    private let storage: FavoriteStorage

    init(storage: FavoriteStorage = DefaultFavoriteStorage()) {
        self.storage = storage
    }

    func load() -> Set<String> {
        storage.load()
    }

    func save(favoriteIDs: Set<String>) {
        storage.save(favoriteIDs: favoriteIDs)
    }
}
