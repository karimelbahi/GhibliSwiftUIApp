//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {

    @State private var coordinator: AppCoordinator

    init(dependencies: AppDependencies) {
        _coordinator = State(initialValue: AppCoordinator(dependencies: dependencies))
    }

    var body: some View {
        coordinator.rootView
    }
}

#Preview {
    ContentView(dependencies: .preview())
}
