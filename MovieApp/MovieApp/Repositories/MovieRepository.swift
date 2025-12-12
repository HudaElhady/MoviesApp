//
//  MovieRepository.swift
//  MovieApp
//
//  Created by huda elhady on 11/12/2025.
//

import Foundation

public protocol MovieRepositoryProtocol {
    func fetchMovies(page: Int) async throws -> MoviesResponse
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
    func fetchGenres() async throws -> [Genre]
}

public final class MovieRepository: MovieRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let cacheManager: CacheManager
    
    public init(
        networkClient: NetworkClientProtocol = NetworkClient(),
        cacheManager: CacheManager = .shared
    ) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
    }

    public func fetchMovies(page: Int) async throws -> MoviesResponse {
        let cacheKey = CacheKey.movies(page: page)
        if let cachedMovies: MoviesResponse = cacheManager.load(forKey: cacheKey, as: MoviesResponse.self) {
            return cachedMovies
        }

        let response: MoviesResponse = try await networkClient.request(MovieEndpoint.discoverMovies(page: page))

        cacheManager.save(response, forKey: cacheKey)
        
        return response
    }

    public func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let cacheKey = CacheKey.movieDetails(id: id)
        if let cachedDetails: MovieDetails = cacheManager.load(forKey: cacheKey, as: MovieDetails.self) {
            return cachedDetails
        }

        let details: MovieDetails = try await networkClient.request(MovieEndpoint.movieDetails(id: id))
        cacheManager.save(details, forKey: cacheKey)
        return details
    }

    public func fetchGenres() async throws -> [Genre] {
        let cacheKey = CacheKey.genres
        if let cachedGenres: [Genre] = cacheManager.load(forKey: cacheKey, as: [Genre].self) {
            return cachedGenres
        }

        let response: GenresResponse = try await networkClient.request(MovieEndpoint.genres)
        cacheManager.save(response.genres, forKey: cacheKey)
        
        return response.genres
    }
}
