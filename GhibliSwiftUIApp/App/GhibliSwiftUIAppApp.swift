//
//  GhibliSwiftUIAppApp.swift
//  GhibliSwiftUIApp
//

import SwiftUI

@main
struct GhibliSwiftUIAppApp: App {
    private let dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
        }
    }
}
