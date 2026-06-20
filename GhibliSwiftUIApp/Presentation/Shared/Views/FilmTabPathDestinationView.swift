//
//  FilmTabPathDestinationView.swift
//

import ComposableArchitecture
import SwiftUI

struct FilmTabPathDestinationView: View {

    // TCA: Store scoped to one navigation stack item (FilmTabNavigation.State).
    let store: StoreOf<FilmTabNavigation>
    let favoriteIDs: Set<String>
    let onFavoriteTapped: (String) -> Void

    var body: some View {
        // TCA: switch store.case = match enum path state and get a child Store for that case.
        switch store.case {
        case let .filmDetail(detailStore):
            // TCA: detailStore = StoreOf<FilmDetailFeature> for this stack entry only.
            FilmDetailScreen(
                store: detailStore,
                isFavorite: favoriteIDs.contains(detailStore.film.id),
                onFavoriteTapped: { onFavoriteTapped(detailStore.film.id) }
            )

        case let .personDetail(personStore):
            // TCA: personStore = StoreOf<PersonDetailFeature> — pushed after .personTapped bubbles up.
            PersonDetailScreen(store: personStore)
        }
    }
}
