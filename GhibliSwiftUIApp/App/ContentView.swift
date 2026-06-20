//
//  ContentView.swift
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {

    let store: StoreOf<AppFeature>

    init(
        cacheContainer: GhibliCacheContainer,
        useMockService: Bool = false
    ) {
        let (ghibliClient, favoritesClient) = LiveDependencies.make(
            cacheContainer: cacheContainer,
            useMockService: useMockService
        )
        store = Store(initialState: AppFeature.State()) {
            AppFeature(
                ghibliClient: ghibliClient,
                favoritesClient: favoritesClient
            )
        }
    }

    init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    var body: some View {
        AppView(store: store)
    }
}

#Preview {
    let (ghibliClient, favoritesClient) = LiveDependencies.makePreview()
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature(
                ghibliClient: ghibliClient,
                favoritesClient: favoritesClient
            )
        }
    )
}
