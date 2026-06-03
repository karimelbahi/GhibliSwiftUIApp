//
//  FilmImageView.swift
//

import SwiftUI

public struct FilmImageView: View {

    let url: URL?

    public init(urlPath: String) {
        self.url = URL(string: urlPath)
    }

    public init(url: URL?) {
        self.url = url
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Color(white: 0.8)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            case .failure:
                Text("Could not get image")
            @unknown default:
                fatalError()
            }
        }
    }
}
