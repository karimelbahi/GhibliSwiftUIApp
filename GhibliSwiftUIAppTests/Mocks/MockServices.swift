//
//  MockServices.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

actor MockGhibliService: GhibliService {

    let mockFilms: [Film]
    let mockPerson: Person
    let shouldThrowError: Bool
    let errorToThrow: Error

    private(set) var fetchFilmsCallCount = 0
    private(set) var searchFilmCallCount = 0
    private(set) var lastSearchTerm: String?
    private(set) var fetchPersonCallCount = 0
    private(set) var fetchedPersonURLs: [String] = []

    init(
        mockFilms: [Film] = TestFixtures.films,
        mockPerson: Person = TestFixtures.people[0],
        shouldThrowError: Bool = false,
        errorToThrow: Error = APIError.networkError(NSError(domain: "Test", code: -1))
    ) {
        self.mockFilms = mockFilms
        self.mockPerson = mockPerson
        self.shouldThrowError = shouldThrowError
        self.errorToThrow = errorToThrow
    }

    func fetchFilms() async throws -> [Film] {
        fetchFilmsCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return mockFilms
    }

    func searchFilm(for searchTerm: String) async throws -> [Film] {
        searchFilmCallCount += 1
        lastSearchTerm = searchTerm

        if shouldThrowError {
            throw errorToThrow
        }

        return mockFilms.filter {
            $0.title.localizedStandardContains(searchTerm)
        }
    }

    func fetchPerson(from URLString: String) async throws -> Person {
        fetchPersonCallCount += 1
        fetchedPersonURLs.append(URLString)

        if shouldThrowError {
            throw errorToThrow
        }

        return mockPerson
    }
}
