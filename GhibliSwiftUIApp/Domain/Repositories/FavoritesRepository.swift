//
//  FavoritesRepository.swift
//

import Foundation

public protocol FavoritesRepository: Sendable {
    nonisolated func load() -> Set<String>
    nonisolated func save(favoriteIDs: Set<String>)
}
