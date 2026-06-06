//
//  CoordinatorNavigationStack.swift
//

import SwiftUI

struct CoordinatorNavigationStack<Coordinator: FilmNavigationCoordinating, Root: View>: View {

    @Bindable var coordinator: Coordinator
    @ViewBuilder let root: (Coordinator) -> Root

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root(coordinator)
                .navigationDestination(for: FilmCoordinatorRoute.self) { route in
                    switch route {
                    case .detail(let film):
                        coordinator.filmDetailScreen(for: film)
                    }
                }
        }
    }
}
