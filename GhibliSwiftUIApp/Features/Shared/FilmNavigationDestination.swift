//
//  FilmNavigationDestination.swift
//

import ComposableArchitecture
import SwiftUI

enum FilmNavigationRoute: Hashable {
    case filmDetail(Film)
    case personDetail(Person)
}

struct FilmNavigationDestinationModifier: ViewModifier {

    let ghibliClient: GhibliClient
    let favoriteIDs: Set<String>
    let onFavoriteTapped: (String) -> Void

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: FilmNavigationRoute.self) { route in
                switch route {
                case let .filmDetail(film):
                    FilmDetailScreen(
                        store: Store(
                            initialState: FilmDetailFeature.State(film: film)
                        ) {
                            FilmDetailFeature(ghibliClient: ghibliClient)
                        },
                        isFavorite: favoriteIDs.contains(film.id),
                        onFavoriteTapped: { onFavoriteTapped(film.id) }
                    )

                case let .personDetail(person):
                    PersonDetailScreen(
                        store: Store(
                            initialState: PersonDetailFeature.State(person: person)
                        ) {
                            PersonDetailFeature()
                        }
                    )
                }
            }
    }
}

struct PersonNavigationDestinationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: FilmNavigationRoute.self) { route in
                if case let .personDetail(person) = route {
                    PersonDetailScreen(
                        store: Store(
                            initialState: PersonDetailFeature.State(person: person)
                        ) {
                            PersonDetailFeature()
                        }
                    )
                }
            }
    }
}

extension View {
    func filmNavigationDestinations(
        ghibliClient: GhibliClient,
        favoriteIDs: Set<String>,
        onFavoriteTapped: @escaping (String) -> Void
    ) -> some View {
        modifier(
            FilmNavigationDestinationModifier(
                ghibliClient: ghibliClient,
                favoriteIDs: favoriteIDs,
                onFavoriteTapped: onFavoriteTapped
            )
        )
    }

    func personNavigationDestination() -> some View {
        modifier(PersonNavigationDestinationModifier())
    }
}
