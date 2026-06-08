//
//  FilmDetailFeature.swift
//

import ComposableArchitecture
import Foundation

struct FilmDetailFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var film: Film
        var peopleState: LoadingState<[Person]> = .idle
    }

    enum Action: Equatable {
        case onAppear
        case fetchPeopleResponse(Result<[Person], DomainError>)
    }

    let ghibliClient: GhibliClient

    init(ghibliClient: GhibliClient) {
        self.ghibliClient = ghibliClient
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.peopleState.isLoading else { return .none }
                if case .idle = state.peopleState {
                    state.peopleState = .loading
                }
                let film = state.film
                return .run { [ghibliClient] send in
                    do {
                        let people = try await ghibliClient.fetchPeople(film)
                        await send(.fetchPeopleResponse(.success(people)))
                    } catch let error as DomainError {
                        await send(.fetchPeopleResponse(.failure(error)))
                    } catch {
                        await send(.fetchPeopleResponse(.failure(.unknown)))
                    }
                }

            case let .fetchPeopleResponse(.success(people)):
                state.peopleState = .loaded(people)
                return .none

            case let .fetchPeopleResponse(.failure(error)):
                state.peopleState = .error(error.userMessage)
                return .none
            }
        }
    }
}
