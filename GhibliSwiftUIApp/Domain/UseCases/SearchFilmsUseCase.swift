//
//  SearchFilmsUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol SearchFilmsUseCase: Sendable {
    func execute(searchTerm: String) async throws -> [Film]
}

nonisolated
struct DefaultSearchFilmsUseCase: SearchFilmsUseCase {

    private let repository: GhibliRepository

    init(repository: GhibliRepository) {
        self.repository = repository
    }

    func execute(searchTerm: String) async throws -> [Film] {
        try await repository.searchFilms(for: searchTerm)
    }
}
