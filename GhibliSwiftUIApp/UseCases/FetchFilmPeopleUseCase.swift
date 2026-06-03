//
//  FetchFilmPeopleUseCase.swift
//  GhibliSwiftUIApp
//

import Foundation

protocol FetchFilmPeopleUseCase: Sendable {
    func execute(for film: Film) async throws -> [Person]
}

struct DefaultFetchFilmPeopleUseCase: FetchFilmPeopleUseCase {

    private let service: GhibliService

    init(service: GhibliService = DefaultGhibliService()) {
        self.service = service
    }

    func execute(for film: Film) async throws -> [Person] {
        var loadedPeople: [Person] = []

        try await withThrowingTaskGroup(of: Person.self) { group in
            for personInfoURL in film.people {
                group.addTask {
                    try await self.service.fetchPerson(from: personInfoURL)
                }
            }

            for try await person in group {
                loadedPeople.append(person)
            }
        }

        return loadedPeople
    }
}
