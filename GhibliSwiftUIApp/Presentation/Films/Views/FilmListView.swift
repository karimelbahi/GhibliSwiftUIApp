//
//  FilmListView.swift
//  GhibliSwiftUIApp
//

import SwiftUI

struct FilmListView: View {

    var films: [Film]
    let favoritesViewModel: FavoritesViewModel
    let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase

    var body: some View {
        List(films) { film in
            NavigationLink(value: film) {
                FilmRow(film: film, favoritesViewModel: favoritesViewModel)
            }
        }
        .navigationDestination(for: Film.self) { film in
            FilmDetailScreen(
                film: film,
                favoritesViewModel: favoritesViewModel,
                fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
            )
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

#Preview {
    let dependencies = AppDependencies.preview()
    return NavigationStack {
        FilmListView(
            films: [PreviewData.totoro, PreviewData.castleInTheSky],
            favoritesViewModel: dependencies.favoritesViewModel,
            fetchFilmPeopleUseCase: dependencies.fetchFilmPeopleUseCase
        )
    }
}
