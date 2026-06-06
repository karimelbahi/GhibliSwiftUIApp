//
//  SearchFilmsViewModelTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct SearchFilmsViewModelTests {

    @MainActor
    private func makeViewModel(useCase: MockSearchFilmsUseCase) -> SearchFilmsViewModel {
        SearchFilmsViewModel(searchFilmsUseCase: useCase)
    }

    @MainActor
    @Test func initialStateIsIdle() async {
        let useCase = MockSearchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        #expect(viewModel.state.data == nil)
        #expect(viewModel.state == .idle)
    }

    @MainActor
    @Test("Search with query filters results")
    func searchWithQuery() async {
        let useCase = MockSearchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch(for: "Totoro")

        #expect(viewModel.state.data?.count == 1)
        #expect(viewModel.state.data?.first?.title == "My Neighbor Totoro")
    }

    @MainActor
    @Test("Empty search term resets to idle")
    func emptySearchTermResetsToIdle() async {
        let useCase = MockSearchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch(for: "")

        #expect(viewModel.state == .idle)

        let callCount = await useCase.executeCallCount
        #expect(callCount == 0)
    }

    @MainActor
    @Test("Search result gives error")
    func searchWithError() async {
        let useCase = MockSearchFilmsUseCase(
            mockFilms: TestFixtures.films,
            shouldThrowError: true
        )
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch(for: "Totoro")

        #expect(viewModel.state.error != nil)
    }

    @MainActor
    @Test("Task cancellation after API call prevents state update")
    func cancellationAfterAPICall() async {
        let useCase = MockSearchFilmsUseCase(
            mockFilms: TestFixtures.films,
            fetchDelay: .milliseconds(100)
        )
        let viewModel = makeViewModel(useCase: useCase)

        let task = Task {
            await viewModel.fetch(for: "tot")
        }

        try? await Task.sleep(for: .milliseconds(550))
        task.cancel()
        await task.value

        let callCount = await useCase.executeCallCount
        let lastSearchTerm = await useCase.lastSearchTerm

        #expect(callCount == 1)
        #expect(lastSearchTerm == "tot")
        #expect(viewModel.state.error != nil)
    }

    @MainActor
    @Test("Task cancelled before debounce does not call use case")
    func debounceTiming() async {
        let useCase = MockSearchFilmsUseCase(
            mockFilms: TestFixtures.films,
            fetchDelay: .milliseconds(100)
        )
        let viewModel = makeViewModel(useCase: useCase)

        let task = Task {
            await viewModel.fetch(for: "tot")
        }

        try? await Task.sleep(for: .milliseconds(450))
        task.cancel()
        await task.value

        let callCount = await useCase.executeCallCount
        let lastSearchTerm = await useCase.lastSearchTerm

        #expect(callCount == 0)
        #expect(lastSearchTerm == nil)
        #expect(viewModel.state == .idle)
    }

    @MainActor
    @Test("Multiple rapid searches only execute the last one")
    func debounceWithMultipleSearches() async {
        let useCase = MockSearchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        let searchQueries = ["t", "to", "tot", "toto", "totor", "totoro"]
        var tasks: [Task<Void, Never>] = []

        for query in searchQueries {
            tasks.last?.cancel()

            let task = Task {
                await viewModel.fetch(for: query)
            }
            tasks.append(task)

            try? await Task.sleep(for: .milliseconds(50))
        }

        await tasks.last?.value

        let callCount = await useCase.executeCallCount
        let lastSearchTerm = await useCase.lastSearchTerm

        #expect(callCount == 1)
        #expect(lastSearchTerm == "totoro")
        #expect(viewModel.state.data?.count == 1)
        #expect(viewModel.state.data?.first?.title == "My Neighbor Totoro")
    }

    @MainActor
    @Test("Multiple slow searches execute all")
    func debounceWithSlowMultipleSearches() async {
        let useCase = MockSearchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        let searchQueries = ["tot", "totor", "totoro"]
        var tasks: [Task<Void, Never>] = []

        for query in searchQueries {
            tasks.last?.cancel()

            let task = Task {
                await viewModel.fetch(for: query)
            }
            tasks.append(task)

            try? await Task.sleep(for: .milliseconds(550))
        }

        await tasks.last?.value

        let callCount = await useCase.executeCallCount
        let lastSearchTerm = await useCase.lastSearchTerm

        #expect(callCount == 3)
        #expect(lastSearchTerm == "totoro")
        #expect(viewModel.state.data?.count == 1)
        #expect(viewModel.state.data?.first?.title == "My Neighbor Totoro")
    }
}
