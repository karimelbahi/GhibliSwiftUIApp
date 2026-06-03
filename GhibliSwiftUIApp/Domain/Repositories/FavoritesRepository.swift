//
//  FavoritesRepository.swift
//

import Foundation

public protocol FavoritesRepository {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}
