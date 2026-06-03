//
//  FetchFilmsUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FetchFilmsUseCase: Sendable {
    func execute() async throws -> [Film]
}

nonisolated
struct DefaultFetchFilmsUseCase: FetchFilmsUseCase {

    private let repository: GhibliRepository

    init(repository: GhibliRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Film] {
        try await repository.fetchFilms()
    }
}
