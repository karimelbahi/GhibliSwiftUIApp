//
//  ScreenPreviews.swift
//
//  DI layer: Preview injection — each preview Store gets its own withDependencies block.
//

import ComposableArchitecture
import SwiftUI

#Preview("Films") {
    FilmsScreen(
        store: Store(
            initialState: FilmsFeature.State(
                filmsState: .loaded([PreviewData.totoro, PreviewData.castleInTheSky])
            )
        ) {
            FilmsFeature()  // DI: Reducer with @Dependency(\.ghibliClient) — must register client below.
        } withDependencies: {
            // DI: Preview factory — mock API + NullGhibliCacheStore (no SwiftData disk writes).
            let (ghibliClient, _) = LiveDependencies.makePreview()
            $0.ghibliClient = ghibliClient
        }
    )
}

#Preview("Film Detail") {
    NavigationStack {
        FilmDetailScreen(
            store: Store(
                initialState: FilmDetailFeature.State(
                    film: PreviewData.totoro,
                    peopleState: .loaded([PreviewData.samplePerson])
                )
            ) {
                FilmDetailFeature()
            } withDependencies: {
                let (ghibliClient, _) = LiveDependencies.makePreview()
                $0.ghibliClient = ghibliClient  // DI: Needed if preview triggers .onAppear / fetchPeople.
            },
            isFavorite: true,
            onFavoriteTapped: {}
        )
    }
}

#Preview("Person Detail") {
    NavigationStack {
        PersonDetailScreen(
            store: Store(
                initialState: PersonDetailFeature.State(person: PreviewData.samplePerson)
            ) {
                PersonDetailFeature()  // DI: No @Dependency — no withDependencies required.
            }
        )
    }
}

#Preview("Film Images") {
    FilmImageView(url: URL.convertAssetImage(named: "posterImage"))
        .frame(height: 150)
}
