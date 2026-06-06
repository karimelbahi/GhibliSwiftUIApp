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
        let personURLs = Self.validPersonURLs(from: film.people)

        // The API sometimes returns collection placeholders like ".../people/" with no ID.
        guard !personURLs.isEmpty else { return [] }

        return await withTaskGroup(of: Person?.self) { group in
            for personURL in personURLs {
                group.addTask {
                    try? await self.service.fetchPerson(from: personURL)
                }
            }

            var loadedPeople: [Person] = []
            for await person in group {
                if let person {
                    loadedPeople.append(person)
                }
            }
            return loadedPeople
        }
    }

    /// Keeps only person resource URLs (e.g. `/people/{id}`), not collection endpoints (`/people/`).
    static func validPersonURLs(from urls: [String]) -> [String] {
        urls.filter { urlString in
            guard let url = URL(string: urlString) else { return false }

            let pathComponents = url.pathComponents.filter { $0 != "/" }
            guard pathComponents.count >= 2 else { return false }

            let resourceID = pathComponents[pathComponents.count - 1]
            let resourceType = pathComponents[pathComponents.count - 2]

            return resourceType == "people" && !resourceID.isEmpty
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
