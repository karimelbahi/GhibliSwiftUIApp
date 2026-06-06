//
//  FilmDetailViewModelTests.swift
//  GhibliSwiftUIAppTests
//

import Foundation
import Testing
@testable import GhibliSwiftUIApp

struct FilmDetailViewModelTests {

    @MainActor
    private func makeViewModel(useCase: MockFetchFilmPeopleUseCase) -> FilmDetailViewModel {
        FilmDetailViewModel(fetchFilmPeopleUseCase: useCase)
    }

    @MainActor
    @Test func initialStateIsIdle() {
        let useCase = MockFetchFilmPeopleUseCase(mockPeople: TestFixtures.people)
        let viewModel = makeViewModel(useCase: useCase)

        #expect(viewModel.state == .idle)
    }

    @MainActor
    @Test("Fetch loads people for film")
    func fetchLoadsPeople() async {
        let useCase = MockFetchFilmPeopleUseCase(mockPeople: TestFixtures.people)
        let viewModel = makeViewModel(useCase: useCase)
        let film = TestFixtures.films[2]

        await viewModel.fetch(for: film)

        #expect(viewModel.state.data == TestFixtures.people)

        let lastFilm = await useCase.lastFilm
        #expect(lastFilm == film)
    }

    @MainActor
    @Test("Fetch sets domain error message")
    func fetchSetsDomainError() async {
        let useCase = MockFetchFilmPeopleUseCase(
            mockPeople: TestFixtures.people,
            shouldThrowError: true,
            errorToThrow: DomainError.notFound
        )
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch(for: TestFixtures.films[0])

        #expect(viewModel.state.error == DomainError.notFound.userMessage)
    }

    @MainActor
    @Test("Fetch sets unknown error for non-domain errors")
    func fetchSetsUnknownError() async {
        let useCase = MockFetchFilmPeopleUseCase(
            mockPeople: TestFixtures.people,
            shouldThrowError: true,
            errorToThrow: NSError(domain: "Test", code: -1)
        )
        let viewModel = makeViewModel(useCase: useCase)

        await viewModel.fetch(for: TestFixtures.films[0])

        #expect(viewModel.state.error == DomainError.unknown.userMessage)
    }

    @MainActor
    @Test("Fetch does not run while already loading")
    func fetchDoesNotRunWhileLoading() async {
        let useCase = MockFetchFilmPeopleUseCase(
            mockPeople: TestFixtures.people,
            fetchDelay: .milliseconds(200)
        )
        let viewModel = makeViewModel(useCase: useCase)
        let film = TestFixtures.films[0]

        let firstFetch = Task {
            await viewModel.fetch(for: film)
        }

        try? await Task.sleep(for: .milliseconds(50))
        await viewModel.fetch(for: film)

        await firstFetch.value

        let callCount = await useCase.executeCallCount
        #expect(callCount == 1)
    }
}
