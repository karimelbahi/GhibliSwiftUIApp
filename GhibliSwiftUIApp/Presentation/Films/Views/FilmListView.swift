//
//  FilmListView.swift
//

import SwiftUI

struct FilmListView: View {

    let films: [Film]
    let favoriteIDs: Set<String>
    let itemsPerPage: Int
    let navigationRoute: (Film) -> FilmNavigationRoute
    let onFavoriteTapped: (String) -> Void

    init(
        films: [Film],
        favoriteIDs: Set<String>,
        itemsPerPage: Int = 20,
        navigationRoute: @escaping (Film) -> FilmNavigationRoute,
        onFavoriteTapped: @escaping (String) -> Void
    ) {
        self.films = films
        self.favoriteIDs = favoriteIDs
        self.itemsPerPage = itemsPerPage
        self.navigationRoute = navigationRoute
        self.onFavoriteTapped = onFavoriteTapped
    }

    private var displayedFilms: [Film] {
        Array(films.prefix(itemsPerPage))
    }

    var body: some View {
        List(displayedFilms) { film in
            NavigationLink(value: navigationRoute(film)) {
                FilmRow(
                    film: film,
                    isFavorite: favoriteIDs.contains(film.id),
                    onFavoriteTapped: { onFavoriteTapped(film.id) }
                )
            }
        }
    }
}

private struct FilmRow: View {

    let film: Film
    let isFavorite: Bool
    let onFavoriteTapped: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            FilmImageView(urlPath: film.image)
                .frame(width: 100, height: 150)

            VStack(alignment: .leading) {
                HStack {
                    Text(film.title)
                        .bold()

                    Spacer()
                    FavoriteButton(isFavorite: isFavorite, action: onFavoriteTapped)
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
