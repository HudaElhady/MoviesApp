//
//  CacheManager.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//
import Foundation

public final class CacheManager {
    public static let shared = CacheManager()

    private let cache = NSCache<NSString, CacheEntry>()
    private let expirationInterval: TimeInterval = 60 * 60 * 60

    public func save<T: Codable>(_ object: T, forKey key: String) {
        let entry = CacheEntry(
            data: object,
            expirationDate: Date().addingTimeInterval(expirationInterval)
        )
        cache.setObject(entry, forKey: key as NSString)
    }
    
    public func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }

        if Date() > entry.expirationDate {
            remove(forKey: key)
            return nil
        }
        
        return entry.data as? T
    }
    
    public func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func clearAll() {
        cache.removeAllObjects()
    }
}

private final class CacheEntry {
    let data: Any
    let expirationDate: Date
    
    init(data: Any, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
}

public enum CacheKey {
    static func movies(page: Int) -> String {
        "movies_page_\(page)"
    }
    
    static func movieDetails(id: Int) -> String {
        "movie_details_\(id)"
    }
    
    static let genres = "genres"
}
