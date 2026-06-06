//
//  SearchCoordinator.swift
//

import Observation
import SwiftUI

// Coordinator for Search tab.
//
// @MainActor: all navigation/UI work stays on main actor.
// @Observable: enables @Bindable coordinator binding in CoordinatorNavigationStack.
@MainActor
@Observable
public final class SearchCoordinator: FilmNavigationCoordinating {

    // Navigation stack for Search tab.
    public var path = NavigationPath()

    // Search state (idle/loading/loaded/error).
    public let searchViewModel: SearchFilmsViewModel
    // Shared favorites state for rows/detail.
    public let favoritesViewModel: FavoritesViewModel
    // Needed to build FilmDetailScreen from search results.
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
