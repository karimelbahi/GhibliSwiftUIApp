//
//  PersonDetailFeature.swift
//

import ComposableArchitecture
import Foundation

struct PersonDetailFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var person: Person
    }

    enum Action: Equatable {}

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
