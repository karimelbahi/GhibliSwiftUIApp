//
//  FilmListView.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/6/25.
//

import SwiftUI

struct FilmListView: View {
    
    // films: [Film]
    
    var filmsViewModel: FilmsViewModel
    
    var body: some View {
        NavigationStack {
            switch filmsViewModel.state {
                case .idle:
                    Text("No Films yet")

                case .loading:
                    ProgressView {
                        Text("Loading ...")
                    }
                case .loaded(let films):
                    List(films) { film in
                        NavigationLink(value: film) {
                            Text(film.title)
                        }
                        
                    }
                    .navigationDestination(for: Film.self) { film in
                        FilmDetailScreen(film: film)
                    }
                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
            }
        }
        .task {
            await filmsViewModel.fetch()
        }

    }
}

#Preview {
    
    @State @Previewable var vm = FilmsViewModel(service: MockGhibliService())
    
    FilmListView(filmsViewModel: vm)
}
