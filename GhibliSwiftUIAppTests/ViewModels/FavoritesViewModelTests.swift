//
//  FavoritesViewModelTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct FavoritesViewModelTests {

    @MainActor
    private func makeViewModel(useCase: MockManageFavoritesUseCase) -> FavoritesViewModel {
        FavoritesViewModel(manageFavoritesUseCase: useCase)
    }

    @MainActor
    @Test func initialStateHasNoFavorites() {
        let useCase = MockManageFavoritesUseCase()
        let viewModel = makeViewModel(useCase: useCase)

        #expect(viewModel.favoriteIDs.isEmpty)
    }

    @MainActor
    @Test("Load populates favorites from use case")
    func loadPopulatesFavorites() {
        let useCase = MockManageFavoritesUseCase(storedFavorites: ["1", "2"])
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.load()

        #expect(viewModel.favoriteIDs == ["1", "2"])
        #expect(useCase.loadCallCount == 1)
    }

    @MainActor
    @Test("Toggle favorite adds and removes film")
    func toggleFavoriteAddsAndRemoves() {
        let useCase = MockManageFavoritesUseCase()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.toggleFavorite(filmID: "1")
        #expect(viewModel.isFavorite(filmID: "1"))
        #expect(useCase.saveCallCount == 1)
        #expect(useCase.storedFavorites == ["1"])

        viewModel.toggleFavorite(filmID: "1")
        #expect(!viewModel.isFavorite(filmID: "1"))
        #expect(useCase.saveCallCount == 2)
        #expect(useCase.storedFavorites.isEmpty)
    }

    @MainActor
    @Test("Is favorite reflects current state")
    func isFavoriteReflectsState() {
        let useCase = MockManageFavoritesUseCase(storedFavorites: ["2"])
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.load()

        #expect(!viewModel.isFavorite(filmID: "1"))
        #expect(viewModel.isFavorite(filmID: "2"))
    }
}
