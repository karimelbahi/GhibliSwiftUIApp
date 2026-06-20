//
//  AppView.swift
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {

    let store: StoreOf<AppFeature>

    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(
                    store: store.scope(state: \.films, action: \.films),
                    itemsPerPage: store.settings.itemsPerPage
                )
            }

            Tab("Favorites", systemImage: "heart") {
                FavoritesScreen(
                    store: store.scope(state: \.favorites, action: \.favorites),
                    itemsPerPage: store.settings.itemsPerPage
                )
            }

            Tab("Settings", systemImage: "gear") {
                SettingsScreen(
                    store: store.scope(state: \.settings, action: \.settings)
                )
            }

            Tab(role: .search) {
                SearchScreen(
                    store: store.scope(state: \.search, action: \.search),
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
