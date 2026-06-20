//
//  FilmsScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FilmsScreen: View {

    // TCA: @Bindable store = read state + two-way bind navigation path to NavigationStack.
    @Bindable var store: StoreOf<FilmsFeature>
    let itemsPerPage: Int

    init(
        // TCA: StoreOf<FilmsFeature> = Store scoped to this feature's State and Action.
        store: StoreOf<FilmsFeature>,
        itemsPerPage: Int = 20
    ) {
        self.store = store
        self.itemsPerPage = itemsPerPage
    }

    var body: some View {
        // TCA: Two-way bind NavigationStack to state.path via scoped store binding.
        //      When path grows → push screen. When user taps Back → path shrinks.
        //      Same stack handles list → detail AND detail → person (see PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md).
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                // TCA: Read observable state from the store; UI updates when reducer changes it.
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
                        // TCA: store.send = dispatch Action into FilmsFeature reducer.
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
            // TCA: pathStore = scoped Store for ONE stack item (detail or person).
            FilmTabPathDestinationView(
                store: pathStore,
                favoriteIDs: store.favoriteIDs,
                onFavoriteTapped: { store.send(.favoriteButtonTapped($0)) }
            )
        }
    }
}
