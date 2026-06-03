//
//  SettingsScreen.swift
//

import SwiftUI

public struct SettingsScreen: View {

    @AppStorage(UserDefaultsKeys.appearanceTheme)
    private var appearanceTheme: AppearanceTheme = .system

    @AppStorage(UserDefaultsKeys.username)
    private var username: String = ""

    @AppStorage(UserDefaultsKeys.itemsPerPage)
    private var itemsPerPage: Int = 20

    @AppStorage(UserDefaultsKeys.notificationsEnabled)
    private var notificationsEnabled: Bool = true

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: $appearanceTheme) {
                        ForEach(AppearanceTheme.allCases) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Overrides the system appearance to always use Light.")
                }

                Section("Account") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Preferences") {
                    Stepper("Items per page: \(itemsPerPage)", value: $itemsPerPage, in: 10...100, step: 5)
                    Toggle("Enable notifications", isOn: $notificationsEnabled)
                }

                Section {
                    Button(role: .destructive) {
                        resetDefaults()
                    } label: {
                        Text("Reset to Defaults")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func resetDefaults() {
        appearanceTheme = .system
        username = ""
        itemsPerPage = 20
        notificationsEnabled = true
    }
}

public enum AppearanceTheme: String, Identifiable, CaseIterable {
    case system
    case light
    case dark
    public var id: Self { self }
}

public enum UserDefaultsKeys {
    public static let appearanceTheme = "appearanceTheme"
    public static let username = "username"
    public static let itemsPerPage = "itemsPerPage"
    public static let notificationsEnabled = "notificationsEnabled"
}

public extension View {
    func setAppearanceTheme() -> some View {
        modifier(AppearanceThemeViewModifier())
    }
}

public struct AppearanceThemeViewModifier: ViewModifier {

    @AppStorage(UserDefaultsKeys.appearanceTheme) private var appearanceTheme: AppearanceTheme = .system

    public init() {}

    public func body(content: Content) -> some View {
        content
            .preferredColorScheme(scheme())
    }

    private func scheme() -> ColorScheme? {
        switch appearanceTheme {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}
