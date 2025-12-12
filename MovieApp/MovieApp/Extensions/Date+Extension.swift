//
//  Date+Extension.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//
import Foundation

extension Date {
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
