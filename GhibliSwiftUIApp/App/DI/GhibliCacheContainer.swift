//
//  GhibliCacheContainer.swift
//
//  DI layer: Infrastructure (NOT a TCA @Dependency).
//  Created at app launch and passed by constructor to ContentView → LiveDependencies.
//

import Foundation   // DI: Foundation only — no ComposableArchitecture here.
import SwiftData    // DI: SwiftData backs the offline film/people cache.

@MainActor          // DI: Container is created on main thread (matches App init + SwiftUI).
public final class GhibliCacheContainer {

    // DI: Exposed for SwiftUI — GhibliSwiftUIAppApp attaches .modelContainer(...) to the scene.
    public let modelContainer: ModelContainer

    // DI: Exposed for LiveDependencies — OfflineFirstGhibliRepository reads/writes through this.
    public let cacheStore: GhibliCacheStore

    // DI: Single place that wires SwiftData stack → cache protocol used by repositories.
    public init(inMemory: Bool = false) throws {
        // DI: Creates on-disk (or in-memory) SwiftData container with CachedFilm / CachedPerson models.
        modelContainer = try GhibliSwiftDataStack.makeContainer(inMemory: inMemory)

        // DI: Adapts ModelContainer to GhibliCacheStore so Data layer does not import SwiftData directly everywhere.
        cacheStore = SwiftDataGhibliCacheStoreBridge(container: modelContainer)
    }
}
