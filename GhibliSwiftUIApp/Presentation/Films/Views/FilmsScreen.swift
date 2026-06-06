//
//  FilmsScreen.swift
//

import SwiftUI

public struct FilmsScreen: View {

    // Coordinator gives this screen access to view models and navigation context.
    let coordinator: FilmsCoordinator

    public init(coordinator: FilmsCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        Group {
            // UI only: switch on data state from coordinator's view model.
            switch coordinator.filmsViewModel.state {
            case .idle:
                Text("No Films yet")

            case .loading:
                ProgressView {
                    Text("Loading ...")
                }
            case .loaded(let films):
                // List view pushes routes; coordinator resolves destination screen.
                FilmListView(
                    films: films,
                    coordinator: coordinator
                )
            case .error(let error):
                Text(error)
                    .foregroundStyle(.pink)
            }
        }
        // Title only; NavigationStack is owned by FilmsCoordinator.
        .navigationTitle("Ghibli Movies")
    }
}
