//
//  FilmsViewModelTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct FilmsViewModelTests {

    @MainActor
    private func makeViewModel(useCase: MockFetchFilmsUseCase) -> FilmsViewModel {
        FilmsViewModel(fetchFilmsUseCase: useCase)
    }

    @MainActor
    @Test func initialStateIsIdle() {
        let useCase = MockFetchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        #expect(viewModel.state == .idle)
    }

    @MainActor
    @Test("Fetch loads films successfully")
    func fetchLoadsFilms() async {
        let useCase = MockFetchFilmsUseCase(mockFilms: TestFixtures.films)
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch()

        #expect(viewModel.state.data?.count == TestFixtures.films.count)
        #expect(viewModel.state.data == TestFixtures.films)
    }

    @MainActor
    @Test("Fetch sets domain error message")
    func fetchSetsDomainError() async {
        let useCase = MockFetchFilmsUseCase(
            mockFilms: TestFixtures.films,
            shouldThrowError: true,
            errorToThrow: DomainError.networkUnavailable
        )
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch()

        #expect(viewModel.state.error == DomainError.networkUnavailable.userMessage)
    }

    @MainActor
    @Test("Fetch sets unknown error for non-domain errors")
    func fetchSetsUnknownError() async {
        let useCase = MockFetchFilmsUseCase(
            mockFilms: TestFixtures.films,
            shouldThrowError: true,
            errorToThrow: NSError(domain: "Test", code: -1)
        )
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch()

        #expect(viewModel.state.error == DomainError.unknown.userMessage)
    }

    @MainActor
    @Test("Fetch does not run while already loading")
    func fetchDoesNotRunWhileLoading() async {
        let useCase = MockFetchFilmsUseCase(
            mockFilms: TestFixtures.films,
            fetchDelay: .milliseconds(200)
        )
        let viewModel = makeViewModel(useCase: useCase)

        let firstFetch = Task {
            await viewModel.fetch()
        }

        try? await Task.sleep(for: .milliseconds(50))
        await viewModel.fetch()

        await firstFetch.value

        let callCount = await useCase.executeCallCount
        #expect(callCount == 1)
    }

    @MainActor
    @Test("Fetch retries after error state")
    func fetchRetriesAfterError() async {
        let useCase = MockFetchFilmsUseCase(
            mockFilms: TestFixtures.films,
            failuresBeforeSuccess: 1,
            errorToThrow: DomainError.networkUnavailable
        )
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch()
        #expect(viewModel.state.error != nil)

        await viewModel.fetch()

        #expect(viewModel.state.data == TestFixtures.films)
    }
}
