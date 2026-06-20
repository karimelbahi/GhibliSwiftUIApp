//
//  LiveDependencies.swift
//

import ComposableArchitecture
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

    /// Wires live clients into TCA's dependency context for a root store or preview.
    @MainActor
    static func configure(
        cacheContainer: GhibliCacheContainer? = nil,
        useMockService: Bool = false,
        _ update: (inout DependencyValues) -> Void = { _ in }
    ) -> DependencyValues {
        var dependencies = DependencyValues()
        let (ghibliClient, favoritesClient): (GhibliClient, FavoritesClient)
        if let cacheContainer {
            (ghibliClient, favoritesClient) = make(
                cacheContainer: cacheContainer,
                useMockService: useMockService
            )
        } else {
            (ghibliClient, favoritesClient) = makePreview()
        }
        dependencies.ghibliClient = ghibliClient
        dependencies.favoritesClient = favoritesClient
        update(&dependencies)
        return dependencies
    }
}
