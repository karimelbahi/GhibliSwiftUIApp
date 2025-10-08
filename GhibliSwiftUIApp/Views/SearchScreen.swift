//
//  SearchScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Karin Prater on 10/8/25.
//

import SwiftUI

struct SearchScreen: View {
    
    @State private var text: String = ""
    
    var body: some View {
        NavigationStack {
            Text("Show search here")
                .searchable(text: $text)
        }
    }
}

#Preview {
    SearchScreen()
}
