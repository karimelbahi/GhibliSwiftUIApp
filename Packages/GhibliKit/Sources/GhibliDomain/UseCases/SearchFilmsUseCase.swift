//
//  SearchFilmsUseCase.swift
//

import Foundation

public protocol SearchFilmsUseCase: Sendable {
    func execute(searchTerm: String) async throws -> [Film]
}

nonisolated
public struct DefaultSearchFilmsUseCase: SearchFilmsUseCase {

    private let repository: GhibliRepository

    public init(repository: GhibliRepository) {
        self.repository = repository
    }

    public func execute(searchTerm: String) async throws -> [Film] {
        try await repository.searchFilms(for: searchTerm)
    }
}
