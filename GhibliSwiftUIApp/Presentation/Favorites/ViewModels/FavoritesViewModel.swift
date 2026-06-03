//
//  FavoritesViewModel.swift
//

import Foundation
import Observation

@MainActor
@Observable
public class FavoritesViewModel {

    public private(set) var favoriteIDs: Set<String> = []

    private let manageFavoritesUseCase: ManageFavoritesUseCase

    public init(manageFavoritesUseCase: ManageFavoritesUseCase) {
        self.manageFavoritesUseCase = manageFavoritesUseCase
    }

    public func load() {
        favoriteIDs = manageFavoritesUseCase.load()
    }

    private func save() {
        manageFavoritesUseCase.save(favoriteIDs: favoriteIDs)
    }

    public func toggleFavorite(filmID: String) {
        if favoriteIDs.contains(filmID) {
            favoriteIDs.remove(filmID)
        } else {
            favoriteIDs.insert(filmID)
        }

        save()
    }

    public func isFavorite(filmID: String) -> Bool {
        favoriteIDs.contains(filmID)
    }
}
