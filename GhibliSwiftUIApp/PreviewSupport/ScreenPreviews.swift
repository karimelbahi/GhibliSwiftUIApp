//
//  ScreenPreviews.swift
//

import SwiftUI

#Preview("Films") {
    // Preview the Movies tab through its coordinator (same path as runtime app).
    FilmsCoordinator(dependencies: .preview()).start()
}

#Preview("Film Detail") {
    let dependencies = AppDependencies.preview()
    NavigationStack {
        FilmDetailScreen(
            film: PreviewData.totoro,
            favoritesViewModel: dependencies.favoritesViewModel,
            viewModel: dependencies.makeFilmDetailViewModel(preloaded: true)
        )
    }
}

#Preview("Person Detail") {
    NavigationStack {
        PersonDetailScreen(person: PreviewData.samplePerson)
    }
}

#Preview("Film Images") {
    FilmImageView(url: URL.convertAssetImage(named: "posterImage"))
        .frame(height: 150)
}
