//
//  AppView.swift
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {

    // TCA: Root store holds all app state (tabs, favorites, settings).
    let store: StoreOf<AppFeature>

    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(
                    // TCA: Scope = slice the root store down to FilmsFeature only.
                    //      Reads AppFeature.State.films, sends actions as AppFeature.Action.films(...).
                    store: store.scope(state: \.films, action: \.films),
                    itemsPerPage: store.settings.itemsPerPage
                )
            }

            Tab("Favorites", systemImage: "heart") {
                FavoritesScreen(
                    // TCA: Scope = slice root store to FavoritesFeature (own path stack).
                    //      See FAVORITES_NAVIGATION_TCA_GUIDE.md for list → detail flow.
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
                    // TCA: Scope = slice root store to SearchFeature (own path stack).
                    //      See SEARCH_NAVIGATION_TCA_GUIDE.md for results → detail flow.
                    store: store.scope(state: \.search, action: \.search),
                    itemsPerPage: store.settings.itemsPerPage
                )
            }
        }
        .task {
            // TCA: Dispatch an action into the store (starts app-level effects).
            store.send(.onAppear)
        }
        .setAppearanceTheme()
    }
}
