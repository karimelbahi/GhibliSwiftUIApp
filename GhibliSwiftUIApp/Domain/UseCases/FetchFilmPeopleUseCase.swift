//
//  FetchFilmPeopleUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FetchFilmPeopleUseCase: Sendable {
    func execute(for film: Film) async throws -> [Person]
}

nonisolated
struct DefaultFetchFilmPeopleUseCase: FetchFilmPeopleUseCase {

    private let repository: GhibliRepository

    init(repository: GhibliRepository) {
        self.repository = repository
    }

    func execute(for film: Film) async throws -> [Person] {
        try await repository.fetchPeople(for: film)
    }
}
