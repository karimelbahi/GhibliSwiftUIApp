//
//  SettingsStorage.swift
//
//  DI layer: Direct UserDefaults helper — NOT a TCA @Dependency (yet).
//  AppFeature / SettingsFeature call static methods instead of @Dependency(\.settingsStorage).
//

import Foundation

enum SettingsStorage {

    // DI: Reads UserDefaults keys into SettingsFeature.State on app launch.
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

    // DI: Persists SettingsFeature.State when user changes a setting.
    static func save(_ state: SettingsFeature.State) {
        let defaults = UserDefaults.standard
        defaults.set(state.appearanceTheme.rawValue, forKey: UserDefaultsKeys.appearanceTheme)
        defaults.set(state.username, forKey: UserDefaultsKeys.username)
        defaults.set(state.itemsPerPage, forKey: UserDefaultsKeys.itemsPerPage)
        defaults.set(state.notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
    }

    static func reset() -> SettingsFeature.State {
        let state = SettingsFeature.State()
        save(state)
        return state
    }
}
