//
//  FilmTabPath.swift
//
//  DI layer: Navigation composer — no @Dependency here; children read dependencies themselves.
//

import ComposableArchitecture
import Foundation

struct FilmTabNavigation: Reducer {

    @Reducer
    enum Path {
        case filmDetail(FilmDetailFeature)   // DI: Uses @Dependency(\.ghibliClient) internally.
        case personDetail(PersonDetailFeature) // DI: No dependencies — display-only reducer.
    }

    typealias State = Path.State
    typealias Action = Path.Action

    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
            // DI: FilmDetailFeature() — no ghibliClient arg; inherits Store's DependencyValues.
            .ifCaseLet(\State.Cases.filmDetail, action: \Action.Cases.filmDetail) {
                FilmDetailFeature()
            }
            // DI: PersonDetailFeature has no @Dependency properties.
            .ifCaseLet(\State.Cases.personDetail, action: \Action.Cases.personDetail) {
                PersonDetailFeature()
            }
    }
}

extension FilmTabNavigation.Path.State: Equatable {}
extension FilmTabNavigation.Path.Action: Equatable {}
