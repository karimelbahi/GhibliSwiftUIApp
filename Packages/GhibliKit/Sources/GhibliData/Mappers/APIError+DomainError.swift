//
//  APIError+DomainError.swift
//  GhibliSwiftUIApp
//

import Foundation
import GhibliDomain

extension APIError {
    func toDomainError() -> DomainError {
        switch self {
        case .invalideURL, .invalidResponse, .decoding:
            return .invalidData
        case .networkError:
            return .networkUnavailable
        }
    }
}
