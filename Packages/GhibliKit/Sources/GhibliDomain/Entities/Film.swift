//
//  Film.swift
//

import Foundation

public struct Film: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let director: String
    public let producer: String
    public let releaseYear: String
    public let score: String
    public let duration: String
    public let image: String
    public let bannerImage: String
    public let people: [String]

    public init(
        id: String,
        title: String,
        description: String,
        director: String,
        producer: String,
        releaseYear: String,
        score: String,
        duration: String,
        image: String,
        bannerImage: String,
        people: [String]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.director = director
        self.producer = producer
        self.releaseYear = releaseYear
        self.score = score
        self.duration = duration
        self.image = image
        self.bannerImage = bannerImage
        self.people = people
    }
}
