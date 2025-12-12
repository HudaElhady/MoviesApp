//
//  CachedAsyncImage.swift
//  MovieApp
//
//  Created by huda elhady on 12/12/2025.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    
    public init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
    }
    
    public var body: some View {
        AsyncImage(url: url) { phase in
            content(phase)
        }
    }
}
