//
//  GhibliSwiftUIAppApp.swift
//

import SwiftData
import SwiftUI

@main
struct GhibliSwiftUIAppApp: App {

    private let cacheContainer: GhibliCacheContainer

    init() {
        cacheContainer = try! GhibliCacheContainer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(cacheContainer: cacheContainer)
        }
        .modelContainer(cacheContainer.modelContainer)
    }
}
