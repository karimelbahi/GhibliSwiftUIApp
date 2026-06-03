//
//  PersonDTO.swift
//  GhibliSwiftUIApp
//

import Foundation

struct PersonDTO: Decodable, Sendable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let eye_color: String
    let hair_color: String
    let films: [String]
    let species: String
    let url: String
}
