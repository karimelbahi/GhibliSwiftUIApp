//
//  SwiftDataGhibliCacheStoreBridge.swift
//

import Foundation
import SwiftData

/// Sendable facade that performs SwiftData work on the main actor.
final class SwiftDataGhibliCacheStoreBridge: GhibliCacheStore, @unchecked Sendable {

    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func loadFilms() async -> [Film] {
        await runOnMainActor { store in
            await store.loadFilms()
        }
    }

    func saveFilms(_ films: [Film]) async {
        await runOnMainActor { store in
            await store.saveFilms(films)
        }
    }

    func loadPeople(forFilmId filmId: String) async -> [Person] {
        await runOnMainActor { store in
            await store.loadPeople(forFilmId: filmId)
        }
    }

    func savePeople(_ people: [Person], forFilmId filmId: String) async {
        await runOnMainActor { store in
            await store.savePeople(people, forFilmId: filmId)
        }
    }

    @MainActor
    private func runOnMainActor<T>(
        _ work: (SwiftDataGhibliCacheStore) async -> T
    ) async -> T {
        let store = SwiftDataGhibliCacheStore(context: ModelContext(container))
        return await work(store)
    }
}
