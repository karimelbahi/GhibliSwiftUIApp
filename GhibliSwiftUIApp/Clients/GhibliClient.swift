//
//  GhibliClient.swift
//
//  DI layer: TCA dependency type — API boundary for all film/people network + cache access.
//

import ComposableArchitecture  // DI: @DependencyClient, DependencyKey, DependencyValues.
import Foundation

// DI: Macro generates memberwise init + test/preview stubs for each closure property.
@DependencyClient
struct GhibliClient: Sendable {
    // DI: Default `{ [] }` required by macro — safe placeholder until ContentView overrides liveValue.
    var fetchFilms: @Sendable () async throws -> [Film] = { [] }
    var searchFilms: @Sendable (_ searchTerm: String) async throws -> [Film] = { _ in [] }
    var fetchPeople: @Sendable (_ film: Film) async throws -> [Person] = { _ in [] }
}

extension GhibliClient {
    // DI: Called only from LiveDependencies — maps repository protocol to client closures.
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
    // DI: Fallback if no withDependencies — empty closures; real app always overrides in ContentView.
    static let liveValue = GhibliClient()
}

extension DependencyValues {
    // DI: Enables @Dependency(\.ghibliClient) and $0.ghibliClient = ... in withDependencies.
    var ghibliClient: GhibliClient {
        get { self[GhibliClient.self] }
        set { self[GhibliClient.self] = newValue }
    }
}
