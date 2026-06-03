//
//  ManageFavoritesUseCase.swift
//

import Foundation

public protocol ManageFavoritesUseCase {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}

nonisolated
public struct DefaultManageFavoritesUseCase: ManageFavoritesUseCase {

    private let repository: FavoritesRepository

    public init(repository: FavoritesRepository) {
        self.repository = repository
    }

    public func load() -> Set<String> {
        repository.load()
    }

    public func save(favoriteIDs: Set<String>) {
        repository.save(favoriteIDs: favoriteIDs)
    }
}
