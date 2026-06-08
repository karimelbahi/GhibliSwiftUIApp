//
//  GhibliCacheStore.swift
//

import Foundation

@MainActor
public protocol GhibliCacheStore {
    func loadFilms() async -> [Film]
    func saveFilms(_ films: [Film]) async

    func loadPeople(forFilmId filmId: String) async -> [Person]
    func savePeople(_ people: [Person], forFilmId filmId: String) async
}

/// Used in tests and SwiftUI previews — always misses cache.
@MainActor
public struct NullGhibliCacheStore: GhibliCacheStore {
    public init() {}

    public func loadFilms() async -> [Film] { [] }
    public func saveFilms(_ films: [Film]) async {}
    public func loadPeople(forFilmId filmId: String) async -> [Person] { [] }
    public func savePeople(_ people: [Person], forFilmId filmId: String) async {}
}
