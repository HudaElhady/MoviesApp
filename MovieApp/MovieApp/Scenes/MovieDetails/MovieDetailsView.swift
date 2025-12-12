//
//  MovieDetailsView.swift
//  MovieApp
//
//  Created by huda elhady on 11/12/2025.
//

import SwiftUI

public struct MovieDetailsView: View {
    @StateObject private var input: MovieDetailsViewModel.Input
    @StateObject private var output: MovieDetailsViewModel.Output
    @Environment(\.dismiss) private var dismiss

    init(viewModel: MovieDetailsViewModelProtocol) {
        self._input = .init(wrappedValue: viewModel.input)
        self._output = .init(wrappedValue: viewModel.output)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                makeLoadingView()
                    .isHidden(!output.isLoading, remove: true)

                if let error = output.error {
                    ErrorView(error: error) {
                        input.retryButtonTrigger.send()
                    }
                } else if let movie = output.movieDetails {
                    makeContentView(movie: movie)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func makeLoadingView() -> some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func makeContentView(movie: MovieDetails) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                backdropSection(movie: movie)
    
                genresSection(movie: movie)
                    .padding()

                overviewSection(movie: movie)
                    .padding()

                detailsGrid(movie: movie)
                    .padding()

                homepageSection(movie: movie)
                    .padding()

                Spacer(minLength: 40)
            }
            
        }
    }

    private func backdropSection(movie: MovieDetails) -> some View {
        CachedAsyncImage(url: backdropURL(movie)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            @unknown default:
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
        }
        .frame(height: 250)
        .clipped()
    }

    private func genresSection(movie: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Genres")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(movie.genres) { genre in
                        Text(genre.name)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.horizontal)
        .isHidden(movie.genres.isEmpty, remove: true)
    }

    private func overviewSection(movie: MovieDetails) -> some View {
        Group {
            if let overview = movie.overview, !overview.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.headline)
                    
                    Text(overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
    }

    private func detailsGrid(movie: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                makeDetailItemView(
                    title: "Budget",
                    value: output.budget
                )
                
                makeDetailItemView(
                    title: "Revenue",
                    value: output.revenue
                )
                
                makeDetailItemView(
                    title: "Status",
                    value: output.movieDetails?.status ?? ""
                )
                
                makeDetailItemView(
                    title: "Spoken Languages",
                    value: output.movieDetails?.spokenLanguages?.map{$0.englishName}.joined(separator: ", ") ?? ""
                )
            }
            .padding(.horizontal)
        }
    }

    private func homepageSection(movie: MovieDetails) -> some View {
        Group {
            if let homepage = movie.homepage, !homepage.isEmpty, let url = URL(string: homepage) {
                Link(destination: url) {
                    HStack {
                        Text("Visit Homepage")

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
    
    func makeDetailItemView(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private func backdropURL(_ movie: MovieDetails) -> URL? {
        guard let backdropPath = movie.backdropPath else { return nil }
        return MovieEndpointConfig.posterURL(path: backdropPath)
    }
}

#Preview {
    MovieDetailsView(viewModel: MovieDetailsViewModel(movieId: 508947))
}
