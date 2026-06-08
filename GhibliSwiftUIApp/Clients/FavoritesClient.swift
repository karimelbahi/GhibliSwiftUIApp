//
//  FavoritesClient.swift
//

import Foundation

struct FavoritesClient: Sendable {
    var loadFavoriteIDs: @Sendable () -> Set<String>
    var saveFavoriteIDs: @Sendable (Set<String>) -> Void

    init(
        loadFavoriteIDs: @escaping @Sendable () -> Set<String> = { [] },
        saveFavoriteIDs: @escaping @Sendable (Set<String>) -> Void = { _ in }
    ) {
        self.loadFavoriteIDs = loadFavoriteIDs
        self.saveFavoriteIDs = saveFavoriteIDs
    }
}

extension FavoritesClient {
    static func live(repository: FavoritesRepository) -> FavoritesClient {
        FavoritesClient(
            loadFavoriteIDs: { repository.load() },
            saveFavoriteIDs: { repository.save(favoriteIDs: $0) }
        )
    }
}
