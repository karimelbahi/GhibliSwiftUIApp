//
//  GhibliRepository.swift
//  GhibliSwiftUIApp
//

import Foundation

public protocol GhibliRepository: Sendable {
    func fetchFilms() async throws -> [Film]
    func fetchPerson(from urlString: String) async throws -> Person
    func searchFilms(for searchTerm: String) async throws -> [Film]
    func fetchPeople(for film: Film) async throws -> [Person]
}
