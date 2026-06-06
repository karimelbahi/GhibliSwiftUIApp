//
//  DefaultGhibliRepositoryTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct DefaultGhibliRepositoryTests {

    private func makeRepository(service: MockGhibliService) -> DefaultGhibliRepository {
        DefaultGhibliRepository(service: service)
    }

    @Test("Fetch films delegates to service")
    func fetchFilmsDelegatesToService() async throws {
        let service = MockGhibliService(mockFilms: TestFixtures.films)
        let repository = makeRepository(service: service)

        let films = try await repository.fetchFilms()

        #expect(films == TestFixtures.films)

        let callCount = await service.fetchFilmsCallCount
        #expect(callCount == 1)
    }

    @Test("Search films delegates to service")
    func searchFilmsDelegatesToService() async throws {
        let service = MockGhibliService(mockFilms: TestFixtures.films)
        let repository = makeRepository(service: service)

        let films = try await repository.searchFilms(for: "Totoro")

        #expect(films.count == 1)
        #expect(films.first?.title == "My Neighbor Totoro")

        let callCount = await service.searchFilmCallCount
        let lastSearchTerm = await service.lastSearchTerm
        #expect(callCount == 1)
        #expect(lastSearchTerm == "Totoro")
    }

    @Test("Fetch person delegates to service")
    func fetchPersonDelegatesToService() async throws {
        let service = MockGhibliService(mockPerson: TestFixtures.people[0])
        let repository = makeRepository(service: service)

        let person = try await repository.fetchPerson(from: "https://api/p1")

        #expect(person == TestFixtures.people[0])

        let callCount = await service.fetchPersonCallCount
        let fetchedURLs = await service.fetchedPersonURLs
        #expect(callCount == 1)
        #expect(fetchedURLs == ["https://api/p1"])
    }

    @Test("Fetch people loads each person URL from film")
    func fetchPeopleLoadsEachPersonURL() async throws {
        let service = MockGhibliService(mockPerson: TestFixtures.people[0])
        let repository = makeRepository(service: service)

        let people = try await repository.fetchPeople(for: TestFixtures.filmWithPeople)

        #expect(people.count == 2)

        let callCount = await service.fetchPersonCallCount
        let fetchedURLs = await service.fetchedPersonURLs
        #expect(callCount == 2)
        #expect(
            Set(fetchedURLs) == Set([
                "https://ghibliapi.vercel.app/people/p1",
                "https://ghibliapi.vercel.app/people/p2"
            ])
        )
    }

    @Test("Fetch people returns empty list for placeholder people URLs")
    func fetchPeopleReturnsEmptyForPlaceholderURLs() async throws {
        let service = MockGhibliService(mockPerson: TestFixtures.people[0])
        let repository = makeRepository(service: service)

        let people = try await repository.fetchPeople(for: TestFixtures.filmWithPlaceholderPeopleURLs)

        #expect(people.isEmpty)

        let callCount = await service.fetchPersonCallCount
        #expect(callCount == 0)
    }

    @Test("Fetch people skips placeholder URLs and loads valid ones")
    func fetchPeopleSkipsPlaceholderURLs() async throws {
        let service = MockGhibliService(mockPerson: TestFixtures.people[0])
        let repository = makeRepository(service: service)

        let people = try await repository.fetchPeople(for: TestFixtures.filmWithMixedPeopleURLs)

        #expect(people.count == 1)

        let callCount = await service.fetchPersonCallCount
        let fetchedURLs = await service.fetchedPersonURLs
        #expect(callCount == 1)
        #expect(fetchedURLs == ["https://ghibliapi.vercel.app/people/p1"])
    }

    @Test("Maps network API errors to domain errors")
    func mapsNetworkAPIErrorToDomainError() async {
        let service = MockGhibliService(
            shouldThrowError: true,
            errorToThrow: APIError.networkError(NSError(domain: "Test", code: -1))
        )
        let repository = makeRepository(service: service)

        do {
            _ = try await repository.fetchFilms()
            Issue.record("Expected fetchFilms to throw")
        } catch let error as DomainError {
            #expect(error == .networkUnavailable)
        } catch {
            Issue.record("Expected DomainError, got \(error)")
        }
    }

    @Test("Maps decoding API errors to domain errors")
    func mapsDecodingAPIErrorToDomainError() async {
        let service = MockGhibliService(
            shouldThrowError: true,
            errorToThrow: APIError.decoding(NSError(domain: "Test", code: -1))
        )
        let repository = makeRepository(service: service)

        do {
            _ = try await repository.searchFilms(for: "Totoro")
            Issue.record("Expected searchFilms to throw")
        } catch let error as DomainError {
            #expect(error == .invalidData)
        } catch {
            Issue.record("Expected DomainError, got \(error)")
        }
    }

    @Test("Maps invalid response API errors to domain errors")
    func mapsInvalidResponseAPIErrorToDomainError() async {
        let service = MockGhibliService(
            shouldThrowError: true,
            errorToThrow: APIError.invalidResponse
        )
        let repository = makeRepository(service: service)

        do {
            _ = try await repository.fetchPerson(from: "https://api/p1")
            Issue.record("Expected fetchPerson to throw")
        } catch let error as DomainError {
            #expect(error == .invalidData)
        } catch {
            Issue.record("Expected DomainError, got \(error)")
        }
    }
}
