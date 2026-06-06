//
//  SettingsCoordinator.swift
//

import Observation
import SwiftUI

@MainActor
@Observable
public final class SettingsCoordinator {

    public init() {}

    @ViewBuilder
    public func start() -> some View {
        SettingsScreen()
    }
}
