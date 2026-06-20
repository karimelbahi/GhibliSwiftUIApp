//
//  FilmTabPath.swift
//

import ComposableArchitecture
import Foundation

// TCA: Shared navigation reducer — describes every screen that can be pushed on a tab stack.
struct FilmTabNavigation: Reducer {

    let ghibliClient: GhibliClient

    init(ghibliClient: GhibliClient) {
        self.ghibliClient = ghibliClient
    }

    // TCA: @Reducer enum Path = one enum for all destination types on the stack.
    @Reducer
    enum Path {
        case filmDetail(FilmDetailFeature)
        // TCA: Second stack destination — pushed when parent handles .personTapped from detail.
        case personDetail(PersonDetailFeature)
    }

    // TCA: Path.State / Path.Action are synthesized from the enum cases above.
    typealias State = Path.State
    typealias Action = Path.Action

    var body: some Reducer<State, Action> {
        // TCA: Parent path reducer does no work itself; child reducers handle each case.
        Reduce { _, _ in .none }
            // TCA: CaseKeyPath syntax for @Reducer enum cases (replaces deprecated /State.case).
            .ifCaseLet(\State.Cases.filmDetail, action: \Action.Cases.filmDetail) {
                FilmDetailFeature(ghibliClient: ghibliClient)
            }
            // TCA: ifCaseLet = run PersonDetailFeature when stack item is .personDetail(...).
            .ifCaseLet(\State.Cases.personDetail, action: \Action.Cases.personDetail) {
                PersonDetailFeature()
            }
    }
}

extension FilmTabNavigation.Path.State: Equatable {}
extension FilmTabNavigation.Path.Action: Equatable {}
