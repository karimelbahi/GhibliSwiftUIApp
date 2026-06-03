//
//  SearchFilmsViewModel.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/8/25.
//

import Foundation
import Observation

@Observable
class SearchFilmsViewModel {
    
    var state: LoadingState<[Film]> = .idle
    private var currentSearchTerm: String = ""
    
    private let searchFilmsUseCase: SearchFilmsUseCase
    
    init(searchFilmsUseCase: SearchFilmsUseCase = DefaultSearchFilmsUseCase()) {
        self.searchFilmsUseCase = searchFilmsUseCase
    }
    
    func fetch(for searchTerm: String) async {
        
        self.currentSearchTerm = searchTerm
        
        guard !searchTerm.isEmpty else {
            state = .idle
            return
        }
        
        state = .loading
        
        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else {
            if currentSearchTerm == searchTerm {
                state = .idle
            }
            return
        }
        
        do {
            let films = try await searchFilmsUseCase.execute(searchTerm: searchTerm)
            self.state = .loaded(films)
        } catch {
            setError(error, for: searchTerm)
        }
    }
    
    func setError(_ error: Error, for searchTerm: String) {
        
        guard currentSearchTerm == searchTerm else { return }
        
        if let error = error as? APIError {
            self.state = .error(error.errorDescription ?? "unknown error")
        } else {
            self.state = .error("unknown error")
        }
        
    }
    
// MARK: - Preview
    
    static var example: SearchFilmsViewModel {
        let vm = SearchFilmsViewModel(
            searchFilmsUseCase: DefaultSearchFilmsUseCase(
                repository: DefaultGhibliRepository(service: MockGhibliService())
            )
        )
        vm.state = .loaded([Film.example])
        return vm
    }
    
}

