//
//  FavoritesViewModel.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/8/25.
//

import Foundation
import Observation

@Observable
class FavoritesViewModel {
    
    private(set) var favoriteIDs: Set<String> = []
    
    private let manageFavoritesUseCase: ManageFavoritesUseCase
  
    init(manageFavoritesUseCase: ManageFavoritesUseCase = DefaultManageFavoritesUseCase()) {
        self.manageFavoritesUseCase = manageFavoritesUseCase
    }
    
    func load() {
        favoriteIDs = manageFavoritesUseCase.load()
    }
    
    private func save() {
        manageFavoritesUseCase.save(favoriteIDs: favoriteIDs)
    }
    
    func toggleFavorite(filmID: String) {
        if favoriteIDs.contains(filmID) {
            favoriteIDs.remove(filmID)
        } else {
            favoriteIDs.insert(filmID)
        }
        
        save()
    }
    
    
    func isFavorite(filmID: String) -> Bool {
        favoriteIDs.contains(filmID)
    }
    
    //MARK: - preview
    static var example: FavoritesViewModel {
        let vm = FavoritesViewModel(
            manageFavoritesUseCase: DefaultManageFavoritesUseCase(
                repository: DefaultFavoritesRepository(storage: MockFavoriteStorage())
            )
        )
        vm.favoriteIDs = ["2baf70d1-42bb-4437-b551-e5fed5a87abe"]
        
        return vm
    }
    
}
