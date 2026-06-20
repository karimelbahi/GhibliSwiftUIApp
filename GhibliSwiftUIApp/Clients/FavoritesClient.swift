//
//  FavoritesClient.swift
//

import ComposableArchitecture
import Foundation

// TCA: @DependencyClient registers this type in DependencyValues (see @Dependency(\.favoritesClient)).
@DependencyClient
struct FavoritesClient: Sendable {
    var loadFavoriteIDs: @Sendable () -> Set<String> = { [] }
    var saveFavoriteIDs: @Sendable (Set<String>) -> Void = { _ in }
}

extension FavoritesClient {
    static func live(repository: FavoritesRepository) -> FavoritesClient {
        FavoritesClient(
            loadFavoriteIDs: { repository.load() },
            saveFavoriteIDs: { repository.save(favoriteIDs: $0) }
        )
    }
}

extension FavoritesClient: DependencyKey {
    // Overridden at the composition root via Store.withDependencies { ... }.
    static let liveValue = FavoritesClient()
}

extension DependencyValues {
    var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}
