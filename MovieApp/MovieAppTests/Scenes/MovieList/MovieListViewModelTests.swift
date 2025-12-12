//
//  MovieListViewModelTests.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//

import XCTest
import Combine
@testable import MovieApp

final class MovieListViewModelTests: XCTestCase {
    
    var movieListViewModel: MovieListViewModel!
    var mockRepository: MockMovieRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        movieListViewModel = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitializerLoadsBothGenresAndMovies() async {
        // Given
        let expectedGenres = [Genre.mock(id: 1, name: "Action"), Genre.mock(id: 2, name: "Drama")]
        let expectedMovies = [Movie.mock(id: 1, title: "Movie 1"), Movie.mock(id: 2, title: "Movie 2")]
        
        mockRepository.genresToReturn = expectedGenres
        mockRepository.moviesToReturn = MoviesResponse(
            page: 1,
            results: expectedMovies,
            totalPages: 5,
            totalResults: 100
        )
        
        // When
        movieListViewModel = MovieListViewModel(repository: mockRepository)

        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(movieListViewModel.output.genres.count, 2)
        XCTAssertEqual(movieListViewModel.output.movies.count, 2)
        XCTAssertTrue(movieListViewModel.output.hasMorePages)
        XCTAssertFalse(movieListViewModel.output.isLoading)
    }
    
    func testInitializerGenreLoadingError() async {
        // Given
        mockRepository.genreError = URLError(.badURL)
        
        // When
        movieListViewModel = MovieListViewModel(repository: mockRepository)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(movieListViewModel.output.error)
        XCTAssertTrue(movieListViewModel.output.genres.isEmpty)
    }
  
    func testLoadMoviesPreventsManyDuplicateLoading() async {
        // Given
        mockRepository.moviesToReturn = MoviesResponse(
            page: 1,
            results: [Movie.mock(id: 1)],
            totalPages: 5,
            totalResults: 50
        )
        mockRepository.delayInSeconds = 0.5
        
        movieListViewModel = MovieListViewModel(repository: mockRepository)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When multiple loads quickly
        movieListViewModel.input.movieCardAppearTrigger.send(Movie.mock(id: 1))
        movieListViewModel.input.movieCardAppearTrigger.send(Movie.mock(id: 1))
        movieListViewModel.input.movieCardAppearTrigger.send(Movie.mock(id: 1))
        
        try? await Task.sleep(nanoseconds: 600_000_000)
    
        XCTAssertEqual(mockRepository.fetchMoviesCallCount, 1)
    }
  
    func testSearchTextFiltersMovies() async {
        // Given
        let movies = [
            Movie.mock(id: 1, title: "test-movie1"),
            Movie.mock(id: 2, title: "test-movie2"),
            Movie.mock(id: 3, title: "test-movie3")
        ]
        
        mockRepository.moviesToReturn = MoviesResponse(
            page: 1,
            results: movies,
            totalPages: 1,
            totalResults: 3
        )
        
        movieListViewModel = MovieListViewModel(repository: mockRepository)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        movieListViewModel.input.searchText = "movie"
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(movieListViewModel.output.filteredMovies.count, 3)

        movieListViewModel.input.searchText = "movie3"
        try? await Task.sleep(nanoseconds: 400_000_000)
    
        XCTAssertEqual(movieListViewModel.output.filteredMovies.count, 1)
        XCTAssertEqual(movieListViewModel.output.filteredMovies.first?.title, "test-movie3")
    }
   
    func testSelectGenreToggleGenre() async {
        // Given
        let actionGenre = Genre.mock(id: 28, name: "Action")
        
        mockRepository.genresToReturn = [actionGenre]
        mockRepository.moviesToReturn = MoviesResponse(
            page: 1,
            results: [Movie.mock(id: 1, genreIds: [28])],
            totalPages: 1,
            totalResults: 1
        )
        
        movieListViewModel = MovieListViewModel(repository: mockRepository)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When select genre
        movieListViewModel.input.selectGenresTrigger.send(actionGenre)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(movieListViewModel.output.selectedGenres.contains(28))
        
        // When toggle off
        movieListViewModel.input.selectGenresTrigger.send(actionGenre)
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertFalse(movieListViewModel.output.selectedGenres.contains(28))
        XCTAssertTrue(movieListViewModel.output.selectedGenres.isEmpty)
    }
}

// MARK: - Mock Repository

class MockMovieRepository: MovieRepositoryProtocol {
    var fetchMoviesCallCount = 0
    var fetchMoviesCalledWithPage: Int?
    var fetchGenresCallCount = 0
    
    var moviesToReturn: MoviesResponse?
    var genresToReturn: [Genre] = []
    
    var movieError: Error?
    var genreError: Error?
    
    var delayInSeconds: Double = 0
    
    func fetchMovies(page: Int) async throws -> MoviesResponse {
        fetchMoviesCallCount += 1
        fetchMoviesCalledWithPage = page
        
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }
        
        if let movieError {
            throw movieError
        }
        
        guard let response = moviesToReturn
        else {
            throw URLError.init(.badServerResponse)
        }
        
        return response
    }
    
    func fetchGenres() async throws -> [Genre] {
        fetchGenresCallCount += 1
        
        if delayInSeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
        }
        
        if let genreError {
            throw genreError
        }
        
        return genresToReturn
    }
    
    func fetchMovieDetails(id: Int) async throws -> MovieApp.MovieDetails {
        throw URLError.init(.unknown)
    }
}

// MARK: - Mock

extension Movie {
    static func mock(
        id: Int,
        title: String = "Mock Movie",
        genreIds: [Int]? = nil
    ) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "Mock overview",
            posterPath: "/mock.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2024-01-01",
            genreIds: genreIds,
            voteAverage: 7.5
        )
    }
}

extension Genre {
    static func mock(id: Int, name: String = "Mock Genre") -> Genre {
        Genre(id: id, name: name)
    }
}
