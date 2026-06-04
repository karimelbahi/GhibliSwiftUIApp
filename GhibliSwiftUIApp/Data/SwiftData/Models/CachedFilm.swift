//
//  CachedFilm.swift
//

import Foundation
import SwiftData

@Model
final class CachedFilm {
    @Attribute(.unique) var id: String
    var title: String
    var filmDescription: String
    var director: String
    var producer: String
    var releaseYear: String
    var score: String
    var duration: String
    var image: String
    var bannerImage: String
    var people: [String]
    var cachedAt: Date

    init(
        id: String,
        title: String,
        filmDescription: String,
        director: String,
        producer: String,
        releaseYear: String,
        score: String,
        duration: String,
        image: String,
        bannerImage: String,
        people: [String],
        cachedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.filmDescription = filmDescription
        self.director = director
        self.producer = producer
        self.releaseYear = releaseYear
        self.score = score
        self.duration = duration
        self.image = image
        self.bannerImage = bannerImage
        self.people = people
        self.cachedAt = cachedAt
    }
}
