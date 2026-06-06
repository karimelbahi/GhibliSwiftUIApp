//
//  TestFixtures.swift
//  GhibliSwiftUIAppTests
//

import Foundation
@testable import GhibliSwiftUIApp

enum TestFixtures {

    static let films: [Film] = [
        Film(
            id: "1",
            title: "My Neighbor Totoro",
            description: "Two sisters discover Totoro",
            director: "Hayao Miyazaki",
            producer: "Isao Takahata",
            releaseYear: "1988",
            score: "93",
            duration: "",
            image: "",
            bannerImage: "",
            people: []
        ),
        Film(
            id: "2",
            title: "Spirited Away",
            description: "A girl enters a spirit world",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseYear: "2001",
            score: "97",
            duration: "",
            image: "",
            bannerImage: "",
            people: []
        ),
        Film(
            id: "3",
            title: "Princess Mononoke",
            description: "A prince fights to save the forest",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseYear: "1997",
            score: "92",
            duration: "",
            image: "",
            bannerImage: "",
            people: []
        )
    ]

    static let filmWithPeople = Film(
        id: "3",
        title: "Princess Mononoke",
        description: "A prince fights to save the forest",
        director: "Hayao Miyazaki",
        producer: "Toshio Suzuki",
        releaseYear: "1997",
        score: "92",
        duration: "",
        image: "",
        bannerImage: "",
        people: ["https://api/p1", "https://api/p2"]
    )

    static let people: [Person] = [
        Person(
            id: "p1",
            name: "Ashitaka",
            gender: "male",
            age: "17",
            eyeColor: "brown",
            hairColor: "black",
            films: ["3"],
            species: "Human",
            url: ""
        ),
        Person(
            id: "p2",
            name: "San",
            gender: "female",
            age: "17",
            eyeColor: "brown",
            hairColor: "black",
            films: ["3"],
            species: "Human",
            url: ""
        )
    ]
}
