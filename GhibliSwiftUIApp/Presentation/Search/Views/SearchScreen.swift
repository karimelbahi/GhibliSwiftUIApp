//
//  SearchScreen.swift
//

import SwiftUI

public struct SearchScreen: View {

    @State private var text: String = ""
    let searchViewModel: SearchFilmsViewModel
    let favoritesViewModel: FavoritesViewModel
    let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    public init(
        searchViewModel: SearchFilmsViewModel,
        favoritesViewModel: FavoritesViewModel,
        fetchFilmPeopleUseCase: FetchFilmPeopleUseCase
    ) {
        self.searchViewModel = searchViewModel
        self.favoritesViewModel = favoritesViewModel
        self.fetchFilmPeopleUseCase = fetchFilmPeopleUseCase
    }

    public var body: some View {
        NavigationStack {
            VStack {
                switch searchViewModel.state {
                case .idle:
                    Text("Your search results will be shown here.")
                        .foregroundStyle(.secondary)
                case .loading:
                    ProgressView()
                case .error(let error):
                    Text(error)
                case .loaded(let films):
                    FilmListView(
                        films: films,
                        favoritesViewModel: favoritesViewModel,
                        fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
                    )
                }
            }
            .navigationTitle("Search Ghibli Movies")
            .searchable(text: $text)
            .task(id: text) {
                await searchViewModel.fetch(for: text)
            }
        }
    }
}
