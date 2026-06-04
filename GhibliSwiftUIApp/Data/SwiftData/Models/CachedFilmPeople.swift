//
//  CachedFilmPeople.swift
//

import Foundation
import SwiftData

@Model
final class CachedFilmPeople {
    @Attribute(.unique) var filmId: String
    var personIds: [String]
    var cachedAt: Date

    init(filmId: String, personIds: [String], cachedAt: Date = .now) {
        self.filmId = filmId
        self.personIds = personIds
        self.cachedAt = cachedAt
    }
}
