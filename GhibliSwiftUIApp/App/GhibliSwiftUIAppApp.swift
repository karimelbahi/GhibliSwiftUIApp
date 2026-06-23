//
//  GhibliSwiftUIAppApp.swift
//
//  DI layer: App entry — creates infrastructure BEFORE any TCA Store exists.
//

import SwiftData  // DI: For .modelContainer modifier on the app scene.
import SwiftUI

@main
struct GhibliSwiftUIAppApp: App {

    // DI: Infrastructure singleton for this app process — lives as long as the app.
    private let cacheContainer: GhibliCacheContainer

    init() {
        // DI: Build cache first (throws if SwiftData setup fails). Not registered via @Dependency.
        cacheContainer = try! GhibliCacheContainer()
    }

    var body: some Scene {
        WindowGroup {
            // DI: Pass cache into composition root; ContentView uses it in LiveDependencies.make(...).
            ContentView(cacheContainer: cacheContainer)
        }
        // DI: SwiftUI needs ModelContainer on the scene for @Model / SwiftData integration.
        .modelContainer(cacheContainer.modelContainer)
    }
}
