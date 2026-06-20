//
//  FilmDetailScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct FilmDetailScreen: View {

    @Bindable var store: StoreOf<FilmDetailFeature>
    let isFavorite: Bool
    let onFavoriteTapped: () -> Void

    init(
        store: StoreOf<FilmDetailFeature>,
        isFavorite: Bool,
        onFavoriteTapped: @escaping () -> Void
    ) {
        self.store = store
        self.isFavorite = isFavorite
        self.onFavoriteTapped = onFavoriteTapped
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 7) {
                FilmImageView(urlPath: store.film.bannerImage)
                    .frame(height: 300)
                    .containerRelativeFrame(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text(store.film.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Grid(alignment: .leading) {
                        InfoRow(label: "Director", value: store.film.director)
                        InfoRow(label: "Producer", value: store.film.producer)
                        InfoRow(label: "Release Date", value: store.film.releaseYear)
                        InfoRow(label: "Running Time", value: "\(store.film.duration) minutes")
                        InfoRow(label: "Score", value: "\(store.film.score)/100")
                    }
                    .padding(.vertical, 8)

                    Divider()

                    Text("Description")
                        .font(.headline)

                    Text(store.film.description)

                    Divider()

                    CharacterSectionView(store: store)
                }
                .padding()
            }
        }
        .toolbar {
            FavoriteButton(isFavorite: isFavorite, action: onFavoriteTapped)
        }
        .task(id: store.film.id) {
            store.send(.onAppear)
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

    @Bindable var store: StoreOf<FilmDetailFeature>

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Characters")
                    .font(.headline)

                switch store.peopleState {
                case .idle:
                    EmptyView()

                case .loading:
                    ProgressView()

                case .loaded(let people):
                    if people.isEmpty {
                        Text("No character data available for this film.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    ForEach(people) { person in
                        Button {
                            store.send(.personTapped(person))
                        } label: {
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
                        .buttonStyle(.plain)
                    }

                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
                }
            }
        }
    }
}
