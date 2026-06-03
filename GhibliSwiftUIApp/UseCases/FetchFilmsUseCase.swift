//
//  FetchFilmsUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FetchFilmsUseCase: Sendable {
    func execute() async throws -> [Film]
}

struct DefaultFetchFilmsUseCase: FetchFilmsUseCase {

    private let service: GhibliService

    init(service: GhibliService = DefaultGhibliService()) {
        self.service = service
    }

    func execute() async throws -> [Film] {
        try await service.fetchFilms()
    }
}
