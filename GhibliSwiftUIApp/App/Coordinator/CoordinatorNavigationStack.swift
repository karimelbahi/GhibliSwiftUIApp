//
//  CoordinatorNavigationStack.swift
//

import SwiftUI

// Reusable wrapper that connects:
// 1) coordinator-owned NavigationPath
// 2) root screen (list/search/favorites)
// 3) pushed destinations (film detail)
struct CoordinatorNavigationStack<Coordinator: FilmNavigationCoordinating, Root: View>: View {

    // @Bindable works only because Coordinator conforms to Observable (@Observable macro).
    // It exposes a two-way binding ($coordinator.path) for NavigationStack push/pop.
    // Flow: path changes -> Observation notifies SwiftUI -> stack updates destination.
    @Bindable var coordinator: Coordinator

    // Closure that builds the first screen in this tab (e.g. FilmsScreen).
    // Receives the coordinator so the root view can read view models from it.
    @ViewBuilder let root: (Coordinator) -> Root

    var body: some View {
        // NavigationStack is bound to coordinator.path (single source of truth for navigation).
        NavigationStack(path: $coordinator.path) {
            // Show the tab's root screen.
            root(coordinator)
                // When a route is pushed, decide which screen to present.
                // STEP 3a: Register how each route maps to a screen.
                .navigationDestination(for: FilmCoordinatorRoute.self) { route in
                    switch route {
                    case .detail(let film):
                        coordinator.filmDetailScreen(for: film)

                    case .personDetail(let person):
                        coordinator.personDetailScreen(for: person)
                    }
                }
        }
    }
}
