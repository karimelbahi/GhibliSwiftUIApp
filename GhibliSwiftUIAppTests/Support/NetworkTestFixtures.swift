//
//  NetworkTestFixtures.swift
//  GhibliSwiftUIAppTests
//

import Foundation

enum NetworkTestFixtures {

    static let filmsURL = URL(string: "https://ghibliapi.vercel.app/films")!
    static let personURL = URL(string: "https://ghibliapi.vercel.app/people/p1")!

    static let filmsJSON = """
    [
        {
            "id": "1",
            "title": "My Neighbor Totoro",
            "description": "Two sisters discover Totoro",
            "director": "Hayao Miyazaki",
            "producer": "Isao Takahata",
            "release_date": "1988",
            "running_time": "86",
            "rt_score": "93",
            "image": "https://example.com/totoro.jpg",
            "movie_banner": "https://example.com/totoro-banner.jpg",
            "people": ["https://ghibliapi.vercel.app/people/p1"]
        },
        {
            "id": "2",
            "title": "Spirited Away",
            "description": "A girl enters a spirit world",
            "director": "Hayao Miyazaki",
            "producer": "Toshio Suzuki",
            "release_date": "2001",
            "running_time": "125",
            "rt_score": "97",
            "image": "https://example.com/spirited.jpg",
            "movie_banner": "https://example.com/spirited-banner.jpg",
            "people": []
        }
    ]
    """

    static let personJSON = """
    {
        "id": "p1",
        "name": "Ashitaka",
        "gender": "male",
        "age": "17",
        "eye_color": "brown",
        "hair_color": "black",
        "films": ["3"],
        "species": "Human",
        "url": "https://ghibliapi.vercel.app/people/p1"
    }
    """

    static let invalidJSON = "{ not-valid-json"

    static func httpResponse(
        for url: URL,
        statusCode: Int = 200
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
