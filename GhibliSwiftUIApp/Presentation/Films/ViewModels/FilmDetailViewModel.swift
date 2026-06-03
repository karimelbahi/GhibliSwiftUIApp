//
//  FilmDetailViewModel.swift
//

import Foundation
import Observation

@MainActor
@Observable
public class FilmDetailViewModel {

    public var state: LoadingState<[Person]> = .idle

    private let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    public init(fetchFilmPeopleUseCase: FetchFilmPeopleUseCase) {
        self.fetchFilmPeopleUseCase = fetchFilmPeopleUseCase
    }

    public func fetch(for film: Film) async {
        guard !state.isLoading else { return }

        state = .loading

        do {
            let people = try await fetchFilmPeopleUseCase.execute(for: film)
            state = .loaded(people)
        } catch let error as DomainError {
            self.state = .error(error.userMessage)
        } catch {
            self.state = .error(DomainError.unknown.userMessage)
        }
    }
}
