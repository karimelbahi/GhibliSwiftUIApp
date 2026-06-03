//
//  SearchScreen.swift
//  GhibliSwiftUIApp
//

import SwiftUI

struct SearchScreen: View {

    @State private var text: String = ""
    @State private var searchViewModel: SearchFilmsViewModel
    let favoritesViewModel: FavoritesViewModel
    let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    init(searchViewModel: SearchFilmsViewModel,
         favoritesViewModel: FavoritesViewModel,
         fetchFilmPeopleUseCase: FetchFilmPeopleUseCase) {
        _searchViewModel = State(initialValue: searchViewModel)
        self.favoritesViewModel = favoritesViewModel
        self.fetchFilmPeopleUseCase = fetchFilmPeopleUseCase
    }

    var body: some View {
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

#Preview {
    let dependencies = AppDependencies.preview()
    return SearchScreen(
        searchViewModel: dependencies.searchFilmsViewModel,
        favoritesViewModel: dependencies.favoritesViewModel,
        fetchFilmPeopleUseCase: dependencies.fetchFilmPeopleUseCase
    )
}
