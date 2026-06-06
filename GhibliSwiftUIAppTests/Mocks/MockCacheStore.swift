//
//  MockCacheStore.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

actor MockGhibliCacheStore: GhibliCacheStore {

    var films: [Film] = []
    var peopleByFilmId: [String: [Person]] = [:]
    var returnEmptyOnFirstFilmsLoad = false

    private(set) var loadFilmsCallCount = 0
    private(set) var saveFilmsCallCount = 0
    private(set) var lastSavedFilms: [Film]?
    private(set) var loadPeopleCallCount = 0
    private(set) var savePeopleCallCount = 0
    private(set) var lastSavedPeople: [Person]?
    private(set) var lastSavedFilmId: String?

    func loadFilms() async -> [Film] {
        loadFilmsCallCount += 1

        if returnEmptyOnFirstFilmsLoad && loadFilmsCallCount == 1 {
            return []
        }

        return films
    }

    func saveFilms(_ films: [Film]) async {
        saveFilmsCallCount += 1
        lastSavedFilms = films
        self.films = films
    }

    func loadPeople(forFilmId filmId: String) async -> [Person] {
        loadPeopleCallCount += 1
        return peopleByFilmId[filmId] ?? []
    }

    func savePeople(_ people: [Person], forFilmId filmId: String) async {
        savePeopleCallCount += 1
        lastSavedPeople = people
        lastSavedFilmId = filmId
        peopleByFilmId[filmId] = people
    }

    func configureReturnEmptyOnFirstFilmsLoad(_ value: Bool) {
        returnEmptyOnFirstFilmsLoad = value
    }
}
