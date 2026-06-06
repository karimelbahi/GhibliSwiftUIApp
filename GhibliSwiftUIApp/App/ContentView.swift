//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {

    // @State keeps AppCoordinator alive across view re-renders.
    // AppCoordinator is @Observable, so changes inside it can refresh this view tree.
    @State private var coordinator: AppCoordinator

    // Create AppCoordinator from dependency container.
    init(dependencies: AppDependencies) {
        _coordinator = State(initialValue: AppCoordinator(dependencies: dependencies))
    }

    var body: some View {
        // ContentView no longer builds tabs directly; coordinator does that.
        coordinator.rootView
    }
}

#Preview {
    ContentView(dependencies: .preview())
}
