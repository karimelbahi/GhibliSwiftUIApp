//
//  FilmsFeature.swift
//

import ComposableArchitecture
import Foundation

// TCA: Reducer = the unit that receives Actions, updates State, and returns Effects.
struct FilmsFeature: Reducer {

    // TCA: @ObservableState lets SwiftUI views observe state changes automatically.
    @ObservableState
    struct State: Equatable {
        var filmsState: LoadingState<[Film]> = .idle
        var favoriteIDs: Set<String> = []

        // TCA: StackState stores the navigation stack inside reducer state (not only in SwiftUI).
        //      Each appended item = one pushed screen (detail, person, etc.).
        var path = StackState<FilmTabNavigation.State>()
    }

    // TCA: @CasePathable enables extracting nested actions like .path(...) for Scope/forEach.
    @CasePathable
    enum Action: Equatable {
        case onAppear
        case fetchFilmsResponse(Result<[Film], DomainError>)
        case favoriteButtonTapped(String)

        // TCA: User tapped a film — this action triggers navigation (see .filmTapped handler).
        case filmTapped(Film)

        // TCA: Actions from screens already on the navigation stack (detail, person, etc.).
        case path(StackActionOf<FilmTabNavigation>)
    }

    let ghibliClient: GhibliClient

    init(ghibliClient: GhibliClient) {
        self.ghibliClient = ghibliClient
    }

    var body: some Reducer<State, Action> {
        // TCA: Reduce = synchronous handler; return an Effect for async/side-effect work.
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.filmsState.isLoading || state.filmsState.error != nil else {
                    // TCA: .none = no side effect; state is unchanged.
                    return .none
                }
                if case .idle = state.filmsState {
                    state.filmsState = .loading
                }
                // TCA: .run = async Effect; fetches data then sends a new Action back to the store.
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
                // TCA: .none = pure state update, no async work needed.
                return .none

            case let .fetchFilmsResponse(.failure(error)):
                state.filmsState = .error(error.userMessage)
                return .none

            case let .filmTapped(film):
                // TCA: Navigation = append a new screen to path (state change only).
                state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))
                // TCA: .none = no Effect; SwiftUI NavigationStack reacts to path change.
                return .none

            case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
                // TCA: Parent intercepts child action from stack and pushes the next screen.
                state.path.append(.personDetail(PersonDetailFeature.State(person: person)))
                return .none

            case .favoriteButtonTapped, .path:
                // TCA: Other .path actions are handled by the child reducer via .forEach below.
                return .none
            }
        }
        // TCA: .forEach = run FilmTabNavigation reducer for each item in state.path.
        .forEach(\.path, action: \.path) {
            FilmTabNavigation(ghibliClient: ghibliClient)
        }
    }
}
