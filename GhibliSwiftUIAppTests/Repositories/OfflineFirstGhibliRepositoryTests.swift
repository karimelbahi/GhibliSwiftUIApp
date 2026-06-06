//
//  OfflineFirstGhibliRepositoryTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct OfflineFirstGhibliRepositoryTests {

    private func makeRepository(
        remote: MockGhibliRepository,
        cache: MockGhibliCacheStore
    ) -> OfflineFirstGhibliRepository {
        OfflineFirstGhibliRepository(remote: remote, cache: cache)
    }

    @Test("Fetch films returns cache when available")
    func fetchFilmsReturnsCacheWhenAvailable() async throws {
        let remote = MockGhibliRepository(mockFilms: TestFixtures.films)
        let cache = MockGhibliCacheStore()
        await cache.saveFilms(TestFixtures.films)
        let repository = makeRepository(remote: remote, cache: cache)

        let films = try await repository.fetchFilms()

        #expect(films == TestFixtures.films)

        let loadCallCount = await cache.loadFilmsCallCount
        #expect(loadCallCount == 1)
    }

    @Test("Fetch films fetches from remote when cache is empty")
    func fetchFilmsFetchesFromRemoteWhenCacheEmpty() async throws {
        let remote = MockGhibliRepository(mockFilms: TestFixtures.films)
        let cache = MockGhibliCacheStore()
        let repository = makeRepository(remote: remote, cache: cache)

        let films = try await repository.fetchFilms()

        #expect(films == TestFixtures.films)

        let remoteCallCount = await remote.fetchFilmsCallCount
        let saveCallCount = await cache.saveFilmsCallCount
        let cachedFilms = await cache.films

        #expect(remoteCallCount == 1)
        #expect(saveCallCount == 1)
        #expect(cachedFilms == TestFixtures.films)
    }

    @Test("Fetch films falls back to cache when remote fails")
    func fetchFilmsFallsBackToCacheOnRemoteFailure() async throws {
        let remote = MockGhibliRepository(
            shouldThrowError: true,
            errorToThrow: APIError.networkError(NSError(domain: "Test", code: -1))
        )
        let cache = MockGhibliCacheStore()
        await cache.saveFilms(TestFixtures.films)
        await cache.configureReturnEmptyOnFirstFilmsLoad(true)
        let repository = makeRepository(remote: remote, cache: cache)

        let films = try await repository.fetchFilms()

        #expect(films == TestFixtures.films)

        let remoteCallCount = await remote.fetchFilmsCallCount
        #expect(remoteCallCount == 1)
    }

    @Test("Fetch films throws when remote fails and cache is empty")
    func fetchFilmsThrowsWhenRemoteFailsAndCacheEmpty() async {
        let remote = MockGhibliRepository(
            shouldThrowError: true,
            errorToThrow: APIError.networkError(NSError(domain: "Test", code: -1))
        )
        let cache = MockGhibliCacheStore()
        let repository = makeRepository(remote: remote, cache: cache)

        do {
            _ = try await repository.fetchFilms()
            Issue.record("Expected fetchFilms to throw")
        } catch let error as DomainError {
            #expect(error == .networkUnavailable)
        } catch {
            Issue.record("Expected DomainError, got \(error)")
        }
    }

    @Test("Search films filters cached films when cache is available")
    func searchFilmsFiltersCachedFilms() async throws {
        let remote = MockGhibliRepository(mockFilms: TestFixtures.films)
        let cache = MockGhibliCacheStore()
        await cache.saveFilms(TestFixtures.films)
        let repository = makeRepository(remote: remote, cache: cache)

        let films = try await repository.searchFilms(for: "Totoro")

        #expect(films.count == 1)
        #expect(films.first?.title == "My Neighbor Totoro")

        let remoteCallCount = await remote.searchFilmsCallCount
        #expect(remoteCallCount == 0)
    }

    @Test("Search films delegates to remote when cache is empty")
    func searchFilmsDelegatesToRemoteWhenCacheEmpty() async throws {
        let remote = MockGhibliRepository(mockFilms: TestFixtures.films)
        let cache = MockGhibliCacheStore()
        let repository = makeRepository(remote: remote, cache: cache)

        let films = try await repository.searchFilms(for: "Spirited")

        #expect(films.count == 1)
        #expect(films.first?.title == "Spirited Away")

        let remoteCallCount = await remote.searchFilmsCallCount
        let lastSearchTerm = await remote.lastSearchTerm
        #expect(remoteCallCount == 1)
        #expect(lastSearchTerm == "Spirited")
    }

    @Test("Fetch people returns cache when available")
    func fetchPeopleReturnsCacheWhenAvailable() async throws {
        let remote = MockGhibliRepository(mockPeople: TestFixtures.people)
        let cache = MockGhibliCacheStore()
        await cache.savePeople(TestFixtures.people, forFilmId: TestFixtures.filmWithPeople.id)
        let repository = makeRepository(remote: remote, cache: cache)

        let people = try await repository.fetchPeople(for: TestFixtures.filmWithPeople)

        #expect(people == TestFixtures.people)

        let loadCallCount = await cache.loadPeopleCallCount
        #expect(loadCallCount == 1)
    }

    @Test("Fetch people fetches from remote when cache is empty")
    func fetchPeopleFetchesFromRemoteWhenCacheEmpty() async throws {
        let remote = MockGhibliRepository(mockPeople: TestFixtures.people)
        let cache = MockGhibliCacheStore()
        let repository = makeRepository(remote: remote, cache: cache)

        let people = try await repository.fetchPeople(for: TestFixtures.filmWithPeople)

        #expect(people == TestFixtures.people)

        let remoteCallCount = await remote.fetchPeopleCallCount
        let saveCallCount = await cache.savePeopleCallCount
        let savedFilmId = await cache.lastSavedFilmId

        #expect(remoteCallCount == 1)
        #expect(saveCallCount == 1)
        #expect(savedFilmId == TestFixtures.filmWithPeople.id)
    }

    @Test("Fetch person delegates to remote")
    func fetchPersonDelegatesToRemote() async throws {
        let remote = MockGhibliRepository(mockPerson: TestFixtures.people[0])
        let cache = MockGhibliCacheStore()
        let repository = makeRepository(remote: remote, cache: cache)

        let person = try await repository.fetchPerson(from: "https://api/p1")

        #expect(person == TestFixtures.people[0])

        let remoteCallCount = await remote.fetchPersonCallCount
        let lastPersonURL = await remote.lastPersonURL
        #expect(remoteCallCount == 1)
        #expect(lastPersonURL == "https://api/p1")
    }

    @Test("Cache hit schedules background refresh for films")
    func cacheHitSchedulesBackgroundRefreshForFilms() async throws {
        let remote = MockGhibliRepository(mockFilms: TestFixtures.films)
        let cache = MockGhibliCacheStore()
        await cache.saveFilms([TestFixtures.films[0]])
        let repository = makeRepository(remote: remote, cache: cache)

        _ = try await repository.fetchFilms()

        try await Task.sleep(for: .milliseconds(100))

        let remoteCallCount = await remote.fetchFilmsCallCount
        let saveCallCount = await cache.saveFilmsCallCount
        let cachedFilms = await cache.films

        #expect(remoteCallCount == 1)
        #expect(saveCallCount >= 2)
        #expect(cachedFilms == TestFixtures.films)
    }
}
