//
//  FavoriteStorage.swift
//

import Foundation

public protocol FavoriteStorage {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}
