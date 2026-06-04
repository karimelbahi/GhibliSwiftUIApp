//
//  GhibliSwiftDataStack.swift
//

import Foundation
import SwiftData

enum GhibliSwiftDataStack {
    static let schema = Schema([
        CachedFilm.self,
        CachedPerson.self,
        CachedFilmPeople.self
    ])

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
