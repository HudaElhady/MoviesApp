//
//  MovieListViewModel.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//

import Foundation
import Combine

protocol MovieListViewModelProtocol {
    var input: MovieListViewModel.Input { get }
    var output: MovieListViewModel.Output { get }
}

extension MovieListViewModel {
    class Input: ObservableObject {
        @Published public var searchText: String = ""

        var retryButtonTrigger = PassthroughSubject<Void, Never>()
        var movieCardAppearTrigger = PassthroughSubject<Movie, Never>()
        var selectMovieTrigger = PassthroughSubject<Movie, Never>()
        var selectGenresTrigger = PassthroughSubject<Genre, Never>()
        var clearFilterButtonTrigger = PassthroughSubject<Void, Never>()
    }
}

extension MovieListViewModel {
    class Output: ObservableObject {
        @Published public var movies: [Movie] = []
        @Published public var filteredMovies: [Movie] = []
        @Published public var genres: [Genre] = []
        @Published public var selectedGenres: Set<Int> = []
        @Published public var isLoading = false
        @Published public var error: Error?
        @Published public var hasMorePages = true
        @Published public var selectedMovie: Movie?
    }
}
public final class MovieListViewModel: MovieListViewModelProtocol {
    var input: Input
    var output: Output

    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let repository: MovieRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    public init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.input = .init()
        self.output = .init()
        self.repository = repository
        
        setupObservers()
        loadGenres()
        loadMovies()
    }
}

private extension MovieListViewModel {
    func setupObservers() {
        observerRetryButtonTrigger()
        observerMovieCardAppearTrigger()
        observerSearchText()
        observerSelectGenresTrigger()
        observerClearFilterButtonTrigger()
        observerSelectMovieTrigger()
    }
    
    func observerRetryButtonTrigger() {
        input
            .retryButtonTrigger
            .sink { [weak self] in
                guard let self else { return }
                retry()
            }
            .store(in: &cancellables)
    }
    
    func observerMovieCardAppearTrigger() {
        input
            .movieCardAppearTrigger
            .sink { [weak self] movie in
                guard let self else { return }
                shouldLoadMore(currentMovie: movie)
            }
            .store(in: &cancellables)
    }
    
    func observerSearchText() {
        input
            .$searchText
            .sink { [weak self] _ in
                guard let self else { return }
                filterMovies()
            }
            .store(in: &cancellables)
    }
    
    func observerSelectGenresTrigger() {
        input
            .selectGenresTrigger
            .sink { [weak self] genre in
                guard let self else { return }

                if output.selectedGenres.contains(genre.id) {
                    output.selectedGenres.remove(genre.id)
                } else {
                    output.selectedGenres.insert(genre.id)
                }

                filterMovies()
            }
            .store(in: &cancellables)
    }
    
    func observerClearFilterButtonTrigger() {
        input
            .clearFilterButtonTrigger
            .sink { [weak self] genre in
                guard let self else { return }

                output.selectedGenres.removeAll()
                input.searchText = ""
            }
            .store(in: &cancellables)
    }
    
    func observerSelectMovieTrigger() {
        input
            .selectMovieTrigger
            .sink { [weak self] movie in
                guard let self else { return }

                output.selectedMovie = movie
            }
            .store(in: &cancellables)
    }
}

private extension MovieListViewModel {
    func retry() {
        output.error = nil
        if output.movies.isEmpty {
            currentPage = 1
            output.hasMorePages = true
            loadMovies()
        }
    }
    
    func shouldLoadMore(currentMovie: Movie) {
        let thresholdIndex = output.filteredMovies.index(output.filteredMovies.endIndex, offsetBy: -5)
        if let index = output.filteredMovies.firstIndex(where: { $0.id == currentMovie.id }),
           index >= thresholdIndex {
            loadMovies()
        }
    }
    
    func filterMovies() {
        searchTask?.cancel()

        searchTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            guard !Task.isCancelled else { return }
            
            var filtered = output.movies

            if !input.searchText.isEmpty {
                filtered = filtered.filter { movie in
                    movie.title.localizedCaseInsensitiveContains(input.searchText)
                }
            }

            if !output.selectedGenres.isEmpty {
                filtered = filtered.filter { movie in
                    guard let genreIds = movie.genreIds else { return false }
                    return !Set(genreIds).isDisjoint(with: output.selectedGenres)
                }
            }
            
            output.filteredMovies = filtered
        }
    }
    
    func loadGenres() {
        Task { @MainActor in
            do {
                output.genres = try await repository.fetchGenres()
            } catch {
                output.error = error
            }
        }
    }

    func loadMovies() {
        guard !output.isLoading && output.hasMorePages else { return }
        
        output.isLoading = true
        output.error = nil
    
        Task { @MainActor in
            do {
                let response = try await repository.fetchMovies(page: currentPage)
                output.movies.append(contentsOf: response.results)
                output.hasMorePages = currentPage < response.totalPages
                currentPage += 1
                filterMovies()
            } catch {
                self.output.error = error
            }
            
            output.isLoading = false
        }
    }
}
