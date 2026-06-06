//
//  PersonDetailScreen.swift
//  STEP 2: Create the new screen (UI only, no navigation logic here).
//

import SwiftUI

public struct PersonDetailScreen: View {

    let person: Person

    public init(person: Person) {
        self.person = person
    }

    public var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name", value: person.name)
                LabeledContent("Gender", value: person.gender)
                LabeledContent("Age", value: person.age)
                LabeledContent("Species", value: person.species.isEmpty ? "Unknown" : person.species)
            }

            Section("Appearance") {
                LabeledContent("Eye Color", value: person.eyeColor)
                LabeledContent("Hair Color", value: person.hairColor)
            }

            if !person.films.isEmpty {
                Section("Film IDs") {
                    ForEach(person.films, id: \.self) { filmID in
                        Text(filmID)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
