//
//  CachedPerson.swift
//

import Foundation
import SwiftData

@Model
final class CachedPerson {
    @Attribute(.unique) var id: String
    var name: String
    var gender: String
    var age: String
    var eyeColor: String
    var hairColor: String
    var films: [String]
    var species: String
    var url: String

    init(
        id: String,
        name: String,
        gender: String,
        age: String,
        eyeColor: String,
        hairColor: String,
        films: [String],
        species: String,
        url: String
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.age = age
        self.eyeColor = eyeColor
        self.hairColor = hairColor
        self.films = films
        self.species = species
        self.url = url
    }
}
