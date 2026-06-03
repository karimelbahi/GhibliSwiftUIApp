//
//  FavoritesScreen.swift
//

import SwiftUI

public struct FavoritesScreen: View {

    let filmsViewModel: FilmsViewModel
    let favoritesViewModel: FavoritesViewModel
    let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    public init(
        filmsViewModel: FilmsViewModel,
        favoritesViewModel: FavoritesViewModel,
        fetchFilmPeopleUseCase: FetchFilmPeopleUseCase
    ) {
        self.filmsViewModel = filmsViewModel
        self.favoritesViewModel = favoritesViewModel
        self.fetchFilmPeopleUseCase = fetchFilmPeopleUseCase
    }

    private var films: [Film] {
        let favorites = favoritesViewModel.favoriteIDs
        switch filmsViewModel.state {
        case .loaded(let films):
            return films.filter { favorites.contains($0.id) }
        default: return []
        }
    }

    public var body: some View {
        NavigationStack {
            Group {
                if films.isEmpty {
                    ContentUnavailableView("No Favorites yet", systemImage: "heart")
                } else {
                    FilmListView(
                        films: films,
                        favoritesViewModel: favoritesViewModel,
                        fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
                    )
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
