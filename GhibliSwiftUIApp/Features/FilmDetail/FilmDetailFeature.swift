//
//  FilmDetailFeature.swift
//

import ComposableArchitecture
import Foundation

struct FilmDetailFeature: Reducer {

    // TCA: State for one detail screen on the navigation stack.
    @ObservableState
    struct State: Equatable {
        var film: Film
        var peopleState: LoadingState<[Person]> = .idle
    }

    enum Action: Equatable {
        // TCA: Sent when detail screen appears — triggers .run effect to fetch people.
        case onAppear
        // TCA: Sent by .run effect when network call finishes (success or failure).
        case fetchPeopleResponse(Result<[Person], DomainError>)
        // TCA: User tapped a character — bubbles up via .path to parent for navigation.
        case personTapped(Person)
    }

    let ghibliClient: GhibliClient

    init(ghibliClient: GhibliClient = GhibliClient()) {
        self.ghibliClient = ghibliClient
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.peopleState.isLoading else { return .none }
                if case .idle = state.peopleState {
                    // TCA: Update state immediately so UI shows loading spinner.
                    state.peopleState = .loading
                }
                let film = state.film
                // TCA: .run = async Effect (network). Captures ghibliClient for the task.
                return .run { [ghibliClient] send in
                    do {
                        let people = try await ghibliClient.fetchPeople(film)
                        // TCA: send(...) dispatches a new Action when async work completes.
                        await send(.fetchPeopleResponse(.success(people)))
                    } catch let error as DomainError {
                        await send(.fetchPeopleResponse(.failure(error)))
                    } catch {
                        await send(.fetchPeopleResponse(.failure(.unknown)))
                    }
                }

            case let .fetchPeopleResponse(.success(people)):
                // TCA: Effect result applied to state — UI shows character list.
                state.peopleState = .loaded(people)
                return .none

            case let .fetchPeopleResponse(.failure(error)):
                state.peopleState = .error(error.userMessage)
                return .none

            case .personTapped:
                // TCA: Child does not own StackState — no path.append here.
                //      Action bubbles: .path(.element(..., .filmDetail(.personTapped(person)))).
                //      Parent FilmsFeature performs navigation; effect is .none.
                return .none
            }
        }
    }
}
