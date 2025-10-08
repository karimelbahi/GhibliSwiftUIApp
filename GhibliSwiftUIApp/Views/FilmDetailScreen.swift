//
//  FilmDetailScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/7/25.
//

import SwiftUI

struct FilmDetailScreen: View {
    
    let film: Film
    
    @State private var viewModel = FilmDetailViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(film.title)
         
            Divider()
            
            Text("Characters")
                .font(.title3)
            
            switch viewModel.state {
                case .idle: EmptyView()
                case .loading:  ProgressView()
                    
                case .loaded(let people):
                    ForEach(people) { person in
                        Text(person.name)
                    }
                    
                case .error(let error):
                    Text(error)
                        .foregroundStyle(.pink)
            }
        }
        .padding()
        .task(id: film) {
           await viewModel.fetch(for: film)
        }
    }
}

#Preview {
    FilmDetailScreen(film: Film.example)
}
