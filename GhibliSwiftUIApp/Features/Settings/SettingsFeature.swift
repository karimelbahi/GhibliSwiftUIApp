//
//  SettingsFeature.swift
//

import ComposableArchitecture
import Foundation

struct SettingsFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var appearanceTheme: AppearanceTheme = .system
        var username: String = ""
        var itemsPerPage: Int = 20
        var notificationsEnabled: Bool = true
    }

    enum Action: Equatable {
        case onAppear
        case appearanceThemeChanged(AppearanceTheme)
        case usernameChanged(String)
        case itemsPerPageChanged(Int)
        case notificationsEnabledChanged(Bool)
        case resetDefaults
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state = SettingsStorage.load()
                return .none

            case let .appearanceThemeChanged(theme):
                state.appearanceTheme = theme
                SettingsStorage.save(state)
                return .none

            case let .usernameChanged(username):
                state.username = username
                SettingsStorage.save(state)
                return .none

            case let .itemsPerPageChanged(itemsPerPage):
                state.itemsPerPage = itemsPerPage
                SettingsStorage.save(state)
                return .none

            case let .notificationsEnabledChanged(isEnabled):
                state.notificationsEnabled = isEnabled
                SettingsStorage.save(state)
                return .none

            case .resetDefaults:
                state = SettingsStorage.reset()
                return .none
            }
        }
    }
}
