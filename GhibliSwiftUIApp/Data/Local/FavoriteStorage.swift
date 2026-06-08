//
//  FavoriteStorage.swift
//

import Foundation

public protocol FavoriteStorage: Sendable {
    nonisolated func load() -> Set<String>
    nonisolated func save(favoriteIDs: Set<String>)
}
