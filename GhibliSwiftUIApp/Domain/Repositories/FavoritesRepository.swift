//
//  FavoritesRepository.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FavoritesRepository {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}
