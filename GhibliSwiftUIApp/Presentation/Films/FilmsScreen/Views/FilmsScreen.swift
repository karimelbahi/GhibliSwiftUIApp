//
//  FilmsScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FilmsScreen: View {

    @Bindable var store: StoreOf<FilmsFeature>
    let itemsPerPage: Int

    init(
        store: StoreOf<FilmsFeature>,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.itemsPerPage = itemsPerPage
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                switch store.filmsState {
                case .idle:
                    Text("No Films yet")

                case .loading:
                    ProgressView {
                        Text("Loading ...")
                    }

                case .loaded(let films):
                    FilmListView(
                        films: films,
                        favoriteIDs: store.favoriteIDs,
                        itemsPerPage: itemsPerPage,
                        onFilmTapped: { store.send(.filmTapped($0)) },
                        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                    )

                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
            .navigationTitle("Ghibli Movies")
        } destination: { pathStore in
            FilmTabPathDestinationView(
                store: pathStore,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
