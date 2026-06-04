//
//  OfflineFirstGhibliRepository.swift
//

import Foundation

/// Reads cached domain data first, refreshes from the network when possible,
/// and falls back to cache when the network is unavailable.
nonisolated
public struct OfflineFirstGhibliRepository: GhibliRepository {

    private let remote: GhibliRepository
    private let cache: GhibliCacheStore

    public init(remote: GhibliRepository, cache: GhibliCacheStore) {
        self.remote = remote
        self.cache = cache
    }

    public func fetchFilms() async throws -> [Film] {
        let cached = await cache.loadFilms()

        if !cached.isEmpty {
            scheduleBackgroundRefresh { _ = try? await self.refreshFilmsFromNetwork() }
            return cached
        }

        return try await refreshFilmsFromNetwork()
    }

    public func searchFilms(for searchTerm: String) async throws -> [Film] {
        let cached = await cache.loadFilms()

        if !cached.isEmpty {
            scheduleBackgroundRefresh { _ = try? await self.refreshFilmsFromNetwork() }
            return filter(cached, matching: searchTerm)
        }

        return try await remote.searchFilms(for: searchTerm)
    }

    public func fetchPeople(for film: Film) async throws -> [Person] {
        let cached = await cache.loadPeople(forFilmId: film.id)

        if !cached.isEmpty {
            scheduleBackgroundRefresh { _ = try? await self.refreshPeopleFromNetwork(for: film) }
            return cached
        }

        return try await refreshPeopleFromNetwork(for: film)
    }

    public func fetchPerson(from urlString: String) async throws -> Person {
        try await remote.fetchPerson(from: urlString)
    }

    // MARK: - Network + cache

    private func refreshFilmsFromNetwork() async throws -> [Film] {
        do {
            let films = try await remote.fetchFilms()
            await cache.saveFilms(films)
            return films
        } catch {
            let cached = await cache.loadFilms()
            if !cached.isEmpty {
                return cached
            }
            throw mapError(error)
        }
    }

    private func refreshPeopleFromNetwork(for film: Film) async throws -> [Person] {
        do {
            let people = try await remote.fetchPeople(for: film)
            await cache.savePeople(people, forFilmId: film.id)
            return people
        } catch {
            let cached = await cache.loadPeople(forFilmId: film.id)
            if !cached.isEmpty {
                return cached
            }
            throw mapError(error)
        }
    }

    private func filter(_ films: [Film], matching searchTerm: String) -> [Film] {
        films.filter { $0.title.localizedStandardContains(searchTerm) }
    }

    private func scheduleBackgroundRefresh(_ operation: @escaping @Sendable () async -> Void) {
        Task {
            await operation()
        }
    }

    private func mapError(_ error: Error) -> Error {
        if let apiError = error as? APIError {
            return apiError.toDomainError()
        }
        return error
    }
}
