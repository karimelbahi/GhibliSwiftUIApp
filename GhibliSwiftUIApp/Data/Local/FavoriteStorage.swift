//
//  FavoriteStorage.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FavoriteStorage {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}
