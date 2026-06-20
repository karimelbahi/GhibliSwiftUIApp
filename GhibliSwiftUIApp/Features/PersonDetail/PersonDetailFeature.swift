//
//  PersonDetailFeature.swift
//

import ComposableArchitecture
import Foundation

// TCA: Display-only reducer for a person screen pushed onto the tab navigation stack.
struct PersonDetailFeature: Reducer {

    // TCA: @ObservableState — SwiftUI observes person data for PersonDetailScreen.
    @ObservableState
    struct State: Equatable {
        // TCA: Person passed in when parent appends .personDetail(...) to path.
        var person: Person
    }

    // TCA: No actions — profile is read-only; no store.send from this screen.
    enum Action: Equatable {}

    var body: some Reducer<State, Action> {
        // TCA: EmptyReducer = no logic and no effects (.none only).
        EmptyReducer()
    }
}
