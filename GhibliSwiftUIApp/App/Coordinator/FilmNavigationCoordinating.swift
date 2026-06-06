//
//  FilmNavigationCoordinating.swift
//

import Observation
import SwiftUI

// Shared contract for any tab coordinator that can open film detail.
// Films, Favorites, and Search coordinators all conform to this.
//
// @MainActor on protocol:
// - Any conforming coordinator is guaranteed main-thread isolated.
// - Safe to call from SwiftUI views and NavigationStack updates.
//
// Observable requirement:
// - Needed so CoordinatorNavigationStack can use @Bindable coordinator.
// - `@Bindable` only works with types that conform to Observation's Observable protocol.
@MainActor
public protocol FilmNavigationCoordinating: AnyObject, Observable {

    // The navigation stack state (which screens are currently pushed).
    var path: NavigationPath { get set }

    // Needed to build FilmDetailScreen and show favorite button state.
    var favoritesViewModel: FavoritesViewModel { get }

    // Needed to load characters on FilmDetailScreen.
    var fetchFilmPeopleUseCase: FetchFilmPeopleUseCase { get }
}

// Default navigation helpers shared by all conforming coordinators.
extension FilmNavigationCoordinating {

    // Programmatic navigation: push detail without a NavigationLink tap.
    public func showFilmDetail(_ film: Film) {
        // Append a route to the stack; NavigationStack reacts to `path` changes.
        path.append(FilmCoordinatorRoute.detail(film))
    }

    // Factory for the destination screen.
    // Centralizes how FilmDetailScreen is created for every tab.
    @ViewBuilder
    public func filmDetailScreen(for film: Film) -> FilmDetailScreen {
        FilmDetailScreen(
            film: film,
            favoritesViewModel: favoritesViewModel,
            fetchFilmPeopleUseCase: fetchFilmPeopleUseCase
        )
    }

    //showPersonDetail = “push this route”
    //personDetailScreen = “this route means this view”
    
    // STEP 3b (optional): Programmatic navigation to person detail.
    // Same pattern as showFilmDetail(_:), useful for buttons/tasks not using NavigationLink.
    public func showPersonDetail(_ person: Person) {
        path.append(FilmCoordinatorRoute.personDetail(person))
    }

    // STEP 3c: Coordinator factory for the new destination screen.
    @ViewBuilder
    public func personDetailScreen(for person: Person) -> PersonDetailScreen {
        PersonDetailScreen(person: person)
    }
}
