//
//  GhibliCacheContainer.swift
//

import Foundation
import SwiftData

@MainActor
public final class GhibliCacheContainer {

    public let modelContainer: ModelContainer
    public let cacheStore: GhibliCacheStore

    public init(inMemory: Bool = false) throws {
        modelContainer = try GhibliSwiftDataStack.makeContainer(inMemory: inMemory)
        cacheStore = SwiftDataGhibliCacheStoreBridge(container: modelContainer)
    }
}
