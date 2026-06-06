//
//  FilmNavigationCoordinating.swift
//

import Observation
import SwiftUI

@MainActor
public protocol FilmNavigationCoordinating: AnyObject, Observable {
    var path: NavigationPath { get set }
    var favoritesViewModel: FavoritesViewModel { get }
    var fetchFilmPeopleUseCase: FetchFilmPeopleUseCase { get }
}

extension FilmNavigationCoordinating {
    public func showFilmDetail(_ film: Film) {
        path.append(FilmCoordinatorRoute.detail(film))
    }

    @ViewBuilder
    public func filmDetailScreen(for film: Film) -> FilmDetailScreen {
        FilmDetailScreen(
            film: film,
            favoritesViewModel: favoritesViewModel,
            fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
        )
    }
}
