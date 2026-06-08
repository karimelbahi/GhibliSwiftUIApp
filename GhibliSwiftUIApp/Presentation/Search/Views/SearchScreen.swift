//
//  SearchScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct SearchScreen: View {

    @Bindable var store: StoreOf<SearchFeature>
    let ghibliClient: GhibliClient
    let itemsPerPage: Int

    init(
        store: StoreOf<SearchFeature>,
        ghibliClient: GhibliClient,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.ghibliClient = ghibliClient
        self.itemsPerPage = itemsPerPage
    }

    var body: some View {
        NavigationStack {
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
                        navigationRoute: { .filmDetail($0) },
                        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                    )
                }
            }
            .navigationTitle("Search Ghibli Movies")
            .searchable(text: Binding(
                get: { store.searchText },
                set: { store.send(.searchTextChanged($0)) }
            ))
            .filmNavigationDestinations(
                ghibliClient: ghibliClient,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
