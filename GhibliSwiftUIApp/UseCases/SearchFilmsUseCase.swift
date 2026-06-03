//
//  SearchFilmsUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol SearchFilmsUseCase: Sendable {
    func execute(searchTerm: String) async throws -> [Film]
}

struct DefaultSearchFilmsUseCase: SearchFilmsUseCase {

    private let service: GhibliService

    init(service: GhibliService = DefaultGhibliService()) {
        self.service = service
    }

    func execute(searchTerm: String) async throws -> [Film] {
        try await service.searchFilm(for: searchTerm)
    }
}
