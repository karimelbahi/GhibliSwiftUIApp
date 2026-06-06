//
//  AppCoordinator.swift
//

import Observation
import SwiftUI

// Top-level coordinator: owns app navigation structure (tabs), not individual pushes.
//
// @MainActor
// - Pins this class to the main (UI) thread.
// - Coordinators create SwiftUI views and trigger navigation updates.
// - UIKit/SwiftUI must be updated on the main thread, so this avoids race conditions.
//
// @Observable
// - Observation macro (iOS 17+) that tracks property changes automatically.
// - If a coordinator property changes, SwiftUI views that read it re-render.
// - Works with @Bindable in child views (e.g. CoordinatorNavigationStack).
// - Replaces older ObservableObject + @Published + @ObservedObject.
@MainActor
@Observable
public final class AppCoordinator {

    // Child coordinator for Movies tab.
    public let filmsCoordinator: FilmsCoordinator
    // Child coordinator for Favorites tab.
    public let favoritesCoordinator: FavoritesCoordinator
    // Child coordinator for Search tab.
    public let searchCoordinator: SearchCoordinator
    // Child coordinator for Settings tab.
    public let settingsCoordinator: SettingsCoordinator

    // Build all coordinators from the composition root dependencies.
    public init(dependencies: AppDependencies) {
        self.filmsCoordinator = FilmsCoordinator(dependencies: dependencies)
        self.favoritesCoordinator = FavoritesCoordinator(dependencies: dependencies)
        self.searchCoordinator = SearchCoordinator(dependencies: dependencies)
        self.settingsCoordinator = SettingsCoordinator()
    }

    // Entry UI for the whole app.
    @ViewBuilder
    public var rootView: some View {
        TabView {
            // Each tab asks its coordinator for the tab root view.
            Tab("Movies", systemImage: "movieclapper") {
                filmsCoordinator.start()
            }

            Tab("Favorites", systemImage: "heart") {
                favoritesCoordinator.start()
            }

            Tab("Settings", systemImage: "gear") {
                settingsCoordinator.start()
            }

            Tab(role: .search) {
                searchCoordinator.start()
            }
        }
        // App-level startup work (not screen-specific UI logic).
        .task {
            self.favoritesCoordinator.favoritesViewModel.load()
            await self.filmsCoordinator.filmsViewModel.fetch()
        }
        .setAppearanceTheme()
    }
}
