//
//  SearchFeature.swift
//

import ComposableArchitecture
import Foundation

struct SearchFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var searchText: String = ""
        var searchState: LoadingState<[Film]> = .idle
        var favoriteIDs: Set<String> = []
        var path = StackState<FilmTabNavigation.State>()
    }

    @CasePathable
    enum Action: Equatable {
        case searchTextChanged(String)
        case searchResponse(Result<[Film], DomainError>, searchTerm: String)
        case favoriteButtonTapped(String)
        case filmTapped(Film)
        case path(StackActionOf<FilmTabNavigation>)
    }

    let ghibliClient: GhibliClient
    let clock: any Clock<Duration>

    init(
        ghibliClient: GhibliClient,
        clock: any Clock<Duration> = ContinuousClock()
    ) {
        self.ghibliClient = ghibliClient
        self.clock = clock
    }

    private enum CancelID { case search }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(searchTerm):
                state.searchText = searchTerm

                guard !searchTerm.isEmpty else {
                    state.searchState = .idle
                    return .cancel(id: CancelID.search)
                }

                state.searchState = .loading

                return .run { [ghibliClient, clock] send in
                    try await clock.sleep(for: .milliseconds(500))
                    try Task.checkCancellation()
                    do {
                        let films = try await ghibliClient.searchFilms(searchTerm)
                        await send(.searchResponse(.success(films), searchTerm: searchTerm))
                    } catch let error as DomainError {
                        await send(.searchResponse(.failure(error), searchTerm: searchTerm))
                    } catch is CancellationError {
                        return
                    } catch {
                        await send(.searchResponse(.failure(.unknown), searchTerm: searchTerm))
                    }
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case let .searchResponse(.success(films), searchTerm):
                guard state.searchText == searchTerm else { return .none }
                state.searchState = .loaded(films)
                return .none

            case let .searchResponse(.failure(error), searchTerm):
                guard state.searchText == searchTerm else { return .none }
                state.searchState = .error(error.userMessage)
                return .none

            case let .filmTapped(film):
                state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))
                return .none

            case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
                // TCA: Same detail → person navigation as FilmsFeature (parent-owned stack).
                state.path.append(.personDetail(PersonDetailFeature.State(person: person)))
                return .none

            case .favoriteButtonTapped, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            FilmTabNavigation(ghibliClient: ghibliClient)
        }
    }
}
