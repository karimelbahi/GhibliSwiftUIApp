//
//  SwiftDataGhibliCacheStore.swift
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataGhibliCacheStore: GhibliCacheStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func loadFilms() async -> [Film] {
        let descriptor = FetchDescriptor<CachedFilm>(
            sortBy: [SortDescriptor(\.title, order: .forward)]
        )

        guard let cached = try? context.fetch(descriptor) else {
            return []
        }

        return cached.map(CacheEntityMapper.toDomain)
    }

    func saveFilms(_ films: [Film]) async {
        deleteAll(CachedFilm.self)

        for film in films {
            context.insert(CacheEntityMapper.toCached(film))
        }

        try? context.save()
    }

    func loadPeople(forFilmId filmId: String) async -> [Person] {
        let entryDescriptor = FetchDescriptor<CachedFilmPeople>(
            predicate: #Predicate { $0.filmId == filmId }
        )

        guard
            let entry = try? context.fetch(entryDescriptor).first,
            !entry.personIds.isEmpty
        else {
            return []
        }

        var people: [Person] = []
        people.reserveCapacity(entry.personIds.count)

        for personId in entry.personIds {
            let personDescriptor = FetchDescriptor<CachedPerson>(
                predicate: #Predicate { $0.id == personId }
            )
            if let cached = try? context.fetch(personDescriptor).first {
                people.append(CacheEntityMapper.toDomain(cached))
            }
        }

        return people
    }

    func savePeople(_ people: [Person], forFilmId filmId: String) async {
        let entryDescriptor = FetchDescriptor<CachedFilmPeople>(
            predicate: #Predicate { $0.filmId == filmId }
        )

        if let existing = try? context.fetch(entryDescriptor).first {
            context.delete(existing)
        }

        for person in people {
            let personId = person.id
            let personDescriptor = FetchDescriptor<CachedPerson>(
                predicate: #Predicate { $0.id == personId }
            )

            if let existing = try? context.fetch(personDescriptor).first {
                update(existing, from: person)
            } else {
                context.insert(CacheEntityMapper.toCached(person))
            }
        }

        let entry = CachedFilmPeople(
            filmId: filmId,
            personIds: people.map(\.id)
        )
        context.insert(entry)
        try? context.save()
    }

    private func update(_ cached: CachedPerson, from person: Person) {
        cached.name = person.name
        cached.gender = person.gender
        cached.age = person.age
        cached.eyeColor = person.eyeColor
        cached.hairColor = person.hairColor
        cached.films = person.films
        cached.species = person.species
        cached.url = person.url
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) {
        guard let items = try? context.fetch(FetchDescriptor<T>()) else { return }
        for item in items {
            context.delete(item)
        }
    }
}
