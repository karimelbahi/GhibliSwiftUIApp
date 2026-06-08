//
//  SettingsStorage.swift
//

import Foundation

enum SettingsStorage {

    static func load() -> SettingsFeature.State {
        let defaults = UserDefaults.standard
        let themeRaw = defaults.string(forKey: UserDefaultsKeys.appearanceTheme) ?? AppearanceTheme.system.rawValue
        let appearanceTheme = AppearanceTheme(rawValue: themeRaw) ?? .system

        let storedItemsPerPage = defaults.integer(forKey: UserDefaultsKeys.itemsPerPage)
        let itemsPerPage = storedItemsPerPage == 0 ? 20 : storedItemsPerPage

        return SettingsFeature.State(
            appearanceTheme: appearanceTheme,
            username: defaults.string(forKey: UserDefaultsKeys.username) ?? "",
            itemsPerPage: itemsPerPage,
            notificationsEnabled: defaults.object(forKey: UserDefaultsKeys.notificationsEnabled) as? Bool ?? true
        )
    }

    static func save(_ state: SettingsFeature.State) {
        let defaults = UserDefaults.standard
        defaults.set(state.appearanceTheme.rawValue, forKey: UserDefaultsKeys.appearanceTheme)
        defaults.set(state.username, forKey: UserDefaultsKeys.username)
        defaults.set(state.itemsPerPage, forKey: UserDefaultsKeys.itemsPerPage)
        defaults.set(state.notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
    }

    static func reset() -> SettingsFeature.State {
        var state = SettingsFeature.State()
        save(state)
        return state
    }
}
