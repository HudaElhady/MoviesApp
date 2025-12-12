//
//  MovieCardView.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//

import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MoviePosterView(posterPath: movie.posterPath, width: 150, height: 225)

            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let year = movie.releaseYear {
                Text(year)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let rating = movie.voteAverage {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
