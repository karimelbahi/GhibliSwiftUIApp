//
//  FilmTabPathDestinationView.swift
//

import ComposableArchitecture
import SwiftUI

struct FilmTabPathDestinationView: View {

    let store: StoreOf<FilmTabNavigation>
    let favoriteIDs: Set<String>
    let onFavoriteTapped: (String) -> Void

    var body: some View {
        switch store.case {
        case let .filmDetail(detailStore):
            FilmDetailScreen(
                store: detailStore,
                isFavorite: favoriteIDs.contains(detailStore.film.id),
                onFavoriteTapped: { onFavoriteTapped(detailStore.film.id) }
            )

        case let .personDetail(personStore):
            PersonDetailScreen(store: personStore)
        }
    }
}
