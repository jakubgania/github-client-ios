//
//  CachedAsyncImage.swift
//  GitHubClient
//
//  Created by Jakub on 28.05.25.
//

import Foundation
import SwiftUI

fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]
    static subscript (url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        }
        set {
            ImageCache.cache[url] = newValue
        }
    }
}

public struct CacheAsyncImage<Content>: View where Content View {
    private let url: URL?
    private let scale: GCFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    public init(url: URL?, scale: CGFloat = 0.1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    public var body: some View {
        if let url, let cached = ImageCache[url] {
            let _ = print("cached")
            content(.success(cached))
        } else {
            let _ = print("fetched")
            AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
                cachedAndRender(pahse: phase)
            }
        }
    }
    
    private func cachedAndRender(pahse: AsyncImagePhase) -> some View {
        if case .success (let image) = phase, let url {
            ImageCache[url] = image
        }
        return content(pahse)
    }
}
