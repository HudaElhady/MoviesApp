//
//  MovieListView.swift
//  MovieApp
//
//  Created by huda elhady on 11/12/2025.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var input: MovieListViewModel.Input
    @StateObject private var output: MovieListViewModel.Output

    public init(viewModel: MovieListViewModelProtocol) {
        self._input = .init(wrappedValue: viewModel.input)
        self._output = .init(wrappedValue: viewModel.output)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                if output.error != nil && output.movies.isEmpty {
                    ErrorView(error: output.error!) {
                        input.retryButtonTrigger.send()
                    }
                } else {
                    makeContentView()
                }
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $output.selectedMovie) { movie in
            MovieDetailsView(viewModel: MovieDetailsViewModel(movieId: movie.id))
        }
    }

    private func makeContentView() -> some View {
        VStack(spacing: 0) {
            makeSearchBar()
            
            makeGenreFilterView()
                .isHidden(output.genres.isEmpty, remove: true)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(output.filteredMovies) { movie in
                        MovieCardView(movie: movie)
                            .padding()
                            .onTapGesture {
                                input.selectMovieTrigger.send(movie)
                            }
                            .onAppear {
                                input.movieCardAppearTrigger.send(movie)
                            }
                    }
                }
                .padding()
                
                ProgressView()
                    .padding()
                    .isHidden(!output.isLoading, remove: true)
            }
        }
    }

    private func makeSearchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search movies", text: $input.searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func makeGenreFilterView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Genres")
                    .font(.headline)

                Spacer()

                Button("Clear", action: input.clearFilterButtonTrigger.send)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .isHidden(output.selectedGenres.isEmpty, remove: true)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(output.genres) { genre in
                        makeGenreView(genre)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    func makeGenreView(_ genre: Genre) -> some View {
        Button(action: {
            input.selectGenresTrigger.send(genre)
        }) {
            Text(genre.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    output.selectedGenres.contains(genre.id) ? Color.blue : Color.gray.opacity(0.2)
                )
                .foregroundColor(
                    output.selectedGenres.contains(genre.id) ? .white : .primary
                )
                .cornerRadius(20)
        }
    }
}

#Preview {
    MovieListView(viewModel: MovieListViewModel())
}
