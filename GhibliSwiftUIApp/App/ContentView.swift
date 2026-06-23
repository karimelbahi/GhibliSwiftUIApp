//
//  ContentView.swift
//
//  DI layer: TCA composition root — registers live clients on the Store (withDependencies).
//

import ComposableArchitecture  // DI: Store, withDependencies, DependencyValues.
import SwiftUI

struct ContentView: View {

    // DI: Root store carries DependencyValues to all child reducers (films, search, detail, …).
    let store: StoreOf<AppFeature>

    init(
        cacheContainer: GhibliCacheContainer,  // DI: Infrastructure from GhibliSwiftUIAppApp (not @Dependency).
        useMockService: Bool = false           // DI: Switch API to MockGhibliService when true (e.g. demos).
    ) {
        // DI: Step 1 — create Store with empty AppFeature state; reducer has no init parameters.
        store = Store(initialState: AppFeature.State()) {
            AppFeature()
        // DI: Step 2 — attach dependency "backpack" to this Store (and all scoped children).
        } withDependencies: {
            // DI: Step 3 — factory builds real clients from cache + repositories + UserDefaults.
            let (ghibliClient, favoritesClient) = LiveDependencies.make(
                cacheContainer: cacheContainer,
                useMockService: useMockService
            )
            // DI: Step 4 — register on DependencyValues; reducers read via @Dependency(\.ghibliClient).
            $0.ghibliClient = ghibliClient
            // DI: Step 5 — same for favorites; AppFeature reads @Dependency(\.favoritesClient).
            $0.favoritesClient = favoritesClient
        }
    }

    // DI: Secondary init for previews/tests that build the Store externally with their own withDependencies.
    init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    var body: some View {
        AppView(store: store)  // DI: Passes store down; tab scopes inherit the same DependencyValues.
    }
}

#Preview {
    ContentView(
        // DI: Preview builds Store manually — no GhibliCacheContainer (uses NullGhibliCacheStore inside makePreview).
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            let (ghibliClient, favoritesClient) = LiveDependencies.makePreview()
            $0.ghibliClient = ghibliClient
            $0.favoritesClient = favoritesClient
        }
    )
}
