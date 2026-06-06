//
//  SettingsCoordinator.swift
//

import Observation
import SwiftUI

// Coordinator for Settings tab.
// Settings has no push navigation today, but this keeps tab structure consistent.
//
// @MainActor: returns SwiftUI views, so it must run on UI thread.
// @Observable: keeps coordinator style consistent across tabs (ready for future navigation state).
@MainActor
@Observable
public final class SettingsCoordinator {

    public init() {}

    // Returns Settings root screen directly (no NavigationPath needed yet).
    @ViewBuilder
    public func start() -> some View {
        SettingsScreen()
    }
}
