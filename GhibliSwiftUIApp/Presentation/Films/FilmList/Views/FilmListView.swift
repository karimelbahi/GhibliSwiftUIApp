//
//  FilmListView.swift
//

import SwiftUI

struct FilmListView: View {

    let films: [Film]
    let favoriteIDs: Set<String>
    let itemsPerPage: Int
    // TCA: Callback wired by parent to store.send(.filmTapped) — this view is not TCA-aware.
    let onFilmTapped: (Film) -> Void
    let onFavoriteTapped: (String) -> Void

    init(
        films: [Film],
        favoriteIDs: Set<String>,
        itemsPerPage: Int = 20,
        onFilmTapped: @escaping (Film) -> Void,
        onFavoriteTapped: @escaping (String) -> Void
    ) {
        self.films = films
        self.favoriteIDs = favoriteIDs
        self.itemsPerPage = itemsPerPage
        self.onFilmTapped = onFilmTapped
        self.onFavoriteTapped = onFavoriteTapped
    }

    private var displayedFilms: [Film] {
        Array(films.prefix(itemsPerPage))
    }

    var body: some View {
        List(displayedFilms) { film in
            Button {
                // TCA flow starts here: parent FilmsScreen turns this into store.send(.filmTapped(film)).
                onFilmTapped(film)
            } label: {
                FilmRow(
                    film: film,
                    isFavorite: favoriteIDs.contains(film.id),
                    onFavoriteTapped: { onFavoriteTapped(film.id) }
                )
            }
            .buttonStyle(.plain)
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
