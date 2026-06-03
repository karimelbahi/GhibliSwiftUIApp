//
//  DomainError.swift
//  GhibliSwiftUIApp
//

import Foundation

public enum DomainError: Error, Equatable, Sendable {
    case invalidData
    case notFound
    case networkUnavailable
    case unknown

    public var userMessage: String {
        switch self {
        case .invalidData:
            return "We couldn't read the server response."
        case .notFound:
            return "No results found."
        case .networkUnavailable:
            return "Please check your internet connection."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
