//
//  FilmsViewModel.swift
//

import Foundation
import Observation

// @MainActor: view model updates UI state, so it must run on main thread.
// @Observable: when `state` changes, SwiftUI screens refresh automatically.
@MainActor
@Observable
public class FilmsViewModel {

    public var state: LoadingState<[Film]> = .idle

    private let fetchFilmsUseCase: FetchFilmsUseCase

    public init(fetchFilmsUseCase: FetchFilmsUseCase) {
        self.fetchFilmsUseCase = fetchFilmsUseCase
    }

    public func fetch() async {
        guard !state.isLoading || state.error != nil else { return }

        if case .idle = state {
            state = .loading
        }

        do {
            let films = try await fetchFilmsUseCase.execute()
            self.state = .loaded(films)
        } catch let error as DomainError {
            self.state = .error(error.userMessage)
        } catch {
            self.state = .error(DomainError.unknown.userMessage)
        }
    }
}
