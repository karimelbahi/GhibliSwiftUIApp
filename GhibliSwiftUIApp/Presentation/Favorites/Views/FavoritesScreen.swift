//
//  FavoritesScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FavoritesScreen: View {

    @Bindable var store: StoreOf<FavoritesFeature>
    let itemsPerPage: Int

    init(
        store: StoreOf<FavoritesFeature>,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.itemsPerPage = itemsPerPage
    }

    private var favoriteFilms: [Film] {
        guard let films = store.filmsState.data else { return [] }
        return films.filter { store.favoriteIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
                            onFilmTapped: { store.send(.filmTapped($0)) },
                            onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                        )
                    }

                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
            .navigationTitle("Favorites")
        } destination: { pathStore in
            FilmTabPathDestinationView(
                store: pathStore,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
