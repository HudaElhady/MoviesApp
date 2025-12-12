//
//  Movie.swift
//  MovieApp
//
//  Created by huda elhady on 11/12/2025.
//

public struct Movie: Identifiable, Codable, Equatable {
    public let id: Int
    public let title: String
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let genreIds: [Int]?
    public let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
    }
    
    public var releaseYear: String? {
        releaseDate?.prefix(4).description
    }
    
    public init(id: Int, title: String, overview: String?, posterPath: String?,
                backdropPath: String?, releaseDate: String?, genreIds: [Int]?,
                voteAverage: Double? ){
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.voteAverage = voteAverage
    }
}

public struct MovieDetails: Identifiable, Codable, Equatable {
    public let id: Int
    public let title: String
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let genres: [Genre]
    public let homepage: String?
    public let budget: Int?
    public let revenue: Int?
    public let runtime: Int?
    public let status: String?
    public let spokenLanguages: [SpokenLanguage]?
    public let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, homepage, budget, revenue, runtime, status
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case spokenLanguages = "spoken_languages"
        case voteAverage = "vote_average"
    }
    
    public var releaseYear: String? {
        releaseDate?.prefix(4).description
    }
    
    public var releaseYearMonth: String? {
        guard let date = releaseDate else { return nil }
        let components = date.split(separator: "-")
        guard components.count >= 2 else { return nil }
        return "\(components[0])-\(components[1])"
    }
}

public struct Genre: Identifiable, Codable, Equatable, Hashable {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct SpokenLanguage: Codable, Equatable {
    public let englishName: String
    public let iso639_1: String
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name
    }
}

public struct MoviesResponse: Codable {
    public let page: Int
    public let results: [Movie]
    public let totalPages: Int
    public let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

public struct GenresResponse: Codable {
    public let genres: [Genre]
}
