//
//  LiveDependencies.swift
//

import Foundation

enum LiveDependencies {

    @MainActor
    static func make(
        cacheContainer: GhibliCacheContainer,
        useMockService: Bool = false
    ) -> (GhibliClient, FavoritesClient) {
        let service: GhibliService = useMockService ? MockGhibliService() : DefaultGhibliService()
        let remoteRepository = DefaultGhibliRepository(service: service)
        let ghibliRepository = OfflineFirstGhibliRepository(
            remote: remoteRepository,
            cache: cacheContainer.cacheStore
        )
        let favoritesRepository = DefaultFavoritesRepository(storage: DefaultFavoriteStorage())

        return (
            GhibliClient.live(repository: ghibliRepository),
            FavoritesClient.live(repository: favoritesRepository)
        )
    }

    @MainActor
    static func makePreview() -> (GhibliClient, FavoritesClient) {
        let remoteRepository = DefaultGhibliRepository(service: MockGhibliService())
        let ghibliRepository = OfflineFirstGhibliRepository(
            remote: remoteRepository,
            cache: NullGhibliCacheStore()
        )
        let favoritesRepository = DefaultFavoritesRepository(storage: MockFavoriteStorage())

        return (
            GhibliClient.live(repository: ghibliRepository),
            FavoritesClient.live(repository: favoritesRepository)
        )
    }
}
