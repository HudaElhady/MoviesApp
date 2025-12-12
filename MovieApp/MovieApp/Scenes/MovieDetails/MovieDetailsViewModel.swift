//
//  MovieDetailsViewModel.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//
import Foundation
import Combine

protocol MovieDetailsViewModelProtocol {
    var input: MovieDetailsViewModel.Input { get }
    var output: MovieDetailsViewModel.Output { get }
}

extension MovieDetailsViewModel {
    class Input: ObservableObject {
        var retryButtonTrigger = PassthroughSubject<Void, Never>()
    }
}

extension MovieDetailsViewModel {
    class Output: ObservableObject {
        @Published public var movieDetails: MovieDetails?
        @Published public var runtime: String = ""
        @Published public var budget: String = ""
        @Published public var revenue: String = ""
        @Published public var isLoading = false
        @Published public var error: Error?
    }
}

public final class MovieDetailsViewModel: MovieDetailsViewModelProtocol {
    var input: Input
    var output: Output

    private let movieId: Int
    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(movieId: Int, repository: MovieRepositoryProtocol = MovieRepository()) {
        self.input = .init()
        self.output = .init()
        self.movieId = movieId
        self.repository = repository
        
        setupObservers()
        setupOutputs()
        loadMovieDetails()
    }
}

private extension MovieDetailsViewModel {
    func setupObservers() {
        observerRetryButtonTrigger()
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
}

private extension MovieDetailsViewModel {
    func setupOutputs() {
        output.runtime = formatRuntime(output.movieDetails?.runtime)
        output.budget = formatCurrency(output.movieDetails?.budget)
        output.revenue = formatCurrency(output.movieDetails?.revenue)
    }
    
    func loadMovieDetails() {
        output.isLoading = true
        output.error = nil

        Task { @MainActor in
            do {
                output.movieDetails = try await repository.fetchMovieDetails(id: movieId)
            } catch {
                self.output.error = error
            }
            
            output.isLoading = false
        }
    }

    func retry() {
        output.error = nil
        loadMovieDetails()
    }
    
    func formatCurrency(_ amount: Int?) -> String {
        guard let amount = amount, amount > 0 else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "N/A"
    }

    func formatRuntime(_ minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else { return "N/A" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}
