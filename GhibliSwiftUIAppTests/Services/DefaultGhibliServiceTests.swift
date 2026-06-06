//
//  DefaultGhibliServiceTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

@Suite(.serialized)
struct DefaultGhibliServiceTests {

    private func filmsData() -> Data {
        Data(NetworkTestFixtures.filmsJSON.utf8)
    }

    private func personData() -> Data {
        Data(NetworkTestFixtures.personJSON.utf8)
    }

    private func filmsHandler() -> MockURLResponseHandler {
        { request in
            let response = NetworkTestFixtures.httpResponse(
                for: request.url ?? NetworkTestFixtures.filmsURL
            )
            return (response, filmsData())
        }
    }

    @Test("Fetch films decodes and maps DTOs")
    func fetchFilmsDecodesAndMapsDTOs() async throws {
        let films = try await MockURLSessionSupport.withService(
            handler: filmsHandler()
        ) { service in
            try await service.fetchFilms()
        }

        #expect(films.count == 2)
        #expect(films[0].title == "My Neighbor Totoro")
        #expect(films[0].releaseYear == "1988")
        #expect(films[0].score == "93")
        #expect(films[1].title == "Spirited Away")
    }

    @Test("Search film filters fetched films by title")
    func searchFilmFiltersFetchedFilms() async throws {
        let films = try await MockURLSessionSupport.withService(
            handler: filmsHandler()
        ) { service in
            try await service.searchFilm(for: "Totoro")
        }

        #expect(films.count == 1)
        #expect(films.first?.title == "My Neighbor Totoro")
    }

    private func personHandler() -> MockURLResponseHandler {
        { request in
            let response = NetworkTestFixtures.httpResponse(
                for: request.url ?? NetworkTestFixtures.personURL
            )
            return (response, personData())
        }
    }

    @Test("Fetch person decodes and maps DTO")
    func fetchPersonDecodesAndMapsDTO() async throws {
        let person = try await MockURLSessionSupport.withService(
            handler: personHandler()
        ) { service in
            try await service.fetchPerson(from: NetworkTestFixtures.personURL.absoluteString)
        }

        #expect(person.id == "p1")
        #expect(person.name == "Ashitaka")
        #expect(person.eyeColor == "brown")
        #expect(person.hairColor == "black")
    }

    @Test("Invalid URL throws APIError.invalideURL")
    func invalidURLThrowsAPIError() async {
        let service = DefaultGhibliService(session: .mock)

        do {
            _ = try await service.fetchPerson(from: "")
            Issue.record("Expected fetchPerson to throw")
        } catch let error as APIError {
            if case .invalideURL = error {
                // expected
            } else {
                Issue.record("Expected invalideURL, got \(error)")
            }
        } catch {
            Issue.record("Expected APIError, got \(error)")
        }
    }

    @Test("Non-success status code throws APIError.invalidResponse")
    func invalidResponseThrowsAPIError() async {
        do {
            _ = try await MockURLSessionSupport.withService(
                handler: { request in
                    let response = NetworkTestFixtures.httpResponse(
                        for: request.url ?? NetworkTestFixtures.filmsURL,
                        statusCode: 500
                    )
                    return (response, filmsData())
                }
            ) { service in
                try await service.fetchFilms()
            }
            Issue.record("Expected fetchFilms to throw")
        } catch let error as APIError {
            if case .invalidResponse = error {
                // expected
            } else {
                Issue.record("Expected invalidResponse, got \(error)")
            }
        } catch {
            Issue.record("Expected APIError, got \(error)")
        }
    }

    @Test("Malformed JSON throws APIError.decoding")
    func decodingErrorThrowsAPIError() async {
        do {
            _ = try await MockURLSessionSupport.withService(
                handler: { request in
                    let response = NetworkTestFixtures.httpResponse(
                        for: request.url ?? NetworkTestFixtures.filmsURL
                    )
                    let data = Data(NetworkTestFixtures.invalidJSON.utf8)
                    return (response, data)
                }
            ) { service in
                try await service.fetchFilms()
            }
            Issue.record("Expected fetchFilms to throw")
        } catch let error as APIError {
            if case .decoding = error {
                // expected
            } else {
                Issue.record("Expected decoding error, got \(error)")
            }
        } catch {
            Issue.record("Expected APIError, got \(error)")
        }
    }

    @Test("Network failure throws APIError.networkError")
    func networkFailureThrowsAPIError() async {
        do {
            _ = try await MockURLSessionSupport.withService(
                handler: { _ in
                    throw URLError(.notConnectedToInternet)
                }
            ) { service in
                try await service.fetchFilms()
            }
            Issue.record("Expected fetchFilms to throw")
        } catch let error as APIError {
            if case .networkError = error {
                // expected
            } else {
                Issue.record("Expected networkError, got \(error)")
            }
        } catch {
            Issue.record("Expected APIError, got \(error)")
        }
    }
}
