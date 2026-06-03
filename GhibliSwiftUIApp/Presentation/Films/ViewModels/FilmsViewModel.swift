//
//  FilmsViewModel.swift
//  GhibliSwiftUIApp
//

import Foundation
import Observation

@Observable
class FilmsViewModel {

    var state: LoadingState<[Film]> = .idle

    private let fetchFilmsUseCase: FetchFilmsUseCase

    init(fetchFilmsUseCase: FetchFilmsUseCase) {
        self.fetchFilmsUseCase = fetchFilmsUseCase
    }

    func fetch() async {
        guard !state.isLoading || state.error != nil else { return }

        state = .loading

        do {
            let films = try await fetchFilmsUseCase.execute()
            self.state = .loaded(films)
        } catch let error as APIError {
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
}
