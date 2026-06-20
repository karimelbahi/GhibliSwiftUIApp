//
//  FavoritesFeature.swift
//

import ComposableArchitecture
import Foundation

// TCA: Reducer for the Favorites tab — owns its own navigation stack (separate from Movies tab).
struct FavoritesFeature: Reducer {

    // TCA: @ObservableState lets SwiftUI views observe state changes automatically.
    @ObservableState
    struct State: Equatable {
        var filmsState: LoadingState<[Film]> = .idle
        var favoriteIDs: Set<String> = []

        // TCA: StackState stores this tab's navigation stack (list → detail → person).
        var path = StackState<FilmTabNavigation.State>()
    }

    // TCA: @CasePathable enables extracting nested actions like .path(...) for Scope/forEach.
    @CasePathable
    enum Action: Equatable {
        case onAppear
        case fetchFilmsResponse(Result<[Film], DomainError>)
        case favoriteButtonTapped(String)

        // TCA: User tapped a favorite film — starts navigation (see .filmTapped handler).
        case filmTapped(Film)

        // TCA: Actions from screens already on this tab's navigation stack.
        case path(StackActionOf<FilmTabNavigation>)
    }

    let ghibliClient: GhibliClient

    init(ghibliClient: GhibliClient) {
        self.ghibliClient = ghibliClient
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.filmsState.isLoading else { return .none }
                if case .idle = state.filmsState {
                    state.filmsState = .loading
                }
                // TCA: .run = fetch catalog so view can filter favorites client-side.
                return .run { [ghibliClient] send in
                    do {
                        let films = try await ghibliClient.fetchFilms()
                        await send(.fetchFilmsResponse(.success(films)))
                    } catch let error as DomainError {
                        await send(.fetchFilmsResponse(.failure(error)))
                    } catch {
                        await send(.fetchFilmsResponse(.failure(.unknown)))
                    }
                }

            case let .fetchFilmsResponse(.success(films)):
                state.filmsState = .loaded(films)
                return .none

            case let .fetchFilmsResponse(.failure(error)):
                state.filmsState = .error(error.userMessage)
                return .none

            case let .filmTapped(film):
                // TCA: Navigation = append detail to this tab's path (state change only).
                state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))
                // TCA: .none = no Effect; FavoritesScreen NavigationStack reacts to path change.
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
            FilmTabNavigation(ghibliClient: ghibliClient)
        }
    }
}
