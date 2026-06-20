//
//  FavoritesFeature.swift
//

import ComposableArchitecture
import Foundation

struct FavoritesFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var filmsState: LoadingState<[Film]> = .idle
        var favoriteIDs: Set<String> = []
        var path = StackState<FilmTabNavigation.State>()
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case fetchFilmsResponse(Result<[Film], DomainError>)
        case favoriteButtonTapped(String)
        case filmTapped(Film)
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
                state.path.append(.filmDetail(FilmDetailFeature.State(film: film)))
                return .none

            case let .path(.element(id: _, action: .filmDetail(.personTapped(person)))):
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
