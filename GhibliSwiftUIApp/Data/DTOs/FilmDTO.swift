//
//  FilmDTO.swift
//  GhibliSwiftUIApp
//

import Foundation

nonisolated
struct FilmDTO: Decodable, Sendable {
    let id: String
    let title: String
    let description: String
    let director: String
    let producer: String
    let release_date: String
    let rt_score: String
    let running_time: String
    let image: String
    let movie_banner: String
    let people: [String]
}
