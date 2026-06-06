//
//  FilmsScreen.swift
//

import SwiftUI

public struct FilmsScreen: View {

    let coordinator: FilmsCoordinator

    public init(coordinator: FilmsCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        Group {
            switch coordinator.filmsViewModel.state {
            case .idle:
                Text("No Films yet")

            case .loading:
                ProgressView {
                    Text("Loading ...")
                }
            case .loaded(let films):
                FilmListView(
                    films: films,
                    coordinator: coordinator
                )
            case .error(let error):
                Text(error)
                    .foregroundStyle(.pink)
            }
        }
        .navigationTitle("Ghibli Movies")
    }
}
