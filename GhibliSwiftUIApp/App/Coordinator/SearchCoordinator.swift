//
//  SearchCoordinator.swift
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class SearchCoordinator: FilmNavigationCoordinating {

    public var path = NavigationPath()

    public let searchViewModel: SearchFilmsViewModel
    public let favoritesViewModel: FavoritesViewModel
    public let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    public init(dependencies: AppDependencies) {
        self.searchViewModel = dependencies.searchFilmsViewModel
        self.favoritesViewModel = dependencies.favoritesViewModel
        self.fetchFilmPeopleUseCase = dependencies.fetchFilmPeopleUseCase
    }

    @ViewBuilder
    public func start() -> some View {
        CoordinatorNavigationStack(coordinator: self) { coordinator in
            SearchScreen(coordinator: coordinator)
        }
    }
}
