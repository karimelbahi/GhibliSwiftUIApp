//
//  GhibliClient.swift
//

import ComposableArchitecture
import Foundation

// TCA: @DependencyClient registers this type in DependencyValues (see @Dependency(\.ghibliClient)).
@DependencyClient
struct GhibliClient: Sendable {
    var fetchFilms: @Sendable () async throws -> [Film] = { [] }
    var searchFilms: @Sendable (_ searchTerm: String) async throws -> [Film] = { _ in [] }
    var fetchPeople: @Sendable (_ film: Film) async throws -> [Person] = { _ in [] }
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

extension GhibliClient: DependencyKey {
    // Overridden at the composition root via Store.withDependencies { ... }.
    static let liveValue = GhibliClient()
}

extension DependencyValues {
    var ghibliClient: GhibliClient {
        get { self[GhibliClient.self] }
        set { self[GhibliClient.self] = newValue }
    }
}
