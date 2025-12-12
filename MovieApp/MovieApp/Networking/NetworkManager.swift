//
//  NetworkManager.swift
//  MovieApp
//
//  Created by huda elhady on 11/12/2025.
//
import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Client Protocol
public protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// MARK: - Network Client
public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url
        else {
            throw URLError.init(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                throw URLError(.badServerResponse)
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw URLError(.cannotDecodeRawData)
            }
        } catch {
            throw URLError(.unknown)
        }
    }
}
