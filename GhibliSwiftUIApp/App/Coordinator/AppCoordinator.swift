//
//  AppCoordinator.swift
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class AppCoordinator {

    public let filmsCoordinator: FilmsCoordinator
    public let favoritesCoordinator: FavoritesCoordinator
    public let searchCoordinator: SearchCoordinator
    public let settingsCoordinator: SettingsCoordinator

    public init(dependencies: AppDependencies) {
        self.filmsCoordinator = FilmsCoordinator(dependencies: dependencies)
        self.favoritesCoordinator = FavoritesCoordinator(dependencies: dependencies)
        self.searchCoordinator = SearchCoordinator(dependencies: dependencies)
        self.settingsCoordinator = SettingsCoordinator()
    }

    @ViewBuilder
    public var rootView: some View {
        TabView {
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
        .task {
            self.favoritesCoordinator.favoritesViewModel.load()
            await self.filmsCoordinator.filmsViewModel.fetch()
        }
        .setAppearanceTheme()
    }
}
