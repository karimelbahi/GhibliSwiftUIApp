//
//  DefaultGhibliService.swift
//

import Foundation

nonisolated
public struct DefaultGhibliService: GhibliService {

    public init() {}

    func fetch<T: Decodable>(from URLString: String, type: T.Type) async throws -> T {
        guard let url = URL(string: URLString) else {
            throw APIError.invalideURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }

            return try JSONDecoder().decode(type, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        } catch let error as URLError {
            throw APIError.networkError(error)
        }
    }

    public func fetchFilms() async throws -> [Film] {
        let url = "https://ghibliapi.vercel.app/films"
        let dtos: [FilmDTO] = try await fetch(from: url, type: [FilmDTO].self)
        return dtos.map(FilmMapper.toDomain)
    }

    public func searchFilm(for searchTerm: String) async throws -> [Film] {
        let allFilms = try await fetchFilms()

        return allFilms.filter { film in
            film.title.localizedStandardContains(searchTerm)
        }
    }

    public func fetchPerson(from URLString: String) async throws -> Person {
        let dto: PersonDTO = try await fetch(from: URLString, type: PersonDTO.self)
        return PersonMapper.toDomain(dto)
    }
}
