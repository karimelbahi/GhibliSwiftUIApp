//
//  APIError.swift
//  GhibliSwiftUIApp
//

import Foundation

public enum APIError: LocalizedError {
    case invalideURL
    case invalidResponse
    case decoding(Error)
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalideURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "Invalid response from server"
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
