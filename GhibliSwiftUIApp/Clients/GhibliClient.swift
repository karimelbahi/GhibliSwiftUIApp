//
//  GhibliClient.swift
//

import Foundation

struct GhibliClient: Sendable {
    var fetchFilms: @Sendable () async throws -> [Film]
    var searchFilms: @Sendable (_ searchTerm: String) async throws -> [Film]
    var fetchPeople: @Sendable (_ film: Film) async throws -> [Person]

    init(
        fetchFilms: @escaping @Sendable () async throws -> [Film] = { [] },
        searchFilms: @escaping @Sendable (_ searchTerm: String) async throws -> [Film] = { _ in [] },
        fetchPeople: @escaping @Sendable (_ film: Film) async throws -> [Person] = { _ in [] }
    ) {
        self.fetchFilms = fetchFilms
        self.searchFilms = searchFilms
        self.fetchPeople = fetchPeople
    }
}

extension GhibliClient {
    static func live(repository: GhibliRepository) -> GhibliClient {
        GhibliClient(
            fetchFilms: { try await repository.fetchFilms() },
            searchFilms: { try await repository.searchFilms(for: $0) },
            fetchPeople: { try await repository.fetchPeople(for: $0) }
        )
    }

    static func preview(repository: GhibliRepository) -> GhibliClient {
        live(repository: repository)
    }
}
