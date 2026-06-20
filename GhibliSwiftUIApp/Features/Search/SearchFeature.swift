//
//  SearchFeature.swift
//

import ComposableArchitecture
import Foundation

// TCA: Reducer for the Search tab — owns its own navigation stack (separate from other tabs).
struct SearchFeature: Reducer {

    // TCA: @ObservableState lets SwiftUI views observe state changes automatically.
    @ObservableState
    struct State: Equatable {
        var searchText: String = ""
        var searchState: LoadingState<[Film]> = .idle
        var favoriteIDs: Set<String> = []

        // TCA: StackState stores this tab's navigation stack (results → detail → person).
        var path = StackState<FilmTabNavigation.State>()
    }

    // TCA: @CasePathable enables extracting nested actions like .path(...) for Scope/forEach.
    @CasePathable
    enum Action: Equatable {
        // TCA: User typed in search field — triggers debounced .run search effect.
        case searchTextChanged(String)
        case searchResponse(Result<[Film], DomainError>, searchTerm: String)
        case favoriteButtonTapped(String)

        // TCA: User tapped a search result — starts navigation (see .filmTapped handler).
        case filmTapped(Film)

        // TCA: Actions from screens already on this tab's navigation stack.
        case path(StackActionOf<FilmTabNavigation>)
    }

    @Dependency(\.ghibliClient) var ghibliClient
    @Dependency(\.continuousClock) var clock

    // TCA: CancelID identifies the debounced search effect for .cancel / .cancellable.
    private enum CancelID { case search }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(searchTerm):
                state.searchText = searchTerm

                guard !searchTerm.isEmpty else {
                    state.searchState = .idle
                    // TCA: .cancel = stop in-flight debounced search when field is cleared.
                    return .cancel(id: CancelID.search)
                }

                state.searchState = .loading

                // TCA: .run = debounce 500ms, then call search API.
                return .run { send in
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
                // TCA: .cancellable = new keystroke cancels the previous search task.
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case let .searchResponse(.success(films), searchTerm):
                // TCA: Ignore stale responses if user typed something else while waiting.
                guard state.searchText == searchTerm else { return .none }
                state.searchState = .loaded(films)
                return .none

            case let .searchResponse(.failure(error), searchTerm):
                guard state.searchText == searchTerm else { return .none }
                state.searchState = .error(error.userMessage)
                return .none

            case let .filmTapped(film):
                // TCA: Navigation = append detail to this tab's path (state change only).
                state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))
                // TCA: .none = no Effect; SearchScreen NavigationStack reacts to path change.
                return .none

            case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
                // TCA: Same detail → person navigation — see PERSON_DETAIL_NAVIGATION_TCA_GUIDE.md.
                state.path.append(.personDetail(PersonDetailFeature.State(person: person)))
                return .none

            case .favoriteButtonTapped, .path:
                return .none
            }
        }
        // TCA: .forEach = run FilmTabNavigation reducer for each item in state.path.
        .forEach(\.path, action: \.path) {
            FilmTabNavigation()
        }
    }
}
