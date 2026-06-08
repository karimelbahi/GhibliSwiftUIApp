//
//  FavoritesScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FavoritesScreen: View {

    @Bindable var store: StoreOf<FavoritesFeature>
    let ghibliClient: GhibliClient
    let itemsPerPage: Int

    init(
        store: StoreOf<FavoritesFeature>,
        ghibliClient: GhibliClient,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.ghibliClient = ghibliClient
        self.itemsPerPage = itemsPerPage
    }

    private var favoriteFilms: [Film] {
        guard let films = store.filmsState.data else { return [] }
        return films.filter { store.favoriteIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch store.filmsState {
                case .idle:
                    Text("No favorites loaded yet")

                case .loading:
                    ProgressView {
                        Text("Loading favorites...")
                    }

                case .loaded:
                    if favoriteFilms.isEmpty {
                        ContentUnavailableView("No Favorites yet", systemImage: "heart")
                    } else {
                        FilmListView(
                            films: favoriteFilms,
                            favoriteIDs: store.favoriteIDs,
                            itemsPerPage: itemsPerPage,
                            navigationRoute: { .filmDetail($0) },
                            onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                        )
                    }

                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
            .navigationTitle("Favorites")
            .filmNavigationDestinations(
                ghibliClient: ghibliClient,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
