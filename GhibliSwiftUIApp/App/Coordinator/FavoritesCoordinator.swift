//
//  FavoritesCoordinator.swift
//

import Observation
import SwiftUI

// Coordinator for Favorites tab.
//
// @MainActor: UI-thread-only coordinator (navigation + view building).
// @Observable: publishes `path` changes to SwiftUI for stack push/pop updates.
@MainActor
@Observable
public final class FavoritesCoordinator: FilmNavigationCoordinating {

    // Navigation stack for Favorites tab (independent from Movies/Search tabs).
    public var path = NavigationPath()

    // Needed to filter all films down to only favorited ones.
    public let filmsViewModel: FilmsViewModel
    // Favorite IDs and toggle behavior.
    public let favoritesViewModel: FavoritesViewModel
    // Needed to build FilmDetailScreen when a favorite is tapped.
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
