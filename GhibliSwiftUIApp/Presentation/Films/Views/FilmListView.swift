//
//  FilmListView.swift
//

import SwiftUI

// Generic so the same list works in Movies, Favorites, and Search tabs.
public struct FilmListView<Coordinator: FilmNavigationCoordinating>: View {

    let films: [Film]
    // Coordinator handles navigation + favorites access.
    let coordinator: Coordinator

    public init(
        films: [Film],
        coordinator: Coordinator
    ) {
        self.films = films
        self.coordinator = coordinator
    }

    public var body: some View {
        List(films) { film in
            // Push a coordinator route (not Film directly).
            // CoordinatorNavigationStack converts route -> FilmDetailScreen.
            NavigationLink(value: FilmCoordinatorRoute.detail(film)) {
                FilmRow(
                    film: film,
                    favoritesViewModel: coordinator.favoritesViewModel
                )
            }
        }
    }
}

private struct FilmRow: View {

    let film: Film
    let favoritesViewModel: FavoritesViewModel

    var body: some View {
        HStack(alignment: .top) {
            FilmImageView(urlPath: film.image)
                .frame(width: 100, height: 150)

            VStack(alignment: .leading) {
                HStack {
                    Text(film.title)
                        .bold()

                    Spacer()
                    FavoriteButton(filmID: film.id, favoritesViewModel: favoritesViewModel)
                        .buttonStyle(.plain)
                        .controlSize(.large)
                }
                .padding(.bottom, 5)

                Text("Directed by \(film.director)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Released: \(film.releaseYear)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
    }
}
