//
//  FavoritesScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FavoritesScreen: View {

    // TCA: @Bindable store = read state + two-way bind this tab's navigation path.
    @Bindable var store: StoreOf<FavoritesFeature>
    let itemsPerPage: Int

    init(
        // TCA: StoreOf<FavoritesFeature> = Store scoped to this tab's State and Action.
        store: StoreOf<FavoritesFeature>,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.itemsPerPage = itemsPerPage
    }

    // View-only: filter loaded films to favorites (synced from AppFeature via favoriteIDs).
    private var favoriteFilms: [Film] {
        guard let films = store.filmsState.data else { return [] }
        return films.filter { store.favoriteIDs.contains($0.id) }
    }

    var body: some View {
        // TCA: Two-way bind NavigationStack to FavoritesFeature.State.path (this tab's own stack).
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
                            // TCA: store.send = dispatch Action into FavoritesFeature reducer.
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
            // TCA: Shared destination — same FilmTabPathDestinationView as Movies/Search tabs.
            FilmTabPathDestinationView(
                store: pathStore,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
