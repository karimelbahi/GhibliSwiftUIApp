//
//  SearchScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct SearchScreen: View {

    // TCA: @Bindable store = read state + two-way bind this tab's navigation path.
    @Bindable var store: StoreOf<SearchFeature>
    let itemsPerPage: Int

    init(
        // TCA: StoreOf<SearchFeature> = Store scoped to this tab's State and Action.
        store: StoreOf<SearchFeature>,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.itemsPerPage = itemsPerPage
    }

    var body: some View {
        // TCA: Two-way bind NavigationStack to SearchFeature.State.path (this tab's own stack).
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
                        // TCA: store.send = dispatch Action into SearchFeature reducer.
                        onFilmTapped: { store.send(.filmTapped($0)) },
                        onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
                    )
                }
            }
            .navigationTitle("Search Ghibli Movies")
            // TCA: Manual Binding — typing sends .searchTextChanged (debounced .run in reducer).
            .searchable(text: Binding(
                get: { store.searchText },
                set: { store.send(.searchTextChanged($0)) }
            ))
        } destination: { pathStore in
            // TCA: Shared destination — same FilmTabPathDestinationView as Movies/Favorites tabs.
            FilmTabPathDestinationView(
                store: pathStore,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
