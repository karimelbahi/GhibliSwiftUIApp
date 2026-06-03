//
//  FavoritesViewModel.swift
//  GhibliSwiftUIApp
//

import Foundation
import Observation

@Observable
class FavoritesViewModel {

    private(set) var favoriteIDs: Set<String> = []

    private let manageFavoritesUseCase: ManageFavoritesUseCase

    init(manageFavoritesUseCase: ManageFavoritesUseCase) {
        self.manageFavoritesUseCase = manageFavoritesUseCase
    }

    func load() {
        favoriteIDs = manageFavoritesUseCase.load()
    }

    private func save() {
        manageFavoritesUseCase.save(favoriteIDs: favoriteIDs)
    }

    func toggleFavorite(filmID: String) {
        if favoriteIDs.contains(filmID) {
            favoriteIDs.remove(filmID)
        } else {
            favoriteIDs.insert(filmID)
        }

        save()
    }

    func isFavorite(filmID: String) -> Bool {
        favoriteIDs.contains(filmID)
    }
}
