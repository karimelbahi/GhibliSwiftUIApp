//
//  ScreenPreviews.swift
//

import ComposableArchitecture
import SwiftUI

#Preview("Films") {
    let (ghibliClient, _) = LiveDependencies.makePreview()
    FilmsScreen(
        store: Store(
            initialState: FilmsFeature.State(
                filmsState: .loaded([PreviewData.totoro, PreviewData.castleInTheSky])
            )
        ) {
            FilmsFeature(ghibliClient: ghibliClient)
        },
        ghibliClient: ghibliClient
    )
}

#Preview("Film Detail") {
    let (ghibliClient, _) = LiveDependencies.makePreview()
    NavigationStack {
        FilmDetailScreen(
            store: Store(
                initialState: FilmDetailFeature.State(
                    film: PreviewData.totoro,
                    peopleState: .loaded([PreviewData.samplePerson])
                )
            ) {
                FilmDetailFeature(ghibliClient: ghibliClient)
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
                PersonDetailFeature()
            }
        )
    }
}

#Preview("Film Images") {
    FilmImageView(url: URL.convertAssetImage(named: "posterImage"))
        .frame(height: 150)
}
