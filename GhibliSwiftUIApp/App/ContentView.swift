//
//  ContentView.swift
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {

    let store: StoreOf<AppFeature>
    let ghibliClient: GhibliClient

    init(
        cacheContainer: GhibliCacheContainer,
        useMockService: Bool = false
    ) {
        let (ghibliClient, favoritesClient) = LiveDependencies.make(
            cacheContainer: cacheContainer,
            useMockService: useMockService
        )
        self.ghibliClient = ghibliClient
        store = Store(initialState: AppFeature.State()) {
            AppFeature(
                ghibliClient: ghibliClient,
                favoritesClient: favoritesClient
            )
        }
    }

    init(store: StoreOf<AppFeature>, ghibliClient: GhibliClient) {
        self.store = store
        self.ghibliClient = ghibliClient
    }

    var body: some View {
        AppView(store: store, ghibliClient: ghibliClient)
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
        },
        ghibliClient: ghibliClient
    )
}
