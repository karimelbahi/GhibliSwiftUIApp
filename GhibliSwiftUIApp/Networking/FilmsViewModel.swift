//
//  FilmsViewModel.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/6/25.
//

import Foundation
import Observation

@Observable
class FilmsViewModel {

    var state: LoadingState<[Film]> = .idle
    
    private let fetchFilmsUseCase: FetchFilmsUseCase
    
    init(fetchFilmsUseCase: FetchFilmsUseCase = DefaultFetchFilmsUseCase()) {
        self.fetchFilmsUseCase = fetchFilmsUseCase
    }
    
    func fetch() async {
        guard !state.isLoading || state.error != nil else { return }
        
        state = .loading
        
        do {
            let films = try await fetchFilmsUseCase.execute()
            self.state = .loaded(films)
        } catch let error as APIError {
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
    
    
// MARK: - Preview
    
    static var example: FilmsViewModel {
        let vm = FilmsViewModel(
            fetchFilmsUseCase: DefaultFetchFilmsUseCase(
                repository: DefaultGhibliRepository(service: MockGhibliService())
            )
        )
        vm.state = .loaded([Film.example, Film.exampleFavorite])
        return vm
    }

}
