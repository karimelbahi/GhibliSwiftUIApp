//
//  FilmMapper.swift
//  GhibliSwiftUIApp
//

import Foundation

nonisolated
enum FilmMapper {
    static func toDomain(_ dto: FilmDTO) -> Film {
        Film(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            director: dto.director,
            producer: dto.producer,
            releaseYear: dto.release_date,
            score: dto.rt_score,
            duration: dto.running_time,
            image: dto.image,
            bannerImage: dto.movie_banner,
            people: dto.people
        )
    }
}
