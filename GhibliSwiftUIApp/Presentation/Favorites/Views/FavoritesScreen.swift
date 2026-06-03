//
//  FavoritesScreen.swift
//  GhibliSwiftUIApp
//

import SwiftUI

struct FavoritesScreen: View {

    let filmsViewModel: FilmsViewModel
    let favoritesViewModel: FavoritesViewModel
    let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    var films: [Film] {
        let favorites = favoritesViewModel.favoriteIDs
        switch filmsViewModel.state {
        case .loaded(let films):
            return films.filter { favorites.contains($0.id) }
        default: return []
        }
    }

    var body: some View {
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

#Preview {
    let dependencies = AppDependencies.preview()
    return FavoritesScreen(
        filmsViewModel: dependencies.filmsViewModel,
        favoritesViewModel: dependencies.favoritesViewModel,
        fetchFilmPeopleUseCase: dependencies.fetchFilmPeopleUseCase
    )
}
