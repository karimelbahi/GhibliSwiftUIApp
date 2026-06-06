//
//  FilmDetailScreen.swift
//

import SwiftUI

public struct FilmDetailScreen: View {

    let film: Film
    let favoritesViewModel: FavoritesViewModel

    @State private var viewModel: FilmDetailViewModel

    public init(
        film: Film,
        favoritesViewModel: FavoritesViewModel,
        fetchFilmPeopleUseCase: FetchFilmPeopleUseCase
    ) {
        self.film = film
        self.favoritesViewModel = favoritesViewModel
        _viewModel = State(
            initialValue: FilmDetailViewModel(fetchFilmPeopleUseCase: fetchFilmPeopleUseCase)
        )
    }

    public init(
        film: Film,
        favoritesViewModel: FavoritesViewModel,
        viewModel: FilmDetailViewModel
    ) {
        self.film = film
        self.favoritesViewModel = favoritesViewModel
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 7) {
                FilmImageView(urlPath: film.bannerImage)
                    .frame(height: 300)
                    .containerRelativeFrame(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text(film.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Grid(alignment: .leading) {
                        InfoRow(label: "Director", value: film.director)
                        InfoRow(label: "Producer", value: film.producer)
                        InfoRow(label: "Release Date", value: film.releaseYear)
                        InfoRow(label: "Running Time", value: "\(film.duration) minutes")
                        InfoRow(label: "Score", value: "\(film.score)/100")
                    }
                    .padding(.vertical, 8)

                    Divider()

                    Text("Description")
                        .font(.headline)

                    Text(film.description)

                    Divider()

                    CharacterSectionView(viewModel: viewModel)
                }
                .padding()
            }
        }
        .toolbar {
            FavoriteButton(filmID: film.id, favoritesViewModel: favoritesViewModel)
        }
        .task(id: film) {
            await viewModel.fetch(for: film)
        }
    }
}

fileprivate struct InfoRow: View {

    let label: String
    let value: String

    var body: some View {
        GridRow {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.subheadline)
        }
    }
}

fileprivate struct CharacterSectionView: View {

    let viewModel: FilmDetailViewModel

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Characters")
                    .font(.headline)

                switch viewModel.state {
                case .idle: EmptyView()
                case .loading: ProgressView()

                case .loaded(let people):
                    if people.isEmpty {
                        Text("No character data available for this film.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    ForEach(people) { person in
                        // STEP 4: Push a coordinator route (same pattern as FilmListView).
                        // NavigationStack in CoordinatorNavigationStack resolves this route.
                        NavigationLink(value: FilmCoordinatorRoute.personDetail(person)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(person.name)

                                HStack(spacing: 8) {
                                    Label(person.gender, systemImage: "person.fill")
                                    Text("Age: \(person.age)")
                                    Spacer()
                                    Label(person.eyeColor, systemImage: "eye")
                                    Text("Hair: \(person.hairColor)")
                                }
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .lineLimit(1)
                            }
                        }
                    }

                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
        }
    }
}
