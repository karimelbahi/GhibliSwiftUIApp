//
//  ManageFavoritesUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol ManageFavoritesUseCase {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}

nonisolated
struct DefaultManageFavoritesUseCase: ManageFavoritesUseCase {

    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func load() -> Set<String> {
        repository.load()
    }

    func save(favoriteIDs: Set<String>) {
        repository.save(favoriteIDs: favoriteIDs)
    }
}
