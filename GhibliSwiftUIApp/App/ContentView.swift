//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {

    @State private var filmsViewModel: FilmsViewModel
    @State private var favoritesViewModel: FavoritesViewModel
    @State private var searchFilmsViewModel: SearchFilmsViewModel
    private let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    init(dependencies: AppDependencies) {
        _filmsViewModel = State(initialValue: dependencies.filmsViewModel)
        _favoritesViewModel = State(initialValue: dependencies.favoritesViewModel)
        _searchFilmsViewModel = State(initialValue: dependencies.searchFilmsViewModel)
        fetchFilmPeopleUseCase = dependencies.fetchFilmPeopleUseCase
    }

    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(
                    filmsViewModel: filmsViewModel,
                    favoritesViewModel: favoritesViewModel,
                    fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
                )
            }

            Tab("Favorites", systemImage: "heart") {
                FavoritesScreen(
                    filmsViewModel: filmsViewModel,
                    favoritesViewModel: favoritesViewModel,
                    fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
                )
            }

            Tab("Settings", systemImage: "gear") {
                SettingsScreen()
            }

            Tab(role: .search) {
                SearchScreen(
                    searchViewModel: searchFilmsViewModel,
                    favoritesViewModel: favoritesViewModel,
                    fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
                )
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
    ContentView(dependencies: .preview())
}
