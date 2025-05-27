//
//  Avatar.swift
//  GitHubClient
//
//  Created by Jakub on 28.05.25.
//

import SwiftUI

struct Avatar: View {
    let urlString: String?
    let size: CGFloat?
    let type: String
    
    var body: some View {
        CachedAsyncImage(url: URL(string: urlString!), transaction: .init(animation: .smooth)) {
            phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                if type == "Organization" {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 6))
                }
                
                if type == "User" {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            case .failure:
                if type == "Organization" {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.1))
                }
                
                if type == "User" {
                    Circle()
                        .foregroundStyle(.gray.opacity(0.1))
                }
            @unknown default:
                Circle()
                    .foregroundStyle(.gray.opacity(0.1))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    Avatar(urlString: "https://avatars.githubusercontent.com/u/21696393?v=4", size: 40, type: "User")
    Avatar(urlString: "https://avatars.githubusercontent.com/u/14985020?v=4", size: 40, type: "Organization")
}
