//
//  SearchScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct SearchScreen: View {

    @Bindable var store: StoreOf<SearchFeature>
    let itemsPerPage: Int

    init(
        store: StoreOf<SearchFeature>,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.itemsPerPage = itemsPerPage
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                switch store.searchState {
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
                        favoriteIDs: store.favoriteIDs,
                        itemsPerPage: itemsPerPage,
                        onFilmTapped: { store.send(.filmTapped($0)) },
                        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                    )
                }
            }
            .navigationTitle("Search Ghibli Movies")
            .searchable(text: Binding(
                get: { store.searchText },
                set: { store.send(.searchTextChanged($0)) }
            ))
        } destination: { pathStore in
            FilmTabPathDestinationView(
                store: pathStore,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
