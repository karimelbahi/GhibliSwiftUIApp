//
//  LiveDependencies.swift
//
//  DI layer: Factory — assembles Data-layer types into GhibliClient / FavoritesClient.
//  Does NOT register on a Store; ContentView calls withDependencies after make(...).
//

import ComposableArchitecture  // DI: DependencyValues type used by configure(...).
import Foundation

enum LiveDependencies {

    // DI: Production factory — needs cache from GhibliCacheContainer for offline-first reads.
    @MainActor
    static func make(
        cacheContainer: GhibliCacheContainer,
        useMockService: Bool = false
    ) -> (GhibliClient, FavoritesClient) {
        // DI: Network layer — real URLSession API or in-app mock service.
        let service: GhibliService = useMockService ? MockGhibliService() : DefaultGhibliService()

        // DI: Remote repository — DTO decode + domain mapping from GhibliService.
        let remoteRepository = DefaultGhibliRepository(service: service)

        // DI: Offline-first repo — cacheStore from container + remote for refresh/fallback.
        let ghibliRepository = OfflineFirstGhibliRepository(
            remote: remoteRepository,
            cache: cacheContainer.cacheStore
        )

        // DI: Favorites persistence — UserDefaults via DefaultFavoriteStorage.
        let favoritesRepository = DefaultFavoritesRepository(storage: DefaultFavoriteStorage())

        // DI: Wrap repositories as TCA-friendly client structs (closures only, no types exposed to Features).
        return (
            GhibliClient.live(repository: ghibliRepository),
            FavoritesClient.live(repository: favoritesRepository)
        )
    }

    // DI: Preview factory — mock API + no disk cache (NullGhibliCacheStore) + mock favorite storage.
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

    // DI: Optional — returns a full DependencyValues bag (same clients as make / makePreview).
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
        update(&dependencies)  // DI: Caller can override e.g. $0.continuousClock for tests.
        return dependencies
    }
}
