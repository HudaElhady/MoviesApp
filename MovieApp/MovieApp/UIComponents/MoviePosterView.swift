//
//  MoviePosterView.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//

import SwiftUI

public struct MoviePosterView: View {
    let posterPath: String?
    let width: CGFloat
    let height: CGFloat
    
    public init(posterPath: String?, width: CGFloat = 150, height: CGFloat = 225) {
        self.posterPath = posterPath
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        CachedAsyncImage(url: posterURL) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
        .frame(width: width, height: height)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return MovieEndpointConfig.posterURL(path: posterPath)
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "photo")
                .foregroundColor(.gray)
                .font(.system(size: 40))
        }
    }
}
