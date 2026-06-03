//
//  SearchScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/8/25.
//

import SwiftUI

struct SearchScreen: View {
    
    @State private var text: String = ""
    @State private var searchViewModel: SearchFilmsViewModel
    let favoritesViewModel: FavoritesViewModel
    
    init(favoritesViewModel: FavoritesViewModel,
         searchFilmsUseCase: SearchFilmsUseCase = DefaultSearchFilmsUseCase()) {
        self.favoritesViewModel = favoritesViewModel
        self.searchViewModel = SearchFilmsViewModel(searchFilmsUseCase: searchFilmsUseCase)
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
                        FilmListView(films: films,
                                     favoritesViewModel: favoritesViewModel)
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
    SearchScreen(
        favoritesViewModel: .example,
        searchFilmsUseCase: DefaultSearchFilmsUseCase(
            repository: DefaultGhibliRepository(service: MockGhibliService())
        )
    )
}
