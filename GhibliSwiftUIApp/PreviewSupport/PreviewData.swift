//
//  PreviewData.swift
//  GhibliSwiftUIApp
//

import Foundation

enum PreviewData {

    @MainActor
    static var totoro: Film {
        let bannerURL = URL.convertAssetImage(named: "bannerImage")
        let posterURL = URL.convertAssetImage(named: "posterImage")

        return Film(
            id: "id",
            title: "My Neighbor Totoro",
            description: "Two sisters encounter friendly forest spirits in rural Japan.",
            director: "Hayao Miyazaki",
            producer: "Toru Hara",
            releaseYear: "1988",
            score: "93",
            duration: "86",
            image: posterURL?.absoluteString ?? "",
            bannerImage: bannerURL?.absoluteString ?? "",
            people: ["https://ghibliapi.vercel.app/people/598f7048-74ff-41e0-92ef-87dc1ad980a9"]
        )
    }

    @MainActor
    static var castleInTheSky: Film {
        let bannerURL = URL.convertAssetImage(named: "bannerImage")
        let posterURL = URL.convertAssetImage(named: "posterImage")

        return Film(
            id: "2baf70d1-42bb-4437-b551-e5fed5a87abe",
            title: "Castle in the Sky",
            description: "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa.",
            director: "Hayao Miyazaki",
            producer: "Toru Hara",
            releaseYear: "1988",
            score: "93",
            duration: "86",
            image: posterURL?.absoluteString ?? "",
            bannerImage: bannerURL?.absoluteString ?? "",
            people: ["https://ghibliapi.vercel.app/people/598f7048-74ff-41e0-92ef-87dc1ad980a9"]
        )
    }

    static var samplePerson: Person {
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
    }
}
