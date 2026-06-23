//
//  FavoritesClient.swift
//
//  DI layer: TCA dependency type — load/save favorite film IDs (UserDefaults behind the scenes).
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct FavoritesClient: Sendable {
    var loadFavoriteIDs: @Sendable () -> Set<String> = { [] }
    var saveFavoriteIDs: @Sendable (Set<String>) -> Void = { _ in }
}

extension FavoritesClient {
    // DI: LiveDependencies wires DefaultFavoritesRepository → these two closures.
    static func live(repository: FavoritesRepository) -> FavoritesClient {
        FavoritesClient(
            loadFavoriteIDs: { repository.load() },
            saveFavoriteIDs: { repository.save(favoriteIDs: $0) }
        )
    }
}

extension FavoritesClient: DependencyKey {
    static let liveValue = FavoritesClient()
}

extension DependencyValues {
    var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}
