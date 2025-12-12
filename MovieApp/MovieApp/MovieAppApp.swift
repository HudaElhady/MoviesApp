//
//  MovieAppApp.swift
//  MovieApp
//
//  Created by huda elhady on 11/12/2025.
//

import SwiftUI

@main
struct MovieAppApp: App {
    var body: some Scene {
        WindowGroup {
            MovieListView(viewModel: MovieListViewModel())
        }
    }
}

