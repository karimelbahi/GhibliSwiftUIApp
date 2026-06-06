//
//  MockUseCases.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

actor MockSearchFilmsUseCase: SearchFilmsUseCase {

    let mockFilms: [Film]
    let shouldThrowError: Bool
    let errorToThrow: Error
    let fetchDelay: Duration

    private(set) var executeCallCount = 0
    private(set) var lastSearchTerm: String?

    init(
        mockFilms: [Film],
        shouldThrowError: Bool = false,
        errorToThrow: Error = APIError.networkError(NSError(domain: "Test", code: -1)),
        fetchDelay: Duration = .zero
    ) {
        self.mockFilms = mockFilms
        self.shouldThrowError = shouldThrowError
        self.errorToThrow = errorToThrow
        self.fetchDelay = fetchDelay
    }

    func execute(searchTerm: String) async throws -> [Film] {
        executeCallCount += 1
        lastSearchTerm = searchTerm

        if shouldThrowError {
            throw errorToThrow
        }

        if fetchDelay > .zero {
            try await Task.sleep(for: fetchDelay)
        }

        try Task.checkCancellation()

        return mockFilms.filter {
            $0.title.localizedCaseInsensitiveContains(searchTerm)
        }
    }
}

actor MockFetchFilmsUseCase: FetchFilmsUseCase {

    let mockFilms: [Film]
    let shouldThrowError: Bool
    let failuresBeforeSuccess: Int
    let errorToThrow: Error
    let fetchDelay: Duration

    private(set) var executeCallCount = 0

    init(
        mockFilms: [Film],
        shouldThrowError: Bool = false,
        failuresBeforeSuccess: Int = 0,
        errorToThrow: Error = DomainError.networkUnavailable,
        fetchDelay: Duration = .zero
    ) {
        self.mockFilms = mockFilms
        self.shouldThrowError = shouldThrowError
        self.failuresBeforeSuccess = failuresBeforeSuccess
        self.errorToThrow = errorToThrow
        self.fetchDelay = fetchDelay
    }

    func execute() async throws -> [Film] {
        executeCallCount += 1

        if shouldThrowError || executeCallCount <= failuresBeforeSuccess {
            throw errorToThrow
        }

        if fetchDelay > .zero {
            try await Task.sleep(for: fetchDelay)
        }

        return mockFilms
    }
}

actor MockFetchFilmPeopleUseCase: FetchFilmPeopleUseCase {

    let mockPeople: [Person]
    let shouldThrowError: Bool
    let errorToThrow: Error
    let fetchDelay: Duration

    private(set) var executeCallCount = 0
    private(set) var lastFilm: Film?

    init(
        mockPeople: [Person],
        shouldThrowError: Bool = false,
        errorToThrow: Error = DomainError.networkUnavailable,
        fetchDelay: Duration = .zero
    ) {
        self.mockPeople = mockPeople
        self.shouldThrowError = shouldThrowError
        self.errorToThrow = errorToThrow
        self.fetchDelay = fetchDelay
    }

    func execute(for film: Film) async throws -> [Person] {
        executeCallCount += 1
        lastFilm = film

        if shouldThrowError {
            throw errorToThrow
        }

        if fetchDelay > .zero {
            try await Task.sleep(for: fetchDelay)
        }

        return mockPeople
    }
}

final class MockManageFavoritesUseCase: ManageFavoritesUseCase {

    var storedFavorites: Set<String>
    private(set) var saveCallCount = 0
    private(set) var loadCallCount = 0

    init(storedFavorites: Set<String> = []) {
        self.storedFavorites = storedFavorites
    }

    func load() -> Set<String> {
        loadCallCount += 1
        return storedFavorites
    }

    func save(favoriteIDs: Set<String>) {
        saveCallCount += 1
        storedFavorites = favoriteIDs
    }
}
