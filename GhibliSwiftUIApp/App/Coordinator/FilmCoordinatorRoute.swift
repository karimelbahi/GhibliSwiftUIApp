//
//  FilmCoordinatorRoute.swift
//

import Foundation

// A route is a "destination address" the coordinator can navigate to.
// Think of it like GPS waypoints in the navigation stack.
public enum FilmCoordinatorRoute: Hashable {

    // Push the film detail screen for a specific film.
    // `Film` is attached so the detail screen knows which movie to show.
    case detail(Film)

    // STEP 1: Add a new route case for the new screen.
    // Push person detail when user taps a character on FilmDetailScreen.
    // Note: associated types must be Hashable because NavigationStack routes are Hashable.
    case personDetail(Person)
}
