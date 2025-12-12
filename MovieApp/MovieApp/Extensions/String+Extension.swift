//
//  extension.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//
import Foundation

extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
