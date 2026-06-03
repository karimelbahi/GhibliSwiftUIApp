//
//  MockGhibliService.swift
//

import Foundation
import GhibliDomain

nonisolated
public struct MockGhibliService: GhibliService {

    private struct SampleData: Decodable {
        let films: [FilmDTO]
        let people: [PersonDTO]
    }

    public init() {}

    private func loadSampleData() throws -> SampleData {
        guard let url = Bundle.module.url(forResource: "SampleData", withExtension: "json") else {
            throw APIError.invalideURL
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SampleData.self, from: data)
        } catch let error as DecodingError {
            print(error)
            throw APIError.decoding(error)
        } catch {
            throw APIError.networkError(error)
        }
    }

    public func fetchFilms() async throws -> [Film] {
        let data = try loadSampleData()
        return data.films.map(FilmMapper.toDomain)
    }

    public func searchFilm(for searchTerm: String) async throws -> [Film] {
        let allFilms = try await fetchFilms()

        return allFilms.filter { film in
            film.title.localizedStandardContains(searchTerm)
        }
    }

    public func fetchPerson(from URLString: String) async throws -> Person {
        let data = try loadSampleData()
        guard let dto = data.people.first else {
            throw APIError.invalidResponse
        }
        return PersonMapper.toDomain(dto)
    }

    public func fetchFilm() -> Film {
        let data = try! loadSampleData()
        return FilmMapper.toDomain(data.films.first!)
    }
}
