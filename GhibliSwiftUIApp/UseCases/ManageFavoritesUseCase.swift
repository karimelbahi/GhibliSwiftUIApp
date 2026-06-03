//
//  ManageFavoritesUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol ManageFavoritesUseCase {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}

struct DefaultManageFavoritesUseCase: ManageFavoritesUseCase {

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
