//
//  GhibliSwiftUIAppApp.swift
//  GhibliSwiftUIApp
//

import SwiftData
import SwiftUI

@main
struct GhibliSwiftUIAppApp: App {

    private let cacheContainer: GhibliCacheContainer
    private let dependencies: AppDependencies

    init() {
        let cacheContainer = try! GhibliCacheContainer()
        self.cacheContainer = cacheContainer
        self.dependencies = AppDependencies.live(cacheContainer: cacheContainer)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
        }
        .modelContainer(cacheContainer.modelContainer)
    }
}
