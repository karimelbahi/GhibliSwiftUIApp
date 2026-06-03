//
//  FilmDetailViewModel.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/7/25.
//

import Foundation
import Observation

@Observable
class FilmDetailViewModel {
    
    var state: LoadingState<[Person]> = .idle
    
    private let fetchFilmPeopleUseCase: FetchFilmPeopleUseCase
    
    init(fetchFilmPeopleUseCase: FetchFilmPeopleUseCase = DefaultFetchFilmPeopleUseCase()) {
        self.fetchFilmPeopleUseCase = fetchFilmPeopleUseCase
    }
    
    func fetch(for film: Film) async {
        guard !state.isLoading else { return }
        
        state = .loading
    
        do {
            let people = try await fetchFilmPeopleUseCase.execute(for: film)
            state = .loaded(people)
        }  catch let error as APIError {
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
}

// MARK: - Preview

extension FilmDetailViewModel {
    static var example: FilmDetailViewModel {
        let vm = FilmDetailViewModel(
            fetchFilmPeopleUseCase: DefaultFetchFilmPeopleUseCase(service: MockGhibliService())
        )
        vm.state = .loaded([
            Person(
                id: "598f7048-74ff-41e0-92ef-87dc1ad980a9",
                name: "Lusheeta Toel Ul Laputa",
                gender: "Female",
                age: "13",
                eyeColor: "Black",
                hairColor: "Black",
                films: [],
                species: "",
                url: ""
            )
        ])
        return vm
    }
}

import Playgrounds

#Playground {
    let service = MockGhibliService()
    let vm = FilmDetailViewModel(fetchFilmPeopleUseCase: DefaultFetchFilmPeopleUseCase(service: service))
    
    let film = service.fetchFilm()
    await vm.fetch(for: film)
    
    switch vm.state {
        case .loading: print("loading")
        case .idle: print("idle")
        case .loaded(let people):
            for person in people {
                print(person)
            }
        case .error(let error): print(error)
    }
    
}
