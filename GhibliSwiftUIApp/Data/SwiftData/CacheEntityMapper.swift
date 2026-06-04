//
//  CacheEntityMapper.swift
//

import Foundation

enum CacheEntityMapper {
    static func toDomain(_ cached: CachedFilm) -> Film {
        Film(
            id: cached.id,
            title: cached.title,
            description: cached.filmDescription,
            director: cached.director,
            producer: cached.producer,
            releaseYear: cached.releaseYear,
            score: cached.score,
            duration: cached.duration,
            image: cached.image,
            bannerImage: cached.bannerImage,
            people: cached.people
        )
    }

    static func toCached(_ film: Film, cachedAt: Date = .now) -> CachedFilm {
        CachedFilm(
            id: film.id,
            title: film.title,
            filmDescription: film.description,
            director: film.director,
            producer: film.producer,
            releaseYear: film.releaseYear,
            score: film.score,
            duration: film.duration,
            image: film.image,
            bannerImage: film.bannerImage,
            people: film.people,
            cachedAt: cachedAt
        )
    }

    static func toDomain(_ cached: CachedPerson) -> Person {
        Person(
            id: cached.id,
            name: cached.name,
            gender: cached.gender,
            age: cached.age,
            eyeColor: cached.eyeColor,
            hairColor: cached.hairColor,
            films: cached.films,
            species: cached.species,
            url: cached.url
        )
    }

    static func toCached(_ person: Person) -> CachedPerson {
        CachedPerson(
            id: person.id,
            name: person.name,
            gender: person.gender,
            age: person.age,
            eyeColor: person.eyeColor,
            hairColor: person.hairColor,
            films: person.films,
            species: person.species,
            url: person.url
        )
    }
}
