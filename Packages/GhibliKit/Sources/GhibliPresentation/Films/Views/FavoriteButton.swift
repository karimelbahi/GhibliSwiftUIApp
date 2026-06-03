//
//  FavoriteButton.swift
//

import SwiftUI

public struct FavoriteButton: View {

    let filmID: String
    let favoritesViewModel: FavoritesViewModel

    public init(filmID: String, favoritesViewModel: FavoritesViewModel) {
        self.filmID = filmID
        self.favoritesViewModel = favoritesViewModel
    }

    private var isFavorite: Bool {
        favoritesViewModel.isFavorite(filmID: filmID)
    }

    public var body: some View {
        Button {
            favoritesViewModel.toggleFavorite(filmID: filmID)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? Color.pink : Color.gray)
        }
    }
}
