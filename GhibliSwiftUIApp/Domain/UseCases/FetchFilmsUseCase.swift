//
//  FetchFilmsUseCase.swift
//

import Foundation

public protocol FetchFilmsUseCase: Sendable {
    func execute() async throws -> [Film]
}

nonisolated
public struct DefaultFetchFilmsUseCase: FetchFilmsUseCase {

    private let repository: GhibliRepository

    public init(repository: GhibliRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Film] {
        try await repository.fetchFilms()
    }
}
