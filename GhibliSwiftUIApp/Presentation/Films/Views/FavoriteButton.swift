//
//  FavoriteButton.swift
//

import SwiftUI

public struct FavoriteButton: View {

    let isFavorite: Bool
    let action: () -> Void

    public init(isFavorite: Bool, action: @escaping () -> Void) {
        self.isFavorite = isFavorite
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? Color.pink : Color.gray)
        }
    }
}
