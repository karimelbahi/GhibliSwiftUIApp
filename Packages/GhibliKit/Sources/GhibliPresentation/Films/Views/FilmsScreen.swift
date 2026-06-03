//
//  FilmsScreen.swift
//

import SwiftUI
import GhibliDomain

public struct FilmsScreen: View {

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

    public var body: some View {
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
