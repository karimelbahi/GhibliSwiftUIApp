//
//  FilmsScreen.swift
//  GhibliSwiftUIApp
//

import SwiftUI

struct FilmsScreen: View {

    let filmsViewModel: FilmsViewModel
    let favoritesViewModel: FavoritesViewModel
    let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    var body: some View {
        NavigationStack {
            Group {
                switch filmsViewModel.state {
                case .idle:
                    Text("No Films yet")

                case .loading:
                    ProgressView {
                        Text("Loading ...")
                    }
                case .loaded(let films):
                    FilmListView(
                        films: films,
                        favoritesViewModel: favoritesViewModel,
                        fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
                    )
                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
            .navigationTitle("Ghibli Movies")
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    return FilmsScreen(
        filmsViewModel: dependencies.filmsViewModel,
        favoritesViewModel: dependencies.favoritesViewModel,
        fetchFilmPeopleUseCase: dependencies.fetchFilmPeopleUseCase
    )
}
