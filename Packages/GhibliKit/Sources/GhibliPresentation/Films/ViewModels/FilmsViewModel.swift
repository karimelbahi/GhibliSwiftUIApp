//
//  FilmsViewModel.swift
//

import Foundation
import GhibliDomain
import Observation

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

        state = .loading

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
