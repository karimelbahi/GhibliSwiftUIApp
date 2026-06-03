//
//  GhibliService.swift
//

import Foundation
import GhibliDomain

public protocol GhibliService: Sendable {
    func fetchFilms() async throws -> [Film]
    func fetchPerson(from URLString: String) async throws -> Person
    func searchFilm(for searchTerm: String) async throws -> [Film]
}
