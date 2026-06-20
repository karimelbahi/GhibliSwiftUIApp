//
//  ScreenPreviews.swift
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
            FilmsFeature()
        } withDependencies: {
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
                $0.ghibliClient = ghibliClient
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
