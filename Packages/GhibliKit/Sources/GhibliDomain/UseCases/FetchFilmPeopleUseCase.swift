//
//  FetchFilmPeopleUseCase.swift
//

import Foundation

public protocol FetchFilmPeopleUseCase: Sendable {
    func execute(for film: Film) async throws -> [Person]
}

nonisolated
public struct DefaultFetchFilmPeopleUseCase: FetchFilmPeopleUseCase {

    private let repository: GhibliRepository

    public init(repository: GhibliRepository) {
        self.repository = repository
    }

    public func execute(for film: Film) async throws -> [Person] {
        try await repository.fetchPeople(for: film)
    }
}
