//
//  SettingsScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct SettingsScreen: View {

    @Bindable var store: StoreOf<SettingsFeature>

    init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: appearanceThemeBinding) {
                        ForEach(AppearanceTheme.allCases) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose light, dark, or follow the system appearance.")
                }

                Section("Account") {
                    TextField("Username", text: usernameBinding)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Preferences") {
                    Stepper(
                        "Items per page: \(store.itemsPerPage)",
                        value: itemsPerPageBinding,
                        in: 10...100,
                        step: 5
                    )
                    Toggle("Enable notifications", isOn: notificationsEnabledBinding)
                }

                Section {
                    Button(role: .destructive) {
                        store.send(.resetDefaults)
                    } label: {
                        Text("Reset to Defaults")
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                store.send(.onAppear)
            }
        }
    }

    private var appearanceThemeBinding: Binding<AppearanceTheme> {
        Binding(
            get: { store.appearanceTheme },
            set: { store.send(.appearanceThemeChanged($0)) }
        )
    }

    private var usernameBinding: Binding<String> {
        Binding(
            get: { store.username },
            set: { store.send(.usernameChanged($0)) }
        )
    }

    private var itemsPerPageBinding: Binding<Int> {
        Binding(
            get: { store.itemsPerPage },
            set: { store.send(.itemsPerPageChanged($0)) }
        )
    }

    private var notificationsEnabledBinding: Binding<Bool> {
        Binding(
            get: { store.notificationsEnabled },
            set: { store.send(.notificationsEnabledChanged($0)) }
        )
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
