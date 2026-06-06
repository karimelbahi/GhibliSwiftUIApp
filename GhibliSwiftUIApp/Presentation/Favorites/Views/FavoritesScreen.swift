//
//  FavoritesScreen.swift
//

import SwiftUI

public struct FavoritesScreen: View {

    let coordinator: FavoritesCoordinator

    public init(coordinator: FavoritesCoordinator) {
        self.coordinator = coordinator
    }

    private var films: [Film] {
        let favorites = coordinator.favoritesViewModel.favoriteIDs
        switch coordinator.filmsViewModel.state {
        case .loaded(let films):
            return films.filter { favorites.contains($0.id) }
        default: return []
        }
    }

    public var body: some View {
        Group {
            if films.isEmpty {
                ContentUnavailableView("No Favorites yet", systemImage: "heart")
            } else {
                FilmListView(
                    films: films,
                    coordinator: coordinator
                )
            }
        }
        .navigationTitle("Favorites")
    }
}
