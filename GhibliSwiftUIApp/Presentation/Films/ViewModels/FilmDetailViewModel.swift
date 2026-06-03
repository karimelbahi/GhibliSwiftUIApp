//
//  FilmDetailViewModel.swift
//  GhibliSwiftUIApp
//

import Foundation
import Observation

@Observable
class FilmDetailViewModel {

    var state: LoadingState<[Person]> = .idle

    private let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    init(fetchFilmPeopleUseCase: FetchFilmPeopleUseCase) {
        self.fetchFilmPeopleUseCase = fetchFilmPeopleUseCase
    }

    func fetch(for film: Film) async {
        guard !state.isLoading else { return }

        state = .loading

        do {
            let people = try await fetchFilmPeopleUseCase.execute(for: film)
            state = .loaded(people)
        } catch let error as APIError {
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
}
