//
//  MockFavoriteStorage.swift
//

import Foundation

nonisolated
public struct MockFavoriteStorage: FavoriteStorage {

    public init() {}

    public nonisolated func load() -> Set<String> {
        ["2baf70d1-42bb-4437-b551-e5fed5a87abe"]
    }

    public nonisolated func save(favoriteIDs: Set<String>) {}
}
