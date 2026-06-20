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
        store = Store(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            let (ghibliClient, favoritesClient) = LiveDependencies.make(
                cacheContainer: cacheContainer,
                useMockService: useMockService
            )
            $0.ghibliClient = ghibliClient
            $0.favoritesClient = favoritesClient
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
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            let (ghibliClient, favoritesClient) = LiveDependencies.makePreview()
            $0.ghibliClient = ghibliClient
            $0.favoritesClient = favoritesClient
        }
    )
}
