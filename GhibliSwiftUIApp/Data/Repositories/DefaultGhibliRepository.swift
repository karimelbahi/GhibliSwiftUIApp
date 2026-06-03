//
//  DefaultGhibliRepository.swift
//

import Foundation

nonisolated
public struct DefaultGhibliRepository: GhibliRepository {

    private let service: GhibliService

    public init(service: GhibliService) {
        self.service = service
    }

    public func fetchFilms() async throws -> [Film] {
        try await mapErrors { try await service.fetchFilms() }
    }

    public func fetchPerson(from urlString: String) async throws -> Person {
        try await mapErrors { try await service.fetchPerson(from: urlString) }
    }

    public func searchFilms(for searchTerm: String) async throws -> [Film] {
        try await mapErrors { try await service.searchFilm(for: searchTerm) }
    }

    public func fetchPeople(for film: Film) async throws -> [Person] {
        try await mapErrors {
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

    private func mapErrors<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as APIError {
            throw error.toDomainError()
        }
    }
}
