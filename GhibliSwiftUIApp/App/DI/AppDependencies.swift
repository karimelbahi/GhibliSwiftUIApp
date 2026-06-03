//
//  AppDependencies.swift
//

import Foundation
import GhibliDomain
import GhibliData
import GhibliPresentation

public struct AppDependencies {
    public let filmsViewModel: FilmsViewModel
    public let favoritesViewModel: FavoritesViewModel
    public let searchFilmsViewModel: SearchFilmsViewModel
    public let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    public static func live() -> AppDependencies {
        let ghibliRepository = DefaultGhibliRepository(service: DefaultGhibliService())
        let favoritesRepository = DefaultFavoritesRepository(storage: DefaultFavoriteStorage())

        let fetchFilmsUseCase = DefaultFetchFilmsUseCase(repository: ghibliRepository)
        let searchFilmsUseCase = DefaultSearchFilmsUseCase(repository: ghibliRepository)
        let fetchFilmPeopleUseCase = DefaultFetchFilmPeopleUseCase(repository: ghibliRepository)
        let manageFavoritesUseCase = DefaultManageFavoritesUseCase(repository: favoritesRepository)

        return AppDependencies(
            filmsViewModel: FilmsViewModel(fetchFilmsUseCase: fetchFilmsUseCase),
            favoritesViewModel: FavoritesViewModel(manageFavoritesUseCase: manageFavoritesUseCase),
            searchFilmsViewModel: SearchFilmsViewModel(searchFilmsUseCase: searchFilmsUseCase),
            fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
        )
    }

    #if DEBUG
    @MainActor
    public static func preview() -> AppDependencies {
        let ghibliRepository = DefaultGhibliRepository(service: MockGhibliService())
        let favoritesRepository = DefaultFavoritesRepository(storage: MockFavoriteStorage())

        let fetchFilmsUseCase = DefaultFetchFilmsUseCase(repository: ghibliRepository)
        let searchFilmsUseCase = DefaultSearchFilmsUseCase(repository: ghibliRepository)
        let fetchFilmPeopleUseCase = DefaultFetchFilmPeopleUseCase(repository: ghibliRepository)
        let manageFavoritesUseCase = DefaultManageFavoritesUseCase(repository: favoritesRepository)

        let filmsViewModel = FilmsViewModel(fetchFilmsUseCase: fetchFilmsUseCase)
        filmsViewModel.state = .loaded([PreviewData.totoro, PreviewData.castleInTheSky])

        let favoritesViewModel = FavoritesViewModel(manageFavoritesUseCase: manageFavoritesUseCase)
        favoritesViewModel.load()

        let searchFilmsViewModel = SearchFilmsViewModel(searchFilmsUseCase: searchFilmsUseCase)

        return AppDependencies(
            filmsViewModel: filmsViewModel,
            favoritesViewModel: favoritesViewModel,
            searchFilmsViewModel: searchFilmsViewModel,
            fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
        )
    }

    @MainActor
    public func makeFilmDetailViewModel(preloaded: Bool = false) -> FilmDetailViewModel {
        let viewModel = FilmDetailViewModel(fetchFilmPeopleUseCase: fetchFilmPeopleUseCase)
        if preloaded {
            viewModel.state = .loaded([PreviewData.samplePerson])
        }
        return viewModel
    }
    #endif
}
