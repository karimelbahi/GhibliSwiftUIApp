//
//  PersonDetailScreen.swift
//

import ComposableArchitecture
import SwiftUI

struct PersonDetailScreen: View {

    let store: StoreOf<PersonDetailFeature>

    init(store: StoreOf<PersonDetailFeature>) {
        self.store = store
    }

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name", value: store.person.name)
                LabeledContent("Gender", value: store.person.gender)
                LabeledContent("Age", value: store.person.age)
                LabeledContent("Species", value: store.person.species.isEmpty ? "Unknown" : store.person.species)
            }

            Section("Appearance") {
                LabeledContent("Eye Color", value: store.person.eyeColor)
                LabeledContent("Hair Color", value: store.person.hairColor)
            }

            if !store.person.films.isEmpty {
                Section("Film IDs") {
                    ForEach(store.person.films, id: \.self) { filmID in
                        Text(filmID)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(store.person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
