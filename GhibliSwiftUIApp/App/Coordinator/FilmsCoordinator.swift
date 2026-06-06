//
//  FilmsCoordinator.swift
//

import Observation
import SwiftUI

// Coordinator for Movies tab: owns navigation path + dependencies for that flow.
//
// @MainActor
// - Keeps navigation changes (`path.append`, push/pop) on the UI thread.
// - Matches ViewModels and SwiftUI view lifecycle expectations.
//
// @Observable
// - Makes `path` changes observable so NavigationStack(path: $coordinator.path) updates.
// - Without this, pushing FilmCoordinatorRoute would not refresh the UI reliably.
@MainActor
@Observable
public final class FilmsCoordinator: FilmNavigationCoordinating {

    // Current pushed screens in Movies tab (empty = only list visible).
    public var path = NavigationPath()

    // Data/state for list screen.
    public let filmsViewModel: FilmsViewModel
    // Shared favorites state used in list rows and detail toolbar.
    public let favoritesViewModel: FavoritesViewModel
    // Used when building FilmDetailScreen destination.
    public let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    // Pull dependencies once from AppDependencies.
    public init(dependencies: AppDependencies) {
        self.filmsViewModel = dependencies.filmsViewModel
        self.favoritesViewModel = dependencies.favoritesViewModel
        self.fetchFilmPeopleUseCase = dependencies.fetchFilmPeopleUseCase
    }

    // Returns the full Movies tab UI (NavigationStack + FilmsScreen + destinations).
    @ViewBuilder
    public func start() -> some View {
        CoordinatorNavigationStack(coordinator: self) { coordinator in
            // Root screen for this tab.
            FilmsScreen(coordinator: coordinator)
        }
    }
}
