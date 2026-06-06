//
//  MockRepositories.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

actor MockGhibliRepository: GhibliRepository {

    let mockFilms: [Film]
    let mockPeople: [Person]
    let mockPerson: Person
    let shouldThrowError: Bool
    let errorToThrow: Error

    private(set) var fetchFilmsCallCount = 0
    private(set) var searchFilmsCallCount = 0
    private(set) var lastSearchTerm: String?
    private(set) var fetchPeopleCallCount = 0
    private(set) var lastFetchedFilm: Film?
    private(set) var fetchPersonCallCount = 0
    private(set) var lastPersonURL: String?

    init(
        mockFilms: [Film] = TestFixtures.films,
        mockPeople: [Person] = TestFixtures.people,
        mockPerson: Person = TestFixtures.people[0],
        shouldThrowError: Bool = false,
        errorToThrow: Error = APIError.networkError(NSError(domain: "Test", code: -1))
    ) {
        self.mockFilms = mockFilms
        self.mockPeople = mockPeople
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

    func searchFilms(for searchTerm: String) async throws -> [Film] {
        searchFilmsCallCount += 1
        lastSearchTerm = searchTerm

        if shouldThrowError {
            throw errorToThrow
        }

        return mockFilms.filter {
            $0.title.localizedStandardContains(searchTerm)
        }
    }

    func fetchPeople(for film: Film) async throws -> [Person] {
        fetchPeopleCallCount += 1
        lastFetchedFilm = film

        if shouldThrowError {
            throw errorToThrow
        }

        return mockPeople
    }

    func fetchPerson(from urlString: String) async throws -> Person {
        fetchPersonCallCount += 1
        lastPersonURL = urlString

        if shouldThrowError {
            throw errorToThrow
        }

        return mockPerson
    }
}
