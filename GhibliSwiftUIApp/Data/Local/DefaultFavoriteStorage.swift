//
//  DefaultFavoriteStorage.swift
//

import Foundation

nonisolated
public struct DefaultFavoriteStorage: FavoriteStorage {

    private let favoritesKey = "GhibliExplorer.FavoriteFilms"

    public init() {}

    public func load() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        return Set(array)
    }

    public func save(favoriteIDs: Set<String>) {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }
}
