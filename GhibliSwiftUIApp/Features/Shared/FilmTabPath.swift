//
//  FilmTabPath.swift
//

import ComposableArchitecture
import Foundation

struct FilmTabNavigation: Reducer {

    let ghibliClient: GhibliClient

    init(ghibliClient: GhibliClient) {
        self.ghibliClient = ghibliClient
    }

    @Reducer
    enum Path {
        case filmDetail(FilmDetailFeature)
        case personDetail(PersonDetailFeature)
    }

    typealias State = Path.State
    typealias Action = Path.Action

    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
            .ifCaseLet(/State.filmDetail, action: /Action.filmDetail) {
                FilmDetailFeature(ghibliClient: ghibliClient)
            }
            .ifCaseLet(/State.personDetail, action: /Action.personDetail) {
                PersonDetailFeature()
            }
    }
}

extension FilmTabNavigation.Path.State: Equatable {}
extension FilmTabNavigation.Path.Action: Equatable {}
