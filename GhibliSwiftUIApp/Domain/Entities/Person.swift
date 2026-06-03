//
//  Person.swift
//

import Foundation

public struct Person: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let gender: String
    public let age: String
    public let eyeColor: String
    public let hairColor: String
    public let films: [String]
    public let species: String
    public let url: String

    public init(
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
