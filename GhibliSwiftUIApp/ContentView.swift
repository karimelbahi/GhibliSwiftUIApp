//
//  ContentView.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/6/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var filmsViewModel: FilmsViewModel
    @State private var favoritesViewModel: FavoritesViewModel
    private let searchFilmsUseCase: SearchFilmsUseCase
    
    init(filmsViewModel: FilmsViewModel = FilmsViewModel(),
         favoritesViewModel: FavoritesViewModel = FavoritesViewModel(),
         searchFilmsUseCase: SearchFilmsUseCase = DefaultSearchFilmsUseCase()) {
        _filmsViewModel = State(initialValue: filmsViewModel)
        _favoritesViewModel = State(initialValue: favoritesViewModel)
        self.searchFilmsUseCase = searchFilmsUseCase
    }
    
    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(filmsViewModel: filmsViewModel,
                            favoritesViewModel: favoritesViewModel)
            }
            
            Tab("Favorites", systemImage: "heart") {
                FavoritesScreen(filmsViewModel: filmsViewModel,
                                favoritesViewModel: favoritesViewModel)
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsScreen()
            }
            
            Tab(role: .search) {
                SearchScreen(favoritesViewModel: favoritesViewModel,
                             searchFilmsUseCase: searchFilmsUseCase)
            }
        }
        .task {
            favoritesViewModel.load()
            await filmsViewModel.fetch()
        }
        .setAppearanceTheme()
    }
}

#Preview {
    ContentView(
        filmsViewModel: .example,
        favoritesViewModel: .example,
        searchFilmsUseCase: DefaultSearchFilmsUseCase(service: MockGhibliService())
    )
}
