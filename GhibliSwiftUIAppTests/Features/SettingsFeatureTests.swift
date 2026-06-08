//
//  SettingsFeatureTests.swift
//  GhibliSwiftUIAppTests
//

import ComposableArchitecture
import Foundation
import Testing
@testable import GhibliSwiftUIApp

@MainActor
struct SettingsFeatureTests {

    @Test("Reset defaults restores initial values")
    func resetDefaultsRestoresInitialValues() async {
        let store = TestStore(
            initialState: SettingsFeature.State(
                appearanceTheme: .dark,
                username: "Miyazaki",
                itemsPerPage: 50,
                notificationsEnabled: false
            )
        ) {
            SettingsFeature()
        }

        await store.send(.resetDefaults) {
            $0 = SettingsFeature.State()
        }
    }
}
