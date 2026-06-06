//
//  SearchScreen.swift
//

import SwiftUI

public struct SearchScreen: View {

    @State private var text: String = ""
    let coordinator: SearchCoordinator

    public init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        VStack {
            switch coordinator.searchViewModel.state {
            case .idle:
                Text("Your search results will be shown here.")
                    .foregroundStyle(.secondary)
            case .loading:
                ProgressView()
            case .error(let error):
                Text(error)
            case .loaded(let films):
                FilmListView(
                    films: films,
                    coordinator: coordinator
                )
            }
        }
        .navigationTitle("Search Ghibli Movies")
        .searchable(text: $text)
        .task(id: text) {
            await coordinator.searchViewModel.fetch(for: text)
        }
    }
}
