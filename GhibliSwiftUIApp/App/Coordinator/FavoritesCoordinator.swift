//
//  FavoritesCoordinator.swift
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class FavoritesCoordinator: FilmNavigationCoordinating {

    public var path = NavigationPath()

    public let filmsViewModel: FilmsViewModel
    public let favoritesViewModel: FavoritesViewModel
    public let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    public init(dependencies: AppDependencies) {
        self.filmsViewModel = dependencies.filmsViewModel
        self.favoritesViewModel = dependencies.favoritesViewModel
        self.fetchFilmPeopleUseCase = dependencies.fetchFilmPeopleUseCase
    }

    @ViewBuilder
    public func start() -> some View {
        CoordinatorNavigationStack(coordinator: self) { coordinator in
            FavoritesScreen(coordinator: coordinator)
        }
    }
}
