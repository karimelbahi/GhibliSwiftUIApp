//
//  SearchFilmsViewModel.swift
//

import Foundation
import Observation

@MainActor
@Observable
public class SearchFilmsViewModel {

    public var state: LoadingState<[Film]> = .idle
    private var currentSearchTerm: String = ""

    private let searchFilmsUseCase: SearchFilmsUseCase

    public init(searchFilmsUseCase: SearchFilmsUseCase) {
        self.searchFilmsUseCase = searchFilmsUseCase
    }

    public func fetch(for searchTerm: String) async {
        self.currentSearchTerm = searchTerm

        guard !searchTerm.isEmpty else {
            state = .idle
            return
        }

        state = .loading

        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else {
            if currentSearchTerm == searchTerm {
                state = .idle
            }
            return
        }

        do {
            let films = try await searchFilmsUseCase.execute(searchTerm: searchTerm)
            self.state = .loaded(films)
        } catch {
            setError(error, for: searchTerm)
        }
    }

    public func setError(_ error: Error, for searchTerm: String) {
        guard currentSearchTerm == searchTerm else { return }

        if let error = error as? DomainError {
            self.state = .error(error.userMessage)
        } else {
            self.state = .error(DomainError.unknown.userMessage)
        }
    }
}
