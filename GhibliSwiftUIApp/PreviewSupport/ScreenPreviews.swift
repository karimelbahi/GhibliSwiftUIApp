//
//  ScreenPreviews.swift
//

import SwiftUI

#Preview("Films") {
    let dependencies = AppDependencies.preview()
    FilmsScreen(
        filmsViewModel: dependencies.filmsViewModel,
        favoritesViewModel: dependencies.favoritesViewModel,
        fetchFilmPeopleUseCase: dependencies.fetchFilmPeopleUseCase
    )
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

#Preview("Film Images") {
    FilmImageView(url: URL.convertAssetImage(named: "posterImage"))
        .frame(height: 150)
}
