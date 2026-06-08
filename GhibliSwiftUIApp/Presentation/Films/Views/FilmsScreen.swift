//
//  FilmsScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FilmsScreen: View {

    @Bindable var store: StoreOf<FilmsFeature>
    let ghibliClient: GhibliClient
    let itemsPerPage: Int

    init(
        store: StoreOf<FilmsFeature>,
        ghibliClient: GhibliClient,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.ghibliClient = ghibliClient
        self.itemsPerPage = itemsPerPage
    }

    var body: some View {
        NavigationStack {
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
                        navigationRoute: { .filmDetail($0) },
                        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                    )

                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
            .navigationTitle("Ghibli Movies")
            .filmNavigationDestinations(
                ghibliClient: ghibliClient,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
