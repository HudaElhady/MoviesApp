//
//  MovieEndpoint.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//
import Foundation

public enum MovieEndpoint: Endpoint {
    case genres
    case discoverMovies(page: Int)
    case movieDetails(id: Int)
    
    public var baseURL: String {
        "https://api.themoviedb.org/3"
    }
    
    public var path: String {
        switch self {
        case .genres:
            return "/genre/movie/list"
        case .discoverMovies:
            return "/discover/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        .get
    }
    
    public var headers: [String: String]? {
        [
            "accept": "application/json",
            "Authorization": "Bearer \(MovieEndpointConfig.apiKey)"
        ]
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .genres:
            return nil
        case .discoverMovies(let page):
            return [
                URLQueryItem(name: "include_adult", value: "false"),
                URLQueryItem(name: "sort_by", value: "popularity.desc"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .movieDetails:
            return nil
        }
    }
}

public struct MovieEndpointConfig {
    public static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhZTA1ZWUxZGM0ZDJjNzg3NzY1MGU4NzJmNTcwYTdiMSIsIm5iZiI6MTUzMDA0MjQ1MS42Nywic3ViIjoiNWIzMjk4NTNjM2EzNjg1MzIwMDBmOTFkIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.Isvbq8QH8Zp6FNjitOBTS8cU9W5_eO2EQ6jqBMqt3E8"
    public static let imageBaseURL = "https://image.tmdb.org/t/p/"
    
//    public enum ImageSize: String {
//        case w92, w154, w185, w342, w500, w780, original
//    }
    
    public static func posterURL(path: String) -> URL? {
        URL(string: imageBaseURL + "w500" + path)
    }
}
