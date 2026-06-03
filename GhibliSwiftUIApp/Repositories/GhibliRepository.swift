//
//  GhibliRepository.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol GhibliRepository: Sendable {
    func fetchFilms() async throws -> [Film]
    func fetchPerson(from urlString: String) async throws -> Person
    func searchFilms(for searchTerm: String) async throws -> [Film]
    func fetchPeople(for film: Film) async throws -> [Person]
}

nonisolated
struct DefaultGhibliRepository: GhibliRepository {

    private let service: GhibliService

    init(service: GhibliService = DefaultGhibliService()) {
        self.service = service
    }

    func fetchFilms() async throws -> [Film] {
        try await service.fetchFilms()
    }

    func fetchPerson(from urlString: String) async throws -> Person {
        try await service.fetchPerson(from: urlString)
    }

    func searchFilms(for searchTerm: String) async throws -> [Film] {
        try await service.searchFilm(for: searchTerm)
    }

    func fetchPeople(for film: Film) async throws -> [Person] {
        var loadedPeople: [Person] = []

        try await withThrowingTaskGroup(of: Person.self) { group in
            for personInfoURL in film.people {
                group.addTask {
                    try await self.service.fetchPerson(from: personInfoURL)
                }
            }

            for try await person in group {
                loadedPeople.append(person)
            }
        }

        return loadedPeople
    }
}
