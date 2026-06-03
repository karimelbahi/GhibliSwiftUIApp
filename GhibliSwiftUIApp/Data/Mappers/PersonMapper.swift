//
//  PersonMapper.swift
//  GhibliSwiftUIApp
//

import Foundation

nonisolated
enum PersonMapper {
    static func toDomain(_ dto: PersonDTO) -> Person {
        Person(
            id: dto.id,
            name: dto.name,
            gender: dto.gender,
            age: dto.age,
            eyeColor: dto.eye_color,
            hairColor: dto.hair_color,
            films: dto.films,
            species: dto.species,
            url: dto.url
        )
    }
}
