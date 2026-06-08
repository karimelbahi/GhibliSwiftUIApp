//
//  AppView.swift
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {

    let store: StoreOf<AppFeature>
    let ghibliClient: GhibliClient

    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(
                    store: store.scope(
                        state: \.films,
                        action: { .films($0) }
                    ),
                    ghibliClient: ghibliClient,
                    itemsPerPage: store.settings.itemsPerPage
                )
            }

            Tab("Favorites", systemImage: "heart") {
                FavoritesScreen(
                    store: store.scope(
                        state: \.favorites,
                        action: { .favorites($0) }
                    ),
                    ghibliClient: ghibliClient,
                    itemsPerPage: store.settings.itemsPerPage
                )
            }

            Tab("Settings", systemImage: "gear") {
                SettingsScreen(
                    store: store.scope(
                        state: \.settings,
                        action: { .settings($0) }
                    )
                )
            }

            Tab(role: .search) {
                SearchScreen(
                    store: store.scope(
                        state: \.search,
                        action: { .search($0) }
                    ),
                    ghibliClient: ghibliClient,
                    itemsPerPage: store.settings.itemsPerPage
                )
            }
        }
        .task {
            store.send(.onAppear)
        }
        .setAppearanceTheme()
    }
}
